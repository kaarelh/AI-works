#!/usr/bin/env python3
"""Referee check q3 (final referee of the imitation drafts, 2026-10-14).

Independent code; seeded with numpy.random.default_rng(9103).  log = log2.

End-to-end machine-free form of thm:imit:main (i), (ii), (iv) and the bound on Phi, in explicit prefix classes.
For a class C (lengths l, Kraft sum k_C) containing a copy of length l0, and a coupling beta' of exact type rho, put
    j*(beta') := max_pi max{ L - l(pi) - 2^m R(pi),  L - l(pi) - 2^(m-1) (H + R(pi) - Dbar(pi)) },
the least j for which neither counting event of q2 occurs.  Then for every pi in C
    2^m R(pi) >= L - l(pi) - j*                       (the right line; plays the role of lem:imit:coding),
    Dbar(pi) <= R(pi) - H + 2 (Delta + l(pi) + j*)/2^m   (plays the role of lem:imit:closeness),  Delta := 2^m H - L,
and with G := l0 + j* + Delta (the draft's G with delta_beta + |Sigma| log(2^m+1) + kappa replaced by j* + Delta)
the draft's proof gives, for every pi with J_c(pi) <= Phi(c) + eps, c = a 2^-m, a > 1:
    (i)  l(pi) <= l0 + (G + 2^m eps)/(a-1)
    (ii) -(a G + 2^m eps)/((a-1) 2^m) <= R(pi) - H <= c l0 + eps
    (iv) E_x D_half(nu_H||nu_pi) <= c l0 + (2a/(a-1)) G/2^m + ((a+1)/(a-1)) eps
    (Phi) J_c(pi_H) <= Phi(c) + G/2^m + c l0.
Part (A) checks these implications on every coupling (exhaustive for m = 4, 5000 uniform samples for m = 8), at
several a and eps, together with Pr[j* > j] <= 2 k_C 2^-j, and reports how informative (iv) is against H(rho)
(the best predictor's E_x D_half in the feature case).  Part (B) adds, per coupling, adversarial coupling-aware
programs (partial memorisers priced below their information, mixtures of the person and the memoriser, and
perturbed coin laws per cell) and checks the implications again with that coupling's j*.  Since (A) and (B) only
re-run the algebra of the draft's proof, a violation would show an error in the insertion of (ii), (iii) or in the
kink-lemma step; the probability statement tests the counting content.
"""
from itertools import combinations
from math import comb, log2, ceil, lgamma, log

import numpy as np

rng = np.random.default_rng(9103)


def H(v):
    v = np.asarray(v, float)
    v = v[v > 0]
    return float(-(v * np.log2(v)).sum())


def log2_multinom(W, counts):
    return (lgamma(W + 1) - sum(lgamma(c + 1) for c in counts)) / log(2)


def dhalf_rows(P, Q):
    b = np.sqrt(P * Q).sum(axis=-1)
    with np.errstate(divide='ignore'):
        return np.where(b > 0, -2 * np.log2(b), np.inf)


def couplings_exhaustive(W, k1):
    out = []
    for S in combinations(range(W), k1):
        a = np.zeros(W, np.int8)
        a[list(S)] = 1
        out.append(a)
    return np.array(out)


def couplings_sampled(W, counts, n):
    base = np.repeat(np.arange(len(counts)), counts).astype(np.int8)
    return np.array([rng.permutation(base) for _ in range(n)])


class World:
    """Feature case, one input per cell (x = w), binary coins, |Y| = 2 or more."""

    def __init__(self, m, counts, nY):
        self.m, self.W = m, 2 ** m
        self.counts = counts
        self.nS = len(counts)
        self.rho = np.array(counts, float) / self.W
        self.Hr = H(self.rho)
        self.nY = nY
        self.h = np.array([rng.permutation(nY)[:self.nS] for _ in range(self.W)])
        self.nuH = np.zeros((self.W, nY))
        for x in range(self.W):
            self.nuH[x, self.h[x]] = self.rho
        self.L = log2_multinom(self.W, counts)
        self.Delta = self.W * self.Hr - self.L

    def r_table(self, P):
        """r[w,b] = -log P(h(w,b)|w): the per-cell loss if the coin of cell w is b."""
        with np.errstate(divide='ignore'):
            lp = np.log2(P)
        r = -lp[np.arange(self.W)[:, None], self.h]
        return r

    def Dbar(self, P):
        r = self.r_table(P)
        qt = np.where(np.isfinite(r), 2.0 ** (-r), 0.0)
        return float(np.mean(dhalf_rows(self.rho[None, :], qt)))

    def ED(self, P):
        return float(np.mean(dhalf_rows(self.nuH, P)))


def check(world, Cc, progs_fixed, adversarial=None, a_list=(1.25, 1.5, 2.0, 4.0, 16.0, 64.0), eps_list=(0.0, 1e-3)):
    W = world.W
    l0 = 4
    ls = np.array([l for _, l, _ in progs_fixed], float)
    kC = float(np.sum(2.0 ** -ls))
    rt = np.array([world.r_table(P) for _, _, P in progs_fixed])         # (P, W, nS)
    Db = np.array([world.Dbar(P) for _, _, P in progs_fixed])
    ED = np.array([world.ED(P) for _, _, P in progs_fixed])
    names = [n for n, _, _ in progs_fixed]
    viol = dict(i=0, ii_lo=0, ii_hi=0, iv=0, phi=0, line=0, clo=0)
    jstars = []
    informative = {a: [] for a in a_list}
    maxED = {a: 0.0 for a in a_list}
    winners = {a: {} for a in a_list}
    for beta in Cc:
        R = rt[:, np.arange(W), beta].mean(axis=1)                         # R_beta(pi) for every pi
        lsx, Rx, Dbx, EDx, namesx = ls, R, Db, ED, names
        if adversarial is not None:
            extra = adversarial(world, beta)
            if extra:
                lsx = np.concatenate([ls, [l for _, l, _ in extra]])
                Rx = np.concatenate([R, [world.r_table(P)[np.arange(W), beta].mean() for _, _, P in extra]])
                Dbx = np.concatenate([Db, [world.Dbar(P) for _, _, P in extra]])
                EDx = np.concatenate([ED, [world.ED(P) for _, _, P in extra]])
                namesx = names + [n for n, _, _ in extra]
        fin = np.isfinite(Rx)
        jc = world.L - lsx - W * Rx
        jl = world.L - lsx - 2 ** (world.m - 1) * (world.Hr + Rx - Dbx)
        jstar = float(np.max(np.maximum(jc[fin], jl[fin])))
        jstars.append(jstar)
        G = l0 + jstar + world.Delta
        # the two lemma-forms with j* (sanity: hold by construction)
        viol['line'] += int(np.any(W * Rx[fin] < world.L - lsx[fin] - jstar - 1e-9))
        viol['clo'] += int(np.any(Dbx[fin] > Rx[fin] - world.Hr + 2 * (world.Delta + lsx[fin] + jstar) / W + 1e-9))
        for a in a_list:
            c = a / W
            J = c * lsx + Rx
            Phi = float(np.min(J))
            Jh = c * l0 + world.Hr
            viol['phi'] += int(Jh > Phi + G / W + c * l0 + 1e-9)
            for eps in eps_list:
                near = J <= Phi + eps + 1e-12
                b_i = l0 + (G + W * eps) / (a - 1)
                b_lo = -(a * G + W * eps) / ((a - 1) * W)
                b_hi = c * l0 + eps
                b_iv = c * l0 + (2 * a / (a - 1)) * G / W + (a + 1) / (a - 1) * eps
                viol['i'] += int(np.any(lsx[near] > b_i + 1e-9))
                viol['ii_lo'] += int(np.any(Rx[near] - world.Hr < b_lo - 1e-9))
                viol['ii_hi'] += int(np.any(Rx[near] - world.Hr > b_hi + 1e-9))
                viol['iv'] += int(np.any(EDx[near] > b_iv + 1e-9))
                if eps == 0.0:
                    informative[a].append(b_iv)
                    maxED[a] = max(maxED[a], float(np.max(EDx[near])))
                    for k in np.nonzero(near)[0]:
                        winners[a][namesx[k]] = winners[a].get(namesx[k], 0) + 1
    jstars = np.array(jstars)
    return dict(viol=viol, jstars=jstars, kC=kC, informative=informative, maxED=maxED, winners=winners)


def report(tag, world, res, a_list=(1.25, 1.5, 2.0, 4.0, 16.0, 64.0)):
    print(f"  {tag}: 2^m = {world.W}, rho = {tuple(world.counts)}/{world.W}, H(rho) = {world.Hr:.4f}, L = {world.L:.2f},"
          f" Delta = 2^m H - L = {world.Delta:.2f}, k_C = {res['kC']:.4f}, couplings checked = {len(res['jstars'])}")
    print(f"    violations of the implications (must all be 0): {res['viol']}")
    js = res['jstars']
    for j in (0, 2, 4, 6, 8):
        print(f"    Pr[j* > {j}] = {np.mean(js > j):.5f}   (bound 2 k_C 2^-j = {2 * res['kC'] * 2.0 ** -j:.5f})")
    print(f"    j*: median {np.median(js):.2f}, max {js.max():.2f}")
    for a in a_list:
        b = np.array(res['informative'][a])
        w = res['winners'][a]
        top = sorted(w.items(), key=lambda kv: -kv[1])[:3]
        print(f"    a = {a:6.2f} (c = {a / world.W:.2e}): bound (iv) median {np.median(b):.4f} = {np.median(b) / world.Hr:.3f} H(rho);"
              f" max E_x D_half of a minimiser {res['maxED'][a]:.4f}; minimisers: {top}")


def fixed_class(world, n_patterns_t=8, structured=True):
    W, nY = world.W, world.nY
    progs = [("person", 4, world.nuH), ("uniform", 3, np.full((W, nY), 1 / nY))]
    for t in range(40):
        rp = rng.dirichlet(world.rho * 30)
        P = np.zeros((W, nY))
        for x in range(W):
            P[x, world.h[x]] = rp
        progs.append(("near-copy", 10, P))
    for t in range(40):
        progs.append(("random", 12, rng.dirichlet(np.ones(nY), size=W)))
        progs.append(("subprob", 12, rng.dirichlet(np.ones(nY), size=W) * rng.uniform(0.3, 1, size=(W, 1))))
    eta = 0.02
    for t in range(1, n_patterns_t + 1):
        lt = 4 + ceil(2 * log2(t + 1)) + t
        for code in range(2 ** t):
            P = world.nuH.copy()
            for w in range(t):
                b = (code >> w) & 1
                P[w] = eta * world.nuH[w]
                P[w, world.h[w, b]] += 1 - eta
            progs.append((f"memo-first-cells", lt, P))
    if structured:
        base = np.repeat(np.arange(2), world.counts)
        for s in range(W):
            for arr in (base, base[::-1]):
                st = np.roll(arr, s)
                P = eta * world.nuH.copy()
                for w in range(W):
                    P[w, world.h[w, st[w]]] += 1 - eta
                progs.append(("structured-memo", 4 + 2 * world.m + 2, P))
    return progs


def adversarial(world, beta):
    """Coupling-aware programs, priced below their information (allowed: only the implications are tested)."""
    W, nY = world.W, world.nY
    out = []
    for frac in (0.05, 0.1, 0.25, 0.5, 1.0):
        t = max(1, int(frac * W))
        cells = rng.choice(W, size=t, replace=False)
        for eta in (0.0, 0.05):
            P = world.nuH.copy()
            for w in cells:
                P[w] = eta * world.nuH[w]
                P[w, world.h[w, beta[w]]] += 1 - eta
            for price in (0.25, 0.5, 1.0):
                out.append((f"adv-memo", 4 + int(price * t), P))
    for lam in (0.1, 0.3, 0.6, 0.9):
        M = np.zeros((W, nY))
        M[np.arange(W), world.h[np.arange(W), beta]] = 1.0
        out.append(("adv-mix", 4 + W // 4, lam * M + (1 - lam) * world.nuH))
    for t in range(5):
        P = world.nuH.copy()
        tilt = rng.normal(0, 0.5, size=W)
        for w in range(W):
            rp = world.rho * np.exp(tilt[w] * (np.arange(world.nS) == beta[w]))
            rp /= rp.sum()
            P[w] = 0
            P[w, world.h[w]] = rp
        out.append(("adv-tilt", 4 + W // 8, P))
    return out


print("(A) fixed classes")
w4 = World(4, (12, 4), 2)
res = check(w4, couplings_exhaustive(16, 4), fixed_class(w4, n_patterns_t=6))
report("m = 4, exhaustive", w4, res)
w8 = World(8, (192, 64), 2)
res = check(w8, couplings_sampled(256, (192, 64), 5000), fixed_class(w8, n_patterns_t=8))
report("m = 8, 5000 sampled couplings", w8, res)
w8b = World(8, (224, 24, 8), 3)
res = check(w8b, couplings_sampled(256, (224, 24, 8), 3000), fixed_class(w8b, n_patterns_t=8, structured=False))
report("m = 8, three coins, 3000 sampled couplings", w8b, res)

print()
print("(B) per-coupling adversarial programs added (implications only)")
res = check(w4, couplings_exhaustive(16, 4)[::4], fixed_class(w4, n_patterns_t=6), adversarial=adversarial)
report("m = 4", w4, res)
res = check(w8, couplings_sampled(256, (192, 64), 400), fixed_class(w8, n_patterns_t=8), adversarial=adversarial)
report("m = 8", w8, res)
