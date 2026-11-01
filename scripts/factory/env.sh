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
  else
    echo "❌ $name FALLÓ (log: $log)"
    grep -E "error:|✘|failed|Failing tests:|XCTAssert|Expectation failed|^Test case .* failed" "$log" | grep -v "^note:" | head -40
    exit 1
  fi
}

# Número de tests que pasaron. Prefiere el .xcresult (fuente de verdad) y si no, cuenta en el log.
# El log mezcla dos formatos: Swift Testing ("✔ Test x() passed"; los parametrizados empiezan con U+200B,
# por eso el prefijo [^A-Za-z]*, y se excluye el resumen "Test run with N tests") y XCTest ("Test Case '...' passed").
count_passed_tests() {
  local result="$1" log="$2" n=""
  if [[ -d "$result" ]]; then
    n=$(xcrun xcresulttool get test-results summary --path "$result" 2>/dev/null \
          | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["passedTests"])' 2>/dev/null || true)
  fi
  if [[ -z "$n" ]]; then
    n=$(grep -E '^[^A-Za-z]*✔ Test .* passed|^Test [Cc]ase .* passed' "$log" | grep -vc 'Test run with' || true)
  fi
  echo "$n"
}
