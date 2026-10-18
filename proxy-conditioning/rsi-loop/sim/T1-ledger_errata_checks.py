"""Checks for the errata to drafts/T1-ledger.md after the reconciliation (sim/reconciliation.md).

E1. T1.7q with (B) training noise, by exact dynamic programming over the lattice L = L0 + Lam*S
    (quenched reading; and the annealed reading with the same noise), against reconciliation R3 (Monte Carlo).
E2. Step size with n proportional to g, continued regime: P(fail) as the number of generations grows,
    and its limit, the probability that the event walk ever dips below L_dag (reconciliation 3.3, R8).
E3. T1.9 in regime (ii) with a discriminating data channel: closed form and binomial version (reconciliation 3.7).
E4. Section 1.2: the realised (B) flip is the m-th exploited error, a negative-binomial time.
E5. T1.10s scope: Gaussian SNR z and the escape hazard when the per-event evidence is small ((D)-like),
    at the same event rates as the worked example.

Worked example as in T1: eps_h = 0.01, Delta_eps = 0.05, a = 0.03, h = 1, s = 0.5, delta = 0.01, (B), n = 500.
Run: python3 T1-ledger_errata_checks.py   (about a minute; seeds fixed). Writes T1-ledger_errata_checks_output.txt.
"""
import os
import sys
import numpy as np
from scipy.optimize import brentq
from scipy.stats import binom, nbinom, norm, poisson, skellam

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import loopcore as lc  # noqa: E402

out = []


def say(*a):
    s = " ".join(str(x) for x in a)
    print(s)
    out.append(s)


def check(name, pred, got, tol):
    ok = abs(pred - got) <= tol
    say(f"CHECK {name}: reference {pred:.6g}, computed {got:.6g}  -> {'OK' if ok else 'MISMATCH'}")
    return ok


sig = lambda x: 1 / (1 + np.exp(-np.clip(x, -700, 700)))
delta = 0.01
Lam = np.log((1 - delta) / delta)
a0, s0, eh, de, n = 0.03, 0.5, 0.01, 0.05, 500
uq = lambda q: a0 * (1 - q) * (1 - s0)
vq = lambda q: (1 - a0 * (1 - q)) * (eh + q * de)
qdag = brentq(lambda q: vq(q) - uq(q), 0, 1)
Ldag = np.log((1 - qdag) / qdag)
u0, v0 = uq(0), vq(0)
say(f"worked example: u0={u0:.5f} v0={v0:.5f} Lam={Lam:.4f} q_dag={qdag:.4f} L_dag={Ldag:.4f} "
    f"n|D0|={n*Lam*(u0-v0):.3f}, per-generation sd Lam sqrt(n w) = {Lam*np.sqrt(n*(u0+v0)):.2f}")

# ---------------------------------------------------------------------------
say("\nE1. T1.7q with (B) noise: exact DP over the lattice (multinomial episode counts, n = 500)")
# pmf of N_c - N_r for one generation of n multinomial episodes with probabilities (u0, v0, rest)
w = u0 + v0
pmf = {}
for t in range(0, n + 1):
    pt = binom.pmf(t, n, w)
    if pt < 1e-16:
        continue
    ks = np.arange(t + 1)
    pk = binom.pmf(ks, t, u0 / w)
    for k, p in zip(ks, pk):
        d = 2 * k - t
        pmf[d] = pmf.get(d, 0.0) + pt * p
dmin, dmax = min(pmf), max(pmf)
step = np.array([pmf.get(d, 0.0) for d in range(dmin, dmax + 1)])
K = 40
Smin, Smax = -K * 40, K * 40
S = np.arange(Smin, Smax + 1)
R3_mc = {1.0: 0.4794, 2.0: 0.3567, 2.4: 0.3253, 3.0: 0.2927, np.log(1e6): 0.1113}
R3_ann = {1.0: 0.9529, 2.0: 0.6831, 2.4: 0.5578, 3.0: 0.4309, np.log(1e6): 0.1308}


def conv_shift(dist, stp, lo):
    """distribution of S + D, with D supported on [lo, lo+len(stp)-1], on the same grid S."""
    full = np.convolve(dist, stp)
    # index i of full corresponds to S[0] + lo + i
    res = np.zeros_like(dist)
    off = lo  # S[0] + lo + i = S[j]  ->  i = j - lo
    j = np.arange(len(dist))
    i = j - off
    ok = (i >= 0) & (i < len(full))
    res[ok] = full[i[ok]]
    return res


rows = []
for L0 in (1.0, 2.0, 2.4, 3.0, np.log(1e6)):
    det = 1 - np.prod([1 - sig(-(L0 + k * n * Lam * (u0 - v0))) for k in range(400)])
    # quenched: weight = E[prod_j (1 - sigma(-L_j)) ; S_k = S]
    wgt = (S == 0).astype(float) * (1 - sig(-L0))
    for k in range(1, K):
        wgt = conv_shift(wgt, step, dmin)
        wgt *= 1 - sig(-(L0 + Lam * S))
    pq = 1 - wgt.sum()
    # annealed with the same noise (Poisson counts with q-dependent rates, as in R3), absorbed below -20
    dist = (S == 0).astype(float)
    dead = 0.0
    Ls = L0 + Lam * S
    alive_idx = np.where(Ls >= -20)[0]
    for k in range(1, K):
        new = np.zeros_like(dist)
        for j in np.where(dist > 1e-15)[0]:
            q = sig(-Ls[j])
            mu_c, mu_r = n * uq(q), n * vq(q)
            km = int(mu_c + mu_r + 12 * np.sqrt(mu_c + mu_r + 1)) + 5
            ds = np.arange(-km, km + 1)
            p = skellam.pmf(ds, mu_c, mu_r)
            tgt = j + ds
            okk = (tgt >= 0) & (tgt < len(S))
            np.add.at(new, tgt[okk], dist[j] * p[okk])
        absorbed = Ls < -20
        dead += new[absorbed].sum()
        new[absorbed] = 0.0
        dist = new
    rows.append((L0, det, pq, dead))
    say(f"   L0 = {L0:5.2f}: noise-free T1.7q {det:.4f} | quenched with noise (DP) {pq:.4f} | "
        f"annealed with noise (DP, L < -20 by gen {K}) {dead:.4f}")
    check(f"E1 quenched DP vs R3 Monte Carlo, L0={L0:.2f}", R3_mc[L0], pq, 0.003)
    check(f"E1 annealed DP vs R3 Monte Carlo, L0={L0:.2f}", R3_ann[L0], dead, 0.01)
say("   quenched < annealed at every L0:", all(r[2] < r[3] for r in rows))
# contribution of the first two generations to the quenched failure, L0 = 3
L0 = 3.0
wgt = (S == 0).astype(float) * (1 - sig(-L0))
p_by = [1 - wgt.sum()]
for k in range(1, K):
    wgt = conv_shift(wgt, step, dmin)
    wgt *= 1 - sig(-(L0 + Lam * S))
    p_by.append(1 - wgt.sum())
say("   L0 = 3: quenched P(fail) accumulated by generations 0, 1, 2, 5, 39: " +
    ", ".join(f"{p_by[i]:.3f}" for i in (0, 1, 2, 5, K - 1)))

# ---------------------------------------------------------------------------
say("\nE2. Step size, continued regime, n = 8000 g episodes per generation (n_ref = 2000 at g = 1/4), "
    "eps_h = 0.02 + 0.02 g")
P = lc.default_params()
for Lb in (4.0, 10.0):
    vals = []
    for N in (8, 64, 256, 1024, 4096):
        g = 1.0 / N
        ps = dict(P, eps_h=0.02 + 0.02 * g, n=8000.0 * g, K=N, L_base=Lb)
        vals.append((N, lc.p_fail_continued(ps, N)))
    say(f"   L_base = {Lb:4.1f}: P(fail) by number of generations N = 1/g: " +
        ", ".join(f"N={N}: {p:.3f}" for N, p in vals))
    # the limit: episode-by-episode check (ever-dip below L_dag within 8000 episodes) at eps_h = 0.02
    ps = dict(P, eps_h=0.02, n=1.0, K=8000, L_base=Lb)
    pd = lc.p_fail_continued(ps, 8000)
    say(f"   L_base = {Lb:4.1f}: limit g -> 0 (check after every episode, eps_h = 0.02): ever-dip probability {pd:.3f}")

# ---------------------------------------------------------------------------
say("\nE3. T1.9 in regime (ii), discriminating data channel (sim defaults: m = 100, rho = 0.1)")
m, rho = P["m"], P["rho"]
lam_r = np.log((1 + 2 * rho) / (1 - 2 * rho))
pz = 0.5 + rho
Xi = lam_r * m * (2 * pz - 1)
sd = 2 * lam_r * np.sqrt(m * pz * (1 - pz))
fps = lc.fixed_points_fresh(P)
q_u = [q for L, q, st in fps if not st][0]
Kg = 30
zK = norm.ppf(2 ** (-1 / Kg))
rstar = q_u / (1 - q_u) * np.exp(Xi - sd * zK)
say(f"   Xi = {Xi:.3f} nats, sd = {sd:.3f} nats, q_u = {q_u:.4f}, z_K = {zK:.3f} (K = {Kg})")
check("E3 closed-form threshold odds (reconciliation: 0.044)", 0.044, rstar, 0.0006)
say(f"   mean-map threshold q_u/(1-q_u) e^Xi = {q_u/(1-q_u)*np.exp(Xi):.2f}; frozen threshold q_u/(1-q_u) = {q_u/(1-q_u):.4f}")
zs = np.arange(m + 1)
pzs = binom.pmf(zs, m, pz)
for r in (0.032, 0.042, 0.044, 0.056):
    # band odds after the data channel: r * exp(-lam_r (2Z - m)); fails in a generation if band mass > q_u
    odds = r * np.exp(-lam_r * (2 * zs - m))
    p1 = pzs[odds / (1 + odds) > q_u].sum()
    pK = 1 - (1 - p1) ** Kg
    say(f"   r = {r:.3f}: per-generation P(band mass > q_u) = {p1:.4f}; P(fail within {Kg}) = {pK:.3f} "
        f"(binomial channel, band only)")
# P(fail within K) is a step function of r; find the step at which it crosses 1/2
thr_z = q_u / (1 - q_u) * np.exp(lam_r * (2 * zs - m))      # band fails at count Z iff r > thr_z[Z]
order = np.argsort(thr_z)
cum = np.cumsum(pzs[order])
jump = thr_z[order][np.argmax(1 - (1 - cum) ** Kg > 0.5)]
say(f"   binomial version: P(fail within {Kg}) crosses 1/2 at r = {jump:.4f} (a step of the discrete channel)")

# ---------------------------------------------------------------------------
say("\nE4. Realised (B) flip: the m-th exploited error, m = floor(ln O / Lam) + 1 (negative binomial)")
for eps, lab in ((0.02, "sim P0, eps = 0.02"), (0.01, "T1 example, eps = 0.01")):
    for O in (1e2, 1e4, 1e6):
        mm = int(np.floor(np.log(O) / Lam)) + 1
        med = nbinom.median(mm, eps) + mm   # trials = failures + successes
        mean = mm / eps
        say(f"   {lab}, O = {O:.0e}: m = {mm}, median episode of the flip {med:.0f}, mean {mean:.0f}; "
            f"deterministic ln O/(eps Lam) = {np.log(O)/(eps*Lam):.0f}")

# ---------------------------------------------------------------------------
say("\nE5. T1.10s with small evidence per event, same event rates as the worked example (eta = 0.5, n = 500)")
eta = 0.5
drift_part = np.sqrt(n) * (u0 - v0) / np.sqrt(u0 + v0) * np.sqrt((1 + eta) / (1 - eta))


def z_of(lam_ev, Lb):
    return drift_part + (Lb - Ldag) * np.sqrt(1 - eta ** 2) / (lam_ev * np.sqrt(n * (u0 + v0)))


rng = np.random.default_rng(11)
for lam_ev in (Lam, 0.5, 0.05):
    for Lb in (3.0, 10.0):
        z = z_of(lam_ev, Lb)
        # linearised chain near q = 0; hazard = P(L_k < L_dag) per generation in the stationary phase
        R, Kg2, burn = 100000, 120, 20
        LA = Lb + n * lam_ev * (u0 - v0) / (1 - eta)
        L = np.full(R, LA)
        hits, tot = 0, 0
        alive = np.ones(R, bool)
        for k in range(Kg2):
            L = (1 - eta) * Lb + eta * L + lam_ev * (rng.poisson(n * u0, R) - rng.poisson(n * v0, R))
            if k >= burn:
                below = alive & (L < Ldag)
                hits += below.sum()
                tot += alive.sum()
                alive &= ~below
        say(f"   lambda = {lam_ev:5.3f}, L_b = {Lb:4.1f}: z = {z:6.2f}, Phi(-z) = {norm.sf(z):.2e}; "
            f"simulated per-generation P(first dip below L_dag) = {hits/tot:.2e} ({hits} events)")

with open(os.path.join(HERE, "T1-ledger_errata_checks_output.txt"), "w") as f:
    f.write("\n".join(out) + "\n")
