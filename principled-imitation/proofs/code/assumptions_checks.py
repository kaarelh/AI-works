"""Numerical checks for research/prove-c/assumptions.md (key: assumptions).

Each part prints a block that is quoted in Section 9 of that file.

  part 1  Example 2.3: without A2 the member that is exact on the human system is destroyed
          on inputs that only the mixture's runs visit (exact product, exact recursion, simulation)
  part 2  Example 3.3: the asked call is a keyed function of the run (a short seed) and the
          inputs are stamped; expected unfaithful calls per run, against fresh coins (exact)
  part 3  Theorem 3.2(a): probability that the run of a uniformly random round meets a set Q
          that no earlier question met, against L/n (exact, worst case over visit rates)
  part 4  Examples 3.4 and 3.5: a real task of rehearsal probability p; a time stamp (exact)
  part 5  Theorem 7.4: one posterior draw per run over a delta-separated class, against the
          bound 2^K (1 - delta/(2L))^n, and the same protocol over a class with patches
  part 6  Theorem 1.7: rehearsal with whole episodes (two messages per episode), sum over the
          rounds of the expected number of unfaithful episodes, against L_e K ln 2
  part 7  Corollary 1.12: a human who drifts; distance of the deployed mixture to the human of
          the first round, as a function of the length of rehearsal
  part 8  Theorem 6.1 and Section 6: numbers of questions (lower bounds, upper bounds, budgets)
  part 9  Proposition 2.5 and Remark 2.6: mismatch probability against total variation; the
          identity for the squared L2 distance

Usage: python3 assumptions_checks.py [seed]
"""
import math
import sys

import numpy as np

SEED = int(sys.argv[1]) if len(sys.argv) > 1 else 20261115
LN2 = math.log(2.0)


# ---------------------------------------------------------------------------------------------
def part1():
    print("== part 1: Example 2.3 (the best member is destroyed off the human system's inputs)")
    # state k = number of answers at input a so far (nu1 alive). Posterior weight of nu2:
    # omega_k = 1/(1+2^k). Per round: prob 1/2 -> k+1; prob omega_k/4 -> nu1 dies; else nothing.
    prod = 1.0
    for k in range(200):
        omega = 1.0 / (1.0 + 2.0 ** k)
        prod *= 2.0 / (2.0 + omega)
    print(f"  Pr[nu1 is never refuted] = prod_k 2/(2+omega_k) = {prod:.6f};"
          f"  Pr[nu1 is refuted at some time] = {1 - prod:.6f}")
    # exact recursion for Pr[nu1 dead after n rounds]
    for n in (5, 20, 100):
        alive = {0: 1.0}
        dead = 0.0
        for _ in range(n):
            new = {}
            for k, pr in alive.items():
                omega = 1.0 / (1.0 + 2.0 ** k)
                dead += pr * omega / 4.0
                new[k + 1] = new.get(k + 1, 0.0) + pr * 0.5
                new[k] = new.get(k, 0.0) + pr * (0.5 - omega / 4.0)
            alive = new
        # expected run failure of the mixture after n rounds: dead -> nu2 alone: 1/2;
        # alive in state k: omega_k / 2
        fail = dead * 0.5 + sum(pr * 0.5 / (1.0 + 2.0 ** k) for k, pr in alive.items())
        print(f"  n = {n:3d}: Pr[nu1 refuted] = {dead:.6f};"
              f"  Pr[run of the mixture after n rounds differs from the human system] = {fail:.6f}")
    rng = np.random.default_rng(SEED)
    trials, n = 200000, 60
    k = np.zeros(trials, dtype=np.int64)
    deadv = np.zeros(trials, dtype=bool)
    for _ in range(n):
        omega = 1.0 / (1.0 + 2.0 ** k)
        ans1 = rng.random(trials) < omega / 2.0          # mixture answers 1 at a: run has 2 calls
        j2 = rng.random(trials) < 0.5                    # J = 2
        deadv |= (~deadv) & ans1 & j2
        k += ((~deadv) & (~j2)).astype(np.int64)
    se = math.sqrt(deadv.mean() * (1 - deadv.mean()) / trials)
    print(f"  simulation, {trials} trials, n = {n}: Pr[nu1 refuted] = {deadv.mean():.4f} +- {se:.4f}")


# ---------------------------------------------------------------------------------------------
def binom_pmf(N, p):
    return np.array([math.comb(N, i) * p ** i * (1 - p) ** (N - i) for i in range(N + 1)])


def part2():
    print("== part 2: Example 3.3 (asked call computed from the run by a k-bit seed; stamped inputs)")
    k, L = 3, 4
    S = 2 ** k
    print(f"  k = {k} (class: f and {S} seed hypotheses, w(f) = 1/2, K = 1 bit), L = {L}")
    print("  E[number of unfaithful calls of the run of round t] = (L-1) E[|A|/(2^k+|A|)], A = alive seeds")
    print("    t   seeded J   fresh J")
    tot_seed = tot_fresh = 0.0
    rows = {}
    nmax = 1000
    for t in range(1, nmax + 1):
        q = float(L) ** (-(t - 1))                       # survival probability of a refutable seed
        pm = binom_pmf(S - 1, q)
        e_seed = (L - 1) * sum(pm[i] * (1 + i) / (S + 1 + i) for i in range(S))
        pf = binom_pmf(S, q)
        e_fresh = (L - 1) * sum(pf[i] * i / (S + i) for i in range(S + 1))
        tot_seed += e_seed
        tot_fresh += e_fresh
        rows[t] = (e_seed, e_fresh, tot_seed, tot_fresh)
    for t in (1, 2, 3, 5, 10, 100, 1000):
        print(f"  {t:5d}   {rows[t][0]:.6f}   {rows[t][1]:.3e}")
    print(f"  limit for seeded J: (L-1)/(2^k+1) = {(L - 1) / (S + 1):.6f}")
    print("  average over a uniformly random round T of n (the deployed imitator), against L K ln2 / n:")
    for n in (10, 100, 1000):
        print(f"    n = {n:4d}: seeded {rows[n][2] / n:.5f}   fresh {rows[n][3] / n:.5f}"
              f"   R1 bound {L * LN2 / n:.5f}")
    # Proposition 6.3: fresh coins, batches of b rounds; sum over batches of E[unfaithful calls]
    for b in (1, 5, 20):
        tot = 0.0
        for s in range(1, 200 // b + 1):
            pf = binom_pmf(S, float(L) ** (-(b * (s - 1))))
            tot += (L - 1) * sum(pf[i] * i / (S + i) for i in range(S + 1))
        print(f"  batches of {b:2d} rounds, fresh J: sum over {200 // b:3d} batches of E[unfaithful calls]"
              f" = {tot:.4f}  (bound L K ln2 = {L * LN2:.4f})")
    # simulation of the seeded protocol as a check of the formula at t = 4
    rng = np.random.default_rng(SEED + 1)
    trials, t = 100000, 4
    alive_wrong = rng.random((trials, S - 1)) < float(L) ** (-(t - 1))
    a = 1 + alive_wrong.sum(axis=1)
    est = ((L - 1) * a / (S + a)).mean()
    print(f"  simulation check of the seeded formula at t = {t}: {est:.5f} (formula {rows[t][0]:.5f})")


# ---------------------------------------------------------------------------------------------
def part3():
    print("== part 3: Theorem 3.2(a) (a set Q met by the run of round T before any question met it)")
    print("  each run meets Q with probability q, at exactly one of its calls; exact value")
    print("  (1/n) sum_t (1-q/L)^(t-1) q, maximised over q in (0,1], against L/n")
    for L, n in ((1, 10), (4, 10), (4, 100), (20, 100), (20, 10000)):
        best = max((sum((1 - q / L) ** (t - 1) * q for t in range(1, n + 1)) / n, q)
                   for q in np.linspace(0.01, 1.0, 100))
        print(f"    L = {L:3d}, n = {n:5d}: max = {best[0]:.5f} at q = {best[1]:.2f};"
              f"  min(1, L/n) = {min(1.0, L / n):.5f}")


# ---------------------------------------------------------------------------------------------
def part4():
    print("== part 4: Examples 3.4 and 3.5")
    print("  Example 3.4: real task z* of rehearsal probability p, guard of prior weight eta = 1/2;")
    print("  E[fraction of unfaithful calls | deployed run is on z*] = eta' (1-(1-p)^n)/(n p), eta' <= eta")
    for n in (100, 10000):
        for p in (0.0, 1e-6, 1.0 / n, 0.1):
            val = 0.5 if p == 0.0 else 0.5 * (1 - (1 - p) ** n) / (n * p)
            print(f"    n = {n:5d}, p = {p:8.1e}: at most {val:.5f}")
    print("  Example 3.5: threshold guards g_theta with weights eta/(theta(theta+1)), eta = w(f) = 1/2;")
    print("  probability that a call at date d > n is unfaithful after n rounds:")
    for n in (100, 10000):
        tail = 0.5 / (n + 1)
        for d in (n + 1, 2 * n + 1, 10 ** 9):
            hit = 0.5 * (1.0 / (n + 1) - 1.0 / (d + 1))
            print(f"    n = {n:5d}, d = {d:10d}: {hit / (0.5 + tail):.3e}")
    print("  weights 0.49/(theta(theta+1)) and one further guard of weight 0.01 at a special date theta0 > n:")
    for n in (100, 10000):
        tail = 0.49 / (n + 1)
        print(f"    n = {n:5d}, any d >= theta0: at least {0.01 / (0.5 + tail + 0.01):.4f}")


# ---------------------------------------------------------------------------------------------
def part5():
    print("== part 5: Theorem 7.4 (delta-separated class, one posterior draw per run, last posterior)")
    rng = np.random.default_rng(SEED + 2)
    N, L, n_code = 16, 3, 15
    # f = 0 on [N]; code: n_code random functions, each differing from f on exactly N/2 inputs
    f = np.zeros(N, dtype=np.int64)
    code = []
    for _ in range(n_code):
        g = np.zeros(N, dtype=np.int64)
        g[rng.choice(N, N // 2, replace=False)] = 1
        code.append(g)
    code = np.array(code)
    patches = np.eye(N, dtype=np.int64)     # the N one-point patches of f

    def run_inputs(g, z):
        # adaptive scaffold: x_1 = z, x_{j+1} = x_j + 1 + 3 y_j (mod N), L calls
        xs = [z]
        for _ in range(L - 1):
            xs.append((xs[-1] + 1 + 3 * g[xs[-1]]) % N)
        return xs

    def run_dist(g):
        # Pr_z[run of g differs from run of f] = Pr_z[g differs from f at an input of f's run]
        return sum(any(g[x] != f[x] for x in run_inputs(f, z)) for z in range(N)) / N

    dists = [run_dist(g) for g in code]
    delta = min(dists)
    w_f = 1.0 / (n_code + 1)
    K = math.log2(1.0 / w_f)
    print(f"  X = [{N}], adaptive scaffold with L = {L} calls, f = 0, {n_code} members at Hamming")
    print(f"  distance {N // 2}; run distances to f between {min(dists):.4f} and {max(dists):.4f},")
    print(f"  so f is delta-separated with delta = {delta:.4f}; uniform weights, K = {K:.2f} bits;")
    print(f"  run distance of a one-point patch of f: {run_dist(patches[0]):.4f}")

    def simulate(table, weights, n_rounds, trials):
        # table[0] is f. Returns the mean posterior mass off f after each round.
        H = table.shape[0]
        mass = np.zeros(n_rounds + 1)
        for _ in range(trials):
            alive = np.ones(H, dtype=bool)
            for t in range(n_rounds + 1):
                wa = weights * alive
                mass[t] += 1.0 - wa[0] / wa.sum()
                if t == n_rounds:
                    break
                g = table[rng.choice(H, p=wa / wa.sum())]     # one posterior draw drives the run
                xs = run_inputs(g, rng.integers(0, N))
                x = xs[rng.integers(0, L)]
                alive &= (table[:, x] == f[x])
        return mass / trials

    trials, n_rounds = 4000, 60
    t1 = np.vstack([f[None, :], code])
    w1 = np.full(t1.shape[0], w_f)
    m1 = simulate(t1, w1, n_rounds, trials)
    # the same class with the N one-point patches of f added (they are not delta-separated from f)
    t2 = np.vstack([f[None, :], code, patches])
    w2 = np.concatenate([np.full(n_code + 1, w_f / 2), np.full(N, 0.5 / N)])
    m2 = simulate(t2, w2, n_rounds, trials)
    print("    n   separated class   bound 2^K(1-delta/(2L))^n   class with patches")
    for n in (0, 5, 10, 20, 40, 60):
        bound = min(1.0, 2 ** K * (1 - delta / (2 * L)) ** n)
        print(f"  {n:3d}   {m1[n]:.5f}           {bound:.5f}                     {m2[n]:.5f}")
    print(f"  ({trials} trials; mean posterior mass off f after n rounds)")


# ---------------------------------------------------------------------------------------------
def part6():
    print("== part 6: Theorem 1.7 (rehearsal with whole episodes; deterministic human)")
    rng = np.random.default_rng(SEED + 3)
    NO, NY, LE = 4, 3, 3          # openings, answers, episodes per run
    # visible histories: (o1) -> index o1 ; (o1, y1, o2) with o2 = (o1 + y1 + r) mod NO, r a coin
    n_hist1 = NO
    n_hist2 = NO * NY * NO

    def idx2(o1, y1, o2):
        return n_hist1 + (o1 * NY + y1) * NO + o2

    D = n_hist1 + n_hist2
    H = 40
    table = rng.integers(0, NY, size=(H, D))
    # make the hypotheses close to the human (row 0): each differs from it on a few histories
    f = table[0].copy()
    for h in range(1, H):
        table[h] = f
        pos = rng.choice(D, size=rng.integers(1, 6), replace=False)
        table[h, pos] = (f[pos] + rng.integers(1, NY, size=len(pos))) % NY
    lengths = rng.integers(2, 9, size=H).astype(float)
    lengths[0] = 6.0
    w = 2.0 ** (-lengths)
    w = w / w.sum()                 # weights with total 1
    K = math.log2(1.0 / w[0])

    def play(o1, r, strategy):
        y1 = strategy[o1]
        o2 = (o1 + y1 + r) % NO
        y2 = strategy[idx2(o1, y1, o2)]
        return (o1, y1), (idx2(o1, y1, o2), y2)

    trials, n_rounds = 3000, 150
    tot = 0.0
    tot_runs = 0.0
    for _ in range(trials):
        alive_w = w.copy()
        for _t in range(n_rounds):
            post = alive_w / alive_w.sum()
            # an independent own run of the episodic mixture: a fresh posterior draw per episode
            unfaithful = 0
            for _e in range(LE):
                g = table[rng.choice(H, p=post)]
                o1, r = rng.integers(0, NO), rng.integers(0, NO)
                (a1, y1), (a2, y2) = play(o1, r, g)
                if y1 != f[a1] or y2 != f[a2]:
                    unfaithful += 1
            tot += unfaithful
            tot_runs += (unfaithful > 0)
            # the rehearsal round: episode I is played by the human (the other episodes do not
            # influence it in this sequential scaffold), both messages become data
            o1, r = rng.integers(0, NO), rng.integers(0, NO)
            (a1, y1), (a2, y2) = play(o1, r, f)
            alive_w = alive_w * (table[:, a1] == y1) * (table[:, a2] == y2)
    print(f"  {LE} episodes per run, 2 messages per episode, {H} hypotheses, K = {K:.3f} bits")
    print(f"  sum over {n_rounds} rounds of E[number of unfaithful episodes of a run of the round's")
    print(f"  episodic mixture] = {tot / trials:.4f};  bound L_e K ln2 = {LE * K * LN2:.4f}")
    print(f"  sum over the rounds of Pr[run not faithful] = {tot_runs / trials:.4f}  ({trials} trials)")


# ---------------------------------------------------------------------------------------------
def part7():
    print("== part 7: Corollary 1.12 (a human who drifts during rehearsal)")
    rng = np.random.default_rng(SEED + 4)
    grid = np.linspace(0.05, 0.95, 19)          # class: Bernoulli(theta), theta on a grid; uniform weights
    gamma = 2e-4
    p0 = 0.5
    print(f"  one call per run at a fixed input; human of round t answers 1 with probability"
          f" {p0} + {gamma} t;")
    print("  class: 19 Bernoulli samplers, uniform weights; TV between the mixture of a uniformly")
    print("  random round T <= n and the human of round 1, and the human of round T:")
    trials = 4000
    for n in (10, 30, 100, 300, 1000, 2000):
        tv0 = tvT = 0.0
        for _ in range(trials):
            T = rng.integers(1, n + 1)
            ps = p0 + gamma * np.arange(1, T)
            y = rng.random(T - 1) < ps
            ones = y.sum()
            loglik = ones * np.log(grid) + (T - 1 - ones) * np.log(1 - grid)
            post = np.exp(loglik - loglik.max())
            post /= post.sum()
            mix = float(post @ grid)
            tv0 += abs(mix - (p0 + gamma))
            tvT += abs(mix - (p0 + gamma * T))
        print(f"    n = {n:5d}: to the human of round 1: {tv0 / trials:.4f};"
              f"  to the human of round T: {tvT / trials:.4f}")


# ---------------------------------------------------------------------------------------------
def part8():
    print("== part 8: Theorem 6.1 and the budget")
    print("  Theorem 6.1: m_b blocks, B critical units per run, each replicated 2m+1 times, N = B/(2 delta):")
    print("  lower bound (1-10 delta) m_b B/(8 delta); R3 upper bound L K ln2/((m+1) delta);")
    print("  'scan' = expected questions of the protocol that scans half of the blocks (failure <= delta)")
    print("    m_b    B    m   delta      L     K bits   lower bound   scan     R3 upper   upper/lower")
    for m_b, B, m, delta in ((10, 5, 0, 0.05), (10, 5, 50, 0.05), (1000, 5, 50, 0.05),
                             (1000, 50, 5, 0.01), (10 ** 6, 5, 10 ** 6, 0.05)):
        N = B / (2 * delta)
        L = B * (2 * m + 1)
        K = m_b * math.log2(N)
        low = (1 - 10 * delta) * m_b * B / (8 * delta)
        scan = math.ceil(m_b / 2) * (N - 1) * (N + 2) / (2 * N)
        up = L * K * LN2 / ((m + 1) * delta)
        print(f"  {m_b:7d} {B:4d} {m:7d} {delta:5.2f} {L:10.3g} {K:10.4g} {low:12.4g} {scan:10.4g}"
              f" {up:10.4g} {up / low:8.1f}")
    print("  the family 'scan c of the m_b blocks' (m_b = 1000, B = 5, delta = 0.05, N = 50):")
    print("    c/m_b   expected questions n   failure (1-c/m_b) p   lower bound p(1-2B/N-2n/(m_b N))")
    m_b, B, delta = 1000, 5, 0.05
    N = int(round(B / (2 * delta)))
    p = 1 - (1 - 1 / N) ** B
    for frac in (0.0, 0.25, 0.5, 0.75, 1.0):
        c = int(frac * m_b)
        n = c * (N - 1) * (N + 2) / (2 * N)
        fail = (1 - c / m_b) * p
        low = p * (1 - 2 * B / N - 2 * n / (m_b * N))
        print(f"    {frac:4.2f}    {n:12.1f}           {fail:.5f}               {low:.5f}")
    print("  questions needed by the bounds (theta = fraction of faults tolerated, delta = failure):")
    print("    K bits   theta  delta   det. low stakes   stoch. low stakes   critical, L = 1e3   certificate")
    for K in (30.0, 1e3, 1e6, 1e9):
        for theta, delta in ((0.1, 0.1), (0.01, 0.01)):
            det = K * LN2 / (theta * delta)
            sto = K * LN2 / (2 * theta ** 2 * delta ** 2)
            crit = 1e3 * K * LN2 / delta
            cert = math.log(20.0) / (theta * delta)
            print(f"    {K:7.3g}  {theta:5.2f}  {delta:5.2f}   {det:15.4g}   {sto:17.4g}   {crit:17.4g}"
                  f"   {cert:11.4g}")
    hours_per_year = 8765.82
    print("  human time for n answers (one human-year = 8765.82 hours, the figure in the notes):")
    for n in (300.0, 6.9e4, 6.9e7, 6.9e10):
        print(f"    n = {n:8.3g}: {n / hours_per_year:10.4g} human-years at one hour each;"
              f" {n:10.4g} human-years at one year each")
    print("  largest K (bits) for which K ln2/(theta delta) <= n:")
    for n, what in ((1e5, "one career of 1e5 working hours, one hour per answer"),
                    (50.0, "one career of 50 years, one year per answer"),
                    (1e4, "1e4 people for one year, one year per answer"),
                    (2e9, "1e6 people for one year at 2000 hours, one hour per answer")):
        for theta, delta in ((0.1, 0.1), (0.5, 0.5)):
            print(f"    n = {n:8.3g} ({what}), theta = {theta}, delta = {delta}:"
                  f" K <= {n * theta * delta / LN2:10.4g}")


def part9():
    print("== part 9: Proposition 2.5 and Remark 2.6 (mismatch rates) on random pairs of distributions")
    rng = np.random.default_rng(SEED + 5)
    worst_gap = 1.0
    worst_id = 0.0
    for _ in range(100000):
        s = rng.integers(2, 8)
        a = rng.dirichlet(np.full(s, rng.choice([0.2, 1.0, 5.0])))
        p = rng.dirichlet(np.full(s, rng.choice([0.2, 1.0, 5.0])))
        rho_ap = 1 - float(a @ p)
        tv = 0.5 * float(np.abs(a - p).sum())
        worst_gap = min(worst_gap, rho_ap - tv)
        l2 = float(((a - p) ** 2).sum())
        ident = 2 * rho_ap - (1 - float(a @ a)) - (1 - float(p @ p))
        worst_id = max(worst_id, abs(l2 - ident))
    print(f"  100000 random pairs (A, P) on 2 to 7 answers: min of (mismatch probability - TV) = {worst_gap:.3e}")
    print(f"  max |sum (A-P)^2 - (2 rho_AP - rho_AA - rho_PP)| = {worst_id:.3e}")


if __name__ == "__main__":
    print(f"seed {SEED}")
    part1()
    part2()
    part3()
    part4()
    part5()
    part6()
    part7()
    part8()
    part9()
