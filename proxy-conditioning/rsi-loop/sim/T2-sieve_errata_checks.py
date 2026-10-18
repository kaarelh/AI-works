"""Checks for the errata to drafts/T2-sieve.md (18 October 2026).

E1. Envelope of the best-responder drift D* over ALL recognition signals with a given AUC
    (Example 1 parameters), against the Gaussian (binormal) signal used in Examples 1 and 4.
    Claim: with k = exp(xi*) = odds(pbar)/odds(t*) and c0 = (1-pbar) t*,
        c0 * (1 - sqrt(2 k (1-AUC)))^+  <=  D*/(w lambar)  <=  c0 * (2 AUC - 1),
    both attained.  D* = 0 is possible iff AUC <= 1 - 1/(2k).
E2. Per-type mean-field ratio R_t(n) = n pi_t (E l_t)^2 / Var l_t in Example 1 under per-episode (D),
    and for low-tail types in sieve scenario 2.
E3. Capture law: predictions (P+/P-)^ceil(x/lambda) recomputed (simulated values are in
    reconcile_checks_output.txt, R12); Lundberg exponent for asymmetric steps (+lambda_+, -lambda_-),
    checked by Monte Carlo.
E4. Example 1's headline (P_on at n = 1e4) under other priors and under the envelope of E1.

Run: python3 T2-sieve_errata_checks.py  (about 20 s).  Output: T2-sieve_errata_checks_output.txt
"""
import numpy as np
from scipy.stats import norm
from scipy.optimize import brentq
from scipy.special import expit, logit

out = []


def P(*a):
    s = " ".join(str(x) for x in a)
    out.append(s)
    print(s)


rng = np.random.default_rng(20261018)

pbar, w, lp, lm, alpha = 0.3, 0.05, 0.1, 0.4, 0.99
lb = lp + lm
ts = lp / lb
k = (pbar / (1 - pbar)) / (ts / (1 - ts))           # exp(xi*)
c0 = (1 - pbar) * ts


def gauss_Dstar_norm(auc):
    d = np.sqrt(2) * norm.ppf(auc)
    z = (logit(ts) - logit(pbar) + d * d / 2) / d
    return (1 - pbar) * ts * norm.cdf(z) - pbar * (1 - ts) * norm.cdf(z - d)


def env(auc):
    lo = c0 * max(0.0, 1 - np.sqrt(2 * k * (1 - auc)))
    hi = c0 * (2 * auc - 1)
    return lo, hi


# ---------------------------------------------------------------- E1
P("=" * 78)
P("E1. Envelope of D*/(w lambar) over all recognition signals with a given AUC (Example 1: pbar=0.3, t*=0.2)")
P("=" * 78)
P(f"   k = exp(xi*) = {k:.4f}, xi* = {np.log(k):.4f}, c0 = (1-pbar) t* = {c0:.3f}")
P(f"   largest AUC compatible with D* = 0: 1 - 1/(2k) = {1 - 1 / (2 * k):.4f}")
P("   AUC    lower   Gaussian   upper    | flip time L0/D* (episodes): lower-D* signal, Gaussian, upper-D* signal")
L0 = np.log(alpha / (1 - alpha))
for auc in (0.6, 0.7, 0.75, 0.8, 0.9, 0.95, 0.99):
    lo, hi = env(auc)
    g = gauss_Dstar_norm(auc)
    ft = lambda x: (L0 / (w * lb * x)) if x > 0 else np.inf
    P(f"   {auc:.2f}  {lo:.4f}  {g:.4f}    {hi:.4f}   | {ft(lo):9.0f} {ft(g):9.0f} {ft(hi):9.0f}")


# numerical validation: random discrete signals; the ROC of the LR test, AUC, and max[TPR - k FPR]
def roc_stats(pu, pc):
    llr = np.log(pu) - np.log(pc)
    o = np.argsort(-llr)                      # most "unchecked"-looking first
    tpr = np.concatenate([[0], np.cumsum(pu[o])])
    fpr = np.concatenate([[0], np.cumsum(pc[o])])
    auc = np.sum((fpr[1:] - fpr[:-1]) * (tpr[1:] + tpr[:-1]) / 2)
    b = np.max(tpr - k * fpr)
    return auc, b


viol, ntest = 0, 20000
tight_lo, tight_hi = [], []
for _ in range(ntest):
    m = rng.integers(2, 8)
    pu = rng.dirichlet(np.ones(m) * rng.uniform(0.2, 3))
    pc = rng.dirichlet(np.ones(m) * rng.uniform(0.2, 3))
    pu, pc = np.clip(pu, 1e-12, None), np.clip(pc, 1e-12, None)
    auc, b = roc_stats(pu / pu.sum(), pc / pc.sum())
    if auc < 0.5:
        continue
    lo = max(0.0, 1 - np.sqrt(2 * k * (1 - auc)))
    hi = 2 * auc - 1
    if b < lo - 1e-9 or b > hi + 1e-9:
        viol += 1
    tight_lo.append(b - lo)
    tight_hi.append(hi - b)
P(f"CHECK | random discrete signals ({ntest} draws, AUC >= 0.5): violations of the envelope: {viol}")
P(f"      smallest gap to the lower bound {min(tight_lo):.2e}, to the upper bound {min(tight_hi):.2e}")

# attainment: lower bound by ROC min(1, b + k x) (atom of certainly-unchecked real episodes + LR = k region);
# upper bound by ROC jump to b at FPR 0 then linear to (1,1)
for auc in (0.8,):
    blo = 1 - np.sqrt(2 * k * (1 - auc))
    x0 = (1 - blo) / k
    # signal: atom u0 (P_u = blo, P_c = 0); region u1 (P_u = 1 - blo, P_c = x0); region u2 (P_u = 0, P_c = 1 - x0)
    pu = np.array([blo, 1 - blo, 1e-15]); pc = np.array([1e-15, x0, 1 - x0])
    a1, b1 = roc_stats(pu, pc)
    bhi = 2 * auc - 1
    # signal: atom (P_u = bhi, P_c = 0); region (P_u = 1-bhi, P_c = 1) -> ROC linear from (0,bhi) to (1,1)
    pu = np.array([bhi, 1 - bhi]); pc = np.array([1e-15, 1.0])
    a2, b2 = roc_stats(pu, pc)
    P(f"CHECK | attainment at AUC 0.8: lower-bound signal AUC {a1:.4f}, b {b1:.4f} (bound {blo:.4f}); "
      f"upper-bound signal AUC {a2:.4f}, b {b2:.4f} (bound {bhi:.4f})")

P("")
P("   Example 4 (D*_k/(w lambar) = phi_k t* + (1 - phi_k) g(AUC_k)); growth factor D*_5/D*_0:")
sched = [(0.6, 0.0), (0.7, 0.02), (0.8, 0.05), (0.9, 0.1), (0.95, 0.15), (0.99, 0.2)]
rows = []
for kk, (auc, phi0) in enumerate(sched):
    lo, hi = env(auc)
    g = gauss_Dstar_norm(auc)
    rows.append([phi0 * ts + (1 - phi0) * x for x in (lo, g, hi)])
    P(f"   k={kk} AUC={auc:.2f} phi={phi0:.2f}: lower {rows[-1][0]*w*lb:.2e}, Gaussian {rows[-1][1]*w*lb:.2e}, "
      f"upper {rows[-1][2]*w*lb:.2e} nats/episode")
gf = lambda a, b: (b / a) if a > 0 else np.inf
P(f"   growth D*_5/D*_0: Gaussian {gf(rows[0][1], rows[5][1]):.1f}x; "
  f"from the upper-D* signal at k=0 to the lower-D* signal at k=5 {gf(rows[0][2], rows[5][0]):.1f}x; "
  f"lower-D* signal at k=0 gives D*_0 = 0 (growth unbounded)")

# ---------------------------------------------------------------- E2
P("")
P("=" * 78)
P("E2. Per-type mean-field ratio R_t(n) = n pi_t (E l_t)^2 / Var l_t (and n pi_t (E l)^2 / E l^2)")
P("=" * 78)
P("   Example 1, AUC 0.8, per-episode (D), lambda = (0.1, 0.4); pi_t = w H(t) decisive events per episode")
d = np.sqrt(2) * norm.ppf(0.8)


def type_moments(t):
    z = (logit(t) - logit(pbar) + d * d / 2) / d
    Pu = (1 - pbar) * norm.cdf(z)        # P(phat < t, unchecked)
    Pc = pbar * norm.cdf(z - d)          # P(phat < t, checked)
    H = Pu + Pc
    El = (Pu * lp - Pc * lm) / H
    El2 = (Pu * lp ** 2 + Pc * lm ** 2) / H
    return H, El, El2 - El ** 2, El2


tgrid = np.array([1e-4, 1e-3, 0.01, 0.05, 0.1, 0.2, 0.3, 0.4, 0.48, 0.6, 0.9])
for n in (6083, 10000):
    P(f"   n = {n}:")
    for t in tgrid:
        H, El, V, El2 = type_moments(t)
        R = n * w * H * El ** 2 / V
        R2 = n * w * H * El ** 2 / El2
        P(f"     t = {t:<7g} n pi_t = {n*w*H:8.2f}  E l = {El:+.4f}  R_t = {R:9.3f}  (with E l^2: {R2:8.3f})")
# prior mass (within the gamer continuum, uniform on (0,1]) of types with R_t < 1 at n = 1e4
tt = np.linspace(1e-6, 1 - 1e-6, 200001)
H, El, V, El2 = type_moments(tt)
R = 1e4 * w * H * El ** 2 / V
P(f"   share of the gamer prior with R_t < 1 at n = 1e4: {np.mean(R < 1):.3f}  "
  f"(low tail t < {tt[np.argmax(R >= 1)]:.4f} and a band around the mesh t0 = 0.48 where E l_t = 0)")

P("")
P("   Sieve scenario 2 (sim/README.md section 5): feature logit(0.03) + 0.5 N(0,1); every opportunity decisive;")
P("   P+ = 0.43, P- = 0.57, (B) lambda = Lambda = 4.595 per event.  Type t (threshold on the raw feature):")
Pp = 0.4 + 0.6 * 0.05
Pm = 1 - Pp
mean_step = Pp - Pm
var_step = 1 - mean_step ** 2
for n in (1e3, 1e4, 1e6):
    P(f"   n = {n:.0e}: n pi_t for the threshold at the j-th smallest feature value is about j; "
      f"R_t = j (E s)^2/Var s = j x {mean_step**2/var_step:.4f}, so R_t >= 1 needs j >= {var_step/mean_step**2:.0f} "
      f"(threshold above the {var_step/mean_step**2/n:.1e} quantile of the feature)")
P("   The band of types with R_t < 1 always exists, and its prior mass falls only like the spacing of the")
P("   low order statistics, ~ 0.5/sqrt(2 ln n) in logit units, i.e. logarithmically in n.")

# ---------------------------------------------------------------- E3
P("")
P("=" * 78)
P("E3. Capture law P(capture) ~ (P+/P-)^ceil(x/lambda); Lundberg form for asymmetric steps")
P("=" * 78)
MU_A = 0.5
g = (1 - MU_A) / 16 * 0.5 / np.sqrt(2 * np.log(1e4))
x = np.log(MU_A / g)
r = Pp / Pm
P(f"   scenario 2: P+/P- = {r:.4f}, g = {g:.5f} (n = 1e4), x = ln(mu0(A)/g) = {x:.3f}")
sim = {4.595: (0.563, 0.543), 3.920: (0.498, 0.497), 1.960: (0.348, 0.312), 0.980: (0.160, 0.110),
       0.490: (0.042, 0.030), 0.245: (0.003, 0.000)}
for lam_, (s3, s4) in sim.items():
    kk = int(np.ceil(x / lam_))
    P(f"   lambda = {lam_:.3f}: ceil(x/lambda) = {kk:2d}, predicted {r**kk:.3f}; simulated (R12) n=1e3 {s3:.3f}, n=1e4 {s4:.3f}")

# exact maximum law for the +-1 walk
Pw = 0.43
Mmax = []
for _ in range(20000):
    s = np.cumsum(np.where(rng.random(400) < Pw, 1, -1))
    Mmax.append(max(0, s.max()))
Mmax = np.array(Mmax)
for kk in (1, 2, 3, 5):
    P(f"CHECK | +-1 walk, P+ = 0.43: P(M >= {kk}) predicted {r**kk:.4f}, Monte Carlo {np.mean(Mmax >= kk):.4f}")

# asymmetric steps: +lambda_+ w.p. P+, -lambda_- w.p. P-; Lundberg exponent theta*: P+ e^{theta lp} + P- e^{-theta lm} = 1
P("   Asymmetric steps (T2's (D) example lambda = (0.1, 0.4)), pooled audits at pbar = 0.3 > t* = 0.2:")
Pp2, Pm2 = 0.7, 0.3
f = lambda th: Pp2 * np.exp(th * lp) + Pm2 * np.exp(-th * lm) - 1
th = brentq(f, 1e-6, 100)
P(f"   drift per event {Pp2*lp - Pm2*lm:+.3f} nats; Lundberg exponent theta* = {th:.4f} per nat")
Ma = []                                      # integer lattice: steps +1 / -4 in units of 0.1 nat
for _ in range(10):
    st = np.where(rng.random((10000, 3000)) < Pp2, 1, -4).astype(np.int32)
    Ma.append(np.maximum(0, np.cumsum(st, axis=1).max(axis=1)))
Ma = np.concatenate(Ma)
for y in (1.0, 2.0, 3.0, 4.0):
    P(f"CHECK | P(M > {y}) Monte Carlo {np.mean(Ma > round(10*y)):.5f} (100000 walks); "
      f"Lundberg bound exp(-theta* y) = {np.exp(-th*y):.5f}")
P("   (the bound is rigorous; the ratio MC/bound is the Cramer constant, roughly constant in y)")

# ---------------------------------------------------------------- E4
P("")
P("=" * 78)
P("E4. Example 1 headline (AUC 0.8, P_on at n = 1e4 under S4d) under other priors and recognition signals")
P("=" * 78)


def Dnorm_g(t):
    z = (logit(np.clip(t, 1e-300, 1 - 1e-16)) - logit(pbar) + d * d / 2) / d
    return (1 - pbar) * ts * norm.cdf(z) - pbar * (1 - ts) * norm.cdf(z - d)


def pon(n, dens, scale=1.0):
    tg = np.linspace(1e-6, 1, 20001)
    m = dens(tg)
    m = m / np.trapezoid(m, tg)
    logw = n * w * lb * Dnorm_g(tg) * scale
    mx = max(logw.max(), 0)
    tot = alpha * np.exp(-mx) + (1 - alpha) * np.trapezoid(m * np.exp(logw - mx), tg)
    return alpha * np.exp(-mx) / tot


for lab, dens in (("uniform on (0,1] (Example 1)", lambda t: np.ones_like(t)),
                  ("uniform on [0.5, 1] (no mass near t*)", lambda t: (t >= 0.5).astype(float)),
                  ("density proportional to t^4 (little mass near t*)", lambda t: t ** 4),
                  ("density proportional to (1-t)^4 (mass near A)", lambda t: (1 - t) ** 4)):
    P(f"   prior {lab:48s}: P_on(1e3) {pon(1e3, dens):.3f}  P_on(1e4) {pon(1e4, dens):.3f}  P_on(1e5) {pon(1e5, dens):.3f}")
lo, hi = env(0.8)
gg = gauss_Dstar_norm(0.8)
P(f"   uniform prior, drift field rescaled to the envelope's D* (shape kept Gaussian): "
  f"lower {pon(1e4, lambda t: np.ones_like(t), lo/gg):.3f}, upper {pon(1e4, lambda t: np.ones_like(t), hi/gg):.3f} at n = 1e4")

with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write("\n".join(out) + "\n")
