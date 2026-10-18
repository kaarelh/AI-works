"""Numerical checks for drafts/T1-ledger.md (the alignment ledger and the loop).

Notation as in the draft:
  u = a h (1-s)        rate of caught gaming opportunities (unrecognised audits)
  v = (1-a) eps        rate of rewarded, uncaught gaming opportunities
  w = u + v            rate of unrecognised gaming opportunities
  p = u / w            detection probability of an unrecognised opportunity
  lp, lm               evidence (nats) per rewarded / per caught gaming event
  t* = lp / (lp + lm)  break-even detection probability
Master formula:  D(C_t) = w (lp + lm) (t* - p) 1{p < t}.
"""
import numpy as np
from scipy.optimize import brentq, minimize_scalar
from scipy.integrate import quad

rng = np.random.default_rng(0)
out = []


def say(*a):
    s = " ".join(str(x) for x in a)
    print(s)
    out.append(s)


def check(name, pred, sim, tol):
    ok = abs(pred - sim) <= tol
    say(f"CHECK {name}: predicted {pred:.6g}, computed {sim:.6g}  -> {'OK' if ok else 'MISMATCH'}")
    return ok


sig = lambda x: 1 / (1 + np.exp(-x))

# ---------------------------------------------------------------------------
say("=== 1. Master formula under (B), exact expectation over episode categories")
for (eps, a, h, s, delta, t) in [(0.02, 0.05, 1, 0.5, 0.01, 1.0), (0.05, 0.2, 0.05, 0.5, 0.05, 0.3),
                                 (0.01, 0.03, 1, 0.5, 0.01, 0.55), (0.01, 0.03, 1, 0.5, 0.01, 0.65)]:
    Lam = np.log((1 - delta) / delta)
    u, v = a * h * (1 - s), (1 - a) * eps
    p = u / (u + v)
    games = p < t
    # (B): factor = P(pass).  Rewarded opportunity: gaming passes, intended fails.
    # Caught opportunity: intended passes, gaming fails.  Recognised audits, clean
    # episodes: every disposition intends -> equal factors.
    pg_gamer = (1 - delta) if games else delta
    inc_rewarded = np.log(pg_gamer / delta)            # ln P_theta(pass)/P_A(pass)
    inc_caught = np.log((1 - pg_gamer) / (1 - delta))
    D_exact = v * inc_rewarded + u * inc_caught        # drift of ln mu(theta)/mu(A)
    tstar = 0.5
    D_master = (u + v) * 2 * Lam * (tstar - p) * games
    check(f"(B) eps={eps} a={a} h={h} s={s} t={t} p={p:.3f}", D_master, D_exact, 1e-12)

say("=== 2. Best-responding gamer with heterogeneous detection d: max_t E[(t*-d)1{d<t}] at t=t*, >= 0")
for trial in range(5):
    d = rng.beta(rng.uniform(0.3, 3), rng.uniform(0.3, 3), size=200000)
    tstar = rng.uniform(0.05, 0.95)
    ts = np.linspace(0, 1, 401)
    vals = np.array([np.mean((tstar - d) * (d < t)) for t in ts])
    tbest = ts[np.argmax(vals)]
    check(f"trial {trial}: argmax_t (t*={tstar:.3f})", tstar, tbest, 0.003)
    say(f"     max value {vals.max():.4g} >= 0; E[(t*-d)^+] = {np.mean(np.maximum(tstar - d, 0)):.4g}")

say("=== 3. Ruin probability with negative drift: lattice walk, steps of Lam, up w.p. u, down w.p. v")
u, v, Lam, L0 = 0.015, 0.0097, np.log(99), np.log(1e6)
m = int(np.ceil(L0 / Lam))
pred = (v / u) ** m
# simulate embedded jump chain: up w.p. u/(u+v), down w.p. v/(u+v)
pu = u / (u + v)
N, hits = 200000, 0
pos = np.full(N, m)
alive = np.ones(N, bool)
for step in range(3000):
    jumps = np.where(rng.random(N) < pu, 1, -1)
    pos = np.where(alive, pos + jumps, pos)
    newly = alive & (pos <= 0)
    hits += newly.sum()
    alive &= ~newly
check(f"P(posterior ever flips) m={m} steps, (v/u)^m", pred, hits / N, 0.01)
say(f"     Lundberg bound (v/u)^(L0/Lam) = {(v / u) ** (L0 / Lam):.4f}")
# same drift, (D)-like small evidence: lp = lm = 0.05 nats
lam_small = 0.05
theta = np.log(u / v) / lam_small
say(f"     with 0.05-nat events: bound exp(-theta* L0) = {np.exp(-theta * L0):.3g}")

say("=== 4. Separatrix q_dagger")
# random audits (h = eps):  q_dag = 1 - lp / (a (lp + (1-s) lm))
for (a, s, lp, lm, eh, de) in [(0.6, 0.0, 1, 1, 0.01, 0.05), (0.1, 0.3, 0.05, 1.0, 0.002, 0.05)]:
    D = lambda q: (eh + q * de) * ((1 - a * (1 - q)) * lp - a * (1 - q) * (1 - s) * lm)
    qd = brentq(D, 1e-9, 1 - 1e-9)
    check(f"random audits a={a} s={s} lp={lp} lm={lm}", 1 - lp / (a * (lp + (1 - s) * lm)), qd, 1e-9)
# honeypots (h = 1), (B), worked example of the draft
a, s, eh, de, Lam = 0.03, 0.5, 0.01, 0.05, np.log(99)
uq = lambda q: a * (1 - q) * (1 - s)
vq = lambda q: (1 - a * (1 - q)) * (eh + q * de)
qd = brentq(lambda q: vq(q) - uq(q), 0, 1)
say(f"     honeypot worked example: u0={uq(0):.4f} v0={vq(0):.4f} p0={uq(0)/(uq(0)+vq(0)):.3f} "
    f"D0/ep={Lam*(vq(0)-uq(0)):.4f}  D(1)/ep={Lam*(vq(1)-uq(1)):.4f}  q_dag={qd:.4f}  L_dag={np.log((1-qd)/qd):.3f}")
n = 500
say(f"     per generation (n={n}): n D0 = {n*Lam*(vq(0)-uq(0)):.2f} nats, n D(1) = {n*Lam*(vq(1)-uq(1)):.1f} nats")

say("=== 5. Time to failure, regime (i): dL/dk = -n (D0 + D1 q(L)), q = 1/(1+e^L)")
def T_formula(L0, nD0, nD1):
    if nD0 == 0:
        return (L0 + np.exp(L0) - 1) / nD1
    c = nD0 + nD1
    return L0 / c + (nD1 / (c * nD0)) * np.log((c + nD0 * np.exp(L0)) / (c + nD0))
for (L0, nD0, nD1) in [(np.log(1e6), 0.5, 5.0), (np.log(1e6), 0.0, 5.0), (np.log(1e3), 0.2, 20.0), (5.0, 0.0, 0.5)]:
    Tnum = quad(lambda L: 1 / (nD0 + nD1 / (1 + np.exp(L))), 0, L0, limit=200)[0]
    check(f"ODE time L0={L0:.2f} nD0={nD0} nD1={nD1}", T_formula(L0, nD0, nD1), Tnum, 1e-6 * max(1, Tnum))
    # discrete map
    L, k = L0, 0
    while L > 0 and k < 10**7:
        L -= nD0 + nD1 * sig(-L)
        k += 1
    say(f"     discrete map: fails after {k} generations; L0/(nD0) = {L0 / nD0 if nD0 else float('inf'):.1f}; "
        f"O/(nD1) = {np.exp(L0)/nD1:.3g}")

say("=== 6. Regime (ii): L' = (1-eta) Lb + eta L - n D(q(L)), honeypot worked example")
def Dq(q):
    return Lam * (vq(q) - uq(q))
def F(L, Lb, eta, best_resp=False):
    d = Dq(sig(-L))
    if best_resp:
        d = max(d, 0.0)
    return (1 - eta) * Lb + eta * L - n * d
for (Lb, eta, br) in [(3.0, 0.5, False), (3.0, 0.5, True), (2.0, 0.5, True), (1.0, 0.5, False)]:
    grid = np.linspace(-400, 60, 460001)
    Fg = np.array([F(L, Lb, eta, br) for L in grid[::50]])
    gg = grid[::50]
    sgn = np.sign(Fg - gg)
    idx = np.where(np.diff(sgn) != 0)[0]
    fps = []
    for i in idx:
        try:
            r = brentq(lambda L: F(L, Lb, eta, br) - L, gg[i], gg[i + 1])
            dF = (F(r + 1e-5, Lb, eta, br) - F(r - 1e-5, Lb, eta, br)) / 2e-5
            fps.append((round(float(r), 3), round(float(dF), 3)))
        except ValueError:
            pass
    fps = sorted(set(fps))
    # orbits from a few starting points
    ends = []
    for L in [10.0, 3.0, 2.6, 2.3, 0.0]:
        x = L
        for _ in range(200):
            x = F(x, Lb, eta, br)
        ends.append(round(float(x), 2))
    say(f"     Lb={Lb} eta={eta} best_resp={br}: fixed points (L*, F'(L*)) = {fps}; "
        f"orbits from [10,3,2.6,2.3,0] end at {ends}")
say(f"     step-limit prediction for aligned FP (naive, D~D0): Lb + n|D0|/(1-eta) = {3.0 + n*abs(Dq(0))/0.5:.2f}")

say("=== 7. Step size: Lambda_tot(g) = C psi/g + (C/r) Phi (eps0 + kappa g)")
C, psi, r, Phi, eps0, kappa = 10.0, 0.3, 0.01, 2.0, 0.002, 0.004
tot = lambda g: C * psi / g + (C / r) * Phi * (eps0 + kappa * g)
res = minimize_scalar(tot, bounds=(1e-4, 10), method="bounded")
gstar = np.sqrt(r * psi / (Phi * kappa))
check("g* = sqrt(r psi/(Phi kappa))", gstar, res.x, 1e-4)
check("Lambda* = C Phi eps0/r + 2C sqrt(psi Phi kappa/r)", C * Phi * eps0 / r + 2 * C * np.sqrt(psi * Phi * kappa / r), res.fun, 1e-6)
say(f"     g*={gstar:.3f}, K*=C/g*={C/gstar:.1f} generations, total loss {res.fun:.2f} nats")

say("=== 8. Recognition selection under (B), random audits: drift between gamers G_s', G_s = a h (s'-s) lm")
eps, a, h, Lam = 0.02, 0.1, 0.02, np.log(99)
for (s1, s2) in [(0.0, 0.5), (0.2, 0.9)]:
    D = lambda s: (1 - a) * eps * Lam - a * h * (1 - s) * Lam   # naive gamers, both game when unrecognised
    check(f"s'={s2}, s={s1}", a * h * (s2 - s1) * Lam, D(s2) - D(s1), 1e-12)

open(__file__.replace(".py", "_output.txt"), "w").write("\n".join(out) + "\n")
