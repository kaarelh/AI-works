"""rb1 (referee B): Lemma 2.1 (Ville deficiency with side information) by EXACT enumeration of all sample
paths, and the two ways privacy can fail.  Deterministic (no randomness: every path is enumerated with its
exact probability).  Independent of the prover's r1 (different world, class and method).

World P (private coins).  Each step: x in {0,1} uniform; z in {0,1} uniform (environment, seen by predictors);
  y ~ Bern(theta_x), theta = (1/5, 2/3), independent of everything else given x.  We also enumerate z_{n+1}, so
  that a predictor may look one step into the FUTURE environment (A_i contains z_{i+1}; (Priv) still holds).
Class C (Kraft sum 0.84375; M_0 = 0.84375):
  human        q = nu_H(.|x_i)                                                   l = 2
  table1..3    product kernels on (x,z): q(1) = T[x_i, z_i]                      l = 4 each
  KT           history-aware Krichevsky-Trofimov estimate per (x,z) cell        l = 3
  peek         looks at the FUTURE environment: q(1) = 0.85 if z_{i+1} = 1 else 0.15        l = 4
  momentum     history: q(1) = 0.9 if y_{i-1} = 1 else 0.1 (0.5 at i = 1)        l = 4
  fill1        deterministic all-ones (a fill-in for one path)                  l = 5
  mixH         Bayes mixture over 'humans' theta in {1/5,1/3,1/2,2/3,4/5}^2, uniform weights (an in-context
               learner that contains the true human with weight 1/25)            l = 3
For every n <= N = 6 we compute exactly: E[M_n] (must be <= M_0) and P[max_{k<=n} M_k >= a] for a = 2^j (Ville:
must be <= M_0/a), with M_n = xi_n / nu_H(o_n) = sum_pi 2^-l(pi) prod_i q_{pi,i}(y_i)/nu_H(y_i|x_i).

World L (leak: (Priv) fails).  As P, but each step also reveals u_i with P(u_i = y_i) = 0.8 (a variable the
  predictor may see before y_i, correlated with the human's coin).  Predictor 'leak': q(1) = 0.8 if u_i = 1 else
  0.2, l = 4, added to C (Kraft 0.90625); n = 4.  Ville must FAIL for some n, a.

World L' (leak, simulated; seeded numpy default_rng(101)).  The class {human (l=2), leak (l=4)} on 2000 runs of
  n = 1000: the empirical tail of delta* against M_0 2^-j.

World X (XOR: marginal independence is not privacy).  x, z uniform bits, y = x XOR z.  The calibrated human
  says nu_H(1|x) = 1/2; z is independent of y and x is independent of y, but y is a function of (x,z).
  The product predictor q(y = x XOR z) = 0.99 on (x,z), l = 4, gains n log2(1.98) - 4 bits deterministically.
"""
import itertools
import numpy as np

N = 6
THETA = np.array([1 / 5, 2 / 3])
TABLES = [np.array([[0.05, 0.6], [0.9, 0.3]]), np.array([[0.5, 0.5], [0.1, 0.95]]),
          np.array([[0.3, 0.1], [0.7, 0.8]])]
GRID = np.array([1 / 5, 1 / 3, 1 / 2, 2 / 3, 4 / 5])


def enumerate_world(n, leak):
    """All paths of n steps (+ z_{n+1}); returns dict of int arrays and the path probabilities."""
    per = [(x, z, y) for x in (0, 1) for z in (0, 1) for y in (0, 1)]
    if leak:
        per = [(x, z, y, u) for (x, z, y) in per for u in (0, 1)]
    S = len(per)
    idx = np.array(list(itertools.product(range(S), repeat=n)), dtype=np.int32)   # (P, n)
    P = idx.shape[0]
    tab = np.array(per, dtype=np.int8)
    X, Z, Y = tab[idx, 0], tab[idx, 1], tab[idx, 2]
    U = tab[idx, 3] if leak else None
    # append z_{n+1}
    Z = np.concatenate([np.repeat(Z, 2, axis=0), np.tile(np.array([[0], [1]], np.int8), (P, 1))], axis=1)
    X, Y = np.repeat(X, 2, axis=0), np.repeat(Y, 2, axis=0)
    if leak:
        U = np.repeat(U, 2, axis=0)
    pr = np.full(X.shape[0], 0.5)                                     # z_{n+1}
    nuH = np.where(Y == 1, THETA[X], 1 - THETA[X])                  # nu_H(y_i | x_i), (P, n)
    pr = pr * np.prod(0.25 * nuH, axis=1)
    if leak:
        pr = pr * np.prod(np.where(U == Y, 0.8, 0.2), axis=1)
    return X, Z, Y, U, nuH, pr


def predictors(X, Z, Y, U, n, leak):
    """Per-step probabilities q_{pi,i}(y_i) for every predictor, (P, n) each, and lengths."""
    P = X.shape[0]
    out, lens, names = [], [], []

    def add(q1, l, nm):                                              # q1 = probability of label 1
        out.append(np.where(Y == 1, q1, 1 - q1)); lens.append(l); names.append(nm)

    add(THETA[X], 2, "human")
    for k, T in enumerate(TABLES):
        add(T[X, Z[:, :n]], 4, f"table{k+1}")
    # KT per (x,z) cell, sequential
    q = np.empty((P, n))
    c1 = np.zeros((P, 4)); c0 = np.zeros((P, 4))
    rows = np.arange(P)
    for i in range(n):
        cell = 2 * X[:, i] + Z[:, i]
        q[:, i] = (c1[rows, cell] + 0.5) / (c1[rows, cell] + c0[rows, cell] + 1.0)
        c1[rows, cell] += (Y[:, i] == 1); c0[rows, cell] += (Y[:, i] == 0)
    add(q, 3, "KT")
    add(np.where(Z[:, 1:n + 1] == 1, 0.85, 0.15), 4, "peek(z_{i+1})")
    mom = np.empty((P, n)); mom[:, 0] = 0.5
    mom[:, 1:] = np.where(Y[:, :-1] == 1, 0.9, 0.1)
    add(mom, 4, "momentum")
    add(np.ones((P, n)), 5, "fill1")
    # Bayes mixture over theta = (t0, t1) in GRID^2, sequential predictive
    th0, th1 = np.meshgrid(GRID, GRID, indexing="ij")
    th = np.stack([th0.ravel(), th1.ravel()], axis=1)               # (25, 2)
    logw = np.full((P, 25), -np.log(25.0))
    qm = np.empty((P, n))
    for i in range(n):
        tx = th[:, X[:, i]].T                                       # (P, 25): theta_{x_i}
        w = np.exp(logw - logw.max(axis=1, keepdims=True)); w /= w.sum(axis=1, keepdims=True)
        qm[:, i] = (w * tx).sum(axis=1)
        logw += np.log(np.where(Y[:, i:i + 1] == 1, tx, 1 - tx))
    add(qm, 3, "mixH")
    if leak:
        add(np.where(U == 1, 0.8, 0.2), 4, "leak(u_i)")
    return out, np.array(lens, float), names


def ville_table(leak, n):
    X, Z, Y, U, nuH, pr = enumerate_world(n, leak)
    qs, lens, names = predictors(X, Z, Y, U, n, leak)
    M0 = (2.0 ** -lens).sum()
    ratio = [np.cumprod(q / nuH, axis=1) for q in qs]                # (P, n) each
    M = sum(2.0 ** -l * r for l, r in zip(lens, ratio))              # (P, n): M_1..M_n
    EM = (pr[:, None] * M).sum(axis=0)
    runmax = np.maximum.accumulate(M, axis=1)
    return M0, EM, runmax, pr, names, lens, ratio, nuH, qs, Y


print(f"(P) private coins, exact over all {8**N * 2} paths of n = {N} steps (+ z_(n+1)); total probability checked")
M0, EM, runmax, pr, names, lens, ratio, nuH, qs, Yp = ville_table(False, N)
print(f"  predictors: {', '.join(f'{a}(l={int(b)})' for a, b in zip(names, lens))}")
print(f"  total path probability = {pr.sum():.15f};  M_0 = Kraft sum = {M0:.5f}")
print("  E[M_n] for n = 1..N (must be <= M_0): " + ", ".join(f"{v:.6f}" for v in EM))
assert np.all(EM <= M0 + 1e-12)
worst = -np.inf
for a in (1.0, 1.5, 2.0, 4.0, 8.0, 16.0, 32.0):
    p_emp = (pr * (runmax[:, -1] >= a)).sum()
    worst = max(worst, p_emp * a / M0)
    print(f"  P[max_(k<=n) M_k >= {a:5.1f}] = {p_emp:.6f}   Ville bound M_0/a = {M0 / a:.6f}")
print(f"  max over a of P[...] * a / M_0 = {worst:.4f} (must be <= 1)")
assert worst <= 1 + 1e-12
# per-program sup gain - length <= delta*: a pathwise identity, checked for completeness
dstar = np.log2(np.maximum(runmax[:, -1], 1e-300))
gainmax = np.stack([np.log2(np.maximum(np.max(r, axis=1), 1e-300)) - l for r, l in zip(ratio, lens)], axis=1)
print(f"  pathwise: max over paths of [sup_n (gain - length) - delta*] = {np.max(gainmax.max(axis=1) - dstar):.3e}"
      " (<= 0 by definition; an identity, not evidence)")
# fill-in and fixed-lambda length bound at lambda = 2, pathwise
lam = 2.0
L_nu = -np.log2(np.prod(nuH, axis=1))
fill_len = lens[names.index("fill1")]
is_fill = np.all(Yp == 1, axis=1)
print(f"  fill-in 'fill1' (l = {int(fill_len)}) is consistent on {is_fill.mean()*100:.2f}% of paths; on those,"
      f" min over paths of [l - (L_n(nu_H) - delta*)] = {np.min(fill_len - (L_nu[is_fill] - dstar[is_fill])):.3f} (>= 0)")

print(f"\n(L) leak: u_i = y_i with probability 0.8, seen by the predictor 'leak' -- (Priv) fails; n = 4 exact")
M0L, EML, runmaxL, prL, namesL, lensL, *_ = ville_table(True, 4)
print(f"  total path probability = {prL.sum():.15f};  M_0 = {M0L:.5f}")
print("  E[M_n], n = 1..4: " + ", ".join(f"{v:.4f}" for v in EML) + "   (grows: not a supermartingale)")
for a in (2.0, 4.0, 8.0, 16.0):
    p_emp = (prL * (runmaxL[:, -1] >= a)).sum()
    flag = "VIOLATES Ville" if p_emp > M0L / a else "ok"
    print(f"  P[max_k M_k >= {a:4.1f}] = {p_emp:.5f}   M_0/a = {M0L / a:.5f}   {flag}")

print("\n(L') leak, simulated: class {human, leak}, 2000 runs of n = 1000 (seed 101)")
rng = np.random.default_rng(101)
runs, n = 2000, 1000
M0s = 2.0 ** -2 + 2.0 ** -4
ds = np.empty(runs)
for r in range(runs):
    x = rng.integers(0, 2, n)
    y = (rng.random(n) < THETA[x]).astype(int)
    u = np.where(rng.random(n) < 0.8, y, 1 - y)
    nu = np.where(y == 1, THETA[x], 1 - THETA[x])
    ql = np.where(u == y, 0.8, 0.2)
    logM = np.logaddexp2(-2 + np.zeros(n), -4 + np.cumsum(np.log2(ql / nu)))
    ds[r] = max(0.0, logM.max())
for j in (1, 4, 16, 32, 64):
    print(f"  P_emp[delta* >= {j:2d}] = {np.mean(ds >= j):.4f}   M_0 2^-j = {M0s * 2.0**-j:.2e}")
print(f"  median delta* = {np.median(ds):.1f} bits (expected gain of 'leak' about n*0.098 - 4 = {n*0.0980-4:.0f})")

print("\n(X) XOR world: y = x XOR z, calibrated human nu_H(1|x) = 1/2; z independent of y, x independent of y")
for n in (10, 50, 100, 1000):
    gain = n * np.log2(2 * 0.99) - 4
    print(f"  n = {n:5d}: the (x,z)-product predictor's gain minus its length = {gain:8.2f} bits, deterministically;"
          f" P[delta* >= {int(gain)}] = 1 > 2^-{int(gain)}")
print("  so (Priv) must be conditional on the human's input (and on all side information), as Lemma 2.1 states;"
      " marginal independence of the coin from each variable is not enough.")
