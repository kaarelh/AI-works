"""rB3 (referee B): simulation of the per-query i.i.d. setting in a richer class; pathwise and
finite-sample checks of notes Lemma 2.2, Thm 3.1 and Thm 4.1.  Seeded: numpy default_rng(31).

Setting.  X = {0,...,7}, mu(x) proportional to 1/(x+1) (inputs repeat), Y = {0,1}, labels fresh per query.
Truth nu(1|x) = (2x+1)/16.  Class (Kraft sum printed below):
  * T      : the truth, l* = 10;  copies of the truth of lengths 12, 14, 16 (E \\ E*);
  * BERN_j : constant Bern(j/16), j = 1..15, length 6;
  * THR_t  : nu_t(1|x) = 3/4 if x >= t else 1/4, t = 0..7, length 7;
  * DET_f  : all 256 deterministic functions X -> {0,1}, length 11 (the fill-ins of this class);
  * EXC    : nu except deterministic at one input (16 programs), length 12 (partial fill-ins);
  * NEAR   : nu with nu(1|x) moved by +-2^{-j} at one input x, j = 3..20, length 14 + 2 ceil(log2(j+1)),
             kept when the moved value lies in (0,1) (near-equivalent programs; tiny Hellinger gaps).
Checks, for lambda in {1, 1.25, 2, 4}, R = 2000 runs of N = 2000 queries:
  (A) Lemma 2.2: empirical P[delta* >= j] <= 2^{-j}, i.i.d. inputs and an ADAPTIVE input rule
      (next input where the class mixture's prediction deviates most from nu; fresh labels at repeats).
  (B) Thm 4.1(i)-(iii) pathwise at every n with the current deficiency delta_n = log(xi_n / L_n(nu)):
      MAP length, posterior length tail (L = 12, 14, 16, 20), fill-in posterior (power and tempered).
  (C) Thm 4.1(iv): empirical P[lambda-MAPs != E*] at n against the bound minimised over L,
      and against the margin sample size n(lambda, l*, gamma, eps).
  (D) Thm 4.1(v): empirical P[exists n in [n0, N]: MAPs != E*] against its bound.
  (E) Thm 3.1 at lambda = 1: fraction of runs whose MAP is in E* at every n in [N/2, N].
"""
import numpy as np
from math import ceil, log2, log, exp

rng = np.random.default_rng(31)
X = np.arange(8)
mu = 1.0 / (X + 1); mu /= mu.sum()
nu1 = (2 * X + 1) / 16.0

progs, lens, kinds = [], [], []
def add(p1, L, kind):
    progs.append(np.asarray(p1, float)); lens.append(L); kinds.append(kind)
add(nu1, 10, "T")
for L in (12, 14, 16):
    add(nu1, L, "Tcopy")
for j in range(1, 16):
    add(np.full(8, j / 16), 6, "BERN")
for t in range(8):
    add(np.where(X >= t, 0.75, 0.25), 7, "THR")
for f in range(256):
    add(np.array([(f >> x) & 1 for x in X], float), 11, "DET")
for x in X:
    for b in (0, 1):
        p = nu1.copy(); p[x] = b; add(p, 12, "EXC")
for x in X:
    for sgn in (-1, 1):
        for j in range(3, 21):
            q = nu1[x] + sgn * 2.0 ** -j
            if not 0 < q < 1:
                continue                      # keep only genuine probability kernels
            p = nu1.copy(); p[x] = q; add(p, 14 + 2 * ceil(log2(j + 1)), "NEAR")
P1 = np.stack(progs); lens = np.array(lens, float); kinds = np.array(kinds)
P = len(progs)
kraft = (2.0 ** -lens).sum()
assert kraft <= 1
inE = np.array([k in ("T", "Tcopy") for k in kinds]); Estar = kinds == "T"
det = kinds == "DET"
LSTAR = 10
assert np.all((P1 >= 0) & (P1 <= 1))
with np.errstate(divide="ignore"):
    LK1, LK0 = np.log2(P1), np.log2(1 - P1)             # (P, 8)
print(f"class: {P} programs, Kraft sum {kraft:.4f}; E has {inE.sum()} programs, E* = {{T}}, l* = {LSTAR}")


def rho(i, s):
    t = 0.0
    for x in X:
        for (a, b) in ((nu1[x], P1[i, x]), (1 - nu1[x], 1 - P1[i, x])):
            if a > 0 and b > 0:
                t += mu[x] * a ** (1 - s) * b ** s
    return t


gaps = np.array([1 - rho(i, 0.5) if not inE[i] else 0.0 for i in range(P)])
print(f"smallest Hellinger gap: {gaps[~inE].min():.3e} (a NEAR program); smallest gap among non-NEAR wrong programs: "
      f"{gaps[(~inE) & (kinds != 'NEAR')].min():.4f}")


def logsumexp2(W, axis=0):
    m = np.max(W, axis=axis, keepdims=True)
    m = np.where(np.isfinite(m), m, 0.0)
    with np.errstate(divide="ignore"):
        return np.squeeze(m, axis) + np.log2(np.sum(np.exp2(W - m), axis=axis))


# ------------------------------------------------------------------------------------------------
LAMS = [1.0, 1.25, 2.0, 4.0]
R, N = 2000, 2000
NS = [25, 50, 100, 200, 400, 800, 1600, 2000]
Ls_tail = [12, 14, 16, 20]
fail = {lam: np.zeros(len(NS)) for lam in LAMS}
fail_after = {lam: {n0: 0 for n0 in (200, 400, 800)} for lam in LAMS}
lam1_ok_late = 0
viol = {"len": 0, "tail": 0, "det": 0, "det_temp": 0}
dstar = np.empty(R)
maxmaplen = {lam: 0 for lam in LAMS}
for r in range(R):
    xs = rng.choice(8, size=N, p=mu)
    ys = rng.random(N) < nu1[xs]
    inc = np.where(ys[None, :], LK1[:, xs], LK0[:, xs])          # (P, N)
    cum = np.cumsum(inc, axis=1)                                   # log2 L_n(pi), n = 1..N
    lognu = cum[0]
    Sn = -lognu
    logxi = logsumexp2(-lens[:, None] + cum, axis=0)
    delta_n = logxi - lognu                                       # log2(xi_n / L_n(nu)), n >= 1
    dstar[r] = max(np.log2(kraft), float(delta_n.max()))           # sup over n >= 0 (n = 0 gives log kraft)
    for lam in LAMS:
        J = lam * lens[:, None] - cum
        Jmin = J.min(axis=0)
        maps = J <= Jmin[None, :] + 1e-9
        bad = (maps & ~Estar[:, None]).any(axis=0)                 # MAP set != E* (E* = {T})
        for t, n in enumerate(NS):
            fail[lam][t] += bad[n - 1]
        for n0 in fail_after[lam]:
            fail_after[lam][n0] += bool(bad[n0 - 1:].any())
        if lam == 1.0:
            lam1_ok_late += not bad[N // 2 - 1:].any()
        if lam > 1:
            maplen = np.where(maps, lens[:, None], 0).max(axis=0)
            maxmaplen[lam] = max(maxmaplen[lam], int(maplen.max()))
            viol["len"] += int(np.sum(maplen > (lam * LSTAR + delta_n) / (lam - 1) + 1e-9))
            W = -lam * lens[:, None] + cum
            lz = logsumexp2(W, axis=0)
            for Lt in Ls_tail:
                sel = lens > Lt
                lt = logsumexp2(W[sel], axis=0) - lz
                viol["tail"] += int(np.sum(lt > lam * LSTAR + delta_n - (lam - 1) * Lt + 1e-9))
            # fill-ins: deterministic programs (consistent ones have finite weight)
            ld = logsumexp2(W[det], axis=0) - lz
            viol["det"] += int(np.sum(ld > lam * LSTAR + lam * delta_n - (lam - 1) * Sn + 1e-9))
            Wt = -lens[:, None] + cum / lam
            ldt = logsumexp2(Wt[det], axis=0) - logsumexp2(Wt, axis=0)
            viol["det_temp"] += int(np.sum(ldt > LSTAR + delta_n - (1 - 1 / lam) * Sn + 1e-9))

print("=" * 78)
print("(A) Lemma 2.2, i.i.d. inputs: empirical P[delta* >= j] (sup over n <= 2000) vs 2^-j")
for j in [0.5, 1, 2, 3, 4, 6, 8]:
    print(f"  j={j}: {np.mean(dstar >= j):.4f}  <= {2.0 ** -j:.4f}")

print("=" * 78)
print("(B) Thm 4.1(i)-(iii) pathwise, every n <= 2000, every run, lambda in {1.25, 2, 4}")
print(f"  violations: MAP length {viol['len']}; posterior length tail {viol['tail']}; fill-ins (power) "
      f"{viol['det']}; fill-ins (tempered 1/lambda) {viol['det_temp']}")
print(f"  longest lambda-MAP seen: {maxmaplen}")

print("=" * 78)
print("(C) Thm 4.1(iv): empirical P[MAPs != E*] at n vs the bound minimised over L")
lens_wrong = lens[~inE]
rhos = {lam: np.array([rho(i, 1 / lam) for i in np.flatnonzero(~inE)]) for lam in LAMS}
for lam in LAMS:
    print(f"  lambda = {lam}")
    for t, n in enumerate(NS):
        best = np.inf
        for L in range(LSTAR, 60):
            first = 2.0 ** (lam * LSTAR - (lam - 1) * L) if lam > 1 else (0.0 if L >= lens.max() else np.inf)
            sel = lens_wrong <= L
            second = float(np.sum(2.0 ** (LSTAR - lens_wrong[sel]) * rhos[lam][sel] ** n))
            best = min(best, first + second)
        emp = fail[lam][t] / R
        se = (max(emp, 1 / R) * (1 - emp) / R) ** 0.5
        flag = "  EXCEEDS BOUND" if emp > best + 3 * se else ""
        print(f"    n={n:5d}  empirical={emp:.4f}  bound(min over L)={min(best, 99):.4g}{flag}")
for lam in [1.25, 2.0, 4.0]:
    eps = 0.05
    Le = ceil((lam * LSTAR + log2(2 / eps)) / (lam - 1))
    gam = gaps[(~inE) & (lens <= Le)].min()
    nexp = lam * (LSTAR + log2(2 / eps)) * log(2) / (2 * min(1, lam - 1) * gam)
    print(f"  lambda={lam}: L_eps={Le}, gamma_L = {gam:.3e}, n(lambda,l*,gamma,0.05) = {nexp:.3g}")

print("=" * 78)
print("(D) Thm 4.1(v): empirical P[exists n in [n0, 2000]: MAPs != E*]")
for lam in LAMS:
    s = "  ".join(f"n0={n0}: {fail_after[lam][n0] / R:.4f}" for n0 in fail_after[lam])
    print(f"  lambda={lam}: {s}")

print("=" * 78)
print(f"(E) Thm 3.1, lambda = 1: runs whose 1-MAP is in E* at every n in [1000, 2000]: {lam1_ok_late}/{R}")

# ------------------------------------------------------------------------------------------------
print("=" * 78)
print("(A') Lemma 2.2(c), ADAPTIVE inputs (argmax_x of the mixture's deviation from nu), 1000 runs of 1000")
R2, N2 = 1000, 1000
dstar2 = np.empty(R2)
for r in range(R2):
    logw = -lens.copy()                         # log2 of 2^{-l} L_n(pi)
    lognu = 0.0
    best = np.log2(kraft)
    for n in range(N2):
        w = np.exp2(logw - logw.max()); w /= w.sum()
        pred1 = w @ P1                           # mixture's normalised P(1|x), (8,)
        x = int(np.argmax(np.abs(pred1 - nu1)))
        y = rng.random() < nu1[x]
        logw += LK1[:, x] if y else LK0[:, x]
        lognu += log2(nu1[x]) if y else log2(1 - nu1[x])
        m = logw.max()
        best = max(best, m + log2(np.exp2(logw - m).sum()) - lognu)
    dstar2[r] = best
for j in [0.5, 1, 2, 3, 4, 6]:
    print(f"  j={j}: {np.mean(dstar2 >= j):.4f}  <= {2.0 ** -j:.4f}")
