"""Part 11 tables: DFG v1.3 ALONE (`dfg13-perm`, PROTOCOL.md) against the study's networks, v3, v2, lin, hgb and the
low-degree algorithm on the 11 toy suites (Q1 held out, Q2 every suite, Q3 lowdeg), its scaling with the input dimension
(Q4), its ablations (Q5), kr_vs_kp and mushroom (Q6), and its compute.  Writes RESULTS.md and RESULTS.json next to this
file.  Every number is computed from result files with compare_hybrid.py's definitions and compare_learner.py's choice
of reference files; none is typed by hand.  Runs still in progress are handled: a missing file is reported as 'not yet
run', a suite whose shards (__partNN) are not merged yet as 'partial'.  Re-run when the queue is done.
usage: python compare_dfg.py

DEFINITIONS (those of Parts 8-10; PROTOCOL.md, "Fixed in advance")
  n*         training-set size at which the seed-mean test error reaches 0.1, log-interpolated on the grid 16 .. 16384
             (discrete_learner/harness.nstar); 'never' if not reached by 16384 (networks at d = 120: by the end of each
             target's own grid, listed in Q4).
  ratio      'A vs B' = log2(n*_A / n*_B) per target (compare_hybrid.l2r): +inf if only B reaches 10% test error, -inf if
             only A does, n/a if neither.  Negative: A needs less data.
  summary    compare_hybrid.toy_summary: the mean ratio over the targets both reach; clearly better / worse: ratio < -0.25 /
             > +0.25, the infinite ratios included (only one of the two reaches 10% error).  Written
             'mean (clearly better / clearly worse) [both reach / targets compared]'.
  nets_best  per target the smallest n* among the network variants run on that suite (compare_learner.toy_tables;
             hindsight, favours the networks): nets (square loss), nets_wd (decoupled weight decay 0.1), nets_cewd
             (logistic loss + weight decay 0.1), nets_cewd0.3 / nets_cewd1.0 (weight decay 0.3 / 1.0), where run.
  pooled     per-target ratios pooled over suites (not a mean of suite means).
  same seeds (Q5) an ablation run on seeds {0, 1} or {0} is compared with DFG alone's n* computed from the same seeds of
             DFG alone's own runs: identical training sets and column permutations (the fit rng is
             default_rng([fn_seed(target), seed, n, 77]) and harness.Permuted draws the permutation from it first).
  cells      (Q6) compare_hybrid.cells: per (dataset, n) the seed-mean test error; better / worse when the errors differ by
             > 10% relative and by > 2 s.e. (seed spread of both, at least the binomial test-set noise).
SOURCES
  DFG alone  part11/results/toy__dfg13-perm__<suite>.json (eval_dfg.py: DFG(readout="logit").fit of
             part10/hyb_portfolio3/dfg13.py inside harness.Permuted); d-scaling: toy__dfg13-perm__designed_d<d>.json
  ablations  part11/results/toy__dfg13-<tag>-perm__<suite>.json;  lowdeg: part11/results/toy__lowdeg-perm__<suite>.json
  v3         hybrid/results/toy__p10_sum-perm__<suite>.json (v3 = p10_sum on toy inputs; part10/hyb_portfolio3/ASSEMBLY.md)
  v2         hybrid/results/toy__hyb_portfolio2-perm__<suite>.json, else toy__p9_sum-perm (compare_learner.v2_toy)
  lin, hgb   hybrid/results/toy__lin__<suite>.json, toy__hgb__<suite>.json (Part 8; natural column order)
  networks   compare_hybrid.toy_nstars: the networks' npz under the scratch results_<suite>[<variant suffix>] directories
             (else hybrid/results/nets_final_err.json); d-scaling: harness.nn_reference on the scratch results_d15,
             results (d = 30), results_d60, results_d120, checked against study/dscale.json
  Part 6 DFG discrete_learner/results/dfg-c1.0__designed_d15.json and dfg-c1.0__designed.json (v1),
             dfg-v1.1__designed_d60.json and dfg-v1.1__designed_d120.json (v1.1); natural column order
  tabular    standard_tasks/results/dfg13__<ds>.json (dfg_real.py) against the MLP references (compare_part9.ref), hgb,
             v3 = hyb_portfolio3 (compare_learner.v3_real), v2, v1; Part 7's DFG adaptations as context
"""
import os, sys, re, json, glob, time, hashlib, datetime, warnings
from collections import defaultdict
import numpy as np
warnings.filterwarnings("ignore", category=RuntimeWarning)               # nanmean over cells not run
HERE = os.path.dirname(os.path.abspath(__file__)); STUDY = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(STUDY, "hybrid")); sys.path.insert(0, os.path.join(STUDY, "part9"))
sys.path.append(os.path.join(STUDY, "part10")); sys.path.append(STUDY)
import compare_hybrid as CH                                               # noqa: E402  n*, l2r, toy_summary, cells
_argv = sys.argv; sys.argv = sys.argv[:1]
import compare_part9 as C9                                                # noqa: E402  ref (mlp_best+)
import compare_learner as CL                                              # noqa: E402  nst, v2_toy, v3_real, NETS, TOY
sys.argv = _argv
import boolfuncs                                                          # noqa: E402  the suites' target lists
TH, DATA = CH.TH, CH.DATA

RES11 = os.path.join(HERE, "results"); SCR = TH.SCR
QUEUE = os.path.join(SCR, "p11")                                          # the Part 11 queue (read only: logs)
THR = 0.25                                                                # clearly better / worse (toy_summary)
INF, NAN = float("inf"), float("nan")
DL = {"dlheld": "make_dl_heldout_suite", "dlheld2": "make_dl_heldout2_suite", "dlheld3": "make_dl_heldout3_suite",
      "dlsymdev": "make_dl_symdev_suite", "dlheld4": "make_dl_heldout4_suite", "dlheld5": "make_dl_heldout5_suite",
      "dlheld6": "make_dl_heldout6_suite", "dlfamdev": "make_dl_famdev_suite", "dlheld7": "make_dl_heldout7_suite"}  # = eval_dfg.DL
TOY = [su for su, _ in CL.TOY]                                            # the 11 suites, in Part 10's order
P10_HELD = [su for su, role in CL.TOY if role.startswith("held out")]     # Part 10's pooled held-out set
V13 = {"designed": "development (v1.1, v1.2, v1.3)", "random": "development (v1.1)", "dlheld": "development (v1.1)",
       "dlheld2": "held out for an earlier version only", "dlheld3": "held out for an earlier version only",
       "dlsymdev": "development (v1.2, v1.3)", "dlheld4": "exposed (v1.2 built after exposure)",
       "dlheld5": "exposed (v1.2 built after exposure)", "dlheld6": "development (v1.3)", "dlfamdev": "development (v1.3)",
       "dlheld7": "**held out** (the only suite)"}      # PROTOCOL.md "Held out"; v1.2's dev suites: part9/PROTOCOL.md
ABL = [("nosums", (0, 1), "no sum blocks"), ("strict", (0, 1), "stricter tests (delta)"),
       ("lenient", (0, 1), "more lenient tests (delta)"), ("noeig", (0, 1), "block search without eigenvector seeds"),
       ("noblocks", (0, 1), "no linear or spectral block"), ("nocomp", (0, 1), "no extension or local classes"),
       ("noweighted", (0,), "no weighted blocks (v1.2's class)"), ("nosmalln", (0,), "no forced variant, no small-n CV"),
       ("nobg", (0,), "no kernel background"), ("lsread", (0,), "least-squares readout"),
       ("K3", (0,), "global search to degree 3 only"), ("labelnoise", (0,), "tests scaled to the labels' noise")]  # PROTOCOL.md Q5
ABL_SUITES = ["designed", "dlsymdev", "dlfamdev", "dlheld6", "dlheld7"]
DSC = (15, 30, 60, 120)
OLD_DFG = {15: ("dfg-c1.0__designed_d15", "v1"), 30: ("dfg-c1.0__designed", "v1"), 60: ("dfg-v1.1__designed_d60", "v1.1"),
           120: ("dfg-v1.1__designed_d120", "v1.1")}
TAB = ("kr_vs_kp", "mushroom")
TAB_REFS = ("mlp", "mlp_reg", "mlp_strong", "mlp_wide", "mlp_xl", "mlp_best", "mlp_best+", "hgb", "v3", "v2", "v1")
TAB_CONTEXT = ("dfg_bits-v1", "dfg_dirs-v2", "dfg_gates-v1")              # Part 7's frozen DFG adaptations


# ---------------------------------------------------------------- loading
def _read(p):
    """A JSON file, or None if absent; retried while it is being written."""
    for k in range(4):
        try:
            with open(p) as f:
                return json.load(f)
        except FileNotFoundError:
            return None
        except (ValueError, OSError):
            time.sleep(1 + k)
    return None


_TG = {}


def targets(suite):
    """The suite's targets in suite order (boolfuncs, as merge.py); designed_d<d>: the networks' targets at that d."""
    if suite not in _TG:
        if suite == "designed":
            t = list(boolfuncs.make_suite(30))
        elif suite == "random":
            t = list(boolfuncs.make_random_suite(30))
        elif suite in DL:
            t = list(getattr(boolfuncs, DL[suite])(30))
        else:                                                             # designed_d<d>, as eval_dfg.run
            rdir = os.path.join(SCR, "results_d" + suite[len("designed_d"):])
            t = sorted(f[len("fixed_adam_"):-4] for f in os.listdir(rdir) if f.startswith("fixed_adam_")) if os.path.isdir(rdir) else []
        _TG[suite] = t
    return _TG[suite]


_RUN = {}


def run(name, suite):
    """(result, status) of a Part 11 toy run: the merged file, else the union of its finished shards."""
    key = (name, suite)
    if key in _RUN:
        return _RUN[key]
    want, merged = targets(suite), os.path.join(RES11, f"toy__{name}__{suite}.json")
    r, P = None, []
    for _ in range(3):
        r = _read(merged)
        if r is not None:
            break
        shards = sorted(glob.glob(os.path.join(RES11, f"toy__{name}__{suite}__part*.json")))
        P = [x for x in map(_read, shards) if x is not None]
        if len(P) == len(shards):
            break
        time.sleep(2)                                                     # a shard vanished: merged meanwhile
    src = "merged"
    if r is None:
        if not P:
            _RUN[key] = (None, "not yet run")
            return _RUN[key]
        r = dict(P[0]); r["fns"] = {}; src = f"{len(P)} unmerged shard" + "s" * (len(P) > 1)
        for x in P:
            r["fns"].update(x["fns"])
    r["fns"] = {**{t: r["fns"][t] for t in want if t in r["fns"]}, **{t: v for t, v in r["fns"].items() if t not in want}}
    k = sum(t in r["fns"] for t in want)
    st = ("complete" if k == len(want) else f"partial: {k} of {len(want)} targets") + ("" if src == "merged" else f" ({src})")
    _RUN[key] = (r, st)
    return _RUN[key]


def complete(name, suite):
    return run(name, suite)[1].startswith("complete")


def nst(r, seeds=None):
    """{target: n*} of a toy result (seed-mean error); with seeds, from those seeds of the run only ({} if one is missing)."""
    if r is None:
        return {}
    if seeds is None:
        idx = list(range(len(r["seeds"])))
    elif all(s in r["seeds"] for s in seeds):
        idx = [r["seeds"].index(s) for s in seeds]
    else:
        return {}
    return {fn: TH.nstar(r["ns"], np.nanmean(np.array(v["err"], float)[:, idx], 1)) for fn, v in r["fns"].items()}


_NETS = {}


def nets(suite):
    """({variant: {target: n*}}, nets_best) for the network variants run on a suite (as compare_learner.toy_tables)."""
    if suite not in _NETS:
        NR = {k: v for k, v in CH.toy_nstars(suite).items() if k in CL.NETS and v}
        fns = [t for t in targets(suite) if any(t in v for v in NR.values())]
        _NETS[suite] = (NR, {t: min(NR[k][t] for k in NR if t in NR[k]) for t in fns})
    return _NETS[suite]


def nets_argbest(suite):
    """{target: the variant(s) attaining nets_best} ('all' if every variant is 'never')."""
    NR, nb = nets(suite)
    return {t: ("all never" if not np.isfinite(nb[t]) else "/".join(k for k in CL.NETS if k in NR and NR[k].get(t) == nb[t])) for t in nb}


def net_seeds(suite):
    """{variant: seeds} of the networks run on a suite (read from one npz per variant directory)."""
    out = {}
    for k, suf in CH.NET_VARIANTS:
        d = CH.net_dir(suite, suf)
        f = sorted(x for x in os.listdir(d) if x.startswith("fixed_adam_") and x.endswith(".npz")) if os.path.isdir(d) else []
        if f:
            out[k] = sorted(set(int(s) for s in np.load(os.path.join(d, f[0]))["net_s"]))
    return out


def hyb_seeds(name, suite):
    r = CH.toy_load(name, suite)
    return None if r is None else r["seeds"]


def v2_name(suite):
    return "hyb_portfolio2-perm" if CH.toy_load("hyb_portfolio2-perm", suite) is not None else (
        "p9_sum-perm" if CH.toy_load("p9_sum-perm", suite) is not None else None)


# ---------------------------------------------------------------- statistics
def ratios(A, B):
    return {t: CH.l2r(A[t], B[t]) for t in A if t in B}


def pstats(R):
    """Statistics of a list of per-target ratios, with toy_summary's rule."""
    R = list(R); fin = [v for v in R if np.isfinite(v)]
    return dict(targets=len(R), both=len(fin), mean=float(np.mean(fin)) if fin else NAN,
                median=float(np.median(fin)) if fin else NAN, better=sum(1 for v in R if v < -THR),
                worse=sum(1 for v in R if v > THR), learner_never=sum(1 for v in R if v == INF),
                ref_never=sum(1 for v in R if v == -INF), neither=sum(1 for v in R if np.isnan(v)))


def summ(A, B):
    """compare_hybrid.toy_summary(A, B) plus both / neither / median and the per-target ratios; None without a common target."""
    if not A or not B or not any(t in B for t in A):
        return None
    t = CH.toy_summary(A, B); r = ratios(A, B); p = pstats(r.values())
    assert (t["targets"], t["better"], t["worse"], t["learner_never"]) == (p["targets"], p["better"], p["worse"], p["learner_never"])
    t.update(both=p["both"], neither=p["neither"], median=p["median"], ratios=r)
    return t


def expo(vals):
    """Least-squares slope of log n* on log d over the d with finite n* (as dscale_analysis.py); (slope or None, d used)."""
    pts = [(d, v) for d, v in sorted(vals.items()) if v is not None and np.isfinite(v)]
    if len(pts) < 2:
        return None, [d for d, _ in pts]
    return float(np.polyfit(np.log([p[0] for p in pts]), np.log([p[1] for p in pts]), 1)[0]), [p[0] for p in pts]


# ---------------------------------------------------------------- formatting
def f_n(v):
    return "–" if v is None else ("never" if not np.isfinite(v) else f"{v:.0f}")


def f_r(v):
    if v is None:
        return "–"
    return "+inf" if v == INF else "-inf" if v == -INF else "n/a" if np.isnan(v) else f"{v:+.2f}"


def f_m(v, p=2):
    return "n/a" if v is None or not np.isfinite(v) else f"{v:+.{p}f}"


def f_s(t):
    return "–" if not t else f"{f_m(t['mean'])} ({t['better']}/{t['worse']}) [{t['both']}/{t['targets']}]"


def f_seeds(s):
    return "–" if not s else ", ".join(str(x) for x in s)


def srow(lab, t, extra=""):
    """Markdown row of a summary: targets, both reach, mean, median, better, worse, learner never, ref never, neither."""
    if not t:
        return f"| {lab} |{extra} – | – | – | – | – | – | – | – | – |"
    return (f"| {lab} |{extra} {t['targets']} | {t['both']} | {f_m(t['mean'])} | {f_m(t['median'])} | {t['better']} | {t['worse']} | "
            f"{t['learner_never']} | {t['ref_never']} | {t['neither']} |")


SHEAD = "targets | both reach | mean log2 n* ratio | median | clearly better | clearly worse | never, the other reaches | the other never | neither |"
SSEP = "---|---|---|---|---|---|---|---|---|"


# ---------------------------------------------------------------- Q1
def q1():
    su = "dlheld7"
    r, st = run("dfg13-perm", su); D = nst(r)
    NR, nb = nets(su); ns_ = net_seeds(su)
    rl, stl = run("lowdeg-perm", su)
    cols = [("v3", CL.nst("p10_sum-perm", su)), ("v2", CL.v2_toy(su)), ("lin", CL.nst("lin", su)), ("hgb", CL.nst("hgb", su)),
            ("lowdeg", nst(rl))] + [(k, NR[k]) for k in CL.NETS if k in NR] + [("nets_best", nb)]
    L = ["## Q1. Held out: `dlheld7`", "",
         f"Numerical. DFG alone: `part11/results/toy__dfg13-perm__dlheld7.json` ({st}; seeds {f_seeds(r['seeds'] if r else None)}). "
         f"v3: `hybrid/results/toy__p10_sum-perm__dlheld7.json` (seeds {f_seeds(hyb_seeds('p10_sum-perm', su))}); "
         f"v2: `toy__{v2_name(su)}__dlheld7.json`; lin, hgb: `toy__lin__dlheld7.json`, `toy__hgb__dlheld7.json` (natural column order); "
         f"lowdeg: `part11/results/toy__lowdeg-perm__dlheld7.json` ({stl}); networks: "
         + ", ".join(f"{k} (seeds {f_seeds(ns_.get(k))})" for k in CL.NETS if k in NR) + " (scratch npz). "
         "n* per target; '–' = not run.", ""]
    out = dict(status=st, seeds=r["seeds"] if r else None, per_target={}, summary={}, context={})
    if not D:
        return L + ["DFG alone on `dlheld7`: not yet run.", ""], out
    L += ["| target | DFG alone | " + " | ".join(k for k, _ in cols) + " | DFG vs v3 | DFG vs nets_best |", "|---|---|" + "---|" * (len(cols) + 2)]
    V3 = dict(cols)["v3"]
    for t in targets(su):
        if t not in D:
            continue
        L.append(f"| {t} | {f_n(D[t])} | " + " | ".join(f_n(R.get(t)) for _, R in cols) + f" | "
                 f"{f_r(CH.l2r(D[t], V3[t]) if t in V3 else None)} | {f_r(CH.l2r(D[t], nb[t]) if t in nb else None)} |")
        out["per_target"][t] = dict(dfg=D[t], **{k: R.get(t) for k, R in cols})
    L += ["", "| DFG alone vs | " + SHEAD, "|---|" + SSEP]
    for k, R in cols:
        s = summ(D, R); out["summary"][k] = s
        L.append(srow(k, s))
    L += ["", "Context, the same summary for the references against `nets_best`:", "", "| learner vs nets_best | " + SHEAD, "|---|" + SSEP]
    for k in ("v3", "v2", "lowdeg", "lin", "hgb"):
        s = summ(dict(cols)[k], nb); out["context"][k] = s
        L.append(srow(k, s))
    return L + [""], out


# ---------------------------------------------------------------- Q2
def q2():
    L = ["## Q2. Every toy suite (d = 30)", "",
         "Numerical. DFG alone: `part11/results/toy__dfg13-perm__<suite>.json`; references as in the docstring "
         "(v3 = `toy__p10_sum-perm`, v2 = `toy__hyb_portfolio2-perm` or `toy__p9_sum-perm`, lin, hgb in `hybrid/results/`; lowdeg "
         "`part11/results/toy__lowdeg-perm__<suite>.json`; networks from the scratch npz). Cells: "
         "'mean (clearly better / clearly worse) [both reach / targets compared]', DFG alone vs the column. Status for v1.3: "
         "PROTOCOL.md, 'Held out'.", "",
         "| suite | status for DFG v1.3 | DFG alone run | targets | vs nets_best | vs each network variant: min / max mean (variants) "
         "| vs v3 | vs v2 | vs lin | vs hgb | vs lowdeg | DFG never | context: v3 vs nets_best |",
         "|---|---|---|---|---|---|---|---|---|---|---|---|---|"]
    out, pool, inc, v3cmp, cworse, dnever = {}, defaultdict(list), [], [], [], []
    for su in TOY:
        r, st = run("dfg13-perm", su); D = nst(r); NR, nb = nets(su)
        V3 = CL.nst("p10_sum-perm", su)
        refs = {"nets_best": nb, **{k: NR[k] for k in CL.NETS if k in NR}, "v3": V3, "v2": CL.v2_toy(su),
                "lin": CL.nst("lin", su), "hgb": CL.nst("hgb", su), "lowdeg": nst(run("lowdeg-perm", su)[0])}
        if not complete("dfg13-perm", su):
            inc.append(su)
        if not D:
            L.append(f"| {su} | {V13[su]} | {st} | {len(targets(su))} | | | | | | | | | |"); out[su] = dict(status=st); continue
        S = {k: summ(D, R) for k, R in refs.items()}
        ctx = summ({t: V3[t] for t in D if t in V3}, nb)
        mm = [S[k]["mean"] for k in NR if S.get(k) and np.isfinite(S[k]["mean"])]
        never = sum(1 for v in D.values() if not np.isfinite(v))
        L.append(f"| {su} | {V13[su]} | {st} | {len(D)} | {f_s(S['nets_best'])} | "
                 + (f"{min(mm):+.2f} / {max(mm):+.2f} ({len(mm)})" if mm else "no networks run") + " | "
                 + " | ".join(f_s(S[k]) for k in ("v3", "v2", "lin", "hgb", "lowdeg")) + f" | {never} of {len(D)} | {f_s(ctx)} |")
        for k, s in S.items():
            if s:
                pool[k] += [(su, t, v) for t, v in s["ratios"].items()]
        if ctx:
            pool["_v3_vs_nets_best"] += [(su, t, v) for t, v in ctx["ratios"].items()]
        ab = nets_argbest(su)
        for t in D:
            if t in V3:
                v3cmp.append(dict(suite=su, target=t, dfg=D[t], v3=V3[t], ratio=CH.l2r(D[t], V3[t]),
                                  identical=bool(D[t] == V3[t]), v2=refs["v2"].get(t), nets_best=nb.get(t)))
            if t in nb and CH.l2r(D[t], nb[t]) > THR:
                cworse.append(dict(suite=su, target=t, dfg=D[t], nets_best=nb[t], variant=ab.get(t), v3=V3.get(t)))
            if not np.isfinite(D[t]):
                dnever.append(dict(suite=su, target=t, v3=V3.get(t), nets_best=nb.get(t), lowdeg=refs["lowdeg"].get(t)))
        out[su] = dict(status=st, v13_status=V13[su], targets=len(D), dfg_never=never, dfg=D, summary=S, v3_vs_nets_best=ctx,
                       v2_file=v2_name(su), network_variants=sorted(NR), network_seeds=net_seeds(su))
    prov = (" **Provisional**: DFG alone is not complete on " + ", ".join(f"`{s}`" for s in inc) + ".") if inc else ""
    L += ["", "### Pooled over the suites (per-target ratios pooled)", "",
          "Numerical; same sources." + prov, "",
          "| DFG alone vs | suites | " + SHEAD, "|---|---|" + SSEP]
    out["_pooled"] = {}
    for k in ["nets_best"] + list(CL.NETS) + ["v3", "v2", "lin", "hgb", "lowdeg"]:
        if not pool.get(k):
            continue
        s = pstats(v for _, _, v in pool[k]); s["suites"] = sorted({su for su, _, _ in pool[k]}, key=TOY.index)
        out["_pooled"][k] = s
        L.append(srow(k, s, f" {len(s['suites'])} |"))
    # Part 10's pooled held-out set, DFG alone and v3 on the same targets
    hd = [x for x in pool["nets_best"] if x[0] in P10_HELD]; hv = [x for x in pool["_v3_vs_nets_best"] if x[0] in P10_HELD]
    sd, sv = pstats(v for _, _, v in hd), pstats(v for _, _, v in hv)
    sd["suites"] = sv["suites"] = sorted({su for su, _, _ in hd}, key=TOY.index)
    out["_pooled_p10_heldout"] = dict(dfg_vs_nets_best=sd, v3_vs_nets_best=sv)
    L += ["", f"On Part 10's pooled held-out set ({', '.join(f'`{s}`' for s in P10_HELD)}; suites with DFG alone run: {len(sd['suites'])}), "
              "against `nets_best`, on the same targets:", "", "| learner vs nets_best | suites | " + SHEAD, "|---|---|" + SSEP,
          srow("DFG alone", sd, f" {len(sd['suites'])} |"), srow("v3", sv, f" {len(sv['suites'])} |")]
    out["dfg_clearly_worse_than_nets_best"] = cworse; out["dfg_never"] = dnever
    L += ["", f"Targets where DFG alone is clearly worse than `nets_best` (ratio > +{THR}, or only the networks reach 10% error): "
              f"{len(cworse)} of {len(pool['nets_best'])}." + prov, ""]
    if cworse:
        L += ["| suite | target | DFG alone | nets_best (variant) | DFG vs nets_best | v3 |", "|---|---|---|---|---|---|"]
        L += [f"| {x['suite']} | {x['target']} | {f_n(x['dfg'])} | {f_n(x['nets_best'])} ({x['variant']}) | "
              f"{f_r(CH.l2r(x['dfg'], x['nets_best']))} | {f_n(x['v3'])} |" for x in cworse]
    L += ["", f"Targets DFG alone never brings to 10% test error by n = 16384: {len(dnever)} of "
              f"{sum(len(o.get('dfg', {})) for o in out.values() if isinstance(o, dict))}: "
              + (", ".join(f"{x['suite']}/{x['target']} (v3 {f_n(x['v3'])}, nets_best {f_n(x['nets_best'])}, lowdeg {f_n(x['lowdeg'])})"
                           for x in dnever) or "none") + "."]
    # DFG alone against v3, target by target
    R = [x["ratio"] for x in v3cmp]; ident = sum(x["identical"] for x in v3cmp)
    lower = sum(1 for v in R if v < 0); higher = sum(1 for v in R if v > 0); m = lower + higher
    ps = pstats(R); p = CH.sign_p(lower, m) if m else NAN
    out["dfg_vs_v3"] = dict(targets=len(R), identical=ident, lower=lower, higher=higher, sign_test_p=p, stats=ps, per_target=v3cmp)
    L += ["", "### DFG alone against v3, target by target", "",
          f"Numerical. Over {len(R)} targets (the suites where DFG alone has run): identical n* on {ident}; DFG alone lower on "
          f"{lower} (by more than {THR}: {ps['better']}), higher on {higher} (by more than {THR}: {ps['worse']}); mean log2 n* ratio "
          f"DFG / v3 {f_m(ps['mean'], 3)}, median {f_m(ps['median'], 3)}, over the {ps['both']} targets both reach; DFG alone never "
          f"where v3 reaches: {ps['learner_never']}; v3 never where DFG alone reaches: {ps['ref_never']}; neither: {ps['neither']}. "
          f"Two-sided sign test over the {m} targets with unequal n*: p = {p:.2g}." + prov, "",
          "| suite | targets | identical n* | DFG lower / higher | clearly lower / higher (beyond ±0.25) | mean DFG vs v3 (both reach) |",
          "|---|---|---|---|---|---|"]
    for su in TOY:
        X = [x for x in v3cmp if x["suite"] == su]
        if not X:
            continue
        q = pstats(x["ratio"] for x in X)
        L.append(f"| {su} | {len(X)} | {sum(x['identical'] for x in X)} | {sum(1 for x in X if x['ratio'] < 0)} / "
                 f"{sum(1 for x in X if x['ratio'] > 0)} | {q['better']} / {q['worse']} | {f_m(q['mean'], 3)} |")
    big = [x for x in v3cmp if abs(x["ratio"]) > THR]
    L += ["", f"Targets where DFG alone and v3 differ by more than {THR} in log2 n* (or only one reaches 10% error): {len(big)}.", ""]
    if big:
        L += ["| suite | target | DFG alone | v3 | DFG vs v3 | v2 | nets_best |", "|---|---|---|---|---|---|---|"]
        L += [f"| {x['suite']} | {x['target']} | {f_n(x['dfg'])} | {f_n(x['v3'])} | {f_r(x['ratio'])} | {f_n(x['v2'])} | {f_n(x['nets_best'])} |"
              for x in big]
    return L + [""], out


# ---------------------------------------------------------------- Q3
def q3():
    L = ["## Q3. The dictionary without the search: `lowdeg`", "",
         "Numerical. lowdeg: `part11/results/toy__lowdeg-perm__<suite>.json` (discrete_learner/sparse_fourier.py, inputs permuted); "
         "DFG alone and networks as in Q2. Ratios are lowdeg vs the column (positive: lowdeg needs more data).", "",
         "| suite | lowdeg run | targets | lowdeg vs DFG alone | lowdeg vs nets_best | lowdeg never | DFG never | lowdeg reaches, DFG never | DFG reaches, lowdeg never |",
         "|---|---|---|---|---|---|---|---|---|"]
    out, pl, pn, inc = {}, [], [], []
    for su in TOY:
        rl, st = run("lowdeg-perm", su); LD = nst(rl); D = nst(run("dfg13-perm", su)[0]); NR, nb = nets(su)
        if not complete("lowdeg-perm", su) or not complete("dfg13-perm", su):
            inc.append(su)
        if not LD:
            L.append(f"| {su} | {st} | {len(targets(su))} | | | | | | |"); out[su] = dict(status=st); continue
        s1, s2 = summ(LD, D), summ(LD, nb)
        ol = [t for t in LD if t in D and np.isfinite(LD[t]) and not np.isfinite(D[t])]
        od = [t for t in LD if t in D and np.isfinite(D[t]) and not np.isfinite(LD[t])]
        L.append(f"| {su} | {st} | {len(LD)} | {f_s(s1)} | {f_s(s2) if nb else 'no networks run'} | "
                 f"{sum(1 for v in LD.values() if not np.isfinite(v))} of {len(LD)} | "
                 f"{sum(1 for t in LD if t in D and not np.isfinite(D[t]))} of {sum(1 for t in LD if t in D)} | "
                 f"{', '.join(ol) or '–'} | {', '.join(od) or '–'} |")
        if s1:
            pl += [(su, t, v) for t, v in s1["ratios"].items()]
        if s2:
            pn += [(su, t, v) for t, v in s2["ratios"].items()]
        out[su] = dict(status=st, lowdeg=LD, vs_dfg=s1, vs_nets_best=s2, lowdeg_only=ol, dfg_only=od)
    if pl:
        a, b = pstats(v for *_, v in pl), pstats(v for *_, v in pn)
        a["suites"] = sorted({x[0] for x in pl}, key=TOY.index); b["suites"] = sorted({x[0] for x in pn}, key=TOY.index)
        R = [v for *_, v in pl]
        band = dict(clearly_lower=sum(1 for v in R if v < -THR and np.isfinite(v)),
                    within=sum(1 for v in R if np.isfinite(v) and abs(v) <= THR),
                    clearly_higher=sum(1 for v in R if v > THR and np.isfinite(v)), only_lowdeg=sum(1 for v in R if v == -INF),
                    only_dfg=sum(1 for v in R if v == INF), neither=sum(1 for v in R if np.isnan(v)))
        out["_pooled"] = dict(vs_dfg=a, vs_nets_best=b, bands=band)
        L += ["", "Pooled (per-target ratios)." + (" **Provisional**: lowdeg or DFG alone not complete on "
                                                  + ", ".join(f"`{s}`" for s in inc) + "." if inc else ""), "",
              "| lowdeg vs | suites | " + SHEAD, "|---|---|" + SSEP, srow("DFG alone", a, f" {len(a['suites'])} |"),
              srow("nets_best", b, f" {len(b['suites'])} |"), "",
              f"lowdeg against DFG alone, per target: lower by more than {THR}: {band['clearly_lower']}; within ±{THR}: {band['within']}; "
              f"higher by more than {THR}: {band['clearly_higher']}; only lowdeg reaches 10% error: {band['only_lowdeg']}; only DFG alone: "
              f"{band['only_dfg']}; neither: {band['neither']} (of {len(R)})."]
    return L + [""], out


# ---------------------------------------------------------------- Q4
def nn_full(fn, rdir):
    """Networks' n* on the npz's own grid (beyond 16384 where run), the grid's ends and the seeds."""
    p = os.path.join(rdir, f"fixed_adam_{fn}.npz")
    if not os.path.exists(p):
        return None
    z = np.load(p); ns = [int(v) for v in z["ns"]]
    I = {(int(n), int(s)): j for j, (n, s) in enumerate(zip(z["net_n"], z["net_s"]))}
    sd = sorted(set(int(s) for s in z["net_s"]))
    e = [float(np.mean(np.array([z["test_err"][-1, I[(n, s)]] for s in sd if (n, s) in I], float))) for n in ns]
    return dict(nstar=TH.nstar(ns, e), lo=ns[0], hi=ns[-1], seeds=sd)


def same_n(a, b, tol=1e-6):
    """Equal n* up to float rounding (both 'never' counts as equal)."""
    if not np.isfinite(a) or not np.isfinite(b):
        return not np.isfinite(a) and not np.isfinite(b)
    return abs(np.log2(a / b)) < tol


def q4():
    fns = sorted(set().union(*[set(targets(f"designed_d{d}")) for d in DSC if d != 30]))
    X = _read(os.path.join(STUDY, "dscale.json")) or {"rows": {}, "exponents": {}}
    NR30, _ = nets("designed")
    DF, DF01, NN, GRID, OLD, ST, FL = {}, {}, {}, {}, {}, {}, {}
    for d in DSC:
        r, st = run("dfg13-perm", "designed" if d == 30 else f"designed_d{d}"); ST[d] = (st, r["seeds"] if r else None)
        DF[d] = {t: v for t, v in nst(r).items() if t in fns}
        if d == 30:
            DF01 = {t: v for t, v in nst(r, seeds=[0, 1]).items() if t in fns}
        rdir = os.path.join(SCR, "results" if d == 30 else f"results_d{d}")
        NN[d] = {t: TH.nstar(TH.NS, np.nanmean(e, 1)) for t in fns for e in [TH.nn_reference(t, rdir)] if e is not None}
        GRID[d] = {t: g for t in fns for g in [nn_full(t, rdir)] if g is not None}
        o = _read(os.path.join(STUDY, "discrete_learner", "results", OLD_DFG[d][0] + ".json"))
        OLD[d] = {t: v for t, v in nst(o).items() if t in fns}
        FL[d] = max((np.nanmax(np.array(v["flops"], float)) / r["gd_flops"] for t, v in r["fns"].items() if t in fns), default=None) if r else None
    L = ["## Q4. Input dimension: the `designed` targets the networks were trained on at d = 15, 60, 120", "",
         "Numerical. DFG v1.3 alone: `part11/results/toy__dfg13-perm__designed_d<d>.json` ("
         + "; ".join(f"d = {d}: {ST[d][0]}, seeds {f_seeds(ST[d][1])}" for d in DSC if d != 30)
         + f") and at d = 30 `toy__dfg13-perm__designed.json` ({ST[30][0]}, seeds {f_seeds(ST[30][1])}). Networks: `nets` (square "
         "loss; the only variant run at every d), harness.nn_reference on the scratch `results_d15`, `results`, `results_d60`, "
         "`results_d120` npz (seeds per d below; 40000 steps at d = 120, 20000 otherwise). Part 6 DFG: "
         + ", ".join(f"d = {d}: `discrete_learner/results/{OLD_DFG[d][0]}.json` ({OLD_DFG[d][1]})" for d in DSC)
         + ", natural column order. Exponent: least-squares slope of log n* on log d over the d with finite n* (as "
         "dscale_analysis.py), the d used in brackets.", "",
         "| target | DFG v1.3 n* at d = " + " / ".join(map(str, DSC)) + " | networks n* | Part 6 DFG n* | exponent DFG v1.3 | exponent networks "
         "| exponent Part 6 DFG | networks' exponent in dscale.json (d = 15-60) |", "|---|---|---|---|---|---|---|---|"]
    out = dict(targets=fns, status={d: ST[d][0] for d in DSC}, per_target={}, per_d={})
    fe = lambda e: "–" if e[0] is None else f"{e[0]:.2f} ({', '.join(map(str, e[1]))})"
    for t in fns:
        a = {d: DF[d].get(t) for d in DSC}; b = {d: NN[d].get(t) for d in DSC}; c = {d: OLD[d].get(t) for d in DSC}
        ea, eb, ec = expo(a), expo(b), expo(c)
        xe = X.get("exponents", {}).get(t, {}).get("nn")
        L.append(f"| {t} | " + " / ".join(f_n(a[d]) for d in DSC) + " | " + " / ".join(f_n(b[d]) for d in DSC) + " | "
                 + " / ".join(f_n(c[d]) for d in DSC) + f" | {fe(ea)} | {fe(eb)} | {fe(ec)} | {'–' if xe is None else f'{xe:.2f}'} |")
        out["per_target"][t] = dict(dfg13=a, nets=b, part6_dfg=c, dfg13_d30_seeds01=DF01.get(t), exponent_dfg13=ea[0], d_dfg13=ea[1],
                                    exponent_nets=eb[0], d_nets=eb[1], exponent_part6=ec[0], d_part6=ec[1], exponent_nets_dscale_json=xe,
                                    nets_grid={d: GRID[d].get(t) for d in DSC})
    L += ["", "| d | targets | both reach (DFG v1.3, networks) | median DFG v1.3 vs networks | median data factor | mean | Part 6 DFG vs networks: "
              "both reach / median / mean | DFG v1.3 vs Part 6 DFG: both reach / median | DFG v1.3 max FLOPs per fit / one network run |",
          "|---|---|---|---|---|---|---|---|---|"]
    for d in DSC:
        A = {t: v for t, v in DF[d].items() if v is not None}; B = NN[d]; C = OLD[d]
        ra, rc, rac = pstats(ratios(A, B).values()), pstats(ratios(C, B).values()), pstats(ratios(A, C).values())
        out["per_d"][d] = dict(dfg_vs_nets=ra, part6_vs_nets=rc, dfg_vs_part6=rac, max_flops_frac=FL[d],
                               nets_seeds=sorted({s for g in GRID[d].values() for s in g["seeds"]}))
        L.append(f"| {d} | {len(A)} | {ra['both']} | {f_m(ra['median'])} | "
                 + ("–" if not np.isfinite(ra["median"]) else f"{2 ** -ra['median']:.1f}x") + f" | {f_m(ra['mean'])} | "
                 f"{rc['both']} / {f_m(rc['median'])} / {f_m(rc['mean'])} | {rac['both']} / {f_m(rac['median'])} | "
                 + ("–" if FL[d] is None else f"{FL[d]:.2f}") + " |")
    # checks and grids
    dev = [abs(np.log2(NN[d][t] / X["rows"][str(d)][t]["nn"])) for d in (15, 30, 60) for t in fns
           if t in NN[d] and str(d) in X.get("rows", {}) and t in X["rows"][str(d)] and np.isfinite(NN[d][t])
           and X["rows"][str(d)][t].get("nn") is not None and X["rows"][str(d)][t]["nn"] < 1e98]
    d01 = [abs(CH.l2r(DF01[t], DF[30][t])) for t in fns if t in DF01 and t in DF[30] and np.isfinite(DF01[t]) and np.isfinite(DF[30][t])]
    grids = "; ".join(f"d = {d}: " + ", ".join(f"{t} {g['lo']}–{g['hi']}" for t, g in GRID[d].items()) for d in DSC
                      if any(g["lo"] != TH.NS[0] or g["hi"] != TH.NS[-1] for g in GRID[d].values()))
    full = [(d, t) for d in DSC for t, g in GRID[d].items() if t in NN[d] and not same_n(g["nstar"], NN[d][t])]
    out["checks"] = dict(nets_vs_dscale_json_max_abs_log2=max(dev) if dev else None, compared=len(dev),
                         d30_seeds01_vs_all_max_abs_log2=max(d01) if d01 else None, full_grid_differs=full)
    L += ["", "Checks (Numerical): the networks' n* here against `study/dscale.json` (d = 15, 30, 60): largest |log2 difference| "
              + (f"{max(dev):.3g} over {len(dev)} (target, d)" if dev else "not computable") + ". DFG v1.3 at d = 30 uses seeds 0, 1, 2 "
              "(the d = 30 networks have 3 seeds); from seeds 0, 1 only, its n* differs by at most "
              + (f"{max(d01):.2f}" if d01 else "–") + " in log2 over the targets both versions reach. "
              + ("Networks' grids not 16–16384: " + grids + ". " if grids else "")
              + ("n* on the networks' full npz grid differs from the 16–16384 value at: " + ", ".join(f"{t}@d={d}" for d, t in full) + "."
                 if full else "n* on the networks' full npz grid (to 65536 at d = 60) equals the 16–16384 value everywhere."),
          "", "Network seeds per d: " + "; ".join(f"d = {d}: {f_seeds(out['per_d'][d]['nets_seeds'])}" for d in DSC) + "."]
    return L + [""], out


# ---------------------------------------------------------------- Q5
def q5():
    base = {su: run("dfg13-perm", su)[0] for su in ABL_SUITES}
    L = ["## Q5. What the parts do: ablations", "",
         f"Numerical. Ablations: `part11/results/toy__dfg13-<tag>-perm__<suite>.json` on {', '.join(f'`{s}`' for s in ABL_SUITES)} "
         f"({sum(len(targets(s)) for s in ABL_SUITES)} targets). Ratio = log2(n*_ablation / n*_DFG alone), DFG alone's n* computed "
         "from the same seeds of its own runs (paired: identical training sets and column permutations). 'lower' = the ablation "
         "needs less data; 'newly never' = the ablation never reaches 10% error where DFG alone does; 'newly reached' = the reverse.", "",
         "### Pooled over the five suites", "",
         "| ablation | change (constructor kw, from the file) | seeds | suites run | targets | both reach | mean log2 ratio | median "
         f"| ablation lower (< -{THR}) | ablation higher (> +{THR}) | newly never | newly reached |", "|---|---|---|---|---|---|---|---|---|---|---|---|"]
    out, per, moved = {}, [], {}
    for tag, ps, what in ABL:
        rows, R, kw, seeds = {}, [], None, set()
        for su in ABL_SUITES:
            ra, st = run(f"dfg13-{tag}-perm", su)
            if ra is None:
                rows[su] = dict(status=st); per.append((tag, su, st, None, None)); continue
            kw = ra.get("kw", kw); sd = ra["seeds"]; seeds.add(tuple(sd))
            A = nst(ra); B = nst(base[su], seeds=sd); s = summ(A, B)
            nn_ = [t for t, v in (s["ratios"].items() if s else []) if v == INF]
            nr_ = [t for t, v in (s["ratios"].items() if s else []) if v == -INF]
            rows[su] = dict(status=st, seeds=sd, kw=ra.get("kw"), summary=s, newly_never=nn_, newly_reached=nr_,
                            ablation=A, dfg_same_seeds=B, protocol_seeds=list(ps), seeds_as_protocol=tuple(sd) == tuple(ps))
            per.append((tag, su, st, sd, s))
            if s:
                R += [(su, t, v) for t, v in s["ratios"].items()]
        P = pstats(v for *_, v in R)
        newly_never = [f"{su}/{t}" for su, t, v in R if v == INF]; newly_reached = [f"{su}/{t}" for su, t, v in R if v == -INF]
        moved[tag] = [(su, t, v) for su, t, v in R if abs(v) > THR]
        nrun = sum(1 for su in ABL_SUITES if rows[su].get("seeds") is not None)
        out[tag] = dict(what=what, kw=kw, protocol_seeds=list(ps), suites=rows, pooled=P, newly_never=newly_never, newly_reached=newly_reached)
        sd_txt = f_seeds(sorted(seeds)[0]) if len(seeds) == 1 else ("–" if not seeds else "mixed: " + "; ".join(f_seeds(s) for s in sorted(seeds)))
        if not R:
            L.append(f"| {tag} | {what}: {json.dumps(kw) if kw is not None else '–'} | {sd_txt if seeds else f_seeds(ps) + ' (protocol)'} | "
                     f"{nrun} of {len(ABL_SUITES)} | – | – | – | – | – | – | – | – |"); continue
        L.append(f"| {tag} | {what}: `{json.dumps(kw)}` | {sd_txt} | {nrun} of {len(ABL_SUITES)} | {P['targets']} | {P['both']} | "
                 f"{f_m(P['mean'])} | {f_m(P['median'])} | {P['better']} | {P['worse']} | {', '.join(newly_never) or '–'} | {', '.join(newly_reached) or '–'} |")
    # null reference: DFG alone on one seed against another seed (no change; unpaired data)
    out["_null"] = {}
    for a, b in ((1, 0), (2, 0)):
        R = []
        for su in ABL_SUITES:
            A, B = nst(base[su], seeds=[a]), nst(base[su], seeds=[b])
            R += list(ratios(A, B).values())
        P = pstats(R); out["_null"][f"seed{a}_vs_seed{b}"] = P
        if R:
            L.append(f"| null: DFG alone, seed {a} vs seed {b} | no change; different training sets (unpaired) | {a} vs {b} | "
                     f"{sum(1 for su in ABL_SUITES if base[su] is not None)} of {len(ABL_SUITES)} | {P['targets']} | {P['both']} | "
                     f"{f_m(P['mean'])} | {f_m(P['median'])} | {P['better']} | {P['worse']} | {P['learner_never']} | {P['ref_never']} |")
    L += ["", "The null rows compare single seeds of DFG alone with each other (different training sets), so they bound the "
              "seed-to-seed spread of a one-seed n*; the ablation rows are paired (same training sets), whose spread this overstates.", "",
          "### Per suite", "", "| ablation | suite | run | seeds | targets | both reach | mean log2 ratio | ablation lower | ablation higher | newly never | newly reached |",
          "|---|---|---|---|---|---|---|---|---|---|---|"]
    for tag, su, st, sd, s in per:
        if s is None:
            L.append(f"| {tag} | {su} | {st} | {f_seeds(sd)} | – | – | – | – | – | – | – |"); continue
        L.append(f"| {tag} | {su} | {st} | {f_seeds(sd)} | {s['targets']} | {s['both']} | {f_m(s['mean'])} | {s['better']} | {s['worse']} | "
                 f"{', '.join(t for t, v in s['ratios'].items() if v == INF) or '–'} | {', '.join(t for t, v in s['ratios'].items() if v == -INF) or '–'} |")
    L += ["", f"### Targets moved by more than {THR} in log2 n* (ablation vs DFG alone, same seeds)", ""]
    for tag, *_ in ABL:
        if out[tag]["pooled"]["targets"]:
            mv = sorted(moved[tag], key=lambda x: -abs(x[2]) if np.isfinite(x[2]) else -1e9)
            L.append(f"- `{tag}` ({len(mv)} of {out[tag]['pooled']['targets']}): " + (", ".join(f"{su}/{t} ({f_r(v)})" for su, t, v in mv) or "none"))
    if not any(out[tag]["pooled"]["targets"] for tag, *_ in ABL):
        L.append("No ablation has run yet.")
    return L + [""], out


# ---------------------------------------------------------------- Q6
def tab_ref(k, ds):
    if k == "v3":
        return CL.v3_real(ds)
    if k in ("v2", "v1"):
        return CH.load({"v2": "hyb_portfolio2", "v1": "hyb_portfolio"}[k], ds)
    return CH.load(k, ds) if k in ("mlp_wide", "mlp_xl") + TAB_CONTEXT else C9.ref(k, ds)


def cell_mean(r, n, key="err"):
    if r is None or n not in r["ns"][:len(r.get(key, []))]:
        return None
    v = np.array(r[key][r["ns"].index(n)], float)
    return float(np.nanmean(v)) if np.isfinite(v).any() else None


def q6():
    L = ["## Q6. Tabular: kr_vs_kp and mushroom", "",
         "Numerical. DFG alone: `standard_tasks/results/dfg13__<ds>.json` (dfg_real.py: binary / categorical inputs one-hot as ±1, "
         "v3's DFG view; standard learning curves, seeds 0, 1, 2). References in `standard_tasks/results/`: the MLP variants "
         "(compare_part9.ref: mlp_reg = mlp_l2; mlp_best = the per-cell best of Part 8's MLP variants by test error, hindsight; "
         "mlp_best+ adds Part 9's wider ones), hgb, v3 = `hyb_portfolio3` (compare_learner.v3_real), v2, v1. Cell rule: "
         "compare_hybrid.cells. kr_vs_kp is a development set of the standard tasks; mushroom is in Part 7's held-out set.", ""]
    out = {}
    have = {ds: CH.load("dfg13", ds) for ds in TAB}
    if not any(have.values()):
        return L + ["DFG alone on kr_vs_kp and mushroom: not yet run.", ""], dict(status="not yet run")
    L += ["| DFG alone vs | dataset | cells | better | tie | worse | mean log2(err / ref err) |", "|---|---|---|---|---|---|---|"]
    pooled = defaultdict(list)
    for ds in TAB:
        r = have[ds]; out[ds] = dict(status="complete" if r is not None else "not yet run", summary={})
        if r is None:
            L.append(f"| – | {ds} | not yet run | | | | |"); continue
        for k in TAB_REFS:
            c = CH.cells(r, tab_ref(k, ds), ds)
            if not c:
                continue
            v = [x["v"] for x in c]; pooled[k] += c
            out[ds]["summary"][k] = dict(cells=len(c), better=v.count("better"), tie=v.count("tie"), worse=v.count("worse"),
                                        mean=float(np.mean([x["lr"] for x in c])), per_cell=c)
            L.append(f"| {k} | {ds} | {len(c)} | {v.count('better')} | {v.count('tie')} | {v.count('worse')} | {np.mean([x['lr'] for x in c]):+.3f} |")
    for k in TAB_REFS:
        c = pooled.get(k)
        if c:
            v = [x["v"] for x in c]
            L.append(f"| {k} | both | {len(c)} | {v.count('better')} | {v.count('tie')} | {v.count('worse')} | {np.mean([x['lr'] for x in c]):+.3f} |")
    cols = ["dfg13"] + list(TAB_REFS) + list(TAB_CONTEXT)
    L += ["", "Test error per cell (seed mean); the last three columns are Part 7's DFG adaptations (context).", "",
          "| dataset | n | " + " | ".join(cols) + " |", "|---|---|" + "---|" * len(cols)]
    for ds in TAB:
        R = {c: (have[ds] if c == "dfg13" else tab_ref(c, ds)) for c in cols}
        ns = sorted({n for x in R.values() if x for n in x["ns"][:len(x["err"])]})
        out.setdefault(ds, {})["errors"] = {}
        for n in ns:
            vals = {c: cell_mean(R[c], n) for c in cols}; out[ds]["errors"][n] = vals
            vb = ""
            if R["mlp_best"] is not None and n in R["mlp_best"]["ns"]:
                vb = f" ({R['mlp_best']['variant'][R['mlp_best']['ns'].index(n)]})"
            L.append(f"| {ds} | {n} | " + " | ".join(("–" if vals[c] is None else f"{vals[c]:.4f}") + (vb if c == "mlp_best" and vals[c] is not None else "")
                                                     for c in cols) + " |")
    # compute
    L += ["", "Compute per fit: DFG alone's FLOPs as a fraction of the standard-task budget (3 MLP runs, hybrid/common.budget_real; "
              "max over seeds) and CPU seconds per fit (process time, seed mean), with v3's CPU seconds on the same cells.", "",
          "| dataset | n | DFG FLOPs / budget | DFG CPU s | v3 CPU s |", "|---|---|---|---|---|"]
    for ds in TAB:
        r = have[ds]
        if r is None:
            continue
        D = DATA.load(ds); pool_, _ = DATA.splits(D, 0); v3 = CL.v3_real(ds)
        out[ds]["compute"] = {}
        for i, n in enumerate(r["ns"][:len(r["flops"])]):
            f = np.array(r["flops"][i], float)
            fr = float(np.nanmax(f)) / CH.common.budget_real(D["X"][pool_[:n]], list(D["types"]), D["C"], n) if np.isfinite(f).any() else None
            c, cv = cell_mean(r, n, "cpu_seconds"), cell_mean(v3, n, "cpu_seconds")
            out[ds]["compute"][n] = dict(flops_frac=fr, cpu=c, v3_cpu=cv)
            L.append(f"| {ds} | {n} | {'–' if fr is None else f'{fr:.3f}'} | {'–' if c is None else f'{c:.1f}'} | {'–' if cv is None else f'{cv:.1f}'} |")
    return L + [""], out


# ---------------------------------------------------------------- compute
def compute():
    L = ["## Compute and CPU time", "",
         "Numerical. FLOPs: DFG's own count (multiply-add = 2) per fit, as a fraction of one network run at that d (the file's "
         "`gd_flops` = harness.gd_flops(d)). CPU seconds: the harness's process time per fit (the fit only), measured while the "
         f"Part 11 queue ran {len(glob.glob(os.path.join(QUEUE, 'logs', 'worker_*.log'))) or 'several'} worker processes in parallel at "
         f"nice 10 on a machine with {os.cpu_count()} CPUs; v3's were measured in Part 10, under that run's own load, so CPU "
         "comparisons are rough.", "",
         "| run | suite | d | fits | max FLOPs per fit / one network run (target, n) | fits above 0.75 of a run | CPU s per fit: median / max |",
         "|---|---|---|---|---|---|---|"]
    out = dict(runs={}, by_n={})
    jobs = [("dfg13-perm", su) for su in TOY] + [("dfg13-perm", f"designed_d{d}") for d in DSC if d != 30] + \
           [("lowdeg-perm", su) for su in TOY] + [(f"dfg13-{tag}-perm", su) for tag, *_ in ABL for su in ABL_SUITES]
    agg = defaultdict(lambda: dict(fits=0, fmax=0.0, over=0, cpu=[]))
    for name, su in jobs:
        r, st = run(name, su)
        if r is None:
            continue
        F = [(np.array(v["flops"], float) / r["gd_flops"], t) for t, v in r["fns"].items()]
        C = np.concatenate([np.array(v["cpu_seconds"], float).ravel() for v in r["fns"].values()])
        fits = int(sum(np.isfinite(f).sum() for f, _ in F))
        fm, (tt, nn_) = max(((float(np.nanmax(f)), (t, r["ns"][int(np.nanargmax(np.nanmax(f, 1)))])) for f, t in F), key=lambda x: x[0])
        over = int(sum((f > 0.75).sum() for f, _ in F))
        out["runs"][f"{name}|{su}"] = dict(status=st, d=r["d"], fits=fits, max_flops_frac=fm, at=[tt, nn_], over_075=over,
                                            cpu_median=float(np.nanmedian(C)), cpu_max=float(np.nanmax(C)))
        if name.startswith("dfg13-") and name != "dfg13-perm":
            a = agg[name]; a["fits"] += fits; a["fmax"] = max(a["fmax"], fm); a["over"] += over; a["cpu"] += list(C)
            continue
        L.append(f"| {name} | {su} | {r['d']} | {fits} | {fm:.3f} ({tt}, {nn_}) | {over} | {np.nanmedian(C):.2f} / {np.nanmax(C):.1f} |")
    for name, a in agg.items():
        L.append(f"| {name} | the {len(ABL_SUITES)} ablation suites | 30 | {a['fits']} | {a['fmax']:.3f} | {a['over']} | "
                 f"{np.nanmedian(a['cpu']):.2f} / {np.nanmax(a['cpu']):.1f} |")
    # by n, DFG alone on the d = 30 suites against v3 on the same fits
    L += ["", "By n: DFG alone on the d = 30 suites run so far, and v3 (`hybrid/results/toy__p10_sum-perm__<suite>.json`) on the same "
              "(suite, target, n, seed) fits.", "",
          "| n | fits | DFG CPU s: median / mean / max | v3 CPU s: median / mean / max | median of the paired ratio DFG / v3 | DFG FLOPs per fit / one network run: median / max |",
          "|---|---|---|---|---|---|"]
    by = defaultdict(lambda: dict(c=[], v=[], pr=[], f=[]))
    for su in TOY:
        r, _ = run("dfg13-perm", su); v3 = CH.toy_load("p10_sum-perm", su)
        if r is None:
            continue
        for t, v in r["fns"].items():
            c = np.array(v["cpu_seconds"], float); f = np.array(v["flops"], float) / r["gd_flops"]
            w = np.array(v3["fns"][t]["cpu_seconds"], float) if v3 is not None and t in v3["fns"] and v3["seeds"] == r["seeds"] else None
            for i, n in enumerate(r["ns"]):
                by[n]["c"] += list(c[i]); by[n]["f"] += list(f[i])
                if w is not None:
                    by[n]["v"] += list(w[i]); by[n]["pr"] += list(c[i] / np.maximum(w[i], 1e-9))
    for n in sorted(by):
        b = by[n]; c, v = np.array(b["c"]), np.array(b["v"])
        out["by_n"][n] = dict(fits=len(c), cpu_median=float(np.median(c)), cpu_mean=float(np.mean(c)), cpu_max=float(np.max(c)),
                              v3_fits=len(v), v3_cpu_median=float(np.median(v)) if len(v) else None,
                              v3_cpu_mean=float(np.mean(v)) if len(v) else None, v3_cpu_max=float(np.max(v)) if len(v) else None,
                              paired_ratio_median=float(np.median(b["pr"])) if b["pr"] else None,
                              flops_median=float(np.median(b["f"])), flops_max=float(np.max(b["f"])))
        o = out["by_n"][n]
        L.append(f"| {n} | {len(c)} | {o['cpu_median']:.2f} / {o['cpu_mean']:.2f} / {o['cpu_max']:.2f} | "
                 + ("–" if not len(v) else f"{o['v3_cpu_median']:.2f} / {o['v3_cpu_mean']:.2f} / {o['v3_cpu_max']:.2f}") + " | "
                 + ("–" if o["paired_ratio_median"] is None else f"{o['paired_ratio_median']:.2f}") + f" | {o['flops_median']:.3f} / {o['flops_max']:.3f} |")
    return L + [""], out


# ---------------------------------------------------------------- status, checks
def status():
    rows = [("dfg13-perm", su, "Q1, Q2") for su in TOY] + [("lowdeg-perm", su, "Q3") for su in TOY] + \
           [("dfg13-perm", f"designed_d{d}", "Q4") for d in DSC if d != 30] + \
           [(f"dfg13-{tag}-perm", su, "Q5") for tag, *_ in ABL for su in ABL_SUITES]
    out, cnt = [], defaultdict(int)
    for name, su, q in rows:
        r, st = run(name, su)
        out.append(dict(run=name, suite=su, question=q, status=st, seeds=r["seeds"] if r else None,
                        kw=r.get("kw") if r else None, file=f"part11/results/toy__{name}__{su}.json"))
        cnt["complete" if st.startswith("complete") else "partial" if st.startswith("partial") else "not yet run"] += 1
    for ds in TAB:
        r = CH.load("dfg13", ds); st = "complete" if r is not None else "not yet run"
        out.append(dict(run="dfg13", suite=ds, question="Q6", status=st, seeds=r["seeds"] if r else None, kw=None,
                        file=f"standard_tasks/results/dfg13__{ds}.json"))
        cnt[st] += 1
    L = ["## Run status", "", f"{cnt['complete']} of {len(out)} result files complete, {cnt['partial']} partial, {cnt['not yet run']} not yet run.", "",
         "| question | run | suite | status | seeds |", "|---|---|---|---|---|"]
    L += [f"| {x['question']} | {x['run']} | {x['suite']} | {x['status']} | {f_seeds(x['seeds'])} |" for x in out]
    return L + [""], out, dict(cnt)


def checks(q1o, q2o):
    """Consistency checks: the frozen file's md5; v3's summaries recomputed here against Part 10's LEARNER_RESULTS.json; the
    queue's dlheld7 runs against the timing check disclosed in PROTOCOL.md."""
    L = ["## Consistency checks", ""]
    out = {}
    md5 = hashlib.md5(open(os.path.join(STUDY, "part10", "hyb_portfolio3", "dfg13.py"), "rb").read()).hexdigest()
    m = re.search(r'MD5 = "([0-9a-f]{32})"', open(os.path.join(HERE, "eval_dfg.py")).read())
    out["dfg13_md5"] = md5; out["md5_matches_eval_dfg"] = bool(m and m.group(1) == md5)
    L.append(f"- `part10/hyb_portfolio3/dfg13.py` md5 {md5}; equal to `eval_dfg.py`'s frozen MD5 (asserted before every fit): "
             f"{'yes' if out['md5_matches_eval_dfg'] else 'NO'}.")
    P10 = _read(os.path.join(STUDY, "part10", "LEARNER_RESULTS.json"))
    ok, tot, bad = 0, 0, []
    if P10:
        for su in TOY:
            ref = P10["toy"].get(su, {}).get("nets_best")
            NR, nb = nets(su); V3 = CL.nst("p10_sum-perm", su)
            mine = summ(V3, nb)
            if not ref or not mine:
                continue
            tot += 1
            same = (mine["targets"], mine["better"], mine["worse"]) == (ref["targets"], ref["better"], ref["worse"]) and abs(mine["mean"] - ref["mean"]) < 1e-9
            ok += same
            if not same:
                bad.append(su)
        ph = P10["toy"].get("_pooled_heldout", {})
        R = []
        for su in P10_HELD:
            NR, nb = nets(su); R += list(ratios(CL.nst("p10_sum-perm", su), nb).values())
        p = pstats(R)
        pok = bool(ph) and (p["targets"], p["better"], p["worse"]) == (ph["targets"], ph["better"], ph["worse"]) and abs(p["mean"] - ph["mean"]) < 1e-9
        out.update(p10_suites_reproduced=ok, p10_suites_compared=tot, p10_mismatch=bad, p10_pooled_reproduced=pok)
        L.append(f"- v3 vs nets_best recomputed here reproduces Part 10's `part10/LEARNER_RESULTS.json` (targets, mean, clearly better, "
                 f"clearly worse) on {ok} of {tot} suites" + (f" (not on: {', '.join(bad)})" if bad else "")
                 + f", and its pooled held-out row: {'yes' if pok else 'NO'}.")
    # PROTOCOL.md's disclosed timing check
    txt = " ".join(open(os.path.join(HERE, "PROTOCOL.md")).read().split())
    m = re.search(r"fitted DFG alone on `dlheld7`'s (\w+) and (\w+) \(seed 0; n = ([0-9, ]+)\) and printed their test errors "
                  r"\(([0-9., ]+) and ([0-9., ]+)\)", txt)
    r, _ = run("dfg13-perm", "dlheld7")
    if m and r is not None:
        ns = [int(x) for x in m.group(3).replace(" ", "").split(",")]
        res, agree, n_cmp = {}, 0, 0
        for fn, vals in ((m.group(1), m.group(4)), (m.group(2), m.group(5))):
            disc = [float(x) for x in vals.replace(" ", "").split(",")]
            if fn not in r["fns"]:
                continue
            e = np.array(r["fns"][fn]["err"], float)[:, r["seeds"].index(0)]
            got = [float(e[r["ns"].index(n)]) for n in ns]
            res[fn] = dict(n=ns, disclosed=disc, queue=got)
            for g, dv in zip(got, disc):
                n_cmp += 1; agree += abs(g - dv) <= 5e-4 + 1e-12
        out["timing_check"] = dict(res, agree=agree, compared=n_cmp)
        L.append(f"- PROTOCOL.md's disclosed timing check (seed-0 test errors of {m.group(1)} and {m.group(2)} on `dlheld7` at n = "
                 f"{', '.join(map(str, ns))}) against the queue's run: {agree} of {n_cmp} errors agree to the disclosed 3 decimals.")
    else:
        L.append("- PROTOCOL.md's disclosed timing check: " + ("DFG alone on dlheld7 not yet run." if r is None else "could not parse."))
    return L + [""], out


# ---------------------------------------------------------------- coverage
def coverage(q2o):
    L = ["## Coverage and what could not be checked", ""]
    miss = defaultdict(list)
    for su in TOY:
        NR, nb = nets(su)
        if not NR:
            miss["networks"].append(su)
        for k in ("lin", "hgb"):
            if not CL.nst(k, su):
                miss[k].append(su)
        if not CL.nst("p10_sum-perm", su):
            miss["v3"].append(su)
        if not CL.v2_toy(su):
            miss["v2"].append(su)
    for k, v in miss.items():
        L.append(f"- No `{k}` result on: {', '.join(f'`{s}`' for s in v)}; comparisons with it are absent there.")
    v2p9 = [su for su in TOY if v2_name(su) == "p9_sum-perm"]
    if v2p9:
        L.append(f"- v2 is `p9_sum-perm` (identical to v2 on toy inputs, compare_learner.v2_toy) on: {', '.join(f'`{s}`' for s in v2p9)}.")
    nv = {su: sorted(nets(su)[0]) for su in TOY if nets(su)[0]}
    L.append("- Network variants per suite (nets_best is their per-target minimum): " + "; ".join(f"`{su}` {', '.join(v)}" for su, v in nv.items()) + ".")
    L += ["- `lin` and `hgb` were run in the natural column order (Part 8); DFG alone, v2, v3 and lowdeg with the inputs permuted per fit.",
          "- The harness's own reports (`part11/results/*.md`) show the networks as 'never' on `dlheld7`, because no plain `nets` run "
          "exists there; this file uses the variants that were run.",
          "- n* is a seed mean over 2-3 training sets per (target, n); no confidence interval is attached to it. The one-seed ablations "
          "(Q5) are compared on the same training set as DFG alone; the null rows there give the scale of a one-seed difference.",
          "- Part 6's d-scaling DFG runs are other versions (v1, v1.1) in natural column order; they are context, not a paired comparison.",
          ""]
    return L


# ---------------------------------------------------------------- main
def clean(o):
    """JSON-safe: inf -> 'inf' / '-inf' (n* never, or a one-sided ratio), nan -> null; numpy scalars -> Python."""
    if isinstance(o, dict):
        return {str(k): clean(v) for k, v in o.items()}
    if isinstance(o, (list, tuple)):
        return [clean(v) for v in o]
    if isinstance(o, (bool, np.bool_)):
        return bool(o)
    if isinstance(o, (np.integer,)):
        return int(o)
    if isinstance(o, (float, np.floating)):
        v = float(o)
        return v if np.isfinite(v) else ("inf" if v > 0 else "-inf" if v < 0 else None)
    return o


def main():
    now = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    LS, S, cnt = status(); L1, o1 = q1(); L2, o2 = q2(); L3, o3 = q3(); L4, o4 = q4(); L5, o5 = q5(); L6, o6 = q6()
    LC, oc = compute(); LK, ok_ = checks(o1, o2); LV = coverage(o2)
    head = ["# Part 11 results: DFG v1.3 alone", "",
            f"Generated by `compare_dfg.py` on {now} from the result files; definitions and sources are in its docstring. "
            "Re-run `python compare_dfg.py` to refresh. Every number here is computed by the script from the files named in each "
            "section (Numerical); this file states no interpretation (Heuristic readings belong in the paper).", "",
            f"**Run status:** {cnt.get('complete', 0)} of {len(S)} result files complete, {cnt.get('partial', 0)} partial, "
            f"{cnt.get('not yet run', 0)} not yet run (table at the end). Tables over incomplete runs say so.", "",
            "Notation: n* = training-set size reaching 10% test error (seed mean, log-interpolated; 'never' if not by 16384). "
            "'A vs B' = log2(n*_A / n*_B) per target, negative when A needs less data. Summary cells: 'mean (clearly better / "
            "clearly worse) [both reach / targets compared]', mean over the targets both reach, clearly = beyond ±0.25 or only one "
            "reaches 10% error. In the summary tables: 'never, the other reaches' = the row's learner never, the reference does; "
            "'the other never' = the reverse.", ""]
    L = head + L1 + L2 + L3 + L4 + L5 + L6 + LC + LK + LV + LS
    open(os.path.join(HERE, "RESULTS.md"), "w").write("\n".join(L) + "\n")
    J = dict(generated_utc=now, script="part11/compare_dfg.py",
             notes=dict(nstar="training-set size at 10% test error (seed mean); 'inf' = never by n = 16384",
                        ratio="log2(n*_A / n*_B); '+inf' only B reaches 10% error, '-inf' only A, null neither",
                        summary="compare_hybrid.toy_summary + both (both reach), neither, median, per-target ratios"),
             status=S, status_counts=cnt, q1_dlheld7=o1, q2_suites=o2, q3_lowdeg=o3, q4_dscale=o4, q5_ablations=o5,
             q6_tabular=o6, compute=oc, checks=ok_)
    json.dump(clean(J), open(os.path.join(HERE, "RESULTS.json"), "w"), indent=1)
    print("\n".join(L[:12] + L1[:6]))
    print(f"... wrote RESULTS.md ({len(L)} lines) and RESULTS.json")


if __name__ == "__main__":
    main()
