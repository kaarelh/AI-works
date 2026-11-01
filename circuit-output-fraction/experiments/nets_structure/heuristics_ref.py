"""Heuristics at d = 32 ... 128 against the SMC reference values of
experiments/nets_lower (results/scaling.jsonl, kind "ref": the mean of
independent fixed-plan SMC runs, unbiased; NOT exact, relative s.e. a few %;
cross-checked there by Monte Carlo when p_ref > 2e-6). Read-only use of that
folder's nets and numbers. Moments of f from 1e6 samples.

usage: python3 heuristics_ref.py   (writes results/heuristics_ref.json)
"""

import json
import math
import os

import numpy as np

from common import ROOT, load_net, save_json
from heuristics import (edgeworth, gauss, lin_gauss_cgf, lugannani_rice_lower, mcfit, poi_cgf, sus_curve)

LOWER = os.path.join(ROOT, "experiments", "nets_lower", "results")


def main():
    refs = [json.loads(l) for l in open(os.path.join(LOWER, "scaling.jsonl")) if '"kind": "ref"' in l]
    rng = np.random.default_rng(41)
    rows = []
    for r in refs:
        path = os.path.join(LOWER, "scaling_nets", r["name"] + ".npz")
        if not os.path.exists(path):
            continue
        net = load_net(path)
        d, t = net.d, net.threshold
        fs = [net.forward(rng.choice([-1.0, 1.0], size=(250_000, d))) for _ in range(4)]
        f = np.concatenate(fs)
        mu, sd = float(f.mean()), float(f.std())
        y = (f - mu) / sd
        k3, k4 = float((y ** 3).mean()), float((y ** 4).mean() - 3)
        o = dict(name=r["name"], d=d, widths=net.widths, loss=net.loss, step=r["step"], z=(mu - t) / sd,
                 skew=k3, exkurt=k4, p_ref=r["p_ref"], p_ref_se=r["p_ref_se"])
        o["gauss"] = gauss(t, mu, sd)
        o["edgeworth"] = edgeworth(t, mu, sd, k3, k4)
        o["mcfit"] = mcfit(net, rng)(t)
        o["lin_gauss"] = lugannani_rice_lower(lin_gauss_cgf(net, mu, sd * sd, rng), t, sd)
        o["ginput"] = sus_curve(lambda G: net.forward(G), d, t - 1e-9, rng)(t)
        o["sphere"] = sus_curve(lambda G: net.forward(G * (math.sqrt(d) / np.linalg.norm(G, axis=1))[:, None]), d,
                                t - 1e-9, rng)(t)
        if len(net.Ws) == 2:
            o["poi_even"] = lugannani_rice_lower(poi_cgf(net, "even"), t, sd)
        if r["p_ref"] > 0:
            for m in ("gauss", "edgeworth", "mcfit", "lin_gauss", "ginput", "sphere", "poi_even"):
                v = o.get(m)
                o[f"log10ratio_{m}"] = math.log10(v / r["p_ref"]) if v and v > 1e-299 else None
        rows.append(o)
        print(r["name"], f"z={o['z']:.2f} p_ref={r['p_ref']:.2e}",
              " ".join(f"{m}={o[m]:.1e}" for m in ("gauss", "edgeworth", "mcfit", "lin_gauss", "ginput", "sphere")),
              flush=True)
        save_json(rows, "heuristics_ref.json")


if __name__ == "__main__":
    main()
