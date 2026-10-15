"""rB5 (referee B): exact binomial checks of notes.md Prop 5.8 (the margin is necessary) and of the
per-program step of Lemma 5.2 (Markov on sqrt of the likelihood ratio), for Bernoulli pairs.

Model: labels i.i.d. Bern(p) given the inputs (a feature-free sampler suffices: the statements only see
the per-input laws); pi* has rate p and length l0; pi1 has rate q and length l0 - Delta.  With k ones
among n labels, X := L(pi1) - L0 = k log(p/q) + (n-k) log((1-p)/(1-q)) exactly, so every probability
below is a finite binomial sum (scipy.stats.binom, exact pmf).

(A) Prop 5.8: P[X >= lambda Delta] (= P[pi* is not beaten by pi1]) <= (n Kbar + log e/e)/(lambda Delta).
    Max of exact/bound over a grid; the sample size where P = 1/2 against n_KL = lambda Delta/Kbar;
    the ratio Kbar/(2 log e Hel).
(B) Lemma 5.2, one program (l = 0): P[X <= 2 log e n Hel - 2 log(1/eps)] <= eps.  Max of exact/eps.
Deterministic.
"""
import math
import numpy as np
from scipy.stats import binom

LOG2E = math.log2(math.e)


def KL(p, q):
    return p * math.log2(p / q) + (1 - p) * math.log2((1 - p) / (1 - q))


def Hel(p, q):
    return 1 - math.sqrt(p * q) - math.sqrt((1 - p) * (1 - q))


def X_values(n, p, q):
    k = np.arange(n + 1)
    return k * math.log2(p / q) + (n - k) * math.log2((1 - p) / (1 - q)), binom.pmf(k, n, p)


def p_ident(n, p, q, lamDelta):
    x, w = X_values(n, p, q)
    return float(w[x >= lamDelta - 1e-12].sum())


def main():
    print("rB5: Prop 5.8 and the one-program step of Lemma 5.2, exact binomial (referee B)")
    print("=" * 100)
    print("(A) Prop 5.8")
    worst = (0, None)
    rows = []
    for p in (0.05, 0.125, 0.25, 0.4):
        for q in (p / 2, p * 0.8, min(0.5, p * 1.5), min(0.5, 2 * p), 0.5):
            if abs(q - p) < 1e-12:
                continue
            Kb = KL(p, q)
            he = Hel(p, q)
            for Delta in (1, 3, 10, 30):
                for lam in (1.0, 1.5, 2.0, 8.0):
                    lD = lam * Delta
                    nKL = lD / Kb
                    ns = sorted(set(int(x) for x in np.geomspace(1, 4 * nKL + 10, 60)))
                    for n in ns:
                        ex = p_ident(n, p, q, lD)
                        bd = (n * Kb + LOG2E / math.e) / lD
                        if bd < 1 and ex / bd > worst[0]:
                            worst = (ex / bd, (p, q, Delta, lam, n, ex, bd))
                        assert ex <= bd + 1e-12, (p, q, Delta, lam, n, ex, bd)
                    # sample size at which P = 1/2 and 0.95 (first n)
                    # first n with P >= 1/2: bisection (P is nondecreasing in n up to lattice effects), then a
                    # backward linear check over the last 50 sample sizes
                    lo_, hi_ = 1, int(20 * nKL) + 200
                    if p_ident(hi_, p, q, lD) < 0.5:
                        n_half = None
                    else:
                        while lo_ < hi_:
                            mid = (lo_ + hi_) // 2
                            if p_ident(mid, p, q, lD) >= 0.5:
                                hi_ = mid
                            else:
                                lo_ = mid + 1
                        n_half = lo_
                        for nn in range(max(1, lo_ - 50), lo_):
                            if p_ident(nn, p, q, lD) >= 0.5:
                                n_half = nn
                                break
                    rows.append((p, q, Delta, lam, Kb, he, nKL, n_half))
    print(f"  bound never violated; max exact/bound (where bound < 1) = {worst[0]:.3f} at "
          f"(p, q, Delta, lambda, n) = {worst[1][:5]} (exact {worst[1][5]:.3f}, bound {worst[1][6]:.3f})")
    r_half = [nh / nk for (_, _, _, _, _, _, nk, nh) in rows if nh is not None]
    big = [nh / nk for (_, _, D, lam, _, _, nk, nh) in rows if nh is not None and lam * D >= 15]
    ratio = [Kb / (2 * LOG2E * he) for (_, _, _, _, Kb, he, _, _) in rows]
    print(f"  {len(rows)} settings: n(P = 1/2) / n_KL ranges over [{min(r_half):.2f}, {max(r_half):.2f}]; "
          f"for lambda*Delta >= 15: [{min(big):.2f}, {max(big):.2f}]")
    print(f"  Kbar/(2 log e Hel) ranges over [{min(ratio):.3f}, {max(ratio):.3f}] (it is >= 1 always: KL >= -2 log BC)")
    print("  the notes' family (k5): p = 1/8, q in {1/4, 3/16}: "
          + ", ".join(f"q={q}: {KL(0.125, q) / (2 * LOG2E * Hel(0.125, q)):.3f}" for q in (0.25, 0.1875)))
    print("  identification with prob >= 1/2 needs n >= (lambda Delta/2 - log e/e)/Kbar; checked:",
          all(nh is None or nh >= (lam * D / 2 - LOG2E / math.e) / Kb - 1e-9 for (_, _, D, lam, Kb, _, _, nh) in rows))
    print("=" * 100)
    print("(B) Lemma 5.2 for one program of length 0: P[X <= 2 log e n Hel - 2 log(1/eps)] <= eps")
    worstB = (0, None)
    for p in (0.05, 0.125, 0.25, 0.4):
        for q in (p / 2, p * 0.8, min(0.5, 2 * p), 0.5, 0.9):
            if abs(q - p) < 1e-12:
                continue
            he = Hel(p, q)
            for eps in (0.5, 0.1, 0.01):
                for n in (1, 2, 5, 10, 30, 100, 300, 1000):
                    x, w = X_values(n, p, q)
                    thr = 2 * LOG2E * n * he - 2 * math.log2(1 / eps)
                    ex = float(w[x <= thr + 1e-12].sum())
                    assert ex <= eps + 1e-12
                    if ex / eps > worstB[0]:
                        worstB = (ex / eps, (p, q, eps, n))
    print(f"  never violated; max exact/eps = {worstB[0]:.4f} at (p, q, eps, n) = {worstB[1]}")


if __name__ == "__main__":
    main()
