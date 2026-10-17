import httpx
import pytest
from pydantic import SecretStr

import app.main as main


@pytest.mark.asyncio
async def test_admin_dashboard_is_served_without_exposing_credentials():
    async with httpx.AsyncClient(
        transport=httpx.ASGITransport(app=main.app), base_url="http://test"
    ) as client:
        response = await client.get("/admin")
    assert response.status_code == 200
    assert "ManubisGuard Store" in response.text
    assert "sessionStorage" in response.text
    assert '<div id="adminContent" hidden>' in response.text
    assert "async function authenticate()" in response.text
    assert "await api('/store-api/api/v1/admin/settings')" in response.text
    assert "$('adminContent').hidden=false" in response.text
    assert "$('adminContent').hidden=true" in response.text
    assert response.headers["cache-control"] == "no-store, max-age=0"


@pytest.mark.asyncio
async def test_liveness_is_independent_of_database():
    async with httpx.AsyncClient(
        transport=httpx.ASGITransport(app=main.app), base_url="http://test"
    ) as client:
        response = await client.get("/health/live")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


@pytest.mark.asyncio
async def test_readiness_fails_when_database_is_not_configured(monkeypatch):
    monkeypatch.setattr(main.settings, "panel_api_key", SecretStr("test-key"))
    monkeypatch.setattr(main, "engine", None)
    async with httpx.AsyncClient(
        transport=httpx.ASGITransport(app=main.app), base_url="http://test"
    ) as client:
        response = await client.get("/health/ready")
    assert response.status_code == 503
    assert response.json() == {
        "status": "not_ready",
        "missing": ["database_not_configured"],
    }
