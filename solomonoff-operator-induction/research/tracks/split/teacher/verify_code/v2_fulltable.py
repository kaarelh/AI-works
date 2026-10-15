"""v2: independent check of teacher/notes-final.md Prop 3.1(c) (full tables, every m: right line, memoriser's
secant, offsets of flatter lines), with the constants of Paper 2's def:teacher:instance and thm:teacher:main.

Written for research/tracks/split/verify-teacher.md; no code shared with teacher/checks/ or referee_code/.
Deterministic (no randomness). B = infinity, delta_S = 0 unless stated; kappa = 0 rows are illustrations.

(A) The rows of the record's Prop 3.1 table: L_S (exact binomial), theta_m, 2^{d-m} theta_m, N c_hi.
(B) Bullet 1 against bullet 3 at tau = 2^{d-m}: the actual offset 2^{d-m} Lambda_2 is at least the lower bound
    N H(p) - tau (ceil(L_S) + kappa_b - kappa_g) that bullet 3 imposes on every right line of that slope
    (a consistency check of the two bullets).
(C) Bullet 3 for tau = rho 2^{d-m}: the bound in units of 2^{d-m} L_S.
(D) Where bullet 2 applies: (D2) puts the memoriser at length >= d + B_S - 4 - Lambda_1; the reference
    (d + kappa_g) lies to its left iff B_S > 4 + Lambda_1 + kappa_g. Level-1 programs exist at every length
    beyond d - 4 - Lambda_1 (padding), so "every level-1 point" includes points to the right of the memoriser.
(E) An explicit three-point class in which bullet 2, read literally, fails at a padded copy of the good model.
"""
import math
from fractions import Fraction as Fr

LOG = math.log2


def H(p):
    return -(p * LOG(p) + (1 - p) * LOG(1 - p))


def consts(d, m, r, kappa=0.0, dS=0.0):
    p = 2.0 ** -r
    s0 = 2 ** (m - r)
    LS = LOG(math.comb(2 ** m, s0))
    BS = LS - dS
    kg = 2 * LOG(d) + 2 * LOG(r) + kappa
    kb = 2 * LOG(d) + 2 * LOG(m) + 2 * LOG(s0) + kappa
    L1 = 2 * LOG(d) + 2 * LOG(m) + kappa
    L2 = 2 ** m * H(p) - BS + 4 + L1 + kg
    G = lambda j: 1 - LOG(1 + (0.0 if j == math.inf else 2.0 ** -j) + 2 * p)
    ts = (d - L1) / 4
    if ts >= 2:
        chi = min((G(1) - H(p)) / (8 + L1 + kg), (G(ts - 1) - H(p)) / (d + kg))
    else:
        chi = (G(1) - H(p)) / (d + kg)
    theta = 2 ** m * H(p) / (math.ceil(LS) + kb + 4 + L1)
    return dict(p=p, s0=s0, LS=LS, BS=BS, kg=kg, kb=kb, L1=L1, L2=L2, chi=chi, theta=theta)


def partA():
    print("=" * 96)
    print("(A) Prop 3.1 table rows (p = 2^-10, B = inf, delta_S = 0, kappa = 0: illustrations)")
    print(f"    {'d':>4} {'m':>3} {'L_S':>11} {'theta_m':>8} {'2^(d-m)':>10} {'2^(d-m)theta':>13} {'N c_hi':>10}")
    for d, m in [(20, 20), (20, 18), (20, 16), (20, 12), (100, 20)]:
        K = consts(d, m, 10)
        f = 2.0 ** (d - m)
        print(f"    {d:4d} {m:3d} {K['LS']:11.2f} {K['theta']:8.4f} {f:10.4g} {f * K['theta']:13.4g} "
              f"{2.0 ** d * K['chi']:10.4g}")


def partB():
    print("=" * 96)
    print("(B) Bullet 1 vs bullet 3 at tau = 2^{d-m}: offset of the line minus the least offset bullet 3 allows,")
    print("    in units of 2^{d-m}; equals ceil(L_S) - L_S + delta_S + 4 + Lambda_1 + kappa_b >= 0")
    for d, m in [(20, 20), (20, 18), (20, 16), (20, 12), (100, 20)]:
        for kappa in (0.0, 30.0):
            for dS in (0.0, 20.0):
                K = consts(d, m, 10, kappa, dS)
                N = 2.0 ** d
                f = 2.0 ** (d - m)
                line_g = f * K["L2"]
                lower = N * H(K["p"]) - f * (math.ceil(K["LS"]) + K["kb"] - K["kg"])
                gap = (line_g - lower) / f
                pred = math.ceil(K["LS"]) - K["LS"] + dS + 4 + K["L1"] + K["kb"]
                assert gap >= 0 and abs(gap - pred) < 1e-6 * max(1, pred)
        print(f"    d={d:3d} m={m:2d}: gap >= 0 for kappa in {{0,30}}, delta_S in {{0,20}} (= predicted form)")


def partC():
    print("=" * 96)
    print("(C) Bullet 3: least offset of a right line of slope rho 2^{d-m}, in units of 2^{d-m} L_S (kappa = 0)")
    for d, m in [(20, 16), (100, 20)]:
        K = consts(d, m, 10)
        row = []
        for rho in (0.0, 0.5, 0.9, K["theta"], 1.0):
            b = (2 ** m * H(K["p"]) - rho * (math.ceil(K["LS"]) + K["kb"] - K["kg"])) / K["LS"]
            row.append(f"rho={rho:.4f}: {b:.4f}")
        print(f"    d={d}, m={m}: " + "; ".join(row))
    print("    (about 1 - rho, as the record says; at rho = theta_m the bound is still positive)")


def partD():
    print("=" * 96)
    print("(D) Where bullet 2 (memoriser's secant >= 2^{d-m} theta_m) is proved: points left of the memoriser")
    for d, m, r in [(20, 20, 10), (20, 12, 10), (100, 20, 10), (100, 10, 6)]:
        for kappa in (0.0, 30.0):
            K = consts(d, m, r, kappa)
            lb_mem = d + K["BS"] - 4 - K["L1"]          # (D2) at level 1 with R_B = 0
            ub_mem = d + math.ceil(K["LS"]) + K["kb"]   # def:teacher:instance(e)
            ref = d + K["kg"]
            lvl1_min = d - 4 - K["L1"]
            print(f"    d={d:3d} m={m:2d} p=2^-{r:<2d} kappa={kappa:4.0f}: level-1 lengths >= {lvl1_min:8.2f}; "
                  f"memoriser in [{lb_mem:9.2f}, {ub_mem:9.2f}]; reference {ref:7.2f} "
                  f"{'left of' if ref < lb_mem else 'NOT provably left of'} it")


def partE():
    print("=" * 96)
    print("(E) Literal bullet 2 fails in a class whose only programs are pi_g, pi_b and a padded copy of pi_g")
    d, m, r = 20, 16, 10
    K = consts(d, m, r)
    N = 2 ** d
    lg = d + K["kg"]
    lb = d + math.ceil(K["LS"]) + K["kb"]
    lpad = lb + 5
    pts = {"pi_g": (lg, N * H(K["p"])), "pi_b": (lb, 0.0), "pi_g padded": (lpad, N * H(K["p"]))}
    for name, (l0, F0) in pts.items():
        sec = max([0.0] + [(F0 - F) / (l - l0) for (l, F) in pts.values() if l > l0])
        print(f"    right secant at {name:12s} (l = {l0:8.2f}, NR = {F0:9.2f}): {sec:10.4f}   "
              f"bound 2^(d-m) theta_m = {2.0 ** (d - m) * K['theta']:.4f}")
    print("    the padded good model is level 1 with R = H(p) but has right secant 0: the bullet needs")
    print("    'either the memoriser dominates the point, or its secant from the point is >= 2^{d-m} theta_m'.")


if __name__ == "__main__":
    partA()
    partB()
    partC()
    partD()
    partE()
