"""Two hidden layers: are failures caused by rarely active second-layer units?

For f = a . relu(z2) + c, z2 = W2 relu(z1) + b2, each second-layer unit k
contributes a_k relu(z2_k). For every failing input we find the unit whose
contribution deviates most (downwards) from its typical mean, in units of its
typical sd, and record that unit's activation probability pi_k = Pr[z2_k > 0]
and its share of the total drop of f. A unit with small pi_k and a_k < 0 is a
natural "planted subregion" (cf. Thm. blackbox): almost always off, and pulling
f down in the rare region where it fires.

usage: python3 depth2.py   (writes results/depth2.json)
"""

import glob
import json
import os

import numpy as np

from common import HERE, RES, all_f, decode, load_net, save_json, suite_net

CACHE = os.path.join(HERE, "cache")


def analyse(net, name, S_idx, F, rng):
    d = net.d
    R = rng.choice([-1.0, 1.0], size=(200000, d))
    fR, preR = net.forward(R, keep=True)
    a = net.Ws[-1][0]
    cR = a * np.maximum(preR[-1], 0)
    mu_c, sd_c = cR.mean(0), cR.std(0) + 1e-12
    pi = (preR[-1] > 0).mean(0)
    S = decode(S_idx[:20000], d)
    fS, preS = net.forward(S, keep=True)
    cS = a * np.maximum(preS[-1], 0)
    dev = cS - mu_c
    k = np.argmin(dev, axis=1)
    drop = fR.mean() - fS
    share_top = dev[np.arange(len(S)), k] / -drop
    zdev = -dev[np.arange(len(S)), k] / sd_c[k]
    units, counts = np.unique(k, return_counts=True)
    order = np.argsort(-counts)
    top = [dict(unit=int(units[i]), frac=float(counts[i] / len(S)), pi=float(pi[units[i]]), a=float(a[units[i]]))
           for i in order[:3]]
    rare = (pi < 0.01) & (a < 0)
    return dict(name=name, d=d, widths=net.widths, loss=net.loss, F=int(F), n_rare_neg_units=int(rare.sum()),
                frac_failures_dominated_by_rare_unit=float(np.mean(rare[k])),
                median_top_unit_share_of_drop=float(np.median(share_top)), median_top_unit_zdev=float(np.median(zdev)),
                top_units=top)


def main():
    rng = np.random.default_rng(17)
    rows = []
    for path in sorted(glob.glob(os.path.join(CACHE, "*x*_s*.npz"))):
        name = os.path.basename(path)[:-4]
        z = np.load(path)
        F = int(z["fail_count"])
        if F == 0:
            continue
        o = analyse(suite_net(name), name, z["fail_i"], F, rng)
        rows.append(o)
        print(o, flush=True)
    for sp in sorted(glob.glob(os.path.join(RES, "scaling_*2.json"))):
        for r in json.load(open(sp)):
            if r["seed"] != 0 or not (0 < r["p"] <= 0.05) or r["d"] < 20:
                continue
            net = load_net(os.path.join(CACHE, "own", r["name"] + ".npz"))
            f = all_f(net)
            S = np.where(f < net.threshold)[0]
            if len(S) > 20000:
                S = rng.choice(S, 20000, replace=False)
            o = analyse(net, r["name"], S, r["F"], rng)
            o["step"] = r["step"]
            rows.append(o)
            print(o, flush=True)
    save_json(rows, "depth2.json")


if __name__ == "__main__":
    main()
