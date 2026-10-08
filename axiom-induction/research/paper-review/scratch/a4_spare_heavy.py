"""a4 (review, math A): Prop ident:spare(c) (model Prop 5.5(c)) needs a finite-information hypothesis.

Case (c): inst(sigma) inside supp P*, Q_sigma not in the span of T*'s components.  Claimed: ln R_n = -(alpha/2) ln n + O_P(1).
Abstract instance: T* has one component with law P*(k) = k^-3/zeta(3) on k = 1, 2, ...; the spare sigma has law
Q_sigma(k) = k^-gamma/zeta(gamma) on the same set (so inst(sigma) = supp P*, and Q_sigma is not a multiple of P*).
T* u {sigma} has weights (1-u, u) ~ Dir(alpha_1, alpha_sigma), i.e. u ~ Beta(alpha_sigma, alpha_1); T* alone has none.
  R_n = E_u prod_i (1 - u + u Y_i),  Y_i = Q_sigma(X_i)/P*(X_i),  E Y = 1.
gamma = 2.6: E Y^2 = sum Q_sigma^2/P* < inf (finite chi^2).   Expected slope -alpha/2 = -0.25.
gamma = 1.5: E Y^2 = inf; P*(Y > y) ~ y^(-4/3).  Heuristic slope -alpha/beta = -0.375 with beta = 4/3.
Exact quadrature in u (logit grid), data binned by value.  Seeded; writes a4_spare_heavy.out."""
import math
import numpy as np
from scipy.special import zeta, betaln

out = []
def p(s):
    print(s); out.append(s)

rng = np.random.default_rng(55)
a_sig, a_1 = 0.5, 0.5
z = np.linspace(-45, 12, 1500)
u = 1 / (1 + np.exp(-z))
# integrand in z: Beta density * du/dz = u^a_sig (1-u)^a_1 / B
logw = a_sig * np.log(u) + a_1 * np.log1p(-u) - betaln(a_sig, a_1) + np.log(z[1] - z[0])
checkpoints = [10**2, 10**3, 10**4, 10**5, 10**6]
for gam in (2.6, 1.5):
    cY = zeta(3.0) / zeta(gam)
    res = {n: [] for n in checkpoints}
    for run in range(60):
        x = rng.zipf(3.0, size=checkpoints[-1])          # P*(k) = k^-3 / zeta(3)
        for n in checkpoints:
            vals, cnt = np.unique(x[:n], return_counts=True)
            Y = cY * vals.astype(float) ** (3.0 - gam)
            S = (cnt[None, :] * np.log1p(u[:, None] * (Y[None, :] - 1))).sum(axis=1)
            res[n].append(float(np.logaddexp.reduce(logw + S)))
    means = [np.mean(res[n]) for n in checkpoints]
    ses = [np.std(res[n]) / math.sqrt(len(res[n])) for n in checkpoints]
    slope = np.polyfit(np.log(checkpoints), means, 1)[0]
    slope_hi = np.polyfit(np.log(checkpoints[2:]), means[2:], 1)[0]
    p(f"gamma={gam}: mean ln R_n at n={checkpoints}: " + ", ".join(f"{m:.3f}±{s:.3f}" for m, s in zip(means, ses)))
    p(f"gamma={gam}: slope vs ln n (1e2..1e6) = {slope:.3f}; (1e4..1e6) = {slope_hi:.3f};  claimed -alpha/2 = {-a_sig/2}")

open(__file__.replace('.py', '.out'), 'w').write("\n".join(out) + "\n")
