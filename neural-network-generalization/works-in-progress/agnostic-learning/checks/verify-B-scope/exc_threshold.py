"""Displayed Exc_n of Thm 6.3 (with K <= 2 n^theta) vs the sharper K = n^theta + 1, at L=3, d=10, m=B=1, theta=1/4, delta=0.05."""
import math
from scipy.optimize import brentq
L, H, d, m, B, th, dl = 3, 2, 10, 1, 1, 0.25, 0.05
Es, U = d*(d+1)*B**2 + 2*(L-1)*m**2*B**2, m*B
def Dn(n): return math.sqrt(2*(d+1)*math.log(n+1)) + (H-1)/2
def exc_displayed(n): return (Es+1)*n**-th + 8*(2/H)**(H/2)*Dn(n)*n**(-(1-th*H)/2) + (4+(U+1)**2)*math.sqrt(math.log(2/dl)/(2*n))
def exc_sharp(n): return (Es+1)*n**-th + 8*((n**th+1)/H)**(H/2)*Dn(n)/math.sqrt(n) + (4+(U+1)**2)*math.sqrt(math.log(2/dl)/(2*n))
for name, f in [("displayed Exc_n", exc_displayed), ("K = n^theta+1  ", exc_sharp)]:
    r = brentq(lambda t: f(10**t) - 0.1, 5, 40)
    print(f"{name}: first <= 0.1 at log10 n = {r:.2f};  value at n = 10^13.4: {f(10**13.4):.4f}")
