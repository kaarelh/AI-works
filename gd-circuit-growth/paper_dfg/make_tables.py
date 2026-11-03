"""LaTeX tables of the DFG paper (paper_dfg/).

Every number is read from study/part11/RESULTS.json (written by study/part11/compare_dfg.py from the result files;
regenerate that first) or, where a function says so, from the result files themselves.  No number is typed here.
usage: python3 make_tables.py            all tables
       python3 make_tables.py NAME ...   only these (function names below)

One function per table, registered with @table; each writes tables/<name>.tex.  Derived numbers that the text quotes
but no table shows are recorded with note(...) and written to tables/numbers.json under the function's name (the file is
merged, so running some functions keeps the other functions' entries).  To add a table: write a function, decorate it
with @table, use the helpers below (R = RESULTS.json; num, ns, rt, summ1, summ2, code, tg, desc, toy(), nstar, load_res).

Tables of sections/results.tex ("How well it does"):
  tab_dlheld7        dlheld7 per target: definition; n* of DFG alone, v3, lowdeg, lin, hgb, each network variant run there
                     and nets_best; log2 ratios of DFG alone to nets_best and to v3          (RESULTS.json q1_dlheld7)
  tab_dlheld7_summ   dlheld7: DFG alone against each reference; each reference against nets_best (q1_dlheld7)
  tab_suites         every toy suite: status for DFG v1.3, DFG alone against each reference (q2_suites)
  tab_pooled         pooled over the suites, and over Part 10's held-out set (q2_suites _pooled, _pooled_p10_heldout)
  tab_notwins        the targets where DFG alone is not clearly better than nets_best, and those it never learns (q2, q3)
  tab_v3             DFG alone against v3: per suite, by v3's n* (q2 dfg_vs_v3), and test errors by n (result files)
  tab_v3_targets     the targets on which DFG alone and v3 differ by more than 0.25 in log2 n* (q2 dfg_vs_v3)
  tab_lowdeg         lowdeg against DFG alone and nets_best, per suite and pooled (q3_lowdeg)
  tab_dscale         n* against d on the designed targets with networks at d != 30; exponents; per-d summary (q4_dscale)
  tab_tabular        kr_vs_kp and mushroom: test error per cell with verdicts, compute; summary per reference (q6_tabular)
  tab_compute        FLOPs and CPU seconds per fit, per run and by n (compute)

Tables of sections/learner.tex ("What DFG is"); every value is computed from the frozen DFG v1.3 itself
(study/part10/hyb_portfolio3/dfg13.py, md5 asserted), not from RESULTS.json:
  tab_dictionary     DFG's candidate classes at d = 30: size N, rows tested, log term of the threshold, smallest n that
                     can pass (checked against study/part11/interp/theory/check_theory.json)
  tab_params         the constructor defaults as run, and the constants fixed in the code (asserted at their lines)

Conventions.  n* = training-set size at 10% test error (seed mean, log-interpolated on 16..16384; 'never' if not
reached).  'A vs B' or a ratio = log2(n*_A / n*_B), negative when A needs less data; clearly better / worse = ratio
below -0.25 / above +0.25, or only one of the two reaches 10% error (compare_hybrid.toy_summary).  Summary cells are
'mean (clearly better / clearly worse)' with the number of targets both reach in brackets where shown; the mean is over
the targets both reach.
"""
import os, sys, json, math, re
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
STUDY = os.path.join(os.path.dirname(HERE), "study")
RJ = os.path.join(STUDY, "part11", "RESULTS.json")
R = json.load(open(RJ))
OUT = os.path.join(HERE, "tables"); os.makedirs(OUT, exist_ok=True)
INF = math.inf
THR = 0.25                                                      # clearly better / worse (compare_hybrid.toy_summary)
TOY = ["designed", "random", "dlheld", "dlheld2", "dlheld3", "dlsymdev", "dlheld4", "dlheld5", "dlheld6", "dlfamdev",
       "dlheld7"]                                               # Part 10's order (compare_dfg.TOY)
NETS = ["nets", "nets_wd", "nets_cewd", "nets_cewd0.3", "nets_cewd1.0"]   # compare_learner.NETS
TABLES, NUM = {}, {}


def table(fn):
    TABLES[fn.__name__] = fn
    return fn


def note(fn, **kv):
    """Record derived numbers quoted in the text under the table function's name (written to tables/numbers.json)."""
    NUM.setdefault(fn, {}).update(kv)


def write(name, lines):
    open(os.path.join(OUT, name + ".tex"), "w").write("\n".join(lines) + "\n")
    print("wrote", os.path.join("tables", name + ".tex"))


# ---- values and formatting ---------------------------------------------------------------------------------------------
def num(v):
    """A RESULTS.json value: None (not run, or n/a), inf / -inf (stored as 'inf' / '-inf'), or a float."""
    if v is None:
        return None
    if isinstance(v, str):
        return {"inf": INF, "-inf": -INF}[v]
    return float(v)


fin = lambda v: v is not None and math.isfinite(v)
code = lambda s: "\\code{" + s + "}"
tg = lambda t: t.replace("_", "\\_")                             # a target name in text


def ns(v):
    """n* for a table: '--' not run, 'never', or the rounded value."""
    v = num(v) if not isinstance(v, float) else v
    return "--" if v is None else ("never" if v == INF else f"{v:.0f}")


def rt(v, nan="n/a"):
    """A per-target log2 ratio: finite, or one-sided (only one reaches 10% error), or n/a (neither)."""
    v = num(v) if not isinstance(v, float) else v
    if v is None or (isinstance(v, float) and math.isnan(v)):
        return nan
    return "$+\\infty$" if v == INF else "$-\\infty$" if v == -INF else f"${v:+.2f}$"


def mean_s(m, p=2):
    m = num(m)
    return "n/a" if not fin(m) else f"${m:+.{p}f}$"


def summ1(s):
    """One-line summary cell: 'mean (better/worse)'; '--' if not run."""
    return "--" if not s else f"{mean_s(s['mean'])} ({s['better']}/{s['worse']})"


def top2(a, b):
    """A two-line table cell, top-aligned with its row: a above, b (scriptsize) below."""
    return "\\begin{tabular}[t]{@{}c@{}}" + a + "\\\\{\\scriptsize " + b + "}\\end{tabular}"


def summ2(s):
    """Two-line summary cell: mean on top, '(better/worse) [both reach]' below."""
    if not s:
        return "--"
    return f"\\begin{{tabular}}[t]{{@{{}}c@{{}}}}{mean_s(s['mean'])}\\\\{{\\scriptsize({s['better']}/{s['worse']}) [{s['both']}]}}\\end{{tabular}}"


def l2r(a, b):
    """compare_hybrid.l2r: log2(a / b); +inf if only b reaches 10% error, -inf if only a, nan if neither."""
    if fin(a) and fin(b):
        return math.log2(a / b)
    return INF if fin(b) else (-INF if fin(a) else math.nan)


def pstats(rs):
    """compare_dfg.pstats on a list of ratios (None = neither reaches, as nan)."""
    rs = [math.nan if v is None else v for v in rs]; f = [v for v in rs if math.isfinite(v)]
    srt = sorted(f)
    med = None if not f else (srt[len(f) // 2] if len(f) % 2 else 0.5 * (srt[len(f) // 2 - 1] + srt[len(f) // 2]))
    return dict(targets=len(rs), both=len(f), mean=sum(f) / len(f) if f else None, median=med,
                better=sum(1 for v in rs if v < -THR), worse=sum(1 for v in rs if v > THR),
                learner_never=sum(1 for v in rs if v == INF), ref_never=sum(1 for v in rs if v == -INF),
                neither=sum(1 for v in rs if isinstance(v, float) and math.isnan(v)))


def nstar(ns_, err, thr=0.1):
    """discrete_learner/harness.nstar: first grid point with seed-mean error <= thr, log-interpolated."""
    for i, e in enumerate(err):
        if e == e and e <= thr:
            if i == 0:
                return float(ns_[0])
            if err[i - 1] != err[i - 1]:
                return float(ns_[i])
            f = (err[i - 1] - thr) / max(err[i - 1] - e, 1e-12)
            return float(2 ** (math.log2(ns_[i - 1]) + f * (math.log2(ns_[i]) - math.log2(ns_[i - 1]))))
    return INF


def load_res(path):
    """A toy result file (relative to study/), or None."""
    p = os.path.join(STUDY, path)
    return json.load(open(p)) if os.path.exists(p) else None


def seed_mean(r, t):
    """Seed-mean test error per n of target t in a toy result file."""
    out = []
    for row in r["fns"][t]["err"]:
        v = [float(x) for x in row if x is not None and x == x]
        out.append(sum(v) / len(v) if v else math.nan)
    return out


# ---- the suites' status for DFG v1.3 (study/part11/PROTOCOL.md "Held out", as RESULTS.json q2_suites v13_status) --------
STATUS = {"development (v1.1, v1.2, v1.3)": "development", "development (v1.1)": "development",
          "held out for an earlier version only": "\\begin{tabular}[t]{@{}l@{}}held out for\\\\v1.1 only\\end{tabular}", "development (v1.2, v1.3)": "development",
          "exposed (v1.2 built after exposure)": "\\begin{tabular}[t]{@{}l@{}}exposed\\\\to v1.2\\end{tabular}", "development (v1.3)": "development",
          "**held out** (the only suite)": "\\textbf{held out}"}           # the labels of sections/protocol.tex, tab:status


def status(su):
    return STATUS[R["q2_suites"][su]["v13_status"]]


# ---- target definitions (study/boolfuncs.py) ------------------------------------------------------------------------------
SUITE_FN = {"designed": "make_suite", "random": "make_random_suite", "dlheld": "make_dl_heldout_suite",
            "dlheld2": "make_dl_heldout2_suite", "dlheld3": "make_dl_heldout3_suite", "dlsymdev": "make_dl_symdev_suite",
            "dlheld4": "make_dl_heldout4_suite", "dlheld5": "make_dl_heldout5_suite", "dlheld6": "make_dl_heldout6_suite",
            "dlfamdev": "make_dl_famdev_suite", "dlheld7": "make_dl_heldout7_suite"}
_DEFS = {}


def tex_desc(s):
    """A target's definition string from study/boolfuncs.py as LaTeX (paper_learner/make_tables.py): comparison and arrow
    signs as math, minus signs as math minus, a break point after each comma, '~' as negation."""
    s = s.replace("~", "\x00")
    s = re.sub(r"sum_\(i<=(\d+)\) s_i x_i", "\x01\\1\x01", s)
    s = s.replace("_", "\\_").replace("&", "\\&").replace("<=", "$\\le$").replace(">=", "$\\ge$").replace("->", "$\\to$")
    s = s.replace("{", "\\{").replace("}", "\\}").replace("|", "$|$")
    s = re.sub(r"(?<=[0-9a-z)])-(?=[0-9x(])", lambda m: "\\allowbreak{}-", s)
    s = re.sub(r"\+(?=x)", lambda m: "+\\allowbreak{}", s)
    s = re.sub(r"-(?=[0-9x(])", "$-$", s).replace(",", ",\\allowbreak{}")
    s = re.sub("\x01(\\d+)\x01", lambda m: "$\\sum_{i\\le" + m.group(1) + "}s_ix_i$", s)
    return s.replace("\x00", "$\\neg$")


def desc(su, t, short=True):
    """LaTeX definition of target t of suite su; random formulas shortened to their size ('random 6-gate formula ...')."""
    if su not in _DEFS:
        if STUDY not in sys.path:
            sys.path.insert(0, STUDY)
        import boolfuncs
        _DEFS[su] = getattr(boolfuncs, SUITE_FN[su])(30)
    d = _DEFS[su][t]["desc"]
    if short and d.startswith("random"):
        d = d.split(":")[0]
    return tex_desc(d)


# ---- every learner's n* on every toy suite --------------------------------------------------------------------------------
_TOY = {}


def toy():
    """{suite: {target: {learner: n*}}} at d = 30 for 'dfg' (DFG alone), v3, v2, lowdeg, lin, hgb, nets_best and every
    network variant run on the suite.  dfg, v3, v2, nets_best: RESULTS.json q2_suites (dfg, dfg_vs_v3); lowdeg: q3_lowdeg.
    lin, hgb and the variants are recovered from q2's per-target ratios against DFG alone (n*_ref = n*_dfg / 2^ratio;
    'never' when only DFG reaches 10% error; for the targets DFG never learns, from nets_best).  The recovery is checked
    against the explicit values (v3, v2, lowdeg, nets_best, and dlheld7's q1 table) and against the lin / hgb result
    files (study/hybrid/results/toy__{lin,hgb}__<suite>.json, harness.nstar)."""
    if _TOY:
        return _TOY
    Q2, Q3 = R["q2_suites"], R["q3_lowdeg"]
    for su in TOY:
        o = Q2[su]; T = {t: {"dfg": num(v)} for t, v in o["dfg"].items()}
        for x in Q2["dfg_vs_v3"]["per_target"]:
            if x["suite"] == su:
                T[x["target"]].update(v3=num(x["v3"]), v2=num(x["v2"]), nets_best=num(x["nets_best"]))
        for t, v in Q3[su]["lowdeg"].items():
            T[t]["lowdeg"] = num(v)
        for k in ["lin", "hgb"] + NETS + ["v3", "v2", "lowdeg", "nets_best"]:
            s = o["summary"].get(k)
            if not s:
                continue
            for t, r in s["ratios"].items():
                r, a = num(r), T[t]["dfg"]
                if r is None:
                    v = INF                                                  # neither reaches
                elif r == -INF:
                    v = INF
                elif math.isfinite(r):
                    v = a / 2 ** r
                elif T[t].get(k) is not None:                                # only the reference reaches: explicit value
                    v = T[t][k]
                else:                                                        # only this variant reaches: it is nets_best
                    assert k in NETS, (su, t, k)
                    others = [j for j in NETS if j != k and o["summary"].get(j) and num(o["summary"][j]["ratios"].get(t)) == INF]
                    assert not others, (su, t, k, others)
                    v = T[t].get("nets_best")
                    assert fin(v), (su, t, k)
                if k in T[t] and T[t][k] is not None:                       # explicit value: check the recovery
                    w = T[t][k]
                    assert (w == v == INF) or (fin(w) and fin(v) and abs(math.log2(w / v)) < 1e-9), (su, t, k, w, v)
                else:
                    T[t][k] = v
        _TOY[su] = T
    # checks against q1 (dlheld7) and the lin / hgb result files
    for t, v in R["q1_dlheld7"]["per_target"].items():
        for k, w in v.items():
            k2 = "dfg" if k == "dfg" else k
            a, b = num(w), _TOY["dlheld7"][t].get(k2)
            assert (a == b == INF) or (fin(a) and fin(b) and abs(math.log2(a / b)) < 1e-9), ("dlheld7", t, k, a, b)
    for su in TOY:
        for k in ("lin", "hgb"):
            r = load_res(os.path.join("hybrid", "results", f"toy__{k}__{su}.json"))
            if r is None:
                continue
            for t in r["fns"]:
                a, b = nstar(r["ns"], seed_mean(r, t)), _TOY[su][t][k]
                assert (a == b == INF) or (fin(a) and fin(b) and abs(math.log2(a / b)) < 1e-6), (su, t, k, a, b)
    return _TOY


def best_variant(su, t):
    """The network variant(s) attaining nets_best (exact equality of the recovered n*)."""
    T = toy()[su][t]; nb = T.get("nets_best")
    if not fin(nb):
        return []
    return [k for k in NETS if k in T and fin(T[k]) and abs(math.log2(T[k] / nb)) < 1e-9]


# =========================================================================================================================
# sections/results.tex, sec:res-dlheld7
# =========================================================================================================================
D7_COLS = [("dfg", "\\hd{DFG\\\\alone}"), ("v3", "v3"), ("lowdeg", code("lowdeg")), ("lin", code("lin")), ("hgb", code("hgb")),
           ("nets_wd", "\\hd{\\code{nets_}\\\\\\code{wd}}"), ("nets_cewd0.3", "\\hd{\\code{nets_}\\\\\\code{cewd0.3}}"),
           ("nets_cewd1.0", "\\hd{\\code{nets_}\\\\\\code{cewd1.0}}"), ("nets_best", "\\hd{\\code{nets_}\\\\\\code{best}}")]


@table
def tab_dlheld7():
    """dlheld7, one row per target: n* of each learner (bold: the smallest in the row) and the log2 ratios of DFG alone to
    nets_best and to v3 (tables/tab_dlheld7.tex); the targets' definitions from study/boolfuncs.py in a full-width block
    below it (tables/tab_dlheld7_defs.tex).  Source: RESULTS.json q1_dlheld7.per_target and .summary."""
    Q = R["q1_dlheld7"]
    vars_ = [k for k in NETS if k in Q["summary"]]
    cols = [c for c in D7_COLS if not c[0].startswith("nets_") or c[0] in vars_ + ["nets_best"]]
    nd, nc, nn = 3, 2, len([c for c in cols if c[0].startswith("nets")])
    L = [r"\begin{tabular*}{\linewidth}{@{\extracolsep{\fill}}l" + "r" * len(cols) + "rr@{}}", r"\toprule",
         rf" & \multicolumn{{{nd}}}{{c}}{{discrete, inputs permuted}} & \multicolumn{{{nc}}}{{c}}{{calibration}} & "
         rf"\multicolumn{{{nn}}}{{c}}{{networks}} & \multicolumn{{2}}{{c}}{{\hd{{$\log_2$ ratio of\\DFG alone to}}}}\\",
         rf"\cmidrule(lr){{2-{1 + nd}}}\cmidrule(lr){{{2 + nd}-{1 + nd + nc}}}\cmidrule(lr){{{2 + nd + nc}-{1 + len(cols)}}}"
         rf"\cmidrule(l){{{2 + len(cols)}-{3 + len(cols)}}}",
         "target & " + " & ".join(h for _, h in cols) + r" & \hd{\code{nets_}\\\code{best}} & v3\\", r"\midrule"]
    D = [r"\begin{tabularx}{\linewidth}{@{}l>{\raggedright\arraybackslash}X@{}}", r"\toprule", r"target & definition\\", r"\midrule"]
    for t, v in Q["per_target"].items():
        vals = {k: num(v.get(k)) for k, _ in cols}
        best = min((x for x in vals.values() if fin(x)), default=None)
        cell = lambda k: (r"\textbf{" + ns(vals[k]) + "}") if (best is not None and fin(vals[k]) and vals[k] <= best * (1 + 1e-12)) else ns(vals[k])
        r1 = num(Q["summary"]["nets_best"]["ratios"][t]); r2 = num(Q["summary"]["v3"]["ratios"][t])
        L.append(f"{tg(t)} & " + " & ".join(cell(k) for k, _ in cols) + f" & {rt(r1)} & {rt(r2)}" + r"\\")
        D.append(f"{tg(t)} & {desc('dlheld7', t, short=False)}" + r"\\")
    L += [r"\bottomrule", r"\end{tabular*}"]
    D += [r"\bottomrule", r"\end{tabularx}"]
    write("tab_dlheld7", L); write("tab_dlheld7_defs", D)
    # derived numbers for the text
    S = Q["summary"]["nets_best"]; rr = {t: num(x) for t, x in S["ratios"].items()}
    f = [x for x in rr.values() if fin(x)]; m = sum(f) / len(f)
    sd = math.sqrt(sum((x - m) ** 2 for x in f) / (len(f) - 1))
    T = toy()["dlheld7"]
    calib = sorted(t for t in T if any(l2r(T[t][k], T[t]["nets_best"]) < -THR for k in ("lin", "hgb")))
    rest = sorted(t for t in T if t not in calib)
    better_cal = {t: min(T[t]["lin"], T[t]["hgb"]) for t in T}
    note("tab_dlheld7", nets_best_mean=m, nets_best_median=num(S["median"]), nets_best_factor=2 ** -m, nets_best_sd=sd,
         nets_best_se=sd / math.sqrt(len(f)), nets_best_both=len(f), largest=sorted(((t, x) for t, x in rr.items() if fin(x)), key=lambda z: z[1])[:5],
         smallest=sorted(((t, x) for t, x in rr.items() if fin(x)), key=lambda z: -z[1])[:3],
         calibration_wins=calib,
         calibration_wins_ref={t: ("lin" if l2r(T[t]["lin"], T[t]["nets_best"]) < -THR else "hgb") for t in calib},
         calib_dfg_vs_nets_best=pstats(rr[t] for t in calib), calib_dfg_vs_nets_best_each={t: rr[t] for t in calib},
         calib_dfg_vs_better_calibration={t: l2r(T[t]["dfg"], better_cal[t]) for t in calib},
         calib_v3_vs_better_calibration={t: l2r(T[t]["v3"], better_cal[t]) for t in calib},
         calib_better_ref_vs_nets_best={t: l2r(better_cal[t], T[t]["nets_best"]) for t in calib},
         rest=rest, rest_dfg_vs_nets_best=pstats(rr[t] for t in rest),
         rest_clearly_better=[t for t in rest if rr[t] is not None and rr[t] < -THR],
         rest_clearly_better_mean=sum(rr[t] for t in rest if rr[t] is not None and rr[t] < -THR)
         / sum(1 for t in rest if rr[t] is not None and rr[t] < -THR),
         dfg_vs_v3_clearly_worse={t: num(x) for t, x in Q["summary"]["v3"]["ratios"].items() if fin(num(x)) and num(x) > THR},
         rest_hgb_range=[min(T[t]["hgb"] for t in rest if fin(T[t]["hgb"])), max(T[t]["hgb"] for t in rest if fin(T[t]["hgb"]))],
         rest_hgb_never=[t for t in rest if not fin(T[t]["hgb"])], rest_lin_learns=[t for t in rest if fin(T[t]["lin"])],
         dfg_vs_better_calibration_all=pstats(l2r(T[t]["dfg"], better_cal[t]) for t in T))


@table
def tab_dlheld7_summ():
    """dlheld7: DFG alone against each reference (left), and the reference against nets_best (right, context).
    Source: RESULTS.json q1_dlheld7.summary and .context."""
    Q = R["q1_dlheld7"]
    lab = {"v3": "v3", "v2": "v2", "lowdeg": code("lowdeg"), "lin": code("lin"), "hgb": code("hgb")}
    L = ["\\begin{tabular}{@{}lcccccccc@{}}", "\\toprule",
         " & \\multicolumn{6}{c}{DFG alone against the reference} & \\multicolumn{2}{c}{the reference against \\code{nets_best}}\\\\",
         "\\cmidrule(lr){2-7}\\cmidrule(l){8-9}",
         "reference & \\hd{both\\\\reach} & \\hd{mean $\\log_2$\\\\ratio} & median & \\hd{clearly\\\\better} & \\hd{clearly\\\\worse} & "
         "\\hd{only the reference\\\\/ only DFG reaches} & \\hd{mean (better/worse)\\\\{}[both reach]} & median\\\\", "\\midrule"]
    order = ["v3", "v2", "lowdeg", "lin", "hgb"] + [k for k in NETS if k in Q["summary"]] + ["nets_best"]
    for k in order:
        s = Q["summary"][k]; c = Q["context"].get(k)
        if k == "nets_wd":
            L.append("\\addlinespace[2pt]")
        ctx = "--" if not c else f"{mean_s(c['mean'])} ({c['better']}/{c['worse']}) [{c['both']}]"
        cm = "--" if not c else mean_s(c["median"])
        L.append(f"{lab.get(k, code(k))} & {s['both']} & {mean_s(s['mean'])} & {mean_s(s['median'])} & {s['better']} & {s['worse']} & "
                 f"{s['learner_never']} / {s['ref_never']} & {ctx} & {cm}\\\\")
    L += ["\\bottomrule", "\\end{tabular}"]
    write("tab_dlheld7_summ", L)
    note("tab_dlheld7_summ", targets=Q["summary"]["nets_best"]["targets"], seeds=Q["seeds"],
         factor_vs={k: 2 ** -num(Q["summary"][k]["mean"]) for k in order if fin(num(Q["summary"][k]["mean"]))},
         dfg_never=list(Q["dfg_never"]))


# =========================================================================================================================
# sec:res-suites
# =========================================================================================================================
@table
def tab_suites():
    """Every toy suite: status for DFG v1.3; DFG alone against nets_best, the range of its means against the single
    network variants run there, v3, v2, lin, hgb and lowdeg; targets DFG alone never learns.  Source: RESULTS.json
    q2_suites[<suite>].summary."""
    Q = R["q2_suites"]
    L = ["\\begin{tabular}{@{}llccccccccc@{}}", "\\toprule",
         "suite & status for v1.3 & targets & \\hd{DFG\\\\never} & \\code{nets_best} & \\hd{single variants:\\\\min / max mean} & "
         "v3 & v2 & \\code{lin} & \\code{hgb} & \\code{lowdeg}\\\\", "\\midrule"]
    rng_all = {}
    for su in TOY:
        o = Q[su]; S = o["summary"]
        mm = [(num(S[k]["mean"]), k) for k in NETS if S.get(k) and fin(num(S[k]["mean"]))]
        if mm:
            lo, hi = min(mm), max(mm); rng_all[su] = dict(min=lo, max=hi, variants=[k for _, k in mm])
            rng = f"\\begin{{tabular}}[t]{{@{{}}c@{{}}}}${lo[0]:+.2f}$ / ${hi[0]:+.2f}$\\\\{{\\scriptsize({len(mm)} variants)}}\\end{{tabular}}"
        else:
            rng = "--"
        L.append(f"{code(su)} & {status(su)} & {o['targets']} & {o['dfg_never']} & {summ2(S.get('nets_best'))} & {rng} & "
                 + " & ".join(summ2(S.get(k)) for k in ("v3", "v2", "lin", "hgb", "lowdeg")) + "\\\\")
        if su != TOY[-1]:
            L.append("\\addlinespace[1pt]")
    L += ["\\bottomrule", "\\end{tabular}"]
    write("tab_suites", L)
    nb = {su: num(Q[su]["summary"]["nets_best"]["mean"]) for su in TOY if Q[su]["summary"].get("nets_best")}
    wd = {su: num(Q[su]["summary"]["nets_wd"]["mean"]) for su in TOY if Q[su]["summary"].get("nets_wd")}
    note("tab_suites", nets_best_mean_range=[min(nb.values()), max(nb.values())], nets_best_mean=nb,
         nets_wd_mean=wd, nets_wd_mean_range=[min(wd.values()), max(wd.values())], variant_range=rng_all,
         suites_with_networks=[su for su in TOY if Q[su]["network_variants"]],
         variants=dict((su, Q[su]["network_variants"]) for su in TOY))


POOL_LAB = {"nets_best": code("nets_best"), "nets": code("nets"), "nets_wd": code("nets_wd"), "nets_cewd": code("nets_cewd"),
            "nets_cewd0.3": code("nets_cewd0.3"), "nets_cewd1.0": code("nets_cewd1.0"), "v3": "v3", "v2": "v2",
            "lin": code("lin"), "hgb": code("hgb"), "lowdeg": code("lowdeg")}


def prow(lab, s):
    return (f"{lab} & {len(s['suites'])} & {s['targets']} & {s['both']} & {mean_s(s['mean'])} & {mean_s(s['median'])} & "
            f"{s['better']} & {s['worse']} & {s['learner_never']} & {s['ref_never']} & {s['neither']}\\\\")


@table
def tab_pooled():
    """DFG alone against each reference with the per-target ratios pooled over the suites where both ran; and DFG alone
    and v3 against nets_best on Part 10's pooled held-out set.  Source: RESULTS.json q2_suites._pooled, _pooled_p10_heldout."""
    P = R["q2_suites"]["_pooled"]; H = R["q2_suites"]["_pooled_p10_heldout"]
    L = ["\\begin{tabular}{@{}lcccccccccc@{}}", "\\toprule",
         "reference & suites & targets & \\hd{both\\\\reach} & \\hd{mean $\\log_2$\\\\ratio} & median & \\hd{clearly\\\\better} & "
         "\\hd{clearly\\\\worse} & \\hd{only the\\\\reference} & \\hd{only\\\\DFG} & neither\\\\", "\\midrule",
         "\\multicolumn{11}{@{}l}{\\emph{DFG alone against}}\\\\"]
    for k in ["nets_best"] + NETS + ["v3", "v2", "lin", "hgb", "lowdeg"]:
        if k in P:
            if k in ("nets", "v3"):
                L.append("\\addlinespace[2pt]")
            L.append(prow(POOL_LAB[k], P[k]))
    L += ["\\midrule", f"\\multicolumn{{11}}{{@{{}}l}}{{\\emph{{against \\code{{nets_best}} on Part 10's held-out suites "
          f"(\\code{{{H['dfg_vs_nets_best']['suites'][0]}}}--\\code{{{H['dfg_vs_nets_best']['suites'][-1]}}})}}}}\\\\",
          prow("DFG alone", H["dfg_vs_nets_best"]), prow("v3", H["v3_vs_nets_best"]), "\\bottomrule", "\\end{tabular}"]
    write("tab_pooled", L)
    s = P["nets_best"]
    note("tab_pooled", nets_best=dict(mean=num(s["mean"]), median=num(s["median"]), factor=2 ** -num(s["mean"]),
                                      better=s["better"], worse=s["worse"], both=s["both"], targets=s["targets"]),
         nets_wd_factor=2 ** -num(P["nets_wd"]["mean"]), nets_factor=2 ** -num(P["nets"]["mean"]),
         v3_factor=2 ** num(P["v3"]["mean"]), lowdeg_factor=2 ** -num(P["lowdeg"]["mean"]))


@table
def tab_notwins():
    """Every target on which DFG alone is not clearly better than nets_best (clearly worse, tie, or no learner reaches 10%
    error), and every target DFG alone never learns.  Values from toy() (RESULTS.json q2_suites, q3_lowdeg)."""
    Q = R["q2_suites"]; T = toy()
    groups = {"worse": [], "tie": [], "neither": [], "no networks": []}
    for su in TOY:
        for t, v in T[su].items():
            nb = v.get("nets_best")
            if nb is None:
                if not fin(v["dfg"]):
                    groups["no networks"].append((su, t))
                continue
            r = l2r(v["dfg"], nb)
            if isinstance(r, float) and math.isnan(r):
                groups["neither"].append((su, t))
            elif r > THR:
                groups["worse"].append((su, t))
            elif r >= -THR:
                groups["tie"].append((su, t))
    head = {"worse": "DFG alone clearly worse", "tie": "ties ($|\\log_2\\text{ratio}|\\le0.25$)",
            "neither": "no learner reaches 10\\% error", "no networks": "DFG alone never learns it; no network runs"}
    L = ["\\begin{tabularx}{\\linewidth}{@{}ll>{\\raggedright\\arraybackslash}Xrlrrrrr@{}}", "\\toprule",
         "suite & target & definition & \\hd{DFG\\\\alone} & \\code{nets_best} (variant) & \\hd{$\\log_2$\\\\ratio} & v3 & "
         "\\code{lowdeg} & \\code{lin} & \\code{hgb}\\\\"]
    vlab = {"nets": "nets", "nets_wd": "wd", "nets_cewd": "cewd", "nets_cewd0.3": "cewd0.3", "nets_cewd1.0": "cewd1.0"}
    for g in ("worse", "tie", "neither", "no networks"):
        if not groups[g]:
            continue
        L += ["\\midrule", f"\\multicolumn{{10}}{{@{{}}l}}{{\\emph{{{head[g]}}}}}\\\\"]
        def key(z):                                                  # largest ratio first ('never' = +inf first)
            r = l2r(T[z[0]][z[1]]["dfg"], T[z[0]][z[1]].get("nets_best"))
            return 0.0 if math.isnan(r) else -r
        rows = sorted(groups[g], key=key)
        for su, t in rows:
            v = T[su][t]; bv = best_variant(su, t)
            nb = "--" if v.get("nets_best") is None else ns(v["nets_best"]) + (f" ({', '.join(vlab[k] for k in bv)})" if bv else "")
            r = rt(l2r(v["dfg"], v["nets_best"])) if v.get("nets_best") is not None else "--"
            L.append(f"{code(su)} & {tg(t)} & {{\\scriptsize {desc(su, t)}}} & {ns(v['dfg'])} & {nb} & {r} & {ns(v.get('v3'))} & "
                     f"{ns(v.get('lowdeg'))} & {ns(v.get('lin'))} & {ns(v.get('hgb'))}\\\\")
    L += ["\\bottomrule", "\\end{tabularx}"]
    write("tab_notwins", L)
    never = [(x["suite"], x["target"]) for x in Q["dfg_never"]]
    note("tab_notwins", groups={g: [f"{su}/{t}" for su, t in v] for g, v in groups.items()},
         n_with_networks=Q["_pooled"]["nets_best"]["targets"], dfg_never=[f"{su}/{t}" for su, t in never],
         dfg_never_count=len(never), targets_total=sum(Q[su]["targets"] for su in TOY))


# =========================================================================================================================
# sec:res-v3
# =========================================================================================================================
@table
def tab_v3():
    """DFG alone against v3: (a) per suite and (b) by v3's n* (RESULTS.json q2_suites.dfg_vs_v3, dfg_vs_v3_by_v3_nstar);
    (c) by n, from the result files: per (target, n) the seed-mean test errors of DFG alone
    (study/part11/results/toy__dfg13-perm__<suite>.json) and v3 (study/hybrid/results/toy__p10_sum-perm__<suite>.json),
    on the same seeds and training sets."""
    Q = R["q2_suites"]; X = Q["dfg_vs_v3"]["per_target"]
    L = ["\\begin{tabular}{@{}lcccc@{}}", "\\toprule",
         "\\multicolumn{5}{@{}l}{\\emph{(a) per suite}}\\\\",
         "suite & targets & \\hd{DFG alone lower / higher\\\\(identical)} & \\hd{clearly lower / higher\\\\($|\\log_2$ ratio$|>0.25$)} & "
         "\\hd{mean $\\log_2$ ratio\\\\(both reach)}\\\\", "\\midrule"]
    for su in TOY:
        Y = [x for x in X if x["suite"] == su]
        if not Y:
            continue
        p = pstats(num(x["ratio"]) if num(x["ratio"]) is not None else math.nan for x in Y)
        lo = sum(1 for x in Y if num(x["ratio"]) is not None and num(x["ratio"]) < 0)
        hi = sum(1 for x in Y if num(x["ratio"]) is not None and num(x["ratio"]) > 0)
        L.append(f"{code(su)} & {len(Y)} & {lo} / {hi} ({sum(x['identical'] for x in Y)}) & {p['better']} / {p['worse']} & {mean_s(p['mean'])}\\\\")
    S = Q["dfg_vs_v3"]; st = S["stats"]
    L += ["\\midrule", f"all & {S['targets']} & {S['lower']} / {S['higher']} ({S['identical']}) & {st['better']} / {st['worse']} & "
          f"{mean_s(st['mean'])}\\\\"]
    L += ["\\midrule", "\\multicolumn{5}{@{}l}{\\emph{(b) by v3's $\\nstar$}}\\\\",
          "v3's $\\nstar$ & targets & \\hd{DFG alone lower / higher} & \\hd{clearly lower / higher} & \\hd{mean (median)}\\\\", "\\midrule"]
    B = Q["dfg_vs_v3_by_v3_nstar"]
    blab = {"<= 64": "$\\le64$", "64 - 256": "64--256", "256 - 1024": "256--1024", "> 1024": "$>1024$", "never": "never"}
    for b, q in B.items():
        Y = [x for x in X if _bin(num(x["v3"])) == b]
        lo = sum(1 for x in Y if num(x["ratio"]) is not None and num(x["ratio"]) < 0)
        hi = sum(1 for x in Y if num(x["ratio"]) is not None and num(x["ratio"]) > 0)
        mm = "--" if not fin(num(q["mean"])) else f"{mean_s(q['mean'])} ({mean_s(q['median'])})"
        L.append(f"{blab[b]} & {q['targets']} & {lo} / {hi} & {q['better']} / {q['worse']} & {mm}\\\\")
    L += ["\\bottomrule", "\\end{tabular}"]
    write("tab_v3", L)
    # (c) test errors by n, from the result files
    by = defaultdict(lambda: dict(cells=0, v3_lower=0, dfg_lower=0, diff=[]))
    seeds = {}
    for su in TOY:
        a = load_res(os.path.join("part11", "results", f"toy__dfg13-perm__{su}.json"))
        b = load_res(os.path.join("hybrid", "results", f"toy__p10_sum-perm__{su}.json"))
        assert a["seeds"] == b["seeds"] and a["ns"] == b["ns"], su
        seeds[su] = a["seeds"]
        for t in a["fns"]:
            ea, eb = seed_mean(a, t), seed_mean(b, t)
            for i, n in enumerate(a["ns"]):
                g = by[n]; g["cells"] += 1; g["diff"].append(ea[i] - eb[i])
                g["v3_lower"] += eb[i] < ea[i] - 0.02; g["dfg_lower"] += ea[i] < eb[i] - 0.02
    NS_ = sorted(by)
    # inside v3: Part 10's seed-0 analysis refits of v3 (study/part10/interp/toy_structure.py: err = v3's cell, err_dfg = v3's
    # own final DFG member alone, or its last out-of-fold DFG fit where the stacker gave DFG no weight; w_dfg = the DFG
    # members' share of the stack weight; each target's grid stops after two consecutive n with err <= 0.005)
    import glob
    in3 = defaultdict(lambda: dict(cells=0, stack_lower=0, member_lower=0, zero=0, w=[]))
    P10 = sorted(glob.glob(os.path.join(STUDY, "part10", "interp", "results", "toy_final", "v3", "*__s0.json")))
    cells10 = {}
    for f in P10:
        r = json.load(open(f))
        for c in r["cells"]:
            g = in3[c["n"]]; g["cells"] += 1; g["w"].append(c["w_dfg"])
            g["stack_lower"] += c["err"] < c["err_dfg"] - 0.02; g["member_lower"] += c["err_dfg"] < c["err"] - 0.02
            g["zero"] += c["w_dfg"] == 0
            cells10[(r["suite"], r["target"], c["n"])] = dict(err=c["err"], err_dfg=c["err_dfg"], w_dfg=c["w_dfg"],
                                                              final=c.get("dfg_source") == "final")
    med = lambda v: sorted(v)[len(v) // 2] if len(v) % 2 else 0.5 * (sorted(v)[len(v) // 2 - 1] + sorted(v)[len(v) // 2])
    c1 = 1 + len(NS_)
    L = ["\\begin{tabular}{@{}l" + "r" * len(NS_) + "@{}}", "\\toprule", "$n$ & " + " & ".join(str(n) for n in NS_) + "\\\\", "\\midrule",
         f"\\multicolumn{{{c1}}}{{@{{}}l}}{{\\emph{{(a) DFG alone against v3: the result files, every seed, {by[NS_[0]]['cells']} targets}}}}\\\\",
         "v3 lower by $>0.02$ & " + " & ".join(str(by[n]["v3_lower"]) for n in NS_) + "\\\\",
         "DFG alone lower by $>0.02$ & " + " & ".join(str(by[n]["dfg_lower"]) for n in NS_) + "\\\\",
         "mean difference (points) & " + " & ".join(f"${100 * sum(by[n]['diff']) / len(by[n]['diff']):+.1f}$" for n in NS_) + "\\\\",
         "\\midrule",
         f"\\multicolumn{{{c1}}}{{@{{}}l}}{{\\emph{{(b) inside v3: Part 10's analysis fits of v3, seed 0}}}}\\\\",
         "fits analysed & " + " & ".join(str(in3[n]["cells"]) for n in NS_) + "\\\\",
         "v3 lower than DFG member & " + " & ".join(str(in3[n]["stack_lower"]) for n in NS_) + "\\\\",
         "DFG member lower than v3 & " + " & ".join(str(in3[n]["member_lower"]) for n in NS_) + "\\\\",
         "DFG members' weight 0 & " + " & ".join(str(in3[n]["zero"]) for n in NS_) + "\\\\",
         "median DFG weight share & " + " & ".join(f"{med(in3[n]['w']):.2f}" for n in NS_) + "\\\\",
         "\\bottomrule", "\\end{tabular}"]
    write("tab_v3_byn", L)
    big = [x for x in X if num(x["ratio"]) is not None and abs(num(x["ratio"])) > THR]
    pos = [x for x in big if num(x["ratio"]) > 0]
    T = toy()
    cal = lambda x: min(T[x["suite"]][x["target"]].get("lin", INF) or INF, T[x["suite"]][x["target"]].get("hgb", INF) or INF)
    hgb_run = [x for x in pos if T[x["suite"]][x["target"]].get("hgb") is not None]
    note("tab_v3", stats=st, identical=S["identical"], lower=S["lower"], higher=S["higher"], sign_test_p=S["sign_test_p"],
         factor_mean=2 ** num(st["mean"]), clearly_higher=len(pos), clearly_lower=len(big) - len(pos),
         clearly_higher_v3_le64=sum(1 for x in pos if num(x["v3"]) <= 64),
         clearly_higher_v3_le128=sum(1 for x in pos if num(x["v3"]) <= 128),
         clearly_higher_hgb_run=len(hgb_run),
         clearly_higher_hgb_le_dfg=sum(1 for x in hgb_run if fin(T[x["suite"]][x["target"]]["hgb"])
                                       and T[x["suite"]][x["target"]]["hgb"] <= num(x["dfg"])),
         clearly_higher_calib_le_dfg=sum(1 for x in pos if cal(x) <= num(x["dfg"])),
         clearly_lower_list=[(x["suite"], x["target"], num(x["dfg"]), num(x["v3"]), num(x["ratio"])) for x in big if num(x["ratio"]) < 0],
         by_n={n: dict(cells=by[n]["cells"], v3_lower=by[n]["v3_lower"], dfg_lower=by[n]["dfg_lower"],
                       mean_diff=sum(by[n]["diff"]) / len(by[n]["diff"])) for n in NS_},
         by_n_seeds=seeds,
         inside_v3_by_n={n: dict(cells=in3[n]["cells"], stack_lower=in3[n]["stack_lower"], member_lower=in3[n]["member_lower"],
                                 zero=in3[n]["zero"], median_share=med(in3[n]["w"])) for n in NS_ if in3[n]["cells"]},
         inside_v3_files=len(P10),
         inside_v3_clearly_lower_targets={f"{x['suite']}/{x['target']}": {n: cells10.get((x["suite"], x["target"], n))
                                                                         for n in (16, 32, 64, 128, 256, 512)}
                                          for x in big if num(x["ratio"]) < 0},
         alone_err_clearly_lower_targets={f"{x['suite']}/{x['target']}": _errs(x["suite"], x["target"]) for x in big if num(x["ratio"]) < 0},
         degree5_rows=_deg5_rows())


def _deg5_rows():
    """Rows the frozen DFG v1.3 gives its degree-5 search at d = 30 (dfg13.py: m = budget_hi * GD * share /
    (2 N1 N2 + m_tab_cost), skipped if m < 64), for v3's DFG fits (part10/hyb_portfolio3/learner.py: the out-of-fold fits share
    dfg_share[0] = 0.35 of the budget over the folds and the variants; 10 folds at n <= K_small_n = 500, else 5; both variants
    at n <= 512; the final fits share dfg_share[1] = 0.5 over the variants kept) and for DFG alone (final fit: half the
    budget at n <= 512)."""
    src = open(os.path.join(STUDY, "part10", "hyb_portfolio3", "learner.py")).read()
    assert "K=5, K_small=10, K_small_n=500" in src and "dfg_share=(0.35, 0.5)" in src
    for p in (os.path.join(STUDY, "discrete_learner"), os.path.join(STUDY, "part11")):
        if p not in sys.path:
            sys.path.insert(0, p)
    import eval_dfg                                              # loads part10/hyb_portfolio3/dfg13.py, md5 asserted
    from harness import gd_flops
    M = eval_dfg.load_dfg13(); D = M.DFG(); d = 30; k = 5; k1, k2 = (k + 1) // 2, k // 2
    rows = lambda share: int(D.budget_hi * gd_flops(d) * share / (2 * math.comb(d, k1) * math.comb(d, k2) + M.m_tab_cost(d, k1, k2)))
    return dict(v3_oof_n_le_500=rows(0.35 / 10 / 2), v3_oof_n_501_512=rows(0.35 / 5 / 2), v3_final_both_kept=rows(0.5 / 2),
                v3_final_one_kept=rows(0.5), alone_final_n_le_512=rows(0.5), alone_n_gt_512=rows(1.0), minimum=64,
                shares=dict(v3_oof_n_le_500=0.35 / 10 / 2, v3_oof_n_501_512=0.35 / 5 / 2))


def _errs(su, t):
    """Seed-mean test errors of DFG alone and of v3 at n <= 512 (the result files)."""
    a = load_res(os.path.join("part11", "results", f"toy__dfg13-perm__{su}.json"))
    b = load_res(os.path.join("hybrid", "results", f"toy__p10_sum-perm__{su}.json"))
    ea, eb = seed_mean(a, t), seed_mean(b, t)
    return {n: dict(dfg=ea[i], v3=eb[i]) for i, n in enumerate(a["ns"]) if n <= 512}


def _bin(v):
    """compare_dfg.nbin: n* range for the breakdown by v3's n*."""
    return "never" if not fin(v) else "<= 64" if v <= 64 else "64 - 256" if v <= 256 else "256 - 1024" if v <= 1024 else "> 1024"


@table
def tab_v3_targets():
    """The targets on which DFG alone and v3 differ by more than 0.25 in log2 n*, sorted by the ratio, in two side-by-side
    halves; with hgb's and lin's n* (natural column order) where run.  Source: RESULTS.json q2_suites.dfg_vs_v3 and toy()."""
    X = [x for x in R["q2_suites"]["dfg_vs_v3"]["per_target"] if num(x["ratio"]) is not None and abs(num(x["ratio"])) > THR]
    X.sort(key=lambda x: -num(x["ratio"])); T = toy()
    half = (len(X) + 1) // 2
    row = lambda x: (f"{code(x['suite'])} & {tg(x['target'])} & {ns(num(x['dfg']))} & {ns(num(x['v3']))} & {rt(num(x['ratio']))} & "
                     f"{ns(T[x['suite']][x['target']].get('hgb'))} & {ns(T[x['suite']][x['target']].get('lin'))}")
    h = "suite & target & \\hd{DFG\\\\alone} & v3 & \\hd{$\\log_2$\\\\ratio} & \\code{hgb} & \\code{lin}"
    L = ["\\begin{tabular}{@{}llrrrrr@{\\hspace{14pt}}llrrrrr@{}}", "\\toprule", h + " & " + h + "\\\\", "\\midrule"]
    for i in range(half):
        a = row(X[i]); b = row(X[i + half]) if i + half < len(X) else " & & & & & & "
        L.append(a + " & " + b + "\\\\")
    L += ["\\bottomrule", "\\end{tabular}"]
    write("tab_v3_targets", L)
    note("tab_v3_targets", count=len(X), top=[(x["suite"], x["target"], num(x["ratio"])) for x in X[:8]],
         bottom=[(x["suite"], x["target"], num(x["ratio"])) for x in X[-6:]])


# =========================================================================================================================
# sec:res-lowdeg
# =========================================================================================================================
@table
def tab_lowdeg():
    """lowdeg against DFG alone and against nets_best, per suite and pooled; the targets lowdeg never learns.
    Source: RESULTS.json q3_lowdeg."""
    Q = R["q3_lowdeg"]; T = toy()
    L = ["\\begin{tabularx}{\\linewidth}{@{}lcccc>{\\raggedright\\arraybackslash}X@{}}", "\\toprule",
         "suite & targets & \\hd{\\code{lowdeg} vs\\\\DFG alone} & \\hd{\\code{lowdeg} vs\\\\\\code{nets_best}} & "
         "\\hd{\\code{lowdeg}\\\\never} & targets \\code{lowdeg} never learns (DFG alone's $\\nstar$)\\\\", "\\midrule"]
    never = []
    for su in TOY:
        o = Q[su]; lv = o["lowdeg"]
        nv = [t for t, v in lv.items() if not fin(num(v))]
        never += [(su, t) for t in nv]
        names = ", ".join(f"{tg(t)} ({ns(T[su][t]['dfg'])})" for t in nv) or "--"
        L.append(f"{code(su)} & {len(lv)} & {summ2(o['vs_dfg'])} & {summ2(o['vs_nets_best'])} & {len(nv)} & {{\\footnotesize {names}}}\\\\")
    P = Q["_pooled"]
    L += ["\\midrule", f"pooled & {P['vs_dfg']['targets']} & {summ2(P['vs_dfg'])} & {summ2(P['vs_nets_best'])} & {len(never)} & \\\\",
          "\\bottomrule", "\\end{tabularx}"]
    write("tab_lowdeg", L)
    a, b = P["vs_dfg"], P["vs_nets_best"]
    # where lowdeg is clearly better than DFG alone
    lower = sorted(((su, t, T[su][t]["lowdeg"], T[su][t]["dfg"]) for su in TOY for t in T[su]
                    if l2r(T[su][t]["lowdeg"], T[su][t]["dfg"]) < -THR), key=lambda z: l2r(z[2], z[3]))
    note("tab_lowdeg", vs_dfg=dict(mean=num(a["mean"]), median=num(a["median"]), factor=2 ** num(a["mean"]), better=a["better"],
                                   worse=a["worse"], both=a["both"], targets=a["targets"], lowdeg_never=a["learner_never"], neither=a["neither"]),
         vs_nets_best=dict(mean=num(b["mean"]), median=num(b["median"]), better=b["better"], worse=b["worse"], both=b["both"],
                           targets=b["targets"], lowdeg_never=b["learner_never"], neither=b["neither"]),
         bands=P["bands"], never=[f"{su}/{t}" for su, t in never],
         never_dfg_reaches=[f"{su}/{t}" for su, t in never if fin(T[su][t]["dfg"])],
         lowdeg_clearly_lower=[(su, t, lo, d) for su, t, lo, d in lower],
         lowdeg_clearly_lower_count=len(lower))


# =========================================================================================================================
# sec:res-dscale
# =========================================================================================================================
@table
def tab_dscale():
    """n* of DFG v1.3 alone and of the networks (nets, square loss: the variant run at every d) on the designed targets
    the networks were trained on at d = 15, 60, 120; least-squares exponents of log n* on log d over the d where both
    reach 10% error; per-d summary.  Source: RESULTS.json q4_dscale (and status for the seeds)."""
    Q = R["q4_dscale"]; D = ["15", "30", "60", "120"]
    L = ["\\begin{tabular}{@{}lccccccccc@{}}", "\\toprule",
         " & \\multicolumn{4}{c}{DFG v1.3 alone: $\\nstar$ at $d=$} & \\multicolumn{4}{c}{networks (\\code{nets}): $\\nstar$ at $d=$} & "
         "\\multicolumn{1}{c}{} \\\\", "\\cmidrule(lr){2-5}\\cmidrule(lr){6-9}",
         "target & " + " & ".join(D) + " & " + " & ".join(D) + " & \\hd{exponent\\\\DFG / networks}\\\\", "\\midrule"]
    for t in Q["targets"]:
        p = Q["per_target"][t]
        ex = f"{p['exponent_dfg13']:.2f} / {p['exponent_nets']:.2f}"
        if len(p["common_d"]) < 4:
            ex += "$^\\ast$"
        L.append(f"{t} & " + " & ".join(ns(p["dfg13"].get(d)) for d in D) + " & " + " & ".join(ns(p["nets"].get(d)) for d in D) + f" & {ex}\\\\")
    L += ["\\midrule", " & \\multicolumn{4}{c}{\\hd{DFG v1.3 against the networks:\\\\median $\\log_2$ ratio (factor)}} & "
          "\\multicolumn{2}{c}{\\hd{DFG v1.3 against\\\\Part 6's DFG: median}} & \\multicolumn{2}{c}{\\hd{max FLOPs per fit /\\\\one network run}} & "
          "\\hd{seeds\\\\(DFG; nets)}\\\\", "\\midrule"]
    seeds = {st["suite"]: st["seeds"] for st in R["status"] if st["run"] == "dfg13-perm"}
    for d in D:
        q = Q["per_d"][d]; a = q["dfg_vs_nets"]; c = q["dfg_vs_part6"]
        sd = seeds["designed" if d == "30" else f"designed_d{d}"]
        L.append(f"$d={d}$ ({a['targets']} targets) & \\multicolumn{{4}}{{c}}{{{mean_s(a['median'])} ({2 ** -num(a['median']):.1f}$\\times$)}} & "
                 f"\\multicolumn{{2}}{{c}}{{{mean_s(c['median'])}}} & \\multicolumn{{2}}{{c}}{{{num(q['max_flops_frac']):.2f}}} & "
                 f"{len(sd)}; {len(q['nets_seeds'])}\\\\")
    L += ["\\bottomrule", "\\end{tabular}"]
    write("tab_dscale", L)
    E = {t: (Q["per_target"][t]["exponent_dfg13"], Q["per_target"][t]["exponent_nets"]) for t in Q["targets"]}
    note("tab_dscale", exponents=E, dfg_exp_range=[min(e[0] for e in E.values()), max(e[0] for e in E.values())],
         nets_exp_range=[min(e[1] for e in E.values()), max(e[1] for e in E.values())],
         per_d={d: dict(median=num(Q["per_d"][d]["dfg_vs_nets"]["median"]), factor=2 ** -num(Q["per_d"][d]["dfg_vs_nets"]["median"]),
                        mean=num(Q["per_d"][d]["dfg_vs_nets"]["mean"]), targets=Q["per_d"][d]["dfg_vs_nets"]["targets"],
                        dfg_vs_part6_median=num(Q["per_d"][d]["dfg_vs_part6"]["median"]),
                        dfg_vs_part6_mean=num(Q["per_d"][d]["dfg_vs_part6"]["mean"]),
                        dfg_vs_part6_better=Q["per_d"][d]["dfg_vs_part6"]["better"],
                        max_flops=num(Q["per_d"][d]["max_flops_frac"]), nets_seeds=Q["per_d"][d]["nets_seeds"]) for d in D},
         dfg_seeds={d: seeds["designed" if d == "30" else f"designed_d{d}"] for d in D},
         part6=dict((t, Q["per_target"][t]["part6_dfg"]) for t in Q["targets"]),
         checks=Q["checks"], grids={t: {d: (g["lo"], g["hi"]) if g else None for d, g in Q["per_target"][t]["nets_grid"].items()}
                                    for t in Q["targets"]})


# =========================================================================================================================
# sec:res-tabular
# =========================================================================================================================
TAB_COLS = [("dfg13", "\\hd{DFG\\\\alone}"), ("mlp", code("mlp")), ("mlp_reg", "\\hd{\\code{mlp_}\\\\\\code{reg}}"),
            ("mlp_strong", "\\hd{\\code{mlp_}\\\\\\code{strong}}"), ("mlp_best", "\\hd{\\code{mlp_}\\\\\\code{best}}"),
            ("hgb", code("hgb")), ("v3", "v3")]


@table
def tab_tabular():
    """kr_vs_kp and mushroom.  (a) Test error (%) per cell, seed mean of 3; a reference's entry is marked where DFG alone is
    clearly worse ($\\ast$) or clearly better ($\\dagger$) than it by the cell rule; DFG alone's FLOPs as a fraction of the
    standard-task budget and CPU s per fit, and v3's CPU s.  (b) Summary per reference.  Source: RESULTS.json q6_tabular."""
    Q = R["q6_tabular"]; DS = ["kr_vs_kp", "mushroom"]
    L = ["\\begin{tabular}{@{}lr" + "r" * len(TAB_COLS) + "rrr@{}}", "\\toprule",
         f" & & \\multicolumn{{{len(TAB_COLS)}}}{{c}}{{test error (\\%)}} & \\multicolumn{{2}}{{c}}{{DFG alone}} & \\\\",
         f"\\cmidrule(lr){{3-{2 + len(TAB_COLS)}}}\\cmidrule(lr){{{3 + len(TAB_COLS)}-{4 + len(TAB_COLS)}}}",
         "dataset & $n$ & " + " & ".join(h for _, h in TAB_COLS) + " & \\hd{FLOPs /\\\\budget} & \\hd{CPU s\\\\per fit} & \\hd{v3\\\\CPU s}\\\\",
         "\\midrule"]
    for i, ds in enumerate(DS):
        if i:
            L.append("\\addlinespace[2pt]")
        o = Q[ds]
        V = {(k, c["n"]): c["v"] for k, s in o["summary"].items() for c in s["per_cell"]}
        for n, e in o["errors"].items():
            def cell(k):
                v = e.get(k)
                if v is None:
                    return "--"
                mk = {"worse": "$^{\\ast}$", "better": "$^{\\dagger}$"}.get(V.get((k, int(n))), "") if k != "dfg13" else ""
                return f"{100 * v:.2f}" + (f"\\rlap{{{mk}}}" if mk else "")
            cpu = o["compute"].get(n, {})
            L.append(f"{ds.replace('_', chr(92) + '_') if n == list(o['errors'])[0] else ''} & {n} & " + " & ".join(cell(k) for k, _ in TAB_COLS)
                     + f" & {num(cpu.get('flops_frac')):.3f} & {num(cpu.get('cpu')):.1f} & {num(cpu.get('v3_cpu')):.1f}\\\\")
    L += ["\\bottomrule", "\\end{tabular}"]
    write("tab_tabular", L)
    REFS = [("mlp", code("mlp")), ("mlp_reg", code("mlp_reg")), ("mlp_strong", code("mlp_strong")), ("mlp_best", code("mlp_best")),
            ("mlp_best+", code("mlp_best+")), ("hgb", code("hgb")), ("v3", "v3"), ("v2", "v2"), ("v1", "v1")]
    L = ["\\begin{tabular}{@{}lcccccc@{}}", "\\toprule",
         " & \\multicolumn{2}{c}{kr\\_vs\\_kp} & \\multicolumn{2}{c}{mushroom} & \\multicolumn{2}{c}{both}\\\\",
         "\\cmidrule(lr){2-3}\\cmidrule(lr){4-5}\\cmidrule(l){6-7}",
         "DFG alone against & \\hd{cells (better /\\\\tie / worse)} & \\hd{mean $\\log_2$\\\\error ratio} & \\hd{cells (better /\\\\tie / worse)} & "
         "\\hd{mean $\\log_2$\\\\error ratio} & \\hd{cells (better /\\\\tie / worse)} & \\hd{mean $\\log_2$\\\\error ratio}\\\\", "\\midrule"]
    both = {}
    for k, lab in REFS:
        cells = []; parts = []
        for ds in DS:
            s = Q[ds]["summary"].get(k)
            if not s:
                parts.append("-- & --"); continue
            cells += s["per_cell"]
            parts.append(f"{s['cells']} ({s['better']}/{s['tie']}/{s['worse']}) & {mean_s(s['mean'], 3)}")
        v = [c["v"] for c in cells]
        m = sum(c["lr"] for c in cells) / len(cells)
        both[k] = dict(cells=len(cells), better=v.count("better"), tie=v.count("tie"), worse=v.count("worse"), mean=m)
        L.append(f"{lab} & " + " & ".join(parts) + f" & {len(cells)} ({v.count('better')}/{v.count('tie')}/{v.count('worse')}) & ${m:+.3f}$\\\\")
    L += ["\\bottomrule", "\\end{tabular}"]
    write("tab_tabular_summ", L)
    worse = sorted({(ds, c["n"], k) for ds in DS for k, s in Q[ds]["summary"].items() for c in s["per_cell"] if c["v"] == "worse"})
    better = sorted({(ds, c["n"], k) for ds in DS for k, s in Q[ds]["summary"].items() for c in s["per_cell"] if c["v"] == "better"})
    comp = [(ds, n, num(c["flops_frac"]), num(c["cpu"]), num(c["v3_cpu"])) for ds in DS for n, c in Q[ds]["compute"].items()]
    note("tab_tabular", both=both, worse_cells=worse, better_cells=better, max_flops_frac=max(c[2] for c in comp),
         max_cpu=max(c[3] for c in comp), max_v3_cpu=max(c[4] for c in comp),
         cpu_ratio_range=[min(c[3] / c[4] for c in comp), max(c[3] / c[4] for c in comp)],
         references_without_cells=Q["references_without_cells"])


# =========================================================================================================================
# sec:res-compute
# =========================================================================================================================
sec = lambda v: f"{num(v):.2f}" if num(v) < 1 else f"{num(v):.1f}"        # CPU seconds


@table
def tab_compute():
    """FLOPs per fit as a fraction of one network run at that d, and CPU seconds per fit: (a) per run (DFG alone on every
    suite and at every d; lowdeg pooled over its 11 suites), (b) by n over DFG alone's d = 30 fits, with v3 on the same fits.
    Source: RESULTS.json compute.runs and compute.by_n."""
    C = R["compute"]; RU = C["runs"]
    L = ["\\begin{tabular}{@{}lrrlrr@{}}", "\\toprule",
         "\\multicolumn{6}{@{}l}{\\emph{(a) per suite: DFG alone}}\\\\",
         "suite & $d$ & fits & \\hd{max FLOPs per fit / one\\\\network run (target, $n$)} & \\hd{fits above\\\\0.75 run} & "
         "\\hd{CPU s per fit:\\\\median / max}\\\\", "\\midrule"]
    keys = [f"dfg13-perm|{su}" for su in TOY] + [f"dfg13-perm|designed_d{d}" for d in (15, 60, 120)]
    for k in keys:
        x = RU[k]; su = k.split("|")[1]
        lab = code(su) if "_d" not in su else f"{code(su.split('_d')[0])}, $d={su.split('_d')[1]}$"
        L.append(f"{lab} & {x['d']} & {x['fits']} & {num(x['max_flops_frac']):.3f} ({tg(x['at'][0])}, {x['at'][1]}) & {x['over_075']} & "
                 f"{num(x['cpu_median']):.2f} / {num(x['cpu_max']):.1f}\\\\")
        if su == TOY[-1]:
            L.append("\\addlinespace[2pt]")
    lw = [RU[f"lowdeg-perm|{su}"] for su in TOY if f"lowdeg-perm|{su}" in RU]
    L += ["\\addlinespace[2pt]", f"\\code{{lowdeg}}, 11 suites & 30 & {sum(x['fits'] for x in lw)} & {max(num(x['max_flops_frac']) for x in lw):.3f} & "
          f"{sum(x['over_075'] for x in lw)} & {min(num(x['cpu_median']) for x in lw):.2f}--{max(num(x['cpu_median']) for x in lw):.2f} / "
          f"{max(num(x['cpu_max']) for x in lw):.1f}\\\\", "\\bottomrule", "\\end{tabular}"]
    write("tab_compute", L)
    B = C["by_n"]; NS_ = sorted(B, key=int)
    L = ["\\begin{tabular}{@{}l" + "r" * len(NS_) + "@{}}", "\\toprule", "$n$ & " + " & ".join(NS_) + "\\\\", "\\midrule",
         "\\multicolumn{" + str(1 + len(NS_)) + "}{@{}l}{\\emph{DFG alone: FLOPs per fit / one network run}}\\\\",
         "median & " + " & ".join(f"{num(B[n]['flops_median']):.3f}" for n in NS_) + "\\\\",
         "max & " + " & ".join(f"{num(B[n]['flops_max']):.3f}" for n in NS_) + "\\\\",
         "\\multicolumn{" + str(1 + len(NS_)) + "}{@{}l}{\\emph{CPU s per fit: median (max)}}\\\\",
         "DFG alone & " + " & ".join(top2(f"{num(B[n]['cpu_median']):.2f}", f"({sec(B[n]['cpu_max'])})") for n in NS_) + "\\\\",
         "v3 & " + " & ".join(top2(f"{num(B[n]['v3_cpu_median']):.2f}", f"({sec(B[n]['v3_cpu_max'])})") for n in NS_) + "\\\\",
         "\\begin{tabular}[b]{@{}l@{}}median of the paired\\\\ratio DFG alone / v3\\end{tabular} & "
         + " & ".join(f"{num(B[n]['paired_ratio_median']):.2f}" for n in NS_) + "\\\\",
         "\\bottomrule", "\\end{tabular}"]
    write("tab_compute_byn", L)
    dfg = {k: RU[k] for k in keys}
    m = max(dfg.items(), key=lambda z: num(z[1]["max_flops_frac"]))
    d30 = [RU[f"dfg13-perm|{su}"] for su in TOY]
    note("tab_compute", max_flops=dict(run=m[0], value=num(m[1]["max_flops_frac"]), at=m[1]["at"]),
         fits_d30=sum(x["fits"] for x in d30), fits_all=sum(x["fits"] for x in dfg.values()),
         over_075=sum(x["over_075"] for x in dfg.values()), over_1=sum(x["over_1"] for x in dfg.values()),
         cpu_median_range_d30=[min(num(x["cpu_median"]) for x in d30), max(num(x["cpu_median"]) for x in d30)],
         cpu_max_d30=max(num(x["cpu_max"]) for x in d30), cpu_max_all=max(num(x["cpu_max"]) for x in dfg.values()),
         suite_max_range_d30=[min(num(x["max_flops_frac"]) for x in d30), max(num(x["max_flops_frac"]) for x in d30)],
         all_max_at_16384=all(x["at"][1] == 16384 for x in dfg.values()),
         by_n={n: {k: num(v) for k, v in B[n].items()} for n in NS_},
         paired_ratio_range=[min(num(B[n]["paired_ratio_median"]) for n in NS_), max(num(B[n]["paired_ratio_median"]) for n in NS_)],
         lowdeg_max_flops=max(num(x["max_flops_frac"]) for x in lw))


# =========================================================================================================================
# sections/learner.tex ("What DFG is"): every value is read from the frozen DFG v1.3 itself
# =========================================================================================================================
def _frozen_dfg():
    """The frozen DFG v1.3 (study/part10/hyb_portfolio3/dfg13.py, md5 asserted by part11/eval_dfg.load_dfg13), its source
    text, its constructor defaults (read with inspect) and harness.gd_flops, the budget unit."""
    import inspect
    for p in (os.path.join(STUDY, "discrete_learner"), os.path.join(STUDY, "part11")):
        if p not in sys.path:
            sys.path.insert(0, p)
    import eval_dfg                                              # loads part10/hyb_portfolio3/dfg13.py, md5 asserted
    from harness import gd_flops
    M = eval_dfg.load_dfg13()
    src = open(eval_dfg.DFG13).read()
    dflt = {k: v.default for k, v in inspect.signature(M.DFG.__init__).parameters.items() if k != "self"}
    return M, src, dflt, gd_flops


def _budget_rows(M, D, gd_flops, d, scale):
    """Rows of the budgeted searches of one fit call with budget scale `scale` (DFG._fit: GD = gd_flops(d) * scale, line 582;
    degree 3, line 628; degree 4, line 638; degrees 5..K_hi, line 654; two-input extensions of b bases, line 668), before
    the min(n, .)."""
    GD = gd_flops(d) * scale
    m3 = int(D.budget[1] * GD / (d * (2 * d * d + 2 * d)))
    m4 = int(D.budget[0] * GD / (math.comb(d, 2) * (2 * d * d + 3 * d)))
    mk = {}
    for k in range(D.K + 1, D.K_hi + 1):
        k1, k2 = (k + 1) // 2, k // 2
        N1, N2 = math.comb(d, k1), math.comb(d, k2)
        mk[k] = int(D.budget_hi * GD / (2 * N1 * N2 + M.m_tab_cost(d, k1, k2)))
    me = lambda b: int(D.budget[2] * GD / (b * (2 * d * d + 3 * d)))
    return m3, m4, mk, me


def _thin(v):
    """An integer with thin-space thousands separators."""
    return f"{int(v):,}".replace(",", "\\,")


def _sci(v, p=1):
    """A positive number as $a\\times10^{b}$."""
    e = int(math.floor(math.log10(v))); m = v / 10 ** e
    return f"${m:.{p}f}\\times10^{{{e}}}$"


@table
def tab_dictionary():
    """sections/learner.tex, tab:dictionary.  DFG v1.3's candidate classes at d = 30: what each enumerates, the rows its
    test uses, its size N (the count its union bound pays for), the log term of its threshold and the smallest n at which
    any member can pass its own test.  Characters: L = ln(4KN/delta) (dfg13.py line 602), smallest n = 2 c^2 L (P2':
    Cauchy-Schwarz).  Sum blocks: L_B = ln(4K C(d,k) 2^(k-1) 2 (1+mu) k_max / delta) (line 719), i.e. L with
    N = C(d,k) 2^(k-1) 2 (1+mu) k_max; smallest n = 1 + 2 sqrt(L_B) + 2 L_B (dfg13._chi2_thr at nu = 1; the block
    statistic is at most n by Bessel's inequality).  Linear block: its chi^2_k threshold at k = d (line 699) and its room
    condition n >= 2(p + k) in round 0; spectral features: n >= 4d (line 707).  Every value is computed from the frozen
    file (constructor defaults, its helpers _chi2_thr, _ln_inner, m_tab_cost, and the budget formulas of DFG._fit) with
    harness.gd_flops; the budgeted rows and n_thr are checked against study/part11/interp/theory/check_theory.json
    (P5.m_table, P2.n_thr)."""
    M, src, dflt, gd_flops = _frozen_dfg()
    D = M.DFG(readout="logit"); d = 30
    K, c, dl, KM = D.K, D.c, D.delta, D.sum_kmax
    L = lambda N: math.log(4 * K * max(N, 1) / dl)                       # line 602
    nfl = lambda N: 2 * c * c * L(N)                                       # P2'
    Nb = lambda k, nmod=1: math.comb(d, k) * 2 ** (k - 1) * 2 * nmod * KM   # line 719, as N in ln(4KN/delta)
    tau = lambda k, nmod=1: math.log(4 * D.K * math.comb(d, k) * 2.0 ** (k - 1) * 2 * nmod * KM / D.delta)
    bfl = lambda t: M._chi2_thr(1, t)
    # ---- checks against THEORY.md's numbers
    TJ = json.load(open(os.path.join(STUDY, "part11", "interp", "theory", "check_theory.json")))
    for dd in (15, 30, 60, 120):
        T = TJ["P5"]["m_table"][str(dd)]
        for sc, key in ((1.0, "scale1.0"), (0.5, "scale0.5"), (0.05, "scale0.05"), (0.025, "scale0.025")):
            m3, m4, mk, _ = _budget_rows(M, D, gd_flops, dd, sc)
            assert (m3, m4, mk[5], mk[6]) == tuple(T[f"m{k}"][key] for k in (3, 4, 5, 6)), (dd, sc)
    for dd, row in TJ["P2"]["n_thr"].items():
        for k, v in row.items():
            assert abs(nfl(math.comb(int(dd), int(k))) - v) < 1e-9, (dd, k)
    for k in range(2, KM + 1):
        assert abs(tau(k) - L(Nb(k))) < 1e-9
    # ---- values at d = 30
    m3, m4, mk, me = _budget_rows(M, D, gd_flops, d, 1.0)
    m3h, m4h, mkh, meh = _budget_rows(M, D, gd_flops, d, 0.5)
    B, V = D.max_ext_bases, D.local_max
    NMAX = 16384                                                            # the grid's largest n
    assert min(m3, m4, me(B)) > NMAX and min(m3h, m4h, meh(B)) > 512    # degrees 3, 4 and ext2 run on all rows at d = 30
    assert mk[5] < NMAX and mk[6] < NMAX
    rng = lambda a, b, f: f"{f(a)}--{f(b)}"
    f2 = lambda v: f"{v:.2f}"
    loc_N = [math.comb(v, k) for v in range(2, V + 1) for k in range(1, v + 1)]
    lin_thr = lambda k: k + 2 * math.sqrt(k * math.log(1 / dl)) + 2 * math.log(1 / dl)   # line 699
    cand = {1: "every $x_i$", 2: "every pair", 3: "every triple", 4: "every 4-set; round 0",
            5: "round 0, final fit", 6: "round 0, final fit"}
    rows_of = {1: "all", 2: "all", 3: "all", 4: "all", 5: f"first {_thin(mk[5])} ({_thin(mkh[5])})",
               6: f"first {_thin(mk[6])} ({_thin(mkh[6])})"}
    Lx = ["\\begin{tabular}{@{}lllrrr@{}}", "\\toprule",
          "class & candidates & rows tested & $N$ at $d=30$ & $\\ln(4KN/\\delta)$ & \\hd{smallest $n$\\\\that can pass}\\\\",
          "\\midrule", "\\multicolumn{6}{@{}l}{\\emph{Characters} $\\chi_S$, test \\eqref{eq:chartest}}\\\\"]
    for k in range(1, D.K_hi + 1):
        N = math.comb(d, k)
        Lx.append(f"global, $k={k}$ & {cand[k]} & {rows_of[k]} & {_thin(N)} & {f2(L(N))} & {f2(nfl(N))}\\\\")
    C2 = math.comb(d, 2)
    Lx += [f"extension, $+1$ input & $T\\cup\\{{j\\}}$ & all & $bd\\le{_thin(B * d)}$ & {rng(L(d), L(B * d), f2)} & "
           f"{rng(nfl(d), nfl(B * d), f2)}\\\\",
           f"extension, $+2$ inputs & $T\\cup\\{{j,l\\}}$ & all & $b\\binom d2\\le{_thin(B * C2)}$ & {rng(L(C2), L(B * C2), f2)} & "
           f"{rng(nfl(C2), nfl(B * C2), f2)}\\\\",
           f"local & $S\\subseteq V$, $|V|\\le{V}$ & all & $\\binom{{|V|}}{{|S|}}\\le{_thin(max(loc_N))}$ & "
           f"{rng(L(min(loc_N)), L(max(loc_N)), f2)} & {rng(nfl(min(loc_N)), nfl(max(loc_N)), f2)}\\\\",
           "\\addlinespace", "\\multicolumn{6}{@{}l}{\\emph{Dense moves}}\\\\",
           f"linear block & every remaining $x_i$ & all & \\multicolumn{{2}}{{r}}{{$\\chi^2_d$ threshold {lin_thr(d):.1f}, "
           f"\\eqref{{eq:lintest}}}} & {2 * (1 + d)}\\\\",
           f"spectral features & $\\le4$ eigenvectors & all & \\multicolumn{{2}}{{r}}{{edge \\eqref{{eq:spectest}}}} & {4 * d}\\\\",
           "\\addlinespace",
           f"\\multicolumn{{6}}{{@{{}}l}}{{\\emph{{Sum blocks}} on $k$ inputs, test \\eqref{{eq:blocktest}}, $\\mu=0$; "
           f"searched on the first {_thin(D.sum_gcap)} rows}}\\\\"]
    KS = [2, 3, 5, 9, 14, KM]
    for k in KS:
        Lx.append(f"$k={k}$ & $(S,s)$, folded or not & all & {_sci(Nb(k))} & {f2(tau(k))} & {bfl(tau(k)):.1f}\\\\")
    w_extra = M._ln_inner(d); w_cnt = 2 * (4 * d + 20 * C2)
    Lx += [f"weighted & $+a\\tau$, $a\\in\\{{\\pm2,\\pm3\\}}$ & all & $\\times\\,{_thin(w_cnt)}$ & $+{w_extra:.2f}$ & \\\\",
           f"modulated & by $\\chi_P$, $\\mu\\le{D.sum_mod}$ & all & $\\times\\,(1+\\mu)$ & $\\le+{math.log(1 + D.sum_mod):.2f}$ & \\\\",
           "product & $A\\times B$, disjoint & all & $N_AN_B$ & $L_A+L_B$ & \\\\",
           "\\bottomrule", "\\end{tabular}"]
    write("tab_dictionary", Lx)
    n_glob_chars = sum(math.comb(d, k) for k in range(1, D.K_hi + 1))
    n_blocks = sum(math.comb(d, k) * 2 ** (k - 1) * 2 for k in range(2, KM + 1))
    note("tab_dictionary", d=d, K=K, c=c, delta=dl, k_max=KM, gd_flops_d30=gd_flops(d),
         n_thr={dd: {k: nfl(math.comb(dd, k)) for k in range(1, 7)} for dd in (15, 30, 60, 120, 1000)},
         L_char={k: L(math.comb(d, k)) for k in range(1, 7)},
         rows_scale1=dict(m3=m3, m4=m4, m5=mk[5], m6=mk[6], m_ext2_b32=me(B)),
         rows_scale05=dict(m3=m3h, m4=m4h, m5=mkh[5], m6=mkh[6], m_ext2_b32=meh(B)),
         rows_fold=dict(F5=_budget_rows(M, D, gd_flops, d, 1 / 20)[:2], F10=_budget_rows(M, D, gd_flops, d, 1 / 40)[:2]),
         rows_d60_d120_scale1={dd: dict(zip(("m3", "m4"), _budget_rows(M, D, gd_flops, dd, 1.0)[:2])) for dd in (60, 120)},
         ext1_N=[d, B * d], ext2_N=[C2, B * C2], local_N=[min(loc_N), max(loc_N)],
         linear_thr_k30=lin_thr(d), linear_min_n_round0=2 * (1 + d), spectral_min_n=4 * d,
         tau={k: tau(k) for k in range(2, KM + 1)}, block_min_n={k: bfl(tau(k)) for k in range(2, KM + 1)},
         block_N={k: Nb(k) for k in KS}, weighted_extra_nats=w_extra, weighted_count=w_cnt,
         modulator_extra_nats_max=math.log(1 + D.sum_mod),
         global_chars_deg1to6=n_glob_chars, unweighted_blocks_S_s_fold=n_blocks, three_pow_d=3 ** d,
         par4_name_nats=L(math.comb(d, 4)), char_min_n_deg1=nfl(d), char_min_n_deg4=nfl(math.comb(d, 4)))


PARAM_ROLES = [   # (constructor argument, what it sets); the values are read from the frozen file
    ("Tests", None),
    ("K", "global degree in round 0"),
    ("K_later", "global degree, rounds $\\ge1$"),
    ("K_hi", "top degree, round 0"),
    ("c", "threshold multiplier"),
    ("delta", "level $\\delta$ of every test"),
    ("noise", "tests scaled by $s=\\mathrm{rms}(r)$"),
    ("Rounds and classes", None),
    ("rounds", "rounds at most"),
    ("max_new", "characters admitted per round"),
    ("max_feats", "features (also $\\le n/2$)"),
    ("max_ext_bases", "characters extended"),
    ("local_max", "largest $|V|$, local class"),
    ("blocks", "linear and spectral moves"),
    ("Small $n$ and budget", None),
    ("small_n", "forced variant and its test"),
    ("cv_n", "the test runs at $n\\le$ this"),
    ("background", "kernel background $g\\cdot x$"),
    ("budget", "shares: degree 4; 3; ext.\\ by 2"),
    ("budget_hi", "share: degrees 5, 6 each"),
    ("Readout", None),
    ("readout", "run as \\code{logit}"),
    ("ridge", "ridge of least squares ($\\times n$)"),
    ("logit_lam", "L2 penalty, logistic steps"),
    ("Sum blocks", None),
    ("sums", "sum blocks"),
    ("sum_nmin", "smallest $n$ for the block search"),
    ("sum_kmax", "largest block; the $k_{\\max}$ of $N_B$"),
    ("sum_mod", "modulators $\\mu$ at most"),
    ("sum_add", "additive blocks per round"),
    ("sum_gcap", "rows for the search's scores"),
    ("sum_mc", "smallest group over $n$ (at least 3)"),
    ("sum_prod", "product and split blocks"),
    ("sum_seeds", "eigenvector, pair, single seeds"),
    ("sum_inner", "weighted blocks $t+a\\tau$"),
    ("sum_ntau", "pairs tried as inner terms"),
    ("sum_beam", "beam width"),
    ("sum_beam_nmax", "beam only at $n\\le$ this"),
    ("sum_force", "forced variant may force a block"),
    ("sum_force_nmin", "smallest $n$ for a forced block"),
    ("sum_force_r2", "smallest $T_B/n$ of a forced block"),
]

FIXED = [   # ([(code fragment that must occur in the frozen source, its line), ...], how it is shown, what it sets)
    ([("for _ in range(15):", 851)], "15", "logistic Newton steps"),
    ([("n >= 8 * len(cols)", 849)], "$n\\ge8p$", "when they run"),
    ([("v = 4.0 * W", 850)], "$4w$", "where they start"),
    ([("fl[0] > 0.75 * GD", 598)], "0.75", "budget share that ends the rounds"),
    ([("F = 10 if n <= 64 else 5", 553)], "10 / 5", "folds at $n\\le64$ / above"),
    ([("b - c_ > 2 * math.sqrt(b + c_)", 567)], "$2\\sqrt{e_{10}+e_{01}}$", "margin of the paired test"),
    ([("False, 1 / (4 * F))", 564), ("run(variants[best], X, y, True, 0.5)", 569)], "$\\frac1{4F}$, $\\frac12$",
     "budget scale: fold fit, final fit"),
    ([("if m >= 32 else 0", 630), ("if m < 64:", 655)], "32 / 64", "fewest rows: degrees 3, 4 / 5, 6"),
    ([("[:4] if n >= 4 * d else []", 707)], "4; $4d$", "spectral features; smallest $n$"),
    ([("forced[0] < 2", 817)], "2", "forced guesses per fit"),
    ([("live = s2S > 1e-4 * s2", 734)], "$10^{-4}$", "least $\\mathrm{mean}(\\tilde r^2)/s^2$ for blocks"),
    ([("mc = max(3, int(self.sum_mc * n))", 721)], "3", "fewest points per group"),
    ([("for a in (2, 3, -2, -3):", 273)], "$\\pm2,\\pm3$", "weights $a$ of inner terms"),
    ([("patience=5", 179)], "5", "growth steps without gain"),
    ([("npool=24", 180)], "24", "pairs for inner-term extensions"),
    ([("bcap=1024", 180)], "1024", "rows of the beam"),
    ([("for _ in range(3 * kmax):", 376)], "$3k_{\\max}$", "refinement moves at most"),
]


def _pval(v):
    if isinstance(v, bool):
        return str(v)
    if isinstance(v, str):
        return "\\code{" + v + "}"
    if isinstance(v, (tuple, list)):
        return "(" + ", ".join(_pval(x) for x in v) + ")"
    if isinstance(v, float):
        return f"{v:g}"
    return str(v)


@table
def tab_params():
    """sections/learner.tex, tab:params.  The frozen DFG v1.3's constructor defaults (read with inspect from dfg13.py,
    md5 asserted; it is run as DFG(readout="logit") with every other argument at its default), and the constants fixed
    in its code, each asserted to occur in the frozen source at the line given."""
    M, src, dflt, gd_flops = _frozen_dfg()
    lines = src.split("\n")
    shown = {k for k, r in PARAM_ROLES if r is not None}
    assert shown == set(dflt) - {"name"}, sorted(set(dflt) ^ shown)
    for frags, _, _ in FIXED:
        for frag, ln in frags:
            assert frag in lines[ln - 1], (frag, ln)
    head = lambda t, ncol: f"\\multicolumn{{{ncol}}}{{@{{}}l}}{{\\emph{{{t}}}}}\\\\"

    def panel(rows):
        out = []
        for k, r in rows:
            out.append(head(k, 3) if r is None else f"\\code{{{k}}} & {_pval(dflt[k])} & {r}\\\\")
        return out
    cut = PARAM_ROLES.index(("Sum blocks", None))
    left = (["\\begin{tabularx}{\\linewidth}[t]{@{}l@{\\hspace{4pt}}l@{\\hspace{5pt}}>{\\raggedright\\arraybackslash}X@{}}",
             "\\toprule"] + panel(PARAM_ROLES[:cut]) + ["\\bottomrule", "\\end{tabularx}"])
    right = (["\\begin{tabularx}{\\linewidth}[t]{@{}l@{\\hspace{4pt}}l@{\\hspace{5pt}}>{\\raggedright\\arraybackslash}X@{}}",
              "\\toprule"] + panel(PARAM_ROLES[cut:]) + ["\\bottomrule", "\\end{tabularx}", "\\par\\medskip",
              "\\begin{tabularx}{\\linewidth}[t]{@{}l@{\\hspace{5pt}}>{\\raggedright\\arraybackslash}Xr@{}}", "\\toprule",
              head("Fixed in the code", 2) .replace("\\\\", "") + " & line\\\\"])
    for frags, val, what in FIXED:
        right.append(f"{val} & {what} & {', '.join(str(ln) for _, ln in frags)}\\\\")
    right += ["\\bottomrule", "\\end{tabularx}"]
    L = (["\\begin{minipage}[t]{0.505\\linewidth}"] + left + ["\\end{minipage}\\hfill", "\\begin{minipage}[t]{0.47\\linewidth}"]
         + right + ["\\end{minipage}"])
    write("tab_params", L)
    note("tab_params", defaults={k: (list(v) if isinstance(v, tuple) else v) for k, v in dflt.items()}, run_as=dict(readout="logit"),
         fixed={f"{ln}": frag for frags, _, _ in FIXED for frag, ln in frags})


# =========================================================================================================================
# sections/ablations.tex ("What its parts do", sec:ablations): RESULTS.json q5_ablations and q5b_core, and
# study/part11/interp/ablations/ablations.json (written by ablations.py from the same result files, the paired null of
# perm_null.py and the leave-one-in runs of leavein.py; families from families.py).
# =========================================================================================================================
ABJ = os.path.join(STUDY, "part11", "interp", "ablations", "ablations.json")
ABL_TAGS = [("nosums", "no sum blocks"), ("strict", "stricter tests, $\\delta=10^{-4}$"),
            ("lenient", "more lenient tests, $\\delta=0.9$"), ("noeig", "no eigenvector seeds in the block search"),
            ("noblocks", "no linear or spectral block"), ("nocomp", "no extension or local classes"),
            ("noweighted", "no weighted blocks"), ("nosmalln", "no forced variant, no cross-validation"),
            ("nobg", "no kernel background"), ("lsread", "least-squares readout"),
            ("K3", "global search to degree 3"), ("labelnoise", "tests scaled to the labels' noise")]   # PROTOCOL.md Q5
ABL_FAMS = ["Parities", "Staircases", "Majorities and halfspaces", "Compositions",
            "DNF, CNF, decision lists, read-once formulas", "Random formulas", "Symmetric and pure signed-sum targets",
            "Signed-sum mixtures"]                                   # the atlas groups present in the five ablation suites
FAM_HEAD = {"Parities": "parities", "Staircases": "stair-\\\\cases", "Multiplexers (address and data bits)": "multi-\\\\plexers",
            "Majorities and halfspaces": "half-\\\\spaces", "Compositions": "compo-\\\\sitions",
            "DNF, CNF, decision lists, read-once formulas": "formulas", "Random formulas": "random\\\\formulas",
            "Symmetric and pure signed-sum targets": "sym-\\\\metric", "Signed-sum mixtures": "mixtures"}
CLS_HEAD = [("character", "character\\\\targets"), ("halfspace", "halfspaces"), ("sum", "symmetric and\\\\mixtures")]
hdn = lambda lab, n: "\\hd{" + lab + "\\\\(" + str(n) + ")}"           # a two- or three-line header with the count
_AJ = {}


def abl_json():
    if not _AJ:
        _AJ.update(json.load(open(ABJ)))
    return _AJ


def ab_cell(s, two=True):
    """An ablation summary: mean over the targets both reach, (clearly lower / clearly higher) [both reach]; lower = the
    ablation (or the core) needs less data than DFG alone on the same seeds."""
    if not s or not s.get("targets"):
        return "--"
    m = "n/a" if s["mean"] is None else f"${s['mean']:+.2f}$"
    lo = f"({s['lower']}/{s['higher']})" + (f" [{s['both']}]" if two else "")
    return f"\\begin{{tabular}}[t]{{@{{}}c@{{}}}}{m}\\\\{{\\scriptsize {lo}}}\\end{{tabular}}"


@table
def tab_ablations():
    """The 12 pre-registered ablations on the 65 targets of the five ablation suites, against DFG alone on the same seeds:
    pooled and by coarse class (families.py), the targets newly never learned; the paired null (DFG alone with another
    column order and other folds, same training sets; post hoc) and the unpaired seed null.  Sources: ablations.json
    ('ablations', 'nulls'), checked against RESULTS.json q5_ablations (pooled means and counts)."""
    J = abl_json(); A = J["ablations"]; Q5 = R["q5_ablations"]
    cn = {c: max(A[t]["by_class"][c]["targets"] for t, _ in ABL_TAGS) for c, _ in CLS_HEAD}
    L = ["\\begin{tabular}{@{}llc" + "c" * (2 + len(CLS_HEAD)) + "@{}}", "\\toprule",
         "run & change & seeds & \\hd{all\\\\(65)} & \\hd{newly\\\\never} & " + " & ".join(hdn(h, cn[c]) for c, h in CLS_HEAD) + "\\\\",
         "\\midrule"]
    for tag, what in ABL_TAGS:
        a = A[tag]; q = Q5[tag]["pooled"]
        assert (a["pooled"]["targets"], a["pooled"]["lower"], a["pooled"]["higher"]) == (q["targets"], q["better"], q["worse"]), tag
        assert abs(a["pooled"]["mean"] - num(q["mean"])) < 1e-9, tag
        nv = ", ".join(tg(x.split("/")[1]) for x in Q5[tag]["newly_never"]) or "--"
        L.append(f"{code(tag)} & {what} & {', '.join(map(str, a['seeds']))} & {ab_cell(a['pooled'])} & {{\\scriptsize {nv}}} & "
                 + " & ".join(ab_cell(a["by_class"].get(c)) for c, _ in CLS_HEAD) + "\\\\")
    N = J["nulls"]; L.append("\\midrule")
    for key, lab, sd in (("paired_seed0", "paired null", "0"), ("paired_seed01", "paired null", "0, 1"),
                         ("unpaired_seed1_vs_seed0", "unpaired null", "1 vs 0")):
        if key not in N:
            L.append(f"{lab} & {'not run' if key.startswith('paired') else ''} & {sd} & -- & -- & " + " & ".join("--" for _ in CLS_HEAD) + "\\\\"); continue
        x = N[key]; what = ("other column order and folds, same training sets" if key.startswith("paired")
                            else "seed 1 against seed 0: other training sets")
        nv = ", ".join(tg(k.split("/")[1]) for k, v in x["ratios"].items() if v in ("inf", INF)) or "--"
        L.append(f"{lab} & {what} & {sd} & {ab_cell(x['pooled'])} & {{\\scriptsize {nv}}} & " + " & ".join(ab_cell(x["by_class"].get(c)) for c, _ in CLS_HEAD) + "\\\\")
    L += ["\\bottomrule", "\\end{tabular}"]
    write("tab_ablations", L)
    note("tab_ablations", pooled={t: A[t]["pooled"] for t, _ in ABL_TAGS}, by_class={t: A[t]["by_class"] for t, _ in ABL_TAGS},
         seed_agreement={t: A[t].get("seed_agreement") for t, _ in ABL_TAGS if "seed_agreement" in A[t]},
         per_seed={t: A[t].get("per_seed") for t, _ in ABL_TAGS if "per_seed" in A[t]},
         nulls={k: dict(pooled=v["pooled"], by_class=v["by_class"],
                        moved={t: r for t, r in v["ratios"].items() if r == r and abs(r) > THR},
                        nonzero=sum(1 for r in v["ratios"].values() if r == r and abs(r) > 1e-9)) for k, v in N.items()},
         class_sizes=cn, parity_P2=J["parity_P2"], char_shift=J["char_shift"], linear_block_thr=J["linear_block_thr"],
         block_thr_shift=J["block_thr_shift"], block_gap={k: v for k, v in J["block_gap"].items() if k != "rows"},
         atlas_counterfactuals={k: {kk: vv for kk, vv in v.items() if kk != "unequal"} | dict(unequal=[(x["target"], x["n"]) for x in v["unequal"]])
                                for k, v in J["atlas_counterfactuals"].items()},
         errs_by_n=J["errs_by_n"], moved={t: {k: r for k, r in A[t]["ratios"].items() if r == r and abs(r) > THR} for t, _ in ABL_TAGS},
         mean_abs={t: A[t]["pooled"]["mean_abs"] for t, _ in ABL_TAGS})


@table
def tab_abl_family():
    """The ablations by target family (the atlas's groups, families.py) on the 65 targets of the five ablation suites, with
    the paired null and the core restricted to the same 65 targets.  Source: ablations.json."""
    J = abl_json(); A = J["ablations"]; F = J["families"]
    size = {g: sum(1 for k, v in F.items() if v == g and k.split("/")[0] in ("designed", "dlsymdev", "dlfamdev", "dlheld6", "dlheld7")) for g in ABL_FAMS}
    cell = lambda s: ab_cell(s, two=False)
    L = ["\\begin{tabular}{@{}l" + "c" * len(ABL_FAMS) + "@{}}", "\\toprule",
         "run & " + " & ".join(hdn(FAM_HEAD[g], size[g]) for g in ABL_FAMS) + "\\\\", "\\midrule"]
    for tag, _ in ABL_TAGS:
        L.append(f"{code(tag)} & " + " & ".join(cell(A[tag]["by_family"].get(g)) for g in ABL_FAMS) + "\\\\")
    L.append("\\midrule")
    N = J["nulls"]
    for key, lab in (("paired_seed01", "paired null (0, 1)"), ("paired_seed0", "paired null (0)"), ("unpaired_seed1_vs_seed0", "unpaired null")):
        if key in N:
            L.append(f"{lab} & " + " & ".join(cell(N[key]["by_family"].get(g)) for g in ABL_FAMS) + "\\\\")
    L += ["\\midrule", "core (post hoc) & " + " & ".join(cell(J["core"]["ablation_suites_by_family"].get(g)) for g in ABL_FAMS) + "\\\\",
          "\\bottomrule", "\\end{tabular}"]
    write("tab_abl_family", L)
    note("tab_abl_family", sizes=size, by_family={t: A[t]["by_family"] for t, _ in ABL_TAGS},
         core_by_family_65=J["core"]["ablation_suites_by_family"])


@table
def tab_core():
    """The post-hoc core DFG: (a) per suite and pooled, against DFG alone on the same seeds and against nets_best (RESULTS.json
    q5b_core); (b) by family over all 138 targets (ablations.json 'core')."""
    Q = R["q5b_core"]; J = abl_json()["core"]
    c2 = lambda s: summ2(s) if s else "--"
    L = ["\\begin{tabular}{@{}llccccc@{}}", "\\toprule",
         "suite & status for DFG v1.3 & targets & \\hd{core vs\\\\DFG alone} & \\hd{newly\\\\never} & \\hd{core vs\\\\\\code{nets_best}} & "
         "\\hd{DFG alone vs\\\\\\code{nets_best}}\\\\", "\\midrule"]
    for su in TOY:
        o = Q["suites"][su]
        L.append(f"{code(su)} & {status(su)} & {o['vs_dfg']['targets']} & {c2(o['vs_dfg'])} & {', '.join(tg(t) for t in o['newly_never']) or '--'} & "
                 f"{c2(o['vs_nets_best']) if o['vs_nets_best'] else 'no networks'} & {c2(o['dfg_same_seeds_vs_nets_best']) if o['dfg_same_seeds_vs_nets_best'] else '--'}\\\\")
    P = Q["pooled"]
    L += ["\\midrule", f"pooled & & {P['vs_dfg']['targets']} & {c2(P['vs_dfg'])} & {len(P['newly_never'])} & {c2(P['vs_nets_best'])} & "
          f"{c2(P['dfg_same_seeds_vs_nets_best'])}\\\\", "\\bottomrule", "\\end{tabular}"]
    write("tab_core", L)
    # (b) by family
    fams = ["Parities", "Staircases", "Multiplexers (address and data bits)", "Majorities and halfspaces", "Compositions",
            "DNF, CNF, decision lists, read-once formulas", "Random formulas", "Symmetric and pure signed-sum targets", "Signed-sum mixtures"]
    sz = {g: sum(1 for v in abl_json()["families"].values() if v == g) for g in fams}
    cell = lambda s: ab_cell(s, two=True)
    cnb = cell                                                   # lower = the core (or DFG alone) needs less data than nets_best
    L = ["\\begin{tabular}{@{}l" + "c" * len(fams) + "@{}}", "\\toprule",
         " & " + " & ".join(hdn(FAM_HEAD[g], sz[g]) for g in fams) + "\\\\", "\\midrule",
         "core vs DFG alone & " + " & ".join(cell(J["by_family"].get(g)) for g in fams) + "\\\\",
         "core vs \\code{nets_best} & " + " & ".join(cnb(J["vs_nets_best"]["by_family"].get(g)) for g in fams) + "\\\\",
         "DFG alone vs \\code{nets_best} & " + " & ".join(cnb(J["dfg_same_seeds_vs_nets_best"]["by_family"].get(g)) for g in fams) + "\\\\",
         "\\bottomrule", "\\end{tabular}"]
    write("tab_core_family", L)
    mv = Q["moved"]
    note("tab_core", pooled={k: v for k, v in P.items() if k not in ("newly_never", "newly_reached", "neither")},
         newly_never=P["newly_never"], neither=P["neither"], moved_count=len(mv),
         moved_up=[(m["suite"], m["target"], num(m["ratio"])) for m in mv if num(m["ratio"]) > 0],
         moved_down=[(m["suite"], m["target"], num(m["ratio"])) for m in mv if num(m["ratio"]) < 0],
         dlheld7=Q["suites"]["dlheld7"], by_family=J["by_family"], vs_nets_best_by_family=J["vs_nets_best"]["by_family"],
         dfg_vs_nets_best_by_family=J["dfg_same_seeds_vs_nets_best"]["by_family"], by_class=J["by_class"],
         ablation_suites=J["ablation_suites"], other_suites=J["other_suites"], family_sizes=sz,
         paired_null_same_seeds=J.get("paired_null_same_seeds"), compute=J.get("compute"),
         ablation_suites_by_class=J["ablation_suites_by_class"])


LEAVEIN = [("deg46", "\\hd{degrees\\\\4--6}"), ("comp", "\\hd{compo-\\\\sition}"), ("blocks", "\\hd{linear,\\\\spectral}"),
           ("logit", "\\hd{logistic\\\\readout}"), ("bg", "\\hd{back-\\\\ground}"), ("weighted", "\\hd{weighted\\\\blocks}"),
           ("eig", "\\hd{eigen.\\\\seeds}")]


@table
def tab_leavein():
    """Leave one in (post hoc; leavein.py): for the core's largest losses and gains, n* (seeds 0, 1) of the core with one part
    put back, against the core and DFG alone on the same seeds.  Source: ablations.json 'leavein' and 'core'."""
    J = abl_json(); LI = J["leavein"]; C = J["core"]
    tg_all = []
    for cfg, _ in LEAVEIN:
        for k in LI.get(cfg, {}):
            if k not in tg_all:
                tg_all.append(k)
    rc = lambda k: num(C["ratios"][k])
    loss = sorted([k for k in tg_all if rc(k) > 0], key=lambda k: -rc(k)); gain = sorted([k for k in tg_all if rc(k) <= 0], key=rc)
    def row(k):
        su, t = k.split("/"); d = num(C["dfg_same_seeds"][k]); c = num(C["nstar"][k])
        cells = []
        for cfg, _ in LEAVEIN:
            v = LI.get(cfg, {}).get(k)
            if v is None:
                cells.append("")
            else:
                a = num(v["leavein"]); s = ns(a)
                if fin(a) and fin(d) and abs(math.log2(a / d)) <= THR and not (fin(c) and abs(math.log2(c / d)) <= THR):
                    s = "\\textbf{" + s + "}"
                cells.append(s)
        return f"{tg(t)} & {ns(d)} & {ns(c)} & {rt(rc(k))} & " + " & ".join(cells) + "\\\\"
    L = ["\\begin{tabular}{@{}lrrr" + "r" * len(LEAVEIN) + "@{}}", "\\toprule",
         "target & \\hd{DFG\\\\alone} & core & \\hd{core vs\\\\DFG alone} & " + " & ".join(h for _, h in LEAVEIN) + "\\\\", "\\midrule",
         f"\\multicolumn{{{4 + len(LEAVEIN)}}}{{@{{}}l}}{{\\emph{{the core needs more data}}}}\\\\"] + [row(k) for k in loss] + [
         f"\\multicolumn{{{4 + len(LEAVEIN)}}}{{@{{}}l}}{{\\emph{{the core needs less data}}}}\\\\"] + [row(k) for k in gain] + ["\\bottomrule", "\\end{tabular}"]
    write("tab_leavein", L)
    note("tab_leavein", runs={cfg: {k: {kk: num(vv) for kk, vv in v.items()} for k, v in LI.get(cfg, {}).items()} for cfg, _ in LEAVEIN},
         losses=loss, gains=gain)


# ---------------------------------------------------------------------------------------------------------------------------
def save_numbers():
    p = os.path.join(OUT, "numbers.json")
    old = json.load(open(p)) if os.path.exists(p) else {}
    old.update(NUM)
    old["_source"] = dict(results_json=os.path.relpath(RJ, HERE), generated_utc=R.get("generated_utc"), script="paper_dfg/make_tables.py")
    json.dump(old, open(p, "w"), indent=1, default=lambda v: None)
    print("wrote tables/numbers.json")


if __name__ == "__main__":
    names = sys.argv[1:] or list(TABLES)
    for nm in names:
        TABLES[nm]()
    save_numbers()
