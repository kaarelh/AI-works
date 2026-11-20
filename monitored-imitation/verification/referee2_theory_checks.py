"""Referee checks (second note, without-a-check.md): theory.

Sections
  1. The weights q_EW: normalisation, uniform floor, distance-d weight; the code's sampler.
  2. Lemma 2 by brute force on random small systems; why Theorem 3(a) needs the human's
     own runs to succeed.
  3. The hidden-insight classes (silent / catch-up) with the exact class posterior and the
     majority decoder: does (C_1) hold?  Does the code's decoder_write_step equal the
     exact majority decoder?  Is the mistake set an up-set (Proposition 4)?
  4. Exact expected costs on a three-hypothesis toy: end-weighting can cost more than
     twice what chained imitation costs on a particular human (the abstract's
     "never worse ... by more than a factor 2" is a statement about bounds only).
     Also checks Theorem 1 / Theorem 3's per-round sums against K(P) on the toy.
  5. Theorem 3(c) variants and the "doubling loses about log r" remark.

Usage: python3 referee2_theory_checks.py   (about 10 s)
"""

import itertools
import math
import os
import random
import sys
from fractions import Fraction

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "code"))
import end_weighted as ew  # noqa: E402


def H(n):
    return sum(1.0 / i for i in range(1, n + 1))


def q_ew(n):
    Hn = H(n)
    return np.array([0.5 / n + 0.5 / ((n - k) * Hn) for k in range(n)])


# ----------------------------------------------------------------------------------
def section1():
    print("=" * 78)
    print("1. q_EW weights")
    worst_sum, worst_floor, worst_dist = 0.0, 1.0, 1.0
    for n in range(1, 3001):
        q = q_ew(n)
        Hn = H(n)
        worst_sum = max(worst_sum, abs(q.sum() - 1.0))
        worst_floor = min(worst_floor, (q * 2 * n).min())          # q(k) / (1/(2n))
        d = np.arange(n)
        ratio = q[n - 1 - d] * 2 * (d + 1) * Hn                    # q(dist d) / (1/(2(d+1)H_n))
        worst_dist = min(worst_dist, ratio.min())
    print(f"  n = 1..3000: max |sum q - 1| = {worst_sum:.2e};"
          f" min q(k)*2n = {worst_floor:.6f} (>= 1 required);"
          f" min q(n-1-d)*2(d+1)H_n = {worst_dist:.6f} (>= 1 required)")
    # the code's harmonic half
    for n in [16, 64, 256, 1024]:
        cdf = ew.end_weights_cdf(n)
        w = np.diff(np.concatenate([[0.0], cdf]))
        target = np.array([1.0 / ((n - k) * H(n)) for k in range(n)])
        print(f"  n = {n:4d}: code's harmonic half vs 1/((n-k)H_n): max abs diff = {np.abs(w - target).max():.2e}")
    # Monte Carlo of the exact sampling line used in simulate()
    rng = np.random.default_rng(7)
    for n in [16, 64]:
        cdf = ew.end_weights_cdf(n)
        N = 400000
        counts = np.zeros(n)
        for _ in range(N):
            j = int(rng.integers(n)) if rng.random() < 0.5 else min(n - 1, int(np.searchsorted(cdf, rng.random(), side='right')))
            counts[j] += 1
        q = q_ew(n)
        chi2 = (((counts - N * q) ** 2) / (N * q)).sum()
        print(f"  n = {n}: {N} draws of the code's EW sampler: chi^2 = {chi2:.1f} on {n-1} d.o.f.;"
              f" last-step freq {counts[-1]/N:.4f} vs q {q[-1]:.4f}; first-step freq {counts[0]/N:.5f} vs q {q[0]:.5f}")
    # the same sampling rule, vectorised, 2e6 draws, three seeds
    for n in [16, 64, 1024]:
        cdf = ew.end_weights_cdf(n)
        q = q_ew(n)
        chis = []
        for seed in [11, 12, 13]:
            g = np.random.default_rng(seed)
            N = 2_000_000
            a = g.random(N) < 0.5
            uni = g.integers(0, n, size=N)
            har = np.minimum(n - 1, np.searchsorted(cdf, g.random(N), side='right'))
            c = np.bincount(np.where(a, uni, har), minlength=n)
            chis.append(round(float((((c - N * q) ** 2) / (N * q)).sum()), 1))
        print(f"  n = {n}: vectorised sampler, 3 x 2e6 draws: chi^2 = {chis} on {n-1} d.o.f.")


# ----------------------------------------------------------------------------------
def section2():
    print("=" * 78)
    print("2. Lemma 2 by brute force")
    rnd = random.Random(1)
    checked = violations = 0
    nomistake_fail = 0
    for trial in range(20000):
        S = rnd.randint(2, 7)
        n = rnd.randint(1, 7)
        P = [rnd.randrange(S) for _ in range(S)]
        G = [P[s] if rnd.random() < 0.6 else rnd.randrange(S) for s in range(S)]
        good = [rnd.random() < 0.5 for _ in range(S)]            # success = final state in 'good'
        x0 = rnd.randrange(S)
        xs = [x0]
        for _ in range(n):
            xs.append(G[xs[-1]])

        def hybrid_final(k):
            x = xs[k]
            for _ in range(n - k):
                x = P[x]
            return x
        M = [k for k in range(n) if G[xs[k]] != P[xs[k]]]
        if not good[xs[n]] and not M:
            nomistake_fail += 1          # possible only because the human's own run fails
            assert not good[hybrid_final(0)]
        for r in range(1, n + 1):
            if good[hybrid_final(n - r)] and not good[xs[n]]:
                checked += 1
                if not any(n - r <= k < n for k in M):
                    violations += 1
    print(f"  {checked} (system, r) cases with H_(n-r) succeeding and H_n failing; violations of Lemma 2: {violations}")
    print(f"  failed decoder runs with NO mistake (human's own run also fails): {nomistake_fail}")
    print("  -> Theorem 3(a)'s step 'on a failed run |M_t| >= 1' needs the standing assumption that the")
    print("     human's own run succeeds on every problem; the note never states it as an assumption.")


# ----------------------------------------------------------------------------------
BOT = 0  # the 'no insight' symbol; insight values are 1..q


def human(theta, cls, n):
    """Return P_theta as a function of (j, a). theta = None (no insight) or (t, k)."""
    def P(j, a):
        if j >= n:
            return (n, a)
        if theta is not None and a == BOT:
            t, k = theta
            if (cls == "silent" and j == t) or (cls == "catch-up" and j >= t):
                return (j + 1, k)
        return (j + 1, a)
    return P


def thetas(n, q):
    return [None] + [(t, k) for t in range(n) for k in range(1, q + 1)]


def prior(theta, n, q, eta):
    return (1 - eta) if theta is None else eta / (n * q)


def majority(consistent, x, cls, n, q, eta, tiebreak):
    mass = {}
    for th in consistent:
        y = human(th, cls, n)(*x)
        mass[y] = mass.get(y, 0) + prior(th, n, q, eta)
    best = max(mass.values())
    cands = [y for y, v in mass.items() if v >= best - 1e-15]
    # tiebreak 'bot-first': prefer a = BOT; 'ins-first': prefer the smallest insight value
    key = (lambda y: y[1]) if tiebreak == "bot-first" else (lambda y: (y[1] == BOT, y[1]))
    return sorted(cands, key=key)[0]


def section3():
    print("=" * 78)
    print("3. Hidden-insight classes, exact class posterior, majority decoder")
    print("   (C_1): from the decoder's state at step n-1, the human's last step ends in the human's final state.")
    for cls in ["catch-up", "silent"]:
        for q in [2, 3]:
            for eta in [0.05, 0.25, 0.5, 0.6, 0.64, 0.66, 0.70, 0.74, 0.76, 0.8, 0.9]:
                for tiebreak in ["bot-first", "ins-first"]:
                    total = bad = bad_empty = 0
                    for n in range(2, 7):
                        TH = thetas(n, q)
                        for truth in TH:
                            Ptrue = human(truth, cls, n)
                            hfinal = (0, BOT)
                            for _ in range(n):
                                hfinal = Ptrue(*hfinal)
                            for size in range(n + 1):
                                for S in itertools.combinations(range(n), size):
                                    ans = {j: Ptrue(j, BOT) for j in S}
                                    cons = [th for th in TH if all(human(th, cls, n)(j, BOT) == ans[j] for j in S)]
                                    x = (0, BOT)
                                    for _ in range(n - 1):
                                        x = majority(cons, x, cls, n, q, eta, tiebreak)
                                    ok = Ptrue(*x) == hfinal          # hybrid H_(n-1)
                                    total += 1
                                    if not ok:
                                        bad += 1
                                        if size == 0:
                                            bad_empty += 1
                    if cls == "catch-up" or eta in (0.5,):
                        print(f"  {cls:8s} q={q} eta={eta:4.2f} tie={tiebreak:9s}: (C_1) fails in {bad:6d} of {total} (truth, probe set) cases"
                              f" ({bad_empty} with no data at all); q/(q+1) = {q/(q+1):.3f}")
    print("  -> catch-up: with no data the decoder writes a guessed insight at step j iff eta(j+1)/n > q/(q+1);")
    print("     data (t_p > lo) only lower the posterior of t_p <= j, so (C_1) holds for every data set iff")
    print("     eta(n-1)/n <= q/(q+1) (equality: depends on ties). For n = 2..6 that is eta <= 0.8 (q=2), 0.9 (q=3), as found.")
    print("     Larger n, no data:")
    for q in [2, 3]:
        for eta in [0.5, 0.66, 0.7, 0.8]:
            for n in [10, 50]:
                fails = 0
                TH = thetas(n, q)
                for truth in TH:
                    Ptrue = human(truth, "catch-up", n)
                    hfinal = (0, BOT)
                    for _ in range(n):
                        hfinal = Ptrue(*hfinal)
                    x = (0, BOT)
                    for _ in range(n - 1):
                        x = majority(TH, x, "catch-up", n, q, eta, "bot-first")
                    fails += (Ptrue(*x) != hfinal)
                print(f"       q={q} eta={eta:4.2f} n={n:2d}: eta(n-1)/n = {eta*(n-1)/n:.3f} vs q/(q+1) = {q/(q+1):.3f};"
                      f" (C_1) fails for {fails} of {len(TH)} truths")
    print("     So (C_1) holds in E3's setting (eta = 1/2) and in Theorem 3's regime (eta = 8 eps <= 1/2), for the")
    print("     class-prior majority decoder. It is not a property of the class alone: from a state carrying a wrong")
    print("     insight, or an insight on a problem without one, the catch-up human keeps it and the run fails.")
    print("  -> silent: (C_1) fails as soon as an insight with t_p < n-1 has not been found.")

    # the code's decoder vs the exact majority decoder (eta = 1/2, ties to BOT as in the code)
    print()
    print("  Code's decoder_write_step vs exact majority decoder (eta = 1/2, q in {2,3}, n = 2..7, all probe sets):")
    for cls in ["silent", "catch-up"]:
        mism = cnt = 0
        upset_fail_known = upset_fail_unknown = known_cases = unknown_cases = 0
        for q in [2, 3]:
            for n in range(2, 8):
                TH = thetas(n, q)
                for truth in TH:
                    if truth is None:
                        continue
                    t, k = truth
                    Ptrue = human(truth, cls, n)
                    for size in range(n + 1):
                        for S in itertools.combinations(range(n), size):
                            ans = {j: Ptrue(j, BOT) for j in S}
                            cons = [th for th in TH if all(human(th, cls, n)(j, BOT) == ans[j] for j in S)]
                            xs = [(0, BOT)]
                            for _ in range(n):
                                xs.append(majority(cons, xs[-1], cls, n, q, 0.5, "bot-first"))
                            exact_w = next((i for i in range(n) if xs[i + 1][1] != BOT), None)
                            if exact_w is not None:
                                assert xs[exact_w + 1][1] == k
                            pr = ew.Problem(n)
                            for j in S:
                                if cls == "silent":
                                    if j == t:
                                        pr.k_known, pr.t_known = True, t
                                else:
                                    if j >= t:
                                        pr.k_known = True
                                        pr.hi = min(pr.hi, j)
                                    else:
                                        pr.lo = max(pr.lo, j)
                            code_w = ew.decoder_write_step(pr, cls)
                            cnt += 1
                            mism += (code_w != exact_w)
                            M = [i for i in range(n) if Ptrue(*xs[i]) != xs[i + 1]]
                            is_up = (not M) or M == list(range(M[0], n))
                            if pr.k_known:
                                known_cases += 1
                                upset_fail_known += (not is_up)
                            else:
                                unknown_cases += 1
                                upset_fail_unknown += (not is_up)
        print(f"    {cls:8s}: {cnt} cases, mismatches = {mism}")
        if cls == "catch-up":
            print(f"    catch-up mistake set an up-set? k_p unknown: fails in {upset_fail_unknown}/{unknown_cases};"
                  f" k_p known: fails in {upset_fail_known}/{known_cases}")
            print("    -> Proposition 4 applies to the decoder that has not yet learned k_p; the binary search must be run")
            print("       on that (old) decoder's run, held fixed, as the code does. Once k_p is known the mistake set is")
            print("       [t_p, w) or {w}, not an up-set.")


# ----------------------------------------------------------------------------------
def exact_cost(hyps, w, true_name, x0, n, q, success, f):
    """Expected sum over rounds of f(run) for a protocol that, each round, runs the majority
    decoder on the single problem x0 and task-queries step k ~ q, then adds the answer.
    Exact, by recursion over the set of hypotheses consistent with the data (the decoder
    depends only on it). Returns math.inf if the protocol can loop forever with f > 0."""
    P = hyps[true_name]
    memo = {}

    def decoder(C):
        def G(x):
            mass = {}
            for h in C:
                mass[hyps[h][x]] = mass.get(hyps[h][x], Fraction(0)) + w[h]
            best = max(mass.values())
            return sorted(y for y, v in mass.items() if v == best)[0]
        return G

    def V(C):
        if C in memo:
            return memo[C]
        G = decoder(C)
        xs = [x0]
        for _ in range(n):
            xs.append(G(xs[-1]))
        val = f(xs, G, P)
        stay = Fraction(0)
        moves = {}
        for k in range(n):
            C2 = frozenset(h for h in C if hyps[h][xs[k]] == P[xs[k]])
            if C2 == C:
                stay += q[k]
            else:
                moves[C2] = moves.get(C2, Fraction(0)) + q[k]
        acc = Fraction(0)
        for C2, pk in moves.items():
            sub = V(C2)
            if sub == math.inf:
                if pk > 0:
                    memo[C] = math.inf
                    return math.inf
                continue
            acc += pk * sub
        if stay == 1:
            res = math.inf if val > 0 else Fraction(0)
        else:
            res = (val + acc) / (1 - stay)
        memo[C] = res
        return res
    return V(frozenset(hyps))


def section4():
    print("=" * 78)
    print("4. A particular human on which end-weighting costs more than twice chained imitation")
    print("   States s0..sN (the human's run), z1..zN (an off-track chain), y. Success: final state sN.")
    print("   P: s_i -> s_(i+1), z_i -> z_(i+1).   A = P except A(s_(N-1)) = y.   B = P except B(s0) = z1.")
    print("   Prior w(P)=3/10, w(A)=2/10, w(B)=4/10, so K(P) = log2(10/3) = 1.737.")
    print("   Initially the decoder is right everywhere (P+A outvote B at s0). A query at s_(N-1) refutes A,")
    print("   after which B outvotes P at s0 and every run fails until s0 itself is queried.")
    wP, wA, wB = Fraction(3, 10), Fraction(2, 10), Fraction(4, 10)
    for N in [4, 16, 64, 256]:
        X = [f"s{i}" for i in range(N + 1)] + [f"z{i}" for i in range(1, N + 1)] + ["y"]

        def base():
            h = {}
            for i in range(N):
                h[f"s{i}"] = f"s{i+1}"
            h[f"s{N}"] = f"s{N}"
            for i in range(1, N):
                h[f"z{i}"] = f"z{i+1}"
            h[f"z{N}"] = f"z{N}"
            h["y"] = "y"
            return h
        P = base()
        A = base(); A[f"s{N-1}"] = "y"
        B = base(); B["s0"] = "z1"
        hyps = {"P": P, "A": A, "B": B}
        w = {"P": wP, "A": wA, "B": wB}
        HN = sum(Fraction(1, i) for i in range(1, N + 1))
        qCI = [Fraction(1, N)] * N
        qEW = [Fraction(1, 2 * N) + Fraction(1, 2) / ((N - k) * HN) for k in range(N)]
        qLAST = [Fraction(0)] * (N - 1) + [Fraction(1)]
        succ = lambda xs: xs[-1] == f"s{N}"  # noqa: E731
        fail = lambda xs, G, P_: Fraction(int(not succ(xs)))  # noqa: E731

        def hits(qv):
            return lambda xs, G, P_: sum((qv[k] for k in range(N) if G(xs[k]) != P_[xs[k]]), Fraction(0))

        def thm3(xs, G, P_):
            if succ(xs):
                return Fraction(0)
            M = [k for k in range(N) if G(xs[k]) != P_[xs[k]]]
            d = N - 1 - max(M)
            return max(Fraction(1, 2 * N), Fraction(1, 2) / ((d + 1) * HN))
        fCI = exact_cost(hyps, w, "P", "s0", N, qCI, succ, fail)
        fEW = exact_cost(hyps, w, "P", "s0", N, qEW, succ, fail)
        fLAST = exact_cost(hyps, w, "P", "s0", N, qLAST, succ, fail)
        hCI = exact_cost(hyps, w, "P", "s0", N, qCI, succ, hits(qCI))
        hEW = exact_cost(hyps, w, "P", "s0", N, qEW, succ, hits(qEW))
        t3 = exact_cost(hyps, w, "P", "s0", N, qEW, succ, thm3)
        K = math.log2(10 / 3)
        print(f"  N = {N:3d}: E[failed runs]  CI = {float(fCI):8.2f}   EW = {float(fEW):8.2f}   ratio EW/CI = {float(fEW/fCI):.3f}"
              f"   LAST = {fLAST}")
        print(f"           Theorem 1 sums E sum q(M_t): CI {float(hCI):.3f}, EW {float(hEW):.3f};"
              f" Theorem 3 sum {float(t3):.3f}; K(P) = {K:.3f}; bound 2nK = {2*N*K:.1f}")
    print("  -> ratio EW/CI exceeds 2 (tends to 4 as N grows). Theorem 3(a) compares upper bounds (2nK vs nK);")
    print("     on a particular human end-weighting can be worse than chained imitation by more than 2.")


# ----------------------------------------------------------------------------------
def section5():
    print("=" * 78)
    print("5. Theorem 3(c) variants, and the 'doubling loses about log r' remark")
    for n, r in [(64, 4), (1024, 8)]:
        Hn = H(n)
        qa = np.array([0.5 * (1.0 / r if k >= n - r else 0.0) + 0.5 / ((n - k) * Hn) for k in range(n)])
        qb = np.array([0.5 / n + 0.5 * (1.0 / r if k >= n - r else 0.0) for k in range(n)])
        print(f"  n={n}, r={r}: (uniform half -> last r) min q = {qa.min():.2e} = 1/(2nH_n) -> worst case {1/qa.min():.0f}*K"
              f" (vs 2n = {2*n}); last-r weight >= {qa[n-r:].min():.4f} = 1/(2r)")
        print(f"               (harmonic half -> last r) min q = {qb.min():.2e} = 1/(2n) -> worst case {1/qb.min():.0f}*K;"
              f" last-r weight >= {qb[n-r:].min():.4f} >= 1/(2r)")
    print("  Any weighting with q(dist d) >= 1/(C (d+1) log2(d+2)) for all d < n needs C >= S(n) = sum_d 1/((d+1)log2(d+2)):")
    for n in [16, 1024, 2**20, 2**40]:
        if n <= 2**20:
            S = sum(1.0 / ((d + 1) * math.log2(d + 2)) for d in range(n))
        else:
            S = sum(1.0 / ((d + 1) * math.log2(d + 2)) for d in range(2**20)) + math.log(2) * (math.log(math.log2(n)) - math.log(20))
        print(f"    n = 2^{int(round(math.log2(n))):2d}: S(n) = {S:.2f}")
    print("  -> 'a factor of about log r' must carry a further factor growing like log log n (or (log log r)^(1+o(1))).")


if __name__ == "__main__":
    section1()
    section2()
    section3()
    section4()
    section5()
