#!/usr/bin/env python3
"""Build assets/exercises from local exercises-dataset clone + names_zh."""
from __future__ import annotations

import json
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATASET = ROOT / "exercises-dataset"
SRC_JSON = DATASET / "data" / "exercises.json"
VIDEOS = DATASET / "videos"
NAMES_ZH = ROOT / "tool" / "names_zh.json"
OUT_DIR = ROOT / "assets" / "exercises"
OUT_JSON = OUT_DIR / "catalog.json"
OUT_GIFS = OUT_DIR / "gifs"
CATALOG_VERSION = 1


def main() -> int:
    if not SRC_JSON.is_file():
        print(f"ERROR: missing {SRC_JSON}", file=sys.stderr)
        print("Clone exercises-dataset into project root first.", file=sys.stderr)
        return 1
    if not NAMES_ZH.is_file():
        print(f"ERROR: missing {NAMES_ZH}. Run tool/generate_names_zh.py first.", file=sys.stderr)
        return 1

    exercises = json.loads(SRC_JSON.read_text(encoding="utf-8"))
    names_zh = json.loads(NAMES_ZH.read_text(encoding="utf-8"))

    missing_names = [e["id"] for e in exercises if not str(names_zh.get(e["id"], "")).strip()]
    if missing_names:
        print(f"ERROR: {len(missing_names)} ids missing name_zh, e.g. {missing_names[:5]}", file=sys.stderr)
        return 1

    OUT_GIFS.mkdir(parents=True, exist_ok=True)

    # index videos by id prefix: "0001-xxxx.gif"
    video_by_id: dict[str, Path] = {}
    for p in VIDEOS.glob("*.gif"):
        eid = p.name.split("-", 1)[0]
        video_by_id[eid] = p

    out_items = []
    missing_gif = []
    for ex in exercises:
        eid = ex["id"]
        gif_src = video_by_id.get(eid)
        gif_asset = f"assets/exercises/gifs/{eid}.gif"
        if gif_src is None:
            missing_gif.append(eid)
        else:
            dest = OUT_GIFS / f"{eid}.gif"
            if not dest.exists() or dest.stat().st_size != gif_src.stat().st_size:
                shutil.copy2(gif_src, dest)

        steps = ex.get("instruction_steps", {}).get("zh") or []
        if not isinstance(steps, list):
            steps = []
        instructions = ex.get("instructions", {}).get("zh") or ""
        if not instructions and steps:
            instructions = "".join(steps)

        out_items.append(
            {
                "dataset_id": eid,
                "name_en": ex.get("name") or "",
                "name_zh": names_zh[eid],
                "body_part": ex.get("body_part") or ex.get("category") or "",
                "equipment": ex.get("equipment") or "",
                "target": ex.get("target") or "",
                "muscle_group": ex.get("muscle_group") or "",
                "secondary_muscles": ex.get("secondary_muscles") or [],
                "instructions_zh": instructions,
                "instruction_steps_zh": steps,
                "gif_asset": gif_asset,
            }
        )

    catalog = {"catalog_version": CATALOG_VERSION, "exercises": out_items}
    OUT_JSON.write_text(json.dumps(catalog, ensure_ascii=False, separators=(",", ":")) + "\n", encoding="utf-8")

    gif_count = len(list(OUT_GIFS.glob("*.gif")))
    print(f"catalog_version={CATALOG_VERSION}")
    print(f"exercises={len(out_items)}")
    print(f"gifs_written_or_present={gif_count}")
    print(f"missing_gif={len(missing_gif)} {missing_gif[:5] if missing_gif else ''}")
    print(f"wrote {OUT_JSON} ({OUT_JSON.stat().st_size / 1e6:.1f} MB)")
    if missing_gif:
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
