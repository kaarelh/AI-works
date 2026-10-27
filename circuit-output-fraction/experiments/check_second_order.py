"""Exact check of the second-order independence sandwich (paper, appendix A)
on random small instances: increasing events given as monotone DNFs over a
few variables, under random product distributions; every probability is
computed by enumeration. Writes results/second_order_check.json."""

import itertools
import json
import math
import os

import numpy as np

OUT = os.path.join(os.path.dirname(__file__), "results")


def run(trials=400, seed=11):
    rng = np.random.default_rng(seed)
    viol = 0
    widths = []
    for t in range(trials):
        n = int(rng.integers(8, 15))
        q = rng.uniform(0.05, 0.5, n)
        X = ((np.arange(1 << n)[:, None] >> np.arange(n)) & 1).astype(bool)
        w = np.prod(np.where(X, q, 1 - q), axis=1)
        m = int(rng.integers(3, 9))
        events, sups = [], []
        for i in range(m):
            S = rng.choice(n, size=int(rng.integers(2, 5)), replace=False)
            # random monotone function on S: a random up-set given by a monotone DNF
            terms = [rng.choice(S, size=int(rng.integers(1, len(S) + 1)), replace=False) for _ in range(int(rng.integers(1, 3)))]
            ev = np.zeros(len(X), dtype=bool)
            for T in terms:
                ev |= X[:, T].all(axis=1)
            sup = set(int(v) for T in terms for v in T)
            events.append(ev)
            sups.append(sup)
        P = lambda mask: float(w[mask].sum())
        noB = np.ones(len(X), dtype=bool)
        for ev in events:
            noB &= ~ev
        p = P(noB)
        b = [P(ev) for ev in events]
        nb = lambda i, j: bool(sups[i] & sups[j])
        lo_f, hi_f = 1.0, 1.0
        ok_beta = True
        logM2 = 0.0
        E3 = 0.0
        for i in range(m):
            N = [j for j in range(i) if nb(i, j)]
            R = [j for j in range(i) if not nb(i, j)]
            beta = sum(b[j] for j in N)
            if beta >= 1:
                ok_beta = False
                break
            C = sum(P(events[i] & events[j]) - b[i] * b[j] for j in N)
            Th = b[i] * (sum(P(events[j] & events[k]) for j in N for k in R if nb(j, k))
                         + sum(P(events[j] & events[jj]) for j, jj in itertools.combinations(N, 2)))
            Thp = (sum(P(events[i] & events[j] & events[k]) for j in N for k in R if nb(j, k))
                   + sum(P(events[i] & events[j] & events[jj]) for j, jj in itertools.combinations(N, 2)))
            lo_f *= 1 - min(b[i], b[i] - C + Thp / (1 - beta))
            hi_f *= 1 - max(0.0, b[i] - (C + Th) / (1 - beta))
            logM2 += math.log(1 - b[i] + C)
            E3 += (Th + Thp + beta * C) / ((1 - beta) * (1 - b[i]))
        if not ok_beta or p == 0:
            continue
        bad = not (lo_f <= p * (1 + 1e-9) and p <= hi_f * (1 + 1e-9)) or abs(math.log(p) - logM2) > E3 + 1e-9
        viol += bad
        widths.append(E3)
    return dict(trials=len(widths), violations=viol, median_E3=float(np.median(widths)))


if __name__ == "__main__":
    r = run()
    print(r)
    json.dump(r, open(os.path.join(OUT, "second_order_check.json"), "w"), indent=1)
