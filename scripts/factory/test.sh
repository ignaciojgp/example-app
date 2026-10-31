#!/usr/bin/env bash
# Ejecuta tests. Uso: test.sh [--ui]   (por defecto solo unit tests; --ui incluye UI tests)
source "$(dirname "$0")/env.sh"
ONLY=(-only-testing:example-appTests)
[[ "${1:-}" == "--ui" ]] && ONLY=()
RESULT="$ROOT/.build/TestResults.xcresult"; rm -rf "$RESULT"
run_xcodebuild test test "${ONLY[@]}" -resultBundlePath "$RESULT" CODE_SIGNING_ALLOWED=NO
