# ManubisGuard Store API Contract (draft v1)

Status: draft; do not treat payment or provisioning endpoints as production-ready until auth, database transactions, payment provider and panel mapping are implemented and tested.

## Boundary

- Android communicates only with Store Backend.
- Store Backend communicates with ManubisGuard Panel API through a server-side adapter.
- Panel API key remains server-side and must never be returned to Android.
- Admin Dashboard communicates with Store Backend's admin API, never directly from browser to panel.

## Proposed Android-facing routes

| Method | Route | Purpose | Initial status |
|---|---|---|---|
| GET | `/api/v1/store/plans` | Active public plans and prices | Implemented in scaffold; needs database/runtime tests |
| GET | `/api/v1/me/subscription` | Current subscription, usage, expiry | Planned; account binding required |
| POST | `/api/v1/orders` | Create a pending order from a plan ID | Planned; idempotency required |
| GET | `/api/v1/orders` | List caller's orders | Planned; ownership checks required |
| GET | `/api/v1/orders/{order_id}` | Read one caller-owned order | Planned |
| POST | `/api/v1/payments/{provider}/webhook` | Verify provider callback/signature and settle order | Planned; provider not selected |
| GET | `/api/v1/wallet` | Wallet balance | Optional; only after ledger design |
| GET | `/api/v1/wallet/transactions` | Immutable wallet ledger history | Optional; only after ledger design |

## Proposed admin routes

- `GET /api/v1/admin/panel/config` returns safe masked configuration only.
- `PUT /api/v1/admin/panel/config` updates panel base URL and secret reference, with strict URL validation and audit event.
- `POST /api/v1/admin/panel/test-connection` performs a read-only permission-scoped test. The route is implemented, but live panel credentials and permissions have not been verified.
- CRUD for store plans and panel template/group mappings. Initial protected plan endpoints and `GET /api/v1/admin/panel/templates` metadata endpoint are implemented; live panel API authentication still needs verification.
- Order search and manual review tools, with audit events for any privileged change.

The public plans route and initial admin plan endpoints are implemented. Admin endpoints currently include `GET /api/v1/admin/plans`, `POST /api/v1/admin/plans`, and `PATCH /api/v1/admin/plans/{id}`, protected by a separate `ADMIN_API_TOKEN`. Panel config editing, template browsing UI, order/payment routes, and all other routes remain proposed.

## Domain rules

1. A client cannot set an order to paid or activate a subscription directly.
2. A payment webhook must be authenticated using the provider's signature/verification API and be idempotent.
3. The same provider transaction ID cannot settle multiple orders.
4. Provisioning should happen after confirmed payment; failures need retryable state, not duplicate user creation.
5. Store order state and wallet movements must be committed transactionally and audited.
6. Panel operations must be restricted to only the routes/permissions the adapter requires.
7. A panel outage must not silently mark an order fulfilled. Keep it paid-but-pending-provisioning and retry safely.
8. Store plans need explicit mapping to panel template/group IDs. Do not infer product mapping from display names.
9. User/account binding design must be settled before building `me` endpoints. Guest config import remains separate from store-account ownership.

## Current persistence scaffold

- `StorePlan` stores public plan metadata and the server-side `panel_template_id` mapping. The panel template ID is deliberately excluded from public responses.
- `StoreOrder` includes a unique customer/idempotency-key pair and a unique provider/transaction-ID pair to support duplicate prevention.
- No order-creation or payment-settlement endpoint exists yet. Alembic migrations `0001_initial_store_tables` and `0002_order_status_constraint` were applied successfully to a disposable PostgreSQL 16 database; `alembic check` reported no model/schema drift, and PostgreSQL rejected an invalid order status. No production database was migrated. Order concurrency/idempotency tests remain required before checkout is implemented.

## Open decisions before checkout implementation

- Payment provider(s) and whether wallet is needed for first release.
- Account registration/login method and password reset policy.
- Plan price source and currency representation (store DB vs panel metadata).
- Exact mapping between a purchased plan, panel template, group, data limit and expiry.
- Whether subscriptions are per account, per device, or per generated panel username.
- Refund/cancel/renewal behavior.
