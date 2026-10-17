import secrets
from uuid import UUID

from fastapi import APIRouter, Depends, Header, HTTPException, Query, Response, status
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.db import get_db
from app.models import OrderStatus, PanelConnectionSettings, StoreOrder, StorePlan, StoreSettings
from app.panel.client import PanelConfigurationError, PanelRequestError
from app.panel.connection_settings import build_panel_client, decrypt_api_key, encrypt_api_key, normalize_panel_url
from app.schemas import (
    PanelConnectionPatch,
    PanelConnectionPublic,
    StorePlanAdmin,
    StorePlanCreate,
    StorePlanPatch,
    StoreSettingsPublic,
    StoreSettingsPatch,
    AdminOrderReview,
)

router = APIRouter(prefix="/api/v1/admin", tags=["admin"])


async def require_admin(authorization: str | None = Header(default=None, alias="Authorization")) -> None:
    expected = get_settings().admin_api_token.get_secret_value().strip()
    if not expected:
        raise HTTPException(status_code=503, detail="Admin API is not configured")
    scheme, separator, credential = (authorization or "").partition(" ")
    supplied = credential.strip() if separator and scheme.lower() == "bearer" else ""
    if not supplied or not secrets.compare_digest(supplied, expected):
        raise HTTPException(status_code=401, detail="Invalid admin credentials")


@router.get("/plans", response_model=list[StorePlanAdmin], dependencies=[Depends(require_admin)])
async def list_admin_plans(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(StorePlan).order_by(StorePlan.created_at.desc()))
    return result.scalars().all()


@router.post("/plans", response_model=StorePlanAdmin, status_code=status.HTTP_201_CREATED, dependencies=[Depends(require_admin)])
async def create_plan(payload: StorePlanCreate, db: AsyncSession = Depends(get_db)):
    plan = StorePlan(**payload.model_dump())
    db.add(plan)
    try:
        await db.commit()
        await db.refresh(plan)
    except IntegrityError as exc:
        await db.rollback()
        raise HTTPException(status_code=409, detail="A plan with this slug already exists") from exc
    return plan


@router.patch("/plans/{plan_id}", response_model=StorePlanAdmin, dependencies=[Depends(require_admin)])
async def patch_plan(plan_id: UUID, payload: StorePlanPatch, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(StorePlan).where(StorePlan.id == plan_id))
    plan = result.scalar_one_or_none()
    if plan is None:
        raise HTTPException(status_code=404, detail="Plan not found")
    changes = payload.model_dump(exclude_unset=True)
    required = {"slug", "name", "price_minor", "currency", "duration_seconds", "data_limit_bytes", "panel_template_id", "is_active"}
    if any(key in changes and changes[key] is None for key in required):
        raise HTTPException(status_code=422, detail="Required plan fields cannot be null")
    for key, value in changes.items():
        setattr(plan, key, value)
    try:
        await db.commit()
        await db.refresh(plan)
    except IntegrityError as exc:
        await db.rollback()
        raise HTTPException(status_code=409, detail="Plan update conflicts with existing data") from exc
    return plan


@router.get("/settings", response_model=StoreSettingsPublic, dependencies=[Depends(require_admin)])
async def get_store_settings(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(StoreSettings).where(StoreSettings.id == 1))
    settings = result.scalar_one_or_none()
    if settings is None:
        raise HTTPException(status_code=503, detail="Store settings are not initialized; apply database migrations")
    return settings


@router.patch("/settings", response_model=StoreSettingsPublic, dependencies=[Depends(require_admin)])
async def patch_store_settings(payload: StoreSettingsPatch, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(StoreSettings).where(StoreSettings.id == 1))
    settings = result.scalar_one_or_none()
    if settings is None:
        raise HTTPException(status_code=503, detail="Store settings are not initialized; apply database migrations")
    changes = payload.model_dump(exclude_unset=True)
    required = {"store_name", "store_description", "default_currency", "maintenance_mode", "card_transfer_enabled", "card_holder_name", "card_number", "card_bank_name", "card_transfer_instructions"}
    if any(key in changes and changes[key] is None for key in required):
        raise HTTPException(status_code=422, detail="Required store settings cannot be null")
    for key, value in changes.items():
        setattr(settings, key, value)
    try:
        await db.commit()
        await db.refresh(settings)
    except Exception as exc:
        await db.rollback()
        raise HTTPException(status_code=503, detail="Could not save store settings") from exc
    return settings


@router.get("/orders", dependencies=[Depends(require_admin)])
async def list_orders(limit: int = Query(default=100, ge=1, le=200), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(StoreOrder).order_by(StoreOrder.created_at.desc()).limit(limit))
    orders = result.scalars().all()
    output = []
    for order in orders:
        plan_result = await db.execute(select(StorePlan).where(StorePlan.id == order.plan_id))
        plan = plan_result.scalar_one_or_none()
        output.append({
            "id": str(order.id), "status": order.status, "amount_minor": order.amount_minor,
            "currency": order.currency, "plan_name": plan.name if plan else "Unknown plan",
            "customer_reference": order.customer_reference or order.customer_id,
            "receipt_filename": order.receipt_filename, "receipt_content_type": order.receipt_content_type,
            "receipt_sha256": order.receipt_sha256,
            "receipt_uploaded_at": order.receipt_uploaded_at.isoformat() if order.receipt_uploaded_at else None,
            "admin_note": order.admin_note, "created_at": order.created_at.isoformat() if order.created_at else "",
        })
    return output


@router.get("/orders/{order_id}/receipt", dependencies=[Depends(require_admin)])
async def get_order_receipt(order_id: UUID, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(StoreOrder).where(StoreOrder.id == order_id))
    order = result.scalar_one_or_none()
    if order is None or not order.receipt_data or not order.receipt_content_type:
        raise HTTPException(status_code=404, detail="Receipt not found")
    if order.receipt_content_type not in {"image/jpeg", "image/png", "image/webp", "application/pdf"}:
        raise HTTPException(status_code=415, detail="Unsupported receipt type")
    disposition = "inline" if order.receipt_content_type.startswith("image/") else "attachment"
    return Response(content=order.receipt_data, media_type=order.receipt_content_type, headers={
        "Content-Disposition": f'{disposition}; filename="{order.receipt_filename or "receipt"}"',
        "Cache-Control": "no-store, max-age=0", "X-Content-Type-Options": "nosniff",
    })


@router.post("/orders/{order_id}/review", dependencies=[Depends(require_admin)])
async def review_order(order_id: UUID, payload: AdminOrderReview, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(StoreOrder).where(StoreOrder.id == order_id))
    order = result.scalar_one_or_none()
    if order is None:
        raise HTTPException(status_code=404, detail="Order not found")
    if order.status != "pending_review":
        raise HTTPException(status_code=409, detail="Only orders awaiting receipt review can be reviewed")
    order.admin_note = payload.note.strip() if payload.note else None
    if payload.action == "approve":
        # This marks the transfer as manually verified. Provisioning remains a separate, explicit phase.
        order.status = OrderStatus.paid_pending_provisioning.value
    else:
        order.status = "rejected"
    await db.commit()
    return {"order_id": str(order.id), "status": order.status, "message": "Transfer approved; provisioning still pending" if payload.action == "approve" else "Receipt rejected"}


@router.get("/panel/connection", response_model=PanelConnectionPublic, dependencies=[Depends(require_admin)])
async def get_panel_connection(db: AsyncSession = Depends(get_db)):
    settings = get_settings()
    result = await db.execute(select(PanelConnectionSettings).where(PanelConnectionSettings.id == 1))
    stored = result.scalar_one_or_none()
    encryption_ready = bool(settings.panel_settings_encryption_key.get_secret_value().strip())
    if stored is not None:
        return {"base_url": stored.base_url, "api_key_configured": True, "encryption_ready": encryption_ready}
    return {
        "base_url": settings.panel_base_url,
        "api_key_configured": bool(settings.panel_api_key.get_secret_value().strip()),
        "encryption_ready": encryption_ready,
    }


@router.patch("/panel/connection", response_model=PanelConnectionPublic, dependencies=[Depends(require_admin)])
async def patch_panel_connection(payload: PanelConnectionPatch, db: AsyncSession = Depends(get_db)):
    settings = get_settings()
    changes = payload.model_dump(exclude_unset=True)
    if not changes:
        raise HTTPException(status_code=422, detail="Provide a panel URL or a new API key")
    result = await db.execute(select(PanelConnectionSettings).where(PanelConnectionSettings.id == 1))
    stored = result.scalar_one_or_none()
    current_url = stored.base_url if stored is not None else settings.panel_base_url
    try:
        base_url = normalize_panel_url(changes.get("base_url") or current_url)
        if "api_key" in changes and changes["api_key"] is not None:
            encrypted_key = encrypt_api_key(changes["api_key"], settings)
        elif stored is not None:
            # Verify the configured encryption key before retaining the existing ciphertext.
            decrypt_api_key(stored.api_key_encrypted, settings)
            encrypted_key = stored.api_key_encrypted
        else:
            raise HTTPException(status_code=422, detail="An API key is required when configuring the panel for the first time")
    except PanelConfigurationError as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc
    if stored is None:
        stored = PanelConnectionSettings(id=1, base_url=base_url, api_key_encrypted=encrypted_key)
        db.add(stored)
    else:
        stored.base_url = base_url
        stored.api_key_encrypted = encrypted_key
    try:
        await db.commit()
        await db.refresh(stored)
    except Exception as exc:
        await db.rollback()
        raise HTTPException(status_code=503, detail="Could not save panel connection settings") from exc
    return {"base_url": stored.base_url, "api_key_configured": True, "encryption_ready": True}


@router.get("/panel/templates", dependencies=[Depends(require_admin)])
async def list_panel_templates(limit: int = Query(default=100, ge=1, le=200), offset: int = Query(default=0, ge=0, le=1000000), db: AsyncSession = Depends(get_db)):
    """Return a deliberately small allowlist of template metadata, never raw panel payloads."""
    try:
        panel = await build_panel_client(db, get_settings())
        templates = await panel.list_templates(limit=limit, offset=offset)
    except PanelConfigurationError as exc:
        raise HTTPException(status_code=503, detail="Panel integration is not configured") from exc
    except PanelRequestError as exc:
        raise HTTPException(status_code=502, detail="Could not retrieve templates from panel") from exc
    safe_templates = []
    for item in templates:
        if not isinstance(item, dict):
            continue
        template_id = item.get("id", item.get("user_template_id"))
        if not isinstance(template_id, int) or template_id < 1:
            continue
        name = item.get("name", item.get("remark", item.get("template_name", "")))
        description = item.get("description")
        safe_templates.append({
            "id": template_id,
            "name": str(name)[:160] if name is not None else "",
            "description": str(description)[:500] if description is not None else None,
        })
    return {"items": safe_templates, "limit": limit, "offset": offset}


@router.post("/panel/test-connection", dependencies=[Depends(require_admin)])
async def test_panel_connection(db: AsyncSession = Depends(get_db)):
    """Read-only connectivity check; never returns credentials or raw panel responses."""
    try:
        panel = await build_panel_client(db, get_settings())
        result = await panel.test_connection()
    except PanelConfigurationError as exc:
        raise HTTPException(status_code=503, detail="Panel integration is not configured") from exc
    return {"ok": result.ok, "status_code": result.status_code, "message": result.message}
