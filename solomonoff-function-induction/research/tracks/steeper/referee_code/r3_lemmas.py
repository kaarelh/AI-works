"""Referee check r3: the combinatorial/analytic ingredients of notes Lemmas 2.1-2.3 and Thm 2(ii)(e),
(ii)(b), (iii), tested on adversarial random sub-probability hypotheses (independent code).

Setting: X = {0,1}^d with d = 8, junta length m = 5, |S| = s0 = 4 (p = 1/8), random parity a.
Hypothesis families (all sub-probabilities nu(.|x)):
  H1 partial memorisers: good model, plus correct error label on a random subset of S x {0,1}^{d-m},
     plus random mass deficit;
  H2 mixtures of a few parities with noise (per-input mixtures, i.e. product hypotheses);
  H3 hypotheses that know S on some z's, are anti-correlated elsewhere;
  H4 fully random tables.
Checks:
  L2.1  u(a') = (E[h0+h1] + shat(a'))/2, and #{a' : u(a') > 1/2 + 2^-(t+1)} < 2^(2t) for t = 1..4;
  L2.2  R_B >= -log2(u + p + 2^-B), B in {inf, 6, 12};
  L2.3  Q(S') = prod_z q_z(1_{S'}(z)) / (1+tau_B)^(2^m) has total mass <= 1 over all 2^(2^m) subsets
        (exactly, via the product formula, and by brute force for m = 4), and -log2 Q(S) = 2^m R_B + beta_B;
  (e)   vbar <= 1 - u; the Hoeffding counting step |{S' : |S'| = s0, avg_{S'} v > vbar + gamma}|
        <= C(2^m, s0) exp(-2 s0 gamma^2), by exhaustive enumeration of all s0-subsets;
  psi   the inequalities used in Thm 2(ii)(b) and (iii), on random parameters.
Seeded: numpy default_rng(12).
"""
import itertools
from math import comb, log2, exp, inf, log
import numpy as np

rng = np.random.default_rng(12)
d, m = 8, 5
n = 2 ** d
s0 = 4
p = s0 / 2 ** m
X = np.array([[(x >> i) & 1 for i in range(d)] for x in range(n)])   # bit i of x; first m bits = i < m
zidx = np.array([x & (2 ** m - 1) for x in range(n)])                 # junta coordinates z(x)
par = (X @ X.T) % 2                                                  # par[a', x] = <a', x> mod 2
chi = 1 - 2 * par


def make_instance():
    a = int(rng.integers(1, n))
    S = set(int(z) for z in rng.choice(2 ** m, s0, replace=False))
    inE = np.array([zidx[x] in S for x in range(n)])
    fa = par[a]
    ystar = fa ^ inE.astype(int)
    return a, S, inE, fa, ystar


def random_hyp(kind, a, S, inE, fa):
    tot = rng.uniform(0.5, 1.0, n) if rng.uniform() < 0.5 else np.ones(n)
    if kind == 1:
        pr = rng.uniform(0.001, 0.3)
        p1 = np.where(fa == 1, 1 - pr, pr).astype(float)           # nu(1|x) under the good model
        know = inE & (rng.uniform(size=n) < rng.uniform(0, 1))
        p1 = np.where(know, 1 - fa, p1)                              # memorise some error labels
    elif kind == 2:
        k = int(rng.integers(1, 5))
        comps = [a] + [int(c) for c in rng.integers(0, n, k - 1)]
        w = rng.dirichlet(np.ones(k))
        pr = rng.uniform(0.0, 0.3)
        p1 = sum(wj * np.where(par[c] == 1, 1 - pr, pr) for wj, c in zip(w, comps))
    elif kind == 3:
        knownz = set(int(z) for z in rng.choice(2 ** m, int(rng.integers(0, 2 ** m)), replace=False))
        p1 = np.array([(1 - fa[x]) if (zidx[x] in knownz and zidx[x] in S) else
                       (fa[x] if zidx[x] in knownz else rng.uniform()) for x in range(n)], dtype=float)
    else:
        p1 = rng.uniform(size=n)
    h1 = tot * p1
    h0 = tot * (1 - p1)
    return h0, h1


viol = dict(ident=0, lst=0, floor=0, Qmass=0, Qeq=0, vbar=0)
trials = 0
for trial in range(600):
    a, S, inE, fa, ystar = make_instance()
    kind = trial % 4 + 1
    h0, h1 = random_hyp(kind, a, S, inE, fa)
    trials += 1
    s = h0 - h1
    shat = (chi * s[None, :]).mean(axis=1)
    u_all = np.where(par == 0, h0[None, :], h1[None, :]).mean(axis=1)
    if np.max(np.abs(u_all - ((h0 + h1).mean() + shat) / 2)) > 1e-12:
        viol['ident'] += 1
    for t in range(1, 5):
        if np.sum(u_all > 0.5 + 2.0 ** -(t + 1)) >= 2 ** (2 * t):
            viol['lst'] += 1
    u = u_all[a]
    hy = np.where(ystar == 0, h0, h1)
    for B in [inf, 6.0, 12.0]:
        tauB = 0.0 if B == inf else 2.0 ** (1 - B)
        with np.errstate(divide='ignore'):
            loss = np.minimum(B, -np.log2(hy))
        RB = loss.mean()
        if RB < -log2(u + p + (0 if B == inf else 2.0 ** -B)) - 1e-12:
            viol['floor'] += 1
        # Lemma 2.3: q_z(b) = 2^{- E_w min(B, -log nu(f_a xor b | x))}
        if B == inf and np.any(hy == 0):
            continue
        qz = np.zeros((2 ** m, 2))
        for z in range(2 ** m):
            xs = np.where(zidx == z)[0]
            for b in (0, 1):
                lab = fa[xs] ^ b
                v = np.where(lab == 0, h0[xs], h1[xs])
                with np.errstate(divide='ignore'):
                    qz[z, b] = 2.0 ** (-np.mean(np.minimum(B, -np.log2(v))))
        total_mass = np.prod(qz.sum(axis=1) / (1 + tauB))
        if total_mass > 1 + 1e-12:
            viol['Qmass'] += 1
        logQS = sum(log2(qz[z, int(z in S)]) for z in range(2 ** m)) - 2 ** m * log2(1 + tauB)
        betaB = 2 ** m * log2(1 + tauB)
        if abs(-logQS - (2 ** m * RB + betaB)) > 1e-8:
            viol['Qeq'] += 1
    vz = np.array([np.mean(np.where((fa[zidx == z] ^ 1) == 0, h0[zidx == z], h1[zidx == z])) for z in range(2 ** m)])
    if vz.mean() > 1 - u + 1e-12:
        viol['vbar'] += 1
print(f"[L2.1-L2.3, (e) vbar] {trials} adversarial hypotheses; violations: {viol}")

# brute-force mass of Q over all subsets for m = 4 (2^16 subsets), a few random tables
mm = 4
worst = 0.0
for _ in range(5):
    q = rng.uniform(0, 1, (2 ** mm, 2))
    q = q / q.sum(axis=1, keepdims=True) * rng.uniform(0.7, 1.0, (2 ** mm, 1))
    tot = 0.0
    for bits in range(2 ** (2 ** mm)):
        tot += np.prod([q[z, (bits >> z) & 1] for z in range(2 ** mm)])
    worst = max(worst, tot)
print(f"[L2.3 brute force, m=4] max total mass of Q over 2^16 subsets = {worst:.6f} (<= 1)")

# Hoeffding counting step, exhaustive over all s0-subsets of {0,1}^m (m=5, s0=4: C(32,4)=35960)
viol_h = 0; checks = 0
for _ in range(40):
    v = rng.uniform(0, 1, 2 ** m) ** rng.uniform(0.3, 3)
    vbar = v.mean()
    sums = np.array([sum(c) for c in itertools.combinations(v, s0)]) / s0
    for gam in [0.1, 0.2, 0.3, 0.4]:
        cnt = int(np.sum(sums > vbar + gam))
        bound = comb(2 ** m, s0) * exp(-2 * s0 * gam ** 2)
        checks += 1
        if cnt > bound:
            viol_h += 1
print(f"[(e) Hoeffding counting] {checks} (population, gamma) cases, exhaustive over C(32,4) subsets: violations {viol_h}")

# psi inequalities used in Thm 2(ii)(b) and (iii)
viol_b = viol_iii = 0
for _ in range(200000):
    mm2 = int(rng.integers(3, 25)); c = 10 ** rng.uniform(-8, -1)
    Hp = rng.uniform(1e-4, 0.3); BS = 2 ** mm2 * Hp - rng.uniform(0, 2 * mm2)
    if BS <= 0:
        continue
    L1 = rng.uniform(0, 60); kg = rng.uniform(0, 40); eta = rng.uniform(0, 1e-2)
    R = rng.uniform(0, 2 * BS / 2 ** mm2)
    psi = c * max(0.0, BS - 2 ** mm2 * R) + R
    if c * 2 ** mm2 > 1:
        if psi <= c * (4 + L1 + kg) + Hp + eta:
            Lam2 = 2 ** mm2 * Hp - BS + 4 + L1 + kg
            if R < Hp - (c * Lam2 + eta) / (c * 2 ** mm2 - 1) - 1e-12:
                viol_b += 1
    else:
        if psi < c * BS + (1 - c * 2 ** mm2) * min(R, BS / 2 ** mm2) - 1e-12:
            viol_iii += 1
print(f"[psi] violations of the (ii)(b) implication: {viol_b}; of the (iii) lower bound: {viol_iii}")
