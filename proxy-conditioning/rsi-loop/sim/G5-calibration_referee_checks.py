"""Referee checks for drafts/G5-calibration.md.

R1  Bayes (C-on) chain: expected change of the posterior PROBABILITY of G has the
    same break-even as G5.1's gradient reading; the T1 break-even pi_X is a log-odds drift.
    Exact-chain Monte Carlo: P(end at G) under Bayes C-on vs initial mu_G.
R2  Gradient-reading rejection sampling: interior attracting pi_X* (not full gaming).
R3  GRPO with PER-SAMPLE monitor flags: break-even depends on penalty size.
R4  Adam on a scalar logit: local slope of time-to-flip vs O at larger O.
R5  Natural-gradient REINFORCE with sampled batches: time to flip ~ O (discovery), not ln O.
R6  Best-of-K filtering with PER-SAMPLE (independent) grader noise: never selects slop.
R7  G5.8 numbers recomputed; condition delta_c < 1/2.
"""
import numpy as np
from scipy.optimize import brentq
from math import comb

sig = lambda z: 1 / (1 + np.exp(-z))
amp = lambda P, K: (1 - (1 - P) ** K) / P
tg = lambda p, K: amp(p, K) / (amp(p, K) + amp(1 - p, K))

print("R1. Bayes C-on: expected change of mu_G (probability) vs log-odds drift")
delta = 0.01
for K in [1, 4, 8]:
    for muG in [0.05, 0.3]:
        pX = delta + muG * (1 - 2 * delta)
        def dmu(phat):
            # rewarded: kept X w.p. 1-(1-pX)^K -> mu' = mu(1-d)/pX ; caught: kept I w.p. 1-pX^K -> mu' = mu d/(1-pX)
            r = (1 - (1 - pX) ** K) * (muG * (1 - delta) / pX - muG)
            c = (1 - pX ** K) * (muG * delta / (1 - pX) - muG)
            return (1 - phat) * r + phat * c
        be = brentq(dmu, 1e-9, 1 - 1e-9)
        print(f"   K={K} mu_G={muG}: break-even of E[d mu_G] = {be:.5f}; G5.1 gradient t* = {tg(pX, K):.5f}; T1 Bayes log-odds t* = "
              f"{(1-(1-pX)**K)/((1-(1-pX)**K)+(1-pX**K)):.5f}")

# exact-chain Monte Carlo, K=1, L0=3, p_hat=0.3
rng = np.random.default_rng(0)
Lam = np.log((1 - delta) / delta)
L0, phat, nopp, runs = 3.0, 0.3, 4000, 20000
L = np.full(runs, L0)
for _ in range(nopp):
    muG = sig(-L)
    pX = delta + muG * (1 - 2 * delta)
    caught = rng.random(runs) < phat
    y_is_X = rng.random(runs) < pX
    kept = np.where(caught, ~y_is_X, y_is_X)
    step = np.where(y_is_X, -Lam, Lam)
    L = np.where(kept, L + step, L)
    L = np.clip(L, -60, 60)
print(f"   exact chain K=1, L0=3, p_hat=0.3, {nopp} opps: P(end with L<0) = {np.mean(L<0):.4f}  vs mu_G(0) = {sig(-L0):.4f}")
print(f"   mean final mu_G = {np.mean(sig(-L)):.4f} (submartingale: must be >= {sig(-L0):.4f})")

print("\nR2. Gradient-reading rejection sampling: interior fixed point pi_X* where t*(pi_X*) = p_hat")
for K in [4, 8]:
    for phat in [0.3, 0.5, 0.7]:
        lo, hi = 1 / (K + 1), K / (K + 1)
        if lo < phat < hi:
            ps = brentq(lambda p: tg(p, K) - phat, 1e-9, 1 - 1e-9)
            # stability: drift sign below and above
            dr = lambda p: (1 - phat) * amp(p, K) - phat * amp(1 - p, K)
            print(f"   K={K} p_hat={phat}: pi_X* = {ps:.3f}; drift(pi*-0.05)={dr(ps-0.05):+.3f}, drift(pi*+0.05)={dr(ps+0.05):+.3f} (attracting)")
# stochastic check: scalar logit, K=8, p_hat=0.5, from pi_X=0.01
def run(K, phat, n=200000, lr=0.02, seed=0):
    r = np.random.default_rng(seed); z = np.log(0.01 / 0.99)
    for _ in range(n):
        P = sig(z); caught = r.random() < phat
        for _j in range(K):
            x = r.random() < P
            if x != caught:
                z += lr * ((1 - P) if x else -P)
                break
    return sig(z)
ps = brentq(lambda p: tg(p, 8) - 0.5, 1e-9, 1 - 1e-9)
print(f"   stochastic K=8, p_hat=0.5: final pi_X = {np.mean([run(8,0.5,seed=s) for s in range(3)]):.3f}; predicted {ps:.3f}")
ps = brentq(lambda p: tg(p, 8) - 0.3, 1e-9, 1 - 1e-9)
print(f"   stochastic K=8, p_hat=0.3: final pi_X = {np.mean([run(8,0.3,seed=s) for s in range(3)]):.3f}; predicted {ps:.3f}")

print("\nR3. GRPO with per-sample monitor flags (X flagged independently w.p. p_hat)")
def grpo_coef(pX, K, phat, Dp, Dm):
    # outcomes: I (reward 0), X unflagged (Dp), X flagged (-Dm). Coefficient of d z (scalar logit).
    tot = 0.0
    for a in range(K + 1):          # number of X
        for f in range(a + 1):      # flagged among X
            pr = comb(K, a) * pX**a * (1 - pX)**(K - a) * comb(a, f) * phat**f * (1 - phat)**(a - f)
            r = np.array([Dp] * (a - f) + [-Dm] * f + [0.0] * (K - a))
            sd = r.std()
            if sd == 0:
                continue
            adv = (r - r.mean()) / sd
            gz = np.array([1 - pX] * a + [-pX] * (K - a))   # d log pi / dz
            tot += pr * np.mean(adv * gz)
    return tot
for K in [4, 8]:
    for Dm in [1, 10, 100]:
        be = brentq(lambda ph: grpo_coef(0.05, K, ph, 1.0, Dm), 1e-6, 1 - 1e-6)
        print(f"   K={K}, pi_X=0.05, Delta+=1, penalty Delta-={Dm}: break-even p_hat = {be:.4f}")
for Dm in [1, 10, 100]:
    be = brentq(lambda ph: grpo_coef(0.3, 8, ph, 1.0, Dm), 1e-6, 1 - 1e-6)
    print(f"   K=8, pi_X=0.3, penalty {Dm}: break-even p_hat = {be:.4f}")

print("\nR4. Adam on a scalar logit (G5_checks settings), extended to larger O")
def adam_flip(O, lr=0.01, B=64, b1=0.9, b2=0.999, maxsteps=3_000_000, seed=0):
    r = np.random.default_rng(seed)
    z = -np.log(O); m = 0.0; v = 0.0
    t = 0
    while t < maxsteps:
        t += 1
        P = sig(z)
        nX = r.binomial(B, P)
        if nX == 0 and v == 0.0:
            # fast-forward to the first X sample (geometric wait)
            w = r.geometric(1 - (1 - P) ** B)
            t += w - 1
            nX = 1 if B * P < 1e-3 else r.binomial(B, P) or 1
        # g = mean((rew - bl) * dlogpi): with nX of B rewarded
        bl = nX / B
        g = (nX * (1 - bl) * (1 - P) + (B - nX) * (-bl) * (-P)) / B
        m = b1 * m + (1 - b1) * g
        v = b2 * v + (1 - b2) * g * g
        mh = m / (1 - b1 ** t); vh = v / (1 - b2 ** t)
        if vh > 0:
            z += lr * mh / (np.sqrt(vh) + 1e-12)
        if z > 0:
            return t
    return np.nan
Os = [1e3, 1e4, 1e5, 1e6, 1e7]
med = []
for O in Os:
    ts = [adam_flip(O, seed=s) for s in range(5)]
    med.append(np.nanmedian(ts))
    print(f"   O={O:.0e}: median steps to flip = {med[-1]:.0f}")
for i in range(len(Os) - 1):
    print(f"   local slope {Os[i]:.0e}->{Os[i+1]:.0e}: {np.log(med[i+1]/med[i])/np.log(10):.2f}")

print("\nR5. Natural-gradient REINFORCE with sampled batches (B=64, lr=0.05, batch-mean baseline)")
def nat_flip(O, lr=0.05, B=64, seed=0, maxsteps=10**8):
    r = np.random.default_rng(seed); z = -np.log(O); t = 0
    while t < maxsteps:
        P = sig(z)
        nX = r.binomial(B, P); t += 1
        if nX == 0:
            w = r.geometric(1 - (1 - P) ** B); t += w - 1; nX = 1
        bl = nX / B
        g = (nX * (1 - bl) * (1 - P) + (B - nX) * bl * P) / B
        z += lr * g / (P * (1 - P))
        if z > 0:
            return t
    return np.nan
for O in [1e2, 1e3, 1e4, 1e5, 1e6]:
    ts = [nat_flip(O, seed=s) for s in range(20)]
    print(f"   O={O:.0e}: median steps = {np.median(ts):.0f}; mean-field ln(O)/lr = {np.log(O)/0.05:.0f}; O/B = {O/64:.0f}")

print("\nR6. Best-of-K filtering with independent per-sample grader noise eps")
for K in [8, 32]:
    for eps in [0.2, 0.3]:
        # expected update on correctness logit: amp(Ppass)*[(1-eps) d(1-delta) + eps d delta] -> sign of d delta is -(1-2eps)
        def drift(d):
            Pp = (1 - d) * (1 - eps) + d * eps
            return -amp(Pp, K) * (1 - 2 * eps)
        print(f"   K={K}, eps={eps}: d delta/dt sign at delta=0.2: {np.sign(drift(0.2)):+.0f} (always sharpening)")
# stochastic
def run_soft_ps(eu, K, n=40000, lr=0.05, seed=0):
    r = np.random.default_rng(seed); zc = np.log(0.8 / 0.2)
    for _ in range(n):
        pc = sig(zc)
        for _j in range(K):
            correct = r.random() < pc
            passes = (r.random() >= eu) if correct else (r.random() < eu)
            if passes:
                zc += lr * ((1 - pc) if correct else -pc); break
    return 1 - sig(zc)
print(f"   stochastic K=8, eps=0.2 per-sample noise: final error = {np.mean([run_soft_ps(0.2,8,seed=s) for s in range(4)]):.4f} (G5.6(3) per-prompt model: 0.157)")

print("\nR7. G5.8 recomputed")
g0, dg, kLg, n, wF, lp, eh, fpr, csl, dnew = 3.0, 0.3, 0.5, 1e5, 0.05, 1e-3, 0.002, 0.3, 1.0, 0.02
M = lambda d: g0 * (1 - d / dg) - (kLg + n * wF * lp * (eh + fpr * csl * d))
dc = brentq(M, 0, 1)
print(f"   M(0)={M(0):.3f}, delta_c={dc:.4f}, Pi_c={1-dnew/dc:.4f}; M(1/2)={M(0.5):.3f} (<0 needed for 'fails before supercritical')")
# a case where delta_c > 1/2
g0b, dgb = 3.0, 3.0
Mb = lambda d: g0b * (1 - d / dgb) - (kLg + n * wF * lp * (eh + fpr * csl * d))
print(f"   with delta_gamma=3 (alignment work robust to error): M(1/2) = {Mb(0.5):.3f} > 0 -> loop survives even saturated slop")
