# ManubisGuard customer account API

Base URL: `https://all.qoqnusradio.top/store-api`

## Endpoints

- `POST /api/v1/auth/register` — create a username/password account and return a bearer session.
- `POST /api/v1/auth/login` — authenticate an existing account and issue a new session.
- `GET /api/v1/auth/me` — return the authenticated account profile.
- `GET /api/v1/auth/me/orders` — list orders owned by the signed-in account only.
- `POST /api/v1/auth/logout` — revoke the current bearer session.

Usernames are normalized to lowercase and must be 3–32 characters from letters, digits, dot, underscore and hyphen. Passwords must be 10–128 characters. Passwords are stored as salted PBKDF2-HMAC-SHA256 hashes (310,000 iterations). Session tokens are random, returned once, and only their SHA-256 digests are stored. Sessions expire after 30 days; the Android client intentionally keeps the current token in memory only and does not persist it in QSettings.

Nginx exposes only the `/api/v1/auth/` route for account operations, applies the existing request-rate limit zone, and sets the trusted `X-Real-IP` header. The application also has bounded in-process throttling for registration and login. These controls are defense in depth, not a replacement for production edge monitoring.

When a signed-in user creates a store order, the API associates the order with that account. Anonymous card-transfer orders remain possible, but are not shown in account history. Account order history never returns another user's orders.

## Important current limitations

- This API is deployed on the current store-test backend/database; the catalogue currently has zero active plans and card transfer is disabled. It is not yet a production-ready subscription sales system.
- Email verification, password recovery, MFA, device/session management and a formal account deletion flow are not implemented.
- Manually approving a receipt only changes the order to `paid_pending_provisioning`; it does not provision a subscription. Real panel API credentials, template mapping, provisioning and renewal still need end-to-end validation before accepting real payments.
- Account endpoint checks performed so far cover unauthenticated access, malformed registration validation, password hashing/validation unit tests and the backend regression suite. A full live register → login → order → logout lifecycle and physical Android runtime test are still outstanding.
