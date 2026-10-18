"""Checks for drafts/G2-learning.md (learning, not just selection).

Sections S1..S10 correspond to the claims G2.1..G2.10 in the draft.
Worked-example parameters follow T1's honeypot example:
  eps=0.01, a=0.03, h=1, s0=0.5, delta=0.01, operator (B): lam+=lam-=Lambda=ln(99)=4.595
  => u0 = a h (1-s0) = 0.015 caught-opportunities/episode, v = (1-a) eps = 0.0097.
All numbers are illustrative; the learning yields (varpi) are free parameters.
Run:  python3 G2_checks.py > G2_checks_output.txt
"""
import numpy as np
from scipy.special import expit
from scipy.integrate import solve_ivp
from scipy.optimize import brentq
from scipy.stats import norm

rng = np.random.default_rng(7)
out = []


def P(*a):
    s = " ".join(str(x) for x in a)
    out.append(s)
    print(s, flush=True)


LAM = np.log(99.0)
U0 = 0.03 * 1 * 0.5
V = (1 - 0.03) * 0.01
M0 = np.log(U0 * LAM / (V * LAM))


def bank_fn(M):
    return M - 1 + np.exp(-M)


P("=" * 78)
P("S0. Worked-example constants")
P(f"Lambda={LAM:.4f} u0={U0} v={V:.4f} audit margin M0=ln(u0 lam-/(v lam+))={M0:.4f}")
P(f"bank function B(M0)=M0-1+exp(-M0)={bank_fn(M0):.4f}; small-M approx M0^2/2={M0**2/2:.4f}")

# ---------------------------------------------------------------- S1
P("=" * 78)
P("S1. Additive law: each caught event lowers non-recognition m=1-s by varpi_A.")
P("    Claim: total caught events = ceil(m0/varpi_A), independent of the audit rate.")
m0, vA = 0.5, 0.05
for ap in [0.003, 0.03, 0.3]:
    tots, times = [], []
    for rep in range(2000):
        m, n, N = m0, 0, 0
        # jump directly between events: waiting time geometric with p = ap*m
        while m > 1e-12:
            n += rng.geometric(ap * m)
            N += 1
            m -= vA
        tots.append(N)
        times.append(n)
    harm = sum(1 / (ap * (m0 - j * vA)) for j in range(int(round(m0 / vA))))
    P(f"  audit-opportunity rate a h={ap:<6}: caught total mean={np.mean(tots):.3f} "
      f"(sd {np.std(tots):.3f}); mean episodes to exhaust={np.mean(times):9.0f}, "
      f"harmonic formula={harm:9.0f}")
P(f"  prediction m0/varpi_A = {m0/vA:.1f}")

# ---------------------------------------------------------------- S2
P("=" * 78)
P("S2. Multiplicative law (gradient on a recognition logit): each caught event")
P("    multiplies m by exp(-varpi).  Mean field: N_c(n)=ln(1+varpi u0 n)/varpi;")
P("    ledger L(n)-L0 = (lam-/varpi) ln(1+varpi u0 n) - lam+ v n;")
P("    turn at n_turn=(e^M0-1)/(varpi u0); max bank=(lam-/varpi) B(M0).")
for vp in [0.01, 0.1, 1.0]:
    nturn = (np.exp(M0) - 1) / (vp * U0)
    bank = LAM / vp * bank_fn(M0)
    # stochastic Monte Carlo, operator (B): +-Lambda per event
    R = 4000
    nmax = int(min(6 * nturn + 2000, 60000))
    grid = np.unique(np.linspace(0, nmax, 301).astype(int))
    Ls = np.zeros((R, len(grid)))
    Ncs = np.zeros((R, len(grid)))
    for r in range(R):
        Rk, Nc, Nr = 0.0, 0, 0
        L = 0.0
        gi = 0
        # per-episode simulation vectorised over chunks is awkward; use event-time sim
        n = 0
        rec = []
        # simulate as competing Poisson processes in continuous time (small rates)
        t = 0.0
        while True:
            rc = U0 * np.exp(-Rk)
            tot = rc + V
            dt = rng.exponential(1 / tot)
            while gi < len(grid) and grid[gi] < t + dt:
                Ls[r, gi] = LAM * (Nc - Nr)
                Ncs[r, gi] = Nc
                gi += 1
            if gi >= len(grid):
                break
            t += dt
            if rng.random() < rc / tot:
                Nc += 1
                Rk += vp
            else:
                Nr += 1
    meanL = Ls.mean(0)
    mfL = LAM / vp * np.log1p(vp * U0 * grid) - LAM * V * grid
    mfNc = np.log1p(vp * U0 * grid) / vp
    i_mf = np.argmax(mfL)
    P(f"  varpi={vp:<5}: n_turn formula={nturn:8.1f}, mean-field argmax={grid[i_mf]:6d}; "
      f"max bank formula={bank:7.3f}, mean-field max={mfL[i_mf]:7.3f}, "
      f"MC max of E[L]={meanL.max():7.3f} at n={grid[np.argmax(meanL)]}")
    j = np.searchsorted(grid, int(nturn))
    P(f"        E[N_c] at n~n_turn: MC={Ncs[:, j].mean():7.2f}, mean field={mfNc[j]:7.2f}, "
      f"ln(e^M0)/varpi={M0/vp:7.2f}")
    for nn in [500, 5000]:
        jj = np.searchsorted(grid, nn)
        if jj < len(grid):
            P(f"        n={grid[jj]:5d}: E[L]-L0 MC={meanL[jj]:8.2f}, formula={mfL[jj]:8.2f}; "
              f"no-learning n(u0-v)Lambda={grid[jj]*(U0-V)*LAM:8.2f}")

P("  Persistence with decaying rewarded rate v(n)=c/(n+n0), n0=100, varpi=0.1:")
P("  restoring persists (L->+inf) iff c*lam+ < lam-/varpi (here c < 10).")
vp = 0.1
for c in [2.0, 8.0, 12.0, 30.0]:
    def rhs(n, y):
        L, Rk = y
        return [LAM * U0 * np.exp(-Rk) - LAM * c / (n + 100), vp * U0 * np.exp(-Rk)]
    sol = solve_ivp(rhs, [0, 1e9], [0, 0], t_eval=[1e3, 1e5, 1e7, 1e9], rtol=1e-8, atol=1e-10)
    P(f"    c={c:5.1f}: L at n=1e3,1e5,1e7,1e9 = " + ", ".join(f"{x:8.2f}" for x in sol.y[0]))

# ---------------------------------------------------------------- S3
P("=" * 78)
P("S3. Bayes clock: ledger moves at the counterfactual rate, the gamer learns only")
P("    on its own realised events (share q=sigmoid(-L)).  Claim: selection wins")
P("    forever iff (varpi/lam-) ln(1+e^{-L0}) < B(M0).")
for vp in [0.1, 1.0, 3.0]:
    def fate(L0):
        def rhs(n, y):
            L, Rk = y
            return [LAM * U0 * np.exp(-Rk) - LAM * V, vp * expit(-L) * U0 * np.exp(-Rk)]
        ev = lambda n, y: y[0] + 30
        ev.terminal = True
        sol = solve_ivp(rhs, [0, 2e6], [L0, 0], events=ev, rtol=1e-9, atol=1e-11)
        return sol.y[0, -1]
    # analytic critical L0
    target = bank_fn(M0) * LAM / vp
    if target < np.log(2) * 50:
        Lc = -np.log(np.expm1(target)) if target < 50 else -np.inf
    P(f"  varpi={vp}: analytic critical L0 = {Lc:7.3f}")
    for L0 in [Lc - 0.3, Lc + 0.3]:
        P(f"     L0={L0:7.3f}: L at end of run = {fate(L0):9.2f}")

# ---------------------------------------------------------------- S4
P("=" * 78)
P("S4. Gradient model in one network: gaming logits theta (real inputs) and")
P("    theta-psi (audit inputs); expected REINFORCE with step sizes c0, c1.")
P("    Claim (small-pi limit): max bank in -theta = (c0/c1) B(M0), M0=ln(ah e^{-psi0} Dm/(v Dp)).")
Dp = Dm = 1.0
ah = 0.03
for th0 in [-6.0, -2.0, 0.0]:
    for (c0, c1) in [(1.0, 1.0), (1.0, 0.25), (1.0, 0.0)]:
        psi0 = np.log(2.0)

        def rhs(n, y):
            th, ps = y
            pr = expit(th)
            pa = expit(th - ps)
            return [c0 * (V * Dp * pr * (1 - pr) - ah * Dm * pa * (1 - pa)),
                    c1 * ah * Dm * pa * (1 - pa)]
        T = 4e6
        sol = solve_ivp(rhs, [0, T], [th0, psi0], dense_output=True, rtol=1e-9, atol=1e-12,
                        method="LSODA")
        ts = np.concatenate([np.linspace(0, 1e4, 2001), np.geomspace(1e4, T, 2000)])
        th = sol.sol(ts)[0]
        bank = th0 - th.min()
        Mg = np.log(ah * np.exp(-psi0) * Dm / (V * Dp))
        pred = (c0 / c1) * bank_fn(Mg) if c1 > 0 else np.inf
        P(f"  theta0={th0:5.1f} c0/c1={c0}/{c1}: max bank={bank:8.3f} (pred {pred:7.3f}); "
          f"gaming prob on real at n=4e6: {expit(th[-1]):.4f}")

# ---------------------------------------------------------------- S5
P("=" * 78)
P("S5. ROC version: logistic gaming policy sigma(th0 - th1 z) on a binormal feature")
P("    (real z~N(0,1), synthetic audits z~N(d',1)); a fraction c_r of audits are")
P("    perturbed real episodes (z~N(0,1)).  Expected policy gradient, Dp=Dm=1.")
zg = np.linspace(-8, 12, 4001)
dz = zg[1] - zg[0]


def run_roc(dprime, cr, ahh, v, steps=200000, lr=40.0, th=(-1.0, 0.0)):
    fr = norm.pdf(zg)
    fa = cr * norm.pdf(zg) + (1 - cr) * norm.pdf(zg, dprime)
    w = v * fr - ahh * fa  # net reward weight per unit gaming at z
    th0, th1 = th
    traj = []
    for k in range(steps):
        p = expit(th0 - th1 * zg)
        g = w * p * (1 - p) * dz
        g0 = g.sum()
        g1 = -(g * zg).sum()
        th0 += lr * g0
        th1 += lr * g1
        if k % 20000 == 0 or k == steps - 1:
            preal = (fr * expit(th0 - th1 * zg)).sum() * dz
            traj.append((k, th0, th1, preal))
    p = expit(th0 - th1 * zg)
    Dpol = (w * p).sum() * dz
    Dstar = np.clip(w, 0, None).sum() * dz
    return traj, Dpol, Dstar


for dprime, cr in [(1.9, 0.0), (1.9, 0.5), (1.9, 0.2)]:
    traj, Dpol, Dstar = run_roc(dprime, cr, ahh=0.03, v=0.0097)
    auc = norm.cdf(dprime / np.sqrt(2))
    P(f"  d'={dprime} (AUC {auc:.2f}), c_r={cr}: learned-policy drift {Dpol:.5f} per episode, "
      f"best-responder D* {Dstar:.5f}; c_r*ah/v={cr*0.03/0.0097:.2f}")
    P("     (step, th0, th1, P(game | real)): " +
      "; ".join(f"({k},{a:.2f},{b:.2f},{c:.3f})" for k, a, b, c in traj[::2]))
P("  Learnable separation: d' grows by varpi_d per caught event, best responder.")
P("  caught rate = ah*Phi(-d'/2 - M/d'), M=ln(ah lam-/(v lam+)); total caught grows ~ sqrt(log n).")
Mb = np.log(0.03 / 0.0097)
for vd in [0.0, 0.05, 0.2]:
    def rhs(n, y):
        d = 1.0 + vd * y[0]
        return [0.03 * norm.cdf(-d / 2 - Mb / d)]
    sol = solve_ivp(rhs, [0, 1e8], [0.0], t_eval=[1e3, 1e4, 1e5, 1e6, 1e7, 1e8], rtol=1e-8)
    P(f"   varpi_d={vd}: N_c at n=1e3..1e8: " + ", ".join(f"{x:8.1f}" for x in sol.y[0]))

# ---------------------------------------------------------------- S6
P("=" * 78)
P("S6. Concealment vs selection (gradient form).  Gaming prob p=sigmoid(-L);")
P("    given gaming, conceal w.p. c=sigmoid(H).  Detection det=tpr(1-c)+tpr_c c.")
P("    dL/dn = w p(1-p)(lp+lm)(det-t*),  dH/dn = w p varpi_T (tpr-tpr_c) c(1-c).")
P("    Closed form (small p, small c_init): takeover after N_b=1/(varpi_T (tpr-tpr_c) c_init)")
P("    gaming events; horizon n_b=(e^{B_T}-1)/(k w q0), B_T=k N_b, k=(lp+lm)(tpr-t*).")
lp, lm = 1.0, 3.0
ts_ = lp / (lp + lm)
w = 0.05
for (tpr, tprc, vT, cinit, L0) in [(0.6, 0.1, 1.0, 1e-2, 0.0), (0.6, 0.1, 10.0, 1e-2, 0.0),
                                    (0.6, 0.1, 20.0, 1e-2, 0.0), (0.6, 0.1, 40.0, 1e-2, 0.0),
                                    (0.6, 0.1, 40.0, 1e-2, 4.0), (0.6, 0.1, 20.0, 1e-2, 4.0),
                                    (0.6, 0.1, 40.0, 1e-3, 0.0), (0.6, 0.3, 40.0, 1e-2, 0.0)]:
    H0 = np.log(cinit / (1 - cinit))
    k = (lp + lm) * (tpr - ts_)
    Nb = 1 / (vT * (tpr - tprc) * cinit)
    BT = k * Nb
    q0 = expit(-L0)
    nb = np.expm1(BT) / (k * w * q0) if BT < 600 else np.inf

    def rhs(n, y):
        L, H = y
        p = expit(-L)
        c = expit(H)
        det = tpr * (1 - c) + tprc * c
        return [w * p * (1 - p) * (lp + lm) * (det - ts_), w * p * vT * (tpr - tprc) * c * (1 - c)]

    def ev(n, y):
        c = expit(y[1])
        return tpr * (1 - c) + tprc * c - ts_
    ev.terminal = True
    if np.isfinite(nb) and nb < 1e14:
        sol = solve_ivp(rhs, [0, 1e15], [L0, H0], events=ev, rtol=1e-10, atol=1e-12, method="LSODA")
        nturn = sol.t_events[0][0] if len(sol.t_events[0]) else np.inf
        Lpk = sol.y[0, -1]
        P(f"  tpr={tpr} tpr_c={tprc} varpi_T={vT} c_init={cinit} L0={L0}: B_T={BT:7.2f} nats, "
          f"n_b formula={nb:10.3e}, ODE turn={nturn:10.3e}, L-L0 at turn={Lpk-L0:6.2f}")
    else:
        P(f"  tpr={tpr} tpr_c={tprc} varpi_T={vT} c_init={cinit}: B_T={BT:7.2f}; n_b formula ~ e^{BT:.0f} (beyond any run)")
P("  If tpr_c >= t* the takeover never reverses the drift: check tpr_c=0.3 > t*=0.25:")
def rhs(n, y, tpr=0.6, tprc=0.3, vT=40.0):
    L, H = y
    p = expit(-L); c = expit(H)
    det = tpr * (1 - c) + tprc * c
    return [w * p * (1 - p) * (lp + lm) * (det - ts_), w * p * vT * (tpr - tprc) * c * (1 - c)]
sol = solve_ivp(rhs, [0, 1e9], [0.0, np.log(0.01/0.99)], t_eval=[1e3, 1e5, 1e7, 1e9], rtol=1e-9, atol=1e-12, method="LSODA")
P("    L at n=1e3,1e5,1e7,1e9: " + ", ".join(f"{x:.2f}" for x in sol.y[0]) + "; c at end: " + f"{expit(sol.y[1,-1]):.3f}")
P("  KL-anchored optimum (T1 operator (D) at its fixed point): honest iff for the concealed")
P("  strategy  lam+(1-tpr_c) - lam- tpr_c <= K_c ln2  (nats, reward/beta units).")
P("  Example in reward/beta units lam+=5, lam-=15 (t*=0.25), fixed-reference KL:")
for K_c in [2, 5, 10]:
    tc_crit = (5 - K_c * np.log(2)) / 20
    P(f"    K_c={K_c:2d} bits: honest iff tpr_c >= {max(tc_crit, 0):.3f}")
P("    and with the KL coefficient doubled (lam+=2.5, lam-=7.5):")
for K_c in [2, 5]:
    tc_crit = (2.5 - K_c * np.log(2)) / 10
    P(f"    K_c={K_c:2d} bits: honest iff tpr_c >= {max(tc_crit, 0):.3f}")

# ---------------------------------------------------------------- S7
P("=" * 78)
P("S7. Discovery.  Exploit j has complexity K_j bits and opportunity rate eps_j;")
P("    the policy tries it w.p. 2^-(K_j - S) per opportunity (S = search bits).")
P("    Claim: exploited rate eps_eff(N,S) ~ eps_bit * (S + log2(N eps_j)) (one exploit per bit).")
Ks = np.arange(1, 61)
eps_j = 1e-3
for S in [0, 5, 10]:
    row = []
    for N in [1e3, 1e5, 1e7]:
        x = np.minimum(1.0, 2.0 ** (-(Ks - S)))
        found = 1 - np.exp(-N * eps_j * x)
        exact = (eps_j * found).sum()
        approx = eps_j * max(0, min(60, S + np.log2(N * eps_j)))
        row.append(f"N={N:.0e}: exact {exact*1e3:6.2f}e-3 approx {approx*1e3:6.2f}e-3")
    P(f"  S={S:2d}: " + " | ".join(row))

# ---------------------------------------------------------------- S8
P("=" * 78)
P("S8. Rotation: N_gen audit families, each audit drawn uniformly; a caught event on")
P("    family i lowers m_i by varpi_A and m_j (j!=i) by sigma_tr*varpi_A.")
P("    Claim: total caught -> (m0/varpi_A) N_gen/(1+(N_gen-1) sigma_tr).")
m0, vA = 0.5, 0.05
for Ng in [1, 4, 16]:
    for st in [0.0, 0.25, 1.0]:
        tots = []
        for rep in range(400):
            m = np.full(Ng, m0)
            N = 0
            for _ in range(200000):
                i = rng.integers(Ng)
                if m[i] <= 1e-12:
                    if (m <= 1e-12).all():
                        break
                    continue
                if rng.random() < m[i]:
                    N += 1
                    m -= st * vA
                    m[i] -= (1 - st) * vA
                    m = np.maximum(m, 0)
            tots.append(N)
        pred = m0 / vA * Ng / (1 + (Ng - 1) * st)
        P(f"  N_gen={Ng:2d} sigma_tr={st:4.2f}: mean total caught={np.mean(tots):7.2f}, prediction={pred:7.2f}")
P("  Fluid-limit check (varpi_A=0.005, 100 events per family):")
for Ng, st in [(4, 0.25), (16, 0.25)]:
    tots = []
    for rep in range(40):
        m = np.full(Ng, 0.5); N = 0
        while (m > 1e-12).any():
            i = rng.integers(Ng)
            if m[i] > 1e-12 and rng.random() < m[i]:
                N += 1; m -= st * 0.005; m[i] -= (1 - st) * 0.005; m = np.maximum(m, 0)
        tots.append(N)
    P(f"    N_gen={Ng} sigma_tr={st}: mean={np.mean(tots):.1f}, prediction={100*Ng/(1+(Ng-1)*st):.1f}")
P("  Held-out diagnostic: ln(caught rate on held-out family / on trained family)")
P("  = (1-sigma_tr) R  under the multiplicative law; e.g. R=2 nats, sigma_tr=0.25 -> 1.5.")

# ---------------------------------------------------------------- S9
P("=" * 78)
P("S9. Loop map with learning.  Fresh audit generators each generation.")
P("    R0_{k+1} = R_gap + (sig_w - iota) ln(1 + varpi a h n e^{-R0_k})  (arms race)")
P("    L_{k+1}  = L_k + (lam/varpi) ln(1+varpi a h n e^{-R0_k}) - lam v n + gamma - kL g")
n = 500
Rgap = np.log(2.0)
for (vp, sw, io, vv, gam, lab) in [(0.0, 0, 0, V, 0, "no learning (T1)"),
                                   (0.1, 0.3, 0.0, V, 0, "learning, no realism transfer"),
                                   (0.1, 0.3, 0.3, V, 0, "learning, iota = sigma_w"),
                                   (0.1, 0.3, 0.3, V / 10, 0, "learning, v/10 (verifiable)"),
                                   (1.0, 0.3, 0.3, V / 10, 0, "varpi=1, v/10"),
                                   (1.0, 0.3, 0.3, V / 100, 0, "varpi=1, v/100")]:
    R0 = Rgap
    L = 3.0
    Ls = []
    for k in range(10):
        if vp > 0:
            lr_ = np.log1p(vp * 0.03 * n * np.exp(-R0))
            bankk = LAM / vp * lr_
        else:
            lr_ = 0.0
            bankk = LAM * 0.03 * n * np.exp(-R0)
        L = L + bankk - LAM * vv * n + gam
        Ls.append(L)
        R0 = Rgap + (sw - io) * lr_
    # fixed point of R0 map
    if vp > 0 and sw - io != 0:
        Rs = brentq(lambda R: R - Rgap - (sw - io) * np.log1p(vp * 0.03 * n * np.exp(-R)), -5, 50)
    else:
        Rs = Rgap
    P(f"  {lab:32s}: R0*={Rs:5.3f}; L_k for k=1..10: " + ", ".join(f"{x:7.1f}" for x in Ls))
P("  Learning loop inequality (per generation): (lam-/varpi) ln(1+varpi u0 n) + gamma >")
P("  lam+ v n + kL g.  For n=500, u0=0.015, varpi=0.1 the audit term is 25.7 nats;")
P("  break-even v = 25.7/(500*4.6) = 0.0112; at varpi=1: audit term 6.4, v* = 0.0028.")
for vp in [0.01, 0.1, 1.0]:
    for nn in [500, 5000, 50000]:
        term = LAM / vp * np.log1p(vp * U0 * nn)
        P(f"   varpi={vp:5}: n={nn:6d}: audit term={term:8.2f} nats; break-even v*={term/(LAM*nn):.2e}"
          f" (no learning: v*=u0={U0})")

P("=" * 78)
P("S10. Doubling the audit rate versus halving the rewarded rate (varpi=0.1).")
for nn in [500, 5000, 50000]:
    dA = LAM / 0.1 * (np.log1p(0.1 * 2 * U0 * nn) - np.log1p(0.1 * U0 * nn))
    dV = LAM * V * nn / 2
    P(f"  n={nn:6d}: doubling audits adds {dA:7.2f} nats (limit (lam/varpi) ln2 = {LAM/0.1*np.log(2):.2f}); "
      f"halving v adds {dV:8.2f}; without learning doubling audits adds {LAM*U0*nn:8.2f}")
open(__file__.replace(".py", "_output.txt"), "w").write("\n".join(out) + "\n")
