#!/usr/bin/env python3
"""Referee check q2 (final referee of the imitation drafts, 2026-10-14).

Independent code; seeded with numpy.random.default_rng(9102).  log = log2.

The machine-free (counting) forms of the coding lemma and of the closeness lemma, exhaustively over a whole type
class, in explicit prefix classes C with lengths l(pi) and Kraft sum k_C:

  coding:    Pr_{beta'}[ exists pi in C : 2^m R_beta'(pi) <= L - l(pi) - j ]                         <= k_C 2^-j
  closeness: Pr_{beta'}[ exists pi in C : Dbar(pi) >= H + R_beta'(pi) - 2 (L - l(pi) - j)/2^m ]       <= k_C 2^-j
             equivalently Dbar(pi) >= R(pi) - H + 2 (l(pi) + j + Delta)/2^m, Delta := 2^m H - L <= |Sigma| log(2^m+1)

beta' uniform on the type class T of rho, L = log|T|.  Both follow from the proofs of the two lemmas with the
universal machine replaced by the explicit code (Q/Z is a probability on Sigma^W, Z does not depend on beta', and
-log Q(beta') + log Z = 2^(m-1)(H + R_beta' - Dbar) at exact type).  The role of I_beta(pi) <= l(pi) + kappa in the
lemma is played here by l(pi).  We also evaluate a hypothetical sharpening that halves the information term,
Dbar(pi) >= R(pi) - H + (l(pi) + j + 2 Delta)/2^m (the counting form of 'Dbar <= R - H + (I + 2(delta + ...))/2^m'),
to see whether the factor 2 in front of I_beta can be dropped: it cannot (memorisers violate the sharpened form for
every coupling), so the factor 2 is needed.

Instances
  F: feature case, m = 4 (16 cells), Sigma = {0,1,2}, rho = (10,3,3)/16, Y = {0,1,2,3}, two inputs per cell with a
     random channel and a random injective response; all 160,160 couplings of the type class.
  Lt: latent-cause case, m = 3 (8 cells), Sigma = {0,1,2}, rho = (4,2,2)/8, five shared inputs; all 420 couplings.
  F2: feature case, m = 4, Sigma = {0,1}, rho = (12,4)/16, one input per cell; all 1820 couplings, and the class
     contains the soft memoriser of every coupling (the tightness test of the factor 2).
Class (lengths chosen so that the Kraft sum is below 1): the person (l0 = 4), the uniform kernel, near-copies with
other coin laws, random kernels and sub-probabilities, soft partial memorisers of every pattern on the first t <= 6
cells (feature case), soft memorisers of 'structured' couplings (cyclic shifts of sorted arrangements, cheap), and,
in the latent case, the data kernel of every coupling of the type class (the full memorisers, at length
l0 + ceil(L) + 2).
"""
from itertools import combinations, product
from math import comb, log2, ceil, factorial

import numpy as np

rng = np.random.default_rng(9102)


def H(v):
    v = np.asarray(v, float)
    v = v[v > 0]
    return float(-(v * np.log2(v)).sum())


def dhalf_rows(rho, Q):
    b = np.sqrt(rho[None, :] * Q).sum(axis=1)
    with np.errstate(divide='ignore'):
        return np.where(b > 0, -2 * np.log2(b), np.inf)


def type_class(W, counts):
    """All maps W -> Sigma with |beta^-1(b)| = counts[b], as an int8 array (n, W)."""
    nS = len(counts)
    out = []

    def rec(prefix_free, b, assign):
        if b == nS - 1:
            a = assign.copy()
            a[list(prefix_free)] = b
            out.append(a)
            return
        for S in combinations(sorted(prefix_free), counts[b]):
            a = assign.copy()
            a[list(S)] = b
            rec(prefix_free - set(S), b + 1, a)

    rec(set(range(W)), 0, np.full(W, -1, dtype=np.int8))
    return np.array(out, dtype=np.int8)


def run(name, W, counts, mu, h, nY, progs):
    """progs: list of (label, length, kernel P[x,y]).  Returns frequencies of the events."""
    nS = len(counts)
    rho = np.array(counts, float) / W
    Hr = H(rho)
    T = type_class(W, counts)
    nT = len(T)
    L = log2(factorial(W)) - sum(log2(factorial(c)) for c in counts)
    assert abs(L - log2(nT)) < 1e-9
    m = int(round(log2(W)))
    kC = sum(2.0 ** -l for _, l, _ in progs)
    onehot = np.zeros((nT, W * nS), dtype=np.float64)
    onehot[np.repeat(np.arange(nT), W), (np.tile(np.arange(W), nT) * nS + T.reshape(-1))] = 1.0
    js = np.arange(-4, 13)
    hit_cod = {j: np.zeros(nT, bool) for j in js}
    hit_clo2 = {j: np.zeros(nT, bool) for j in js}
    hit_half = {j: np.zeros(nT, bool) for j in js}
    Delta = W * Hr - L
    worst_label = {}
    nX = mu.shape[1]
    for lab, l, P in progs:
        with np.errstate(divide='ignore'):
            lp = np.log2(P)
        r = np.zeros((W, nS))
        lgq = np.zeros((W, nS))
        for w in range(W):
            xs = np.nonzero(mu[w] > 0)[0]
            for b in range(nS):
                v = lp[xs, h[xs, b]]
                r[w, b] = -np.sum(mu[w, xs] * v) if np.all(np.isfinite(v)) else np.inf
        qt = np.where(np.isfinite(r), 2.0 ** (-r), 0.0)          # geometric means qtilde_w(b) = 2^(-r[w,b])
        Dbar = float(np.mean(dhalf_rows(rho, qt)))
        rf = np.where(np.isfinite(r), r, 1e9).reshape(-1)
        R = onehot @ rf / W                                       # R_beta'(pi) for every beta' in T
        for j in js:
            hit_cod[j] |= (W * R <= L - l - j + 1e-9)
            if np.isfinite(Dbar):
                e2 = Dbar >= Hr + R - 2 * (L - l - j) / W - 1e-12
                eh = Dbar >= R - Hr + (l + j + 2 * Delta) / W - 1e-12
                hit_clo2[j] |= e2
                hit_half[j] |= eh
                if j == 0 and e2.any():
                    worst_label[lab] = worst_label.get(lab, 0) + int(e2.sum())
    print(f"  {name}: |T| = {nT}, L = {L:.3f}, H(rho) = {Hr:.4f}, 2^m H - L = {W * Hr - L:.3f}"
          f" (<= |Sigma| log(2^m+1) = {nS * log2(W + 1):.3f}), {len(progs)} programs, Kraft k_C = {kC:.4f}")
    print("     j   coding freq    closeness (lemma)  bound k_C 2^-j   halved information term (hypothetical)")
    ok = True
    for j in js:
        fc, f2, f1 = hit_cod[j].mean(), hit_clo2[j].mean(), hit_half[j].mean()
        bnd = kC * 2.0 ** -int(j)
        ok &= (fc <= bnd + 1e-12) and (f2 <= bnd + 1e-12)
        print(f"   {int(j):3d}   {fc:11.6f}   {f2:15.6f}   {bnd:14.6f}   {f1:12.6f}{'  <-- exceeds bound' if f1 > bnd else ''}")
    print(f"     coding and closeness (lemma) within k_C 2^-j at every j: {ok}")
    if worst_label:
        print(f"     programs triggering the closeness event at j = 0 (couplings counted): {worst_label}")
    return ok


# ------------------------------------------------------------------------------------------------ instance F
print("Instance F (feature case, exhaustive over 160,160 couplings)")
W, counts, nY = 16, (10, 3, 3), 4
nS = 3
nX = 2 * W
mu = np.zeros((W, nX))
for w in range(W):
    mu[w, 2 * w:2 * w + 2] = rng.dirichlet([2.0, 2.0])
h = np.array([rng.permutation(nY)[:nS] for _ in range(nX)])
rho = np.array(counts) / W
nuH = np.zeros((nX, nY))
for x in range(nX):
    nuH[x, h[x]] = rho
progs = [("person", 4, nuH), ("uniform", 3, np.full((nX, nY), 1 / nY))]
for t in range(30):
    rp = rng.dirichlet(rho * 20)
    P = np.zeros((nX, nY))
    for x in range(nX):
        P[x, h[x]] = rp
    progs.append(("near-copy", 10, P))
for t in range(60):
    progs.append(("random", 12, rng.dirichlet(np.ones(nY), size=nX)))
    progs.append(("subprob", 12, rng.dirichlet(np.ones(nY), size=nX) * rng.uniform(0.3, 1, size=(nX, 1))))
eta = 0.01


def soft_memo(pattern_cells, pattern):
    P = nuH.copy()
    for w, b in zip(pattern_cells, pattern):
        for x in (2 * w, 2 * w + 1):
            P[x] = eta * nuH[x]
            P[x, h[x, b]] += 1 - eta
    return P


for t in range(1, 7):
    lt = 4 + ceil(2 * log2(t + 1)) + ceil(t * log2(3))
    for pat in product(range(3), repeat=t):
        progs.append((f"memo{t}", lt, soft_memo(range(t), pat)))
# structured couplings: sorted arrangement and its cyclic shifts and reversals, at length l0 + 6
base = np.repeat(np.arange(3), counts)
structured = set()
for s in range(W):
    for order in ((0, 1, 2), (0, 2, 1), (1, 0, 2), (2, 1, 0)):
        arr = np.repeat(np.array(order), [counts[o] for o in order])
        structured.add(tuple(np.roll(arr, s)))
for st in sorted(structured):
    progs.append(("structured", 4 + 9, soft_memo(range(W), st)))
okF = run("F", W, counts, mu, h, nY, progs)

# ------------------------------------------------------------------------------------------------ instance Lt
print()
print("Instance Lt (latent-cause channel, exhaustive over 420 couplings)")
W, counts, nY = 8, (4, 2, 2), 4
nX = 5
mu = rng.dirichlet(np.full(nX, 0.7), size=W)
mu[mu < 0.06] = 0.0
mu /= mu.sum(axis=1, keepdims=True)
h = np.array([rng.permutation(nY)[:3] for _ in range(nX)])
rho = np.array(counts) / W
nuH = np.zeros((nX, nY))
for x in range(nX):
    nuH[x, h[x]] = rho
T = type_class(W, counts)
L = log2(len(T))


def data_kernel(beta):
    P = np.zeros((nX, nY))
    for w in range(W):
        for x in range(nX):
            if mu[w, x] > 0:
                P[x, h[x, beta[w]]] += mu[w, x]
    s = P.sum(axis=1, keepdims=True)
    s[s == 0] = 1
    return P / s


progs = [("person", 4, nuH), ("uniform", 3, np.full((nX, nY), 1 / nY))]
for t in range(30):
    rp = rng.dirichlet(rho * 20)
    P = np.zeros((nX, nY))
    for x in range(nX):
        P[x, h[x]] = rp
    progs.append(("near-copy", 10, P))
for t in range(60):
    progs.append(("random", 12, rng.dirichlet(np.ones(nY), size=nX)))
    progs.append(("subprob", 12, rng.dirichlet(np.ones(nY), size=nX) * rng.uniform(0.3, 1, size=(nX, 1))))
lfull = 4 + ceil(L) + 2
for beta2 in T:
    progs.append(("full-memo", lfull, 0.98 * data_kernel(beta2) + 0.02 * nuH))
okL = run("Lt", W, counts, mu, h, nY, progs)

# ------------------------------------------------------------------------------------------------ instance F2
print()
print("Instance F2 (feature case, every coupling's memoriser in the class; tightness of the factor 2)")
W, counts, nY = 16, (12, 4), 2
nX = W
mu = np.eye(W)
h = np.array([rng.permutation(2) for _ in range(nX)])
rho = np.array(counts) / W
nuH = np.zeros((nX, nY))
for x in range(nX):
    nuH[x, h[x]] = rho
T = type_class(W, counts)
L = log2(len(T))
progs = [("person", 4, nuH), ("uniform", 3, np.full((nX, nY), 1 / nY))]
for t in range(30):
    rp = rng.dirichlet(rho * 20)
    P = np.zeros((nX, nY))
    for x in range(nX):
        P[x, h[x]] = rp
    progs.append(("near-copy", 10, P))
lfull = 4 + ceil(L) + 2
for beta2 in T:
    P = 0.01 * nuH.copy()
    for w in range(W):
        P[w, h[w, beta2[w]]] += 0.99
    progs.append(("full-memo", lfull, P))
okF2 = run("F2", W, counts, mu, h, nY, progs)
print()
print(f"ALL COUNTING FORMS OF THE LEMMAS HOLD: {okF and okL and okF2}")
