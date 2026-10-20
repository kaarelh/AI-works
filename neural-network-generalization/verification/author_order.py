"""Order of the two human authors, Dmitry Vaintrob and Kaarel Hänni, on the collection's papers.

The rule below was fixed, with every convention spelled out, on 20 October 2026, before any outcome
was computed. It was committed to the repository before this script was first run.

1. Fixed assignments, decided by the authors:
   - strong-prior-generalization: Kaarel Hänni first;
   - gamma-above-one and meanfield-all-width: Dmitry Vaintrob first.
2. Every other catalogued paper, and every Markdown research note, whose author list contains both
   names is randomized, with an exact split: one order goes to 18 of these items and the other to
   17, and which order gets 18 is itself random.
   - Rank the items by the SHA-256 digest of the UTF-8 encoding of the title, read as a 256-bit
     big-endian integer, smallest first.
   - Sort the titles in code-point order, join them with single newlines (no trailing newline),
     and take the SHA-256 digest of the UTF-8 encoding. If its last bit is 0, set m = ceil(N/2);
     if 1, m = floor(N/2). Here N = 35, so m is 18 or 17.
   - The first m items in the ranking get Kaarel Hänni first; the remaining N - m get Dmitry
     Vaintrob first.
   The title is the paper's "title" field in catalog.json, or a note's first-level heading, as they
   stood when the rule was applied (the record lists them, so later retitles do not change the order).
3. All other authors keep their positions; only the two human names are ordered by this rule.

A first rule, the parity of each title's letter sum (commit 50f6df57), gave 21 papers to one order
and 14 to the other. The authors asked for an exact split with the larger side randomized, so it
was replaced by this rule before it was applied.

Usage:
  python3 verification/author_order.py            # compute the assignment from the current titles
  python3 verification/author_order.py --write    # ... and write the record
  python3 verification/author_order.py --check    # recompute from the titles frozen in the record
"""
import hashlib
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


def sha(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def assign(items):
    """items: list of (key, title). Returns rows in input order, plus the split bit and m."""
    free = [(k, t) for k, t in items if k not in FIXED]
    ranked = sorted(free, key=lambda kt: int(sha(kt[1]), 16))
    split_digest = sha("\n".join(sorted(t for _, t in free)))
    bit = int(split_digest, 16) & 1
    n = len(free)
    m = (n + 1) // 2 if bit == 0 else n // 2
    rank = {k: i + 1 for i, (k, _) in enumerate(ranked)}
    rows = []
    for k, t in items:
        if k in FIXED:
            rows.append({"key": k, "title": t, "sha256": None, "rank": None, "order": FIXED[k]})
        else:
            rows.append({"key": k, "title": t, "sha256": sha(t), "rank": rank[k],
                         "order": "Hänni first" if rank[k] <= m else "Vaintrob first"})
    return rows, {"randomized_items": n, "split_sha256": split_digest, "split_bit": bit,
                  "hanni_first_count": m, "vaintrob_first_count": n - m}


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
        rows, split = assign([(r["key"], r["title"]) for r in rec["assignments"]])
        bad = sum(a != b for a, b in zip(rows, rec["assignments"])) + (split != rec["split"])
        for r in rows:
            print(f"{r['key']}: {r['order']}" + (f" (rank {r['rank']})" if r["rank"] else " (fixed)"))
        print(split)
        print("all assignments reproduce" if not bad else f"{bad} mismatches")
        sys.exit(1 if bad else 0)
    rows, split = assign(current_items())
    for r in rows:
        print(f"{r['key']}: {r['order']}" + (f" (rank {r['rank']})" if r["rank"] else " (fixed)"))
    print(split)
    if "--write" in sys.argv:
        RECORD.write_text(json.dumps({"rule": __doc__.split("Usage:")[0].strip(), "split": split,
                                      "assignments": rows}, indent=2, ensure_ascii=False) + "\n",
                          encoding="utf-8")
        print("wrote", RECORD.relative_to(ROOT))


if __name__ == "__main__":
    main()
