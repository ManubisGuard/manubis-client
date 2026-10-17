from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from app.config import get_settings


class Base(DeclarativeBase):
    pass


_database_url = get_settings().database_url.get_secret_value().strip()
engine = create_async_engine(_database_url, pool_pre_ping=True) if _database_url else None
SessionLocal = async_sessionmaker(engine, expire_on_commit=False) if engine else None


async def get_db():
    if SessionLocal is None:
        raise RuntimeError("Database is not configured")
    async with SessionLocal() as session:
        yield session
