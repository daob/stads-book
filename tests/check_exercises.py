"""Exercise check.

The book's convention: every exercise callout is followed by a collapsible
answer callout with the same number, inline exercises are numbered n.1, n.2, ...
and end-of-chapter ones n.A, n.B, ... This check enforces the pairing, the
chapter prefix, and the collapse attribute that makes answers hidden by default.
"""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
CALLOUT = re.compile(r'^:::+\s*\{([^}]*)\}\s*$', re.M)
TITLE = re.compile(r'title="(Exercise|Answer)\s+([0-9]+)\.([A-Za-z0-9]+)[^"]*"')


def chapter_number(name):
    m = re.match(r"(\d+)-", name)
    return int(m.group(1)) if m else None


def main():
    failures, total = [], 0
    for qmd in sorted(ROOT.glob("[0-9]*.qmd")):
        chapter = chapter_number(qmd.name)
        text = qmd.read_text()
        exercises, answers = {}, {}
        for attrs in CALLOUT.findall(text):
            m = TITLE.search(attrs)
            if not m:
                continue
            kind, chap, num = m.group(1), int(m.group(2)), m.group(3)
            (exercises if kind == "Exercise" else answers)[num] = attrs
            if chap != chapter:
                failures.append(f"{qmd.name}: {kind} {chap}.{num} carries the wrong "
                                f"chapter number (file is chapter {chapter})")
            if kind == "Answer" and "collapse=\"true\"" not in attrs:
                failures.append(f"{qmd.name}: Answer {chap}.{num} is not collapsible")
        total += len(exercises)
        for num in exercises:
            if num not in answers:
                failures.append(f"{qmd.name}: Exercise {chapter}.{num} has no answer")
        for num in answers:
            if num not in exercises:
                failures.append(f"{qmd.name}: Answer {chapter}.{num} has no exercise")
        inline = sorted(n for n in exercises if n.isdigit())
        if inline != [str(i) for i in range(1, len(inline) + 1)]:
            failures.append(f"{qmd.name}: inline exercises are numbered "
                            f"{', '.join(inline)}, expected a run from 1")
        lettered = sorted(n for n in exercises if not n.isdigit())
        expected = [chr(ord("A") + i) for i in range(len(lettered))]
        if lettered != expected:
            failures.append(f"{qmd.name}: end-of-chapter exercises are lettered "
                            f"{', '.join(lettered)}, expected {', '.join(expected)}")

    print(f"exercises: {total} exercises, each checked for a matching answer")
    for f in failures:
        print("  FAIL", f)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
