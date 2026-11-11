"""Corollary 4.5 with a_d = max{(max{c_d,1}/2^d)^{1/3}, 1/d} instead of (max{c_d,1}/2^d)^{1/3}:
every term of eps_bar_d still tends to 0, and N_0 <= 64 log2 d(d+1) 2^d d^2 + 1 <= 45 d^3 (d+1) 2^d = O(n log^4 n).
Prints eps_bar_d, the certified excess lower bound of Corollary 4.5, and N_0/n for both choices (c=1, t=1, lambda=1)."""
from math import log, sqrt, floor, exp
import mpmath as mp
out = []
def P(*a):
    s = " ".join(str(x) for x in a); print(s); out.append(s)
def alpha(d): return 0.5*log(4*sqrt(2*d))
b1 = float(mp.e**(-1)*(mp.ei(1)-mp.euler))
def epsbar(d, H, c, a, t=1.0, lam=1.0):
    n = lam*2.0**d
    return c*(d*(d+1)*alpha(d)**2 + t)/2**d + (H+1)*c*((8*d*n)**(1/H) + 9/(2*a))/2**d + lam*a*a
def ecor(d, H, c, a):
    q = max(b1 - 2.0**(-d) - sqrt(2)*2.0**(-d/4), 0)
    return max(sqrt(q) - sqrt(epsbar(d, H, c, a)), 0)**2
P(" H   d |  a_d (paper)  epsbar  e_cor  N0/n      |  a_d (new)   epsbar  e_cor  N0/n      | 45 d^3(d+1) bound/n")
for H in (2, 3):
    for d in (20, 40, 60, 100, 200, 400):
        c = 1.0; n = 2.0**d
        a_old = (max(c, 1)/2**d)**(1/3)
        a_new = max(a_old, 1/d)
        N_old = (64*log(2)*d*(d+1)*n/a_old**2 + 1)/n
        N_new = (64*log(2)*d*(d+1)*n/a_new**2 + 1)/n
        P(f" {H} {d:4d} | {a_old:.2e} {epsbar(d,H,c,a_old):.2e} {ecor(d,H,c,a_old):.4f} {N_old:.2e} | "
          f"{a_new:.2e} {epsbar(d,H,c,a_new):.2e} {ecor(d,H,c,a_new):.4f} {N_new:.2e} | {45*d**3*(d+1):.2e}")
P("limit beta(1) =", round(b1, 6))
open(__file__.replace('.py', '.out'), 'w').write("\n".join(out) + "\n")
