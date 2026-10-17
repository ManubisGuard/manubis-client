# ManubisGuard Store Backend: isolated test deployment

This guide deploys the **current catalogue/admin scaffold only** to a separate test stack. It does not enable customer accounts, real orders, payments, or automatic subscription provisioning. Do not use this as a production checkout service.

## 1. Prepare secrets

```bash
cd /opt/manubisguard-android/store-backend
cp .env.compose.example .env
chmod 600 .env
```

Generate strong independent values for `POSTGRES_PASSWORD` and `ADMIN_API_TOKEN` (for example with `openssl rand -hex 32`) and replace the placeholders in `.env`. Do not reuse the panel API key. Leave `PANEL_API_KEY` empty until a new least-privilege test key is issued. Generate a Fernet key for `PANEL_SETTINGS_ENCRYPTION_KEY` using the command in `.env.compose.example`; keep a secure backup of it. Do not put any secret in Git, `todo.md`, terminal screenshots, or the Android app.

## 2. Build and migrate the test database

```bash
docker compose -f compose.yaml config --quiet
docker compose -f compose.yaml build --pull
docker compose -f compose.yaml run --rm api alembic upgrade head
docker compose -f compose.yaml run --rm api alembic check
```

These commands target only the Compose database volume named `manubisguard-store-test_store_db_data`. Do not point this compose file at a production database. Keep a backup before any migration of an existing database.

## 3. Start the isolated stack

```bash
docker compose -f compose.yaml up -d
docker compose -f compose.yaml ps
curl --fail http://127.0.0.1:8091/health/live
curl --fail http://127.0.0.1:8091/api/v1/store/settings
curl --fail http://127.0.0.1:8091/api/v1/store/plans
bash scripts/smoke_test.sh
```

The API is published on loopback (`127.0.0.1:8091`) by default and is not directly exposed to the internet. Access `/admin` through an SSH tunnel or a separately configured, trusted HTTPS reverse proxy with allowlisting and rate limits. Do not change `STORE_PUBLISH_HOST` to `0.0.0.0` on a public host. `/health/ready` intentionally remains `503` until a panel API key is configured (through a test-only environment key or after migrations, the encrypted dashboard setting); `/health/live` is the container liveness probe and should be healthy in this catalogue-only test.

## 4. Review logs and stop

```bash
docker compose -f compose.yaml logs --tail=200 api
docker compose -f compose.yaml down
```

`down` keeps the named database volume. To delete the test database volume as well, explicitly run `docker compose -f compose.yaml down -v`; this is destructive and should only be done when the test data is disposable.

## 5. Known blockers before any public beta

- The current backend does not yet implement customer authentication, user-owned subscriptions, order creation, payment provider integration, verified payment webhooks, idempotent fulfilment, or panel provisioning from a paid order.
- The live panel adapter still requires an approved test API key with least privilege. Never test with a previously exposed key.
- The admin token is a shared bearer secret, not a user/role system. Restrict the admin route at the network/reverse-proxy layer; rate limiting and audit logging must be completed before public exposure.
- The Android app has local branding edits but no verified APK build and no integrated Store UI yet.
- Do not perform production migration or deployment as part of this test procedure.
