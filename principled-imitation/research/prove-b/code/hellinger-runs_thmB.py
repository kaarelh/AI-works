#!/usr/bin/env python3
"""Numerical checks for Section 5 (Theorem B, its failure at lambda = 1, Theorem B').

(1) Example 5.4 (tables against a fair coin): exact expected posterior mass of the far
    set at lambda = 1 and at lambda = 2.
(2) A countable class with prefix code lengths (dyadic biases): Monte Carlo estimate of
    E[posterior mass of {nu : H2(Q_nu, Q_P) >= eps^2}] for several lambda, against
        2^(lambda s l(P)) (1 - eps^2)^(2 min(s, 1-s) N),   s in [1/lambda, 1).
(3) Theorem B' (likelihood to the power alpha): Monte Carlo estimate of
    E E_{nu ~ tempered posterior}[H2(Q_nu, Q*)] against the oracle bound, in a class that
    does not contain the truth.
Only numpy is needed.
"""
import math
import numpy as np

rng = np.random.default_rng(5)
LN2 = math.log(2)


# ------------------------------------------------------------------ (1)
def tables_example(d, N):
    """z uniform on {0,1}^d, one call, human = fair coin; class = fair coin (length 1)
    and all 2^(2^d) tables (length 2^d + 1).  With R = N - (number of distinct z):
    lambda = 1: posterior mass of the tables = 2^R/(1+2^R) if the data are consistent
    (probability 2^-R given the z's), else 0; so E = E[1/(1+2^-R) * 2^-R] ... computed
    exactly from the law of R restricted to R <= rmax (a lower bound)."""
    Z = 2.0 ** d
    # law of the number of distinct values (occupancy), exact dynamic programme
    p = np.zeros(N + 2); p[0] = 1.0
    v = np.arange(N + 2)
    for _ in range(N):
        q = p * np.minimum(v / Z, 1.0)
        q[1:] += p[:-1] * np.maximum(1 - v[:-1] / Z, 0.0)
        p = q
    e1 = e2 = 0.0
    for D in range(1, N + 1):
        R = N - D
        if p[D] == 0:
            continue
        cons = 2.0 ** (-R)                                  # probability of consistency
        e1 += p[D] * cons * (2.0 ** R / (1 + 2.0 ** R))     # lambda = 1
        ratio2 = 2.0 ** (R - Z) if R - Z > -1000 else 0.0   # lambda = 2: tables/coin
        e2 += p[D] * cons * (ratio2 / (1 + ratio2))
    return e1, e2


# ------------------------------------------------------------------ (2), (3)
def dyadic_class(jmax):
    """Biases (2i-1)/2^j, j = 1..jmax, with prefix code length 2j-1 (Kraft sum <= 1)."""
    th, ln = [], []
    for j in range(1, jmax + 1):
        for i in range(1, 2 ** (j - 1) + 1):
            th.append((2 * i - 1) / 2 ** j); ln.append(2 * j - 1)
    return np.array(th), np.array(ln, dtype=float)


def h2_runs(th, th0, L):
    """H2 between the laws of L independent Bern(th) and L independent Bern(th0)."""
    bc = np.sqrt(th * th0) + np.sqrt((1 - th) * (1 - th0))
    return 1 - bc ** L


def post_mass_far(th, ln, th0, L, N, lam, eps2, reps):
    far = h2_runs(th, th0, L) >= eps2
    tot = 0.0
    for _ in range(reps):
        ones = rng.binomial(N * L, th0)
        loglik = ones * np.log(th) + (N * L - ones) * np.log(1 - th)
        lw = -lam * ln * LN2 + loglik
        w = np.exp(lw - lw.max()); w /= w.sum()
        tot += w[far].sum()
    return tot / reps


def tempered_risk(th, ln, th_true, L, N, alpha, reps):
    """E over data of the tempered-posterior mean of H2(Q_nu, Q*), prior 2^-l."""
    h2 = h2_runs(th, th_true, L)
    tot = 0.0
    for _ in range(reps):
        ones = rng.binomial(N * L, th_true)
        loglik = ones * np.log(th) + (N * L - ones) * np.log(1 - th)
        lw = -ln * LN2 + alpha * loglik
        w = np.exp(lw - lw.max()); w /= w.sum()
        tot += float(w @ h2)
    return tot / reps


def kl_runs(th_true, th, L):
    return L * (th_true * np.log(th_true / th) + (1 - th_true) * np.log((1 - th_true) / (1 - th)))


if __name__ == "__main__":
    print("(1) Example 5.4: expected posterior mass of the tables (all at H2 = 0.2929 from the coin)")
    print("    d, N | lambda = 1 | lambda = 2 | Theorem B bound at lambda = 2: 2 exp(-0.2929 N)")
    for d, N in [(10, 8), (10, 32), (20, 32), (20, 512), (30, 1024), (30, 16384)]:
        e1, e2 = tables_example(d, N)
        print(f"    d={d} N={N:6d}: {e1:.4f}   {e2:.3e}   {min(1.0, 2 * math.exp(-0.2929 * N)):.3e}")

    print("(2) dyadic class (levels <= 10), truth Bern(3/8) with l(P) = 5, runs of L = 5 calls")
    th, ln = dyadic_class(10)
    th0 = 3 / 8
    eps2 = 0.02
    print("    lambda, N | Monte Carlo E[mass of far set] | bound with s = max(1/2, 1/lambda)")
    for lam in [1.0, 1.25, 1.5, 2.0, 3.0]:
        for N in [20, 80, 320]:
            est = post_mass_far(th, ln, th0, 5, N, lam, eps2, reps=4000)
            if lam > 1:
                s = max(0.5, 1 / lam)
                bound = 2 ** (lam * s * 5) * (1 - eps2) ** (2 * min(s, 1 - s) * N)
                print(f"    lambda={lam:<4} N={N:4d}: {est:.4e}   bound {min(1.0, bound):.4e}")
            else:
                print(f"    lambda={lam:<4} N={N:4d}: {est:.4e}   (no bound)")

    print("(3) Theorem B', alpha = 1/2: class = dyadic levels <= 3, truth Bern(0.3), L = 5")
    th3, ln3 = dyadic_class(3)
    th_true = 0.3
    print("    N | Monte Carlo E[tempered posterior mean of H2] | oracle bound min_nu [KL/2 + l(nu) ln2 / N]")
    for N in [5, 20, 80, 320, 1280]:
        est = tempered_risk(th3, ln3, th_true, 5, N, 0.5, reps=4000)
        orc = float(np.min(kl_runs(th_true, th3, 5) / 2 + ln3 * LN2 / N))
        print(f"    N={N:5d}: {est:.5f}   bound {orc:.5f}")
    print("    (the best member has H2 =", f"{h2_runs(th3, th_true, 5).min():.5f}",
          "and KL/2 =", f"{(kl_runs(th_true, th3, 5) / 2).min():.5f})")
