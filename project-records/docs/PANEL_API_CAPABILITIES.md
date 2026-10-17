# ManubisGuard Panel API: source-based capability map

Date: 2026-10-15
Panel source inspected locally at `/opt/manubisguard-panel`.
Repository branch: `feature/amnezia-wg`; working tree was clean at inspection.
Panel URL: `https://vip.qoqnusradio.top/dashboard/`

> This document contains route shapes and source-code findings only. It does not contain or use the API key supplied in chat. Routes below were confirmed from the local panel source, not all live-tested against production.

## Authentication

`app/routers/authentication.py` extracts API credentials from either:

- `X-Api-Key: <key>`
- `Authorization: ApiKey <key>`

The key must use the `pg_key_` prefix and must be active/not expired. The panel API key can inherit the associated admin's permissions or use a custom permission snapshot. Route-level permissions are checked by `require_permission(...)`.

**Security recommendation:** use a dedicated API key with `inherit_permissions=false`, minimum permissions, an expiry if practical, and only the permissions required by the adapter. Do not use an owner's broad key for a storefront. Do not embed the key in the Android app. The key already shared in chat should be revoked/replaced.

## Confirmed source routes useful to the store

| Purpose | Route | Permission / notes |
|---|---|---|
| Create user | `POST /api/user` | `users.create`; body `UserCreate` |
| Read user by username | `GET /api/user/{username}` | `users.read` |
| Modify user | `PUT /api/user/{username}` | `users.update`; nullable/omitted fields are documented as no-change |
| Create user from template | `POST /api/user/from_template` | `users.create`; body `CreateUserFromTemplate` |
| Update user from template | `PUT /api/user/from_template/{username}` | `users.update` |
| List user templates | `GET /api/user_template/s` | `templates.read`; paginated response |
| Lightweight template list | `GET /api/user_template/s/simple` | `templates.read_simple`; returns IDs and names |
| Read template | `GET /api/user_template/{template_id}` | `templates.read` |
| List groups | `GET /api/groups` must not be assumed; group router uses prefix `/api/group` | Inspect exact route/schema before integration |
| Subscription link and info | `GET /{subscription_path}/{token}/info` and related token routes | Public-token access; do not treat a subscription token as an admin API key |

The user and template route signatures are defined in `app/routers/user.py` and `app/routers/user_template.py`. Some API route names use pluralized suffixes without a slash (e.g. `GET /api/user/s`), so the adapter must use the actual registered paths, not guess based on naming.

## Important data model observations

- User creation/modification supports expiry (`expire`), data limit (`data_limit`, in bytes), status, protocol proxy settings, group IDs, notes and subscription-related fields.
- User templates expose `data_limit`, `expire_duration` (seconds), `group_ids`, prefix/suffix and reset strategy.
- The panel API is an admin/control-plane API. It is not a storefront checkout API.
- No evidence in the inspected routes/models shows built-in wallet balances, payment intents, payment provider callbacks, coupon redemption, or an auditable storefront order/transaction ledger.
- Therefore a separate Store Backend is needed for account-facing product catalogue, order lifecycle, payment verification and wallet/ledger if those features are required. It should use the panel adapter only for provisioning and subscription state.

## Recommended adapter boundary

Expose a stable Store API to Android, independent of panel-specific field names:

- `GET /api/store/plans`
- `GET /api/store/me/subscription`
- `POST /api/store/orders`
- `GET /api/store/orders`
- `POST /api/store/payments/{provider}/webhook` (provider-specific, signature-verified)
- `GET /api/store/wallet` and `GET /api/store/wallet/transactions` only if wallet is enabled

These are **proposed Store Backend endpoints**, not existing panel endpoints. The adapter should translate plan-to-template/group mappings, provisioning and subscription state into the Store API contract. Do not expose panel API responses or credentials directly to the app.

## Remaining verification

- Confirm the exact group list/detail routes and response models from `app/routers/group.py`.
- Inspect `CreateUserFromTemplate`, `UserResponse` and subscription link/token generation to determine the safest provisioning and account-linking flow.
- Confirm the API key's effective permissions in the panel UI; do not test the chat-exposed key.
- If live connectivity is needed, test with a newly rotated least-privilege key, only after storing it securely on the server (not in chat or shell history).
