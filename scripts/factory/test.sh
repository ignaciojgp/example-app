#!/usr/bin/env bash
# Ejecuta tests. Uso: test.sh [--ui]   (por defecto solo unit tests; --ui incluye UI tests)
#
# Por defecto los tests corren en serie en UN solo simulador. Con testing en paralelo, xcodebuild
# clona el simulador por núcleo, y en máquinas de 8 GB eso satura memoria/CPU (load > 150)
# y provoca timeouts de foco/accesibilidad en los UI tests.
#
# ⚠️  En modo serie se ejecuta `xcrun simctl shutdown all`: se apagan TODOS los simuladores de la
#     máquina, incluidos los que tengas abiertos para otra cosa.
#
# Paralelismo (máquinas grandes): PARALLEL_TESTING=YES scripts/factory/test.sh
# (acepta YES/TRUE/1/ON en cualquier combinación de mayúsculas; cualquier otro valor = NO).
source "$(dirname "$0")/env.sh"
ONLY=(-only-testing:example-appTests)
[[ "${1:-}" == "--ui" ]] && ONLY=()

case "$(printf '%s' "${PARALLEL_TESTING:-NO}" | tr '[:lower:]' '[:upper:]')" in
  YES|TRUE|1|ON) PARALLEL_TESTING=YES ;;
  *)             PARALLEL_TESTING=NO ;;
esac

if [[ "$PARALLEL_TESTING" == "NO" ]]; then
  # Libera simuladores (y sus clones) de corridas anteriores antes de arrancar.
  xcrun simctl shutdown all >/dev/null 2>&1 || true
fi

RESULT="$ROOT/.build/TestResults.xcresult"; rm -rf "$RESULT"
run_xcodebuild test test ${ONLY[@]+"${ONLY[@]}"} \
  -parallel-testing-enabled "$PARALLEL_TESTING" \
  -resultBundlePath "$RESULT" CODE_SIGNING_ALLOWED=NO
echo "   $(count_passed_tests "$RESULT" "$LOG_DIR/test.log") tests pasaron (paralelo: $PARALLEL_TESTING)"
