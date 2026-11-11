"""Concentration constants of C.md Section C.7 and the corollaries: symbolic re-derivation + Monte Carlo.

A. SymPy: Hoeffding/Chernoff constants, the choice of u, every sample-size threshold, Theorem C.7 (i)/(ii).
B. Monte Carlo on a finite dictionary (exact population losses):
   - empirical tail of the martingale sum  sum_t Delta_t  versus  exp(-u^2/(8n));
   - failure frequencies of (C.7.1) and (C.7.2) at delta = 0.01 (allowed 2 delta), including eta = 1, 4 for (C.7.2);
   - the in-expectation bound (C.2.5) for pure-noise labels (y = +-1 independent of x).
"""
import numpy as np, sympy as sp

print("A. symbolic checks")
s, u, n, R, lam, dl, eps, A, Ng, eta, rho = sp.symbols('s u n R lambda delta epsilon A N_g eta rho', positive=True)
# Hoeffding's lemma exponent s^2 R^2/8 with range R = 4
print("  Hoeffding exponent, range 4:", sp.simplify(s**2 * 4**2 / 8))
# Chernoff: minimise 2 n s^2 - s u over s
expo = 2 * n * s**2 - s * u; s_opt = sp.solve(sp.diff(expo, s), s)[0]
print("  argmin s =", s_opt, "; min exponent =", sp.simplify(expo.subs(s, s_opt)))
uu = sp.sqrt(8 * n * sp.log(1 / dl))
print("  exp(-u^2/(8n)) at u=sqrt(8 n log(1/delta)):", sp.simplify(sp.exp(-uu**2 / (8 * n))))
print("  2u/n - 4 sqrt(2 log(1/delta)/n) =", sp.simplify(2 * uu / n - 4 * sp.sqrt(2 * sp.log(1 / dl) / n)))
# Theorem C.6 sample sizes: 4 sqrt(2 log(1/delta)/n) <= eps/4  <=> n >= 512 log(1/delta)/eps^2
nthr = sp.solve(sp.Eq(4 * sp.sqrt(2 * sp.log(1 / dl) / n), eps / 4), n)
print("  Thm C.6: 4 sqrt(2 log(1/d)/n) = eps/4  at n =", nthr)
print("  Thm C.6: A N^g/(eta n) = eps/4 at n =", sp.solve(sp.Eq(A * Ng / (eta * n), eps / 4), n), "; 4 rho = eps/2 at rho =", sp.solve(sp.Eq(4 * rho, eps / 2), rho))
print("  Cor C.2.1: rho = eps/8, A N^g/(eta(n+1)) = eps/2 at n+1 =", sp.solve(sp.Eq(A * Ng / (eta * n), eps / 2), n))
# Theorem C.7: per-sample factor (lambda/n)^2 * 16/8, n samples
print("  Thm C.7: n * (lambda/n)^2 * 16/8 =", sp.simplify(n * (lam / n)**2 * 16 / 8))
print("  Thm C.7 chain: 2 lambda/n + 2 lambda/n with lambda = eta n:", sp.simplify((4 * lam / n).subs(lam, eta * n)))
# (i): eta = rho = eps/16: 4 rho + 4 eta = eps/2; (A N^g + 2 log(1/d))/(eta n) <= eps/2 <=> n >= 32 (...)/eps^2
K = sp.Symbol('K', positive=True)
print("  Thm C.7(i): 4rho+4eta at eps/16 =", sp.simplify(4 * eps / 16 + 4 * eps / 16), "; threshold n =", sp.solve(sp.Eq(K / ((eps / 16) * n), eps / 2), n), "(K = A N^g + 2 log(1/delta))")
# (ii): eta = sqrt(N^g/n)
e2 = sp.sqrt(Ng / n); L_ = sp.Symbol('l', positive=True)  # l = log(1/delta)
expr = 4 * e2 + (A * Ng + 2 * L_) / (e2 * n)
claim = (4 + A + 2 * L_) * sp.sqrt(Ng / n)
print("  Thm C.7(ii): claim - actual =", sp.simplify(claim - expr), " (>= 0 iff N^g >= 1)")
print("  Thm C.5(c): 4(4+sqrt 2) =", float(4 * (4 + sp.sqrt(2))), "< 22")
print("  Remark C.7.1: off-event contribution 4 * 2/n =", 8, "/ n")

print("\nB. Monte Carlo")
rng = np.random.default_rng(12)
M = 30; xs = np.linspace(-1, 1, M)
K_ = 200
H = np.clip(rng.uniform(-1.5, 1.5, K_)[:, None] * np.tanh(rng.uniform(-5, 5, K_)[:, None] * xs[None, :] + rng.uniform(-2, 2, K_)[:, None]), -1, 1)
H[0] = 0.0                                          # the zero function is in the dictionary
mu = rng.dirichlet(np.ones(K_) * 0.3); mu[0] = 1e-6; mu /= mu.sum()   # ...with tiny prior mass
# D1: y = sign(sin 4x) with prob 0.7 else flipped (agnostic, labels +-1)
f0 = np.sign(np.sin(4 * xs) + 1e-12)
def D1(nn):
    idx = rng.integers(0, M, nn); y = f0[idx] * np.where(rng.uniform(size=nn) < 0.7, 1, -1); return idx, y
Ey1 = 0.4 * f0; Ey21 = np.ones(M)
# D2: pure noise y = +-1 independent of x
def D2(nn):
    return rng.integers(0, M, nn), rng.choice([-1.0, 1.0], nn)
Ey2 = np.zeros(M); Ey22 = np.ones(M)
def LD(f, Ey, Ey2_):
    return np.mean(f ** 2 - 2 * f * Ey + Ey2_, axis=-1)

def run(D, Ey, Ey2_, n, R, eta, delta):
    Lj = LD(H, Ey, Ey2_); jb = np.argmin(Lj + np.log(1 / mu) / (eta * n))
    Ssum = []; v_hp = 0; v_g = 0; risks = []
    for _ in range(R):
        idx, y = D(n)
        logw = np.log(mu).copy(); fh = []
        for t in range(n):
            w = np.exp(logw - logw.max()); w /= w.sum(); fh.append(w @ H)
            logw -= eta * (H[:, idx[t]] - y[t]) ** 2
        w = np.exp(logw - logw.max()); w /= w.sum(); fh.append(w @ H)
        fh = np.array(fh)
        Lt = LD(fh[:n], Ey, Ey2_)
        Ssum.append(np.sum(Lt - (fh[np.arange(n), idx] - y) ** 2))
        risks.append(LD(fh.mean(0), Ey, Ey2_))
        if LD(fh[:n].mean(0), Ey, Ey2_) > Lj[jb] + np.log(1 / mu[jb]) / (eta * n) + 4 * np.sqrt(2 * np.log(1 / delta) / n): v_hp += 1
        gibbs = w @ Lj
        if gibbs > Lj[jb] + 4 * eta + (np.log(1 / mu[jb]) + 2 * np.log(1 / delta)) / (eta * n): v_g += 1
    lse = -np.log(np.sum(mu * np.exp(-eta * (n + 1) * (Lj - Lj.min())))) / (eta * (n + 1)) + Lj.min()
    return np.array(Ssum), v_hp / R, v_g / R, np.mean(risks), lse, Lj.min()

for (name, D, Ey, Ey2_) in [("D1 agnostic +-1 labels", D1, Ey1, Ey21), ("D2 pure noise", D2, Ey2, Ey22)]:
    for n in [10, 50, 200]:
        S, fhp, fg, Er, lse, Lmin = run(D, Ey, Ey2_, n, 2000, 0.125, 0.01)
        tails = "  ".join(f"P(S>={uu:.1f})={np.mean(S >= uu):.4f}<= {np.exp(-uu**2/(8*n)):.4f}" for uu in [np.sqrt(n), 2 * np.sqrt(n), 3 * np.sqrt(n)])
        print(f"  {name}, n={n}: E L(fbar)={Er:.4f} <= bound(C.2.5)={lse:.4f}: {Er <= lse};  fail(C.7.1)={fhp:.3f}  fail(C.7.2)={fg:.3f} (allowed 0.02)")
        print(f"      martingale tail: {tails}")
print("  (C.7.2) at eta outside the exp-concave range (no exp-concavity used):")
for eta in [1.0, 4.0]:
    for n in [20, 100]:
        _, _, fg, _, _, _ = run(D1, Ey1, Ey21, n, 1000, eta, 0.01)
        print(f"    eta={eta}, n={n}: fail(C.7.2)={fg:.3f} (allowed 0.02)")
