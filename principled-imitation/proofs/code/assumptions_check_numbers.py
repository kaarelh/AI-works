"""Referee checks for research/prove-c/assumptions.md, part 3: the examples and the constants.

  A  Example 2.3: the product, an independent exact recursion, and the same example with
     unequal weights (the probability that the exact member is destroyed tends to 1).
  B  Example 3.3: the exact formula, and a simulation of the protocol itself (seed and fresh coins).
  C  Examples 3.4 and 3.5: the displayed numbers; the claim "at least 0.0194 for every n < theta0";
     with a fresh posterior draw at every call the L calls of a run do NOT fail together.
  D  Corollary 1.12: the inequality KL(p || nu^eta) <= ln(1/(1-eta)) + a (1 + ln(s/eta)) on random
     pairs; the minimiser n*.
  E  Theorem 6.1: brute-force check of tolerance (part 1) on small cases; exact failure of the
     scan protocols against the bound of part 2; arithmetic of parts 3 and 4, of Corollary 6.2,
     of Remark 6.2a and of Section 6.2 (including "2^45" and "2^9033").
  F  Theorem 7.4 and Proposition 7.5(b): exact Markov chain over the set of unrefuted members
     (no sampling), on an adaptive scaffold.
  G  Example 7.6: the three displayed probabilities.
  H  Proposition 2.4(a),(b); Proposition 2.5 (mismatch rate >= TV); Remark 2.6.
  I  Section 6.3: H^2/KL for close distributions is 1/4, and 1/2 is the supremum.

Usage: python3 assumptions_check_numbers.py [seed]
"""
import itertools
import math
import sys

import numpy as np

SEED = int(sys.argv[1]) if len(sys.argv) > 1 else 11
LN2 = math.log(2.0)


def part_A():
    print("== A: Example 2.3")
    prod = 1.0
    for k in range(400):
        prod *= 2.0 / (2.0 + 1.0 / (1.0 + 2.0 ** k))
    print(f"    prod_k 2/(2 + omega_k) = {prod:.6f};  1 - product = {1 - prod:.6f};  half of it = {(1 - prod) / 2:.6f}")
    # independent recursion on (k, alive): absorbing probability computed by value iteration
    # u_k = Pr[nu1 is eventually refuted | k answers at a so far] = (omega_k/4 + u_{k+1}/2) / (1/2 + omega_k/4)
    u = 0.0
    for k in range(399, -1, -1):
        om = 1.0 / (1.0 + 2.0 ** k)
        u = (om / 4 + u / 2) / (0.5 + om / 4)
    print(f"    backward recursion: Pr[nu1 refuted] = {u:.6f}")
    print("    unequal weights w(nu1) = 2^-K1, w(nu2) = 1 - 2^-K1:  Pr[nu1 is refuted]")
    for K1 in (1, 2, 5, 10, 20, 40):
        w1 = 2.0 ** (-K1)
        w2 = 1 - w1
        u = 0.0
        for k in range(600, -1, -1):
            om = w2 * 2.0 ** (-k) / (w1 + w2 * 2.0 ** (-k))
            u = (om / 4 + u / 2) / (0.5 + om / 4)
        print(f"      K1 = {K1:2d}: {u:.6f}   (1 - (2/3)^K1 = {1 - (2 / 3) ** K1:.6f})")


def part_B(rng):
    print("== B: Example 3.3 (k = 3, L = 4)")
    k, L = 3, 4
    S = 2 ** k

    def binom(N, p):
        return [math.comb(N, i) * p ** i * (1 - p) ** (N - i) for i in range(N + 1)]

    for n in (100, 1000):
        ts = tf = 0.0
        for t in range(1, n + 1):
            q = float(L) ** (-(t - 1))
            pm = binom(S - 1, q)
            ts += (L - 1) * sum(pm[i] * (1 + i) / (S + 1 + i) for i in range(S))
            pf = binom(S, q)
            tf += (L - 1) * sum(pf[i] * i / (S + i) for i in range(S + 1))
        print(f"    n = {n:4d}: seeded {ts / n:.5f}, fresh {tf / n:.5f}, bound L K ln2/n = {L * LN2 / n:.5f},"
              f" floor (L-1)/(2^k+1) = {(L - 1) / (S + 1):.5f}")
    # simulation of the protocol itself
    trials, n = 20000, 30
    for mode in ("seeded", "fresh"):
        tot = np.zeros(n)
        for _ in range(trials):
            alive = np.ones(S, dtype=bool)
            for t in range(n):
                tot[t] += (L - 1) * alive.sum() / (S + alive.sum())
                z = rng.integers(1, L + 1, size=S)
                J = z[0] if mode == "seeded" else rng.integers(1, L + 1)   # the seed is s = 0
                alive &= (z == J)        # nu_sigma answers 0 at call j iff j = z_sigma
        est = tot / trials
        print(f"    simulation ({mode} J, {trials} trials): E[unfaithful calls] at rounds 1, 2, 3, 5, 30 ="
              f" {est[0]:.4f}, {est[1]:.4f}, {est[2]:.4f}, {est[4]:.4f}, {est[29]:.4f}")


def part_C():
    print("== C: Examples 3.4 and 3.5")
    n = 10 ** 4
    for p in (1e-6, 1.0 / n, 0.1):
        print(f"    Example 3.4, n = 10^4, eta = 1/2, p = {p:g}: {0.5 * (1 - (1 - p) ** n) / (n * p):.4f}")
    for n, d in ((100, 101), (100, 201), (100, 10 ** 9)):
        v = (1 / (n + 1) - 1 / (d + 1)) / (1 + 1 / (n + 1))
        print(f"    Example 3.5, n = {n}, d = {d}: {v:.3e}   (1/n^2 = {1 / n ** 2:.1e}, 1/(2n) = {1 / (2 * n):.1e}, 1/n = {1 / n:.1e})")
    # the special guard: two weight conventions; minimum over n >= 1, theta0 >= n + 1, d >= theta0
    for label, wf, wg in (("weights as in the text (total 1.01 > 1)", 0.5, 0.5),
                          ("weights as in the script (guards scaled to 0.49)", 0.5, 0.49)):
        best_special = (1.0, 0)
        best_total = (1.0, 0)
        for n in range(1, 20001):
            special = 0.01 / (wf + wg / (n + 1) + 0.01)
            # smallest total probability of an unfaithful call: theta0 = d = n + 1
            total = (0.01 + wg * (1 / (n + 1) - 1 / (n + 2))) / (wf + wg / (n + 1) + 0.01)
            if special < best_special[0]:
                best_special = (special, n)
            if total < best_total[0]:
                best_total = (total, n)
        print(f"    Example 3.5 with one guard of weight 0.01, {label}:")
        print(f"      posterior weight of the special guard alone: minimum over n = {best_special[0]:.4f} at n = {best_special[1]}"
              f" (so 'at least 0.0194' is false for this term at small n)")
        print(f"      probability of an unfaithful call at d = theta0 = n + 1 (all live guards): minimum over n"
              f" = {best_total[0]:.5f} at n = {best_total[1]}")
    q = (1 / 101 - 1 / (10 ** 9 + 1)) / (1 + 1 / 101)
    L = 10
    print(f"    per-call mixture at date d >> n = 100, L = {L}: each call unfaithful with probability q = {q:.5f}, independently;")
    print(f"      Pr[all L calls unfaithful] = q^L = {q ** L:.2e}; Pr[at least one] = {1 - (1 - q) ** L:.4f};"
          f" with one posterior draw per run both are q = {q:.5f}")


def part_D(rng):
    print("== D: Corollary 1.12")
    worst = math.inf
    for _ in range(200000):
        s = int(rng.integers(2, 9))
        p = rng.dirichlet(np.full(s, rng.choice([0.1, 1.0, 5.0])))
        nu = rng.dirichlet(np.full(s, rng.choice([0.1, 1.0, 5.0])))
        if rng.random() < 0.3:          # make nu sparse
            nu = nu * (rng.random(s) < 0.5)
            if nu.sum() == 0:
                continue
            nu = nu / nu.sum()
        eta = float(rng.choice([1e-3, 0.01, 0.1, 0.5, 0.9]))
        q = (1 - eta) * nu + eta / s
        a = 0.5 * np.abs(p - nu).sum()
        klv = float(np.sum(np.where(p > 0, p * np.log(np.where(p > 0, p, 1.0) / q), 0.0)))
        bound = math.log(1 / (1 - eta)) + a * (1 + math.log(s / eta))
        worst = min(worst, bound - klv)
    print(f"    min over 200000 random (p, nu, eta) of [bound - KL(p || nu^eta)] = {worst:.6f} (>= 0)")
    K0, gam, s, eta = 100.0, 1e-5, 4, 0.01
    c = 1 + math.log(s / eta)
    nstar = math.sqrt(2 * K0 * LN2 / (gam * c))
    kap = lambda n: K0 * LN2 / n + math.log(1 / (1 - eta)) + gam * (n + 1) / 2 * c
    grid = min(range(1, 200000), key=kap)
    print(f"    linear drift, K = {K0:g}, gamma = {gam:g}, s = {s}, eta = {eta}: n* = {nstar:.1f}; argmin over integers = {grid}")


def part_E():
    print("== E: Theorem 6.1")
    # (1) tolerance, brute force: B units of 2m+1 equal answers; replace at most m answers in all
    ok = True
    for m, B in ((1, 2), (2, 2), (1, 3)):
        Lc = B * (2 * m + 1)
        for truth in itertools.product((0, 1), repeat=B):
            answers = [truth[b] for b in range(B) for _ in range(2 * m + 1)]
            out = max(truth)
            for r in range(m + 1):
                for pos in itertools.combinations(range(Lc), r):
                    a = list(answers)
                    for i in pos:
                        a[i] = 1 - a[i]
                    vals = [1 if sum(a[b * (2 * m + 1):(b + 1) * (2 * m + 1)]) >= m + 1 else 0 for b in range(B)]
                    ok &= (max(vals) == out)
    print(f"    part 1 (m faults never change the outcome), brute force for (m, B) in (1,2), (2,2), (1,3): {ok}")
    # (2) the scan protocols: scan c of the m_b blocks completely; exact failure and question count
    print("    part 2: scan c blocks, m_b = 6, B = 3, N = 30 (delta = 0.05):  n,  exact average failure,  bound")
    m_b, B, N = 6, 3, 30
    p = 1 - (1 - 1 / N) ** B
    good = True
    for c in range(m_b + 1):
        n = c * (N - 1) * (N + 2) / (2 * N)
        fail = (1 - c / m_b) * p
        low = p * (1 - 2 * B / N - 2 * n / (m_b * N))
        good &= fail >= low - 1e-12
        print(f"      c = {c}: n = {n:7.2f}, failure = {fail:.5f}, bound = {low:.5f}")
    print(f"      bound never exceeds the failure of these protocols: {good}")
    # half-scans (stop a block after N/2 cells): failure of a block = p/2, questions about 3N/8
    n_half = m_b * (sum(min(i, N // 2) for i in range(1, N + 1)) / N)
    fail_half = p * 0.5
    print(f"      half-scan of every block: n = {n_half:.2f}, failure = {fail_half:.5f},"
          f" bound = {p * (1 - 2 * B / N - 2 * n_half / (m_b * N)):.5f}")
    # (3), (4) arithmetic
    for m_b, B, m, delta in ((10, 5, 0, 0.05), (10, 5, 50, 0.05), (1000, 50, 5, 0.01)):
        N = B / (2 * delta)
        K = m_b * math.log2(N)
        L = B * (2 * m + 1)
        low = (1 - 10 * delta) * m_b * B / (8 * delta)
        low2 = (1 - 10 * delta) * K * B / (8 * delta * math.log2(B / (2 * delta)))
        up = L * K * LN2 / ((m + 1) * delta)
        fac = 16 * LN2 * math.log2(B / (2 * delta)) / (1 - 10 * delta)
        ab = 1 + 2.7 * K * L / ((m + 1) * delta * math.log2(L / ((m + 1) * delta)))
        ab_bound = 1 + 5.4 * K * B / (delta * math.log2(B / delta))
        print(f"    m_b = {m_b}, B = {B}, m = {m}, delta = {delta}: lower {low:.4g} = {low2:.4g}; R3 {up:.4g};"
              f" ratio {up / low:.1f} <= {fac:.1f};  Prop. A2: {ab:.4g} <= {ab_bound:.4g}; A2/lower = {ab / low:.1f} (<= {44 / (1 - 10 * delta):.0f})")
    c = (1 - 10 * 0.05) * 5 / (8 * 0.05 * math.log2(50))
    print(f"    Section 6.2: B = 5, delta = 0.05: n >= {c:.6f} K;  n = 50 allows K <= {50 / c:.2f};"
          f"  n = 10^4 allows K <= {1e4 / c:.1f}  (the text says 2^9033)")
    print(f"      in whole blocks (K = m_b log2 50, n >= 6.25 m_b): n = 50 -> m_b <= 8, K <= {8 * math.log2(50):.2f};"
          f" n = 10^4 -> m_b <= 1600, K <= {1600 * math.log2(50):.1f}")
    hy = 8765.82
    print(f"    Section 6.2 units: 6.9e4 answers of one hour = {69315 / hy:.2f} years of 8765.82 h (round the clock)"
          f" = {69315 / 2000:.1f} working years of 2000 h;  6.9e10 answers = {6.9315e10 / hy:.3g} resp. {6.9315e10 / 2000:.3g}")
    print(f"      certificate: ln 20/(theta delta) = {math.log(20) / 0.01:.1f} (theta = delta = 0.1);"
          f" pass probability of an imitator with mismatch rate rho over m = 300 rounds:"
          f" rho = 0.01: {0.99 ** 300:.3f}, rho = 0.001: {0.999 ** 300:.3f}, rho = 0.0001: {0.9999 ** 300:.3f}")


def part_F(rng):
    print("== F: Theorem 7.4 and Proposition 7.5(b), exact Markov chain over the set of unrefuted members")
    N, L = 12, 3
    f = np.zeros(N, dtype=int)

    def run_inputs(g, z):
        xs = [z]
        for _ in range(L - 1):
            xs.append((xs[-1] + 1 + 3 * int(g[xs[-1]])) % N)
        return xs

    def run_dist(g, h):
        return sum(any(h[x] != g[x] for x in run_inputs(g, z)) for z in range(N)) / N

    for label in ("separated class", "class with one patch of the human", "human outside the class (a patch of member 0)"):
        members = [f.copy()]
        while len(members) < 7:
            g = np.zeros(N, dtype=int)
            g[rng.choice(N, N // 2, replace=False)] = 1
            members.append(g)
        human = f
        if label.startswith("class with one patch"):
            g = f.copy()
            g[5] = 1
            members.append(g)
        if label.startswith("human outside"):
            human = f.copy()
            human[5] = 1
        H = len(members)
        w = np.full(H, 1.0 / H)
        dists = [run_dist(human, g) for g in members]
        in_class = any(d == 0 for d in dists)
        delta = min(d for d in dists if d > 0)
        eps_dag = min(dists)
        K = math.log2(H)
        # chain over alive sets (bitmask)
        dist = {(1 << H) - 1: 1.0}
        rows = []
        for n in range(0, 61):
            off = 0.0     # expected posterior weight off the run class of the human
            Wn = 0.0      # expected weight of the consistent members
            for mask, pr in dist.items():
                alive = [i for i in range(H) if mask >> i & 1]
                if not alive:
                    continue
                tw = sum(w[i] for i in alive)
                Wn += pr * tw
                off += pr * sum(w[i] for i in alive if dists[i] > 0) / tw
            rows.append((n, off, Wn))
            new = {}
            for mask, pr in dist.items():
                alive = [i for i in range(H) if mask >> i & 1]
                if not alive:
                    new[mask] = new.get(mask, 0.0) + pr
                    continue
                tw = sum(w[i] for i in alive)
                for i in alive:
                    for z in range(N):
                        xs = run_inputs(members[i], z)
                        for x in xs:
                            nm = mask
                            for j in alive:
                                if members[j][x] != human[x]:
                                    nm &= ~(1 << j)
                            new[nm] = new.get(nm, 0.0) + pr * (w[i] / tw) / N / L
            dist = new
        print(f"    {label}: {H} members, K = {K:.2f} bits, least positive run distance to the human = {delta:.4f},"
              f" eps_dagger = {eps_dag:.4f}")
        if in_class:
            okk = all(off <= 2 ** K * (1 - delta / (2 * L)) ** n + 1e-12 for n, off, _ in rows)
            print(f"      E[posterior weight off the run class] at n = 0, 10, 20, 40, 60: "
                  + ", ".join(f"{rows[n][1]:.5f}" for n in (0, 10, 20, 40, 60))
                  + f";  bound 2^K (1 - delta/(2L))^n: " + ", ".join(f"{min(1.0, 2 ** K * (1 - delta / (2 * L)) ** n):.5f}" for n in (0, 10, 20, 40, 60))
                  + f"   ({'holds' if okk else 'VIOLATED'})")
        else:
            okk = all(Wn <= (1 - eps_dag / (2 * L)) ** n + 1e-12 for n, _, Wn in rows)
            print(f"      E[W_(n+1)] at n = 0, 10, 20, 40, 60: " + ", ".join(f"{rows[n][2]:.5f}" for n in (0, 10, 20, 40, 60))
                  + f";  bound (1 - eps/(2L))^n: " + ", ".join(f"{(1 - eps_dag / (2 * L)) ** n:.5f}" for n in (0, 10, 20, 40, 60))
                  + f"   ({'holds' if okk else 'VIOLATED'})")


def part_G():
    print("== G: Example 7.6 (N = 100)")
    N = 100
    for k in (0, 1, 10, 50):
        # class {0 (1/4), 1 (1/4), needles (1/(2N) each)}, human = needle at x0, k distinct questions
        # outside x0 answered 0 (for k >= 1 the constant 1 is refuted)
        mass_f = 0.25
        mass_g = 0.25 if k == 0 else 0.0
        needles = (N - k) / (2 * N)
        right = (1 / (2 * N) + mass_g) / (mass_f + mass_g + needles)
        print(f"    human = needle, {k:2d} questions outside x0: mixture wrong at x0 with probability {1 - right:.5f}"
              f"  (1 - 2/N = {1 - 2 / N:.2f})")
    for k in (1, 10, 50, 90):
        fail = ((N - k) / N) * (1 / (2 * N)) / (0.25 + (N - k) / (2 * N))
        print(f"    human = 0, {k:2d} distinct questions: a run of the mixture fails with probability {fail:.5f}"
              f"  (2/(3N) = {2 / (3 * N):.5f})")


def part_H(rng):
    print("== H: Propositions 2.4(b), 2.5; Remark 2.6")
    worst = math.inf
    for _ in range(20000):
        m = int(rng.integers(1, 40))
        w = rng.dirichlet(np.ones(m + 3))[:m]
        worst = min(worst, float(np.mean(np.log2(1 / w))) - math.log2(m))
    print(f"    min of mean log2(1/w) - log2|S| over 20000 random sub-probability weightings: {worst:.4f} (>= 0)")
    worst_gap, worst_id = math.inf, 0.0
    for _ in range(100000):
        s = int(rng.integers(2, 8))
        a = rng.dirichlet(np.full(s, rng.choice([0.2, 1.0, 5.0])))
        p = rng.dirichlet(np.full(s, rng.choice([0.2, 1.0, 5.0])))
        rho = 1 - float(a @ p)
        worst_gap = min(worst_gap, rho - 0.5 * float(np.abs(a - p).sum()))
        worst_id = max(worst_id, abs(float(((a - p) ** 2).sum()) - (2 * rho - (1 - float(a @ a)) - (1 - float(p @ p)))))
    print(f"    min (mismatch probability - TV) = {worst_gap:.2e};  max error of the L2 identity = {worst_id:.2e}")
    # for A = P the mismatch rate is 1 - sum P^2: the certificate (a) cannot be attained
    for pmax in (1.0, 0.99, 0.9, 0.5):
        rho = 1 - (pmax ** 2 + (1 - pmax) ** 2)
        print(f"    perfect imitator of a human who gives the modal answer with probability {pmax}:"
              f" mismatch rate {rho:.4f}; Pr[no mismatch in 300 rounds] = {(1 - rho) ** 300:.3g}")


def part_I():
    print("== I: H^2/KL (H^2 = 1 - sum sqrt(pq))")
    for eps in (0.1, 0.01, 0.001):
        p, q = np.array([0.5, 0.5]), np.array([0.5 + eps, 0.5 - eps])
        print(f"    p = (1/2, 1/2), q = (1/2 + {eps}, 1/2 - {eps}): H^2/KL(p||q) = "
              f"{(1 - np.sqrt(p * q).sum()) / float((p * np.log(p / q)).sum()):.4f}")
        print(f"    p = point mass, q = (1 - {eps}, {eps}):          H^2/KL(p||q) = "
              f"{(1 - math.sqrt(1 - eps)) / math.log(1 / (1 - eps)):.4f}")


if __name__ == "__main__":
    rng = np.random.default_rng(SEED)
    print(f"seed {SEED}")
    part_A()
    part_B(rng)
    part_C()
    part_D(rng)
    part_E()
    part_F(rng)
    part_G()
    part_H(rng)
    part_I()
