"""Thread F, experiment F1b: check-before-committing (CSI-CBC, Theorem F2(c)) on the class of
threadF_certified.py. During the run, before the decoder's step is committed, its entry is checked;
if it is invalid, the human is asked for that step instead (added to the data at once). After the
run, one uniform task query. Same humans, seeds and rounds as the CSI cells of F1.

Usage: python3 threadF_cbc.py
"""

import sys
import time
from multiprocessing import Pool

import numpy as np

import threadF_certified as F


class ProbCBC(F.Prob):
    def build(self, alpha):
        if self.built == self.version:
            return 0
        asks = 0
        st = (0, 0, 0, 0)
        states, codes, asked = [st], [], []
        for j in range(self.n):
            idx = np.flatnonzero(self.alive)
            out = self.outs(j, st, idx)
            w = self.w[idx]
            mass = np.bincount(out, weights=w, minlength=F.NCODES)
            tol = 1e-12 * w.sum()
            order = ([F.INC, F.NOTHING, F.SETUP, F.STUCK2, F.WEAK, F.VAL1, F.VAL2] if st[2] != 0 else
                     [F.NOTHING, F.SETUP, F.STUCK2, F.WEAK, F.VAL1, F.VAL2, F.INC])
            best = order[0]
            for c in order[1:]:
                if mass[c] > mass[best] + tol:
                    best = c
            if F.invalid(best, self.kp):            # the check fires before committing
                hum = self.human(j, st)
                self.alive[idx[out != hum]] = False
                best, a = hum, True
                asks += 1
            else:
                a = False
            codes.append(best)
            asked.append(a)
            st = F.advance(st, best)
            states.append(st)
        self.states, self.codes, self.asked = states, codes, asked
        if asks:                                  # the data changed during the run, so
            self.version += 1                     # the next round must rebuild it
            self.built = -1
        else:
            self.built = self.version
        return asks


def one(args):
    typ, kind, r, n, seed, R = args
    n0 = n // 2
    T = n0 - 5
    rng = np.random.default_rng(seed)
    tp = rng.integers(0, T, size=F.M)
    kp = np.where(rng.random(F.M) < F.PI, 1, 2)
    probs = [ProbCBC(typ, kind, r, n, n0, tp[p], kp[p]) for p in range(F.M)]
    rng2 = np.random.default_rng(seed + 7 * 10**8)
    failed = asks = hits = 0
    for _ in range(R):
        p = int(rng2.integers(F.M))
        pr = probs[p]
        asks += pr.build(None)
        failed += not pr.success()
        hits += pr.query(int(rng2.integers(n)))
    return failed, asks, hits


def main():
    H = 20
    t0 = time.time()
    print(f"F1b: CSI-CBC, {H} humans per cell, {F.M} problems, R = 4*M*n rounds, sigma = n/2")
    with Pool(4) as pool:
        for n in [32, 64, 128]:
            for typ in ["C", "N", "W"]:
                R = 4 * F.M * n
                rows = pool.map(one, [(typ, "trusting", 1, n, 5000 * n + s, R) for s in range(H)])
                f = np.array([x[0] for x in rows], dtype=float)
                print(f"{typ}_trusting_r1_n{n}_CSI-CBC   failed {f.mean():7.1f} ± "
                      f"{f.std(ddof=1) / np.sqrt(H):5.1f}; check-triggered asks "
                      f"{np.mean([x[1] for x in rows]):5.1f}; hits {np.mean([x[2] for x in rows]):6.1f}"
                      f"  [{time.time() - t0:.0f}s]")
                sys.stdout.flush()


if __name__ == "__main__":
    main()
