from datetime import datetime, timezone
from enum import StrEnum
from uuid import UUID, uuid4

from sqlalchemy import BigInteger, Boolean, CheckConstraint, DateTime, ForeignKey, Integer, LargeBinary, String, Text, UniqueConstraint, Uuid
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db import Base


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


class OrderStatus(StrEnum):
    pending_payment = "pending_payment"
    pending_review = "pending_review"
    rejected = "rejected"
    paid_pending_provisioning = "paid_pending_provisioning"
    fulfilled = "fulfilled"
    cancelled = "cancelled"
    failed = "failed"
    refunded = "refunded"


class StoreUser(Base):
    __tablename__ = "store_users"

    id: Mapped[UUID] = mapped_column(Uuid, primary_key=True, default=uuid4)
    username: Mapped[str] = mapped_column(String(32), unique=True, index=True)
    password_hash: Mapped[str] = mapped_column(String(256))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class StoreSession(Base):
    __tablename__ = "store_sessions"

    id: Mapped[UUID] = mapped_column(Uuid, primary_key=True, default=uuid4)
    user_id: Mapped[UUID] = mapped_column(ForeignKey("store_users.id", ondelete="CASCADE"), index=True)
    token_hash: Mapped[str] = mapped_column(String(64), unique=True, index=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), index=True)
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    user: Mapped[StoreUser] = relationship()


class StoreSettings(Base):
    __tablename__ = "store_settings"
    __table_args__ = (CheckConstraint("id = 1", name="ck_store_settings_singleton"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, default=1)
    store_name: Mapped[str] = mapped_column(String(120), default="ManubisGuard Store")
    store_description: Mapped[str] = mapped_column(Text, default="")
    default_currency: Mapped[str] = mapped_column(String(3), default="IRR")
    support_url: Mapped[str | None] = mapped_column(String(2048), nullable=True)
    maintenance_mode: Mapped[bool] = mapped_column(Boolean, default=False)
    card_transfer_enabled: Mapped[bool] = mapped_column(Boolean, default=False)
    card_holder_name: Mapped[str] = mapped_column(String(120), default="")
    card_number: Mapped[str] = mapped_column(String(32), default="")
    card_bank_name: Mapped[str] = mapped_column(String(120), default="")
    card_transfer_instructions: Mapped[str] = mapped_column(Text, default="")
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, onupdate=utcnow)


class PanelConnectionSettings(Base):
    __tablename__ = "panel_connection_settings"
    __table_args__ = (CheckConstraint("id = 1", name="ck_panel_connection_singleton"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, default=1)
    base_url: Mapped[str] = mapped_column(String(2048))
    api_key_encrypted: Mapped[str] = mapped_column(Text)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, onupdate=utcnow)


class StorePlan(Base):
    __tablename__ = "store_plans"
    __table_args__ = (
        CheckConstraint("price_minor >= 0", name="ck_store_plan_price_nonnegative"),
        CheckConstraint("duration_seconds > 0", name="ck_store_plan_duration_positive"),
        CheckConstraint("data_limit_bytes >= 0", name="ck_store_plan_data_nonnegative"),
    )

    id: Mapped[UUID] = mapped_column(Uuid, primary_key=True, default=uuid4)
    slug: Mapped[str] = mapped_column(String(80), unique=True, index=True)
    name: Mapped[str] = mapped_column(String(120))
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    price_minor: Mapped[int] = mapped_column(BigInteger)
    currency: Mapped[str] = mapped_column(String(3), default="IRR")
    duration_seconds: Mapped[int] = mapped_column(BigInteger)
    data_limit_bytes: Mapped[int] = mapped_column(BigInteger)
    panel_template_id: Mapped[int] = mapped_column(Integer)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, onupdate=utcnow)


class StoreOrder(Base):
    __tablename__ = "store_orders"
    __table_args__ = (
        UniqueConstraint("customer_id", "idempotency_key", name="uq_order_customer_idempotency"),
        UniqueConstraint("provider", "provider_transaction_id", name="uq_order_provider_transaction"),
        CheckConstraint("amount_minor >= 0", name="ck_order_amount_nonnegative"),
        CheckConstraint("status IN ('pending_payment', 'pending_review', 'rejected', 'paid_pending_provisioning', 'fulfilled', 'cancelled', 'failed', 'refunded')", name="ck_store_order_status_valid"),
    )

    id: Mapped[UUID] = mapped_column(Uuid, primary_key=True, default=uuid4)
    customer_id: Mapped[str] = mapped_column(String(128), index=True)
    user_id: Mapped[UUID | None] = mapped_column(ForeignKey("store_users.id", ondelete="SET NULL"), nullable=True, index=True)
    plan_id: Mapped[UUID] = mapped_column(ForeignKey("store_plans.id", ondelete="RESTRICT"))
    amount_minor: Mapped[int] = mapped_column(BigInteger)
    currency: Mapped[str] = mapped_column(String(3))
    status: Mapped[str] = mapped_column(String(40), default=OrderStatus.pending_payment.value, index=True)
    idempotency_key: Mapped[str] = mapped_column(String(128))
    provider: Mapped[str | None] = mapped_column(String(40), nullable=True)
    provider_transaction_id: Mapped[str | None] = mapped_column(String(200), nullable=True)
    panel_username: Mapped[str | None] = mapped_column(String(64), nullable=True)
    customer_reference: Mapped[str] = mapped_column(String(120), default="")
    receipt_token_hash: Mapped[str | None] = mapped_column(String(64), nullable=True, index=True)
    receipt_filename: Mapped[str | None] = mapped_column(String(180), nullable=True)
    receipt_content_type: Mapped[str | None] = mapped_column(String(80), nullable=True)
    receipt_data: Mapped[bytes | None] = mapped_column(LargeBinary, nullable=True)
    receipt_sha256: Mapped[str | None] = mapped_column(String(64), nullable=True)
    receipt_uploaded_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    admin_note: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, onupdate=utcnow)

    plan: Mapped[StorePlan] = relationship()
