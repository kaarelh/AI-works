"""rB6 (referee B): the noisy-parity instance at small d (notes Cor 6.1, Thm 4.1(iv), Section 7.5).
Seeded: numpy default_rng(61).

Class (independent of i4's).  Inputs {0,1}^d, mu uniform.  Programs:
  * (a, q): label = <a,x> mod 2 flipped with probability q, a in {0,1}^d, q in RATES with a prefix code
    RATES = 1/8 (2 bits), 1/4 (3), 1/16 (3), 3/16 (4), 0 (4), 3/32 (5), 5/32 (5); length 2 + d + code(q);
  * (a, q, x0): as (a, q) but with the parity bit flipped at the single input x0 (a "function competitor"
    g = f xor 1_{x0}), length 2 + d + code(q) + d + 1;
  * the coin, length 2.
Truth (a*, 1/8): l* = d + 4.  Kraft sum printed.
(A) Cor 6.1(iii): the closed-form gap mu(g!=f) h_ne(p,q) + mu(g=f) h_eq(p,q) against direct computation,
    and which competitor attains the margin, for d = 6 and d = 10 (claim: "rate competitors have the
    smallest gaps").
(B) Fresh noise (per-query), d = 6: empirical P[lambda-MAP != truth] (1000 runs) against the Renyi sum
    and the margin sample size n(lambda, l*, gamma, 0.05); split into wrong parity / wrong rate /
    function competitor.
(C) Frozen noise, d = 6: one label per input, n large enough that every input is seen; the data set is
    then the full table, and the MAP depends only on the number K ~ Bin(64, 1/8) of flipped inputs
    (and, for function competitors, on which inputs are flipped; their cost exceeds their gain, checked).
    Exact P[lambda-MAP has rate != 1/8] for lambda in {1, 1.5, 2, 4}.  With fresh noise the rate is
    eventually exact (Thm 3.1; Cor 6.1(i)).
"""
import numpy as np
from math import sqrt, log2, log, exp, comb, ceil

rng = np.random.default_rng(61)
RATES = [1 / 8, 1 / 4, 1 / 16, 3 / 16, 0.0, 3 / 32, 5 / 32]
RCODE = [2, 3, 3, 4, 4, 5, 5]
assert sum(2.0 ** -c for c in RCODE) <= 1
heq = lambda p, q: 1 - sqrt(p * q) - sqrt((1 - p) * (1 - q))
hne = lambda p, q: 1 - sqrt(p * (1 - q)) - sqrt((1 - p) * q)
PSTAR = 1 / 8


def build(d):
    Xn = 2 ** d
    par = np.array([[bin(a & x).count("1") & 1 for x in range(Xn)] for a in range(Xn)], dtype=np.int8)
    return Xn, par


def direct_gap(p1_nu, p1_pi):
    """E_mu H^2 for binary kernels given as P(label 1 | x) arrays (mu uniform)."""
    a = np.sqrt(p1_nu * p1_pi) + np.sqrt((1 - p1_nu) * (1 - p1_pi))
    return float(np.mean(1 - a))


print("=" * 78)
print("(A) Cor 6.1(iii): closed-form gaps vs direct computation; which competitor attains the margin")
for d in [6, 10]:
    Xn, par = build(d)
    astar = Xn - 3
    f = par[astar].astype(float)
    nu1 = np.where(f == 1, 1 - PSTAR, PSTAR)
    maxerr = 0.0
    best = []
    for a in [astar, 1, 5]:
        for q in RATES:
            g = par[a].astype(float)
            p1 = np.where(g == 1, 1 - q, q)
            dg = direct_gap(nu1, p1)
            mne = float(np.mean(g != f))
            cf = mne * hne(PSTAR, q) + (1 - mne) * heq(PSTAR, q)
            maxerr = max(maxerr, abs(dg - cf))
            if not (a == astar and q == PSTAR):
                best.append((dg, f"rate/parity competitor (a{'=' if a == astar else '!='}a*, q={q:.4g})"))
            # function competitor: flip the parity bit at x0 = 0
            g2 = g.copy(); g2[0] = 1 - g2[0]
            p2 = np.where(g2 == 1, 1 - q, q)
            dg2 = direct_gap(nu1, p2)
            mne2 = float(np.mean(g2 != f))
            cf2 = mne2 * hne(PSTAR, q) + (1 - mne2) * heq(PSTAR, q)
            maxerr = max(maxerr, abs(dg2 - cf2))
            best.append((dg2, f"function competitor g = f xor 1_x0 (a{'=' if a == astar else '!='}a*, q={q:.4g})"))
    best.sort()
    print(f"  d={d}: max |closed form - direct| = {maxerr:.2e}; three smallest gaps:")
    for v, nm in best[:3]:
        print(f"     {v:.6f}  {nm}")

print("=" * 78)
print("(B) fresh noise, d = 6: empirical P[MAP != truth] vs bounds; 1000 runs")
d = 6
Xn, par = build(d)
astar = 45
f = par[astar]
progs = []      # (kind, length, P(1|x) array)
for a in range(Xn):
    for q, cq in zip(RATES, RCODE):
        g = par[a]
        progs.append(("par" if a != astar else ("truth" if q == PSTAR else "rate"), 2 + d + cq,
                      np.where(g == 1, 1 - q, q)))
        for x0 in range(Xn):
            if a != astar:          # keep the class small: function competitors only around a*
                break
            g2 = g.copy(); g2[x0] ^= 1
            progs.append(("func", 2 + d + cq + d + 1, np.where(g2 == 1, 1 - q, q)))
progs.append(("coin", 2, np.full(Xn, 0.5)))
kinds = np.array([p[0] for p in progs]); lens = np.array([p[1] for p in progs], float)
P1 = np.stack([p[2] for p in progs])
kraft = float((2.0 ** -lens).sum()); assert kraft <= 1
it = int(np.flatnonzero(kinds == "truth")[0]); LSTAR = int(lens[it])
nu1 = P1[it]
print(f"  {len(progs)} programs, Kraft sum {kraft:.4f}, l* = {LSTAR}")


def rho_s(i, s):
    a, b = nu1, P1[i]
    t = np.zeros(Xn)
    for A, B in ((a, b), (1 - a, 1 - b)):
        m = (A > 0) & (B > 0)
        t[m] += A[m] ** (1 - s) * B[m] ** s
    return float(t.mean())


wrong = np.flatnonzero(kinds != "truth")
gaps = np.array([1 - rho_s(i, 0.5) for i in wrong])
gam = gaps.min()
print(f"  margin gamma = {gam:.6f}, attained by a '{kinds[wrong[int(gaps.argmin())]]}' program; "
      f"smallest 'func' gap = {gaps[kinds[wrong] == 'func'].min():.6f}")
with np.errstate(divide="ignore"):
    LK1, LK0 = np.log2(P1), np.log2(1 - P1)
NS = [50, 100, 200, 400, 800, 1600, 3200, 6400]
LAMS = [1.0, 1.5, 2.0, 4.0]
R = 1000
cnt = {lam: np.zeros((len(NS), 4)) for lam in LAMS}       # any failure, wrong parity/coin, rate, func
for r in range(R):
    xs = rng.integers(0, Xn, size=NS[-1])
    ys = (rng.random(NS[-1]) < nu1[xs]).astype(np.int8)
    for t, n in enumerate(NS):
        c1 = np.bincount(xs[:n][ys[:n] == 1], minlength=Xn)
        c0 = np.bincount(xs[:n][ys[:n] == 0], minlength=Xn)
        with np.errstate(invalid="ignore"):
            L = np.where(c1[None, :] > 0, c1[None, :] * LK1, 0).sum(1) + np.where(c0[None, :] > 0, c0[None, :] * LK0, 0).sum(1)
        for lam in LAMS:
            J = lam * lens - L
            m = J[it]
            beat = np.flatnonzero(J <= m + 1e-9)
            beat = beat[beat != it]
            if len(beat):
                ks = set(kinds[beat])
                cnt[lam][t] += [1, bool(ks & {"par", "coin"}), "rate" in ks, "func" in ks]
for lam in LAMS:
    s = 1 / lam
    rh = np.array([rho_s(i, s) for i in wrong])
    if lam > 1:
        nexp = lam * (LSTAR + log2(2 / 0.05)) * log(2) / (2 * min(1, lam - 1) * gam)
        ex = f"; n(lambda, l*, gamma, 0.05) = {nexp:.0f}"
    else:
        ex = ""
    print(f"  lambda = {lam}{ex}")
    for t, n in enumerate(NS):
        BR = float(np.sum(2.0 ** (LSTAR - lens[wrong]) * rh ** n))
        a, b, c, e_ = cnt[lam][t] / R
        print(f"    n={n:5d}: P[fail]={a:.3f} (parity/coin {b:.3f}, rate {c:.3f}, function {e_:.3f});  Renyi sum={min(BR, 99):.3g}")

print("=" * 78)
print("(C) frozen noise on the full table, d = 6 (64 inputs): exact P[lambda-MAP rate != 1/8]")
# On the full table with K flipped inputs, the parity a* with rate q has -log L = K log(1/q) + (64-K) log(1/(1-q)).
# Other parities disagree with about half the table; function competitors absorb one flip for d+1 extra bits
# of length: gain log2((1-q)/q) <= log2(15) < 3.91 bits < lambda (d+1) = 7 lambda, so they never win;
# the coin costs 64 bits.  Both facts are checked numerically below for every K <= 15.
# A parity a != a* disagrees with f on 32 inputs, so it makes at least 32 - K errors on the table; for
# K <= 15 that is more than K, and with the same rate it is worse than a*.  So for K <= 15 the MAP's parity
# is a* and the computation is exact; the mass P[K >= 16] is reported separately.
Nt = Xn
pK = [comb(Nt, K) * PSTAR ** K * (1 - PSTAR) ** (Nt - K) for K in range(Nt + 1)]
for lam in [1.0, 1.5, 2.0, 4.0]:
    wrong = 0.0
    detail = {}
    for K in range(16):
        cands = {}
        for q, cq in zip(RATES, RCODE):
            if q == 0:
                F = 0.0 if K == 0 else np.inf
            else:
                F = -(K * log2(q) + (Nt - K) * log2(1 - q))
            cands[f"(a*, q={q:.4g})"] = lam * (2 + d + cq) + F
            # function competitor with rate q: absorbs one flip (K -> K-1) for d+1 extra bits
            if K >= 1 and q > 0:
                cands[f"function competitor, q={q:.4g}"] = min(
                    cands.get(f"function competitor, q={q:.4g}", np.inf),
                    lam * (2 + d + cq + d + 1) - ((K - 1) * log2(q) + (Nt - K + 1) * log2(1 - q)))
        cands["coin"] = lam * 2 + Nt
        jmin = min(cands.values())
        maps = [k for k, v in cands.items() if v <= jmin + 1e-9]
        if maps != ["(a*, q=0.125)"]:
            wrong += pK[K]
            key = " / ".join(maps)
            detail[key] = detail.get(key, 0.0) + pK[K]
    ds = "; ".join(f"{k}: {v:.3f}" for k, v in sorted(detail.items(), key=lambda t: -t[1]))
    print(f"  lambda={lam}: P[frozen MAP != (a*, 1/8)] = {wrong:.4f} + at most {sum(pK[16:]):.4f} (K >= 16)")
    print(f"      selected instead: {ds}")
