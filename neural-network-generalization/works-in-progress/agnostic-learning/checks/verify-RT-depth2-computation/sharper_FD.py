"""Aside: Theorem 5.1's explicit bound at c=1, lambda=1 (asymptotic surrogates G=(1-1/e)M, V=M) with the
README's own slope a_d = max{1, ln(4 sqrt(2d))/2}: rows satisfy ||omega||^2 <= max{1,(d+1) a_d^2} =: F'_d,
instead of F_d = 1+(d+1)(d+2)^2.  Also with A0^2 = 8 d Q (|c|^{-1} <= 2 sqrt(2d)) -> 16 d instead of 18 d."""
import math
lam = 1.0
def ad(d): return max(1.0, 0.5*math.log(4*math.sqrt(2*d)))
def FD(d): return 1 + (d+1)*(d+2)**2
def FDp(d): return max(1.0, (d+1)*ad(d)**2)
def bound(d, F, coef):
    M = 2.0**d; G = (1-math.exp(-lam))*M; V = lam*M
    th = 1/(coef*d+1); E0 = (d*F(d)+1) + 2
    return max(th*G-E0, 0)**2/(4*M*V)
for name, F, coef in [("F_d, 18d", FD, 18), ("F'_d, 18d", FDp, 18), ("F'_d, 16d", FDp, 16)]:
    first = next(d for d in range(5, 80) if bound(d, F, coef) > 0)
    best = max(range(5, 80), key=lambda d: bound(d, F, coef))
    print("%-10s: positive from d=%d; max %.3e at d=%d; value at d=30: %.3e" % (name, first, bound(best, F, coef), best, bound(30, F, coef)))
