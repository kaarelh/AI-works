"""How large can the subcubes of a sound subcube-partition argument be?

A sound procedure that partitions {-1,+1}^d into subcubes, certifies f >= t on
some (they must contain no failure) and samples or enumerates inside the rest
(an envelope made of subcube indicators, as in input branch and bound) pays at
least one unit per certified subcube. For a point x let

  k(x)  = the largest dimension of a failure-free subcube containing x (x not in S),
  kS(x) = the largest dimension of a subcube inside S containing x (x in S).

Any partition into monochromatic subcubes has at least sum_x 2^{-k(x)} pieces
(each piece Q holds |Q| points, each contributing 1/|Q| <= 2^{-k(x)}); one that
leaves undecided pieces of total mass Z and certifies the rest has at least
LB(Z) = 2^d * (the sum of the smallest 2^{-k(x)} / 2^d over a (1 - Z) share of
the non-failing mass) certified pieces, and sampling the undecided mass costs
~ (Z/p) * 3 ln(2/delta) / eps^2 more (envelope estimator, K = Z/p). We compute
k(x) EXACTLY (upward closure of {x xor s : s in S} over all 2^d free-sets) for
sampled x, on nets with d <= 20 trained here, and compare with the random-set
prediction k ~ d - log2 F + log2 d and with Monte Carlo.

usage: python3 subcube.py [name-substring ...]
"""

import glob
import json
import math
import os
import sys

import numpy as np

from common import HERE, RES, all_f, load_net, save_json

OWN = os.path.join(HERE, "cache", "own")
EPS, DELTA = 0.1, 0.05
CMC = 3 * math.log(2 / DELTA) / EPS ** 2


def popcounts(d):
    idx = np.arange(1 << d, dtype=np.int64)
    pc = np.zeros(1 << d, dtype=np.int8)
    for i in range(d):
        pc += ((idx >> i) & 1).astype(np.int8)
    return pc


def up_closure(A, d):
    n = A.shape[0]
    for i in range(d):
        B = A.reshape(-1, 2, 1 << i)
        B[:, 1, :] |= B[:, 0, :]
    return A.reshape(n)


def down_and(G, d):
    """G[T] = AND of G[T'] over T' subset of T."""
    n = G.shape[0]
    for i in range(d):
        B = G.reshape(-1, 2, 1 << i)
        B[:, 1, :] &= B[:, 0, :]
    return G.reshape(n)


def k_values(S_idx, inS, d, pc, xs):
    ks = []
    for x in xs:
        A = np.zeros(1 << d, dtype=bool)
        A[S_idx ^ x] = True
        A = up_closure(A, d)
        ks.append(int(pc[~A].max()))
    return np.array(ks)


def analyse_set(inS, d, name, rng, nx=300):
    S_idx = np.where(inS)[0].astype(np.int64)
    F = len(S_idx)
    if F == 0:
        return None
    p = F / 2.0 ** d
    pc = popcounts(d)
    ks = k_values(S_idx, inS, d, pc, rng.choice(np.where(~inS)[0], size=nx, replace=True))
    ksS = []
    for x in rng.choice(S_idx, size=min(nx, F), replace=False):
        G = inS[np.arange(1 << d, dtype=np.int64) ^ x].copy()
        G = down_and(G, d)
        ksS.append(int(pc[G].max()))
    ksS = np.array(ksS)
    # control: a uniformly random set of the same size
    R_idx = rng.choice(1 << d, size=F, replace=False).astype(np.int64)
    inR = np.zeros(1 << d, dtype=bool)
    inR[R_idx] = True
    kr = k_values(R_idx, inR, d, pc, rng.choice(np.where(~inR)[0], size=max(30, nx // 5), replace=True))
    # pieces of any monochromatic subcube partition (decision tree with exact leaves)
    lb_full = 2.0 ** d * ((1 - p) * np.mean(2.0 ** -ks) + p * np.mean(2.0 ** -ksS))
    # certify all but mass Z = K p of the cube, sample the rest (envelope looseness K)
    w = np.sort(2.0 ** -ks)
    out = dict(name=name, d=d, F=F, p=p, k_mean=float(ks.mean()), k_min=int(ks.min()), k_max=int(ks.max()),
               kS_mean=float(ksS.mean()), kS_max=int(ksS.max()), k_randomset_mean=float(kr.mean()),
               lb_partition=float(lb_full), F_over_d=F / d, mc_cost=CMC / p)
    best = math.inf
    for K in (1, 3, 10, 30, 100, 300, 1000, 3000, 1e4, 1e5):
        Z = K * p
        if Z >= 1:
            cost = CMC * K  # sample everything (Monte Carlo is K = 1/p)
        else:
            frac = 1 - (Z - p) / (1 - p)  # share of the non-failing mass certified
            j = int(math.ceil(frac * len(w)))
            cost = 2.0 ** d * (1 - p) * (w[:j].sum() / len(w)) + CMC * K
        out[f"lb_K{int(K)}"] = float(cost)
        best = min(best, cost)
    best = min(best, CMC / p)
    out["lb_best"] = float(best)
    out["speedup_bound"] = float((CMC / p) / best)
    return out


def analyse(net, name, rng, nx=300):
    d, t = net.d, net.threshold
    f = all_f(net)
    return analyse_set(f < t, d, name, rng, nx)


def main():
    subs = sys.argv[1:] or ["_d16_w32_seed0", "_d20_w32_seed0", "_d16_w32x32_seed0", "_d20_w32x32_seed0"]
    rng = np.random.default_rng(3)
    rows = []
    paths = sorted(glob.glob(os.path.join(OWN, "*.npz")))
    for path in paths:
        name = os.path.basename(path)[:-4]
        if not any(s in name for s in subs):
            continue
        net = load_net(path)
        if net.d > 20:
            continue
        o = analyse(net, name, rng)
        if o is None:
            continue
        rows.append(o)
        print(name, "F=%d k=%.2f [%d,%d] random-set k=%.2f kS=%.2f LBpartition=%.3g F/d=%.3g MC=%.3g best=%.3g (speedup <= %.3g)" % (
            o["F"], o["k_mean"], o["k_min"], o["k_max"], o["k_randomset_mean"], o["kS_mean"], o["lb_partition"],
            o["F_over_d"], o["mc_cost"], o["lb_best"], o["speedup_bound"]), flush=True)
        save_json(rows, "subcube.json")
        # (all nets matching the filters; rerun to refresh)


if __name__ == "__main__":
    main()
