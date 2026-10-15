"""v1: independent exact checks of teacher/notes-final.md Lemma 1.1 (final form), Def 1.4, Lemma 1.5, Lemma 3.0.

Written for the independent verification (research/tracks/split/verify-teacher.md). Shares no code with
teacher/checks/ or teacher/referee_code/. Exact rational arithmetic (fractions.Fraction); infinite fits are None.
Seeded: random.Random(20261013). Deterministic.

Differences from the record's t7(A): here the two fits differ (F' <= F, with F' < F on about half the programs,
and some infinite F or F'), the offset g is either the least admissible one or a random larger one, l_M is random
below min(l0, least length in M), and the margin epsilon is pointwise (no infimum).

(1) Lemma 1.1 (i)-(iv) and the last bullet; the observation that the hypotheses of (ii) force g >= 0.
(2) Def 1.4's sentence "a right line exists for every tau >= 0, for example with g = F0": counterexamples, and the
    offset F0 + tau (l0 - l_M) that always works.
(3) Lemma 1.5 (a)-(c), with F' != F.
(4) Lemma 3.0 (duplication): MAP sets, exact lambda-intervals of every point, hull slopes, least offsets, right
    secants and left steepness all scale by r.
(5) Necessity: c > tau and the strict pointwise margin cannot be dropped (two explicit point sets).
"""
from fractions import Fraction as Fr
import random

R = random.Random(20261013)
INF = None


def le(a, b):            # a <= b with None = +infinity
    if b is None:
        return True
    if a is None:
        return False
    return a <= b


def add(a, b):
    return None if (a is None or b is None) else a + b


def rand_prog(lmax=24, fmax=40):
    l = R.randint(0, lmax)
    u = R.random()
    if u < 0.06:
        Fp, F = None, None
    else:
        Fp = Fr(R.randint(0, fmax * 6), 6)
        if u < 0.10:
            F = None
        elif u < 0.55:
            F = Fp
        else:
            F = Fp + Fr(R.randint(1, 30), 6)
    return (l, Fp, F)


def J(c, prog, prime):
    l, Fp, F = prog
    f = Fp if prime else F
    return None if f is None else c * l + f


def minJ(c, progs, prime):
    vals = [J(c, q, prime) for q in progs]
    vals = [v for v in vals if v is not None]
    return min(vals) if vals else None


def part1(n_sets=4000):
    st = dict(sets=0, slopes=0, i_checks=0, sandwich=0, gneg=0, gneg_bounded_by_M=0, ii_hyp=0,
              ii_hyp_with_gneg=0, ii_hyp_in_sets_with_least_gneg=0, near=0, near_from_Phi=0, iv=0, lastbullet=0,
              concave=0)
    for _ in range(n_sets):
        M = [rand_prog() for _ in range(R.randint(1, 9))]
        N = [rand_prog() for _ in range(R.randint(0, 7))]
        l0 = R.randint(0, 24)
        F0 = Fr(R.randint(0, 40 * 6), 6)
        # bounding program, in M or in N (with F <= F0, so also F' <= F0)
        Fb = F0 - Fr(R.randint(0, 12), 6)
        if Fb < 0:
            Fb = Fr(0)
        b = (R.randint(0, l0), Fb - Fr(R.randint(0, 6), 6) if Fb >= 1 else Fb, Fb)
        if R.random() < 0.5:
            M.append(b)
        else:
            N.append(b)
        Mfin = [q for q in M if q[1] is not None]
        bounded_by_M = any(q[0] <= l0 and le(q[2], F0) for q in M)
        bounded_by_N = any(q[0] <= l0 and le(q[2], F0) for q in N)
        assert bounded_by_M or bounded_by_N
        tau = Fr(R.randint(0, 30), 6)
        lmin = min(q[0] for q in M)
        lM = R.randint(min(0, l0), min(l0, lmin)) if min(l0, lmin) >= 0 else 0
        # least admissible g (real; may be negative); programs with F' = inf impose nothing
        gl = max((F0 - q[1] - tau * (q[0] - l0) for q in Mfin), default=None)
        if gl is None:
            continue
        g = gl if R.random() < 0.6 else gl + Fr(R.randint(1, 30), 6)
        if gl < 0:
            st["gneg"] += 1
            if bounded_by_M:
                st["gneg_bounded_by_M"] += 1
        if bounded_by_M:
            assert g >= 0           # (i), second sentence
        st["sets"] += 1
        allp = M + N
        for _c in range(10):
            c = tau + Fr(R.randint(1, 60), 12)
            ref = c * l0 + F0
            Delta = g + (c - tau) * (l0 - lM)
            if bounded_by_M:
                assert Delta >= 0
            JN = [J(c, q, True) for q in N]
            mN = None if all(v is None for v in JN) else min(v for v in JN if v is not None) - ref
            # (i) first sentence
            inf_all = minJ(c, allp, True)
            lower = -Delta if mN is None else min(mN, -Delta)
            assert inf_all is not None and inf_all >= ref + lower
            st["i_checks"] += 1
            Phi = minJ(c, allp, False)
            assert Phi is not None and Phi <= ref
            if (mN is None or mN >= 0) and Delta >= 0:
                assert ref - Delta <= Phi <= ref
                st["sandwich"] += 1
            # last bullet
            if not bounded_by_M:
                assert mN is not None and mN <= 0
                st["lastbullet"] += 1
            # (iii) concavity of m_N on a triple
            if mN is not None:
                c2 = c + Fr(R.randint(1, 30), 12)
                cm = (c + c2) / 2
                def mNat(cc):
                    vv = [J(cc, q, True) for q in N if q[1] is not None]
                    return min(vv) - (cc * l0 + F0)
                assert mNat(cm) >= (mNat(c) + mNat(c2)) / 2
                st["concave"] += 1
            # (ii) with a pointwise margin
            margins = [v - ref for v in JN if v is not None]
            if margins and min(margins) <= 0:
                epss = []
            else:
                top = min(margins) if margins else Fr(50)
                epss = [Fr(0), top * Fr(R.randint(0, 99), 100)]
            for eps in epss:
                assert all(v is None or v > ref + eps for v in JN)
                st["ii_hyp"] += 1
                if g < 0:
                    st["ii_hyp_with_gneg"] += 1
                if gl < 0:
                    st["ii_hyp_in_sets_with_least_gneg"] += 1
                for q in allp:
                    Jp = J(c, q, True)
                    Jq = J(c, q, False)
                    if Jq is not None and Jq <= Phi + eps:
                        assert Jp is not None and Jp <= ref + eps
                        st["near_from_Phi"] += 1
                    if Jp is not None and Jp <= ref + eps:
                        st["near"] += 1
                        assert q in M
                        l, Fp, _ = q
                        assert (c - tau) * (l - l0) <= g + eps
                        assert l <= l0 + (g + eps) / (c - tau)
                        assert Fp >= F0 - (c * g + tau * eps) / (c - tau)
            # (iv): no right line needed, every c > 0, every eps >= 0
            for eps in (Fr(0), Fr(R.randint(0, 40), 6)):
                for q in M:
                    Jp = J(c, q, True)
                    if Jp is not None and Jp <= ref + eps:
                        assert q[1] <= F0 + eps + c * (l0 - q[0]) <= F0 + eps + c * (l0 - lM)
                        st["iv"] += 1
            st["slopes"] += 1
    print("=" * 96)
    print("(1) Lemma 1.1, final form (two fits F' <= F, real g, pointwise margin, item (iv))")
    for k, v in st.items():
        print(f"    {k:22s} {v}")
    assert st["gneg_bounded_by_M"] == 0
    assert st["ii_hyp_with_gneg"] == 0
    assert st["ii_hyp_in_sets_with_least_gneg"] == 0
    print("    all assertions passed")
    print("    observation: in no set whose least admissible g is negative do the hypotheses of (ii) hold:")
    print("    a bounded reference plus a pointwise margin forces the bounding program into M, hence g >= 0.")


def part2(n_sets=3000):
    fails = ok_alt = 0
    example = None
    for _ in range(n_sets):
        M = [rand_prog() for _ in range(R.randint(1, 9))]
        Mfin = [q for q in M if q[1] is not None]
        if not Mfin:
            continue
        l0 = R.randint(0, 24)
        F0 = Fr(R.randint(0, 40 * 6), 6)
        tau = Fr(R.randint(0, 30), 6)
        lM = min(min(q[0] for q in M), l0)
        holds_F0 = all(q[1] >= F0 - F0 - tau * (q[0] - l0) for q in Mfin)
        holds_alt = all(q[1] >= F0 - (F0 + tau * (l0 - lM)) - tau * (q[0] - l0) for q in Mfin)
        assert holds_alt
        ok_alt += 1
        if not holds_F0:
            fails += 1
            if example is None:
                bad = [q for q in Mfin if q[1] < -tau * (q[0] - l0)][0]
                example = (l0, F0, tau, bad)
    print("=" * 96)
    print("(2) Def 1.4: 'a right line exists for every tau >= 0, for example with g = F0'")
    print(f"    g = F0 fails (R) in {fails} of {ok_alt} random sets; g = F0 + tau (l0 - l_M) holds in all {ok_alt}")
    l0, F0, tau, bad = example
    print(f"    first failure: l0 = {l0}, F0 = {F0}, tau = {tau}; program (l, F') = ({bad[0]}, {bad[1]}) needs "
          f"F' >= tau (l0 - l) = {tau * (l0 - bad[0])}")
    # the minimal two-point counterexample used in verify-teacher.md
    l0, F0, tau, q = 10, Fr(5), Fr(1), (0, Fr(0))
    assert not (q[1] >= F0 - F0 - tau * (q[0] - l0))
    print("    minimal example: reference (10, 5), tau = 1, M = {(0, 0)}: (R) with g = F0 needs 0 >= 10; fails")


def part3(n_sets=4000):
    na = nb = nc = 0
    for _ in range(n_sets):
        M = [rand_prog() for _ in range(R.randint(1, 10))]
        Mfin = [q for q in M if q[1] is not None]
        if not Mfin:
            continue
        l0 = R.randint(0, 24)
        F0 = Fr(R.randint(0, 40 * 6), 6)
        tau = Fr(R.randint(0, 30), 6)
        g = max(F0 - q[1] - tau * (q[0] - l0) for q in Mfin) + Fr(R.randint(0, 6), 6)
        longer = [q for q in Mfin if q[0] > l0]
        for q in longer:
            x = q[0] - l0
            s = (F0 - q[1]) / x
            assert s <= tau + g / x                     # (a)
            assert g >= (s - tau) * x                   # (b)
            na += 1
            nb += 1
        splus = max([Fr(0)] + [(F0 - q[1]) / (q[0] - l0) for q in longer])
        # (c): reference attained by pi_0 = (l0, F0) (F'(pi_0) = F0)
        lams = [Fr(0), splus, splus * Fr(R.randint(0, 99), 100), splus + Fr(R.randint(1, 30), 6)]
        for lam in lams:
            Jref = lam * l0 + F0
            strictly = [q for q in longer if lam * q[0] + q[1] < Jref]
            weakly = [q for q in longer if lam * q[0] + q[1] <= Jref]
            if lam < splus:
                assert strictly
            if lam > splus:
                assert not weakly
            nc += 1
    print("=" * 96)
    print("(3) Lemma 1.5")
    print(f"    (a) {na} longer programs, secant <= tau + g/x; (b) {nb}, g >= (s1 - tau) x1; (c) {nc} values of lambda >= 0")
    print("    all assertions passed (lambda = s_+ itself is not covered by (c) and was not asserted)")


def lam_interval(pts, i):
    """exact set {lam >= 0 : point i minimises lam*l + F} as (lo, hi) with hi None = +inf, or None if empty."""
    li, Fi = pts[i]
    lo, hi = Fr(0), None
    for j, (lj, Fj) in enumerate(pts):
        if j == i:
            continue
        # need lam*li + Fi <= lam*lj + Fj  <=>  lam (li - lj) <= Fj - Fi
        if li == lj:
            if Fi > Fj:
                return None
        elif li > lj:      # lam <= (Fj - Fi)/(li - lj)
            b = (Fj - Fi) / (li - lj)
            hi = b if hi is None else min(hi, b)
        else:              # lam >= (Fi - Fj)/(lj - li)
            lo = max(lo, (Fi - Fj) / (lj - li))
    if hi is not None and hi < lo:
        return None
    return (lo, hi)


def least_g(pts, l0, F0, tau):
    return max(F0 - F - tau * (l - l0) for (l, F) in pts)


def right_secant(pts, l0, F0):
    return max([Fr(0)] + [(F0 - F) / (l - l0) for (l, F) in pts if l > l0])


def left_steepness(pts, l0, F0):
    """largest sigma with F >= F0 + sigma (l0 - l) for every point with l < l0 (inf of the secants)."""
    left = [(F - F0) / (l0 - l) for (l, F) in pts if l < l0]
    return min(left) if left else None


def part4(n_sets=3000):
    n = 0
    for _ in range(n_sets):
        pts = [(R.randint(0, 24), Fr(R.randint(0, 240), 6)) for _ in range(R.randint(2, 12))]
        r = R.randint(2, 9)
        dup = [(l, r * F) for (l, F) in pts]
        for i in range(len(pts)):
            a, b = lam_interval(pts, i), lam_interval(dup, i)
            if a is None:
                assert b is None
            else:
                assert b == (r * a[0], None if a[1] is None else r * a[1])
            n += 1
        l0 = R.randint(0, 24)
        F0 = Fr(R.randint(0, 240), 6)
        tau = Fr(R.randint(0, 30), 6)
        assert least_g(dup, l0, r * F0, r * tau) == r * least_g(pts, l0, F0, tau)
        assert right_secant(dup, l0, r * F0) == r * right_secant(pts, l0, F0)
        s1, s2 = left_steepness(pts, l0, F0), left_steepness(dup, l0, r * F0)
        assert (s1 is None and s2 is None) or s2 == r * s1
        lams = [Fr(R.randint(0, 400), 16) for _ in range(6)]
        for lam in lams:
            v1 = [lam * l + F for (l, F) in dup]
            v0 = [(lam / r) * l + F for (l, F) in pts]
            m1, m0 = min(v1), min(v0)
            assert [k for k, v in enumerate(v1) if v == m1] == [k for k, v in enumerate(v0) if v == m0]
            assert m1 == r * m0
    print("=" * 96)
    print("(4) Lemma 3.0 (duplication)")
    print(f"    {n_sets} point sets, r in 2..9: the exact lambda-interval of each of {n} points is multiplied by r;")
    print("    least offsets (tau, g) -> (r tau, r g), right secants, left steepness and MAP sets at random lambda")
    print("    scale as stated (reference (l0, F0) -> (l0, r F0)); all assertions passed")


def part5():
    # c <= tau: M = {(0, 0), (L, 0)}, reference (0, 0) attained, tau = 1, g = 0 is a right line; at c = tau = 1
    # every point is optimal at eps = 0 only if ... use M = {(0,1), (L, 1 - L)} with L large? keep fits >= 0:
    # reference (0, 10), M = {(0, 10), (10, 0)}: least g at tau = 1 is max(0, 10 - 0 - 10) = 0.
    l0, F0, tau = 0, Fr(10), Fr(1)
    M = [(0, Fr(10)), (10, Fr(0))]
    g = least_g(M, l0, F0, tau)
    assert g == 0
    c = tau                                    # c = tau: the far point ties with the reference
    near = [q for q in M if c * q[0] + q[1] <= c * l0 + F0]
    assert (10, Fr(0)) in near                 # length 10, but (g + eps)/(c - tau) is undefined
    # c slightly above tau: bound l0 + g/(c - tau) = 0 holds and excludes the far point
    c = tau + Fr(1, 100)
    near = [q for q in M if c * q[0] + q[1] <= c * l0 + F0]
    assert near == [(0, Fr(10))]
    # strict margin: N = {(0, 9)} with reference (5, 9) bounded by an M point? use reference (0, 10), c = 1/2:
    # N point (2, 9): J' = 1 + 9 = 10 = ref -> margin 0 is not > eps = 0; it is near-optimal but lies in N.
    N = [(2, Fr(9))]
    c = Fr(1, 2)
    assert c * 2 + 9 == c * l0 + F0
    print("=" * 96)
    print("(5) Necessity")
    print("    c = tau: reference (0,10), M = {(0,10),(10,0)}, tau = 1, g = 0: the point at length 10 ties, so no")
    print("    length bound holds at c = tau; at c = 1.01 the bound l <= 0 holds.")
    print("    margin: an N-point with J'_c equal to the reference value is near-optimal at eps = 0, so the margin")
    print("    must be strict, as stated.")


if __name__ == "__main__":
    part1()
    part2()
    part3()
    part4()
    part5()
