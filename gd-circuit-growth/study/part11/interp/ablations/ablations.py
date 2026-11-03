"""Part 11, Q5 and Q5b analysis: what DFG v1.3's parts do (ABLATIONS.md).

Reads the evaluation's result files (part11/results/toy__dfg13-perm__<suite>.json, toy__dfg13-<tag>-perm__<suite>.json,
toy__dfg13-core-perm__<suite>.json), the paired null of this folder (results/toy__dfg13-reperm__<suite>.json,
perm_null.py), the atlas's counterfactual records (../results/cv/forced_vs_default.json, ../tables/atlas_cells.csv),
the networks' n* (RESULTS.json, q2_suites) and the refits of refit.py (results/refits.json, if present); writes
ablations.json and tables/*.md.  Every number in ABLATIONS.md is printed by this script or by refit.py.
usage: python ablations.py

Definitions (those of compare_dfg.py): n* = training-set size at 10% seed-mean test error (harness.nstar, log-interpolated
on 16 .. 16384, inf = never); ratio = log2(n*_A / n*_B) per target, +inf if only B reaches 10% error, -inf if only A,
nan if neither; mean over the targets both reach; 'higher' / 'lower' = ratio > +0.25 / < -0.25, the infinite ratios
included.  Ablation vs DFG alone is paired: DFG alone's n* from the same seeds of its own runs.  Families: families.py.
"""
import os, sys, json, math, csv
from collections import defaultdict, Counter
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__)); INTERP = os.path.dirname(HERE); P11 = os.path.dirname(INTERP)
sys.path.insert(0, P11); sys.path.insert(0, HERE)
import eval_dfg as E                                                   # noqa: E402
import families as FAM                                                 # noqa: E402
TH = E.TH
RES = os.path.join(P11, "results"); OWN = os.path.join(HERE, "results"); TAB = os.path.join(HERE, "tables")
os.makedirs(TAB, exist_ok=True)
INF, NAN, THR = math.inf, math.nan, 0.25
TOY = ["designed", "random", "dlheld", "dlheld2", "dlheld3", "dlsymdev", "dlheld4", "dlheld5", "dlheld6", "dlfamdev", "dlheld7"]
ABL_SUITES = ["designed", "dlsymdev", "dlfamdev", "dlheld6", "dlheld7"]
ABL = [("nosums", (0, 1)), ("strict", (0, 1)), ("lenient", (0, 1)), ("noeig", (0, 1)), ("noblocks", (0, 1)), ("nocomp", (0, 1)),
       ("noweighted", (0,)), ("nosmalln", (0,)), ("nobg", (0,)), ("lsread", (0,)), ("K3", (0,)), ("labelnoise", (0,))]
GROUPS = FAM.GROUPS
CLASSES = ["character", "halfspace", "sum"]
R = json.load(open(os.path.join(P11, "RESULTS.json")))


def load(path):
    return json.load(open(path)) if os.path.exists(path) else None


def res(name, su):
    return load(os.path.join(RES, f"toy__{name}__{su}.json"))


def nst(r, seeds=None):
    if r is None:
        return {}
    idx = list(range(len(r["seeds"]))) if seeds is None else [r["seeds"].index(s) for s in seeds]
    return {t: float(TH.nstar(r["ns"], np.nanmean(np.array(v["err"], float)[:, idx], 1))) for t, v in r["fns"].items()}


def l2r(a, b):
    if math.isfinite(a) and math.isfinite(b):
        return math.log2(a / b)
    return INF if math.isfinite(b) else (-INF if math.isfinite(a) else NAN)


def stats(rs):
    rs = list(rs); f = [v for v in rs if math.isfinite(v)]
    return dict(targets=len(rs), both=len(f), mean=float(np.mean(f)) if f else None, median=float(np.median(f)) if f else None,
                sd=float(np.std(f, ddof=1)) if len(f) > 1 else None,
                se=float(np.std(f, ddof=1) / math.sqrt(len(f))) if len(f) > 1 else None,
                mean_abs=float(np.mean(np.abs(f))) if f else None,
                higher=sum(1 for v in rs if v > THR), lower=sum(1 for v in rs if v < -THR),
                newly_never=sum(1 for v in rs if v == INF), newly_reached=sum(1 for v in rs if v == -INF),
                neither=sum(1 for v in rs if isinstance(v, float) and math.isnan(v)))


def by_group(ratios, key):
    """ratios: {(su, t): r}; key: FAM.family or FAM.coarse -> {group: stats}."""
    G = defaultdict(list)
    for (su, t), v in ratios.items():
        G[key(su, t)].append(v)
    return {g: stats(v) for g, v in G.items()}


def fmt(v, p=2):
    return "–" if v is None else ("+inf" if v == INF else "-inf" if v == -INF else "n/a" if v != v else f"{v:+.{p}f}")


def cell(s):
    """'mean (higher/lower) [both/targets]'."""
    return "–" if not s or not s["targets"] else f"{fmt(s['mean'])} ({s['higher']}/{s['lower']}) [{s['both']}/{s['targets']}]"


# ------------------------------------------------------------------------------------------------ the data
BASE = {su: res("dfg13-perm", su) for su in TOY}
for su in TOY:
    assert BASE[su] is not None and len(BASE[su]["fns"]) == len(FAM._G and [k for k in FAM.FAMILY if k[0] == su]), su


def paired(name_or_res, suites, seeds=None):
    """{(su, t): ratio} of a run against DFG alone on the same seeds, and the two n* dicts."""
    out, A_, B_ = {}, {}, {}
    for su in suites:
        r = res(name_or_res, su) if isinstance(name_or_res, str) else name_or_res(su)
        if r is None:
            continue
        sd = list(seeds) if seeds is not None else r["seeds"]
        A = nst(r, sd); B = nst(BASE[su], sd)
        for t in A:
            out[(su, t)] = l2r(A[t], B[t]); A_[(su, t)] = A[t]; B_[(su, t)] = B[t]
    return out, A_, B_


def reperm(su):
    return load(os.path.join(OWN, f"toy__dfg13-reperm__{su}.json"))


# ------------------------------------------------------------------------------------------------ (b) the test or the search
K_, C_, D_ = 4, 1.0, 30                                                # DFG's K, c and d on the toy suites
DELTAS = {"default": 0.1, "strict": 1e-4, "lenient": 0.9}


def n_thr(k, delta, d=D_):
    """THEORY.md P2: a k-parity passes round 0's global test iff n (1 - ybar^2) > 2 c^2 ln(4 K C(d, k) / delta)."""
    return 2 * C_ ** 2 * math.log(4 * K_ * math.comb(d, k) / delta)


def chi2_thr(m, t):
    return m + 2 * math.sqrt(m * t) + 2 * t                          # dfg13._chi2_thr (Laurent-Massart)


def parity_prediction():
    """P2 under the three deltas: per seed and n, the default variant's final fit holds chi_S iff n (1 - ybar^2) > n_thr
    (degrees 3-4 are searched on all rows from n = 32 at d = 30; P5); the predicted error is 0 where it passes and DFG
    alone's own measured error where DFG alone fails (about 0.5); at n = 16 nothing passes for any of the three deltas
    (n_thr > 16), so the cell is the forced-or-default choice of the cross-validation, which does not depend on delta:
    DFG alone's measured error is used there (P2's '+ forced' column)."""
    T = TH.suite_targets("designed", 30)[0]; r = BASE["designed"]; ns = r["ns"]
    out = {}
    for t, k in (("par2", 2), ("par3", 3), ("par4", 4)):
        fn = T[t]["fn"]; o = {}
        E0 = np.array(r["fns"][t]["err"], float)                       # DFG alone, ns x seeds
        for lab, dl in DELTAS.items():
            thr = n_thr(k, dl); pe = np.zeros((len(ns), 2)); passes = {}
            for j, s in enumerate((0, 1)):
                for i, n in enumerate(ns):
                    X, y = TH.train_data(fn, t, s, n, 30); yb = float(np.mean(y))
                    ok = n >= 32 if k >= 3 else True
                    p = bool(ok and n * (1 - yb * yb) > thr); passes[(s, n)] = p
                    pe[i, j] = E0[i, r["seeds"].index(s)] if n == 16 else (0.0 if p else max(E0[i, r["seeds"].index(s)], 0.45))
            o[lab] = dict(n_thr=thr, nstar_pred=float(TH.nstar(ns, pe.mean(1))),
                          first_pass={s: min([n for n in ns if passes[(s, n)]] or [None]) for s in (0, 1)})
        base = o["default"]["nstar_pred"]
        meas = {"default": nst(r, [0, 1])[t]}
        for lab in ("strict", "lenient"):
            meas[lab] = nst(res(f"dfg13-{lab}-perm", "designed"), [0, 1])[t]
        for lab in DELTAS:
            o[lab]["nstar_measured"] = meas[lab]
            o[lab]["ratio_pred"] = l2r(o[lab]["nstar_pred"], base)
            o[lab]["ratio_measured"] = l2r(meas[lab], meas["default"])
        out[t] = o
    return out


def char_shift(k, delta):
    """Expected shift (doublings) of n_glob for a character of degree k admitted by round 0's global test: n_glob is
    proportional to ln(4 K C(d, k) / delta) (THEORY.md P3b)."""
    return math.log2(math.log(4 * K_ * math.comb(D_, k) / delta) / math.log(4 * K_ * math.comb(D_, k) / 0.1))


def block_power():
    """n_detect of each target's true block (Part 10's toy_power files: DFG's block test applied to the true largest
    signed-symmetry class as if proposed in round 0, seed-0 rows; unfolded, folded, and modulated by the best character
    of the other relevant inputs; for the five weighted targets the weighted block, toy_power_w) under the three deltas:
    the statistic T does not depend on delta; the threshold m + 2 sqrt(m t) + 2 t is recomputed with t + ln(0.1 / delta).
    The modulated entries store only T / threshold: their threshold is rescaled with the unfolded block's m (approximate)."""
    P10 = os.path.join(os.path.dirname(os.path.dirname(P11)), "study", "part10", "interp", "results", "toy_final")
    if not os.path.isdir(P10):
        P10 = os.path.join(P11, "..", "part10", "interp", "results", "toy_final")
    out = {}
    for su in ABL_SUITES:
        for t in BASE[su]["fns"]:
            p = os.path.join(P10, "power", f"{su}__{t}.json"); w = os.path.join(P10, "toy_power_w", f"{su}__{t}.json")
            if not os.path.exists(p):
                continue
            d = json.load(open(p)); tk = d["tk"]; o = dict(k=d["k"], tk=tk)
            for lab, dl in DELTAS.items():
                dt = math.log(0.1 / dl); first = None; ratios = []
                for c in d["cells"]:
                    best = 0.0
                    for key in ("unfold", "fold"):
                        m = max(c[key]["levels"] - 1, 1); best = max(best, c[key]["T"] / chi2_thr(m, tk + dt))
                    m = max(c["unfold"]["levels"] - 1, 1); tkm = tk + math.log(5)
                    best = max(best, c["modulated"]["ratio"] * chi2_thr(m, tkm) / chi2_thr(m, tkm + dt))
                    if os.path.exists(w):
                        dw = json.load(open(w)); cw = [x for x in dw["cells"] if x["n"] == c["n"]][0]
                        for key, tt in (("weighted", dw["tk_weighted"]), ("weighted_fold", dw["tk_weighted"]), ("unit", dw["tk"]), ("unit_fold", dw["tk"])):
                            m = max(cw[key]["levels"] - 1, 1); best = max(best, cw[key]["T"] / chi2_thr(m, tt + dt))
                    ratios.append(best)
                    if first is None and best > 1:
                        first = c["n"]
                o[lab] = dict(n_detect=first, ratios=ratios)
            out[f"{su}/{t}"] = o
    return out


# ------------------------------------------------------------------------------------------------ (d) the atlas's counterfactuals
def atlas_counterfactuals():
    """nosmalln against 'always the default variant' and nobg against 'the same model without its background', on the
    atlas cells (seed 0) of the targets the ablation suites share with the atlas.  nosmalln fits the default variant on
    all n rows with the whole budget (scale 1); the atlas's counterfactual refits it as DFG.fit's final fit (scale 0.5):
    at d = 30 the two differ only in the degree-5/6 subsample sizes (THEORY.md P5)."""
    CV = json.load(open(os.path.join(INTERP, "results", "cv", "forced_vs_default.json")))
    cells = list(csv.DictReader(open(os.path.join(INTERP, "tables", "atlas_cells.csv"))))
    out = {}
    for tag in ("nosmalln", "nobg"):
        rows = []
        for su in ABL_SUITES:
            ra = res(f"dfg13-{tag}-perm", su); rb = BASE[su]
            for c in (CV if tag == "nosmalln" else cells):
                if c["suite"] != su or c["target"] not in ra["fns"]:
                    continue
                n = int(c["n"]); i = ra["ns"].index(n)
                e_ab = float(ra["fns"][c["target"]]["err"][i][ra["seeds"].index(0)])
                e_dfg = float(rb["fns"][c["target"]]["err"][i][rb["seeds"].index(0)])
                if tag == "nosmalln":
                    e_cf = float(c["default"]["err"]); chosen = c["chosen"]
                else:
                    e_cf = float(c["err_no_bg"]); chosen = "forced" if c["variant"] == "1" else "default"
                rows.append(dict(suite=su, target=c["target"], n=n, err_ablation=e_ab, err_counterfactual=e_cf, err_dfg=e_dfg,
                                 chosen=chosen, equal=bool(abs(e_ab - e_cf) < 1e-12)))
        neq = [x for x in rows if not x["equal"]]
        out[tag] = dict(cells=len(rows), equal=len(rows) - len(neq), unequal=neq,
                        targets=sorted({f"{x['suite']}/{x['target']}" for x in rows}),
                        mean_err_ablation=float(np.mean([x["err_ablation"] for x in rows])),
                        mean_err_counterfactual=float(np.mean([x["err_counterfactual"] for x in rows])),
                        mean_err_dfg=float(np.mean([x["err_dfg"] for x in rows])),
                        lower=sum(1 for x in rows if x["err_ablation"] < x["err_dfg"] - 1e-12),
                        higher=sum(1 for x in rows if x["err_ablation"] > x["err_dfg"] + 1e-12))
    return out


def errs_by_n(tag, suites=ABL_SUITES, seed=0):
    """Mean test error by n of an ablation and of DFG alone (same seed), and the cells lower / higher by > 0.02."""
    out = {}
    for i, n in enumerate(TH.NS):
        a, b = [], []
        for su in suites:
            ra = res(f"dfg13-{tag}-perm", su); rb = BASE[su]
            for t in ra["fns"]:
                a.append(ra["fns"][t]["err"][i][ra["seeds"].index(seed)]); b.append(rb["fns"][t]["err"][i][rb["seeds"].index(seed)])
        a, b = np.array(a), np.array(b)
        out[n] = dict(cells=len(a), mean_ablation=float(a.mean()), mean_dfg=float(b.mean()), lower=int(np.sum(a < b - 0.02)),
                      higher=int(np.sum(a > b + 0.02)))
    return out


# ------------------------------------------------------------------------------------------------ (f) leave one in
def leavein():
    """results/leavein/: the core with one part put back (leavein.py), against the core and DFG alone on the same seeds."""
    D = os.path.join(OWN, "leavein"); out = {}
    if not os.path.isdir(D):
        return out
    for f in sorted(os.listdir(D)):
        if not f.endswith(".json"):
            continue
        r = json.load(open(os.path.join(D, f))); cfg = r["config"]; su = r["suite"]
        A = nst(r, [0, 1]); Cc = nst(res("dfg13-core-perm", su), [0, 1]); B = nst(BASE[su], [0, 1])
        for t in A:
            out.setdefault(cfg, {})[f"{su}/{t}"] = dict(leavein=A[t], core=Cc[t], dfg=B[t], vs_core=l2r(A[t], Cc[t]),
                                                         vs_dfg=l2r(A[t], B[t]), core_vs_dfg=l2r(Cc[t], B[t]))
    return out


def main():
    J = dict(source="part11/interp/ablations/ablations.py", families={f"{su}/{t}": g for (su, t), g in FAM.FAMILY.items()})
    Lmd = []
    # ---- (a) every ablation, by family and by coarse class ----------------------------------------------------------
    A = {}
    for tag, sd in ABL:
        r, a, b = paired(f"dfg13-{tag}-perm", ABL_SUITES)
        kw = res(f"dfg13-{tag}-perm", "designed")["kw"]
        A[tag] = dict(seeds=list(sd), kw=kw, pooled=stats(r.values()), by_family=by_group(r, FAM.family),
                      by_class=by_group(r, FAM.coarse), ratios={f"{su}/{t}": v for (su, t), v in r.items()},
                      nstar={f"{su}/{t}": v for (su, t), v in a.items()}, dfg_same_seeds={f"{su}/{t}": v for (su, t), v in b.items()})
        # per seed, for the 2-seed ablations: does each seed move the same way?
        if len(sd) == 2:
            ps = {}
            for s in sd:
                rs, _, _ = paired(f"dfg13-{tag}-perm", ABL_SUITES, seeds=[s])
                ps[s] = rs
            agree = dict(both_higher=0, both_lower=0, opposite=0, one_only=0, neither_moved=0)
            for k in r:
                u, v = ps[sd[0]][k], ps[sd[1]][k]
                if any(isinstance(x, float) and math.isnan(x) for x in (u, v)):
                    continue
                hu, hv = (u > THR) - (u < -THR), (v > THR) - (v < -THR)
                if hu == hv == 0:
                    agree["neither_moved"] += 1
                elif hu == hv:
                    agree["both_higher" if hu > 0 else "both_lower"] += 1
                elif hu * hv < 0:
                    agree["opposite"] += 1
                else:
                    agree["one_only"] += 1
            A[tag]["per_seed"] = {str(s): stats(ps[s].values()) for s in sd}
            A[tag]["seed_agreement"] = agree
    J["ablations"] = A
    # ---- nulls ----------------------------------------------------------------------------------------------------------
    N = {}
    for a_, b_ in ((1, 0), (2, 0), (2, 1)):
        rr = {}
        for su in ABL_SUITES:
            X, Y = nst(BASE[su], [a_]), nst(BASE[su], [b_])
            rr.update({(su, t): l2r(X[t], Y[t]) for t in X})
        N[f"unpaired_seed{a_}_vs_seed{b_}"] = dict(pooled=stats(rr.values()), by_family=by_group(rr, FAM.family),
                                                   by_class=by_group(rr, FAM.coarse), ratios={f"{su}/{t}": v for (su, t), v in rr.items()})
    for sd in ((0,), (0, 1)):
        have = [su for su in ABL_SUITES if reperm(su) is not None]
        if not have:
            continue
        rr, a, b = paired(reperm, have, seeds=sd)
        N["paired_seed" + "".join(map(str, sd))] = dict(suites=have, pooled=stats(rr.values()), by_family=by_group(rr, FAM.family),
                                                        by_class=by_group(rr, FAM.coarse), ratios={f"{su}/{t}": v for (su, t), v in rr.items()})
    J["nulls"] = N
    # ---- the core (Q5b, post hoc), all 11 suites ---------------------------------------------------------------------
    rc, a, b = paired("dfg13-core-perm", TOY)
    nb = {}
    for su in TOY:
        Q = R["q2_suites"][su]
        for x in R["q2_suites"]["dfg_vs_v3"]["per_target"]:
            if x["suite"] == su:
                v = x["nets_best"]; nb[(su, x["target"])] = None if v is None else (INF if v == "inf" else float(v))
    vs_nb = {k: l2r(a[k], nb[k]) for k in rc if nb.get(k) is not None}
    dfg_nb = {k: l2r(b[k], nb[k]) for k in rc if nb.get(k) is not None}
    J["core"] = dict(pooled=stats(rc.values()), by_family=by_group(rc, FAM.family), by_class=by_group(rc, FAM.coarse),
                     ablation_suites=stats(v for k, v in rc.items() if k[0] in ABL_SUITES),
                     other_suites=stats(v for k, v in rc.items() if k[0] not in ABL_SUITES),
                     by_suite={su: stats(v for k, v in rc.items() if k[0] == su) for su in TOY},
                     vs_nets_best=dict(pooled=stats(vs_nb.values()), by_family=by_group(vs_nb, FAM.family),
                                       by_class=by_group(vs_nb, FAM.coarse)),
                     dfg_same_seeds_vs_nets_best=dict(pooled=stats(dfg_nb.values()), by_family=by_group(dfg_nb, FAM.family),
                                                      by_class=by_group(dfg_nb, FAM.coarse)),
                     ratios={f"{su}/{t}": v for (su, t), v in rc.items()}, nstar={f"{su}/{t}": v for (su, t), v in a.items()},
                     dfg_same_seeds={f"{su}/{t}": v for (su, t), v in b.items()},
                     nets_best={f"{su}/{t}": v for (su, t), v in nb.items()})
    # paired null on the core's seeds, all suites where present
    have = [su for su in TOY if reperm(su) is not None]
    if have:
        rr, _, _ = paired(reperm, have, seeds=(0, 1))
        J["core"]["paired_null_same_seeds"] = dict(suites=have, pooled=stats(rr.values()), by_class=by_group(rr, FAM.coarse))
    # ---- (b) test or search -----------------------------------------------------------------------------------------
    J["parity_P2"] = parity_prediction()
    J["char_shift"] = {lab: {k: char_shift(k, dl) for k in (1, 2, 3, 4)} for lab, dl in DELTAS.items() if lab != "default"}
    J["linear_block_thr"] = {lab: chi2_thr(30, math.log(1 / dl)) for lab, dl in DELTAS.items()}
    BP = block_power(); J["block_power"] = BP
    rows = []
    for key, o in BP.items():
        su, t = key.split("/")
        rows.append(dict(target=key, family=FAM.family(su, t), cls=FAM.coarse(su, t), k=o["k"],
                         n_detect={lab: o[lab]["n_detect"] for lab in DELTAS},
                         shift_detect={lab: (None if o[lab]["n_detect"] is None or o["default"]["n_detect"] is None
                                             else math.log2(o[lab]["n_detect"] / o["default"]["n_detect"])) for lab in ("strict", "lenient")},
                         measured={lab: A[lab]["ratios"].get(key) for lab in ("strict", "lenient")},
                         nstar_dfg=A["strict"]["dfg_same_seeds"].get(key)))
    J["block_power_rows"] = rows
    # ---- (d) the atlas's counterfactuals -------------------------------------------------------------------------------
    J["atlas_counterfactuals"] = atlas_counterfactuals()
    J["errs_by_n"] = {tag: errs_by_n(tag) for tag in ("nosmalln", "nobg", "labelnoise", "noblocks", "strict", "lenient")}
    # ---- (f) leave one in ----------------------------------------------------------------------------------------------
    J["leavein"] = leavein()
    json.dump(J, open(os.path.join(HERE, "ablations.json"), "w"), indent=1, default=lambda v: None,
              allow_nan=True)
    # ---- printout ----------------------------------------------------------------------------------------------------
    cls_n = Counter(FAM.coarse(su, t) for (su, t) in FAM.FAMILY if su in ABL_SUITES)
    fam_n = Counter(FAM.family(su, t) for (su, t) in FAM.FAMILY if su in ABL_SUITES)
    head = "| run | seeds | pooled | " + " | ".join(f"{c} ({cls_n[c]})" for c in CLASSES) + " |"
    Lmd += ["## By coarse class (65 targets of the five ablation suites)", "", "cells: mean (higher / lower) [both reach / targets]", "",
            head, "|---|---|---|" + "---|" * len(CLASSES)]
    for tag, sd in ABL:
        x = A[tag]; Lmd.append(f"| {tag} | {','.join(map(str, sd))} | {cell(x['pooled'])} | " + " | ".join(cell(x["by_class"].get(c)) for c in CLASSES) + " |")
    for k, x in N.items():
        Lmd.append(f"| null {k} | | {cell(x['pooled'])} | " + " | ".join(cell(x["by_class"].get(c)) for c in CLASSES) + " |")
    x = J["core"]
    Lmd.append(f"| core (all 11 suites) | 0,1 | {cell(x['pooled'])} | " + " | ".join(cell(x["by_class"].get(c)) for c in CLASSES) + " |")
    Lmd += ["", "## By family (atlas groups), 65 targets", "", "| run | " + " | ".join(f"{FAM.SHORT[g]} ({fam_n[g]})" for g in GROUPS if fam_n[g]) + " |",
            "|---|" + "---|" * sum(1 for g in GROUPS if fam_n[g])]
    for tag, sd in ABL:
        Lmd.append(f"| {tag} | " + " | ".join(cell(A[tag]["by_family"].get(g)) for g in GROUPS if fam_n[g]) + " |")
    for k, x in N.items():
        Lmd.append(f"| null {k} | " + " | ".join(cell(x["by_family"].get(g)) for g in GROUPS if fam_n[g]) + " |")
    fam_all = Counter(FAM.FAMILY.values())
    Lmd += ["", "## The core by family (138 targets)", "", "| | " + " | ".join(f"{FAM.SHORT[g]} ({fam_all[g]})" for g in GROUPS) + " |",
            "|---|" + "---|" * len(GROUPS),
            "| core vs DFG alone | " + " | ".join(cell(J["core"]["by_family"].get(g)) for g in GROUPS) + " |",
            "| core vs nets_best | " + " | ".join(cell(J["core"]["vs_nets_best"]["by_family"].get(g)) for g in GROUPS) + " |",
            "| DFG alone (0,1) vs nets_best | " + " | ".join(cell(J["core"]["dfg_same_seeds_vs_nets_best"]["by_family"].get(g)) for g in GROUPS) + " |"]
    open(os.path.join(TAB, "by_family.md"), "w").write("\n".join(Lmd) + "\n")
    print("\n".join(Lmd))
    for tag, sd in ABL:
        if "seed_agreement" in A[tag]:
            print(tag, "per seed:", {s: cell(v) for s, v in A[tag]["per_seed"].items()}, A[tag]["seed_agreement"])
    print("\n(b) parities, P2 under the three deltas (seeds 0, 1):")
    for t, o in J["parity_P2"].items():
        print("  ", t, {lab: dict(n_thr=round(v["n_thr"], 2), pred=round(v["nstar_pred"], 1), meas=round(v["nstar_measured"], 1),
                                  r_pred=fmt(v["ratio_pred"]), r_meas=fmt(v["ratio_measured"]), first=v["first_pass"]) for lab, v in o.items()})
    print("   character n_glob shift (doublings) by degree:", {lab: {k: round(v, 2) for k, v in d.items()} for lab, d in J["char_shift"].items()})
    print("   linear block threshold (k = 30):", {k: round(v, 1) for k, v in J["linear_block_thr"].items()})
    print("\n(b) block power: n_detect under default / strict / lenient, shift, measured n* ratio")
    for x in sorted(J["block_power_rows"], key=lambda x: (x["cls"], x["family"], x["target"])):
        print(f"   {x['cls']:9s} {FAM.SHORT[x['family']]:15s} {x['target']:18s} k={x['k']:2d} n_detect {x['n_detect']} "
              f"shift s/l {x['shift_detect']} measured s/l {fmt(x['measured']['strict'])} {fmt(x['measured']['lenient'])} n*={x['nstar_dfg']:.0f}")
    print("\n(d) atlas counterfactuals:")
    for tag, o in J["atlas_counterfactuals"].items():
        print("  ", tag, {k: v for k, v in o.items() if k not in ("unequal", "targets")}, "targets", len(o["targets"]))
        for x in o["unequal"][:30]:
            print("      unequal:", x)
    for tag, o in J["errs_by_n"].items():
        print("   errs by n", tag, {n: (round(v["mean_ablation"] - v["mean_dfg"], 4), v["lower"], v["higher"]) for n, v in o.items()})
    print("\n(f) leave one in:")
    for cfg, o in J["leavein"].items():
        for k, v in o.items():
            print(f"   +{cfg:9s} {k:18s} core {v['core']:8.0f} leavein {v['leavein']:8.0f} dfg {v['dfg']:8.0f}  vs core {fmt(v['vs_core'])} vs dfg {fmt(v['vs_dfg'])} (core vs dfg {fmt(v['core_vs_dfg'])})")


if __name__ == "__main__":
    main()
