from pathlib import Path

from fastapi import FastAPI
from fastapi.responses import FileResponse, JSONResponse
from sqlalchemy import text

from app.config import get_settings
from app.db import engine
from app.routes.store import router as store_router
from app.routes.admin import router as admin_router
from app.routes.auth import router as auth_router

settings = get_settings()
app = FastAPI(
    title="ManubisGuard Store API",
    version="0.1.0",
    docs_url="/docs" if settings.app_env != "production" else None,
    redoc_url=None,
    openapi_url="/openapi.json" if settings.app_env != "production" else None,
)
app.include_router(store_router)
app.include_router(admin_router)
app.include_router(auth_router)


@app.middleware("http")
async def security_headers(request, call_next):
    response = await call_next(request)
    response.headers.setdefault("X-Content-Type-Options", "nosniff")
    response.headers.setdefault("Referrer-Policy", "no-referrer")
    response.headers.setdefault("X-Frame-Options", "DENY")
    response.headers.setdefault("Permissions-Policy", "camera=(), microphone=(), geolocation=()")
    if (
        request.url.path == "/admin"
        or request.url.path.startswith("/api/v1/admin/")
        or request.url.path == "/api/v1/admin"
        or request.url.path.startswith("/api/v1/auth/")
    ):
        response.headers["Cache-Control"] = "no-store, max-age=0"
        response.headers["Pragma"] = "no-cache"
    if request.url.path == "/admin":
        response.headers["Content-Security-Policy"] = (
            "default-src 'self'; base-uri 'none'; object-src 'none'; "
            "frame-ancestors 'none'; form-action 'self'; "
            "script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; "
            "connect-src 'self'; img-src 'self' data:"
        )
    return response


@app.get("/admin", include_in_schema=False)
async def admin_dashboard():
    """Serve the lightweight browser admin UI; all privileged actions still require the admin API token."""
    dashboard = Path(__file__).parent / "static" / "admin.html"
    return FileResponse(dashboard, media_type="text/html; charset=utf-8", headers={"Cache-Control": "no-store"})


@app.get("/health/live", tags=["health"])
async def liveness() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/health/ready", tags=["health"])
async def readiness():
    """Check required configuration and database reachability without exposing secrets."""
    missing: list[str] = []
    panel_key_configured = bool(settings.panel_api_key.get_secret_value().strip())
    encryption_key_configured = bool(settings.panel_settings_encryption_key.get_secret_value().strip())
    if engine is None:
        missing.append("database_not_configured")
        if not panel_key_configured:
            missing.append("panel_not_configured")
    else:
        try:
            async with engine.connect() as connection:
                await connection.execute(text("SELECT 1"))
                managed_panel_configured = False
                try:
                    result = await connection.execute(
                        text("SELECT 1 FROM panel_connection_settings WHERE id = 1")
                    )
                    managed_panel_configured = result.scalar_one_or_none() is not None
                except Exception:
                    # A not-yet-applied migration means managed settings are unavailable.
                    managed_panel_configured = False
                if managed_panel_configured and not encryption_key_configured:
                    missing.append("panel_encryption_not_configured")
                elif not managed_panel_configured and not panel_key_configured:
                    missing.append("panel_not_configured")
        except Exception:
            missing.append("database_unavailable")
            if not panel_key_configured:
                missing.append("panel_not_configured")
    if missing:
        return JSONResponse(status_code=503, content={"status": "not_ready", "missing": missing})
    return {"status": "ready"}
