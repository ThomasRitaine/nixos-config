#!/usr/bin/env python3
"""Applies controller presets and input profiles to Eden's qt-config.ini."""

import pathlib
import re
import subprocess
import sys

CFG_PATH = pathlib.Path("/home/nintendo-switch/.config/eden/qt-config.ini")
PROFILE_DIR = pathlib.Path("/home/nintendo-switch/.config/eden/input")

GUIDS = {
    "8bitdo": "03000000c82d00000b31000000010000",
    "moonlight": "0000000053756e7368696e65204d6f00",
}

BINDINGS_TEMPLATE = {
    "button_a": '"{prefix},button:1"',
    "button_b": '"{prefix},button:0"',
    "button_x": '"{prefix},button:3"',
    "button_y": '"{prefix},button:2"',
    "button_lstick": '"{prefix},button:9"',
    "button_rstick": '"{prefix},button:10"',
    "button_l": '"{prefix},button:4"',
    "button_r": '"{prefix},button:5"',
    "button_zl": '"{prefix},axis:2,threshold:0.500000,invert:+"',
    "button_zr": '"{prefix},axis:5,threshold:0.500000,invert:+"',
    "button_plus": '"{prefix},button:7"',
    "button_minus": '"{prefix},button:6"',
    "button_dleft": '"{prefix},hat:0,direction:left"',
    "button_dup": '"{prefix},hat:0,direction:up"',
    "button_dright": '"{prefix},hat:0,direction:right"',
    "button_ddown": '"{prefix},hat:0,direction:down"',
    "button_slleft": '"{prefix},button:4"',
    "button_srleft": '"{prefix},button:5"',
    "button_home": '"{prefix},button:8"',
    "button_screenshot": "[empty]",
    "button_slright": '"{prefix},button:4"',
    "button_srright": '"{prefix},button:5"',
    "lstick": (
        '"{prefix},axis_x:0,axis_y:1,offset_x:-0.000000,offset_y:0.000000,'
        'invert_x:+,invert_y:+,deadzone:0.150000"'
    ),
    "rstick": (
        '"{prefix},axis_x:3,axis_y:4,offset_x:-0.000000,offset_y:0.000000,'
        'invert_x:+,invert_y:+,deadzone:0.150000"'
    ),
    "motionleft": "[empty]",
    "motionright": "[empty]",
}


def set_ini_key(text: str, key: str, value: str, default_str: str = "false") -> str:
    esc_key = re.escape(key)
    def_line = f"{key}\\default={default_str}"
    val_line = f"{key}={value}"

    if re.search(rf"^{esc_key}\\default=.*$", text, flags=re.M):
        text = re.sub(rf"^{esc_key}\\default=.*$", lambda _: def_line, text, flags=re.M)
    if re.search(rf"^{esc_key}=.*$", text, flags=re.M):
        text = re.sub(rf"^{esc_key}=.*$", lambda _: val_line, text, flags=re.M)
    else:
        text += f"\n{def_line}\n{val_line}\n"
    return text


def write_input_profiles():
    PROFILE_DIR.mkdir(parents=True, exist_ok=True)
    for name, guid in GUIDS.items():
        vib = "true" if name == "8bitdo" else "false"
        prefix = f"engine:sdl,port:0,guid:{guid}"
        lines = [
            "[Controls]",
            "type\\default=true",
            "type=0",
            f"vibration_enabled\\default={vib}",
            f"vibration_enabled={vib}",
            "vibration_strength\\default=true",
            "vibration_strength=100",
        ]
        for k, tmpl in BINDINGS_TEMPLATE.items():
            lines.append(f"{k}\\default=false")
            lines.append(f"{k}={tmpl.format(prefix=prefix)}")
        p = PROFILE_DIR / f"{name}.ini"
        p.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main():
    players = [arg.lower() for arg in sys.argv[1:]]
    if not players or len(players) > 4 or any(p not in GUIDS for p in players):
        print(
            "Usage: set-switch-controllers <8bitdo|moonlight> [player2] [player3]"
            " [player4]",
            file=sys.stderr,
        )
        sys.exit(1)

    # Ensure Eden is not running so it cannot overwrite qt-config.ini
    subprocess.run(
        ["pkill", "-9", "-x", ".eden-wrapped"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )

    write_input_profiles()

    text = CFG_PATH.read_text(encoding="utf-8")
    port_counters = {"8bitdo": 0, "moonlight": 0}
    any_8bitdo = "8bitdo" in players

    # Global vibration master switch: true only if at least one 8BitDo is active
    text = set_ini_key(
        text, "vibration_enabled", "true" if any_8bitdo else "false", "false"
    )

    # Exit hotkey: Home+Minus when Player 1 is 8BitDo, Minus+Plus when Player 1 is Moonlight
    exit_seq = "Home+Minus" if players[0] == "8bitdo" else "Minus+Plus"
    text = set_ini_key(
        text,
        "Shortcuts\\Main%20Window\\Exit%20Eden\\Controller_KeySeq",
        exit_seq,
        "false",
    )

    for idx in range(4):
        p_prefix = f"player_{idx}"
        if idx < len(players):
            ctype = players[idx]
            port = port_counters[ctype]
            port_counters[ctype] += 1
            guid = GUIDS[ctype]
            is_8bitdo = ctype == "8bitdo"

            text = set_ini_key(text, f"{p_prefix}_type", "0", "true")
            text = set_ini_key(text, f"{p_prefix}_connected", "true", "false")
            text = set_ini_key(text, f"{p_prefix}_profile_name", ctype, "false")
            text = set_ini_key(
                text,
                f"{p_prefix}_vibration_enabled",
                "true" if is_8bitdo else "false",
                "false",
            )

            sdl_prefix = f"engine:sdl,port:{port},guid:{guid}"
            for btn_key, tmpl in BINDINGS_TEMPLATE.items():
                text = set_ini_key(
                    text,
                    f"{p_prefix}_{btn_key}",
                    tmpl.format(prefix=sdl_prefix),
                    "false",
                )
        else:
            text = set_ini_key(text, f"{p_prefix}_connected", "false", "false")
            text = set_ini_key(text, f"{p_prefix}_vibration_enabled", "false", "false")

    CFG_PATH.write_text(text, encoding="utf-8")
    print(f"Applied preset: {' + '.join(players)} (Exit: {exit_seq})")


if __name__ == "__main__":
    main()
