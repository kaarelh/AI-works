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
    return f"{min(x, 1.0):.{d}f}"


def sparse_exact_bound(r, delta=0.05):
    """Occam bound for the sparse-update network f coded EXACTLY: seed, flags and
    architecture as in the dithered code, the same per-band support code, and 32
    bits for every nonzero first-layer coefficient and every b, V, c entry."""
    H = r["widths"][1]
    C = r["widths"][2]
    nz = int(round(r["nonzero_fraction"] * 784 * H))
    c = r["code"]
    bits = (c["architecture"] + c["init seed"] + c["code flags"] + c["basis"] + c["support flag"]
            + c["layer0 support"] + 32.0 * (nz + H + C * H + C) + 4)
    k = int(round(r["train_err_f"] * 60000))
    return occam_bound(k, 60000, bits, delta), bits


def vc_dense(r, delta=0.05, m=60000):
    from cgb.bounds import vc_bound
    return vc_bound(int(round(r["train_err_f"] * m)), m, r["params"], delta)


def write(name, body):
    # Shrink any table wider than the text block (adjustbox's max width leaves narrower tables alone).
    body = body.replace(r"\begin{tabular}", r"\begin{adjustbox}{max width=\linewidth}\begin{tabular}")
    body = body.replace(r"\end{tabular}", r"\end{tabular}\end{adjustbox}")
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
        lines = [r"\begin{table}[t]", r"\centering\small", r"\begin{tabular}{l r l l r r r r r r}", r"\toprule",
                 r"data & $H$ & training & code & test err.\ $f$ & bits & certified & bound on $f$ & 32-bit Occam & VC \\",
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
        for r in sorted(rows, key=lambda r: (r["data"] != "mnist", r.get("weight_noise", 0), r["widths"][1], code(r))):
            P = r["params"]
            occ32 = occam_bound(int(round(r["train_err_f"] * 60000)), 60000, 32.0 * P + 64, 0.05)
            lines.append(f"{r['data']} & {r['widths'][1]} & {var(r)} & {code(r)} & {r['test_err_f']:.4f} & {r['bits'] + 4:.0f} & "
                         f"{r['cert_frac']:.3f} & {fmt(t3_bound(r))} & {fmt(occ32, 2)} & {fmt(vc_dense(r), 2)}" + r" \\")
        lines += [r"\bottomrule", r"\end{tabular}",
                  r"\caption{Bounds on the original one-hidden-layer network $f$ from the 60{,}000 training examples "
                  r"alone (\cref{thm:dither,lem:cert}): no validation set and no unlabeled data. `Certified': fraction "
                  r"of training points with $\pi_g=1$. `Noise $\sigma$': $f$ trained with Gaussian weight noise of "
                  r"$\sigma$ times each tensor's initial RMS. Baselines for $f$: the Occam bound with 32 bits per "
                  r"parameter, and the VC bound with $d$ equal to the number of parameters (optimistic, "
                  r"\cref{sec:methods}). One seed per row. Chance level is 0.9.}\label{tab:t3}", r"\end{table}"]
        write("t3.tex", "\n".join(lines) + "\n")
    rows = load(os.path.join(RES, "mnist", "t3_sparse.jsonl"))
    if rows:
        lines = [r"\begin{table}[t]", r"\centering\small", r"\begin{tabular}{l r r r r r r r r}", r"\toprule",
                 r"data & $H$ & kept coeff. & test err.\ $f$ & bits & certified & bound on $f$ & exact code: bits & bound \\",
                 r"\midrule"]
        for r in sorted(rows, key=lambda r: (r["data"] != "mnist", r["widths"][1], -r["nonzero_fraction"])):
            eb, ebits = sparse_exact_bound(r)
            lines.append(f"{r['data']} & {r['widths'][1]} & {100 * r['nonzero_fraction']:.1f}\\% & {r['test_err_f']:.4f} & "
                         f"{r['bits'] + 4:.0f} & {r['cert_frac']:.3f} & {fmt(t3_bound(r))} & {ebits:.0f} & {fmt(eb)}" + r" \\")
        lines += [r"\bottomrule", r"\end{tabular}",
                  r"\caption{As \cref{tab:t3}, for networks whose first-layer update is exactly sparse in the DCT basis "
                  r"(trained, pruned to the stated fraction of coefficients, fine-tuned with the support fixed). The "
                  r"support is part of the description; only nonzero coefficients are dithered. The last two columns "
                  r"are the baseline for such a network: the Occam bound for coding $f$ exactly, with the same support "
                  r"code and 32 bits per stored parameter. One seed per row.}\label{tab:t3sparse}",
                  r"\end{table}"]
        write("t3_sparse.tex", "\n".join(lines) + "\n")
    rows = load(os.path.join(RES, "boolean", "t3.jsonl"))
    if rows:
        lines = [r"\begin{table}[t]", r"\centering\small", r"\setlength{\tabcolsep}{4pt}",
                 r"\begin{tabular}{l r r r r r r r r r r}", r"\toprule",
                 r" & & & & & \multicolumn{2}{c}{baselines} & \multicolumn{2}{c}{training data only} & "
                 r"\multicolumn{2}{c}{known $D_X$} \\",
                 r"\cmidrule(lr){6-7}\cmidrule(lr){8-9}\cmidrule(lr){10-11}",
                 r"task & $n$ & $m$ & $H$ & test err.\ $f$ & 32-bit Occam & VC & bits & bound & bits & bound \\",
                 r"\midrule"]
        for r in sorted(rows, key=lambda r: (r["n"], r["task"], r["m"], r["width"], r["weight_noise"])):
            m = r["m"]
            occ32 = occam_bound(int(round(r["train_err_f"] * m)), m, 32.0 * r["params"] + 64, 0.05)
            lines.append(f"{tname(r)}{', noise ' + format(r['weight_noise'], 'g') if r['weight_noise'] else ''} & {r['n']} & "
                         f"{m} & {r['width']} & {r['test_err_f']:.4f} & {fmt(occ32, 2)} & {fmt(vc_dense(r, m=m), 2)} & "
                         f"{r['t3_bits'] + 4:.0f} & {fmt(t3_bound(r))} & "
                         f"{r['T2known_bits'] + 4:.0f} & {fmt(boolean_bound(dict(r['T2known'], m=m)))}" + r" \\")
        lines += [r"\bottomrule", r"\end{tabular}",
                  r"\caption{Boolean tasks, one-hidden-layer networks, one seed each: the training-data-only bound "
                  r"(\cref{thm:dither}), which holds whatever the input distribution, against the bound that uses the "
                  r"known uniform input distribution (\cref{thm:reduction}) on the same network. `Noise $\sigma$': $f$ "
                  r"trained with Gaussian weight noise of $\sigma$ times each tensor's initial RMS. Baselines for $f$ as in "
                  r"\cref{tab:t3}; with only 353--1665 parameters they are not vacuous here.}\label{tab:boolean_t3}",
                  r"\end{table}"]
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
                  r"initialization. `Scale' multiplies the default (PyTorch) initialization. One network per row; best of 8 "
                  r"compression configurations each, with the bound on $f$ union-bounded over the 8.}\label{tab:init}", r"\end{table}"]
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
                  r"at $\theta_0$. One seed per row.}\label{tab:kernel}", r"\end{table}"]
        write("init_kernel.tex", "\n".join(lines) + "\n")


def headline():
    rows = []
    b50 = load(os.path.join(RES, "boolean", "grid_n50.jsonl"))
    b20 = load(os.path.join(RES, "boolean", "grid_n20.jsonl"))

    def bool_row(data, task, noise, m, label, anyD=False):
        rr = [r for r in data if r["task"] == task and r["noise"] == noise and r["m"] == m]
        if not rr:
            return
        n = rr[0]["n"]
        te = np.mean([r["test_err_f"] for r in rr])
        bd = np.mean([boolean_any_D(r) if anyD else boolean_bound(r) for r in rr])
        bits = np.mean([(r["bits_any_D"] if anyD else r["bits"]) + 4 for r in rr])
        P = rr[0]["params"]
        occ = np.mean([occam_bound(int(round(r["train_err_f"] * m)), m, 32.0 * P + 64, 0.05) for r in rr])
        vc = np.mean([r["baseline_vc_W"] for r in rr])
        rows.append((label + f" ($n={n}$, $m={m}$)", f"MLP, {P / 1000:.0f}k params",
                     "known $D_X$" if not anyD else "none (any $D$)", te, bd, bits, occ, vc))
    bool_row(b50, "parity3", 0.0, 4000, r"\texttt{parity3}")
    bool_row(b50, "parity3", 0.0, 2000, r"\texttt{parity3}, partly learned")
    bool_row(b50, "junta6", 0.0, 4000, r"\texttt{junta6}")
    bool_row(b50, "maj5", 0.1, 16000, r"\texttt{maj5}, 10\% label noise")
    bool_row(b20, "parity3", 0.0, 4000, r"\texttt{parity3}", anyD=True)
    t2rows = load(os.path.join(RES, "mnist", "t2.jsonl"))
    for d, H in [("mnist", 100), ("fashion", 100)]:
        rr = [r for r in t2rows if r["data"] == d and r["widths"][1] == H and r.get("init", "random") == "random"
              and r.get("code_ref", "init") == "init" and r["basis"] == "dct"]
        if rr:
            K = len(rr)
            b = min(rr, key=lambda r: t2_bound(r, K))
            occ = occam_bound(int(round(b["train_err_f"] * 60000)), 60000, 32.0 * b["params"] + 64, 0.05)
            rows.append(({"mnist": "MNIST", "fashion": "Fashion-MNIST"}[d], f"784-{H}-10", "unlabeled inputs",
                         b["test_err_f"], t2_bound(b, K), b["bits"] + 4, occ, b["baseline_vc_W"]))
    t3rows = load(os.path.join(RES, "mnist", "t3.jsonl"))
    for d, H in [("mnist", 8), ("mnist", 16)]:
        rr = [r for r in t3rows if r["data"] == d and r["widths"][1] == H and r.get("weight_noise", 0) == 0
              and r["basis"] == "dct" and r.get("code_ref", "init") == "init" and r.get("init", "random") == "random"]
        for r in rr:
            occ = occam_bound(int(round(r["train_err_f"] * 60000)), 60000, 32.0 * r["params"] + 64, 0.05)
            rows.append(({"mnist": "MNIST", "fashion": "Fashion-MNIST"}[d], f"784-{H}-10", "none",
                         r["test_err_f"], t3_bound(r), r["bits"] + 4, occ, vc_dense(r)))
    sp = load(os.path.join(RES, "mnist", "t3_sparse.jsonl"))
    for d, H, nz in [("mnist", 100, 0.01), ("mnist", 256, 0.003)]:
        rr = [r for r in sp if r["data"] == d and r["widths"][1] == H and abs(r["nonzero_fraction"] - nz) < 1e-4]
        for r in rr:
            occ = sparse_exact_bound(r)[0]
            rows.append(({"mnist": "MNIST", "fashion": "Fashion-MNIST"}[d], f"784-{H}-10, {100 * nz:g}\\% update",
                         "none", r["test_err_f"], t3_bound(r), r["bits"] + 4, occ, None))
    lines = [r"\begin{table}[t]", r"\centering\small", r"\setlength{\tabcolsep}{4pt}",
             r"\begin{tabular}{l l l r r r r r}", r"\toprule",
             r"task & network $f$ & extra data & test err.\ $f$ & bound on $f$ & bits & 32-bit code & VC \\", r"\midrule"]
    for row in rows:
        vc = "--" if row[7] is None else fmt(row[7], 2)
        lines.append(f"{row[0]} & {row[1]} & {row[2]} & {row[3]:.4f} & {fmt(row[4])} & {row[5]:,.0f} & {fmt(row[6], 2)} & {vc}" + r" \\")
    lines += [r"\bottomrule", r"\end{tabular}",
              r"\caption{Headline results: certified upper bounds on the test error of the trained network itself, at "
              r"confidence 95\%, against its measured test error and two parameter-counting baselines for the same "
              r"network: the Occam bound for coding it exactly with 32 bits per parameter (for sparse-update networks: "
              r"per stored parameter, plus the support), and the VC bound with $d$ equal to the number of parameters "
              r"(optimistic). `Extra data': what the bound uses besides the training set; no row uses labelled "
              r"held-out data. Chance level is 0.5 for the Boolean tasks and 0.9 for MNIST. Boolean rows average three seeds; "
              r"image rows are one network each, with $m=60000$. "
              r"`Bits': description length of the compressed or dithered network.}"
              r"\label{tab:headline}", r"\end{table}"]
    write("headline.tex", "\n".join(lines) + "\n")


if __name__ == "__main__":
    headline()
    boolean("n50", [500, 1000, 2000, 4000, 16000])
    boolean("n20", [100, 250, 500, 1000, 4000])
    t2()
    t3()
    init()
    print(sorted(os.listdir(TAB)) if os.path.exists(TAB) else [])
