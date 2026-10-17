#!/usr/bin/env python3
"""Merge the verified bibliographies of the scouts and threads into research/refs.bib.

Synthesis editor's script, 2026-10-16.  Deterministic (no randomness, so no seed is needed).

Sources, in priority order (the first source that has a key supplies the entry; later copies are compared
field by field and every difference is reported):
  1. tracks/philosophy/refs.bib  (every entry re-verified by WebSearch on 2026-10-16)
  2. tracks/laws/refs.bib        (searched in the thread, or copied from philosophy)
  3. scouts/literature/refs.bib  (scout L, searched 2026-10-15)
  4. scouts/philosophy/refs.bib  (scout P, searched 2026-10-15)
  5. synthesis/thread_refs.bib   (entries written at synthesis from the reference tables of the
                                  fundamentals, sfi, logic, terms and shape records; only those whose
                                  bibliographic data those records state were confirmed)

Each output entry keeps the comment block that stood above it in its primary source (which records how it was
verified) and gets one provenance line naming every source that contains the key.  The script also reports
possible duplicates under different keys (same normalised title) and writes a summary to merge_bib.out.

Usage:  python3 -I merge_bib.py <research-dir>    (writes <research-dir>/refs.bib)
"""
import re
import sys
from pathlib import Path

SOURCES = [
    ("tracks/philosophy/refs.bib", "philosophy thread (re-verified 2026-10-16)"),
    ("tracks/laws/refs.bib", "laws thread"),
    ("scouts/literature/refs.bib", "scout L"),
    ("scouts/philosophy/refs.bib", "scout P"),
    ("synthesis/thread_refs.bib", "thread reference tables (synthesis)"),
]
COMPARE = ["author", "title", "journal", "booktitle", "year", "volume", "number", "pages", "doi", "publisher"]


def parse_entries(text):
    """Return a list of (comment_lines, entry_text, key, fields)."""
    out = []
    lines = text.split("\n")
    i = 0
    pending = []
    while i < len(lines):
        line = lines[i]
        m = re.match(r"\s*@(\w+)\s*\{\s*([^,\s]+)\s*,", line)
        if m:
            # collect the entry by brace matching
            buf = []
            depth = 0
            started = False
            while i < len(lines):
                buf.append(lines[i])
                for ch in lines[i]:
                    if ch == "{":
                        depth += 1
                        started = True
                    elif ch == "}":
                        depth -= 1
                i += 1
                if started and depth == 0:
                    break
            entry = "\n".join(buf)
            comments = [c for c in pending if not re.match(r"%\s*[-=]{5,}", c.strip())]
            out.append((comments, entry, m.group(2), parse_fields(entry), m.group(1).lower()))
            pending = []
            continue
        if line.strip().startswith("%"):
            pending.append(line)
        elif line.strip() == "":
            pending = []
        i += 1
    return out


def parse_fields(entry):
    body = entry[entry.index(",") + 1: entry.rindex("}")]
    fields = {}
    j = 0
    while j < len(body):
        m = re.compile(r"\s*([A-Za-z]+)\s*=\s*").match(body, j)
        if not m:
            j += 1
            continue
        name = m.group(1).lower()
        j = m.end()
        if j < len(body) and body[j] == "{":
            depth = 0
            k = j
            while k < len(body):
                if body[k] == "{":
                    depth += 1
                elif body[k] == "}":
                    depth -= 1
                    if depth == 0:
                        break
                k += 1
            val = body[j + 1:k]
            j = k + 1
        elif j < len(body) and body[j] == '"':
            k = body.index('"', j + 1)
            val = body[j + 1:k]
            j = k + 1
        else:
            m2 = re.compile(r"[^,\n]*").match(body, j)
            val = m2.group(0).strip()
            j = m2.end()
        fields[name] = val
    return fields


def norm(v):
    v = v.lower()
    v = re.sub(r"\\[a-z]+\s*", "", v)
    v = re.sub(r"[{}\\'\"`^~.,:;\s-]", "", v)
    return v


def main():
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".")
    log = []
    merged = {}  # key -> dict
    order = []
    per_source = {}
    for rel, label in SOURCES:
        text = (root / rel).read_text(encoding="utf-8")
        entries = parse_entries(text)
        per_source[rel] = len(entries)
        seen_here = set()
        for comments, entry, key, fields, etype in entries:
            if key in seen_here:
                log.append(f"DUPLICATE KEY within {rel}: {key} (later copy ignored)")
                continue
            seen_here.add(key)
            if key not in merged:
                merged[key] = dict(comments=comments, entry=entry, fields=fields, type=etype,
                                   primary=label, sources=[label])
                order.append(key)
            else:
                rec = merged[key]
                rec["sources"].append(label)
                for f in COMPARE:
                    a = rec["fields"].get(f)
                    b = fields.get(f)
                    if a is None and b is not None:
                        log.append(f"FIELD ONLY IN LATER SOURCE: {key}.{f} = {b!r} ({label}); primary ({rec['primary']}) omits it")
                    elif a is not None and b is not None and norm(a) != norm(b):
                        log.append(f"FIELD DIFFERS: {key}.{f}: primary ({rec['primary']}) {a!r} vs {label} {b!r}")
                if etype != rec["type"]:
                    log.append(f"TYPE DIFFERS: {key}: primary @{rec['type']} vs {label} @{etype}")
    # possible duplicates under different keys
    by_title = {}
    for key in order:
        t = norm(merged[key]["fields"].get("title", ""))[:60]
        if t:
            by_title.setdefault(t, []).append(key)
    for t, keys in by_title.items():
        if len(keys) > 1:
            log.append(f"SAME TITLE, DIFFERENT KEYS: {', '.join(keys)}")
    # write
    header = [
        "% refs.bib -- merged verified bibliography for the paper on Solomonoff axiom induction (working name).",
        "% Written by research/synthesis/merge_bib.py on 2026-10-16 (synthesis editor). Do not edit by hand without",
        "% recording the change in research/notes-final.md, section 8 (Verification log).",
        "%",
        "% Sources, in priority order (the first source with a key supplies the entry; differences between copies are",
        "% listed in research/synthesis/merge_bib.out):",
    ] + [f"%   {i+1}. research/{rel}  [{label}]" for i, (rel, label) in enumerate(SOURCES)] + [
        "% Every literature entry was verified by WebSearch in this project by a scout, a thread or a referee, at the level",
        "% stated in the comment above it (bibliographic data; abstract; secondary; source); the six companion reports of",
        "% this repository (hanni2026notes, claude*) are internal and were read here.  The 'Provenance' line names every",
        "% source that contains the key.  Content levels matter: the paper must hedge a claim about a work's content to",
        "% the level recorded here.  References that the records cite but could not verify are NOT here; they are",
        "% listed in research/notes-final.md, section 5.7.",
        "",
    ]
    body = []
    for key in sorted(order, key=str.lower):
        rec = merged[key]
        body.append(f"% Provenance: {'; '.join(rec['sources'])}.")
        body.extend(rec["comments"])
        body.append(rec["entry"].strip())
        body.append("")
    (root / "refs.bib").write_text("\n".join(header + body), encoding="utf-8")
    summary = [f"entries per source: " + ", ".join(f"{rel}: {n}" for rel, n in per_source.items()),
               f"merged unique keys: {len(order)}",
               f"keys in more than one source: {sum(1 for k in order if len(merged[k]['sources']) > 1)}",
               f"report lines: {len(log)}", ""]
    (root / "synthesis" / "merge_bib.out").write_text("\n".join(summary + log) + "\n", encoding="utf-8")
    print("\n".join(summary))


if __name__ == "__main__":
    main()
