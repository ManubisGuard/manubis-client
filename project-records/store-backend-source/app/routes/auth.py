import asyncio
import base64
import hashlib
import hmac
import ipaddress
import re
import secrets
import time
from collections import defaultdict, deque
from datetime import datetime, timedelta, timezone
from uuid import UUID

from fastapi import APIRouter, Depends, Header, HTTPException, Request, status
from sqlalchemy import select
from sqlalchemy.orm import load_only, selectinload
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.db import get_db
from app.models import StoreOrder, StorePlan, StoreSession, StoreUser, utcnow
from app.schemas import AccountCredentials, AccountOrderPublic, AccountPublic, AccountSessionResponse

router = APIRouter(prefix="/api/v1/auth", tags=["account"])
SESSION_LIFETIME = timedelta(days=30)
PBKDF2_ITERATIONS = 310_000
RATE_WINDOW_SECONDS = 900
RATE_MAX_ATTEMPTS = 8
_rate_lock = asyncio.Lock()
_rate_events: dict[str, deque[float]] = defaultdict(deque)


async def enforce_rate_limit(request: Request, action: str, identity: str) -> None:
    # X-Real-IP is set by the local Nginx reverse proxy; do not trust a client-supplied X-Forwarded-For chain.
    candidate = request.headers.get("x-real-ip", "").strip()
    try:
        ip = str(ipaddress.ip_address(candidate)) if candidate else (request.client.host if request.client else "unknown")
    except ValueError:
        ip = request.client.host if request.client else "unknown"
    now = time.monotonic()
    keys = [f"{action}:ip:{ip}", f"{action}:identity:{identity}"]
    async with _rate_lock:
        if len(_rate_events) > 4096:
            for old_key, old_events in list(_rate_events.items()):
                if not old_events or now - old_events[-1] > RATE_WINDOW_SECONDS:
                    _rate_events.pop(old_key, None)
            while len(_rate_events) > 4096:
                _rate_events.pop(next(iter(_rate_events)))
        for key in keys:
            events = _rate_events[key]
            while events and now - events[0] > RATE_WINDOW_SECONDS:
                events.popleft()
            if len(events) >= RATE_MAX_ATTEMPTS:
                raise HTTPException(status_code=429, detail="Too many attempts. Please wait 15 minutes and try again.", headers={"Retry-After": "900"})
        for key in keys:
            _rate_events[key].append(now)


def hash_password(password: str, salt: bytes | None = None) -> str:
    salt = salt or secrets.token_bytes(16)
    digest = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt, PBKDF2_ITERATIONS)
    enc = lambda value: base64.urlsafe_b64encode(value).decode("ascii").rstrip("=")
    return f"pbkdf2_sha256${PBKDF2_ITERATIONS}${enc(salt)}${enc(digest)}"


def verify_password(password: str, encoded: str) -> bool:
    try:
        algorithm, iterations, salt_text, digest_text = encoded.split("$", 3)
        if algorithm != "pbkdf2_sha256" or int(iterations) < 100_000 or int(iterations) > 2_000_000:
            return False
        dec = lambda value: base64.urlsafe_b64decode(value + "=" * (-len(value) % 4))
        expected = dec(digest_text)
        actual = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), dec(salt_text), int(iterations))
        return hmac.compare_digest(actual, expected)
    except (ValueError, TypeError):
        return False


def token_digest(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def public_user(user: StoreUser) -> AccountPublic:
    return AccountPublic(id=user.id, username=user.username, created_at=user.created_at.isoformat())


async def create_session(db: AsyncSession, user: StoreUser) -> AccountSessionResponse:
    token = secrets.token_urlsafe(32)
    expires = utcnow() + SESSION_LIFETIME
    db.add(StoreSession(user_id=user.id, token_hash=token_digest(token), expires_at=expires))
    await db.commit()
    return AccountSessionResponse(access_token=token, expires_at=expires.isoformat(), user=public_user(user))


async def optional_current_user(
    authorization: str | None = Header(default=None, alias="Authorization"),
    db: AsyncSession = Depends(get_db),
) -> StoreUser | None:
    if not authorization:
        return None
    scheme, sep, token = authorization.partition(" ")
    if not sep or scheme.lower() != "bearer" or not token.strip():
        raise HTTPException(status_code=401, detail="Invalid session")
    result = await db.execute(
        select(StoreSession).options(selectinload(StoreSession.user)).where(
            StoreSession.token_hash == token_digest(token.strip()), StoreSession.revoked_at.is_(None)
        )
    )
    session = result.scalar_one_or_none()
    if session is None or session.expires_at <= utcnow() or not session.user.is_active:
        raise HTTPException(status_code=401, detail="Session expired; sign in again")
    return session.user


@router.post("/register", response_model=AccountSessionResponse, status_code=status.HTTP_201_CREATED)
async def register(payload: AccountCredentials, request: Request, db: AsyncSession = Depends(get_db)):
    await enforce_rate_limit(request, "register", payload.username)
    user = StoreUser(username=payload.username, password_hash=hash_password(payload.password))
    db.add(user)
    try:
        await db.flush()
        result = await create_session(db, user)
    except IntegrityError as exc:
        await db.rollback()
        raise HTTPException(status_code=409, detail="Username is already registered") from exc
    return result


@router.post("/login", response_model=AccountSessionResponse)
async def login(payload: AccountCredentials, request: Request, db: AsyncSession = Depends(get_db)):
    await enforce_rate_limit(request, "login", payload.username)
    result = await db.execute(select(StoreUser).where(StoreUser.username == payload.username))
    user = result.scalar_one_or_none()
    if user is None:
        # Reduce timing differences for unknown usernames.
        verify_password(payload.password, hash_password("not-the-user-password"))
        raise HTTPException(status_code=401, detail="Username or password is incorrect")
    if not user.is_active or not verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Username or password is incorrect")
    return await create_session(db, user)


@router.get("/me", response_model=AccountPublic)
async def get_me(user: StoreUser = Depends(optional_current_user)):
    if user is None:
        raise HTTPException(status_code=401, detail="Sign in required")
    return public_user(user)


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(
    authorization: str | None = Header(default=None, alias="Authorization"),
    db: AsyncSession = Depends(get_db),
):
    scheme, sep, token = (authorization or "").partition(" ")
    if sep and scheme.lower() == "bearer" and token.strip():
        result = await db.execute(select(StoreSession).where(StoreSession.token_hash == token_digest(token.strip())))
        session = result.scalar_one_or_none()
        if session is not None and session.revoked_at is None:
            session.revoked_at = utcnow()
            await db.commit()
    return None


@router.get("/me/orders", response_model=list[AccountOrderPublic])
async def my_orders(user: StoreUser = Depends(optional_current_user), db: AsyncSession = Depends(get_db)):
    if user is None:
        raise HTTPException(status_code=401, detail="Sign in required")
    result = await db.execute(
        select(StoreOrder)
        .options(load_only(
            StoreOrder.id, StoreOrder.user_id, StoreOrder.plan_id, StoreOrder.status,
            StoreOrder.amount_minor, StoreOrder.currency, StoreOrder.customer_reference,
            StoreOrder.created_at, StoreOrder.receipt_filename,
        ))
        .where(StoreOrder.user_id == user.id)
        .order_by(StoreOrder.created_at.desc())
        .limit(100)
    )
    orders = result.scalars().all()
    output = []
    for order in orders:
        plan_result = await db.execute(select(StorePlan).where(StorePlan.id == order.plan_id))
        plan = plan_result.scalar_one_or_none()
        output.append(AccountOrderPublic(
            id=order.id, status=order.status, amount_minor=order.amount_minor, currency=order.currency,
            plan_name=plan.name if plan else "Unknown plan", customer_reference=order.customer_reference,
            receipt_submitted=bool(order.receipt_filename), created_at=order.created_at.isoformat(),
        ))
    return output
