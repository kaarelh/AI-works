"""Adversary's checks for research/prove-c/assumptions.md, part 3: the lower bound of
Section 6, the patch-free theorem of Section 7, the parts of A3, and the budget.

  A  Theorem 6.1(2),(3) against exactly optimal protocols for one block (m_b = 1 and, by
     separability, any m_b): the frontier (expected questions, average failure) of the
     protocols 'ask k cells of the block, stop when the needle is found, then answer by the
     Bayes rule', against the bound p (1 - 2B/N - 2n/(m_b N))
  B  additive work (not treated by Theorem 6.1): the class of all 2^K functions on K inputs,
     L calls at uniform inputs, a run is good if at most m = eta L answers are wrong.  A lower
     bound n >= (1 - 2 eta - 2 delta) K for every protocol; what the best protocol, Protocol R
     with a random round, and Protocol R with the last mixture need, against the bound
     L K ln 2/((m+1) delta) of R3
  C  Theorem 7.4(a): the one-round inequality E[R_{t+1} | F] <= R_t (1 - delta/(2L)) for EVERY
     set S of surviving members that contains f (all subsets), and the n-round bound exactly
  D  A3: rehearsal runs from a pseudo-random generator with a k-bit seed, L = 1 (so A3(i) is
     void), deployment on a fresh input: the conclusion of R1 fails although A3(i)-(iv) hold as
     worded in Section 0.2 of the file
  E  Example 3.5: the weights as written sum to 1.01; the numbers of the file need 0.49
  F  the budget: the certificate for a human who is not deterministic; break-even run length;
     calendar years against working years
  G  the table of the data against the human: the posterior weight of 'the data set, and something
     else elsewhere' while n times the bits of a question is below K

Usage: python3 assumptions_attack_lower.py [seed]
"""
import itertools
import math
import sys

import numpy as np

SEED = int(sys.argv[1]) if len(sys.argv) > 1 else 20261118
LN2 = math.log(2.0)


def binom_tail_gt(L, p, m):
    """Pr[Bin(L, p) > m]."""
    return sum(math.comb(L, i) * p ** i * (1 - p) ** (L - i) for i in range(m + 1, L + 1))


# ---------------------------------------------------------------------------------------------
def part_A():
    print("== A: Theorem 6.1 against the exact frontier of one block")
    print("  plan k: ask k cells in turn, stop when the needle is found; expected questions")
    print("  n_k = k - k(k-1)/(2N); if not found, the deployed system sees z and answers by the Bayes")
    print("  rule: average failure F_k = (1/N) E_z[min(D, N-k-D)], D = number of distinct cells of the")
    print("  run outside the asked ones.  Bound of Theorem 6.1(2) with m_b = 1: p (1 - 2B/N - 2 n_k/N).")
    worst = float("inf")
    worst_case = None
    for N in range(2, 41):
        for B in range(1, 7):
            p = 1 - (1 - 1 / N) ** B
            for k in range(0, N + 1):
                # distribution of D after B draws: draw in asked set w.p. k/N, old outside cell d/N
                dist = {0: 1.0}
                for _ in range(B):
                    new = {}
                    for d, pr in dist.items():
                        stay = (k + d) / N
                        new[d] = new.get(d, 0.0) + pr * stay
                        if N - k - d > 0:
                            new[d + 1] = new.get(d + 1, 0.0) + pr * (N - k - d) / N
                    dist = new
                Fk = sum(pr * min(d, N - k - d) for d, pr in dist.items()) / N
                nk = k - k * (k - 1) / (2 * N)
                bound = p * (1 - 2 * B / N - 2 * nk / N)
                if Fk - bound < worst:
                    worst, worst_case = Fk - bound, (N, B, k, Fk, bound)
                assert Fk >= bound - 1e-12, (N, B, k, Fk, bound)
    print(f"  N = 2..40, B = 1..6, all k: smallest (F_k - bound) = {worst:.5f} at (N, B, k) = {worst_case[:3]}"
          f" (F = {worst_case[3]:.5f}, bound = {worst_case[4]:.5f})")
    # item (3): least expected number of questions for failure <= delta, per block, against the bound
    print("  item (3), N = B/(2 delta): least expected questions per block of the frontier (lower convex")
    print("  envelope of the plans) for average failure <= delta, against (1 - 10 delta) B/(8 delta):")
    for B, delta in ((5, 0.05), (10, 0.05), (4, 0.02), (20, 0.01)):
        N = round(B / (2 * delta))
        pts = []
        for k in range(0, N + 1):
            dist = {0: 1.0}
            for _ in range(B):
                new = {}
                for d, pr in dist.items():
                    new[d] = new.get(d, 0.0) + pr * (k + d) / N
                    if N - k - d > 0:
                        new[d + 1] = new.get(d + 1, 0.0) + pr * (N - k - d) / N
                dist = new
            pts.append((k - k * (k - 1) / (2 * N), sum(pr * min(d, N - k - d) for d, pr in dist.items()) / N))
        # least n on the lower convex envelope with F <= delta: mix two plans
        best = float("inf")
        for (n1, F1) in pts:
            if F1 <= delta:
                best = min(best, n1)
            for (n2, F2) in pts:
                if F1 > delta >= F2:
                    lam = (F1 - delta) / (F1 - F2)
                    best = min(best, (1 - lam) * n1 + lam * n2)
        lower = (1 - 10 * delta) * B / (8 * delta)
        print(f"    B = {B:2d}, delta = {delta}: N = {N:4d}; best plan mixture {best:9.2f};"
              f" lower bound {lower:9.2f}; ratio {best / lower:.2f}")


# ---------------------------------------------------------------------------------------------
def occupancy(K, n):
    """Law of the number of distinct inputs among n uniform draws from [K], for 0..n draws."""
    dists = [np.zeros(K + 1)]
    dists[0][0] = 1.0
    for _ in range(n):
        d = dists[-1]
        nd = np.zeros(K + 1)
        s = np.arange(K + 1)
        nd += d * s / K
        nd[1:] += (d * (K - s) / K)[:-1]
        dists.append(nd)
    return dists


def part_B():
    print("== B: additive work: all 2^K functions on K inputs, L uniform calls, good = at most m wrong")
    print("  lower bound for every protocol: failure <= delta for all members forces")
    print("  n >= K (1 - 2 (m/L) - 2 delta)   [each call at an unasked input is wrong w.p. >= 1/2 on average")
    print("  over the class, so E[wrong calls] >= L (K - n)/(2K); and E[wrong calls] <= m + delta L]")
    print("     K    L    m  delta | lower bound | best protocol | Protocol R, M^(T) | T in 2nd half | Protocol R, last | R3 bound")
    for (K, L, m, delta) in ((20, 20, 2, 0.1), (50, 50, 5, 0.1), (50, 200, 20, 0.1),
                             (200, 100, 10, 0.1), (200, 100, 10, 0.01), (400, 1000, 100, 0.05)):
        eta = m / L
        lower = K * (1 - 2 * eta - 2 * delta)
        # best protocol: n distinct questions, fair guesses elsewhere
        best = next(n for n in range(K + 1) if binom_tail_gt(L, (K - n) / (2 * K), m) <= delta)
        assert best >= lower - 1e-9, (best, lower)
        # exhaustive check of the inequality E[wrong] <= m + delta L => n >= lower, for this protocol
        for n in range(K + 1):
            fail = binom_tail_gt(L, (K - n) / (2 * K), m)
            if fail <= delta:
                assert n >= lower - 1e-9
        r3 = L * K * LN2 / ((m + 1) * delta)
        nmax = int(min(6 * r3, 40000)) + 1
        occ = occupancy(K, nmax)
        tails = np.array([binom_tail_gt(L, (K - s) / (2 * K), m) for s in range(K + 1)])
        fail_round = np.array([float(o @ tails) for o in occ])       # failure of the mixture after t answers
        cum = np.cumsum(fail_round)
        nR = next((n for n in range(1, nmax + 1) if cum[n - 1] / n <= delta), None)
        nlast = next((n for n in range(0, nmax + 1) if fail_round[n] <= delta), None)
        # T uniform on the second half of the rounds (rounds n/2+1..n use the mixtures after n/2..n-1 answers)
        nhalf = next((n for n in range(2, nmax + 1, 2)
                      if (cum[n - 1] - cum[n // 2 - 1]) / (n // 2) <= delta), None)
        print(f"  {K:4d} {L:4d} {m:4d}  {delta:5.2f} | {lower:11.1f} | {best:13d} | {str(nR):>17s} |"
              f" {str(nhalf):>11s} | {str(nlast):>16s} | {r3:8.0f}")
    print("  (Protocol R asks one uniformly chosen call per run, which here is a uniform input; 'last' deploys")
    print("   the mixture after all n answers (nothing is proved for it in assumptions.md; the file")
    print("   research/prove-c/rehearsal-core.md announces a bound for scaffolds of this kind); 'T in 2nd half'")
    print("   deploys the mixture of a round drawn uniformly from the second half of the rounds, for which")
    print("   the proof of R1 gives the bound 2 L K ln 2/n.)")


# ---------------------------------------------------------------------------------------------
def part_C(rng):
    print("== C: Theorem 7.4(a): one-round inequality on every surviving set, and the n-round bound, exact")
    worst = float("inf")
    worst_n = float("inf")
    for trial in range(12):
        N, L = 6, int(rng.integers(1, 4))
        Hn = 7
        a_shift = int(rng.integers(1, 4))
        stop_at = int(rng.integers(0, N)) if trial % 2 else -1

        def run_inputs(g, z):
            xs = [z]
            while len(xs) < L:
                if xs[-1] == stop_at and g[xs[-1]] == 1:
                    break                                   # runs of different lengths
                xs.append((xs[-1] + 1 + a_shift * g[xs[-1]]) % N)
            return xs

        f = np.zeros(N, dtype=int)
        members = [f]
        while len(members) < Hn:
            g = rng.integers(0, 2, N)
            if trial % 3 == 0 and len(members) == 1:
                g = f.copy()                                 # a second member of the run class
                unreached = [x for x in range(N) if all(x not in run_inputs(f, z) for z in range(N))]
                if unreached:
                    g[unreached[0]] = 1
            members.append(g)
        w = rng.dirichlet(np.ones(Hn))
        D = []
        for h in members:
            D.append(sum(any(h[x] != f[x] for x in run_inputs(f, z)) for z in range(N)) / N)
        pos = [d for d in D if d > 0]
        if not pos:
            continue
        delta = min(pos)
        off = [i for i in range(Hn) if D[i] > 0]              # members outside the run class [f]
        # one-round check for every subset S containing f (index 0)
        for mask in range(1, 2 ** Hn, 2):
            S = [i for i in range(Hn) if mask >> i & 1]
            W = sum(w[i] for i in S)
            R = sum(w[i] for i in S if i in off)
            removed = 0.0
            for g_i in S:
                for z in range(N):
                    xs = run_inputs(members[g_i], z)
                    for J in range(L):
                        if J < len(xs):
                            x = xs[J]
                            removed += (w[g_i] / W) / N / L * sum(w[i] for i in S if i in off
                                                                   and members[i][x] != f[x])
            worst = min(worst, removed - delta * R / (2 * L))
            assert removed >= delta * R / (2 * L) - 1e-12, (trial, mask)
        # n rounds exactly: Markov chain on subsets
        states = {2 ** Hn - 1: 1.0}
        K = math.log2(1.0 / w[0])
        for n in range(1, 13):
            new = {}
            for mask, pr in states.items():
                S = [i for i in range(Hn) if mask >> i & 1]
                W = sum(w[i] for i in S)
                for g_i in S:
                    for z in range(N):
                        xs = run_inputs(members[g_i], z)
                        for J in range(L):
                            q = pr * (w[g_i] / W) / N / L
                            nm = mask
                            if J < len(xs):
                                x = xs[J]
                                for i in S:
                                    if members[i][x] != f[x]:
                                        nm &= ~(1 << i)
                            new[nm] = new.get(nm, 0.0) + q
            states = new
            mass = 0.0
            for mask, pr in states.items():
                S = [i for i in range(Hn) if mask >> i & 1]
                mass += pr * sum(w[i] for i in S if i in off) / sum(w[i] for i in S)
            bound = 2 ** K * (1 - delta / (2 * L)) ** n
            worst_n = min(worst_n, bound - mass)
            assert mass <= bound + 1e-12
    # Proposition 7.5(b): the human f_dag is NOT in the class; eps_dag = min_h D(f_dag, h); for every
    # subset S of the class the expected fraction of w(S) removed in a round is >= eps_dag/(2L)
    worst_b = float("inf")
    for trial in range(12):
        N, L = 6, int(rng.integers(1, 4))
        Hn = 6
        a_shift = int(rng.integers(1, 4))

        def run_inputs2(g, z):
            xs = [z]
            while len(xs) < L:
                xs.append((xs[-1] + 1 + a_shift * g[xs[-1]]) % N)
            return xs

        fd = rng.integers(0, 2, N)
        members = []
        while len(members) < Hn:
            g = rng.integers(0, 2, N)
            if any(g[x] != fd[x] for z in range(N) for x in run_inputs2(fd, z)):
                members.append(g)
        w = rng.dirichlet(np.ones(Hn))
        D = [sum(any(h[x] != fd[x] for x in run_inputs2(fd, z)) for z in range(N)) / N for h in members]
        eps = min(D)
        for mask in range(1, 2 ** Hn):
            S = [i for i in range(Hn) if mask >> i & 1]
            W = sum(w[i] for i in S)
            removed = 0.0
            for g_i in S:
                for z in range(N):
                    xs = run_inputs2(members[g_i], z)
                    for J in range(L):
                        removed += (w[g_i] / W) / N / L * sum(w[i] for i in S if members[i][xs[J]] != fd[xs[J]])
            worst_b = min(worst_b, removed / W - eps / (2 * L))
            assert removed / W >= eps / (2 * L) - 1e-12
    print(f"  Proposition 7.5(b), 12 random instances, all subsets: smallest (expected fraction of the weight")
    print(f"  removed - eps_dag/(2L)) = {worst_b:.5f}")
    print(f"  12 random instances (6 inputs, 7 functions, runs of different lengths in half of them):")
    print(f"  smallest (expected removed weight - delta R/(2L)) over all subsets = {worst:.5f};")
    print(f"  smallest (bound - exact posterior weight off [f]) for n = 1..12 = {worst_n:.5f}")


# ---------------------------------------------------------------------------------------------
def part_D(rng):
    print("== D: pseudo-random rehearsal runs with a k-bit seed, L = 1, fresh deployment")
    k, N = 3, 64
    S = 2 ** k
    # A_sigma: the set of inputs that the generator with seed sigma ever outputs (half of X)
    sets = [set(rng.choice(N, N // 2, replace=False).tolist()) for _ in range(S)]
    s_true = 0
    print(f"  X = [{N}], human f = 0; class: f (weight 1/2) and, for each of {S} seeds, the function that is")
    print("  0 on the outputs of the generator with that seed and 1 elsewhere (weight 2^-(k+1) each);")
    print("  rehearsal input of round t: the t-th output of the generator with the true seed (uniform on")
    print("  its set); deployed input: uniform on X, fresh.  A3(i) is void (L = 1); (ii)-(iv) hold.")
    for n in (10, 100, 1000):
        # a wrong seed sigma survives a round iff the rehearsal input lies in A_sigma
        surv = [len(sets[s_true] & sets[sg]) / len(sets[s_true]) for sg in range(1, S)]
        tot_seed = 0.0
        tot_fresh = 0.0
        for t in range(1, n + 1):
            # seeded rehearsal: exact expectation over which wrong seeds are alive (independent? no:
            # they depend on the same inputs; use the exact law by enumeration of alive patterns is
            # 2^(S-1) per round; instead bound from below by the true seed alone and compute the
            # exact value when t is large enough that the others are dead with probability ~1)
            alive_p = [q ** (t - 1) for q in surv]
            # lower bound: only the true seed counted (weight 1/(S+1) at least... exact if others dead)
            err_true = (1 - len(sets[s_true]) / N)
            tot_seed += err_true / (S + 1 + sum(alive_p))      # Jensen: E[1/(S+1+A)] >= 1/(S+1+E[A])
            # fresh rehearsal inputs: each seed function survives a round with probability 1/2
            qf = 0.5 ** (t - 1)
            e = sum(math.comb(S, i) * qf ** i * (1 - qf) ** (S - i) * i / (S + i) for i in range(S + 1))
            tot_fresh += 0.5 * e
        print(f"    n = {n:4d}: Pr[deployed answer of M^(T) is wrong] >= {tot_seed / n:.5f} with the generator;"
              f"  = {tot_fresh / n:.5f} with fresh inputs;  R1 bound K ln 2/n = {LN2 / n:.5f}")
    print(f"  floor for every n: (1/2)/(2^k + 1) = {0.5 / (S + 1):.5f}")


# ---------------------------------------------------------------------------------------------
def part_E():
    print("== E: Example 3.5")
    print(f"  weights as written: 1/2 (human) + 1/2 (date guards) + 0.01 (special guard) = {0.5 + 0.5 + 0.01}")
    for n in (100, 10000):
        v49 = 0.01 / (0.5 + 0.49 / (n + 1) + 0.01)
        v50 = 0.01 / (0.5 + 0.5 / (n + 1) + 0.01)
        print(f"    n = {n:5d}: with guard weights 0.49/(theta(theta+1)): {v49:.4f}; with 0.5/(theta(theta+1)),"
              f" total 1.01: {v50:.4f}")


# ---------------------------------------------------------------------------------------------
def part_F():
    print("== F: the budget")
    print("  (1) the certificate when the human is not deterministic.  Certificate (a) of Proposition 2.5")
    print("  needs no mismatch in m = ln(1/dc)/(theta delta) rounds; the exact imitator of a human whose")
    print("  answers agree with their own repetition with probability c per call passes with probability c^m:")
    for theta, delta in ((0.1, 0.1), (0.01, 0.01)):
        m = math.ceil(math.log(20) / (theta * delta))
        for c in (1.0, 0.999, 0.99, 0.9):
            print(f"    theta = delta = {theta}: m = {m:6d}; self-agreement c = {c}: Pr[pass] = {c ** m:.3e}")
    print("  what remains for such a human is V1(b): frequencies of tests fixed in advance, to accuracy eps")
    print("  with m = 2 ln(2/(pi dc))/eps^2 answers (pi = weight of the test, dc = 0.05):")
    for eps in (0.1, 0.03, 0.01):
        for pi in (1.0, 2.0 ** -20):
            print(f"    eps = {eps:5.2f}, pi = {pi:.1e}: m = {2 * math.log(2 / (pi * 0.05)) / eps ** 2:12.0f}")
    print("  (2) break-even: one run of L calls costs the human system L answers; rehearsal with R3 costs")
    print("  K ln 2/(theta delta) answers plus the certificate; rehearsal is cheaper for one run only if")
    print("  L exceeds:")
    for K in (30, 1e3, 1e6, 1e9):
        for theta, delta in ((0.1, 0.1), (0.5, 0.5)):
            n = K * LN2 / (theta * delta) + math.log(20) / (theta * delta)
            print(f"    K = {K:8.0e}, theta = delta = {theta}: L > {n:.3g}")
    print("  (3) units: the file converts answers to 'human-years' at 8765.82 hours per year (all hours")
    print("  of the calendar); at 2000 working hours per year the same numbers are 4.38 times larger:")
    for n in (300, 6.9e4, 6.9e7):
        print(f"    n = {n:8.3g} one-hour answers: {n / 8765.82:10.4g} calendar years = {n / 2000:10.4g} working years")
    print("  (4) sequential rounds (Proposition 6.3): with b answers per batch and S batches the bound of R3")
    print("  is K ln 2/(theta S).  Twenty batches, theta = delta = 0.1: K <= "
          f"{20 * 0.01 / LN2:.3f} bits, as the file says.")


# ---------------------------------------------------------------------------------------------
def part_G():
    print("== G: the table of the data against the human (the referent test where R1 is empty)")
    print("  X = [N], one call per run at a uniform input, human f = 0 with weight 2^-K; for every set A")
    print("  of inputs the member 'answer 0 on A, 1 elsewhere' (the table of a data set with questions A)")
    print("  with weight proportional to (2N)^-|A|: b = log2(2N) bits per recorded question.  After s")
    print("  distinct questions, probability that the mixture answers 1 at an input not yet asked:")
    for (N, K) in ((1024, 100), (1024, 1000), (2 ** 20, 1000)):
        b = math.log2(2 * N)
        # log-weights: tables containing the s asked inputs and not x*: c (2N)^-s (1+1/(2N))^(N-s-1)
        logc = math.log(1 - 2.0 ** (-K)) - N * math.log1p(1 / (2 * N))
        row = []
        thr = K / b
        for s_ in sorted(set([0, int(0.5 * thr), int(0.9 * thr), int(thr), int(1.1 * thr) + 1, int(1.5 * thr) + 1])):
            lw = logc - s_ * math.log(2 * N) + (N - s_ - 1) * math.log1p(1 / (2 * N))
            l_wrong = lw
            l_right_tables = lw - math.log(2 * N)
            l_f = -K * LN2
            mx = max(l_wrong, l_right_tables, l_f)
            wrong = math.exp(l_wrong - mx)
            tot = wrong + math.exp(l_right_tables - mx) + math.exp(l_f - mx)
            row.append(f"s = {s_}: {wrong / tot:.4f}")
        print(f"    N = {N}, K = {K} bits, b = {b:.0f} bits, K/b = {thr:.1f}:  " + ";  ".join(row))
    print("  the bound of R1 for the same n, K ln 2/n, is below 1 only for n > K ln 2: the tables lose to")
    print("  the human only after about K/b questions, and before that the mixture is the table's.")


if __name__ == "__main__":
    print(f"seed {SEED}")
    rng = np.random.default_rng(SEED)
    part_A()
    part_B()
    part_C(rng)
    part_D(rng)
    part_E()
    part_F()
    part_G()
