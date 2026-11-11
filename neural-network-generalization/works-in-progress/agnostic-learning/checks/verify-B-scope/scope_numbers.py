"""Scope checks for out/B.md (referee: scope and adversarial interpretation).

Part D. Fixed-law (non-uniform) reading of the user's conjecture.
  For the steep two-point law D_{delta0} of Prop. 9.1 with delta0 FIXED, the learner SP_c, c = n^{1-theta},
  (i) provably fails (L_D >= 1/4) while eta = delta0 ((n^theta+1)/L)^{L/2} <= 1/2           [Prop 9.1(a)];
  (ii) is certified to have excess <= eps once Remark 6.5's bound with w' = clone of the chain
       competitor g_{delta0} (energy <= (H+9/4) delta0^{-2/L}, sup|g| <= v <= 1.5 omega) is <= eps.
  Both thresholds are finite for every fixed delta0, and scale like delta0^{-2/(L theta)}.
  So, for each FIXED law, the width-only (no weight bound) comparison holds eventually; the weight bound
  in B.md Section 9 is needed only for uniformity over laws (delta0 shrinking with n).

Part E. Independent recomputation of the Section 7.5 transition window (noisy cube, n = 2^d, zero competitor).
  Negative certificate (Prop. 7.3): excess >= (sqrt(1/e - n^{-1/3}) - sqrt(eps_{c,t}))_+^2, optimised over t <= 1/4.
  Positive certificate (Remark 6.5 with w' = 0 and Lemma 5.3(a)):
      excess <= c/n + 8((n/c+1)/H)^{H/2} D_n / sqrt(n) + 5 sqrt(ln(2/delta)/(2n)).
"""
import math
from scipy.optimize import brentq, minimize_scalar


# ---------------- Part D ----------------
def chain_competitor(delta0, L):
    """Width-1 chain of Prop 9.1(b): omega = delta0^{-1/L}, t_l = tanh(omega t_{l-1}), v = 1/t_H. Returns (omega, v, energy)."""
    H = L - 1
    omega = delta0 ** (-1.0 / L)
    t = delta0
    for _ in range(H):
        t = math.tanh(omega * t)
    v = 1.0 / t
    energy = H * omega ** 2 + v ** 2          # clone energy at every width (Prop 9.1(b))
    return omega, v, energy


def remark65_bound(n, theta, L, delta0, delta=0.05):
    H = L - 1
    omega, v, kap = chain_competitor(delta0, L)
    U = abs(v)                                 # sup |g| <= |v| (hidden units bounded by 1)
    K = n ** theta + 1
    Dn = math.sqrt(2 * (1 + 1) * math.log(n + 1)) + (H - 1) / 2   # d = 1
    psi = 8 * (K / H) ** (H / 2) * Dn / math.sqrt(n) + 4 * math.sqrt(math.log(2 / delta) / (2 * n))
    return n ** (-theta) * (kap + 1) + psi + (U + 1) ** 2 * math.sqrt(math.log(2 / delta) / (2 * n))


def fail_threshold(theta, L, delta0):
    """Largest n with eta = delta0((n^theta+1)/L)^{L/2} <= 1/2 (learner has L_D >= 1/4 at every width)."""
    # eta <= 1/2  <=>  n^theta + 1 <= L (1/(2 delta0))^{2/L}
    rhs = L * (1 / (2 * delta0)) ** (2 / L) - 1
    return rhs ** (1 / theta) if rhs > 0 else 0.0


def success_threshold(theta, L, delta0, eps=0.1):
    f = lambda logn: remark65_bound(math.exp(logn), theta, L, delta0) - eps
    lo, hi = math.log(2.0), math.log(1e300)
    if f(hi) > 0:
        return float('inf')
    # f is not monotone at tiny n; scan for the last sign change from + to -
    import numpy as np
    grid = np.linspace(lo, hi, 4000)
    vals = [f(g) for g in grid]
    last_pos = max(i for i, val in enumerate(vals) if val > 0)
    return math.exp(brentq(f, grid[last_pos], grid[last_pos + 1]))


print("Part D: steep two-point law D_delta0 with delta0 FIXED; c = n^(1-theta)")
print("  L  theta   delta0     chain energy   log10 n_fail (L_D>=1/4)   log10 n_cert (excess<=0.1)   ratio of logs")
for L, theta in [(2, 0.4), (3, 0.25), (3, 0.4), (4, 0.25)]:
    for delta0 in [1e-1, 1e-2, 1e-3, 1e-4]:
        om, v, kap = chain_competitor(delta0, L)
        nf = fail_threshold(theta, L, delta0)
        ns = success_threshold(theta, L, delta0)
        lf = math.log10(nf) if nf > 1 else float('nan')
        print(f"  {L}  {theta:4.2f}  {delta0:8.0e}   {kap:12.4g}        {lf:8.2f}                   {math.log10(ns):8.2f}              "
              f"{(math.log10(ns) / lf if lf == lf and lf > 0 else float('nan')):6.2f}")
print("  Both thresholds are finite for each fixed law and grow polynomially in 1/delta0 "
      "(slope ~ 2/(L theta) in log10(1/delta0)).")
print()

# ---------------- Part E ----------------
def neg_excess(logc, d, H):
    n = 2.0 ** d
    c = math.exp(logc)
    q = 1 / math.e - n ** (-1 / 3)

    def eps_of(logt):
        t = math.exp(logt)
        Amax2 = (d + 1) ** 2 * n
        beta = max(1.0, 0.5 * math.log(2 * math.sqrt(Amax2) / t))
        Kmem = beta ** 2 * d ** 3 + (H + 1) * max(2.0, 9 / (4 * t), Amax2 ** (1 / H))
        return (c / n) * (Kmem + 1) + 9 * t ** 2

    res = minimize_scalar(eps_of, bounds=(math.log(1e-30), math.log(0.25)), method='bounded',
                          options={'xatol': 1e-10})
    e = min(res.fun, eps_of(math.log(0.25)))
    return max(0.0, math.sqrt(q) - math.sqrt(e)) ** 2


def pos_excess(logc, d, H, delta=0.05):
    n = 2.0 ** d
    c = math.exp(logc)
    Dn = math.sqrt(2 * (d + 1) * math.log(n + 1)) + (H - 1) / 2
    return c / n + 8 * ((n / c + 1) / H) ** (H / 2) * Dn / math.sqrt(n) + 5 * math.sqrt(math.log(2 / delta) / (2 * n))


print("Part E: transition window on the noisy cube (independent recomputation)")
print("  H    d    log_n c_neg (excess>=0.2)   log_n c_pos (excess<=0.1)   1-1/H")
for H in [2, 3]:
    for d in [80, 200, 400]:
        ln_n = d * math.log(2)
        cneg = brentq(lambda lc: neg_excess(lc, d, H) - 0.2, 1e-9, ln_n * 0.999)
        # pos_excess is U-shaped in log c: bracket between c = 1 and its minimiser
        mres = minimize_scalar(lambda lc: pos_excess(lc, d, H), bounds=(1e-9, ln_n * 0.999999), method='bounded')
        cpos = brentq(lambda lc: pos_excess(lc, d, H) - 0.1, 1e-9, mres.x)
        print(f"  {H}  {d:4d}        {cneg / ln_n:7.4f}                    {cpos / ln_n:7.4f}            {1 - 1 / H:6.4f}")
