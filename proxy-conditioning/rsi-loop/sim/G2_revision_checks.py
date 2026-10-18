"""Revision checks for drafts/G2-learning.md (response to G2-learning-referee.md).

Sections S11..S22 extend S1..S10 of G2_checks.py.  Same worked-example constants:
  T1 honeypot design, eps=0.01, a=0.03, h=1, 1-s0=m0=0.5, lam+=lam-=Lambda=ln 99,
  read as operator (D) with Delta/beta = ln 99 (penalty-bearing gradients).
All learning yields are illustrative free parameters.
Run:  python3 G2_revision_checks.py   (writes G2_revision_checks_output.txt)
"""
import numpy as np
from scipy.special import expit
from scipy.integrate import solve_ivp
from scipy.optimize import brentq, minimize_scalar

out = []


def P(*a):
    s = " ".join(str(x) for x in a)
    out.append(s)
    print(s, flush=True)


LAM = np.log(99.0)
EPS, A, H, M0NR = 0.01, 0.03, 1.0, 0.5
AH = A * H
U0 = AH * M0NR
V = (1 - A) * EPS
M0 = np.log(U0 / V)


def bank_fn(M):
    return M - 1 + np.exp(-M)


# ---------------------------------------------------------------- S11
P("=" * 78)
P("S11. Additive law, corrected justification.")
P("  (a) Linear parametrisation of non-recognition m, expected gradient: dm/dn = -lr*ah*Dm")
P("      (per episode).  Caught rate ah*m.  Total caught = m0^2/(2 lr Dm), free of ah.")
lrDm = 0.01
for ah in [0.003, 0.03, 0.3]:
    # integrate dNc/dn = ah m, dm/dn = -lrDm*ah until m=0
    T = M0NR / (lrDm * ah)
    ns = np.linspace(0, T, 200001)
    m = M0NR - lrDm * ah * ns
    Nc = np.trapezoid(ah * m, ns)
    P(f"      ah={ah:<6}: total caught={Nc:.3f}; formula m0^2/(2 lr Dm)={M0NR**2/(2*lrDm):.3f}; "
      f"episodes to exhaust={T:.0f}")
P("  (b) Template memorisation: J equiprobable audit templates, each caught template is")
P("      learned for good.  Non-recognition drops by m0/J per catch: exactly additive, total J.")

# ---------------------------------------------------------------- S12
P("=" * 78)
P("S12. Non-recognition floor.  m(R) = m_fl + (m0-m_fl) e^{-R}; caught rate ah*m(R);")
P("     dR/dn = varpi*ah*m(R) (shared clock).  Closed form: e^R = [m0 e^{varpi ah m_fl n} - (m0-m_fl)]/m_fl.")
P("     L(n)-L0 = (lam-/varpi) R(n) - lam+ v n.  Long-run slope lam(ah m_fl - v).")
vp = 0.1
for mfl in [0.0, 0.1, 0.2, 0.4]:
    def Rcf(n):
        if mfl == 0:
            return np.log1p(vp * AH * M0NR * n)
        return np.log((M0NR * np.exp(vp * AH * mfl * n) - (M0NR - mfl)) / mfl)

    def rhs(n, y):
        return [vp * AH * (mfl + (M0NR - mfl) * np.exp(-y[0]))]
    sol = solve_ivp(rhs, [0, 50000], [0.0], t_eval=[500, 5000, 50000], rtol=1e-10, atol=1e-12)
    vals = []
    for i, nn in enumerate([500, 5000, 50000]):
        Lcf = LAM / vp * Rcf(nn) - LAM * V * nn
        Lode = LAM / vp * sol.y[0, i] - LAM * V * nn
        vals.append(f"n={nn}: {Lcf:9.2f} (ODE {Lode:9.2f})")
    ratio = AH * mfl / V
    slope = LAM * (AH * mfl - V)
    P(f"  m_fl={mfl:.1f} (floor ratio ah m_fl lam-/(v lam+)={ratio:.2f}, long-run slope {slope:+.5f}): "
      + "; ".join(vals))
P("  Large-n form: N_c ~ ah m_fl n + (1/varpi) ln(m0/m_fl).")

# ---------------------------------------------------------------- S13
P("=" * 78)
P("S13. Doubling a under T1's parametrisation v=(1-a) eps (varpi=0.1, no floor):")
for nn in [500, 5000, 50000]:
    def L(a):
        u0 = a * H * M0NR
        v = (1 - a) * EPS
        return LAM / vp * np.log1p(vp * u0 * nn) - LAM * v * nn
    tot = L(2 * A) - L(A)
    disp = LAM * A * EPS * nn
    P(f"  n={nn:6d}: doubling a adds {tot:7.2f} nats, of which displacement lam+ a eps n = {disp:6.2f}")

# ---------------------------------------------------------------- S14
P("=" * 78)
P("S14. Remark 0.2: filtering operators.  Caught samples carry no gradient (varpi_R=0);")
P("     recognition grows on kept samples, dR/dn = varpi' v.  Turn at n=M0/(varpi' v);")
P("     bank = (lam+/varpi')(e^{M0}-1-M0)  [using lam- u0/v = lam+ e^{M0}].")
for vpp in [0.01, 0.1]:
    nt = M0 / (vpp * V)
    bank = LAM / vpp * (np.exp(M0) - 1 - M0)
    ns = np.linspace(0, nt, 100001)
    num = np.trapezoid(LAM * U0 * np.exp(-vpp * V * ns) - LAM * V, ns)
    P(f"  varpi'={vpp}: n_turn={nt:8.1f}, bank formula={bank:7.2f}, numerical={num:7.2f}; "
      f"compare (B)-free gradient case (lam-/varpi)B(M0) at varpi=varpi': {LAM/vpp*bank_fn(M0):7.2f}")

# ---------------------------------------------------------------- S15
P("=" * 78)
P("S15. G2.3 with v(n)=c/(n+100), varpi=0.1: minimum of L at c=8, and boundary case c=10.")
for c in [8.0, 10.0]:
    def Lfun(n):
        return LAM / vp * np.log1p(vp * U0 * n) - LAM * c * np.log((n + 100) / 100)
    res = minimize_scalar(lambda x: Lfun(np.exp(x)), bounds=(0, 25), method="bounded")
    P(f"  c={c}: min L = {res.fun:7.2f} at n = {np.exp(res.x):9.0f}; L at 1e6,1e9,1e12 = "
      + ", ".join(f"{Lfun(x):8.2f}" for x in [1e6, 1e9, 1e12]))

# ---------------------------------------------------------------- S16
P("=" * 78)
P("S16. G2.6 equality case and graded concealment.")
lp, lm = 1.0, 3.0
ts = lp / (lp + lm)
w = 0.05
tpr = 0.6


def conceal_ode(tprc, vT, c0, L0, T):
    def rhs(n, y):
        L, Hh = y
        p = expit(-L)
        c = expit(Hh)
        det = tpr * (1 - c) + tprc * c
        return [w * p * (1 - p) * (lp + lm) * (det - ts), w * p * vT * (tpr - tprc) * c * (1 - c)]
    return solve_ivp(rhs, [0, T], [L0, np.log(c0 / (1 - c0))], t_eval=[1e3, 1e5, 1e7, 1e9, 1e11],
                     rtol=1e-10, atol=1e-12, method="LSODA")


sol = conceal_ode(ts, 40.0, 0.01, 0.0, 1e11)
P("  tpr_c = t* = 0.25 (Bernoulli concealment, varpi_T=40, c_init=0.01, L0=0):")
P("    L at n=1e3,1e5,1e7,1e9,1e11: " + ", ".join(f"{x:.3f}" for x in sol.y[0]) + "  (grows, slowly)")
P("  Equality case, event-space identity (small q): dL/dH = (lp+lm)(tpr-t*)/(varpi_T b c), so")
P("  L-L0 = k[(H - e^-H) - (H0 - e^-H0)], k=(lp+lm)(tpr-t*)/(varpi_T (tpr-tpr_c)); L -> inf like k/(k+1) ln n.")
sol6 = conceal_ode(ts, 40.0, 0.01, 6.0, 1e15)
kk = (lp + lm) * (tpr - ts) / (40.0 * (tpr - ts))
H0 = np.log(0.01 / 0.99)
for i in range(len(sol6.t)):
    Hn = sol6.y[1, i]
    pred = kk * ((Hn - np.exp(-Hn)) - (H0 - np.exp(-H0)))
    P(f"    L0=6, n={sol6.t[i]:.0e}: L-L0={sol6.y[0,i]-6:.3f}, identity {pred:.3f}, H={Hn:.2f}")
sol = conceal_ode(0.3, 40.0, 0.01, 0.0, 1e11)
P("  tpr_c = 0.3 > t*: L at n=1e3..1e11: " + ", ".join(f"{x:.2f}" for x in sol.y[0]) + "  (~ ln n)")
P("  Graded concealment: mean level mu in [0,1], det(mu) = tpr - b mu, b = tpr - tpr_c;")
P("  Gaussian-policy REINFORCE: dmu/dN_g = varpi_G b  (no factor of the concealment probability).")
P("  Turn at mu_turn=(tpr-t*)/b after N=(tpr-t*)/(varpi_G b^2) gaming events; since dL/dN_g")
P("  falls linearly from S to 0 along the path, bank = S*N/2 = (lp+lm)(tpr-t*)^2/(2 varpi_G b^2).")
tprc = 0.1
b = tpr - tprc
for vG in [0.05, 0.4]:
    S = (lp + lm) * (tpr - ts)
    N = (tpr - ts) / (vG * b ** 2)
    BG = S * N / 2

    def rhs(n, y):
        L, mu = y
        p = expit(-L)
        det = tpr - b * min(mu, 1.0)
        return [w * p * (1 - p) * (lp + lm) * (det - ts), w * p * vG * b * (mu < 1.0)]

    def ev(n, y):
        return tpr - b * y[1] - ts
    ev.terminal = True
    for L0 in [0.0, 4.0]:
        s = solve_ivp(rhs, [0, 1e14], [L0, 0.0], events=ev, rtol=1e-10, atol=1e-12, method="LSODA")
        P(f"    varpi_G={vG}: bank formula {BG:6.2f} nats; ODE L-L0 at turn (L0={L0}) = {s.y[0,-1]-L0:6.2f}; "
          f"Bernoulli bank with c_init=0.01, varpi_T=varpi_G: {S/(vG*b*0.01):8.1f}")

# ---------------------------------------------------------------- S17
P("=" * 78)
P("S17. G2.9 exact best-of-k entrenchment under (C) with softness delta=0.01.")
P("     entrench iff (1-x)^k ln((1-x)/delta) > (1-(1-x)^k) ln((1-delta)/x).")
d = 0.01
for x in [0.01, 0.05, 0.1, 0.2]:
    ks = [k for k in range(1, 400)
          if (1 - x) ** k * np.log((1 - x) / d) > (1 - (1 - x) ** k) * np.log((1 - d) / x)]
    kmax = max(ks) if ks else 0
    approx = np.log(2) / (-np.log(1 - x))
    P(f"  x_I={x:4.2f}: entrenches for k <= {kmax:3d}; old +-Lambda formula threshold {approx:6.2f}")

# ---------------------------------------------------------------- S18
P("=" * 78)
P("S18. Selecting 1 of k runs by a detector (independent runs, gamer probability q=0.1).")
q = 0.1


def gain_noisy(k, r, f):
    # pick uniformly among unflagged runs if any, else uniformly among all
    pu_g, pu_a = 1 - r, 1 - f
    pu = q * pu_g + (1 - q) * pu_a
    p_none = (1 - pu) ** k
    # P(selected is gamer) = P(some unflagged)*q pu_g/pu + P(none)*P(gamer | flagged)
    pf = 1 - pu
    pg_flag = q * r / pf if pf > 0 else 0.0
    pg = (1 - p_none) * q * pu_g / pu + p_none * pg_flag
    return np.log((1 - pg) / pg) - np.log((1 - q) / q)


for k in [2, 4, 16, 256]:
    perfect = np.log((1 - q ** k) / q ** k) - np.log((1 - q) / q)
    P(f"  k={k:3d}: ln k={np.log(k):5.2f}; perfect detector log-odds gain={perfect:6.2f}; "
      f"noisy (tpr 0.9, fpr 0.1) gain={gain_noisy(k, 0.9, 0.1):5.2f} (cap ln((1-f)/(1-r))={np.log(9):.2f})")
P("  Probability of the event 'selected run is an undetected evader' rises by at most k.")
for k in [2, 4, 16]:
    # evader: gamer that the detector misses w.p. 1 (detector blind to it), share e of runs
    e = 0.01
    pu = e + (1 - q) * 0.9 + (q - e) * 0.1
    p_none = (1 - pu) ** k
    p_sel = (1 - p_none) * e / pu
    P(f"    k={k:2d}: evader share 0.01 -> selected {p_sel:.4f} (ratio {p_sel/e:.2f}, bound k={k})")

# ---------------------------------------------------------------- S19
P("=" * 78)
P("S19. G2.10 with a floor: break-even rewarded rate v* = A(n)/(lam+ n), varpi=0.1, ah=0.03, m0=0.5.")
for mfl in [0.0, 0.05, 0.2]:
    row = []
    for nn in [500, 5000, 50000, 500000]:
        if mfl == 0:
            Rn = np.log1p(vp * AH * M0NR * nn)
        else:
            Rn = np.log((M0NR * np.exp(vp * AH * mfl * nn) - (M0NR - mfl)) / mfl) if vp * AH * mfl * nn < 600 \
                else vp * AH * mfl * nn + np.log(M0NR / mfl)
        row.append(f"n={nn}: {Rn/vp/nn:.2e}")
    P(f"  m_fl={mfl:4.2f}: v* = " + "; ".join(row) + f"  (limit ah m_fl = {AH*mfl:.2e})")
P("  Common scale-up by alpha of lam and varpi: separable audit term / rewarded cost, n=5000, varpi=0.1:")
for al in [1, 4, 16]:
    sep = LAM / vp * np.log1p(al * vp * U0 * 5000)
    rew = al * LAM * V * 5000
    P(f"    alpha={al:2d}: separable term {sep:7.1f}, rewarded cost {rew:8.1f}, ratio {sep/rew:.3f}")
P("  G2.10.1 clamp example: R_gap=0.1, Y=-0.3, X=varpi ah n=1.5: f(0) = "
  f"{0.1 - 0.3*np.log1p(1.5):.3f} < 0, so the map needs max(0, f).")

# ---------------------------------------------------------------- S20
P("=" * 78)
P("S20. Kernel form of the exchange rate (tangent model, exact for linear-in-parameter logits).")
rng = np.random.default_rng(3)
for alpha in [0.2, 0.5, 0.9]:
    dim = 50
    phr = rng.normal(size=dim)
    pha = alpha * phr + np.sqrt(1 - alpha ** 2) * rng.normal(size=dim)
    k_ra, k_aa = phr @ pha, pha @ pha
    lr, Dm = 1e-3, 1.0
    wgt = -lr * Dm * pha             # caught-event step: lower the audit gaming logit
    dL = -(wgt @ phr)                # ledger = minus real gaming logit
    dR = wgt @ phr - wgt @ pha       # recognition = real logit minus audit logit
    P(f"  mixing {alpha}: dL/dR = {dL/dR:.4f}; k_ra/(k_aa-k_ra) = {k_ra/(k_aa-k_ra):.4f}; "
      f"kernel correlation k_ra/k_aa = {k_ra/k_aa:.3f}")

P("=" * 78)
P("S21. Bayes clock: posterior share at the critical L0 (G2.4).")
for L0c in [-3.772, 0.773, 2.004]:
    P(f"  critical L0={L0c:+.3f}: gamer posterior share sigma(-L0) = {expit(-L0c):.4f}")
P("S22. Units of S5: D* in reward units x Lambda = nats under (D) with Delta/beta = Lambda.")
for Dr in [0.00436, 0.00116]:
    P(f"  {Dr} reward units -> {Dr*LAM:.4f} nats")

open(__file__.replace(".py", "_output.txt"), "w").write("\n".join(out) + "\n")
