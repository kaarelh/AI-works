"""Brute-force check of Lemma S of slack-imitation.md on random append-only humans.

Notebooks are subsets of a universe of U items (bitmasks). A human is a random deterministic
map y -> P(y) with P(y) a superset of y. Success S is "contains a target set T", which appending
preserves. tau(y) = number of the human's own steps from y to success (inf if never).

For random problems x0 with tau(x0) = n0 <= n and random append-only decoders, every run of n
steps is classified, and the identity behind Lemma S is checked:

  if the run fails and tau stays finite, then  sum over mistakes k of (1 + D_k)  >= sigma + 1,

where D_k = tau(x'_{k+1}) - tau(x'_k) is the actual setback at mistake k and sigma = n - n0.
In particular, with every D_k <= D, a failed run has at least (sigma + 1)/(D + 1) mistakes.

Usage: python3 setback_check.py
"""

import numpy as np

U = 8
INF = 10**6


def random_human(rng):
    N = 1 << U
    P = np.zeros(N, dtype=np.int64)
    for y in range(N):
        add = 0
        for i in range(U):
            if rng.random() < 0.15:
                add |= 1 << i
        P[y] = y | add
    return P


def remaining_time(P, T):
    N = len(P)
    tau = np.full(N, INF, dtype=np.int64)
    for y in range(N):
        z, m, seen = y, 0, set()
        while (z & T) != T and z not in seen and m <= N:
            seen.add(z)
            z = int(P[z])
            m += 1
        if (z & T) == T:
            tau[y] = m
    return tau


def main():
    rng = np.random.default_rng(20261120)
    runs = fails = violations = 0
    min_slack_margin = None
    single_mistake_fails = 0
    unbounded = 0
    for h in range(400):
        P = random_human(rng)
        T = int(rng.integers(1, 1 << U))
        tau = remaining_time(P, T)
        starts = [y for y in range(1 << U) if 1 <= tau[y] <= 6]
        if not starts:
            continue
        for _ in range(30):
            x0 = int(rng.choice(starts))
            n0 = int(tau[x0])
            sigma = int(rng.integers(0, 6))
            n = n0 + sigma
            # a random append-only decoder: at each step, with prob. 0.7 the human's step,
            # otherwise a random superset of the notebook
            y, total, mistakes, dmax, finite = x0, 0, 0, -INF, True
            for k in range(n):
                hy = int(P[y])
                if rng.random() < 0.7:
                    g = hy
                else:
                    add = int(rng.integers(0, 1 << U)) & int(rng.integers(0, 1 << U))
                    g = y | add
                if g != hy:
                    mistakes += 1
                    if tau[g] >= INF:
                        finite = False
                    else:
                        d = int(tau[g]) - int(tau[y])
                        total += 1 + d
                        dmax = max(dmax, d)
                y = g
            runs += 1
            failed = (y & T) != T
            if not failed:
                continue
            fails += 1
            if mistakes == 1:
                single_mistake_fails += 1
            if not finite:
                unbounded += 1
                continue
            margin = total - (sigma + 1)
            D = max(dmax, 0)
            if margin < 0 or mistakes * (D + 1) < sigma + 1:
                violations += 1
            if min_slack_margin is None or margin < min_slack_margin:
                min_slack_margin = margin
    print(f"runs {runs}, failed {fails}, failed with a single mistake {single_mistake_fails}")
    print(f"failed runs with an infinite setback (tau = inf after a mistake): {unbounded}")
    print(f"failed runs with finite setbacks violating  sum(1 + D_k) >= sigma + 1  or"
          f"  |M|(D + 1) >= sigma + 1: {violations}")
    print(f"smallest margin sum(1 + D_k) - (sigma + 1) on those runs: {min_slack_margin}")


if __name__ == "__main__":
    main()
