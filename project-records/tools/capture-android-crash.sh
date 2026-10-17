#!/usr/bin/env bash
set -Eeuo pipefail
ADB_BIN="${ADB_BIN:-/opt/android-sdk/platform-tools/adb}"
PACKAGE="org.manubisguard.vpn"
OUT_DIR="${OUT_DIR:-/opt/manubisguard-build/logs}"
mkdir -p "$OUT_DIR"
COUNT="$($ADB_BIN devices | awk 'NR>1 && $2=="device" {n++} END {print n+0}')"
if [[ "$COUNT" != "1" ]]; then
  echo "Expected exactly one authorized Android device; found $COUNT."
  "$ADB_BIN" devices -l || true
  exit 2
fi
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
LOG="$OUT_DIR/manubisguard-logcat-$STAMP.txt"
MARKERS="$OUT_DIR/manubisguard-crash-markers-$STAMP.txt"
echo "Capturing Android logcat to: $LOG"
# Do not clear the user's existing log buffer. Capture first, then launch once.
timeout 55s "$ADB_BIN" logcat -b all -v threadtime > "$LOG" 2>&1 &
LOGCAT_PID=$!
sleep 2
"$ADB_BIN" shell monkey -p "$PACKAGE" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1 || true
wait "$LOGCAT_PID" || true
grep -nEi -C 5 'FATAL EXCEPTION|AndroidRuntime|Fatal signal|SIGSEGV|SIGABRT|tombstoned|libc.*(fatal|signal)|Qt.*(fatal|error)|QQmlApplicationEngine|qrc:/ui/qml/Pages2|Process .* has died|ANR in org.manubisguard.vpn' "$LOG" > "$MARKERS" || true
echo "Crash markers: $MARKERS"
if [[ -s "$MARKERS" ]]; then cat "$MARKERS"; else echo "No common fatal markers found. Review full log: $LOG"; fi
