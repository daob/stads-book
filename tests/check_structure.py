"""Structural checks on the repository.

Verifies that the book's file list, the working tree and the conventions agree:
every chapter listed in _quarto.yml exists and every chapter file is listed, the
supporting files the build needs are present, no editing markers are left in the
text, and no microdata have crept in.
"""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
REQUIRED = [
    "_quarto.yml", "_quarto-answers.yml", "answers-in-back.lua", "apa.csl",
    "references.bib", "references.qmd", "index.qmd", "Makefile",
    "README.md", "CONTRIBUTING.md", "LICENSE", "LICENSE-CODE",
]
MARKERS = re.compile(r"<!--\s*DO:|\bTODO\b|\bFIXME\b|\[TODO\]|XXX+")
# Deliberate, registered open questions are written as <!-- OPEN(who): ... -->.
# They are reported but do not fail the check; drafting leftovers do.
OPEN_ITEM = re.compile(r"<!--\s*OPEN\(([^)]*)\):\s*(.*?)\s*-->", re.S)
DATA_SUFFIXES = {".dta", ".sav", ".rds", ".por"}


def listed_chapters(text):
    """The chapters: entries of _quarto.yml, without a YAML parser."""
    out, in_chapters = [], False
    for line in text.splitlines():
        if re.match(r"^\s{2}chapters:\s*$", line):
            in_chapters = True
            continue
        if in_chapters:
            m = re.match(r"^\s+-\s+(\S+\.qmd)\s*$", line)
            if m:
                out.append(m.group(1))
            elif line.strip() and not line.startswith(" " * 4):
                break
    return out


def main():
    failures = []
    config = (ROOT / "_quarto.yml").read_text()

    for name in REQUIRED:
        if not (ROOT / name).exists():
            failures.append(f"missing required file: {name}")

    listed = listed_chapters(config)
    if not listed:
        failures.append("could not read the chapter list from _quarto.yml")
    on_disk = sorted(p.name for p in ROOT.glob("*.qmd"))
    for name in listed:
        if not (ROOT / name).exists():
            failures.append(f"_quarto.yml lists {name}, which does not exist")
    for name in on_disk:
        if name not in listed:
            failures.append(f"{name} exists but is not listed in _quarto.yml")

    open_items = []
    for qmd in sorted(ROOT.glob("*.qmd")):
        text = qmd.read_text()
        for who, what in OPEN_ITEM.findall(text):
            open_items.append(f"{qmd.name}: {who}: {' '.join(what.split())[:90]}")
        stripped = OPEN_ITEM.sub("", text)
        for i, line in enumerate(stripped.splitlines(), start=1):
            if MARKERS.search(line):
                failures.append(f"{qmd.name}:{i}: editing marker left in the text")

    tracked = [Path(p) for p in
               __import__("subprocess").run(
                   ["git", "ls-files"], cwd=ROOT, capture_output=True,
                   text=True, check=True).stdout.split()]
    for path in tracked:
        if path.suffix.lower() in DATA_SUFFIXES:
            failures.append(f"microdata must never be committed: {path}")

    print(f"structure: {len(listed)} chapters listed, {len(on_disk)} on disk, "
          f"{len(tracked)} files tracked")
    for item in open_items:
        print("  open question ", item)
    for f in failures:
        print("  FAIL", f)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
