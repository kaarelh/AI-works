"""Independent exact check of Example 2.2 (refutation of the candidate's S1 with visit measures).
Brute force over all rehearsal histories (top call answers drawn by the mixture, slot J uniform),
small L and n, compared with the closed forms of the file:
  E beta(M^(T))        = (1-w) L (1-(1-kappa)^n)/n
  E int e_{M^(T)} dd_f = (1-w) L^2 (1-(1-kappa)^n)/(n (1+w(L-1))),  kappa = (1+w(L-1))/L."""
from fractions import Fraction as Fr
from itertools import product
def brute(L, n, w):
    # state: alive (g not refuted). Mixture while alive: M(1|x0)=1-w, M(1|a)=1-w, M(.|b)=0 (both say 0).
    total_own = Fr(0); total_hum = Fr(0)
    def rec(t, alive, prob):
        nonlocal total_own, total_hum
        if t > n: return
        if alive:
            own = (1-w)*(1 + w*(L-1)); hum = (1-w)*L
        else:
            own = Fr(0); hum = Fr(0)
        total_own += prob*own/n; total_hum += prob*hum/n
        if not alive:
            rec(t+1, False, prob); return
        # rehearsal run: call 1 at x0, mixture answers 0 w.p. w (-> a), 1 w.p. 1-w (-> b)
        for branch, pb in (("a", w), ("b", 1-w)):
            for J in range(1, L+1):
                pj = Fr(1, L)
                refute = (J == 1) or (branch == "a")
                rec(t+1, not refute, prob*pb*pj)
    rec(1, True, Fr(1))
    return total_own, total_hum
for L, n, w in ((2, 3, Fr(1, 3)), (3, 3, Fr(1, 4)), (4, 2, Fr(1, 2))):
    own, hum = brute(L, n, w)
    kap = (1 + w*(L-1))/L
    f_own = (1-w)*L*(1-(1-kap)**n)/n
    f_hum = (1-w)*L*L*(1-(1-kap)**n)/(n*(1+w*(L-1)))
    print(f"L={L} n={n} w={w}: brute E beta_own={own} formula {f_own}; brute E beta_hum={hum} formula {f_hum}; equal: {own==f_own and hum==f_hum}")
import math
for L, n in ((100, 10**4), (1000, 10**6)):
    w = 1/L; kap = (1+w*(L-1))/L
    hum = (1-w)*L*L*(1-(1-kap)**n)/(n*(1+w*(L-1)))
    claim = 1/(1-L/n)*L*math.log(L)/n   # B * L * K ln2 / n with K ln 2 = ln L and B <= 1/(1-L/n)
    print(f"L={L}, w=1/L, n={n}: E int e dd_f = {hum:.4f} > candidate S1 bound {claim:.5f} (ratio {hum/claim:.1f})")
