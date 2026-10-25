#!/usr/bin/env python3
"""Pins selected keys in Eden's qt-config.ini right before Eden starts.

Eden rewrites qt-config.ini on exit, so a read-only Nix-managed file would break
it. Instead, the `eden` wrapper calls this script with KEY=VALUE pairs.

To test settings in the Eden GUI without them being reset, temporarily run:
  sudo -u nintendo-switch touch /home/nintendo-switch/.config/eden/.no-pin
and remove the file when done.
"""

import os
import pathlib
import re
import sys

CFG_DIR = pathlib.Path("/home/nintendo-switch/.config/eden")
CFG_PATH = CFG_DIR / "qt-config.ini"
NO_PIN = CFG_DIR / ".no-pin"


def main() -> None:
    if NO_PIN.exists():
        print(f"apply-eden-settings: {NO_PIN} present, not pinning", file=sys.stderr)
        return
    if not CFG_PATH.exists():
        return  # first launch: Eden creates the file, pins apply from the next launch
    if os.geteuid() != CFG_PATH.stat().st_uid:
        print("apply-eden-settings: not the config owner, skipping", file=sys.stderr)
        return

    text = CFG_PATH.read_text(encoding="utf-8")
    new = text
    for arg in sys.argv[1:]:
        key, sep, value = arg.partition("=")
        if not sep:
            continue
        esc = re.escape(key)
        if not re.search(rf"^{esc}=", new, flags=re.M):
            print(f"apply-eden-settings: '{key}' not found, skipped", file=sys.stderr)
            continue
        new = re.sub(
            rf"^{esc}\\default=.*$", lambda _: f"{key}\\default=false", new, flags=re.M
        )
        new = re.sub(rf"^{esc}=.*$", lambda _: f"{key}={value}", new, flags=re.M)

    if new != text:
        tmp = CFG_PATH.with_name(CFG_PATH.name + ".pin-tmp")
        tmp.write_text(new, encoding="utf-8")
        os.replace(tmp, CFG_PATH)


if __name__ == "__main__":
    main()
