from dataclasses import dataclass
from typing import Any
from urllib.parse import quote

import httpx

from app.config import Settings


class PanelConfigurationError(RuntimeError):
    """Raised when the panel adapter is not configured safely."""


class PanelRequestError(RuntimeError):
    """Raised when the panel API cannot fulfill a request."""

    def __init__(self, message: str, *, status_code: int | None = None):
        super().__init__(message)
        self.status_code = status_code


@dataclass(frozen=True)
class PanelConnectionResult:
    ok: bool
    status_code: int | None
    message: str


class PanelClient:
    """Server-side adapter for the ManubisGuard/PasarGuard control-plane API."""

    def __init__(
        self,
        settings: Settings,
        *,
        base_url: str | None = None,
        api_key: str | None = None,
        transport: httpx.AsyncBaseTransport | None = None,
    ):
        self._base_url = base_url or settings.panel_base_url
        self._api_key = (api_key if api_key is not None else settings.panel_api_key.get_secret_value()).strip()
        self._timeout = settings.panel_timeout_seconds
        self._transport = transport

    def _headers(self) -> dict[str, str]:
        if not self._api_key:
            raise PanelConfigurationError("Panel API key is not configured")
        return {"X-Api-Key": self._api_key, "Accept": "application/json"}

    async def _request(self, method: str, path: str, **kwargs: Any) -> Any:
        try:
            async with httpx.AsyncClient(
                base_url=self._base_url,
                headers=self._headers(),
                timeout=self._timeout,
                follow_redirects=False,
                transport=self._transport,
            ) as client:
                response = await client.request(method, path, **kwargs)
        except PanelConfigurationError:
            raise
        except httpx.TimeoutException as exc:
            raise PanelRequestError("Panel request timed out") from exc
        except httpx.HTTPError as exc:
            raise PanelRequestError("Panel request failed") from exc

        if response.status_code in (401, 403):
            raise PanelRequestError(
                "Panel rejected credentials or required permission",
                status_code=response.status_code,
            )
        if response.status_code == 404:
            raise PanelRequestError("Requested panel resource was not found", status_code=404)
        if 300 <= response.status_code < 400:
            raise PanelRequestError("Panel API returned an unexpected redirect", status_code=response.status_code)
        if response.status_code >= 400:
            raise PanelRequestError(
                f"Panel API returned HTTP {response.status_code}",
                status_code=response.status_code,
            )
        if response.status_code == 204 or not response.content:
            return None
        try:
            return response.json()
        except ValueError as exc:
            raise PanelRequestError("Panel API returned an invalid JSON response") from exc

    async def test_connection(self) -> PanelConnectionResult:
        """Perform a read-only permission probe; return no panel data."""
        try:
            await self.list_templates(limit=1)
            return PanelConnectionResult(True, 200, "Panel API reachable; template read permission accepted")
        except PanelConfigurationError:
            raise
        except PanelRequestError as exc:
            return PanelConnectionResult(False, exc.status_code, str(exc))

    async def list_templates(self, *, limit: int = 100, offset: int = 0) -> list[dict[str, Any]]:
        if not 1 <= limit <= 500 or offset < 0:
            raise ValueError("limit must be 1..500 and offset must be non-negative")
        result = await self._request(
            "GET", "/api/user_template/s", params={"limit": limit, "offset": offset}
        )
        if not isinstance(result, list):
            raise PanelRequestError("Panel returned an unexpected template list shape")
        return result

    async def get_user(self, username: str) -> dict[str, Any]:
        if not username or len(username) > 64:
            raise ValueError("username is invalid")
        result = await self._request("GET", f"/api/user/{quote(username, safe='')}")
        if not isinstance(result, dict):
            raise PanelRequestError("Panel returned an unexpected user response shape")
        return result

    async def create_user_from_template(
        self, *, username: str, template_id: int, note: str | None = None
    ) -> dict[str, Any]:
        if not username or len(username) > 64:
            raise ValueError("username is invalid")
        if template_id < 1:
            raise ValueError("template_id must be positive")
        payload: dict[str, Any] = {"username": username, "user_template_id": template_id}
        if note is not None:
            payload["note"] = note[:500]
        result = await self._request("POST", "/api/user/from_template", json=payload)
        if not isinstance(result, dict):
            raise PanelRequestError("Panel returned an unexpected user creation response shape")
        return result
