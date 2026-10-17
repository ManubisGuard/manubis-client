"""Constrain store order statuses to the documented state set.

Revision ID: 0002_order_status_constraint
Revises: 0001_initial_store_tables
"""
from alembic import op
import sqlalchemy as sa

revision = "0002_order_status_constraint"
down_revision = "0001_initial_store_tables"
branch_labels = None
depends_on = None

VALID_STATUSES = (
    "pending_payment",
    "paid_pending_provisioning",
    "fulfilled",
    "cancelled",
    "failed",
    "refunded",
)


def upgrade() -> None:
    # Fail safely instead of silently rewriting unexpected historical values.
    connection = op.get_bind()
    invalid = connection.execute(
        sa.text(
            "SELECT status, count(*) FROM store_orders "
            "WHERE status NOT IN :statuses GROUP BY status"
        ).bindparams(sa.bindparam("statuses", expanding=True)),
        {"statuses": list(VALID_STATUSES)},
    ).all()
    if invalid:
        raise RuntimeError(
            "Cannot constrain store_orders.status: unexpected existing statuses "
            + ", ".join(f"{row[0]} ({row[1]})" for row in invalid)
        )
    op.create_check_constraint(
        "ck_store_order_status_valid",
        "store_orders",
        "status IN ('pending_payment', 'paid_pending_provisioning', "
        "'fulfilled', 'cancelled', 'failed', 'refunded')",
    )


def downgrade() -> None:
    op.drop_constraint(
        "ck_store_order_status_valid",
        "store_orders",
        type_="check",
    )
