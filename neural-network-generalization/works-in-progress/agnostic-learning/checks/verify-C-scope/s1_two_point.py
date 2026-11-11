"""Scope check of C-fixed-temperature-bayes.md, Remark 3 after Theorem C.1 (two-point prior).

Theta = {w1, w2}, mu uniform, z_{w1} = M, z_{w2} = -1, y = -1 (deterministic), eta = 1/8, Q = delta_{w2}.
FIX_eta uses the clipped likelihood, so l(w1) = (clip M + 1)^2 = 4, l(w2) = 0, and the posterior weight of w1
after t samples is p_t = e^{-4 eta t} / (1 + e^{-4 eta t}).

Prints:
 (a) the bound log2/(eta(n+1)) of (C.2.5) with Q = delta_{w2};
 (b) the test losses of: the clipped progressive mixture fbar_n (covered by Thm C.1), the progressive mixture of
     the unclipped posterior means zbar_t, its clip, and the average over t of the losses of zbar_t and of clip zbar_t
     (the left side of (C.2.4) with these replacements);
 (c) the first inequality of (C.2.3) at T = 1 and the full chain (C.2.3) at T = 1, 2 for clip zbar_t;
 (d) the unclipped Gibbs risk of the final posterior, int L_D(z_w) dPi_n, against the bound of Thm C.7
     (any eta; right side with Q = delta_{w2}): shows that Thm C.7 also fails for the unclipped Gibbs risk
     for this prior when M is large (not claimed in the note; it says only that C.7 concerns clipped outputs).
"""
import numpy as np

eta = 0.125
def p(t):
    return np.exp(-4 * eta * t) / (1 + np.exp(-4 * eta * t))

def zbar(t, M):
    pt = p(t)
    return pt * M + (1 - pt) * (-1.0)

def fhat(t, M):  # clipped outputs: clip M = 1
    pt = p(t)
    return pt * 1.0 + (1 - pt) * (-1.0)

print("(a)/(b) losses vs the bound log2/(eta(n+1)) of (C.2.5)")
for M in [10.0, 1e3, 1e6]:
    for n in [10, 100, 1000]:
        ts = np.arange(n + 1)
        bound = np.log(2) / (eta * (n + 1))
        fbar = np.mean([fhat(t, M) for t in ts])
        pm_unclipped = np.mean([zbar(t, M) for t in ts])
        loss_fbar = (fbar + 1) ** 2
        loss_pm = (pm_unclipped + 1) ** 2
        loss_clip_pm = (np.clip(pm_unclipped, -1, 1) + 1) ** 2
        avg_loss_zbar = np.mean([(zbar(t, M) + 1) ** 2 for t in ts])
        avg_loss_clipzbar = np.mean([(np.clip(zbar(t, M), -1, 1) + 1) ** 2 for t in ts])
        print(f"  M={M:8.0e} n={n:5d}: bound={bound:.4g} | clipped fbar: {loss_fbar:.3g} (ok={loss_fbar<=bound+1e-15}) |"
              f" PM of zbar: {loss_pm:.4g} | clip(PM of zbar): {loss_clip_pm:.3g} |"
              f" avg_t L(zbar_t): {avg_loss_zbar:.4g} | avg_t L(clip zbar_t): {avg_loss_clipzbar:.3g}")

print("\n(c) chain (C.2.3) for clip zbar_t, M=10: LHS_T = sum_{t<T}(clip zbar_t - y)^2, mid = -(1/eta) log Z_T,"
      " RHS = sum_i int l_i dQ + KL(Q||mu)/eta = 0 + log2/eta")
M = 10.0
for T in [1, 2, 3, 5]:
    lhs = sum((np.clip(zbar(t, M), -1, 1) + 1) ** 2 for t in range(T))
    ZT = 0.5 * np.exp(-4 * eta * T) + 0.5
    mid = -np.log(ZT) / eta
    rhs = np.log(2) / eta
    print(f"  T={T}: LHS={lhs:.4f}  mid={mid:.4f}  RHS={rhs:.4f}  first ineq holds={lhs<=mid}  full chain LHS<=RHS: {lhs<=rhs}")
print(f"  zbar_0 at M=10: {zbar(0,10.0)}; (zbar_0+1)^2={(zbar(0,10.0)+1)**2}; -(1/eta)log(Z1/Z0)={-np.log(0.5*np.exp(-0.5)+0.5)/eta:.4f}")

print("\n(d) unclipped Gibbs risk of the final posterior vs Theorem C.7's right side (delta=0.1, Q=delta_{w2}, KL=log2)")
delta = 0.1
for n in [10, 100, 1000]:
    for M in [1e2, 1e6, np.exp(4 * eta * n / 2) * 10]:
        gibbs_unclipped = p(n) * (M + 1) ** 2   # w2 has zero loss
        rhs = 0 + 4 * eta + (np.log(2) + 2 * np.log(1 / delta)) / (eta * n)
        gibbs_clipped = p(n) * 4.0
        print(f"  n={n:5d} M={M:9.3e}: clipped Gibbs risk={gibbs_clipped:.3e} (<= {rhs:.3f}: {gibbs_clipped<=rhs}),"
              f" unclipped Gibbs risk={gibbs_unclipped:.3e} (<= {rhs:.3f}: {gibbs_unclipped<=rhs})")
