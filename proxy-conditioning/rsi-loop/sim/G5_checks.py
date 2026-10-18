#!/usr/bin/env python3
"""G5 checks: calibration of the toy's operators to real post-training algorithms,
the competence ("slop") loop, and parameter arithmetic.

Sections (cited in drafts/G5-calibration.md as K1..K10):
  K1  on-policy filtering (rejection-sampling FT, best-of-k): break-even under the
      gradient reading (policy-gradient identity) vs the Bayes reading (T1's C-on)
  K2  stochastic check of K1 with two persona logits (SGD) and with Bayes C-on
  K3  GRPO std-normalisation erases the penalty: break-even 1/2 for any penalty
  K4  time to flip vs prior odds O: plain PG ~ O, GRPO ~ sqrt(O) (population) /
      ~ O (finite group, p << 1/K), natural gradient ~ ln O; plus Adam (stochastic)
  K5  converged KL-regularised RL: output log-odds shift and the softness cap
  K6  DPO and IPO converged margins
  K7  softness selection under each operator (T1.1b revisited)
  K8  the slop loop: fixed point, runaway, coupling to the intent ledger
  K9  binormal recognition: lower tail of the likelihood ratio at measured AUCs
  K10 order-of-magnitude anchors for evidence per example
"""
import numpy as np
from scipy.optimize import brentq, minimize_scalar
from scipy.stats import norm, binom
from scipy.integrate import solve_ivp

rng = np.random.default_rng(20261018)
OUT = []
NCHECK = [0, 0]


def say(s=""):
    print(s)
    OUT.append(s)


def check(name, pred, sim, tol, rel=False):
    NCHECK[0] += 1
    err = abs(pred - sim) / (abs(pred) if rel else 1.0)
    ok = err <= tol
    if not ok:
        NCHECK[1] += 1
    say(f"  [{'ok' if ok else 'MISMATCH'}] {name}: predicted {pred:.6g}, computed {sim:.6g}")
    return ok


sig = lambda z: 1 / (1 + np.exp(-z))
logit = lambda p: np.log(p / (1 - p))

# ---------------------------------------------------------------- K1
say("K1. On-policy filtering: break-even under gradient vs Bayes readings")
say("    w_k(P) = (1-(1-P)^k)/P ; gradient t* = w_k(pX)/(w_k(pX)+w_k(1-pX))")
say("    Bayes (T1 C-on) t* = (1-(1-pX)^k)/((1-(1-pX)^k)+(1-pX^k))")


def wk(P, k):
    return (1 - (1 - P) ** k) / P


def tstar_grad(pX, k):
    return wk(pX, k) / (wk(pX, k) + wk(1 - pX, k))


def tstar_bayes(pX, k):
    a = 1 - (1 - pX) ** k
    b = 1 - pX ** k
    return a / (a + b)


say("    pX     k   t*_gradient   t*_Bayes")
for pX in [0.01, 0.1, 0.5]:
    for k in [1, 4, 8, 32]:
        say(f"    {pX:<5}  {k:<3} {tstar_grad(pX, k):.4f}        {tstar_bayes(pX, k):.4f}")


# Exact expected first-order update, one-logit model, by enumeration over k samples.
def expected_update_filter(pX, k, rewarded):
    # one logit z, P(X)=pX. Keep first passing sample, SFT step on it: grad log P(y).
    # rewarded opp: X passes; caught opp: I passes.
    pass_p = pX if rewarded else 1 - pX
    prob_keep = 1 - (1 - pass_p) ** k
    g = (1 - pX) if rewarded else (-pX)  # d/dz log P(kept)
    return prob_keep * g


for pX, k in [(0.01, 1), (0.01, 8), (0.2, 4)]:
    up = expected_update_filter(pX, k, True)
    dn = -expected_update_filter(pX, k, False)
    check(f"gradient t* by enumeration, pX={pX}, k={k}", tstar_grad(pX, k), up / (up + dn), 1e-12)
check("k=1 gradient t* is exactly 1/2 (pX=0.03)", 0.5, tstar_grad(0.03, 1), 1e-12)
check("k=1 Bayes t* equals pX (pX=0.03)", 0.03, tstar_bayes(0.03, 1), 1e-12)

# ---------------------------------------------------------------- K2
say()
say("K2. Stochastic check: two persona logits (A,G), softness delta, on-policy best-of-k")
say("    filtering with SGD on the logits (gradient reading) vs Bayes C-on, fixed p_hat")
delta = 0.01


def run_persona(phat, k, n, lr, L0, mode, seeds=40):
    finals = []
    for sd in range(seeds):
        r = np.random.default_rng(1000 + sd)
        om = np.array([L0, 0.0])  # logits of A, G -> ln mu(A)/mu(G) = L0
        for _ in range(n):
            q = np.exp(om - om.max()); q /= q.sum()
            piX = np.array([delta, 1 - delta])
            P = q @ piX
            caught = r.random() < phat
            kept = None
            for _j in range(k):
                y = 'X' if r.random() < P else 'I'
                passes = (y == 'X') != caught
                if passes:
                    kept = y
                    break
            if kept is None:
                continue
            piy = piX if kept == 'X' else 1 - piX
            Py = q @ piy
            if mode == 'grad':
                S = q * (piy - Py) / Py  # surprise = d log P(y) / d omega
                om = om + lr * S
            else:  # Bayes on the kept sample
                om = om + np.log(piy)
        finals.append(om[0] - om[1])
    return np.mean(finals) - L0


n, lr, L0 = 20000, 0.2, 3.0
for k in [1, 4]:
    tg = tstar_grad(delta + (1 - 2 * delta) * sig(-L0), k)
    say(f"    k={k}: gradient-reading t* at the start = {tg:.3f}")
    for phat in [tg - 0.12, tg + 0.12]:
        d = run_persona(phat, k, n, lr, L0, 'grad', seeds=20)
        say(f"      gradient: p_hat={phat:.3f}  mean change of L over {n} opps = {d:+.3f}")
        NCHECK[0] += 1
        ok = (d > 0) == (phat > tg)
        if not ok:
            NCHECK[1] += 1
        say(f"      [{'ok' if ok else 'MISMATCH'}] sign of drift as predicted by gradient t*")
pX0 = delta + (1 - 2 * delta) * sig(-L0)
for phat in [0.3, 0.6]:
    d = run_persona(phat, 1, 1500, lr, L0, 'bayes', seeds=20)
    say(f"    Bayes C-on k=1: p_hat={phat}: mean change of L = {d:+.2f} (Bayes t* = pX = {pX0:.3f}; both p_hat above it)")
    NCHECK[0] += 1
    ok = d > 0
    if not ok:
        NCHECK[1] += 1
    say(f"      [{'ok' if ok else 'MISMATCH'}] Bayes C-on restores (p_hat above its t*)")
d = run_persona(0.3, 1, n, lr, L0, 'grad', seeds=20)
say(f"    gradient k=1, p_hat=0.3: mean change of L = {d:+.3f} (the gradient reading leaks where Bayes C-on restores)")
NCHECK[0] += 1
if not d < 0: NCHECK[1] += 1
say(f"      [{'ok' if d<0 else 'MISMATCH'}] gradient reading leaks at p_hat=0.3")

# ---------------------------------------------------------------- K3
say()
say("K3. GRPO std-normalised advantages: break-even 1/2 whatever the penalty")


def grpo_expected(pX, K, rX, rI):
    # one-logit model; exact expectation over the number m of X in a group of K
    tot = 0.0
    for m in range(1, K):
        pm = binom.pmf(m, K, pX)
        rbar = (m * rX + (K - m) * rI) / K
        sd = abs(rX - rI) * np.sqrt(m * (K - m)) / K
        advX = (rX - rbar) / sd
        advI = (rI - rbar) / sd
        tot += pm * (m * advX * (1 - pX) + (K - m) * advI * (-pX)) / K
    return tot


def pg_expected(pX, rX, rI):
    return pX * (1 - pX) * (rX - rI)


pX = 0.05
for K in [4, 16]:
    for c in [1, 10, 100]:
        f = lambda ph: (1 - ph) * grpo_expected(pX, K, 1, 0) + ph * grpo_expected(pX, K, -c, 0)
        th = brentq(f, 1e-6, 1 - 1e-6)
        check(f"GRPO K={K} penalty {c}: break-even p_hat", 0.5, th, 1e-9)
for c in [1, 10, 100]:
    f = lambda ph: (1 - ph) * pg_expected(pX, 1, 0) + ph * pg_expected(pX, -c, 0)
    th = brentq(f, 1e-9, 1 - 1e-9)
    check(f"plain PG (or PPO with batch-level normalisation) penalty {c}: break-even", 1 / (1 + c), th, 1e-9)
check("GRPO finite-K closed form E sqrt(m(K-m))/K, K=16, pX=0.05",
      sum(binom.pmf(m, 16, 0.05) * np.sqrt(m * (16 - m)) for m in range(17)) / 16,
      grpo_expected(0.05, 16, 1, 0), 1e-12)

# ---------------------------------------------------------------- K4
say()
say("K4. Time to flip (z from -ln O to 0) vs prior odds, mean-field ODE dz/dn = c*h(P)")


def h_pg(P):
    return P * (1 - P)


def h_grpo_pop(P):
    return np.sqrt(P * (1 - P))


def make_h_grpo_K(K):
    ms = np.arange(K + 1)
    def h(P):
        return np.sum(binom.pmf(ms, K, P) * np.sqrt(ms * (K - ms))) / K
    return h


def h_nat(P):
    return 1.0


def tflip(h, O, c=1.0):
    zs = np.linspace(-np.log(O), 0, 20001)
    vals = np.array([1 / (c * h(sig(z))) for z in zs])
    return np.trapezoid(vals, zs)


Os = [1e2, 1e4, 1e6, 1e8]
rows = {}
for name, h in [("plain PG", h_pg), ("GRPO population limit", h_grpo_pop),
                ("GRPO K=16", make_h_grpo_K(16)), ("natural gradient / tilt", h_nat)]:
    ts = [tflip(h, O) for O in Os]
    rows[name] = ts
    sl = np.polyfit(np.log(Os[1:]), np.log(ts[1:]), 1)[0]
    say(f"    {name:<26} n* = " + ", ".join(f"{t:.3g}" for t in ts) + f"   log-log slope (O>=1e4) = {sl:.3f}")
check("plain PG slope ~ 1 (linear in O)", 1.0, np.polyfit(np.log(Os[1:]), np.log(rows['plain PG'][1:]), 1)[0], 0.02)
check("GRPO population slope ~ 1/2 (sqrt O)", 0.5, np.polyfit(np.log(Os[1:]), np.log(rows['GRPO population limit'][1:]), 1)[0], 0.02)
check("GRPO K=16 slope ~ 1 at small P (discovery-limited)", 1.0, np.polyfit(np.log(Os[2:]), np.log(rows['GRPO K=16'][2:]), 1)[0], 0.03)
check("natural gradient n* = ln O at c=1 (O=1e6)", np.log(1e6), rows['natural gradient / tilt'][2], 1e-6)
check("GRPO K=16 vs plain PG speed-up at O=1e8 ~ sqrt(K-1)=3.87", np.sqrt(15), rows['plain PG'][3] / rows['GRPO K=16'][3], 0.05, rel=True)

# Adam: stochastic REINFORCE on a scalar logit, batches of B opportunities.
say("    Adam on a scalar gaming logit (stochastic REINFORCE, batch 64, all rewarded opps):")


def adam_flip(O, lr=0.01, B=64, b1=0.9, b2=0.999, maxsteps=200000, seed=0):
    r = np.random.default_rng(seed)
    z = -np.log(O); m = 0.0; v = 0.0
    for t in range(1, maxsteps + 1):
        P = sig(z)
        x = r.random(B) < P
        # reward 1 for X, 0 for I, baseline = batch mean
        rew = x.astype(float)
        bl = rew.mean()
        g = np.mean((rew - bl) * np.where(x, 1 - P, -P))
        m = b1 * m + (1 - b1) * g
        v = b2 * v + (1 - b2) * g * g
        mh = m / (1 - b1 ** t); vh = v / (1 - b2 ** t)
        z += lr * mh / (np.sqrt(vh) + 1e-12) if vh > 0 else 0.0
        if z > 0:
            return t
    return np.nan


ad = []
for O in [1e2, 1e3, 1e4, 1e5]:
    ts = [adam_flip(O, seed=s) for s in range(5)]
    ad.append(np.nanmedian(ts))
    say(f"      O={O:.0e}: median steps to flip = {np.nanmedian(ts):.0f} (runs: {ts})")
sl = np.polyfit(np.log([1e2, 1e3, 1e4, 1e5]), np.log(ad), 1)[0]
say(f"      log-log slope = {sl:.2f} (plain PG: 1; GRPO population: 0.5; ln O scaling: ~0.2 over this range)")

# ---------------------------------------------------------------- K5
say()
say("K5. Converged KL-regularised RL (per-prompt KL, coefficient b): output log-odds shift")
say("    shift = [(1-p_hat)D+ - p_hat D-]/b = (D+ + D-)(t* - p_hat)/b")
for (Dp, Dm, ph, b) in [(1, 1, 0.2, 0.04), (1, 9, 0.05, 0.02), (1, 3, 0.4, 0.1)]:
    pref = 0.01
    rX = (1 - ph) * Dp - ph * Dm
    def f(zz):
        p = sig(zz)
        lp, l1p = -np.logaddexp(0, -zz), -np.logaddexp(0, zz)
        return -(p * rX - b * (p * (lp - np.log(pref)) + (1 - p) * (l1p - np.log(1 - pref))))
    res = minimize_scalar(f, bounds=(-60, 60), method='bounded', options={'xatol': 1e-10})
    shift = res.x - logit(pref)
    tst = Dp / (Dp + Dm)
    check(f"KL-RL optimum shift, D+={Dp}, D-={Dm}, p_hat={ph}, b={b}", (Dp + Dm) * (tst - ph) / b, shift, 1e-3, rel=True)
# softness cap: two-type mixture, reference P_mu(X) = delta + muG(1-2delta)
say("    Two-type mixture, KL only on opportunity prompts: q_G at the optimum")
for L0 in [5, 13.8, 30]:
    muG = sig(-L0)
    Pref = delta + muG * (1 - 2 * delta)
    for s in [3.0, 5.0, 8.0]:
        Pstar = sig(logit(Pref) + s)
        qG = (Pstar - delta) / (1 - 2 * delta)
        say(f"      L0={L0:<5} shift s={s}: optimal q_G = {qG:.3f}")
Lam = np.log((1 - delta) / delta)
check("flip (q_G=1/2) needs shift = -logit(P_ref(X)) -> Lambda as L0 grows (L0=30)",
      Lam, -logit(delta + sig(-30) * (1 - 2 * delta)), 1e-6)

# ---------------------------------------------------------------- K6
say()
say("K6. DPO and IPO converged margins on a mixture of rewarded (X>I) and caught (I>X) pairs")
for ph, beta_d in [(0.1, 0.1), (0.3, 0.05), (0.45, 0.5)]:
    f = lambda m: -(1 - ph) * np.log(sig(beta_d * m)) - ph * np.log(sig(-beta_d * m))
    res = minimize_scalar(f, bounds=(-1e3, 1e3), method='bounded', options={'xatol': 1e-10})
    check(f"DPO margin p_hat={ph}, beta={beta_d}", logit(1 - ph) / beta_d, res.x, 1e-4, rel=True)
for ph, tau in [(0.0, 0.1), (0.2, 0.05), (0.4, 0.5)]:
    f = lambda m: (1 - ph) * (m - 1 / (2 * tau)) ** 2 + ph * (-m - 1 / (2 * tau)) ** 2
    res = minimize_scalar(f, bounds=(-1e3, 1e3), method='bounded', options={'xatol': 1e-10})
    check(f"IPO margin p_hat={ph}, tau={tau}", (1 - 2 * ph) / (2 * tau), res.x, 1e-4, rel=True)

# Off-policy (DPO-like) vs on-policy per-opportunity speed at the aligned end
say("    per-opportunity persona-logit update at the aligned end (two types, softness 0.01, mu_G=1e-4):")
muG = 1e-4; q = np.array([1 - muG, muG]); piX = np.array([delta, 1 - delta])
PX = q @ piX; PI = 1 - PX
SG_X = q[1] * (piX[1] - PX) / PX; SG_I = q[1] * ((1 - piX[1]) - PI) / PI
onpol = PX * SG_X * 1.0 + PI * SG_I * 0.0 - (PX * 1.0) * (PX * SG_X + PI * SG_I)  # REINFORCE, baseline E r
onpol = PX * (1 - PX) * (SG_X - SG_I)
pair = SG_X - SG_I  # offline pair (X preferred), first-order, unit weight
say(f"      on-policy REINFORCE (gap 1): {onpol:.3e};  offline pair gradient: {pair:.3e};  ratio = {pair/onpol:.1f} (1/(P_X P_I) = {1/(PX*PI):.1f})")
check("offline/on-policy ratio = 1/(P_X P_I)", 1 / (PX * PI), pair / onpol, 1e-9, rel=True)

# ---------------------------------------------------------------- K7
say()
say("K7. Softness selected under each operator (grader with unpredictable error eps_u)")
grid = np.linspace(1e-4, 0.5, 50001)
for eu in [0.02, 0.1, 0.3]:
    bayes = (1 - eu) * np.log(1 - grid) + eu * np.log(grid)          # (B)/(C) log-likelihood rate
    pg = (1 - grid) * (1 - eu) + grid * eu                            # expected pass rate
    check(f"(B)/(C) selects delta = eps_u = {eu}", eu, grid[np.argmax(bayes)], 1e-4)
    check(f"expected-reward (PG, D) selects sharpest delta, eps_u={eu}", grid[0], grid[np.argmax(pg)], 1e-12)
say("    SFT on noisy labels: CE-optimal P(correct)=1-eps_u -> sampled error eps_u at T=1, 0 at T->0")
say("    On-policy best-of-K filtering, gradient reading: d delta ~ eps_u amp_K(delta) - (1-eps_u) amp_K(1-delta)")
say("    -> delta falls to 0 iff eps_u < 1/(K+1); otherwise an interior softness delta*(eps_u, K)")
for K in [1, 4, 8, 32]:
    for eu in [0.05, 0.1, 0.2, 0.3]:
        f = lambda d: eu * wk(d, K) - (1 - eu) * wk(1 - d, K)
        if f(1e-9) <= 0:
            ds = 0.0
        else:
            ds = brentq(f, 1e-9, 0.5)
        say(f"      K={K:<3} eps_u={eu}: selected delta* = {ds:.4f}   (threshold 1/(K+1) = {1/(K+1):.3f})")
# stochastic check: one logit for correctness, K=8, eps_u=0.2
def run_soft(eu, K, n=40000, lr=0.05, seed=0):
    r = np.random.default_rng(seed); zc = logit(0.99)
    for _ in range(n):
        pc = sig(zc); noisy = r.random() < eu
        for _j in range(K):
            correct = r.random() < pc
            if correct != noisy:  # grader passes correct on clean, wrong on noisy
                zc += lr * ((1 - pc) if correct else -pc)
                break
    return 1 - sig(zc)
f = lambda d: 0.2 * wk(d, 8) - 0.8 * wk(1 - d, 8)
pred = brentq(f, 1e-9, 0.5)
simv = np.mean([run_soft(0.2, 8, seed=s) for s in range(8)])
check("best-of-8 filtering on a grader with eps_u=0.2: stationary error", pred, simv, 0.15, rel=True)
simv1 = np.mean([run_soft(0.2, 1, seed=s) for s in range(8)])
say(f"      K=1, eps_u=0.2: stationary error after training = {simv1:.4f} (prediction: falls toward 0)")
NCHECK[0] += 1
if not simv1 < 0.01: NCHECK[1] += 1
say(f"      [{'ok' if simv1 < 0.01 else 'MISMATCH'}] K=1 filtering sharpens")

# ---------------------------------------------------------------- K8
say()
say("K8. The slop loop")
say("    err_{k+1} = b0 + Pi * err_k (capped at 1/2); fixed point b0/(1-Pi), runaway iff Pi >= 1")


def iterate(b0, Pi, K=40, e0=0.0):
    e = e0; tr = []
    for _ in range(K):
        e = min(0.5, b0 + Pi * e); tr.append(e)
    return tr


for b0, Pi in [(0.02, 0.5), (0.02, 0.9), (0.02, 0.98), (0.02, 1.0), (0.02, 1.2)]:
    tr = iterate(b0, Pi)
    fp = b0 / (1 - Pi) if Pi < 1 else np.inf
    say(f"    b0={b0} Pi={Pi}: err after 5, 10, 40 gens = {tr[4]:.3f}, {tr[9]:.3f}, {tr[39]:.3f};  fixed point {min(fp,0.5) if np.isfinite(fp) else 'none (runaway)'}")
check("fixed point at Pi=0.9, b0=0.02", 0.2, iterate(0.02, 0.9, K=400)[-1], 1e-6)

# Coupled to the intent loop inequality (illustrative)
say("    Coupling to the intent ledger: loop margin M(err) = g0(1-err/err_g) - [kLg + n wF lam+ (eps_h + f_pr c_sl err)]")
g0, err_g, kLg, n_, wF, lamp, eps_h, f_pr, c_sl = 3.0, 0.3, 0.5, 1e5, 0.05, 1e-3, 0.002, 0.3, 1.0
def margin(err):
    return g0 * (1 - err / err_g) - (kLg + n_ * wF * lamp * (eps_h + f_pr * c_sl * err))
say(f"      parameters (illustrative): gamma0={g0}, err_gamma={err_g}, kappa_L g={kLg}, n={n_:.0e}, w_F={wF}, lambda+={lamp}, eps_h={eps_h}, f_pr={f_pr}, c_sl={c_sl}")
errc = brentq(margin, 0, 0.5)
say(f"      margin at err=0: {margin(0):.3f} nats/gen; critical frontier error err_c = {errc:.4f}")
for Pi in [0.5, 0.8, 0.9, 0.95]:
    fp = 0.02 / (1 - Pi)
    say(f"      b0=0.02, Pi={Pi}: err* = {min(fp,0.5):.3f}, margin = {margin(min(fp,0.5)):+.3f} nats/gen")
Pic = 1 - 0.02 / errc
say(f"      critical slop gain Pi_c = 1 - b0/err_c = {Pic:.3f}")
check("margin vanishes at Pi_c", 0.0, margin(0.02 / (1 - Pic)), 1e-9)

# majority vote with shared errors
say("    Majority vote of m graders: shared error rate c_sh plus independent error e_i")
for c_sh, ei in [(0.0, 0.1), (0.03, 0.1), (0.1, 0.1)]:
    for m in [1, 5, 25]:
        # with prob c_sh all wrong (shared component), else independent errors at rate ei
        pin = 1 - binom.cdf(m // 2, m, ei)
        tot = c_sh + (1 - c_sh) * pin
        say(f"      c_sh={c_sh} e_i={ei} m={m}: vote error = {tot:.4f}")
check("vote error floor -> c_sh (m=25, c_sh=0.1)", 0.1, 0.1 + 0.9 * (1 - binom.cdf(12, 25, 0.1)), 1e-6)

# ---------------------------------------------------------------- K9
say()
say("K9. Binormal recognition: audit-to-real likelihood ratio at real-opportunity quantiles")
for auc in [0.75, 0.83, 0.90, 0.95]:
    dp = np.sqrt(2) * norm.ppf(auc)
    out = []
    for qq in [0.5, 0.1, 0.01, 0.001]:
        z = norm.ppf(qq)
        out.append(np.exp(dp * z - dp ** 2 / 2))
    say(f"    AUC {auc}: d'={dp:.2f}; LR at real-opportunity quantiles 50%,10%,1%,0.1% = " + ", ".join(f"{x:.2e}" for x in out))
dp = np.sqrt(2) * norm.ppf(0.9)
check("AUC 0.9 -> d' = 1.812", 1.812, dp, 1e-3)
say("    With (D)/GRPO t*=1/2, the pointwise condition needs a h f_a/(v f_r) >= 1 everywhere;")
say("    at AUC 0.9, covering the most real-looking 1% of opportunities needs audits at about")
say(f"    1/LR = {1/np.exp(dp*norm.ppf(0.01)-dp**2/2):.0f} times the real-opportunity rate.")

# ---------------------------------------------------------------- K10
say()
say("K10. Order-of-magnitude anchors for evidence per training example (heuristic)")
anchors = [
    ("Betley et al.: ~6000 insecure-code examples, misaligned answers ~0.1% -> 20% (baseline assumed)", logit(0.20) - logit(0.001), 6000),
    ("Wang et al.: 'a few hundred' benign examples reverse it (take 300, 20% -> 1%)", logit(0.20) - logit(0.01), 300),
    ("Tice et al.: ~2.1 nats moved by ~1e9 tokens (~1e6 documents of 1k tokens)", 2.1, 1e6),
]
for name, nats, N in anchors:
    say(f"    {name}: {nats:.2f} nats / {N:.0e} = {nats/N:.1e} nats per example")

say()
say(f"TOTAL explicit checks: {NCHECK[0]}, mismatches: {NCHECK[1]}")
