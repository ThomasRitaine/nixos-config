#!/usr/bin/env python3
"""Generates metadata.pegasus.txt and downloads Switch box art and banners."""

import argparse
import json
import pathlib
import re
import sys
import urllib.request


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
    media_dir.mkdir(parents=True, exist_ok=True)
    db_cache = media_dir / ".titledb_US.en.json"

    by_id = {}
    by_norm = {}

    # Download Switch TitleDB once if not cached
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

    lines = [
        "collection: Nintendo Switch",
        "shortname: switch",
        "extensions: nsp, xci",
        f'launch: {args.eden_bin} -f -g "{{file.path}}"',
        "",
    ]

    roms = sorted(
        [
            p
            for p in rom_dir.iterdir()
            if p.is_file() and p.suffix.lower() in (".nsp", ".xci")
        ],
        key=lambda p: p.name.lower(),
    )

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

        lines.append(f"game: {title}")
        lines.append(f"file: {rom.name}")
        if info:
            if info.get("publisher"):
                lines.append(f"developer: {info['publisher']}")
                lines.append(f"publisher: {info['publisher']}")
            if info.get("numberOfPlayers"):
                lines.append(f"players: {info['numberOfPlayers']}")
            rd = str(info.get("releaseDate") or "")
            if len(rd) == 8 and rd.isdigit():
                lines.append(f"release: {rd[:4]}-{rd[4:6]}-{rd[6:8]}")
            desc = str(info.get("description") or "").strip()
            if desc:
                first_para = re.sub(r"\s+", " ", desc.splitlines()[0]).strip()
                lines.append(f"summary: {first_para[:220]}")
                lines.append(f"description: {re.sub(r'\s+', ' ', desc)}")
            box = g_media / "boxFront.jpg"
            bg = g_media / "background.jpg"
            dl_image(info.get("iconUrl"), box)
            dl_image(info.get("bannerUrl"), bg)
            if box.exists():
                lines.append(f"assets.boxFront: media/{safe_dir}/boxFront.jpg")
            if bg.exists():
                lines.append(f"assets.background: media/{safe_dir}/background.jpg")
        print(f"Indexed: {title} ({rom.name})")
        lines.append("")

    lines.extend(
        [
            "collection: Tools",
            "shortname: tools",
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
    )

    meta_path = rom_dir / "metadata.pegasus.txt"
    if meta_path.is_symlink():
        meta_path.unlink()
    meta_path.write_text("\n".join(lines), encoding="utf-8")
    print(f"Wrote {meta_path}")


if __name__ == "__main__":
    main()
