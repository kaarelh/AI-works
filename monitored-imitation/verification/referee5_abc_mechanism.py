"""Referee 5: why fooled humans' SI-V-ABC cost hardly grows with n in E6.

For fooled humans under SI-V-ABC (alpha = 0.3 and 0.1; seeds as in main_verifier_abc), every
rejected run has one committed mistake: the decoder commits the default value 1 when k_p = 2.
This script records, for each such mistake, the step j, the problem's t_p, the horizon n0, and
the set of idea times t still possible under the data the decoder used (D u A_<j). It also
reports the rejection rate per 100 problems and the search cost per human, by n.
Usage: python3 referee5_abc_mechanism.py
"""

import os
import sys
from collections import Counter
from multiprocessing import Pool

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(os.path.dirname(HERE), "code"))
import slack_imitation as si  # noqa: E402

import numpy as np  # noqa: E402

NOTHING, SET1, SET2, INC = si.NOTHING, si.SET1, si.SET2, si.INC


def run_abc_support(pr, tp, kp, alpha):
    """run_abc, recording the alive idea times at each committed SET step."""
    a, u = 0, 0
    run, codes, flags, support = [(0, 0)], [], [], {}
    asked = 0
    for j in range(pr.n):
        idx = np.flatnonzero(pr.alive)
        t, k, w = pr.t[idx], pr.k[idx], pr.w[idx]
        out = pr.outputs(j, a, u, t, k)
        mass = np.array([w[out == c].sum() for c in range(4)])
        tol = 1e-12 * w.sum()
        order = [INC, NOTHING, SET1, SET2] if a != 0 else [NOTHING, SET1, SET2, INC]
        best = order[0]
        for c in order[1:]:
            if mass[c] > mass[best] + tol:
                best = c
        if mass[best] < (1 - alpha) * w.sum() - tol:
            hum = int(pr.outputs(j, a, u, np.array([tp]), np.array([kp]))[0])
            pr.alive[idx[out != hum]] = False
            best = hum
            asked += 1
            flags.append(True)
        else:
            flags.append(False)
            if best in (SET1, SET2):
                support[j] = sorted(set(int(x) for x in t))
        if best == INC:
            u += 1
        elif best in (SET1, SET2):
            a, u = best, 0
        run.append((a, u))
        codes.append(best)
    pr.run, pr.codes, pr.asked = run, codes, flags
    return asked, support


def one(args):
    kind, n, seed, alpha = args
    persistent, D = si.KINDS[kind]
    n0 = n - n // 2
    rng = np.random.default_rng(seed)
    tp = rng.integers(0, n0, size=si.M)
    kp = np.where(rng.random(si.M) < si.PI, 1, 2)
    rng2 = np.random.default_rng(seed + 3 * 10**8)
    rec, search = [], 0
    for p in range(si.M):
        pr = si.Problem(n, n0, persistent, D)
        _, sup = run_abc_support(pr, tp[p], kp[p], alpha)
        while not pr.success(tp[p], kp[p]):
            for j in range(n):
                if not pr.asked[j] and pr.codes[j] != pr.human_step(j, tp[p], kp[p]):
                    rec.append((j, int(tp[p]), n0, sup.get(j)))
            held = []
            while True:
                j = int(rng2.integers(n))
                search += 1
                a, u = pr.run[j]
                hum = pr.human_step(j, tp[p], kp[p])
                if hum != pr.decoder_step(j):
                    break
                held.append((j, a, u, hum))
            for (jj, aa, uu, hh) in [(j, a, u, hum)] + held:
                idx = np.flatnonzero(pr.alive)
                out = pr.outputs(jj, aa, uu, pr.t[idx], pr.k[idx])
                pr.alive[idx[out != hh]] = False
            _, sup = run_abc_support(pr, tp[p], kp[p], alpha)
    return rec, search


def main():
    with Pool(4) as pool:
        for alpha in (0.3, 0.1):
            for n in (16, 64, 256):
                rows = pool.map(one, [("fooled", n, 1000 * n + s, alpha) for s in range(40)])
                recs = [r for rr, _ in rows for r in rr]
                search = np.mean([s for _, s in rows])
                n0 = n // 2
                gap = Counter(n0 - 1 - r[1] for r in recs)          # how far t_p is from the end
                size = Counter(len(r[3]) if r[3] else -1 for r in recs)
                pos = Counter("j == t_p" if r[0] == r[1] else ("j < t_p" if r[0] < r[1] else "j > t_p")
                              for r in recs)
                print(f"fooled, alpha = {alpha}, n = {n} (n0 = {n0}): committed mistakes on rejected runs "
                      f"{len(recs)} over 40 humans ({100 * len(recs) / 4000:.2f} per 100 problems); "
                      f"search queries per human {search:.1f}")
                print(f"    n0 - 1 - t_p: {dict(sorted(gap.items()))}")
                print(f"    number of idea times still possible when the default was committed: "
                      f"{dict(sorted(size.items()))}")
                print(f"    step of the commitment vs t_p: {dict(pos)}")
                sys.stdout.flush()


if __name__ == "__main__":
    main()
