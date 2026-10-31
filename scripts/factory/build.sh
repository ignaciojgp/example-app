#!/usr/bin/env bash
# Compila la app para simulador.
source "$(dirname "$0")/env.sh"
run_xcodebuild build build CODE_SIGNING_ALLOWED=NO
