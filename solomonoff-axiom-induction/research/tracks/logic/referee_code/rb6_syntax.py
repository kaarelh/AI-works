"""rb6_syntax.py -- referee B (thread `logic`): the syntax counts behind Thm 6.1 and the proof
sketch of 6.2, for the developer's 14-symbol Polish syntax (c5):
    terms     0 | S t | + t t | * t t | x'^i  (variable of length i+1)
    formulas  = t t | < t t | ~ f | & f f | | f f | > f f | A v f | E v f
Independent code (not the developer's DP).

No randomness.  Output: rb6_syntax.out (stdout).

S1  Formula counts F(L) three ways: brute-force parsing of all 14^L strings (L <= 5), explicit
    generation from the grammar (L <= 9), and a memoised recursion (L <= 400); compared with each
    other and with c5's printed values F(3)=8, F(5)=162, F(10)=341796, F(20)=3112976679456.
S2  Exact SENTENCE (closed formula) counts s(L), L <= 70, by a recursion on (length, set of variables
    allowed free); cross-checked against brute force (L <= 5) and explicit generation (L <= 9).
    Reported: s(L)/F(L), s(L)/s(L-1), and s(L-5)/s(L) -- the ratio the sketch in 6.2 needs
    bounded below (the decidable set "& ~ = 0 0 psi", psi a sentence, has s(L-5) members of length L).
S3  A RIGOROUS growth bound.  With V(x) = x/(1-x), the generating functions satisfy
        T = x + V + x T + 2 x T^2,     F = 2 x T^2 + x F + 3 x F^2 + 2 x V F.
    If rationals x0, T*, F* > 0 satisfy both equations with ">=" in place of "=" (a super-solution),
    then by monotone iteration from 0 the series converge at x0 and sum_L F(L) x0^L <= F*, so
    #formulas of length <= L is at most (F*/(1-x0)) x0^-L for every L.  The certificate is checked
    in exact rational arithmetic; gamma' = 1/x0 then gives a PROVED exponent
    delta >= 1/(5 log2 gamma') in Thm 6.1 (binary numerals with c_1 = 5), replacing the record's
    numerical delta_wff ~ 0.082 ("computed, not proved").
"""
import itertools
from fractions import Fraction
from functools import lru_cache
from math import log2

SYMS = "0S+*x'=<~&|>AE"
assert len(SYMS) == 14


# ------------------------------------------------------------------ parsing (brute force)
def parse_term(s, i, bound):
    """Return list of (end, freevars) parses of a term starting at i (unique readability: <= 1)."""
    if i >= len(s):
        return None
    c = s[i]
    if c == "0":
        return (i + 1, frozenset())
    if c == "x":
        j = i + 1
        while j < len(s) and s[j] == "'":
            j += 1
        return (j, frozenset([j - i]))           # variable identified by its length
    if c == "S":
        r = parse_term(s, i + 1, bound)
        return r
    if c in "+*":
        r1 = parse_term(s, i + 1, bound)
        if r1 is None:
            return None
        r2 = parse_term(s, r1[0], bound)
        if r2 is None:
            return None
        return (r2[0], r1[1] | r2[1])
    return None


def parse_formula(s, i):
    if i >= len(s):
        return None
    c = s[i]
    if c in "=<":
        r1 = parse_term(s, i + 1, None)
        if r1 is None:
            return None
        r2 = parse_term(s, r1[0], None)
        if r2 is None:
            return None
        return (r2[0], r1[1] | r2[1])
    if c == "~":
        return parse_formula(s, i + 1)
    if c in "&|>":
        r1 = parse_formula(s, i + 1)
        if r1 is None:
            return None
        r2 = parse_formula(s, r1[0])
        if r2 is None:
            return None
        return (r2[0], r1[1] | r2[1])
    if c in "AE":
        if i + 1 >= len(s) or s[i + 1] != "x":
            return None
        j = i + 2
        while j < len(s) and s[j] == "'":
            j += 1
        v = j - (i + 1)
        r = parse_formula(s, j)
        if r is None:
            return None
        return (r[0], r[1] - {v})
    return None


def brute(Lmax):
    F, Sn = {}, {}
    for L in range(1, Lmax + 1):
        f = sn = 0
        for tup in itertools.product(SYMS, repeat=L):
            s = "".join(tup)
            r = parse_formula(s, 0)
            if r is not None and r[0] == L:
                f += 1
                sn += not r[1]
        F[L], Sn[L] = f, sn
    return F, Sn


# ------------------------------------------------------------------ explicit generation
def generate(Lmax):
    """All terms/formulas as (length, freevars) multisets via explicit construction."""
    from collections import Counter
    T = {L: Counter() for L in range(1, Lmax + 1)}
    F = {L: Counter() for L in range(1, Lmax + 1)}
    for L in range(1, Lmax + 1):
        if L == 1:
            T[1][frozenset()] += 1                              # 0
        T[L][frozenset([L])] += 1                               # variable of length L
        if L >= 2:
            for fv, n in T[L - 1].items():
                T[L][fv] += n                                   # S t
        for a in range(1, L - 1):
            for fv1, n1 in T[a].items():
                for fv2, n2 in T[L - 1 - a].items():
                    T[L][fv1 | fv2] += 2 * n1 * n2               # + t t, * t t
        for a in range(1, L - 1):
            for fv1, n1 in T[a].items():
                for fv2, n2 in T[L - 1 - a].items():
                    F[L][fv1 | fv2] += 2 * n1 * n2               # = t t, < t t
        if L >= 2:
            for fv, n in F[L - 1].items():
                F[L][fv] += n                                   # ~ f
        for a in range(1, L - 1):
            for fv1, n1 in F[a].items():
                for fv2, n2 in F[L - 1 - a].items():
                    F[L][fv1 | fv2] += 3 * n1 * n2               # & | >
        for lv in range(1, L - 1):
            for fv, n in F[L - 1 - lv].items():
                F[L][fv - {lv}] += 2 * n                         # A v f, E v f
    return ({L: sum(F[L].values()) for L in F}, {L: F[L].get(frozenset(), 0) for L in F})


# ------------------------------------------------------------------ recursions
def formula_counts(Lmax):
    T = [0] * (Lmax + 1)
    F = [0] * (Lmax + 1)
    for L in range(1, Lmax + 1):
        T[L] = (L == 1) + 1 + (T[L - 1] if L >= 2 else 0) + 2 * sum(T[a] * T[L - 1 - a] for a in range(1, L - 1))
        F[L] = (2 * sum(T[a] * T[L - 1 - a] for a in range(1, L - 1)) + (F[L - 1] if L >= 2 else 0)
                + 3 * sum(F[a] * F[L - 1 - a] for a in range(1, L - 1))
                + 2 * sum(F[L - 1 - lv] for lv in range(1, L - 1)))
    return F


def sentence_counts(Lmax):
    """s(L) = number of formulas of length L with no free variable.  G(X)[L] = number of formulas
    of length L whose free variables (identified by length) lie in X."""
    cache = {}

    def arrays(X, budget):
        key = X
        if key in cache and len(cache[key][1]) - 1 >= budget:
            return cache[key]
        T = [0] * (budget + 1)
        G = [0] * (budget + 1)
        for L in range(1, budget + 1):
            T[L] = ((L == 1) + (L in X) + (T[L - 1] if L >= 2 else 0)
                    + 2 * sum(T[a] * T[L - 1 - a] for a in range(1, L - 1)))
            g = 2 * sum(T[a] * T[L - 1 - a] for a in range(1, L - 1))
            g += G[L - 1] if L >= 2 else 0
            g += 3 * sum(G[a] * G[L - 1 - a] for a in range(1, L - 1))
            for lv in range(1, L - 1):
                rest = L - 1 - lv
                if lv in X:
                    g += 2 * G[rest]
                else:
                    sub = arrays(X | frozenset([lv]), budget - 1 - lv)
                    g += 2 * sub[1][rest]
            G[L] = g
        cache[key] = (T, G)
        return cache[key]

    return arrays(frozenset(), Lmax)[1]


# ------------------------------------------------------------------ rigorous growth certificate
def certificate(x0):
    """Return (ok, T*, F*) with exact super-solution check at rational x0."""
    V = x0 / (1 - x0)
    # T: 2 x T^2 + (x - 1) T + (x + V) <= 0 ; take T* as a rational just above the smaller root
    a, b, c = 2 * x0, x0 - 1, x0 + V
    disc = b * b - 4 * a * c
    if disc < 0:
        return False, None, None
    import math
    r = (-b - math.sqrt(float(disc))) / (2 * float(a))
    for eps in (1e-12, 1e-10, 1e-8, 1e-6, 1e-4):
        Ts = Fraction(r + eps).limit_denominator(10 ** 15)
        if a * Ts * Ts + b * Ts + c <= 0 and Ts > 0:
            break
    else:
        return False, None, None
    # F: 3 x F^2 + (x + 2 x V - 1) F + 2 x T*^2 <= 0
    a2, b2, c2 = 3 * x0, x0 + 2 * x0 * V - 1, 2 * x0 * Ts * Ts
    disc2 = b2 * b2 - 4 * a2 * c2
    if disc2 < 0:
        return False, Ts, None
    r2 = (-b2 - math.sqrt(float(disc2))) / (2 * float(a2))
    for eps in (1e-12, 1e-10, 1e-8, 1e-6, 1e-4):
        Fs = Fraction(r2 + eps).limit_denominator(10 ** 15)
        if a2 * Fs * Fs + b2 * Fs + c2 <= 0 and Fs > 0:
            break
    else:
        return False, Ts, None
    # exact verification of the two super-solution inequalities
    okT = Ts >= x0 + V + x0 * Ts + 2 * x0 * Ts * Ts
    okF = Fs >= 2 * x0 * Ts * Ts + x0 * Fs + 3 * x0 * Fs * Fs + 2 * x0 * V * Fs
    return okT and okF, Ts, Fs


def main():
    print("== S1/S2 cross-checks ==")
    Fb, Sb = brute(5)
    Fg, Sg = generate(9)
    Fr = formula_counts(400)
    Sr = sentence_counts(70)
    print(f"  brute force L<=5:  F = {[Fb[L] for L in range(1, 6)]}, sentences = {[Sb[L] for L in range(1, 6)]}")
    print(f"  generation  L<=9:  F = {[Fg[L] for L in range(1, 10)]}")
    print(f"                     sentences = {[Sg[L] for L in range(1, 10)]}")
    agreeF = all(Fb[L] == Fg[L] == Fr[L] for L in range(1, 6)) and all(Fg[L] == Fr[L] for L in range(1, 10))
    agreeS = all(Sb[L] == Sg[L] == Sr[L] for L in range(1, 6)) and all(Sg[L] == Sr[L] for L in range(1, 10))
    print(f"  formula counts agree (3 methods): {agreeF}; sentence counts agree (3 methods): {agreeS}")
    c5vals = {3: 8, 5: 162, 10: 341796, 20: 3112976679456}
    print(f"  recursion matches c5's printed F(L) {c5vals}: {all(Fr[L] == v for L, v in c5vals.items())}")
    assert agreeF and agreeS
    print("== S2 sentence counts ==")
    print(f"  {'L':>3} {'F(L)':>14} {'s(L)':>14} {'s/F':>8} {'s(L)/s(L-1)':>12} {'s(L-5)/s(L)':>12}")
    for L in (10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70):
        sf = Sr[L] / Fr[L]
        ratio = Sr[L] / Sr[L - 1] if Sr[L - 1] else float("nan")
        r5 = Sr[L - 5] / Sr[L] if Sr[L] else float("nan")
        print(f"  {L:>3} {Fr[L]:>14.4e} {Sr[L]:>14.4e} {sf:>8.4f} {ratio:>12.4f} {r5:>12.3e}")
    rmin = min(Sr[L - 5] / Sr[L] for L in range(20, 71))
    print(f"  min over 20 <= L <= 70 of s(L-5)/s(L) = {rmin:.3e}  (gamma^-5 at gamma = 5.383: {5.383 ** -5:.3e})")
    print(f"  F(L+1)/F(L) at L = 399: {Fr[400] / Fr[399]:.6f}")
    print("== S3 rigorous growth certificate ==")
    # locate the threshold by bisection on floats, then certify slightly above
    lo, hi = 5.0, 6.0
    for _ in range(60):
        mid = (lo + hi) / 2
        ok, _, _ = certificate(Fraction(1) / Fraction(mid).limit_denominator(10 ** 9))
        if ok:
            hi = mid
        else:
            lo = mid
    print(f"  smallest gamma' with a certificate found by bisection: about {hi:.6f}")
    for g in (Fraction(5385, 1000), Fraction(539, 100), Fraction(54, 10)):
        ok, Ts, Fs = certificate(1 / g)
        if ok:
            x0 = 1 / g
            C = Fs / (1 - x0)
            delta = 1 / (5 * log2(float(g)))
            print(f"  gamma' = {float(g)}: certificate verified exactly (T* = {float(Ts):.6f}, F* = {float(Fs):.6f}); "
                  f"#formulas of length <= L <= {float(C):.4f} * {float(g)}^L; proved delta >= {delta:.5f}")
            # sanity: the bound holds for the computed counts
            cum = 0
            okb = True
            for L in range(1, 401):
                cum += Fr[L]
                if Fraction(cum) > C * g ** L:
                    okb = False
                    break
            print(f"    check against exact counts, L <= 400: bound holds: {okb}")
        else:
            print(f"  gamma' = {float(g)}: no certificate")
    print("done")


if __name__ == "__main__":
    main()
