"""e1: exact checks for Eisenstat's example (track notes §3).

(a) Brute-force law of the revealed data set D_n for small n, compared with the
    closed form P(D_n = D) = C(n,H) (2/9)^n r^(M-n)   (Prop 3.7(a)),
    r = 2/3 if the largest revealed index is a head, 1/3 if a tail.
(b) The conditional law of the labels given the domain S and the normaliser
    Z(S) = [(2/3)^(M-n) + (1/3)^(M-n)] C(n+g, g)  (gap)  or  C(2n, n)  (no gap)
    (Prop 3.7(b)).
(c) The Bayes history-aware predictor P* (Lemma 3.8) equals the brute-force
    conditional P(y_t | history, x_t) for every reachable history, t <= n.
(d) E[UB_n] = n h(1/3)/2 exactly, from E[tau_n | T_n = j] = 3j/2  (Prop 3.4).
(e) Markov-chain constants (Prop 3.9): return probability 2/3, E[#touching steps] = 3,
    kappa (expected Bayes loss per touching step); simulation cross-check.
(f) P(heads frontier behind at time n) against the Hoeffding bound 20 exp(-n/18) of Lemma 3.5.

Seeded; output saved to e1_eisenstat_exact.out.txt.
"""
import itertools
import math
import os
import sys
from collections import defaultdict
from fractions import Fraction

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, "..", "..", "..", "..", "code")))
import sfi_examples as se  # noqa: E402

OUT = []


def say(*a):
    s = " ".join(str(x) for x in a)
    print(s)
    OUT.append(s)


def run_process(c, b):
    """Deterministic process given reveal coins c (tuple of 0/1) and finite b.
    Returns list of (x, y) or None if an index >= len(b) is needed."""
    eta = tau = 0
    seq = []
    for ct in c:
        if ct == 1:
            i = eta
            while i < len(b) and b[i] != 1:
                i += 1
            if i >= len(b):
                return None
            seq.append((i, 1))
            eta = i + 1
        else:
            i = tau
            while i < len(b) and b[i] != 0:
                i += 1
            if i >= len(b):
                return None
            seq.append((i, 0))
            tau = i + 1
    return seq


def brute_force(n, L):
    """Exact joint law of reveal sequences of length n, using b of length L.
    Returns dict: tuple(seq) -> Fraction probability (only sequences with all indices < L
    are exact; their probability only depends on b below max index + 1 <= L)."""
    law = defaultdict(Fraction)
    ph = Fraction(1, 3)
    pc = Fraction(2, 3)
    for c in itertools.product([0, 1], repeat=n):
        pcv = Fraction(1)
        for ct in c:
            pcv *= pc if ct == 1 else 1 - pc
        for b in itertools.product([0, 1], repeat=L):
            seq = run_process(c, b)
            if seq is None:
                continue
            pb = Fraction(1)
            for bi in b:
                pb *= ph if bi == 1 else 1 - ph
            law[tuple(seq)] += pcv * pb
    return law


def main():
    say("e1_eisenstat_exact.py  (seed 20261011 for the simulation parts)")
    rng = np.random.default_rng(20261011)

    # ---------------- (a) + (b) + (c) ----------------
    for n, L in [(3, 9), (4, 10), (5, 11)]:
        law = brute_force(n, L)
        # law of the data set D (set of pairs) restricted to max index + 1 <= L
        lawD = defaultdict(Fraction)
        for seq, p in law.items():
            lawD[frozenset(seq)] += p
        max_err = Fraction(0)
        ncheck = 0
        for D, p in lawD.items():
            idx = sorted(i for i, _ in D)
            M = idx[-1] + 1
            if M > L:
                continue
            H = sum(y for _, y in D)
            top = dict(D)[M - 1]
            r = Fraction(2, 3) if top == 1 else Fraction(1, 3)
            formula = math.comb(n, H) * Fraction(2, 9) ** n * r ** (M - n)
            max_err = max(max_err, abs(formula - p))
            ncheck += 1
        say(f"(a) n={n}, L={L}: {ncheck} data sets checked, max |P(D) - C(n,H)(2/9)^n r^(M-n)| = {max_err}")
        # (b) conditional on the domain
        lawS = defaultdict(Fraction)
        byS = defaultdict(list)
        for D, p in lawD.items():
            S = frozenset(i for i, _ in D)
            lawS[S] += p
            byS[S].append((D, p))
        max_errZ = Fraction(0)
        nS = 0
        for S, lst in byS.items():
            idx = sorted(S)
            M = idx[-1] + 1
            if M > L:
                continue
            g = 0
            while g in S:
                g += 1
            e = M - n
            if g == M:
                Z = Fraction(math.comb(2 * n, n))
            else:
                Z = (Fraction(2, 3) ** e + Fraction(1, 3) ** e) * math.comb(n + g, g)
            # P(S) predicted = (2/9)^n Z ; compare
            pred = Fraction(2, 9) ** n * Z
            max_errZ = max(max_errZ, abs(pred - lawS[S]))
            nS += 1
        say(f"(b) n={n}: {nS} domains checked, max |P(S) - (2/9)^n Z(S)| = {max_errZ}")
        # (c) P* vs brute-force conditional P(y_t | h_{t-1}, x_t), for every t <= n.
        # The law of the length-t prefix is computed from t-step runs; the event
        # (h_{t-1}, x_t, y_t) depends only on c_1..c_t and on b below x_t + 1 and the
        # earlier indices, so it is exact whenever all indices are < L.
        worst = 0.0
        ncond = 0
        for t in range(1, n + 1):
            law_t = brute_force(t, L)
            pref_x = defaultdict(Fraction)
            pref_xy = defaultdict(Fraction)
            for seq, p in law_t.items():
                h = seq[:t - 1]
                x, y = seq[t - 1]
                pref_x[(h, x)] += p
                pref_xy[(h, x, y)] += p
            for (h, x), p in pref_x.items():
                st = se.EisenstatState()
                for (i, yy) in h:
                    st.add(i, yy)
                p1 = se.pstar_prob_one(st, x)
                q1 = float(pref_xy[(h, x, 1)] / p)
                worst = max(worst, abs(p1 - q1))
                ncond += 1
        say(f"(c) n={n}: {ncond} (history, input) pairs over t=1..{n}, max |P* - brute-force conditional| = {worst:.3e}")

    # ---------------- (d) ----------------
    say("")
    say("(d) E[UB_n] with UB_n = tau_n log2 3 - T_n; E[tau_n | T_n=j] = 3j/2 (NegBin mean j/2 heads)")
    for n in [1, 2, 5, 10, 100, 1000]:
        # exact: sum_j Bin(n,1/3)(j) * (1.5 j log2 3 - j)
        E = sum(math.comb(n, j) * (1 / 3) ** j * (2 / 3) ** (n - j) * (1.5 * j * se.LOG2_3 - j)
                for j in range(n + 1))
        say(f"    n={n:5d}: E[UB_n] = {E:.10f}, n*h(1/3)/2 = {n*se.H13/2:.10f}, diff = {E - n*se.H13/2:.2e}")
    # simulation cross-check of E[tau | T=j]
    sims = []
    for _ in range(20000):
        j = 30
        heads = 0
        tails = 0
        while tails < j:
            if rng.random() < 1 / 3:
                heads += 1
            else:
                tails += 1
        sims.append(heads + tails)
    say(f"    simulated E[tau | T=30] = {np.mean(sims):.3f} (+- {np.std(sims)/math.sqrt(len(sims)):.3f}); 3j/2 = 45")
    say(f"    Var(UB_n)/n (exact, from the NegBin decomposition) = "
        f"{(2/9)*(1.5*se.LOG2_3-1)**2 + (1/3)*(3/4)*se.LOG2_3**2:.5f}")

    # ---------------- (e) ----------------
    say("")
    say("(e) touching-state chain")
    # phi solves 2 phi^2 - 3 phi + 1 = 0, minimal root 1/2
    phi = 0.5
    r_ret = 4 / 9 + sum((2 / 9) * (2 / 3) ** d * phi ** d for d in range(1, 400)) \
        + sum((2 / 9) * (1 / 3) ** d for d in range(1, 400))
    say(f"    return probability r = {r_ret:.12f} (claim 2/3); E[N_touch] = 1/(1-r) = {1/(1-r_ret):.10f} (claim 3)")
    # check phi by simulating the A-walk hitting 0 from 1 (truncate at 200 levels)
    hits = 0
    R = 20000
    for _ in range(R):
        U = 1
        steps = 0
        while 0 < U < 200 and steps < 10000:
            if rng.random() < 1 / 3:
                U -= 1
            else:
                G = 0
                while rng.random() < 2 / 3:
                    G += 1
                U += G
            steps += 1
        hits += (U == 0)
    say(f"    simulated P(A-walk from 1 hits 0) = {hits/R:.4f} (claim 1/2; truncation at level 200)")
    kap = se.kappa_touching()
    say(f"    kappa = E[Bayes loss of one touching step] = {kap:.10f} bits")
    say(f"    E[L_P*(infinity)] = 3 kappa = {3*kap:.10f} bits")
    # simulation of the full process: touching count and P* loss over a long horizon
    tc, lossP = [], []
    for _ in range(2000):
        res = se.simulate_eisenstat(200, rng)
        tc.append(res["touching_steps"])
        lossP.append(res["pstar_losses"].sum())
    tc = np.array(tc)
    lossP = np.array(lossP)
    say(f"    simulated (2000 runs, n=200): E[N_touch] = {tc.mean():.4f} +- {tc.std()/math.sqrt(len(tc)):.4f}; "
        f"P(N_touch=j) for j=1..5: {[round(float(np.mean(tc==j)),4) for j in range(1,6)]} "
        f"(geometric(1/3): {[round((2/3)**(j-1)/3,4) for j in range(1,6)]})")
    say(f"    simulated E[L_P*(200)] = {lossP.mean():.4f} +- {lossP.std()/math.sqrt(len(lossP)):.4f} (claim {3*kap:.4f})")

    # ---------------- (f) ----------------
    say("")
    say("(f) P(eta_n < tau_n) (heads frontier behind) vs bound 20 exp(-n/18) (Lemma 3.5)")
    for n in [10, 20, 40, 80, 160]:
        cnt = 0
        R = 20000
        for _ in range(R):
            # simulate frontiers only
            eta = tau = 0
            b = {}

            def bit(i):
                if i not in b:
                    b[i] = 1 if rng.random() < 1 / 3 else 0
                return b[i]
            for _t in range(n):
                if rng.random() < 2 / 3:
                    i = eta
                    while bit(i) != 1:
                        i += 1
                    eta = i + 1
                else:
                    i = tau
                    while bit(i) != 0:
                        i += 1
                    tau = i + 1
            cnt += (eta < tau)
        say(f"    n={n:4d}: simulated P = {cnt/R:.5f}; bound = {min(1.0, 20*math.exp(-n/18)):.5f}")

    with open(os.path.join(HERE, "e1_eisenstat_exact.out.txt"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
