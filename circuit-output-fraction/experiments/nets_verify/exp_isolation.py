"""Where the failing inputs are, for the one-hidden-layer suite nets with
2 ... 20000 failing points.

The failing points are collected by the exact branch and bound (collect=...)
and compared: Hamming distances between failing points (minimum, mean), the
fraction of failing points with a failing neighbour (if none has one, every
certified-failing subcube is a single point, so any subcube-partition proof of
a lower bound >= (1 - eps) p has at least (1 - eps) F failing leaves and any
proof of an upper bound <= (1 + eps) p must isolate all but an eps-fraction
of the failures in leaves of their own), the connected components of the
failing set under Hamming distance 1, and the dimension of a greedily grown
all-failing subcube around each failing point. Writes
results/isolation.json.
"""

import json
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net  # noqa: E402
from rareprob.nets_verify import bab  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")
OUT = os.path.join(HERE, "results")


def main(max_fail=20000):
    suite = json.load(open(os.path.join(NETS, "suite.json")))
    out = []
    rng = np.random.default_rng(0)
    for row in suite:
        if "fail_count" not in row or not 2 <= row["fail_count"] <= max_fail:
            continue
        if len(row["widths"]) > 1:
            continue  # two hidden layers: the exact count is slow (see exp_suite.py); skipped
        net = load_net(os.path.join(NETS, row["name"] + ".npz"))
        col = []
        res = bab(net, r_enum=4, min_rate=0.01, collect=col)
        assert not res.fail_cubes
        X = np.concatenate(col).astype(np.int64)
        assert len(X) == res.fail == row["fail_count"]
        F, d = X.shape
        S = X if F <= 4000 else X[rng.choice(F, 4000, replace=False)]
        D = (d - S @ S.T) // 2  # Hamming distances
        iu = np.triu_indices(len(S), 1)
        dist = D[iu]
        # failing neighbours (distance 1) among all failures, via a hash set
        keys = {x.tobytes() for x in X.astype(np.int8)}
        nb = 0
        for x in X.astype(np.int8):
            for i in range(d):
                y = x.copy()
                y[i] = -y[i]
                if y.tobytes() in keys:
                    nb += 1
                    break
        # connected components of the failing set under Hamming distance 1,
        # and for every failing point a greedily grown subcube of failing
        # points around it (its dimension lower-bounds the largest failing
        # subcube containing the point)
        Xi = X.astype(np.int8)
        index = {x.tobytes(): i for i, x in enumerate(Xi)}
        parent = list(range(F))

        def find(i):
            while parent[i] != i:
                parent[i] = parent[parent[i]]
                i = parent[i]
            return i

        for i, x in enumerate(Xi):
            for k in range(d):
                y = x.copy()
                y[k] = -y[k]
                j = index.get(y.tobytes())
                if j is not None:
                    parent[find(i)] = find(j)
        comp = {}
        for i in range(F):
            comp.setdefault(find(i), 0)
            comp[find(i)] += 1
        sizes = sorted(comp.values(), reverse=True)
        dims = []
        for x in Xi[: min(F, 2000)]:
            pts = [x]
            dim = 0
            for k in range(d):
                flipped = []
                for q in pts:
                    y = q.copy()
                    y[k] = -y[k]
                    flipped.append(y)
                if all(y.tobytes() in index for y in flipped):
                    pts = pts + flipped
                    dim += 1
            dims.append(dim)
        dims = np.array(dims)
        mean_x = X.mean(0)
        o = dict(name=row["name"], d=d, F=F, p=row["p_exact"], min_dist=int(dist.min()), mean_dist=float(dist.mean()),
                 frac_dist_le_2=float((dist <= 2).mean()), frac_with_failing_neighbour=nb / F,
                 mean_abs_coord_of_mean_failing_input=float(np.abs(mean_x).mean()),
                 random_pair_mean_dist=d / 2, components=len(sizes), largest_components=sizes[:5],
                 mean_component_size=F / len(sizes), greedy_failing_subcube_dim_hist=np.bincount(dims).tolist())
        print(o, flush=True)
        out.append(o)
        json.dump(out, open(os.path.join(OUT, "isolation.json"), "w"), indent=1)


if __name__ == "__main__":
    main()
