#!/usr/bin/env bash
# Configuración compartida de los scripts de la fábrica. Sobrescribible por variables de entorno.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT="${PROJECT:-$ROOT/example-app.xcodeproj}"
SCHEME="${SCHEME:-example-app}"
DESTINATION="${DESTINATION:-platform=iOS Simulator,name=iPhone 17}"
DERIVED_DATA="${DERIVED_DATA:-$ROOT/.build/DerivedData}"
LOG_DIR="${LOG_DIR:-$ROOT/.build/logs}"
mkdir -p "$LOG_DIR"

# Ejecuta xcodebuild guardando el log completo y mostrando solo errores/resumen.
run_xcodebuild() {
  local name="$1"; shift
  local log="$LOG_DIR/$name.log"
  if xcodebuild -project "$PROJECT" -scheme "$SCHEME" -destination "$DESTINATION" \
       -derivedDataPath "$DERIVED_DATA" "$@" >"$log" 2>&1; then
    echo "✅ $name OK (log: $log)"
    n=$(grep -c "^Test case .* passed" "$log" || true); if [[ "$name" == test ]]; then echo "   $n tests pasaron"; fi
  else
    echo "❌ $name FALLÓ (log: $log)"
    grep -E "error:|✘|failed|Failing tests:|XCTAssert|Expectation failed|^Test case .* failed" "$log" | grep -v "^note:" | head -40
    exit 1
  fi
}
