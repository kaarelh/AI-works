"""Proposition 5.2 / Table 5.1: independent simulation of U_S, the high-probability bound, the consequence's
sample size, and an exact check that max{sum f^2 : Delta(f) <= Delta_0 + ct} <= M U_S (Minkowski step)."""
import numpy as np
from math import log, sqrt, exp
rng = np.random.default_rng(20261111)
out = []
def P(*a):
    s = " ".join(str(x) for x in a); print(s); out.append(s)

def sample(d, n):
    M = 2**d
    k = rng.multinomial(n, np.full(M, 1.0/M))
    sums = 2*rng.binomial(k, 0.5) - k          # sum of k_x fair signs at atom x
    return M, k, sums

def U_S(M, k, sums, c=1.0, t=1.0):
    kmin = k.min()
    if kmin == 0: return np.inf, None
    Delta0 = float(np.sum(sums**2 / k))        # sum_x k_x ybar_x^2 = sum_x (sum)^2/k_x
    U1 = ((sqrt((Delta0 + c*t)/kmin) + sqrt(Delta0/kmin))**2)/M
    U2 = 2*(2*Delta0 + c*t)/(M*kmin)
    return U1, (U2, Delta0, kmin)

P("Table 5.1 (c=t=1): median U_S, 400 reps (100 at d=8, n/M=1024); HP bound (8M/delta'+4ct)/n at delta'=0.05")
P(" d  n/M   med U_S   med U2   ratio med/(M/n)   HPbound  freq(U<=HP)  guaranteed  P(kmin>=1)")
for d in (6, 8):
    for lam in (4, 16, 64, 256, 1024):
        reps = 100 if (d == 8 and lam == 1024) else 400
        M = 2**d; n = lam*M
        U = []; U2s = []
        for _ in range(reps):
            u, extra = U_S(*sample(d, n))
            U.append(u); U2s.append(extra[0] if extra else np.inf)
        U = np.array(U); U2s = np.array(U2s)
        hp = (8*M/0.05 + 4)/n
        guar = max(0.0, 1 - 0.05 - M*exp(-n/(8*M)))
        P(f" {d}  {lam:4d}  {np.median(U):8.4f}  {np.median(U2s):8.4f}   {np.median(U)*lam:8.2f}       {hp:8.4f}   {np.mean(U <= hp):.3f}      {guar:.3f}      {np.mean(np.isfinite(U)):.3f}")

P("\nConsequence's sample size n >= max{8M log(2M/delta), (16M/delta + 4ct)/eps} (c=t=1):")
for d in (4, 8, 12):
    M = 2**d
    for eps in (0.1, 0.01):
        delta = 0.05
        n0 = max(8*M*log(2*M/delta), (16*M/delta + 4)/eps)
        P(f"  d={d} eps={eps} delta={delta}: n0 = {n0:.3e} = {n0/M:.3g} M")

P("\nExact maximum of sum_x f(x)^2 subject to Delta(f) <= Delta_0 + ct, versus M U_S (Minkowski) [d=4]:")
worst = 0.0
for rep in range(300):
    d = 4; lam = int(rng.choice([2, 8, 32])); M, k, sums = sample(d, lam*2**d)
    if k.min() == 0: continue
    ybar = sums / k
    B = float(np.sum(k*ybar**2)) + 1.0   # Delta_0 + ct with c=t=1
    # maximise ||f||^2 s.t. sum k (f-ybar)^2 <= B: f = nu k ybar/(nu k - 1), nu > 1/kmin, constraint active
    def g(nu): return np.sum(k*(ybar/(nu*k - 1))**2) - B
    lo, hi = 1.0/k.min()*(1+1e-14), 1e6
    if g(hi) > 0: continue
    for _ in range(300):
        mid = 0.5*(lo+hi)
        if g(mid) > 0: lo = mid
        else: hi = mid
    nu = hi; f = nu*k*ybar/(nu*k - 1)
    assert np.sum(k*(f-ybar)**2) <= B*(1+1e-9)
    val = float(np.sum(f**2)) / M
    U1, _ = U_S(M, k, sums)
    worst = max(worst, val/U1)
P("  max over 300 random samples of [max_f (1/M) sum f^2] / U_S =", round(worst, 4), "(<= 1 required)")
open(__file__.replace('.py', '.out'), 'w').write("\n".join(out) + "\n")
