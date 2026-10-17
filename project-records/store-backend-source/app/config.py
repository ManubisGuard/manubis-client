from functools import lru_cache
from urllib.parse import urlsplit

from pydantic import Field, SecretStr, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_env: str = "development"
    store_host: str = "127.0.0.1"
    store_port: int = Field(default=8091, ge=1, le=65535)
    panel_base_url: str = "https://vip.qoqnusradio.top"
    panel_api_key: SecretStr = SecretStr("")
    panel_settings_encryption_key: SecretStr = SecretStr("")
    admin_api_token: SecretStr = SecretStr("")
    database_url: SecretStr = SecretStr("")
    panel_timeout_seconds: float = Field(default=8.0, gt=0, le=30)

    @field_validator("panel_base_url")
    @classmethod
    def validate_panel_base_url(cls, value: str) -> str:
        value = value.strip().rstrip("/")
        parsed = urlsplit(value)
        if parsed.scheme != "https" or not parsed.hostname:
            raise ValueError("PANEL_BASE_URL must be an absolute HTTPS URL")
        if parsed.username or parsed.password or parsed.query or parsed.fragment:
            raise ValueError("PANEL_BASE_URL must not contain credentials, query, or fragment")
        if parsed.path not in ("", "/"):
            raise ValueError("PANEL_BASE_URL must be the panel origin without a path")
        return value


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()
