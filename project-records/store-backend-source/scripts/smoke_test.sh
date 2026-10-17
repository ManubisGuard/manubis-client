#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://127.0.0.1:8091}"
BASE_URL="${BASE_URL%/}"

check_status() {
  local path="$1" expected="$2" actual
  actual="$(curl --silent --show-error --output /tmp/manubisguard-smoke-body --write-out '%{http_code}' --max-time 5 "$BASE_URL$path")"
  if [[ "$actual" != "$expected" ]]; then
    printf 'FAIL %s: expected HTTP %s, got %s\n' "$path" "$expected" "$actual" >&2
    cat /tmp/manubisguard-smoke-body >&2 || true
    exit 1
  fi
  printf 'PASS %s -> HTTP %s\n' "$path" "$actual"
}

check_status /health/live 200
check_status /admin 200
check_status /api/v1/store/settings 200
check_status /api/v1/store/plans 200
check_status /api/v1/admin/plans 401

printf '\nSmoke checks passed. This verifies the local test deployment only; it does not validate panel credentials, payments, or customer provisioning.\n'
