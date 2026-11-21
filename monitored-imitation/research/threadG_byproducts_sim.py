"""Thread G: by-product insights under slack imitation (exact Bayes, small class).

The class BYPROD (thread E's V5, with scaffold variants). There are m problems. Problem p has,
with probability ETA, an insight of value k_p in {1, 2} (uniform) triggered by routine unit t_p
(uniform on 0..N-1); otherwise no insight (t_p = inf). Every work step of the human's own chain
does one routine unit; the routine always completes within the run. Success: the final notebook
contains the insight k_p if t_p < inf, and no insight otherwise. There is no dependent work, so
lateness never matters here: the experiment isolates *loss* of an insight.

The variants differ only in U_k, the set of units whose trigger fires at step k. The human
writes k_p at step k iff the notebook has no insight yet and t_p is in U_k. All U_k are
intervals, and none depends on theta, so the step structure of a run is known to every
hypothesis.
  DO       doing only (silent): U_k = {k} for k < N, empty afterwards.
  RECHECK  doing only; once the routine is done the human rechecks units cyclically:
           U_k = {(k - N) mod N} for k >= N (no seed needed).
  REDO     doing only, seeded re-derivation: while units remain, with probability 1/2 the step
           redoes a uniformly random done unit instead of a new one; once done, it rechecks a
           uniform unit. The seed is part of the step's input in both chains.
  WINDOW   readable from raw records, attention window a: U_k = [k - a, k] for k < N and
           [N - a, N) afterwards (the human reads the last a raw records).
  REVIEW   readable; after every L work steps a review step reads every raw record:
           U = [0, units done). Work steps: U_k = {unit done}.

Learner: exact posterior over (t, v) in [N] x {1, 2} plus "no insight"; the majority decoder
(ties go to writing nothing, then to value 1). Protocols: SI (uniform step), LASTREV (last
review step), MIXREV (last review with probability 1/2, else uniform). Cost: task queries until
at most EPS of the m problems fail (oracle stopping, as in E6). ABC: online, R rounds of
ask-before-committing (alpha = 0.3) plus one uniform query per round; reports failed runs and
asks, against SI's failed runs over the same rounds.

Usage: python3 threadG_byproducts_sim.py [--quick]
"""

import sys
import time
from multiprocessing import Pool

import numpy as np

EPS, ETA, M = 0.02, 0.5, 100
L_REV, A_WIN, P_REDO = 4, 4, 0.5
TOL = 1e-12


def schedule(variant, N, rng=None):
    """Return (n0, n, lo, hi, review_steps): the human's routine horizon, the run length (slack
    rho = 1/2, so n = 2 n0), and U_k = [lo[k], hi[k]) for each step of one run."""
    if variant == "DO0":                      # chained imitation, no slack
        n0, n = N, N
    elif variant in ("DO", "RECHECK", "WINDOW"):
        n0, n = N, 2 * N
    elif variant == "REDO":
        n0, n = 2 * N, 4 * N                  # expected routine time N / (1 - P_REDO)
    elif variant == "REVIEW":
        n0 = N + N // L_REV
        n = 2 * n0
    lo, hi, rev = np.zeros(n, int), np.zeros(n, int), []
    if variant in ("DO0", "DO", "RECHECK"):
        for k in range(n):
            if k < N:
                lo[k], hi[k] = k, k + 1
            elif variant == "RECHECK":
                r = (k - N) % N
                lo[k], hi[k] = r, r + 1
    elif variant == "WINDOW":
        for k in range(n):
            if k < N:
                lo[k], hi[k] = max(0, k - A_WIN), k + 1
            else:
                lo[k], hi[k] = N - A_WIN, N
    elif variant == "REDO":
        j = 0
        for k in range(n):
            if j < N and not (j >= 1 and rng.random() < P_REDO):
                lo[k], hi[k] = j, j + 1
                j += 1
            else:
                r = int(rng.integers(j))
                lo[k], hi[k] = r, r + 1
    elif variant == "REVIEW":
        j, since = 0, 0
        for k in range(n):
            if since == L_REV:
                lo[k], hi[k] = 0, j
                rev.append(k)
                since = 0
            else:
                if j < N:
                    lo[k], hi[k] = j, j + 1
                    j += 1
                since += 1
    return n0, n, lo, hi, rev


class Problem:
    """Exact posterior for one problem: weights W[t, v] (v = 0, 1 for values 1, 2) and w_inf."""

    def __init__(self, N):
        self.N = N
        self.W = np.full((N, 2), ETA / (2 * N))
        self.w_inf = 1.0 - ETA
        self._cum()

    def _cum(self):
        self.C = np.vstack([np.zeros((1, 2)), np.cumsum(self.W, axis=0)])
        self.total = self.C[-1].sum() + self.w_inf

    def masses(self, lo, hi):
        """Arrays over steps: mass of 'writes value 1', 'writes value 2', 'writes nothing'."""
        m = self.C[hi] - self.C[lo]
        return m[..., 0], m[..., 1], self.total - m[..., 0] - m[..., 1]

    def decide(self, m1, m2, m0):
        """Majority label at one step: 0 nothing, 1 or 2 a value (ties: nothing, then 1)."""
        tol = TOL * self.total
        best, bm = 0, m0
        if m1 > bm + tol:
            best, bm = 1, m1
        if m2 > bm + tol:
            best = 2
        return best

    def run(self, lo, hi):
        """The decoder's run: (write step or -1, value written). Before the write, notebooks lack
        the insight; after it, every step is routine and all hypotheses agree."""
        m1, m2, m0 = self.masses(lo, hi)
        tol = TOL * self.total
        cand = np.flatnonzero((np.maximum(m1, m2) > m0 + tol))
        if len(cand) == 0:
            return -1, 0
        k = int(cand[0])
        return k, self.decide(m1[k], m2[k], m0[k])

    def update(self, lo, hi, ans):
        """Datum: at a notebook lacking the insight, with trigger set [lo, hi), the human wrote
        ans (0 nothing, else the value)."""
        inside = np.zeros(self.N, bool)
        inside[lo:hi] = True
        if ans == 0:
            self.W[inside, :] = 0.0
        else:
            self.W[~inside, :] = 0.0
            self.W[:, 2 - ans] = 0.0          # keep only value ans
            self.w_inf = 0.0
        self._cum()


def human(lo, hi, tp, kp):
    return kp if (tp >= 0 and lo <= tp < hi) else 0


def success(pr, lo, hi, tp, kp):
    k, v = pr.run(lo, hi)
    return (k >= 0 and v == kp) if tp >= 0 else (k < 0)


def success_redo(pr, tp, kp):
    """REDO: every run touches every unit as a singleton step (the routine completes; checked
    separately), so the run writes iff some singleton {u} is writable; then u = t_p."""
    m = pr.W
    m0 = pr.total - m.sum(axis=1)
    ok = np.maximum(m[:, 0], m[:, 1]) > m0 + TOL * pr.total
    if tp < 0:
        return not ok.any()
    if not ok.any():
        return False
    u = int(np.flatnonzero(ok)[0])
    return u == tp and (1 if m[u, 0] > m[u, 1] else 2) == kp


def one_human(args):
    variant, N, proto, seed, cap = args
    rng = np.random.default_rng(seed)
    tp = np.where(rng.random(M) < ETA, rng.integers(0, N, M), -1)
    kp = rng.integers(1, 3, M)
    probs = [Problem(N) for _ in range(M)]
    rng2 = np.random.default_rng(seed + 10**7)
    seeded = variant == "REDO"
    if not seeded:
        n0, n, lo, hi, rev = schedule(variant, N)
        ok = np.array([success(probs[p], lo, hi, tp[p], kp[p]) for p in range(M)])
    else:
        ok = np.array([success_redo(probs[p], tp[p], kp[p]) for p in range(M)])
    queries = hits = 0
    while (M - ok.sum()) / M > EPS and queries < cap:
        p = int(rng2.integers(M))
        pr = probs[p]
        if seeded:
            n0, n, lo, hi, rev = schedule(variant, N, rng2)
        wk, wv = pr.run(lo, hi)
        if proto == "SI":
            k = int(rng2.integers(n))
        elif proto == "LASTREV":
            k = rev[-1]
        elif proto == "MIXREV":
            k = rev[-1] if rng2.random() < 0.5 else int(rng2.integers(n))
        queries += 1
        if wk >= 0 and k > wk:
            continue                          # routine step after the insight: correct, no information
        ans = human(lo[k], hi[k], tp[p], kp[p])
        dec = wv if k == wk else 0
        hits += ans != dec
        pr.update(lo[k], hi[k], ans)
        ok[p] = success_redo(pr, tp[p], kp[p]) if seeded else success(pr, lo, hi, tp[p], kp[p])
    return queries, (M - ok.sum()) / M, hits


def abc_human(args):
    """Online: R rounds. mode 'SI' = plain runs, uniform query; 'MIX' = plain runs, query the
    last review step with probability 1/2, else uniform; 'ABC' / 'ABCMIX' = the same with ask
    before committing at alpha. Each round: a uniform problem, a run, one task query. Returns
    (failed runs, asks, mistakes found by the query)."""
    variant, N, mode, alpha, R, seed = args
    rng = np.random.default_rng(seed)
    tp = np.where(rng.random(M) < ETA, rng.integers(0, N, M), -1)
    kp = rng.integers(1, 3, M)
    probs = [Problem(N) for _ in range(M)]
    rng2 = np.random.default_rng(seed + 10**7)
    n0, n, lo, hi, rev = schedule(variant, N)
    failed = asks = found = 0
    for _ in range(R):
        p = int(rng2.integers(M))
        pr = probs[p]
        have = 0                               # value in the notebook (0: none)
        ins_step, ins_asked = n, False         # step at which the insight entered the notebook
        asked_steps = set()
        for k in range(n):
            if have:
                break                          # the rest of the run is routine
            m1, m2, m0 = pr.masses(np.array([lo[k]]), np.array([hi[k]]))
            m1, m2, m0 = float(m1[0]), float(m2[0]), float(m0[0])
            top = max(m0, m1, m2)
            if mode.startswith("ABC") and top < (1 - alpha) * pr.total - TOL * pr.total:
                ans = human(lo[k], hi[k], tp[p], kp[p])
                pr.update(lo[k], hi[k], ans)
                asks += 1
                asked_steps.add(k)
                if ans:
                    have, ins_step, ins_asked = ans, k, True
            else:
                d = pr.decide(m1, m2, m0)
                if d:
                    have, ins_step = d, k
        okrun = (have == kp[p]) if tp[p] >= 0 else (have == 0)
        failed += not okrun
        # One uniform task query at the run's state. Steps after the insight entered are
        # routine (uninformative); asked steps are the human's own (never mistakes).
        if mode.endswith("MIX") and rng2.random() < 0.5:
            k = rev[-1]                        # the last review step
        else:
            k = int(rng2.integers(n))
        if k > ins_step or k in asked_steps:
            continue
        ans = human(lo[k], hi[k], tp[p], kp[p])
        dec = have if (k == ins_step and not ins_asked) else 0
        found += ans != dec
        pr.update(lo[k], hi[k], ans)
    return failed, asks, found


def main(quick=False):
    H = 10 if quick else 40
    Ns = [8, 32] if quick else [8, 32, 128]
    cells = [("DO0", "SI"), ("DO", "SI"), ("RECHECK", "SI"), ("REDO", "SI"),
             ("WINDOW", "SI"), ("REVIEW", "SI"), ("REVIEW", "LASTREV"), ("REVIEW", "MIXREV")]
    t0 = time.time()
    print(f"BYPROD: m = {M}, eta = {ETA}, q = 2, target failure {EPS}; L = {L_REV}, a = {A_WIN}, "
          f"redo rate {P_REDO}; {H} humans per cell; slack rho = 1/2 except DO0.")
    # sanity: the human's own chain completes the routine in REDO
    rng = np.random.default_rng(1)
    for N in Ns:
        inc = 0
        for _ in range(2000):
            n0, n, lo, hi, rev = schedule("REDO", N, rng)
            done = set()
            for k in range(n):
                if hi[k] - lo[k] == 1:
                    done.add(int(lo[k]))
            inc += len(done) < N
        print(f"REDO N={N}: runs in which some unit is never touched: {inc}/2000")
    print()
    print("| variant | protocol | " + " | ".join(f"N = {N}" for N in Ns) + " |")
    print("|---|---|" + "---|" * len(Ns))
    with Pool(4) as pool:
        for variant, proto in cells:
            row = []
            for N in Ns:
                n0, n, *_ = schedule(variant, N, np.random.default_rng(0))
                cap = 400 * M * n
                rows = pool.map(one_human, [(variant, N, proto, 7919 * N + s, cap) for s in range(H)])
                q = np.array([r[0] for r in rows], float)
                f = np.array([r[1] for r in rows], float)
                reached = int((f <= EPS).sum())
                cell = f"{q.mean():,.0f} ± {q.std(ddof=1) / np.sqrt(H):,.0f}"
                if reached < H:
                    cell += f" ({reached}/{H} reached)"
                row.append(f"{cell} [n={n}]")
            print(f"| {variant} | {proto} | " + " | ".join(row) + f" |  [{time.time() - t0:.0f}s]")
            sys.stdout.flush()
    print()
    R = 1000 if quick else 3000
    Habc = 10 if quick else 20
    print(f"Online, {R} rounds, {Habc} humans, alpha = 0.3: failed runs, and asks for the ABC modes")
    print("| variant | N | SI failed | MIX failed | ABC failed / asks | ABC+MIX failed / asks |")
    print("|---|---|---|---|---|---|")
    with Pool(4) as pool:
        for variant in ["DO", "REVIEW"]:
            for N in Ns:
                res = {}
                for mode in (["SI", "ABC"] if variant == "DO" else ["SI", "MIX", "ABC", "ABCMIX"]):
                    rows = pool.map(abc_human, [(variant, N, mode, 0.3, R, 104729 * N + s)
                                                for s in range(Habc)])
                    res[mode] = (np.mean([r[0] for r in rows]), np.mean([r[1] for r in rows]))
                f = lambda md: f"{res[md][0]:,.1f}" if md in res else "–"
                g = lambda md: f"{res[md][0]:,.1f} / {res[md][1]:,.1f}" if md in res else "–"
                print(f"| {variant} | {N} | {f('SI')} | {f('MIX')} | {g('ABC')} | {g('ABCMIX')} |"
                      f"  [{time.time() - t0:.0f}s]")
                sys.stdout.flush()


if __name__ == "__main__":
    main(quick="--quick" in sys.argv)
