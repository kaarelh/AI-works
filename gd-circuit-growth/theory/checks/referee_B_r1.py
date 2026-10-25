"""Referee round 1 checks for ../B-nn-time-bounds.md (independent code; runs in well under a minute).

  1. Lemma B1.4: is C_t monotone in t?  S_T values; how fast does the time-based Adam KL grow (B3.3(c))?
  2. Lemma B2.0: exact (all sign patterns) brute force with several convex increasing G and
     non-monotone 1-Lipschitz psi with psi(0)=0.
  3. Proposition B1.3: SGD on a smooth problem (logistic regression), Monte Carlo of E||theta_K-theta_0||^2
     against the stated bound.
  4. Theorem B1.1 / Corollary B1.2(b): small ReLU net, tiny-step GD, checks ||D||_{M^-1} <= sqrt(t (L0-Lt)/c)
     and the per-group inequality.
  5. Theorem B3.1: P^max by random search (as in sgd_short.PF_sup) vs constrained optimizer vs closed form.
  6. Proposition 6.1 prior: ln(1/pi) for k = 0..6.
  7. Recompute a few kl^{-1} chains of Table 5.2 / 5.3 from the stored JSON.
  8. Theorem B3.3 reading: max_g m_g / 2 sigma_g^2 and the "25 eps steps per 1000 samples".
  9. Proposition B3.4 slack, Section 3 thresholds, B3.1 explicit form constant.
"""
import itertools, json, math, os
import numpy as np
from scipy.optimize import minimize

HERE = os.path.dirname(os.path.abspath(__file__))
rng = np.random.default_rng(12345)

def kl(q, p):
    q = min(max(q, 1e-15), 1 - 1e-15); p = min(max(p, 1e-15), 1 - 1e-15)
    return q * math.log(q / p) + (1 - q) * math.log((1 - q) / (1 - p))

def klinv(q, c):
    lo, hi = q, 1.0
    for _ in range(200):
        mid = (lo + hi) / 2
        if kl(q, mid) > c: hi = mid
        else: lo = mid
    return hi

print("== 1. Lemma B1.4 ==")
b1, b2 = 0.9, 0.999; r = b1 ** 2 / b2
C = lambda t: (1 - b1) / (1 - b1 ** t) * math.sqrt((1 - b2 ** t) / (1 - b2)) * math.sqrt((1 - r ** t) / (1 - r))
Cs = np.array([C(t) for t in range(1, 20001)])
dec = np.where(np.diff(Cs) < 0)[0]
print("C_t monotone non-decreasing on 1..20000:", len(dec) == 0, " first decreases at t =", (dec[:5] + 1).tolist())
print("C_1..C_4 =", np.round(Cs[:4], 6).tolist(), " C_100 =", round(Cs[99], 4), " C_inf =", round((1 - b1) / math.sqrt((1 - b2) * (1 - r)), 4))
S = np.cumsum(Cs)
print("S_T for T=10,100,1000,20000:", [round(S[T - 1], 1) for T in (10, 100, 1000, 20000)])
# B3.3(c): KL = sum_g p_g (eta m_g S_K)^2 / (2 sigma_g^2) is quadratic in S_K, S_K ~ 7 K => KL ~ K^2
for K in (50, 100, 200, 300):
    print(f"   K={K}: S_K={S[K-1]:.1f}, (S_K/S_50)^2={(S[K-1]/S[49])**2:.1f}, K/50={K/50:.1f}")
# extremal sequence attains C_t (direct recursion, eps=0)
def ratio(g):
    m = v = 0.0
    for s, gs in enumerate(g):
        m = b1 * m + (1 - b1) * gs; v = b2 * v + (1 - b2) * gs ** 2
    t = len(g)
    return abs(m / (1 - b1 ** t)) / math.sqrt(v / (1 - b2 ** t))
print("extremal ratio t=300:", round(ratio((b2 / b1) ** np.arange(300)), 6), " C_300 =", round(C(300), 6))
g = np.concatenate([1e-3 * np.ones(200), 1e-3 * 1.05 ** np.arange(100)])
print("plateau + 5%/step growth ratio:", round(ratio(g), 3))

print("\n== 2. Lemma B2.0 (exact enumeration of signs) ==")
Gs = {"exp": lambda z: np.exp(z), "relu^2": lambda z: np.maximum(z, 0) ** 2, "softplus": lambda z: np.log1p(np.exp(z)),
      "relu": lambda z: np.maximum(z, 0)}
psis = {"relu": lambda u: np.maximum(u, 0), "abs": np.abs, "sin": np.sin, "bent": lambda u: np.clip(u, -1, 1) - 0.5 * np.clip(u - 1.5, 0, 1)}
worst = -np.inf
for trial in range(1500):
    n = rng.integers(1, 6); m = rng.integers(1, 7)
    T = rng.standard_normal((m, n)) * rng.uniform(0.2, 3)
    signs = np.array(list(itertools.product([-1, 1], repeat=n)))
    Gk = list(Gs)[trial % 4]; G = Gs[Gk]
    ps = [list(psis.values())[rng.integers(0, 4)] for _ in range(n)]
    PT = np.stack([ps[i](T[:, i]) for i in range(n)], 1)
    assert np.allclose([ps[i](np.zeros(1))[0] for i in range(n)], 0)
    lhs = np.mean([G(np.max(PT @ e)) for e in signs]); rhs = np.mean([G(np.max(T @ e)) for e in signs])
    worst = max(worst, (lhs - rhs) / max(1e-12, abs(rhs)))
print("max relative (LHS-RHS)/|RHS| over 1500 instances:", worst, "(<= 0 expected)")
# Lipschitz check of the psis
uu = np.linspace(-5, 5, 20001)
for k, f in psis.items():
    print(f"   psi={k}: Lipschitz const ~ {np.max(np.abs(np.diff(f(uu)) / np.diff(uu))):.3f}, psi(0) = {float(f(np.zeros(1))[0]):.1f}")

print("\n== 3. Proposition B1.3 on logistic regression (smooth, M = I) ==")
n_, d_ = 200, 10
X = rng.standard_normal((n_, d_)); wstar = rng.standard_normal(d_)
yb = (rng.uniform(size=n_) < 1 / (1 + np.exp(-X @ wstar))).astype(float)
beta = np.linalg.eigvalsh(X.T @ X / n_).max() / 4
sig2 = float((np.sum(X ** 2, 1)).mean())   # >= sup_w (1/n) sum ||grad_i - grad||^2 since |p - y| <= 1
def Ls(w): z = X @ w; return float(np.mean(np.logaddexp(0, z) - yb * z))
def grad_i(w, idx): p = 1 / (1 + np.exp(-X[idx] @ w)); return ((p - yb[idx])[:, None] * X[idx]).mean(0)
for eta, K, B in [(1 / beta, 200, 4), (0.5 / beta, 400, 1)]:
    runs = 400; sq = []; LK = []
    w0 = np.zeros(d_)
    for _ in range(runs):
        w = w0.copy()
        for k in range(K):
            w = w - eta * grad_i(w, rng.integers(0, n_, B))
        sq.append(np.sum((w - w0) ** 2)); LK.append(Ls(w))
    t = eta * K
    bound = 4 * t * (Ls(w0) - np.mean(LK)) + 2 * eta * t * sig2 * (1 + beta * t) / B
    print(f"   eta*beta={eta*beta:.2f} K={K} B={B}: E||D||^2 = {np.mean(sq):.2f}  bound = {bound:.2f}  ok={np.mean(sq) <= bound}")

print("\n== 4. Theorem B1.1 / B1.2(b), small ReLU net, tiny-step full-batch GD ==")
d4, N4, n4 = 6, 16, 64
X4 = rng.choice([-1.0, 1.0], size=(n4, d4)); y4 = np.sign(X4[:, 0] * X4[:, 1] + 0.5 * X4[:, 2])
P = dict(W1=rng.standard_normal((N4, d4)) / math.sqrt(d4), b1=np.zeros(N4), W2=rng.standard_normal((N4, N4)) / math.sqrt(N4),
         b2=np.zeros(N4), a=rng.standard_normal(N4) / N4)
mult = dict(W1=N4 / 8, b1=N4 / 8, W2=1.0, b2=1.0, a=8 / N4)
def fwd(P):
    z1 = X4 @ P["W1"].T + P["b1"]; h1 = np.maximum(z1, 0); z2 = h1 @ P["W2"].T + P["b2"]; h2 = np.maximum(z2, 0)
    return z1, h1, z2, h2, h2 @ P["a"]
def loss_grad(P):
    z1, h1, z2, h2, f = fwd(P); r_ = (f - y4) / n4
    g = {}; g["a"] = h2.T @ r_
    d2 = (r_[:, None] * P["a"][None, :]) * (z2 > 0); g["W2"] = d2.T @ h1; g["b2"] = d2.sum(0)
    d1 = (d2 @ P["W2"]) * (z1 > 0); g["W1"] = d1.T @ X4; g["b1"] = d1.sum(0)
    return 0.5 * np.mean((f - y4) ** 2), g
P0 = {k: v.copy() for k, v in P.items()}
eta4 = 2e-3; L0, _ = loss_grad(P); ratios = []; Eg = np.zeros(3)
grp = [("W1", "b1"), ("W2", "b2"), ("a",)]
for K in range(1, 6001):
    L, g = loss_grad(P)
    g2 = sum(mult[k] * np.sum(g[k] ** 2) for k in g)
    Eg += eta4 * np.array([sum(mult[k] * np.sum(g[k] ** 2) for k in gg) for gg in grp])
    P = {k: P[k] - eta4 * mult[k] * g[k] for k in P}
    Ln, _ = loss_grad(P); ratios.append((L - Ln) / (eta4 * g2))
c = min(ratios); t = eta4 * 6000
D2 = np.array([sum(np.sum((P[k] - P0[k]) ** 2) for k in gg) for gg in grp]); m_g = np.array([mult["W1"], mult["W2"], mult["a"]])
print(f"   c = {c:.4f}; ||D||_Minv = {math.sqrt((D2 / m_g).sum()):.3f} <= sqrt(t(L0-Lt)/c) = {math.sqrt(t * (L0 - Ln) / c):.3f}")
print(f"   per group ||D_g||^2 = {np.round(D2, 4)} <= m_g t E_g = {np.round(m_g * t * Eg, 4)}")

print("\n== 5. Theorem B3.1: P^max ==")
A1, A2, B2_, Aa = 11.3, 11.3, 0.0, 0.088
mm = np.array([2.0, 1.0, 1.0, 0.5])
def val(dl): return (Aa + dl[3]) * ((A1 + dl[0]) * (A2 + dl[1]) + B2_ + dl[2])
for rho in (1.4, 3.2, 7.1, 22.6):
    rs = np.random.default_rng(0); U = np.abs(rs.standard_normal((4000, 4))); U /= np.linalg.norm(U, axis=1, keepdims=True)
    rnd = max(val(np.sqrt(mm) * rho * u) for u in U)
    best = -np.inf
    for s in range(30):
        x0 = np.abs(rs.standard_normal(4)); x0 /= np.linalg.norm(x0)
        res = minimize(lambda u: -val(np.sqrt(mm) * rho * np.abs(u) / np.linalg.norm(u)), x0, method="Nelder-Mead", options=dict(xatol=1e-10, fatol=1e-10, maxiter=4000))
        best = max(best, -res.fun)
    closed = (Aa + math.sqrt(mm[3]) * rho) * ((A1 + math.sqrt(mm[0]) * rho) * (A2 + math.sqrt(mm[1]) * rho) + B2_ + math.sqrt(mm[2]) * rho)
    print(f"   rho={rho}: random-search (4000 pts, no refine) {rnd:.2f}  optimizer {best:.2f}  closed-form upper {closed:.2f}")

print("\n== 6. Proposition 6.1 prior ==")
for k in range(7):
    print(f"   k={k}: ln(1/pi) = {math.log(7) + math.log(math.comb(30, k)) + 2 ** k * math.log(2):.3f}")

print("\n== 7. kl^-1 chains ==")
G = 16 ** 3
rows = [json.loads(l) for l in open(os.path.join(HERE, "eval_saved.json"))]
for fn, n in [("dict", 16384), ("maj3", 16384), ("dict", 2048)]:
    for rw in rows:
        if rw["fn"] == fn and rw["n"] == n and rw["seed"] == 0 and rw.get("opt", "adam") == "adam":
            ge_up = klinv(rw["pb_gibbs"], math.log(100) / 400)
            RQ = klinv(ge_up, (rw["pb_KL"] + math.log(2 * math.sqrt(n) * G / 0.03)) / n)
            dis_up = klinv(rw["pb_dis"], math.log(100) / 400)
            print(f"   {fn} n={n}: KL={rw['pb_KL']:.0f} gibbs={rw['pb_gibbs']:.3f} -> R(Q)<={RQ:.3f} (json {rw['pb_RQ']:.3f}); det <= {min(1, RQ + dis_up):.3f} (json {rw['pb_det']:.3f})")
            break

print("\n== 8. B3.3 reading ==")
sg = np.array([0.14, 0.2, 0.025]); mg = np.array([2, 1, 0.5])
print("   m_g/(2 sig_g^2) =", np.round(mg / (2 * sg ** 2), 1), "; SGD steps per 1000 samples per unit eps (K <= eps n/(eta L0 max)):", 1000 / (0.2 * 0.5 * (mg / (2 * sg ** 2)).max()))

print("\n== 9. misc ==")
print("   B3.4 slack:", math.sqrt(math.log(20) / (2 * 1000 * 64)))
kp = math.sqrt(2 * math.log(248)); kf = math.sqrt(31) * (1 + math.sqrt(4 * math.log(2)))
print("   kappa_path", round(kp, 4), "kappa_F", round(kf, 4), "GRS", round(math.sqrt(31) * (1 + math.sqrt(6 * math.log(2))), 3))
print("   Section 3 thresholds:", round((2 * 1.1 * kp * 31.5) ** 2), round((2 * 1.1 * kf * 11.3) ** 2))
print("   B3.1 explicit constant at t=0, alpha=1: 2 q kappa_F sqrt(N) =", round(2 * 1.1 * kf * math.sqrt(128), 1))
print("   E path norm at init (2/pi)^1.5 sqrt(N d) =", round((2 / math.pi) ** 1.5 * math.sqrt(128 * 30), 2))
