"""Order of the two human authors, Dmitry Vaintrob and Kaarel Hänni, on the collection's papers.

The rule below was proposed by Kaarel Hänni and fixed, with every convention spelled out, on
20 October 2026, before any outcome was computed. It was committed to the repository before this
script was first run.

1. Fixed assignments, decided by the authors:
   - strong-prior-generalization: Kaarel Hänni first;
   - gamma-above-one and meanfield-all-width: Dmitry Vaintrob first.
2. Every other catalogued paper, and every Markdown research note, whose author list contains both
   names: add up the letter values of its title (a=1, b=2, ..., z=26, ignoring case; every other
   character, including digits, spaces, punctuation and non-Latin letters, is ignored).
   - even sum: alphabetical order by surname, Hänni then Vaintrob;
   - odd sum: Vaintrob then Hänni.
   The title is the paper's "title" field in catalog.json, or a note's first-level heading, as they
   stood when the rule was applied (the record lists them, so later retitles do not change the order).
3. All other authors keep their positions; only the two human names are ordered by this rule.

Usage:
  python3 verification/author_order.py            # compute the assignment from the current titles
  python3 verification/author_order.py --check    # recompute from the titles frozen in the record
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RECORD = ROOT / "verification" / "author-order-2026-10-20.json"
FIXED = {
    "strong-prior-generalization": "Hänni first",
    "gamma-above-one": "Vaintrob first",
    "meanfield-all-width": "Vaintrob first",
}
NOTES = ["works-in-progress/slt-likelihood/README.md", "works-in-progress/slt-finite-sample/README.md"]


def letter_sum(title):
    return sum(ord(ch) - ord("a") + 1 for ch in title.lower() if "a" <= ch <= "z")


def order(key, title):
    if key in FIXED:
        return FIXED[key], None
    s = letter_sum(title)
    return ("Hänni first" if s % 2 == 0 else "Vaintrob first"), s


def has_both(text):
    return "Vaintrob" in text and ("H\\\"anni" in text or "Hänni" in text)


def current_items():
    items = []
    for e in json.loads((ROOT / "catalog.json").read_text(encoding="utf-8")):
        src = (ROOT / e["path"] / e["source_entry"]).read_text(encoding="utf-8", errors="replace")
        start = src.find("\\author")
        block = src[start:start + 400] if start >= 0 else ""
        if block.startswith("\\author{Dmitry Vaintrob") or block.startswith("\\author{Kaarel"):
            items.append((e["slug"], e["title"]))
    for note in NOTES:
        lines = (ROOT / note).read_text(encoding="utf-8").splitlines()
        title = next(l[2:].strip() for l in lines if l.startswith("# "))
        if has_both("\n".join(lines[:6])):
            items.append((note, title))
    return items


def main():
    if "--check" in sys.argv:
        rec = json.loads(RECORD.read_text(encoding="utf-8"))
        bad = 0
        for row in rec["assignments"]:
            got, s = order(row["key"], row["title"])
            ok = got == row["order"] and s == row.get("letter_sum")
            bad += not ok
            print(f"{'ok ' if ok else 'BAD'} {row['key']}: {got} (sum {s})")
        print("all assignments reproduce" if not bad else f"{bad} mismatches")
        sys.exit(1 if bad else 0)
    rows = []
    for key, title in current_items():
        got, s = order(key, title)
        rows.append({"key": key, "title": title, "letter_sum": s, "order": got})
        print(f"{key}: {got}" + (f" (sum {s}, {'even' if s % 2 == 0 else 'odd'})" if s is not None else " (fixed)"))
    if "--write" in sys.argv:
        RECORD.write_text(json.dumps({"rule": __doc__.split("Usage:")[0].strip(), "assignments": rows},
                                     indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        print("wrote", RECORD.relative_to(ROOT))


if __name__ == "__main__":
    main()
