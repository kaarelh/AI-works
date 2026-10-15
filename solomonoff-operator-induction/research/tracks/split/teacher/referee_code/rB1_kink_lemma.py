"""rB1: referee B's independent brute-force test of the two-sided kink lemma (notes.md Lemma 1.1),
Remark 1.2 (wedge -> margin) and its converse, Remark 1.3 (window variant), and counterexamples
showing which hypotheses are needed.

Exact rational arithmetic throughout. Point sets are drawn with many ties (small integer ranges),
and in half of the trials the M-points are pushed onto the (R) line and the N-points onto the
margin, so that the boundary cases of every inequality are exercised.

(A) Lemma 1.1 (i), in its general form inf J' >= c l0 + F0 + min{m_N(c), -Delta(c)} for every c > tau
    (also when m_N(c) < 0), the sandwich when m_N(c) >= 0, and (ii) for eps in [0, m_N(c)),
    including the inclusion {J_c <= Phi + eps} subset {J'_c <= c l0 + F0 + eps}; (iii) concavity.
    g is the least admissible offset, and is NOT clipped at 0: the run records whether g < 0 ever
    co-occurs with m_N(c) > 0 (it cannot, if the reference is bounded; see the report).
(B) Remark 1.2 and the stated converse.
(C) Remark 1.3's window variant.
(D) Necessity: counterexamples to (ii) when c <= tau, when eps >= m_N(c), and to the length bound
    when (R) is dropped.
Seeded: random.seed(20261013).
"""
import random
from fractions import Fraction as Fr

random.seed(20261013)


def rnd_points(k):
    pts = []
    for _ in range(k):
        l = random.randint(0, 12)
        F = Fr(random.randint(0, 60), random.choice([1, 2, 3]))
        Fp = max(Fr(0), F - Fr(random.randint(0, 6), random.choice([1, 2])))
        pts.append([l, F, Fp, random.choice("MN")])
    return pts


def part_A(trials=40000):
    st = dict(sets=0, cvals=0, cvals_mneg=0, near=0, gneg_sets=0, gneg_with_positive_margin=0)
    for _ in range(trials):
        pts = rnd_points(random.randint(2, 10))
        if not any(q[3] == "M" for q in pts):
            continue
        # reference point bounded by a random program
        b = random.choice(pts)
        l0 = b[0] + random.randint(0, 2)
        F0 = b[1] + Fr(random.randint(0, 4), 2)
        tau = Fr(random.randint(0, 12), random.choice([1, 2, 4]))
        M = [q for q in pts if q[3] == "M"]
        lM = min(q[0] for q in M)
        if lM > l0:
            lM = l0  # l_M <= l0 is part of the hypothesis; any smaller l_M is also admissible
        if random.random() < 0.5:
            # push M points down onto the line through (l0, F0 - g0) of slope -tau (boundary cases)
            g0 = Fr(random.randint(0, 6), 2)
            for q in M:
                line = F0 - g0 - tau * (q[0] - l0)
                if line >= 0 and random.random() < 0.7:
                    q[2] = line
                    q[1] = max(q[1], q[2])
        g = max(F0 - q[2] - tau * (q[0] - l0) for q in M)  # least g with (R); may be negative
        N = [q for q in pts if q[3] == "N"]
        st["sets"] += 1
        if g < 0:
            st["gneg_sets"] += 1

        def mN(c):
            return None if not N else min(c * q[0] + q[2] for q in N) - (c * l0 + F0)

        # (iii) concavity on a grid
        if N:
            grid = [Fr(i, 4) for i in range(0, 60)]
            v = [mN(c) for c in grid]
            assert all(2 * v[i] >= v[i - 1] + v[i + 1] for i in range(1, len(v) - 1))
        for _ in range(8):
            c = tau + Fr(random.randint(1, 80), random.choice([4, 8, 16]))
            m = mN(c)
            Delta = g + (c - tau) * (l0 - lM)
            infJp = min(c * q[0] + q[2] for q in pts)
            Phi = min(c * q[0] + q[1] for q in pts)
            # (i), general form
            lower = c * l0 + F0 + (-Delta if m is None else min(m, -Delta))
            assert infJp >= lower, ("(i) general", pts, l0, F0, tau, g, c)
            assert Phi <= c * l0 + F0
            st["cvals"] += 1
            if m is not None and m < 0:
                st["cvals_mneg"] += 1
                continue
            if g >= 0:
                assert c * l0 + F0 - Delta <= Phi
            else:
                # g < 0 with m_N(c) >= 0: the bounding program must be in N, so m_N(c) = 0 exactly,
                # (ii) is vacuous, and the sandwich's lower end can fail (it needs Delta >= 0)
                assert m is not None and m == 0
                st["gneg_mN_zero"] = st.get("gneg_mN_zero", 0) + 1
                if not (c * l0 + F0 - Delta <= Phi):
                    st["gneg_sandwich_fails"] = st.get("gneg_sandwich_fails", 0) + 1
            if g < 0 and (m is None or m > 0):
                st["gneg_with_positive_margin"] += 1
            # (ii)
            epsmax = m if m is not None else Fr(30)
            for eps in [Fr(0), epsmax / 2, epsmax * Fr(999, 1000)]:
                if m is not None and not (0 <= eps < m):
                    continue
                Sprime = [q for q in pts if c * q[0] + q[2] <= c * l0 + F0 + eps]
                Sphi = [q for q in pts if c * q[0] + q[1] <= Phi + eps]
                assert all(q in Sprime for q in Sphi)
                for q in Sprime:
                    st["near"] += 1
                    assert q[3] == "M"
                    assert q[0] <= l0 + (g + eps) / (c - tau)
                    assert q[2] >= F0 - (c * g + tau * eps) / (c - tau)
                    assert q[2] <= F0 + eps + c * (l0 - q[0]) <= F0 + eps + c * (l0 - lM)
    return st


def part_B(trials=20000):
    st = dict(wedge_sets=0, wedge_c=0, converse_sets=0)
    for _ in range(trials):
        l0 = random.randint(0, 15)
        F0 = Fr(random.randint(0, 20))
        sigma = Fr(random.randint(1, 30), random.choice([1, 2, 4]))
        mu = Fr(random.randint(0, 20), random.choice([1, 2]))
        N = []
        for _ in range(random.randint(1, 8)):
            l = random.randint(0, 25)
            floor = F0 + max(sigma * (l0 - l), mu)
            N.append((l, floor + (0 if random.random() < 0.6 else Fr(random.randint(0, 10), 3))))
        st["wedge_sets"] += 1
        for k in range(0, 41):
            c = sigma * Fr(k, 40)
            m = min(c * l + F for (l, F) in N) - (c * l0 + F0)
            assert m >= mu * (1 - c / sigma), (N, l0, F0, sigma, mu, c)
            st["wedge_c"] += 1
    # converse: m_N >= 0 on [0, sigma] forces F >= F0 and F >= F0 + sigma (l0 - l)
    for _ in range(trials):
        l0 = random.randint(0, 15)
        F0 = Fr(random.randint(0, 20))
        sigma = Fr(random.randint(1, 30), random.choice([1, 2, 4]))
        N = [(random.randint(0, 25), Fr(random.randint(0, 120), 2)) for _ in range(random.randint(1, 6))]
        ok = all(c * l + F >= c * l0 + F0 for (l, F) in N for c in (Fr(0), sigma))  # affine: endpoints suffice
        if ok:
            st["converse_sets"] += 1
            for (l, F) in N:
                assert F >= F0 and F >= F0 + sigma * (l0 - l)
    return st


def part_C(trials=20000):
    st = dict(sets=0, near=0)
    for _ in range(trials):
        pts = [(random.randint(0, 20), Fr(random.randint(0, 80), 2)) for _ in range(random.randint(2, 9))]
        b = random.choice(pts)
        l0, F0 = b[0], b[1]
        tau = Fr(random.randint(0, 8), 2)
        wplus = random.randint(0, 6)
        far = [q for q in pts if q[0] > l0 + wplus]
        g = max([F0 - F - tau * (l - l0) for (l, F) in far] + [Fr(0)])
        st["sets"] += 1
        for _ in range(5):
            c = tau + Fr(random.randint(1, 40), 4)
            for eps in [Fr(0), Fr(random.randint(0, 10), 3)]:
                for (l, F) in pts:
                    if c * l + F <= c * l0 + F0 + eps:
                        st["near"] += 1
                        assert l <= l0 + max(wplus, (g + eps) / (c - tau))
    return st


def part_D():
    out = []
    # (1) c <= tau: M = {(0, 10), (10, 0)}, reference (0, 10), tau = 1, g = 0. At c = 1/2 the far point is
    #     optimal and violates any length bound of the form l0 + (g + eps)/(c - tau) (negative denominator).
    pts = [(0, Fr(10), "M"), (10, Fr(0), "M")]
    l0, F0, tau, g, c = 0, Fr(10), Fr(1), Fr(0), Fr(1, 2)
    assert all(F >= F0 - g - tau * (l - l0) for (l, F, _) in pts)
    Phi = min(c * l + F for (l, F, _) in pts)
    best = [(l, F) for (l, F, _) in pts if c * l + F == Phi]
    out.append(f"  (1) c <= tau: c = {c}, tau = {tau}; the MAP is {best} although (R) holds with g = 0: "
               f"the hypothesis c > tau is needed")
    # (2) eps >= m_N: an N point enters the near-optimal set
    pts = [(5, Fr(3), "M"), (2, Fr(10), "N")]
    l0, F0, c = 5, Fr(3), Fr(2)
    mN = 2 * 2 + 10 - (c * l0 + F0)
    eps = mN
    near = [(l, F, lab) for (l, F, lab) in pts if c * l + F <= c * l0 + F0 + eps]
    out.append(f"  (2) eps = m_N(c) = {mN}: the near-optimal set {near} contains an N point: eps < m_N is needed")
    # (3) tightness of the length bound: a point on the (R) line at l0 + g/(c - tau) ties with the reference
    l0, F0, tau, g, c = 0, Fr(10), Fr(1), Fr(2), Fr(2)
    x = g / (c - tau)
    pts = [(0, F0, "M"), (int(x), F0 - g - tau * x, "M")]
    gmin = max(F0 - F - tau * (l - l0) for (l, F, _) in pts)
    Phi = min(c * l + F for (l, F, _) in pts)
    best = [(l, F) for (l, F, _) in pts if c * l + F == Phi]
    out.append(f"  (3) tightness: (R) holds with tau = {tau}, least g = {gmin}; at c = {c} the MAPs are {best}; "
               f"the longer one has l = {max(l for l, _ in best)} = l0 + g/(c - tau) = {l0 + gmin / (c - tau)}")
    # (4) dropping (R) altogether: no length bound
    pts = [(0, Fr(10), "M"), (40, Fr(0), "M")]
    c = Fr(1, 5)
    Phi = min(c * l + F for (l, F, _) in pts)
    best = [(l, F) for (l, F, _) in pts if c * l + F == Phi]
    out.append(f"  (4) without a right line (or with tau >= c) the MAP can be arbitrarily long: at c = {c} the MAP is "
               f"{best}")
    return out


if __name__ == "__main__":
    print("=" * 100)
    print("(A) Lemma 1.1 (i)-(iii), exact arithmetic, g unclipped")
    stA = part_A()
    for k, v in stA.items():
        print(f"    {k:28s} {v}")
    print("    all assertions passed")
    print("=" * 100)
    print("(B) Remark 1.2 (wedge gives m_N(c) >= mu (1 - c/sigma) on [0, sigma]) and its converse")
    for k, v in part_B().items():
        print(f"    {k:28s} {v}")
    print("    all assertions passed")
    print("=" * 100)
    print("(C) Remark 1.3, window variant: l <= l0 + max{w+, (g + eps)/(c - tau)}")
    for k, v in part_C().items():
        print(f"    {k:28s} {v}")
    print("    all assertions passed")
    print("=" * 100)
    print("(D) necessity and tightness")
    for line in part_D():
        print(line)
