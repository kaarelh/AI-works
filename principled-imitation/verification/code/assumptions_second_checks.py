"""Second checker, part assumptions: independent recomputation of the numbers that the
note's text for this part uses, and of the statements seen by one verifier and the editor.

Written from the statements in proofs/assumptions.md, without reusing the code of
proofs/code/assumptions_*.py.  Usage: python3 assumptions_second_checks.py
"""
import itertools
import math
import random
from math import comb, log, log2, exp, sqrt

LN2 = log(2.0)


def hdr(s):
    print("\n== " + s)


# ---------------------------------------------------------------- Section 9.1 of the note
def budget():
    hdr("Section 9.1: budget table and sentences")
    th = de = 0.1
    for label, n in (("career 1e5 h", 1e5), ("50 years, 1 year/answer", 50), ("1e6 people x 2000 h", 1e6 * 2000)):
        print(f"  {label:28s} n = {n:.3g}  K paid = n*theta*delta/ln2 = {n * th * de / LN2:.4g} bits")
    n9 = 1e9 * LN2 / (th * de)
    print(f"  K = 1e9: n = {n9:.4g} answers = {n9 / 2000:.4g} working years of 2000 h = {n9 / 8765.82:.4g} calendar years")
    print(f"  certificate ln(20)/(theta delta) = {log(20) / (th * de):.2f}  (ceil {math.ceil(log(20) / (th * de))})")
    print(f"  pool of 1e4 people, one year each: K paid = {1e4 * th * de / LN2:.1f} bits (proof file 6.2, row 3)")
    print(f"  20 sequential batches: K paid = {20 * th * de / LN2:.3f} bits")
    m = math.ceil(log(20) / (th * de))
    for e in (0.0, 0.001, 0.01, 0.1):
        rho = 2 * e * (1 - e)
        print(f"  certificate pass prob, exact imitator, e = {e}: (1-2e(1-e))^{m} = {(1 - rho) ** m:.3g}")
    # N8 constants
    B, d = 5, 0.05
    c = (1 - 10 * d) * B / (8 * d * log2(B / (2 * d)))
    print(f"  N8 with g = 5, delta = 0.05: n >= {c:.4f} K; 50 answers -> K <= {50 / c:.2f}; 1e4 -> K <= {1e4 / c:.1f}")
    print(f"  Prop 6.4 at theta = delta = 0.1: factor {1 - 0.2 - 0.2:.2f}; 50 answers -> K <= {50 / 0.6:.1f}")
    # algebra of Theorem 6.1(3): p >= 2 delta (1 - delta), delta/p <= 1/2 + delta, final constant
    worst = 0.0
    for B in (1, 2, 3, 5, 10, 50, 400):
        for dd in (0.001, 0.01, 0.03, 0.05, 0.0999):
            N = B / (2 * dd)
            p = 1 - (1 - 1 / N) ** B
            ok1 = p >= 2 * dd * (1 - dd) - 1e-15
            ok2 = dd / p <= 0.5 + dd + 1e-15
            lhs = (N / 2) * (1 - 2 * B / N - dd / p)  # per block
            rhs = (1 - 10 * dd) * B / (8 * dd)
            if not (ok1 and ok2 and lhs >= rhs - 1e-9):
                print("  FAIL", B, dd, p, lhs, rhs)
            worst = max(worst, rhs / lhs if lhs > 0 else 0)
    print(f"  Theorem 6.1(3) algebra checked on a grid (N real): max ratio rhs/lhs = {worst:.4f} (<= 1 needed)")
    # factor between upper and lower bound, 16 ln2 log2(B/(2delta))/(1-10delta)
    for B, dd in ((5, 0.05), (10, 0.01)):
        print(f"  N8 gap factor at g = {B}, delta = {dd}: {16 * LN2 * log2(B / (2 * dd)) / (1 - 10 * dd):.1f}")
    # 'What survives': N2b constant (1-10delta)/8 >= 1/16 iff delta <= 1/20
    print(f"  N2b: (1-10*0.05)/8 = {(1 - 0.5) / 8:.4f} = 1/16")


# ---------------------------------------------------------------- Example 2.3
def example23():
    hdr("Example 2.3 (caveat on A2)")
    prod = 1.0
    for k in range(0, 200):
        w = 1 / (1 + 2 ** k)
        prod *= 2 / (2 + w)
    print(f"  Pr[nu1 never refuted] = {prod:.6f}; refuted = {1 - prod:.6f}; limit failure prob = {(1 - prod) / 2:.4f}")
    # simulation of the protocol itself (not of the product)
    rng = random.Random(1)
    R, n = 200000, 60
    refuted = 0
    for _ in range(R):
        k = 0
        for t in range(n):
            wk = 1 / (1 + 2 ** k)
            # round: run of mixture: call a, mixture answers 1 w.p. wk/2 (nu2 fair bit); asked index J uniform in {1,2}
            ans_a = 1 if rng.random() < wk / 2 else 0
            J = rng.randint(1, 2)
            if J == 1:
                k += 1  # human answers 0 at a; nu2 likelihood halves, nu1 fine
            elif ans_a == 1:
                refuted += 1  # call b exists and is asked; human 0, nu1 says 1
                break
    print(f"  simulation of Protocol R, {R} runs, n = {n}: Pr[nu1 refuted] = {refuted / R:.4f} +- {sqrt(0.25 / R) * 2:.4f}")
    for K1 in (1, 2, 5, 10, 20):
        w1 = 2.0 ** (-K1)
        w2 = 1 - w1
        p = 1.0
        for k in range(0, 400):
            om = w2 * 2.0 ** (-k) / (w1 + w2 * 2.0 ** (-k))
            p *= 2 / (2 + om)
        print(f"  K1 = {K1:2d}: Pr[nu1 refuted] = {1 - p:.4f}  (bound 1-(4/5)^K1 = {1 - 0.8 ** K1:.4f})")


# ---------------------------------------------------------------- Example 3.3
def example33():
    hdr("Example 3.3 (seeded index), k = 3, L = 4")
    k, L = 3, 4
    S = 2 ** k

    def per_round(t, seeded):
        q = L ** (-(t - 1))
        tot = 0.0
        if seeded:
            for a in range(S):  # a other seeds alive
                pr = comb(S - 1, a) * q ** a * (1 - q) ** (S - 1 - a)
                A = a + 1
                tot += pr * (L - 1) * A / (S + A)
        else:
            for A in range(S + 1):
                pr = comb(S, A) * q ** A * (1 - q) ** (S - A)
                tot += pr * (L - 1) * A / (S + A)
        return tot

    for n in (100, 1000):
        s1 = sum(per_round(t, True) for t in range(1, n + 1)) / n
        s2 = sum(per_round(t, False) for t in range(1, n + 1)) / n
        print(f"  n = {n}: seeded {s1:.4f} (limit {(L - 1) / (S + 1):.4f}); fresh {s2:.4f}; R1 bound L ln2/n = {L * LN2 / n:.4f}")


# ---------------------------------------------------------------- Example 3.3a
def example33a():
    hdr("Example 3.3a (generator with an 8-valued seed), exact")
    X = range(64)
    masks = [1, 2, 4, 8, 16, 32, 3, 5]  # eight distinct nonzero masks
    A = [frozenset(x for x in X if bin(x & m).count("1") % 2 == 0) for m in masks]
    assert all(len(a) == 32 for a in A)
    inter = {len(A[i] & A[j]) for i in range(8) for j in range(8) if i != j}
    print(f"  |A_s| = 32; pairwise intersections: {sorted(inter)}")
    s = 0

    def wrong(alive):
        a = len(alive)
        return (a / 32) / (0.5 + a / 16)  # each g_sigma wrong on half of X, weight 1/16

    def deployed(n, gen):
        # per round, each g_sigma (sigma != s) survives w.p. 1/2 (gen) ; with fresh inputs also g_s survives w.p. 1/2
        tot = 0.0
        for T in range(1, n + 1):
            q = 0.5 ** (T - 1)
            if gen:
                for a in range(8):
                    tot += comb(7, a) * q ** a * (1 - q) ** (7 - a) * wrong(range(a + 1))
            else:
                for a in range(9):
                    tot += comb(8, a) * q ** a * (1 - q) ** (8 - a) * wrong(range(a))
        return tot / n

    # check the survival probability 1/2 by enumeration
    surv = {len(A[s] & A[j]) / len(A[s]) for j in range(1, 8)}
    print(f"  survival probability of g_sigma under generator s: {surv}; floor (1/2)/(2^k+1) = {0.5 / 9:.4f}")
    for n in (10, 100, 1000):
        print(f"  [independence approximation] n = {n}: generator {deployed(n, True):.4f}; fresh {deployed(n, False):.4f}; R1 bound ln2/n = {LN2 / n:.4f}")

    # exact: the alive set after t questions is the set of sigma with x_1..x_t all in A_sigma;
    # computed by enumerating, for each t, the law of the intersection pattern via the set
    # of inputs, as a Markov chain on alive sets (states as frozensets).
    def exact(n, pool, s_immortal):
        dist = {frozenset(range(8)): 1.0}
        acc = 0.0
        for t in range(1, n + 1):
            acc += sum(pr * wrong(st) for st, pr in dist.items())
            nd = {}
            for st, pr in dist.items():
                for x in pool:
                    ns = frozenset(g for g in st if x in A[g] or (s_immortal and g == s))
                    nd[ns] = nd.get(ns, 0.0) + pr / len(pool)
            dist = nd
        return acc / n

    for n in (10, 100, 1000):
        print(f"  [exact, masks {masks}] n = {n}: generator {exact(n, sorted(A[s]), True):.4f}; "
              f"fresh {exact(n, list(X), False):.4f}; R1 bound ln2/n = {LN2 / n:.4f}")


# ---------------------------------------------------------------- Remark 3.2a
def remark32a():
    hdr("Remark 3.2a: tables against the human")
    for N, K, ss in ((1024, 100, (8, 9, 10, 11)), (1024, 1000, (81, 90, 100, 101))):
        # weights: human 2^-K; table_A weight c (2N)^-|A|; c normalises total to 1
        logc = log(1 - 2.0 ** (-K)) - N * math.log1p(1 / (2 * N))
        out = []
        for s in ss:
            la = logc - s * log(2 * N) + (N - s) * math.log1p(1 / (2 * N))
            l1 = la - math.log1p(1 / (2 * N))
            lh = -K * LN2
            mx = max(la, lh)
            out.append(f"s={s}: {exp(l1 - mx) / (exp(la - mx) + exp(lh - mx)):.4f}")
        print(f"  N = {N}, K = {K}: " + "; ".join(out))
    Z, n = 2 ** 20, 1000
    l2 = (math.lgamma(Z + 1) - math.lgamma(n + 1) - math.lgamma(Z - n + 1)) / LN2
    dist = exp(sum(math.log1p(-i / Z) for i in range(n)))
    print(f"  (ii) log2 C(2^20,1000) = {l2:.1f}; Pr[distinct] = {dist:.3f}; K ln2/n at K = 11500: {11500 * LN2 / 1000:.2f}")


# ---------------------------------------------------------------- Example 3.2b
def example32b():
    hdr("Example 3.2b: last mixture on a chain")
    for L in (10, 40, 160):
        best, bn = 0, 0
        p = 1 / L
        for n in range(L - 1, 20 * L * L):
            lp = math.lgamma(n + 1) - math.lgamma(L) - math.lgamma(n - L + 2) + (L - 1) * log(p) + (n - L + 1) * math.log1p(-p)
            r = exp(lp) * (n + 1) / L
            if r > best:
                best, bn = r, n
        print(f"  L = {L}: max ratio {best:.3f} at n = {bn} (L^2 = {L * L}); 0.4 sqrt(L) = {0.4 * sqrt(L):.2f}")
    # simulation of the limiting chain to confirm the 'one success per round w.p. 1/L' description
    rng = random.Random(3)
    L, n, R = 10, 100, 100000
    hit = 0
    for _ in range(R):
        learned = 0
        asked_xL = False
        for t in range(n):
            length = min(learned + 1, L)  # run stops at first unlearned link (answered 0), or reaches x_L
            J = rng.randint(1, L)
            if J <= length and J == learned + 1:
                if learned + 1 == L:
                    asked_xL = True
                    break
                learned += 1
        if not asked_xL and learned == L - 1:
            hit += 1
    lp = comb(n, L - 1) * (1 / L) ** (L - 1) * (1 - 1 / L) ** (n - L + 1)
    print(f"  simulation L = 10, n = 100: Pr = {hit / R:.4f}; binomial formula {lp:.4f}")


# ---------------------------------------------------------------- Proposition 1.9a
def prop19a():
    hdr("Proposition 1.9a: cut and paste and subadditivity, random episodic scaffolds")
    rng = random.Random(7)

    def build(depth, Le):
        # a random scaffold on binary answers: episode number of each call drawn as a function of history,
        # in order of first appearance; P and C kernels on histories (more general than visible histories)
        ep, P, C = {}, {}, {}

        def rec(h, used):
            if len(h) == depth or (len(h) > 0 and rng.random() < 0.15):
                return
            choices = list(range(1, min(used + 1, Le) + 1))
            e = rng.choice(choices)
            ep[h] = e
            P[h] = rng.random()
            C[h] = rng.random()
            nu = max(used, e)
            for y in (0, 1):
                rec(h + (y,), nu)

        rec((), 0)
        return ep, P, C

    def law(ep, P, C, S):
        out = {}

        def rec(h, pr):
            if h not in ep:
                out[h] = out.get(h, 0) + pr
                return
            p1 = P[h] if ep[h] in S else C[h]
            rec(h + (1,), pr * p1)
            rec(h + (0,), pr * (1 - p1))

        rec((), 1.0)
        return out

    def H2(a, b):
        keys = set(a) | set(b)
        return 1 - sum(sqrt(a.get(k, 0) * b.get(k, 0)) for k in keys)

    def KL(a, b):
        return sum(v * log(v / b[k]) for k, v in a.items() if v > 0)

    max_id, max_sub, max_b3, max_b2 = 0, -1e9, -1e9, -1e9
    trials = 0
    for _ in range(400):
        Le = rng.choice([2, 3, 4])
        ep, P, C = build(rng.choice([3, 4, 5, 6]), Le)
        eps = sorted(set(ep.values()))
        if not eps:
            continue
        trials += 1
        allE = list(range(1, Le + 1))
        subsets = [frozenset(c) for r in range(Le + 1) for c in itertools.combinations(allE, r)]
        laws = {S: law(ep, P, C, S) for S in subsets}
        for S in subsets:
            for T in subsets:
                max_id = max(max_id, abs(H2(laws[S], laws[T]) - H2(laws[S & T], laws[S | T])))
        Q0, Qall = laws[frozenset()], laws[frozenset(allE)]
        h = H2(Q0, Qall)
        hs = [H2(Q0, laws[frozenset([i])]) for i in allE]
        kls = [KL(laws[frozenset([i])], Q0) for i in allE]
        max_sub = max(max_sub, sqrt(max(h, 0)) - sum(sqrt(max(x, 0)) for x in hs))
        max_b3 = max(max_b3, h - (Le / 2) * sum(kls))
        if Le == 2:
            max_b2 = max(max_b2, h - sum(kls))
    print(f"  {trials} scaffolds: max |H2(Q_S,Q_T) - H2(Q_SnT,Q_SuT)| = {max_id:.2e}")
    print(f"  max of sqrt(H2(C,P)) - sum_i sqrt(H2(C,C[i<-P])) = {max_sub:.3e} (<= 0 claimed)")
    print(f"  max of H2 - (L_e/2) sum KL = {max_b3:.3e} (<= 0 claimed); for L_e = 2, max of H2 - sum KL = {max_b2:.3e}")


if __name__ == "__main__":
    budget()
    example23()
    example33()
    example33a()
    remark32a()
    example32b()
    prop19a()
