import ipaddress
from urllib.parse import urlsplit, urlunsplit

from cryptography.fernet import Fernet, InvalidToken
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import Settings
from app.models import PanelConnectionSettings
from app.panel.client import PanelClient, PanelConfigurationError


def normalize_panel_url(value: str) -> str:
    """Accept only HTTPS panel origins/paths and reject obvious local targets."""
    normalized = value.strip().rstrip("/")
    parsed = urlsplit(normalized)
    if parsed.scheme.lower() != "https" or not parsed.hostname:
        raise ValueError("Panel URL must be an absolute HTTPS URL")
    if parsed.username or parsed.password or parsed.query or parsed.fragment:
        raise ValueError("Panel URL must not contain credentials, query, or fragment")
    if parsed.path not in ("", "/"):
        raise ValueError("Panel URL must be the panel origin without a path")
    try:
        port = parsed.port
    except ValueError as exc:
        raise ValueError("Panel URL contains an invalid port") from exc
    if port not in (None, 443):
        raise ValueError("Panel URL must use HTTPS port 443")

    hostname = parsed.hostname.rstrip(".").lower()
    if not hostname or hostname in {"localhost", "localhost.localdomain"}:
        raise ValueError("Panel URL must use a public hostname")
    if hostname.endswith((".localhost", ".local", ".internal", ".test", ".invalid", ".example")):
        raise ValueError("Panel URL must not target a local or reserved hostname")
    try:
        address = ipaddress.ip_address(hostname)
    except ValueError:
        if "." not in hostname or " " in hostname:
            raise ValueError("Panel URL must use a fully qualified hostname")
    else:
        if not address.is_global:
            raise ValueError("Panel URL must not target a private or reserved IP address")

    netloc = hostname
    if ":" in hostname:
        netloc = f"[{hostname}]"
    return urlunsplit(("https", netloc, parsed.path.rstrip("/"), "", ""))


def encrypt_api_key(api_key: str, settings: Settings) -> str:
    key = settings.panel_settings_encryption_key.get_secret_value().strip()
    if not key:
        raise PanelConfigurationError("Panel settings encryption is not configured")
    try:
        cipher = Fernet(key.encode("ascii"))
    except (ValueError, UnicodeEncodeError) as exc:
        raise PanelConfigurationError("Panel settings encryption key is invalid") from exc
    return cipher.encrypt(api_key.encode("utf-8")).decode("ascii")


def decrypt_api_key(encrypted: str, settings: Settings) -> str:
    key = settings.panel_settings_encryption_key.get_secret_value().strip()
    if not key:
        raise PanelConfigurationError("Panel settings encryption is not configured")
    try:
        cipher = Fernet(key.encode("ascii"))
        return cipher.decrypt(encrypted.encode("ascii")).decode("utf-8")
    except (ValueError, UnicodeEncodeError, InvalidToken, UnicodeDecodeError) as exc:
        raise PanelConfigurationError("Stored panel credentials cannot be decrypted; verify encryption key") from exc


async def build_panel_client(db: AsyncSession, settings: Settings) -> PanelClient:
    result = await db.execute(select(PanelConnectionSettings).where(PanelConnectionSettings.id == 1))
    stored = result.scalar_one_or_none()
    if stored is None:
        return PanelClient(settings)
    api_key = decrypt_api_key(stored.api_key_encrypted, settings)
    return PanelClient(settings, base_url=stored.base_url, api_key=api_key)
