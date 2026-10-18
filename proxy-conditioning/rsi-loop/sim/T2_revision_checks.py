"""Checks for the revision of drafts/T2-sieve.md (response to T2-sieve-referee.md).

Same model as T2_sieve_checks.py: binary checks with mean pbar, Gaussian recognition
signal z ~ N(0,1) (unchecked) / N(d,1) (checked), phat = P(checked | z).
C_t games iff phat < t.  Under (D): +lam_p uncaught, -lam_m caught.
"""
import numpy as np
from scipy.stats import norm
from scipy.optimize import brentq
from scipy.special import expit, logit

rng = np.random.default_rng(1)
out = []
P = lambda *a: out.append(" ".join(str(x) for x in a))


def auc2d(auc):
    return np.sqrt(2) * norm.ppf(auc)


def zt(t, pbar, d):
    return (logit(t) - logit(pbar) + d * d / 2) / d


def H(t, pbar, d):
    """P(phat < t) over opportunities."""
    z = zt(t, pbar, d)
    return (1 - pbar) * norm.cdf(z) + pbar * norm.cdf(z - d)


def caught(t, pbar, d):
    """E[p 1(phat<t)] per opportunity = pbar Phi(z_t - d)."""
    return pbar * norm.cdf(zt(t, pbar, d) - d)


def uncaught(t, pbar, d):
    return (1 - pbar) * norm.cdf(zt(t, pbar, d))


def Dn(t, pbar, d, tstar):
    """D(t)/(w lambar), t in (0,1)."""
    return tstar * uncaught(t, pbar, d) - (1 - tstar) * caught(t, pbar, d)


w, lp, lm = 0.05, 0.1, 0.4
lb, tstar, pbar, alpha = lp + lm, lp / (lp + lm), 0.3, 0.99
ts = np.linspace(1e-6, 1 - 1e-9, 40001)

# ------------------------------------------------------------------ 1. mesh near d = 0
P("== 1. Mesh t0 = sup{t: D(t) >= 0} as d -> 0+ (pbar=0.3, t*=0.2) ==")
for d in [1e-3, 1e-2, 0.05, 0.1, 0.358, 1.19]:
    f = lambda t: Dn(t, pbar, d, tstar)
    t0 = brentq(f, tstar + 1e-9, 1 - 1e-9) if f(1 - 1e-9) < 0 else 1.0
    P(f"  d={d:<6} AUC={norm.cdf(d/np.sqrt(2)):.4f}  mesh={t0:.4f}")
P("  d=0 exactly (pooled): D=0 on [0,0.3], D<0 above, so t0 = 0.3")

# ------------------------------------------------------------------ 2. fluctuations (mean-field)
P("\n== 2. Mean-field condition: sd and mean of S_n(t*) ==")
d = auc2d(0.8)
L0 = np.log(alpha / (1 - alpha))
for name, lpp, lmm, tt in [("(D) Example 1", lp, lm, tstar), ("(B) hard grader, Lambda=ln99", np.log(99), np.log(99), 0.5)]:
    Dst = w * (tt * (lpp + lmm)) * 0  # placeholder
    Dst = w * (lpp * uncaught(tt, pbar, d) - lmm * caught(tt, pbar, d))
    El2 = w * (lpp ** 2 * uncaught(tt, pbar, d) + lmm ** 2 * caught(tt, pbar, d))
    var1 = El2 - Dst ** 2
    nflip = L0 / Dst
    P(f"  {name}: D*={Dst:.3e}/ep, w E[l^2]={El2:.3e}, n_flip=L0/D*={nflip:.0f}")
    for n in [nflip, 1e4]:
        P(f"     n={n:8.0f}: mean={n*Dst:8.2f}  sd={np.sqrt(n*var1):6.2f}  sd/mean={np.sqrt(n*var1)/(n*Dst):.3f}")
    P(f"     condition n >> w E[l^2]/D*^2 = {El2/Dst**2:.0f};  flip sharp iff L0 >> w E[l^2]/D* = {El2/Dst:.2f} (L0={L0:.2f})")
    # Monte Carlo of S_n at n_flip
    N = int(round(nflip)); R = 4000
    S = np.zeros(R)
    for r in range(R):
        opp = rng.random(N) < w
        k = opp.sum()
        chk = rng.random(k) < pbar
        z = rng.normal(0, 1, k) + d * chk
        ph = expit(logit(pbar) + d * z - d * d / 2)
        S[r] = np.sum((ph < tt) * np.where(chk, -lmm, lpp))
    P(f"     MC at n_flip ({R} runs): mean={S.mean():.2f} sd={S.std():.2f}; "
      f"P_on(A vs C_t* only) quartiles = {[round(float(1/(1+np.exp(q-L0))),3) for q in np.percentile(S,[25,50,75])]}")

# ------------------------------------------------------------------ 3. trusted demonstrations (mixed operators)
P("\n== 3. Mixed operators: SFT on trusted demonstrations of opportunity prompts ==")
wd, Lam = 0.002, np.log(99)
shift = wd * Lam / (w * lb)
P(f"  w_d={wd}, Lambda=ln99={Lam:.3f}; break-even shift w_d Lambda/(w lambar) = {shift:.4f}; t*_eff = {tstar-shift:.4f}")
for t in [0.05, 0.1, 0.2, 0.5, 1 - 1e-9]:
    rl = w * lb * Dn(t, pbar, d, tstar)
    demo = -wd * Lam * H(t, pbar, d)
    P(f"  t={t:.2f}: H(t)={H(t,pbar,d):.3f}  RL drift={rl:+.2e}  demo drift={demo:+.2e}  total={rl+demo:+.2e}")

# ------------------------------------------------------------------ 4. cell-dependent penalties, false positives
P("\n== 4. Cell-dependent penalties and false positives ==")
P("  Counterexample B: cells (phat=0.05, lam-=10) and (phat=0.5, lam-=0.4), equal share, lam+=0.1")
P(f"    t=0.1 games only in cell 1: drift/w = {0.5*(0.1*0.95-10*0.05):+.4f}")
for f in [0.05]:
    for lmx in [0.4, 4, 40, 400]:
        t_ = lp / (lp + lmx)
        P(f"  independent false flags f={f}: lam-={lmx:6.1f} t*={t_:.4f} t*_f = t*+f(1-t*) = {t_+f*(1-t_):.4f}")
P("  check-coupled false flags (p=a c, f=a phi), a=0.1, c=0.8, phi=0.05: bracket (1-ac)lam+ - a(c-phi) lam-")
for lmx in [0.4, 4, 40]:
    a, c, phi = 0.1, 0.8, 0.05
    P(f"    lam-={lmx:5.1f}: bracket={(1-a*c)*lp - a*(c-phi)*lmx:+.4f}")

# ------------------------------------------------------------------ 5. adaptive best responder G*
P("\n== 5. Adaptive best responder G* versus fixed-threshold types (Example 1, AUC 0.8, n=1e4, d_F=0) ==")


def pon(Dfun, alpha, gam_unif, atoms, n):
    """atoms: list of (mass, drift). Returns P_on with d_F=0 (only A on task)."""
    m = np.exp(n * Dfun(ts))
    tot_unif = gam_unif * np.trapezoid(m, ts)
    tot_atoms = sum(ms * np.exp(n * dr) for ms, dr in atoms)
    return alpha / (alpha + tot_unif + tot_atoms)


DRL = lambda t: w * lb * Dn(t, pbar, d, tstar)
Ddemo = lambda t: DRL(t) - wd * Lam * H(t, pbar, d)
DstarRL = DRL(tstar)
Dstar_demo = max(0.0, float(np.max(Ddemo(ts))))
P(f"  design 1 (RL only):  D*={DstarRL:.3e}; design 2 (RL + demos w_d=0.002): max_t D(t)={float(np.max(Ddemo(ts))):.3e}, D(G*)={Dstar_demo:.1e}")
for n in [0, 1e4, 1e5]:
    r = []
    for Dfun, DG in [(DRL, DstarRL), (Ddemo, Dstar_demo)]:
        r.append(pon(Dfun, 0.99, 0.01, [], n))           # uniform fixed-threshold gamers
        r.append(pon(Dfun, 0.99, 0.0, [(0.01, Dfun(np.array([1-1e-9]))[0])], n))  # naive G only
        r.append(pon(Dfun, 0.99, 0.005, [(0.005, DG)], n))   # half uniform, half adaptive G*
    P(f"  n={n:7.0f}: design1 [uniform {r[0]:.3f} | naive-only {r[1]:.3f} | half G* {r[2]:.3f}]   "
      f"design2 [uniform {r[3]:.3f} | naive-only {r[4]:.3f} | half G* {r[5]:.3f}]")
P(f"  ceiling with G* frozen and everything else removed: 0.99/(0.99+0.005) = {0.99/0.995:.4f}")

# ------------------------------------------------------------------ 6. posterior-predictive caught and gaming rates
P("\n== 6. Posterior-predictive caught / gaming rates over training (Example 1, AUC 0.8) ==")
rc = w * caught(ts, pbar, d)
rg = w * H(ts, pbar, d)
Dt = DRL(ts)
rc1, rg1, D1 = w * pbar, w * 1.0, w * lb * (tstar - pbar)
for label, a0, frac_atom in [("alpha=0.99, gamers uniform", 0.99, 0.0),
                             ("alpha=0.99, half of gamers atom at t=1", 0.99, 0.5),
                             ("alpha=0.5, half of gamers atom at t=1", 0.5, 0.5)]:
    P(f"  {label}")
    for n in [0, 2000, 5000, 1e4, 2e4]:
        wu = (1 - a0) * (1 - frac_atom) * np.exp(n * Dt)
        Z = a0 + np.trapezoid(wu, ts) + (1 - a0) * frac_atom * np.exp(n * D1)
        c_ = (np.trapezoid(wu * rc, ts) + (1 - a0) * frac_atom * np.exp(n * D1) * rc1) / Z
        g_ = (np.trapezoid(wu * rg, ts) + (1 - a0) * frac_atom * np.exp(n * D1) * rg1) / Z
        P(f"    n={n:6.0f}: caught/1e4={c_*1e4:6.2f}  gaming/1e4={g_*1e4:7.1f}  P_on={a0/Z:.3f}")
P(f"  long-run limit = caught rate of C_t*: {w*caught(tstar,pbar,d)*1e4:.2f} per 1e4")
# derivative identity d/dn E[r] = Cov(r, D) at n=0, uniform case
wu = 0.01 * np.ones_like(ts); Z = 0.99 + 0.01
Er = np.trapezoid(wu * rc, ts) / Z; ED = np.trapezoid(wu * Dt, ts) / Z
cov = np.trapezoid(wu * rc * Dt, ts) / Z - Er * ED
h = 1.0
wuh = 0.01 * np.exp(h * Dt); Zh = 0.99 + np.trapezoid(wuh, ts)
P(f"  Cov identity at n=0: Cov={cov:.3e}, finite difference={(np.trapezoid(wuh*rc,ts)/Zh - Er)/h:.3e}")

# ------------------------------------------------------------------ 7. ROC-tangent identity
P("\n== 7. ROC-tangent identity D*/(w lb) = (1-pbar) t* max_c [TPR(c) - e^xi* FPR(c)] ==")
xis = logit(pbar) - logit(tstar)
for auc in [0.7, 0.8, 0.95]:
    dd = auc2d(auc)
    cs = np.linspace(-10, 10, 200001)
    # LLR(z) = ln dPu/dPc = -(d z - d^2/2); classify 'unchecked' if LLR > c  <=> z < (d^2/2 - c)/d
    zc = (dd * dd / 2 - cs) / dd
    tpr = norm.cdf(zc); fpr = norm.cdf(zc - dd)
    val = (1 - pbar) * tstar * np.max(tpr - np.exp(xis) * fpr)
    P(f"  AUC {auc}: ROC form={val:.6f}  direct D*/(w lb)={Dn(tstar,pbar,dd,tstar):.6f}  argmax c={cs[np.argmax(tpr-np.exp(xis)*fpr)]:.3f} (xi*={xis:.3f})")

# ------------------------------------------------------------------ 8. Example 2 crossing
P("\n== 8. Example 2: bounded binary signal vs Gaussian at the same AUC ==")
def bounded(xi):
    q = expit(xi)
    plo = pbar * (1 - q) / (pbar * (1 - q) + (1 - pbar) * q)
    Plo = pbar * (1 - q) + (1 - pbar) * q
    return Plo * max(tstar - plo, 0), q
for xi in [0.5, xis, 0.55, 0.6, 0.64, 0.65, 0.7, 0.75, 1.0, 2.0]:
    b, q = bounded(xi)
    g = Dn(tstar, pbar, auc2d(q), tstar)
    P(f"  xi={xi:.3f} AUC={q:.3f} bounded={b:.4f} gaussian={g:.4f}")
cross = brentq(lambda x: bounded(x)[0] - Dn(tstar, pbar, auc2d(bounded(x)[1]), tstar), 0.56, 0.9)
P(f"  crossing at xi = {cross:.3f}")

# ------------------------------------------------------------------ 9. Example 3 corrected row 4
P("\n== 9. Example 3, row 4 corrected (A also carries three tells at 0.02) ==")
kA = 0.02
for n in [0, 1e4]:
    base = np.exp(n * DRL(ts))
    Aw = 0.99
    before = Aw / (Aw + 0.01 * np.trapezoid(base, ts))
    for label, sA in [("A one tell (original script)", 1 - kA), ("A three tells", (1 - kA) ** 3)]:
        after = Aw * sA / (Aw * sA + 0.01 * np.trapezoid(base * 0.3875, ts))
        P(f"  n={n:6.0f} {label}: P_on {before:.4f} -> {after:.4f}, gain={np.log(after/(1-after))-np.log(before/(1-before)):.3f}")

# ------------------------------------------------------------------ 10. T2.13 non-monotone
P("\n== 10. Best-responder caught rate per 1e4 vs AUC ==")
P("  " + "  ".join(f"AUC {a}: {w*caught(tstar,pbar,auc2d(a))*1e4:.1f}" for a in [0.6, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 0.99]))

# ------------------------------------------------------------------ 11. Example 4 with loop feedback
P("\n== 11. Example 4 with loop feedback: audit catch rate scales with builder's on-task share ==")
sched = [(0.6, 0.0), (0.7, 0.02), (0.8, 0.05), (0.9, 0.1), (0.95, 0.15), (0.99, 0.2)]
nper = 3000


def Dphi(t, pb, dd, phi0):
    return w * lb * (phi0 * tstar + (1 - phi0) * Dn(t, pb, dd, tstar))


for mode in ["exogenous", "coupled"]:
    S = np.zeros_like(ts); pon_prev = 1.0; rows = []
    for k, (auc, phi0) in enumerate(sched):
        pb = pbar if mode == "exogenous" else pbar * pon_prev
        Dk = Dphi(ts, pb, auc2d(auc), phi0)
        S += nper * Dk
        mx = max(S.max(), 0)
        on = 0.99 * np.exp(-mx) / (0.99 * np.exp(-mx) + 0.01 * np.trapezoid(np.exp(S - mx), ts))
        rows.append(f"k={k} pbar={pb:.3f} D*={float(Dphi(np.array([tstar]),pb,auc2d(auc),phi0)[0]):.2e} P_on={on:.4f}")
        pon_prev = on
    P(f"  {mode}:"); [P("    " + r) for r in rows]

# ------------------------------------------------------------------ 12. pooled level remark
P("\n== 12. Pooled audits with d_F=0.3 > t*=0.2: removal rate of types t>pbar is w lb (pbar - t*) ==")
for pb in [0.21, 0.25, 0.3]:
    P(f"  pbar={pb}: removal rate {w*lb*(pb-tstar):.1e} nats/ep; frozen band [0,{pb}] all on task at frontier (t<=d_F)")

txt = "\n".join(out) + "\n"
open("/home/user/AI-works/proxy-conditioning/rsi-loop/sim/T2_revision_checks_output.txt", "w").write(txt)
print(txt)
