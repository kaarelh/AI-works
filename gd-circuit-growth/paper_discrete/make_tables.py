"""Tables for the Parts 6-9 paper (paper_discrete/), generated from the study's result files with the study's own
functions (compare_hybrid, ablations, the toy harness).  Writes LaTeX fragments to paper_discrete/tables/.
usage: python3 make_tables.py

Every number is recomputed from the result files; the generated values were checked against the study's markdown
tables (discrete_learner/RESULTS.md, standard_tasks/RESULTS.md, hybrid/RESULTS.md, hybrid/HYBRID.md).
"""
import os, sys, json, numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
STUDY = os.path.join(os.path.dirname(HERE), "study")
OUT = os.path.join(HERE, "tables")
sys.path.insert(0, os.path.join(STUDY, "hybrid"))
import compare_hybrid as CH                                   # noqa: E402

TH, SC, DATA = CH.TH, CH.SC, CH.DATA
DL_RES = os.path.join(STUDY, "discrete_learner", "results")

DEF = {  # short definitions (from study/boolfuncs.py); products of +-1 inputs are parities
    "dict": r"$x_1$", "and3": r"AND$(x_1,x_2,x_3)$", "maj3": r"MAJ$(x_1,x_2,x_3)$", "maj9": r"MAJ$(x_1..x_9)$",
    "thr10": r"sign$(w\cdot x_{1..10})$, Gaussian $w$", "par2": r"$x_1x_2$", "par3": r"$x_1x_2x_3$",
    "par4": r"$x_1x_2x_3x_4$", "stair5": r"sign$(x_1+x_1x_2+\dots+x_1\cdots x_5)$",
    "majpar": r"MAJ$(x_1x_2,x_3x_4,x_5x_6)$", "parmaj": r"MAJ$_3\oplus$MAJ$_3$ on $x_{1..6}$",
    "mux": r"$x_4\,?\,x_1x_2x_3:\mathrm{MAJ}(x_1,x_2,x_3)$", "dnf3": "3-term DNF, 3 literals per term",
    "dlist5": "decision list on 5 literals", "rmaj9": r"MAJ of three MAJ$_3$", "andxor": r"AND$(x_1x_2,x_3x_4)$",
    "sparsepoly": r"sign$(2x_1+x_2x_3+x_4x_5x_6)$", "rand0": "random 6-gate formula", "rand1": "random 6-gate formula",
    "rand2": "random 6-gate formula", "rand3": "random 6-gate formula",
    "maj15": r"MAJ$(x_1..x_{15})$", "thr30": r"sign$(w\cdot x)$, Gaussian $w$ on all 30",
    "majxor": r"MAJ$_5\oplus$MAJ$_5$ on $x_{1..10}$", "majmaj5": r"MAJ of three MAJ$_5$", "par5": r"$x_1\cdots x_5$",
    "mux6": "6-multiplexer", "stair6": r"sign$(x_1+\dots+x_1\cdots x_6+\tfrac12)$",
    "inter2": r"AND of two halfspaces on $x_{1..10}$", "majpar5": r"MAJ$(x_1x_2,\dots,x_9x_{10})$",
    "hrf0": "random formula, 6 inputs", "hrf1": "random formula, 6 inputs", "hrf2": "random formula, 6 inputs",
    "thr20": r"sign$(w\cdot x_{1..20})$, Gaussian $w$", "maj21": r"MAJ$(x_1..x_{21})$",
    "xmaj": r"$x_1x_2\,$MAJ$(x_3,x_4,x_5)$", "dnf4x2": r"$(x_1\wedge x_2)\vee\dots\vee(x_7\wedge x_8)$",
    "sym8": r"$[|x_1+\dots+x_8|\ge4]$", "h2rf0": "random formula, 7 inputs", "h2rf1": "random formula, 7 inputs",
    "cnf3": r"$(x_1{\vee}x_2{\vee}x_3)\wedge(\bar x_4{\vee}x_5{\vee}x_6)\wedge(x_7{\vee}\bar x_8{\vee}x_9)$",
    "dlist8": "decision list on 8 literals", "h3rf0": "random formula, 7 inputs", "h3rf1": "random formula, 7 inputs",
    "mixmaj": r"MAJ$(x_1x_2,\ x_3{\wedge}x_4,\ x_5{\vee}x_6)$", "mux11": "11-multiplexer",
    "par3or": r"$x_1x_2x_3\vee(x_4{\wedge}x_5)$",
    "poly4": r"sign$(x_1x_2+x_3x_4x_5+\tfrac12x_6+x_7x_8x_9x_{10})$", "sym9": r"$[|x_1+\dots+x_9|\le1]$",
    "thrint": r"sign$(3x_1+2x_2+2x_3+x_4+\dots+x_9)$"}


def f_n(v):
    return "never" if not np.isfinite(v) else f"{v:.0f}"


def tt(s):
    return r"\texttt{" + s.replace("_", r"\_") + "}"


def toy_n(name, suite):
    r = CH.toy_load(name, suite)
    if r is None:
        return {}
    return {fn: TH.nstar(r["ns"], np.nanmean(np.array(v["err"], float), 1)) for fn, v in r["fns"].items()}


def dl_n(run):
    r = json.load(open(os.path.join(DL_RES, run + ".json")))
    return {fn: TH.nstar(r["ns"], np.nanmean(np.array(v["err"], float), 1)) for fn, v in r["fns"].items()}


def write(name, lines):
    p = os.path.join(OUT, name)
    open(p, "w").write("\n".join(lines) + "\n")
    print("wrote", p)


# ---- toy -------------------------------------------------------------------------------------------------------------
def tab_dlheld3():
    NR = CH.toy_nstars("dlheld3")
    P, S, U, L, G = (toy_n(k, "dlheld3") for k in ("hyb_portfolio-perm", "hyb_stage-perm", "hyb_union-perm", "lin", "hgb"))
    D = toy_n("abl_dfg-perm", "dlheld3"); X = toy_n("abl_noDFG-perm", "dlheld3")
    out = [r"\begin{tabular}{lrrrrrrrrrr}", r"\toprule",
           r"target & portfolio & \hd{DFG\\alone} & \hd{without\\DFG} & \texttt{lin} & \texttt{hgb} & \texttt{nets} & "
           r"\texttt{nets\_wd} & \texttt{nets\_cewd} & \texttt{nets\_best} & \hd{$\log_2$ ratio to\\\texttt{nets\_best}}\\", r"\midrule"]
    for fn in NR["nets"]:
        lr = CH.l2r(P[fn], NR["nets_best"][fn])
        out.append(f"{fn} & {f_n(P[fn])} & {f_n(D[fn])} & {f_n(X[fn])} & {f_n(L[fn])} & {f_n(G[fn])} & "
                   f"{f_n(NR['nets'][fn])} & {f_n(NR['nets_wd'][fn])} & {f_n(NR['nets_cewd'][fn])} & "
                   f"{f_n(NR['nets_best'][fn])} & ${lr:+.2f}$\\\\")
    out += [r"\bottomrule", r"\end{tabular}"]
    write("tab_dlheld3.tex", out)


def tab_toy_suites():
    rows = [("designed", "21", "development"), ("random", "20", "DFG development data"), ("dlheld", "12", "post hoc for DFG"),
            ("dlheld2", "7", "blind for DFG v1.1, used once"), ("dlheld3", "10", r"\textbf{fresh}")]
    out = [r"\begin{tabular}{lllllll}", r"\toprule",
           r"suite & targets & status & vs \texttt{nets} & vs \texttt{nets\_wd} & vs \texttt{nets\_best} & "
           r"\texttt{lin} vs \texttt{nets\_best}\\", r"\midrule"]
    for suite, k, status in rows:
        NR = CH.toy_nstars(suite); P = toy_n("hyb_portfolio-perm", suite); L = toy_n("lin", suite)
        cell = lambda A, ref: (lambda t: f"${t['mean']:+.2f}$ ({t['better']}/{t['worse']})")(CH.toy_summary(A, NR[ref]))
        out.append(f"\\texttt{{{suite}}} & {k} & {status} & {cell(P, 'nets')} & {cell(P, 'nets_wd')} & "
                   f"{cell(P, 'nets_best')} & {cell(L, 'nets_best')}\\\\")
    out += [r"\bottomrule", r"\end{tabular}"]
    write("tab_toy_suites.tex", out)


def app_toy(suite, dfg_runs, fname, with_def=True):
    NR = CH.toy_nstars(suite)
    P, L, G = toy_n("hyb_portfolio-perm", suite), toy_n("lin", suite), toy_n("hgb", suite)
    Ds = [(lab, dl_n(run)) for lab, run in dfg_runs]
    cols = "l" + ("l" if with_def else "") + "r" * (len(Ds) + 5 + (1 if G else 0))
    head = "target" + (" & definition" if with_def else "") + "".join(f" & {lab}" for lab, _ in Ds) + \
        r" & portfolio & \texttt{lin}" + (r" & \texttt{hgb}" if G else "") + r" & \texttt{nets} & \texttt{nets\_wd} & $\log_2$\\"
    out = [rf"\begin{{tabular}}{{{cols}}}", r"\toprule", head, r"\midrule"]
    for fn in NR["nets"]:
        lr = CH.l2r(P[fn], NR["nets_best"][fn])
        out.append(f"{fn}" + (f" & {DEF.get(fn, '')}" if with_def else "") + "".join(f" & {f_n(D.get(fn, np.nan))}" for _, D in Ds)
                   + f" & {f_n(P[fn])} & {f_n(L[fn])}" + (f" & {f_n(G[fn])}" if G else "")
                   + f" & {f_n(NR['nets'][fn])} & {f_n(NR['nets_wd'][fn])} & ${lr:+.2f}$\\\\")
    out += [r"\bottomrule", r"\end{tabular}"]
    write(fname, out)


# ---- Part 7 ------------------------------------------------------------------------------------------------------------
def err_at(L, ds, n):
    r = SC.load(L, ds)
    if r is None:
        return np.nan
    ns = r["ns"][:len(r["err"])]
    return float(np.nanmean(np.array(r["err"][ns.index(n)], float))) if n in ns else np.nan


def app_part7():
    Ls = ["mlp", "mlp_l2", "dfg_bits-v1", "dfg_gates-v1", "dfg_dirs-v2", "linear", "hgb"]
    out = [r"\begin{tabular}{lrrrrrrrr}", r"\toprule",
           r"dataset & $n$ & MLP & MLP-L2 & \texttt{dfg\_bits} & \texttt{dfg\_gates} & \texttt{dfg\_dirs} & linear & \texttt{hgb}\\",
           r"\midrule"]
    for ds in DATA.HELDOUT:
        rm = SC.load("mlp", ds); full = rm["ns"][len(rm["err"]) - 1]
        for n in [300, 3000, full] if full != 3000 else [300, 3000]:
            if n not in rm["ns"]:
                continue
            v = [err_at(L, ds, n) for L in Ls]
            out.append((ds.replace("_", r"\_") if n == 300 else "") + f" & {n} & " +
                       " & ".join("--" if not np.isfinite(x) else f"{x:.3f}" for x in v) + r"\\")
        out.append(r"\addlinespace[1pt]")
    out += [r"\bottomrule", r"\end{tabular}"]
    write("app_part7.tex", out)


# ---- Part 8 real ---------------------------------------------------------------------------------------------------------
def ds_stats(L, ds, kind):
    c = CH.cells(CH.load(L, ds), CH.ref(kind, ds), ds)
    if not c:
        return None
    return float(np.mean([x["lr"] for x in c])), sum(x["v"] == "better" for x in c), sum(x["v"] == "worse" for x in c), len(c)


def app_part8_real():
    short = {"mlp": "mlp", "mlp_plus": "plus", "mlp_l2": "l2", "mlp_l2unit": "l2unit", "mlp_unit": "unit",
             "mlp_strong": "strong", "mlp_strong1": "strong1"}
    out = [r"\begin{tabular}{lrcccrrlr}", r"\toprule",
           r"dataset & cells & \hd{vs \texttt{mlp\_best}\\(b/w)} & \hd{vs \texttt{mlp\_strong}\\(b/w)} & "
           r"\hd{\texttt{hgb} vs\\\texttt{mlp\_best}} & full $n$ & \hd{\texttt{mlp\_best}\\error} & variant & \hd{portfolio\\error}\\",
           r"\midrule"]
    for title, names in (("HELDOUT2 (fresh)", list(DATA.HELDOUT2)),
                         ("Part 7 tabular set (references known to the designers)", [d for d in DATA.HELDOUT if d not in CH.IMG]),
                         ("images (references known to the designers)", list(CH.IMG))):
        out.append(rf"\multicolumn{{9}}{{l}}{{\emph{{{title}}}}}\\")
        for ds in names:
            a = ds_stats("hyb_portfolio", ds, "mlp_best"); b = ds_stats("hyb_portfolio", ds, "mlp_strong")
            h = ds_stats("hgb", ds, "mlp_best")
            mb = CH.ref("mlp_best", ds); full = mb["ns"][-1]
            e_mb = float(np.nanmean(np.array(mb["err"][-1], float)))
            rp = CH.load("hyb_portfolio", ds); e_p = float(np.nanmean(np.array(rp["err"][rp["ns"].index(full)], float)))
            bs = (f"${b[0]:+.2f}$ ({b[1]}/{b[2]})" + ("" if b[3] == a[3] else r"$^\dagger$")) if b else "--"
            out.append(f"{ds.replace('_', chr(92) + '_')} & {a[3]} & ${a[0]:+.2f}$ ({a[1]}/{a[2]}) & {bs} & ${h[0]:+.2f}$ & "
                       f"{full} & {e_mb:.4f} & {short[mb['variant'][-1]]} & {e_p:.4f}\\\\")
        out.append(r"\addlinespace[2pt]")
    out += [r"\bottomrule", r"\end{tabular}"]
    write("app_part8_real.tex", out)


# ---- Part 9 ------------------------------------------------------------------------------------------------------------
sys.path.insert(0, os.path.join(STUDY, "part9"))
import compare_part9 as C9                                    # noqa: E402  (functions only)
C9.V2 = "hyb_portfolio2"                                      # (compare_part9 reads its V2 from sys.argv)
NETS9 = ("nets", "nets_wd", "nets_cewd", "nets_cewd0.3", "nets_cewd1.0")
P9_TOY = [("dlheld6", "held out, blind (Q1)"), ("dlheld5", "held out, inside S's class"),
          ("dlheld4", "held out, definitions seen by S"), ("dlsymdev", "development"), ("designed", "development")]


def l2fmt(x):
    return f"${x:+.2f}$" if np.isfinite(x) else ("both never" if np.isnan(x) else (r"$+\infty$" if x > 0 else r"$-\infty$"))


def tab_p9_toy(suite, fname):
    NR = CH.toy_nstars(suite)
    V2, V1, L, G = (toy_n(k, suite) for k in ("hyb_portfolio2-perm", "hyb_portfolio-perm", "lin", "hgb"))
    nets = [k for k in NETS9 if k in NR]
    hdr = {"nets": r"\texttt{nets}", "nets_wd": r"\hd{\texttt{nets}\\\texttt{\_wd}}", "nets_cewd": r"\hd{\texttt{nets}\\\texttt{\_cewd}}",
           "nets_cewd0.3": r"\hd{\texttt{cewd}\\0.3}", "nets_cewd1.0": r"\hd{\texttt{cewd}\\1.0}"}
    out = [r"\begin{tabular}{l" + "r" * (4 + len(nets) + 3) + "}", r"\toprule",
           r"target & v2 & v1 & \texttt{lin} & \texttt{hgb} & " + " & ".join(hdr[k] for k in nets)
           + r" & \hd{\texttt{nets}\\\texttt{\_best}} & \hd{$\log_2$ v2 /\\\texttt{nets\_best}} & \hd{$\log_2$\\v2 / v1}\\", r"\midrule"]
    order = [fn for fn in NR["nets"] if fn not in C9.NONSUM] + [fn for fn in NR["nets"] if fn in C9.NONSUM]
    for i, fn in enumerate(order):
        if fn in C9.NONSUM and (i == 0 or order[i - 1] not in C9.NONSUM):
            out.append(r"\midrule")                                       # the controls below
        nb = NR["nets_best"][fn]
        out.append(f"{tt(fn)}{' (control)' if fn in C9.NONSUM else ''} & {f_n(V2.get(fn, np.nan))} & {f_n(V1.get(fn, np.nan))} & "
                   f"{f_n(L.get(fn, np.nan))} & {f_n(G.get(fn, np.nan))} & "
                   + " & ".join(f_n(NR[k][fn]) if fn in NR[k] else "---" for k in nets)
                   + f" & {f_n(nb)} & {l2fmt(CH.l2r(V2.get(fn, np.nan), nb))} & {l2fmt(CH.l2r(V2.get(fn, np.nan), V1.get(fn, np.nan)))}" + r"\\")
    out += [r"\bottomrule", r"\end{tabular}"]
    write(fname, out)


def tab_p9_toy_summary():
    out = [r"\begin{tabular}{llcccc}", r"\toprule",
           r"suite & status & \hd{v2 vs \texttt{nets\_best}\\all targets} & \hd{v2 vs \texttt{nets\_best}\\sum-structured} & "
           r"\hd{v1 vs \texttt{nets\_best}\\sum-structured} & \hd{v2 vs v1\\sum-structured}\\", r"\midrule"]
    sub = lambda A: {fn: v for fn, v in A.items() if fn not in C9.NONSUM}
    cell = lambda A, R: (lambda t: f"${t['mean']:+.2f}$ ({t['better']}/{t['worse']})")(CH.toy_summary(A, R))
    for suite, status in P9_TOY:
        NR = CH.toy_nstars(suite); V2 = toy_n("hyb_portfolio2-perm", suite) or toy_n("p9_sum-perm", suite)
        V1 = toy_n("hyb_portfolio-perm", suite)
        out.append(f"\\texttt{{{suite}}} & {status} & {cell(V2, NR['nets_best'])} & {cell(sub(V2), NR['nets_best'])} & "
                   f"{cell(sub(V1), NR['nets_best'])} & {cell(sub(V2), V1)}" + r"\\")
    out += [r"\bottomrule", r"\end{tabular}"]
    write("tab_p9_toy_summary.tex", out)


P9_IMG_COLS = [("hyb_portfolio2", "v2"), ("hyb_portfolio", "v1"), ("hgb", r"\texttt{hgb}"), ("mlp_strong", r"\hd{\texttt{mlp}\\\texttt{\_strong}}"),
               ("mlp_wide", r"\hd{\texttt{mlp}\\\texttt{\_wide}}"), ("mlp_wide1", r"\hd{\texttt{mlp}\\\texttt{\_wide1}}"),
               ("mlp_xl", r"\hd{\texttt{mlp}\\\texttt{\_xl}}"), ("mlp_best", r"\hd{\texttt{mlp}\\\texttt{\_best}}"),
               ("mlp_best+", r"\hd{\texttt{mlp}\\\texttt{\_best+}}"), ("mlp_pool", r"\hd{\texttt{mlp}\\\texttt{\_pool}}"), ("cnn", r"\texttt{cnn}")]


def tab_p9_images():
    out = [r"\begin{tabular}{ll" + "r" * len(P9_IMG_COLS) + "}", r"\toprule",
           "set & $n$ & " + " & ".join(h for _, h in P9_IMG_COLS) + r"\\", r"\midrule"]
    for ds in C9.IMG_HELD:
        R = {k: C9.ref(k, ds) for k, _ in P9_IMG_COLS}
        for n in DATA.grid(DATA.load(ds)):
            def g(k):
                r = R[k]
                if r is None or n not in r["ns"][:len(r["err"])]:
                    return "---"
                v = np.nanmean(np.array(r["err"][r["ns"].index(n)], float))
                return "---" if not np.isfinite(v) else f"{100 * v:.1f}"
            vals = [g(k) for k, _ in P9_IMG_COLS]
            ranked = [float(v) for (k, _), v in zip(P9_IMG_COLS, vals) if v != "---" and k not in ("cnn", "mlp_pool", "mlp_best", "mlp_best+")]
            best = min(ranked) if ranked else None
            cells = [r"\textbf{" + v + "}" if v != "---" and best is not None and float(v) == best and k not in ("cnn", "mlp_pool", "mlp_best", "mlp_best+")
                     else v for (k, _), v in zip(P9_IMG_COLS, vals)]
            out.append((r"\texttt{" + ds.replace("_", r"\_") + "}" if n == 100 else "") + f" & {n} & " + " & ".join(cells) + r"\\")
        if ds != C9.IMG_HELD[-1]:
            out.append(r"\midrule")
    out += [r"\bottomrule", r"\end{tabular}"]
    write("tab_p9_images.tex", out)


def tab_p9_q2():
    refs = [("mlp_strong", r"\texttt{mlp\_strong} (pre-registered)"), ("mlp_best", r"\texttt{mlp\_best} (pre-registered)"),
            ("mlp_wide", r"\texttt{mlp\_wide}"), ("mlp_wide1", r"\texttt{mlp\_wide1}"), ("mlp_xl", r"\texttt{mlp\_xl} (CPU-matched)"),
            ("mlp_best+", r"\texttt{mlp\_best+}"), ("mlp_pool", r"\texttt{mlp\_pool} (control)"), ("cnn", r"\texttt{cnn} (context; uses the layout)")]
    out = [r"\begin{tabular}{lcccc}", r"\toprule",
           r"reference & \hd{v2, $n\ge10000$: cells\\better / tie / worse} & \hd{v2, $n\ge10000$\\mean $\log_2$} & \hd{v2, $n\le3000$\\mean $\log_2$} & \hd{v1, $n\ge10000$\\mean $\log_2$}\\", r"\midrule"]
    summ = lambda L, k, lo, hi: [c for ds in C9.IMG_HELD for c in C9.img_cells(L, ds, k, lo, hi)]
    m = lambda C: f"${np.mean([c['lr'] for c in C]):+.2f}$" if C else "---"
    for k, lab in refs:
        A = summ(C9.V2, k, 10000, 10 ** 9); B = summ(C9.V2, k, 0, 3000); V = summ("hyb_portfolio", k, 10000, 10 ** 9)
        v = [c["v"] for c in A]
        out.append(f"{lab} & {len(A)}: {v.count('better')} / {v.count('tie')} / {v.count('worse')} & {m(A)} & {m(B)} & {m(V)}" + r"\\")
    out += [r"\bottomrule", r"\end{tabular}"]
    write("tab_p9_q2.tex", out)


def p9_tables():
    tab_p9_toy("dlheld6", "tab_p9_dlheld6.tex"); tab_p9_toy("dlheld5", "app_p9_dlheld5.tex"); tab_p9_toy("dlheld4", "app_p9_dlheld4.tex")
    tab_p9_toy_summary(); tab_p9_images(); tab_p9_q2()


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    if sys.argv[1:] == ["p9"]:
        p9_tables(); sys.exit(0)
    tab_dlheld3(); tab_toy_suites()
    app_toy("designed", [("DFG v1", "dfg-c1.0__designed")], "app_toy_designed.tex")
    app_toy("random", [("DFG v1", "dfg-c1.0__random")], "app_toy_random.tex", with_def=False)
    app_toy("dlheld", [("DFG v1$^-$", "dfg-c1.0-Khi4__dlheld"), ("DFG v1.1", "dfg-v1.1__dlheld")], "app_toy_dlheld.tex")
    app_toy("dlheld2", [("DFG v1.1", "dfg-v1.1-perm__dlheld2")], "app_toy_dlheld2.tex")
    app_part7(); app_part8_real()
    p9_tables()
