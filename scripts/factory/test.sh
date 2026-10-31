#!/usr/bin/env bash
# Ejecuta tests. Uso: test.sh [--ui]   (por defecto solo unit tests; --ui incluye UI tests)
#
# Los tests se ejecutan en serie en UN solo simulador. Con testing en paralelo, xcodebuild
# clona el simulador por núcleo, y en máquinas de 8 GB eso satura memoria/CPU (load > 150)
# y provoca timeouts de foco/accesibilidad en los UI tests.
# Para permitir paralelismo en máquinas grandes: PARALLEL_TESTING=YES scripts/factory/test.sh
source "$(dirname "$0")/env.sh"
ONLY=(-only-testing:example-appTests)
[[ "${1:-}" == "--ui" ]] && ONLY=()
PARALLEL_TESTING="${PARALLEL_TESTING:-NO}"

if [[ "$PARALLEL_TESTING" == "NO" ]]; then
  # Libera simuladores (y sus clones) de corridas anteriores antes de arrancar.
  xcrun simctl shutdown all >/dev/null 2>&1 || true
fi

RESULT="$ROOT/.build/TestResults.xcresult"; rm -rf "$RESULT"
run_xcodebuild test test ${ONLY[@]+"${ONLY[@]}"} \
  -parallel-testing-enabled "$PARALLEL_TESTING" \
  -resultBundlePath "$RESULT" CODE_SIGNING_ALLOWED=NO
