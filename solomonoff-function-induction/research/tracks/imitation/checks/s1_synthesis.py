#!/usr/bin/env python3
"""Synthesis checks for track "imitation" (research/tracks/imitation/notes-final.md), 2026-10-14.

Independent of the sub-tracks' code (robust/checks*, decay/checks, referee code): nothing is imported from them.
Deterministic, except part (B), seeded with numpy.random.default_rng(141) and part (C), seeded with
default_rng(142).  Python 3.11, NumPy 2.x.  log = log2 throughout; all divergences in bits.

(A) The numbers quoted in the draft section sec:imit: the bound of thm:imit:main(iv) (robust Theorem 4.7(U)(vi), in
    its stated form) at two illustrative sizes, with the machine constant and delta_beta set to 0 (an illustration),
    against the memoriser's value H(rho).  Also the tighter intermediate form of the proof, which the robust check f7(D)
    printed, so that the two can be compared.
(B) The closeness lemma (robust Lemma 4.6), machine-free steps, on random latent-cause instances: the Hoelder step
    E_x D_half(nu_H||nu_pi) <= Dbar(pi); sum_b qtilde_w <= sum_b q_w <= 1; total mass Z <= 1 of the semimeasure Q by
    brute force over all |Sigma|^(2^m) maps; the identities -log Q(beta) = 2^(m-1)(H + R) and log Z = -2^(m-1) Dbar.
(C) The counting (machine-free) form of the closeness lemma, exhaustively over the type class of an explicit
    feature-case world (32 cells, 4 coin-1 cells, 35,960 couplings) and an explicit prefix class with Kraft sum < 1:
    Pr_beta'[exists pi: Dbar(pi) >= H + R_beta'(pi) - 2(L_beta - l(pi) - j)/2^m] <= Kraft * 2^-j.
(D) Model-coupling confounding (robust Prop 4.11(b)) for m = 3: every data table T is shared by exactly
    C(8, s0) worlds with pairwise different humans, so the best average copying probability is 1/C(8, s0).
(E) The numbers quoted in the weight-decay draft: omega*, the l_inf-box thresholds, c_+/2^-m; and a direct Newton
    solve of the L2 toy on both sides of omega*.
(F) The two inequalities used to convert D_half: D_half >= 2 Hel / ln 2 and mean TV <= sqrt(2 Hel), on random pairs.
"""
from itertools import combinations, product
from math import comb, log, log2, sqrt, exp

import numpy as np


def H(v):
    v = np.asarray(v, dtype=float)
    v = v[v > 0]
    return float(-(v * np.log2(v)).sum())


def dhalf(P, Q):
    """Renyi divergence of order 1/2 in bits, P a probability vector, Q a sub-probability vector."""
    bc = float(np.sum(np.sqrt(np.asarray(P) * np.asarray(Q))))
    return float('inf') if bc <= 0 else -2.0 * log2(bc)


# ------------------------------------------------------------------------------------------------- (A)
print("(A) Bound of thm:imit:main(iv) (robust Thm 4.7(U)(vi)), eps = 0, kappa = 0, delta_beta = 0 (an illustration)")


def bound_stated(l0, m, nS, Hr, a, delta=0.0, kappa=0.0, eps=0.0):
    c = a / 2 ** m
    G = l0 + delta + nS * log2(2 ** m + 1) + kappa
    Em = 2 * log2(2 ** (m - 1) * (2 * Hr + c * (l0 + kappa) + eps) + 1)
    return c * (l0 + kappa) + (2 * a / (a - 1)) * (G + Em + kappa) / 2 ** m + (a + 1) / (a - 1) * eps


def bound_tight(l0, m, nS, Hr, a, delta=0.0):
    """The intermediate bound in the proof (before simplifying to 2a/(a-1)): E_m and the +1 get coefficient 2."""
    c = a / 2 ** m
    G = l0 + delta + nS * log2(2 ** m + 1)
    Em = 2 * log2(2 ** (m - 1) * (2 * Hr + c * l0) + 1)
    return c * l0 + (2 / 2 ** m) * (l0 + G / (a - 1) + delta + nS * log2(2 ** m + 1) + Em + 1)


m = 20
a_rho = lambda mm, nS: 2 * log2(mm + 1) + 2 * log2(nS + 1) + nS * (mm + 1)
cases = [("fair-coin human: Sigma = {0,1}, rho = (1/2,1/2), h(x,b) = b; l_0 <= a_rho", a_rho(20, 2), 2, 1.0),
         ("parity human: d = 100, m = 20, p = 2^-10; l_0 <= d + 2 log d + 2 log 10",
          100 + 2 * log2(100) + 2 * log2(10), 2, H([1 - 2 ** -10, 2 ** -10]))]
for name, l0, nS, Hr in cases:
    print(f"  {name}")
    print(f"    l_0 = {l0:.2f} bits, 2^m = {2 ** m}, H(rho) = {Hr:.6f} bits (= E_x D_half of the memoriser)")
    for a in (1.5, 2.0, 4.0, 16.0, 1e-4 * 2 ** m):
        bs, bt = bound_stated(l0, m, nS, Hr, a), bound_tight(l0, m, nS, Hr, a)
        hel = bs * log(2) / 2
        print(f"    a = {a:8.3f} (c = {a / 2 ** m:.3e}): E D_half <= {bs:.4e} (tight form {bt:.4e});"
              f" ratio to H(rho) {bs / Hr:.4f}; Hellinger gap <= {hel:.3e}")
# window cells (robust Prop 4.10(d)) for a large human, kappa = 0
for l0 in (1e6, 1e12):
    Hr, logY = 0.5, 1.0
    need = l0 / (logY - Hr) - (a_rho(40, 2) + 1) / Hr
    print(f"  Prop 4.10(d): l_0 = {l0:.0e}, H(rho) = 0.5, log|Y| = 1: a window needs 2^m > {need:.4e}")

# ------------------------------------------------------------------------------------------------- (B)
print()
print("(B) Closeness lemma, machine-free steps, random latent-cause instances (seed 141)")
rng = np.random.default_rng(141)
m_b = 3
W = 2 ** m_b
rho_choices = {2: [(6, 2), (5, 3), (4, 4), (7, 1)], 3: [(4, 2, 2), (3, 3, 2), (5, 2, 1), (6, 1, 1)]}
worst = dict(holder=-np.inf, qq=-np.inf, qsum=-np.inf, Z=-np.inf, idQ=0.0, idZ=0.0)
n_prog = 0
n_finite = [0]
n_idQ = [0]
for trial in range(40):
    nS = int(rng.integers(2, 4))
    nY = nS + int(rng.integers(0, 3))
    nX = 6
    rho = np.array(rho_choices[nS][int(rng.integers(0, 4))], dtype=float) / W
    # channel mu(x|w): random, sparse-ish
    mu = rng.dirichlet(np.full(nX, 0.6), size=W)
    mu[mu < 0.03] = 0.0
    mu /= mu.sum(axis=1, keepdims=True)
    mubar = mu.mean(axis=0)
    # response function: injective in b for each x
    hmap = np.array([rng.permutation(nY)[:nS] for _ in range(nX)])        # hmap[x, b] = y
    nuH = np.zeros((nX, nY))
    for x in range(nX):
        nuH[x, hmap[x]] = rho
    # a coupling of exact type rho
    beta = rng.permutation(np.repeat(np.arange(nS), (rho * W).astype(int)))
    progs = [nuH.copy()]
    for _ in range(30):
        kind = rng.integers(0, 3)
        if kind == 0:
            P = rng.dirichlet(np.ones(nY), size=nX) * rng.uniform(0.5, 1.0, size=(nX, 1))
        elif kind == 1:
            P = np.clip(nuH + rng.normal(0, 0.05, size=nuH.shape), 1e-6, None)
            P = P / P.sum(axis=1, keepdims=True) * rng.uniform(0.9, 1.0, size=(nX, 1))
        else:
            P = rng.dirichlet(np.full(nY, 0.3), size=nX)
            P[rng.random(P.shape) < 0.15] = 0.0
        progs.append(P)
    for P in progs:
        n_prog += 1
        with np.errstate(divide='ignore'):
            logP = np.log2(P)
        # Hoelder step
        ED = sum(mubar[x] * dhalf(nuH[x], P[x]) for x in range(nX) if mubar[x] > 0)
        qt = np.zeros((W, nS))
        qa = np.zeros((W, nS))
        for w in range(W):
            for b in range(nS):
                lv = np.array([logP[x, hmap[x, b]] for x in range(nX)])
                sel = mu[w] > 0
                qt[w, b] = 2.0 ** float(np.sum(mu[w][sel] * lv[sel])) if np.all(np.isfinite(lv[sel])) else 0.0
                qa[w, b] = float(np.sum(mu[w] * np.array([P[x, hmap[x, b]] for x in range(nX)])))
        Dbar = float(np.mean([dhalf(rho, qt[w]) for w in range(W)]))
        if np.isfinite(ED) and np.isfinite(Dbar):
            worst['holder'] = max(worst['holder'], ED - Dbar)
            if P is not progs[0]:
                worst['holder_nonhuman'] = max(worst.get('holder_nonhuman', -np.inf), ED - Dbar)
        if np.isfinite(Dbar):
            n_finite[0] += 1
        worst['qq'] = max(worst['qq'], float(np.max(qt - qa)))
        worst['qsum'] = max(worst['qsum'], float(np.max(qa.sum(axis=1))))
        Zw = np.sqrt(rho[None, :] * qt).sum(axis=1)
        # brute force over all maps Sigma^W
        Zbf = 0.0
        for bp in product(range(nS), repeat=W):
            Zbf += float(np.prod([sqrt(rho[bp[w]] * qt[w, bp[w]]) for w in range(W)]))
        worst['Z'] = max(worst['Z'], Zbf)
        assert abs(Zbf - float(np.prod(Zw))) <= 1e-12 * max(1.0, Zbf)
        # identities, when R < infinity
        Rv = np.mean([sum(mu[w, x] * -logP[x, hmap[x, beta[w]]] for x in range(nX) if mu[w, x] > 0) for w in range(W)])
        if np.isfinite(Rv):
            n_idQ[0] += 1
            mlogQ = -sum(log2(sqrt(rho[beta[w]] * qt[w, beta[w]])) for w in range(W))
            worst['idQ'] = max(worst['idQ'], abs(mlogQ - 2 ** (m_b - 1) * (H(rho) + Rv)))
            worst['idZ'] = max(worst['idZ'], abs(float(np.sum(np.log2(Zw))) + 2 ** (m_b - 1) * Dbar))
print(f"  {n_prog} programs in 40 instances (|Sigma| in {{2,3}}, |Y| up to 4, 8 cells, 6 inputs)")
print(f"  programs with finite Dbar: {n_finite[0]}; with finite R at the true coupling: {n_idQ[0]}")
print(f"  max [E_x D_half - Dbar]           = {worst['holder']:.3e}   (Hoelder step: must be <= 0 up to rounding;"
      f" 0 at the human)")
print(f"  max over non-human programs       = {worst['holder_nonhuman']:.3e}")
print(f"  max [qtilde_w(b) - q_w(b)]         = {worst['qq']:.3e}   (geometric <= arithmetic mean)")
print(f"  max_w sum_b q_w(b)                 = {worst['qsum']:.12f}   (<= 1)")
print(f"  max total mass Z (brute force)     = {worst['Z']:.12f}   (<= 1)")
print(f"  max |-log Q(beta) - 2^(m-1)(H+R)|  = {worst['idQ']:.3e}")
print(f"  max |log Z + 2^(m-1) Dbar|         = {worst['idZ']:.3e}")
assert worst['holder'] <= 1e-12 and worst['qq'] <= 1e-12 and worst['qsum'] <= 1 + 1e-12 and worst['Z'] <= 1 + 1e-12
assert worst['idQ'] <= 1e-9 and worst['idZ'] <= 1e-9

# ------------------------------------------------------------------------------------------------- (C)
print()
print("(C) Counting form of the closeness lemma, exhaustive over a type class (seed 142)")
rng = np.random.default_rng(142)
m_c, s0 = 5, 4
N = 2 ** m_c
rho = np.array([(N - s0) / N, s0 / N])
Hr = H(rho)
Lb = log2(comb(N, s0))
g = rng.integers(0, 3, size=N)                          # the human's model: h(w, b) = (g(w) + b) mod 3


def hlab(w, b):
    return (g[w] + b) % 3


# A program is a kernel nu(y|w) on Y = {0,1,2}; what matters are A1[w] = nu(h(w,1)|w), A0[w] = nu(h(w,0)|w).
programs = []          # (name, length, A0, A1)


def add(name, length, A0, A1):
    programs.append((name, length, np.asarray(A0, float), np.asarray(A1, float)))


add("human", 6, np.full(N, rho[0]), np.full(N, rho[1]))
add("uniform on Y", 4, np.full(N, 1 / 3), np.full(N, 1 / 3))
for k in range(1, N):
    q = k / N
    add(f"rate {k}/32", 11, np.full(N, 1 - q), np.full(N, q))
for _ in range(200):                                   # random kernels on (w, y)
    K = rng.dirichlet(np.ones(3), size=N) * rng.uniform(0.7, 1.0, size=(N, 1))
    add("random", 16, K[np.arange(N), [hlab(w, 0) for w in range(N)]], K[np.arange(N), [hlab(w, 1) for w in range(N)]])
dense = list(programs)
# deterministic set memorisers (coin 1 exactly on T): handled per coupling (finite risk only when T = beta')
intervals = [frozenset((s + i) % N for i in range(s0)) for s in range(N)]
subcubes = []
for coords in combinations(range(m_c), 3):
    for vals in product((0, 1), repeat=3):
        subcubes.append(frozenset(w for w in range(N) if all(((w >> c) & 1) == v for c, v in zip(coords, vals))))
L_int, L_sub, L_full = 6 + 5 + 2, 6 + 7 + 2, 6 + 16 + 2
# partial memorisers: coin 1 with probability 1 on T (|T| = t), rate (s0-t)/(N-t) elsewhere; finite risk iff T <= beta'
L_part = {1: 6 + 5 + 4, 2: 6 + 9 + 4, 3: 6 + 13 + 4}
kraft = (2 ** -6 + 2 ** -4 + (N - 1) * 2 ** -11 + 200 * 2 ** -16 + len(intervals) * 2 ** -L_int
         + len(subcubes) * 2 ** -L_sub + comb(N, s0) * 2 ** -L_full + sum(comb(N, t) * 2 ** -L_part[t] for t in L_part))
print(f"  N = {N} cells, s0 = {s0}, H(rho) = {Hr:.6f}, L_beta = {Lb:.4f} bits, couplings = {comb(N, s0)}")
print(f"  class: human, uniform, 31 rates, 200 random kernels, {len(intervals)} interval, {len(subcubes)} subcube,"
      f" {comb(N, s0)} full and {sum(comb(N, t) for t in L_part)} partial memorisers; Kraft sum = {kraft:.6f}")
assert kraft <= 1


def dbar_of(A0, A1):
    return float(np.mean(-2 * np.log2(np.sqrt(rho[0] * A0) + np.sqrt(rho[1] * A1))))


Dd = np.array([dbar_of(A0, A1) for (_, _, A0, A1) in dense])
Ld = np.array([l for (_, l, _, _) in dense], dtype=float)
L0 = np.array([-np.log2(A0) for (_, _, A0, _) in dense])          # programs x cells
L1 = np.array([-np.log2(A1) for (_, _, _, A1) in dense])
couplings = list(combinations(range(N), s0))
M = np.zeros((len(couplings), N))
for i, cpl in enumerate(couplings):
    M[i, list(cpl)] = 1.0
Rd = (L0.sum(axis=1)[None, :] + M @ (L1 - L0).T) / N              # couplings x programs
js = list(range(-2, 9))
# slack(pi, beta') := Dbar - H - R + 2 (L_beta - l - j)/N >= 0 is the event; record max over pi of (Dbar - H - R + 2(L_beta - l)/N)
best = (Dd[None, :] - Hr - Rd + 2 * (Lb - Ld[None, :]) / N).max(axis=1)
Sint, Ssub = set(intervals), set(subcubes)
D_det = Hr                                                           # Dbar of a deterministic set memoriser = H(rho)
for i, cpl in enumerate(couplings):
    S = frozenset(cpl)
    cand = [L_full]
    if S in Sint:
        cand.append(L_int)
    if S in Ssub:
        cand.append(L_sub)
    for l in cand:                                                   # R = 0, Dbar = H
        best[i] = max(best[i], D_det - Hr + 2 * (Lb - l) / N)
    for t in L_part:
        q = (s0 - t) / (N - t)
        for T in combinations(cpl, t):
            # on its coupling: R = (1/N) * [sum over the s0-t other coin-1 cells of -log q + sum over coin-0 cells of -log(1-q)]
            R = ((s0 - t) * -log2(q) + (N - s0) * -log2(1 - q)) / N
            D = (t * (-2 * log2(sqrt(rho[1]))) + (s0 - t) * (-2 * log2(sqrt(rho[0] * (1 - q)) + sqrt(rho[1] * q)))
                 + (N - s0) * (-2 * log2(sqrt(rho[0] * (1 - q)) + sqrt(rho[1] * q)))) / N
            best[i] = max(best[i], D - Hr - R + 2 * (Lb - L_part[t]) / N)
print("     j   Pr_beta'[event]   Kraft*2^-j")
for j in js:
    frac = float(np.mean(best >= 2 * j / N - 1e-12))
    print(f"   {j:3d}   {frac:14.6f}   {kraft * 2.0 ** -j:10.6f}" + ("" if frac <= kraft * 2.0 ** -j else "   VIOLATION"))
    assert frac <= kraft * 2.0 ** -j + 1e-12
nint = sum(1 for i, cpl in enumerate(couplings) if frozenset(cpl) in Sint)
nsub = sum(1 for i, cpl in enumerate(couplings) if frozenset(cpl) in Ssub)
print(f"  ({nint} interval and {nsub} subcube couplings; the event at j >= 1 occurs on "
      f"{int(np.sum(best >= 2 / N - 1e-12))} couplings)")

# ------------------------------------------------------------------------------------------------- (D)
print()
print("(D) Confounding (robust Prop 4.11(b)), m = 3, exhaustive")
m_d = 3
Wd = 2 ** m_d
for s0 in (1, 2, 3):
    groups = {}
    for f in product((0, 1), repeat=Wd):
        for S in combinations(range(Wd), s0):
            T = tuple(f[w] ^ (1 if w in S else 0) for w in range(Wd))
            groups.setdefault(T, []).append(f)
    sizes = {len(v) for v in groups.values()}
    distinct = all(len(set(v)) == len(v) for v in groups.values())
    n_worlds = 2 ** Wd * comb(Wd, s0)
    # best procedure: per data table T, copy one world's human; success = (number of T) / (number of worlds)
    best_avg = len(groups) / n_worlds
    print(f"  s0 = {s0}: {len(groups)} data tables, worlds per table = {sorted(sizes)}, humans pairwise different: "
          f"{distinct}; best average copying probability = {best_avg:.6f} = 1/{1 / best_avg:.0f} (C(8,s0) = {comb(Wd, s0)})")
    assert sizes == {comb(Wd, s0)} and distinct

# ------------------------------------------------------------------------------------------------- (E)
print()
print("(E) Weight-decay draft numbers")
sig = lambda u: 1 / (1 + exp(-u))


def omega_star(eps, q):
    astar = log((2 * (1 - q) * (1 - eps ** 2) - q * (1 + eps ** 2)) / (q * (1 + eps ** 2)))
    return 2 * q * eps ** 2 / ((1 - eps ** 2) * astar), astar


def newton_min(eps, q, om):
    th = np.array([1.0, 0.5])
    for _ in range(200):
        a_, b_ = eps * th[0] + th[1], eps * th[0] - th[1]
        da, db = np.array([eps, 1.0]), np.array([eps, -1.0])
        ga, gb = -(1 - q) * sig(-a_), -q * sig(-b_)
        grad = ga * da + gb * db + om * th
        ha, hb = (1 - q) * sig(a_) * sig(-a_), q * sig(b_) * sig(-b_)
        Hm = ha * np.outer(da, da) + hb * np.outer(db, db) + om * np.eye(2)
        th = th - np.linalg.solve(Hm, grad)
    return th


ws, ast = omega_star(0.1, 0.2)
print(f"  omega*(0.1, 0.2) = {ws:.6e} (a* = {ast:.6f})")
for fac in (0.99, 1.01):
    th = newton_min(0.1, 0.2, fac * ws)
    b_ = 0.1 * th[0] - th[1]
    print(f"    Newton at {fac} omega*: theta = ({th[0]:.4f}, {th[1]:.4f}), b = {b_:+.5f} -> error rate "
          f"{0.2 if b_ <= 0 else 0.0}")
for eps, q in ((0.1, 0.2), (0.8, 0.2), (0.7, 0.3)):
    print(f"  lambda_box({eps}, {q}) = 2 eps / ln((2-3q)/q) = {2 * eps / log((2 - 3 * q) / q):.6f};"
          f" L2 switch condition eps^2 < 1 - 2q: {eps ** 2 < 1 - 2 * q}")
d, mm, r = 100, 20, 10
p = 2.0 ** -r
Hp = H([1 - p, p])
LS = log2(comb(2 ** mm, int(p * 2 ** mm)))
for kap in (0, 30):
    for dS in (0, 20):
        Lam1 = 2 * log2(d) + 2 * log2(mm) + kap
        kg = 2 * log2(d) + 2 * log2(r) + kap
        cplus = Hp / (LS - dS - 4 - Lam1 - kg)
        print(f"  kappa = {kap:2d}, delta_S = {dS:2d}: c_+ / 2^-m = {cplus * 2 ** mm:.5f}")
print(f"  L_S = {LS:.3f}; two-rate example: no fixed prior for 0 < ck < log(3/2) = {log2(1.5):.6f}")

# ------------------------------------------------------------------------------------------------- (F)
print()
print("(F) D_half >= 2 Hel/ln 2 and TV <= sqrt(2 Hel), 20000 random pairs (seed 143)")
rng = np.random.default_rng(143)
w1 = w2 = -np.inf
for _ in range(20000):
    k = int(rng.integers(2, 6))
    P = rng.dirichlet(np.full(k, 0.5))
    Q = rng.dirichlet(np.full(k, 0.5)) * rng.uniform(0.3, 1.0)
    bc = float(np.sum(np.sqrt(P * Q)))
    hel = 1 - bc
    w1 = max(w1, 2 * hel / log(2) - (-2 * log2(bc)))
    w2 = max(w2, 0.5 * float(np.sum(np.abs(P - Q))) - sqrt(2 * hel))
print(f"  max [2 Hel/ln2 - D_half] = {w1:.3e} (<= 0);  max [TV - sqrt(2 Hel)] = {w2:.3e} (<= 0)")
assert w1 <= 1e-12 and w2 <= 1e-12
print()
print("All assertions passed.")
