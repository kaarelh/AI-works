"""Theorem 5.1's near-minimizer bound R(z_w) <= (1-theta_c) G + E_0 in the regime c -> 0.

Corollary 5.2 says the depth-two bound does not refute the '+o(1)' formulation 'since eps_d ~ 1/log^2 n'.
That is only true for c bounded below. Here: explicit lower bounds on the excess at n = M = 2^d
(lambda = 1, high-probability values Q/M ~ beta, G/M ~ 1-e^-1, V/M ~ 1) for c = kappa/d and c = d^-p, via
  route (b): (theta G - E0)_+^2 / (4 M V)                 [Lemma 1.2(b), as in Theorem 5.1]
  route (a): (sqrt(Q/M) - sqrt(((1-theta) G + E0)/M))_+^2  [Lemma 1.2(a), as in Theorem 2.2]
"""
import math
beta = 0.4848291069956878; lam = 1.0
p1 = 1 - math.exp(-lam)
FD = lambda d: 1 + (d+1)*(d+2)**2
gam = p1**2/(4*lam)
print(f"gamma(1) = {gam:.4f}, beta(1) = {beta:.4f}")
print(" d   c          18dc     theta   route(b)   route(a)   max")
for d in [30, 40, 60, 100, 200]:
    M = 2.0**d; G = p1*M; V = lam*M; Q = beta*M
    for label, c in [("1", 1.0), ("1/d", 1/d), ("0.05/d", 0.05/d), ("1/d^2", 1/d**2), ("1/d^3", 1/d**3)]:
        th = 1/(18*d*c+1); E0 = c*(d*FD(d)+1) + 2
        rb = max(0.0, th*G - E0)**2/(4*M*V)
        Rb = (1-th)*G + E0
        ra = max(0.0, math.sqrt(Q/M) - math.sqrt(Rb/M))**2
        print(f"{d:3d} {label:7s} {18*d*c:10.3e} {th:7.4f} {rb:9.4f} {ra:9.4f} {max(ra, rb):7.4f}")
print("Limits: c = kappa/d -> route (b) -> gamma/(18 kappa+1)^2; d c -> 0 -> route (a) -> beta(lambda).")
for kappa in [0.05, 0.18, 1.0]:
    print(f"  kappa={kappa}: gamma/(18k+1)^2 = {gam/(18*kappa+1)**2:.4f}; route (a) limit "
          f"{max(0.0, math.sqrt(beta)-math.sqrt(p1*18*kappa/(18*kappa+1)))**2:.4f}")
