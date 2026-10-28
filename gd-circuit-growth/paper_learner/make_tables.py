"""LaTeX tables of the learner paper, generated from study/part10/LEARNER_RESULTS.json (compare_learner.py); the image
tables also read the result files in study/standard_tasks/results/ (see the images block below).
usage: python make_tables.py          writes tables/*.tex"""
import os, json, math
HERE = os.path.dirname(os.path.abspath(__file__))
J = json.load(open(os.path.join(HERE, "..", "study", "part10", "LEARNER_RESULTS.json")))
OUT = os.path.join(HERE, "tables"); os.makedirs(OUT, exist_ok=True)
fin = lambda v: v is not None and isinstance(v, (int, float)) and math.isfinite(v)
code = lambda s: "\\code{" + s + "}"


def ns(v):
    return f"{v:.0f}" if fin(v) else ("never" if v is not None else "--")


def summ(t):
    if not t:
        return "--"
    m = f"${t['mean']:+.2f}$" if fin(t["mean"]) else "n/a"
    return f"{m} ({t['better']}/{t['worse']})"


TOY_ROLE = {"designed": "dev", "random": "dev check (P6)$^c$", "dlheld": "held out (P6)", "dlheld2": "held out (P6)",
            "dlheld3": "held out (P8)", "dlsymdev": "dev (P9)", "dlheld4": "held out (P9)$^a$", "dlheld5": "held out (P9)",
            "dlheld6": "held out (P9), dev (P10)$^b$", "dlfamdev": "dev (P10)", "dlheld7": "\\textbf{held out (P10)}"}
ORDER = ["designed", "random", "dlheld", "dlheld2", "dlheld3", "dlsymdev", "dlheld4", "dlheld5", "dlheld6", "dlfamdev", "dlheld7"]


def tab_toy_suites():
    L = ["\\begin{tabular}{llccccc}", "\\toprule",
         "suite & status & targets & v3 vs \\code{nets_best} & v3 vs v2 & v3 vs \\code{lin} & v3 vs \\code{hgb}\\\\", "\\midrule"]
    for su in ORDER:
        r = J["toy"].get(su)
        if not r:
            L.append(f"{code(su)} & {TOY_ROLE[su]} & \\multicolumn{{5}}{{c}}{{(not run)}}\\\\"); continue
        L.append(f"{code(su)} & {TOY_ROLE[su]} & {r['targets']} & {summ(r['nets_best'])} & {summ(r['v2'])} & {summ(r['lin'])} & {summ(r['hgb'])}\\\\")
    L += ["\\bottomrule", "\\end{tabular}"]
    open(os.path.join(OUT, "tab_toy_suites.tex"), "w").write("\n".join(L) + "\n")


def tab_dlheld7():
    r = J["toy"].get("dlheld7")
    if not r:
        return
    import sys
    sys.path.insert(0, os.path.join(HERE, "..", "study"))
    import boolfuncs
    T = boolfuncs.make_dl_heldout7_suite(30)
    cols = ["v3", "v2", "nets_wd", "nets_cewd0.3", "nets_cewd1.0", "nets_best", "lin", "hgb"]
    hdr = ["v3", "v2", "\\code{nets_wd}", "\\hd{\\code{nets_}\\\\\\code{cewd0.3}}", "\\hd{\\code{nets_}\\\\\\code{cewd1.0}}",
           "\\code{nets_best}", "\\code{lin}", "\\code{hgb}"]
    L = ["\\begin{tabularx}{\\linewidth}{l>{\\raggedright\\arraybackslash}X" + "r" * len(cols) + "}", "\\toprule",
         "target & definition & " + " & ".join(hdr) + "\\\\", "\\midrule"]
    for t, v in sorted(r["per_target"].items()):
        desc = T[t]["desc"].replace("_", "\\_").replace("&", "\\&").replace("<=", "$\\le$").replace(">=", "$\\ge$").replace("->", "$\\to$")
        L.append(f"{t.replace('_', chr(92) + '_')} & {{\\scriptsize {desc}}} & " + " & ".join(ns(v.get(c)) for c in cols) + "\\\\")
    L += ["\\bottomrule", "\\end{tabularx}"]
    open(os.path.join(OUT, "tab_dlheld7.tex"), "w").write("\n".join(L) + "\n")


def tab_real():
    REFS = [("mlp", "\\code{mlp}"), ("mlp_reg", "\\code{mlp_reg}"), ("mlp_strong", "\\code{mlp_strong}"), ("mlp_best", "\\code{mlp_best}"),
            ("hgb", "\\code{hgb}")]
    L = ["\\begin{tabular}{llccc}", "\\toprule", "split & reference & \\hd{cells\\\\(better / tie / worse)} & \\hd{mean\\\\$\\log_2$ ratio} & "
         "\\hd{datasets with lower\\\\mean error (sign test $p$)}\\\\", "\\midrule"]
    for lab in ["tabular, Part 7 held-out set", "tabular, Part 8 fresh set (HELDOUT2)", "tabular, development"]:
        R = J["real"].get(lab, {})
        first = True
        for k, nm in REFS:
            x = R.get(f"{k}|all")
            if not x:
                continue
            L.append(f"{lab.replace('tabular, ', '') if first else ''} & {nm} & {x['cells']} ({x['better']}/{x['tie']}/{x['worse']}) & ${x['mean']:+.3f}$ & {x['ds_lower']} of {x['datasets']} ({x['ds_p']:.2g})\\\\")
            first = False
        L.append("\\midrule")
    L[-1] = "\\bottomrule"; L.append("\\end{tabular}")
    open(os.path.join(OUT, "tab_real.tex"), "w").write("\n".join(L) + "\n")


# ---- images (sections/results_images.tex) --------------------------------------------------------------------------------
# Errors and cell summaries: LEARNER_RESULTS.json (compare_learner.py).  Per-cell verdicts of v3 against each reference:
# recomputed here with compare_learner's own loaders (v3_real; compare_hybrid.load / compare_part9.ref) and
# compare_hybrid.cells (better / worse: > 10% relative and > 2 s.e.).  Stacking weights, FLOPs and CPU seconds: the result
# files study/standard_tasks/results/<learner>__<dataset>.json and .info.json.
RES = os.path.join(HERE, "..", "study", "standard_tasks", "results")
IMG_PANELS = [("(a) held out for v3 (Part 10): 3 seeds at $n\\le10000$, seed 0 at $n=60000$", ["qd_c", "qd_d"],
               "images, Part 10 held out (QuickDraw qd_c, qd_d)"),
              ("(b) Part 9 held-out sets, development data for v3: v3 seed 0", ["qd_a", "qd_b"],
               "images, Part 9 held out (qd_a, qd_b; v3 at its seed-0 dev cells)"),
              ("(c) development sets: v3 and v2 seed 0", ["qd_dev", "fashion_mnist"],
               "images, development (qd_dev, Fashion-MNIST; seed-0 dev cells)")]
IMG_NAME = {"qd_c": "\\code{qd_c}", "qd_d": "\\code{qd_d}", "qd_a": "\\code{qd_a}", "qd_b": "\\code{qd_b}",
            "qd_dev": "\\code{qd_dev}", "fashion_mnist": "Fashion"}
hd2 = lambda a, b: "\\hd{\\code{" + a + "}\\\\\\code{" + b + "}}"
IMG_COLS = [("v3", "v3"), ("hyb_portfolio2", "v2"), ("hyb_portfolio", "v1"), ("hgb", "\\code{hgb}"),
            ("mlp_strong", hd2("mlp_", "strong")), ("mlp_wide", hd2("mlp_", "wide")), ("mlp_xl", hd2("mlp_", "xl")),
            ("mlp_best+", hd2("mlp_", "best+")), ("mlp_pool", hd2("mlp_", "pool")), ("cnn", "\\code{cnn}")]
IMG_BOLD = ("v3", "hyb_portfolio2", "hyb_portfolio", "hgb", "mlp_strong", "mlp_wide", "mlp_xl")   # not per-cell minima, controls


def _cl():
    """study/part10/compare_learner.py as a module: v3_real, CH (= compare_hybrid), C9 (= compare_part9)."""
    import sys
    p = os.path.join(HERE, "..", "study", "part10")
    if p not in sys.path:
        sys.path.insert(0, p)
    argv = sys.argv; sys.argv = sys.argv[:1]
    try:
        import compare_learner as CL
    finally:
        sys.argv = argv
    return CL


def img_verdicts(CL, ds):
    """{(reference, n): verdict of v3 against it} by the Part 8 cell rule, with compare_learner's loaders."""
    v3, out = CL.v3_real(ds), {}
    for k, _ in IMG_COLS[1:]:
        R = CL.C9.ref(k, ds) if k in ("mlp_best", "mlp_best+") else CL.CH.load(k, ds)
        for c in CL.CH.cells(v3, R, ds):
            out[(k, c["n"])] = c["v"]
    return out


def tab_images_cells():
    """Test error (%) per cell; bold = lowest of IMG_BOLD; a reference's entry is marked where v3 is not clearly better."""
    CL = _cl()
    nc = 2 + len(IMG_COLS)
    L = ["\\begin{tabular}{lr" + "c" * len(IMG_COLS) + "}", "\\toprule", "set & $n$ & " + " & ".join(h for _, h in IMG_COLS) + "\\\\"]
    for title, sets, _ in IMG_PANELS:
        L += ["\\midrule", f"\\multicolumn{{{nc}}}{{l}}{{\\emph{{{title}}}}}\\\\"]
        for i, ds in enumerate(sets):
            rows = J["images"].get(ds, {})
            keep = sorted((int(n), v) for n, v in rows.items() if int(n) >= 1000 and v.get("v3") is not None)
            if ds in ("qd_c", "qd_d"):
                keep = [(n, v) for n, v in keep if n in (1000, 10000, 60000)]
            V = img_verdicts(CL, ds)
            if i:
                L.append("\\addlinespace[2pt]")
            for n, v in keep:
                best = min([v[c] for c in IMG_BOLD if v.get(c) is not None], default=None)

                def cell(c):
                    if v.get(c) is None:
                        return "--"
                    s = f"{100 * v[c]:.2f}"
                    s = f"\\textbf{{{s}}}" if (c in IMG_BOLD and v[c] == best) else s
                    mk = {"tie": "$^{\\circ}$", "worse": "$^{\\ast}$"}.get(V.get((c, n)), "") if c != "v3" else ""
                    return s + (f"\\rlap{{{mk}}}" if mk else "")
                L.append(f"{IMG_NAME[ds]} & {n} & " + " & ".join(cell(c) for c, _ in IMG_COLS) + "\\\\")
    L += ["\\bottomrule", "\\end{tabular}"]
    open(os.path.join(OUT, "tab_images_cells.tex"), "w").write("\n".join(L) + "\n")


def tab_images_summary():
    """v3 against each image reference: cells (better / tie / worse) and mean log2(err / reference err), per panel."""
    REFS = [("mlp_strong", "\\code{mlp_strong}"), ("mlp_wide", "\\code{mlp_wide}"), ("mlp_xl", "\\code{mlp_xl}"),
            ("mlp_best", "\\code{mlp_best}"), ("mlp_best+", "\\code{mlp_best+}"), ("hgb", "\\code{hgb}"),
            ("hyb_portfolio2", "v2"), ("hyb_portfolio", "v1"), ("mlp_pool", "\\code{mlp_pool} (control)"),
            ("cnn", "\\code{cnn} (context)")]
    f = lambda x: ("--", "--") if not x else (f"{x['cells']} ({x['better']}/{x['tie']}/{x['worse']})", f"${x['mean']:+.3f}$")
    L = ["\\begin{tabular}{lcccc}", "\\toprule",
         " & \\multicolumn{2}{c}{all $n$} & \\multicolumn{2}{c}{$n\\ge10000$}\\\\",
         "\\cmidrule(lr){2-3}\\cmidrule(lr){4-5}",
         "reference & cells (better/tie/worse) & mean $\\log_2$ ratio & cells (better/tie/worse) & mean $\\log_2$ ratio\\\\"]
    for title, sets, lab in IMG_PANELS:
        R = J["real"].get(lab, {})
        L += ["\\midrule", "\\multicolumn{5}{l}{\\emph{" + title.split(":")[0] + ": " + ", ".join(IMG_NAME[d] for d in sets) + "}}\\\\"]
        for k, nm in REFS:
            a, b = R.get(f"{k}|all"), R.get(f"{k}|n >= 10000")
            if not a:
                continue
            L.append(f"{nm} & " + " & ".join(f(a)) + " & " + " & ".join(f(b)) + "\\\\")
    L += ["\\bottomrule", "\\end{tabular}"]
    open(os.path.join(OUT, "tab_images_summary.tex"), "w").write("\n".join(L) + "\n")


IMG_FAMILY = lambda m: ("cgbt" if m == "cgbt" else "ggbt" if m == "ggbt" else "gknn" if m.startswith("gknn") else
                        "knn" if m.startswith("knn") else "rest")       # rest: Part 8's gbt, et and lin


def _info(learner, ds):
    p = os.path.join(RES, f"{learner}__{ds}.info.json")
    return json.load(open(p)) if os.path.exists(p) else {}


def _res(learner, ds):
    p = os.path.join(RES, f"{learner}__{ds}.json")
    return json.load(open(p)) if os.path.exists(p) else None


def img_budget(n, d=784, C=10):
    """common.budget_real on the image sets: 3 x harness.mlp_flops (784-256-256-10 MLP, batch 128)."""
    P = d * 256 + 256 + 256 * 256 + 256 + 256 * C + C
    return 3 * 6.0 * P * 128 * int(min(10000, max(2000, math.ceil(50 * n / 128))))


def _fits(learner, ds, n):
    I = _info(learner, ds)
    return [v for k, v in sorted(I.items()) if k.startswith(f"n{n}_s") and v]


def tab_images_stack():
    """Held-out image fits: stacking weight per member family (seed mean) and out-of-fold errors, v3 and v2."""
    fw = lambda fit, fam: sum(w for m, w in fit.get("weights", {}).items() if IMG_FAMILY(m) == fam)
    mean = lambda xs: sum(xs) / len(xs) if xs else float("nan")
    L = ["\\begin{tabular}{lr" + "c" * 13 + "}", "\\toprule",
         " & & \\multicolumn{5}{c}{v3: stacking weight} & \\multicolumn{4}{c}{v2: stacking weight} & "
         "\\multicolumn{4}{c}{out-of-fold error (\\%)}\\\\",
         "\\cmidrule(lr){3-7}\\cmidrule(lr){8-11}\\cmidrule(lr){12-15}",
         "set & $n$ & \\code{cgbt} & \\code{ggbt} & \\code{gknn} & \\code{knn} & rest & \\code{ggbt} & \\code{gknn} & \\code{knn} & rest & "
         "\\code{cgbt} & \\code{ggbt} & v3 & v2\\\\", "\\midrule"]
    for ds in ("qd_c", "qd_d"):
        for n in (1000, 10000, 60000):
            A, B = _fits("hyb_portfolio3", ds, n), _fits("hyb_portfolio2", ds, n)
            if not A or not B:
                continue
            w3 = [f"{mean([fw(a, fam) for a in A]):.2f}" for fam in ("cgbt", "ggbt", "gknn", "knn", "rest")]
            w2 = [f"{mean([fw(b, fam) for b in B]):.2f}" for fam in ("ggbt", "gknn", "knn", "rest")]
            oo = [f"{100 * mean([a['member_oof_err'][m] for a in A]):.1f}" for m in ("cgbt", "ggbt")]
            st = [f"{100 * mean([x['stack_oof_err'] for x in X]):.1f}" for X in (A, B)]
            L.append(f"{IMG_NAME[ds]} & {n} & " + " & ".join(w3 + w2 + oo + st) + "\\\\")
    L += ["\\bottomrule", "\\end{tabular}"]
    open(os.path.join(OUT, "tab_images_stack.tex"), "w").write("\n".join(L) + "\n")


def tab_images_compute():
    """Held-out image cells: FLOPs / budget and process CPU s per fit for v3 and v2 (range over the seeds run), and the
    MLP references' wall s per fit (the cpu_seconds field of their result files) with their FLOPs / budget."""
    def rng(vals, fmt):
        vals = [v for v in vals if v is not None and math.isfinite(v)]
        if not vals:
            return "--"
        a, b = fmt(min(vals)), fmt(max(vals))
        return a if a == b else f"{a}--{b}"

    def seeds(r, key, n):
        if r is None or n not in r["ns"][:len(r.get(key, []))]:
            return []
        return [float(x) for x in r[key][r["ns"].index(n)]]

    L = ["\\begin{tabular}{lrccccccccc}", "\\toprule",
         " & & \\multicolumn{2}{c}{FLOPs / budget} & \\multicolumn{3}{c}{CPU s per fit} & "
         "\\multicolumn{4}{c}{MLP references: wall s per fit (FLOPs / budget)}\\\\",
         "\\cmidrule(lr){3-4}\\cmidrule(lr){5-7}\\cmidrule(lr){8-11}",
         "set & $n$ & v3 & v2 & v3 & \\hd{of which\\\\\\code{cgbt}} & v2 & \\code{mlp_strong} & \\code{mlp_wide} & \\code{mlp_xl} & \\code{mlp_pool}\\\\",
         "\\midrule"]
    for ds in ("qd_c", "qd_d"):
        for n in (1000, 10000, 60000):
            bud = img_budget(n)
            r3, r2 = _res("hyb_portfolio3", ds), _res("hyb_portfolio2", ds)
            if r3 is None or not seeds(r3, "err", n):
                continue
            row = [IMG_NAME[ds], str(n)]
            row += [rng([f / bud for f in seeds(r, "flops", n)], lambda v: f"{v:.2f}") for r in (r3, r2)]
            cg = [a["times"].get("cgbt") for a in _fits("hyb_portfolio3", ds, n)]
            row += [rng(seeds(r3, "cpu_seconds", n), lambda v: f"{v:.0f}"), rng(cg, lambda v: f"{v:.0f}"),
                    rng(seeds(r2, "cpu_seconds", n), lambda v: f"{v:.0f}")]
            for k in ("mlp_strong", "mlp_wide", "mlp_xl", "mlp_pool"):
                r = _res(k, ds); w = seeds(r, "cpu_seconds", n)
                ft = seeds(r, "flops_total", n) if r is not None and "flops_total" in r else []
                row.append("--" if not w else f"{rng(w, lambda v: f'{v:.0f}')} ({rng(ft, lambda v: f'{v / bud:.1f}')})")
            L.append(" & ".join(row) + "\\\\")
        L.append("\\addlinespace[2pt]")
    L[-1] = "\\bottomrule"; L.append("\\end{tabular}")
    open(os.path.join(OUT, "tab_images_compute.tex"), "w").write("\n".join(L) + "\n")


def tab_toy_v2v3():
    """Every toy target whose n* moved clearly between v2 and v3 (|log2 ratio| > 0.25, or only one learns it), all suites
    (results_toy.tex); v2 = hyb_portfolio2-perm (p9_sum-perm on designed / dlsymdev), v3 = p10_sum-perm."""
    L = ["\\begin{tabular}{llrrrr}", "\\toprule",
         "suite & target & v2 & v3 & $\\log_2(\\text{v3}/\\text{v2})$ & \\code{nets_best}\\\\", "\\midrule"]
    rows, last = [], None
    for su in ORDER:
        r = J["toy"].get(su)
        if not r:
            continue
        for t, v in r["per_target"].items():
            a, b = v.get("v3"), v.get("v2")
            if a is None or b is None:
                continue
            lr = math.log2(a / b) if (fin(a) and fin(b)) else (math.inf if fin(b) else (-math.inf if fin(a) else math.nan))
            if abs(lr) > 0.25:
                rows.append((ORDER.index(su), lr, su, t, v))
    for _, lr, su, t, v in sorted(rows):
        if last is not None and su != last:
            L.append("\\addlinespace")
        L.append(f"{code(su) if su != last else ''} & {t.replace('_', chr(92) + '_')} & {ns(v['v2'])} & {ns(v['v3'])} & "
                 f"{'$' + format(lr, '+.2f') + '$' if math.isfinite(lr) else ('v3 only' if lr < 0 else 'v2 only')} & {ns(v.get('nets_best'))}\\\\")
        last = su
    L += ["\\bottomrule", "\\end{tabular}"]
    open(os.path.join(OUT, "tab_toy_v2v3.tex"), "w").write("\n".join(L) + "\n")


if __name__ == "__main__":
    tab_toy_suites(); tab_dlheld7(); tab_real(); tab_images_summary(); tab_images_cells(); tab_toy_v2v3()
    tab_images_stack(); tab_images_compute()
    print(sorted(os.listdir(OUT)))
