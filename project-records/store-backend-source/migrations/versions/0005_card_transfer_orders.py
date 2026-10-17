"""Add manual card transfer payment and receipt review workflow.

Revision ID: 0005_card_transfer_orders
Revises: 0004_panel_connection_settings
"""
from alembic import op
import sqlalchemy as sa

revision = "0005_card_transfer_orders"
down_revision = "0004_panel_connection_settings"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("store_settings", sa.Column("card_transfer_enabled", sa.Boolean(), nullable=False, server_default=sa.false()))
    op.add_column("store_settings", sa.Column("card_holder_name", sa.String(length=120), nullable=False, server_default=""))
    op.add_column("store_settings", sa.Column("card_number", sa.String(length=32), nullable=False, server_default=""))
    op.add_column("store_settings", sa.Column("card_bank_name", sa.String(length=120), nullable=False, server_default=""))
    op.add_column("store_settings", sa.Column("card_transfer_instructions", sa.Text(), nullable=False, server_default=""))
    op.add_column("store_orders", sa.Column("customer_reference", sa.String(length=120), nullable=False, server_default=""))
    op.add_column("store_orders", sa.Column("receipt_token_hash", sa.String(length=64), nullable=True))
    op.add_column("store_orders", sa.Column("receipt_filename", sa.String(length=180), nullable=True))
    op.add_column("store_orders", sa.Column("receipt_content_type", sa.String(length=80), nullable=True))
    op.add_column("store_orders", sa.Column("receipt_data", sa.LargeBinary(), nullable=True))
    op.add_column("store_orders", sa.Column("receipt_sha256", sa.String(length=64), nullable=True))
    op.add_column("store_orders", sa.Column("receipt_uploaded_at", sa.DateTime(timezone=True), nullable=True))
    op.add_column("store_orders", sa.Column("admin_note", sa.Text(), nullable=True))
    op.create_index("ix_store_orders_receipt_token_hash", "store_orders", ["receipt_token_hash"], unique=False)
    op.drop_constraint("ck_store_order_status_valid", "store_orders", type_="check")
    op.create_check_constraint("ck_store_order_status_valid", "store_orders", "status IN ('pending_payment', 'pending_review', 'rejected', 'paid_pending_provisioning', 'fulfilled', 'cancelled', 'failed', 'refunded')")


def downgrade() -> None:
    op.drop_constraint("ck_store_order_status_valid", "store_orders", type_="check")
    op.create_check_constraint("ck_store_order_status_valid", "store_orders", "status IN ('pending_payment', 'paid_pending_provisioning', 'fulfilled', 'cancelled', 'failed', 'refunded')")
    op.drop_index("ix_store_orders_receipt_token_hash", table_name="store_orders")
    for name in ("admin_note", "receipt_uploaded_at", "receipt_sha256", "receipt_data", "receipt_content_type", "receipt_filename", "receipt_token_hash", "customer_reference"):
        op.drop_column("store_orders", name)
    for name in ("card_transfer_instructions", "card_bank_name", "card_number", "card_holder_name", "card_transfer_enabled"):
        op.drop_column("store_settings", name)
