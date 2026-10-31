#!/usr/bin/env bash
# SwiftLint: falla solo con violaciones de severidad error.
source "$(dirname "$0")/env.sh"
cd "$ROOT"
if ! command -v swiftlint >/dev/null; then echo "⚠️  swiftlint no instalado (brew install swiftlint); se omite"; exit 0; fi
if swiftlint lint --quiet --reporter emoji >"$LOG_DIR/lint.log" 2>&1 && ! grep -q "⛔️" "$LOG_DIR/lint.log"; then
  echo "✅ lint OK ($(grep -c "⚠️" "$LOG_DIR/lint.log" || true) warnings)"
else
  echo "❌ lint FALLÓ"; grep "⛔️" "$LOG_DIR/lint.log" | head -30; exit 1
fi
