"""Store encrypted panel connection settings.

Revision ID: 0004_panel_connection_settings
Revises: 0003_store_settings
"""
from alembic import op
import sqlalchemy as sa

revision = "0004_panel_connection_settings"
down_revision = "0003_store_settings"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "panel_connection_settings",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("base_url", sa.String(length=2048), nullable=False),
        sa.Column("api_key_encrypted", sa.Text(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint("id = 1", name="ck_panel_connection_singleton"),
    )


def downgrade() -> None:
    op.drop_table("panel_connection_settings")
