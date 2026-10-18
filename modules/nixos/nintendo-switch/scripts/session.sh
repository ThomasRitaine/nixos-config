#!/usr/bin/env bash
set -euo pipefail

: "${PEGASUS_FE_BIN:?PEGASUS_FE_BIN must be provided in the environment}"

while true; do
  # Wait until any HDMI/DP output reports "connected"
  until grep -qx connected /sys/class/drm/card*-*/status 2>/dev/null; do
    sleep 5
  done

  /run/wrappers/bin/gamescope -W 1920 -H 1080 -r 60 -f -- "${PEGASUS_FE_BIN}" || true
  sleep 3
done
