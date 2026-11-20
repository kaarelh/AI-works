"""Referee 3: theory checks for robust-runs.md.

1. Theorem 1 (sharp form E sum_t 1[B_t] <= n K / (floor(rho n) + 1) <= K / rho) on small
   random hypothesis classes, majority decoder, chained imitation, with i.i.d. problems
   and with an adaptive adversary that picks, among problems whose run is bad, the one
   with the fewest mistakes.
2. The per-run posterior sampler of Proposition 2 does NOT satisfy Theorem 1: a class
   with K(P) = 1 bit in which it has Theta(n) bad rounds for rho = 1/2, while the
   majority decoder has none and the per-step sampler has O(1).
3. Proposition 2's second claim (prior-averaged equality) with adaptive queries, by exact
   enumeration; and its failure when the test problem is chosen using the human.
4. Slide 30: a per-step error rate e = rho does not make a rho-robust property safe.
5. The hidden-insight class (silent and catch-up humans, note.md Theorem 3 and
   without-a-check.md Section 5): the fewest replaced steps that destroy "ends with the
   right insight", for arbitrary replacements and for omission-only replacements (the
   only mistakes the class-prior majority decoder makes, by Lemma 5 of the second note).

Usage: python3 referee3_theory_checks.py
"""

import itertools
import math

import numpy as np


# ---------------------------------------------------------------------------------------
# 1. Theorem 1 on small random classes
# ---------------------------------------------------------------------------------------

def theorem1_random_classes(trials=300, rounds=400, seed=0):
    print("== 1. Theorem 1 (sharp form) on random finite classes, majority decoder ==")
    rng = np.random.default_rng(seed)
    worst_ratio = 0.0
    rows = []
    for S, n, H, rho in [(12, 6, 40, 0.34), (12, 6, 40, 0.0), (20, 10, 60, 0.25), (20, 10, 60, 0.5)]:
        j = math.floor(rho * n)
        for adversary in [False, True]:
            tot_bad, tot_K = [], []
            for _ in range(trials):
                # hypotheses: random functions on S states; the human is hypothesis 0;
                # other hypotheses agree with it except on a random subset (so they are
                # plausible); prior random.
                P = rng.integers(S, size=S)
                hyps = [P.copy()]
                for _h in range(H - 1):
                    f = P.copy()
                    flip = rng.random(S) < rng.uniform(0.05, 0.6)
                    f[flip] = rng.integers(S, size=int(flip.sum()))
                    hyps.append(f)
                hyps = np.array(hyps)
                w = rng.dirichlet(np.ones(H) * 0.5)
                alive = np.ones(H, dtype=bool)
                K = math.log2(1.0 / w[0])
                problems = np.arange(S)
                bad_count = 0
                last_alive = None
                for _t in range(rounds):
                    if last_alive is None or not np.array_equal(alive, last_alive):
                        last_alive = alive.copy()
                        # majority decoder at every state (label of largest posterior
                        # mass, ties to the smallest label)
                        G = np.empty(S, dtype=int)
                        for x in range(S):
                            mass = np.bincount(hyps[alive, x], weights=w[alive], minlength=S)
                            G[x] = int(np.argmax(mass))
                        runs = {}
                        for x0 in problems:
                            xs = [int(x0)]
                            M = 0
                            for _k in range(n):
                                x = xs[-1]
                                if G[x] != P[x]:
                                    M += 1
                                xs.append(int(G[x]))
                            runs[int(x0)] = (xs, M)
                    if adversary:
                        bad = [int(x0) for x0 in problems if runs[int(x0)][1] > j]
                        x0 = int(min(bad, key=lambda z: runs[z][1])) if bad else int(rng.integers(S))
                    else:
                        x0 = int(rng.integers(S))
                    xs, M = runs[x0]
                    bad_count += int(M > j)
                    k = int(rng.integers(n))
                    xq = xs[k]
                    alive &= hyps[:, xq] == P[xq]
                tot_bad.append(bad_count)
                tot_K.append(K)
            Eb, EK = float(np.mean(tot_bad)), float(np.mean(tot_K))
            bound = n * EK / (j + 1)
            worst_ratio = max(worst_ratio, Eb / bound)
            rows.append((S, n, H, rho, adversary, Eb, bound, EK / rho if rho > 0 else float("inf")))
            print(f"S={S:3d} n={n:3d} |H|={H:3d} rho={rho:<5} adversary={str(adversary):5s}: "
                  f"E sum 1[B_t] = {Eb:7.3f}   n E[K]/(floor+1) = {bound:7.2f}   E[K]/rho = "
                  f"{(EK / rho if rho > 0 else float('inf')):7.2f}")
    print(f"largest ratio (observed / sharp bound): {worst_ratio:.3f}  (must be <= 1 up to noise)\n")


# ---------------------------------------------------------------------------------------
# 2. Per-run posterior sampling breaks Theorem 1
# ---------------------------------------------------------------------------------------

def per_run_sampler_counterexample():
    """H = {P, nu_1..nu_m}, w(P) = 1/2, w(nu_j) = 1/(2m), one problem a_0.
    P walks a_0 -> a_1 -> ... ; nu_j agrees with P except at a_0, where it goes to b_{j,1},
    and on its own branch b_{j,k} -> b_{j,k+1} (P and every other hypothesis send b_{j,k}
    to a sink). So nu_j's run has a mistake at every step (|M| = n). A query at step 0
    (state a_0) refutes every nu; a query at b_{j,k} refutes nu_j only. K(P) = 1 bit.

    Majority decoder: follows P (mass 1/2 against 1/(2m) per alternative): no mistakes.
    Per-run sampler (Proposition 2's imitator): with a alive alternatives, samples one
    with probability a/(a+m); that round is bad for every rho < 1. Exact DP for the
    expected number of bad rounds E(a):
        E(a) (1 - (1-p)(1-1/n)) = p (1 + (1-1/n) E(a-1)),  p = a/(a+m).
    Per-step sampler: simulated; a wrong draw at a_0 is followed, at b_{j,1}, by P's label
    with probability >= 1/2, so its runs have few mistakes."""
    print("== 2. Per-run posterior sampling vs Theorem 1 (K(P) = 1 bit, rho = 1/2) ==")
    rng = np.random.default_rng(1)
    for n in [16, 64, 256, 1024]:
        m = n
        E = [0.0] * (m + 1)
        for a in range(1, m + 1):
            p = a / (a + m)
            E[a] = p * (1 + (1 - 1 / n) * E[a - 1]) / (1 - (1 - p) * (1 - 1 / n))
        # per-step sampler simulation: count rounds with more than n/2 mistakes
        bad_step = []
        for _ in range(200 if n <= 256 else 40):
            alive = np.ones(m, dtype=bool)
            bad = 0
            for _t in range(20 * n):
                a = int(alive.sum())
                if a == 0:
                    break
                Z = 0.5 + a / (2 * m)
                # step 0 at a_0
                states = []
                if rng.random() < (a / (2 * m)) / Z:
                    jj = int(rng.choice(np.flatnonzero(alive)))
                    M = 1
                    states.append(("a", 0))
                    # on branch b_{jj,k}: nu_jj (mass 1/(2m)) says continue; all others say sink
                    k = 1
                    on_branch = True
                    while k < n:
                        states.append(("b", jj, k) if on_branch else ("s",))
                        if on_branch and rng.random() < (1 / (2 * m)) / Z:
                            M += 1
                        else:
                            on_branch = False
                        k += 1
                else:
                    M = 0
                    states = [("a", k) for k in range(n)]
                bad += int(M > n // 2)
                q = states[int(rng.integers(n))]
                if q == ("a", 0):
                    alive[:] = False
                elif q[0] == "b":
                    alive[q[1]] = False
            bad_step.append(bad)
        print(f"n={n:5d} (m = n alternatives): per-run sampler E[bad rounds] = {E[m]:8.2f} "
              f"(= {E[m] / n:.3f} n);  majority decoder: 0;  per-step sampler: "
              f"{np.mean(bad_step):.3f};  Theorem 1 bound K/rho = 2")
    print()


# ---------------------------------------------------------------------------------------
# 3. Proposition 2's second claim with adaptive queries
# ---------------------------------------------------------------------------------------

def prop2_exact(seed=3, cases=200):
    """Small class: S states, runs of length n from x0 = 0, hypotheses = a random set of
    functions, prior random. Adaptive query rule: query the state where the current
    posterior is most uncertain (ties random), T times. Imitator: sample one consistent
    hypothesis from the posterior, output its run. Compute exactly
        Pr_{P ~ prior, queries}[imitator's run has Phi]  and  Pr_{P ~ prior}[P's run has Phi]
    for a random Phi (a random set of runs)."""
    print("== 3. Proposition 2, second claim, exact enumeration with adaptive queries ==")
    rng = np.random.default_rng(seed)
    worst = 0.0
    worst_dep = 0.0
    for _ in range(cases):
        S, n, H, T = 5, 3, 12, 2
        hyps = rng.integers(S, size=(H, S))
        w = rng.dirichlet(np.ones(H))

        def run(h, x0=0):
            xs = [x0]
            for _k in range(n):
                xs.append(int(hyps[h, xs[-1]]))
            return tuple(xs)

        runs0 = [run(h) for h in range(H)]
        allruns = sorted(set(runs0))
        Phi = {r for r in allruns if rng.random() < 0.5}

        def posterior_query_states(alive):
            # adaptive rule: state with the largest posterior entropy of the label
            best, bx = -1.0, 0
            for x in range(S):
                mass = np.bincount(hyps[alive, x], weights=w[alive], minlength=S)
                mass = mass / mass.sum()
                ent = -float(np.sum(mass[mass > 0] * np.log(mass[mass > 0])))
                if ent > best + 1e-12:
                    best, bx = ent, x
            return bx

        lhs = 0.0
        for P in range(H):
            alive = np.ones(H, dtype=bool)
            for _t in range(T):
                x = posterior_query_states(alive)
                alive &= hyps[:, x] == hyps[P, x]
            post = w * alive
            post = post / post.sum()
            lhs += w[P] * float(sum(post[h] for h in range(H) if runs0[h] in Phi))
        rhs = float(sum(w[P] for P in range(H) if runs0[P] in Phi))
        worst = max(worst, abs(lhs - rhs))

        # dependent test problem: x0 chosen using P (the start state at which P's run has
        # Phi_x0 = "visits state 0 again" and the posterior believes it least)
        lhs2, rhs2 = 0.0, 0.0
        for P in range(H):
            alive = np.ones(H, dtype=bool)
            for _t in range(T):
                x = posterior_query_states(alive)
                alive &= hyps[:, x] == hyps[P, x]
            post = w * alive
            post = post / post.sum()
            best = None
            for x0 in range(S):
                hum = int(0 in run(P, x0)[1:])
                imi = float(sum(post[h] for h in range(H) if 0 in run(h, x0)[1:]))
                key = (hum - imi)
                if best is None or key > best[0]:
                    best = (key, hum, imi)
            lhs2 += w[P] * best[2]
            rhs2 += w[P] * best[1]
        worst_dep = max(worst_dep, rhs2 - lhs2)
    print(f"{cases} random cases: max |Pr[imitator has Phi] - Pr[human has Phi]| = {worst:.2e} "
          f"(adaptive queries, test problem fixed)")
    print(f"with the test problem chosen using the human: largest gap Pr[human] - Pr[imitator] = "
          f"{worst_dep:.3f}\n")


# ---------------------------------------------------------------------------------------
# 4. Slide 30
# ---------------------------------------------------------------------------------------

def slide30():
    print("== 4. Per-step error rate e versus rho-robustness ==")
    n = 1000
    e = 0.001
    rho = 0.001
    j = math.floor(rho * n)
    # mistakes: j+1 with probability e*n/(j+1), else 0  -> mean per-step error e
    pfail = e * n / (j + 1)
    print(f"n = {n}, per-step error e = {e}, rho = {rho} (tolerates {j} replaced step): a mistake count "
          f"of {j + 1} with probability {pfail:.2f} (else 0) has per-step error {e} and run failure {pfail:.2f}.")
    for rho in [0.001, 0.01, 0.1]:
        j = math.floor(rho * n)
        print(f"   Markov: failure of a rho-robust property <= e n / (floor(rho n)+1) = "
              f"{min(1.0, e * n / (j + 1)):.4f} for rho = {rho}")
    print()


# ---------------------------------------------------------------------------------------
# 5. Hidden-insight class
# ---------------------------------------------------------------------------------------

def hidden_insight_robustness(n=8, q=3):
    """States (j, a) for one problem (the problem index plays no role); a = 0 means no
    insight. Human with insight k at step t: silent or catch-up. Compute the fewest
    replaced steps that make the run not end with a = k, (i) for arbitrary replacement
    outputs (any (j', a')), (ii) for omission-only replacements: at a replaced step the
    output is (j+1, a), i.e. the step writes nothing."""
    print("== 5. Hidden-insight class: fewest replaced steps destroying 'ends with the right insight' ==")

    def P(state, t, k, catchup):
        j, a = state
        if a == 0 and (j == t or (catchup and j > t)) and j < n:
            return (j + 1, k)
        return (min(j + 1, n), a)

    def min_replacements(t, k, catchup, mode):
        # BFS over (step index, state) with cost = number of replaced steps
        best = None
        frontier = {(0, 0): 0}
        for step in range(n):
            nxt = {}
            for (j, a), c in frontier.items():
                outs = [(P((j, a), t, k, catchup), 0)]
                if mode == "arbitrary":
                    outs += [((jj, aa), 1) for jj in range(n + 1) for aa in range(q + 1)]
                else:
                    outs += [((j + 1, a), 1)]
                for s2, dc in outs:
                    if s2 not in nxt or nxt[s2] > c + dc:
                        nxt[s2] = c + dc
            frontier = nxt
        for (j, a), c in frontier.items():
            if a != k:
                best = c if best is None else min(best, c)
        return best

    for catchup in [False, True]:
        label = "catch-up" if catchup else "silent"
        arb = [min_replacements(t, 1, catchup, "arbitrary") for t in range(n)]
        om = [min_replacements(t, 1, catchup, "omission") for t in range(n)]
        print(f"{label:8s} n={n}: arbitrary replacements: {arb} (by insight step t = 0..{n - 1}); "
              f"omission-only: {om}")
    print("   (catch-up with omissions: n - t replaced steps are needed, i.e. robust with a problem-dependent")
    print("    rho = (n - t - 1)/n against omissions only; against arbitrary replacements one step always suffices)\n")


if __name__ == "__main__":
    theorem1_random_classes()
    per_run_sampler_counterexample()
    prop2_exact()
    slide30()
    hidden_insight_robustness()
