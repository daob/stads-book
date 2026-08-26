"""Freeze check.

Chunk output is committed in _freeze/ so that the book can be rendered without
the LISS microdata or any R package. Quarto freezes each output format
separately, so every chapter with code needs three frozen results — HTML, LaTeX
and EPUB. A missing one sends the build looking for R, which is what fails in
CI; `make all` regenerates them.
"""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
CHUNK = re.compile(r"^```\{r[ ,}]", re.M)


def main():
    failures = []
    chapters = [p for p in sorted(ROOT.glob("[0-9]*.qmd")) if CHUNK.search(p.read_text())]
    for qmd in chapters:
        base = ROOT / "_freeze" / qmd.stem / "execute-results"
        for fmt in ("html.json", "tex.json", "epub.json"):
            if not (base / fmt).exists():
                failures.append(f"{qmd.name}: no frozen {fmt}; run `make all` and "
                                f"commit _freeze/{qmd.stem}/")
    print(f"freeze: {len(chapters)} chapters with code, "
          f"{3 * len(chapters) - len(failures)}/{3 * len(chapters)} frozen results present")
    for f in failures:
        print("  FAIL", f)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
