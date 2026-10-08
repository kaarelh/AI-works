"""r4 (referee): independent checks of Prop 5.4(b) and Prop 5.5 of notes.md, with parameters the track did not use.

A.  Prop 5.4(b): Delta_n = n KL(rhat||p) - (K-1)/2 ln n + c_{K,alpha} + (alpha - 1/2) sum_f ln rhat_f + o(1).
    The track checked only alpha = 1/2 (where the last term vanishes).  We check K = 3, alpha in {0.3, 1, 2}, at fixed
    empirical frequencies, by exact log-Gamma arithmetic; the residual must tend to 0.

B.  Prop 5.5 with a different truth and alpha_sigma in {0.5, 1, 2} (track used only 1/2), alpha_tau = 1:
    T* = {tau1, tau2}: Q1 = point mass at a, Q2 = uniform on {b1, b2}; w* = (1/2, 1/2).
    (a) disjoint spare: exact Gamma formula (checked against the integral);
    (b) spare reaching outside: Q_s = 0.6 b1 + 0.4 o (o never observed): claimed slope -alpha_s;
    (c) redundant spare: Q_s = (a + b1)/2 (inside the support, not in span{Q1, Q2}): claimed slope -alpha_s/2;
    (d) spare in the span: Q_s = Q1 (e.g. a renamed or permuted copy of tau1): not covered by the proposition.
    R_n = marginal(T* + s)/marginal(T*), with w = ((1-u)v, (1-u)(1-v), u), u ~ Beta(a_s, A), v ~ Beta(1, 1).
"""
import math
import numpy as np
from scipy.special import gammaln, betaln, logsumexp

out = []
rng = np.random.default_rng(404)

# ---------------- A ----------------
K = 3
r = np.array([0.5, 0.3, 0.2])
p = np.array([0.4, 0.4, 0.2])
for alpha in (0.3, 1.0, 2.0):
    res = []
    for n in (10**3, 10**4, 10**5, 10**6, 10**7):
        cnt = np.round(n * r)
        nn = cnt.sum()
        rh = cnt / nn
        exact = (gammaln(K * alpha) - gammaln(K * alpha + nn) + np.sum(gammaln(alpha + cnt) - gammaln(alpha))
                 - np.sum(cnt * np.log(p)))
        c = gammaln(K * alpha) - K * gammaln(alpha) + (K - 1) / 2 * math.log(2 * math.pi)
        approx = nn * np.sum(rh * np.log(rh / p)) - (K - 1) / 2 * math.log(nn) + c + (alpha - 0.5) * np.sum(np.log(rh))
        res.append(exact - approx)
    out.append(f"A: alpha = {alpha}: residual exact - expansion at n = 1e3..1e7: " + ", ".join(f"{x:.2e}" for x in res))

# ---------------- B ----------------
A1 = A2 = 1.0
A = A1 + A2

def log_marg_tstar(na, nb1, nb2):
    nb = nb1 + nb2
    return betaln(A1 + na, A2 + nb) - betaln(A1, A2) - nb * math.log(2)

def log_marg_spare(na, nb1, nb2, a_s, case, NU=900, NV=900):
    n = na + nb1 + nb2
    vh = na / n
    sd = math.sqrt(vh * (1 - vh) / n)
    lo, hi = max(1e-12, vh - 14 * sd), min(1 - 1e-12, vh + 14 * sd)
    v = lo + (hi - lo) * (np.arange(NV) + 0.5) / NV
    lvw = (A1 - 1) * np.log(v) + (A2 - 1) * np.log1p(-v) - betaln(A1, A2) + math.log((hi - lo) / NV)
    umax = min(1.0, (80.0 / n) if case == 'b' else (60.0 / math.sqrt(n)))
    y = (np.arange(NU) + 0.5) / NU
    u = umax * y ** (1 / a_s)
    # u^(a_s-1) du = umax^a_s / a_s dy ; remaining Beta(a_s, A) density factor (1-u)^(A-1)/B(a_s, A)
    luw = (A - 1) * np.log1p(-u) - betaln(a_s, A) + a_s * math.log(umax) - math.log(a_s) - math.log(NU)
    U, V = u[:, None], v[None, :]
    if case == 'b':
        Pa = (1 - U) * V
        Pb1 = (1 - U) * (1 - V) / 2 + 0.6 * U
        Pb2 = (1 - U) * (1 - V) / 2
    elif case == 'c':
        Pa = (1 - U) * V + U / 2
        Pb1 = (1 - U) * (1 - V) / 2 + U / 2
        Pb2 = (1 - U) * (1 - V) / 2
    ll = na * np.log(Pa) + nb1 * np.log(Pb1) + nb2 * np.log(Pb2)
    return float(logsumexp(ll + luw[:, None] + lvw[None, :]))

def exact_a(n, a_s):
    return gammaln(A + a_s) + gammaln(A + n) - gammaln(A) - gammaln(A + a_s + n)

def exact_d(na, n, a_s):
    # aggregation: (w1 + w_s, w2) ~ Dir(A1 + a_s, A2); likelihood depends only on that pair
    nb = n - na
    lm_sp = betaln(A1 + a_s + na, A2 + nb) - betaln(A1 + a_s, A2)
    lm_st = betaln(A1 + na, A2 + nb) - betaln(A1, A2)
    return lm_sp - lm_st

# grid-convergence check
na, nb1, nb2 = 50_123, 24_900, 24_977
for case in ('b', 'c'):
    v1 = log_marg_spare(na, nb1, nb2, 1.0, case) - log_marg_tstar(na, nb1, nb2)
    v2 = log_marg_spare(na, nb1, nb2, 1.0, case, NU=1800, NV=1800) - log_marg_tstar(na, nb1, nb2)
    out.append(f"B grid check, case ({case}), n = 1e5, a_s = 1: log R = {v1:.5f} (900^2 grid) vs {v2:.5f} (1800^2 grid)")

ns = [10**3, 10**4, 10**5, 10**6]
REPS = 30
for a_s in (0.5, 1.0, 2.0):
    rows = {'b': [], 'c': [], 'd': []}
    for n in ns:
        vals = {'b': [], 'c': [], 'd': []}
        for _ in range(REPS):
            na = rng.binomial(n, 0.5)
            nb1 = rng.binomial(n - na, 0.5)
            nb2 = n - na - nb1
            base = log_marg_tstar(na, nb1, nb2)
            vals['b'].append(log_marg_spare(na, nb1, nb2, a_s, 'b') - base)
            vals['c'].append(log_marg_spare(na, nb1, nb2, a_s, 'c') - base)
            vals['d'].append(exact_d(na, n, a_s))
        for k in rows:
            rows[k].append(np.mean(vals[k]))
    lx = np.log(ns)
    sa = np.polyfit(lx, [exact_a(n, a_s) for n in ns], 1)[0]
    sb = np.polyfit(lx, rows['b'], 1)[0]
    sc = np.polyfit(lx, rows['c'], 1)[0]
    sd_ = np.polyfit(lx, rows['d'], 1)[0]
    out.append(f"B: a_s = {a_s}: slopes of mean log R_n vs ln n on n = 1e3..1e6:  (a) {sa:.3f} [claim {-a_s}],  "
               f"(b) {sb:.3f} [claim {-a_s}],  (c) {sc:.3f} [claim {-a_s/2}],  (d, in span) {sd_:.3f}")
    out.append("      mean log R_n (c): " + ", ".join(f"{x:.3f}" for x in rows['c'])
               + ";  (d): " + ", ".join(f"{x:.3f}" for x in rows['d'])
               + f"  [(d) limit a_s ln w1* + const = {a_s * math.log(0.5) + gammaln(A + a_s) - gammaln(A) + gammaln(A1) - gammaln(A1 + a_s):.3f}]")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
