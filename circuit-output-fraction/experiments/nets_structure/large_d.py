"""Heuristic predictions for the d = 64 and d = 128 suite nets (no exact p).

For each net: moments of f from 1e6 samples, a Monte Carlo reference from
4e6 samples (estimate if >= 20 failures, else the 95% upper bound 3/N), the
heuristics of heuristics.py (gauss, edgeworth, mcfit, lin_gauss, ginput,
sphere, poi_even for one hidden layer), and the expected number of failing
inputs 2^d * p_heuristic (the random-energy-model reading: p = 0 is likely
when it is << 1). Structure diagnostics on the lowest of 4e6 samples are not
attempted; see geometry.py for the relaxation witnesses.

usage: python3 large_d.py   (writes results/large_d.json)
"""

import math

import numpy as np

from common import save_json, suite, suite_net
from heuristics import (edgeworth, gauss, lin_gauss_cgf, lugannani_rice_lower, mcfit, poi_cgf, sus_curve)


def main():
    rng = np.random.default_rng(21)
    rows = []
    for r in suite():
        if r["d"] <= 28:
            continue
        net = suite_net(r["name"])
        d, t = net.d, net.threshold
        fs = []
        for _ in range(8):
            X = rng.choice([-1.0, 1.0], size=(500_000, d))
            fs.append(net.forward(X))
        f = np.concatenate(fs)
        N = len(f)
        mu, sd = float(f[:1_000_000].mean()), float(f[:1_000_000].std())
        y = (f[:1_000_000] - mu) / sd
        k3, k4 = float((y ** 3).mean()), float((y ** 4).mean() - 3)
        cnt = int((f < t).sum())
        o = dict(name=r["name"], d=d, widths=net.widths, loss=net.loss, step=r["step"], mean=mu, std=sd,
                 z=(mu - t) / sd, skew=k3, exkurt=k4, mc_N=N, mc_count=cnt,
                 mc_p=cnt / N if cnt >= 20 else None, mc_upper95=(cnt + 3.0) / N if cnt < 20 else None)
        o["gauss"] = gauss(t, mu, sd)
        o["edgeworth"] = edgeworth(t, mu, sd, k3, k4)
        o["mcfit"] = mcfit(net, rng)(t)
        o["lin_gauss"] = lugannani_rice_lower(lin_gauss_cgf(net, mu, sd * sd, rng), t, sd)
        o["ginput"] = sus_curve(lambda G: net.forward(G), d, t - 1e-9, rng)(t)
        o["sphere"] = sus_curve(lambda G: net.forward(G * (math.sqrt(d) / np.linalg.norm(G, axis=1))[:, None]), d,
                                t - 1e-9, rng)(t)
        if len(net.Ws) == 2:
            o["poi_even"] = lugannani_rice_lower(poi_cgf(net, "even"), t, sd)
        for m in ("gauss", "mcfit", "ginput", "sphere"):
            o[f"log2_count_{m}"] = d + math.log2(o[m]) if o[m] and o[m] > 0 else None
        rows.append(o)
        print({k: (f"{v:.3g}" if isinstance(v, float) else v) for k, v in o.items()}, flush=True)
        save_json(rows, "large_d.json")


if __name__ == "__main__":
    main()
