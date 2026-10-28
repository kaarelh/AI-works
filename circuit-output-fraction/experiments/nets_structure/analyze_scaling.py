"""Summaries of results/scaling_*.json (nets trained here, exact p).

  * p, z = (mean - t)/sd and sd by training step (median over seeds), per
    configuration and d;
  * power-law fit sd ~ step^(-alpha) and the resulting log(1/p) ~ z^2/2 growth;
  * when is p = 0: fraction of nets with p = 0 against the Gaussian expected
    count 2^d Phi(-z) (the random-energy-model prediction: p = 0 once
    z > sqrt(2 d ln 2) roughly);
  * Walsh statistics by step (d <= 20): mean degree, odd share, participation;
  * evenness corr(f(x), f(-x)) by depth and loss.

usage: python3 analyze_scaling.py   (writes results/scaling_summary.json and prints tables)
"""

import glob
import json
import math
import os
from collections import defaultdict

import numpy as np
from scipy.special import log_ndtr

from common import RES, save_json


def load():
    rows = []
    for path in sorted(glob.glob(os.path.join(RES, "scaling_*.json"))):
        if path.endswith("summary.json"):
            continue
        rows += json.load(open(path))
    return rows


def main():
    rows = load()
    out = {}
    groups = defaultdict(list)
    for r in rows:
        groups[(r["config"], r["d"], "x".join(map(str, r["widths"])))].append(r)
    print("=== median over seeds by step: p (fraction of seeds with p=0) z sd")
    fits = []
    for key in sorted(groups):
        g = groups[key]
        steps = sorted({r["step"] for r in g})
        line = []
        sds, sts = [], []
        for s in steps:
            rs = [r for r in g if r["step"] == s]
            ps = np.array([r["p"] for r in rs])
            zs = np.array([r["z"] for r in rs])
            sd = np.array([r["std"] for r in rs])
            line.append(f"s{s}: {np.median(ps):.1e}({(ps == 0).mean():.2f}) z={np.median(zs):.1f}")
            sds.append(np.median(sd))
            sts.append(s)
        sts, sds = np.array(sts, float), np.array(sds)
        k = sts >= sts.max() / 20
        alpha = -np.polyfit(np.log(sts[k]), np.log(sds[k]), 1)[0]
        fits.append(dict(config=key[0], d=key[1], widths=key[2], sd_power=float(alpha), steps=sts.tolist(),
                         sd=sds.tolist()))
        print(key, f"sd ~ step^-{alpha:.2f}", " | ".join(line))
    out["fits"] = fits
    # log(1/p) ~ step^beta over the snapshots with 0 < p < 0.05 (all seeds pooled), per config and d
    print("\n=== log(1/p) ~ step^beta (0 < p < 0.05), and z ~ step^gamma")
    pf = []
    for key in sorted(groups):
        g = [r for r in groups[key] if 0 < r["p"] < 0.05]
        if len({r["step"] for r in g}) < 3:
            continue
        x = np.log([r["step"] for r in g])
        beta = np.polyfit(x, np.log([-math.log(r["p"]) for r in g]), 1)[0]
        gam = np.polyfit(x, np.log([max(r["z"], 1e-3) for r in g]), 1)[0]
        # first step at which at least half of the seeds have p = 0
        steps = sorted({r["step"] for r in groups[key]})
        s0 = next((s for s in steps if np.mean([r["p"] == 0 for r in groups[key] if r["step"] == s]) >= 0.5), None)
        pf.append(dict(config=key[0], d=key[1], widths=key[2], beta=float(beta), gamma=float(gam), step_half_p0=s0))
        print(key, f"beta={beta:.2f} gamma={gam:.2f} first step with >= half the seeds at p=0: {s0}")
    out["p_vs_step"] = pf
    # p = 0 against the Gaussian expected count
    print("\n=== p = 0 vs Gaussian expected count 2^d Phi(-z)")
    bins = [(-np.inf, -2), (-2, -1), (-1, 0), (0, 1), (1, 2), (2, np.inf)]
    tab = []
    for loss in ("mse", "bce"):
        for lo, hi in bins:
            sel = [r for r in rows if r["loss"] == loss and
                   lo <= (r["d"] * math.log10(2) + log_ndtr(-r["z"]) / math.log(10)) < hi]
            if not sel:
                continue
            z0 = np.mean([r["p"] == 0 for r in sel])
            tab.append(dict(loss=loss, log10_count_lo=lo, log10_count_hi=hi, n=len(sel), frac_p0=float(z0)))
            print(f"{loss}: log10 E[count] in [{lo},{hi}): n={len(sel)} fraction p=0: {z0:.2f}")
    out["p0_vs_count"] = tab
    # z at the transition vs sqrt(2 d ln 2)
    print("\n=== largest z with p > 0 and smallest z with p = 0, per d (all configs)")
    trans = []
    for loss, d in sorted({(r["loss"], r["d"]) for r in rows}):
        rs = [r for r in rows if r["d"] == d and r["loss"] == loss]
        zpos = [r["z"] for r in rs if r["p"] > 0]
        zzero = [r["z"] for r in rs if r["p"] == 0]
        zmin_std = [(r["mean"] - r["fmin"]) / r["std"] for r in rs]
        trans.append(dict(loss=loss, d=d, max_z_pos=max(zpos) if zpos else None, min_z_zero=min(zzero) if zzero else None,
                          median_zmin=float(np.median(zmin_std)), rem=math.sqrt(2 * d * math.log(2))))
        print(f"{loss} d={d}: max z with p>0 {max(zpos) if zpos else None:.2f}, min z with p=0 {min(zzero) if zzero else float('nan'):.2f}, "
              f"median (mean-min f)/sd {np.median(zmin_std):.2f}, sqrt(2 d ln2) {math.sqrt(2 * d * math.log(2)):.2f}")
    out["transition"] = trans
    # Walsh
    print("\n=== Walsh (d <= 20): mean degree / odd share / participation by step (median over seeds)")
    wal = []
    for key in sorted(groups):
        g = [r for r in groups[key] if "mean_degree" in r]
        if not g:
            continue
        steps = sorted({r["step"] for r in g})
        line = []
        for s in steps:
            rs = [r for r in g if r["step"] == s]
            md = np.median([r["mean_degree"] for r in rs])
            od = np.median([r["odd_share"] for r in rs])
            pr = np.median([r["participation"] for r in rs])
            w2 = np.median([r["W"][1] for r in rs])
            line.append(f"s{s}: {md:.2f}/{od:.2f}/{pr:.0f}/W2={w2:.2f}")
            wal.append(dict(config=key[0], d=key[1], widths=key[2], step=s, mean_degree=float(md), odd_share=float(od),
                            participation=float(pr), W2=float(w2)))
        print(key, " ".join(line))
    out["walsh"] = wal
    print("\n=== evenness corr(f(x), f(-x)) (median) and skewness by config")
    ev = []
    for cfg in sorted({r["config"] for r in rows}):
        rs = [r for r in rows if r["config"] == cfg]
        c = np.median([r["corr_f_fneg"] for r in rs])
        sk = np.median([r["skew"] for r in rs])
        ku = np.median([r["exkurt"] for r in rs])
        ev.append(dict(config=cfg, corr_f_fneg=float(c), skew=float(sk), exkurt=float(ku)))
        print(cfg, f"corr={c:.3f} skew={sk:.3f} exkurt={ku:.3f}")
    out["evenness"] = ev
    save_json(out, "scaling_summary.json")


if __name__ == "__main__":
    main()
