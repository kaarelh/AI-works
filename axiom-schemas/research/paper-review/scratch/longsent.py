#!/usr/bin/env python3
"""Find long sentences (by word count, math stripped to a token) in main-text sections."""
import re, sys
base = "/home/user/AI-works/axiom-schemas/paper/sections/"
LIM = int(sys.argv[1]) if len(sys.argv) > 1 else 60
for f in ["setting", "single", "universal", "zfc", "many", "experiments"]:
    lines = open(base + f + ".tex").read().split("\n")
    text = []
    for i, l in enumerate(lines, 1):
        if l.lstrip().startswith("%"):
            continue
        text.append((i, l))
    # join paragraphs
    buf, start = [], None
    paras = []
    for i, l in text:
        if l.strip() == "" or l.strip().startswith("\\begin") or l.strip().startswith("\\end") or l.strip().startswith("\\item") or l.strip().startswith("\\subsection"):
            if buf:
                paras.append((start, " ".join(buf)))
            buf, start = [], None
            if l.strip().startswith("\\item"):
                buf, start = [l], i
            continue
        if start is None:
            start = i
        buf.append(l)
    if buf:
        paras.append((start, " ".join(buf)))
    for start, p in paras:
        q = re.sub(r"\$[^$]*\$", "MATH", p)
        q = re.sub(r"\\\[.*?\\\]", "MATH", q)
        q = re.sub(r"\\(src|cref|Cref|citep|citet|label)\{[^}]*\}", "", q)
        # split on sentence end: '. ' followed by capital or backslash
        sents = re.split(r"(?<=[.?!])\s+(?=[A-Z\\(])", q)
        for s in sents:
            n = len(s.split())
            if n >= LIM:
                print(f"{f}.tex:~{start} [{n} words] {s[:160]}...")
