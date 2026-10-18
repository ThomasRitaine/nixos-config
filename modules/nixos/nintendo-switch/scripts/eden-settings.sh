#!/usr/bin/env bash
set -euo pipefail

: "${EDEN_BIN:=eden}"
exec "${EDEN_BIN}"
