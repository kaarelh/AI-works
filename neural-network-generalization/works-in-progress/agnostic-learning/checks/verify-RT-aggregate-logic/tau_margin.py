"""(a) If tau = L_D(g) exactly, the hypothesis Lhat(g) < tau of Remark 6.2 holds only with
probability about 1/2. With tau = L_D(g) + (U+1)^2 sqrt(ln(1/delta)/(2n)) it holds w.p. >= 1-delta.
(b) Caricature of the sample dependence of the scale threshold: P=1, kappa=w^2, prior N(0,sigma^2),
conditioning set O_r = (1-r,1+r) U (2,3): a thin low-energy part (clone, energy 1, margin r)
and a fat higher-energy part (energy 4..9, 'memorizers'). Posterior mass of {kappa > 1+zeta}."""
import numpy as np
from scipy.stats import norm
rng = np.random.default_rng(2)
# (a) competitor g(x)=0.5 tanh(2x) on x~U[-1,1], y = clip(sin(3x) + 0.4*noise)
def sample(n):
    x = rng.uniform(-1, 1, n); y = np.clip(np.sin(3 * x) + 0.4 * rng.standard_normal(n), -1, 1)
    return x, y
g = lambda x: 0.5 * np.tanh(2 * x)
xb, yb = sample(2_000_000); LD = np.mean((g(xb) - yb) ** 2)
U, delta = 0.5, 0.05
for n in [100, 1000, 10000]:
    reps = 4000
    Lh = np.array([np.mean((g(x) - y) ** 2) for x, y in (sample(n) for _ in range(reps))])
    slack = (U + 1) ** 2 * np.sqrt(np.log(1 / delta) / (2 * n))
    print(f"n={n:6d}: Pr[Lhat(g)<L_D(g)]={np.mean(Lh < LD):.3f};  "
          f"Pr[Lhat(g)<L_D(g)+slack]={np.mean(Lh < LD + slack):.4f} (slack={slack:.4f}, target>={1-delta})")
# (b)
def post_tail(r, sigma, zeta=1.0):
    thin = norm.cdf((1 + r) / sigma) - norm.cdf((1 - r) / sigma)
    fat = norm.cdf(3 / sigma) - norm.cdf(2 / sigma)
    # thin part has kappa <= (1+r)^2 <= 1+zeta for r small; fat part has kappa >= 4 > 1+zeta
    return fat / (thin + fat)
print("\nsigma   r=1e-1    r=1e-4    r=1e-8    r=1e-16")
for sigma in [0.5, 0.3, 0.2, 0.1]:
    print(f"{sigma:4.2f} " + " ".join(f"{post_tail(r, sigma):9.2e}" for r in [1e-1, 1e-4, 1e-8, 1e-16]))
