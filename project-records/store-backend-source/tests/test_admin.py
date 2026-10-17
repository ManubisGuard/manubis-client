from types import SimpleNamespace

import httpx
import pytest
from fastapi import HTTPException
from pydantic import SecretStr, ValidationError

import app.main as main
import app.routes.admin as admin
from app.db import get_db
from app.schemas import StorePlanCreate, StorePlanPatch


@pytest.mark.asyncio
async def test_admin_dashboard_has_security_headers():
    async with httpx.AsyncClient(
        transport=httpx.ASGITransport(app=main.app), base_url="http://test"
    ) as client:
        response = await client.get("/admin")
    assert response.status_code == 200
    assert response.headers["cache-control"] == "no-store, max-age=0"
    assert response.headers["pragma"] == "no-cache"
    assert response.headers["x-content-type-options"] == "nosniff"
    assert response.headers["x-frame-options"] == "DENY"
    assert response.headers["referrer-policy"] == "no-referrer"
    assert "default-src 'self'" in response.headers["content-security-policy"]
    assert "frame-ancestors 'none'" in response.headers["content-security-policy"]


@pytest.mark.asyncio
async def test_admin_auth_rejects_missing_token(monkeypatch):
    monkeypatch.setattr(admin, "get_settings", lambda: SimpleNamespace(admin_api_token=SecretStr("secret-test-token")))
    with pytest.raises(HTTPException) as error:
        await admin.require_admin(None)
    assert error.value.status_code == 401


@pytest.mark.asyncio
async def test_admin_auth_accepts_correct_bearer_token(monkeypatch):
    monkeypatch.setattr(admin, "get_settings", lambda: SimpleNamespace(admin_api_token=SecretStr("secret-test-token")))
    assert await admin.require_admin("Bearer secret-test-token") is None


def test_plan_create_normalizes_currency_and_name():
    plan = StorePlanCreate(slug="monthly-basic", name=" Basic ", price_minor=100, duration_seconds=3600, data_limit_bytes=0, panel_template_id=1, currency="irr")
    assert plan.name == "Basic"
    assert plan.currency == "IRR"


def test_plan_create_rejects_invalid_slug():
    with pytest.raises(ValidationError):
        StorePlanCreate(slug="Bad Slug", name="Basic", price_minor=100, duration_seconds=3600, data_limit_bytes=0, panel_template_id=1)


def test_plan_patch_allows_partial_update():
    patch = StorePlanPatch(is_active=False)
    assert patch.model_dump(exclude_unset=True) == {"is_active": False}


@pytest.mark.asyncio
async def test_admin_auth_fails_closed_when_token_not_configured(monkeypatch):
    monkeypatch.setattr(admin, "get_settings", lambda: SimpleNamespace(admin_api_token=SecretStr("")))
    with pytest.raises(HTTPException) as error:
        await admin.require_admin("Bearer any-token")
    assert error.value.status_code == 503


@pytest.mark.asyncio
async def test_panel_template_route_returns_only_allowlisted_metadata(monkeypatch):
    class FakePanelClient:
        def __init__(self, settings):
            pass

        async def list_templates(self, *, limit, offset):
            return [
                {"id": 7, "name": "Monthly", "description": "Standard", "secret": "must-not-leak"},
                {"id": "invalid", "name": "Bad"},
            ]

    async def fake_build_panel_client(db, settings):
        return FakePanelClient(settings)

    monkeypatch.setattr(admin, "build_panel_client", fake_build_panel_client)
    monkeypatch.setattr(admin, "get_settings", lambda: SimpleNamespace())
    result = await admin.list_panel_templates(limit=10, offset=0)
    assert result["items"] == [{"id": 7, "name": "Monthly", "description": "Standard"}]
    assert "secret" not in str(result)


@pytest.mark.asyncio
async def test_panel_connection_route_returns_safe_status(monkeypatch):
    class FakePanelClient:
        def __init__(self, settings):
            pass

        async def test_connection(self):
            return SimpleNamespace(ok=True, status_code=200, message="Panel API reachable")

    async def fake_build_panel_client(db, settings):
        return FakePanelClient(settings)

    monkeypatch.setattr(admin, "build_panel_client", fake_build_panel_client)
    monkeypatch.setattr(admin, "get_settings", lambda: SimpleNamespace())
    result = await admin.test_panel_connection()
    assert result == {"ok": True, "status_code": 200, "message": "Panel API reachable"}


@pytest.mark.asyncio
async def test_panel_template_pagination_rejects_out_of_range_values(monkeypatch):
    async def fake_db():
        yield object()

    monkeypatch.setitem(main.app.dependency_overrides, get_db, fake_db)
    monkeypatch.setattr(
        admin,
        "get_settings",
        lambda: SimpleNamespace(admin_api_token=SecretStr("secret-test-token")),
    )
    async with httpx.AsyncClient(
        transport=httpx.ASGITransport(app=main.app), base_url="http://test"
    ) as client:
        bad_limit = await client.get(
            "/api/v1/admin/panel/templates?limit=0",
            headers={"Authorization": "Bearer secret-test-token"},
        )
        high_limit = await client.get(
            "/api/v1/admin/panel/templates?limit=201",
            headers={"Authorization": "Bearer secret-test-token"},
        )
        bad_offset = await client.get(
            "/api/v1/admin/panel/templates?offset=-1",
            headers={"Authorization": "Bearer secret-test-token"},
        )
    assert bad_limit.status_code == 422
    assert bad_limit.headers["cache-control"] == "no-store, max-age=0"
    assert bad_limit.headers["pragma"] == "no-cache"
    assert high_limit.status_code == 422
    assert bad_offset.status_code == 422


@pytest.mark.asyncio
async def test_admin_auth_accepts_case_insensitive_bearer_scheme(monkeypatch):
    monkeypatch.setattr(admin, "get_settings", lambda: SimpleNamespace(admin_api_token=SecretStr("secret-test-token")))
    assert await admin.require_admin("bearer secret-test-token") is None
    assert await admin.require_admin("BEARER secret-test-token") is None


@pytest.mark.asyncio
@pytest.mark.parametrize("header", ["secret-test-token", "Basic secret-test-token", "Bearer", "Bearer "])
async def test_admin_auth_rejects_malformed_authorization_header(monkeypatch, header):
    monkeypatch.setattr(admin, "get_settings", lambda: SimpleNamespace(admin_api_token=SecretStr("secret-test-token")))
    with pytest.raises(HTTPException) as error:
        await admin.require_admin(header)
    assert error.value.status_code == 401


def test_plan_patch_rejects_invalid_currency_and_blank_name():
    with pytest.raises(ValidationError):
        StorePlanPatch(currency="12$")
    with pytest.raises(ValidationError):
        StorePlanPatch(name="   ")


def test_store_settings_patch_normalizes_currency_and_optional_url():
    from app.schemas import StoreSettingsPatch

    payload = StoreSettingsPatch(
        store_name="  Manubis Store  ",
        store_description="  Fast access  ",
        default_currency="irr",
        support_url="https://t.me/manubis_support",
        maintenance_mode=False,
    )
    assert payload.store_name == "Manubis Store"
    assert payload.store_description == "Fast access"
    assert payload.default_currency == "IRR"
    assert payload.support_url == "https://t.me/manubis_support"
    assert payload.maintenance_mode is False


def test_store_settings_patch_rejects_insecure_support_url():
    from app.schemas import StoreSettingsPatch

    with pytest.raises(ValidationError):
        StoreSettingsPatch(support_url="http://example.com/support")
    with pytest.raises(ValidationError):
        StoreSettingsPatch(support_url="https://user:password@example.com/support")
    with pytest.raises(ValidationError):
        StoreSettingsPatch(support_url="https://example.com/support#secret")


def test_store_settings_patch_allows_explicitly_clearing_support_url():
    from app.schemas import StoreSettingsPatch

    payload = StoreSettingsPatch(support_url=None)
    assert payload.model_dump(exclude_unset=True) == {"support_url": None}


@pytest.mark.asyncio
async def test_admin_store_settings_patch_updates_persisted_fields():
    from app.models import StoreSettings
    from app.schemas import StoreSettingsPatch

    settings = StoreSettings(
        id=1,
        store_name="Old Store",
        store_description="Old description",
        default_currency="IRR",
        support_url=None,
        maintenance_mode=False,
    )

    class FakeResult:
        def scalar_one_or_none(self):
            return settings

    class FakeDB:
        committed = False

        async def execute(self, statement):
            return FakeResult()

        async def commit(self):
            self.committed = True

        async def refresh(self, instance):
            return None

        async def rollback(self):
            return None

    db = FakeDB()
    updated = await admin.patch_store_settings(
        StoreSettingsPatch(
            store_name="New Store",
            store_description="New description",
            default_currency="EUR",
            support_url="https://example.com/help",
            maintenance_mode=True,
        ),
        db=db,
    )
    assert db.committed is True
    assert updated.store_name == "New Store"
    assert updated.default_currency == "EUR"
    assert updated.support_url == "https://example.com/help"
    assert updated.maintenance_mode is True


@pytest.mark.asyncio
async def test_admin_store_settings_rejects_null_required_field():
    from app.models import StoreSettings
    from app.schemas import StoreSettingsPatch

    settings = StoreSettings(
        id=1,
        store_name="Store",
        store_description="",
        default_currency="IRR",
        support_url=None,
        maintenance_mode=False,
    )

    class FakeResult:
        def scalar_one_or_none(self):
            return settings

    class FakeDB:
        committed = False

        async def execute(self, statement):
            return FakeResult()

        async def commit(self):
            self.committed = True

        async def refresh(self, instance):
            return None

        async def rollback(self):
            return None

    db = FakeDB()
    with pytest.raises(HTTPException) as error:
        await admin.patch_store_settings(StoreSettingsPatch(store_name=None), db=db)
    assert error.value.status_code == 422
    assert db.committed is False


def test_card_transfer_settings_normalize_number_and_text():
    from app.schemas import StoreSettingsPatch

    payload = StoreSettingsPatch(
        card_transfer_enabled=True,
        card_holder_name="  Test Holder  ",
        card_number="1111 2222-3333 4444",
        card_bank_name="  Test Bank ",
        card_transfer_instructions="  Upload the receipt  ",
    )
    assert payload.card_transfer_enabled is True
    assert payload.card_holder_name == "Test Holder"
    assert payload.card_number == "1111222233334444"
    assert payload.card_bank_name == "Test Bank"
    assert payload.card_transfer_instructions == "Upload the receipt"


def test_card_transfer_settings_reject_invalid_card_number():
    from app.schemas import StoreSettingsPatch

    with pytest.raises(ValidationError):
        StoreSettingsPatch(card_number="12345")


def test_receipt_upload_rejects_unsupported_media_type():
    from app.schemas import ReceiptUpload

    with pytest.raises(ValidationError):
        ReceiptUpload(filename="receipt.exe", content_type="application/x-msdownload", content_base64="ZmFrZQ==")


def test_receipt_upload_strips_directory_from_filename():
    from app.schemas import ReceiptUpload

    payload = ReceiptUpload(filename="../../receipt.png", content_type="image/png", content_base64="aGVsbG8td29ybGQ=")
    assert payload.filename == "receipt.png"
