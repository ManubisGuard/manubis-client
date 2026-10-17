"""Add customer accounts, sessions, and order ownership."""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "0006_customer_accounts"
down_revision = "0005_card_transfer_orders"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "store_users",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("username", sa.String(length=32), nullable=False),
        sa.Column("password_hash", sa.String(length=256), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_store_users_username", "store_users", ["username"], unique=True)
    op.create_table(
        "store_sessions",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("token_hash", sa.String(length=64), nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("revoked_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["store_users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_store_sessions_user_id", "store_sessions", ["user_id"], unique=False)
    op.create_index("ix_store_sessions_token_hash", "store_sessions", ["token_hash"], unique=True)
    op.create_index("ix_store_sessions_expires_at", "store_sessions", ["expires_at"], unique=False)
    op.add_column("store_orders", sa.Column("user_id", sa.Uuid(), nullable=True))
    op.create_foreign_key("fk_store_orders_user_id_store_users", "store_orders", "store_users", ["user_id"], ["id"], ondelete="SET NULL")
    op.create_index("ix_store_orders_user_id", "store_orders", ["user_id"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_store_orders_user_id", table_name="store_orders")
    op.drop_constraint("fk_store_orders_user_id_store_users", "store_orders", type_="foreignkey")
    op.drop_column("store_orders", "user_id")
    op.drop_index("ix_store_sessions_expires_at", table_name="store_sessions")
    op.drop_index("ix_store_sessions_token_hash", table_name="store_sessions")
    op.drop_index("ix_store_sessions_user_id", table_name="store_sessions")
    op.drop_table("store_sessions")
    op.drop_index("ix_store_users_username", table_name="store_users")
    op.drop_table("store_users")
