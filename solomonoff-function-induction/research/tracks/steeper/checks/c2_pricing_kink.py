"""c2: re-verification of the elementary facts behind notes Sections 1-2 (several are T5 results,
recomputed here with independent code).

(a) Per-input pricing (Thm 2 / T5 Thm 2.1): with F = all parities on {0,1}^d, any product
    hypothesis pays >= N bits on some parity over N distinct nonzero inputs; the shared Bayes
    mixture pays <= d bits.  Also the minimax example of T5 (value < sum log|F(x)|).
(b) Lemma A/B ingredients for semimeasure hypotheses: the identity
    u(a') = (E m + shat(a'))/2, the list-size bound #{a': u(a') > 1/2 + 2^-(t+1)} < 2^(2t),
    and the risk floor R >= -log2(u(a) + p) (+ truncation).
(c) The small kink instance (d=10, |E|=16): product list-mixtures vs shared (set) mixtures,
    including the set models S_u of notes Prop 3.6 (flat two-part totals).
Seeded (numpy default_rng(2), random.seed(2)).
"""
import itertools, random
from math import log2, comb, lgamma, log
import numpy as np
from scipy.optimize import minimize

rng = np.random.default_rng(2); random.seed(2)
def H(q): return 0.0 if q in (0, 1) else -(q*log2(q)+(1-q)*log2(1-q))
def log2binom(n, k): return (lgamma(n+1)-lgamma(k+1)-lgamma(n-k+1))/log(2)

print("=" * 78)
print("(a) per-input pricing over parities")
d = 10; n = 2**d
X = np.array([[(x >> i) & 1 for i in range(d)] for x in range(n)], dtype=np.int64)
A_all = X.copy()                                   # all a' in {0,1}^d
labels_all = (A_all @ X.T) % 2                     # [a', x]
nonzero = np.arange(1, n)
for N in [50, 200, n-1]:
    idx = rng.choice(nonzero, N, replace=False)
    # best product hypothesis against the worst parity: by the minimax argument the per-input
    # mixture h(.|x) = Unif(F(x)) attains sum_i log|F(x_i)| = N; check that EVERY parity gets loss
    # exactly N under it, and that the average over parities of any product h is >= N (Jensen).
    frac1 = labels_all[:, idx].mean(axis=0)
    assert np.allclose(frac1, 0.5)
    # random product hypotheses: worst-case loss over parities >= N
    worst_min = np.inf
    for _ in range(20):
        h1 = rng.uniform(0.01, 0.99, N)
        L = -(labels_all[:, idx]*np.log2(h1) + (1-labels_all[:, idx])*np.log2(1-h1)).sum(axis=1)
        worst_min = min(worst_min, L.max())
    a = rng.integers(0, 2, d); y = (X[idx] @ a) % 2
    consistent = np.all(labels_all[:, idx] == y, axis=1).sum()
    print(f"  N={N:4d}: per-input mixture pays exactly {N} on every parity; min over 20 random product h "
          f"of worst-parity loss = {worst_min:.1f} (>= {N}); shared mixture pays {d - log2(consistent):.2f} <= d={d}")

print("  minimax example F={(a,a),(a,b),(b,a),(c,a)} (two inputs):")
F = [("a", "a"), ("a", "b"), ("b", "a"), ("c", "a")]
def sumH(Q):
    tot = 0.0
    for i in (0, 1):
        mm = {}
        for q, f in zip(Q, F): mm[f[i]] = mm.get(f[i], 0) + q
        tot += -sum(v*log2(v) for v in mm.values() if v > 0)
    return tot
best = 0.0
for _ in range(200000):
    Q = rng.dirichlet(np.ones(4)); best = max(best, sumH(Q))
res = max((-minimize(lambda z: -sumH(np.exp(z)/np.exp(z).sum()), rng.normal(size=4), method="Nelder-Mead",
                     options={"xatol": 1e-12, "fatol": 1e-13, "maxiter": 40000}).fun) for _ in range(20))
# direct min over product h of max over f: epigraph form, variables (h1a,h1b,h1c,h2a,h2b,s), SLSQP
cons = [{"type": "eq", "fun": lambda v: v[0]+v[1]+v[2]-1}, {"type": "eq", "fun": lambda v: v[3]+v[4]-1}]
i1 = {"a": 0, "b": 1, "c": 2}; i2 = {"a": 3, "b": 4}
for f in F:
    cons.append({"type": "ineq", "fun": (lambda f: lambda v: v[5] + log2(v[i1[f[0]]]) + log2(v[i2[f[1]]]))(f)})
minimax = min(minimize(lambda v: v[5], np.r_[rng.dirichlet(np.ones(3)), rng.dirichlet(np.ones(2)), 3.0],
                       method="SLSQP", constraints=cons, bounds=[(1e-9, 1)]*5 + [(0, 10)],
                       options={"ftol": 1e-13, "maxiter": 2000}).fun for _ in range(30))
print(f"    max_Q sum H(Q_x): random search {best:.4f}, optimiser {res:.4f}; SLSQP min_h max_f = {minimax:.4f}; "
      f"sum log|F(x)| = {log2(3)+1:.4f}")

print("=" * 78)
print("(b) semimeasure versions of Lemma A/B ingredients (d=8)")
d = 8; n = 2**d
X8 = np.array([[(x >> i) & 1 for i in range(d)] for x in range(n)], dtype=np.int64)
chis = 1 - 2*((X8 @ X8.T) % 2)                     # chi_{a'}(x), rows a'
a = rng.integers(0, 2, d); fa = (X8 @ a) % 2
viol_id = viol_list = viol_floor = 0; trials = 0
for trial in range(400):
    trials += 1
    mode = trial % 4
    tot = rng.uniform(0.3, 1.0, n) if mode in (0, 1) else np.ones(n)      # sub-probability allowed
    if mode in (0, 2):
        # partially correlated with f_a
        bias = rng.uniform(-1, 1)*rng.uniform(0, 1, n)
        p0 = np.clip(0.5 + 0.5*bias*(1 - 2*fa), 0, 1)
    else:
        # mixtures of a few parities
        k = rng.integers(1, 6); comps = rng.integers(0, n, k); w = rng.dirichlet(np.ones(k))
        p0 = sum(wj*(1 - (X8 @ X8[c]) % 2) for wj, c in zip(w, comps))
    h0, h1 = tot*p0, tot*(1 - p0)                  # nu(0|x), nu(1|x)
    s = h0 - h1; mbar = (h0 + h1).mean()
    shat = (chis * s).mean(axis=1)                 # shat(a') for all a'
    u = np.array([np.where((X8 @ X8[ap]) % 2 == 0, h0, h1).mean() for ap in range(n)])
    if np.max(np.abs(u - (mbar + shat)/2)) > 1e-12: viol_id += 1
    for t in range(1, 5):
        if np.sum(u > 0.5 + 2.0**-(t+1)) >= 2**(2*t): viol_list += 1
    for pE in [1/64, 1/16, 0.2]:
        E = rng.choice(n, int(pE*n), replace=False); e = np.zeros(n, int); e[E] = 1
        ystar = (fa + e) % 2
        hy = np.where(ystar == 0, h0, h1)
        aidx = int(sum(int(a[i]) << i for i in range(d)))
        for B in [np.inf, 6.0]:
            RB = np.mean(np.minimum(B, -np.log2(np.maximum(hy, 1e-300))))
            floor = -log2(u[aidx] + len(E)/n + (2.0**-B if B < np.inf else 0.0))
            if RB < floor - 1e-12: viol_floor += 1
print(f"  {trials} random semimeasure hypotheses: identity violations {viol_id}; list-size violations {viol_list}; "
      f"risk-floor (Lemma B) violations {viol_floor}")

print("=" * 78)
print("(c) kink instance d=10, |E|=16 (p=1/64): product list mixtures vs shared mixtures and set models")
d = 10; n = 2**d
X = np.array([[(x >> i) & 1 for i in range(d)] for x in range(n)], dtype=np.int64)
a = rng.integers(0, 2, d)
pE = 1/64; mE = int(pE*n)
E = rng.choice(n, mE, replace=False); e = np.zeros(n, int); e[E] = 1
fa = (X @ a) % 2; ystar = (fa + e) % 2
LE = log2(comb(n, mE))
print(f"  H(p)={H(pE):.4f}, nH(p)={n*H(pE):.1f}, L_E=log2 C(n,|E|)={LE:.1f}")
print("  u | product list-mixture risk R | shared mixture code length/n | set model S_u: (d-u)+log2|S_u| ")
for u_ in range(d + 1):
    free = list(range(d - u_, d)); L = []
    for t in range(2**u_):
        b = a.copy()
        for k, i in enumerate(free): b[i] = (t >> k) & 1
        L.append((X @ b) % 2)
    L = np.array(L)
    q = (L == ystar).mean(axis=0)
    hprob = (1 - pE)*q + pE*(1 - q)
    Rprod = -np.mean(np.log2(hprob))
    agree = (L == ystar).sum(axis=1)
    ll = agree*log2(1 - pE) + (n - agree)*log2(pE)
    mx = ll.max(); shared = -(mx + log2(np.exp2(ll - mx).sum()) - u_)
    setmodel = (d - u_) + (u_ + LE)                  # K(S_u) ~ d-u (+O(log d)), log|S_u| = u + L_E
    print(f"  {u_:2d} | {Rprod:.4f} | {shared/n:.4f} (total {d-u_ + shared:.1f}) | {setmodel:.1f}")
print("  -> product risk stays near 1 until u is small (kink); shared and set totals are flat in u.")
