"""Citation check.

Every citation key used in the book must exist in references.bib. Entries in the
bibliography that nothing cites are reported but do not fail: a reference list
may deliberately carry further reading.
"""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
CROSSREF = ("sec-", "fig-", "tbl-", "eq-", "lst-")
KEY = re.compile(r"(?<![A-Za-z0-9._#@/-])@([A-Za-z][A-Za-z0-9_:.+-]*[A-Za-z0-9])")
ENTRY = re.compile(r"^@\w+\s*\{\s*([^,\s]+)\s*,", re.M)
CODE_BLOCK = re.compile(r"^```.*?^```", re.M | re.S)


def main():
    bib = (ROOT / "references.bib").read_text()
    defined = set(ENTRY.findall(bib))
    if not defined:
        print("  FAIL could not parse references.bib")
        return 1

    used = {}
    for qmd in sorted(ROOT.glob("*.qmd")):
        text = CODE_BLOCK.sub("", qmd.read_text())   # ignore R code (S4 slots, etc.)
        for key in KEY.findall(text):
            if key.startswith(CROSSREF):
                continue
            used.setdefault(key, set()).add(qmd.name)

    failures = [f"{', '.join(sorted(where))}: @{key} is cited but not in references.bib"
                for key, where in sorted(used.items()) if key not in defined]
    unused = sorted(defined - set(used))

    print(f"citations: {len(used)} keys cited, {len(defined)} entries in references.bib")
    for f in failures:
        print("  FAIL", f)
    if unused:
        print(f"  note {len(unused)} uncited entries: {', '.join(unused[:8])}"
              + (" ..." if len(unused) > 8 else ""))
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
