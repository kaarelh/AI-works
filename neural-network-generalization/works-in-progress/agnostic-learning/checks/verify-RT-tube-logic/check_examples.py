"""Exact examples for redteam.md Prop. 4.1 (TUBE with a sup-norm residual budget).

Family (A.md Prop. 6.3(b)): y = eta0 + b*eps, eps a fair sign independent of x,
eta0 + b < min(rho, 1).  Then max_i |y_i| < rho, the zero network is feasible, and the
strong-prior TUBE_rho Gibbs and posterior-mean risks tend to L_D(0) = b^2 + eta0^2
(A.md Lemma 6.2).  Competitor g = eta0 (width one, weights <= 2), rho0 = b, OPT = b^2.

Compare the actual limit risk with
  * Prop. 4.1's bound (tau + rho0)^2, best case tau -> rho + rho0 (ignoring the +4eps/3),
  * the sharpened bound rho^2 (+eps) proposed in the referee report.
"""
import numpy as np
from math import exp, factorial

print("rho0   rho    eta0      actual     OPT    sharpened rho^2   Prop4.1 inf_tau (rho+2rho0)^2")
for rho0 in [0.02, 0.05, 0.1]:
    for rho in [1.1 * rho0, 2 * rho0]:
        for frac in [0.0, 0.5, 0.999]:
            eta0 = frac * (rho - rho0)          # need eta0 + b < rho
            actual = rho0**2 + eta0**2
            opt = rho0**2
            sharp = rho**2
            p41 = (rho + 2 * rho0)**2
            assert actual <= sharp + 1e-15 <= p41
            print(f"{rho0:5.2f} {rho:6.3f} {eta0:8.4f}  {actual:9.5f} {opt:8.5f}  {sharp:12.5f}   {p41:12.5f}")

# sup over the family of the actual risk at fixed (rho, rho0): rho0^2 + (rho-rho0)^2 <= rho^2
for rho0, rho in [(0.1, 0.2), (0.1, 0.11), (0.0, 0.3)]:
    print(f"rho0={rho0}, rho={rho}: sup actual = {rho0**2 + (rho-rho0)**2:.5f}, rho^2 = {rho**2:.5f}")

# Prop 4.1 with the recommended rho = 2 rho0, tau = 4 rho0: 25 rho0^2 ; nonvacuous iff < 1 (= L_D(0) bound)
print("Prop 4.1 (rho=2rho0,tau=4rho0) beats the trivial bound 1 only if rho0 <", 0.2)

# Memorization excess of SP_1 in the cube example with labels +-rho0 (Theorem 2.2 scaled):
# beta(lambda) * rho0^2 with beta <= 0.517351, i.e. risk <= 1.52 rho0^2 < 25 rho0^2 = Prop 4.1's guarantee.
def beta(lam, kmax=80):
    from math import lgamma, log
    return sum(exp(-lam + k * log(lam) - lgamma(k + 1)) / k for k in range(1, kmax))
lams = np.linspace(0.05, 5, 2000)
bs = [beta(l) for l in lams]
i = int(np.argmax(bs))
print(f"max beta = {bs[i]:.6f} at lambda = {lams[i]:.4f};  beta(1) = {beta(1.0):.6f}")
print(f"SP_1 memorizing risk / rho0^2 <= 1 + {bs[i]:.4f};  sharpened TUBE bound beats it iff rho/rho0 < {np.sqrt(1+bs[i]):.4f}")

# Fair signs: every g has ess sup |y - g(x)| >= 1, so tau + rho0 > 3 and Prop 4.1 is vacuous (bound > 9 > 4).
gs = np.linspace(-3, 3, 100001)
print("min_g max(|1-g|,|-1-g|) =", np.min(np.maximum(np.abs(1 - gs), np.abs(-1 - gs))))
