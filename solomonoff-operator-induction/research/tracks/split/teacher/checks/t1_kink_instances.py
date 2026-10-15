"""t1: the teacher's-mistakes theorem and the private-randomness split theorem as instances of one
two-sided kink lemma (notes.md, Lemma 1.1, Props 2.1-2.4).

(A) Lemma 1.1 by brute force, exact arithmetic. Random finite sets of points (l, F, F') with
    F' <= F, labels M / N, a reference point (l0, F0) with min{F : l <= l0} <= F0, a right line
    (tau, anchor) under all M-points, and the left margin m_N(c). For random c > tau and
    0 <= eps < m_N(c) every program with J'_c <= c l0 + F0 + eps is checked to lie in M and to
    satisfy the length, lower-fit and upper-fit bounds of Lemma 1.1(ii); Lemma 1.1(i) is checked
    against the brute-force infimum. Also: m_N is concave in c (checked on a grid).
(B) thm:teacher:main as an instance. For random admissible parameters (d, m, r, kappa, delta_S, B,
    c, eps) the paper's formulas Phi_1, Delta(c), Delta_l and the risk bound (ii)(b) are compared
    with the kink-lemma formulas under the map tau = 2^-m, l0 = d + kappa_g, F0 = H(p),
    l_M = d - 4 - Lambda_1, anchor value B_S/2^m at l_M, g = Lambda_2/2^m.
    Also: the left wedge. Every level-t region {l >= (d - s(t) - Lambda_1)^+, R_B >= G_{t-1}}
    (t = 2..400 and t = infinity) lies on or above the line through (l0, H(p)) of slope -c_hi,
    with the exact s(t) and with 4t; the exact left steepness of these regions is reported.
(C) thm:split:private(i) and iid Thm 4.1(i) as the instance tau = 1, g = k + delta*, N empty.
(D) cor:teacher:fulltable(i) as the total-bit instance tau = 1 (m = d), g = Lambda_2; and the
    full-table window (2^(d-m), N c_hi] for every m, with the sharp lower end
    2^(d-m) theta_m, theta_m = 2^m H(p) / (ceil(L_S) + kappa_b + 4 + Lambda_1) (thm:teacher:main(iv)).
Deterministic: random.seed(31).
"""
import math
import random
from fractions import Fraction as Fr

random.seed(31)


# ---------------------------------------------------------------------------------------------
# (A) Lemma 1.1 by brute force
# ---------------------------------------------------------------------------------------------
def lemma_check(trials=3000):
    stats = dict(sets=0, c_tested=0, near_opt=0, phi_checked=0, concave=0)
    for _ in range(trials):
        npts = random.randint(2, 14)
        pts = []
        for _ in range(npts):
            l = random.randint(0, 30)
            F = Fr(random.randint(0, 400), random.choice([1, 2, 4]))
            Fp = F - Fr(random.randint(0, 20), random.choice([1, 4]))  # F' <= F
            Fp = max(Fp, Fr(0))
            lab = random.choice("MN")
            pts.append((l, F, Fp, lab))
        Mp = [q for q in pts if q[3] == "M"]
        Np = [q for q in pts if q[3] == "N"]
        if not Mp:
            continue
        # reference point: bounded by some program (min F over l <= l0 is <= F0)
        base = random.choice(pts)
        l0 = base[0] + random.randint(0, 3)
        F0 = base[1] + Fr(random.randint(0, 10), 2)
        assert min(q[1] for q in pts if q[0] <= l0) <= F0
        # right line under all M-points: slope -tau, offset g at l0, left boundary l_M
        tau = Fr(random.randint(0, 40), 4)
        lM = min(q[0] for q in Mp)
        # least g with F'(pi) >= F0 - g - tau (l(pi) - l0) for every M-point
        g = max(F0 - q[2] - tau * (q[0] - l0) for q in Mp)
        if lM > l0:
            continue  # the lemma assumes l_M <= l0 (true in both applications)
        g = max(g, Fr(0))
        stats["sets"] += 1

        def mN(c):
            if not Np:
                return None  # +infinity
            return min(c * q[0] + q[2] for q in Np) - (c * l0 + F0)

        # concavity of m_N on a grid
        if Np:
            grid = [Fr(k, 8) for k in range(0, 120)]
            vals = [mN(c) for c in grid]
            for i in range(1, len(grid) - 1):
                assert 2 * vals[i] >= vals[i - 1] + vals[i + 1]
            stats["concave"] += 1
        for _ in range(6):
            c = tau + Fr(random.randint(1, 200), 16)
            m = mN(c)
            if m is not None and m < 0:
                continue
            stats["c_tested"] += 1
            # (i): Phi'(c) >= c l0 + F0 - Delta(c), Delta = max(0, g + (c - tau)(l0 - lM))
            Delta = max(Fr(0), g + (c - tau) * (l0 - lM))
            phi_p = min(c * q[0] + q[2] for q in pts)
            phi = min(c * q[0] + q[1] for q in pts)
            assert phi_p >= c * l0 + F0 - Delta
            assert phi <= c * l0 + F0  # the reference is bounded by a program
            stats["phi_checked"] += 1
            # (ii)
            epsmax = m if m is not None else Fr(50)
            for eps in [Fr(0), epsmax / 3, epsmax * Fr(99, 100)]:
                if m is not None and eps >= m:
                    continue
                for q in pts:
                    if c * q[0] + q[2] <= c * l0 + F0 + eps:
                        stats["near_opt"] += 1
                        assert q[3] == "M"
                        assert q[0] <= l0 + (g + eps) / (c - tau)
                        assert q[2] >= F0 - (c * g + tau * eps) / (c - tau)
                        assert q[2] <= F0 + eps + c * (l0 - q[0])
                        assert q[2] <= F0 + eps + c * (l0 - lM)
    return stats


# ---------------------------------------------------------------------------------------------
# (B) the teacher's constants
# ---------------------------------------------------------------------------------------------
def H(q):
    return 0.0 if q in (0.0, 1.0) else -(q * math.log2(q) + (1 - q) * math.log2(1 - q))


def log2binom(n, k):
    return (math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)) / math.log(2)


def s_of(t):
    return 2 * t + 2 * math.log2(t + 1)


def LS_and_gap(M, k):
    """(log2 binom(M, k), M H(k/M) - log2 binom(M, k)), the second without cancellation.
    For M <= 10^7 via lgamma; above, via Stirling's series (error O(1/k^3))."""
    q = k / M
    if M <= 10 ** 7:
        L = log2binom(M, k)
        return L, M * H(q) - L
    gap = 0.5 * math.log2(2 * math.pi * M * q * (1 - q)) - (1 / (12 * M) - 1 / (12 * k) - 1 / (12 * (M - k))) / math.log(2)
    return M * H(q) - gap, gap


def teacher_consts(d, m, r, kappa, deltaS, B):
    p = 2.0 ** -r
    s0 = 2 ** (m - r)
    LS, gapS = LS_and_gap(2 ** m, s0)
    BS = LS - deltaS
    tauB = 0.0 if B == math.inf else 2.0 ** (1 - B)
    betaB = 0.0 if B == math.inf else 2 ** m * math.log2(1 + tauB)
    L1 = 2 * math.log2(d) + 2 * math.log2(m) + (2 * math.log2(B) if B != math.inf else 0) + betaB + kappa
    kg = 2 * math.log2(d) + 2 * math.log2(r) + kappa
    kb = 2 * math.log2(d) + 2 * math.log2(m) + 2 * math.log2(s0) + kappa

    def G(j):
        v = 0.0 if j == math.inf else 2.0 ** -j
        return 1 - math.log2(1 + v + 2 * p + tauB)

    tstar = (d - L1) / 4
    Hp = H(p)
    if tstar >= 2:
        chi = min((G(1) - Hp) / (8 + L1 + kg), (G(tstar - 1) - Hp) / (d + kg))
    else:
        chi = (G(1) - Hp) / (d + kg)
    return dict(p=p, s0=s0, LS=LS, BS=BS, L1=L1, kg=kg, kb=kb, G=G, tstar=tstar, Hp=Hp, chi=chi,
                gapS=gapS, deltaS=deltaS, L2=gapS + deltaS + 4 + L1 + kg)


def paper_formulas(C, d, m, c, eps):
    Hp, BS, L1, kg = C["Hp"], C["BS"], C["L1"], C["kg"]
    Phi1 = c * (d - 4 - L1) + BS / 2 ** m
    Delta = max(0.0, c * (4 + L1 + kg) + Hp - BS / 2 ** m)
    L2 = C["L2"]  # = 2^m H(p) - B_S + 4 + Lambda_1 + kappa_g, computed without cancellation
    Dl = kg + eps / c + (L2 + eps / c) / (c * 2 ** m - 1)
    Rb = Hp - (c * L2 + eps) / (c * 2 ** m - 1)
    return Phi1, Delta, Dl, Rb, L2


def kink_formulas(C, d, m, c, eps):
    Hp, BS, L1, kg = C["Hp"], C["BS"], C["L1"], C["kg"]
    tau = 2.0 ** -m
    l0, F0 = d + kg, Hp
    lM = d - 4 - L1
    anchor = BS / 2 ** m  # value of the right line at l_M
    g = (C["gapS"] + C["deltaS"]) / 2 ** m + tau * (l0 - lM)  # = F0 - (anchor - tau (l0 - lM))
    assert abs(g - (F0 - (anchor - tau * (l0 - lM)))) <= 1e-9 * max(1.0, F0) + abs(F0) * 1e-12 * 2 ** m
    PhiM = c * l0 + F0 - g - (c - tau) * (l0 - lM)  # Lemma 1.1(i), M-part
    Delta = max(0.0, g + (c - tau) * (l0 - lM))
    lbound = l0 + (g + eps) / (c - tau)
    Rlow = F0 - (c * g + tau * eps) / (c - tau)
    return PhiM, Delta, lbound - d, Rlow, g


def teacher_check(trials=20000):
    worst = dict(Phi1=0.0, Delta=0.0, Dl=0.0, Rb=0.0, g=0.0)
    n = 0
    for _ in range(trials):
        m = random.randint(4, 40)
        d = random.randint(m, 400)
        r = random.randint(2, min(m, 20))
        if m - r > 30:
            continue
        kappa = random.choice([0, 5, 10, 30, 60])
        deltaS = random.choice([0, 1, 10, 20, 100])
        B = random.choice([math.inf, r, r + 3, 30])
        C = teacher_consts(d, m, r, kappa, deltaS, B)
        if C["BS"] < 0:
            continue
        c = 2.0 ** -m * (1 + 10 ** random.uniform(-4, 4))
        eps = random.choice([0.0, 1e-6, 1e-3, 0.05]) * random.random()
        P = paper_formulas(C, d, m, c, eps)
        K = kink_formulas(C, d, m, c, eps)
        sc = lambda a, b: abs(a - b) / max(1.0, abs(a), abs(b))
        worst["Phi1"] = max(worst["Phi1"], sc(P[0], K[0]))
        worst["Delta"] = max(worst["Delta"], sc(P[1], K[1]))
        worst["Dl"] = max(worst["Dl"], sc(P[2], K[2]))
        worst["Rb"] = max(worst["Rb"], sc(P[3], K[3]))
        worst["g"] = max(worst["g"], sc(P[4] / 2 ** m, K[4]))
        n += 1
    return n, worst


def left_wedge(d, m, r, kappa, deltaS, B, T=400):
    """Is every level-t region above the line through (d + kappa_g, H(p)) of slope -c_hi?
    Returns (holds with exact s(t), holds with 4t, exact steepness of the regions, c_hi)."""
    C = teacher_consts(d, m, r, kappa, deltaS, B)
    l0, Hp, chi, G, L1 = d + C["kg"], C["Hp"], C["chi"], C["G"], C["L1"]
    ok_exact = ok_4t = True
    steep = math.inf
    for t in list(range(2, T + 1)) + [math.inf]:
        Gt = G(t - 1) if t != math.inf else G(math.inf)
        for s in ([s_of(t), 4 * t] if t != math.inf else [math.inf, math.inf]):
            lmin = max(0.0, d - s - L1) if s != math.inf else 0.0
            okk = Gt - Hp >= chi * (l0 - lmin) - 1e-12
            if s == (s_of(t) if t != math.inf else math.inf):
                ok_exact &= okk
                if l0 - lmin > 0:
                    steep = min(steep, (Gt - Hp) / (l0 - lmin))
            else:
                ok_4t &= okk
    return ok_exact, ok_4t, steep, chi


# ---------------------------------------------------------------------------------------------
# (C) the split theorem
# ---------------------------------------------------------------------------------------------
def split_check(trials=20000):
    worst = 0.0
    for _ in range(trials):
        k = random.uniform(0, 1000)
        dstar = random.uniform(0, 50)
        lam = 1 + 10 ** random.uniform(-3, 2)
        L0 = random.uniform(0, 1e6)
        # thm:split:private(i): l <= (lam k + dstar)/(lam - 1); fit >= L0 - l - dstar at that l
        paper_l = (lam * k + dstar) / (lam - 1)
        paper_F = L0 - paper_l - dstar
        # Lemma 1.1 with tau = 1, g = k + dstar, l0 = k, F0 = L0, eps = 0, c = lam
        g = k + dstar
        kink_l = k + g / (lam - 1)
        kink_F = L0 - lam * g / (lam - 1)
        worst = max(worst, abs(paper_l - kink_l) / max(1, paper_l), abs(paper_F - kink_F) / max(1, abs(paper_F)))
    return worst


# ---------------------------------------------------------------------------------------------
# (D) full tables for every m
# ---------------------------------------------------------------------------------------------
def fulltable_rows():
    rows = []
    for (d, r) in [(20, 10), (100, 10)]:
        for m in sorted({d, d - 2, d - 4, d - 8, 20, 16, 12} & set(range(r, d + 1)), reverse=True):
            for kappa in [0, 30]:
                C = teacher_consts(d, m, r, kappa, 0, math.inf)
                N = 2.0 ** d
                lo = 2.0 ** (d - m)
                theta = 2 ** m * C["Hp"] / (math.ceil(C["LS"]) + C["kb"] + 4 + C["L1"])
                L2 = C["L2"]
                rows.append((d, m, r, kappa, lo, lo * theta, N * C["chi"], L2, 2 ** (d - m) * L2))
    return rows


def fulltable_md_check():
    """m = d: cor:teacher:fulltable(i) l <= d + kappa_g + Lambda_2/(lam - 1) and
    N R >= N H(p) - lam Lambda_2/(lam - 1) equal Lemma 1.1 in total bits with tau = 1, g = Lambda_2."""
    worst = 0.0
    for _ in range(5000):
        d = random.randint(8, 40)
        r = random.randint(2, min(d, 14))
        kappa = random.choice([0, 10, 30])
        deltaS = random.choice([0, 5, 20])
        C = teacher_consts(d, d, r, kappa, deltaS, math.inf)
        N = 2.0 ** d
        lam = 1 + 10 ** random.uniform(-3, 3)
        c = lam / N
        P = paper_formulas(C, d, d, c, 0.0)
        L2 = P[4]
        cor_l = C["kg"] + L2 / (lam - 1)          # excess length, cor:teacher:fulltable(i)
        cor_F = N * C["Hp"] - lam * L2 / (lam - 1)  # lower bound on N R
        # Lemma 1.1 in total bits: tau = 1, g = Lambda_2 (= N * Lambda_2 / 2^m), F0 = N H(p)
        kl = C["kg"] + L2 / (lam - 1)
        kF = N * C["Hp"] - lam * L2 / (lam - 1)
        worst = max(worst, abs(cor_l - kl) / max(1, cor_l), abs(cor_F - kF) / max(1, abs(cor_F)),
                    abs(cor_l - P[2]) / max(1, cor_l), abs(cor_F / N - P[3]) / max(1, abs(P[3])))
    return worst


if __name__ == "__main__":
    print("=" * 96)
    print("(A) Lemma 1.1 by brute force (exact fractions)")
    st = lemma_check()
    for k, v in st.items():
        print(f"    {k:12s} {v}")
    print("    all assertions passed")
    print("=" * 96)
    print("(B) thm:teacher:main (i), (ii)(b), (ii)(c) as an instance of Lemma 1.1")
    n, worst = teacher_check()
    print(f"    {n} random parameter sets; largest relative differences paper vs lemma:")
    for k, v in worst.items():
        print(f"      {k:6s} {v:.2e}")
    print("    left wedge at c_hi (every level-t region above the line of slope -c_hi through (d+kappa_g, H(p))):")
    for (d, m, r, kappa, dS, B) in [(100, 20, 10, 0, 0, math.inf), (100, 20, 10, 30, 0, math.inf),
                                    (100, 20, 10, 0, 20, math.inf), (100, 20, 10, 0, 0, 30),
                                    (20, 20, 10, 0, 0, math.inf), (20, 20, 10, 30, 0, math.inf),
                                    (100, 24, 10, 0, 0, math.inf), (100, 10, 6, 0, 0, math.inf),
                                    (100, 10, 6, 30, 0, math.inf), (60, 20, 5, 0, 0, math.inf)]:
        ok_e, ok_4, steep, chi = left_wedge(d, m, r, kappa, dS, B)
        print(f"      d={d:3d} m={m:2d} r={r:2d} kappa={kappa:2d} delta_S={dS:2d} B={B}: "
              f"c_hi={chi:.4e}  exact steepness of the level regions={steep:.4e}  "
              f"wedge holds: exact s(t) {ok_e}, 4t {ok_4}")
    print("=" * 96)
    print("(C) thm:split:private(i) as Lemma 1.1 with tau = 1, g = k + delta*:")
    print(f"    largest relative difference over 20000 random (k, delta*, lambda, L0): {split_check():.2e}")
    print("=" * 96)
    print("(D) full tables: m = d (cor:teacher:fulltable(i)) as Lemma 1.1 in total bits with tau = 1, g = Lambda_2")
    print(f"    largest relative difference over 5000 random instances: {fulltable_md_check():.2e}")
    print("    the full-table lambda-window (2^(d-m), N c_hi] for every m (B = inf, delta_S = 0);")
    print("    'sharp' = 2^(d-m) theta_m: below it the memoriser beats every level-1 program with R >= H(p)")
    print(f"    {'d':>4} {'m':>4} {'r':>3} {'kap':>4} | {'2^(d-m)':>10} {'sharp':>10} {'N c_hi':>11} | {'Lambda_2':>9} {'g_total':>10}")
    for (d, m, r, kappa, lo, sharp, hi, L2, gt) in fulltable_rows():
        print(f"    {d:4d} {m:4d} {r:3d} {kappa:4d} | {lo:10.4g} {sharp:10.4g} {hi:11.4g} | {L2:9.2f} {gt:10.4g}")
