"""Monte Carlo model of the AI R&D progress multiplier at a frontier lab (autumn 2026).

Two stages:

1. Research-labour uplift S_L. Anthropic's R&D Automation Index (Aug 2026) gives the
   share of current person-time at each automation level: AI 'leads' (AL4) 26%,
   'collaborates' (AL3) roughly 64%, AL2 or below roughly 10%. If c_j are current
   time shares and k_j the speedup at level j, the same work without AI would take
   sum_j c_j k_j units of time, so S_L = sum_j c_j k_j. This is a current-time-weighted
   arithmetic mean; with pre-AI time shares it would be a harmonic mean (Amdahl).
   Work that would not have been done at all without AI is discounted by v.

2. Research labour -> algorithmic progress. CES in effective research labour and
   experiment compute, compute held fixed:
       m = [s_L * S_L**rho + (1 - s_L)]**(1/rho),   rho = 1 - 1/sigma,
   where s_L is the elasticity of progress with respect to research labour.
   Anthropic's Mythos Preview system card says reaching 2x via this channel 'would
   require uplift roughly an order of magnitude larger' than the observed ~4x, which
   implies s_L ~ ln 2 / ln 40 ~ 0.19 in the Cobb-Douglas case. Whitfill & Wu (2025)
   estimate sigma anywhere from about 0 (complements) to about 2.6 (substitutes).

The output is a distribution, not a forecast. The structure caps how far a labour-only
channel can push m, which is why the lab estimates and this model sit below 2x.
"""
import warnings

import numpy as np

warnings.filterwarnings("ignore", category=RuntimeWarning)  # percentiles over inf

rng = np.random.default_rng(2026)
N = 400_000


def lognormal_ci(lo, hi, n, z=1.2816):
    """Lognormal with 10th/90th percentiles lo/hi."""
    mu = (np.log(lo) + np.log(hi)) / 2
    s = (np.log(hi) - np.log(lo)) / (2 * z)
    return np.exp(rng.normal(mu, s, n))


def ces(S, sL, sigma):
    rho = 1 - 1 / sigma
    out = np.empty_like(S)
    cd = np.abs(rho) < 1e-3
    out[cd] = S[cd] ** sL[cd]
    r = rho[~cd]
    out[~cd] = (sL[~cd] * S[~cd] ** r + (1 - sL[~cd])) ** (1 / r)
    return out


def labour_uplift(n, scale=1.0):
    # current person-time shares at AL4 / AL3 / <=AL2
    c4 = rng.uniform(0.20, 0.32, n)
    c2 = rng.uniform(0.05, 0.15, n)
    c3 = 1 - c4 - c2
    k4 = lognormal_ci(4.0, 12.0, n) * scale   # human time on an AI-led task is mostly supervision
    k3 = lognormal_ci(1.4, 3.0, n) * np.sqrt(scale)
    k2 = lognormal_ci(1.0, 1.4, n)
    v = rng.uniform(0.75, 1.0, n)              # value discount for AI-enabled marginal work
    S = c4 * k4 + c3 * k3 + c2 * k2
    return 1 + v * (S - 1)


def pct(x, qs=(10, 25, 50, 75, 90)):
    return " ".join(f"{np.percentile(x, q):6.2f}" for q in qs)


S_L = labour_uplift(N)
sL = rng.uniform(0.15, 0.5, N)
sigma = lognormal_ci(0.35, 2.5, N)
m = ces(S_L, sL, sigma)

print("percentiles                    10     25     50     75     90")
print("research-labour uplift S_L  ", pct(S_L))
print("progress multiplier m       ", pct(m))
print("AI share of progress 1-1/m  ", pct(1 - 1 / m))
print(f"P(m >= 2) = {np.mean(m >= 2):.3f}")
print()

# How much labour uplift is needed for m = 2, by bottleneck assumption
print("labour uplift needed for m = 2:")
for sl, sg in [(0.19, 1.0), (0.3, 1.0), (0.5, 1.0), (0.3, 2.5), (0.5, 2.5), (0.5, 0.5)]:
    rho = 1 - 1 / sg
    if abs(rho) < 1e-9:
        need = 2 ** (1 / sl)
    else:
        base = (2 ** rho - (1 - sl)) / sl
        need = base ** (1 / rho) if base > 0 else float("inf")
    print(f"  s_L={sl:.2f} sigma={sg:.1f}: S_L = {need:8.1f}")
print()

# Crossing year if research-labour uplift keeps doubling every T years from Oct 2026
print("crossing date of m = 2 if S_L doubles every T years from Oct 2026 (labour channel only):")
for T in [0.5, 1.0, 1.5]:
    years = np.full(N, np.inf)
    for step in np.arange(0, 8.01, 0.05):
        mm = ces(S_L * 2 ** (step / T), sL, sigma)
        newly = (mm >= 2) & np.isinf(years)
        years[newly] = step
    frac = np.isfinite(years).mean()
    q10, q50, q90 = (np.percentile(years, q) for q in (10, 50, 90))
    fmt = lambda y: f"{2026.75 + y:.1f}" if np.isfinite(y) else "never (by 2034.75)"
    print(f"  T={T}: 10% {fmt(q10)}, median {fmt(q50)}, 90% {fmt(q90)}; "
          f"crossed by 2034.75 in {frac:.0%} of draws")
