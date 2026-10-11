"""r1: independent checks of the Eisenstat example (examples track, notes section 3).

Referee code. It does NOT import the track's code for any computed quantity; it only
imports `sfi_examples` in part (G), to test that module against this file's own
brute-force values.

(A) Lazy exact enumeration of the process (exact Fractions; every new bit of b is
    drawn by branching, so no fixed tape length is assumed; branches whose index
    reaches the cap are dropped and their mass is reported).
    (A1) law of the data set D_n  vs  Prop 3.7(1): C(n,H) (2/9)^n r^(M-n);
    (A2) conditional law of the labelling given the domain vs Prop 3.7(2), and a
         test of the sentence "depends on the labelling only through the number of
         heads";
    (A3) Lemma 3.8 (P*) vs the brute-force conditional, all t <= n;
    (A4) E[L_P*(n)] and E[N_touch(n)] (Prop 3.9: E L = kappa * E N_touch(n));
    (A5) E[g_n] <= n/2 + 1/2 and H(g_n) <= log2(n/2+3/2) + log2 e (proof of Thm 3.6).
(B) Exact Markov-chain DP over the states touching / (A,U) / (B,U) (U capped), for
    n up to 2000: P(eta_n < tau_n) vs 20 exp(-n/18) (Lemma 3.5); E N_touch(n);
    E L_P*(n); the brief's rule "tail iff x_t = smallest unrevealed index": exact
    expected number of errors and exact P(no error in n steps).
(C) kappa (Prop 3.9) to 30 digits with mpmath; sigma^2 (Prop 3.4(3)).
(D) Direct simulation (own simple implementation) of the process: E[UB_n]/n,
    Var(UB_n)/n, frequency of eta_n < tau_n, E g_n.
(E) Exact first-step probabilities of the touching chain: return probability 2/3,
    and the A-walk descent probability phi = 1/2 (minimal root), numerically by
    value iteration from 0.
(G) The track's code: bayes_xonly_surprisal and threshold_mixture_loss vs this
    file's brute force / naive sums.

Seed 20261011 (parts D, G). Output: r1_eisenstat_independent_output.txt
"""
import math
import os
import sys
from collections import defaultdict
from fractions import Fraction as Fr

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []


def say(*a):
    s = " ".join(str(x) for x in a)
    print(s, flush=True)
    OUT.append(s)


P_H = Fr(1, 3)   # P(b_i = 1) (head)
P_C = Fr(2, 3)   # P(coin says: reveal next head)


# ---------------------------------------------------------------------------
# (A) lazy exact enumeration
# ---------------------------------------------------------------------------

def enumerate_process(n, cap):
    """Yield (history, prob, bits) for every branch of n steps whose indices stay < cap.
    history = tuple of (x, y); bits = dict index -> bit read so far.
    Returns (list_of_branches, lost_mass)."""
    out = []
    lost = [Fr(0)]

    def rec(t, hist, prob, bits, eta, tau):
        if t == n:
            out.append((tuple(hist), prob, dict(bits)))
            return
        for coin, pc in ((1, P_C), (0, 1 - P_C)):
            want = coin
            start = eta if want == 1 else tau
            # walk from start; known bits are fixed, unknown bits branch
            walk(t, hist, prob * pc, bits, eta, tau, want, start)

    def walk(t, hist, prob, bits, eta, tau, want, i):
        while True:
            if i >= cap:
                lost[0] += prob
                return
            if i in bits:
                if bits[i] == want:
                    break
                i += 1
                continue
            # unknown bit: branch
            p_want = P_H if want == 1 else 1 - P_H
            # branch 1: bit == want
            bits[i] = want
            new_eta, new_tau = (i + 1, tau) if want == 1 else (eta, i + 1)
            hist.append((i, want))
            rec(t + 1, hist, prob * p_want, bits, new_eta, new_tau)
            hist.pop()
            # branch 2: bit != want, continue walking
            bits[i] = 1 - want
            walk(t, hist, prob * (1 - p_want), bits, eta, tau, want, i + 1)
            del bits[i]
            return
        new_eta, new_tau = (i + 1, tau) if want == 1 else (eta, i + 1)
        hist.append((i, want))
        rec(t + 1, hist, prob, bits, new_eta, new_tau)
        hist.pop()

    rec(0, [], Fr(1), {}, 0, 0)
    return out, lost[0]


def frontiers(hist):
    eta = tau = 0
    S = set()
    for (i, y) in hist:
        S.add(i)
        if y == 1:
            eta = i + 1
        else:
            tau = i + 1
    g = 0
    while g in S:
        g += 1
    return eta, tau, g, S


def my_pstar(hist, x):
    """Lemma 3.8, re-implemented from the statement."""
    eta, tau, g, S = frontiers(hist)
    F = max(eta, tau)
    if x < F:
        if x < eta:
            return Fr(0)
        if x < tau:
            return Fr(1)
        raise ValueError
    if g == F:  # touching
        d = x - F
        return Fr(2 ** d, 2 ** d + 1)
    return Fr(1) if tau <= eta else Fr(0)


def binom(a, b):
    return math.comb(a, b) if 0 <= b <= a else 0


def part_A():
    say("(A) lazy exact enumeration (exact rationals)")
    for n, cap in [(3, 14), (4, 16), (5, 18), (6, 18)]:
        branches, lost = enumerate_process(n, cap)
        say(f"  n={n}, cap={cap}: {len(branches)} branches, mass outside cap = {float(lost):.3e}")
        # (A1) law of D_n
        lawD = defaultdict(Fr)
        for hist, p, _ in branches:
            lawD[frozenset(hist)] += p
        maxerr = Fr(0)
        cnt = 0
        for D, p in lawD.items():
            S = sorted(i for i, _ in D)
            M = S[-1] + 1
            # D is exact only if every b-pattern producing D fits below cap: M <= cap - 1 suffices
            if M > cap - 1:
                continue
            H = sum(y for _, y in D)
            r = Fr(2, 3) if dict(D)[M - 1] == 1 else Fr(1, 3)
            f = binom(n, H) * Fr(2, 9) ** n * r ** (M - n)
            maxerr = max(maxerr, abs(f - p))
            cnt += 1
        say(f"   (A1) {cnt} data sets with max index < cap-1: max |P(D) - formula| = {maxerr}")
        # (A2) conditional given S
        byS = defaultdict(list)
        for D, p in lawD.items():
            byS[frozenset(i for i, _ in D)].append((D, p))
        maxerr2 = Fr(0)
        ex = None
        for S, lst in byS.items():
            M = max(S) + 1
            if M > cap - 1:
                continue
            g = 0
            while g in S:
                g += 1
            e = M - n
            Z = (Fr(2, 3) ** e + Fr(1, 3) ** e) * binom(n + g, g) if g < M else Fr(binom(2 * n, n))
            tot = sum(p for _, p in lst)
            byH = defaultdict(set)
            for D, p in lst:
                H = sum(y for _, y in D)
                r = Fr(2, 3) if dict(D)[M - 1] == 1 else Fr(1, 3)
                maxerr2 = max(maxerr2, abs(p / tot - binom(n, H) * r ** e / Z))
                byH[H].add(p / tot)
            for H, vals in byH.items():
                if len(vals) > 1 and ex is None:
                    ex = (sorted(S), H, sorted(float(v) for v in vals))
        say(f"   (A2) max |P(D | S) - C(n,H) r^(M-n)/Z(S)| = {maxerr2}")
        if ex:
            say(f"   (A2) counterexample to 'depends only on the number of heads': domain {ex[0]}, "
                f"H={ex[1]}: conditional probabilities {ex[2]}")
        # (A3) P*: conditional of y_t given (h_{t-1}, x_t), for t <= n (exact when x_t < cap - 1)
        worst = Fr(0)
        npairs = 0
        for t in range(1, n + 1):
            br_t, _ = enumerate_process(t, cap)
            px = defaultdict(Fr)
            pxy = defaultdict(Fr)
            for hist, p, _ in br_t:
                h, (x, y) = hist[:-1], hist[-1]
                if max([x] + [i for i, _ in h]) >= cap - 1:
                    continue
                px[(h, x)] += p
                pxy[(h, x, y)] += p
            for (h, x), p in px.items():
                q = pxy[(h, x, 1)] / p
                worst = max(worst, abs(q - my_pstar(h, x)))
                npairs += 1
        say(f"   (A3) {npairs} (history, input) pairs: max |P* - brute force| = {worst}")
        # (A4) E L_P*(n), E N_touch(n)
        EL = 0.0
        EN = Fr(0)
        for hist, p, _ in branches:
            L = 0.0
            for t in range(n):
                h, (x, y) = hist[:t], hist[t]
                eta, tau, g, S = frontiers(h)
                if g == max(eta, tau):
                    EN += p
                q = my_pstar(h, x)
                q = q if y == 1 else 1 - q
                L += -math.log2(q)
            EL += float(p) * L
        tm = float(1 - lost)
        say(f"   (A4) E[L_P*(n)] = {EL/tm:.6f}; E[N_touch(n)] = {float(EN)/tm:.6f}; "
            f"kappa*E[N_touch(n)] = {KAPPA*float(EN)/tm:.6f}  (mass-renormalised)")
        # (A5) E g_n, H(g_n)
        gl = defaultdict(Fr)
        for hist, p, _ in branches:
            gl[frontiers(hist)[2]] += p
        Eg = sum(float(p) * g for g, p in gl.items()) / tm
        Hg = -sum(float(p) / tm * math.log2(float(p) / tm) for g, p in gl.items() if p > 0)
        say(f"   (A5) E g_n = {Eg:.4f} (bound n/2+1/2 = {n/2+0.5}); H(g_n) = {Hg:.4f} "
            f"(bound log2(n/2+3/2)+log2 e = {math.log2(n/2+1.5)+math.log2(math.e):.4f})")
    return


# ---------------------------------------------------------------------------
# (B) exact Markov-chain DP
# ---------------------------------------------------------------------------

def kappa_float(dmax=400):
    return sum((2 / 9) * ((2 / 3) ** d * math.log2(1 + 2.0 ** (-d)) + (1 / 3) ** d * math.log2(1 + 2.0 ** d))
               for d in range(dmax))


KAPPA = kappa_float()


def part_B():
    say("")
    say("(B) exact DP over states: touching-with-heads-ahead (TH), touching-with-tails-ahead (TT),")
    say("    (A,U) heads ahead, (B,U) heads behind; U capped at 400 (truncated mass reported)")
    U = 400
    dmax = U + 1
    # probabilities from touching
    ph = np.array([(2 / 9) * (2 / 3) ** d for d in range(dmax)])  # head reveal skipping d tails
    pt = np.array([(2 / 9) * (1 / 3) ** d for d in range(dmax)])  # tail reveal skipping d heads
    jA = np.array([(1 / 3) * (2 / 3) ** j for j in range(dmax)])  # from A: head reveal skipping j tails
    jB = np.array([(2 / 3) * (1 / 3) ** j for j in range(dmax)])  # from B: tail reveal skipping j heads

    def step(TH, TT, A, B):
        nTH = nTT = 0.0
        nA = np.zeros(U + 1)
        nB = np.zeros(U + 1)
        T = TH + TT
        # from touching
        nTH += T * ph[0]
        nTT += T * pt[0]
        nA[1:] += T * ph[1:U + 1]
        nB[1:] += T * pt[1:U + 1]
        # from A_u
        for u in range(1, U + 1):
            if A[u] == 0:
                continue
            m = A[u]
            # tail reveal (1/3): u-1 ; reaching 0 -> touching with heads ahead
            if u - 1 == 0:
                nTH += m / 3
            else:
                nA[u - 1] += m / 3
            # head reveal (2/3): u + j
            top = min(U - u, dmax - 1)
            nA[u:u + top + 1] += (2 / 3) * m * jA[:top + 1]
        for u in range(1, U + 1):
            if B[u] == 0:
                continue
            m = B[u]
            if u - 1 == 0:
                nTT += 2 * m / 3   # head reveal brings heads frontier to... revealed set initial segment, tails ahead
            else:
                nB[u - 1] += 2 * m / 3
            top = min(U - u, dmax - 1)
            nB[u:u + top + 1] += (1 / 3) * m * jB[:top + 1]
        return nTH, nTT, nA, nB

    # NOTE on flags: after the B-walk returns (a head reveal fills the last unrevealed head
    # below tau), the revealed set is [0, tau) and tau = F > eta: tails ahead (TT).
    # After the A-walk returns, eta = F > tau: heads ahead (TH).
    TH, TT, A, B = 1.0, 0.0, np.zeros(U + 1), np.zeros(U + 1)   # empty history: touching, eta=tau=0 (not behind)
    EN = 0.0
    Eerr = 0.0
    # no-error DP (separate): states touching (flag irrelevant), A_u
    T0, A0 = 1.0, np.zeros(U + 1)
    checkpoints = {10, 20, 40, 80, 160, 200, 1000, 2000}
    say("     n | P(eta_n<tau_n) exact | 20 exp(-n/18) | E N_touch(n) | E L_P*(n)=kappa*E N_touch | rule: E errors(n)  P(no error in n steps)")
    for t in range(1, 2001):
        # quantities "before step t"
        T = TH + TT
        EN += T
        Eerr += T * (1 / 3) + B.sum()
        # no-error chain update for step t
        nT0 = T0 * (2 / 9)                      # tail with d = 0 (correct)
        nA0 = np.zeros(U + 1)
        nA0[1:] += T0 * ph[1:U + 1]             # head with d >= 1 (correct)
        for u in range(1, U + 1):
            if A0[u] == 0:
                continue
            m = A0[u]
            if u == 1:
                nT0 += m / 3
            else:
                nA0[u - 1] += m / 3
            top = min(U - u, dmax - 1)
            nA0[u:u + top + 1] += (2 / 3) * m * jA[:top + 1]
        T0, A0 = nT0, nA0
        TH, TT, A, B = step(TH, TT, A, B)
        if t in checkpoints:
            behind = TT + B.sum()   # eta < tau after t steps
            say(f"  {t:5d} | {behind:.6e}         | {min(1.0, 20*math.exp(-t/18)):.6e}   | {EN:.6f}     | {KAPPA*EN:.6f}                   "
                f"| {Eerr:.6f}          {T0 + A0.sum():.6f}")
    say(f"   mass kept after 2000 steps (cap effect): {TH + TT + A.sum() + B.sum():.12f}")
    say(f"   limits: E N_touch -> 3, E L_P* -> 3 kappa = {3*KAPPA:.6f}; rule: E errors -> 2, P(no error) -> 1/2 "
        "(referee's derivation: per touching step error prob 1/3, plus every step in a B-state errs, "
        "expected B-steps per touching step 1/3; no-error prob p = (2/9)p + (1/9)p + 1/3)")


# ---------------------------------------------------------------------------
# (C) constants
# ---------------------------------------------------------------------------

def part_C():
    import mpmath as mp
    mp.mp.dps = 40
    kap = mp.nsum(lambda d: mp.mpf(2) / 9 * ((mp.mpf(2) / 3) ** d * mp.log(1 + mp.mpf(2) ** (-d), 2)
                                             + (mp.mpf(1) / 3) ** d * mp.log(1 + mp.mpf(2) ** d, 2)), [0, mp.inf])
    say("")
    say(f"(C) kappa = {mp.nstr(kap, 25)}; 3 kappa = {mp.nstr(3*kap, 25)}")
    l3 = mp.log(3, 2)
    sig2 = mp.mpf(2) / 9 * (mp.mpf(3) / 2 * l3 - 1) ** 2 + mp.mpf(1) / 4 * l3 ** 2
    say(f"    sigma^2 = {mp.nstr(sig2, 12)}, sigma = {mp.nstr(mp.sqrt(sig2), 12)}; h(1/3)/2 = {mp.nstr(l3/2 - mp.mpf(1)/3, 12)}; "
        f"log2 3 - 1/3 = {mp.nstr(l3 - mp.mpf(1)/3, 12)}")


# ---------------------------------------------------------------------------
# (D) direct simulation, own implementation
# ---------------------------------------------------------------------------

def simulate(n, rng):
    """Returns tau, T, eta, g after n steps."""
    L = 4 * n + 200
    b = rng.random(L) < 1 / 3          # True = head
    coins = rng.random(n) < 2 / 3      # True = reveal head
    heads = np.flatnonzero(b)
    tails = np.flatnonzero(~b)
    H = int(coins.sum())
    T = n - H
    while H > len(heads) or T > len(tails):   # extend (rare)
        b = np.concatenate([b, rng.random(L) < 1 / 3])
        heads = np.flatnonzero(b)
        tails = np.flatnonzero(~b)
    eta = int(heads[H - 1]) + 1 if H > 0 else 0
    tau = int(tails[T - 1]) + 1 if T > 0 else 0
    revealed = np.zeros(max(eta, tau) + 1, dtype=bool)
    revealed[heads[:H]] = True
    revealed[tails[:T]] = True
    g = int(np.argmin(revealed))
    return tau, T, eta, g


def part_D():
    say("")
    say("(D) direct simulation (own implementation; the set D_n does not depend on the coin order)")
    rng = np.random.default_rng(20261011)
    l3 = math.log2(3)
    for n, R in [(100, 20000), (1000, 20000), (10000, 4000)]:
        ub = np.empty(R)
        beh = 0
        gs = np.empty(R)
        for r in range(R):
            tau, T, eta, g = simulate(n, rng)
            ub[r] = tau * l3 - T
            beh += eta < tau
            gs[r] = g
        say(f"  n={n:6d}, R={R}: E UB/n = {ub.mean()/n:.5f} +- {ub.std()/n/math.sqrt(R):.5f} (claim 0.459148); "
            f"Var(UB)/n = {ub.var()/n:.4f} (claim 1.04966); P(eta<tau) = {beh/R:.5f}; E g_n = {gs.mean():.2f} "
            f"(bound n/2+1/2 = {n/2+0.5})")


# ---------------------------------------------------------------------------
# (E) touching chain constants by iteration
# ---------------------------------------------------------------------------

def part_E():
    say("")
    phi = 0.0
    for _ in range(2000):
        phi = 1 / 3 + (2 / 3) * sum((1 / 3) * (2 / 3) ** j * phi ** (j + 1) for j in range(300))
    ret = 4 / 9 + sum((2 / 9) * (2 / 3) ** d * phi ** d for d in range(1, 300)) + sum((2 / 9) * (1 / 3) ** d for d in range(1, 300))
    say(f"(E) A-walk descent probability (minimal fixed point, iterated from 0): phi = {phi:.10f}; "
        f"return probability to touching = {ret:.10f}")


# ---------------------------------------------------------------------------
# (G) the track's code vs brute force
# ---------------------------------------------------------------------------

def part_G():
    say("")
    say("(G) track code vs referee brute force")
    sys.path.insert(0, os.path.abspath(os.path.join(HERE, "..", "..", "..", "..", "code")))
    import sfi_examples as se
    # bayes_xonly_surprisal vs exact P(D|S) from the enumeration (n = 5)
    n, cap = 5, 18
    branches, lost = enumerate_process(n, cap)
    lawD = defaultdict(Fr)
    for hist, p, _ in branches:
        lawD[frozenset(hist)] += p
    byS = defaultdict(Fr)
    for D, p in lawD.items():
        byS[frozenset(i for i, _ in D)] += p
    worst = 0.0
    cnt = 0
    for hist, p, _ in branches:
        D = frozenset(hist)
        S = frozenset(i for i, _ in D)
        if max(S) + 1 > cap - 3:
            continue
        st = se.EisenstatState()
        for (i, y) in hist:
            st.add(i, y)
        mine = -math.log2(float(lawD[D] / byS[S]))
        worst = max(worst, abs(mine - se.bayes_xonly_surprisal(st)))
        cnt += 1
    say(f"  bayes_xonly_surprisal vs exact -log2 P(D_n|S_n), n=5: {cnt} branches, max |diff| = {worst:.2e}")
    # threshold_mixture_loss vs a naive sum
    rng = np.random.default_rng(20261011)
    worst = 0.0
    for _ in range(200):
        m = int(rng.integers(1, 25))
        idx = rng.choice(60, size=m, replace=False)
        lab = rng.integers(0, 2, size=m)
        from math import lgamma, log

        def lb(h, t):
            return (lgamma(h + 1) + lgamma(t + 1) - lgamma(h + t + 2)) / log(2)
        H, T = int(lab.sum()), m - int(lab.sum())
        tot = 2 ** lb(H, T) / 3
        for s in range(0, 5000):
            pi = 1 / ((s + 1) * (s + 2))
            below = idx < s
            hb, tb = int(lab[below].sum()), int(below.sum() - lab[below].sum())
            if np.all(lab[~below] == 1):
                tot += pi * 2 ** lb(hb, tb) / 3
            if np.all(lab[~below] == 0):
                tot += pi * 2 ** lb(hb, tb) / 3
        # tail s >= 5000 : all below
        tail = 1 / 5001
        tot += 2 * tail * 2 ** lb(H, T) / 3
        mine = -math.log2(tot)
        theirs = se.threshold_mixture_loss(idx, lab)["loss"]
        worst = max(worst, abs(mine - theirs))
    say(f"  threshold_mixture_loss vs naive sum (200 random data sets): max |diff| = {worst:.2e}")


def main():
    say("r1_eisenstat_independent.py (seed 20261011 for simulations)")
    part_A()
    part_B()
    part_C()
    part_D()
    part_E()
    part_G()
    with open(os.path.join(HERE, "r1_eisenstat_independent_output.txt"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
