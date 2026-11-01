"""Tables from results/*.jsonl: results/summary.txt (text) and
results/tables.json (machine-readable, for the paper's tables).

Every cost is given in forward-pass equivalents (fpe; one SMC evaluation or
one Monte Carlo sample is one fpe) and in wall-clock seconds on a shared
4-core machine. Headline numbers are computed here from the data, not typed.

usage: python3 summarize.py
"""

import json
import math
import os
from collections import defaultdict

from common import DELTA, MACHINE, RES, fmt, load_rows, mc_two_sided_samples, yardsticks
import numpy as np  # noqa: E402  (after common, which sets OMP_NUM_THREADS=1)

BUDGET_ORDER = {"S": 0, "M": 1, "L": 2}
MC_EPS = 0.1  # the task yardstick at eps = 0.1: 3 ln(2/delta) / (eps^2 p)


def name_key(name):
    base, _, step = name.rpartition("_s")
    return (base, int(step) if step.isdigit() else 0)


def mean(xs):
    xs = [x for x in xs if x is not None]
    return float(np.mean(xs)) if xs else None


def budget_cell(rs, p):
    """Aggregate the runs of one (net, budget): ratios against p, costs in fpe
    and seconds, and the Monte Carlo yardsticks at the mean betting ratio."""
    evals = mean([r["evals"] for r in rs])
    secs = mean([r["seconds"] for r in rs])
    mc_sec = mean([r["mc_sec_per_sample"] for r in rs])
    cell = dict(runs=len(rs), K=mean([r["K"] for r in rs]), evals_fpe=evals, seconds=secs,
                seconds_per_fpe=secs / evals if evals else None, mc_seconds_per_sample=mc_sec,
                flagged=sum(r["flagged"] for r in rs), misses=sum(r["L"] > p for r in rs) if p is not None else None,
                n_witnesses_max=max(r.get("n_wit", 0) for r in rs))
    if p:
        rb = [r["L_bet"] / p for r in rs]
        cell.update(r_bet_mean=mean(rb), r_bet_min=min(rb), r_bet_max=max(rb),
                    r_wit_mean=mean([r["L_wit"] / p for r in rs]), r_mean=mean([r["L"] / p for r in rs]))
        cell.update(yardsticks(p, cell["r_bet_mean"], evals, secs, mc_sec))
    return cell


# ------------------------------------------------------------ exact suite

def suite_tables(rows, out, T):
    by = defaultdict(list)
    for r in rows:
        by[r["name"]].append(r)
    out.append("TABLE N1. Exact suite (d <= 28). p = exact failure probability (fail = number of failing inputs); "
               "MC(0.1) = Monte Carlo cost of a two-sided eps = 0.1 interval, 3 ln(2/delta)/(eps^2 p) samples, in fpe "
               "and in seconds; per budget: mean [min] of L_bet/p over the runs, mean witness ratio, mean reported "
               "L/p (L = max of the two), cost (pilot "
               "included) in fpe and seconds, speedups over Monte Carlo at the mean ratio (KL = one-sided KL lower "
               "end reaching the same ratio; task = 3 ln(2/delta)/((1-ratio)^2 p)), in fpe and in seconds.")
    out.append(f"{'net':22s} {'p':>9s} {'fail':>8s} {'z':>5s} {'MC(0.1)':>8s} {'MC s':>8s} B {'n':>2s} {'K':>3s} "
               f"{'fpe':>8s} {'sec':>7s} {'L_bet/p':>14s} {'wit/p':>6s} {'L/p':>6s} {'xKL fpe':>8s} {'xKL s':>8s} "
               f"{'xtask fpe':>9s} {'xtask s':>8s} miss")
    table = []
    for name in sorted(by, key=name_key):
        rs = by[name]
        r0 = rs[0]
        p = r0["p_exact"]
        mc_sec = mean([r["mc_sec_per_sample"] for r in rs])
        mc01 = mc_two_sided_samples(p, MC_EPS, DELTA) if p > 0 else None
        entry = dict(name=name, d=r0["d"], widths=r0["widths"], loss=r0["loss"], step=r0["step"], z=r0["z"], p=p,
                     fail_count=r0["fail_count"], mc_eps01_fpe=mc01, mc_eps01_seconds=mc01 * mc_sec if mc01 else None,
                     mc_seconds_per_sample=mc_sec, budgets={})
        for b in sorted({r["budget"] for r in rs}, key=BUDGET_ORDER.get):
            c = budget_cell([r for r in rs if r["budget"] == b], p)
            entry["budgets"][b] = c
            head = (f"{name:22s} {fmt(p):>9s} {r0['fail_count']:8d} {r0['z']:5.2f} {fmt(mc01, 2):>8s} "
                    f"{fmt(entry['mc_eps01_seconds'], 2):>8s}")
            if p > 0:
                out.append(f"{head} {b} {c['runs']:2d} {c['K']:3.0f} {c['evals_fpe']:8.2g} {c['seconds']:7.1f} "
                           f"{c['r_bet_mean']:6.3f} [{c['r_bet_min']:.3f}] {c['r_wit_mean']:6.3f} {c['r_mean']:6.3f} "
                           f"{c['speedup_kl_fpe']:8.2g} {c['speedup_kl_sec']:8.2g} {c['speedup_task_fpe']:9.2g} "
                           f"{c['speedup_task_sec']:8.2g} {c['misses']:4d}")
            else:
                out.append(f"{head} {b} {c['runs']:2d} {c['K']:3.0f} {c['evals_fpe']:8.2g} {c['seconds']:7.1f} "
                           f"{'L = 0 in all':>14s} {'':6s} {'':6s} {'':8s} {'':8s} {'':9s} {'':8s} {c['misses']:4d}")
        table.append(entry)
    T["suite_exact"] = table


def efficiency_table(rows, out, T):
    """kappa = relvar(Z) x evaluations per replicate (pooled over the trials of
    budgets M and L): the evaluations an unbiased estimator needs per unit of
    squared relative error; Monte Carlo's is (1 - p)/p."""
    by = defaultdict(list)
    for r in rows:
        if r["p_exact"] > 0 and r["budget"] in ("M", "L"):
            by[(r["name"], r["budget"])].append(r)
    out.append("")
    out.append("EFFICIENCY (exact suite). Pooled replicates of budgets M and L: mean Z/p (unbiasedness check), "
               "relvar = Var Z / (E Z)^2, cost per replicate (final batch) in fpe and seconds, kappa = relvar x cost "
               "(fpe), Monte Carlo's (1-p)/p, gain = MC kappa / SMC kappa.")
    table = []
    for (name, b), rs in sorted(by.items(), key=lambda kv: (name_key(kv[0][0]), kv[0][1])):
        p = rs[0]["p_exact"]
        Z = np.concatenate([np.array(r["Z"]) / p for r in rs])
        cost = mean([r["evals_final"] / r["R"] for r in rs])
        sec = mean([(r["seconds"] - r["seconds_pilot"]) / r["R"] for r in rs])
        rv = float(Z.var() / Z.mean() ** 2)
        e = dict(name=name, budget=b, p=p, replicates=len(Z), mean_Z_over_p=float(Z.mean()),
                 se_mean_Z_over_p=float(Z.std(ddof=1) / math.sqrt(len(Z))), relvar=rv, cost_fpe=cost,
                 cost_seconds=sec, kappa=rv * cost, mc_kappa=(1 - p) / p, gain=(1 - p) / p / (rv * cost))
        table.append(e)
        out.append(f"  {name:22s} {b} replicates {len(Z):4d} mean Z/p {e['mean_Z_over_p']:.3f} +- "
                   f"{e['se_mean_Z_over_p']:.3f} relvar {rv:.3f} cost {cost:.3g} fpe ({sec:.3g} s) kappa "
                   f"{e['kappa']:.3g} MC {e['mc_kappa']:.3g} gain {e['gain']:.3g}")
    small = [e for e in table if e["p"] <= 1e-2]
    if len(small) >= 3:
        x = np.log10([1 / e["p"] for e in small])
        slope = float(np.polyfit(x, np.log10([e["kappa"] for e in small]), 1)[0])
        out.append(f"  fitted log10 kappa vs log10 (1/p) over the {len(small)} rows with p <= 1e-2: slope {slope:.2f} "
                   f"(Monte Carlo: 1), i.e. gain ~ (1/p)^{1 - slope:.2f}")
        T["efficiency_slope"] = dict(rows=len(small), slope=slope)
    T["efficiency"] = table


# ------------------------------------------------------------ d >= 32

def scaling_tables(rows, out, T):
    refs = {r["name"]: r for r in rows if r["kind"] == "ref"}
    lbs = defaultdict(list)
    for r in rows:
        if r["kind"] == "lb":
            lbs[r["name"]].append(r)
    exact = {}
    if os.path.exists(os.path.join(RES, "exact_d32.json")):
        e = json.load(open(os.path.join(RES, "exact_d32.json")))
        exact[e["name"]] = e
    mc_checks = defaultdict(list)
    for c in load_rows(os.path.join(RES, "mc_checks.jsonl")):
        mc_checks[c["name"]].append(dict(kind="plain", samples=c["mc_n"], hits=c["mc_hits"], p=c["p_mc"],
                                         se=c["p_mc_se"], seconds=c["seconds"]))
    for c in load_rows(os.path.join(RES, "mc_blocks.jsonl")):
        mc_checks[c["name"]].append(dict(kind="blocks", samples=c["samples"], hits=c["hits"], p=c["p_hat"],
                                         se=c["se"], seconds=c["seconds"]))
    out.append("")
    out.append("TABLE N2. d = 32 ... 128 (set smc = this lane's own nets, results/scaling_nets; set suite = the "
               "suite's "
               "d = 64/128 nets). p_ref = mean of 100 fixed-plan SMC replicates (N = 3000) +- s.e. (unbiased for "
               "D(A_K) <= p, not a bound); ratios are L_bet / p_ref (and / p for the enumerated d = 32 net); "
               "witnesses = distinct certified failing inputs (best run); costs in fpe and seconds; speedups at the "
               "mean ratio against p_ref.")
    table = []
    for name in sorted(refs, key=lambda n: (refs[n]["set"], refs[n]["d"], name_key(n))):
        ref = refs[name]
        p = ref["p_ref"]
        e = dict(name=name, set=ref["set"], d=ref["d"], widths=ref["widths"], loss=ref["loss"], step=ref["step"],
                 z=ref["z"], p_ref=p, p_ref_se=ref["p_ref_se"], ref_relvar=ref["ref_relvar"], ref_K=ref["ref_K"],
                 ref_evals_fpe=ref["ref_evals"], ref_seconds=ref["ref_seconds"], ref_L_bet=ref["ref_L_bet"],
                 ref_witnesses=ref["ref_witnesses"], ref_L_wit=ref["ref_L_wit"], ref_flagged=ref["ref_flagged"],
                 mc_seconds_per_sample=ref["mc_sec_per_sample"], checks=list(mc_checks.get(name, [])), budgets={})
        if "p_mc" in ref:
            e["checks"].insert(0, dict(kind="plain (ref run)", samples=ref["mc_n"], hits=ref["mc_hits"], p=ref["p_mc"],
                                       se=math.sqrt(ref["mc_hits"]) / ref["mc_n"], seconds=ref["mc_seconds"]))
        if name in exact:
            e["p_exact"] = exact[name]["p_exact"]
            e["checks"].insert(0, dict(kind="exact enumeration", samples=2 ** 32, hits=exact[name]["fail_count"],
                                       p=exact[name]["p_exact"], se=0.0, seconds=exact[name]["seconds"]))
        chk = "; ".join(f"{c['kind']}: {fmt(c['p'])} +- {fmt(c['se'], 2)} ({c['hits']} / {c['samples']:.2g}, "
                        f"{c['seconds']:.0f} s)" for c in e["checks"])
        out.append(f"{name} [{ref['set']}]: d={ref['d']} widths={ref['widths']} {ref['loss']} z={ref['z']:.2f} "
                   f"p_ref={fmt(p)} +- {fmt(ref['p_ref_se'], 2)} (relvar {fmt(ref['ref_relvar'])}, K={ref['ref_K']}, "
                   f"{ref['ref_evals']:.3g} fpe, {ref['ref_seconds']:.0f} s; witnesses {ref['ref_witnesses']})"
                   + (f"; checks: {chk}" if chk else ""))
        if p == 0:
            out.append(f"    no replicate survived the last level: every bound is 0 (witnesses {ref['ref_witnesses']})")
        for b in ("S", "M", "L"):
            rs = [r for r in lbs.get(name, []) if r["budget"] == b]
            if not rs:
                continue
            c = budget_cell(rs, p)
            if "p_exact" in e:
                c["r_bet_mean_vs_exact"] = mean([r["L_bet"] / e["p_exact"] for r in rs])
                c["misses_vs_exact"] = sum(r["L"] > e["p_exact"] for r in rs)
            c["witness_ratio_max"] = max(r["L_wit"] for r in rs) / p if p else None
            e["budgets"][b] = c
            vs = f" (vs exact p: {c['r_bet_mean_vs_exact']:.3f})" if "p_exact" in e else ""
            out.append(f"    {b}: ratio {c['r_bet_mean']:.3f} [min {c['r_bet_min']:.3f}]{vs}, reported (max with the "
                       f"witness bound) {c['r_mean']:.3f}; K {c['K']:.0f} "
                       f"{c['evals_fpe']:.3g} fpe {c['seconds']:.1f} s; witnesses {c['n_witnesses_max']} "
                       f"(= {fmt(c['witness_ratio_max'])} p_ref); speedup KL x{fmt(c['speedup_kl_fpe'])} fpe "
                       f"x{fmt(c['speedup_kl_sec'])} s, task x{fmt(c['speedup_task_fpe'])} fpe "
                       f"x{fmt(c['speedup_task_sec'])} s")
        table.append(e)
    T["scaling"] = table


def sequential_table(rows, out, T):
    by = defaultdict(list)
    for r in rows:
        by[(r["name"], r["target"])].append(r)
    out.append("")
    out.append("SEQUENTIAL (anytime-valid): replicates (N = 1000) are added until L_bet >= target x running mean "
               "(at most 512); ratio = L_bet / p (p exact, or p_ref); cost in fpe and seconds; speedups at the mean "
               "ratio.")
    table = []
    for (name, tg), rs in sorted(by.items(), key=lambda kv: (rs_d(kv[1]), name_key(kv[0][0]), kv[0][1])):
        p = rs[0]["p"]
        rr = [r["ratio"] for r in rs]
        evals, secs = mean([r["evals"] for r in rs]), mean([r["seconds"] for r in rs])
        mc_sec = mean([r["mc_sec_per_sample"] for r in rs])
        e = dict(name=name, d=rs[0]["d"], p=p, p_kind=rs[0]["p_kind"], target=tg, runs=len(rs), ratio_mean=mean(rr),
                 ratio_min=min(rr), R_mean=mean([r["R"] for r in rs]), stopped=sum(r["stopped"] for r in rs),
                 evals_fpe=evals, seconds=secs, **yardsticks(p, mean(rr), evals, secs, mc_sec))
        table.append(e)
        out.append(f"  {name:26s} [{e['p_kind']:5s}] p={fmt(p)} target {tg}: ratio {e['ratio_mean']:.3f} "
                   f"[min {e['ratio_min']:.3f}] R {e['R_mean']:.0f} (stopped {e['stopped']}/{len(rs)}) "
                   f"{evals:.3g} fpe {secs:.1f} s; speedup KL x{fmt(e['speedup_kl_fpe'])} fpe "
                   f"x{fmt(e['speedup_kl_sec'])} s")
    T["sequential"] = table


def rs_d(rs):
    return rs[0]["d"]


# ------------------------------------------------------------ the rest

def other_tables(out, T):
    strat = load_rows(os.path.join(RES, "stratified.jsonl"))
    if strat:
        out.append("")
        out.append("STRATIFICATION (budget M, 3 trials): mean ratio of (stratum + SMC bound) without / with "
                   "stratification.")
        T["stratified"] = []
        for name in sorted({r["name"] for r in strat}, key=name_key):
            a = [r["ratio_smc_part"] for r in strat if r["name"] == name and not r["stratify"]]
            b = [r["ratio_smc_part"] for r in strat if r["name"] == name and r["stratify"]]
            T["stratified"].append(dict(name=name, plain=a, stratified=b))
            out.append(f"  {name:22s} plain {np.mean(a):.3f} [{min(a):.3f}-{max(a):.3f}]  stratified {np.mean(b):.3f} "
                       f"[{min(b):.3f}-{max(b):.3f}]")
    adv = load_rows(os.path.join(RES, "adversarial.jsonl"))
    if adv:
        out.append("")
        out.append("ADVERSARIAL NETS (run_adversarial.py).")
        T["adversarial"] = adv
        for kind in ("float", "planted"):
            for case in sorted({r["case"] for r in adv if r["kind"] == kind}):
                rs = [r for r in adv if r["kind"] == kind and r["case"] == case]
                out.append(f"  {kind:7s} {case:24s} d={rs[0]['d']:3d} p={fmt(rs[0]['p_exact'])} runs {len(rs)}: "
                           f"L = {', '.join(fmt(r['L']) for r in rs)}; misses {sum(r['miss'] for r in rs)}; "
                           f"point estimates {', '.join(fmt(r['point_estimate']) for r in rs)}")
        rnd = [r for r in adv if r["kind"] == "random"]
        for delta in sorted({r["delta"] for r in rnd}):
            c = [r for r in rnd if r["delta"] == delta]
            nets = len({r['case'] for r in c})
            out.append(f"  random untrained nets, delta = {delta}: {len(c)} runs on {nets} nets; "
                       f"misses {sum(r['miss'] for r in c)}; mean ratio {np.mean([r['ratio'] for r in c]):.3f}")
        camp = [r for r in adv if r["kind"] == "campaign"]
        if camp:
            for delta in sorted({r["delta"] for r in camp}):
                c = [r for r in camp if r["delta"] == delta]
                worst = max(c, key=lambda r: r["miss_lower"])
                out.append(f"  campaign delta = {delta}: {len(c)} cells x {c[0]['runs']} runs; worst miss rate of the "
                           f"reported bound {worst['miss_lower']:.3f} ({worst['net']}, {worst['config']}); worst SMC "
                           f"part {max(r['miss_smc'] for r in c):.3f}; witness bound misses "
                           f"{sum(r['miss_witness'] > 0 for r in c)}; mean flagged fraction "
                           f"{np.mean([r['flagged_fraction'] for r in c]):.3f}")
    for part, title in (("combine", "COMBINING RULES on the suite replicates (ablation.py combine)"),
                        ("unbiased", "UNBIASEDNESS of the variants, and coverage of the other rules "
                                     "(ablation.py unbiased)"),
                        ("kernels", "KERNELS (ablation.py kernels; 40 replicates, N = 1000, levels of the "
                                    "method's pilot)"),
                        ("soft", "SOFT LEVELS (ablation.py soft; 40 replicates, N = 1000)"),
                        ("proposals", "PROPOSALS (ablation.py proposals; 1e6 proposal samples in 32 batches)")):
        rows = load_rows(os.path.join(RES, f"ablation_{part}.jsonl"))
        if not rows:
            continue
        T.setdefault("ablation", {})[part] = rows
        out.append("")
        out.append(title + ".")
        if part == "combine":
            for b in ("M", "L"):
                c = [r for r in rows if r["budget"] == b]
                if c:
                    rb = np.mean([r['r_bet'] for r in c])
                    out.append(f"  budget {b}: {len(c)} runs; mean ratio betting {rb:.3f}, "
                               f"clipped KL {np.mean([r['r_clip'] for r in c]):.3f} "
                               f"[{min(r['r_clip'] for r in c):.2f}-{max(r['r_clip'] for r in c):.2f}], "
                               f"min-Markov {np.mean([r['r_min'] for r in c]):.3f} "
                               f"[{min(r['r_min'] for r in c):.2f}-{max(r['r_min'] for r in c):.2f}]; misses "
                               f"{sum(r['miss_clip'] for r in c)} / {sum(r['miss_min'] for r in c)}")
        else:
            for r in rows:
                out.append("  " + ", ".join(f"{k}={fmt(v) if isinstance(v, float) else v}" for k, v in r.items()
                                            if k != "part"))
    for fname in ("checks.txt", "mixing.txt", "failures.txt"):
        path = os.path.join(RES, fname)
        if os.path.exists(path):
            out.append("")
            out.append(f"{fname.upper()}:")
            out.extend("  " + line for line in open(path).read().splitlines())


# ------------------------------------------------------------ headlines

def headlines(T, out):
    H = {}
    suite = T.get("suite_exact", [])
    big = [e for e in suite if e["p"] >= 1e-5]
    if big and all("M" in e["budgets"] and "L" in e["budgets"] for e in big):
        for b in ("M", "L"):
            H[f"suite_p_ge_1e-5_{b}"] = dict(
                r_bet_mean_range=[min(e["budgets"][b]["r_bet_mean"] for e in big),
                                  max(e["budgets"][b]["r_bet_mean"] for e in big)],
                fpe_range=[min(e["budgets"][b]["evals_fpe"] for e in big),
                           max(e["budgets"][b]["evals_fpe"] for e in big)],
                seconds_range=[min(e["budgets"][b]["seconds"] for e in big),
                               max(e["budgets"][b]["seconds"] for e in big)])
    H["suite_small_p"] = [dict(name=e["name"], p=e["p"], fail_count=e["fail_count"],
                               **{f"{b}_{k}": e["budgets"][b][k] for b in e["budgets"]
                                  for k in ("r_bet_mean", "evals_fpe", "seconds", "r_wit_mean", "speedup_kl_fpe",
                                            "speedup_task_fpe", "speedup_kl_sec")})
                          for e in suite if 0 < e["p"] < 1e-5]
    H["suite_runs"] = sum(c["runs"] for e in suite for c in e["budgets"].values())
    H["suite_misses"] = sum(c["misses"] for e in suite for c in e["budgets"].values())
    H["suite_flagged_replicates"] = sum(c["flagged"] for e in suite for c in e["budgets"].values())
    eff = T.get("efficiency", [])
    if eff:
        H["mean_Z_over_p_range"] = [min(e["mean_Z_over_p"] for e in eff), max(e["mean_Z_over_p"] for e in eff)]
        H["mean_Z_over_p_extremes"] = [dict(name=e["name"], budget=e["budget"], value=e["mean_Z_over_p"],
                                            se=e["se_mean_Z_over_p"], replicates=e["replicates"])
                                       for e in (min(eff, key=lambda e: e["mean_Z_over_p"]),
                                                 max(eff, key=lambda e: e["mean_Z_over_p"]))]
    sc = T.get("scaling", [])
    H["scaling"] = [dict(name=e["name"], set=e["set"], d=e["d"], z=e["z"], p_ref=e["p_ref"],
                         ref_witnesses=e["ref_witnesses"], ref_evals_fpe=e["ref_evals_fpe"],
                         ref_seconds=e["ref_seconds"],
                         **{f"{b}_{k}": e["budgets"][b][k] for b in e["budgets"]
                            for k in ("r_bet_mean", "r_bet_min", "r_mean", "evals_fpe", "seconds", "n_witnesses_max")})
                    for e in sc]
    cells = [c for e in suite + sc for c in e["budgets"].values()]
    if cells:
        r = np.array([c["seconds_per_fpe"] / c["mc_seconds_per_sample"] for c in cells])
        H["smc_seconds_per_fpe_over_mc"] = dict(cells=len(r), min=float(r.min()), p10=float(np.percentile(r, 10)),
                                                median=float(np.median(r)), p90=float(np.percentile(r, 90)),
                                                max=float(r.max()))
    seq = T.get("sequential", [])
    H["sequential_0.9"] = [dict(name=e["name"], p=e["p"], ratio_mean=e["ratio_mean"], evals_fpe=e["evals_fpe"],
                                seconds=e["seconds"], speedup_kl_fpe=e["speedup_kl_fpe"])
                           for e in seq if e["target"] == 0.9]
    T["headlines"] = H
    out.append("HEADLINES (computed from the tables below; delta = 0.05; costs include the pilot).")
    for b in ("M", "L"):
        h = H.get(f"suite_p_ge_1e-5_{b}")
        if h:
            out.append(f"  exact suite, p >= 1e-5, budget {b}: mean L/p {h['r_bet_mean_range'][0]:.3f}-"
                       f"{h['r_bet_mean_range'][1]:.3f} at {h['fpe_range'][0]:.2g}-{h['fpe_range'][1]:.2g} fpe "
                       f"({h['seconds_range'][0]:.1f}-{h['seconds_range'][1]:.1f} s)")
    for e in H["suite_small_p"]:
        out.append(f"  {e['name']} (p = {e['p']:.3g}, {e['fail_count']} failing inputs): "
                   + "; ".join(f"{b}: L/p {e[f'{b}_r_bet_mean']:.3f} at {e[f'{b}_evals_fpe']:.2g} fpe "
                               f"({e[f'{b}_seconds']:.1f} s), speedup x{e[f'{b}_speedup_kl_fpe']:.3g} (KL, fpe), "
                               f"x{e[f'{b}_speedup_task_fpe']:.3g} (task, fpe); witnesses {e[f'{b}_r_wit_mean']:.2f} p"
                               for b in ("M", "L") if f"{b}_r_bet_mean" in e))
    out.append(f"  exact suite: {H['suite_runs']} runs, {H['suite_misses']} with L > p, "
               f"{H['suite_flagged_replicates']} flagged replicates")
    if "mean_Z_over_p_range" in H:
        lo, hi = H["mean_Z_over_p_extremes"]
        out.append(f"  mean of Z/p per (net, budget M or L): {H['mean_Z_over_p_range'][0]:.3f}-"
                   f"{H['mean_Z_over_p_range'][1]:.3f} (lowest {lo['name']} {lo['budget']}: {lo['value']:.3f} +- "
                   f"{lo['se']:.3f}, {lo['replicates']} replicates; highest {hi['name']} {hi['budget']}: "
                   f"{hi['value']:.3f} +- {hi['se']:.3f})")
    def scaling_cell(e, b):
        bet, rep = e[f"{b}_r_bet_mean"], e[f"{b}_r_mean"]
        wit = f" (with witnesses {rep:.3f})" if rep > bet + 0.01 else ""
        return (f"{b}: {bet:.3f} [min {e[f'{b}_r_bet_min']:.3f}]{wit} at {e[f'{b}_evals_fpe']:.2g} fpe "
                f"({e[f'{b}_seconds']:.0f} s)")

    for e in H["scaling"]:
        cells = "; ".join(scaling_cell(e, b) for b in ("S", "M", "L") if f"{b}_r_bet_mean" in e)
        if e["p_ref"] == 0:
            cells = (f"no reference replicate reached the last level ({e['ref_evals_fpe']:.2g} fpe, "
                     f"{e['ref_seconds']:.0f} s), {e['ref_witnesses']} witnesses: every bound is 0")
        out.append(f"  {e['name']} [{e['set']}] d={e['d']} z={e['z']:.2f} p_ref={fmt(e['p_ref'])}: "
                   + (cells or "lower-bound runs missing"))
    w = H.get("smc_seconds_per_fpe_over_mc")
    if w:
        out.append(f"  wall clock per fpe, SMC / batched Monte Carlo on the same net and process, over {w['cells']} "
                   f"(net, budget) cells: median {w['median']:.2f}, 10-90% {w['p10']:.2f}-{w['p90']:.2f}, range "
                   f"{w['min']:.2f}-{w['max']:.2f}")
    for e in H["sequential_0.9"]:
        out.append(f"  sequential, target 0.9, {e['name']} (p = {fmt(e['p'])}): ratio {e['ratio_mean']:.3f} at "
                   f"{e['evals_fpe']:.2g} fpe ({e['seconds']:.0f} s), speedup x{fmt(e['speedup_kl_fpe'])} (KL, fpe)")


def main():
    T = dict(machine=MACHINE, delta=DELTA,
             budgets=dict(S=dict(N=300, R=32), M=dict(N=1000, R=32), L=dict(N=3000, R=64), moves=10, rho=0.2),
             definitions=dict(
                 fpe="forward-pass equivalents: evaluations of the net on one input (SMC) or Monte Carlo samples",
                 seconds="wall-clock seconds of the run (pilot included), one process per run",
                 mc_seconds_per_sample="median wall-clock time per sample of batched plain Monte Carlo on the same "
                                       "net, measured in the same process",
                 speedup_kl="Monte Carlo samples for a one-sided (1-delta) KL lower bound reaching the same ratio at "
                            "empirical mean exactly p, divided by the SMC cost",
                 speedup_task="3 ln(2/delta) / ((1 - ratio)^2 p) divided by the SMC cost",
                 ratio="L_bet / p (exact p for d <= 28 and the enumerated d = 32 net, else p_ref)"))
    body = []
    suite = load_rows(os.path.join(RES, "suite.jsonl"))
    if suite:
        suite_tables(suite, body, T)
        efficiency_table(suite, body, T)
    scaling = load_rows(os.path.join(RES, "scaling.jsonl"))
    if scaling:
        scaling_tables(scaling, body, T)
    seq = load_rows(os.path.join(RES, "sequential.jsonl"))
    if seq:
        sequential_table(seq, body, T)
    other_tables(body, T)
    head = [f"SMC lower bounds (rareprob.nets_lower) on MLPs trained to output 1. Machine: {MACHINE}.",
            "Costs: fpe = forward-pass equivalents (one evaluation of the net on one input); seconds = wall clock.", ""]
    headlines(T, head)
    text = "\n".join(head + [""] + body)
    print(text)
    open(os.path.join(RES, "summary.txt"), "w").write(text + "\n")
    json.dump(T, open(os.path.join(RES, "tables.json"), "w"), indent=1, default=float)


if __name__ == "__main__":
    main()
