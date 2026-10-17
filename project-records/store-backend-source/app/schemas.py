import re
from uuid import UUID


from pydantic import BaseModel, ConfigDict, Field, field_validator


class StorePlanPublic(BaseModel):
    id: UUID
    slug: str
    name: str
    description: str | None
    price_minor: int = Field(ge=0)
    currency: str = Field(min_length=3, max_length=3)
    duration_seconds: int = Field(gt=0)
    data_limit_bytes: int = Field(ge=0)

    model_config = ConfigDict(from_attributes=True)


class StorePlanAdmin(BaseModel):
    id: UUID
    slug: str
    name: str
    description: str | None
    price_minor: int
    currency: str
    duration_seconds: int
    data_limit_bytes: int
    panel_template_id: int
    is_active: bool
    model_config = ConfigDict(from_attributes=True)


def validate_slug(value: str) -> str:
    value = value.strip()
    if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", value):
        raise ValueError("slug must use lowercase letters, numbers, and single hyphens")
    return value

class StorePlanCreate(BaseModel):
    slug: str = Field(min_length=1, max_length=80)
    name: str = Field(min_length=1, max_length=120)
    description: str | None = Field(default=None, max_length=4000)
    price_minor: int = Field(ge=0, le=9000000000000000000)
    currency: str = Field(default="IRR", min_length=3, max_length=3)
    duration_seconds: int = Field(gt=0, le=9000000000000000000)
    data_limit_bytes: int = Field(ge=0, le=9000000000000000000)
    panel_template_id: int = Field(gt=0, le=2147483647)
    is_active: bool = True

    @field_validator("slug")
    @classmethod
    def slug_format(cls, value: str) -> str:
        return validate_slug(value)

    @field_validator("name")
    @classmethod
    def name_not_blank(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("name must not be blank")
        return value

    @field_validator("currency")
    @classmethod
    def currency_code(cls, value: str) -> str:
        value = value.strip().upper()
        if not re.fullmatch(r"[A-Z]{3}", value):
            raise ValueError("currency must be a three-letter code")
        return value


class StorePlanPatch(BaseModel):
    slug: str | None = Field(default=None, min_length=1, max_length=80)
    name: str | None = Field(default=None, min_length=1, max_length=120)
    description: str | None = Field(default=None, max_length=4000)
    price_minor: int | None = Field(default=None, ge=0, le=9000000000000000000)
    currency: str | None = Field(default=None, min_length=3, max_length=3)
    duration_seconds: int | None = Field(default=None, gt=0, le=9000000000000000000)
    data_limit_bytes: int | None = Field(default=None, ge=0, le=9000000000000000000)
    panel_template_id: int | None = Field(default=None, gt=0, le=2147483647)
    is_active: bool | None = None

    @field_validator("slug")
    @classmethod
    def patch_slug_format(cls, value: str | None) -> str | None:
        return validate_slug(value) if value is not None else None

    @field_validator("name")
    @classmethod
    def patch_name_not_blank(cls, value: str | None) -> str | None:
        if value is None:
            return value
        value = value.strip()
        if not value:
            raise ValueError("name must not be blank")
        return value

    @field_validator("currency")
    @classmethod
    def patch_currency_code(cls, value: str | None) -> str | None:
        if value is None:
            return None
        value = value.strip().upper()
        if not re.fullmatch(r"[A-Z]{3}", value):
            raise ValueError("currency must be a three-letter code")
        return value


class PanelConnectionPublic(BaseModel):
    base_url: str
    api_key_configured: bool
    encryption_ready: bool


class PanelConnectionPatch(BaseModel):
    base_url: str | None = Field(default=None, min_length=1, max_length=2048)
    api_key: str | None = Field(default=None, min_length=1, max_length=4096)

    @field_validator("base_url")
    @classmethod
    def panel_url_is_safe(cls, value: str | None) -> str | None:
        if value is None:
            return None
        from app.panel.connection_settings import normalize_panel_url
        return normalize_panel_url(value)

    @field_validator("api_key")
    @classmethod
    def normalize_api_key(cls, value: str | None) -> str | None:
        if value is None:
            return None
        value = value.strip()
        if not value:
            raise ValueError("api_key must not be blank; omit it to keep the existing key")
        return value


class StoreSettingsPublic(BaseModel):
    store_name: str
    store_description: str
    default_currency: str
    support_url: str | None
    maintenance_mode: bool
    card_transfer_enabled: bool = False
    card_holder_name: str = ""
    card_number: str = ""
    card_bank_name: str = ""
    card_transfer_instructions: str = ""

    model_config = ConfigDict(from_attributes=True)


class StoreSettingsPatch(BaseModel):
    store_name: str | None = Field(default=None, min_length=1, max_length=120)
    store_description: str | None = Field(default=None, max_length=2000)
    default_currency: str | None = Field(default=None, min_length=3, max_length=3)
    support_url: str | None = Field(default=None, max_length=2048)
    maintenance_mode: bool | None = None
    card_transfer_enabled: bool | None = None
    card_holder_name: str | None = Field(default=None, max_length=120)
    card_number: str | None = Field(default=None, max_length=32)
    card_bank_name: str | None = Field(default=None, max_length=120)
    card_transfer_instructions: str | None = Field(default=None, max_length=2000)

    @field_validator("card_number")
    @classmethod
    def validate_card_number(cls, value: str | None) -> str | None:
        if value is None:
            return None
        normalized = value.strip()
        digits = re.sub(r"[\s-]", "", normalized)
        if digits and not re.fullmatch(r"[0-9]{16,19}", digits):
            raise ValueError("card_number must contain 16 to 19 digits")
        return digits

    @field_validator("card_holder_name", "card_bank_name", "card_transfer_instructions")
    @classmethod
    def normalize_card_text(cls, value: str | None) -> str | None:
        return value.strip() if value is not None else None

    @field_validator("store_name")
    @classmethod
    def settings_name_not_blank(cls, value: str | None) -> str | None:
        if value is None:
            return None
        value = value.strip()
        if not value:
            raise ValueError("store_name must not be blank")
        return value

    @field_validator("store_description")
    @classmethod
    def normalize_store_description(cls, value: str | None) -> str | None:
        return value.strip() if value is not None else None

    @field_validator("default_currency")
    @classmethod
    def settings_currency_code(cls, value: str | None) -> str | None:
        if value is None:
            return None
        value = value.strip().upper()
        if not re.fullmatch(r"[A-Z]{3}", value):
            raise ValueError("default_currency must be a three-letter code")
        return value

    @field_validator("support_url")
    @classmethod
    def support_url_must_be_https(cls, value: str | None) -> str | None:
        if value is None or not value.strip():
            return None
        from urllib.parse import urlsplit
        normalized = value.strip()
        parsed = urlsplit(normalized)
        if parsed.scheme != "https" or not parsed.hostname or parsed.username or parsed.password or parsed.fragment:
            raise ValueError("support_url must be an HTTPS URL without credentials or fragment")
        return normalized


class StoreOrderCreate(BaseModel):
    plan_id: UUID
    customer_reference: str = Field(min_length=2, max_length=120)

    @field_validator("customer_reference")
    @classmethod
    def customer_reference_not_blank(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("customer_reference must not be blank")
        return value


class StoreOrderPublic(BaseModel):
    id: UUID
    status: str
    amount_minor: int
    currency: str
    plan_name: str
    customer_reference: str
    receipt_submitted: bool
    created_at: str


class StoreOrderCreateResponse(BaseModel):
    order_id: UUID
    receipt_token: str
    status: str
    amount_minor: int
    currency: str
    plan_name: str
    card_transfer_enabled: bool
    card_holder_name: str
    card_number: str
    card_bank_name: str
    card_transfer_instructions: str


class ReceiptUpload(BaseModel):
    filename: str = Field(min_length=1, max_length=180)
    content_type: str = Field(min_length=1, max_length=80)
    content_base64: str = Field(min_length=16, max_length=7_000_000)
    transfer_reference: str | None = Field(default=None, max_length=120)

    @field_validator("filename")
    @classmethod
    def safe_filename(cls, value: str) -> str:
        value = value.replace("\\", "/").split("/")[-1].strip()
        if not value or value in {".", ".."}:
            raise ValueError("invalid filename")
        return value

    @field_validator("content_type")
    @classmethod
    def supported_receipt_type(cls, value: str) -> str:
        value = value.strip().lower()
        if value not in {"image/jpeg", "image/png", "image/webp", "application/pdf"}:
            raise ValueError("receipt must be JPEG, PNG, WebP, or PDF")
        return value


class AdminOrderPublic(BaseModel):
    id: UUID
    status: str
    amount_minor: int
    currency: str
    plan_name: str
    customer_reference: str
    receipt_filename: str | None
    receipt_content_type: str | None
    receipt_sha256: str | None
    receipt_uploaded_at: str | None
    admin_note: str | None
    created_at: str


class AdminOrderReview(BaseModel):
    action: str = Field(pattern="^(approve|reject)$")
    note: str | None = Field(default=None, max_length=2000)


class AccountCredentials(BaseModel):
    username: str = Field(min_length=3, max_length=32)
    password: str = Field(min_length=10, max_length=128)

    @field_validator("username")
    @classmethod
    def username_format(cls, value: str) -> str:
        value = value.strip().lower()
        if not re.fullmatch(r"[a-z0-9][a-z0-9_.-]{2,31}", value):
            raise ValueError("username must be 3-32 lowercase letters, numbers, dots, underscores or hyphens")
        return value


class AccountPublic(BaseModel):
    id: UUID
    username: str
    created_at: str


class AccountSessionResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_at: str
    user: AccountPublic


class AccountOrderPublic(BaseModel):
    id: UUID
    status: str
    amount_minor: int
    currency: str
    plan_name: str
    customer_reference: str
    receipt_submitted: bool
    created_at: str
