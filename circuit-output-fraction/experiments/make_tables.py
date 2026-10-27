"""LaTeX tables for the paper from experiments/results/*.json."""

import json
import math
import os
from decimal import ROUND_CEILING, ROUND_FLOOR, ROUND_HALF_UP, Decimal

HERE = os.path.dirname(__file__)
RES = os.path.join(HERE, "results")
OUT = os.path.join(HERE, "..", "paper", "tables")
os.makedirs(OUT, exist_ok=True)


_MODES = {None: ROUND_HALF_UP, "down": ROUND_FLOOR, "up": ROUND_CEILING}


def num(x, rnd=None):
    """x to three significant digits, as LaTeX math without the dollars.
    rnd=None rounds to nearest; certified-interval endpoints are rounded
    outwards, lower ends with rnd="down" and upper ends with rnd="up", so a
    printed interval always contains the computed one. Exact (decimal)."""
    if x == 0:
        return "0"
    if x == math.inf:
        return "\\infty"
    d = Decimal(x)  # the exact binary value
    q = d.quantize(Decimal(1).scaleb(d.adjusted() - 2), rounding=_MODES[rnd])
    e = q.adjusted()  # rounding may carry into the next power of ten
    if e in (-1, 0, 1):
        t = format(q, "f")
        return t.rstrip("0").rstrip(".") if "." in t else t
    m = q.scaleb(-e).quantize(Decimal("0.01"))
    return f"{m}\\cdot10^{{{e}}}"


def sci(x, rnd=None):
    return f"${num(x, rnd)}$"


def interval(lo, hi):
    """A certified interval, endpoints rounded outwards."""
    return f"[{sci(lo, 'down')}, {sci(hi, 'up')}]"


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
        fam = "linear hash" if r["family"] == "linhash" else f"SPN, {r['rounds']} rounds"
        if "part1_lo" in r:
            p1 = r["part1_hi"] / r["part1_lo"] if r["part1_lo"] > 0 else math.inf
            p1s = "$\\infty$" if p1 == math.inf else f"{p1:.3g}"
        else:  # the prover-free procedures hit their time limit
            p1s = f"none in {r['part1_timeout_seconds']} s"
        head = f"{fam} & {r['k']} & {r.get('size', '')} & {sci(r['p']) if 'p' in r else ''} & {p1s}"
        if "proof_steps" not in r:  # the prover hit the per-instance time limit
            lines.append(f"{head} & \\multicolumn{{3}}{{l}}{{no proof within {r['timeout_seconds']} s}}\\\\")
            continue
        p2 = r["part2_hi"] / r["part2_lo"] if r["part2_lo"] > 0 else math.inf
        lines.append(f"{head} & {r['proof_steps']} & {r['verify_seconds']:.1f} & {p2:.3f}\\\\")
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
        iv = interval(r["lo"], r["hi"])
        if r["exact_p"] is not None:
            iv += f" ($p={num(r['exact_p'])}$)"
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
        lines.append(f"{r['n']} & {r['m']} & {r['k']} & {interval(r['lo'], r['hi'])} & {r['ratio']:.3f} & "
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
        lines.append(f"{r['L']} & {r['n']} & {sci(r['p'])} & {interval(r['janson_lo'], r['janson_hi'])} & "
                     f"{interval(r['lo'], r['hi'])} & {sci(r['cftp_runs'])}\\\\")
    lines += ["\\bottomrule", "\\end{tabular}"]
    open(os.path.join(OUT, "cftp.tex"), "w").write("\n".join(lines) + "\n")


if __name__ == "__main__":
    for f in (coverage, speedup, arguments, ctx, janson, cftp):
        f()
