"""v3: simulation of kink/notes-final.md Corollary 5.7 (scheme (pq)), parts (a)-(d): along one infinite
per-query sequence, the left steepness at (l*, S_n) grows linearly, the right slope falls below 1, and the
lambda-MAP set is eventually E* for lambda in {1, 1.5, 2, 4}.  An almost-sure eventual statement cannot be
proved by simulation; this checks that nothing in a natural instance contradicts it, and that the
deterministic consequences used in the proof of (d) hold at every checkpoint where the 1-MAP set is E*.

Written for `../../verify-kink.md`; shares no code with checks/k6 or referee_code/.

Instance.  X = {0,1,2}, mu = (1/2, 3/8, 1/8), Y = {0,1}, nu(1|x) = (1/8, 1/2, 7/8), a fresh label per
query.  Class: for each precision b = 1..7 and each pair of dyadic rates (r0, r2) in {j/2^b : 0<j<2^b}^2,
the program "rate r0 at x0, 1/2 at x1, rate r2 at x2" of length 2b + 3 (Kraft sum < 7/8); 21,343 programs.
The truth first appears at b = 3: l* = 9, E* = {(1/8, 7/8) at b = 3}; the same kernel at b >= 4 is in
E but longer.  Near refinements (rates j/2^b next to 1/8 or 7/8) sit at every larger length.
Seeded: numpy.random.default_rng(57).  200 runs, n up to 2^16.  Python 3.11.
"""
import math

import numpy as np

LOG2E = math.log2(math.e)
MU = np.array([1 / 2, 3 / 8, 1 / 8])
NU1 = np.array([1 / 8, 1 / 2, 7 / 8])
BMAX = 7

rates = {}            # rate -> index
progs = []            # (b, i0, i2)
for b in range(1, BMAX + 1):
    for j0 in range(1, 2 ** b):
        for j2 in range(1, 2 ** b):
            for r in (j0 / 2 ** b, j2 / 2 ** b):
                if r not in rates:
                    rates[r] = len(rates)
            progs.append((b, rates[j0 / 2 ** b], rates[j2 / 2 ** b]))
R = np.array(sorted(rates, key=rates.get))
P = np.array(progs)
lens = 2 * P[:, 0] + 3
kraft = float(np.sum(2.0 ** -lens))
i_true0, i_true2 = rates[1 / 8], rates[7 / 8]
equiv = (P[:, 1] == i_true0) & (P[:, 2] == i_true2)
lstar = int(lens[equiv].min())
Estar = equiv & (lens == lstar)
assert Estar.sum() == 1 and kraft < 1


def hel(a, b):
    return 1 - (math.sqrt(a * b) + math.sqrt((1 - a) * (1 - b)))


gam = MU[0] * np.array([hel(NU1[0], r) for r in R])[P[:, 1]] + MU[2] * np.array([hel(NU1[2], r) for r in R])[P[:, 2]]
gam[equiv] = 0.0
rate_a = min(2 * LOG2E * gam[(lens == l) & ~equiv].min() / (lstar - l) for l in sorted(set(lens[lens < lstar])))
print(f"class: {len(P)} programs, Kraft sum {kraft:.4f}, l* = {lstar}, |E| = {equiv.sum()}, |E*| = {Estar.sum()}")
print(f"Cor 5.7(a) rate bound 2 log e min_(l<l*) gamma_=(l)/(l*-l) = {rate_a:.5f} bits per sample")

rng = np.random.default_rng(57)
RUNS, KMAX = 200, 16
checkpoints = [2 ** k for k in range(4, KMAX + 1)]
lams = [1.0, 1.5, 2.0, 4.0]
ok_map = {lam: np.zeros(len(checkpoints)) for lam in lams}
ok_kink = np.zeros(len(checkpoints))
ok_d_step = 0
n_d_step = 0
smin_per_n = [[] for _ in checkpoints]
splus_med = [[] for _ in checkpoints]
last_fail = {lam: [] for lam in lams}
last_fail_kink = []
nlR, nl1R = -np.log2(R), -np.log2(1 - R)
for run in range(RUNS):
    xs = rng.choice(3, size=2 ** KMAX, p=MU)
    ys = (rng.random(2 ** KMAX) < NU1[xs]).astype(np.int64)
    lf = {lam: 0 for lam in lams}
    lfk = 0
    for c, n in enumerate(checkpoints):
        x, y = xs[:n], ys[:n]
        n01 = int(np.sum((x == 0) & (y == 1))); n00 = int(np.sum((x == 0) & (y == 0)))
        n21 = int(np.sum((x == 2) & (y == 1))); n20 = int(np.sum((x == 2) & (y == 0)))
        n1 = int(np.sum(x == 1))
        f0 = n01 * nlR + n00 * nl1R
        f2 = n21 * nlR + n20 * nl1R
        F = f0[P[:, 1]] + f2[P[:, 2]] + n1
        S = float(f0[i_true0] + f2[i_true2] + n1)
        left, right = lens < lstar, lens > lstar
        s_minus = float(np.min((F[left] - S) / (lstar - lens[left])))
        s_plus = float(max(0.0, np.max((S - F[right]) / (lens[right] - lstar))))
        smin_per_n[c].append(s_minus / n)
        splus_med[c].append(s_plus)
        kink = s_plus < 1 < s_minus
        ok_kink[c] += kink
        if not kink:
            lfk = n
        for lam in lams:
            J = lam * lens + F
            ms = np.abs(J - J.min()) <= 1e-9 * max(1.0, abs(J.min()))
            good = bool(np.array_equal(ms, Estar))
            ok_map[lam][c] += good
            if not good:
                lf[lam] = n
            if lam == 1.0 and good:
                n_d_step += 1
                ok_d_step += kink          # proof of (d): a single 1-MAP point forces s_+ < 1 < s_-
    for lam in lams:
        last_fail[lam].append(lf[lam])
    last_fail_kink.append(lfk)

print("fraction of runs (of 200) with: the lambda-MAP set equal to E* (lambda = 1, 1.5, 2, 4); s_+ < 1 < s_-;")
print("median and minimum of s_-(n)/n; median and maximum of s_+(n)")
for c, n in enumerate(checkpoints):
    sm = np.array(smin_per_n[c]); sp = np.array(splus_med[c])
    print(f"  n={n:6d}: MAP=E* " + " ".join(f"{ok_map[lam][c] / RUNS:.3f}" for lam in lams)
          + f"; s_+<1<s_- {ok_kink[c] / RUNS:.3f}; s_-/n med {np.median(sm):.5f} min {sm.min():.5f}; "
            f"s_+ med {np.median(sp):.3f} max {sp.max():.3f}")
for lam in lams:
    lf = np.array(last_fail[lam])
    print(f"  lambda={lam}: last checkpoint with MAP set != E*: median {int(np.median(lf))}, max {int(lf.max())} "
          f"(runs never failing: {int(np.sum(lf == 0))})")
lfk = np.array(last_fail_kink)
print(f"  s_+ < 1 < s_-: last failing checkpoint median {int(np.median(lfk))}, max {int(lfk.max())}")
print(f"  deterministic step of (d): at {n_d_step} (run, n) with the 1-MAP set equal to E*, s_+ < 1 < s_- held in {ok_d_step}")
assert ok_d_step == n_d_step
