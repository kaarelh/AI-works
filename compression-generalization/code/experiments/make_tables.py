"""Generate the paper's LaTeX tables from the results files (no hand-copied numbers).

Writes paper/tables/*.tex.  All bounds include the design charge of accounting.py.
"""
import collections
import json
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, ".."))
from accounting import boolean_bound, boolean_any_D, t1_bound, t2_bound, t3_bound  # noqa: E402
from cgb.bounds import occam_bound  # noqa: E402

ROOT = os.path.join(HERE, "..", "..")
RES = os.path.join(ROOT, "results")
TAB = os.path.join(ROOT, "paper", "tables")


def load(p):
    return [json.loads(l) for l in open(p)] if os.path.exists(p) else []


def tname(r):
    t = r["task"].replace("_", r"\_")
    return rf"\texttt{{{t}}}" + (rf", noise {r['noise']:g}" if r.get("noise") else "")


def fmt(x, d=3):
    if x >= 0.9995:
        return "1.0"
    return f"{x:.{d}f}"


def write(name, body):
    os.makedirs(TAB, exist_ok=True)
    open(os.path.join(TAB, name), "w").write(body)


def boolean(grid, ms_show):
    rows = load(os.path.join(RES, "boolean", f"grid_{grid}.jsonl"))
    if not rows:
        return
    g = collections.defaultdict(list)
    for r in rows:
        g[(tname(r), r["m"])].append(r)
    tasks = sorted({k[0] for k in g}, key=lambda s: ("noise" in s, s))
    anyD = "bits_any_D" in rows[0]
    cols = "l r r r r" + (" r r" if anyD else "")
    head = r"task & $m$ & test err.\ $f$ & bound on $f$ & bits of $g$" + (r" & any-$D$ bound & $|E|$" if anyD else "")
    lines = [r"\begin{table}[t]", r"\centering\small", rf"\begin{{tabular}}{{{cols}}}", r"\toprule", head + r" \\", r"\midrule"]
    for t in tasks:
        for m in ms_show:
            if (t, m) not in g:
                continue
            rr = g[(t, m)]
            te = np.mean([r["test_err_f"] for r in rr])
            bd = np.mean([boolean_bound(r) for r in rr])
            bits = np.mean([r["bits"] for r in rr]) + 4
            line = f"{t} & {m} & {fmt(te, 4)} & {fmt(bd, 4)} & {bits:.0f}"
            if anyD:
                line += f" & {fmt(np.mean([boolean_any_D(r) for r in rr]), 4)} & {np.mean([r['n_exceptions'] for r in rr]):.0f}"
            lines.append(line + r" \\")
        lines.append(r"\addlinespace[2pt]")
    lines[-1] = r"\bottomrule"
    P = rows[0]["params"]
    cap = (rf"Boolean tasks, $n={rows[0]['n']}$: test error of the trained network $f$ ({P:,} parameters) and the bound on it "
           r"(\cref{thm:reduction}), averaged over 3 seeds; `bits' is the description length of the compressed $g$ "
           r"(including the 4-bit design charge). ")
    if anyD:
        cap += (r"The any-$D$ bound (\cref{cor:anyD}) holds for every input distribution; it patches $g$ on the set $E$ "
                r"of inputs where $g\ne f$ (enumerated over all $2^{20}$ inputs). ")
    cap += r"The parameter-counting and VC bounds for $f$ are 1.0 in every row."
    lines += [r"\end{tabular}", rf"\caption{{{cap}}}\label{{tab:boolean{'' if grid == 'n50' else '_' + grid}}}", r"\end{table}"]
    write(f"boolean_{grid}.tex", "\n".join(lines) + "\n")


def t2():
    rows = load(os.path.join(RES, "mnist", "t2.jsonl")) + load(os.path.join(RES, "mnist", "t2_basis_id.jsonl"))
    if not rows:
        return
    g = collections.defaultdict(list)
    for r in rows:
        g[(r["data"], tuple(r["widths"]), r["seed"], r["epochs"], r["lr"], r["wd"], r["init_scale"],
           r.get("init", "random"), r.get("code_ref", "init"), r["basis"])].append(r)
    lines = [r"\begin{table}[t]", r"\centering\small", r"\begin{tabular}{l l l r r r r r r r}", r"\toprule",
             r"data & network & basis & test err.\ $f$ & $K$ & bound on $g$ & bits & bound on $f$ & bits & $\Pr[f\ne g]$ \\",
             r"\midrule"]
    for k in sorted(g):
        rr = g[k]
        K = len(rr)
        b1 = min(rr, key=t1_bound)
        b2 = min(rr, key=lambda r: t2_bound(r, K))
        net = "-".join(str(w) for w in k[1])
        lines.append(f"{k[0]} & {net} & {k[9]} & {rr[0]['test_err_f']:.4f} & {K} & {fmt(t1_bound(b1))} & {b1['bits'] + 4:.0f} & "
                     f"{fmt(t2_bound(b2, K))} & {b2['bits'] + 4:.0f} & {b2['dis_test_inputs']:.4f}" + r" \\")
    lines += [r"\bottomrule", r"\end{tabular}",
              r"\caption{Bounds with unlabeled inputs. `Bound on $g$': Occam bound (\cref{lem:occam}) for the best "
              r"compressed network among $K$ configurations. `Bound on $f$': \cref{thm:reduction}, with "
              r"$\Pr[f\ne g]$ estimated on the 10{,}000 test images without their labels, union-bounded over the $K$ "
              r"configurations. Parameter-counting and VC bounds for $f$ are 1.0 in every row.}\label{tab:t2}",
              r"\end{table}"]
    write("t2.tex", "\n".join(lines) + "\n")


def t3():
    rows = load(os.path.join(RES, "mnist", "t3.jsonl"))
    if rows:
        lines = [r"\begin{table}[t]", r"\centering\small", r"\begin{tabular}{l r l l r r r r r}", r"\toprule",
                 r"data & $H$ & training & code & test err.\ $f$ & bits & certified & bound on $f$ & 32-bit Occam \\",
                 r"\midrule"]
        def var(r):
            v = []
            if r.get("weight_noise", 0):
                v.append(f"noise {r['weight_noise']:g}")
            return ", ".join(v) or "standard"
        def code(r):
            v = [r["basis"].upper() if r["basis"] == "dct" else "pixel"]
            if r.get("code_ref", "init") == "zero":
                v.append("ref.\\ 0")
            if r.get("init", "random") == "dct":
                v.append("DCT init")
            return ", ".join(v)
        for r in sorted(rows, key=lambda r: (r["data"], r.get("weight_noise", 0), r["widths"][1], code(r))):
            P = r["params"]
            occ32 = occam_bound(int(round(r["train_err_f"] * 60000)), 60000, 32.0 * P + 64, 0.05)
            lines.append(f"{r['data']} & {r['widths'][1]} & {var(r)} & {code(r)} & {r['test_err_f']:.4f} & {r['bits'] + 4:.0f} & "
                         f"{r['cert_frac']:.3f} & {fmt(t3_bound(r))} & {fmt(occ32, 2)}" + r" \\")
        lines += [r"\bottomrule", r"\end{tabular}",
                  r"\caption{Bounds on the original one-hidden-layer network $f$ from the 60{,}000 training examples "
                  r"alone (\cref{thm:dither,lem:cert}): no validation set and no unlabeled data. `Certified': fraction "
                  r"of training points with $\pi_g=1$. `Noise $\sigma$': $f$ trained with Gaussian weight noise of "
                  r"$\sigma$ times each tensor's initial RMS. Chance level is 0.9.}\label{tab:t3}", r"\end{table}"]
        write("t3.tex", "\n".join(lines) + "\n")
    rows = load(os.path.join(RES, "boolean", "t3.jsonl"))
    if rows:
        lines = [r"\begin{table}[t]", r"\centering\small", r"\begin{tabular}{l r r r r r r r r}", r"\toprule",
                 r"task & $n$ & $m$ & $H$ & test err.\ $f$ & bits & training-data-only bound & bits & known-$D_X$ bound \\",
                 r"\midrule"]
        for r in sorted(rows, key=lambda r: (r["n"], r["task"], r["m"], r["width"], r["weight_noise"])):
            known = dict(r, bits=r["T2known_bits"])
            lines.append(f"{tname(r)}{', noise ' + format(r['weight_noise'], 'g') if r['weight_noise'] else ''} & {r['n']} & "
                         f"{r['m']} & {r['width']} & {r['test_err_f']:.4f} & {r['t3_bits'] + 4:.0f} & {fmt(t3_bound(r))} & "
                         f"{r['T2known_bits'] + 4:.0f} & {fmt(boolean_bound(dict(r['T2known'], m=r['m'])))}" + r" \\")
        lines += [r"\bottomrule", r"\end{tabular}",
                  r"\caption{Boolean tasks, one-hidden-layer networks: the training-data-only bound (\cref{thm:dither}), "
                  r"which holds whatever the input distribution, against the bound that uses the known uniform input "
                  r"distribution (\cref{thm:reduction}) on the same network.}\label{tab:boolean_t3}", r"\end{table}"]
        write("boolean_t3.tex", "\n".join(lines) + "\n")


def init():
    rows = load(os.path.join(RES, "init", "mnist_init.jsonl"))
    if rows:
        g = collections.defaultdict(list)
        for r in rows:
            g[(r.get("init", "random"), r["init_scale"], r.get("code_ref", "init"))].append(r)
        lines = [r"\begin{table}[t]", r"\centering\small", r"\begin{tabular}{l r l r r r r r}", r"\toprule",
                 r"initialization & scale & code relative to & test err.\ $f$ & bound on $g$ & bits & bound on $f$ & bits \\",
                 r"\midrule"]
        for k in sorted(g):
            rr = g[k]
            K = len(rr)
            b1 = min(rr, key=t1_bound)
            b2 = min(rr, key=lambda r: t2_bound(r, K))
            lines.append(f"{'seeded random' if k[0] == 'random' else 'deterministic DCT'} & {k[1]:g} & "
                         f"{'initialization' if k[2] == 'init' else 'zero'} & {rr[0]['test_err_f']:.4f} & {fmt(t1_bound(b1))} & "
                         f"{b1['bits'] + 4:.0f} & {fmt(t2_bound(b2, K))} & {b2['bits'] + 4:.0f}" + r" \\")
        lines += [r"\bottomrule", r"\end{tabular}",
                  r"\caption{MNIST, 784-256-10: description length and bounds when the update is coded relative to "
                  r"the (free) initialization or relative to zero, for three initialization scales and a deterministic "
                  r"initialization. Best of 8 compression configurations each.}\label{tab:init}", r"\end{table}"]
        write("init.tex", "\n".join(lines) + "\n")
    rows = load(os.path.join(RES, "init", "init_kernel.jsonl"))
    if rows:
        lines = [r"\begin{table}[t]", r"\centering\small", r"\begin{tabular}{l l r r r r r r r r}", r"\toprule",
                 r"task & regime & $m$ & test err.\ $f$ & move & lin.\ dis. & $r$ & bits & init-kernel bound & distillation bound \\",
                 r"\midrule"]
        for r in sorted(rows, key=lambda r: (r["task"], r["m"], r["regime"])):
            kc = r["kernel_codec"]
            lines.append(f"{tname(r)} & {r['regime']} & {r['m']} & {r['test_err_f']:.4f} & {r['rel_param_move']:.2f} & "
                         f"{r['lin_disagreement']:.3f} & {kc['r']} & {kc['bits'] + 4:.0f} & {fmt(boolean_bound(r['kernel_cert']))} & "
                         f"{fmt(boolean_bound(dict(r['distill_cert'], m=r['m'])))}" + r" \\")
        lines += [r"\bottomrule", r"\end{tabular}",
                  r"\caption{Boolean tasks ($n=30$, one hidden layer of 512): the init-kernel codec of \cref{prop:kernel} "
                  r"($\theta_0$ plus the top-$r$ eigenvectors of the uniform-input empirical NTK at $\theta_0$, both "
                  r"free) against function-space distillation, on the same networks. `Move': "
                  r"$\|\theta-\theta_0\|/\|\theta_0\|$; `lin.\ dis.': disagreement between $f$ and its linearization "
                  r"at $\theta_0$.}\label{tab:kernel}", r"\end{table}"]
        write("init_kernel.tex", "\n".join(lines) + "\n")


if __name__ == "__main__":
    boolean("n50", [500, 1000, 2000, 4000, 16000])
    boolean("n20", [100, 250, 500, 1000, 4000])
    t2()
    t3()
    init()
    print(sorted(os.listdir(TAB)) if os.path.exists(TAB) else [])
