"""e7: Eisenstat's example (H6), exact quantities for the revision (notes-final.md §3).

The state after each step is one of
  touching (the revealed set is an initial segment [0,F)), split by the label at F-1
  ("TH": head on top, "TT": tail on top, "T0": nothing revealed yet),
  (A,U): heads ahead, U >= 1 unrevealed tails in [tau, eta),
  (B,U): heads behind, U >= 1 unrevealed heads in [eta, tau).
Transitions (proof of Prop 3.9):
  touching: head reveal skipping d tails, prob (2/3)(2/3)^d(1/3): d=0 -> TH, else (A,d);
            tail reveal skipping d heads, prob (1/3)(1/3)^d(2/3): d=0 -> TT, else (B,d);
  (A,U): tail (1/3) -> U-1 (0 -> TH); head (2/3) skipping j tails, prob (2/3)^j (1/3) -> U+j;
  (B,U): head (2/3) -> U-1 (0 -> TT); tail (1/3) skipping j heads, prob (1/3)^j (2/3) -> U+j.

(a) Exact forward DP (U truncated at UMAX; the lost mass is reported):
    Pr[eta_n < tau_n] = P(TT) + P(B) after n steps (Lemma 3.5), E N_touch(n), E L_{P*}(n) = kappa E N_touch(n),
    expected errors of the brief's rule "tail iff the input is the smallest unrevealed index" and
    Pr[no rule error in n steps] (Cor 3.11).
(b) kappa to 40 digits (mpmath); phi by value iteration from 0; return probability; per-touching-step
    rule errors; the closed forms of the limits (3, 3 kappa, 2, 1/2).
(c) Cross-checks of (a) that do not use the state chain:
    (c1) truncated exact enumeration over coins and b-prefixes (exact rationals), n <= 5;
    (c2) seeded direct simulation of the process (lazy b), n = 10, 20, 40.
(d) Var(UB_n) = sigma^2 n exactly: exact computation from the laws of T_n and G (n <= 200) and simulation.

Seed 20261012.  Output: e7_eisenstat_dp.out.txt next to this file.
"""
import itertools
import math
import os
import time
from fractions import Fraction

import numpy as np
import mpmath as mp

HERE = os.path.dirname(os.path.abspath(__file__))
OUTFILE = os.path.join(HERE, "e7_eisenstat_dp.out.txt")
OUT = []
SEED = 20261012
LOG2_3 = math.log2(3.0)


def say(*a):
    s = " ".join(str(x) for x in a)
    print(s, flush=True)
    OUT.append(s)


# ----------------------------------------------------------------------------------------
# (a) forward DP
# ----------------------------------------------------------------------------------------

def dp(nmax, UMAX=1500, checkpoints=()):
    """Float DP; returns dict n -> quantities at the checkpoints."""
    A = np.zeros(UMAX + 1)       # A[U], U >= 1
    B = np.zeros(UMAX + 1)
    TH = TT = 0.0
    T0 = 1.0
    # no-error sub-distribution for the brief's rule
    nA = np.zeros(UMAX + 1)
    nTH = nTT = 0.0
    nT0 = 1.0
    U = np.arange(UMAX + 1)
    # skip laws
    jA = (2.0 / 3.0) ** U * (1.0 / 3.0)          # P(j tails before a head)
    jB = (1.0 / 3.0) ** U * (2.0 / 3.0)          # P(j heads before a tail)
    E_touch = 0.0
    E_err = 0.0
    lost = 0.0
    res = {}
    for s in range(nmax):
        Pt = TH + TT + T0
        PB = B[1:].sum()
        E_touch += Pt
        E_err += Pt * (1.0 / 3.0) + PB
        # --- full distribution step
        nA_ = np.zeros(UMAX + 1)
        nB_ = np.zeros(UMAX + 1)
        newTH = Pt * (2.0 / 3.0) * jA[0]
        newTT = Pt * (1.0 / 3.0) * jB[0]
        nA_[1:] += Pt * (2.0 / 3.0) * jA[1:]
        nB_[1:] += Pt * (1.0 / 3.0) * jB[1:]
        # A walk
        newTH += A[1] * (1.0 / 3.0)
        nA_[1:UMAX] += A[2:] * (1.0 / 3.0)
        conv = np.convolve(A * (2.0 / 3.0), jA)[:UMAX + 1]
        nA_[1:] += conv[1:]
        lost += (A * (2.0 / 3.0)).sum() - conv[1:].sum()
        # B walk
        newTT += B[1] * (2.0 / 3.0)
        nB_[1:UMAX] += B[2:] * (2.0 / 3.0)
        convB = np.convolve(B * (1.0 / 3.0), jB)[:UMAX + 1]
        nB_[1:] += convB[1:]
        lost += (B * (1.0 / 3.0)).sum() - convB[1:].sum()
        # truncation of the touching jumps
        lost += Pt * (1 - (2.0 / 3.0) * jA.sum() - (1.0 / 3.0) * jB.sum())
        A, B = nA_, nB_
        TH, TT, T0 = newTH, newTT, 0.0
        # --- no-error sub-distribution
        nPt = nTH + nTT + nT0
        nnA = np.zeros(UMAX + 1)
        nnTT = nPt * (1.0 / 3.0) * jB[0]              # tail at d = 0: correct
        nnA[1:] += nPt * (2.0 / 3.0) * jA[1:]         # head with d >= 1: correct
        nnTH = nA[1] * (1.0 / 3.0)                    # A walk is error-free
        nnA[1:UMAX] += nA[2:] * (1.0 / 3.0)
        convn = np.convolve(nA * (2.0 / 3.0), jA)[:UMAX + 1]
        nnA[1:] += convn[1:]
        nA = nnA
        nTH, nTT, nT0 = nnTH, nnTT, 0.0
        n = s + 1
        if n in checkpoints:
            res[n] = dict(p_behind=TT + B[1:].sum(), E_touch=E_touch, E_err=E_err,
                          p_noerr=nTH + nTT + nA[1:].sum(), mass=TH + TT + A[1:].sum() + B[1:].sum(),
                          lost=lost)
    return res


def dp_exact_small(nmax):
    """Exact rational DP for small n (no truncation needed: U <= n)."""
    third = Fraction(1, 3)
    st = {('T0', 0): Fraction(1)}
    out = {}
    for s in range(nmax):
        new = {}

        def add(key, p):
            new[key] = new.get(key, 0) + p
        for (kind, u), p in st.items():
            if kind in ('T0', 'TH', 'TT'):
                # finitely many d needed: d up to nmax suffices for the event at horizon nmax? No: the jump
                # size matters only through U; we keep the exact geometric tail lumped in one state 'A>' / 'B>'.
                for d in range(0, nmax + 1):
                    ph = Fraction(2, 3) * Fraction(2, 3) ** d * third
                    pt = third * third ** d * Fraction(2, 3)
                    add(('TH', 0) if d == 0 else ('A', d), p * ph)
                    add(('TT', 0) if d == 0 else ('B', d), p * pt)
                # lumped tails: U > nmax cannot return to touching within the horizon; their side is known
                add(('A>', 0), p * Fraction(2, 3) * (Fraction(2, 3) ** (nmax + 1)))
                add(('B>', 0), p * third * (third ** (nmax + 1)))
            elif kind == 'A':
                add(('TH', 0) if u == 1 else ('A', u - 1), p * third)
                for j in range(0, nmax + 1):
                    add(('A', u + j), p * Fraction(2, 3) * Fraction(2, 3) ** j * third)
                add(('A>', 0), p * Fraction(2, 3) * Fraction(2, 3) ** (nmax + 1))
            elif kind == 'B':
                add(('TT', 0) if u == 1 else ('B', u - 1), p * Fraction(2, 3))
                for j in range(0, nmax + 1):
                    add(('B', u + j), p * third * third ** j * Fraction(2, 3))
                add(('B>', 0), p * third * third ** (nmax + 1))
            elif kind in ('A>', 'B>'):
                add((kind, 0), p)
        # states with U > nmax cannot come back within the horizon; lump them
        st = {}
        for (kind, u), p in new.items():
            if kind == 'A' and u > nmax:
                st[('A>', 0)] = st.get(('A>', 0), 0) + p
            elif kind == 'B' and u > nmax:
                st[('B>', 0)] = st.get(('B>', 0), 0) + p
            else:
                st[(kind, u)] = st.get((kind, u), 0) + p
        n = s + 1
        pb = sum(p for (kind, u), p in st.items() if kind in ('TT', 'B', 'B>'))
        out[n] = pb
    return out


# ----------------------------------------------------------------------------------------
# (c) cross-checks
# ----------------------------------------------------------------------------------------

def run_process(coins, b_bits):
    """Run the process with given coin outcomes (1 = reveal head) and a finite b-prefix.
    Returns (eta, tau) after len(coins) steps, or None if the prefix is too short."""
    revealed = set()
    eta = tau = 0
    for c in coins:
        want = 1 if c else 0
        i = 0
        while True:
            if i >= len(b_bits):
                return None
            if b_bits[i] == want and i not in revealed:
                break
            i += 1
        revealed.add(i)
        if want == 1:
            eta = i + 1
        else:
            tau = i + 1
    return eta, tau


def enum_small(n, Lb):
    """Exact Pr[eta_n < tau_n] restricted to paths that need at most Lb b-bits, and the truncated mass."""
    p_in = Fraction(0)
    p_trunc = Fraction(0)
    for coins in itertools.product((1, 0), repeat=n):
        pc = Fraction(1)
        for c in coins:
            pc *= Fraction(2, 3) if c else Fraction(1, 3)
        # enumerate b prefixes of length Lb with their probabilities
        for b in itertools.product((1, 0), repeat=Lb):
            h = sum(b)
            pb = Fraction(1, 3) ** h * Fraction(2, 3) ** (Lb - h)
            r = run_process(coins, b)
            if r is None:
                p_trunc += pc * pb
            elif r[0] < r[1]:
                p_in += pc * pb
    return p_in, p_trunc


def simulate(n, rng):
    """Direct simulation with lazily drawn b; returns eta<tau, touching count, rule errors, P* loss."""
    b = []
    revealed = set()
    eta = tau = 0
    touch = 0
    errs = 0
    lpstar = 0.0

    def bit(i):
        while len(b) <= i:
            b.append(1 if rng.random() < 1.0 / 3.0 else 0)
        return b[i]

    for t in range(n):
        F = max(eta, tau)
        g = 0
        while g in revealed:
            g += 1
        touching = (g == F)
        want = 1 if rng.random() < 2.0 / 3.0 else 0
        i = 0
        while not (bit(i) == want and i not in revealed):
            i += 1
        x = i
        # P*(1 | h, x)
        if x < F:
            p1 = 1.0 if x < tau else 0.0
        elif not touching:
            p1 = 1.0 if tau <= eta else 0.0
        else:
            d = x - F
            p1 = 2.0 ** d / (2.0 ** d + 1.0)
        p = p1 if want == 1 else 1.0 - p1
        lpstar += -math.log2(p)
        touch += touching
        rule_tail = (x == g)
        errs += (rule_tail != (want == 0))
        revealed.add(i)
        if want == 1:
            eta = i + 1
        else:
            tau = i + 1
    return (eta < tau), touch, errs, lpstar


# ----------------------------------------------------------------------------------------
# (d) exact variance of UB_n
# ----------------------------------------------------------------------------------------

def var_ub_exact(n):
    """E and Var of UB_n = T (log2 3 - 1) + G_T log2 3 with T ~ Bin(n,1/3) independent of G,
    G_j a sum of j i.i.d. Geometric (mean 1/2, var 3/4): computed from the binomial law of T
    and the moments of G_j given j (exact moments, no asymptotics)."""
    a = LOG2_3 - 1
    EX = 0.0
    EX2 = 0.0
    for j in range(n + 1):
        pj = math.comb(n, j) * (1 / 3) ** j * (2 / 3) ** (n - j)
        EG = j * 0.5
        EG2 = j * 0.75 + EG ** 2
        m1 = j * a + LOG2_3 * EG
        m2 = (j * a) ** 2 + 2 * j * a * LOG2_3 * EG + LOG2_3 ** 2 * EG2
        EX += pj * m1
        EX2 += pj * m2
    return EX, EX2 - EX ** 2


def main():
    t0 = time.time()
    rng = np.random.default_rng(SEED)
    say(f"e7_eisenstat_dp.py  seed={SEED}")
    say("")
    # (a)
    cps = (1, 2, 3, 5, 10, 20, 40, 80, 160, 400, 1000)
    res = dp(1000, UMAX=1500, checkpoints=cps)
    say("(a) forward DP over the frontier chain (U <= 1500)")
    say("      n | Pr[eta_n < tau_n] | E N_touch(n) | E L_P*(n)    | E rule errors | Pr[no rule error] | retained mass")
    kap = None
    mp.mp.dps = 50
    kappa = mp.nsum(lambda d: mp.mpf(2) / 9 * ((mp.mpf(2) / 3) ** d * mp.log(1 + mp.mpf(2) ** (-d), 2)
                                                + (mp.mpf(1) / 3) ** d * mp.log(1 + mp.mpf(2) ** d, 2)), [0, mp.inf])
    kap = float(kappa)
    for n in cps:
        r = res[n]
        say(f"   {n:4d} | {r['p_behind']:17.6e} | {r['E_touch']:12.9f} | {kap * r['E_touch']:12.9f} | "
            f"{r['E_err']:13.9f} | {r['p_noerr']:17.9f} | {r['mass']:.15f}")
    # exact rational DP for small n
    ex = dp_exact_small(12)
    say("   exact rational DP (no truncation), Pr[eta_n < tau_n]: " +
        ", ".join(f"n={n}: {float(ex[n]):.6f}" for n in (1, 2, 3, 5, 10, 12)))
    say(f"   float DP vs exact at n = 10: {abs(res[10]['p_behind'] - float(ex[10])):.2e}")
    say("   Lemma 3.5 bound 20 e^{-n/18}: " + ", ".join(f"n={n}: {20*math.exp(-n/18):.3g}" for n in (10, 20, 40, 80, 160)))
    # (b)
    say("")
    say("(b) constants")
    say(f"   kappa = {mp.nstr(kappa, 40)}")
    say(f"   3 kappa = {mp.nstr(3 * kappa, 40)}")
    phi = 0.0
    for _ in range(20000):
        phi = 1 / 3 + (2 / 3) * sum((1 / 3) * (2 / 3) ** j * phi ** (j + 1) for j in range(200))
    say(f"   phi by value iteration from 0: {phi:.12f}   (roots of 2phi^2 - 3phi + 1: 1/2 and 1)")
    ret = Fraction(2, 9) + Fraction(2, 9) + Fraction(1, 9) + Fraction(1, 9)
    say(f"   return probability from touching: 2/9 + 2/9 + 1/9 + 1/9 = {ret}")
    per_touch = Fraction(2, 9) + Fraction(1, 9) + Fraction(4, 9) * Fraction(3, 4)
    # expected B steps per touching step: sum_{d>=1} (2/9)(1/3)^d * 2d = 1/3
    eb = sum(Fraction(2, 9) * Fraction(1, 3) ** d * 2 * d for d in range(1, 200))
    say(f"   expected B-steps per touching step (Wald, drift -1/2): {float(eb):.12f}  (= 1/3)")
    say(f"   rule errors per touching step: 2/9 (head at d=0) + 1/9 (tail at d>=1) + 1/3 (B steps) = 2/3;"
        f" times E N_touch = 3 gives 2")
    say("   Pr[no rule error]: p = (2/9) p + (1/9) p + 4/9 - 1/9  =>  p = 1/2")
    # (c)
    say("")
    say("(c1) truncated exact enumeration over coins and b-prefixes (independent of the state chain)")
    for n, Lb in ((1, 16), (2, 16), (3, 16), (4, 14), (5, 13)):
        p_in, p_tr = enum_small(n, Lb)
        say(f"   n={n}, Lb={Lb}: Pr[eta<tau] in [{float(p_in):.6f}, {float(p_in + p_tr):.6f}]   exact DP: {float(ex[n]):.6f}")
    say("")
    say("(c2) direct simulation (lazy b), seed 20261012")
    for n, runs in ((10, 40000), (20, 40000), (40, 20000)):
        out = [simulate(n, rng) for _ in range(runs)]
        pb = np.mean([o[0] for o in out])
        tc = np.mean([o[1] for o in out])
        er = np.mean([o[2] for o in out])
        ne = np.mean([o[2] == 0 for o in out])
        lp = np.array([o[3] for o in out])
        r = res[n]
        se = lambda v: np.std(v) / math.sqrt(len(v))
        tcs = [o[1] for o in out]; ers = [o[2] for o in out]; nes = [o[2] == 0 for o in out]; pbs = [o[0] for o in out]
        say(f"   n={n:3d}, {runs} runs: Pr[eta<tau] {pb:.5f}+-{se(pbs):.5f} (DP {r['p_behind']:.5f}); "
            f"E N_touch {tc:.4f}+-{se(tcs):.4f} (DP {r['E_touch']:.4f}); "
            f"E rule errors {er:.4f}+-{se(ers):.4f} (DP {r['E_err']:.4f}); Pr[no error] {ne:.4f}+-{se(nes):.4f} (DP {r['p_noerr']:.4f}); "
            f"E L_P* {lp.mean():.4f}+-{lp.std()/math.sqrt(runs):.4f} (DP {kap*r['E_touch']:.4f})")
    # (d)
    say("")
    say("(d) Var(UB_n) / n from the exact laws of T_n and G (finite n), against sigma^2")
    sig2 = (2 / 9) * (1.5 * LOG2_3 - 1) ** 2 + 0.25 * LOG2_3 ** 2
    h2 = (LOG2_3 - 2 / 3) / 2
    for n in (1, 2, 5, 10, 50, 200):
        EX, V = var_ub_exact(n)
        say(f"   n={n:4d}: E UB_n / n = {EX/n:.12f} (h(1/3)/2 = {h2:.12f}); Var / n = {V/n:.12f} (sigma^2 = {sig2:.12f})")
    say("")
    say(f"runtime {time.time() - t0:.0f} s")
    with open(OUTFILE, "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
