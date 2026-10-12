"""q2 (referee, second run): brute-force tests of the finite combinatorial/analytic ingredients of
notes Prop 1.3, Lemmas 2.1-2.3 and Thm 2(ii)(e), written independently of the track's scripts.

(a) Prop 1.3(i): for random finite families F of functions on N inputs, compute
      V_dual = max_Q sum_i H(Q_{x_i})   (concave maximisation, exponentiated gradient)
      V_primal = min_nu max_f sum_i -log nu(f(x_i)|x_i)   (via nu = optimal Q's marginals, and via
      a direct subgradient method), and check V_primal >= V_dual - tol (weak duality, the lower bound)
      and |V_primal - V_dual| small (the claimed minimax equality).  Includes the 4-function example.
(b) Lemma 2.1: list size |{a': u(pi;a') > 1/2 + 2^{-t-1}}| < 2^{2t} for adversarial semimeasure
      hypotheses on {0,1}^d (mixtures of parities with sub-probability mass, tables, hedges).
(c) Lemma 2.3: the semimeasure Q on subsets S' of {0,1}^m.  With per-z normalisation
      Q(S') = prod_z q_z(1_{S'}(z)) / (1+tau)  [per factor]  check sum_{S'} Q <= 1 and
      -log Q(S) = 2^m R_B + beta_B.  Also evaluate the literal formula of the notes, which divides the
      whole product by (1+tau) once, and report whether it is still a semimeasure.
(d) Thm 2(ii)(e) counting step: for a population v on 2^m points and s0-subsets, exhaustively count
      |{S': avg_{S'} v >= mean(v) + gamma}| and compare with C(2^m, s0) exp(-2 s0 gamma^2).
Seeded: numpy default_rng(20261012). Output: q2_lemmas.out
"""
import itertools
from math import comb, log2, exp, inf
import numpy as np

rng = np.random.default_rng(20261012)
out = []
P = lambda *a: out.append(" ".join(str(x) for x in a))

def Hvec(q):
    q = q[q > 0]
    return float(-(q*np.log2(q)).sum())

# ---------------------------------------------------------------- (a)
P("=" * 78)
P("(a) Prop 1.3(i): minimax value max_Q sum H(Q_x) vs min_nu max_f loss")

def dual_value(F, labels, iters=20000):
    # F: array (nf, N) of label indices; maximise sum_i H(Q_{x_i}) over Q in simplex(nf) by mirror ascent
    nf, N = F.shape
    w = np.ones(nf)/nf
    best = -1
    bestw = w
    for it in range(iters):
        marg = [np.bincount(F[:, i], weights=w, minlength=labels) for i in range(N)]
        val = sum(Hvec(m) for m in marg)
        if val > best:
            best, bestw = val, w.copy()
        # gradient d/dw_f sum_i H = sum_i -log2 marg_i(F[f,i]) - 1/ln2
        g = np.array([sum(-np.log2(max(marg[i][F[f, i]], 1e-300)) for i in range(N)) for f in range(nf)])
        w = w*np.exp(0.05*(g - g.max()))
        w /= w.sum()
    return best, bestw

def primal_of(F, nu):
    # max over f of sum_i -log2 nu_i(F[f,i])
    return max(sum(-np.log2(nu[i][F[f, i]]) for i in range(F.shape[1])) for f in range(F.shape[0]))

def primal_direct(F, labels, iters=6000):
    # subgradient on logits of nu_i (full probability vectors)
    nf, N = F.shape
    th = np.zeros((N, labels))
    best = inf
    for it in range(iters):
        nu = np.exp(th - th.max(1, keepdims=True)); nu /= nu.sum(1, keepdims=True)
        losses = [sum(-np.log2(nu[i][F[f, i]]) for i in range(N)) for f in range(nf)]
        fstar = int(np.argmax(losses)); best = min(best, losses[fstar])
        # gradient of loss of fstar wrt logits: (nu - e_y)/ln2
        gr = nu.copy()
        for i in range(N):
            gr[i, F[fstar, i]] -= 1
        th -= (0.5/np.sqrt(it + 1))*gr
    return best

ex = np.array([[0, 0], [0, 1], [1, 0], [2, 0]])   # (a,a),(a,b),(b,a),(c,a) with a=0,b=1,c=2
v, w = dual_value(ex, 3)
marg = [np.bincount(ex[:, i], weights=w, minlength=3) for i in range(2)]
P(f"  example: max_Q sum H = {v:.5f}; primal at nu=Q*-marginals = {primal_of(ex, marg):.5f}; "
  f"direct primal search = {primal_direct(ex, 3):.5f}; sum log|F(x)| = {log2(3)+log2(2):.5f}")
viol = 0; gaps = []
for trial in range(60):
    N = int(rng.integers(2, 5)); L = int(rng.integers(2, 4)); nf = int(rng.integers(2, 7))
    F = rng.integers(0, L, size=(nf, N))
    v, w = dual_value(F, L, iters=4000)
    marg = [np.bincount(F[:, i], weights=w, minlength=L) for i in range(N)]
    pv = primal_of(F, [np.maximum(m, 1e-12) for m in marg])
    # weak duality on random sub-probability nu
    for _ in range(50):
        nu = [rng.dirichlet(np.ones(L))*rng.uniform(0.5, 1.0) for _ in range(N)]
        if primal_of(F, nu) < v - 1e-6:
            viol += 1
    gaps.append(pv - v)
P(f"  60 random families: weak-duality violations (random sub-prob nu below dual value) = {viol}; "
  f"primal(Q*-marginals) - dual: max {max(gaps):.2e}, min {min(gaps):.2e}")

# ---------------------------------------------------------------- (b)
P("=" * 78)
P("(b) Lemma 2.1 list bound for semimeasure hypotheses")
d = 7
X = np.array([[(x >> i) & 1 for i in range(d)] for x in range(2**d)])
A = np.array([[(a >> i) & 1 for i in range(d)] for a in range(2**d)])
PAR = (X @ A.T) % 2          # PAR[x, a'] = f_{a'}(x)
def list_sizes(h0, h1):
    # u(pi; a') = E_x nu(f_{a'}(x)|x)
    u = np.where(PAR == 0, h0[:, None], h1[:, None]).mean(0)
    return {t: int((u > 0.5 + 2.0**(-t-1)).sum()) for t in range(1, 6)}
worst = {t: 0 for t in range(1, 6)}; viol = 0
for trial in range(400):
    kind = trial % 4
    if kind == 0:   # mixture of k parities with weights, total mass <= 1, per-input product mixture
        k = int(rng.integers(1, 12)); idx = rng.choice(2**d, k, replace=False); wts = rng.dirichlet(np.ones(k))
        h0 = (PAR[:, idx] == 0) @ wts; h1 = (PAR[:, idx] == 1) @ wts
        mass = rng.uniform(0.7, 1.0); h0 *= mass; h1 *= mass
    elif kind == 1: # random table
        h0 = rng.uniform(0, 1, 2**d); h1 = (1 - h0)*rng.uniform(0, 1, 2**d)
    elif kind == 2: # deterministic table agreeing with many parities on structured set
        lab = rng.integers(0, 2, 2**d); h0 = (lab == 0).astype(float); h1 = 1 - h0
    else:           # majority of 3 parities, hedged
        idx = rng.choice(2**d, 3, replace=False); maj = (PAR[:, idx].sum(1) >= 2).astype(int)
        eps = rng.uniform(0, 0.3); h1 = np.where(maj == 1, 1 - eps, eps); h0 = 1 - h1
    s = list_sizes(h0, h1)
    for t in s:
        worst[t] = max(worst[t], s[t])
        if s[t] >= 2**(2*t): viol += 1
P(f"  d={d}, 400 hypotheses: violations of |A_t| < 4^t: {viol}; worst list sizes by t: {worst}")

# ---------------------------------------------------------------- (c)
P("=" * 78)
P("(c) Lemma 2.3 semimeasure Q on subsets of {0,1}^m (exhaustive over all 2^(2^m) subsets)")
m, dd = 3, 5
Xs = np.array([[(x >> i) & 1 for i in range(dd)] for x in range(2**dd)])
for trial in range(6):
    a = rng.integers(0, 2, dd); fa = (Xs @ a) % 2
    B = [inf, 4.0, 6.0][trial % 3]
    tau = 0.0 if B == inf else 2.0**(1-B)
    nu1 = rng.uniform(0, 1, 2**dd)*rng.uniform(0.6, 1.0)          # nu(1|x)
    nu0 = (1 - nu1)*rng.uniform(0.6, 1.0, 2**dd)                   # nu(0|x), sub-probability
    def nu(y, xi): return nu1[xi] if y == 1 else nu0[xi]
    z_of = lambda xi: xi & (2**m - 1)                              # first m bits = low m bits here
    q = np.zeros((2**m, 2))
    for z in range(2**m):
        xs = [xi for xi in range(2**dd) if z_of(xi) == z]
        for b in (0, 1):
            vals = [min(B, -log2(max(nu(fa[xi] ^ b, xi), 1e-300))) for xi in xs]
            q[z, b] = 2.0**(-np.mean(vals))
    tot_perfactor = 0.0; tot_literal = 0.0
    for bits in range(2**(2**m)):
        ind = [(bits >> z) & 1 for z in range(2**m)]
        prod = np.prod([q[z, ind[z]] for z in range(2**m)])
        tot_perfactor += prod/(1 + tau)**(2**m)
        tot_literal += prod/(1 + tau)
    S = rng.choice(2**m, 2, replace=False); ind = [1 if z in S else 0 for z in range(2**m)]
    ystar = np.array([fa[xi] ^ ind[z_of(xi)] for xi in range(2**dd)])
    RB = np.mean([min(B, -log2(max(nu(ystar[xi], xi), 1e-300))) for xi in range(2**dd)])
    beta = (2**m)*log2(1 + tau)
    lhs = -log2(np.prod([q[z, ind[z]] for z in range(2**m)])/(1 + tau)**(2**m))
    P(f"  B={B}: sum Q (per-factor normalisation) = {tot_perfactor:.6f}; sum (product/(1+tau) once) = "
      f"{tot_literal:.6f}; -log Q(S) - (2^m R_B + beta_B) = {lhs - (2**m*RB + beta):.2e}")

# deterministic hypothesis, smallest allowed truncation B = log2(1/p) = 2 (p = 1/4, m = 3): literal formula
a = rng.integers(0, 2, dd); fa = (Xs @ a) % 2; B = 2.0; tau = 2.0**(1-B)
lab = rng.integers(0, 2, 2**dd)                       # an arbitrary deterministic labelling
q = np.zeros((2**m, 2))
for z in range(2**m):
    xs = [xi for xi in range(2**dd) if (xi & (2**m - 1)) == z]
    for b in (0, 1):
        q[z, b] = 2.0**(-np.mean([min(B, 0.0 if lab[xi] == (fa[xi] ^ b) else inf) for xi in xs]))
prods = [np.prod([q[z, (bits >> z) & 1] for z in range(2**m)]) for bits in range(2**(2**m))]
P(f"  deterministic hypothesis, B=2: sum Q per-factor = {sum(prods)/(1+tau)**(2**m):.4f}; "
  f"sum with a single 1/(1+tau) = {sum(prods)/(1+tau):.4f}  (>1 means the literal formula is not a semimeasure)")

# ---------------------------------------------------------------- (d)
P("=" * 78)
P("(d) Thm 2(ii)(e) counting: |{S': avg_S' v >= vbar + gamma}| <= C(n,s0) exp(-2 s0 gamma^2), exhaustive")
viol = 0; ratios = []
for trial in range(120):
    n = int(rng.choice([12, 16, 20])); s0 = int(rng.integers(2, 6))
    kind = trial % 3
    if kind == 0: v = rng.uniform(0, 1, n)
    elif kind == 1: v = (rng.uniform(0, 1, n) < 0.2).astype(float)
    else: v = rng.beta(0.3, 0.3, n)
    vbar = v.mean()
    sums = np.array([v[list(c)].sum() for c in itertools.combinations(range(n), s0)])/s0
    for gam in [0.1, 0.2, 0.3, 0.5]:
        cnt = int((sums >= vbar + gam - 1e-12).sum())
        bound = comb(n, s0)*exp(-2*s0*gam*gam)
        if cnt > bound + 1e-9: viol += 1
        if cnt > 0: ratios.append(cnt/bound)
P(f"  120 populations x 4 gammas: violations = {viol}; max count/bound = {max(ratios):.3f}")

open(__file__.replace(".py", ".out"), "w").write("\n".join(out) + "\n")
print("\n".join(out))
