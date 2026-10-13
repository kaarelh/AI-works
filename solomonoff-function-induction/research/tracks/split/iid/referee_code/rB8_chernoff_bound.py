"""rB8 (referee B): a free Chernoff exponent in Thm 4.1(iv).  Deterministic (no randomness).

Thm 4.1(iv) bounds P[J(pi) <= J(pi_0)] = P[log Lambda_n(pi) >= lambda (l(pi) - l*)] by Markov for
Lambda^{1/lambda}:  2^{l* - l(pi)} rho_{1/lambda}(pi)^n.  Markov for Lambda^s works for every s in (0, 1]
(E Lambda_n^s = rho_s^n by Lemma 2.1(c)), so

    P[J(pi) <= J(pi_0)] <= min_{0 < s <= 1} 2^{-s lambda (l(pi) - l*)} rho_s(pi)^n,

which is never worse (s = 1/lambda is allowed).  For near-equivalent programs longer than l* (rho_s ~ 1)
s = 1 gives 2^{-lambda (l - l*)} instead of 2^{-(l - l*)}: the prior weight is raised to the power lambda.
This script evaluates both bounds (each minimised over the cut L, first term 2^{lambda l* - (lambda-1) L})
in the class of rB3 and prints them next to rB3's empirical failure frequencies (copied from
rB3_sim_bounds.out, 2000 runs).
"""
import numpy as np
from math import ceil, log2

X = np.arange(8)
mu = 1.0 / (X + 1); mu /= mu.sum()
nu1 = (2 * X + 1) / 16.0
progs, lens, kinds = [], [], []
def add(p1, L, kind):
    progs.append(np.asarray(p1, float)); lens.append(L); kinds.append(kind)
add(nu1, 10, "T")
for L in (12, 14, 16):
    add(nu1, L, "Tcopy")
for j in range(1, 16):
    add(np.full(8, j / 16), 6, "BERN")
for t in range(8):
    add(np.where(X >= t, 0.75, 0.25), 7, "THR")
for f in range(256):
    add(np.array([(f >> x) & 1 for x in X], float), 11, "DET")
for x in X:
    for b in (0, 1):
        p = nu1.copy(); p[x] = b; add(p, 12, "EXC")
for x in X:
    for sgn in (-1, 1):
        for j in range(3, 21):
            q = nu1[x] + sgn * 2.0 ** -j
            if not 0 < q < 1:
                continue
            p = nu1.copy(); p[x] = q; add(p, 14 + 2 * ceil(log2(j + 1)), "NEAR")
P1 = np.stack(progs); lens = np.array(lens, float); kinds = np.array(kinds)
inE = np.array([k in ("T", "Tcopy") for k in kinds])
LSTAR = 10
SG = np.linspace(0.01, 1.0, 100)


def rho_all(s):
    out = np.zeros(len(progs))
    for (A, B) in ((nu1[None, :], P1), (1 - nu1[None, :], 1 - P1)):
        m = (A > 0) & (B > 0)
        val = np.where(m, A ** (1 - s) * np.where(B > 0, B, 1.0) ** s, 0.0)
        out += (val * mu[None, :]).sum(1)
    return out


RHO = np.stack([rho_all(s) for s in SG])          # (len(SG), programs)
wrong = np.flatnonzero(~inE)
EMP = {1.25: [0.9320, 0.6510, 0.3875, 0.1155, 0.0215, 0.0930, 0.0115, 0.0045],
       2.0: [0.9995, 0.8410, 0.3715, 0.0705, 0.0130, 0.0080, 0.0095, 0.0030],
       4.0: [1.0000, 1.0000, 0.8335, 0.1875, 0.0065, 0.0000, 0.0000, 0.0015]}
NS = [25, 50, 100, 200, 400, 800, 1600, 2000]
for lam in (1.25, 2.0, 4.0):
    print(f"lambda = {lam}")
    i_s = int(np.argmin(np.abs(SG - 1 / lam)))
    rho_fix = np.array([rho_all(1 / lam)[i] for i in wrong])
    for t, n in enumerate(NS):
        best_notes = best_free = np.inf
        for L in range(LSTAR, 60):
            first = 2.0 ** (lam * LSTAR - (lam - 1) * L)
            sel = lens[wrong] <= L
            dl = lens[wrong][sel] - LSTAR
            notes = float(np.sum(2.0 ** (-dl) * rho_fix[sel] ** n))
            terms = 2.0 ** (-SG[:, None] * lam * dl[None, :]) * RHO[:, wrong[sel]] ** n
            terms = np.minimum(terms.min(0), 2.0 ** (-dl) * rho_fix[sel] ** n)
            free = float(np.sum(terms))
            best_notes = min(best_notes, first + notes)
            best_free = min(best_free, first + free)
        print(f"  n={n:5d}: empirical {EMP[lam][t]:.4f}   notes' bound {min(best_notes, 99):.4g}   "
              f"free-exponent bound {min(best_free, 99):.4g}")
