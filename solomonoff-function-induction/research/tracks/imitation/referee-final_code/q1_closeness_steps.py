#!/usr/bin/env python3
"""Referee check q1 (final referee of the imitation drafts, 2026-10-14).

Independent of every earlier script of the track: nothing is imported from robust/, checks/ or referee_code/,
and none of them was read before this file was written.  Seeded: numpy.random.default_rng(9101).
Python 3.11, NumPy 2.x.  log = log2; divergences in bits.

Machine-free steps of the closeness lemma (draft lem:imit:closeness = robust Lemma 4.6):
 (A) the generalised Hoelder inequality  sum_b prod_x f_x(b)^th_x <= prod_x (sum_b f_x(b))^th_x
     on random nonnegative arrays with zeros and weights with zeros;
 (B) on random instances (feature and latent-cause channels, |Sigma| in {2,3}, |Y| >= |Sigma|) and random kernels
     (probabilities, sub-probabilities, kernels with zeros, near-person, soft partial memorisers, the data kernel P*,
     kernels that put mass outside h(x,Sigma)):
       E_x D_half(nu_H||nu_pi) <= Dbar(pi)   (also cell by cell),
       qtilde_w <= q_w,  sum_b q_w <= 1,  Z_w <= 1,
       total mass of Q over ALL |Sigma|^(2^m) maps, by brute force, equals prod_w Z_w <= 1,
       -log Q(beta) = 2^(m-1) (H + R)  and  log Z = -2^(m-1) Dbar  for beta of exact type;
 (C) the hidden hypotheses: (C1) for a beta NOT of exact type the identity -log Q(beta) = 2^(m-1)(H+R) fails;
     (C2) for h NOT injective in b, sum_b q_w can exceed 1 and the Hoelder step can fail;
 (D) the trimming used to apply the conditional coding theorem with the extra condition k: lower approximations of
     2^k Q are enumerated and frozen as soon as their total would exceed 1; for the true k = floor(-log Z) nothing is
     frozen, for larger k the output stays a semimeasure;
 (E) the scalar inequalities used afterwards: Hel <= (ln 2 / 2) D_half (also for sub-probabilities),
     E <= 2m + 2 log(2H + c l0 + eps + 1), and 2 log(k+1) <= E(pi) whenever k <= -log Q(beta).
"""
from itertools import product
from math import log, log2, floor, sqrt

import numpy as np

rng = np.random.default_rng(9101)
TOL = 1e-12


def H(v):
    v = np.asarray(v, float)
    v = v[v > 0]
    return float(-(v * np.log2(v)).sum())


def bc(P, Q):
    return float(np.sum(np.sqrt(np.asarray(P, float) * np.asarray(Q, float))))


def dhalf(P, Q):
    b = bc(P, Q)
    return np.inf if b <= 0 else -2.0 * log2(b)


# ------------------------------------------------------------------------------------------------ (A)
print("(A) generalised Hoelder inequality, random arrays with zeros")
worstA = -np.inf
for t in range(20000):
    nx = int(rng.integers(1, 7))
    nb = int(rng.integers(1, 6))
    f = rng.exponential(1.0, size=(nx, nb)) * (rng.random((nx, nb)) > 0.2)
    th = rng.dirichlet(np.ones(nx))
    th[rng.random(nx) < 0.2] = 0.0
    if th.sum() == 0:
        th[0] = 1.0
    th /= th.sum()
    with np.errstate(divide='ignore', invalid='ignore'):
        # prod_x f_x(b)^th_x with 0^0 = 1
        terms = np.where(th[:, None] > 0, np.power(f, th[:, None]), 1.0)
    lhs = float(np.sum(np.prod(terms, axis=0)))
    rhs = float(np.prod([f[x].sum() ** th[x] if th[x] > 0 else 1.0 for x in range(nx)]))
    worstA = max(worstA, lhs - rhs)
print(f"  20000 trials: max(LHS - RHS) = {worstA:.3e}  (must be <= 0 up to rounding)")


# ------------------------------------------------------------------------------------------------ (B)
def make_instance(kind, m, nS, extraY):
    W = 2 ** m
    nY = nS + extraY
    counts = None
    while counts is None or min(counts) < 1:
        cuts = np.sort(rng.choice(np.arange(1, W), size=nS - 1, replace=False))
        counts = np.diff(np.concatenate([[0], cuts, [W]]))
    rho = counts / W
    if kind == "feature":
        per = rng.integers(1, 4, size=W)
        nX = int(per.sum())
        mu = np.zeros((W, nX))
        start = 0
        for w in range(W):
            mu[w, start:start + per[w]] = rng.dirichlet(np.ones(per[w]))
            start += per[w]
    else:
        nX = int(rng.integers(3, 8))
        mu = rng.dirichlet(np.full(nX, 0.5), size=W)
        mu[mu < 0.05] = 0.0
        for w in range(W):
            if mu[w].sum() == 0:
                mu[w, rng.integers(nX)] = 1.0
        mu /= mu.sum(axis=1, keepdims=True)
    h = np.array([rng.permutation(nY)[:nS] for _ in range(nX)])        # h[x, b], injective in b
    beta = rng.permutation(np.repeat(np.arange(nS), counts))            # exact type rho
    return dict(m=m, W=W, nS=nS, nY=nY, nX=nX, rho=rho, counts=counts, mu=mu, h=h, beta=beta, kind=kind)


def person(I):
    P = np.zeros((I['nX'], I['nY']))
    for x in range(I['nX']):
        P[x, I['h'][x]] = I['rho']
    return P


def data_kernel(I):
    W, nX, nY = I['W'], I['nX'], I['nY']
    P = np.zeros((nX, nY))
    for w in range(W):
        for x in range(nX):
            if I['mu'][w, x] > 0:
                P[x, I['h'][x, I['beta'][w]]] += I['mu'][w, x]
    s = P.sum(axis=1, keepdims=True)
    s[s == 0] = 1.0
    return P / s


def risk(I, P, beta=None):
    beta = I['beta'] if beta is None else beta
    tot = 0.0
    for w in range(I['W']):
        for x in range(I['nX']):
            mw = I['mu'][w, x]
            if mw > 0:
                v = P[x, I['h'][x, beta[w]]]
                tot += mw * (np.inf if v <= 0 else -log2(v))
    return tot / I['W']


def qq(I, P):
    W, nS = I['W'], I['nS']
    qa = np.zeros((W, nS))
    qt = np.zeros((W, nS))
    for w in range(W):
        sel = I['mu'][w] > 0
        xs = np.nonzero(sel)[0]
        for b in range(nS):
            vals = np.array([P[x, I['h'][x, b]] for x in xs])
            th = I['mu'][w, xs]
            qa[w, b] = float(np.sum(th * vals))
            qt[w, b] = 0.0 if np.any(vals <= 0) else float(2.0 ** np.sum(th * np.log2(vals)))
    return qa, qt


def programs(I, n_random=12):
    nX, nY = I['nX'], I['nY']
    nuH = person(I)
    Ps = [("person", nuH), ("P*", data_kernel(I)), ("uniform", np.full((nX, nY), 1.0 / nY))]
    for _ in range(n_random):
        Ps.append(("random", rng.dirichlet(np.ones(nY), size=nX)))
        Ps.append(("subprob", rng.dirichlet(np.ones(nY), size=nX) * rng.uniform(0.3, 1.0, size=(nX, 1))))
        Z = rng.dirichlet(np.full(nY, 0.4), size=nX)
        Z[rng.random(Z.shape) < 0.2] = 0.0
        Ps.append(("zeros", Z))
        N = nuH * np.exp(rng.normal(0, 0.3, size=nuH.shape)) + 1e-3 * (nuH == 0)
        N /= N.sum(axis=1, keepdims=True)
        Ps.append(("near", N * rng.uniform(0.9, 1.0, size=(nX, 1))))
        # soft partial memoriser of a random set of cells (inputs of those cells get (1-eta) on the coupling's label)
        M = nuH.copy()
        eta = rng.uniform(0.001, 0.3)
        cells = rng.random(I['W']) < rng.uniform(0.1, 0.9)
        for w in np.nonzero(cells)[0]:
            for x in np.nonzero(I['mu'][w] > 0)[0]:
                M[x] = eta * nuH[x]
                M[x, I['h'][x, I['beta'][w]]] += 1 - eta
        Ps.append(("memo", M))
        if nY > I['nS']:
            O = nuH * rng.uniform(0.2, 1.0, size=(nX, 1))
            for x in range(nX):
                out = [y for y in range(nY) if y not in I['h'][x]]
                O[x, out] += (1 - O[x].sum()) / len(out)
            Ps.append(("outside", O))
        lam = rng.uniform(0, 1)
        Ps.append(("mix", lam * nuH + (1 - lam) * data_kernel(I)))
    return Ps


print()
print("(B) closeness-lemma steps on random instances (seed 9101)")
stats = dict(holder=-np.inf, holder_cell=-np.inf, tq_le_q=-np.inf, sumq=-np.inf, Zw=-np.inf, mass_vs_prod=0.0,
             mass=-np.inf, idQ=0.0, idZ=0.0)
n_inst, n_prog, n_fin = 0, 0, 0
for trial in range(60):
    kind = "feature" if trial % 2 == 0 else "latent"
    m = 2 if trial % 3 == 0 else 3
    nS = int(rng.integers(2, 4))
    I = make_instance(kind, m, nS, int(rng.integers(0, 3)))
    n_inst += 1
    nuH = person(I)
    mubar = I['mu'].mean(axis=0)
    Hr = H(I['rho'])
    allmaps = np.array(list(product(range(nS), repeat=I['W'])))         # all |Sigma|^(2^m) maps
    for name, P in programs(I):
        n_prog += 1
        qa, qt = qq(I, P)
        stats['tq_le_q'] = max(stats['tq_le_q'], float(np.max(qt - qa)))
        stats['sumq'] = max(stats['sumq'], float(np.max(qa.sum(axis=1))))
        Zw = np.sqrt(I['rho'][None, :] * qt).sum(axis=1)
        stats['Zw'] = max(stats['Zw'], float(Zw.max()))
        # brute force over all maps
        Qall = np.prod(np.sqrt(I['rho'][allmaps] * qt[np.arange(I['W'])[None, :], allmaps]), axis=1)
        mass = float(Qall.sum())
        stats['mass'] = max(stats['mass'], mass)
        stats['mass_vs_prod'] = max(stats['mass_vs_prod'], abs(mass - float(np.prod(Zw))))
        R = risk(I, P)
        if not np.isfinite(R):
            continue
        n_fin += 1
        ED = sum(mubar[x] * dhalf(nuH[x], P[x]) for x in range(I['nX']) if mubar[x] > 0)
        Dw = np.array([dhalf(I['rho'], qt[w]) for w in range(I['W'])])
        Dbar = float(Dw.mean())
        stats['holder'] = max(stats['holder'], ED - Dbar)
        for w in range(I['W']):
            EDw = sum(I['mu'][w, x] * dhalf(nuH[x], P[x]) for x in range(I['nX']) if I['mu'][w, x] > 0)
            stats['holder_cell'] = max(stats['holder_cell'], EDw - Dw[w])
        Qb = float(np.prod(np.sqrt(I['rho'][I['beta']] * qt[np.arange(I['W']), I['beta']])))
        stats['idQ'] = max(stats['idQ'], abs(-log2(Qb) - 2 ** (m - 1) * (Hr + R)) / max(1.0, abs(2 ** (m - 1) * (Hr + R))))
        stats['idZ'] = max(stats['idZ'], abs(log2(float(np.prod(Zw))) + 2 ** (m - 1) * Dbar) / max(1.0, 2 ** (m - 1) * Dbar))
print(f"  {n_inst} instances, {n_prog} programs ({n_fin} with finite risk)")
print(f"  max(E_x D_half - Dbar)            = {stats['holder']:.3e}   (Hoelder step; must be <= 0)")
print(f"  max cell-wise (E_x|w D_half - D_w) = {stats['holder_cell']:.3e}")
print(f"  max(qtilde_w - q_w)               = {stats['tq_le_q']:.3e}   (AM-GM; must be <= 0)")
print(f"  max_w sum_b q_w                   = {stats['sumq']:.15f}   (must be <= 1)")
print(f"  max Z_w                           = {stats['Zw']:.15f}   (Cauchy-Schwarz; must be <= 1)")
print(f"  max total mass of Q (brute force) = {stats['mass']:.15f};  max |mass - prod Z_w| = {stats['mass_vs_prod']:.2e}")
print(f"  identity -log Q(beta) = 2^(m-1)(H+R): max relative error {stats['idQ']:.2e}")
print(f"  identity log Z = -2^(m-1) Dbar:       max relative error {stats['idZ']:.2e}")

# ------------------------------------------------------------------------------------------------ (C)
print()
print("(C1) exact type is needed for the evaluation identity")
worstC1 = 0.0
for trial in range(20):
    I = make_instance("feature" if trial % 2 else "latent", 3, 3, 1)
    bad = I['beta'].copy()
    # move one cell to another coin: type no longer rho
    i = int(rng.integers(I['W']))
    bad[i] = (bad[i] + 1) % I['nS']
    P = programs(I, n_random=1)[3][1]
    qa, qt = qq(I, P)
    R = risk(I, P, bad)
    if not np.isfinite(R):
        continue
    Qb = float(np.prod(np.sqrt(I['rho'][bad] * qt[np.arange(I['W']), bad])))
    worstC1 = max(worstC1, abs(-log2(Qb) - 2 ** 2 * (H(I['rho']) + R)))
print(f"  beta with one cell moved off the type: max |-log Q(beta) - 2^(m-1)(H+R)| = {worstC1:.3f} bits (nonzero:"
      f" the identity uses sum_w log 1/rho(beta(w)) = 2^m H(rho), true only at exact type)")

print("(C2) injectivity of h(x,.) is needed")
best_sum, best_hold = -np.inf, -np.inf
for trial in range(4000):
    I = make_instance("latent", 2, 3, 0)
    # make h non-injective at some inputs: coins 0 and 1 give the same label
    hh = I['h'].copy()
    xs = rng.random(I['nX']) < 0.6
    hh[xs, 1] = hh[xs, 0]
    I['h'] = hh
    nuH = np.zeros((I['nX'], I['nY']))
    for x in range(I['nX']):
        for b in range(I['nS']):
            nuH[x, hh[x, b]] += I['rho'][b]          # the person's kernel: push-forward of rho
    P = rng.dirichlet(np.ones(I['nY']), size=I['nX'])
    qa, qt = qq(I, P)
    best_sum = max(best_sum, float(qa.sum(axis=1).max()))
    R = risk(I, P)
    mubar = I['mu'].mean(axis=0)
    ED = sum(mubar[x] * dhalf(nuH[x], P[x]) for x in range(I['nX']) if mubar[x] > 0)
    Dbar = float(np.mean([dhalf(I['rho'], qt[w]) for w in range(I['W'])]))
    best_hold = max(best_hold, ED - Dbar)
print(f"  non-injective h: max_w sum_b q_w = {best_sum:.4f} (> 1 possible); max(E_x D_half - Dbar) = {best_hold:.4f}")
print("  so with two coins on one label the coding semimeasure is not a semimeasure and the first inequality of the")
print("  lemma can fail; the draft states injectivity in def:imit:setting(b), as it must.")

# ------------------------------------------------------------------------------------------------ (D)
print()
print("(D) trimming of 2^k Q for the conditional coding theorem with the extra condition k")
I = make_instance("latent", 3, 2, 1)
P = programs(I, n_random=1)[4][1] * 0.97 + 0.03 * person(I)                  # a sub-probability kernel
qa, qt_true = qq(I, P)
allmaps = np.array(list(product(range(I['nS']), repeat=I['W'])))
Zw = np.sqrt(I['rho'][None, :] * qt_true).sum(axis=1)
Z = float(np.prod(Zw))
ktrue = floor(-log2(Z))
GRID = 2.0 ** -40


def Q_stage(s):
    Ps = np.floor(P * 2 ** s) / 2 ** s                   # rational lower approximations, nondecreasing in s
    _, qt = qq(I, Ps)
    vals = np.prod(np.sqrt(I['rho'][allmaps] * qt[np.arange(I['W'])[None, :], allmaps]), axis=1)
    return np.floor(vals / GRID) * GRID                   # rational lower bounds of the stage values


prev = None
stages = [Q_stage(s) for s in range(1, 31)]
for s in range(1, len(stages)):
    assert np.all(stages[s] >= stages[s - 1] - 1e-300), "approximations not monotone"
for k in (ktrue, ktrue + 1, ktrue + 3):
    out = np.zeros(len(allmaps))
    frozen_at = None
    for s, Qs in enumerate(stages):
        if (2.0 ** k) * Qs.sum() <= 1.0:
            out = (2.0 ** k) * Qs
        else:
            frozen_at = s + 1
            break
    print(f"  k = {k}{' (true k)' if k == ktrue else ''}: frozen at stage {frozen_at}; output mass {out.sum():.6f};"
          f" 2^k Z = {(2.0 ** k) * Z:.6f}")
print(f"  true k = floor(-log Z) = {ktrue}, Z = {Z:.6e}: for the true k nothing is frozen and the output tends to 2^k Q;"
      f" for larger k the output stays below mass 1.")

# ------------------------------------------------------------------------------------------------ (E)
print()
print("(E) scalar inequalities")
worst_hel = -np.inf
for t in range(20000):
    n = int(rng.integers(2, 6))
    Pp = rng.dirichlet(np.ones(n))
    Qq = rng.dirichlet(np.ones(n)) * rng.uniform(0.0, 1.0)
    Qq[rng.random(n) < 0.2] = 0.0
    d = dhalf(Pp, Qq)
    hel = 1 - bc(Pp, Qq)
    if np.isfinite(d):
        worst_hel = max(worst_hel, hel - log(2) / 2 * d)
print(f"  max(Hel - (ln2/2) D_half) over 20000 pairs (sub-probabilities included) = {worst_hel:.3e} (must be <= 0)")
worst_E = -np.inf
for t in range(200000):
    mm = int(rng.integers(1, 60))
    Hh = rng.uniform(0, 5)
    x = rng.uniform(0, 10) * (rng.random() < 0.8)
    E = 2 * log2(2 ** (mm - 1) * (2 * Hh + x) + 1)
    worst_E = max(worst_E, E - (2 * mm + 2 * log2(2 * Hh + x + 1)))
print(f"  max(E - (2m + 2 log(2H + c l0 + eps + 1))) over 2e5 draws = {worst_E:.3e} (must be <= 0)")
worst_k = -np.inf
for t in range(200000):
    mm = int(rng.integers(1, 40))
    Hh, Rr = rng.uniform(0, 4), rng.uniform(0, 4)
    mQ = 2 ** (mm - 1) * (Hh + Rr)
    k = floor(rng.uniform(0, mQ))
    worst_k = max(worst_k, 2 * log2(k + 1) - 2 * log2(mQ + 1))
print(f"  max(2 log(k+1) - E(pi)) for 0 <= k <= -log Q(beta) = {worst_k:.3e} (must be <= 0)")
