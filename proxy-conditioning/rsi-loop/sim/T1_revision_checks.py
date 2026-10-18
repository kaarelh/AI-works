"""Checks for the revision of drafts/T1-ledger.md (response to T1-ledger-referee.md).

Notation as in T1.  Worked example ("honeypot example"): eps_h = 0.01, Delta_eps = 0.05,
a = 0.03, h = 1, s = 0.5, delta = 0.01, operator (B), n = 500 episodes per generation.
Run: python3 T1_revision_checks.py   (about a minute; seeds fixed)
"""
import numpy as np
from scipy.optimize import brentq
from scipy.stats import norm, skellam, poisson
from scipy.integrate import quad

rng = np.random.default_rng(1)
out = []


def say(*a):
    s = " ".join(str(x) for x in a)
    print(s)
    out.append(s)


def check(name, pred, sim, tol):
    ok = abs(pred - sim) <= tol
    say(f"CHECK {name}: predicted {pred:.6g}, computed {sim:.6g}  -> {'OK' if ok else 'MISMATCH'}")
    return ok


sig = lambda x: 1 / (1 + np.exp(-np.clip(x, -700, 700)))
delta = 0.01
Lam = np.log((1 - delta) / delta)
a0, s0, eh, de, n = 0.03, 0.5, 0.01, 0.05, 500
uq = lambda q: a0 * (1 - q) * (1 - s0)
vq = lambda q: (1 - a0 * (1 - q)) * (eh + q * de)
Dq = lambda q: Lam * (vq(q) - uq(q))
qdag = brentq(lambda q: vq(q) - uq(q), 0, 1)
Ldag = np.log((1 - qdag) / qdag)
u0, v0 = uq(0), vq(0)
say(f"worked example: u0={u0:.5f} v0={v0:.5f} Lam={Lam:.4f} q_dag={qdag:.4f} L_dag={Ldag:.4f} "
    f"nD0={n*Dq(0):.3f} nD1={n*Dq(1):.2f}; honeypots per natural opportunity a/v0 = {a0/v0:.2f}")

# ---------------------------------------------------------------------------
say("=== 1. T1.6: end-of-generation tipping (Skellam) and the ceiling edge case")
L0 = np.log(1e6)
# L_n = L0 - Lam (N_r - N_c); N_r ~ Pois(n v0), N_c ~ Pois(n u0)
k0 = int(np.floor(L0 / Lam)) + 1            # smallest k with L0 - k Lam < 0
kdag = int(np.floor((L0 - Ldag) / Lam)) + 1  # smallest k with L0 - k Lam < L_dag
p_end0 = skellam.sf(k0 - 1, n * v0, n * u0)
p_enddag = skellam.sf(kdag - 1, n * v0, n * u0)
say(f"     k0 = floor(L0/Lam)+1 = {k0}; ever-flip (v/u)^k0 = {(v0/u0)**k0:.4f}")
say(f"     P(L_n < 0) at n={n}: {p_end0:.4f};  P(L_n < L_dag) (k={kdag}): {p_enddag:.4f}")
# Monte Carlo
Nr = rng.poisson(n * v0, 400000); Nc = rng.poisson(n * u0, 400000)
check("P(L_n<0) Skellam vs MC", p_end0, np.mean(L0 - Lam * (Nr - Nc) < 0), 0.002)
check("P(L_n<L_dag) Skellam vs MC", p_enddag, np.mean(L0 - Lam * (Nr - Nc) < Ldag), 0.002)
# Bernstein vs Hoeffding: deviation of L_n - L0 from its mean n|D0|, n = 500
var1 = Lam**2 * (u0 + v0) - Dq(0)**2
S = -Lam * (Nr - Nc)
for x in [30.0, 40.0, 60.0]:
    hoef = 2 * np.exp(-2 * x**2 / (n * (2 * Lam)**2))
    bern = 2 * np.exp(-x**2 / (2 * (n * var1 + Lam * x / 3)))
    emp = np.mean(np.abs(S - n * Lam * (u0 - v0)) >= x)
    say(f"     |L_n - E L_n| >= {x} nats at n={n}: Hoeffding bound {min(hoef,1):.3g}, Bernstein bound {min(bern,1):.3g}, "
        f"Monte Carlo {emp:.3g}")

# ---------------------------------------------------------------------------
say("=== 2. M2: stochastic regimes with Poisson counts (annealed q = sigma(-L))")


def run(L_init, regime, Lb=3.0, eta=0.5, nn=n, K=50, R=20000, gamma=0.0, kappa=0.0, Lfail=-20.0,
        best_resp=False):
    L = np.full(R, float(L_init))
    Lbk = np.full(R, float(Lb))
    dead = np.zeros(R, bool)
    frac = {}
    for k in range(1, K + 1):
        q = sig(-L)
        u, v = uq(q), vq(q)
        if best_resp:  # best responder games only where it pays: on the homogeneous model iff v>u
            games = v > u
            u = np.where(games, u, 0.0); v = np.where(games, v, 0.0)
        step = Lam * (rng.poisson(nn * u) - rng.poisson(nn * v))
        if regime == "i":
            L = L + step
        else:
            Lbk = Lbk + gamma * (1 - q) - kappa
            L = (1 - eta) * Lbk + eta * L + step
        dead |= L < Lfail
        if k in (1, 5, 10, 20, 50, 100, 200):
            frac[k] = dead.mean()
    return frac


cases = [("ii, Lb=3, eta=0.5, from 27.35, n=500", dict(L_init=27.354, regime="ii", Lb=3.0)),
         ("ii, Lb=10, eta=0.5, from L_A, n=500", dict(L_init=10 + 2 * 12.18, regime="ii", Lb=10.0)),
         ("i, L0=ln 1e6, n=500", dict(L_init=np.log(1e6), regime="i")),
         ("ii, Lb=3, eta=0.5, n=5000", dict(L_init=3 + 2 * 121.8, regime="ii", Lb=3.0, nn=5000))]
for name, kw in cases:
    fr = run(**kw)
    say(f"     P(collapse to L<-20) by generation {sorted(fr)}: {[round(float(fr[k]), 4) for k in sorted(fr)]}   [{name}]")

# Gaussian SNR estimate for the regime (ii) fixed point
for (Lb, eta, nn) in [(3.0, 0.5, 500), (10.0, 0.5, 500), (3.0, 0.5, 5000), (3.0, 0.9, 500), (3.0, 0.0, 500)]:
    w0 = u0 + v0
    LA = Lb + nn * Lam * (u0 - v0) / (1 - eta)
    sd = Lam * np.sqrt(nn * w0 / (1 - eta**2))
    z = (LA - Ldag) / sd
    say(f"     Lb={Lb} eta={eta} n={nn}: L_A={LA:.2f}, sd_inf={sd:.2f}, z={z:.3f}, Phi(-z)={norm.cdf(-z):.4f}, "
        f"n(u-v)^2/(u+v)={nn*(u0-v0)**2/w0:.2f}")

# empirical per-generation hazard in the stationary phase, Lb=3, eta=0.5
R = 40000
L = np.full(R, 27.354); alive_hist = []
dead = np.zeros(R, bool)
for k in range(1, 61):
    q = sig(-L)
    L = 0.5 * 3.0 + 0.5 * L + Lam * (rng.poisson(n * uq(q)) - rng.poisson(n * vq(q)))
    dead |= L < -20
    alive_hist.append(1 - dead.mean())
alive_hist = np.array(alive_hist)
haz = 1 - alive_hist[29] / alive_hist[19]
say(f"     empirical hazard per generation (gens 20-30), Lb=3, eta=0.5, n=500: {1-(1-haz)**0.1:.4f}")

# ---------------------------------------------------------------------------
say("=== 3. M1: quenched builders (each generation one realised disposition)")
# All-A history: L_k = L0 + k n |D0|. Generation k is G w.p. sigma(-L_k); G is absorbing (D(1)=+138/gen).


def quenched_pf(L0, K=200):
    Ls = L0 + np.arange(K) * n * abs(Dq(0))
    return 1 - np.prod(1 - sig(-Ls))


def quenched_mc(L0, K=60, R=200000):
    L = np.full(R, float(L0)); failed = np.zeros(R, bool)
    for k in range(K):
        isG = rng.random(R) < sig(-L)
        failed |= isG
        L = np.where(failed, L - n * Dq(1), L - n * Dq(0))
    return failed.mean()


for L0q in [1.0, 2.0, 2.4, 3.0, np.log(1e6)]:
    pa = quenched_pf(L0q)
    approx = sig(-L0q) / (1 - np.exp(-n * abs(Dq(0))))
    pm = quenched_mc(L0q)
    annealed = "collapse" if L0q < Ldag else "survives"
    say(f"     L0={L0q:.2f}: annealed map -> {annealed}; quenched P(fail) analytic {pa:.4f}, "
        f"approx sigma(-L0)/(1-e^-n|D0|) {approx:.4f}, MC {pm:.4f}")

# ---------------------------------------------------------------------------
say("=== 4. M3: binormal ROC recognition; best-responder drift (B), honeypot example")
ah, v = a0 * 1.0, v0


def drift_binormal(auc, lp=Lam, lm=Lam):
    dp = np.sqrt(2) * norm.ppf(auc)
    f = lambda z: max(v * norm.pdf(z) * lp - ah * norm.pdf(z - dp) * lm, 0.0)
    return quad(f, -12, 12 + dp, limit=400)[0]


for auc in [0.55, 0.60, 0.70, 0.83, 0.90, 0.95]:
    say(f"     AUC {auc:.2f}: G* drift = {drift_binormal(auc):+.6f} nats/episode "
        f"(homogeneous s=0.5 naive G: {Lam*(v0-u0):+.4f}; homogeneous G*: 0)")
# a bounded-LR design: audits generated from real opportunities so f_a >= c f_r everywhere
for c in [0.2, 0.5, 1.0]:
    # mixture design: audit features = c' * real + (1-c') * binormal-shifted, with c' = c
    dp = np.sqrt(2) * norm.ppf(0.83)
    f = lambda z: max(v * norm.pdf(z) * Lam - ah * (c * norm.pdf(z) + (1 - c) * norm.pdf(z - dp)) * Lam, 0.0)
    D = quad(f, -12, 14, limit=400)[0]
    say(f"     audits are a mixture: fraction {c} drawn from the real-opportunity distribution, rest AUC-0.83 "
        f"shifted: inf LR = {ah*c/v:.3f} (need >= t*/(1-t*) = 1), G* drift = {D:+.6f}")

# ---------------------------------------------------------------------------
say("=== 5. T1.7: random audits, D not monotone in q (single sign change suffices)")
lp = lm = 1.0; a_, s_, eh_, de_ = 0.75, 0.0, 0.001, 0.1
b = a_ * (lp + (1 - s_) * lm)
Dr = lambda q: (eh_ + q * de_) * (lp - b * (1 - q))
vals = [Dr(q) for q in [0, 0.1, 0.2, 0.3, 0.4]]
say(f"     D at q=0,.1,.2,.3,.4: {[round(x, 5) for x in vals]}; q_dag = 1 - lp/b = {1-lp/b:.4f}")

# ---------------------------------------------------------------------------
say("=== 6. T1.11: collusion correction to the time to failure")
L0 = np.log(1e6); nD0, nD1 = 0.5, 5.0
c = nD0 + nD1
T = L0 / c + (nD1 / (c * nD0)) * np.log((c + nD0 * np.exp(L0)) / (c + nD0))
corr_exact = T - L0 / nD0
corr_formula = (nD1 / c) * np.log(nD0 / (2 * nD0 + nD1)) / nD0
say(f"     T = {T:.3f}; L0/(nD0) = {L0/nD0:.3f}; correction {corr_exact:.3f}; "
    f"(D1/(D0+D1)) ln(D0/(2D0+D1))/(nD0) = {corr_formula:.3f}; -ln(D1/D0)/(nD0) = {-np.log(nD1/nD0)/nD0:.3f}")
# random audits, eps_h = 0: D0 = 0 and D1 = Delta_eps (lp - b)
a_, s_ = 0.1, 0.5
for lp_ in [0.05, 1.0]:
    b = a_ * (lp_ + (1 - s_) * 1.0)
    say(f"     random audits, eps_h=0, lp={lp_}, lm=1, a={a_}, s={s_}: D1/Delta_eps = lp - b = {lp_-b:+.3f} "
        f"({'audits adequate: D1<0' if lp_ < b else 'audits inadequate: D1>0'})")

# ---------------------------------------------------------------------------
say("=== 7. T1.10: regime (ii) with D(0)>0, exact fixed point vs L_b - nD(0)/(1-eta)")
eh2 = (u0 + 0.002 / Lam) / (1 - a0)   # chosen so that D(0) = +0.002 nats/episode, nD(0) = 1
D2 = lambda q: Lam * ((1 - a0 * (1 - q)) * (eh2 + q * de) - a0 * (1 - q) * (1 - s0))
for (Lb, eta) in [(3.0, 0.5), (5.0, 0.5), (8.0, 0.5), (12.0, 0.5)]:
    nD0_ = n * D2(0)
    Fm = lambda L: (1 - eta) * Lb + eta * L - n * D2(sig(-L))
    grid = np.linspace(-400, 60, 46001)
    g = np.array([Fm(x) - x for x in grid])
    roots = [brentq(lambda x: Fm(x) - x, grid[i], grid[i + 1]) for i in np.where(np.diff(np.sign(g)) != 0)[0]]
    say(f"     eps_h={eh2:.5f} (nD(0)={nD0_:.2f}) Lb={Lb} eta={eta}: approx condition nD(0)<(1-eta)Lb: "
        f"{nD0_ < (1-eta)*Lb}; approx FP {Lb - nD0_/(1-eta):.2f}; exact fixed points {[round(r, 2) for r in roots]}")

# ---------------------------------------------------------------------------
say("=== 8. T1.1b: competence (slop) axis with unpredictable errors")
eu = 0.05
for dS in [0.02, 0.05, 0.1, 0.2]:
    dA = 0.01
    DB = (1 - eu) * np.log((1 - dS) / (1 - dA)) + eu * np.log(dS / dA)   # (B): drift of ln mu(S)/mu(A)
    DD = (dS - dA) * (2 * eu - 1)                                          # (D), per unit lambda
    say(f"     eps_u={eu}, delta_A=0.01, delta_S={dS}: (B) drift of ln mu(S)/mu(A) = {DB:+.4f}; "
        f"(D) drift x beta = {DD:+.4f}")
ds = np.linspace(1e-4, 0.5, 200001)
obj = (1 - eu) * np.log(1 - ds) + eu * np.log(ds)
check("argmax_delta of (B) log-likelihood equals eps_u", eu, ds[np.argmax(obj)], 1e-4)

# ---------------------------------------------------------------------------
say("=== 9. T1.2b: multiaccuracy bound on gaming drift")
# inputs x in {0..N-1}; error indicator e(x); tests c: X -> [0,1]; drift of a gaming rule c is
# (lp+lm) E[c(x)(e(x)-t*)].  If |E[c(e-eps_u)]| <= alpha for all c in class and eps_u <= t*, drift <= (lp+lm) alpha.
N = 2000
for trial in range(4):
    eps_u = rng.uniform(0.05, 0.3); tstar = rng.uniform(eps_u, 0.6); lp_, lm_ = rng.uniform(0.2, 3, 2)
    tstar = lp_ / (lp_ + lm_)
    if tstar < eps_u:
        lp_, lm_ = lm_, lp_; tstar = lp_ / (lp_ + lm_)
    e = (rng.random(N) < eps_u).astype(float)
    C = rng.random((300, N)) < rng.uniform(0.01, 0.5, (300, 1))       # class of 300 random tests
    alpha = np.max(np.abs(C @ (e - eps_u))) / N
    drifts = (lp_ + lm_) * (C @ (e - tstar)) / N
    say(f"     trial {trial}: eps_u={eps_u:.3f} t*={tstar:.3f} alpha={alpha:.4f}: max drift over class "
        f"{drifts.max():+.5f} <= bound {(lp_+lm_)*alpha:.5f}: {drifts.max() <= (lp_+lm_)*alpha + 1e-12}")

# ---------------------------------------------------------------------------
say("=== 10. M4: the frontier slice of training")
for (wF, epsF) in [(0.1, 0.05), (0.05, 0.2), (0.2, 0.1)]:
    vF = wF * epsF
    say(f"     frontier share w_F={wF}, frontier predictable-error rate eps_F={epsF}: G* gains "
        f"v_F Lam = {vF*Lam:.4f} nats/episode, {n*vF*Lam:.1f} per generation at n={n} "
        f"(restoring drift against naive G elsewhere: {n*Dq(0):.1f})")
# break-even retrospective sampling rate under (D) with penalty ratio
for ratio in [1, 9, 99]:
    say(f"     (D) with Delta_-/Delta_+ = {ratio}: t* = {1/(1+ratio):.3f}: consequential retrospective "
        f"detection on the frontier slice must be >= {1/(1+ratio):.3f}")

# ---------------------------------------------------------------------------
say("=== 11. M5: improvement channel (regime ii, best responders, annealed)")
# L_{b,k+1} = L_{b,k} + gamma (1-q_k) - kappa;  L_{k+1} = (1-eta) L_{b,k+1} + eta L_k + noise (best responder:
# no drift while v<u, so no noise either at the aligned end; noise only from the frontier slice).
for (gamma, kappa) in [(0.0, 0.0), (1.0, 0.5), (0.5, 1.0)]:
    qC = 1 - kappa / gamma if gamma > 0 else float("nan")
    say(f"     gamma={gamma}, kappa={kappa}: aligned-end ledger change per generation gamma-kappa = {gamma-kappa:+.2f}; "
        f"improvement separatrix q_C = 1-kappa/gamma = {qC:.3f}")
# stochastic: naive G, n=500, with and without improvement, P(collapse) by generation
for (gamma, kappa) in [(0.0, 0.0), (1.0, 0.0), (2.0, 0.5)]:
    fr = run(L_init=27.354, regime="ii", Lb=3.0, gamma=gamma, kappa=kappa, K=200, R=20000)
    say(f"     naive G, Lb0=3, eta=0.5, gamma={gamma}, kappa={kappa}: P(collapse) by gen "
        f"{sorted(fr)}: {[round(float(fr[k]), 4) for k in sorted(fr)]}")

open(__file__.replace(".py", "_output.txt"), "w").write("\n".join(out) + "\n")

# ---------------------------------------------------------------------------
say("=== 12. T1.10: sharper existence condition for an aligned fixed point when D(0) > 0")
# Linearise D(q) = D0 + D1 q and use q ~ e^{-L}: L + c1 e^{-L} = Lb - c0 with c0 = nD0/(1-eta), c1 = nD1/(1-eta).
# The left side has minimum 1 + ln c1 at L = ln c1, so an aligned fixed point exists iff Lb - c0 >= 1 + ln c1.
eh2 = (u0 + 0.002 / Lam) / (1 - a0)
D2 = lambda q: Lam * ((1 - a0 * (1 - q)) * (eh2 + q * de) - a0 * (1 - q) * (1 - s0))
eta = 0.5
c0 = n * D2(0) / (1 - eta); c1 = n * (D2(1) - D2(0)) / (1 - eta)
pred_Lb = c0 + 1 + np.log(c1)


def has_aligned_fp(Lb):
    Fm = lambda L: (1 - eta) * Lb + eta * L - n * D2(sig(-L))
    grid = np.linspace(0, 60, 60001)
    g = np.array([Fm(x) - x for x in grid])
    return np.any(g > 0)


lo, hi = 2.0, 30.0
for _ in range(60):
    mid = (lo + hi) / 2
    lo, hi = (lo, mid) if has_aligned_fp(mid) else (mid, hi)
check("smallest Lb with an aligned fixed point vs c0 + 1 + ln c1", pred_Lb, hi, 0.1)
say(f"     c0 = {c0:.2f}, c1 = {c1:.1f}; the cruder condition nD(0) < (1-eta) Lb needs only Lb > {c0:.2f}")
open(__file__.replace(".py", "_output.txt"), "w").write("\n".join(out) + "\n")
