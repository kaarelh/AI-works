#!/usr/bin/env python3
"""Referee check (key: hellinger-runs), part 3: Sections 1 and 3 and Appendix A.

(B16) Lemma 1.1, items 1, 2, 3, 5 on random pairs of laws.
(B1)  Lemma 3.4a at the boundary of its hypothesis ((N-1) delta^2 = 1/4) and inside.
(B2)  kappa = 2 delta ln((1+2delta)/(1-2delta)) <= 8 delta^2/(1-4 delta^2).
(B3)  The constants of Propositions 3.4 and 3.5, recomputed step by step.
(B15) Protocol R on small scaffolds, EXACT expectations (dynamic programme over the data
      sets): Theorem R1, Theorem 3.1(a),(b),(c),(e), and the chain H2 <= 4 E sum h.
(B17) The lower bound for the expected number of unfaithful calls (Section 3.3,
      qualification 3), as filled in the report.
Needs numpy and scipy.
"""
import itertools
import math
from collections import defaultdict

import numpy as np
from scipy.stats import binom

rng = np.random.default_rng(31)
LN2 = math.log(2.0)


def H2(p, q):
    return 1.0 - float(np.sum(np.sqrt(p * q)))


def TV(p, q):
    return 0.5 * float(np.sum(np.abs(p - q)))


def KL(p, q):
    m = p > 0
    if np.any(q[m] == 0):
        return math.inf
    return float(np.sum(p[m] * np.log(p[m] / q[m])))


# ------------------------------------------------------------------ (B16)
def part_b16():
    w1 = w2 = w3 = w5 = w5b = -np.inf
    for _ in range(100000):
        k = int(rng.integers(2, 7))
        p = rng.dirichlet(np.ones(k) * rng.choice([0.2, 1.0, 5.0]))
        q = rng.dirichlet(np.ones(k) * rng.choice([0.2, 1.0, 5.0]))
        if rng.random() < 0.3:
            j = rng.integers(k); p = p.copy(); p[j] = 0.0; p /= p.sum()
        if rng.random() < 0.3:
            j = rng.integers(k); q = q.copy(); q[j] = 0.0; q /= q.sum()
        h, tv, kl = H2(p, q), TV(p, q), KL(p, q)
        w1 = max(w1, h - tv, tv - math.sqrt(max(h * (2 - h), 0.0)))
        bc = float(np.sum(np.sqrt(p * q)))      # computed directly (1 - h loses digits when h is near 1)
        if bc > 0:
            w2 = max(w2, h + math.log(bc))
            if kl < math.inf:
                w2 = max(w2, -math.log(bc) - kl / 2)
        if kl < math.inf:
            w3 = max(w3, tv - math.sqrt(kl / 2))
        A = rng.random(k) < 0.5
        PA, QA = float(p[A].sum()), float(q[A].sum())
        w5 = max(w5, (math.sqrt(QA) - math.sqrt(PA)) ** 2 - 2 * h, QA - 2 * PA - 4 * h)
        if PA == 0.0:
            w5b = max(w5b, QA - 2 * h)
    print(f"(B16) Lemma 1.1 on 100000 random pairs: worst violation of item 1: {w1:.2e}, item 2: {w2:.2e}, item 3: {w3:.2e},"
          f" item 5: {w5:.2e}, item 5 with P(A)=0: {w5b:.2e}  (all must be <= 0 up to rounding)")


# ------------------------------------------------------------------ (B1)
def G(N, delta):
    """TV between Bern(1/2+delta)^N and Bern(1/2-delta)^N for odd N (exact)."""
    k = (N + 1) // 2
    return float(binom.sf(k - 1, N, 0.5 + delta) - binom.sf(k - 1, N, 0.5 - delta))


def part_b1():
    worst = np.inf
    arg = None
    for N in list(range(3, 400, 2)) + [501, 1001, 2001, 5001, 20001]:
        dmax = min(0.5 - 1e-12, 0.5 / math.sqrt(N - 1))
        for frac in [1.0, 0.999, 0.9, 0.7, 0.5, 0.3, 0.1, 0.01, 0.001]:
            d = dmax * frac
            ratio = G(N, d) / (d * math.sqrt(N / 2))
            if ratio < worst:
                worst, arg = ratio, (N, d)
    mono = all(G(N + 2, 0.05) >= G(N, 0.05) for N in range(3, 200, 2))
    print(f"(B1) Lemma 3.4a: smallest G(N,delta)/(delta sqrt(N/2)) over odd N in [3, 20001] and (N-1) delta^2 <= 1/4:"
          f" {worst:.4f} at N = {arg[0]}, delta = {arg[1]:.5f} (must be >= 1); G non-decreasing along odd N: {mono}")
    print(f"     N = 3 at the boundary delta = 1/(2 sqrt 2): G = {G(3, 0.5 / math.sqrt(2)):.5f}, bound = {0.5 / math.sqrt(2) * math.sqrt(1.5):.5f}")


# ------------------------------------------------------------------ (B2), (B3)
def part_b2_b3():
    ds = np.linspace(1e-6, 0.5 - 1e-6, 500001)
    kap = 2 * ds * np.log((1 + 2 * ds) / (1 - 2 * ds))
    print(f"(B2) max of kappa - 8 delta^2/(1-4 delta^2) on (0, 1/2): {float(np.max(kap - 8 * ds ** 2 / (1 - 4 * ds ** 2))):.3e} (must be <= 0)")
    print("(B3) constants of Proposition 3.4")
    print(f"     Step 2: under n = K(1-4d^2)/(16 d^2): kappa n/(2K) <= (8/16)/2 = {8 / 16 / 2}; average of E[d] >= (K/2)(1 - sqrt(1/4)) = K/4")
    print(f"     Step 3: reverse Markov (1/4 - 1/8)/(1 - 1/8) = {(1 / 4 - 1 / 8) / (1 - 1 / 8):.6f} = 1/7;"
          f" (1/7)(1/2) sqrt(3/64) = {(1 / 7) * 0.5 * math.sqrt(3 / 64):.6f} = 1/{1 / ((1 / 7) * 0.5 * math.sqrt(3 / 64)):.3f} >= 1/65 = {1 / 65:.6f}")
    print(f"     consequence: (7/8)/(16*65^2) = 1/{1 / ((7 / 8) / (16 * 65 ** 2)):.1f} >= 1/80000; 8e4 ln2 = {8e4 * LN2:.0f}; 8192 ln2 = {8192 * LN2:.0f}")
    ok = True
    for K in [8, 9, 15, 16, 17, 40, 100]:
        for m in [4, 5, 9]:
            L = K * m
            r0 = -(-K // 8)
            N = r0 * m
            ok = ok and (L / 8 <= N <= L / 4) and N >= 4
            for delta in [1 / math.sqrt(L), 0.5 / math.sqrt(L), 0.1 / math.sqrt(L)]:
                Nodd = N if N % 2 == 1 else N - 1
                ok = ok and (G(Nodd, delta) >= delta * math.sqrt(3 * L / 64))
    print(f"     L/8 <= r0 m <= L/4, r0 m >= 4 and G(N or N-1, delta) >= delta sqrt(3L/64) for K in {{8,...,100}}, m in {{4,5,9}}: {ok}")
    print("     constants of Proposition 3.5")
    e = 1 / 12
    for L in [3, 5, 101]:
        a = 4 * e * math.sqrt(2 / L)
        print(f"     L = {L}: a = {a:.4f} (< 1/2), (L-1) a^2 = {(L - 1) * a * a:.4f} (<= 1/4), 4 a^2 = {4 * a * a:.4f} (<= 0.3),"
              f" G(L,a) = {G(L, a):.4f} >= 4 eps = {4 * e:.4f}")
    print(f"     128/0.7 = {128 / 0.7:.2f} <= 183; 183/740 = {183 / 740:.4f} <= 1/4")


# ------------------------------------------------------------------ (B15)
class Scaffold:
    """Scaffold with L = 2 calls on inputs {0,1,2} and answers {0,1}.
    variant 'full': x1 = 0, x2 = 1 + y1.  variant 'stop': x1 = 0; after y1 = 0 stop; after y1 = 1, x2 = 1.
    variant 'flat': x1 = 0, x2 = 1 whatever y1 (inputs do not depend on the answers)."""

    def __init__(self, variant):
        self.variant = variant
        self.L = 2

    def second(self, y1):
        if self.variant == "full":
            return 1 + y1
        if self.variant == "stop":
            return None if y1 == 0 else 1
        return 1

    def runs(self):
        out = []
        for y1 in (0, 1):
            x2 = self.second(y1)
            if x2 is None:
                out.append(((0,), (y1,)))
            else:
                for y2 in (0, 1):
                    out.append(((0, x2), (y1, y2)))
        return out

    def law(self, S):
        """Law of the run when the sampler S (array [x][y]) answers every call."""
        return np.array([np.prod([S[x][y] for x, y in zip(xs, ys)]) for xs, ys in self.runs()])


def protocol_R_exact(scaf, H, w, n):
    """Exact expectations under Protocol R.  H: list of samplers (arrays 3x2), H[0] is the human.
    Returns (sum_t E E_{Q_M} sum_j KL(P||M)(x_j), list of E H2(Q_{M^(t)},Q_P), list of E TV,
             max over reachable data of H2 - 4 E sum h,  list of E Q_{M^(t)}(G0) for G0 = runs of Q_P-probability 0)."""
    P = H[0]
    QP = scaf.law(P)
    L = scaf.L
    states = {tuple([0] * 6): 1.0}                 # counts of (x,y), index 2x+y
    lik = lambda c: np.array([np.prod([nu[x][y] ** c[2 * x + y] for x in range(3) for y in range(2)]) for nu in H])
    tot_kl = 0.0
    tot_klrun = 0.0                                # sum_t E KL(Q_P || Q_{M^(t)})  (whole-run divergence)
    EH2, ETV, EG0 = [], [], []
    worst_chain = -np.inf
    zero_runs = QP == 0
    for t in range(1, n + 1):
        nxt = defaultdict(float)
        eh2 = etv = eg0 = 0.0
        for c, pr in states.items():
            post = w * lik(c)
            post = post / post.sum()
            M = sum(post[i] * H[i] for i in range(len(H)))
            QM = scaf.law(M)
            # per-call divergences along the run of M
            klx = [KL(P[x], M[x]) for x in range(3)]
            h2x = [H2(P[x], M[x]) for x in range(3)]
            skl = sh = 0.0
            for (xs, ys), pm in zip(scaf.runs(), QM):
                skl += pm * sum(klx[x] for x in xs)
                sh += pm * sum(h2x[x] for x in xs)
            tot_kl += pr * skl
            h2 = H2(QM, QP)
            worst_chain = max(worst_chain, h2 - 4 * sh)
            eh2 += pr * h2
            tot_klrun += pr * KL(QP, QM)
            etv += pr * TV(QM, QP)
            eg0 += pr * float(QM[zero_runs].sum())
            # the question of round t: J uniform on {1,2}; the run is generated by M
            for (xs, ys), pm in zip(scaf.runs(), QM):
                if pm == 0.0:
                    continue
                for J in (1, 2):
                    if J > len(xs):
                        nxt[c] += pr * pm * 0.5                  # no question in this round
                        continue
                    x = xs[J - 1]
                    for y in (0, 1):
                        if P[x][y] == 0.0:
                            continue
                        c2 = list(c)
                        c2[2 * x + y] += 1
                        nxt[tuple(c2)] += pr * pm * 0.5 * P[x][y]
        EH2.append(eh2); ETV.append(etv); EG0.append(eg0)
        states = nxt
    return tot_kl, EH2, ETV, worst_chain, EG0, tot_klrun


def part_b15():
    print("(B15) Protocol R, exact expectations (dynamic programme over data sets); L = 2")
    print("      columns: scaffold, class, n | sum_t E E_Q sum_j KL <= L K ln2 | E H2(T) <= 2LK ln2/n | E TV(T) <= 2 sqrt(LK ln2/n) | max(H2 - 4 E sum h)")
    all_ok = True
    flat_rows = []
    for trial in range(15):
        variant = ["full", "stop", "flat"][trial % 3]
        scaf = Scaffold(variant)
        nH = int(rng.integers(2, 5))
        style = trial % 5
        H = []
        for i in range(nH):
            if style == 3:                       # deterministic samplers (functions)
                S = np.zeros((3, 2))
                for x in range(3):
                    S[x][rng.integers(2)] = 1.0
            else:
                th = rng.random(3) if style != 1 else np.clip(rng.random(3), 0.02, 0.98)
                if style == 2 and i > 0:         # some hypotheses exclude answers
                    th[rng.integers(3)] = float(rng.integers(2))
                if style == 4 and i == 0:        # the human never gives one answer at one input:
                    th[rng.integers(3)] = float(rng.integers(2))   # events of Q_P-probability zero exist
                S = np.stack([1 - th, th], axis=1)
            H.append(S)
        if style == 3:                           # make the functions distinct from the human at least somewhere
            H = [H[0]] + [S for S in H[1:] if not np.array_equal(S, H[0])] or [H[0]]
        w = rng.dirichlet(np.ones(len(H))) * rng.uniform(0.5, 1.0)       # sum of weights <= 1
        K_ln2 = math.log(1 / w[0])
        for n in (3, 7):
            tot, EH2, ETV, chain, EG0, klrun = protocol_R_exact(scaf, H, w, n)
            L = 2
            eh2, etv, eg0 = sum(EH2) / n, sum(ETV) / n, sum(EG0) / n
            factor = 0.25 if variant == "flat" else 1.0
            b = min(1.0, 2 * factor * L * K_ln2 / n)
            ok = (tot <= L * K_ln2 + 1e-12) and (eh2 <= 2 * factor * L * K_ln2 / n + 1e-12) \
                and (etv <= math.sqrt(b * (2 - b)) + 1e-12) and (chain <= 1e-12) and (eg0 <= 4 * factor * L * K_ln2 / n + 1e-12)
            if style == 3:                       # Theorem 3.1(e): a function; TV(Q_M, Q_f) = P[runs differ]
                ok = ok and (etv <= L * K_ln2 / n + 1e-12)
            if variant == "flat":                # the referee's sharpening of (d): KL(Q_P||Q_M) = E_{Q_M} sum_j KL_j exactly,
                same = abs(klrun - tot) <= 1e-9 * max(1.0, tot)          # hence E TV <= sqrt(L K ln2/(2n)) by Pinsker
                ok = ok and same and (etv <= math.sqrt(L * K_ln2 / (2 * n)) + 1e-12)
                flat_rows.append((klrun, tot, etv, math.sqrt(L * K_ln2 / (2 * n))))
            all_ok = all_ok and ok
            print(f"      {variant:5s} |H|={len(H)} style={style} n={n} | {tot:.4f} <= {L * K_ln2:.4f} | {eh2:.5f} <= {2 * factor * L * K_ln2 / n:.5f}"
                  f" | {etv:.4f} <= {math.sqrt(b * (2 - b)):.4f} | {chain:+.2e} | E Q(G0) = {eg0:.5f} {'OK' if ok else 'FAIL'}")
    print("      all rows satisfy R1, Theorem 3.1(a), (b), (c) for the zero-probability event, (d) on the flat scaffold and (e) for functions:", all_ok)
    print("      flat scaffold (inputs do not depend on the answers): sum_t E KL(Q_P||Q_M^(t)) | sum_t E E_Q sum_j KL | E TV(T) | sqrt(LK ln2/(2n))")
    for r in flat_rows:
        print(f"        {r[0]:.6f} | {r[1]:.6f} | {r[2]:.4f} | {r[3]:.4f}")


# ------------------------------------------------------------------ (B17)
def part_b17():
    print("(B17) Section 3.3, qualification 3 (filled in the report): for the K coins, any deployed sampler has")
    print("      E[number of unfaithful calls] >= L delta/4 when n <= K(1-4 delta^2)/(16 delta^2).  With delta^2 = K/(16 n + 4 K):")
    for (K, n) in [(8, 8), (8, 100), (16, 10000), (64, 10 ** 6)]:
        d = math.sqrt(K / (16 * n + 4 * K))
        lower = d / 4                                        # per call: divide by L
        upper = math.sqrt(K * LN2 / (2 * n))
        print(f"      K = {K}, n = {n}: delta = {d:.5f}; lower bound/L = {lower:.6f}; upper bound of R3/L = {upper:.6f}; ratio upper/lower = {upper / lower:.2f}")


if __name__ == "__main__":
    part_b16()
    part_b1()
    part_b2_b3()
    part_b15()
    part_b17()
