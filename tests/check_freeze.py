"""Freeze check.

Chunk output is committed in _freeze/ so that the book can be rendered without
the LISS microdata or the analysis packages. Quarto freezes each output format
separately, so every chapter with code needs three frozen results — HTML, LaTeX
and EPUB — and each one records an MD5 hash of the chapter source it was
computed from. Quarto re-executes a chapter whenever that hash no longer
matches the file, and it does so after *any* edit to the .qmd, prose included,
not only after edits to code. A missing or stale result therefore sends the
build looking for R and the data, which is what fails in CI; `make all`
regenerates them.
"""
from pathlib import Path
import hashlib
import json
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
CHUNK = re.compile(r"^```\{r[ ,}]", re.M)


def main():
    failures = []
    chapters = [p for p in sorted(ROOT.glob("[0-9]*.qmd")) if CHUNK.search(p.read_text())]
    present = 0
    for qmd in chapters:
        base = ROOT / "_freeze" / qmd.stem / "execute-results"
        source_hash = hashlib.md5(qmd.read_bytes()).hexdigest()
        for fmt in ("html.json", "tex.json", "epub.json"):
            path = base / fmt
            if not path.exists():
                failures.append(f"{qmd.name}: no frozen {fmt}; run `make all` and "
                                f"commit _freeze/{qmd.stem}/")
                continue
            present += 1
            try:
                frozen_hash = json.loads(path.read_text()).get("hash")
            except (json.JSONDecodeError, OSError) as err:
                failures.append(f"{qmd.name}: cannot read {fmt} ({err})")
                continue
            if frozen_hash != source_hash:
                failures.append(f"{qmd.name}: frozen {fmt} is stale (the chapter changed "
                                f"after it was computed); run `make all` and commit "
                                f"_freeze/{qmd.stem}/")
    print(f"freeze: {len(chapters)} chapters with code, "
          f"{present}/{3 * len(chapters)} frozen results present, "
          f"{len(failures)} stale or missing")
    for f in failures:
        print("  FAIL", f)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
