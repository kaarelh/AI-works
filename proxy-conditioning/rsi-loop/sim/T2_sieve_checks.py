"""Numerical checks for drafts/T2-sieve.md (proxy training as a sieve).

Model: opportunities arrive at rate w per episode.  An opportunity carries a
strong check with probability pbar (p in {0,1}); the student sees a signal z,
z ~ N(0,1) on unchecked and N(d,1) on checked opportunities (AUC = Phi(d/sqrt2)),
and forms the calibrated estimate phat(z) = P(checked | z).  C_t games iff
phat < t.  Gaming earns +lam_p nats (uncaught) or -lam_m nats (caught).
tstar = lam_p/(lam_p+lam_m).  D(t) = w*(lam_p+lam_m)*E[1{phat<t}(tstar-phat)].
"""
import numpy as np
from scipy.stats import norm
from scipy.optimize import brentq
from scipy.special import expit, logit

rng = np.random.default_rng(0)


def zt(t, pbar, d):
    return (logit(t) - logit(pbar) + d * d / 2) / d


def Dnorm(t, pbar, d, tstar, phi0=0.0):
    """D(t)/(w*lambar).  phi0 = share of opportunities known to be unchecked
    (phat = 0); the remaining 1-phi0 follow the Gaussian audit model."""
    t = np.asarray(t, float)
    if d == 0:
        g = np.where(pbar < t, tstar - pbar, 0.0)
    else:
        z = zt(np.clip(t, 1e-300, 1 - 1e-16), pbar, d)
        g = (1 - pbar) * tstar * norm.cdf(z) - pbar * (1 - tstar) * norm.cdf(z - d)
        g = np.where(t >= 1, (1 - pbar) * tstar - pbar * (1 - tstar), g)
    return phi0 * tstar * (t > 0) + (1 - phi0) * g


def mesh(pbar, d, tstar, phi0=0.0):
    f = lambda t: Dnorm(t, pbar, d, tstar, phi0)
    if f(1.0) >= 0:
        return 1.0
    return brentq(f, tstar, 1 - 1e-12)


def posterior_on(n, wl, pbar, d, tstar, alpha, phi0=0.0, prior="uniform", dF=0.0):
    """Frontier on-task rate = posterior mass on t <= dF (A is an atom at 0)."""
    ts = np.linspace(1e-6, 1, 20001)
    m = np.ones_like(ts) if prior == "uniform" else prior(ts)
    m = m / np.trapezoid(m, ts)
    logw = n * wl * Dnorm(ts, pbar, d, tstar, phi0)
    mx = max(logw.max(), 0)
    wts = m * np.exp(logw - mx)
    on = alpha * np.exp(-mx) + (1 - alpha) * np.trapezoid(np.where(ts <= dF, wts, 0), ts)
    tot = alpha * np.exp(-mx) + (1 - alpha) * np.trapezoid(wts, ts)
    return on / tot


def auc2d(auc):
    return np.sqrt(2) * norm.ppf(auc)


out = []
P = lambda *a: out.append(" ".join(str(x) for x in a))

# ---------------------------------------------------------------- Example 1
P("== Example 1: one generation, Gaussian recognition ==")
w, lp, lm = 0.05, 0.1, 0.4
tstar, lb = lp / (lp + lm), lp + lm
pbar, alpha = 0.3, 0.99
P(f"w={w} lam+={lp} lam-={lm} t*={tstar} pbar={pbar} alpha={alpha}")
P("AUC   d     D*/(w lb)  D*(nats/ep)  D(1)/(w lb)  mesh t0   n_flip~ln(O)/D*   P_on(n=1e3,1e4,1e5)")
for auc in [0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99]:
    d = auc2d(auc)
    ds = float(Dnorm(tstar, pbar, d, tstar)) if d > 0 else max(tstar - pbar, 0)
    d1 = float(Dnorm(1.0, pbar, d, tstar))
    t0 = mesh(pbar, d, tstar) if d > 0 else pbar
    Dst = w * lb * ds
    nf = np.log(alpha / (1 - alpha)) / Dst if Dst > 0 else np.inf
    pons = [posterior_on(n, w * lb, pbar, d, tstar, alpha) for n in (1e3, 1e4, 1e5)]
    P(f"{auc:.2f}  {d:.3f}  {ds:.4f}    {Dst:.2e}    {d1:+.4f}     {t0:.3f}    {nf:9.0f}        "
      + "  ".join(f"{x:.3f}" for x in pons))

# Monte Carlo check of D(t) under (B)-like sampled increments
P("\nMonte Carlo check of D(t)/(w lb) at AUC 0.8 (2e6 opportunities)")
d = auc2d(0.8)
N = 2_000_000
chk = rng.random(N) < pbar
z = rng.normal(0, 1, N) + d * chk
ph = expit(logit(pbar) + d * z - d * d / 2)
for t in [0.05, 0.1, 0.2, 0.3, 0.5, 0.8, 1.0]:
    game = ph < t
    inc = np.where(chk, -lm, lp) * game
    P(f"  t={t:.2f}  MC={inc.mean()/lb:+.5f}  formula={float(Dnorm(t, pbar, d, tstar)):+.5f}")

# calibration check
P("  calibration: E[p | phat in bin] vs bin centre:",
  [(round(c, 2), round(chk[(ph > c - .02) & (ph < c + .02)].mean(), 3)) for c in (0.1, 0.3, 0.6)])

# ---------------------------------------------------------------- pooling / cap identity
P("\n== Cap identity: D*/(w lb) = t* - E[min(phat,t*)] ; wasted audit mass E[(phat-t*)^+] ==")
for auc in [0.5, 0.7, 0.8, 0.9, 0.99]:
    d = auc2d(auc)
    if d == 0:
        P(f"AUC {auc}: effective={min(pbar,tstar):.4f} wasted={max(pbar-tstar,0):.4f}")
        continue
    z0 = rng.normal(0, 1, N) + d * chk
    ph = expit(logit(pbar) + d * z0 - d * d / 2)
    eff = np.minimum(ph, tstar).mean()
    P(f"AUC {auc}: E[min(phat,t*)]={eff:.4f}  wasted={np.maximum(ph-tstar,0).mean():.4f}  "
      f"t*-eff={tstar-eff:.4f}  formula D*={float(Dnorm(tstar,pbar,d,tstar)):.4f}")

# ---------------------------------------------------------------- heavy penalty limit
P("\n== Heavy penalties: lam+ fixed=0.1, lam- -> infinity; D* -> w lam+ P(phat=0) ==")
for phi0 in [0.0, 0.1]:
    for lmx in [0.4, 1.6, 6.4, 25.6, 102.4]:
        ts_ = lp / (lp + lmx)
        row = []
        for auc in [0.8, 0.95]:
            d = auc2d(auc)
            row.append(w * (lp + lmx) * float(Dnorm(ts_, pbar, d, ts_, phi0)))
        P(f"phi0={phi0} lam-={lmx:6.1f} t*={ts_:.4f}  D*(AUC .8)={row[0]:.2e}  D*(AUC .95)={row[1]:.2e}  "
          f"limit w lam+ phi0={w*lp*phi0:.2e}")

# ---------------------------------------------------------------- Example 2: bounded LR (privacy)
P("\n== Example 2: randomized-response recognition with privacy loss xi ==")
P(f"pbar={pbar}, t*={tstar}; xi* = logit(pbar)-logit(t*) = {logit(pbar)-logit(tstar):.3f}")
for xi in [0.25, 0.5, logit(pbar) - logit(tstar), 0.75, 1.0, 1.5, 2.0, 3.0]:
    q = expit(xi)  # P(looks unchecked | unchecked) = q ; P(looks unchecked | checked) = 1-q
    plo = pbar * (1 - q) / (pbar * (1 - q) + (1 - pbar) * q)
    phi = pbar * q / (pbar * q + (1 - pbar) * (1 - q))
    Plo = pbar * (1 - q) + (1 - pbar) * q
    auc = 0.5 * (1 + (2 * q - 1))  # = q for a binary symmetric signal
    Ds = Plo * max(tstar - plo, 0)
    # matched Gaussian with same AUC
    dg = auc2d(auc)
    Dg = float(Dnorm(tstar, pbar, dg, tstar))
    P(f"xi={xi:.3f} AUC={auc:.3f} phat_lo={plo:.3f} phat_hi={phi:.3f} D*/(w lb)={Ds:.4f}   Gaussian same AUC: {Dg:.4f}")

# ---------------------------------------------------------------- Operators: (B) has t*=1/2
P("\n== Operator (B): t*=1/2, Lambda=ln(99)=4.6 per event, pbar=0.3, AUC 0.8 ==")
Lam = np.log(99)
d = auc2d(0.8)
for t in [0.1, 0.3, 0.5, 0.7, 0.9, 1.0]:
    P(f"  t={t}: D/(w*2Lam) = {float(Dnorm(t, pbar, d, 0.5)):+.4f}")
P(f"  mesh t0 = {mesh(pbar, d, 0.5)}  (no type removed if 1.0)")

# ---------------------------------------------------------------- Example 3: tells
P("\n== Example 3: tells ==")
alpha0 = 0.99
kA = 0.02
for name, kap in [("flat kappa=0.5", lambda t: 0.5 * np.ones_like(t)),
                  ("reckless-only kappa=t", lambda t: t),
                  ("careful-heavy kappa=1-t", lambda t: 1 - t),
                  ("concealer mix: 0.3 none, else 3 indep tells at .5", lambda t: (0.7 * (1 - 0.5**3)) * np.ones_like(t))]:
    for n in [0, 1e4, 1e5]:
        d = auc2d(0.8)
        ts = np.linspace(1e-6, 1, 20001)
        logw = n * w * lb * Dnorm(ts, pbar, d, tstar)
        mx = max(logw.max(), 0)
        base = np.exp(logw - mx)
        noTell = (1 - kap(ts))
        Aw = alpha0 * np.exp(-mx)
        before = Aw / (Aw + (1 - alpha0) * np.trapezoid(base, ts))
        after = Aw * (1 - kA) / (Aw * (1 - kA) + (1 - alpha0) * np.trapezoid(base * noTell, ts))
        P(f"  {name:48s} n={n:8.0f}: P_on before tells={before:.4f}  after removing tell-carriers={after:.4f}  "
          f"log-odds gain={np.log(after/(1-after))-np.log(before/(1-before)):.3f}")

# ---------------------------------------------------------------- Example 4: generations
P("\n== Example 4: generations; recognition rises, certainly-unchecked share rises ==")
alpha0 = 0.99
nper = 3000
target = 2e-4
ts = np.linspace(1e-6, 1, 20001)
S = np.zeros_like(ts)
P(f"n per generation = {nper}; prior mu(A)={alpha0}, gamers uniform on t; d_F = 0")
P("k  AUC_k  phi_k  D*_k(nats/ep)  mesh_k  D(1)_k     P_on(continued)  P_on(fresh)  lam- needed for D*<=2e-4")
for k, (auc, phi0) in enumerate([(0.6, 0.0), (0.7, 0.02), (0.8, 0.05), (0.9, 0.1), (0.95, 0.15), (0.99, 0.2)]):
    d = auc2d(auc)
    Dk = w * lb * Dnorm(ts, pbar, d, tstar, phi0)
    S += nper * Dk
    mx = max(S.max(), 0)
    on = alpha0 * np.exp(-mx) / (alpha0 * np.exp(-mx) + (1 - alpha0) * np.trapezoid(np.exp(S - mx), ts))
    mxf = max((nper * Dk).max(), 0)
    onf = alpha0 * np.exp(-mxf) / (alpha0 * np.exp(-mxf) + (1 - alpha0) * np.trapezoid(np.exp(nper * Dk - mxf), ts))
    Dstar = lambda lmx: w * (lp + lmx) * float(Dnorm(lp / (lp + lmx), pbar, d, lp / (lp + lmx), phi0))
    if w * lp * phi0 >= target:
        need = "impossible (floor w lam+ phi = %.1e)" % (w * lp * phi0)
    elif Dstar(lm) <= target:
        need = "%.2f (current)" % lm
    else:
        need = "%.1f" % brentq(lambda x: Dstar(x) - target, lm, 1e7)
    P(f"{k}  {auc:.2f}   {phi0:.2f}   {w*lb*float(Dnorm(tstar,pbar,d,tstar,phi0)):.2e}     "
      f"{mesh(pbar,d,tstar,phi0):.3f}   {float(Dnorm(1.0,pbar,d,tstar,phi0))*w*lb:+.2e}   {on:.4f}           {onf:.4f}       {need}")

# ---------------------------------------------------------------- Blackwell monotonicity
P("\n== Blackwell: D*/(w lb) increasing in d (t*=0.2, pbar=0.3) ==")
P("  " + "  ".join(f"d={d:.1f}:{float(Dnorm(tstar,pbar,d,tstar)):.4f}" for d in [0.01, 0.5, 1, 1.5, 2, 3, 4, 6]))
P(f"  limit (1-pbar) t* = {(1-pbar)*tstar:.4f}")


# ---------------------------------------------------------------- Laplace approximation
P("\n== Laplace approximation of P_on(n) (Example 1, AUC 0.8) ==")
d = auc2d(0.8)
zs = zt(tstar, pbar, d)
h = ((1 - pbar) * norm.pdf(zs) + pbar * norm.pdf(zs - d)) / (d * tstar * (1 - tstar))
Ds = w * lb * float(Dnorm(tstar, pbar, d, tstar))
P(f"  h(t*)={h:.4f}  D*={Ds:.3e}")
for n in [3e3, 5e3, 1e4, 2e4]:
    lap = 1 / (1 + (1 - alpha) / alpha * np.sqrt(2 * np.pi / (n * w * lb * h)) * np.exp(n * Ds))
    P(f"  n={n:.0e}: exact={posterior_on(n, w*lb, pbar, d, tstar, alpha):.4f}  Laplace={lap:.4f}")

# ---------------------------------------------------------------- pooled audits: frontier sufficiency
P("\n== Pooled (zero-information) audits: frozen band [0,pbar], removal of t>pbar ==")
for pb, pF in [(0.25, 0.0), (0.25, 0.25), (0.25, 0.3)]:
    for n in [1e4, 1e5]:
        on = posterior_on(n, w * lb, pb, 0, tstar, alpha, dF=pF)
        P(f"  pbar_train={pb} pF_hat={pF} n={n:.0e}: P_on={on:.4f}")


# ---------------------------------------------------------------- caught rate of the best responder
P("\n== Caught-gaming rate of C_{t*} per episode, w*pbar*Phi(z_t* - d), and per 10^4 episodes ==")
for auc in [0.6, 0.7, 0.8, 0.9, 0.95, 0.99]:
    d = auc2d(auc)
    c = w * pbar * norm.cdf(zt(tstar, pbar, d) - d)
    g = w * (1 - pbar) * norm.cdf(zt(tstar, pbar, d))
    P(f"  AUC {auc}: caught/episode={c:.2e} ({c*1e4:.1f} per 1e4)  rewarded gaming/episode={g:.2e}  caught share={c/(c+g):.3f}")
open("/home/user/AI-works/proxy-conditioning/rsi-loop/sim/T2_sieve_checks_output.txt", "w").write("\n".join(out) + "\n")
print("\n".join(out))
