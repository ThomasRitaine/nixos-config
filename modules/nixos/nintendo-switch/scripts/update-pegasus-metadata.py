#!/usr/bin/env python3
"""Generates isolated *.metadata.pegasus.txt files for Games, Controllers, and Settings."""

import argparse
import json
import pathlib
import re
import sys
import urllib.request

CONTROLLER_PRESETS = [
    (
        "1p-8bitdo",
        "1P: 8BitDo",
        "8bitdo",
        "P1: 8BitDo (Vibration ON | Exit: Home + Minus)",
    ),
    (
        "1p-moonlight",
        "1P: Moonlight",
        "moonlight",
        "P1: Moonlight iPad/Phone (Vibration OFF | Exit: Minus + Plus)",
    ),
    (
        "2p-8bitdo-8bitdo",
        "2P: 8BitDo + 8BitDo",
        "8bitdo 8bitdo",
        "P1: 8BitDo #1 | P2: 8BitDo #2 (Vibration ON | Exit: Home + Minus)",
    ),
    (
        "2p-8bitdo-moonlight",
        "2P: 8BitDo + Moonlight",
        "8bitdo moonlight",
        "P1: 8BitDo (Vib ON) | P2: Moonlight (Vib OFF) | Exit: Home + Minus",
    ),
    (
        "2p-moonlight-moonlight",
        "2P: Moonlight + Moonlight",
        "moonlight moonlight",
        "P1: Moonlight #1 | P2: Moonlight #2 (Vib OFF | Exit: Minus + Plus)",
    ),
    (
        "3p-8bitdo-2x-moonlight",
        "3P: 8BitDo + 2x Moonlight",
        "8bitdo moonlight moonlight",
        "P1: 8BitDo | P2: Moonlight #1 | P3: Moonlight #2 (Exit: Home + Minus)",
    ),
    (
        "3p-2x-8bitdo-moonlight",
        "3P: 2x 8BitDo + Moonlight",
        "8bitdo 8bitdo moonlight",
        "P1: 8BitDo #1 | P2: 8BitDo #2 | P3: Moonlight (Exit: Home + Minus)",
    ),
]


def parse_args():
    parser = argparse.ArgumentParser(
        description="Update Pegasus metadata for Switch games."
    )
    parser.add_argument(
        "--rom-dir",
        required=True,
        type=pathlib.Path,
        help="Directory containing .nsp/.xci ROMs",
    )
    parser.add_argument(
        "--eden-bin",
        required=True,
        type=str,
        help="Path to the Eden executable binary",
    )
    parser.add_argument(
        "--eden-home-script",
        required=True,
        type=str,
        help="Path to switch-home-menu script",
    )
    parser.add_argument(
        "--eden-gui-script",
        required=True,
        type=str,
        help="Path to eden-settings script",
    )
    parser.add_argument(
        "--set-controllers-bin",
        required=True,
        type=str,
        help="Path to set-switch-controllers executable",
    )
    return parser.parse_args()


def clean_filename(stem: str) -> str:
    s = re.sub(r"\[[^\]]*\]|\([^\)]*\)", " ", stem)
    s = re.sub(r"(?i)\b(superxci|xci|nsp|base|dlc|upd|update)\b", " ", s)
    s = re.sub(r"(?i)\s*-[a-z0-9]+$", " ", s)
    s = re.sub(r"[._-]+", " ", s)
    s = re.sub(r"\s+", " ", s).strip()
    return s.title() if s.islower() else (s or stem)


def dl_image(url: str, dest: pathlib.Path):
    if not url or dest.exists():
        return
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=15) as response:
            dest.write_bytes(response.read())
    except Exception as e:
        print(f"  Warning: could not download {url}: {e}", file=sys.stderr)


def main():
    args = parse_args()
    rom_dir = args.rom_dir
    media_dir = rom_dir / "media"
    presets_dir = rom_dir / ".presets"
    media_dir.mkdir(parents=True, exist_ok=True)
    presets_dir.mkdir(parents=True, exist_ok=True)
    db_cache = media_dir / ".titledb_US.en.json"

    by_id = {}
    by_norm = {}

    if not db_cache.exists():
        try:
            print("Downloading Switch TitleDB (one-time cache)...")
            req = urllib.request.Request(
                "https://raw.githubusercontent.com/blawar/titledb/master/US.en.json",
                headers={"User-Agent": "Mozilla/5.0"},
            )
            with urllib.request.urlopen(req, timeout=30) as r:
                db_cache.write_bytes(r.read())
        except Exception as e:
            print(
                f"Warning: Could not download TitleDB ({e}); using filename cleanup"
                " only.",
                file=sys.stderr,
            )

    if db_cache.exists():
        try:
            raw_db = json.loads(db_cache.read_text(encoding="utf-8"))
            for entry in raw_db.values():
                if not isinstance(entry, dict):
                    continue
                tid = str(entry.get("id") or "").upper()
                name = str(entry.get("name") or "").strip()
                if not tid.endswith("000") or not name or not entry.get("iconUrl"):
                    continue
                by_id.setdefault(tid, entry)
                norm = re.sub(r"[^a-z0-9]+", "", name.lower())
                if norm:
                    by_norm.setdefault(norm, entry)
        except Exception as e:
            print(f"Warning: Failed to parse cached TitleDB ({e}).", file=sys.stderr)

    # Remove old single metadata.pegasus.txt or stale *.metadata.pegasus.txt files
    old_meta = rom_dir / "metadata.pegasus.txt"
    if old_meta.exists() or old_meta.is_symlink():
        old_meta.unlink()
    for stale in rom_dir.glob("*.metadata.pegasus.txt"):
        stale.unlink()

    roms = sorted(
        [
            p
            for p in rom_dir.iterdir()
            if p.is_file() and p.suffix.lower() in (".nsp", ".xci")
        ],
        key=lambda p: p.name.lower(),
    )

    # 1. File 01: Games Tab ONLY (01-games.metadata.pegasus.txt)
    games_lines = [
        "collection: Games",
        "shortname: games",
        "sort-by: 01",
        f'launch: {args.eden_bin} -f -g "{{file.path}}"',
        "files:",
    ]
    for rom in roms:
        games_lines.append(f"  {rom.name}")
    games_lines.append("")

    for rom in roms:
        m_tid = re.search(r"\[(0100[0-9A-Fa-f]{12})\]", rom.name)
        tid = m_tid.group(1).upper() if m_tid else None
        cleaned = clean_filename(rom.stem)
        norm = re.sub(r"[^a-z0-9]+", "", cleaned.lower())
        info = (by_id.get(tid) if tid else None) or by_norm.get(norm)
        title = info["name"].strip() if (info and info.get("name")) else cleaned
        safe_dir = re.sub(r"[^A-Za-z0-9 _.-]+", "", title).strip() or rom.stem
        g_media = media_dir / safe_dir
        g_media.mkdir(parents=True, exist_ok=True)

        games_lines.append(f"game: {title}")
        games_lines.append(f"file: {rom.name}")
        if info:
            if info.get("publisher"):
                games_lines.append(f"developer: {info['publisher']}")
                games_lines.append(f"publisher: {info['publisher']}")
            if info.get("numberOfPlayers"):
                games_lines.append(f"players: {info['numberOfPlayers']}")
            rd = str(info.get("releaseDate") or "")
            if len(rd) == 8 and rd.isdigit():
                games_lines.append(f"release: {rd[:4]}-{rd[4:6]}-{rd[6:8]}")
            desc = str(info.get("description") or "").strip()
            if desc:
                first_para = re.sub(r"\s+", " ", desc.splitlines()[0]).strip()
                games_lines.append(f"summary: {first_para[:220]}")
                games_lines.append(f"description: {re.sub(r'\s+', ' ', desc)}")
            box = g_media / "boxFront.jpg"
            bg = g_media / "background.jpg"
            dl_image(info.get("iconUrl"), box)
            dl_image(info.get("bannerUrl"), bg)
            if box.exists():
                games_lines.append(f"assets.boxFront: media/{safe_dir}/boxFront.jpg")
            if bg.exists():
                games_lines.append(
                    f"assets.background: media/{safe_dir}/background.jpg"
                )
        print(f"Indexed: {title} ({rom.name})")
        games_lines.append("")

    games_meta = rom_dir / "01-games.metadata.pegasus.txt"
    games_meta.write_text("\n".join(games_lines), encoding="utf-8")
    print(f"Wrote {games_meta}")

    # 2. File 02: Controllers Tab ONLY (02-controllers.metadata.pegasus.txt)
    for old_file in presets_dir.glob("*.preset"):
        old_file.unlink()

    ctrl_lines = [
        "collection: Controllers",
        "shortname: controllers",
        "sort-by: 02",
        "files:",
    ]
    for slug, _, _, _ in CONTROLLER_PRESETS:
        preset_file = presets_dir / f"{slug}.preset"
        preset_file.write_text(slug + "\n", encoding="utf-8")
        ctrl_lines.append(f"  .presets/{slug}.preset")
    ctrl_lines.append("")

    for slug, title, preset_args, summary in CONTROLLER_PRESETS:
        ctrl_lines.extend(
            [
                f"game: {title}",
                f"file: .presets/{slug}.preset",
                f"launch: {args.set_controllers_bin} {preset_args}",
                f"summary: {summary}",
                f"description: {summary}",
                "",
            ]
        )

    ctrl_meta = rom_dir / "02-controllers.metadata.pegasus.txt"
    ctrl_meta.write_text("\n".join(ctrl_lines), encoding="utf-8")
    print(f"Wrote {ctrl_meta}")

    # 3. File 03: Settings Tab ONLY (03-settings.metadata.pegasus.txt)
    settings_lines = [
        "collection: Settings",
        "shortname: settings",
        "sort-by: 03",
        "files:",
        f"  {args.eden_home_script}",
        f"  {args.eden_gui_script}",
        "",
        "game: Switch Home Menu",
        f"file: {args.eden_home_script}",
        f"launch: {args.eden_home_script}",
        (
            "summary: Open the native Nintendo Switch Home Menu (Miis, profiles,"
            " system settings)"
        ),
        "",
        "game: Eden settings",
        f"file: {args.eden_gui_script}",
        f"launch: {args.eden_gui_script}",
        "summary: Open Eden desktop configuration (requires touch or mouse)",
        "",
    ]

    settings_meta = rom_dir / "03-settings.metadata.pegasus.txt"
    settings_meta.write_text("\n".join(settings_lines), encoding="utf-8")
    print(f"Wrote {settings_meta}")


if __name__ == "__main__":
    main()
