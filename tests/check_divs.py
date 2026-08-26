"""Div fence check.

Callouts and figure blocks are written as Pandoc divs (`::: {.callout-tip}` …
`:::`). A missing closing fence does not stop the build: Pandoc closes the div
implicitly at the end of the document and warns, with the result that
everything after the opening is silently wrapped inside a callout box. This
check makes that a failure instead of a warning.
"""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
OPEN = re.compile(r"^:::+\s*\{")     # ::: {.callout-note} — opens a div
CLOSE = re.compile(r"^:::+\s*$")     # ::: — closes one
FENCE = re.compile(r"^(```+|~~~+)")  # code fences: divs inside them are text


def main():
    failures = []
    for qmd in sorted(ROOT.glob("*.qmd")):
        depth, opened_at, in_code = 0, [], False
        for i, line in enumerate(qmd.read_text().splitlines(), start=1):
            if FENCE.match(line):
                in_code = not in_code
                continue
            if in_code:
                continue
            if OPEN.match(line):
                depth += 1
                opened_at.append(i)
            elif CLOSE.match(line):
                depth -= 1
                if depth < 0:
                    failures.append(f"{qmd.name}:{i}: closing ::: with nothing open")
                    depth = 0
                elif opened_at:
                    opened_at.pop()
        for line_no in opened_at:
            failures.append(f"{qmd.name}:{line_no}: div opened here is never closed; "
                            f"everything below it renders inside the callout")

    print(f"divs: fences balanced in {len(list(ROOT.glob('*.qmd')))} files")
    for f in failures:
        print("  FAIL", f)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
