"""Create initial store plan and order tables."""
from alembic import op
import sqlalchemy as sa

revision = "0001_initial_store_tables"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "store_plans",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("slug", sa.String(length=80), nullable=False),
        sa.Column("name", sa.String(length=120), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("price_minor", sa.BigInteger(), nullable=False),
        sa.Column("currency", sa.String(length=3), nullable=False),
        sa.Column("duration_seconds", sa.BigInteger(), nullable=False),
        sa.Column("data_limit_bytes", sa.BigInteger(), nullable=False),
        sa.Column("panel_template_id", sa.Integer(), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint("price_minor >= 0", name="ck_store_plan_price_nonnegative"),
        sa.CheckConstraint("duration_seconds > 0", name="ck_store_plan_duration_positive"),
        sa.CheckConstraint("data_limit_bytes >= 0", name="ck_store_plan_data_nonnegative"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_store_plans_slug", "store_plans", ["slug"], unique=True)
    op.create_index("ix_store_plans_is_active", "store_plans", ["is_active"], unique=False)

    op.create_table(
        "store_orders",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("customer_id", sa.String(length=128), nullable=False),
        sa.Column("plan_id", sa.Uuid(), nullable=False),
        sa.Column("amount_minor", sa.BigInteger(), nullable=False),
        sa.Column("currency", sa.String(length=3), nullable=False),
        sa.Column("status", sa.String(length=40), nullable=False),
        sa.Column("idempotency_key", sa.String(length=128), nullable=False),
        sa.Column("provider", sa.String(length=40), nullable=True),
        sa.Column("provider_transaction_id", sa.String(length=200), nullable=True),
        sa.Column("panel_username", sa.String(length=64), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint("amount_minor >= 0", name="ck_order_amount_nonnegative"),
        sa.ForeignKeyConstraint(["plan_id"], ["store_plans.id"], ondelete="RESTRICT"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("customer_id", "idempotency_key", name="uq_order_customer_idempotency"),
        sa.UniqueConstraint("provider", "provider_transaction_id", name="uq_order_provider_transaction"),
    )
    op.create_index("ix_store_orders_customer_id", "store_orders", ["customer_id"], unique=False)
    op.create_index("ix_store_orders_status", "store_orders", ["status"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_store_orders_status", table_name="store_orders")
    op.drop_index("ix_store_orders_customer_id", table_name="store_orders")
    op.drop_table("store_orders")
    op.drop_index("ix_store_plans_is_active", table_name="store_plans")
    op.drop_index("ix_store_plans_slug", table_name="store_plans")
    op.drop_table("store_plans")
