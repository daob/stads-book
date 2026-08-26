#!/usr/bin/env python3
"""Copy the frozen figures into the working directories Quarto's LaTeX run expects.

Chunk output lives in _freeze/<chapter>/figure-<format>/, but the .tex that
xelatex compiles refers to <chapter>_files/figure-<format>/. Quarto normally
populates those directories itself; when it does not — a fresh clone, a cleaned
tree, an interrupted render — the PDF build fails with

    Unable to load picture or PDF file '..._files/figure-pdf/fig-....png'

Copying the frozen figures across first makes the build independent of that,
which matters most in CI, where every checkout starts without the directories.
Idempotent: files are copied only when missing or different.
"""
from pathlib import Path
import shutil
import sys

ROOT = Path(__file__).resolve().parent.parent


def main():
    freeze = ROOT / "_freeze"
    if not freeze.is_dir():
        print("restore-figures: no _freeze/ directory; nothing to do")
        return 0

    copied = 0
    for doc in sorted(p for p in freeze.iterdir() if p.is_dir()):
        if doc.name == "site_libs":
            continue
        for figdir in sorted(doc.glob("figure-*")):
            target = ROOT / f"{doc.name}_files" / figdir.name
            target.mkdir(parents=True, exist_ok=True)
            for src in sorted(figdir.iterdir()):
                if not src.is_file():
                    continue
                dst = target / src.name
                if dst.exists() and dst.stat().st_size == src.stat().st_size:
                    continue
                shutil.copy2(src, dst)
                copied += 1

    print(f"restore-figures: {copied} figure file(s) copied from _freeze/")
    return 0


if __name__ == "__main__":
    sys.exit(main())
