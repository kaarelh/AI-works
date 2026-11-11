"""Exact strong-prior TUBE posterior in an agnostic example inside Prop 4.1's hypotheses.

Input law: a single atom x0 = 0 in X = [-1,1] (d = 1).  Teacher g == -0.8, a depth-2,
width-1 network (first-layer weight 1 on the constant coordinate, readout -0.8/tanh 1,
so B = 1.0504).  Labels y = -0.8 + 0.3*Bernoulli(p), so |y - g| <= rho0 = 0.3.
Learner: depth 2, width N, Gaussian strong prior (b_j ~ N(0, sigma^2 N/d), v_j ~ N(0, sigma^2/N)),
conditioned on |z(x0) - y_i| < rho for all i.  At x0, z = sum_j v_j tanh(b_j) is, given b,
Gaussian with variance s^2(b) = (sigma^2/N) sum_j tanh^2(b_j), so the posterior is an exact
mixture of truncated normals; we integrate over b on a grid (N = 1, 2).

Feasible interval once both labels are seen: I = (-0.5 - rho, -0.8 + rho).
Prediction: as sigma -> 0 the posterior concentrates where energy is least, i.e. at the
end of I nearest 0, z -> -0.8 + rho (for rho < 0.8), so the Gibbs risk tends to
(rho - 0.3 p)^2 + 0.09 p (1 - p), while the Bayes risk (a width-1 constant network) is 0.09 p (1-p).
"""
import numpy as np
from scipy.special import log_ndtr, logsumexp
from scipy.stats import truncnorm

LOG_SQRT_2PI = 0.5 * np.log(2 * np.pi)


def logphi(t):
    return -0.5 * t * t - LOG_SQRT_2PI


def log_diff_Phi(a, b):
    """log(Phi(b) - Phi(a)), a < b, stable in both tails."""
    a, b = np.broadcast_arrays(a, b)
    out = np.empty(a.shape)
    neg = b <= 0
    # both on the left: use lower tails
    la, lb = log_ndtr(a[neg]), log_ndtr(b[neg])
    out[neg] = lb + np.log1p(-np.exp(np.minimum(la - lb, -1e-300)))
    # otherwise use upper tails: Phi(b)-Phi(a) = Phibar(a) - Phibar(b)
    pos = ~neg
    la, lb = log_ndtr(-a[pos]), log_ndtr(-b[pos])
    out[pos] = la + np.log1p(-np.exp(np.minimum(lb - la, -1e-300)))
    return out


def trunc_moments(a, b):
    """mean and second moment of N(0,1) truncated to [a,b] (arrays), stable."""
    lZ = log_diff_Phi(a, b)
    ea = np.exp(logphi(a) - lZ)
    eb = np.exp(logphi(b) - lZ)
    m1 = ea - eb
    m2 = 1.0 + a * ea - b * eb
    return lZ, m1, m2


def clipped_risk_given_b(s, lo, hi, eta):
    """E[(clip z - eta)^2 | z ~ N(0,s^2) truncated to (lo,hi)] and log P(z in (lo,hi))."""
    lZ, _, _ = trunc_moments(lo / s, hi / s)
    # split at -1 (lo >= -1.3 > -inf); piece A: z in (max(lo,-1), hi), piece B: z in (lo, -1)
    loA = np.maximum(lo, -1.0)
    lZA, m1A, m2A = trunc_moments(loA / s, hi / s)
    wA = np.exp(lZA - lZ)
    riskA = s * s * m2A - 2 * eta * s * m1A + eta * eta
    if lo < -1.0:
        lZB = log_diff_Phi(lo / s, -1.0 / s)
        wB = np.exp(lZB - lZ)
    else:
        wB = 0.0
    risk = wA * riskA + wB * (-1.0 - eta) ** 2
    return lZ, risk, wA * s * m1A


def gibbs_risk(N, sigma, rho, p, ngrid=4001):
    lo, hi = -0.5 - rho, -0.8 + rho
    eta = -0.8 + 0.3 * p
    sd_b = sigma * np.sqrt(N)          # d = 1
    bmax = 6.0
    g1 = np.linspace(-bmax, bmax, ngrid)
    if N == 1:
        B = g1[:, None]
    elif N == 2:
        g2 = np.linspace(-bmax, bmax, 1501)
        B1, B2 = np.meshgrid(g2, g2, indexing='ij')
        B = np.stack([B1.ravel(), B2.ravel()], axis=1)
    s = sigma / np.sqrt(N) * np.sqrt(np.sum(np.tanh(B) ** 2, axis=1))
    # points with s ~ 0 put z ~ 0, outside I (which excludes 0): zero posterior weight
    keep = s > 1e-3 * (hi - lo) / 40.0 * sigma
    B, s = B[keep], s[keep]
    logprior = np.sum(-0.5 * (B / sd_b) ** 2, axis=1)
    lZ, risk, _ = clipped_risk_given_b(s, lo, hi, eta)
    logw = logprior + lZ
    w = np.exp(logw - logsumexp(logw))
    # posterior mean of z (unclipped) for the posterior-mean predictor
    lZ2, m1, _ = trunc_moments(lo / s, hi / s)
    zmean = np.sum(w * s * m1)
    var_y = 0.09 * p * (1 - p)
    return np.sum(w * risk) + var_y, zmean


# cross-check the truncated-normal routine against scipy
for a, b in [(-3.0, -1.0), (-40.0, -30.0), (-200.0, -150.0), (-1.0, 2.0)]:
    lZ, m1, m2 = trunc_moments(np.array([a]), np.array([b]))
    tn = truncnorm(a, b)
    print(f"trunc check [{a},{b}]: mean {m1[0]:.10g} vs scipy {tn.mean():.10g}; E[X^2] {m2[0]:.10g} vs scipy {tn.moment(2):.10g}")

print()
print("rho0 = 0.3; columns: Gibbs risk (clipped) at decreasing sigma, posterior-mean z, limit, Bayes risk, bounds")
for rho in [0.35, 0.6]:
    for p in [0.5, 0.1, 0.01]:
        limit = (rho - 0.3 * p) ** 2 + 0.09 * p * (1 - p)
        bayes = 0.09 * p * (1 - p)
        LDg = 0.09 * p
        prop41 = (rho + 2 * 0.3) ** 2               # inf over admissible tau of (tau + rho0)^2
        refined = (rho + 0.3 + np.sqrt(LDg)) ** 2   # (tau + sqrt(L_D(g)))^2 at tau -> rho + rho0
        row = []
        for N in [1, 2]:
            for sigma in [0.5, 0.2, 0.1, 0.05, 0.02]:
                r, zm = gibbs_risk(N, sigma, rho, p)
                row.append((N, sigma, r, zm))
        print(f"rho={rho}, p={p}: limit (rho-0.3p)^2+Var = {limit:.5f}; Bayes = {bayes:.5f}; L_D(g) = {LDg:.5f};"
              f" excess limit = {limit-bayes:.5f}; rho^2 = {rho**2:.4f}; Prop4.1 inf bound = {prop41:.4f};"
              f" refined = {refined:.4f}")
        for N, sigma, r, zm in row:
            print(f"    N={N} sigma={sigma:<5}: Gibbs risk {r:.5f}, E_Pi z = {zm:+.5f} (limit {-0.8+rho:+.3f})")
