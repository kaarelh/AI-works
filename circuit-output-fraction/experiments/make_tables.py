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


def ctx():
    path = os.path.join(RES, "ctx.json")
    if not os.path.exists(path):
        return
    rows = json.load(open(path))
    lines = ["\\begin{tabular}{rrrrrrrrr}", "\\toprule",
             "$n$ & $t$ & $w$ & cw & $|C|$ & DNNF size & interval for $p$ & samples & time (s)\\\\", "\\midrule"]
    for r in rows:
        iv = f"[{sci(r['lo'])}, {sci(r['hi'])}]"
        if r["exact_p"] is not None:
            iv += f" ($p={sci(r['exact_p'])}$)"
        lines.append(f"{r['n']} & {r['t']} & {r['w']} & {r['cw']} & {r['size']} & {r['dnnf_size']} & {iv} & "
                     f"{r['samples']} & {r['compile_seconds'] + r['estimate_seconds']:.1f}\\\\")
    lines += ["\\bottomrule", "\\end{tabular}"]
    open(os.path.join(OUT, "ctx.tex"), "w").write("\n".join(lines) + "\n")


def janson():
    path = os.path.join(RES, "janson.json")
    if not os.path.exists(path):
        return
    d = json.load(open(path))
    lines = ["\\begin{tabular}{rrrrrr}", "\\toprule",
             "$n$ & clauses & width & certified interval & ratio & time (s)\\\\", "\\midrule"]
    for r in d["rows"]:
        lines.append(f"{r['n']} & {r['m']} & {r['k']} & [{sci(r['lo'])}, {sci(r['hi'])}] & {r['ratio']:.3f} & "
                     f"{r['seconds']:.1f}\\\\")
    lines += ["\\bottomrule", "\\end{tabular}"]
    open(os.path.join(OUT, "janson.tex"), "w").write("\n".join(lines) + "\n")


def cftp():
    path = os.path.join(RES, "cftp.json")
    if not os.path.exists(path):
        return
    rows = json.load(open(path))
    lines = ["\\begin{tabular}{rrrlll}", "\\toprule",
             "$L$ & $n$ & $p$ (exact) & Harris--Janson window & certified telescoping & CFTP runs\\\\", "\\midrule"]
    for r in rows:
        lines.append(f"{r['L']} & {r['n']} & {sci(r['p'])} & [{sci(r['janson_lo'])}, {sci(r['janson_hi'])}] & "
                     f"[{sci(r['lo'])}, {sci(r['hi'])}] & {sci(r['cftp_runs'])}\\\\")
    lines += ["\\bottomrule", "\\end{tabular}"]
    open(os.path.join(OUT, "cftp.tex"), "w").write("\n".join(lines) + "\n")


if __name__ == "__main__":
    for f in (coverage, speedup, arguments, ctx, janson, cftp):
        f()
