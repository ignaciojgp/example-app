#!/usr/bin/env bash
# Puerta de calidad determinista: lint + build + tests. Uso: gate.sh [--ui]
DIR="$(dirname "$0")"
status=0
"$DIR/lint.sh"  || status=1
"$DIR/build.sh" || { echo "⛔ build falló; se omiten tests"; exit 1; }
"$DIR/test.sh" "$@" || status=1
[[ $status -eq 0 ]] && echo "🟢 GATE OK" || echo "🔴 GATE FALLÓ"
exit $status
