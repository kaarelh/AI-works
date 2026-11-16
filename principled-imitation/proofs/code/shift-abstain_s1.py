#!/usr/bin/env python3
"""Checks for Section 2 of research/prove-c/shift-abstain.md (S1).

Example 2.2.  X = {x0, a, b}, Y = {0, 1}; the human is f = 0 everywhere; the
only other hypothesis is g with g(x0) = 1, g(a) = 1, g(b) = 0; weights
w(f) = omega, w(g) = 1 - omega.  Scaffold of horizon L: call 1 at x0; if the
answer is 0 the calls 2..L are at a, otherwise they are at b.

Protocol R (rehearsal driven by the mixture, one uniformly chosen call per run
put to the human).  As long as g has not been refuted the posterior equals the
prior, because the only informative questions (x0 and a) refute g at once.

Computed exactly:
  beta_own  = E[ number of unfaithful calls of the run of M^(U) ]         (R1 bounds this)
  beta_hum  = E[ integral of e_U d(d_f) ], d_f the visit measure of the human system
  B         = smallest B with d_f <= B * dbar, dbar the expected average rehearsal
              visit measure
and compared with the candidate's S1, which claims beta_hum <= B * L*K*ln2/n.
A Monte Carlo run of the protocol checks the exact formulas.
Also checked: Proposition 2.3, beta_hum <= B*(2L-1)*beta_own.
"""
import math
import random


def exact(L, omega, n):
    kappa = 1.0 / L + omega * (L - 1) / L          # probability that g is refuted in a round
    alive = [(1 - kappa) ** (t - 1) for t in range(1, n + 1)]   # P[g alive at start of round t]
    own_alive = (1 - omega) * (1 + omega * (L - 1))  # unfaithful calls of M's own run, g alive
    hum_alive = (1 - omega) * L                      # errors of M along the human's run, g alive
    beta_own = sum(alive) * own_alive / n
    beta_hum = sum(alive) * hum_alive / n
    # expected average rehearsal visit measure
    dbar_x0 = 1.0
    dbar_a = (L - 1) * sum((1 - p) + p * omega for p in alive) / n
    B = max(1.0 / dbar_x0, (L - 1) / dbar_a)
    K = math.log2(1 / omega)
    return dict(beta_own=beta_own, beta_hum=beta_hum, B=B, K=K,
                r1_bound=L * K * math.log(2) / n,
                s1_claim=B * L * K * math.log(2) / n,
                repl_bound=B * (2 * L - 1) * beta_own)


def monte_carlo(L, omega, n, reps, seed=1):
    rng = random.Random(seed)
    tot_own = 0.0
    tot_hum = 0.0
    for _ in range(reps):
        alive = True
        u = rng.randrange(1, n + 1)                 # the deployed round U
        for t in range(1, n + 1):
            if t == u:
                # exact conditional expectations given the state at round U
                if alive:
                    tot_own += (1 - omega) * (1 + omega * (L - 1))
                    tot_hum += (1 - omega) * L
                break
            if not alive:
                continue
            # rehearsal run of the mixture (a fresh posterior draw at every call)
            y1 = 1 if rng.random() < 1 - omega else 0
            j = rng.randrange(1, L + 1)
            if j == 1:
                alive = False                        # x0 asked: g refuted
            elif y1 == 0:
                alive = False                        # a asked: g refuted
            # else b asked: no information
    return tot_own / reps, tot_hum / reps


def random_scaffold_check(trials, seed=3):
    """Lemma 1.4 and the core inequality of Proposition 2.3 on random instances:
    X = {0..5}, Y = {0,1}, horizon L = 3, a random adaptive scaffold (the next input is a
    random function of z and the answers so far, and the run may stop early), random
    kernels P (human), C_u, C_t.  Checks, by exact enumeration of all runs,
        int TV(P,C_u) d d_{C_t}  <=  L*beta(C_u) + (L-1)*beta(C_t),
        beta^P(C) <= L*p <= L*beta(C)   and   beta(C) <= L*p,
    where p is the probability that the coupled runs of C and P separate."""
    rng = random.Random(seed)
    L, XN = 3, 6
    worst = [-1e9, -1e9, -1e9]
    for _ in range(trials):
        table = {}

        def nxt(z, ans):
            key = (z, ans)
            if key not in table:
                # stop with probability 0.15 after the first call
                table[key] = None if (len(ans) >= 1 and rng.random() < 0.15) else rng.randrange(XN)
            return table[key]

        def kern():
            return [rng.random() for _ in range(XN)]          # probability of answer 1

        P, Cu, Ct = kern(), kern(), kern()
        if rng.random() < 0.3:                                 # sometimes a deterministic human
            P = [float(rng.randrange(2)) for _ in range(XN)]

        def tvx(A, B, x):
            return abs(A[x] - B[x])

        def visit_integral(C, g):
            """E over runs of C of sum_j g(x_j)."""
            tot = 0.0
            for z in range(3):
                stack = [((), 1.0 / 3)]
                while stack:
                    ans, pr = stack.pop()
                    if len(ans) >= L:
                        continue
                    x = nxt(z, ans)
                    if x is None:
                        continue
                    tot += pr * g(x)
                    for y in (0, 1):
                        py = C[x] if y == 1 else 1 - C[x]
                        if py > 0:
                            stack.append((ans + (y,), pr * py))
            return tot

        def sep_prob(C):
            """Probability that the coupled runs of C and P separate: 1 - sum over runs of
            prod_j min(C, P)(y_j | x_j)."""
            stay = 0.0
            for z in range(3):
                stack = [((), 1.0 / 3)]
                while stack:
                    ans, pr = stack.pop()
                    x = nxt(z, ans) if len(ans) < L else None
                    if x is None:
                        stay += pr
                        continue
                    for y in (0, 1):
                        py = min(C[x], P[x]) if y == 1 else min(1 - C[x], 1 - P[x])
                        if py > 0:
                            stack.append((ans + (y,), pr * py))
            return 1.0 - stay

        beta_u = visit_integral(Cu, lambda x: tvx(P, Cu, x))
        beta_t = visit_integral(Ct, lambda x: tvx(P, Ct, x))
        cross = visit_integral(Ct, lambda x: tvx(P, Cu, x))
        worst[0] = max(worst[0], cross - (L * beta_u + (L - 1) * beta_t))
        p_u = sep_prob(Cu)
        betaP_u = visit_integral(P, lambda x: tvx(P, Cu, x))
        worst[1] = max(worst[1], betaP_u - L * p_u, p_u - beta_u)
        worst[2] = max(worst[2], beta_u - L * p_u)
    return worst


def main():
    print("Example 2.2: exact values (candidate S1 claims beta_hum <= B*L*K*ln2/n)")
    print(f"{'L':>5} {'omega':>8} {'n':>7} {'K':>6} {'beta_own':>10} {'R1 bound':>10} "
          f"{'beta_hum':>10} {'B':>7} {'S1 claim':>10} {'hum/claim':>10} {'(2L-1)B*own':>12}")
    for L, omega, n in [(10, 0.1, 1000), (100, 0.01, 10000), (100, 0.5, 10000),
                        (1000, 0.001, 10 ** 6), (1000, 0.03125, 10 ** 6), (30, 1 / 30, 3000)]:
        r = exact(L, omega, n)
        print(f"{L:>5} {omega:>8.5f} {n:>7} {r['K']:>6.2f} {r['beta_own']:>10.3e} {r['r1_bound']:>10.3e} "
              f"{r['beta_hum']:>10.3e} {r['B']:>7.4f} {r['s1_claim']:>10.3e} "
              f"{r['beta_hum'] / r['s1_claim']:>10.2f} {r['repl_bound']:>12.3e}")
        assert r['beta_own'] <= r['r1_bound'] + 1e-12
        assert r['beta_hum'] <= r['repl_bound'] + 1e-12
        ratio = r['beta_hum'] / r['beta_own']
        assert abs(ratio - L / (1 + omega * (L - 1))) < 1e-9
    print()
    print("Monte Carlo check of the exact formulas (L=10, omega=0.1, n=200, 400000 repetitions)")
    L, omega, n = 10, 0.1, 200
    r = exact(L, omega, n)
    mc_own, mc_hum = monte_carlo(L, omega, n, 400000)
    print(f"  beta_own exact {r['beta_own']:.5f}  simulated {mc_own:.5f}")
    print(f"  beta_hum exact {r['beta_hum']:.5f}  simulated {mc_hum:.5f}")
    print()
    print("ratio beta_hum/beta_own = L/(1+omega*(L-1)); with omega = 1/L it is L/(2-1/L):")
    for L in (10, 100, 1000):
        print(f"  L={L:>5}: ratio {L / (2 - 1 / L):8.2f};  K*ln2 = ln L = {math.log(L):.2f}")
    print()
    w = random_scaffold_check(20000)
    print("Lemma 1.4 and Proposition 2.3 on 20000 random adaptive scaffolds (L = 3), largest value of")
    print(f"  int TV(P,C_u) d d_(C_t) - [L beta(C_u) + (L-1) beta(C_t)] : {w[0]:.3e}  (<= 0)")
    print(f"  max(beta^P(C) - L p, p - beta(C))                       : {w[1]:.3e}  (<= 0)")
    print(f"  beta(C) - L p                                            : {w[2]:.3e}  (<= 0)")


if __name__ == "__main__":
    main()
