"""rB8: two sharper forms of thm:teacher:main(ii)(a) (and hence (e)), proposed by referee B, computed at the
paper's example and at the rows of notes.md's t4(B) table.

The paper's (a): u >= max{3/4, 2^-(J_g + eps) - p - 2^-B}, from the floor R_B >= -log2(u + p + 2^-B) and R_B <= J_g + eps.
(a1) A near-optimal program is level 1, so (D1) gives l >= d - 4 - Lambda_1 and hence
       R_B <= R_max := J_g(c) + eps - c (d - 4 - Lambda_1) = c (kappa_g + 4 + Lambda_1) + H(p) + eps,
     which removes the term c d from the exponent:  u >= 2^-R_max - p - 2^-B.
(a2) With the sharp floor (lem:teacher:sharpfloor) and I(pi) <= Delta_l + Lambda_3 (thm:teacher:main(ii)(d)):
       u >= (2^-R_max - p (1 + 2 gamma_g + 2^(1-g)) - 2^-B) / (1 - 2p),  gamma_g as in (ii)(e), g optimised.
Then (e): e <= 1 - u + gamma_g + 2^-g with the better u (g optimised separately).
Instance constants as in rB2 (paper's) and, for general p, kappa_g = 2 log d + K(p) + kappa as in t4.
Deterministic.
"""
import math

LN2 = math.log(2)


def H(q):
    return -(q * math.log2(q) + (1 - q) * math.log2(1 - q))


def least_j(rhs):
    j = 0
    while j - 2 * math.log2(j + 1) <= rhs:
        j += 1
    return j


def bounds(d, m, p_num, p_exp, kappa, deltaS, c, eps=0.0, gmax=40):
    p = p_num / 2 ** p_exp
    s0 = int(round(p * 2 ** m))
    M = 2 ** m
    gap = 0.5 * math.log2(2 * math.pi * M * p * (1 - p)) - (1 / (12 * M) - 1 / (12 * s0) - 1 / (12 * (M - s0))) / LN2
    h, e = p_num, p_exp
    while h % 2 == 0:
        h //= 2
        e -= 1
    Kp = 2 * math.log2(e) if h == 1 else 2 * math.log2(h + 1) + 2 * math.log2(e + 1)
    kg = 2 * math.log2(d) + Kp + kappa
    L1 = 2 * math.log2(d) + 2 * math.log2(m) + kappa
    Hp = H(p)
    L2 = gap + deltaS + 4 + L1 + kg
    L3 = 4 + 2 * math.log2(d) + kappa
    Jg = c * (d + kg) + Hp
    Dl = kg + eps / c + (L2 + eps / c) / (c * M - 1)
    gam = []
    for g in range(1, gmax + 1):
        rhs = deltaS + Dl + L3 + 1 + 2 * math.log2(m) + 2 * math.log2(s0) + g + 2 * math.log2(g) + kappa
        gam.append((g, math.sqrt(least_j(rhs) * LN2 / (2 * s0))))
    u_paper = max(0.75, 2 ** -(Jg + eps) - p)
    Rmax = c * (kg + 4 + L1) + Hp + eps
    u1 = max(0.75, 2 ** -Rmax - p)
    u2 = max([0.75] + [(2 ** -Rmax - p * (1 + 2 * gm + 2.0 ** (1 - g))) / (1 - 2 * p) for (g, gm) in gam])
    e_of = lambda u: min(1 - u + gm + 2.0 ** -g for (g, gm) in gam)
    return dict(p=p, u_paper=u_paper, u1=u1, u2=u2, e_paper=e_of(u_paper), e1=e_of(u1), e2=e_of(u2), Dl=Dl)


def main():
    print("=" * 108)
    print("Paper's example: d = 100, m = 20, p = 2^-10, B = inf, eps = 0, c = 1e-4 (paper's table: u >= 0.983 / 0.981, e <= 0.199 ... 0.287)")
    for (kappa, dS) in ((0, 0), (0, 20), (30, 0), (30, 20)):
        b = bounds(100, 20, 1, 10, kappa, dS, 1e-4)
        print(f"  kappa={kappa:2d} delta_S={dS:2d}: u >= {b['u_paper']:.4f} (paper's (a)), {b['u1']:.4f} (a1), {b['u2']:.4f} (a2);  "
              f"e <= {b['e_paper']:.4f}, {b['e1']:.4f}, {b['e2']:.4f}")
    print("  near the top of the window (kappa = 0, delta_S = 0):")
    for c in (2e-3, 4e-3, 6e-3, 8e-3):
        b = bounds(100, 20, 1, 10, 0, 0, c)
        print(f"    c = {c:.0e}: u >= {b['u_paper']:.4f} (paper), {b['u1']:.4f} (a1), {b['u2']:.4f} (a2); e <= {b['e_paper']:.4f}, "
              f"{b['e1']:.4f}, {b['e2']:.4f}")
    print("=" * 108)
    print("notes' t4(B) rows (d = 100, m = 20, kappa = 0, delta_S = 0, at the notes' c): notes report u >= 0.750 and e <= 0.27-0.28")
    for (num, e, c) in ((1, 4, 6.745e-5), (5, 6, 5.282e-5), (3, 5, 4.278e-5), (7, 6, 4.337e-5), (15, 7, 3.586e-5)):
        b = bounds(100, 20, num, e, 0, 0, c)
        print(f"  p = {num}/{2 ** e:<4d} c = {c:.3e}: u >= {b['u_paper']:.4f} (paper's (a)), {b['u1']:.4f} (a1), {b['u2']:.4f} (a2);  "
              f"e <= {b['e_paper']:.4f}, {b['e1']:.4f}, {b['e2']:.4f}  (l <= d + {b['Dl']:.1f})")


if __name__ == "__main__":
    main()
