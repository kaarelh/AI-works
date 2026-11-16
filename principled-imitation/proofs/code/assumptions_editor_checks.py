"""Editor's checks for proofs/assumptions.md (key: assumptions).

Independent recomputation of the numbers that the editor took over from the two verification
reports (verification/assumptions-check.md, verification/assumptions-attack.md) and of
the corrections made to the prover's file.  No code is shared with the prover's or the
verifiers' scripts.  Everything is exact (closed forms, exact enumeration or exact dynamic
programming) except block 9, which is a seeded random test of an identity.

  block 1   the certificate of Proposition 2.5 for a human who is not deterministic (finding M1)
  block 2   Theorem 3.2(a) is false "for every property at once" (finding M2)
  block 3   Example 3.3a: rehearsal runs from a generator with a short seed (finding M3)
  block 4   Proposition 6.4: additive work; the random round against a late round (m1, m2)
  block 5   Remark 3.2a: the table of the data against the human (finding m5; check, test 3)
  block 6   Section 6.2: the budget in both conventions for a year; Theorem 6.1 in numbers
  block 7   Examples 3.5 and 7.6 (the conditions added); Example 2.3 with unequal weights
  block 8   Example 3.2b: the guard statement for the last mixture on a chain (check, Example C)
  block 9   Proposition 1.9a: cut and paste for episodes, and subadditivity of sqrt(H^2)
  block 10  break-even (objection O22)

Usage: python3 assumptions_editor_checks.py
"""
import itertools
import math
import random

LN2 = math.log(2.0)


def binom_tail_gt(L, p, m):
    """Pr[Bin(L, p) > m], exact summation."""
    if p <= 0.0:
        return 0.0
    if p >= 1.0:
        return 1.0 if L > m else 0.0
    s = 0.0
    for j in range(0, m + 1):
        s += math.exp(math.lgamma(L + 1) - math.lgamma(j + 1) - math.lgamma(L - j + 1)
                      + j * math.log(p) + (L - j) * math.log1p(-p))
    return max(0.0, 1.0 - s)


# ---------------------------------------------------------------------------------------------
def block1():
    print("== block 1: the certificate (Proposition 2.5) and a human who is not deterministic")
    print("  human: answers f(x) with probability 1 - e, one other answer with probability e;")
    print("  exact imitator A = P: mismatch rate rho' = 2e(1-e); Pr[no mismatch in m rounds] = (1-rho')^m")
    m = math.ceil(math.log(20.0) / (0.1 * 0.1))
    print(f"  m = ceil(ln 20/(theta delta)) = {m} for theta = delta = 0.1, confidence 95%")
    for e in (0.0, 0.001, 0.01, 0.1):
        rho = 2 * e * (1 - e)
        print(f"    e = {e:<6}: rho' = {rho:.6f};  Pr[certificate is issued] = {(1 - rho) ** m:.4g}")
    m2 = math.ceil(math.log(20.0) / (0.01 * 0.01))
    print(f"  m = {m2} for theta = delta = 0.01:")
    for c in (0.999, 0.99):
        print(f"    probability that two answers agree = {c}: Pr[issued] = {c ** m2:.4g}")
    print("  check of rho' >= s/2 with s = 1 - sum_y P(y)^2 (used for 'issued with probability <= exp(-m s/2)'):")
    rnd = random.Random(1)
    worst = 1e9
    for _ in range(100000):
        k = rnd.randint(2, 7)
        p = [rnd.random() ** 3 for _ in range(k)]
        a = [rnd.random() ** 3 for _ in range(k)]
        sp, sa = sum(p), sum(a)
        p = [u / sp for u in p]
        a = [u / sa for u in a]
        mism = 1 - sum(x * y for x, y in zip(a, p))
        s = 1 - sum(y * y for y in p)
        tv = 0.5 * sum(abs(x - y) for x, y in zip(a, p))
        worst = min(worst, mism - s / 2, mism - tv, tv + s - mism)
    print(f"    100000 random pairs: min of (mismatch - s/2), (mismatch - TV), (TV + s - mismatch) = {worst:.3e}")


# ---------------------------------------------------------------------------------------------
def block2():
    print("== block 2: Theorem 3.2(a) holds for each fixed Q, not for all Q at once")
    print("  X = [N], L = 1, input uniform; event: the input of round T was never asked before")
    for N, n in ((50, 10), (200, 20), (1000, 50)):
        pr = sum((1 - 1 / N) ** (t - 1) for t in range(1, n + 1)) / n
        print(f"    N = {N:5d}, n = {n:3d}: probability {pr:.4f};  L/n = {1 / n:.4f}")


# ---------------------------------------------------------------------------------------------
def block3():
    print("== block 3: Example 3.3a, rehearsal inputs from a generator with a seed of k = 3 bits")
    print("  X = {0..63}; L = 1; human f = 0 (weight 1/2); for each of 8 seeds sigma the function")
    print("  g_sigma = 0 on A_sigma, 1 elsewhere (weight 1/16); A_sigma = {x : parity(x & mask_sigma) = 0},")
    print("  eight distinct nonzero masks, so |A_sigma| = 32 and |A_sigma & A_s| = 16 for sigma != s.")
    masks = [1, 2, 4, 8, 16, 32, 3, 5]
    A = [frozenset(x for x in range(64) if bin(x & mk).count("1") % 2 == 0) for mk in masks]
    assert all(len(a) == 32 for a in A)
    s = 0
    others = [i for i in range(8) if i != s]

    def run(pool_inputs, s_can_die):
        """Exact law of the set of unrefuted g's; one question per round, uniform on pool_inputs."""
        ids = list(range(8)) if s_can_die else others
        idx = {g: i for i, g in enumerate(ids)}
        full = (1 << len(ids)) - 1
        # for each input: the mask of functions that survive a question at it (g survives iff x in A_g)
        surv = []
        for x in pool_inputs:
            mk = 0
            for g in ids:
                if x in A[g]:
                    mk |= 1 << idx[g]
            surv.append(mk)
        dist = {full: 1.0}
        out = {}
        tmax = 1000
        want = (10, 100, 1000)
        acc = 0.0
        for t in range(1, tmax + 1):
            # deployed error of the mixture of round t (before the question of round t)
            err = 0.0
            for state, pr in dist.items():
                alive = bin(state).count("1") + (0 if s_can_die else 1)
                # each alive g answers 1 at a fresh uniform input with probability 1/2
                err += pr * (alive / 32.0) / (0.5 + alive / 16.0)
            acc += err
            if t in want:
                out[t] = acc / t
            nd = {}
            w = 1.0 / len(surv)
            for state, pr in dist.items():
                for mk in surv:
                    ns = state & mk
                    nd[ns] = nd.get(ns, 0.0) + pr * w
            dist = nd
        return out

    gen = run(sorted(A[s]), s_can_die=False)
    fresh = run(list(range(64)), s_can_die=True)
    for n in (10, 100, 1000):
        print(f"    n = {n:5d}: Pr[deployed answer of M^(T) is wrong] = {gen[n]:.5f} with the generator;"
              f"  {fresh[n]:.5f} with fresh inputs;  R1 bound K ln 2/n = {LN2 / n:.5f}")
    print(f"  floor with the generator: (1/2)/(2^k + 1) = {0.5 / 9:.5f}  (g_s is never refuted)")


# ---------------------------------------------------------------------------------------------
def occupancy_expectations(K, tmax, g):
    """E[g(a_t)] for t = 0..tmax, a_t = number of distinct values among t uniform draws from [K]."""
    dist = [0.0] * (K + 1)
    dist[0] = 1.0
    out = []
    for t in range(tmax + 1):
        out.append(sum(dist[a] * g[a] for a in range(K + 1) if dist[a] > 0.0))
        nd = [0.0] * (K + 1)
        for a in range(K + 1):
            if dist[a] == 0.0:
                continue
            nd[a] += dist[a] * a / K
            if a < K:
                nd[a + 1] += dist[a] * (K - a) / K
        dist = nd
    return out


def block4():
    print("== block 4: Proposition 6.4 (additive work) and the cost of the uniformly random round")
    print("  class: all 2^K functions [K] -> {0,1}; L calls at uniform inputs; good = at most m wrong answers")
    print("  lower bound for every protocol: n >= K (1 - 2m/L - 2 delta)")
    print("     K    L    m  delta | lower | distinct | R, T uniform | R, T in 2nd half | R, last | R3 bound")
    for K, L, m, delta in ((20, 20, 2, 0.10), (200, 100, 10, 0.10), (200, 100, 10, 0.01), (400, 1000, 100, 0.05)):
        g = [binom_tail_gt(L, (K - a) / (2.0 * K), m) for a in range(K + 1)]
        lower = K * (1 - 2 * m / L - 2 * delta)
        # best protocol of this kind: ask n distinct inputs, deploy the function seen, a fair coin elsewhere
        best = next(a for a in range(K + 1) if g[a] <= delta)
        tmax = 40000
        e = occupancy_expectations(K, tmax, g)       # e[t] = failure of the mixture after t questions
        pref = [0.0]
        for t in range(tmax + 1):
            pref.append(pref[-1] + e[t])              # pref[j] = sum_{t<j} e[t]
        # M^(T), T uniform on 1..n, uses t-1 answers: failure = (1/n) sum_{t=0}^{n-1} e[t]
        n_unif = next(n for n in range(1, tmax) if pref[n] / n <= delta)
        # T uniform on the last ceil(n/2) rounds
        def half(n):
            h = (n + 1) // 2
            return (pref[n] - pref[n - h]) / h
        n_half = next(n for n in range(1, tmax) if half(n) <= delta)
        n_last = next(n for n in range(0, tmax) if e[n] <= delta)
        r3 = L * K * LN2 / ((m + 1) * delta)
        print(f"   {K:4d} {L:4d} {m:4d}  {delta:4.2f} | {lower:5.0f} | {best:8d} | {n_unif:12d} | {n_half:16d} | {n_last:7d} | {r3:8.0f}")
    print(f"  with 50 answers, theta = m/L = 0.1 and delta = 0.1 the bound allows at most K = {50 / 0.6:.1f} bits")


# ---------------------------------------------------------------------------------------------
def block5():
    print("== block 5: the table of the data against the human (Remark 3.2a)")
    print("  X = [N], one call per run; human f = 0 with weight 2^-K; for every set A the member")
    print("  '0 on A, 1 elsewhere' with weight c (2N)^-|A|, c = (1 - 2^-K)/(1 + 1/(2N))^N;")
    print("  after s distinct questions: Pr[the mixture answers 1 at an input not yet asked]")
    for N, K, ss in ((1024, 100, (0, 8, 9, 11)), (1024, 1000, (0, 81, 90, 101)), (1 << 20, 1000, (0, 42, 47, 53))):
        b = math.log2(2 * N)
        logc = math.log1p(-2.0 ** (-K)) - N * math.log1p(1 / (2 * N))
        row = []
        for s in ss:
            log_tab_all = logc - s * math.log(2 * N) + (N - s) * math.log1p(1 / (2 * N))
            log_tab_one = logc - s * math.log(2 * N) + (N - s - 1) * math.log1p(1 / (2 * N))
            log_h = -K * LN2
            mx = max(log_tab_all, log_h)
            den = math.exp(log_tab_all - mx) + math.exp(log_h - mx)
            row.append(f"s = {s}: {math.exp(log_tab_one - mx) / den:.4f}")
        print(f"    N = {N}, K = {K}, b = log2(2N) = {b:.0f} bits, K/b = {K / b:.1f}:  " + ";  ".join(row))
    # the check report's worked case
    Z, n = 1 << 20, 1000
    log2C = (math.lgamma(Z + 1) - math.lgamma(n + 1) - math.lgamma(Z - n + 1)) / LN2
    distinct = math.exp(sum(math.log1p(-i / Z) for i in range(n)))
    print(f"  check report, test 3: log2 C(2^20, 1000) = {log2C:.1f}; Pr[1000 uniform inputs are distinct] = {distinct:.3f}")


# ---------------------------------------------------------------------------------------------
def block6():
    print("== block 6: the budget (Section 6.2)")
    cal, work = 8765.82, 2000.0
    print(f"  a calendar year has {cal} hours (the figure of the researcher's notes); a working year is taken as {work:.0f} hours")
    for K in (30, 1e3, 1e6, 1e9):
        n = K * LN2 / 0.01
        print(f"    K = {K:9.0e}: K ln 2/(theta delta) = {n:10.3e} answers at theta = delta = 0.1;"
              f" at one hour each: {n / cal:10.3e} calendar years of unbroken work = {n / work:10.3e} working years")
    print(f"    certificate, 300 answers at one hour each: {300 / 24:.1f} days of unbroken work = {300 / 8:.1f} working days of 8 hours")
    for label, n in (("one career of 10^5 working hours, one hour per answer", 1e5),
                     ("one career of 50 years, one year per answer", 50),
                     ("10^4 people for one year, one year per answer", 1e4),
                     ("10^6 people for one working year, one hour per answer", 2e9)):
        print(f"    {label}: n = {n:.0e}: K <= {n * 0.01 / LN2:.4g} bits at theta = delta = 0.1;"
              f" K <= {n * 0.25 / LN2:.4g} bits at theta = delta = 0.5")
    B, delta = 5, 0.05
    N = B / (2 * delta)
    per_block = (1 - 10 * delta) * B / (8 * delta)
    c = per_block / math.log2(N)
    print(f"  Theorem 6.1(3), B = {B}, delta = {delta}: N = {N:.0f}; n >= {per_block} m_b = {c:.6f} K")
    for n in (50, 1e4):
        mb = math.floor(n / per_block)
        print(f"    n = {n:.0f}: K <= {n / c:.1f} bits (in whole blocks: m_b <= {mb}, K <= {mb * math.log2(N):.1f})")
    for (mb, B, m, delta) in ((10, 5, 0, 0.05), (10, 5, 50, 0.05), (1000, 50, 5, 0.01)):
        N = B / (2 * delta)
        K = mb * math.log2(N)
        L = B * (2 * m + 1)
        lower = (1 - 10 * delta) * mb * B / (8 * delta)
        r3 = L * K * LN2 / ((m + 1) * delta)
        print(f"    m_b = {mb}, B = {B}, m = {m}, delta = {delta}: L = {L}, K = {K:.2f}, lower bound {lower:.4g},"
              f" R3 bound {r3:.4g}, ratio {r3 / lower:.1f};  16 ln2 log2(B/(2 delta))/(1-10 delta) = "
              f"{16 * LN2 * math.log2(N) / (1 - 10 * delta):.1f}")
    print(f"  Proposition 6.3, twenty sequential batches, theta = delta = 0.1: K <= {20 * 0.01 / LN2:.3f} bits")


# ---------------------------------------------------------------------------------------------
def block7():
    print("== block 7: Examples 3.5, 7.6 and 2.3")
    print("  Example 3.5 with the special guard: weights 1/2 (human), 0.49/(theta(theta+1)) (date guards), 0.01 (guard at theta0)")
    for n in (1, 10, 100, 10000):
        alone = 0.01 / (0.51 + 0.49 / (n + 1))
        # smallest total over d >= theta0 > n is at d = theta0 = n + 1
        d = n + 1
        tot = (0.49 * (1 / (n + 1) - 1 / (d + 1)) + 0.01) / (0.51 + 0.49 / (n + 1))
        print(f"    n = {n:5d}: special guard alone {alone:.4f};  all live guards, least over d >= theta0 > n: {tot:.4f}")
    lo = min((0.49 * (1 / (n + 1) - 1 / (n + 2)) + 0.01) / (0.51 + 0.49 / (n + 1)) for n in range(1, 200001))
    print(f"    least value of the second column over n = 1..200000: {lo:.5f}")
    print("  Example 3.5 without the special guard (weights 1/2 and (1/2)/(theta(theta+1))):")
    for n, d in ((100, 101), (100, 201), (100, 10 ** 9)):
        print(f"    n = {n}, d = {d}: {(1 / (n + 1) - 1 / (d + 1)) / (1 + 1 / (n + 1)):.3e}")
    q, L = 0.0098, 10
    print(f"    per-call mixture, q = {q}, L = {L}: Pr[at least one unfaithful call] = {1 - (1 - q) ** L:.3f}; Pr[all] = {q ** L:.1e}")
    print("  Example 7.6, N = 100: mixture over {0, 1, all needles} with weights 1/4, 1/4, 1/(2N) each; human = needle at x0")
    N = 100
    print(f"    before any question: Pr[wrong at x0] = {0.75 - 1 / (2 * N):.4f};"
          f" after one question elsewhere: {1 - 2 / (3 * N - 2):.4f} (> 1 - 2/N = {1 - 2 / N:.2f})")
    print(f"    human f = 0, after one question: a run fails with probability {(N - 1) / N * 2 / (3 * N - 2):.5f} (2/(3N) = {2 / (3 * N):.5f})")
    print("  Example 2.3 with w(nu1) = 2^-K1: Pr[nu1 is refuted] = 1 - prod_k 2/(2 + omega_k)")
    for K1 in (1, 2, 5, 10, 20):
        w1 = 2.0 ** (-K1)
        w2 = 1 - w1
        prod = 1.0
        for k in range(0, 400):
            om = w2 * 2.0 ** (-k) / (w1 + w2 * 2.0 ** (-k))
            prod *= 2 / (2 + om)
        print(f"    K1 = {K1:2d}: {1 - prod:.6f}   (lower bound 1 - (4/5)^K1 = {1 - 0.8 ** K1:.4f})")


# ---------------------------------------------------------------------------------------------
def block8():
    print("== block 8: Example 3.2b, the last mixture on a chain of L links")
    print("  each round learns the next link with probability 1/L; after L-1 links every run reaches x_L,")
    print("  which is asked with probability 1/L per round.  Pr[run of M^(n+1) meets x_L and no question")
    print("  lay in {x_L}] = Pr[Bin(n, 1/L) = L-1]; ratio to L/(n+1), maximised over n:")
    for L in (10, 40, 160):
        best, arg = 0.0, 0
        p = 1.0 / L
        for n in range(L - 1, 6 * L * L):
            lp = (math.lgamma(n + 1) - math.lgamma(L) - math.lgamma(n - L + 2)
                  + (L - 1) * math.log(p) + (n - L + 1) * math.log1p(-p))
            r = math.exp(lp) * (n + 1) / L
            if r > best:
                best, arg = r, n
        print(f"    L = {L:4d}: largest ratio {best:.2f} at n = {arg} (L^2 = {L * L});  0.4 sqrt(L) = {0.4 * math.sqrt(L):.2f}")
    print("  for the round T: sum over t of Pr[L-1 links learned and x_L not asked before round t] = L exactly (a geometric wait)")


# ---------------------------------------------------------------------------------------------
def block9():
    print("== block 9: Proposition 1.9a (cut and paste; sqrt(H^2) is subadditive over episodes)")
    rnd = random.Random(20261116)

    def make_scaffold(n_ep, n_calls):
        """A random episodic scaffold with binary answers: who speaks next is a function of the history."""
        table = {}

        def nxt(hist):
            # hist: tuple of (episode, answer); returns the episode of the next call or None
            if len(hist) >= n_calls:
                return None
            if hist not in table:
                # episodes are numbered in order of first appearance
                seen = sorted(set(e for e, _ in hist))
                opts = list(seen)
                if len(seen) < n_ep:
                    opts.append(len(seen) + 1)
                if len(hist) >= 2 and rnd.random() < 0.15:
                    table[hist] = None
                else:
                    table[hist] = rnd.choice(opts)
            return table[hist]
        return nxt

    def kernel():
        memo = {}

        def k(vis):
            if vis not in memo:
                memo[vis] = rnd.random() ** 2 * 0.98 + 0.01
            return memo[vis]          # probability of answer 1 at the visible history vis
        return k

    def law(nxt, C, P, S):
        out = {}

        def rec(hist, pr):
            e = nxt(hist)
            if e is None:
                out[hist] = out.get(hist, 0.0) + pr
                return
            # visible history of episode e: the positions and answers of its earlier calls and the
            # position of this call (the message is the position together with the global history
            # the scaffold chooses to show; here: the answers of the other episodes so far)
            vis = (e, hist)
            # make the kernel depend on the episode's own visible history only:
            own = tuple((i, a) for i, (ee, a) in enumerate(hist) if ee == e)
            msg = tuple(a for (ee, a) in hist if ee != e)   # the scaffold's message: what the others said
            vis = (own, msg, len(hist))
            k = P if e in S else C
            p1 = k(vis)
            rec(hist + ((e, 1),), pr * p1)
            rec(hist + ((e, 0),), pr * (1 - p1))
        rec((), 1.0)
        return out

    def hell2(a, b):
        keys = set(a) | set(b)
        return max(0.0, 1.0 - sum(math.sqrt(a.get(k, 0.0) * b.get(k, 0.0)) for k in keys))

    def kl(a, b):
        return sum(v * math.log(v / b[k]) for k, v in a.items() if v > 0)

    worst_id, worst_sub, worst_ratio, big2, big3 = 0.0, -1e9, 0.0, 0.0, 0.0
    for trial in range(300):
        n_ep = rnd.choice((2, 3))
        nxt = make_scaffold(n_ep, rnd.choice((3, 4, 5)))
        C, P = kernel(), kernel()
        eps = list(range(1, n_ep + 1))
        subsets = [frozenset(c) for r in range(n_ep + 1) for c in itertools.combinations(eps, r)]
        laws = {S: law(nxt, C, P, S) for S in subsets}
        for S in subsets:
            for T in subsets:
                worst_id = max(worst_id, abs(hell2(laws[S], laws[T]) - hell2(laws[S & T], laws[S | T])))
        full = frozenset(eps)
        d_full = math.sqrt(hell2(laws[frozenset()], laws[full]))
        d_sum = sum(math.sqrt(hell2(laws[frozenset()], laws[frozenset((i,))])) for i in eps)
        worst_sub = max(worst_sub, d_full - d_sum)
        if d_sum > 1e-12:
            worst_ratio = max(worst_ratio, d_full / d_sum)
        klsum = sum(kl(laws[frozenset((i,))], laws[frozenset()]) for i in eps)
        ratio = hell2(laws[frozenset()], laws[full]) / klsum if klsum > 0 else 0.0
        if n_ep == 2:
            big2 = max(big2, ratio)
        else:
            big3 = max(big3, ratio)
    print(f"  300 random scaffolds with 2 or 3 interleaved episodes and 3 to 5 calls, random samplers C, P:")
    print(f"    largest |H^2(Q_S, Q_T) - H^2(Q_S&T, Q_S|T)| over all pairs of sets = {worst_id:.2e}")
    print(f"    largest sqrt(H^2(Q_C, Q_P)) - sum_i sqrt(H^2(Q_C, Q_C[i<-P])) = {worst_sub:.3e} (must be <= 0 up to rounding;")
    print(f"      it is 0 when only one episode ever speaks); largest ratio of the two sides = {worst_ratio:.6f} (must be <= 1)")
    print(f"    largest H^2(Q_C, Q_P)/sum_i KL_i: {big2:.4f} with two episodes (bound 1), {big3:.4f} with three (bound 3/2)")


# ---------------------------------------------------------------------------------------------
def block10():
    print("== block 10: break-even for one run (objection O22), theta = delta = 0.1, certificate 300 answers")
    for K in (30, 1e3, 1e6, 1e9):
        print(f"    K = {K:9.0e}: rehearsal with R3 and the certificate costs {K * LN2 / 0.01 + 300:.3g} answers;"
              f" the human system costs L")


if __name__ == "__main__":
    for blk in (block1, block2, block3, block4, block5, block6, block7, block8, block9, block10):
        blk()
