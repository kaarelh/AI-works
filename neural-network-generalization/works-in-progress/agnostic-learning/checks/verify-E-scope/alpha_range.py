"""Exponent bookkeeping for the conjecture's form (competitors with width m and weights B both <= n^alpha, fixed d).

B Corollary 8.1 (strong prior):  Exc_n = (E_*+1) n^{-theta} + 8(2/H)^{H/2} D_n n^{-(1-theta H)/2} + (4+(U+1)^2) sqrt(log/n),
  with E_* ~ m^2 B^2 ~ n^{4 alpha}, U = mB = n^{2 alpha}.  Constraints: 4a < theta, theta H < 1, 4a < 1/2.
E Remark 2.8 (finite scale, Case I, as written): excess <= h_n + 2 rho (U+1) + rho^2 + 2 n^{-theta}(A_L(rho)+..) + Psi_n(Kbar) + 8 eps0,
  Kbar = 8 A_L + 4 n^theta (U+2)^2 + ..., A_L >= E_*/2.  So Kbar ~ n^{4a} + n^{theta+4a};
  Psi ~ Kbar^{H/2} n^{-1/2}.  Constraints: 4a < theta (from n^{-theta} A_L), H*max(4a, theta+4a) < 1,
  h_n = (U+1)^2 sqrt(log/n): 4a < 1/2; 2 rho (U+1) with rho = n^{-theta}: 2a < theta.
E with the zero-network normaliser for energy control (Pi(G^c) <= mu(G^c) e^{Lambda (1+rho)^2}/mu(U_rho(0))):
  Kbar ~ 8 A_0 + 4 n^theta (1+rho)^2, A_0 = A_L(d,1,1,rho) independent of (m,B); Psi ~ n^{(theta H - 1)/2}.
  Constraints as for B.
We maximise alpha over a fine grid of (alpha, theta)."""
import numpy as np
def sup_alpha(H, feasible):
    best = 0.0
    for th in np.linspace(1e-4, 1.0, 20001):
        # largest alpha feasible at this theta (constraints are monotone in alpha)
        lo, hi = 0.0, 0.5
        if not feasible(H, 0.0, th):
            continue
        for _ in range(60):
            mid = (lo+hi)/2
            if feasible(H, mid, th): lo = mid
            else: hi = mid
        best = max(best, lo)
    return best
fB  = lambda H, a, th: 4*a < th and th*H < 1 and 4*a < 0.5
fE  = lambda H, a, th: 4*a < th and H*max(4*a, th+4*a) < 1 and 4*a < 0.5 and 2*a < th
fE0 = lambda H, a, th: 4*a < th and th*H < 1 and 4*a < 0.5
print(" H   B Cor 8.1 (1/(4H))   E as written   1/(8H)   E with zero-network budget")
for H in [2, 3, 4, 5]:
    print(f" {H}   {sup_alpha(H,fB):.5f} ({1/(4*H):.5f})     {sup_alpha(H,fE):.5f}      {1/(8*H):.5f}   {sup_alpha(H,fE0):.5f}")
# prefactor of the capacity term at fixed n-exponent: ratio E/B of (K/H)^{H/2} with K_E = 4 n^theta (U+2)^2, K_B = 2 n^theta
for H in [2, 3]:
    for U in [1, 3, 10, 100]:
        print(f" H={H}, U={U}: capacity-term ratio E/B >= (2 (U+2)^2)^(H/2) = {(2*(U+2)**2)**(H/2):.3g}")
