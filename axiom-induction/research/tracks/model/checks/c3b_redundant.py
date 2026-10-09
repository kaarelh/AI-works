"""c3b: the redundant-spare case (c) of c3 at larger n, with grids adapted to the posterior scale.

Same model as c3 case (c): Q3 = point mass at a1 (inside supp P*).  R(n) = marginal(T* + tau3)/marginal(T*).
Sketch prediction: log R(n) = -(alpha/2) log n + O_P(1), alpha = 1/2, so slope -0.25.
The finite-n slope in c3 was -0.35 on n in [100, 1e4]; here we look at n up to 1e7.
"""
import math
import numpy as np
from scipy.special import betaln, logsumexp

A = 0.5
W1 = 0.6
rng = np.random.default_rng(31)
out = []


def log_marg_tstar(na1, na2, nb):
    na = na1 + na2
    return -na * math.log(2) + betaln(A + na, A + nb) - betaln(A, A)


def log_marg_spare(na1, na2, nb, NX=1200, NV=1200):
    n = na1 + na2 + nb
    # v grid: centred on the MLE of v under u=0, +-12 sd
    vhat = (na1 + na2) / n
    sd = math.sqrt(vhat * (1 - vhat) / n)
    lo, hi = max(1e-12, vhat - 12 * sd), min(1 - 1e-12, vhat + 12 * sd)
    vg = lo + (hi - lo) * (np.arange(NV) + 0.5) / NV
    lvw = (A - 1) * np.log(vg) + (A - 1) * np.log1p(-vg) - betaln(A, A) + math.log((hi - lo) / NV)
    # u grid: u = x^(1/A), x in (0, xmax); u scale ~ 1/sqrt(n); take u up to 40/sqrt(n)
    umax = min(1.0, 40 / math.sqrt(n))
    xmax = umax ** A
    x = xmax * (np.arange(NX) + 0.5) / NX
    u = x ** (1 / A)
    luw = (2 * A - 1) * np.log1p(-u) - betaln(A, 2 * A) + math.log(1 / A) + math.log(xmax / NX)
    U, V = u[:, None], vg[None, :]
    ll = (na1 * np.log((1 - U) * V / 2 + U) + na2 * np.log((1 - U) * V / 2)
          + nb * np.log((1 - U) * (1 - V)))
    return float(logsumexp(ll + luw[:, None] + lvw[None, :]))


ns = [10**3, 10**4, 10**5, 10**6, 10**7]
rows = []
for n in ns:
    vals = []
    for rep in range(60):
        nb = rng.binomial(n, 1 - W1)
        na1 = rng.binomial(n - nb, 0.5)
        na2 = n - nb - na1
        vals.append(log_marg_spare(na1, na2, nb) - log_marg_tstar(na1, na2, nb))
    vals = np.array(vals)
    rows.append((n, vals.mean(), vals.std() / math.sqrt(len(vals))))
    out.append(f"n = {n:9d}: mean log R = {vals.mean():8.4f} (s.e. {vals.std()/math.sqrt(len(vals)):.3f})")
lx = np.log([r[0] for r in rows])
ly = np.array([r[1] for r in rows])
out.append(f"fitted slope over n in [1e3, 1e7]: {np.polyfit(lx, ly, 1)[0]:.3f}; "
           f"slope over the last three points: {np.polyfit(lx[2:], ly[2:], 1)[0]:.3f}  (prediction -alpha/2 = -0.25)")
text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
