"""Re-referee r2: independent check of depth-two.md Section 7.1 (the RT 5.4 optimisation record) and the
numerics bullets of the Section 6 errata.

Independent of ../../../../.../checks/depth-two/rt54_record.py:
  - the sample is rebuilt from the same random calls as memorize_opt.py (that is what defines the sample),
    but the statistics are computed with plain Python dicts and exact Fractions, not np.bincount;
  - the run files are parsed field by field;
  - the certified quantities are evaluated both with the recorded objective as printed and with the
    worst value consistent with its two-decimal rounding (F_rec + 0.005);
  - the excess lower bound for near-minimizers is computed from Lemma 1.2 (a) and (b) separately.

Run: python3 rr2_rt54.py > rr2_rt54.out
"""
import math
import re
from fractions import Fraction

import numpy as np

CHK = "/workspace/ai-works/neural-network-generalization/works-in-progress/agnostic-learning/checks/"
RUNS = [  # file, d, L, N, c
    (CHK + "verify-RT-depth2-computation/rerun_d8_L2_c1.txt", 8, 2, 256, 1),
    (CHK + "red-team-and-literature/run_d10_L2.txt", 10, 2, 512, 1),
    (CHK + "red-team-and-literature/run_d10_L3.txt", 10, 3, 128, 1),
    (CHK + "red-team-and-literature/run_d8_L2_c4.txt", 8, 2, 256, 4),
    (CHK + "red-team-and-literature/run_d8_L3_c4.txt", 8, 3, 128, 4),
    (CHK + "red-team-and-literature/run_d8_L2_c16.txt", 8, 2, 256, 16),
    (CHK + "red-team-and-literature/run_d8_L3_c16.txt", 8, 3, 128, 16),
]


def sample(d, seed):
    rng = np.random.default_rng(seed)
    M = 2 ** d
    n = M
    idx = rng.integers(0, M, size=n)
    ys = rng.choice([-1.0, 1.0], size=n)
    k, S = {}, {}
    for i, y in zip(idx.tolist(), ys.tolist()):
        k[i] = k.get(i, 0) + 1
        S[i] = S.get(i, 0) + int(y)
    G = sum(Fraction(S[x] ** 2, k[x]) for x in k)
    Q = sum(Fraction(S[x] ** 2, k[x] ** 2) for x in k)
    V = sum(S[x] ** 2 for x in k)
    W = sum((y - Fraction(S[i], k[i])) ** 2 for i, y in zip(idx.tolist(), [int(v) for v in ys.tolist()]))
    assert W == n - G
    return dict(M=M, n=n, s=len(k), G=G, Q=Q, V=V, W=W)


stats = {8: sample(8, 0), 10: sample(10, 1)}
for d, st in stats.items():
    print("d=%d: M=n=%d s=%d G=%s=%.6f Q=%.6f Q/M=%.6f V=%d W=%.6f" % (
        d, st["M"], st["s"], st["G"], float(st["G"]), float(st["Q"]), float(st["Q"]) / st["M"], st["V"], float(st["W"])))


def lb12(G, Q, V, M, B):
    tri = (math.sqrt(Q) - math.sqrt(B)) ** 2 / M if B < Q else 0.0
    cor = (G - B) ** 2 / (4 * M * V) if B < G else 0.0
    return tri, cor


print()
print("d L   N   c | file: F-W/c kappa R phi | kappa+R/c | phi(F_rec) phi_cert(F_rec+.005) | near-min capture"
      " | LB tri/cor (obj<=found) | LB tri/cor (near-min) | file 'rigorous LB' vs (phi G)^2/(4MV)")
for fn, d, L, N, c in RUNS:
    txt = open(fn).read()
    fld = dict(re.findall(r"([A-Za-z/\-]+)=(-?[0-9.]+)", txt))
    st = stats[d]
    M, G, Q, V = st["M"], float(st["G"]), float(st["Q"]), st["V"]
    assert int(fld["d"]) == d and int(fld["L"]) == L and int(fld["N"]) == N and float(fld["c"]) == c
    assert abs(float(fld["G"]) - G) <= 0.05 and int(fld["s"]) == st["s"]
    F = float(fld["F-W/c"]); kap = float(fld["kappa"]); R = float(fld["R"])
    phi_rec = 1 - c * F / G
    phi_cert = 1 - c * (F + 0.005) / G
    cap_nm = phi_cert - c / G
    t1, c1 = lb12(G, Q, V, M, (1 - phi_cert) * G)
    t2, c2 = lb12(G, Q, V, M, (1 - phi_cert) * G + c)
    rig = max(phi_rec * G, 0) ** 2 / (4 * M * V)
    print("%2d %d %4d %2d | %7.2f %6.2f %6.2f %s | %7.3f | %.6f %.6f | %+.6f | %.6f/%.6f | %.6f/%.6f | %s vs %.4f" % (
        d, L, N, c, F, kap, R, fld["theta"], kap + R / c, phi_rec, phi_cert, cap_nm, t1, c1, t2, c2,
        fld["LB"], rig))

G8 = float(stats[8]["G"])
print()
print("RT row d=8 L=3 c=1 (no run file): kappa+R = %.1f; phi = 1-46.8/G = %.4f; sweep: kappa+R/4 = %.3f vs G/4 = %.3f"
      % (43.7 + 3.1, 1 - 46.8 / G8, 43.7 + 3.1 / 4, G8 / 4))
print("zero network objective at c=16: G/16 = %.4f" % (G8 / 16))
print("c/G at c=4, d=8: %.6f ; c/G at c=16: %.6f" % (4 / G8, 16 / G8))
print("asymptotic n^(1-1/H) at n=256, H=2: %.1f" % (256 ** 0.5))
