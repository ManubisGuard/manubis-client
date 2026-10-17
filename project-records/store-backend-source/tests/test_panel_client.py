import httpx
import pytest

from app.config import Settings
from app.panel.client import PanelClient, PanelConfigurationError


@pytest.mark.asyncio
async def test_panel_client_uses_api_key_header_and_read_only_probe():
    seen = []

    def handler(request: httpx.Request) -> httpx.Response:
        seen.append(request)
        assert request.method == "GET"
        assert request.headers.get("X-Api-Key") == "test-key"
        assert request.url.path == "/api/user_template/s"
        return httpx.Response(200, json=[])

    settings = Settings(panel_base_url="https://panel.example", panel_api_key="test-key")
    result = await PanelClient(settings, transport=httpx.MockTransport(handler)).test_connection()

    assert result.ok is True
    assert result.status_code == 200
    assert len(seen) == 1


@pytest.mark.asyncio
async def test_panel_client_without_key_does_not_send_request():
    settings = Settings(panel_base_url="https://panel.example", panel_api_key="")
    client = PanelClient(settings, transport=httpx.MockTransport(lambda request: httpx.Response(200)))
    with pytest.raises(PanelConfigurationError):
        await client.test_connection()


@pytest.mark.asyncio
async def test_create_user_from_template_uses_documented_payload_and_path():
    seen = []

    def handler(request: httpx.Request) -> httpx.Response:
        seen.append(request)
        assert request.method == "POST"
        assert request.url.path == "/api/user/from_template"
        assert request.headers.get("X-Api-Key") == "test-key"
        assert request.read() == b'{"username":"test-user","user_template_id":12,"note":"store order"}'
        return httpx.Response(200, json={"username": "test-user"})

    settings = Settings(panel_base_url="https://panel.example", panel_api_key="test-key")
    client = PanelClient(settings, transport=httpx.MockTransport(handler))
    result = await client.create_user_from_template(
        username="test-user", template_id=12, note="store order"
    )
    assert result == {"username": "test-user"}
    assert len(seen) == 1


@pytest.mark.asyncio
@pytest.mark.parametrize("upstream_status", [401, 403, 404, 429, 500])
async def test_connection_probe_preserves_upstream_http_status(upstream_status):
    calls = []

    def handler(request: httpx.Request) -> httpx.Response:
        calls.append(request)
        return httpx.Response(upstream_status, json={"detail": "private upstream text"})

    settings = Settings(panel_base_url="https://panel.example", panel_api_key="test-key")
    result = await PanelClient(settings, transport=httpx.MockTransport(handler)).test_connection()

    assert result.ok is False
    assert result.status_code == upstream_status
    assert "private upstream text" not in result.message
    assert len(calls) == 1


@pytest.mark.asyncio
async def test_panel_client_does_not_follow_redirects():
    calls = []

    def handler(request: httpx.Request) -> httpx.Response:
        calls.append(request)
        return httpx.Response(302, headers={"Location": "https://other.example/steal"})

    settings = Settings(panel_base_url="https://panel.example", panel_api_key="test-key")
    result = await PanelClient(settings, transport=httpx.MockTransport(handler)).test_connection()

    assert result.ok is False
    assert result.status_code == 302
    assert "redirect" in result.message.lower()
    assert len(calls) == 1
    assert calls[0].url.host == "panel.example"
