"""LaTeX tables for the paper from experiments/results/*.json."""

import json
import math
import os

HERE = os.path.dirname(__file__)
RES = os.path.join(HERE, "results")
OUT = os.path.join(HERE, "..", "paper", "tables")
os.makedirs(OUT, exist_ok=True)


def sci(x):
    if x == 0:
        return "$0$"
    if x == math.inf:
        return "$\\infty$"
    e = int(math.floor(math.log10(abs(x))))
    m = x / 10**e
    return f"${m:.2f}\\cdot10^{{{e}}}$" if e not in (0, 1, -1) else f"${x:.3g}$"


def coverage():
    rows = json.load(open(os.path.join(RES, "coverage.json")))
    lines = ["\\begin{tabular}{lrrr}", "\\toprule", "procedure & trials & misses & miss rate\\\\", "\\midrule"]
    for r in rows:
        lines.append(f"{r['procedure']} & {r['trials']} & {r['misses']} & {r['miss_rate']:.3f}\\\\")
    lines += ["\\bottomrule", "\\end{tabular}"]
    open(os.path.join(OUT, "coverage.tex"), "w").write("\n".join(lines) + "\n")


def speedup():
    rows = json.load(open(os.path.join(RES, "speedup.json")))
    lines = ["\\begin{tabular}{llrrrrr}", "\\toprule",
             "family & param & $p$ & interval ratio & cost & Monte Carlo & speed-up\\\\", "\\midrule"]
    for r in rows:
        sp = r["mc_cost"] / max(r["cost"], 1)
        lines.append(f"{r['family']} & {r['param']} & {sci(r['p'])} & {r['ratio']:.3f} & {sci(r['cost'])} & "
                     f"{sci(r['mc_cost'])} & {sci(sp)}\\\\")
    lines += ["\\bottomrule", "\\end{tabular}"]
    open(os.path.join(OUT, "speedup.tex"), "w").write("\n".join(lines) + "\n")


def arguments():
    path = os.path.join(RES, "arguments.json")
    if not os.path.exists(path):
        return
    rows = json.load(open(path))
    lines = ["\\begin{tabular}{lrrrrrrr}", "\\toprule",
             "family & $k$ & $|C|$ & $p$ & Part 1 ratio & proof steps & check (s) & Part 2 ratio\\\\",
             "\\midrule"]
    for r in rows:
        p1 = r["part1_hi"] / r["part1_lo"] if r["part1_lo"] > 0 else math.inf
        p2 = r["part2_hi"] / r["part2_lo"] if r["part2_lo"] > 0 else math.inf
        fam = "linear hash" if r["family"] == "linhash" else f"SPN, {r['rounds']} rounds"
        lines.append(f"{fam} & {r['k']} & {r['size']} & {sci(r['p'])} & "
                     f"{'$\\infty$' if p1 == math.inf else f'{p1:.3g}'} & {r['proof_steps']} & "
                     f"{r['verify_seconds']:.1f} & {p2:.3f}\\\\")
    lines += ["\\bottomrule", "\\end{tabular}"]
    open(os.path.join(OUT, "arguments.tex"), "w").write("\n".join(lines) + "\n")


if __name__ == "__main__":
    coverage()
    speedup()
    arguments()
