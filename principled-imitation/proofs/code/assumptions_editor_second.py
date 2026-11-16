"""Checks of the editor of the part `assumptions` in the second round.

Written from the statements of proofs/assumptions.md and of verification/assumptions-second.md.
No code is shared with the other scripts of this part (proofs/code/assumptions_*.py) or with
the script of the second check (verification/code/assumptions_second_checks.py).
Everything is exact (closed forms, exact enumeration, exact dynamic programming) except
block 9, which contains one seeded simulation beside an exact value, and the seeded random
instances on which blocks 5 (part (iii)), 7 and 10 test an inequality or an identity exactly.

  block 1   Section 9.1 of the note: every number of the budget table and of the sentences after it
  block 2   Theorem N8 and "What survives": the constants (findings N3, N11a)
  block 3   Proposition 6.4 (additive work): the bound against the protocol that asks distinct inputs
  block 4   Example 3.3a: exact values for several choices of the masks and of the seed
  block 5   Remark 3.2a: the normalising constant, the numbers of (i) and (ii), a test of (iii)
  block 6   Corollary 1.12, the example after it: the error as a function of n, without sampling (finding N7)
  block 7   The price of I1 (finding N5): when no member is closer than the unpatched one
  block 8   Examples 2.3 and 3.3 (the numbers of the caveats) and Proposition 2.5(d)
  block 9   Remark 6.6: a chain and batches, one strategy computed exactly and simulated
  block 10  Proposition 1.9a on random episodic scaffolds
  block 11  Example 3.2b: the last mixture on a chain

Usage: python3 assumptions_editor_second.py
"""
import itertools
import math
import random

LN2 = math.log(2.0)


def binom_pmf(n, k, p):
    if p <= 0.0:
        return 1.0 if k == 0 else 0.0
    if p >= 1.0:
        return 1.0 if k == n else 0.0
    return math.exp(math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)
                    + k * math.log(p) + (n - k) * math.log1p(-p))


# ---------------------------------------------------------------------------------------------
def block1():
    print("== block 1: Section 9.1 of the note")
    th = de = 0.1
    print("  largest K with K ln 2/(theta delta) <= n, theta = delta = 0.1:")
    for label, n in (("a working life of 1e5 hours, an hour per answer", 1e5),
                     ("50 years, a year per answer", 50),
                     ("1e6 people for 2000 hours, an hour per answer", 2e9),
                     ("1e4 people for one year, a year per answer (proof file, Section 6.2)", 1e4),
                     ("20 sequential batches (proof file, Section 6.4)", 20)):
        print(f"    {label:70s} n = {n:<8g} K = {n * th * de / LN2:.4g} bits")
    n9 = 1e9 * LN2 / (th * de)
    print(f"  K = 1e9: n = K ln 2/(theta delta) = {n9:.4g} answers; at an hour per answer:"
          f" {n9 / 2000:.4g} years of 2000 hours, {n9 / 8765.82:.4g} calendar years")
    print(f"  not deterministic: n = K ln 2/(2 theta^2 delta^2) = {1e9 * LN2 / (2 * th**2 * de**2):.4g} for K = 1e9")
    m = math.log(20) / (th * de)
    print(f"  certificate at confidence 0.95: ln 20/(theta delta) = {m:.2f}, so {math.ceil(m)} answers;"
          f" at a year per answer {math.ceil(m)} human-years, more than one working life of 50 years")
    print("  the formulas: failure <= delta0 + beta/(k+1) with k+1 >= theta L;")
    for K, n in ((30, 2080), (1000, 69315)):
        beta_over_L_det = K * LN2 / n
        print(f"    K = {K}, n = {n}: deterministic excess K ln2/(theta n) = {beta_over_L_det / th:.4f}")
    for K in (30, 1000):
        n = K * LN2 / (2 * th**2 * de**2)
        print(f"    K = {K}, n = K ln2/(2 theta^2 delta^2) = {n:.4g}: excess sqrt(K ln2/(2n))/theta ="
              f" {math.sqrt(K * LN2 / (2 * n)) / th:.4f}")


# ---------------------------------------------------------------------------------------------
def block2():
    print("== block 2: Theorem N8 and the sentence of 'What survives' on N2b")
    print("  N8 (Theorem 6.1(3)): p = 1-(1-1/N)^g against g/N for g distinct cells, N = g/(2 delta):")
    worst = 0.0
    for g in range(1, 60):
        for de in (0.001, 0.01, 0.02, 0.05, 0.09, 0.099):
            N = g / (2 * de)
            p_rep = 1 - (1 - 1 / N) ** g
            p_dis = g / N
            # the proof uses p >= 2 delta (1 - delta) and delta/p <= 1/2 + delta
            assert p_rep >= 2 * de * (1 - de) - 1e-15 and p_dis >= p_rep - 1e-15
            assert de / p_rep <= 0.5 + de + 1e-12
            # n >= (m_b N/2)(1 - 2g/N - delta/p)  >=  (1 - 10 delta) m_b g/(8 delta), per block (m_b = 1)
            lhs = (N / 2) * (1 - 2 * g / N - de / p_rep)
            rhs = (1 - 10 * de) * g / (8 * de)
            worst = max(worst, rhs / lhs if lhs > 0 else 0.0)
            assert lhs >= rhs - 1e-9
    print(f"    grid of g <= 59 and six values of delta: the stated bound never exceeds the derived one"
          f" (largest ratio {worst:.4f}); with distinct cells p is larger, so the bound holds for both readings")
    print("  N8, sufficiency: ceil(L K ln2/((k+1) delta)) <= 2 g K ln2/delta + 1 with L = g(2k+1):")
    ok = True
    for g in (1, 2, 5, 17):
        for k in (0, 1, 3, 50):
            for de in (0.01, 0.05, 0.09):
                for d in (1, 7, 100):
                    N = g / (2 * de)
                    K = d * math.log2(N)
                    L = g * (2 * k + 1)
                    ok &= math.ceil(L * K * LN2 / ((k + 1) * de)) <= 2 * g * K * LN2 / de + 1
    print(f"    holds on the grid: {ok}")
    for g, de in ((5, 0.05), (10, 0.01)):
        c = (1 - 10 * de) * g / (8 * de * math.log2(g / (2 * de)))
        gap = 16 * LN2 * math.log2(g / (2 * de)) / (1 - 10 * de)
        print(f"    g = {g}, delta = {de}: n >= {c:.4f} K; ratio of the sufficient to the necessary number <= {gap:.1f}")
    print("  'What survives': for delta <= 1/20 and N = L/(2 delta) >= 10,")
    print("  (1-10 delta) K L/(8 delta log2(L/(2 delta))) >= K L/(16 delta log2(L/delta)):")
    worst = float("inf")
    for L in list(range(1, 200)) + [10**3, 10**6]:
        for i in range(1, 501):
            de = 0.05 * i / 500
            a = (1 - 10 * de) / (8 * math.log2(L / (2 * de)))
            b = 1 / (16 * math.log2(L / de))
            worst = min(worst, a / b)
    print(f"    smallest ratio of the two sides over L in 1..199, 1e3, 1e6 and 500 values of delta in (0, 1/20]: {worst:.4f} (>= 1 needed)")


# ---------------------------------------------------------------------------------------------
def block3():
    print("== block 3: Proposition 6.4 (additive work)")
    print("  class: all functions [K] -> {0,1}; L calls at independent uniform inputs; good run: at most m wrong answers.")
    print("  protocol D_a: ask a distinct inputs, answer them correctly and every other call by a fair coin;")
    print("  then the number of wrong answers is Bin(L, (K-a)/(2K)) for every member.")
    print("     K     L    m  delta | bound K(1-2m/L-2delta) | least a with failure <= delta | failure at a = ceil(bound)-1")
    for K, L, m, de in ((20, 20, 2, 0.10), (200, 100, 10, 0.10), (200, 100, 10, 0.01), (400, 1000, 100, 0.05),
                        (83, 50, 5, 0.10), (1000, 10, 1, 0.10)):
        bound = K * (1 - 2 * m / L - 2 * de)

        def fail(a):
            p = (K - a) / (2 * K)
            return 1.0 - sum(binom_pmf(L, j, p) for j in range(0, m + 1))
        least = next(a for a in range(0, K + 1) if fail(a) <= de)
        below = math.ceil(bound) - 1
        print(f"  {K:5d} {L:5d} {m:4d}  {de:5.2f} | {bound:22.1f} | {least:29d} | {fail(max(below, 0)):.4f}")
        assert least >= bound - 1e-9
        # the inequality of the proof for this protocol: E[wrong] = L (K-a)/(2K) <= m + delta L at a = least
        assert L * (K - least) / (2 * K) <= m + de * L + 1e-9
    print("  (every row: the least number of questions of D_a is at least the bound, as the proposition requires")
    print("   of every protocol; with one question fewer than the bound the failure of D_a exceeds delta)")
    print("  theta = delta = 0.1: the factor 1 - 2 theta - 2 delta = 0.6; 50 answers serve K <= 50/0.6 ="
          f" {50 / 0.6:.1f} bits")
    # an exhaustive check of the averaging step on a tiny instance: all deterministic non-adaptive question sets
    # and the best deployed answerer; K = 4, L = 3, m = 0.
    K, L, m = 4, 3, 0
    print(f"  exhaustive, K = {K}, L = {L}, m = {m}: for each set S of asked inputs, the largest probability of a good run")
    print("  that a deployed answerer can have on average over the 16 functions, against 1 - [L(K-|S|)/(2K) - m]/(L - m):")
    for a in range(0, K + 1):
        # best answerer: correct on S; outside S a fixed guess per input (a guess per call is no better on average)
        # average over f of Pr[no wrong answer] = E over the run of 2^(-number of distinct unasked inputs in the run)
        good = 0.0
        for run in itertools.product(range(K), repeat=L):
            unasked = {x for x in run if x >= a}
            good += 0.5 ** len(unasked)
        good /= K ** L
        # from the proof: E[wrong] >= L(K-a)/(2K), and E[wrong] <= m good + L (1 - good),
        # so good <= 1 - (L(K-a)/(2K) - m)/(L - m)
        cap = 1 - (L * (K - a) / (2 * K) - m) / (L - m)
        print(f"    |S| = {a}: average probability of a good run {good:.4f};  the proof's cap {min(cap, 1):.4f}")
        assert good <= cap + 1e-12


# ---------------------------------------------------------------------------------------------
def block4():
    print("== block 4: Example 3.3a (rehearsal inputs from a generator with a seed of 3 bits)")

    def parity(v):
        return bin(v).count("1") & 1

    def values(masks, s):
        A = [[x for x in range(64) if parity(x & mk) == 0] for mk in masks]
        assert all(len(a) == 32 for a in A)
        inter = {len(set(A[i]) & set(A[j])) for i in range(8) for j in range(8) if i != j}

        def chain(pool, ids):
            # exact law of the set of unrefuted g_sigma, sigma in ids; a question at x keeps g_sigma iff x in A_sigma
            keep = []
            for x in pool:
                bits = 0
                for pos, g in enumerate(ids):
                    if parity(x & masks[g]) == 0:
                        bits |= 1 << pos
                keep.append(bits)
            law = {(1 << len(ids)) - 1: 1.0}
            out, acc = {}, 0.0
            extra = 8 - len(ids)            # the seed's own function, never refuted under the generator
            for t in range(1, 1001):
                err = 0.0
                for st, pr in law.items():
                    a = bin(st).count("1") + extra
                    err += pr * (a / 32.0) / (0.5 + a / 16.0)
                acc += err
                if t in (10, 100, 1000):
                    out[t] = acc / t
                new = {}
                w = 1.0 / len(pool)
                for st, pr in law.items():
                    for kb in keep:
                        new[st & kb] = new.get(st & kb, 0.0) + pr * w
                law = new
            return out
        gen = chain(A[s], [g for g in range(8) if g != s])
        fresh = chain(list(range(64)), list(range(8)))
        return inter, gen, fresh

    print("  floor (1/2)/(2^k+1) = 1/18 = %.5f; R1 would give K ln2/n = %.4f, %.4f, %.4f for n = 10, 100, 1000"
          % (1 / 18, LN2 / 10, LN2 / 100, LN2 / 1000))
    for masks in ([1, 2, 4, 8, 16, 32, 3, 5], [1, 2, 4, 8, 16, 32, 3, 12], [1, 2, 3, 4, 5, 6, 7, 8], [3, 5, 9, 17, 33, 6, 10, 63]):
        seen = {}
        for s in range(8):
            inter, gen, fresh = values(masks, s)
            assert inter == {16}
            assert all(v >= 1 / 18 - 1e-12 for v in gen.values())
            key = tuple(round(gen[n], 5) for n in (10, 100, 1000))
            seen.setdefault(key, []).append(s)
        print(f"  masks {masks}: pairwise intersections all 16;")
        for key, ss in seen.items():
            print(f"    seed index in {ss}: generator {key[0]:.5f}, {key[1]:.5f}, {key[2]:.5f}")
        print(f"    fresh inputs: {fresh[10]:.5f}, {fresh[100]:.5f}, {fresh[1000]:.5f}")


# ---------------------------------------------------------------------------------------------
def block5():
    print("== block 5: Remark 3.2a")
    N = 1024
    lg = math.log2(2 * N)              # 11 bits per recorded question
    S = N * math.log1p(1 / (2 * N))    # ln of sum over A of (2N)^(-|A|) = ln (1 + 1/(2N))^N
    print(f"  (i) N = {N}: the weights (2N)^(-|A|) sum to (1+1/(2N))^N = {math.exp(S):.6f}; with the constant")
    print("      c = (1 - 2^-K)/(1+1/(2N))^N the class has total weight 1 (the member A = X, which equals f, counted twice")
    print(f"      with weight c (2N)^-N = 2^{-11 * N + math.log2(math.exp(-S)):.0f}, negligible)")

    def p_wrong(K, s):
        # log2 of the weight of the tables consistent with s distinct questions answered 0:
        # c (2N)^-s (1+1/(2N))^(N-s); those that answer 1 at a given unasked x: c (2N)^-s (1+1/(2N))^(N-s-1)
        lc = math.log2(1 - 2.0 ** (-K)) - S / LN2
        l_all = lc - lg * s + (N - s) * math.log2(1 + 1 / (2 * N))
        l_one = lc - lg * s + (N - s - 1) * math.log2(1 + 1 / (2 * N))
        # ratio to the human's weight 2^-K
        r_all = 2.0 ** (l_all + K) if l_all + K < 1000 else float("inf")
        r_one = 2.0 ** (l_one + K) if l_one + K < 1000 else float("inf")
        if r_all == float("inf"):
            return 2.0 ** (l_one - l_all)
        return r_one / (1.0 + r_all)
    for K, ss in ((100, (8, 9, 10, 11)), (1000, (81, 90, 91, 92, 93, 100, 101))):
        print(f"      K = {K}: " + "; ".join(f"s = {s}: {p_wrong(K, s):.4g}" for s in ss))
        first = next(s for s in range(0, N) if all(p_wrong(K, t) < 1e-4 for t in range(s, min(N, s + 400))))
        print(f"        below 1e-4 from s = {first} on")
    Z, n = 2 ** 20, 1000
    l2 = (math.lgamma(Z + 1) - math.lgamma(n + 1) - math.lgamma(Z - n + 1)) / LN2
    pd = math.exp(sum(math.log1p(-i / Z) for i in range(n)))
    print(f"  (ii) log2 C(2^20, 1000) = {l2:.1f}; Pr[1000 uniform inputs are distinct] = {pd:.4f};"
          f" K ln2/n at K = 11500: {11500 * LN2 / 1000:.2f}")
    # (iii) on a small instance: E[w(nu_D) nu_D(D)/P(D)] <= max_D c(D), exact
    rnd = random.Random(5)
    worst = -1.0
    for _ in range(200):
        nx, n_q = rnd.randint(2, 4), rnd.randint(1, 3)
        P = [rnd.uniform(0.05, 0.95) for _ in range(nx)]          # P(1|x)
        # a protocol whose question may depend on the earlier pairs: a random distribution over inputs per history
        qdist = {}

        def q(hist):
            if hist not in qdist:
                v = [rnd.random() for _ in range(nx)]
                sv = sum(v)
                qdist[hist] = [u / sv for u in v]
            return qdist[hist]
        datasets = []

        def rec(hist, pc, pp):
            if len(hist) == n_q:
                datasets.append((hist, pc, pp))
                return
            for x in range(nx):
                for y in (0, 1):
                    rec(hist + ((x, y),), pc * q(hist)[x], pp * (P[x] if y else 1 - P[x]))
        rec((), 1.0, 1.0)
        # an injective family D -> nu_D with weights summing to at most 1, and any likelihoods nu_D(D) <= 1
        ws = [rnd.random() for _ in datasets]
        tot = sum(ws) / rnd.uniform(0.3, 1.0)
        lhs = sum(pc * pp * (w / tot) * rnd.uniform(0.0, 1.0) / pp for (h, pc, pp), w in zip(datasets, ws))
        cmax = max(pc for (h, pc, pp) in datasets)
        worst = max(worst, lhs - cmax)
    print(f"  (iii) 200 random small protocols: largest value of E[w(nu_D) nu_D(D)/P(D)] - max_D c(D) = {worst:.3e} (<= 0 needed)")


# ---------------------------------------------------------------------------------------------
def block6():
    print("== block 6: the example after Corollary 1.12, without sampling")
    print("  one call per run at one input; the human of round t answers 1 with probability p0 + 0.0002 t;")
    print("  class: Bernoulli(q), q = 0.05, 0.10, ..., 0.95, equal weights; T uniform on 1..n;")
    print("  E|M^(T)(1) - P_1(1)| and E|M^(T)(1) - P_T(1)|, by dynamic programming over the number of ones:")
    grid = [0.05 * i for i in range(1, 20)]
    lq = [math.log(q) for q in grid]
    l1q = [math.log(1 - q) for q in grid]
    gam = 2e-4
    nmax = 2600
    want = (1, 2, 5, 10, 30, 100, 200, 300, 400, 600, 1000, 2000, 2600)
    for p0 in (0.5, 0.37):
        # law of the number of ones among the answers of rounds 1..T-1 (Poisson binomial)
        law = [1.0]
        acc1 = accT = 0.0
        every = {}
        for T in range(1, nmax + 1):
            k = T - 1
            e1 = eT = 0.0
            for ones, pr in enumerate(law):
                if pr < 1e-18:
                    continue
                ll = [ones * a + (k - ones) * b for a, b in zip(lq, l1q)]
                mx = max(ll)
                wts = [math.exp(v - mx) for v in ll]
                mix = sum(w * q for w, q in zip(wts, grid)) / sum(wts)
                e1 += pr * abs(mix - (p0 + gam))
                eT += pr * abs(mix - (p0 + gam * T))
            acc1 += e1
            accT += eT
            every[T] = (acc1 / T, accT / T)
            pt = p0 + gam * T
            new = [0.0] * (len(law) + 1)
            for ones, pr in enumerate(law):
                new[ones] += pr * (1 - pt)
                new[ones + 1] += pr * pt
            law = new
        print(f"  p0 = {p0}:")
        for n in want:
            print(f"    n = {n:5d}: to the human of round 1: {every[n][0]:.4f};  to the human of round T: {every[n][1]:.4f}")
        lo = 10
        b1 = min(range(lo, nmax + 1), key=lambda n: every[n][0])
        bT = min(range(lo, nmax + 1), key=lambda n: every[n][1])
        inc = all(every[n + 1][0] >= every[n][0] for n in range(b1, nmax)) and \
            all(every[n + 1][1] >= every[n][1] for n in range(bT, nmax))
        dec = all(every[n + 1][0] <= every[n][0] for n in range(lo, b1))
        print(f"    among n >= {lo}: the first column is smallest at n = {b1} ({every[b1][0]:.4f}), the second at n = {bT}"
              f" ({every[bT][1]:.4f}); the first column decreases from n = {lo} to there: {dec};"
              f" both increase from there to n = {nmax}: {inc}")
    print("  (for p0 = 0.5 the mean of the prior is the human's first parameter, so the values at n < 10 are small;")
    print("   with p0 = 0.37 this accident is absent: the values at n < 10 are about 0.13, the error of the prior,")
    print("   and at n = 2600 the error is larger than without any question)")
    K0 = math.log2(19)
    print("  Corollary 1.12 for this drift (gamma_t = gamma t): the part K0 ln2/n + gamma (n+1)(1+ln(s/eta))/2 of the bound")
    for eta in (0.1, 0.01):
        nstar = math.sqrt(2 * K0 * LN2 / (gam * (1 + math.log(2 / eta))))
        print(f"    eta = {eta}: smallest at n* = {nstar:.0f}, and increasing afterwards")


# ---------------------------------------------------------------------------------------------
def block7():
    print("== block 7: the price of I1 (Proposition 7.5(a)) for a patched isolated member")
    print("  X = [12]; a run is L = 2 calls at independent uniform inputs; D(g, g') = Pr[the two runs differ];")
    print("  random classes whose members are pairwise at distance 0 or >= delta; the human is a member h0 patched on a set Q.")
    rnd = random.Random(11)
    nx, L = 12, 2

    def dist(g, h):
        diff = sum(1 for x in range(nx) if g[x] != h[x])
        return 1 - (1 - diff / nx) ** L
    viol_half = 0
    closer_seen = 0
    trials = 0
    while trials < 20000:
        members = [tuple(rnd.randint(0, 1) for _ in range(nx)) for _ in range(rnd.randint(2, 6))]
        ds = [dist(g, h) for g, h in itertools.combinations(members, 2) if g != h]
        if not ds:
            continue
        delta = min(ds)
        h0 = members[0]
        Q = rnd.sample(range(nx), rnd.randint(1, nx))
        f = tuple((1 - h0[x]) if x in Q else h0[x] for x in range(nx))
        eps = dist(f, h0)
        eps_dag = min(dist(f, h) for h in members)
        trials += 1
        if eps <= delta / 2 and eps_dag < eps - 1e-12:
            viol_half += 1
        if eps_dag < eps - 1e-12:
            closer_seen += 1
    print(f"  {trials} random cases: a member closer than h0 occurred in {closer_seen} cases (all with eps > delta/2);")
    print(f"  cases with eps <= delta/2 and a closer member: {viol_half} (the triangle inequality for D excludes them)")


# ---------------------------------------------------------------------------------------------
def block8():
    print("== block 8: the numbers of the caveats and of tests 2 and 5")
    prod = 1.0
    for k in range(0, 400):
        prod *= 2.0 / (2.0 + 1.0 / (1.0 + 2.0 ** k))
    print(f"  Example 2.3: Pr[nu1 is never refuted] = {prod:.6f}; refuted with probability {1 - prod:.6f};")
    print(f"    afterwards the imitator is nu2, whose run differs from the human system's with probability 1/2;"
          f" in the limit the run differs with probability {(1 - prod) / 2:.4f}")
    # exact recursion for finite n
    for n in (20, 100):
        alive, dead = {0: 1.0}, 0.0
        for _ in range(n):
            new = {}
            for k, pr in alive.items():
                om = 1.0 / (1.0 + 2.0 ** k)
                dead += pr * om / 4
                new[k + 1] = new.get(k + 1, 0.0) + pr / 2
                new[k] = new.get(k, 0.0) + pr * (0.5 - om / 4)
            alive = new
        print(f"    after n = {n} rounds: refuted with probability {dead:.6f}")
    print("  Example 3.3 (k = 3, L = 4): expected unfaithful calls of the run of M^(T)")
    k, L = 3, 4
    S = 2 ** k
    for n in (100, 1000):
        acc_seed = acc_fresh = 0.0
        for t in range(1, n + 1):
            pr = L ** (-(t - 1.0))
            es = sum(binom_pmf(S - 1, j, pr) * (1 + j) / (S + 1 + j) for j in range(0, S))
            ef = sum(binom_pmf(S, j, pr) * j / (S + j) for j in range(0, S + 1))
            acc_seed += (L - 1) * es
            acc_fresh += (L - 1) * ef
        print(f"    n = {n}: seeded index {acc_seed / n:.4f} (floor (L-1)/(2^k+1) = {(L - 1) / (S + 1):.4f});"
              f" fresh index {acc_fresh / n:.4f}; R1 bound L ln2/n = {L * LN2 / n:.4f}")
    print("  Proposition 2.5(d): the exact imitator of a human who gives a second answer with probability e")
    for e in (0.0, 0.001, 0.01, 0.1):
        rho = 2 * e * (1 - e)
        print(f"    e = {e}: mismatch rate {rho:.6f}; no mismatch in 300 rounds with probability {(1 - rho) ** 300:.4g}")


# ---------------------------------------------------------------------------------------------
def block9():
    print("== block 9: Remark 6.6 (a chain needs as many batches as it has links)")
    print("  strings of l bits; batches of b questions fixed before the answers of the batch; s batches.")
    print("  strategy G: every batch asks the known list (which reveals the next string) and b-1 lists")
    print("  'known list + a guess of the next string + a guess of the one after', guesses never repeated.")
    print("  A batch reveals two strings instead of one exactly if one of its guesses of the next string is right;")
    print("  Pr[some batch among s does] against the bound s b/(2^l - s b):")
    rnd = random.Random(3)
    for l, b, s in ((4, 3, 2), (5, 4, 3), (6, 4, 6), (8, 8, 8)):
        M = 2 ** l
        # exact for strategy G: in every batch the b-1 guesses of the next string are distinct and fresh,
        # so a batch is lucky with probability (b-1)/M, independently
        exact = 1 - (1 - (b - 1) / M) ** s
        # simulation of the same strategy as a check of the bookkeeping
        hits, trials = 0, 200000
        for _ in range(trials):
            lucky = False
            for _batch in range(s):
                nxt = rnd.randrange(M)
                guesses = rnd.sample(range(M), b - 1)
                if nxt in guesses:
                    lucky = True
                    break
            hits += lucky
        bound = s * b / (M - s * b)
        print(f"    l = {l}, b = {b}, s = {s}: exact {exact:.4f}; simulated {hits / trials:.4f}; bound {bound:.4f}")
        assert exact <= bound


# ---------------------------------------------------------------------------------------------
def block10():
    print("== block 10: Proposition 1.9a on random episodic scaffolds (binary answers, exact enumeration)")
    rnd = random.Random(2026)
    worst_id = 0.0
    worst_sub = -1.0
    worst_3 = -1.0
    worst_two = -1.0
    count = 0
    for _ in range(300):
        depth = rnd.randint(3, 6)
        maxep = rnd.randint(2, 4)
        # the scaffold: for every history (tuple of answers) either stop or name the episode of the next call;
        # episode numbers are given in order of first appearance and may depend on the history
        plan = {}

        def node(hist, used):
            if len(hist) == depth or (len(hist) >= 2 and rnd.random() < 0.15):
                plan[hist] = None
                return
            choices = list(range(1, min(used + 1, maxep) + 1))
            e = rnd.choice(choices)
            plan[hist] = (e, rnd.uniform(0.05, 0.95), rnd.uniform(0.05, 0.95))   # episode, C(1|.), P(1|.)
            for y in (0, 1):
                node(hist + (y,), max(used, e))
        node((), 0)
        eps = sorted({v[0] for v in plan.values() if v})
        Le = len(eps)
        runs = [h for h, v in plan.items() if v is None]

        def dens(Sset):
            out = []
            for r in runs:
                pr = 1.0
                for j in range(len(r)):
                    e, c1, p1 = plan[r[:j]]
                    a1 = p1 if e in Sset else c1
                    pr *= a1 if r[j] == 1 else 1 - a1
                out.append(pr)
            assert abs(sum(out) - 1) < 1e-9
            return out
        subsets = [frozenset(c) for r_ in range(Le + 1) for c in itertools.combinations(eps, r_)]
        dn = {S: dens(S) for S in subsets}

        def h2(a, b):
            return 1 - sum(math.sqrt(x * y) for x, y in zip(dn[a], dn[b]))

        def kl(a, b):
            return sum(x * math.log(x / y) for x, y in zip(dn[a], dn[b]) if x > 0)
        for S in subsets:
            for T in subsets:
                worst_id = max(worst_id, abs(h2(S, T) - h2(S & T, S | T)))
        empty, full = frozenset(), frozenset(eps)
        lhs = math.sqrt(max(h2(empty, full), 0.0))
        rhs = sum(math.sqrt(max(h2(empty, frozenset([i])), 0.0)) for i in eps)
        worst_sub = max(worst_sub, lhs - rhs)
        skl = sum(kl(frozenset([i]), empty) for i in eps)
        worst_3 = max(worst_3, h2(empty, full) - (Le / 2) * skl)
        if Le == 2:
            worst_two = max(worst_two, h2(empty, full) - skl)
        count += 1
    print(f"  {count} scaffolds of depth 3 to 6 with 2 to 4 episodes, kernels arbitrary functions of the history:")
    print(f"    largest |H2(Q_S, Q_T) - H2(Q_S&T, Q_S|T)| over all pairs of sets: {worst_id:.2e}")
    print(f"    largest sqrt(H2(Q_C, Q_P)) - sum_i sqrt(H2(Q_C, Q_C[i<-P])): {worst_sub:.3e} (<= 0 claimed)")
    print(f"    largest H2(Q_C, Q_P) - (L_e/2) sum_i KL_i: {worst_3:.3e} (<= 0 claimed);"
          f" for two episodes, largest H2 - sum_i KL_i: {worst_two:.3e} (<= 0 claimed)")


# ---------------------------------------------------------------------------------------------
def block11():
    print("== block 11: Example 3.2b (the last mixture on a chain of L links, limiting class)")
    for L in (10, 40, 160):
        best, arg = 0.0, None
        for n in range(L - 1, 4 * L * L):
            pr = binom_pmf(n, L - 1, 1.0 / L)
            ratio = pr * (n + 1) / L
            if ratio > best:
                best, arg = ratio, n
        print(f"    L = {L:3d}: largest ratio to L/(n+1) is {best:.3f} at n = {arg}; 0.4 sqrt(L) = {0.4 * math.sqrt(L):.2f}")


if __name__ == "__main__":
    for blk in (block1, block2, block3, block4, block5, block6, block7, block8, block9, block10, block11):
        blk()
        print()
