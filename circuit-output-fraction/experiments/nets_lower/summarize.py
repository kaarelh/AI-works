"""Tables from results/*.jsonl (printed, and written to results/summary.txt)."""

import json
import math
import os
from collections import defaultdict

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
R = os.path.join(HERE, "results")


def load(name):
    path = os.path.join(R, name)
    return [json.loads(l) for l in open(path)] if os.path.exists(path) else []


def fmt(x, nd=3):
    if x is None or (isinstance(x, float) and math.isnan(x)):
        return "-"
    return f"{x:.{nd}g}"


def suite_table(rows, out):
    by = defaultdict(list)
    for r in rows:
        by[(r["name"], r["budget"])].append(r)
    out.append("SUITE (exact p). ratio = lower/p, mean [min] over trials; MC = samples a Monte Carlo KL lower bound "
               "needs for the same ratio as the mean betting ratio; speedup = MC / evaluations (pilot included).")
    out.append(f"{'net':24s} {'p':>9s} {'B':1s} {'n':>2s} {'K':>3s} {'evals':>8s} {'r_bet':>13s} {'r_clip':>6s} "
               f"{'r_min':>6s} {'r_wit':>6s} {'MC':>8s} {'speedup':>8s} {'miss':>4s}")
    order = {"S": 0, "M": 1, "L": 2}
    for (name, b), rs in sorted(by.items(), key=lambda kv: (kv[0][0].split("_s")[0], int(kv[0][0].split("_s")[-1]),
                                                             order[kv[0][1]])):
        p = rs[0]["p_exact"]
        ev = np.mean([r["evals"] for r in rs])
        K = np.mean([r["K"] for r in rs])
        miss = sum(r["miss"] for r in rs)
        if p == 0:
            out.append(f"{name:24s} {'0':>9s} {b} {len(rs):2d} {K:3.0f} {ev:8.2g} {'L=0 (all)':>13s} "
                       f"{'':6s} {'':6s} {'':6s} {'':8s} {'':8s} {miss:4d}")
            continue
        rb = [r["r_bet"] for r in rs]
        from_mc = [r["mc_samples_same_ratio"] for r in rs]
        mc = float(np.median(from_mc))
        out.append(f"{name:24s} {p:9.3g} {b} {len(rs):2d} {K:3.0f} {ev:8.2g} {np.mean(rb):6.3f} [{min(rb):.2f}] "
                   f"{np.mean([r['r_clip'] for r in rs]):6.3f} {np.mean([r['r_min'] for r in rs]):6.3f} "
                   f"{np.mean([r['r_wit'] for r in rs]):6.3f} {mc:8.2g} {mc / ev:8.2g} {miss:4d}")


def efficiency_table(rows, refs, out):
    """kappa = (relative variance of one replicate) x (evaluations per replicate):
    the evaluations an unbiased estimator needs per unit of squared relative
    error; for Monte Carlo kappa = (1 - p)/p."""
    by = defaultdict(list)
    for r in rows:
        Z = r.get("Z_over_p") or r.get("Z_over_pref")
        if Z is None and r.get("Z") is not None and r.get("p_exact"):
            Z = [z / r["p_exact"] for z in r["Z"]]
        if not Z:
            continue
        by[(r["name"], r["budget"])].append((np.array(Z), r["evals_final"] / len(Z) if "evals_final" in r else None))
    out.append("")
    out.append("EFFICIENCY: kappa = relvar(Z) x evaluations per replicate (pooled over trials) versus Monte Carlo's 1/p.")
    for (name, b), lst in sorted(by.items()):
        Z = np.concatenate([z for z, _ in lst])
        cost = np.mean([c for _, c in lst if c is not None]) if any(c is not None for _, c in lst) else float("nan")
        p = refs.get(name)
        rv = Z.var() / max(Z.mean(), 1e-300) ** 2
        if p:
            out.append(f"  {name:24s} {b} replicates {len(Z):4d} mean Z/p {Z.mean():.3f} relvar {rv:.3f} "
                       f"cost/replicate {cost:.3g} kappa {rv * cost:.3g} 1/p {1 / p:.3g} gain {(1 / p) / (rv * cost):.3g}")


def scaling_table(rows, out):
    refs = {r["name"]: r for r in rows if r["kind"] == "ref"}
    lbs = defaultdict(list)
    for r in rows:
        if r["kind"] == "lb":
            lbs[(r["name"], r["budget"])].append(r)
    out.append("")
    out.append("SCALING (no exact p). p_ref = mean of 100 SMC replicates (N=3000) +- standard error; p_mc = plain "
               "Monte Carlo where run; ratio = lower / p_ref.")
    for name, ref in refs.items():
        mc = f" p_mc={ref['p_mc']:.3g} ({ref['mc_hits']} hits / {ref['mc_n']:.2g})" if "p_mc" in ref else ""
        out.append(f"{name}: z={ref['z']:.2f} p_ref={ref['p_ref']:.3g} +- {ref['p_ref_se']:.2g} "
                   f"(replicate relvar {ref['ref_relvar']:.2f}, K={ref['ref_K']}){mc}")
        for b in ("S", "M", "L"):
            rs = lbs.get((name, b), [])
            if not rs:
                continue
            rb = [r["r_bet"] for r in rs]
            ev = np.mean([r["evals"] for r in rs])
            mcn = np.median([r["mc_samples_same_ratio"] for r in rs])
            wit = max(r["L_wit"] for r in rs)
            out.append(f"    {b}: ratio {np.mean(rb):.3f} [min {min(rb):.3f}] evals {ev:.3g} MC-same-ratio {mcn:.3g} "
                       f"speedup {mcn / ev:.3g}; witnesses (best run) {wit * 2.0 ** rs[0]['d']:.0f} = "
                       f"{wit / ref['p_ref']:.3g} p_ref")


def main():
    out = []
    suite = load("suite.jsonl")
    suite_table(suite, out)
    efficiency_table([r for r in suite if r["budget"] in ("M", "L")],
                     {r["name"]: r["p_exact"] for r in suite if r["p_exact"] > 0}, out)
    scaling_table(load("scaling.jsonl"), out)
    checks = load("mc_checks.jsonl")
    ex = os.path.join(R, "exact_d32.json")
    if checks or os.path.exists(ex):
        out.append("")
        out.append("REFERENCE CHECKS.")
        for c in checks:
            out.append(f"  {c['name']}: Monte Carlo {c['mc_hits']} hits / {c['mc_n']:.2g} -> p = {c['p_mc']:.4g} +- "
                       f"{c['p_mc_se']:.2g}; SMC reference {c['p_ref']:.4g} +- {c['p_ref_se']:.2g}")
        if os.path.exists(ex):
            e = json.load(open(ex))
            out.append(f"  {e['name']}: exact enumeration of 2^32 inputs: {e['fail_count']} failing, p = "
                       f"{e['p_exact']:.4g}; SMC reference {e['p_ref']:.4g} +- {e['p_ref_se']:.2g}")
    seq = load("sequential.jsonl")
    if seq:
        out.append("")
        out.append("SEQUENTIAL (stop when the betting bound >= target x running mean; anytime-valid).")
        by = defaultdict(list)
        for r in seq:
            by[(r["name"], r["target"])].append(r)
        for (name, tg), rs in sorted(by.items()):
            ev = np.mean([r["evals"] for r in rs])
            rr = [r["ratio"] for r in rs]
            mc = np.median([r["mc_samples_same_ratio"] for r in rs])
            out.append(f"  {name:24s} target {tg}: ratio {np.mean(rr):.3f} [min {min(rr):.3f}] R {np.mean([r['R'] for r in rs]):.0f} "
                       f"evals {ev:.3g} MC {mc:.3g} speedup {mc / ev:.3g}")
    prop = load("proposals.jsonl")
    if prop:
        out.append("")
        out.append("PROPOSALS (fitted to SMC samples; 3e6 proposal samples in 32 batches; betting bound; "
                   "p = exact, or p_ref for the scaling nets).")
        for r in prop:
            out.append(f"  {r['name']:24s} {r['proposal']:6s} [{r.get('p_kind', 'exact')}] ratio {r['ratio']:.3f} "
                       f"E[W]/p {r['mean_over_p']:.3f} "
                       f"per-sample relvar {r['per_sample_relvar']:.3g} fit samples {r['samples_fit']} "
                       f"(distinct {r['distinct_fit']})")
    adv = load("adversarial.jsonl") + load("adversarial_hidden.jsonl")
    if adv:
        out.append("")
        out.append("ADVERSARIAL / UNTRAINED NETS.")
        pl = [r for r in adv if r["kind"] == "planted"]
        for r in pl:
            out.append(f"  {r['case']:18s} p={r['p_exact']:.3g} L={r['L']:.3g} (smc {r['L_bet']:.3g}, witness "
                       f"{r['L_wit']:.3g}) point estimate {r['point_estimate']:.3g} miss={r['miss']}")
        cov = [r for r in adv if r["kind"] == "coverage"]
        for delta in sorted(set(r["delta"] for r in cov)):
            c = [r for r in cov if r["delta"] == delta]
            out.append(f"  coverage delta={delta}: {len(c)} runs on {len(set(r['net'] for r in c))} random nets; "
                       f"misses betting {sum(r['miss_bet'] for r in c)}, clipped {sum(r['miss_clip'] for r in c)}, "
                       f"min-Markov {sum(r['miss_min'] for r in c)}; mean ratio {np.mean([r['ratio'] for r in c]):.3f}")
    text = "\n".join(out)
    print(text)
    open(os.path.join(R, "summary.txt"), "w").write(text + "\n")


if __name__ == "__main__":
    main()
