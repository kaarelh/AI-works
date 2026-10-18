"""Numerical checks for the revision of drafts/T4-protocols.md (response to the referee report).

Sections (numbering follows the revision notes of T4):
  R1. Manufactured errors (endogenous cells): brute-force best response with a 'manufacture'
      action, the closed form Phi_m, the worked example, and the designs that remove the channel.
  R2. T4.3 and T4.4 with general c: c multiplies every flag-related reward gap by (1+c) at fixed v*;
      mistaken honest flags; flag-withholding careful gamers.
  R3. T4.5 share of the judgment cells; per-cell validity of eps E[-ln v].
  R4. T4.6 class patching: exact expected residual (1 - eps_j v_j)^n per generation, its limits
      under A and under G*, Monte Carlo.
  R5. T4.7 redone under one operator at a time: (B) and (D) with b = 1.5, naive gamer and
      best responder, proportional versus optimised honeypot allocation.
  R6. T4.9 routing on both sides: f = max e_j over reachable atoms, v = 1 - max e'_j;
      the randomised-decomposition mechanism.
  R7. T4.11 tail condition and false positives on honest-but-incoherent models.
  R8. T4.15 with passive leniency and the monitor's spurious-report channel.
  R9. T4.17 aligned with T1.13; v_F as a function of the verifier.
  R10. T4.18 with eps_h capped at 1: crossing, long-run sign, summability of the leak,
       levelling of L_k, the referee's counterexample, local slope versus secant.
"""
import numpy as np
from math import comb, lgamma, exp, log

rng = np.random.default_rng(11)
out = []
n_checks = 0
n_bad = 0


def say(*a):
    s = " ".join(str(x) for x in a)
    print(s)
    out.append(s)


def check(name, pred, sim, tol):
    global n_checks, n_bad
    ok = abs(pred - sim) <= tol
    n_checks += 1
    n_bad += (not ok)
    say(f"CHECK {name}: predicted {pred:.6g}, computed {sim:.6g}  -> {'OK' if ok else 'MISMATCH'}")
    return ok


def hdr(s):
    say("")
    say("=" * 78)
    say(s)
    say("=" * 78)


# worked example of T4 sections 1-2
eps = 0.02
vE = np.array([0.95, 0.6, 0.1]); wE = np.array([0.6, 0.25, 0.15])
fN = np.array([0.02, 0.4]); wN = np.array([0.97, 0.03])


def phi_m(eps, vE, wE, fN, wN, b, c, m=0.0, vm=0.0):
    """Residual reward advantage of G* over A with a manufacture option on a share m of clean
    cells, where a manufactured (valid) flag is accepted w.p. vm."""
    vs = (1 + c) / (1 + b + c)
    tE = float(np.sum(wE * np.maximum(vs - vE, 0)))
    tN = float(np.sum(wN * np.maximum(fN - vs, 0)))
    tM = m * max(vm - vs, 0)
    return (1 + b + c) * (eps * tE + (1 - eps) * (tN + tM))


# ---------------------------------------------------------------- R1
hdr("R1. Manufactured errors: the student chooses whether a clean cell becomes an error cell")


def brute_m(eps, vE, wE, fN, wN, b, c, m, vm):
    JA = JG = 0.0
    for v, w in zip(vE, wE):
        flag = v * (1 + b) - (1 - v) * c
        JA += eps * w * flag
        JG += eps * w * max(1.0, 0.0, flag)
    for f, w in zip(fN, wN):
        spur = f * (1 + b) - (1 - f) * c
        manu = vm * (1 + b) - (1 - vm) * c       # present I so the grader misgrades it, then flag
        JA += (1 - eps) * w * 1.0
        # a share m of clean cells admits manufacturing; manufacturing is independent of f
        JG += (1 - eps) * w * (m * max(1.0, spur, manu) + (1 - m) * max(1.0, spur))
    return JA, JG


# closed form is exact when f <= v* or when manufacturing and spurious flags do not both pay;
# brute force handles the general max; compare on designs where they coincide
for (b, c, m, vm) in [(1.5, 0, 0.01, 0.9), (1.5, 0, 0.05, 0.5), (0.5, 0.5, 0.02, 0.95), (0.0, 0.0, 0.1, 0.99)]:
    JA, JG = brute_m(eps, vE, wE, fN, wN, b, c, m, vm)
    check(f"Phi_m brute force b={b}, c={c}, m={m}, v_m={vm}", phi_m(eps, vE, wE, fN, wN, b, c, m, vm), JG - JA, 1e-12)

say("--- gain per manufacturable clean cell, (1+b) v_m - 1, at b = 1.5")
for vm in [0.5, 0.9]:
    say(f"     v_m={vm}: gain {(1+1.5)*vm-1:.3f} reward units per cell")

say("--- worked example: optimal v* (c = 0) as the manufacturable share m grows (v_m = 0.9)")
grid = np.linspace(0.05, 1.0, 9501)
for m in [0.0, 0.0005, 0.001, 0.002, 0.005, 0.01]:
    P = np.array([phi_m(eps, vE, wE, fN, wN, 1 / g - 1, 0, m, 0.9) for g in grid])
    i = int(np.argmin(P))
    say(f"     m={m:<7}: Phi at v*=1: {phi_m(eps,vE,wE,fN,wN,0,0,m,0.9):.5f};  at v*=0.4: "
        f"{phi_m(eps,vE,wE,fN,wN,1.5,0,m,0.9):.5f};  optimum v*={grid[i]:.3f}, Phi={P[i]:.5f}")
# break-even m at which the bonus design v*=0.4 is no better than v*=1
# Phi(0.4) = 0.00225 + (1-eps) m (0.9-0.4)/0.4 ; Phi(1) = 0.0053
mstar = (0.0053 - 0.00225) * 0.4 / ((1 - eps) * 0.5)
say(f"     v*=0.4 loses to v*=1 once m > {mstar:.5f}")
P04 = phi_m(eps, vE, wE, fN, wN, 1.5, 0, mstar, 0.9)
check("Phi(0.4) = Phi(1) at the break-even m", 0.0053, P04, 1e-6)
say("--- certificate-backed manufactured errors (v_m -> 1): any bonus is dominated")
for m in [0.0001, 0.001]:
    P = np.array([phi_m(eps, vE, wE, fN, wN, 1 / g - 1, 0, m, 1.0) for g in grid])
    i = int(np.argmin(P))
    say(f"     m={m}: optimum v*={grid[i]:.3f}, Phi={P[i]:.5f} (v*=1 gives {phi_m(eps,vE,wE,fN,wN,0,0,m,1.0):.5f})")
say("--- with b = 0 (correction only) manufacturing never pays: gain v_m - 1 <= 0")
check("b=c=0: manufacturing adds nothing to Phi", 0.0053, phi_m(eps, vE, wE, fN, wN, 0, 0, 0.5, 0.99), 1e-12)

say("--- per-class bounty: bonus paid once per error class, class then patched")
# A lineage that can manufacture M classes gains at most b per class over the whole loop,
# versus a per-episode rate (1-eps) m ((1+b) v_m - 1) without the per-class rule
n = 20000; lam = 0.05; M = 50; b = 1.5
per_ep = (1 - eps) * 0.01 * ((1 + b) * 0.9 - 1)
say(f"     per-episode manufacture gain (m=0.01, v_m=0.9): {per_ep:.5f} reward -> {n*lam*per_ep:.1f} nats per generation")
say(f"     per-class bounty, M={M} manufacturable classes: at most {lam*b*M:.2f} nats over the whole loop")

# ---------------------------------------------------------------- R2
hdr("R2. c is a gain on all flag-related reward gaps (T4.3, T4.4)")
for vs in [0.4, 0.6]:
    for c in [0.0, 1.0]:
        b = (1 + c) / vs - 1 - c
        vbar = float(np.dot(vE, wE))
        JG0_JA = eps * (1 + b + c) * (vs - vbar)          # naive non-flagger
        JA = eps * float(np.dot(wE, vE * (1 + b) - (1 - vE) * c)) + (1 - eps) * 1.0
        JG0 = eps * 1.0 + (1 - eps) * 1.0
        check(f"J(G0)-J(A) = eps(1+b+c)(v*-vbar), v*={vs}, c={c}", JG0_JA, JG0 - JA, 1e-12)
        say(f"     v*={vs}, c={c}: Phi = {phi_m(eps,vE,wE,fN,wN,b,c):.5f}, J(G0)-J(A) = {JG0_JA:.5f}")
say("--- mistaken honest flags: an honest A whose flag is wrong pays c, a G* that flags only when confident does not")
for c in [0.0, 0.5, 1.0]:
    rate_mistaken = 0.005    # per-episode rate of honest-but-mistaken flags
    say(f"     c={c}: extra reward loss of honest A = {rate_mistaken*c:.4f} per episode (vs Phi(0.4,c=0)=0.00225)")
say("--- flag-withholding careful gamer (keeps blind spots open), c = 0, b = 1.5")
b = 1.5
wd = eps * float(np.dot(wE, np.maximum(vE * (1 + b) - 1, 0)))
say(f"     reward lost relative to A: eps E[(v(1+b)-1)^+] = {wd:.5f} per episode -> {n*lam*wd:.1f} nats per generation at n lam = {n*lam:.0f}")

# ---------------------------------------------------------------- R3
hdr("R3. T4.5: judgment-cell share and per-cell validity")
delta = 0.01
perE = np.log(((1 - delta) + delta * vE) / ((1 - delta) * vE + delta))
DB = eps * float(np.dot(perE, wE))
share = eps * wE[2] * perE[2] / DB
say(f"     per-cell nats {perE.round(4)}, drift {DB:.5f}, judgment share {share:.4f}")
check("judgment share = 68.1%", 0.681, share, 5e-4)
for v in [0.95, 0.6, 0.1, 0.03, 0.01]:
    ex = np.log(((1 - delta) + delta * v) / ((1 - delta) * v + delta))
    say(f"     v={v}: exact {ex:.4f} vs -ln v {-np.log(v):.4f}")

# ---------------------------------------------------------------- R4
hdr("R4. T4.6: class patching, exact expected residual")
cls_eps = np.array([0.012, 0.005, 0.0025, 0.0005])
cls_v = np.array([0.95, 0.6, 0.1, 0.0])
n4 = 2000
vstar = 0.4


def resid(K, flags):
    return float(np.sum(cls_eps * (1 - cls_eps * cls_v * flags) ** (K * n4)))


fl_A = np.ones(4); fl_G = (cls_v >= vstar).astype(float)
for K in [1, 2, 5, 20]:
    say(f"     K={K:2d}: residual under A {resid(K, fl_A):.5f}; under G* (v*=0.4) {resid(K, fl_G):.5f}")
say(f"     limits: A -> sum eps_j 1[v_j=0] = {float(np.sum(cls_eps*(cls_v==0))):.5f};  "
    f"G* -> sum eps_j 1[v_j<v*] = {float(np.sum(cls_eps*(cls_v<vstar))):.5f}")
# Monte Carlo of one generation
R = 20000
surv = np.zeros(4)
for j in range(4):
    N = rng.binomial(n4, cls_eps[j], R)
    acc = rng.binomial(N, cls_v[j])
    surv[j] = np.mean(acc == 0)
check("MC one-generation residual under A", resid(1, fl_A), float(np.sum(cls_eps * surv)), 3e-5)
say(f"     Jensen approximation (1-v)^(n eps): {float(np.sum(cls_eps*(1-cls_v)**(n4*cls_eps))):.5f} (exact {resid(1, fl_A):.5f})")
say("--- annealed mixture: class j is flagged at rate eps_j v_j [mu_A + mu_G* 1(v_j >= v*)]")
muA = 0.9
fl_mix = muA + (1 - muA) * fl_G
say(f"     mu_A=0.9, K=5: residual {resid(5, fl_mix):.5f}")

# ---------------------------------------------------------------- R5
hdr("R5. T4.7 under one operator at a time (T1's honeypot example: eps=0.01, a=0.03, h=1, s=0.5)")
e7, a7 = 0.01, 0.03
Lam = np.log((1 - delta) / delta)
vrate = (1 - a7) * e7
# (B), no protocol
s_B0 = 1 - vrate * Lam / (a7 * Lam)
say(f"     (B) no protocol: lambda+ = lambda- = {Lam:.3f}; flip at s = {s_B0:.4f}")
lam_plus = float(np.dot(wE, perE))
s_B1 = 1 - vrate * lam_plus / (a7 * Lam)
say(f"     (B) protocol (b=0): lambda+ = E_E ln(...) = {lam_plus:.4f}; t* = {lam_plus/(lam_plus+Lam):.4f}; flip at s = {s_B1:.4f}")
check("(B) protocol flip s = 0.966", 0.966, s_B1, 5e-4)
# best responder under (B) with honeypots spread in proportion to natural cells
tj = perE / (perE + Lam)
# G* games type j iff p_hat < t_j, p_hat = u/(u+v) common
r = tj.max() / (1 - tj.max())
s_prop = 1 - r * vrate / a7
say(f"     (B) per-type t*_j = {tj.round(4)}; best responder, proportional honeypots: G* gains once s > {s_prop:.4f}")
alloc = wE * perE / np.sum(wE * perE)
say(f"     (B) optimal honeypot allocation across cell types (prop. to w_j lambda+_j): {alloc.round(3)}; best-responder flip then = naive flip = {s_B1:.4f}")
# verify optimal allocation: at s slightly below s_B1, every type has p_hat_j >= t_j
s_test = s_B1 - 1e-4
u_j = a7 * (1 - s_test) * alloc
v_j = vrate * wE
ph = u_j / (u_j + v_j)
check("optimal allocation: min_j (p_hat_j - t*_j) >= 0 just below the flip", 1.0, float(np.all(ph >= tj - 1e-12)), 0)
# (D) with b = 1.5: residual cells are judgment cells (omega = 0.15), gain 1 - v(1+b) = 0.75
om = 0.15
for (Arew, Xrew, label) in [(1.0, -1.0, "A gets 1, caught X gets -1"), (0.25, -1.0, "A gets 0.25, X -1"),
                            (1.0, 0.0, "A gets 1, X gets 0"), (0.25, -2.0, "A 0.25, X -2")]:
    Dp = 1 - 0.1 * (1 + 1.5)
    Dm = Arew - Xrew
    ts = Dp / (Dp + Dm)
    s_D1 = 1 - (ts / (1 - ts)) * vrate * om / a7
    # without protocol under the same honeypot convention: gain 1, caught gap = 1 - Xrew
    ts0 = 1 / (1 + (1 - Xrew))
    s_D0 = 1 - (ts0 / (1 - ts0)) * vrate / a7
    ph1 = a7 * 0.5 / (a7 * 0.5 + vrate * om)
    say(f"     (D) b=1.5, {label}: t* = {ts:.4f}, flip at s = {s_D1:.4f};  no protocol (same convention): "
        f"t* = {ts0:.4f}, flip at s = {s_D0:.4f};  p_hat on residual cells at s=0.5: {ph1:.3f}")

# ---------------------------------------------------------------- R6
hdr("R6. T4.9 routing on both sides")
mm = 50
e = rng.beta(0.3, 6, size=mm)       # H's predictable error towards the false side, per atom (illustrative)
e2 = rng.beta(0.3, 6, size=mm)      # H's predictable error against the truth, per atom (illustrative)
say(f"     illustrative atoms: mean e {e.mean():.4f}, max e {e.max():.4f}; mean e' {e2.mean():.4f}, max e' {e2.max():.4f}")
say(f"     prover routes spurious flags: f = {e.max():.4f};  defender routes valid flags: v = 1 - max e' = {1-e2.max():.4f}")
say(f"     separation needs v >= f: {1-e2.max():.4f} >= {e.max():.4f}")
say("--- randomised decomposition: the protocol draws the decomposition after commitment, so the")
say("    dishonest side can route only among a uniformly random k-subset of atoms (illustrative)")
for kk in [1, 5, 20]:
    sims_f = [np.max(rng.choice(e, kk, replace=False)) for _ in range(20000)]
    sims_v = [1 - np.max(rng.choice(e2, kk, replace=False)) for _ in range(20000)]
    say(f"     k={kk:2d}: E f = {np.mean(sims_f):.4f},  E v = {np.mean(sims_v):.4f}")

# ---------------------------------------------------------------- R7
hdr("R7. T4.11: tail condition and false positives")
for (al, be) in [(4.0, 1.0), (2.0, 2.0)]:
    for mq in [20, 100, 1000]:
        exact = exp(lgamma(al + mq) + lgamma(al + be) - lgamma(al) - lgamma(al + be + mq))
        asym = exp(lgamma(al + be) - lgamma(al)) * mq ** (-be)
        say(f"     Beta({al},{be}) m={mq}: E R^m = {exact:.5f}, asymptotic {asym:.5f}")
say("--- a mixing law bounded away from 1 (R uniform on [0.5, 0.9]) decays exponentially")
for mq in [10, 20, 40]:
    val = (0.9 ** (mq + 1) - 0.5 ** (mq + 1)) / ((mq + 1) * 0.4)
    say(f"     m={mq}: E R^m = {val:.6f}  (0.9^m = {0.9**mq:.6f})")
say("--- false positives on an honest but incoherent model: inconsistency rate phi per framing")
for phi_A in [0.005, 0.01]:
    for mq in [5, 20, 50]:
        fp = 1 - (1 - phi_A) ** mq
        det = 1 - exp(lgamma(4 + mq) + lgamma(5) - lgamma(4) - lgamma(5 + mq))
        say(f"     phi={phi_A}, m={mq}: detect Beta(4,1) liar {det:.3f}; false positive on honest A {fp:.3f}")

# ---------------------------------------------------------------- R8
hdr("R8. T4.15 with passive leniency and spurious reports")


def detect(piA, piG, piC, v, sig, xi, hM, r, tM, ell=0.0):
    post = hM * xi / (hM * xi + r * sig) if (hM * xi + r * sig) > 0 else 0
    dC = (1 - sig) + sig * (post >= tM)
    return v * (1 - ell) * (piA + piG + piC * dC)


for (piC, sig, xi, ell) in [(1.0, 0.9, 0.0, 0.0), (1.0, 0.3, 0.0, 0.0), (1.0, 0.9, 0.5, 0.0),
                            (0.3, 0.9, 0.0, 0.0), (0.3, 0.9, 0.0, 0.2), (1.0, 0.9, 0.5, 0.2)]:
    d = detect(1 - piC, 0.0, piC, 0.9, sig, xi, 0.05, 0.01, 0.3, ell)
    say(f"     pi_C={piC}, sigma_p={sig}, xi={xi}, leniency ell={ell}: d = {d:.4f}")
check("T4.15 diverse monitor pi_C=0.3, ell=0", 0.657, detect(0.7, 0, 0.3, 0.9, 0.9, 0, 0.05, 0.01, 0.3), 5e-4)
say("--- spurious reports by a bonus-paid G-monitor: rate pi_G (1-r) Pr(f_M > v*_M) per item")
for pG, pf in [(0.5, 0.02), (0.5, 0.1)]:
    say(f"     pi_G={pG}, Pr(f_M>v*_M)={pf}: spurious reports {pG*(1-0.01)*pf:.4f} per item vs real attacks 0.01")

# ---------------------------------------------------------------- R9
hdr("R9. T4.17 with T1.13's placement of delta and v_F from the verifier")


def P_on(muA, muG, muC, tC, epsF, pres, d, dF=0.0):
    """T1.13 form: (1-dF)[muA + muC 1(t<=d)] + muG[(1-r)(1-dF) + r dF] + dF muC 1(t>d), r = residual."""
    on_C = muC if tC <= d else 0.0
    off_C = muC if tC > d else 0.0
    rG = epsF * pres
    return (1 - dF) * (muA + on_C) + muG * ((1 - rG) * (1 - dF) + rG * dF) + dF * off_C


muA, muG, muC = 0.9, 0.07, 0.03
chi = 0.5   # certificate share of frontier error cells (checkable by a weaker verifier)


def pres_G(chi, zeta, covered):
    """Pr(v_F < v*) for G's valid frontier flags: certificate cells are covered by any verifier;
    the rest only by a same-generation verifier that is not strategically rejecting (prob 1-zeta)
    and whose acceptance v_s(1-ell) clears v* (covered = 1)."""
    return (1 - chi) * (zeta + (1 - zeta) * (1 - covered))


cases = [("no protocol", 1.0, 0.0),
         ("weaker verifier only (chi=0.5)", 1 - chi, 0.0),
         ("same-weights verifier: zeta=0, d=0.09", pres_G(chi, 0.0, 1), 0.09),
         ("diverse verifier: zeta=0.03, d=0.657", pres_G(chi, 0.03, 1), 0.657),
         ("diverse verifier with leniency ell=0.2: zeta=0.03, d=0.526", pres_G(chi, 0.03, 1), 0.5256)]
for name, pres, d in cases:
    say(f"     {name}: Pr(v_F<v*) = {pres:.4f}; P_on = {P_on(muA, muG, muC, 0.3, 0.2, pres, d):.4f}")
say(f"     diverse verifier, delta_F = 0.02: {P_on(muA, muG, muC, 0.3, 0.2, pres_G(chi, 0.03, 1), 0.657, 0.02):.4f}")
check("T4.17 no-protocol value 0.956", 0.956, P_on(muA, muG, muC, 0.3, 0.2, 1.0, 0.0), 1e-9)

# ---------------------------------------------------------------- R10
hdr("R10. T4.18 with eps_h capped at 1")
eps0, kap, deps = 0.01, 0.15, 0.05
a, s0, sg = 0.03, 0.5, 0.3
nlam = 1000.0


def D(q, k, r0, nu, om, cap=True):
    eh = eps0 * np.exp(kap * k)
    if cap:
        eh = min(eh, 1.0)
    ep = eh + q * deps
    if cap:
        ep = min(ep, 1.0)
    rA = r0 * np.exp(-nu * k)
    rX = min(1.0, r0 * np.exp(om * k))
    rho = (1 - q) * rA + q * rX
    one_minus_s = (1 - s0) * np.exp(-sg * k)          # computed directly: 1 - s underflows otherwise
    return (1 - a * (1 - q)) * ep * rho - a * (1 - q) * one_minus_s   # per unit lambda


def runL(r0, nu, om, L0=3.0, K=200, cap=True, e0=None):
    global eps0
    old = eps0
    if e0 is not None:
        eps0 = e0
    L = L0
    Ls = [L]
    for k in range(K):
        q = 1 / (1 + np.exp(L))
        L = L - nlam * D(q, k, r0, nu, om, cap)
        L = max(min(L, 1e4), -1e4)
        Ls.append(L)
    eps0 = old
    return np.array(Ls)


ksat = np.log(1 / eps0) / kap
say(f"     eps_h reaches 1 at k_sat = ln(1/eps0)/kappa = {ksat:.1f}")
scen = {"S0": (1.0, 0.0, 0.0), "S1": (0.3, 0.3, 0.3), "S2": (0.3, 0.05, 0.3), "S3": (0.3, 0.5, 0.3)}
for name, (r0, nu, om) in scen.items():
    Ls = runL(r0, nu, om)
    pos = [k for k in range(200) if D(0, k, r0, nu, om) > 0]
    first = pos[0] if pos else None
    leak_after = sum(nlam * max(D(0, k, r0, nu, om), 0) for k in range(200))
    say(f"     {name}: first k with D_k(0)>0: {first}; L_13 = {Ls[13]:.2f}; L_50 = {Ls[50]:.2f}; "
        f"L_200 = {Ls[200]:.2f}; total positive leak over k<200 = {leak_after:.2f} nats")
Ls1 = runL(0.3, 0.3, 0.3)
check("S1 levels off: L_200 - L_30", 0.0, Ls1[200] - Ls1[30], 0.5)
say(f"     S1: max L = {Ls1.max():.2f} at k = {int(np.argmax(Ls1))}; L_200 = {Ls1[200]:.2f}")
# summability bound: gross leak <= nlam (1-a) eps0 r0 / (1 - e^{kappa-nu}) for the uncapped phase
bound = nlam * (1 - a) * eps0 * 0.3 / (1 - np.exp(kap - 0.3))
say(f"     S1 gross-leak bound nlam(1-a)eps0 r0/(1-e^(kappa-nu)) = {bound:.2f} nats")
# long-run sign with cap: (1-a) r0 e^{-nu k} vs a(1-s0) e^{-sigma k}
say("--- referee's counterexample: eps0 = r0 = 0.01, nu = 0.4 < kappa + sigma = 0.45")
r0c, nuc = 0.01, 0.4
eps0_old = eps0
eps0 = 0.01
kc_uncapped = np.log(a * (1 - s0) / ((1 - a) * eps0 * r0c)) / (kap - nuc + sg)
neg_capped = all(D(0, k, r0c, nuc, 0.3, cap=True) < 0 for k in range(2001))
neg_uncapped_first = next((k for k in range(2001) if D(0, k, r0c, nuc, 0.3, cap=False) > 0), None)
say(f"     uncapped k_c = {kc_uncapped:.1f} (first positive uncapped k = {neg_uncapped_first}); "
    f"capped: D_k(0) < 0 for all k <= 2000: {neg_capped}")
eps0 = eps0_old
check("counterexample: capped D_k(0) never positive", 1.0, float(neg_capped), 0)
say("--- slope at q = 0 and secant D(1) - D(0), per unit lambda")
for k in [0, 5, 10]:
    h = 1e-6
    sl_p = (D(h, k, 0.3, 0.3, 0.3) - D(0, k, 0.3, 0.3, 0.3)) / h
    sl_n = (D(h, k, 1.0, 0.0, 0.0) - D(0, k, 1.0, 0.0, 0.0)) / h
    se_p = D(1, k, 0.3, 0.3, 0.3) - D(0, k, 0.3, 0.3, 0.3)
    se_n = D(1, k, 1.0, 0.0, 0.0) - D(0, k, 1.0, 0.0, 0.0)
    say(f"     k={k:2d}: slope at 0: protocol {sl_p:.5f}, none {sl_n:.5f};  secant: protocol {se_p:.5f}, none {se_n:.5f};"
        f"  D(0): protocol {D(0,k,0.3,0.3,0.3):.6f}, none {D(0,k,1.0,0,0):.6f}")
say("--- linear-in-odds tail: once D_k(0) -> 0, L declines at about n lam q dD/dq, q ~ e^{-L}")
k = 199
h = 1e-6
sl = (D(h, k, 0.3, 0.3, 0.3) - D(0, k, 0.3, 0.3, 0.3)) / h
say(f"     S1 at k=199: dD/dq = {sl:.4f}; decline per generation at L=38.7: {nlam*sl*np.exp(-38.7):.3e} nats")

say("")
say("--- R10b. Leak-budget survival bound: B = sup_{k,q} (D_k(q) - D_k(0))/q, per unit lambda")
qs = np.linspace(1e-6, 1, 2001)
B = max(max((D(q, k, 0.3, 0.3, 0.3) - D(0, k, 0.3, 0.3, 0.3)) / q for q in qs) for k in range(0, 200))
lam_ = 0.05
n_ = nlam / lam_
Splus = sum(nlam * max(D(0, k, 0.3, 0.3, 0.3), 0) for k in range(11, 2000))
Mk = Ls1[11]
say(f"     S1: B = {B:.4f} per unit lambda, n lam B = {nlam*B:.1f}; M = L_11 = {Mk:.2f}; S_+ from k=11 = {Splus:.2f}")
say(f"     guaranteed generations above M - S_+ - 1 = {Mk-Splus-1:.2f}: e^(M-S_+-1)/(n lam B) = {np.exp(Mk-Splus-1)/(nlam*B):.3e}")

say("")
say(f"TOTAL: {n_checks} checks, {n_bad} mismatches")
with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write("\n".join(out) + "\n")
