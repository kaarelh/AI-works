#!/usr/bin/env python3
"""Exact look at the two-coin instance of Proposition 3.5 of research/prove-b/hellinger-runs.md:
X = {x}, P+ = Bern(1/2 + a), P- = Bern(1/2 - a), scaffold = L calls at x, a = 4 eps sqrt(2/L).

 (1) The proof of Proposition 3.5 bounds max(E+ TV, E- TV) from below by the Bayes risk under the prior (1/2, 1/2),
     which equals  (1/2) G(L,a) (1 - TV(Bin(n,1/2+a), Bin(n,1/2-a)))  exactly (a sufficient statistic of n answers is
     the number of ones; the best deployed law is the more likely of the two).  We evaluate it at
     n = floor(L / (740 eps^2)) (must be >= eps) and find the largest n at which it is still >= eps.
 (2) Protocol R on the same instance with the class {P+, P-}, weights 1/2 (K = 1), exact expectation over the data:
     the smallest n with E TV(Q_M(T), Q_P+) <= eps, against the upper bounds
        4 L ln2 / eps^2            (Theorem 3.1(b) of the file)
        L ln2 / eps^2              (Theorem 3.1(d); and, to first order, the bound of the attack report)
        L ln2 / (2 eps^2)          (improvement A of the check report, scaffolds whose inputs do not depend on the answers)
     and the lower bound L / (740 eps^2).

Run:  python3 hellinger-runs_attack_lb.py      (about 1 minute)
"""
import math, time
import numpy as np
from scipy.stats import binom

LN2 = math.log(2.0)

def tv_binom(L, p, q):
    k = np.arange(L + 1)
    return 0.5 * float(np.abs(binom.pmf(k, L, p) - binom.pmf(k, L, q)).sum())

def bayes_risk(L, a, n):
    G = tv_binom(L, 0.5 + a, 0.5 - a)
    T = tv_binom(n, 0.5 + a, 0.5 - a) if n > 0 else 0.0
    return 0.5 * G * (1 - T), G

def protocol_R_curve(L, a, nmax):
    """E TV(Q_{M^(t)}, Q_{P+}) for t = 1..nmax under Protocol R (every round asks: the run always has L calls).
    Data after t-1 rounds: (number of ones) ~ Bin(t-1, 1/2+a) exactly, because every asked input is x.
    The mixture depends on the data through d = (ones) - (zeros) only; TV as a function of d is tabulated once."""
    kL = np.arange(L + 1)
    pP = binom.pmf(kL, L, 0.5 + a)
    lr = math.log((0.5 + a) / (0.5 - a))
    Dmax = int(60 / lr) + 2                                   # beyond |d| = Dmax the posterior odds exceed e^60
    ds = np.arange(-Dmax, Dmax + 1)
    wplus = 1.0 / (1.0 + np.exp(-ds * lr))
    mix = wplus * (0.5 + a) + (1 - wplus) * (0.5 - a)         # M(1|x) as a function of d
    tv_d = np.array([0.5 * np.abs(binom.pmf(kL, L, mm) - pP).sum() for mm in mix])
    out = []
    for t in range(1, nmax + 1):
        m = t - 1; k = np.arange(m + 1)
        pk = binom.pmf(k, m, 0.5 + a)
        d = np.clip(2 * k - m, -Dmax, Dmax) + Dmax
        out.append(float((pk * tv_d[d]).sum()))
    return np.array(out)

if __name__ == '__main__':
    t0 = time.time()
    print("(1) Proposition 3.5: Bayes risk at n0 = floor(L/(740 eps^2)); largest n with Bayes risk >= eps")
    print("     L     eps      a        G(L,a)   n0    risk(n0)/eps   n_max   n_max eps^2 / L")
    for L in [3, 25, 101, 1001]:
        for eps in [1 / 12, 0.05, 0.02]:
            a = 4 * eps * math.sqrt(2 / L)
            n0 = int(L / (740 * eps * eps))
            r0, G = bayes_risk(L, a, n0)
            n = n0
            while bayes_risk(L, a, n + 1)[0] >= eps: n += 1
            print("     %-5d %.4f   %.5f  %.4f   %-5d %.3f          %-6d  %.4f   %s" % (L, eps, a, G, n0, r0 / eps, n, n * eps * eps / L,
                  "" if r0 >= eps else "VIOLATION"))
    print("(2) Protocol R on the same instance (K = 1): smallest n with E TV(Q_M(T), Q_P+) <= eps")
    print("     L     eps     n_R     n_R eps^2/L | 4 ln2 = %.3f (file, 3.1(b))   ln2 = %.3f (3.1(d); attack report)   ln2/2 = %.3f (check report, A)   1/740 = %.5f (lower bound)" % (4 * LN2, LN2, LN2 / 2, 1 / 740))
    for (L, eps) in [(3, 1 / 12), (3, 0.05), (3, 0.02), (25, 1 / 12), (25, 0.05), (101, 1 / 12)]:
        if True:
            a = 4 * eps * math.sqrt(2 / L)
            nmax = int(1.2 * L * LN2 / eps ** 2) + 5
            c = protocol_R_curve(L, a, nmax)
            avg = np.cumsum(c) / np.arange(1, nmax + 1)            # E over the uniform round T <= n
            idx = np.flatnonzero(avg <= eps)
            nR = int(idx[0]) + 1 if idx.size else None
            s = lambda n: L * LN2 / (2 * n)
            newb = min(1.0, s(nR) + math.sqrt(s(nR) ** 2 + 2 * s(nR))) if nR else float('nan')
            print("     %-5d %.4f  %-6s  %s   (at n_R: bound of the file %.3f, of 3.1(d) %.3f, new %.3f, improvement A %.3f; eps = %.3f)" % (
                L, eps, nR, ("%.4f" % (nR * eps * eps / L)) if nR else "  -   ",
                min(1, 2 * math.sqrt(L * LN2 / nR)), min(1, math.sqrt(L * LN2 / nR)), newb, min(1, math.sqrt(L * LN2 / (2 * nR))), eps))
    print("time %.0f s" % (time.time() - t0))
