"""Extract pointers to numbered statements of proofs/*.md from note.md and check
that each number exists in the resolved proof file as a bold statement title
(**Theorem 2.1 ...**), a heading (### 2.1 ...), or, failing that, anywhere as
"Theorem 2.1" text. Also extracts every 'Section x.y' and checks it against the
note's own headings.  Run from the project folder:
    python3 verification/code/referee-consistency_pointers.py
"""
import re, sys, os

NOTE = "note.md"
lines = open(NOTE, encoding="utf8").read().split("\n")

KINDS = r"(?:Theorems?|Propositions?|Lemmas?|Examples?|Corollar(?:y|ies)|Remarks?|Definitions?|Observations?)"
NUM = r"\d+(?:\.\d+)+[a-z]?"
NUMLIST = rf"{NUM}(?:\([a-z]\))?(?:(?:,\s*|\s+and\s+|,\s+and\s+){KINDS}?\s*{NUM}(?:\([a-z]\))?)*"
POINTER = re.compile(rf"({KINDS})\s+({NUMLIST})")

# default proof file per note section (set by the note's own sentences
# 'Numbers refer to ...', '"There" means ...', 'Statements cited by number ...',
# or, where no such sentence exists, the file named by the nearest explicit pointer)
DEFAULT = {
    "0": None, "1": "assumptions", "2": None,
    "3": "rehearsal-core", "3.2": "hellinger-runs",
    "4": "lower-bounds", "5.1": "one-mind", "5.2": "hellinger-runs",
    "6": "shift-abstain", "7": "shift-abstain",
    "8": "property-batch", "8.4": "property-online", "8.5": "property-online",
    "9": "assumptions", "10": "assumptions", "11": None, "12": None, "13": None,
}
# what the note's text itself tells the reader (to report ambiguity)
DECLARED = {"1": "assumptions", "3": "rehearsal-core", "4": "lower-bounds",
            "6": "shift-abstain", "8.2": "property-batch", "8.3": "property-batch",
            "8.4": "property-batch", "8.5": "property-batch", "8.6": "property-batch",
            "8.7": "property-batch", "9": "assumptions", "10": "assumptions"}

def stmt_index(key):
    txt = open(f"proofs/{key}.md", encoding="utf8").read()
    bold = set(); head = set(); loose = set()
    for m in re.finditer(rf"\*\*\s*({KINDS})\s+({NUM})", txt):
        bold.add(m.group(2))
    for m in re.finditer(rf"^#+\s+(?:{KINDS}\s+)?({NUM}|\d+)\b", txt, re.M):
        head.add(m.group(1))
    for m in re.finditer(rf"({KINDS})\s+({NUM})", txt):
        loose.add(m.group(2))
    return bold, head, loose

IDX = {k: stmt_index(k) for k in ["assumptions","hellinger-runs","lower-bounds","one-mind",
        "property-batch","property-online","rehearsal-core","shift-abstain"]}

LIT = re.compile(r"(19|20)\d\d[a-z]?\b[^.;()]*$|Paper \d[^.;]*$|\b(their|his|of that note|Zhang|Li and Zhang|Foster|Ross|Bousquet|Hutter|Juditsky|Hanneke|Bshouty|Perchet|Gupta|Vovk|Lee et al|Goldwasser|Cohen|Christiano|Catoni|Yang)\b[^.;]*$")

sec = "0"; sub = "0"
heads = {}
for i, l in enumerate(lines):
    m = re.match(r"^(#+)\s+(\d+(?:\.\d+)?)\.?\s+(.*)", l)
    if m: heads[m.group(2)] = m.group(3)

out = []
def key_for(sec, sub):
    return DEFAULT.get(sub, DEFAULT.get(sec))

problems = 0
for i, l in enumerate(lines, 1):
    m = re.match(r"^(#+)\s+(\d+)(?:\.(\d+))?", l)
    if m:
        sec = m.group(2); sub = sec + ("." + m.group(3) if m.group(3) else "")
        continue
    if l.startswith("## References"): sec = sub = "refs"
    for pm in POINTER.finditer(l):
        start = pm.start()
        before = l[max(0, start-120):start]
        # sentence prefix
        sent_start = max(l.rfind(". ", 0, start), l.rfind("; ", 0, start), l.rfind("(", 0, start)-1)
        prefix = l[sent_start+1:start] if sent_start >= 0 else l[:start]
        explicit = None
        em = list(re.finditer(r"`proofs/([a-z\-]+)\.md`", l[:start]))
        if em and start - em[-1].end() < 60:
            explicit = em[-1].group(1)
        after = l[pm.end():pm.end()+12]
        if (" there" in after[:7]) and sec == "4":
            explicit = "lower-bounds"   # Section 4: '"There" means proofs/lower-bounds.md'
        elif " there" in after[:7] and explicit is None:
            em2 = list(re.finditer(r"`proofs/([a-z\-]+)\.md`", l[:start]))
            if em2: explicit = em2[-1].group(1)
        if explicit is None and LIT.search(before[-70:]):
            kind = "LIT"
        else:
            kind = "PROOF"
        nums = re.findall(NUM, pm.group(2))
        if kind == "LIT":
            out.append(f"{i:4d} [{sub:>4}] LIT     {pm.group(0)!r}  ctx: ...{before[-50:]!r}")
            continue
        key = explicit or key_for(sec, sub)
        res = []
        for n in nums:
            if key is None:
                res.append(f"{n}:NOFILE"); problems += 1; continue
            bold, head, loose = IDX[key]
            if n in bold: res.append(f"{n}:ok")
            elif n in loose: res.append(f"{n}:text-only")
            else: res.append(f"{n}:MISSING"); problems += 1
        decl = "explicit" if explicit else f"default({DECLARED.get(sub, DECLARED.get(sec, 'undeclared'))})"
        out.append(f"{i:4d} [{sub:>4}] {key or '-':16s} {pm.group(0)!r}  -> {', '.join(res)}  [{decl}]")

out.append("")
out.append("== 'Section x.y' references inside the note ==")
for i, l in enumerate(lines, 1):
    for sm in re.finditer(r"Sections?\s+(\d+(?:\.\d+)?)(?:(?:,| and| to)\s+(\d+(?:\.\d+)?))*", l):
        ctx = l[max(0, sm.start()-40):sm.end()+10]
        if "proof file" in ctx or ".md" in l[max(0, sm.start()-40):sm.start()] or "Section 8 of the proof" in ctx:
            out.append(f"{i:4d} PROOFFILE {sm.group(0)!r} ctx {ctx!r}"); continue
        nums = re.findall(r"\d+(?:\.\d+)?", sm.group(0))
        flags = [f"{n}:{'ok' if n in heads else 'NO-SUCH-SECTION'}" for n in nums]
        out.append(f"{i:4d} {sm.group(0)!r} -> {' '.join(flags)}")
print("\n".join(out))
print(f"\nunresolved or missing numbers: {problems}")
