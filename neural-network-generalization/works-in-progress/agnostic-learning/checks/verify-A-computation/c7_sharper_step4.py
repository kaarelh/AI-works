"""Stress test of the sharper Step 4 proposed for Theorem 7.2:
   if |z_w(x_i) - zeta_{p_i}| <= 1/n, |z_0(x_i) - z_0(p_i)| <= 1/n, |z_0(p) - ybar_p| <= a at seen p, a <= 1,
   and sum_i (z_w(x_i)-y_i)^2 <= C + sum_i (z_0(x_i)-y_i)^2 with 0 <= C <= n, n >= 100,
   then Delta(zeta) := sum_p k_p (zeta_p - ybar_p)^2 <= C + n a^2 + 7.
Adversarial choices: u_i = -sign(v_i)/n (shrinks the near-minimizer's residual), u0_i = +sign(v0_i)/n (inflates
the comparator's residual); C is set to the smallest value for which the hypothesis holds."""
import numpy as np
rng = np.random.default_rng(3)
worst = -np.inf; tested = 0; worst_stated = -np.inf
for rep in range(20000):
    M = int(rng.choice([8, 32, 128])); n = int(rng.choice([100, 128, 512, 1000]))
    a = float(rng.choice([1.0, 0.3, 0.05, 1e-3]))
    p = rng.integers(0, M, n); y = rng.choice([-1.0, 1.0], n)
    k = np.bincount(p, minlength=M); S = np.bincount(p, weights=y, minlength=M)
    seen = k > 0; ybar = np.zeros(M); ybar[seen] = S[seen]/k[seen]
    W = float(np.sum((y - ybar[p])**2))
    # near-minimizer cluster values: memorizing, partly memorizing, or random
    mode = rep % 3
    if mode == 0: zeta = ybar + rng.normal(0, 0.05, M)
    elif mode == 1: zeta = rng.uniform(-1, 1, M)
    else: zeta = ybar*rng.uniform(0, 1, M)
    v = zeta[p] - y; u = -np.sign(v)/n
    z0p = np.clip(ybar + rng.uniform(-a, a, M), -3, 3); z0p[~seen] = 0
    v0 = z0p[p] - y; u0 = np.sign(v0)/n
    C = float(np.sum((u+v)**2) - np.sum((u0+v0)**2))
    if C < 0: C = 0.0
    if C > n: continue
    tested += 1
    Delta = float(np.sum(k*(zeta - ybar)**2))
    worst = max(worst, Delta - (C + n*a*a + 7))
    # the paper's own bound for comparison (E with c(K+t) replaced by C)
    E = np.sqrt(C) + (a + 2/n)*np.sqrt(n)
    worst_stated = max(worst_stated, Delta - (2*E*np.sqrt(W) + E*E))
line1 = f"tested {tested} admissible instances; max of Delta - (C + n a^2 + 7) = {worst:.4f} (<= 0 required)"
line2 = f"same instances, paper's bound: max of Delta - (2E sqrt(W) + E^2) = {worst_stated:.4f} (<= 0 required)"
print(line1); print(line2)
open(__file__.replace('.py', '.out'), 'w').write(line1 + "\n" + line2 + "\n")
