"""Assemble note.md from the section files in research/sections/.

Usage: python3 research/orchestration/assemble.py   (from the project folder)

Each section file was written by the editor of one part and ends with notes that are not text of
the note; this script cuts the text out, puts the blocks in the order of the outline, renumbers the
subsections of Section 8, and applies a list of exact replacements (the lead's harmonisation).
Every replacement must match exactly once, so that a changed section file is noticed.
"""
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
SEC = ROOT / "research" / "sections"


def read(name):
    return (SEC / name).read_text()


def cut(text, start, end=None, keep_start=True):
    """Text from the first occurrence of `start` up to (not including) the first later `end`."""
    i = text.index(start)
    j = text.index(end, i + len(start)) if end is not None else len(text)
    return text[i if keep_start else i + len(start):j].strip() + "\n"


def once(text, old, new):
    n = text.count(old)
    if n != 1:
        sys.exit(f"replacement matched {n} times, expected 1:\n{old[:200]}")
    return text.replace(old, new)


TITLE = """# Imitating a human inside a computation we can run in advance

A protocol, its theorems and its limits. Research note, November 2026.

*Status.* Every numbered statement says whether it is proved here, standard, or open. The proofs are in `proofs/`, one file for each part of the note. Each proof file was examined by a referee who went through it line by line and by a second who tried to break it; their reports and the reports on this text are in `verification/`. The last section of each proof file lists every finding and what was done about it, and names the statements that only one checker has seen.
"""

# ---- Sections 1 to 3 -------------------------------------------------------------------------
rc = read("rehearsal-core.md")
hr = read("hellinger-runs.md")
asm = read("assumptions.md")

sec1 = cut(rc, "## 1. The model", "## 2. The protocol")
sec2 = cut(rc, "## 2. The protocol", "## 3. What rehearsal guarantees")
sec3 = cut(rc, "## 3. What rehearsal guarantees")

caveats = cut(asm, "<!-- BLOCK A", "<!-- BLOCK B")
caveats = caveats.split("-->", 1)[1].strip() + "\n"
sec1 = once(sec1, "[PLACEHOLDER: caveats on A1 to A3, supplied by part `assumptions`.]", caveats.strip())

whole_runs = cut(hr, "### 3.2 Whole runs", "<!-- ================= BLOCK (ii)")
old_32 = cut(sec3, "### 3.2 Whole runs", "### 3.3 Coverage")
sec3 = once(sec3, old_32.strip(), whole_runs.strip())

# ---- Section 4 and the block for Section 6 ---------------------------------------------------
lb = read("lower-bounds.md")
sec4 = cut(lb, "## 4. What no protocol can do", "\n---\n")
block6 = cut(lb, "## For Section 6: lower bounds for inputs from outside", "\n---\n", keep_start=False)

# ---- Section 5 -------------------------------------------------------------------------------
om = read("one-mind.md")
sec51 = cut(om, "### 5.1 One program or a committee", "\n---\n")
sec52 = cut(hr, "### 5.2 Recorded runs of the human system", "<!-- ================= END OF THE TEXT")
sec5 = "## 5. One program or a committee\n\n" + sec51 + "\n" + sec52

# ---- Sections 6 and 7 ------------------------------------------------------------------------
sa = read("shift-abstain.md")
sec6 = cut(sa, "## 6. Inputs from outside", "## 7. Failing obviously")
sec6 = once(sec6, "[Here the block of part lower-bounds: Theorem N3 and what S2 needs.]", block6.strip())
sec7 = cut(sa, "## 7. Failing obviously")

# ---- Section 8 -------------------------------------------------------------------------------
pb = read("property-batch.md")
po = read("property-online.md")
sec8a = cut(pb, "## 8. The property idea", "### 8.5 The mixture need not give the per-property price")
sec8c = cut(pb, "### 8.5 The mixture need not give the per-property price", "## Editor's notes for the assembly")
sec8b = cut(po, "### 8.3 An imitator built from tests alone", "\n---\n")
sec8a = once(sec8a, "### 8.2a The batch estimator", "### 8.3 The batch estimator")
sec8b = once(sec8b, "### 8.3 An imitator built from tests alone", "### 8.4 An imitator built from tests alone")
sec8b = once(sec8b, "### 8.4 What this does not give", "### 8.5 What the imitator built from tests does not give")
sec8c = once(sec8c, "### 8.5 The mixture need not give the per-property price", "### 8.6 The mixture need not give the per-property price")
sec8c = once(sec8c, "### 8.6 What the human's answers can certify", "### 8.7 What the human's answers can certify")
sec8 = sec8a + "\n" + sec8b + "\n" + sec8c

# ---- Sections 9 and 10 -----------------------------------------------------------------------
sec9 = cut(asm, "## 9. ", "<!-- BLOCK C")
sec10 = cut(asm, "## 10. ", "<!-- END")

# ---- Sections 0, 11, 12, 13 ------------------------------------------------------------------
sec0 = read("intro.md")
sec11 = read("toy.md")
sec12 = read("related-work-final.md") if (SEC / "related-work-final.md").exists() else cut(read("related-work.md"), "## 12. Related work", "## References")
sec13 = read("open.md")
refs = read("references-short.md") if (SEC / "references-short.md").exists() else "## References\n\n(The list is being consolidated.)\n"

note = "\n".join([TITLE, sec0, sec1, sec2, sec3, sec4, sec5, sec6, sec7, sec8, sec9, sec10, sec11, sec12, sec13, refs])

# ---- The lead's harmonisation: exact replacements --------------------------------------------
patches_file = ROOT / "research" / "orchestration" / "patches.py"
if patches_file.exists():
    scope = {}
    exec(patches_file.read_text(), scope)
    for old, new in scope["PATCHES"]:
        note = once(note, old, new)

(ROOT / "note.md").write_text(note)
print("note.md written:", len(note.split()), "whitespace-separated tokens,", len(note), "characters")
