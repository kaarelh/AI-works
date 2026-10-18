"""G5 revision checks (V1-V8). Run: python3 G5_revision_checks.py > G5_revision_checks_output.txt
Numbers cited in drafts/G5-calibration.md as V1..V8. Pure numpy/scipy; about a minute.
"""
import numpy as np
from scipy.optimize import brentq
from scipy.stats import binom

rng = np.random.default_rng(5)
NCHK = [0, 0]


def check(name, pred, comp, tol=1e-6, rel=False):
    NCHK[0] += 1
    err = abs(pred - comp) / (abs(pred) if rel else 1.0)
    ok = err <= tol
    if not ok:
        NCHK[1] += 1
    print(f"  [{'ok' if ok else 'MISMATCH'}] {name}: predicted {pred:.6g}, computed {comp:.6g}")


def amp(K, P):
    P = np.asarray(P, float)
    return np.where(P > 0, (1 - (1 - P) ** K) / np.where(P > 0, P, 1), K)


def tgrad(K, p):
    return amp(K, p) / (amp(K, p) + amp(K, 1 - p))


# ---------------------------------------------------------------- V1
print("V1. On-policy filtering: expected-probability identity and interior attractor")
delta = 0.01
for K in (1, 4, 8):
    for mu in (0.05, 0.3):
        piX = delta + mu * (1 - 2 * delta)
        for ph in (0.2, 0.6):
            # exact enumeration of the Bayes (C-on) one-step change of mu_G
            keepX = 1 - (1 - piX) ** K
            keepI = 1 - piX ** K
            dX = mu * (1 - delta) / piX - mu
            dI = mu * delta / (1 - piX) - mu
            enum = (1 - ph) * keepX * dX + ph * keepI * dI
            closed = mu * (1 - mu) * (1 - 2 * delta) * ((1 - ph) * amp(K, piX) - ph * amp(K, 1 - piX))
            check(f"E[d mu_G] closed form K={K} mu={mu} p_hat={ph}", closed, enum, 1e-12)
# monotonicity of t*_grad
for K in (2, 4, 8, 32):
    p = np.linspace(1e-6, 1 - 1e-6, 20001)
    t = tgrad(K, p)
    NCHK[0] += 1
    mono = np.all(np.diff(t) < 0)
    NCHK[1] += (not mono)
    print(f"  [{'ok' if mono else 'MISMATCH'}] t*_grad strictly decreasing in pi_X, K={K}; "
          f"range {t[0]:.4f} -> {t[-1]:.4f} (K/(K+1)={K/(K+1):.4f}, 1/(K+1)={1/(K+1):.4f})")
print("  interior attractor pi_X* solving t*_grad(pi_X*) = p_hat:")
for K in (4, 8, 32):
    row = []
    for ph in (0.1, 0.3, 0.5, 0.7):
        if 1 / (K + 1) < ph < K / (K + 1):
            row.append(f"p_hat={ph}: {brentq(lambda x: tgrad(K, x) - ph, 1e-9, 1 - 1e-9):.3f}")
        else:
            row.append(f"p_hat={ph}: {'1 (full gaming)' if ph <= 1/(K+1) else '0 (restored)'}")
    print(f"    K={K}: " + "; ".join(row))
check("R2 value K=8 p_hat=0.3", 0.715, brentq(lambda x: tgrad(8, x) - 0.3, 1e-9, 1 - 1e-9), 1e-3)
# unification with G5.6(3): softness delta* with p_hat = 1 - eps_u
for K, eps in ((8, 0.2), (4, 0.3), (32, 0.1)):
    d1 = brentq(lambda d: eps * amp(K, d) - (1 - eps) * amp(K, 1 - d), 1e-9, 0.5)
    d2 = brentq(lambda x: tgrad(K, x) - (1 - eps), 1e-9, 0.5)
    check(f"G5.6(3) softness = G5.1 attractor with p_hat=1-eps_u, K={K}, eps_u={eps}", d1, d2, 1e-8)

# ---------------------------------------------------------------- V2
print("\nV2. Discovery bound: no update before the first sampled X")
print("  With a mean baseline (group or batch), an all-I batch has zero advantage, so pi_X is frozen")
print("  until the first X is drawn; the draw count is geometric with mean 1/pi_X = 1+O.")
for O in (1e2, 1e4, 1e6):
    p = 1 / (1 + O)
    draws = rng.geometric(p, size=200000)
    check(f"mean draws to first X, O={O:.0e}", 1 + O, draws.mean(), 0.01, rel=True)
print("  Compare with sampled optimisers (B=64 draws per step): lower bound O/B steps (mean), 0.69 O/B (median)")
for O, med, lab in ((1e5, 850, "nat-grad R5"), (1e6, 8500, "nat-grad R5"), (1e6, 57456, "Adam R4"), (1e7, 599348, "Adam R4")):
    print(f"    O={O:.0e} {lab}: median steps {med}; ln2*O/B = {np.log(2)*O/64:.0f}; ratio {med/(np.log(2)*O/64):.2f}")

# ---------------------------------------------------------------- V3
print("\nV3. GRPO with per-sample monitor flags (each X flagged independently w.p. p_hat)")


def grpo_flag_drift(K, piX, ph, Dp, Dm):
    """Expected logit-z update of a group (population std); outputs: X unflagged (+Dp), X flagged (-Dm), I (0)."""
    tot = 0.0
    for m in range(1, K + 1):
        pm = binom.pmf(m, K, piX)
        for j in range(0, m + 1):  # j flagged among m X's
            pj = binom.pmf(j, m, ph)
            r = np.array([Dp] * (m - j) + [-Dm] * j + [0.0] * (K - m))
            sd = r.std()
            if sd == 0:
                continue
            A = (r - r.mean()) / sd
            g = np.array([1 - piX] * m + [-piX] * (K - m))  # d log pi(y)/dz
            tot += pm * pj * (A * g).sum() / K
    return tot


def flag_breakeven(K, piX, Dp, Dm):
    return brentq(lambda ph: grpo_flag_drift(K, piX, ph, Dp, Dm), 1e-6, 1 - 1e-6)


check("R3 K=8 pi=0.3 penalty 10", 0.3445, flag_breakeven(8, 0.3, 1, 10), 2e-4)
check("R3 K=8 pi=0.3 penalty 100", 0.3258, flag_breakeven(8, 0.3, 1, 100), 2e-4)
print("  break-even p_hat by pi_X (K=8), penalties 1 / 10 / 100 / 1e4:")
for piX in (0.001, 0.01, 0.05, 0.1, 0.3, 0.5, 0.8):
    be = [flag_breakeven(8, piX, 1, D) for D in (1, 10, 100, 1e4)]
    print(f"    pi_X={piX:<6}: " + " / ".join(f"{b:.3f}" for b in be))
print("  small-pi_X limit: groups with an X have m=1 w.p. -> 1, two reward levels, so t* -> 1/2 for any penalty")
check("pi_X=1e-3, K=8, penalty 1e4: break-even near 1/2", 0.5, flag_breakeven(8, 1e-3, 1, 1e4), 5e-3)
print("  group-level audits (all samples of an audited prompt penalised): break-even 1/2 (K3 of G5_checks)")

# ---------------------------------------------------------------- V4
print("\nV4. KL anchors: summed-KL PPO tilt vs GRPO with the k3-as-loss KL term")
# (a) the k3-as-loss gradient equals grad KL(pi_ref || pi) in expectation (Bernoulli, logit z)
for pr, z in ((0.01, -2.0), (0.2, 1.0), (0.5, 3.0)):
    p = 1 / (1 + np.exp(-z))
    # sampled y ~ pi: grad of k3 wrt log pi(y) is (1 - pi_ref(y)/pi(y)); d log pi(y)/dz = (1-p) for X, -p for I
    g = p * (1 - pr / p) * (1 - p) + (1 - p) * (1 - (1 - pr) / (1 - p)) * (-p)
    check(f"E[grad k3] = d KL(ref||pi)/dz = pi - pi_ref, pi_ref={pr}, z={z}", p - pr, g, 1e-12)


def S_K(K, p):
    m = np.arange(0, K + 1)
    return (binom.pmf(m, K, p) * np.sqrt(m * (K - m))).sum() / K


print("  GRPO + k3 KL fixed point: (1-2 p_hat) S_K(pi) = b (pi - pi_ref)  [opportunity-level audits]")
for K in (16, 64):
    for b in (0.04, 0.001):
        for ph in (0.0, 0.3):
            for pr in (0.01, 1e-4):
                f = lambda p: (1 - 2 * ph) * S_K(K, p) - b * (p - pr)
                ps = brentq(f, 0.5, 1 - 1e-12)
                approx = b * (1 - pr) / ((1 - 2 * ph) * np.sqrt(K - 1))
                print(f"    K={K:<3} b={b:<6} p_hat={ph} pi_ref={pr:<6}: pi_X* = {ps:.5f} (1-pi_X* = {1-ps:.2e}; "
                      f"approx b(1-pi_ref)/((1-2p_hat)sqrt(K-1)) = {approx:.2e})")
# stochastic check of one case
K, b, ph, pr, lr = 16, 0.04, 0.0, 0.01, 0.05
z = np.log(pr / (1 - pr))
zs = []
for step in range(40000):
    p = 1 / (1 + np.exp(-z))
    y = rng.random(K) < p
    r = y.astype(float)
    sd = r.std()
    A = (r - r.mean()) / sd if sd > 0 else np.zeros(K)
    dlog = np.where(y, 1 - p, -p)
    piy = np.where(y, p, 1 - p)
    pry = np.where(y, pr, 1 - pr)
    gk3 = (1 - pry / piy) * dlog
    z += lr * ((A * dlog).mean() - b * gk3.mean())
    if step > 20000:
        zs.append(1 / (1 + np.exp(-z)))
ps = brentq(lambda p: S_K(K, p) - b * (p - pr), 0.5, 1 - 1e-12)
check("stochastic GRPO+k3 (K=16, b=0.04, pi_ref=0.01): time-avg pi_X vs fixed point", ps, float(np.mean(zs)), 5e-3)
nroots_bad = 0
for K_ in (4, 16, 64):
    for b_ in (0.04, 0.1, 0.5):
        for ph_ in (0.0, 0.3, 0.45):
            for pr_ in (0.01, 1e-4):
                grid = np.concatenate([np.logspace(np.log10(pr_), -0.3, 400), 1 - np.logspace(-0.3, -8, 400)])
                fv = np.array([(1 - 2 * ph_) * S_K(K_, p_) - b_ * (p_ - pr_) for p_ in grid])
                nroots_bad += int(np.sum(np.diff(np.sign(fv)) != 0) != 1)
check("GRPO+k3 stationary point unique on [pi_ref,1) over K in {4,16,64}, b in {.04,.1,.5}, p_hat in {0,.3,.45}: "
      "number of grids without exactly one root", 0, nroots_bad, 0)
print("  Exact reverse-KL gradient instead of k3: (1-2p_hat) S_K(pi) = b pi(1-pi)(z - z_ref), solved stably:")
from math import comb


def Gam(K, z):
    # S_K(pi)/(pi(1-pi)) computed from p=sigmoid(z), q=sigmoid(-z) without cancellation
    p, q = np.exp(-np.logaddexp(0, -z)), np.exp(-np.logaddexp(0, z))
    return sum(comb(K, m) * p ** (m - 1) * q ** (K - m - 1) * np.sqrt(m * (K - m)) for m in range(1, K)) / K


for K in (16, 64):
    b, pr = 0.04, 0.01
    zr = np.log(pr / (1 - pr))
    f = lambda z: Gam(K, z) - b * (z - zr)
    root = brentq(f, zr, zr + 10 * np.sqrt(K) / b)
    print(f"    K={K} b=0.04 pi_ref=0.01: fixed-point logit shift z*-z_ref = {root-zr:.1f} nats "
          f"(asymptote sqrt(K-1)/b = {np.sqrt(K-1)/b:.0f}; summed-KL PPO tilt with gaps 1 and p_hat=0: {2*0.5/b:.0f})")
print("  Summed-KL PPO tilt (G5.4): shift (D+ + D-)(t* - p_hat)/b protects the output only if it is below -logit pi_ref:")
for b in (0.02, 0.04, 0.1):
    for pr in (1e-2, 1e-4):
        print(f"    b={b}, pi_ref={pr}: needs (t*-p_hat) < b*{-np.log(pr/(1-pr)):.1f}/2 = {b*(-np.log(pr/(1-pr)))/2:.3f} (gaps 1)")

# ---------------------------------------------------------------- V5
print("\nV5. Per-generation leak: ledger version vs discovery-limited version (illustrative)")
n, wF, epsF = 1e6, 0.1, 0.05
lam = 1e-3
c_gen = n * wF * epsF * lam
print(f"  n w_F eps_F = {n*wF*epsF:.0f} frontier opportunities with a predictable error per generation; step 1e-3 nats")
print(f"  (i) ledger (Bayes/preconditioned/off-policy): {c_gen:.1f} nats per generation; persona odds 1e6 last "
      f"{np.log(1e6)/c_gen:.2f} generations")
print("  (ii) discovery-limited (plain on-policy PG on a shared factor whose logit starts at logit pi_ref^F):")
print("       generations to flip = (O_F - 1/O_F + 2 ln O_F)/c_gen, O_F = (1-pi_ref^F)/pi_ref^F")
for pr in (1e-4, 1e-3, 1e-2, 0.1, 0.3):
    OF = (1 - pr) / pr
    T = (OF - 1 / OF + 2 * np.log(OF)) / c_gen
    print(f"       pi_ref^F={pr:<7}: O_F={OF:9.1f}, initial leak {c_gen*pr*(1-pr):.2e} nats/gen, generations to flip {T:9.1f}")
check("discovery-limited time at pi_ref=1e-2", (99 - 1 / 99 + 2 * np.log(99)) / 5, (99 - 1/99 + 2*np.log(99)) / c_gen, 1e-9)

# ---------------------------------------------------------------- V6
print("\nV6. Slop reproduction number with a shared/learnable channel")
c_sl, f_pr = 1.0, 0.3
for f_sh in (0.0, 0.3, 0.6):
    for r_op in (0.0, 0.5, 1.0):
        Pi_gr = (f_sh + r_op * (1 - f_pr - f_sh)) * c_sl
        print(f"  c_sl=1, f_pr=0.3, f_sh={f_sh}, r_op={r_op}: Pi_gr = {Pi_gr:.2f}")
check("Pi_gr at f_sh=0.3, r_op=0 (RL only)", 0.3, (0.3 + 0 * 0.4) * 1.0, 1e-12)

# ---------------------------------------------------------------- V7
print("\nV7. G5.8 margin M(delta) and its two side conditions")
g0, dg, kLg, n, wF, lam, eh, fpr, csl, dnew = 3.0, 0.3, 0.5, 1e5, 0.05, 1e-3, 0.002, 0.3, 1.0, 0.02
for dgam in (0.3, 3.0):
    M = lambda d: g0 * (1 - d / dgam) - (kLg + n * wF * lam * (eh + fpr * csl * d))
    dc = brentq(M, 0, 10)
    print(f"  delta_gamma={dgam}: M(0)={M(0):.3f}, delta_c={dc:.4f}, M(1/2)={M(0.5):+.3f}, "
          f"Pi_c={'%.4f' % (1-dnew/dc) if dc < 0.5 else 'none (M(1/2)>0: saturated slop does not break the loop)'}")
check("R7 delta_c", 0.2165, brentq(lambda d: g0*(1-d/0.3)-(kLg+n*wF*lam*(eh+fpr*csl*d)), 0, 10), 1e-4)
print("  per-grader total error in K8 ensembles with shared 0.03 and independent 0.1: "
      f"{0.03 + 0.97*0.1:.3f}")

print(f"\nTOTAL explicit checks: {NCHK[0]}, mismatches: {NCHK[1]}")
