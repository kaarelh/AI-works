"""c3: spare templates under Dirichlet-integrated L0 weights (notes, Prop 5.5).

Truth T* = {tau1, tau2}: Q1 uniform on {a1, a2}, Q2 = point mass at b; P* = w1 Q1 + w2 Q2, w* = (0.6, 0.4).
A spare template tau3 adds component Q3; prior Dir(alpha, alpha, alpha) on the three weights vs Dir(alpha, alpha).
  (a) disjoint spare:     Q3 = point mass at o (o outside supp P*)
  (b) over-general spare: Q3 = (1-c) at a1 + c at o, c = 0.3
  (c) redundant spare:    Q3 = point mass at a1 (inside supp P*, different from Q1)
R(n) = marginal(T* + tau3) / marginal(T*).  Claims: (a) exactly Gamma(3a)Gamma(2a+n)/(Gamma(2a)Gamma(3a+n)) ~ C n^-a;
(b) ~ n^-a (sketch); (c) ~ n^-(a/2) (sketch).  alpha = 1/2.
Numerics: u = w3 ~ Beta(a, 2a), v = w1/(w1+w2) ~ Beta(a, a) independent; u = x^(1/a) removes the u^(a-1) singularity.
"""
import math
import numpy as np
from scipy.special import gammaln, betaln, logsumexp

A = 0.5
rng = np.random.default_rng(3)
W1 = 0.6
out = []

NX, NV = 1500, 1500
x = (np.arange(NX) + 0.5) / NX
u = x ** (1 / A)                      # u in (0,1); with dx uniform, density factor is constant
log_u_w = (2 * A - 1) * np.log1p(-u) - betaln(A, 2 * A) + math.log(1 / A) - math.log(NX)
vg = (np.arange(NV) + 0.5) / NV
log_v_w = (A - 1) * np.log(vg) + (A - 1) * np.log1p(-vg) - betaln(A, A) - math.log(NV)


def log_marg_tstar(na1, na2, nb):
    na = na1 + na2
    return -na * math.log(2) + betaln(A + na, A + nb) - betaln(A, A)


def log_marg_spare(na1, na2, nb, q3a1):
    """log E_{u,v}[ prod ] for the case where tau3 puts mass q3a1 on a1 and nothing else in supp P*."""
    U = u[:, None]
    V = vg[None, :]
    ll = (na2 * np.log((1 - U) * V / 2) + nb * np.log((1 - U) * (1 - V)))
    if q3a1 > 0:
        ll = ll + na1 * np.log((1 - U) * V / 2 + U * q3a1)
    else:
        ll = ll + na1 * np.log((1 - U) * V / 2)
    return float(logsumexp(ll + log_u_w[:, None] + log_v_w[None, :]))


cases = [("(a) disjoint", 0.0), ("(b) over-general c=0.3", 0.7), ("(c) redundant", 1.0)]
ns = [100, 300, 1000, 3000, 10000]
for name, q3a1 in cases:
    rows = []
    for n in ns:
        vals = []
        for rep in range(8):
            nb = rng.binomial(n, 1 - W1)
            na1 = rng.binomial(n - nb, 0.5)
            na2 = n - nb - na1
            vals.append(log_marg_spare(na1, na2, nb, q3a1) - log_marg_tstar(na1, na2, nb))
        rows.append((n, float(np.mean(vals))))
    exact = [gammaln(3 * A) + gammaln(2 * A + n) - gammaln(2 * A) - gammaln(3 * A + n) for n in ns]
    slope = np.polyfit(np.log([r[0] for r in rows]), [r[1] for r in rows], 1)[0]
    out.append(f"{name}: fitted slope of mean log R(n) vs log n = {slope:.3f}")
    for (n, lr), ex in zip(rows, exact):
        extra = f"   exact formula (a): {ex:.4f}" if q3a1 == 0.0 else ""
        out.append(f"   n = {n:6d}: mean log R = {lr:9.4f}{extra}")
out.append(f"predicted slopes: (a) -alpha = {-A}, (b) -alpha = {-A}, (c) -alpha/2 = {-A/2}")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
