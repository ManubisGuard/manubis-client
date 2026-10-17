import pytest
from pydantic import ValidationError

from app.config import Settings


def test_panel_url_requires_https():
    with pytest.raises(ValidationError):
        Settings(panel_base_url="http://example.com", panel_api_key="test-key")


def test_panel_url_rejects_embedded_credentials():
    with pytest.raises(ValidationError):
        Settings(panel_base_url="https://user:pass@example.com", panel_api_key="test-key")


def test_panel_url_normalizes_trailing_slash():
    settings = Settings(panel_base_url="https://example.com/", panel_api_key="test-key")
    assert settings.panel_base_url == "https://example.com"
