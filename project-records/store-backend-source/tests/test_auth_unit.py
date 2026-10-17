from app.routes.auth import hash_password, token_digest, verify_password
from app.schemas import AccountCredentials


def test_password_hash_uses_salted_pbkdf2_and_verifies():
    password = "unit-test-password-123!"
    encoded = hash_password(password)
    assert encoded.startswith("pbkdf2_sha256$310000$")
    assert password not in encoded
    assert verify_password(password, encoded)
    assert not verify_password("different-password", encoded)
    assert hash_password(password) != encoded


def test_account_username_is_normalized_and_validated():
    value = AccountCredentials(username="Test_User-1", password="long-enough-test-password")
    assert value.username == "test_user-1"


def test_account_username_rejects_invalid_values():
    try:
        AccountCredentials(username="a!", password="long-enough-test-password")
    except Exception as exc:
        assert "username" in str(exc)
    else:
        raise AssertionError("invalid username unexpectedly accepted")


def test_session_token_digest_does_not_retain_raw_token():
    token = "sample-session-token-for-unit-test"
    digest = token_digest(token)
    assert len(digest) == 64
    assert token not in digest
