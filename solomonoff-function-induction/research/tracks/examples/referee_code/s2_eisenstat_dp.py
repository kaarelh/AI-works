"""s2 (referee, run 2): independent checks for Eisenstat's example (H6).

Written from scratch; it does not import the track's code.

(a) Exact forward DP over the frontier chain (states: touching with top head / top tail,
    (A,U) heads ahead with U unrevealed tails, (B,U) heads behind with U unrevealed heads),
    truncated at U <= UMAX with the truncated mass reported.  Exact (to truncation) values of
      * E[N_touch(n)], E[L_P*(n)], and their limits 3 and 3 kappa;
      * Pr[eta_n < tau_n] (Lemma 3.5) against 20 exp(-n/18);
      * the brief's rule ("tail iff x_t = smallest unrevealed index"): E[#errors up to n],
        Pr[no error up to n]; limits 2 and 1/2 derived in the referee report.
(b) kappa at 50 digits (mpmath); phi = 1/2 for the A-walk by value iteration from 0.
(c) Independent simulator of the process: E[UB_n]/n, Var(UB_n)/n, E[g_n] - (n/2 + 1/2),
    an entropy estimate of g_n against the bound log2(n/2+3/2)+log2 e, and the exact
    conditional surprisal -log2 Pr[D_n | dom D_n] (Prop 3.7(2), implemented independently
    from Z(S)), whose mean is the optimal order-free expected loss H(D_n | dom D_n).
(d) Prop 3.7(2): exact check, by enumerating all labellings of a domain that are reachable
    (Lemma-3.1 structure), that Pr[D | S] = C(n,H) r^(M-n) / Z(S) sums to 1 over the
    reachable labellings, for all domains S of size n <= 7 inside [0, 12); and the
    counterexample to "depends only on the number of heads".

Seed 20261012.  Output: s2_eisenstat_dp_output.txt (next to this file).
"""
import itertools
import math
import os
from fractions import Fraction

import mpmath
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []
LOG3 = math.log2(3)
H13 = LOG3 - 2 / 3


def say(*a):
    s = " ".join(str(x) for x in a)
    print(s, flush=True)
    OUT.append(s)


# ---------------------------------------------------------------- (a)
def dp(nmax, UMAX=400, DMAX=400):
    """Forward DP.  State vector: Th, Tt (touching, top head / top tail), A[1..UMAX], B[1..UMAX].
    Tracks probability mass, and accumulates E[P* loss], E[touching steps], E[rule errors],
    Pr[no rule error so far] (as a separate 'clean' copy of the chain)."""
    # touching outcomes: head at F+d with prob (2/9)(2/3)^d ; tail at F+d with prob (2/9)(1/3)^d
    d = np.arange(DMAX)
    ph = (2 / 9) * (2 / 3) ** d
    pt = (2 / 9) * (1 / 3) ** d
    loss_touch = float(np.sum(ph * np.log2(1 + 2.0 ** (-d)) + pt * np.log2(1 + 2.0 ** d)))
    err_touch = ph[0] + pt[1:].sum()          # rule errs: head at d=0, tail at d>=1
    # A-walk: tail (1/3) U-1 ; head (2/3) skipping j tails, prob (1/3)(2/3)^j: U+j
    # B-walk: head (2/3) U-1 ; tail (1/3) skipping j heads, prob (2/3)(1/3)^j: U+j
    jA = (1 / 3) * (2 / 3) ** np.arange(UMAX + 1)
    jB = (2 / 3) * (1 / 3) ** np.arange(UMAX + 1)

    def step(Th, Tt, A, B, clean):
        """One step. If clean, drop the mass of paths on which the rule errs at this step."""
        T = Th + Tt
        nTh = T * ph[0]
        nTt = T * pt[0]
        nA = np.zeros(UMAX + 1)
        nB = np.zeros(UMAX + 1)
        nA[1:] += T * ph[1:UMAX + 1] if not clean else T * ph[1:UMAX + 1]
        if not clean:
            nB[1:] += T * pt[1:UMAX + 1]
            # head at d=0 -> Th (error), counted above in nTh
        else:
            nTh = 0.0                      # head at d=0 is an error for the rule
        # A transitions (never an error)
        for U in range(1, UMAX + 1):
            m = A[U]
            if m == 0.0:
                continue
            down = m * (1 / 3)
            if U - 1 == 0:
                nTh += down
            else:
                nA[U - 1] += down
            up = m * (2 / 3) * jA[:UMAX + 1 - U]
            nA[U:] += up
        if not clean:
            for U in range(1, UMAX + 1):
                m = B[U]
                if m == 0.0:
                    continue
                down = m * (2 / 3)
                if U - 1 == 0:
                    nTt += down
                else:
                    nB[U - 1] += down
                up = m * (1 / 3) * jB[:UMAX + 1 - U]
                nB[U:] += up
        return nTh, nTt, nA, nB

    Th, Tt = 1.0, 0.0
    A = np.zeros(UMAX + 1)
    B = np.zeros(UMAX + 1)
    cTh, cTt, cA, cB = 1.0, 0.0, np.zeros(UMAX + 1), np.zeros(UMAX + 1)
    E_touch = E_loss = E_err = 0.0
    rows = {}
    for n in range(1, nmax + 1):
        T = Th + Tt
        E_touch += T
        E_loss += T * loss_touch
        E_err += T * err_touch + B[1:].sum()
        Th, Tt, A, B = step(Th, Tt, A, B, clean=False)
        cTh, cTt, cA, cB = step(cTh, cTt, cA, cB, clean=True)
        mass = Th + Tt + A.sum() + B.sum()
        behind = Tt + B.sum()
        rows[n] = dict(touch=E_touch, loss=E_loss, err=E_err, clean=cTh + cTt + cA.sum() + cB.sum(),
                       behind=behind, mass=mass)
    return rows, loss_touch


def part_a():
    say("(a) exact forward DP over the frontier chain (truncation U <= 400; 'mass' = retained probability)")
    rows, kap = dp(400)
    say(f"    kappa (from DP setup) = {kap:.12f}")
    say("      n | E[N_touch(n)]  E[L_P*(n)]  E[L_P*]/kappa | E[#rule errors]  P(no rule error) | "
        "P(eta_n<tau_n)    20exp(-n/18) | mass")
    for n in [1, 2, 5, 10, 20, 40, 80, 160, 400]:
        r = rows[n]
        say(f"    {n:4d} | {r['touch']:13.9f} {r['loss']:11.9f} {r['loss']/kap:13.9f} | {r['err']:15.9f} "
            f"{r['clean']:17.9f} | {r['behind']:.6e} {min(1.0, 20*math.exp(-n/18)):.6e} | {r['mass']:.12f}")
    say("    limits claimed: E[N_touch] -> 3, E[L_P*] -> 3 kappa = 2.39855, E[#rule errors] -> 2, P(no error) -> 1/2")


# ---------------------------------------------------------------- (b)
def part_b():
    say("")
    mpmath.mp.dps = 50
    kap = mpmath.nsum(lambda d: mpmath.mpf(2) / 9 * ((mpmath.mpf(2) / 3) ** d * mpmath.log(1 + 2 ** (-d), 2)
                                                     + (mpmath.mpf(1) / 3) ** d * mpmath.log(1 + 2 ** d, 2)),
                      [0, mpmath.inf])
    say(f"(b) kappa = {mpmath.nstr(kap, 30)} ; 3 kappa = {mpmath.nstr(3 * kap, 30)}")
    # phi: probability the A-walk ever goes one level down; minimal fixed point of
    # phi = 1/3 + (2/3) sum_j (1/3)(2/3)^j phi^(j+1)
    phi = mpmath.mpf(0)
    for _ in range(400):
        phi = mpmath.mpf(1) / 3 + mpmath.mpf(2) / 3 * phi / (3 - 2 * phi)
    say(f"    phi by value iteration from 0 (400 iterations) = {mpmath.nstr(phi, 20)} (claim 1/2)")
    ret = mpmath.mpf(4) / 9 + mpmath.nsum(lambda d: mpmath.mpf(2) / 9 * (mpmath.mpf(2) / 3) ** d * phi ** d, [1, mpmath.inf]) \
        + mpmath.nsum(lambda d: mpmath.mpf(2) / 9 * (mpmath.mpf(1) / 3) ** d, [1, mpmath.inf])
    say(f"    return probability to touching = {mpmath.nstr(ret, 20)} (claim 2/3)")
    # expected B-excursion length from touching (all errors of the rule): sum_d (2/9)(1/3)^d * 2d
    eb = mpmath.nsum(lambda d: mpmath.mpf(2) / 9 * (mpmath.mpf(1) / 3) ** d * 2 * d, [1, mpmath.inf])
    say(f"    rule: expected errors per touching step = 2/9 + 1/9 + E[B-excursion length] = "
        f"{mpmath.nstr(mpmath.mpf(3)/9 + eb, 15)} (=2/3); times E[N_touch]=3 gives 2")


# ---------------------------------------------------------------- (c)
def simulate(n, rng):
    """Run the process for n steps with lazily drawn b. Returns tau, T, g, eta, revealed dict."""
    b = []

    def bit(i):
        while len(b) <= i:
            b.append(1 if rng.random() < 1 / 3 else 0)
        return b[i]

    tau = eta = 0
    nxt_h = nxt_t = 0
    lab = {}
    T = 0
    for _ in range(n):
        if rng.random() < 2 / 3:
            i = nxt_h
            while bit(i) != 1:
                i += 1
            lab[i] = 1
            nxt_h = i + 1
            eta = i + 1
        else:
            i = nxt_t
            while bit(i) != 0:
                i += 1
            lab[i] = 0
            nxt_t = i + 1
            tau = i + 1
            T += 1
    g = 0
    while g in lab:
        g += 1
    return tau, T, g, eta, lab


def log2binom(a, k):
    return (math.lgamma(a + 1) - math.lgamma(k + 1) - math.lgamma(a - k + 1)) / math.log(2)


def surprisal_given_domain(lab, n):
    """-log2 Pr[D_n = D | dom D_n = S] from Prop 3.7, recomputed independently."""
    S = sorted(lab)
    M = S[-1] + 1
    g = 0
    while g in lab:
        g += 1
    H = sum(lab.values())
    e = M - n
    if g == M:
        logZ = log2binom(2 * n, n)
        lognum = log2binom(n, H)
    else:
        # Z = ((2/3)^e + (1/3)^e) C(n+g, g);  numerator C(n,H) r^e
        logZ = log2binom(n + g, g) + e * math.log2(2 / 3) + math.log2(1 + 2.0 ** (-e))
        r = 2 / 3 if lab[S[-1]] == 1 else 1 / 3
        lognum = log2binom(n, H) + e * math.log2(r)
    return logZ - lognum


def part_c(rng):
    say("")
    say("(c) independent simulation")
    say("      n  runs | E[UB]/n (se)          Var(UB)/n | E[g]-(n/2+1/2) (se) | H_plugin(g) bound | "
        "E[-log P(D|S)]/n (se)   minus h/2")
    for n, R in [(100, 4000), (1000, 2000), (10000, 300)]:
        UB, G, BX = [], [], []
        for _ in range(R):
            tau, T, g, eta, lab = simulate(n, rng)
            UB.append(tau * LOG3 - T)
            G.append(g)
            BX.append(surprisal_given_domain(lab, n))
        UB = np.array(UB)
        G = np.array(G)
        BX = np.array(BX)
        vals, cnts = np.unique(G, return_counts=True)
        p = cnts / cnts.sum()
        Hplug = float(-(p * np.log2(p)).sum())
        bound = math.log2(n / 2 + 1.5) + math.log2(math.e)
        say(f"    {n:5d} {R:5d} | {UB.mean()/n:.5f} ({UB.std()/n/math.sqrt(R):.5f}) {UB.var()/n:9.4f} | "
            f"{G.mean()-(n/2+0.5):8.3f} ({G.std()/math.sqrt(R):.3f}) | {Hplug:6.3f} <= {bound:6.3f} | "
            f"{BX.mean()/n:.5f} ({BX.std()/n/math.sqrt(R):.5f}) {BX.mean()/n - H13/2:+.5f}")
    say(f"    theory: E[UB]/n = h(1/3)/2 = {H13/2:.6f}; Var/n = 1.04966; E[g] <= n/2 + 1/2 (upper bound only)")


# ---------------------------------------------------------------- (d)
def reachable_labellings(S):
    """All labellings of the finite set S reachable as D_n (Lemma 3.1 structure):
    with tau = 1 + last revealed tail, eta = 1 + last revealed head, every unrevealed index
    below eta is a tail and every unrevealed index below tau is a head, none below min."""
    S = sorted(S)
    M = S[-1] + 1
    out = []
    for labs in itertools.product([0, 1], repeat=len(S)):
        lab = dict(zip(S, labs))
        tails = [i for i in S if lab[i] == 0]
        heads = [i for i in S if lab[i] == 1]
        tau = tails[-1] + 1 if tails else 0
        eta = heads[-1] + 1 if heads else 0
        ok = True
        for i in range(M):
            if i in lab:
                continue
            if i < min(tau, eta):
                ok = False
                break
            if i < eta and i < tau:
                ok = False
                break
        if ok:
            out.append(lab)
    return out


def part_d():
    say("")
    say("(d) Prop 3.7(2) normalisation over reachable labellings, all domains S, |S| = n <= 7, S within [0,12)")
    worst = Fraction(0)
    count = 0
    for n in range(1, 8):
        for S in itertools.combinations(range(12), n):
            labs = reachable_labellings(S)
            if not labs:
                continue
            M = S[-1] + 1
            g = 0
            while g in S:
                g += 1
            e = M - n
            if g == M:
                Z = Fraction(math.comb(2 * n, n))
            else:
                Z = (Fraction(2, 3) ** e + Fraction(1, 3) ** e) * math.comb(n + g, g)
            tot = Fraction(0)
            for lab in labs:
                H = sum(lab.values())
                r = Fraction(2, 3) if lab[S[-1]] == 1 else Fraction(1, 3)
                tot += math.comb(n, H) * r ** e / Z
            worst = max(worst, abs(tot - 1))
            count += 1
    say(f"    {count} domains; max |sum_D Pr[D|S] - 1| = {worst}")
    S = (0, 1, 3)
    say(f"    counterexample to 'depends on the labelling only through the number of heads': domain {S}")
    labs = reachable_labellings(S)
    M = 4
    n = 3
    g = 2
    Z = (Fraction(2, 3) + Fraction(1, 3)) * math.comb(5, 2)
    for lab in labs:
        H = sum(lab.values())
        r = Fraction(2, 3) if lab[3] == 1 else Fraction(1, 3)
        say(f"      labels {tuple(lab[i] for i in S)}  H={H}  Pr[D|S] = {math.comb(n, H) * r ** (M - n) / Z}")


def main():
    rng = np.random.default_rng(20261012)
    say("s2_eisenstat_dp.py  (referee, run 2; seed 20261012)")
    part_a()
    part_b()
    part_c(rng)
    part_d()
    with open(os.path.join(HERE, "s2_eisenstat_dp_output.txt"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
