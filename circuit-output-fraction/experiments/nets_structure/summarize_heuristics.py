"""Accuracy of the heuristic estimators against exact tail probabilities.

Reads results/heuristics_suite.json and results/heuristics_own.json. For every
method, over all (net, level) test points with exact P > 0: the distribution
of log10(estimate / exact), split by loss, depth and by the size of P, at the
net's own threshold and at all levels. An estimate of 0 (or the 1e-300 floor of
a negative Edgeworth value) counts as a failure ("none").

usage: python3 summarize_heuristics.py   (writes results/heuristics_summary.json)
"""

import json
import math
import os

import numpy as np

from common import RES, save_json

METHODS = ["gauss", "gauss_mc", "edgeworth", "mcfit", "lin_gauss", "ginput", "sphere", "poi_relu", "poi_even",
           "poi_walsh", "min_mcfit_sphere", "select"]


_CORR = {}


def evenness(name):
    """corr(f(x), f(-x)) from 2e4 samples (exact value for nets trained here)."""
    if name in _CORR:
        return _CORR[name]
    import glob as _g
    for sp in _g.glob(os.path.join(RES, "scaling_*.json")):
        if sp.endswith("summary.json"):
            continue
        for r in json.load(open(sp)):
            _CORR[r["name"]] = r["corr_f_fneg"]
    if name not in _CORR:
        from common import suite_net
        net = suite_net(name)
        X = np.random.default_rng(0).choice([-1.0, 1.0], size=(20000, net.d))
        _CORR[name] = float(np.corrcoef(net.forward(X), net.forward(-X))[0, 1])
    return _CORR[name]


def select(L, net):
    """Selector by architecture and loss (both known to the estimator): one hidden
    layer + squared loss (the even, small-ball regime) -> mcfit; otherwise -> the
    sphere surrogate. (An evenness-based rule, corr(f(x), f(-x)) > 0.5, fails on
    long-trained one-layer squared-loss nets whose odd part grows, where the
    sphere surrogate is off by up to 5 orders of magnitude.)"""
    return L.get("mcfit") if (len(net["widths"]) == 1 and net["loss"] == "mse") else L.get("sphere")


def derived(L):
    """min(mcfit, sphere): on trained nets both heuristics fail by OVERestimating
    (mcfit on light-tailed logistic-loss logits and at d >> width; the sphere
    surrogate on squared-loss small-ball events at d ~ width)."""
    a, b = L.get("mcfit"), L.get("sphere")
    if a is None or b is None:
        return None
    return min(a, b)


def stats(vals):
    v = np.array([x for x in vals if x is not None and np.isfinite(x)])
    none = sum(1 for x in vals if x is None or not np.isfinite(x))
    if len(v) == 0:
        return dict(n=0, none=none)
    a = np.abs(v)
    return dict(n=int(len(v)), none=int(none), median=float(np.median(v)), mad=float(np.median(a)),
                q90=float(np.quantile(a, 0.9)), max=float(a.max()), within2=float((a <= math.log10(2)).mean()),
                within10=float((a <= 1).mean()))


def main():
    pts = []
    import glob
    for path in sorted(glob.glob(os.path.join(RES, "heuristics_*.json"))):
        if path.endswith("summary.json") or path.endswith("_ref.json"):
            continue
        which = "suite" if "suite" in os.path.basename(path) else "own"
        for net in json.load(open(path)):
            depth = len(net["widths"])
            for L in net["levels"]:
                L["min_mcfit_sphere"] = derived(L)
                L["select"] = select(L, net)
                if L["P"] <= 0:
                    continue
                e = dict(src=which, name=net["name"], d=net["d"], loss=net["loss"], depth=depth, kind=L["kind"],
                         P=L["P"], z=L["z"])
                for m in METHODS:
                    v = L.get(m)
                    if v is None and m in ("poi_relu", "poi_even", "poi_walsh"):
                        continue
                    e[m] = math.log10(v / L["P"]) if (v is not None and v > 1e-299) else None
                pts.append(e)
    out = {}
    splits = {
        "all": lambda e: True,
        "threshold": lambda e: e["kind"] == "threshold",
        "mse": lambda e: e["loss"] == "mse",
        "bce": lambda e: e["loss"] == "bce",
        "depth1": lambda e: e["depth"] == 1,
        "depth2": lambda e: e["depth"] == 2,
        "P>1e-3": lambda e: e["P"] > 1e-3,
        "1e-6<P<=1e-3": lambda e: 1e-6 < e["P"] <= 1e-3,
        "P<=1e-6": lambda e: e["P"] <= 1e-6,
        "mse_depth1_P<=1e-4": lambda e: e["loss"] == "mse" and e["depth"] == 1 and e["P"] <= 1e-4,
        "bce_depth1_P<=1e-4": lambda e: e["loss"] == "bce" and e["depth"] == 1 and e["P"] <= 1e-4,
        "mse_depth2_P<=1e-4": lambda e: e["loss"] == "mse" and e["depth"] == 2 and e["P"] <= 1e-4,
        "bce_depth2_P<=1e-4": lambda e: e["loss"] == "bce" and e["depth"] == 2 and e["P"] <= 1e-4,
    }
    for sname, sel in splits.items():
        sub = [e for e in pts if sel(e)]
        out[sname] = {"points": len(sub), "nets": len({e["name"] for e in sub})}
        for m in METHODS:
            vals = [e[m] for e in sub if m in e]
            if vals:
                out[sname][m] = stats(vals)
    # p = 0 or not: predict p = 0 iff the expected number of failing inputs 2^d * estimate < 1
    cls = {}
    for path in sorted(glob.glob(os.path.join(RES, "heuristics_*.json"))):
        if path.endswith("summary.json") or path.endswith("_ref.json"):
            continue
        for net in json.load(open(path)):
            L = net["levels"][0]
            assert L["kind"] == "threshold"
            L["min_mcfit_sphere"] = derived(L)
            L["select"] = select(L, net)
            for m in METHODS:
                v = L.get(m)
                if v is None:
                    continue
                c = cls.setdefault(m, dict(n=0, correct=0, p0=0, p0_pred_right=0, ppos=0, ppos_pred_right=0))
                pred0 = (2.0 ** net["d"]) * v < 1
                c["n"] += 1
                if L["P"] == 0:
                    c["p0"] += 1
                    c["p0_pred_right"] += int(pred0)
                else:
                    c["ppos"] += 1
                    c["ppos_pred_right"] += int(not pred0)
                c["correct"] += int(pred0 == (L["P"] == 0))
    out["p0_classification"] = cls
    print("== predicting p = 0 by 2^d * estimate < 1 (threshold of every net):")
    for m, c in cls.items():
        print(f"  {m:10s} accuracy {c['correct'] / c['n']:.3f}  (p=0 nets: {c['p0_pred_right']}/{c['p0']} right; "
              f"p>0 nets: {c['ppos_pred_right']}/{c['ppos']} right)")
    save_json(out, "heuristics_summary.json")
    for sname, d in out.items():
        if "points" not in d:
            continue
        print(f"== {sname}: {d['points']} points, {d['nets']} nets   (log10 est/exact: median, median|.|, q90|.|, "
              f"max|.|, within x2, within x10, none)")
        for m in METHODS:
            s = d.get(m)
            if not s or s["n"] == 0:
                continue
            print(f"  {m:10s} {s['median']:+6.2f} {s['mad']:5.2f} {s['q90']:5.2f} {s['max']:6.2f} "
                  f"{s['within2']:5.2f} {s['within10']:5.2f} {s['none']:4d}")


if __name__ == "__main__":
    main()
