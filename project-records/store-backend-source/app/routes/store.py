import base64
import binascii
import hashlib
import re
import secrets
from datetime import datetime, timezone
from uuid import uuid4

from fastapi import APIRouter, Depends, Header, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db import get_db
from app.models import OrderStatus, StoreOrder, StorePlan, StoreSettings, StoreUser
from app.schemas import (ReceiptUpload, StoreOrderCreate, StoreOrderCreateResponse, StorePlanPublic,
                         StoreSettingsPublic)
from app.routes.auth import optional_current_user

router = APIRouter(prefix="/api/v1/store", tags=["store"])
MAX_RECEIPT_BYTES = 5 * 1024 * 1024


@router.get("/plans", response_model=list[StorePlanPublic])
async def list_public_plans(db: AsyncSession = Depends(get_db)) -> list[StorePlanPublic]:
    try:
        result = await db.execute(select(StorePlan).where(StorePlan.is_active.is_(True)).order_by(StorePlan.price_minor.asc(), StorePlan.name.asc()))
        plans = result.scalars().all()
    except Exception as exc:
        raise HTTPException(status_code=503, detail="Store catalogue temporarily unavailable") from exc
    return [StorePlanPublic.model_validate(plan) for plan in plans]


@router.get("/settings", response_model=StoreSettingsPublic)
async def get_public_store_settings(db: AsyncSession = Depends(get_db)) -> StoreSettingsPublic:
    try:
        result = await db.execute(select(StoreSettings).where(StoreSettings.id == 1))
        settings = result.scalar_one_or_none()
    except Exception as exc:
        raise HTTPException(status_code=503, detail="Store settings temporarily unavailable") from exc
    if settings is None:
        raise HTTPException(status_code=503, detail="Store settings are not initialized")
    public_settings = StoreSettingsPublic.model_validate(settings)
    if not settings.card_transfer_enabled:
        public_settings.card_number = ""
        public_settings.card_holder_name = ""
        public_settings.card_bank_name = ""
        public_settings.card_transfer_instructions = ""
    return public_settings


@router.post("/orders", response_model=StoreOrderCreateResponse, status_code=status.HTTP_201_CREATED)
async def create_card_transfer_order(payload: StoreOrderCreate, user: StoreUser | None = Depends(optional_current_user), db: AsyncSession = Depends(get_db)):
    settings_result = await db.execute(select(StoreSettings).where(StoreSettings.id == 1))
    settings = settings_result.scalar_one_or_none()
    if settings is None or settings.maintenance_mode:
        raise HTTPException(status_code=503, detail="Store is temporarily unavailable")
    digits = re.sub(r"[\s-]", "", settings.card_number or "")
    if not settings.card_transfer_enabled or not settings.card_holder_name.strip() or not re.fullmatch(r"[0-9]{16,19}", digits):
        raise HTTPException(status_code=503, detail="Card-to-card payment is not configured yet")
    plan_result = await db.execute(select(StorePlan).where(StorePlan.id == payload.plan_id, StorePlan.is_active.is_(True)))
    plan = plan_result.scalar_one_or_none()
    if plan is None:
        raise HTTPException(status_code=404, detail="Active plan not found")
    receipt_token = secrets.token_urlsafe(32)
    order = StoreOrder(
        id=uuid4(), customer_id=str(user.id) if user else payload.customer_reference.strip()[:128],
        user_id=user.id if user else None, customer_reference=payload.customer_reference.strip(), plan_id=plan.id,
        amount_minor=plan.price_minor, currency=plan.currency, status=OrderStatus.pending_payment.value,
        idempotency_key=secrets.token_urlsafe(24), provider="card_transfer",
        receipt_token_hash=hashlib.sha256(receipt_token.encode()).hexdigest(),
    )
    db.add(order)
    try:
        await db.commit()
    except Exception as exc:
        await db.rollback()
        raise HTTPException(status_code=503, detail="Could not create order") from exc
    return StoreOrderCreateResponse(
        order_id=order.id, receipt_token=receipt_token, status=order.status, amount_minor=plan.price_minor,
        currency=plan.currency, plan_name=plan.name, card_transfer_enabled=True,
        card_holder_name=settings.card_holder_name, card_number=digits, card_bank_name=settings.card_bank_name,
        card_transfer_instructions=settings.card_transfer_instructions,
    )


@router.post("/orders/{order_id}/receipt", status_code=status.HTTP_202_ACCEPTED)
async def submit_payment_receipt(order_id: str, payload: ReceiptUpload, x_receipt_token: str | None = Header(default=None, alias="X-Receipt-Token"), db: AsyncSession = Depends(get_db)):
    from uuid import UUID
    try:
        parsed_id = UUID(order_id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail="Order not found") from exc
    if not x_receipt_token or len(x_receipt_token) < 32:
        raise HTTPException(status_code=401, detail="Receipt token required")
    token_hash = hashlib.sha256(x_receipt_token.encode()).hexdigest()
    result = await db.execute(select(StoreOrder).where(StoreOrder.id == parsed_id, StoreOrder.receipt_token_hash == token_hash))
    order = result.scalar_one_or_none()
    if order is None:
        raise HTTPException(status_code=404, detail="Order not found")
    if order.status not in {OrderStatus.pending_payment.value, "rejected"}:
        raise HTTPException(status_code=409, detail="Receipt cannot be changed in the current order state")
    try:
        raw = base64.b64decode(payload.content_base64, validate=True)
    except (binascii.Error, ValueError) as exc:
        raise HTTPException(status_code=422, detail="Receipt data is not valid base64") from exc
    if not raw or len(raw) > MAX_RECEIPT_BYTES:
        raise HTTPException(status_code=413, detail="Receipt must be no larger than 5 MiB")
    signatures = {
        "image/jpeg": raw.startswith(b"\xff\xd8\xff"),
        "image/png": raw.startswith(b"\x89PNG\r\n\x1a\n"),
        "image/webp": len(raw) >= 12 and raw[:4] == b"RIFF" and raw[8:12] == b"WEBP",
        "application/pdf": raw.startswith(b"%PDF-"),
    }
    if not signatures.get(payload.content_type, False):
        raise HTTPException(status_code=422, detail="Receipt file content does not match its declared type")
    safe_name = re.sub(r"[^A-Za-z0-9._ -]", "_", payload.filename)[:180] or "receipt"
    if payload.transfer_reference:
        order.customer_reference = (order.customer_reference + " | Ref: " + payload.transfer_reference.strip())[:120]
    order.receipt_filename = safe_name
    order.receipt_content_type = payload.content_type
    order.receipt_data = raw
    order.receipt_sha256 = hashlib.sha256(raw).hexdigest()
    order.receipt_uploaded_at = datetime.now(timezone.utc)
    order.status = "pending_review"
    order.admin_note = None
    await db.commit()
    return {"order_id": str(order.id), "status": order.status, "message": "Receipt submitted for manual review"}
