#!/usr/bin/env python3
"""Synthesis check (2026-10-16, deterministic): every bibliography key cited in the related-work coverage of
research/notes-final.md (section 5.7, between the markers below) is a key of research/refs.bib.
Usage: python3 -I check_keys.py <research-dir>"""
import re, sys
from pathlib import Path
root = Path(sys.argv[1] if len(sys.argv) > 1 else ".")
notes = (root / "notes-final.md").read_text(encoding="utf-8")
start = notes.index("**Related-work section (about 2 pages), with keys:**")
end = notes.index("**References the records use but that are NOT in `refs.bib`**")
cited = re.findall(r"`([a-zA-Z][a-zA-Z0-9]*\d{4}[a-zA-Z0-9]*)`", notes[start:end])
bib = (root / "refs.bib").read_text(encoding="utf-8")
keys = set(re.findall(r"^@\w+\{([^,\s]+),", bib, flags=re.M))
missing = sorted(set(cited) - keys)
print(f"keys cited in section 5.7: {len(cited)} ({len(set(cited))} distinct)")
print(f"keys in refs.bib: {len(keys)}")
print(f"cited but missing from refs.bib: {len(missing)}")
for k in missing:
    print("  MISSING", k)
uncited = sorted(keys - set(cited))
print(f"refs.bib keys not named in section 5.7 (kept for the paper's other sections or as background): {len(uncited)}")
print("  " + ", ".join(uncited))
