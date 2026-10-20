"""Apply the replacement blocks R1-R8 and R10 of ThmA-proof.md (Section 9.2) to a copy of the
paper source, write texbuild/standard-nngp-parity.tex, and leave compilation to the caller.
The repository file is only read.  Every 'old' string must occur exactly once."""
import re
import sys

SRC = "/home/user/AI-works/neural-network-generalization/side-results/standard-nngp-parity/source/standard-nngp-parity.tex"
MD = "ThmA-proof.md"
OUT = "texbuild/standard-nngp-parity.tex"

md = open(MD).read()
sec = md[md.index("### 9.2"):md.index("## 10.")]
chunks = re.split(r"(?=\*\*\(R\d+\))", sec)
blocks = {}
for ch in chunks:
    m = re.match(r"\*\*\((R\d+)\)", ch)
    if not m:
        continue
    b = re.search(r"```latex\n(.*?)\n```", ch, re.S)
    if b:
        blocks[m.group(1)] = b.group(1)
print("blocks found:", sorted(blocks, key=lambda k: int(k[1:])))

tex = open(SRC).read()


def once(s, old):
    k = s.count(old)
    if k != 1:
        sys.exit(f"old string occurs {k} times: {old[:80]!r}")


def replace(s, old, new):
    once(s, old)
    return s.replace(old, new)


def span(s, start, end):
    i = s.index(start)
    j = s.index(end, i) + len(end)
    once(s, start)
    return s[i:j]


tex = replace(tex, "We explain why\nan upper bound on that cost matching our lower bound would complete an\nexponential proof.",
              blocks["R6"])
tex = replace(tex, "We\nalso identify a matching upper bound on that cost which would complete an\n"
                   "$\\exp(\\Omega(d))$ proof (Section~\\ref{sec:obstruction}).", blocks["R7"])
tex = replace(tex, "\\cite[eq.~(45)]{subcritical}, where $\\E^*$ is the posterior expectation\n"
                   "and $b_r$ bounds the sampled Gram matrix of the tail kernel.", blocks["R10"])
tex = replace(tex, "We then explain\nwhat estimate would let the rest of the argument go through.", blocks["R5"])
anchor = "Lemma~\\ref{lem:cost} and $E_b\\le e^{C\\sqrt d}$.\n\\end{proof}\n"
tex = replace(tex, anchor, anchor + "\n" + blocks["R1"] + "\n")
old2 = span(tex, "\\paragraph{What this shows and does not show.}",
            "The only upper bound we have is the bump bound $e^{C\\sqrt d}$.")
tex = replace(tex, old2, blocks["R2"])
tex = replace(tex, "no bound here provides that.", blocks["R3"])
old4 = span(tex, "\\paragraph{Heuristic picture} (heuristic; not used above).", "small to test it.")
tex = replace(tex, old4, blocks["R4"])
tex = replace(tex, "A matching upper bound on that cost would give $\\exp(\\Omega(d))$ & Extension suggested by the proof "
                   "(Section~\\ref{sec:obstruction})\\\\", blocks["R8"])
open(OUT, "w").write(tex)
print("wrote", OUT)
