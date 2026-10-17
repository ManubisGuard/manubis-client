"""Add persistent public store settings.

Revision ID: 0003_store_settings
Revises: 0002_order_status_constraint
"""
from alembic import op
import sqlalchemy as sa

revision = "0003_store_settings"
down_revision = "0002_order_status_constraint"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "store_settings",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("store_name", sa.String(length=120), nullable=False),
        sa.Column("store_description", sa.Text(), nullable=False),
        sa.Column("default_currency", sa.String(length=3), nullable=False),
        sa.Column("support_url", sa.String(length=2048), nullable=True),
        sa.Column("maintenance_mode", sa.Boolean(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint("id = 1", name="ck_store_settings_singleton"),
    )
    op.execute(
        sa.text("""INSERT INTO store_settings
        (id, store_name, store_description, default_currency, support_url, maintenance_mode, updated_at)
        VALUES (1, 'ManubisGuard Store', '', 'IRR', NULL, FALSE, CURRENT_TIMESTAMP)""")
    )


def downgrade() -> None:
    op.drop_table("store_settings")
