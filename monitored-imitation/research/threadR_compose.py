"""Thread R, experiment R1: how the components of the final scheme compose (exact Bayes).

One table, mechanism by mechanism. Every mechanism is one exact-posterior class. The existing
classes are imported unchanged from code/slack_imitation.py (E6), threadG_byproducts_sim.py (G1)
and threadF_certified.py (F1); only HEDGE is new.

  M1   persistent idea, noticing human (D = 0)          E6 "noticing"
  M2   fooled commission at a verdict step               E6 "fooled"
  M3   silent human (idea writable at one step only)     E6 "silent"
  M4   readable by-product insight, recovered at reviews  G1 REVIEW (L = 4, eta = 1/2)
  M5   doing-only by-product insight, inside the review   G1's DO humans on G1's REVIEW schedule:
       scaffold                                           the reviews reread the records, but
                                                          reading does not trigger the insight
                                                          (new: empty trigger sets at reviews)
  M5'  the same doing-only humans without reviews         G1 DO (slack) / DO0 (no slack)
  M6   pre-empting hedge at a labelled decision           HEDGE (new, below)
  M7   invalid checkable claim, trusting human            F1 type C, trusting
  M8   false negative recorded as a valid obstruction,    F1 type W, trusting, r = 1
       then a valid weaker result, trusting human

HEDGE (threadG-byproducts.md §5, Proposition G7). Steps 0..d-1 are routine; at the decision step
d = n0 - 1 (content-triggered: "the routine is done, choose the plan") the human writes a
labelled decision. With probability ETA_H = 0.1 the problem has an idea A (k = 2), available
from step t_A, uniform on {d - 3, ..., d} (a late trigger); otherwise (k = 1) it has none. On a
notebook with neither A nor a decision, the human writes A once it is available (persistent);
at d it writes "A; decision A" if A is available, "decision A" if A is already written, and
otherwise the default "decision B". On a notebook holding decision B it never writes A
(pre-emption). Every step after the decision is routine. Success: A and decision A (k = 2), or
decision B (k = 1). Learner: exact posterior over (t_A, k); majority decoder, ties to routine,
then to the default B.

Protocols (slack sigma = n/2, i.e. n = 2 n0, except CI):
  CI        chained imitation, no slack (n = n0), one uniform task query per round
  SI        slack, one uniform task query per round
  SI+D      SI plus the design elements (extra row): if the local check L flags a committed
            entry, task-query the first flagged step (CSI); otherwise, where the run has a last
            review step or a labelled decision step, query it with probability 1/2, else a
            uniform step (MIX-REV, Proposition G7(b))
  SI-ABC    SI with ask-before-committing, alpha = 0.3
  SI-ABC+D  SI-ABC plus the design elements
  SI-V      verifier: rerun each problem until it succeeds; on a rejection, uniform search
            (E6's SI-V; reference row)
  SI-V-ABC  SI-V with asking, uniform search over all n steps as in E6 (reference row)
  VSI       verifier; on a rejection, first task-query an L-flagged committed step if there is
            one; otherwise search with three streams in round robin: U uniform committed steps,
            S a scan from step 0, and a list of the last review step, the labelled decision
            steps and the verdict steps (EQ's "H" stream extended)
  VSI+ABC   VSI with asking, alpha = 0.3

Measurement.
  Protocols without a verifier run online for R = 4 M n rounds (n = 2 n0, the slack run length;
  the same R for CI): each round draws a uniform problem, builds its run, records whether it
  fails, then makes one task query. The entry is the number of failed runs during the R rounds
  (the quantity that Theorem 2, Proposition 5(b), Theorems G4 and F2 bound), with the asks. For
  the protocols that never ask (CI, SI, SI+D) the same run also records the oracle-stopping
  cost of E6 and G1 (task queries until at most 2% of the problems fail), continuing past R
  when needed. Verifier protocols: total task queries (asks plus searches) until every problem's
  output is accepted.

Seeds, so that the existing experiments are reproduced exactly:
  E6 classes: humans 1000 n + s (40), queries seed + 1e8 (E6 SI, referee 5), searches + 2e8
              (E6 SI-V, EQ), searches with asking + 3e8 (E6 SI-V-ABC);
  G classes:  humans 7919 N + s (40; G1's oracle table), queries seed + 1e7 (G1);
  F classes:  humans 5000 n + s (20; F1), queries seed + 7e8 (F1);
  HEDGE:      humans 4243 n + s (40), queries seed + 1e8.

The output also compares every number the code can regenerate with the published one (E6, EQ,
referee 5's online test, G1's two tables, F1's n0 = 32 column), and checks three structural facts
on every failed run of SI's learning (HEDGE's mistakes are t_A..d; REVIEW's last review is a
mistake; the first entry of VSI's list is a mistake in F1's type W).

Usage: python3 -B threadR_compose.py [--quick] [--outdir DIR] [--cache FILE] [--only M1,M2]
  (--cache keeps finished tasks in FILE, so an interrupted run resumes; about 45 minutes on
  4 cores from scratch)
"""

import json
import os
import pickle
import re
import sys
import time
from multiprocessing import Pool

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(ROOT, "code"))
sys.path.insert(0, HERE)

import numpy as np  # noqa: E402

import slack_imitation as E6  # noqa: E402
import threadF_certified as F  # noqa: E402
import threadG_byproducts_sim as G  # noqa: E402

M = 100
EPS = 0.02
ALPHA = 0.3
CONT = -1                      # routine step on which every hypothesis agrees (G classes)
ETA_H, W_H = 0.1, 3            # HEDGE: rate of the idea A, width of its late trigger window


# ----------------------------------------------------------------------------------------------
# Adapters: one problem of one human, behind a common interface.
#   build(alpha) -> asks       build the current run (decoder, or ask-before-committing)
#   failed()                   the current run fails
#   human(j), code(j)          the human's step and the run's step at the run's state j
#   asked(j)                   step j was asked (the human's own)
#   add(j, ans)                add the datum (state j of the current run, ans); no rebuild
#   invalid_steps()            committed entries the local check L flags, in order
#   pointer_D()                last review step / labelled decision steps (design queries)
#   pointer_list()             VSI's list: last review, labelled decisions, verdict steps
# ----------------------------------------------------------------------------------------------

class E6A:
    """E6's class PROJECT (code/slack_imitation.py, class Problem, unchanged)."""
    checkable = False

    def __init__(self, kind, n, n0, tp, kp):
        persistent, D = E6.KINDS[kind]
        self.pr = E6.Problem(n, n0, persistent, D)
        self.n, self.tp, self.kp = n, int(tp), int(kp)
        self.dirty, self.mode, self.last_asks = False, None, 0
        self.flags = [False] * n

    def build(self, alpha):
        pr = self.pr
        if alpha is None:
            if self.mode is not None or self.dirty:
                pr.recompute()
                self.mode, self.dirty, self.flags = None, False, [False] * self.n
            return 0
        if self.mode != alpha or self.dirty or self.last_asks:
            q = E6.run_abc(pr, self.tp, self.kp, alpha)
            self.mode, self.dirty, self.last_asks, self.flags = alpha, False, q, pr.asked
            return q
        return 0

    def failed(self):
        return not self.pr.success(self.tp, self.kp)

    def human(self, j):
        return self.pr.human_step(j, self.tp, self.kp)

    def code(self, j):
        return self.pr.codes[j]

    def asked(self, j):
        return self.flags[j]

    def add(self, j, ans):
        pr = self.pr
        a, u = pr.run[j]
        idx = np.flatnonzero(pr.alive)
        out = pr.outputs(j, a, u, pr.t[idx], pr.k[idx])
        kill = idx[out != ans]
        if len(kill):
            pr.alive[kill] = False
            self.dirty = True

    def invalid_steps(self):
        return []

    def pointer_D(self):
        return []

    def pointer_list(self):
        return [j for j in range(self.n)
                if not self.flags[j] and self.pr.codes[j] in (E6.SET1, E6.SET2)]


def g_schedule(variant, N, slack=True):
    """(n0, n, lo, hi, rev) for the G classes. REVIEW: G1's REVIEW. DOR: the same schedule with
    empty trigger sets at the reviews (doing-only humans in the review scaffold). DO: G1's DO
    (slack) or DO0 (no slack). Without slack the schedule is the first n0 steps."""
    if variant == "DO":
        return G.schedule("DO" if slack else "DO0", N)
    n0, n, lo, hi, rev = G.schedule("REVIEW", N)
    lo, hi = lo.copy(), hi.copy()
    if variant == "DOR":
        lo[rev], hi[rev] = 0, 0
    if not slack:
        n, lo, hi, rev = n0, lo[:n0], hi[:n0], [r for r in rev if r < n0]
    return n0, n, lo, hi, list(rev)


class GA:
    """G1's class BYPROD (threadG_byproducts_sim.py, class Problem, unchanged)."""
    checkable = False

    def __init__(self, N, sched, tp, kp):
        self.pr = G.Problem(N)
        self.n0, self.n, self.lo, self.hi, self.rev = sched
        self.tp, self.kp = int(tp), int(kp)
        self.version, self.built, self.last_asks, self.mode = 0, -1, 0, "unset"
        self.wk, self.wv, self.flags = -1, 0, set()

    def build(self, alpha):
        if self.built == self.version and self.last_asks == 0 and self.mode == alpha:
            return 0
        self.flags = set()
        if alpha is None:
            wk, wv = self.pr.run(self.lo, self.hi)
            asks = 0
        else:
            asks, wk, wv = self._abc(alpha)
        self.wk, self.wv, self.mode, self.last_asks, self.built = wk, wv, alpha, asks, self.version
        return asks

    def _abc(self, alpha):
        """G1's abc_human run, step by step, vectorized between asks."""
        pr, lo, hi, n = self.pr, self.lo, self.hi, self.n
        asks, have, ins, k0 = 0, 0, -1, 0
        while k0 < n and not have:
            m1, m2, m0 = pr.masses(lo[k0:], hi[k0:])
            tol = G.TOL * pr.total
            top = np.maximum(np.maximum(m0, m1), m2)
            ask = top < (1 - alpha) * pr.total - tol
            write = np.maximum(m1, m2) > m0 + tol
            ev = np.flatnonzero(ask | write)
            if len(ev) == 0:
                break
            i = int(ev[0])
            k = k0 + i
            if ask[i]:
                ans = G.human(lo[k], hi[k], self.tp, self.kp)
                pr.update(lo[k], hi[k], ans)
                asks += 1
                self.flags.add(k)
                if ans:
                    have, ins = ans, k
                k0 = k + 1
            else:
                have, ins = pr.decide(m1[i], m2[i], m0[i]), k
        return asks, (ins if have else -1), have

    def failed(self):
        if self.tp >= 0:
            return not (self.wk >= 0 and self.wv == self.kp)
        return self.wk >= 0

    def human(self, j):
        if self.wk >= 0 and j > self.wk:
            return CONT
        return G.human(self.lo[j], self.hi[j], self.tp, self.kp)

    def code(self, j):
        if self.wk >= 0:
            if j > self.wk:
                return CONT
            if j == self.wk:
                return self.wv
        return 0

    def asked(self, j):
        return j in self.flags

    def add(self, j, ans):
        if (self.wk >= 0 and j > self.wk) or j in self.flags:
            return                     # routine after the insight, or the human's own step
        self.pr.update(self.lo[j], self.hi[j], ans)
        self.version += 1

    def invalid_steps(self):
        return []

    def pointer_D(self):
        return [self.rev[-1]] if self.rev else []

    def pointer_list(self):
        L = [self.rev[-1]] if self.rev and self.rev[-1] not in self.flags else []
        if self.wk >= 0 and self.wk not in self.flags and self.wk not in L:
            L.append(self.wk)
        return L


class FA:
    """F1's certified-notebook class (threadF_certified.py, class Prob, unchanged)."""
    checkable = True
    CLAIMS = (F.STUCK2, F.VAL1, F.VAL2, F.WEAK)

    def __init__(self, typ, kind, r, n, n0, tp, kp):
        self.pr = F.Prob(typ, kind, r, n, n0, tp, kp)
        self.n, self.kp = n, kp

    def build(self, alpha):
        return self.pr.build(alpha)

    def failed(self):
        return not self.pr.success()

    def human(self, j):
        return self.pr.human(j, self.pr.states[j])

    def code(self, j):
        return self.pr.codes[j]

    def asked(self, j):
        return self.pr.asked[j]

    def add(self, j, ans):
        self.pr.query(j)               # adds the human's answer at the run's state j

    def _entries(self):
        pr = self.pr
        return [j for j in range(self.n) if not pr.asked[j] and pr.codes[j] != F.NOTHING]

    def invalid_steps(self):
        return [j for j in self._entries() if F.invalid(self.pr.codes[j], self.kp)]

    def pointer_D(self):
        return []

    def pointer_list(self):
        return [j for j in self._entries() if self.pr.codes[j] in self.CLAIMS]


class HedgeA:
    """HEDGE: a pre-empting default at a labelled decision (new; see the module docstring)."""
    checkable = False
    NOTH, WA, DECB, WADEC, DECA, CONTH = range(6)
    ORDER = [0, 5, 2, 4, 1, 3]         # ties: routine, continue, default B, then A
    DECISIONS = (2, 3, 4)

    def __init__(self, n, n0, tA, kA):
        self.n, self.d = n, n0 - 1
        ts = np.arange(self.d - W_H, self.d + 1)
        self.t = np.concatenate([ts, ts])
        self.k = np.repeat([1, 2], len(ts))
        self.w = np.concatenate([np.full(len(ts), (1 - ETA_H) / len(ts)),
                                 np.full(len(ts), ETA_H / len(ts))])
        self.alive = np.ones(len(self.t), dtype=bool)
        self.tA, self.kA = int(tA), int(kA)
        self.version, self.built = 0, -1

    def outputs(self, j, st, t, k):
        have, dec = st
        if dec:
            return np.full(len(t), self.CONTH)
        if j < self.d:
            if have:
                return np.full(len(t), self.NOTH)
            return np.where((k == 2) & (j >= t), self.WA, self.NOTH)
        if have:
            return np.full(len(t), self.DECA)
        return np.where(k == 2, self.WADEC, self.DECB)

    @staticmethod
    def advance(st, c):
        have, dec = st
        if c == HedgeA.WA:
            have = 1
        elif c == HedgeA.DECB:
            dec = 2
        elif c == HedgeA.WADEC:
            have, dec = 1, 1
        elif c == HedgeA.DECA:
            dec = 1
        return (have, dec)

    def build(self, alpha):
        if self.built == self.version:
            return 0
        asks, st = 0, (0, 0)
        states, codes, flags = [st], [], []
        for j in range(self.n):
            idx = np.flatnonzero(self.alive)
            out = self.outputs(j, st, self.t[idx], self.k[idx])
            w = self.w[idx]
            mass = np.bincount(out, weights=w, minlength=6)
            tol = 1e-12 * w.sum()
            best = self.ORDER[0]
            for c in self.ORDER[1:]:
                if mass[c] > mass[best] + tol:
                    best = c
            a = False
            if alpha is not None and mass[best] < (1 - alpha) * w.sum() - tol:
                hum = self._truth(j, st)
                self.alive[idx[out != hum]] = False
                best, a = hum, True
                asks += 1
            codes.append(best)
            flags.append(a)
            st = self.advance(st, best)
            states.append(st)
        self.states, self.codes, self.flags = states, codes, flags
        if asks:
            self.version += 1
            self.built = -1
        else:
            self.built = self.version
        return asks

    def _truth(self, j, st):
        return int(self.outputs(j, st, np.array([self.tA]), np.array([self.kA]))[0])

    def failed(self):
        have, dec = self.states[-1]
        return not ((have == 1 and dec == 1) if self.kA == 2 else dec == 2)

    def human(self, j):
        return self._truth(j, self.states[j])

    def code(self, j):
        return self.codes[j]

    def asked(self, j):
        return self.flags[j]

    def add(self, j, ans):
        idx = np.flatnonzero(self.alive)
        out = self.outputs(j, self.states[j], self.t[idx], self.k[idx])
        kill = idx[out != ans]
        if len(kill):
            self.alive[kill] = False
            self.version += 1

    def invalid_steps(self):
        return []

    def pointer_D(self):
        return [j for j in range(self.n) if self.codes[j] in self.DECISIONS][:1]

    def pointer_list(self):
        dec = [j for j in range(self.n) if self.codes[j] in self.DECISIONS and not self.flags[j]]
        ver = [j for j in range(self.n) if self.codes[j] in (self.WA, self.WADEC)
               and not self.flags[j] and j not in dec]
        return dec + ver


# ----------------------------------------------------------------------------------------------
# Mechanisms: classes, horizons, humans, seeds.
# ----------------------------------------------------------------------------------------------

MECHS = {
    "M1": dict(cls="E6", kind="noticing", H=40, label="persistent idea, noticing (E6)"),
    "M2": dict(cls="E6", kind="fooled", H=40, label="fooled commission at a verdict (E6)"),
    "M3": dict(cls="E6", kind="silent", H=40, label="silent human (E6)"),
    "M4": dict(cls="G", variant="REVIEW", H=40, label="readable by-product, reviews (G1)"),
    "M5": dict(cls="G", variant="DOR", H=40, label="doing-only by-product, review scaffold"),
    "M5'": dict(cls="G", variant="DO", H=40, label="doing-only by-product, no reviews (G1 DO)"),
    "M6": dict(cls="HEDGE", H=40, label="pre-empting hedge at a labelled decision (new)"),
    "M7": dict(cls="F", typ="C", kind="trusting", H=20, label="invalid checkable claim (F1 C)"),
    "M8": dict(cls="F", typ="W", kind="trusting", H=20,
               label="false negative as a valid obstruction (F1 W)"),
}
HORIZONS = {"E6": [16, 64, 256], "G": [8, 32, 128], "F": [16, 64, 256], "HEDGE": [16, 64, 256]}
OFFSETS = {  # (online queries, verifier searches, verifier searches with asking)
    "E6": (10**8, 2 * 10**8, 3 * 10**8), "G": (10**7, 2 * 10**7, 3 * 10**7),
    "F": (7 * 10**8, 8 * 10**8, 9 * 10**8), "HEDGE": (10**8, 2 * 10**8, 3 * 10**8)}


def humans(mech, size, s, slack=True, seed=None):
    """The M problems of human s at horizon parameter `size`. Returns (adapters, n_run, n0,
    n_slack, seed). The same human (same draws) for every protocol."""
    m = MECHS[mech]
    cls = m["cls"]
    if cls == "E6":
        n = size
        n0 = n // 2
        seed = 1000 * n + s if seed is None else seed
        rng = np.random.default_rng(seed)
        tp = rng.integers(0, n0, size=M)
        kp = np.where(rng.random(M) < E6.PI, 1, 2)
        nr = n if slack else n0
        return [E6A(m["kind"], nr, n0, tp[p], kp[p]) for p in range(M)], nr, n0, n, seed
    if cls == "G":
        N = size
        seed = 7919 * N + s if seed is None else seed
        rng = np.random.default_rng(seed)
        tp = np.where(rng.random(M) < G.ETA, rng.integers(0, N, M), -1)
        kp = rng.integers(1, 3, M)
        sched = g_schedule(m["variant"], N, slack)
        n_slack = g_schedule(m["variant"], N, True)[1]
        return [GA(N, sched, tp[p], kp[p]) for p in range(M)], sched[1], sched[0], n_slack, seed
    if cls == "F":
        n = size
        n0 = n // 2
        seed = 5000 * n + s if seed is None else seed
        rng = np.random.default_rng(seed)
        tp = rng.integers(0, n0 - 5, size=M)
        kp = np.where(rng.random(M) < F.PI, 1, 2)
        nr = n if slack else n0
        return ([FA(m["typ"], m["kind"], 1, nr, n0, tp[p], kp[p]) for p in range(M)],
                nr, n0, n, seed)
    if cls == "HEDGE":
        n = size
        n0 = n // 2
        d = n0 - 1
        seed = 4243 * n + s if seed is None else seed
        rng = np.random.default_rng(seed)
        tA = rng.integers(d - W_H, d + 1, size=M)
        kA = np.where(rng.random(M) < ETA_H, 2, 1)
        nr = n if slack else n0
        return [HedgeA(nr, n0, tA[p], kA[p]) for p in range(M)], nr, n0, n, seed
    raise ValueError(cls)


ONLINE = {  # protocol: (slack, alpha, query rule)
    "CI": (False, None, "U"), "SI": (True, None, "U"), "SI+D": (True, None, "D"),
    "SI-ABC": (True, ALPHA, "U"), "SI-ABC+D": (True, ALPHA, "D")}
VERIFIER = {  # protocol: (alpha, streams, L first, uniform over all n steps (E6's SI-V-ABC))
    "SI-V": (None, "U", False, False), "SI-V-ABC": (ALPHA, "U", False, True),
    "VSI": (None, "USL", True, False), "VSI+ABC": (ALPHA, "USL", True, False)}
SAME = {  # cells identical by construction (no design element applies): copied, not rerun
    ("M1", "SI+D"): "SI", ("M2", "SI+D"): "SI", ("M3", "SI+D"): "SI",
    ("M1", "SI-ABC+D"): "SI-ABC", ("M2", "SI-ABC+D"): "SI-ABC", ("M3", "SI-ABC+D"): "SI-ABC",
    ("M5'", "SI+D"): "SI", ("M5'", "SI-ABC+D"): "SI-ABC"}


# ----------------------------------------------------------------------------------------------
# Protocol drivers.
# ----------------------------------------------------------------------------------------------

def choose(rule, A, rng2, n):
    """The round's task-query step. 'U': uniform. 'D': the design elements (see docstring);
    the random draws follow F1's CSI and G1's MIX-REV exactly."""
    if rule == "U":
        return int(rng2.integers(n))
    if A.checkable:
        j = int(rng2.integers(n))
        bad = A.invalid_steps()
        return bad[0] if bad else j
    P = A.pointer_D()
    if P:
        if rng2.random() < 0.5:
            return P[0] if len(P) == 1 else P[int(rng2.integers(len(P)))]
        return int(rng2.integers(n))
    return int(rng2.integers(n))


def run_online(As, rng2, n, R, alpha, rule, track, cap):
    """Online rounds; see the docstring. Returns a dict of per-human results."""
    ok = None
    if track:
        for A in As:
            A.build(None)
        ok = np.array([not A.failed() for A in As])
    failed = late = asks = hits = 0
    f3000 = a3000 = None
    stop = None
    r = 0
    while True:
        if track and stop is None and (M - ok.sum()) / M <= EPS:
            stop = r
        if r >= R and (not track or stop is not None or r >= cap):
            break
        if r == 3000:
            f3000, a3000 = failed, asks
        p = int(rng2.integers(M))
        A = As[p]
        q = A.build(alpha)
        if r < R:
            f = A.failed()
            asks += q
            failed += f
            late += f and r >= 3 * R // 4
        j = choose(rule, A, rng2, n)
        ans = A.human(j)
        if r < R:
            hits += (ans != A.code(j)) and not A.asked(j)
        A.add(j, ans)
        if track:
            A.build(None)
            ok[p] = not A.failed()
        r += 1
    return dict(failed=failed, late=late, asks=asks, hits=hits, queries=R + asks,
                f3000=f3000, a3000=a3000, stop=stop, rounds_run=r,
                final_fail=None if ok is None else float((M - ok.sum()) / M))


def search(A, streams, rng2, n, uniform_all):
    """Search the fixed rejected run for a committed mistake (Lemma Q2's round robin).
    Returns the number of queries; all answers are added afterwards."""
    committed = [j for j in range(n) if not A.asked(j)]
    lists = {"S": committed, "L": A.pointer_list()}
    pos = {"S": 0, "L": 0}
    queried, answers, spent, turn = set(), [], 0, 0
    while True:
        s = streams[turn % len(streams)]
        turn += 1
        if s == "U":
            j = int(rng2.integers(n)) if uniform_all else committed[int(rng2.integers(len(committed)))]
        else:
            L = lists[s]
            while pos[s] < len(L) and L[pos[s]] in queried:
                pos[s] += 1
            if pos[s] >= len(L):
                continue
            j = L[pos[s]]
            pos[s] += 1
        spent += 1
        queried.add(j)
        ans = A.human(j)
        answers.append((j, ans))
        if ans != A.code(j) and not A.asked(j):
            break
        assert spent < 10**7, "search did not terminate"
    hit = answers.pop()
    for (jj, aa) in [hit] + answers:
        A.add(jj, aa)
    return spent


def run_verifier(As, rng2, n, alpha, streams, lfirst, uniform_all):
    queries = asks = rejected = lflag = searchq = 0
    for A in As:
        q = A.build(alpha)
        queries += q
        asks += q
        while A.failed():
            rejected += 1
            bad = A.invalid_steps() if lfirst else []
            if bad:
                j = bad[0]
                A.add(j, A.human(j))
                queries += 1
                lflag += 1
            else:
                sq = search(A, streams, rng2, n, uniform_all)
                queries += sq
                searchq += sq
            q = A.build(alpha)
            queries += q
            asks += q
    return dict(queries=queries, asks=asks, rejected=rejected, lflag=lflag, searchq=searchq)


def task(args):
    """One human, one protocol, one horizon."""
    mech, proto, size, s, R_override, seed = args
    t0 = time.time()
    cls = MECHS[mech]["cls"]
    off = OFFSETS[cls]
    if proto in ONLINE:
        slack, alpha, rule = ONLINE[proto]
        As, nr, n0, n_slack, sd = humans(mech, size, s, slack, seed)
        R = R_override or 4 * M * n_slack
        cap = (400 if cls == "G" else 40) * M * nr
        res = run_online(As, np.random.default_rng(sd + off[0]), nr, R, alpha, rule,
                         track=alpha is None and R_override is None, cap=cap)
        res["R"] = R
    else:
        alpha, streams, lfirst, uniform_all = VERIFIER[proto]
        As, nr, n0, n_slack, sd = humans(mech, size, s, True, seed)
        rng2 = np.random.default_rng(sd + (off[2] if alpha is not None else off[1]))
        res = run_verifier(As, rng2, nr, alpha, streams, lfirst, uniform_all)
    res.update(n=nr, n0=n0, secs=time.time() - t0)
    return (mech, proto, size, s, seed is not None, R_override), res


# ----------------------------------------------------------------------------------------------
# Summaries, tables, reproduction checks.
# ----------------------------------------------------------------------------------------------

def ms(xs):
    x = np.array(xs, dtype=float)
    return float(x.mean()), (float(x.std(ddof=1) / np.sqrt(len(x))) if len(x) > 1 else 0.0)


def summarise(rows):
    out = {"humans": len(rows)}
    for key in rows[0]:
        vals = [r[key] for r in rows]
        if all(v is not None for v in vals) and all(isinstance(v, (int, float, np.integer, np.floating))
                                                    for v in vals):
            out[key + "_mean"], out[key + "_sem"] = ms(vals)
    if "stop" in rows[0]:
        out["stop_reached"] = int(sum(r["stop"] is not None for r in rows))
        if out["stop_reached"] == len(rows):
            out["stop_mean"], out["stop_sem"] = ms([r["stop"] for r in rows])
    return out


def fmt(m, s, d=0):
    return f"{m:,.{d}f} ± {s:,.{d}f}"


def n0_label(mech, size):
    cls = MECHS[mech]["cls"]
    if cls == "G":
        n0 = g_schedule(MECHS[mech]["variant"], size)[0]
        return f"N={size} (n₀={n0})"
    return f"n₀={size // 2}"


def tables(S, mechs, sizes_of):
    L = []
    L.append("## Table 1. Without a verifier: failed runs during R = 4·M·n rounds "
             "(n = 2n₀; asks per problem in brackets)\n")
    L.append("| mechanism | horizon | R | CI | SI | SI+D | SI-ABC | SI-ABC+D |")
    L.append("|---|---|---|---|---|---|---|---|")
    for mech in mechs:
        for size in sizes_of(mech):
            cells, R = [], None
            for proto in ONLINE:
                e = S.get((mech, proto, size))
                if e is None:
                    cells.append("–")
                    continue
                R = int(e["R_mean"])
                c = fmt(e["failed_mean"], e["failed_sem"], 1 if e["failed_mean"] < 100 else 0)
                if ONLINE[proto][1] is not None:
                    c += f" [{e['asks_mean'] / M:.1f}]"
                cells.append(c)
            L.append(f"| {mech} | {n0_label(mech, size)} | {R:,} | " + " | ".join(cells) + " |")
    L.append("\n## Table 2. With a verifier: total task queries for all 100 problems "
             "(asks; rejected runs; L-flagged queries)\n")
    L.append("| mechanism | horizon | SI-V | VSI | SI-V-ABC | VSI+ABC |")
    L.append("|---|---|---|---|---|---|")
    for mech in mechs:
        for size in sizes_of(mech):
            cells = []
            for proto in ["SI-V", "VSI", "SI-V-ABC", "VSI+ABC"]:
                e = S.get((mech, proto, size))
                if e is None:
                    cells.append("–")
                    continue
                c = fmt(e["queries_mean"], e["queries_sem"])
                extra = []
                if VERIFIER[proto][0] is not None:
                    extra.append(f"{e['asks_mean']:.0f} asks")
                extra.append(f"{e['rejected_mean']:.1f} rej.")
                if e.get("lflag_mean", 0) > 0:
                    extra.append(f"{e['lflag_mean']:.1f} L")
                cells.append(c + " (" + "; ".join(extra) + ")")
            L.append(f"| {mech} | {n0_label(mech, size)} | " + " | ".join(cells) + " |")
    L.append("\n## Table 3. Oracle stopping (protocols that never ask): task queries until at "
             "most 2% of problems fail\n")
    L.append("| mechanism | horizon | CI | SI | SI+D |")
    L.append("|---|---|---|---|---|")
    for mech in mechs:
        for size in sizes_of(mech):
            cells = []
            for proto in ["CI", "SI", "SI+D"]:
                e = S.get((mech, proto, size))
                if e is None:
                    cells.append("–")
                elif e.get("stop_reached", 0) < e["humans"]:
                    cells.append(f"{e['stop_reached']}/{e['humans']} reached")
                else:
                    cells.append(fmt(e["stop_mean"], e["stop_sem"]))
            L.append(f"| {mech} | {n0_label(mech, size)} | " + " | ".join(cells) + " |")
    L.append("\n## Table 4. Convergence: failed runs in the last quarter of the R rounds\n")
    L.append("| mechanism | horizon | CI | SI | SI+D | SI-ABC | SI-ABC+D |")
    L.append("|---|---|---|---|---|---|---|")
    for mech in mechs:
        for size in sizes_of(mech):
            cells = []
            for proto in ONLINE:
                e = S.get((mech, proto, size))
                cells.append("–" if e is None else f"{e['late_mean']:.1f}")
            L.append(f"| {mech} | {n0_label(mech, size)} | " + " | ".join(cells) + " |")
    return "\n".join(L) + "\n"


def load_refs():
    """Published numbers to compare with."""
    refs = {}
    res = os.path.join(ROOT, "results")

    def jl(path):
        with open(path) as f:
            return json.load(f)
    try:
        d = jl(os.path.join(res, "slack_imitation_summary.json"))
        d2 = jl(os.path.join(res, "slack_imitation_same.json"))
        d3 = jl(os.path.join(res, "slack_imitation_verifier.json"))
        d4 = jl(os.path.join(res, "slack_imitation_verifier_abc.json"))
        q = jl(os.path.join(HERE, "threadQ_hints.json"))
        for mech, kind in [("M1", "noticing"), ("M2", "fooled"), ("M3", "silent")]:
            for n in [16, 64, 256]:
                refs[("E6 SI (oracle)", mech, "SI", n, "stop")] = d[f"{kind}_n{n}_sigma{n // 2}_CI"]["task_mean"]
                refs[("E6 CI same humans (oracle)", mech, "CI", n, "stop")] = d2[f"{kind}_n{n}_same_CI_n0"]["task_mean"]
                refs[("E6 SI-V", mech, "SI-V", n, "queries")] = d3[f"{kind}_n{n}_sigma{n // 2}_SIV"]["task_mean"]
                refs[("E6 SI-V-ABC 0.3", mech, "SI-V-ABC", n, "queries")] = \
                    d4[f"{kind}_n{n}_sigma{n // 2}_SIV-ABC_alpha0.3"]["task_mean"]
                refs[("EQ USH", mech, "VSI", n, "queries")] = q[f"{kind}_n{n}_USH"]["task_mean"]
                refs[("EQ U", mech, "SI-V", n, "queries")] = q[f"{kind}_n{n}_U"]["task_mean"]
    except (OSError, KeyError) as e:
        print("E6/EQ references unavailable:", e)
    try:
        f1 = jl(os.path.join(HERE, "threadF_certified_summary.out"))
        for mech, typ in [("M7", "C"), ("M8", "W")]:
            for proto, key in [("SI", "SI"), ("SI-ABC", "SI-ABC_a0.3"), ("SI+D", "CSI"),
                               ("SI-ABC+D", "CSI-ABC_a0.3")]:
                e = f1[f"{typ}_trusting_r1_n64_{key}"]
                refs[("F1 n=64", mech, proto, 64, "failed")] = e["failed_mean"]
                refs[("F1 n=64", mech, proto, 64, "asks")] = e["asks_mean"]
    except (OSError, KeyError) as e:
        print("F1 references unavailable:", e)
    try:
        txt = open(os.path.join(HERE, "threadG_byproducts_sim.out")).read()
        for var, proto, mech, rp in [("DO0", "SI", "M5'", "CI"), ("DO", "SI", "M5'", "SI"),
                                     ("REVIEW", "SI", "M4", "SI"), ("REVIEW", "MIXREV", "M4", "SI+D")]:
            m = re.search(rf"^\| {var} \| {proto} \| (.+?) \|  \[", txt, re.M)
            cells = [c.strip() for c in m.group(1).split("|")]
            for N, c in zip([8, 32, 128], cells):
                refs[("G1 oracle", mech, rp, N, "stop_str")] = c.split(" [")[0]
        for var, rows in [("DO", [("SI", 2), ("SI-ABC", 4)]),
                          ("REVIEW", [("SI", 2), ("SI+D", 3), ("SI-ABC", 4), ("SI-ABC+D", 5)])]:
            for N in [8, 32, 128]:
                m = re.search(rf"^\| {var} \| {N} \|(.+?)\|  \[", txt, re.M)
                cells = [c.strip() for c in m.group(1).split("|")]
                for proto, i in rows:
                    refs[("G1 online", var, proto, N, "str")] = cells[i - 2]
    except (OSError, AttributeError) as e:
        print("G1 references unavailable:", e)
    try:
        txt = open(os.path.join(ROOT, "verification", "referee5_si_abc_online.out")).read()
        for m in re.finditer(r"^(\S+)_n(\d+)_alpha(\S+)\s+humans\s+(\d+), 3000 rounds: failed runs\s+"
                             r"([\d.]+) .*?asks\s+([\d.]+);", txt, re.M):
            kind, n, al, H, fm, am = m.groups()
            refs[("referee 5", kind, al, int(n), "H")] = int(H)
            refs[("referee 5", kind, al, int(n), "failed")] = float(fm)
            refs[("referee 5", kind, al, int(n), "asks")] = float(am)
    except OSError as e:
        print("referee 5 references unavailable:", e)
    return refs


def reproduction(S, raw, G1on, refs):
    """Compare with the published numbers; returns markdown lines."""
    L = ["## Reproduction checks\n", "| source | cell | published | here | exact |", "|---|---|---|---|---|"]
    nexact = ntot = 0

    def line(src, cell, pub, here, exact):
        nonlocal nexact, ntot
        ntot += 1
        nexact += bool(exact)
        L.append(f"| {src} | {cell} | {pub} | {here} | {'yes' if exact else 'NO'} |")
    for key, val in sorted(refs.items(), key=lambda kv: str(kv[0])):
        src, mech, proto, size, what = key
        if src in ("referee 5", "G1 online"):
            continue
        e = S.get((mech, proto, size))
        if e is None:
            continue
        if what == "stop":
            if e.get("stop_reached", 0) < e["humans"]:
                continue
            here = e["stop_mean"]
        elif what == "stop_str":
            if e.get("stop_reached", 0) < e["humans"]:
                continue
            here_s = fmt(e["stop_mean"], e["stop_sem"])
            line(src, f"{mech} {proto} N={size}", val, here_s, here_s == val)
            continue
        elif what == "queries":
            here = e["queries_mean"]
        elif what == "failed":
            here = e["failed_mean"]
        elif what == "asks":
            here = e["asks_mean"]
        line(src, f"{mech} {proto} {n0_label(mech, size)} ({what})", f"{val:.4f}", f"{here:.4f}",
             abs(val - here) < 1e-9 * max(1.0, abs(val)))
    # referee 5: failed runs and asks in the first 3000 rounds, first H humans
    kinds = {"noticing": "M1", "fooled": "M2", "silent": "M3"}
    for key, val in sorted(refs.items(), key=lambda kv: str(kv[0])):
        src, kind, al, n, what = key
        if src != "referee 5" or what == "H" or kind not in kinds:
            continue
        proto = "SI" if al == "None" else ("SI-ABC" if al == "0.3" else None)
        rows = raw.get((kinds[kind], proto, n))
        if proto is None or rows is None:
            continue
        H = refs[(src, kind, al, n, "H")]
        rows = [r for s, r in sorted(rows.items()) if s < H]
        here = np.mean([r["f3000" if what == "failed" else "a3000"] for r in rows])
        line("referee 5 (first 3000 rounds)", f"{kinds[kind]} {proto} n₀={n // 2} ({what}, {H} humans)",
             f"{val:.1f}", f"{here:.1f}", f"{here:.1f}" == f"{val:.1f}")
    for (var, proto, N), (fm, am) in sorted(G1on.items()):
        pub = refs.get(("G1 online", var, proto, N, "str"))
        if pub is None:
            continue
        here = f"{fm:,.1f}" + (f" / {am:,.1f}" if "ABC" in proto else "")
        line("G1 online (3000 rounds, 20 humans)", f"{var} {proto} N={N}", pub, here, pub == here)
    L.append(f"\n{nexact} of {ntot} published numbers reproduced exactly.\n")
    return L


def structural(args):
    """Structural facts the reading relies on, checked on every failed run of SI's online
    learning (one human, 4 M n rounds):
      M6: the mistakes are exactly the steps t_A..d (Proposition G7(a));
      M4: the last review step is a mistake (Theorem G4's ripeness);
      M8: the first entry of VSI's list (the obstruction record) is a mistake."""
    mech, size, s = args
    As, nr, n0, n_slack, sd = humans(mech, size, s)
    rng = np.random.default_rng(sd + OFFSETS[MECHS[mech]["cls"]][0])
    nfail = bad = 0
    for _ in range(4 * M * n_slack):
        A = As[int(rng.integers(M))]
        A.build(None)
        if A.failed():
            nfail += 1
            mis = {j for j in range(nr) if A.human(j) != A.code(j)}
            if mech == "M6":
                bad += mis != set(range(A.tA, A.d + 1))
            elif mech == "M4":
                bad += A.rev[-1] not in mis
            else:
                L = A.pointer_list()
                bad += not (L and L[0] in mis)
        j = int(rng.integers(nr))
        A.add(j, A.human(j))
    return mech, size, nfail, bad


def structural_checks(pool, quick):
    jobs = [(m, size, s) for m, sizes in [("M6", [16, 64]), ("M4", [8, 32]), ("M8", [16, 64])]
            for size in sizes for s in range(2 if quick else 10)]
    out = {}
    for mech, size, nf, bad in pool.imap_unordered(structural, jobs):
        a, b = out.get((mech, size), (0, 0))
        out[(mech, size)] = (a + nf, b + bad)
    what = {"M6": "mistakes are exactly steps t_A..d", "M4": "last review step is a mistake",
            "M8": "first entry of VSI's list is a mistake"}
    L = ["\n## Structural checks (SI's online learning, 10 humans per row; every failed run)\n",
         "| mechanism | horizon | property | failed runs checked | violations |", "|---|---|---|---|---|"]
    for (mech, size), (nf, bad) in sorted(out.items()):
        L.append(f"| {mech} | {n0_label(mech, size)} | {what[mech]} | {nf:,} | {bad} |")
    return "\n".join(L) + "\n", {f"{m}|{n0_label(m, s)}": dict(failed_runs=a, violations=b)
                                 for (m, s), (a, b) in out.items()}


def g1_online_check(pool):
    """G1's online table: 20 humans with G1's online seeds, 3000 rounds."""
    out = {}
    jobs = []
    for var, mech, protos in [("DO", "M5'", ["SI", "SI-ABC"]),
                              ("REVIEW", "M4", ["SI", "SI+D", "SI-ABC", "SI-ABC+D"])]:
        for N in [8, 32, 128]:
            for proto in protos:
                for s in range(20):
                    jobs.append((mech, proto, N, s, 3000, 104729 * N + s))
    res = {}
    for key, r in pool.imap_unordered(task, jobs, chunksize=4):
        mech, proto, N, s = key[:4]
        res.setdefault((mech, proto, N), []).append(r)
    for (mech, proto, N), rows in res.items():
        var = "DO" if mech == "M5'" else "REVIEW"
        out[(var, proto, N)] = (np.mean([r["failed"] for r in rows]), np.mean([r["asks"] for r in rows]))
    return out


def main():
    quick = "--quick" in sys.argv
    outdir = HERE
    cache = None
    only = None
    for i, a in enumerate(sys.argv):
        if a == "--outdir":
            outdir = sys.argv[i + 1]
        if a == "--cache":
            cache = sys.argv[i + 1]
        if a == "--only":
            only = sys.argv[i + 1].split(",")
    mechs = [m for m in MECHS if only is None or m in only]

    def sizes_of(mech):
        hs = HORIZONS[MECHS[mech]["cls"]]
        return hs[:2] if quick else hs
    jobs = []
    for mech in mechs:
        H = 4 if quick else MECHS[mech]["H"]
        for size in sizes_of(mech):
            for proto in list(ONLINE) + list(VERIFIER):
                if (mech, proto) in SAME:
                    continue
                for s in range(H):
                    jobs.append((mech, proto, size, s, None, None))
    # longest first
    weight = {"E6": 3.0, "F": 1.0, "HEDGE": 0.3, "G": 0.3}
    jobs.sort(key=lambda a: -(weight[MECHS[a[0]]["cls"]] * a[2] * (2 if a[1] in ONLINE else 0.2)))
    done = {}
    if cache and os.path.exists(cache):
        with open(cache, "rb") as f:
            done = pickle.load(f)
    todo = [j for j in jobs if (j[0], j[1], j[2], j[3]) not in done]
    t0 = time.time()
    print(f"R1: {len(jobs)} tasks ({len(todo)} to run), M = {M} problems per human, alpha = {ALPHA}")
    sys.stdout.flush()
    with Pool(4) as pool:
        last = time.time()
        for i, (key, r) in enumerate(pool.imap_unordered(task, todo, chunksize=1)):
            done[key[:4]] = r
            if time.time() - last > 60 or i == len(todo) - 1:
                last = time.time()
                print(f"  {i + 1}/{len(todo)} tasks done [{time.time() - t0:.0f}s]")
                sys.stdout.flush()
                if cache:
                    with open(cache, "wb") as f:
                        pickle.dump(done, f)
        G1on = {} if quick or (only and "M4" not in only) else g1_online_check(pool)
        stext, sjson = structural_checks(pool, quick)
    raw = {}
    for (mech, proto, size, s), r in done.items():
        if mech in mechs:
            raw.setdefault((mech, proto, size), {})[s] = r
    S = {k: summarise([r for _, r in sorted(v.items())]) for k, v in raw.items()}
    for (mech, proto), src in SAME.items():
        for size in sizes_of(mech) if mech in mechs else []:
            if (mech, src, size) in S:
                S[(mech, proto, size)] = dict(S[(mech, src, size)], same_as=src)
                raw[(mech, proto, size)] = raw[(mech, src, size)]
    text = tables(S, mechs, sizes_of)
    refs = load_refs()
    text += "\n" + "\n".join(reproduction(S, raw, G1on, refs))
    # interference ratios
    L = ["\n## Interference: ratios of total task queries\n",
         "| mechanism | horizon | VSI / SI-V | VSI+ABC / VSI | SI+D / SI (failed runs) |",
         "|---|---|---|---|---|"]
    for mech in mechs:
        for size in sizes_of(mech):
            a, b, c = S.get((mech, "VSI", size)), S.get((mech, "SI-V", size)), S.get((mech, "VSI+ABC", size))
            d, e = S.get((mech, "SI+D", size)), S.get((mech, "SI", size))
            r1 = f"{a['queries_mean'] / b['queries_mean']:.2f}" if a and b else "–"
            r2 = f"{c['queries_mean'] / a['queries_mean']:.2f}" if a and c else "–"
            r3 = f"{d['failed_mean'] / e['failed_mean']:.2f}" if d and e and e["failed_mean"] else "–"
            L.append(f"| {mech} | {n0_label(mech, size)} | {r1} | {r2} | {r3} |")
    text += "\n".join(L) + "\n" + stext
    wall = time.time() - t0
    cpu = sum(r["secs"] for r in done.values())
    head = (f"# threadR_compose.py: experiment R1 ({'quick' if quick else 'full'}). M = {M} problems "
            f"per human; alpha = {ALPHA}; slack sigma = n/2 except CI.\n# Humans per cell: E6, G and "
            f"HEDGE classes {4 if quick else 40}, F classes {4 if quick else 20}.\n# CPU time of all "
            f"{len(done)} tasks {cpu:.0f}s; this invocation ran {len(todo)} of them (the rest from "
            f"the cache) in {wall:.0f}s wall time.\n\n")
    print(head + text)
    suffix = "_quick" if quick else ""
    with open(os.path.join(outdir, f"threadR_compose{suffix}.out"), "w") as f:
        f.write(head + text)
    js = {f"{m}|{p}|{n0_label(m, s)}": v for (m, p, s), v in sorted(S.items(), key=lambda kv: str(kv[0]))}
    js["_G1_online_check"] = {f"{v}|{p}|N={N}": dict(failed=a, asks=b) for (v, p, N), (a, b) in G1on.items()}
    js["_structural_checks"] = sjson
    js["_settings"] = dict(M=M, EPS=EPS, ALPHA=ALPHA, ETA_H=ETA_H, W_H=W_H, quick=quick,
                           cpu_seconds=cpu, wall_seconds_last_invocation=wall)
    with open(os.path.join(outdir, f"threadR_compose{suffix}.json"), "w") as f:
        json.dump(js, f, indent=1)


if __name__ == "__main__":
    main()
