"""LaTeX tables of the learner paper, generated from study/part10/LEARNER_RESULTS.json (compare_learner.py).
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


TOY_ROLE = {"designed": "dev", "random": "dev check", "dlheld": "held out (P6)", "dlheld2": "held out (P6)",
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
    L = ["\\begin{tabular}{llccc}", "\\toprule", "split & reference & cells (better / tie / worse) & mean $\\log_2$ ratio & datasets lower (sign test $p$)\\\\", "\\midrule"]
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


def tab_images_summary():
    REFS = [("mlp_strong", "\\code{mlp_strong}"), ("mlp_wide", "\\code{mlp_wide}"), ("mlp_xl", "\\code{mlp_xl}"), ("mlp_best", "\\code{mlp_best}"),
            ("mlp_best+", "\\code{mlp_best+}"), ("hgb", "\\code{hgb}"), ("hyb_portfolio2", "v2"), ("hyb_portfolio", "v1"),
            ("mlp_pool", "\\code{mlp_pool} (control)"), ("cnn", "\\code{cnn} (context)")]
    L = ["\\begin{tabular}{llccc}", "\\toprule", "sets & reference & $n$ & cells (better / tie / worse) & mean $\\log_2$ ratio\\\\", "\\midrule"]
    for lab, short in [("images, Part 10 held out (QuickDraw qd_c, qd_d)", "\\code{qd_c}, \\code{qd_d}"),
                       ("images, Part 9 held out (qd_a, qd_b; v3 at its seed-0 dev cells)", "\\code{qd_a}, \\code{qd_b}$^c$")]:
        R = J["real"].get(lab, {}); first = True
        for k, nm in REFS:
            for rng in ("all", "n <= 3000", "n >= 10000"):
                x = R.get(f"{k}|{rng}")
                if not x:
                    continue
                r_ = {"all": "all", "n <= 3000": "$\\le3000$", "n >= 10000": "$\\ge10000$"}[rng]
                L.append(f"{short if first else ''} & {nm if rng == 'all' or not R.get(f'{k}|all') else ''} & {r_} & {x['cells']} ({x['better']}/{x['tie']}/{x['worse']}) & ${x['mean']:+.3f}$\\\\")
                first = False
        L.append("\\midrule")
    L[-1] = "\\bottomrule"; L.append("\\end{tabular}")
    open(os.path.join(OUT, "tab_images_summary.tex"), "w").write("\n".join(L) + "\n")


def tab_images_cells():
    cols = [("v3", "v3"), ("hyb_portfolio2", "v2"), ("hyb_portfolio", "v1"), ("hgb", "\\code{hgb}"), ("mlp", "\\code{mlp}"),
            ("mlp_strong", "\\hd{\\code{mlp_}\\\\\\code{strong}}"), ("mlp_wide", "\\hd{\\code{mlp_}\\\\\\code{wide}}"), ("mlp_xl", "\\hd{\\code{mlp_}\\\\\\code{xl}}"),
            ("mlp_pool", "\\hd{\\code{mlp_}\\\\\\code{pool}}"), ("cnn", "\\code{cnn}")]
    L = ["\\begin{tabular}{lr" + "c" * len(cols) + "}", "\\toprule", "set & $n$ & " + " & ".join(h for _, h in cols) + "\\\\", "\\midrule"]
    for ds in ("qd_c", "qd_d", "qd_a", "qd_b", "qd_dev", "fashion_mnist"):
        rows = J["images"].get(ds, {})
        keep = [(int(n), v) for n, v in rows.items() if (v.get("v3") is not None or ds in ("qd_c", "qd_d")) and int(n) >= 1000]
        if ds in ("qd_c", "qd_d"):
            keep = [(n, v) for n, v in keep if n in (1000, 3000, 10000, 30000, 60000) and any(v.get(c) is not None for c, _ in cols[:3])]
        for n, v in sorted(keep):
            best = min([v[c] for c, _ in cols if v.get(c) is not None and c not in ("cnn", "mlp_pool")], default=None)
            cell = lambda c: "--" if v.get(c) is None else (f"\\textbf{{{v[c]:.4f}}}" if v[c] == best else f"{v[c]:.4f}")
            L.append(f"{code(ds)} & {n} & " + " & ".join(cell(c) for c, _ in cols) + "\\\\")
        L.append("\\midrule")
    L[-1] = "\\bottomrule"; L.append("\\end{tabular}")
    open(os.path.join(OUT, "tab_images_cells.tex"), "w").write("\n".join(L) + "\n")


if __name__ == "__main__":
    tab_toy_suites(); tab_dlheld7(); tab_real(); tab_images_summary(); tab_images_cells()
    print(sorted(os.listdir(OUT)))
