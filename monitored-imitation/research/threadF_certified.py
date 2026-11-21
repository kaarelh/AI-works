"""Thread F, experiment F1: the certified notebook on confident commissions (exact Bayes).

A variant of E6 (code/slack_imitation.py, class PROJECT) built so that the imitator's wrong
commissions are *confident*, which E6's prior does not produce (referee 5: in E6 every confident
wrong commitment happens at t_p = n0 - 1). Here the time of the decision is revealed by a
value-free entry ("setup"), and the decision itself is then made at posterior 0.9.

The class. m = 100 problems, all of one type (C, N or W) per cell. Problem p has a value
k_p in {1, 2}, k = 1 with probability PI = 0.9 (base rate), and a setup time t_p, uniform on
{0, ..., n0 - 6}. Every hypothesis knows the type, the kind of human and the rule r; the
unknowns are (t_p, k_p). A notebook is (s, z, a, u): setup written, number of stuck records on
approach 2, what the notebook builds on (0 none, 1 value 1, 2 value 2 = the strong result,
3 the weak result W), units of dependent work (or filler) on it. The human, at step j:

  s = 0:  writes SETUP if j >= t_p (persistent: any later step will do), else nothing.
  type C  (checkable claim). a = 0: writes VAL k_p (a certified claim). On its own value: a unit.
          On the other value (an invalid claim): builds on it, unless u >= D_C, then corrects.
  type N  (negative result with a checkable fallback). a = 0, z = 0: attempts approach 2:
          k = 2: VAL2; k = 1: STUCK2 (a valid obstruction record). a = 0, z >= 1: k = 1 writes
          VAL1; k = 2 re-attempts 2 (VAL2) while z < r, and once 2 is set aside (z = r) writes
          filler units, re-attempting only when u >= D_O. Wrong values as in type C.
  type W  (negative result with a valid weaker fallback). As N, but the fallback is the weak
          result WEAK, valid for every problem; k = 1's own best result is W, k = 2's is VAL2.
          While approach 2 is open (z < r), a k = 2 human re-attempts it (VAL2) and a k = 1
          human re-attempts and gets stuck again (STUCK2); this is the r-fold rule of
          threadF-certified.md, Theorem F4. With 2 set aside, a k = 2 human writes WEAK and
          builds on it, re-attempting 2 only when u >= D_O.

Validity (the local check): VAL1 is invalid iff k_p = 2, VAL2 iff k_p = 1 (a claimed certificate
that does not check). SETUP, STUCK2, WEAK and units are always valid. The human never writes an
invalid entry (self-validity, (L1)). A run *succeeds* if its final notebook builds on the human's
own final result with at least the human's own units at step n0.

Kinds: trusting (D_C = D_O = inf: fooled by invalid claims, never revisits a recorded gap);
revisit (D_C = inf, D_O = 1); noticing (D_C = D_O = 0).

Protocols, online for R rounds (as referee 5's test; no stopping rule). Each round: a uniformly
random problem; build the run; record whether it fails; then one task query.
  SI      uniform step;
  SI-ABC  runs built with ask-before-committing (asks added to the data at once);
  CSI     check every committed entry; if one is invalid, task-query its step (always a mistake,
          Lemma F1); otherwise a uniform step;
  CSI-ABC both.
The posterior uses only task-query answers (checks only choose where to ask).

Usage: python3 threadF_certified.py [--quick]
"""

import json
import sys
import time
from multiprocessing import Pool

import numpy as np

PI = 0.9
M = 100
INF = 10**9
NOTHING, SETUP, STUCK2, VAL1, VAL2, WEAK, INC = range(7)
NCODES = 7
KINDS = {"trusting": (INF, INF), "revisit": (INF, 1), "noticing": (0, 0)}


def outputs(typ, DC, DO, r, j, st, t, k):
    """Output codes of the humans (t, k) (arrays) at notebook st = (s, z, a, u), step j."""
    s, z, a, u = st
    if s == 0:
        return np.where(j >= t, SETUP, NOTHING)
    if typ in ("C", "N") and a in (1, 2):
        right = k == a
        corr = (~right) & (u >= DC)
        return np.where(right, INC, np.where(corr, np.where(k == 1, VAL1, VAL2), INC))
    if typ == "C":                                   # a == 0
        return np.where(k == 1, VAL1, VAL2)
    if typ == "N":                                   # a == 0
        if z == 0:
            return np.where(k == 2, VAL2, STUCK2)
        o2 = VAL2 if (z < r or u >= DO) else INC
        return np.where(k == 1, VAL1, o2)
    # typ == "W"
    if a == 0:
        if z == 0:
            return np.where(k == 2, VAL2, STUCK2)
        return np.where(k == 1, WEAK, VAL2 if z < r else WEAK)
    if a == 3:
        o1 = STUCK2 if z < r else INC
        o2 = VAL2 if (z < r or u >= DO) else INC
        return np.where(k == 1, o1, o2)
    if a == 2:
        return np.where(k == 2, INC, WEAK if u >= DC else INC)
    raise ValueError(st)


def advance(st, c):
    s, z, a, u = st
    if c == SETUP:
        s = 1
    elif c == STUCK2:
        z += 1
        if a == 0:
            u = 0
    elif c in (VAL1, VAL2, WEAK):
        a, u = {VAL1: 1, VAL2: 2, WEAK: 3}[c], 0
    elif c == INC:
        u += 1
    return (s, z, a, u)


def invalid(c, kp):
    return (c == VAL1 and kp == 2) or (c == VAL2 and kp == 1)


class Prob:
    def __init__(self, typ, kind, r, n, n0, tp, kp):
        self.typ, self.r, self.n, self.n0, self.tp, self.kp = typ, r, n, n0, tp, kp
        self.DC, self.DO = KINDS[kind]
        T = n0 - 5
        self.t = np.concatenate([np.arange(T), np.arange(T)])
        self.k = np.concatenate([np.ones(T, dtype=int), 2 * np.ones(T, dtype=int)])
        self.w = np.concatenate([np.full(T, PI / T), np.full(T, (1 - PI) / T)])
        self.alive = np.ones(2 * T, dtype=bool)
        self.version, self.built = 0, -1
        st = (0, 0, 0, 0)                            # the human's own run, for success
        self.own_result_step = None
        for j in range(n0):
            c = self.human(j, st)
            st = advance(st, c)
            if c in (STUCK2, VAL1, VAL2, WEAK):
                self.own_result_step = j        # the last attempt or result entry
        self.goal = st

    def outs(self, j, st, idx):
        return outputs(self.typ, self.DC, self.DO, self.r, j, st, self.t[idx], self.k[idx])

    def human(self, j, st):
        return int(outputs(self.typ, self.DC, self.DO, self.r, j, st,
                           np.array([self.tp]), np.array([self.kp]))[0])

    def build(self, alpha):
        """Build the current run (decoder, or ask-before-committing if alpha is not None).
        Returns the number of asks. Runs are cached while the data do not change."""
        if self.built == self.version:
            return 0
        asks = 0
        st = (0, 0, 0, 0)
        states, codes, asked = [st], [], []
        for j in range(self.n):
            idx = np.flatnonzero(self.alive)
            out = self.outs(j, st, idx)
            w = self.w[idx]
            mass = np.bincount(out, weights=w, minlength=NCODES)
            tol = 1e-12 * w.sum()
            order = ([INC, NOTHING, SETUP, STUCK2, WEAK, VAL1, VAL2] if st[2] != 0 else
                     [NOTHING, SETUP, STUCK2, WEAK, VAL1, VAL2, INC])
            best = order[0]
            for c in order[1:]:
                if mass[c] > mass[best] + tol:
                    best = c
            if alpha is not None and mass[best] < (1 - alpha) * w.sum() - tol:
                hum = self.human(j, st)
                self.alive[idx[out != hum]] = False
                best, a = hum, True
                asks += 1
            else:
                a = False
            codes.append(best)
            asked.append(a)
            st = advance(st, best)
            states.append(st)
        self.states, self.codes, self.asked = states, codes, asked
        if asks:                                  # the data changed during the run, so
            self.version += 1                     # the next round must rebuild it
            self.built = -1
        else:
            self.built = self.version
        return asks

    def success(self):
        a, u = self.states[-1][2], self.states[-1][3]
        return a == self.goal[2] and u >= self.goal[3]

    def query(self, j):
        """Task query at the run's state at step j; returns True on a mistake."""
        st = self.states[j]
        hum = self.human(j, st)
        mistake = (hum != self.codes[j]) and not self.asked[j]
        idx = np.flatnonzero(self.alive)
        out = self.outs(j, st, idx)
        kill = idx[out != hum]
        if len(kill):
            self.alive[kill] = False
            self.version += 1
        return mistake


def one_human(args):
    typ, kind, r, n, proto, alpha, seed, R = args
    n0 = n // 2
    T = n0 - 5
    rng = np.random.default_rng(seed)
    tp = rng.integers(0, T, size=M)
    kp = np.where(rng.random(M) < PI, 1, 2)
    probs = [Prob(typ, kind, r, n, n0, tp[p], kp[p]) for p in range(M)]
    rng2 = np.random.default_rng(seed + 7 * 10**8)
    failed = asks = hits = checks = claim_checks = flagged = 0
    fail_k2 = 0
    for _ in range(R):
        p = int(rng2.integers(M))
        pr = probs[p]
        asks += pr.build(alpha)
        f = not pr.success()
        failed += f
        fail_k2 += f and kp[p] == 2
        committed = [j for j in range(n) if not pr.asked[j] and pr.codes[j] != NOTHING]
        j = int(rng2.integers(n))
        if proto.startswith("CSI"):
            checks += len(committed)
            claim_checks += sum(pr.codes[i] in (STUCK2, VAL1, VAL2, WEAK) for i in committed)
            bad = [i for i in committed if invalid(pr.codes[i], kp[p])]
            if bad:
                j = bad[0]
                flagged += 1
        hits += pr.query(j)
    return dict(failed=failed, fail_k2=fail_k2, asks=asks, hits=hits, checks=checks,
                claim_checks=claim_checks, flagged=flagged, queries=R + asks)


def own_steps(typ, r, n):
    """Mean number of steps of the human's own run from setup to its last attempt or result."""
    n0 = n // 2
    rng = np.random.default_rng(1)
    d = []
    for p in range(400):
        tp, kp = int(rng.integers(0, n0 - 5)), (1 if rng.random() < PI else 2)
        pr = Prob(typ, "trusting", r, n, n0, tp, kp)
        d.append(pr.own_result_step - tp)
    return float(np.mean(d))


def main(quick=False):
    H = 6 if quick else 20
    ns = [32, 64] if quick else [32, 64, 128]
    cells = []
    for n in ns:
        for typ in ["C", "N", "W"]:
            for kind in (["trusting", "revisit", "noticing"] if typ == "W" else ["trusting"]):
                for proto, alpha in [("SI", None), ("SI-ABC", 0.3), ("CSI", None), ("CSI-ABC", 0.3)]:
                    cells.append((typ, kind, 1, n, proto, alpha))
            if typ == "W":
                cells.append((typ, "trusting", 1, n, "SI-ABC", 0.05))
                for r in (2, 3):
                    for proto, alpha in [("SI", None), ("CSI", None)]:
                        cells.append((typ, "trusting", r, n, proto, alpha))
    out = {}
    t0 = time.time()
    print(f"F1: {H} humans per cell, {M} problems, R = 4*M*n rounds, sigma = n/2, PI = {PI}")
    print("columns: failed runs during the R rounds (mean ± sem) [of which on k=2 problems]; "
          "task queries (= R + asks); asks; checks per round (all committed entries / "
          "claims and records); rounds whose check found an invalid entry; mistake hits")
    with Pool(4) as pool:
        for typ, kind, r, n, proto, alpha in cells:
            R = 4 * M * n
            rows = pool.map(one_human, [(typ, kind, r, n, proto, alpha, 5000 * n + s, R)
                                        for s in range(H)])
            f = np.array([x["failed"] for x in rows], dtype=float)
            key = f"{typ}_{kind}_r{r}_n{n}_{proto}" + (f"_a{alpha}" if alpha else "")
            cell = dict(type=typ, kind=kind, r=r, n=n, protocol=proto, alpha=alpha, humans=H,
                        rounds=R, failed_mean=float(f.mean()),
                        failed_sem=float(f.std(ddof=1) / np.sqrt(H)))
            for name in ["fail_k2", "asks", "hits", "checks", "claim_checks", "flagged", "queries"]:
                cell[name + "_mean"] = float(np.mean([x[name] for x in rows]))
            out[key] = cell
            print(f"{key:34s} failed {cell['failed_mean']:8.1f} ± {cell['failed_sem']:6.1f} "
                  f"[k=2: {cell['fail_k2_mean']:7.1f}]; queries {cell['queries_mean']:8.0f}; "
                  f"asks {cell['asks_mean']:6.1f}; checks/round "
                  f"{cell['checks_mean'] / R:5.1f} / {cell['claim_checks_mean'] / R:4.2f}; "
                  f"flagged {cell['flagged_mean']:5.1f}; hits {cell['hits_mean']:5.1f}  "
                  f"[{time.time() - t0:.0f}s]")
            sys.stdout.flush()
    print("\nThe human's own steps from setup to its last attempt or result (cost of the r-fold rule, type W):")
    for n in ns:
        print(f"  n0 = {n // 2}: " + ", ".join(f"r = {r}: {own_steps('W', r, n):.2f}" for r in (1, 2, 3)))
    name = "threadF_certified_quick.json" if quick else "threadF_certified_summary.json"
    with open(name, "w") as fh:
        json.dump(out, fh, indent=1)


if __name__ == "__main__":
    main(quick="--quick" in sys.argv)
