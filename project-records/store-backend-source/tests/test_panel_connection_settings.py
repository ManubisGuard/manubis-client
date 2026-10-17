from types import SimpleNamespace

import pytest
from cryptography.fernet import Fernet
from pydantic import SecretStr, ValidationError

from app.config import Settings
from app.models import PanelConnectionSettings
from app.panel.connection_settings import (
    build_panel_client,
    decrypt_api_key,
    encrypt_api_key,
    normalize_panel_url,
)
from app.panel.client import PanelConfigurationError
from app.schemas import PanelConnectionPatch


def test_panel_url_normalizes_https_origin():
    assert normalize_panel_url(" https://Panel.Example.com/ ") == "https://panel.example.com"


def test_panel_url_rejects_path_prefix():
    with pytest.raises(ValueError):
        normalize_panel_url("https://panel.example.com/proxy")


@pytest.mark.parametrize(
    "url",
    [
        "http://panel.example.com",
        "https://user:pass@panel.example.com",
        "https://panel.example.com/?token=secret",
        "https://panel.example.com/#fragment",
        "https://localhost",
        "https://panel.local",
        "https://127.0.0.1",
        "https://10.0.0.2",
        "https://panel.example.com:8443",
    ],
)
def test_panel_url_rejects_unsafe_targets(url):
    with pytest.raises(ValueError):
        normalize_panel_url(url)


def test_panel_connection_schema_rejects_http_and_private_ip():
    with pytest.raises(ValidationError):
        PanelConnectionPatch(base_url="http://panel.example.com")
    with pytest.raises(ValidationError):
        PanelConnectionPatch(base_url="https://192.168.1.10")


def test_panel_api_key_is_encrypted_and_round_trips():
    settings = Settings(panel_settings_encryption_key=Fernet.generate_key().decode())
    encrypted = encrypt_api_key("panel-secret-value", settings)
    assert encrypted != "panel-secret-value"
    assert "panel-secret-value" not in encrypted
    assert decrypt_api_key(encrypted, settings) == "panel-secret-value"


def test_panel_key_storage_fails_closed_without_encryption_key():
    settings = Settings(panel_settings_encryption_key="")
    with pytest.raises(PanelConfigurationError):
        encrypt_api_key("panel-secret-value", settings)


@pytest.mark.asyncio
async def test_build_panel_client_uses_decrypted_database_config():
    settings = Settings(panel_base_url="https://fallback.example.com", panel_api_key="fallback-key",
                       panel_settings_encryption_key=Fernet.generate_key().decode())
    encrypted = encrypt_api_key("managed-secret", settings)
    stored = PanelConnectionSettings(id=1, base_url="https://managed.example.com", api_key_encrypted=encrypted)

    class FakeResult:
        def scalar_one_or_none(self):
            return stored

    class FakeDB:
        async def execute(self, statement):
            return FakeResult()

    client = await build_panel_client(FakeDB(), settings)
    assert client._base_url == "https://managed.example.com"
    assert client._api_key == "managed-secret"


@pytest.mark.asyncio
async def test_admin_panel_connection_persists_only_encrypted_key(monkeypatch):
    from app.routes import admin

    key = Fernet.generate_key().decode()
    settings = Settings(panel_settings_encryption_key=key, panel_api_key="", panel_base_url="https://fallback.example.com")
    monkeypatch.setattr(admin, "get_settings", lambda: settings)

    class FakeDB:
        stored = None

        async def execute(self, statement):
            return SimpleNamespace(scalar_one_or_none=lambda: self.stored)

        def add(self, instance):
            self.stored = instance

        async def commit(self):
            return None

        async def refresh(self, instance):
            return None

        async def rollback(self):
            return None

    db = FakeDB()
    response = await admin.patch_panel_connection(
        PanelConnectionPatch(base_url="https://panel.example.com", api_key="new-panel-secret"),
        db=db,
    )
    assert db.stored.api_key_encrypted != "new-panel-secret"
    assert "new-panel-secret" not in db.stored.api_key_encrypted
    assert decrypt_api_key(db.stored.api_key_encrypted, settings) == "new-panel-secret"
    assert response == {
        "base_url": "https://panel.example.com",
        "api_key_configured": True,
        "encryption_ready": True,
    }
    assert "new-panel-secret" not in str(response)


@pytest.mark.asyncio
async def test_admin_panel_connection_read_never_returns_secret(monkeypatch):
    from app.routes import admin

    key = Fernet.generate_key().decode()
    settings = Settings(panel_settings_encryption_key=key, panel_api_key="", panel_base_url="https://fallback.example.com")
    encrypted = encrypt_api_key("hidden-secret", settings)
    stored = PanelConnectionSettings(id=1, base_url="https://managed.example.com", api_key_encrypted=encrypted)
    monkeypatch.setattr(admin, "get_settings", lambda: settings)

    class FakeDB:
        async def execute(self, statement):
            return SimpleNamespace(scalar_one_or_none=lambda: stored)

    response = await admin.get_panel_connection(db=FakeDB())
    assert response == {
        "base_url": "https://managed.example.com",
        "api_key_configured": True,
        "encryption_ready": True,
    }
    assert "hidden-secret" not in str(response)
