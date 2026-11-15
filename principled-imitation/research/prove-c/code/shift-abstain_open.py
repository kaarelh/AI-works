#!/usr/bin/env python3
"""Checks for Section 3 of research/prove-c/shift-abstain.md (open systems).

(A) Theorem 3.1 (each step put to the human with probability q, for ever):
    simulation of E sum_t KL against K ln2 / q for a small class of samplers and an
    adaptive input rule; Example 3.2 (the bound is attained up to 2 ln 2).
(B) Theorem 3.3 (thresholds, a label is seen only on a question):
    exact optimum over ALL deterministic learners with at most Q questions, by
    dynamic programming over information states; comparison with the reduction to
    block sizes and with the lower bound (1/4)(N/(Q+1) - (Q+1)/N).
    Expected-question version: Lagrangian optimum, lower bound
    N/(9(Qbar+1)) - sqrt((Qbar+1)/(8N)), and the lemma A*S >= (4/9) N^3.
(C) Proposition 4.6 (thresholds, every label shown, at most k wrong answers):
    exact game value by recursion, against C(m+1, <=k+1) - 1.
"""
import math
import random
from functools import lru_cache
from itertools import combinations


# ---------------------------------------------------------------- (A)
def sim_online(q, T, reps, seed=0):
    """Class: 8 samplers on X = {0,1,2}, Y = {0,1}; nu_c(1|x) = c[x] with c in {0.2, 0.8}^3.
    Human: c = (0.2, 0.8, 0.2).  Prior: uniform.  Input rule (adaptive): the input at which
    the current mixture is farthest in KL from the human.  Returns mean and standard error of
    sum_t KL(P || M_t)(x_t) over all steps, asked or not."""
    rng = random.Random(seed)
    cs = [(a, b, c) for a in (0.2, 0.8) for b in (0.2, 0.8) for c in (0.2, 0.8)]
    human = (0.2, 0.8, 0.2)
    sums = []
    for _ in range(reps):
        logw = [0.0] * 8
        tot = 0.0
        best, bx = None, 0
        for _t in range(T):
            if best is None:                       # the posterior changed: recompute
                mx = max(logw)
                w = [math.exp(l - mx) for l in logw]
                s = sum(w)
                w = [v / s for v in w]
                best, bx = -1.0, 0
                for x in range(3):
                    m1 = sum(wi * c[x] for wi, c in zip(w, cs))
                    p1 = human[x]
                    kl = p1 * math.log(p1 / m1) + (1 - p1) * math.log((1 - p1) / (1 - m1))
                    if kl > best:
                        best, bx = kl, x
            tot += best
            if rng.random() < q:
                y = 1 if rng.random() < human[bx] else 0
                for i, c in enumerate(cs):
                    logw[i] += math.log(c[bx] if y == 1 else 1 - c[bx])
                best = None
        sums.append(tot)
    mean = sum(sums) / reps
    var = sum((v - mean) ** 2 for v in sums) / (reps - 1)
    return mean, math.sqrt(var / reps)


def example_3_2(K, q, reps, seed=0):
    """All 2^K functions on K inputs, uniform prior, f = 0; input a_i is repeated until it
    has been asked.  Silent mistakes of a draw from the mixture: exact value K(1-q)/(2q)."""
    rng = random.Random(seed)
    tot = 0
    for _ in range(reps):
        for _i in range(K):
            while rng.random() >= q:          # an unasked step at a_i
                if rng.random() < 0.5:
                    tot += 1
    return tot / reps


# ---------------------------------------------------------------- (B)
def opt_bruteforce(N, Q):
    """Minimum over all deterministic learners with at most Q questions on every run of
    sum over s in {0..N-1} of the number of silent mistakes.  Inputs 1..N-1 in increasing
    order, label of x is 1 iff x <= s.  State: next position x, the consistent range
    lo <= s <= hi-1, remaining questions."""
    @lru_cache(maxsize=None)
    def V(x, lo, hi, q):
        if lo >= hi:
            return 0
        if x == N:
            return 0
        ones = max(0, min(hi - 1, N - 1) - max(lo, x) + 1)     # s in range with label 1 (s >= x)
        zeros = (hi - lo) - ones
        best = min(zeros, ones) + V(x + 1, lo, hi, q)            # predict 1 (wrong for zeros) or 0
        if q > 0:
            best = min(best, V(x + 1, max(lo, x), hi, q - 1) + V(x + 1, lo, min(hi, x), q - 1))
        return best
    return V(1, 0, N, Q)


def gap_cost(b, R):
    """Mistakes summed over all s that reach a gap of b-1 unasked positions followed by a
    question (or the end), when R members lie beyond the block: sum_r min(r, b - r + R)."""
    return sum(min(r, b - r + R) for r in range(1, b))


def opt_blocks(N, Q):
    """Same optimum through block sizes b_1..b_u (u <= Q+1, sum = N):
    sum_j gap_cost(b_j, N - (b_1+..+b_j))."""
    @lru_cache(maxsize=None)
    def W(rem, u):                      # rem members remain (the last 'rem'), at most u blocks
        if rem == 0:
            return 0
        if u == 0:
            return math.inf
        return min(gap_cost(b, rem - b) + W(rem - b, u - 1) for b in range(1, rem + 1))
    return W(N, Q + 1)


def lagrangian_hull(N, lams):
    """For each lam: minimise sum_s (mistakes + lam * questions) over deterministic learners
    that stop asking after the first answer 0.  A learner is a composition (b_1..b_u) of N;
    for s in block j it asks min(j, u-1) questions.  Returns hull points (Qbar, Mbar)."""
    pts = set()
    for lam in lams:
        @lru_cache(maxsize=None)
        def F(rem, j):
            # best cost for the last 'rem' members when the next block has index j;
            # returns (cost, mistakes, questions)
            if rem == 0:
                return (0.0, 0, 0)
            best = None
            for b in range(1, rem + 1):
                last = (b == rem)
                qs = (j - 1 if last else j) * b          # questions asked by members of this block
                ms = gap_cost(b, rem - b)
                c, m2, q2 = F(rem - b, j + 1)
                cand = (ms + lam * qs + c, ms + m2, qs + q2)
                if best is None or cand[0] < best[0] - 1e-12:
                    best = cand
            return best
        c, m, qsum = F(N, 1)
        pts.add((qsum / N, m / N))
        F.cache_clear()
    return sorted(pts)


# ---------------------------------------------------------------- (C)
def game_value(kmax, mmax, nmax):
    """win[n][k][m]: a deterministic learner can guarantee at most k wrong answers and at most
    m wrong-or-abstained rounds against n thresholds still consistent (every label shown)."""
    win = [[[False] * (mmax + 1) for _ in range(kmax + 1)] for _ in range(nmax + 1)]
    for k in range(kmax + 1):
        for m in range(mmax + 1):
            win[1][k][m] = True
    for n in range(2, nmax + 1):
        for k in range(kmax + 1):
            for m in range(mmax + 1):
                ok = True
                for n1 in range(1, n):          # the adversary's split
                    n2 = n - n1
                    can = False
                    if m >= 1 and win[n1][k][m - 1] and win[n2][k][m - 1]:
                        can = True              # abstain
                    for (pa, pb) in ((n1, n2), (n2, n1)):   # predict the label of part pa
                        if win[pa][k][m] and k >= 1 and m >= 1 and win[pb][k - 1][m - 1]:
                            can = True
                    if not can:
                        ok = False
                        break
                win[n][k][m] = ok
    return win


def binom_le(t, j):
    return sum(math.comb(t, i) for i in range(0, j + 1))


def main():
    print("(A) online form: E sum_t KL over all steps, against K ln2 / q   (K = 3 bits)")
    for q in (0.5, 0.2, 0.05):
        v, se = sim_online(q, T=int(300 / q), reps=20000, seed=7)
        print(f"   q={q:<5} simulated {v:7.3f} +- {se:5.3f} (s.e.)   bound {3 * math.log(2) / q:7.3f}")
    print("    (the input rule shows the most informative input, so the bound is nearly attained)")
    print("    Example 3.2: silent mistakes, simulated against K(1-q)/(2q) and the bound (1-q)K ln2/q")
    for K, q in ((8, 0.25), (8, 0.05)):
        v = example_3_2(K, q, reps=40000, seed=3)
        print(f"   K={K} q={q:<5} simulated {v:8.3f}   exact {K * (1 - q) / (2 * q):8.3f}   "
              f"bound {(1 - q) * K * math.log(2) / q:8.3f}")
    print()

    print("(B) thresholds, labels only on questions: N * E[silent mistakes], exact minimum")
    print("    brute = all deterministic learners;  blocks = reduction to block sizes;")
    print("    bound = (N^2/(Q+1) - (Q+1))/4")
    print(f"   {'N':>3} {'Q':>3} {'brute':>7} {'blocks':>7} {'bound':>8} {'N*M*(Q+1)/N^2':>14}")
    for N in (6, 9, 12, 16):
        for Q in range(0, min(N - 1, 6)):
            br = opt_bruteforce(N, Q)
            bl = opt_blocks(N, Q)
            bd = (N * N / (Q + 1) - (Q + 1)) / 4
            assert br == bl, (N, Q, br, bl)
            assert br >= bd - 1e-9
            print(f"   {N:>3} {Q:>3} {br:>7} {bl:>7} {bd:>8.2f} {br * (Q + 1) / N ** 2:>14.3f}")
    print("    larger N through the block reduction: E[M]*(Q+1)/N")
    for N in (60, 240):
        row = []
        for Q in (0, 1, 2, 5, 11, 29):
            bl = opt_blocks(N, Q)
            assert bl >= (N * N / (Q + 1) - (Q + 1)) / 4 - 1e-9
            row.append(f"Q={Q}: {bl * (Q + 1) / N ** 2:.3f}")
        print(f"   N={N:>4}  " + "  ".join(row))
    print("    (the lower bound of Theorem 3.3(a) gives at least 1/4 - ((Q+1)/N)^2/4)")
    print()

    print("    expected questions: hull of deterministic learners, against")
    print("    g(Qbar) = N/(9(Qbar+1)) - sqrt((Qbar+1)/(8N))  and  E[M](Qbar+1) >= N/15 for Qbar+1 <= N/4")
    for N in (12, 24, 48):
        lams = [0.01 * 1.25 ** i for i in range(60)]
        pts = lagrangian_hull(N, lams)
        worst = math.inf
        worst_prod = math.inf
        for qb, mb in pts:
            g = N / (9 * (qb + 1)) - math.sqrt((qb + 1) / (8 * N))
            assert mb >= g - 1e-9, (N, qb, mb, g)
            worst = min(worst, mb - g)
            if qb + 1 <= N / 4:
                worst_prod = min(worst_prod, mb * (qb + 1) / N)
        print(f"   N={N:>3}: {len(pts)} hull points; min(E[M] - g) = {worst:.3f}; "
              f"min E[M](Qbar+1)/N over Qbar+1 <= N/4: {worst_prod:.3f}  (bound 1/15 = {1/15:.3f})")
    rng = random.Random(5)
    worst = math.inf
    for _ in range(20000):
        u = rng.randrange(1, 12)
        b = [rng.randrange(1, 30) for _ in range(u)]
        N = sum(b)
        A = sum(x * x for x in b)
        S = sum((j + 1) * x for j, x in enumerate(b))
        worst = min(worst, A * S / N ** 3)
    # near-extremal: b_j proportional to (J - j)
    J = 400
    b = [J - j for j in range(1, J)]
    N = sum(b)
    A = sum(x * x for x in b)
    S = sum((j + 1) * x for j, x in enumerate(b))
    print(f"    lemma A*S >= (4/9)N^3: smallest ratio A*S/N^3 over 20000 random compositions "
          f"{worst:.4f}; for b_j = J-j, J=400: {A * S / N ** 3:.4f}; 4/9 = {4 / 9:.4f}")
    print()

    print("(C) thresholds, every label shown, at most k wrong answers and m wrong-or-abstained rounds:")
    print("    largest number of thresholds that can be handled (exact game value) and C(m+1,<=k+1)-1")
    kmax, mmax, nmax = 3, 7, 140
    win = game_value(kmax, mmax, nmax)
    for k in range(0, kmax + 1):
        row = []
        for m in range(0, mmax + 1):
            v = max(n for n in range(1, nmax + 1) if win[n][k][m])
            formula = binom_le(m + 1, k + 1) - 1
            if formula < nmax:
                assert v == formula, (k, m, v, formula)
                row.append(f"{v}")
            else:
                row.append(f">={nmax}")
        print(f"   k={k}: m=0..{mmax}: " + " ".join(row))
    print("    (equal to the formula in every case below the cap)")


if __name__ == "__main__":
    main()
