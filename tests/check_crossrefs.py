"""Cross-reference check.

Every @sec-, @fig-, @tbl- and @eq- reference used in the book must have a label
that defines it, and every label should be referred to at least once (an unused
figure label usually means a figure nobody points at).
"""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
PREFIXES = ("sec-", "fig-", "tbl-", "eq-", "lst-")
USE = re.compile(r"(?<![A-Za-z0-9._#-])@((?:" + "|".join(PREFIXES) + r")[A-Za-z0-9_-]+)")
BRACE = re.compile(r"\{#((?:" + "|".join(PREFIXES) + r")[A-Za-z0-9_-]+)")
CHUNK = re.compile(r"^#\|\s*label:\s*((?:" + "|".join(PREFIXES) + r")[A-Za-z0-9_-]+)", re.M)


def main():
    defined, used = {}, {}
    for qmd in sorted(ROOT.glob("*.qmd")):
        text = qmd.read_text()
        for label in BRACE.findall(text) + CHUNK.findall(text):
            defined.setdefault(label, qmd.name)
        for label in USE.findall(text):
            used.setdefault(label, qmd.name)

    failures = [f"{where}: @{label} is referenced but never defined"
                for label, where in sorted(used.items()) if label not in defined]
    orphans = [f"{where}: label {label} is defined but never referenced"
               for label, where in sorted(defined.items())
               if label not in used and not label.startswith("sec-")]

    print(f"cross-references: {len(defined)} labels defined, {len(used)} referenced")
    for f in failures:
        print("  FAIL", f)
    for o in orphans:
        print("  note", o)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
