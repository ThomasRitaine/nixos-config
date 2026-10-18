#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: import-switch-games <path-to-folder-or-file> [...]" >&2
  exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
  exec sudo "$0" "$@"
fi

: "${ROM_DIR:?ROM_DIR must be set in the environment}"
: "${ADDONS_DIR:?ADDONS_DIR must be set in the environment}"
: "${UPDATE_METADATA_BIN:?UPDATE_METADATA_BIN must be set in the environment}"
: "${FIND_BIN:=find}"

mkdir -p "${ROM_DIR}" "${ADDONS_DIR}"

found=0
for target in "$@"; do
  if [ ! -e "$target" ]; then
    echo "Error: '$target' does not exist" >&2
    exit 1
  fi

  while IFS= read -r f; do
    [ -n "$f" ] || continue
    b="$(basename "$f")"
    case "$b" in
    *\[Up* | *\[UPD* | *Update* | *\[DLC* | *DLC*)
      echo "-> [Update/DLC] $b -> ${ADDONS_DIR}/"
      mv -v "$f" "${ADDONS_DIR}/$b"
      ;;
    *)
      echo "-> [Base Game]  $b -> ${ROM_DIR}/"
      mv -v "$f" "${ROM_DIR}/$b"
      ;;
    esac
    found=1
  done < <("${FIND_BIN}" "$target" -type f \( -iname "*.nsp" -o -iname "*.xci" \))
done

if [ "$found" -eq 0 ]; then
  echo "No .nsp or .xci files found in: $*" >&2
  exit 1
fi

"${UPDATE_METADATA_BIN}"
systemctl restart greetd
echo "Done! Imported games, updated metadata/artwork, and restarted Pegasus."
