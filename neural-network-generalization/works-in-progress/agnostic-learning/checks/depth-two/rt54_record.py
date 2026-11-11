"""The optimisation runs of red-team.md section 5.4, carried into depth-two.md section 7.1.

The runs were made with ../red-team-and-literature/memorize_opt.py and memorize_opt2.py: cube example with n = M = 2^d
inputs drawn with replacement and fair-sign labels (lambda = 1), sample seed 0 at d = 8 and seed 1 at d = 10, L-BFGS on
F_c - W/c = kappa_N + R/c.  This script does not re-run the optimisation.  It
  - rebuilds the two samples with the same random calls and computes G, Q, V, W exactly (fractions);
  - reads the recorded objective values F - W/c from the run files (printed with two decimals);
  - evaluates the certified quantities for that sample, at the run's width:
      phi_cert = 1 - c (F_rec + 0.005) / G     (F_rec + 0.005 bounds the objective value found);
      every network with objective at most the one found has R <= (1 - phi_cert) G;
      every near-minimizer (slack 1 in F_c, so c in c F_c) has R <= (1 - phi_cert) G + c,
        hence captures at least phi_cert - c/G of G;
      the excess of every clipped near-minimizer is at least max(Psi_tri, Psi_cor) of Lemma 1.2 with that budget.
The run files' field "rigorous near-min excess LB" is (phi G)^2/(4 M V): the bound for networks whose objective is at
most the one found, without the slack c of a near-minimizer.

Run: python3 rt54_record.py > rt54_record.out   (under a second)
"""
import math
import re
from fractions import Fraction

import numpy as np

RUNS = [  # (file, d, L, c)
    ("../verify-RT-depth2-computation/rerun_d8_L2_c1.txt", 8, 2, 1.0),
    ("../red-team-and-literature/run_d10_L2.txt", 10, 2, 1.0),
    ("../red-team-and-literature/run_d10_L3.txt", 10, 3, 1.0),
    ("../red-team-and-literature/run_d8_L2_c4.txt", 8, 2, 4.0),
    ("../red-team-and-literature/run_d8_L3_c4.txt", 8, 3, 4.0),
    ("../red-team-and-literature/run_d8_L2_c16.txt", 8, 2, 16.0),
    ("../red-team-and-literature/run_d8_L3_c16.txt", 8, 3, 16.0),
]
SEED = {8: 0, 10: 1}


def sample_stats(d, seed):
    rng = np.random.default_rng(seed)
    M = 2 ** d
    n = M
    idx = rng.integers(0, M, size=n)
    ys = rng.choice([-1.0, 1.0], size=n)
    k = np.bincount(idx, minlength=M)
    S = np.rint(np.bincount(idx, weights=ys, minlength=M)).astype(int)
    G = sum(Fraction(int(S[x]) ** 2, int(k[x])) for x in range(M) if k[x] > 0)
    Q = sum(Fraction(int(S[x]) ** 2, int(k[x]) ** 2) for x in range(M) if k[x] > 0)
    V = sum(int(S[x]) ** 2 for x in range(M))
    W = n - G
    s = int((k > 0).sum())
    return M, n, s, G, Q, V, W


stats = {d: sample_stats(d, SEED[d]) for d in SEED}
for d in sorted(stats):
    M, n, s, G, Q, V, W = stats[d]
    print("d = %2d (seed %d): M = n = %d, s = %d, G = %s = %.4f, Q/M = %.6f, V = %d, W = %.4f" % (
        d, SEED[d], M, s, G, float(G), float(Q) / M, V, float(W)))

print()
print("All certified values are printed with six decimals; quote them rounded down.")
print(" d  L    c   F-W/c   kappa       R   phi(file)  phi_cert   near-min capture  excess LB (obj <= found)  excess LB (near-min)  found excess (seen part)")
for fname, d, L, c in RUNS:
    line = open(fname).read()
    rec = {key: float(val) for key, val in re.findall(r"(F-W/c|kappa|R|theta|G)=(-?[0-9.]+)", line)}
    exc = re.search(r"excess\(found w\)=([0-9.]+) \(seen part ([0-9.]+)\)", line)
    M, n, s, G, Q, V, W = stats[d]
    Gf, Qf = float(G), float(Q)
    assert abs(rec["G"] - Gf) < 0.05, (fname, rec["G"], Gf)
    phi_cert = 1 - c * (rec["F-W/c"] + 0.005) / Gf
    budget_found = (1 - phi_cert) * Gf
    budget_nm = budget_found + c

    def excess_lb(B):
        tri = (math.sqrt(Qf) - math.sqrt(B)) ** 2 / M if B < Qf else 0.0
        cor = (Gf - B) ** 2 / (4 * M * V) if B < Gf else 0.0
        return max(tri, cor)

    print("%2d  %d  %4.0f  %6.2f  %6.2f  %6.2f    %6.3f    %9.6f   %9.6f          %9.6f                 %9.6f            %s (%s)" % (
        d, L, c, rec["F-W/c"], rec["kappa"], rec["R"], rec["theta"], phi_cert, phi_cert - c / Gf,
        excess_lb(budget_found), excess_lb(budget_nm), exc.group(1), exc.group(2)))

print()
print("d = 8, L = 3, c = 1 (red-team.md section 5.4 table and sweep: kappa = 43.7, R = 3.1): no run file in the repository.")
G8 = float(stats[8][3])
print("  values as printed there: kappa + R/4 = %.3f against G/4 = %.2f at c = 4" % (43.7 + 3.1 / 4, G8 / 4))
