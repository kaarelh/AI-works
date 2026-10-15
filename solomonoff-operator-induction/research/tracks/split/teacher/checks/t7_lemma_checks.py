"""t7: exact-arithmetic checks of the revised statements of notes-final.md, Section 1 and Lemma 3.0.

(A) Lemma 1.1 as revised: real offset g (the least admissible one, possibly negative), a POINTWISE margin
    in (ii) (every N-point has J'_c > c l0 + F0 + eps; no use of the infimum m_N), and item (iv), which
    needs no right line. Also: if a program of M bounds the reference, the least admissible g is >= 0.
(B) Lemma 1.5: (a) secants <= tau + g/x for every valid right line; (b) offsets >= (s1 - tau) x1;
    (c) the right secant decides the comparison with an attained reference.
(C) Lemma 3.0 (duplication): on random point sets, the lambda-MAP set of the r-fold duplicated fits equals
    the (lambda/r)-MAP set of the original fits, at random lambda and at every breakpoint.
Random point sets: integer lengths, rational fits (some infinite fits for N in (A)); random.seed(77).
Deterministic.
"""
import random
from fractions import Fraction as Fr

random.seed(77)
INF = None


def rnd_points(k, lmax=30, fmax=60, den=8):
    return [(random.randint(0, lmax), Fr(random.randint(0, fmax * den), den)) for _ in range(k)]


def part_A(sets=3000):
    checks = dict(sets=0, cvals=0, near=0, gneg=0, gneg_boundedM=0, iv=0)
    for _ in range(sets):
        M = rnd_points(random.randint(1, 8))
        N = rnd_points(random.randint(0, 6))
        l0 = random.randint(0, 30)
        F0 = Fr(random.randint(0, 60 * 8), 8)
        # make the reference bounded: by an M-point or by an N-point
        if random.random() < 0.5:
            M.append((random.randint(0, l0), F0 - Fr(random.randint(0, 16), 8)))
            bounded_by_M = True
        else:
            N.append((random.randint(0, l0), F0 - Fr(random.randint(0, 16), 8)))
            bounded_by_M = any(l <= l0 and F <= F0 for (l, F) in M)
        M = [(l, F) for (l, F) in M if F >= 0]
        N = [(l, F) for (l, F) in N if F >= 0]
        if not M:
            continue
        # recompute after dropping negative fits (an appended bounding point may have been dropped)
        bounded_by_M = any(l <= l0 and F <= F0 for (l, F) in M)
        tau = Fr(random.randint(0, 24), 8)
        lM = min(l for l, _ in M)
        # least admissible g for (R) on M
        g = max(F0 - F - tau * (l - l0) for (l, F) in M)
        if g < 0:
            checks["gneg"] += 1
            if bounded_by_M:
                checks["gneg_boundedM"] += 1
        checks["sets"] += 1
        for _c in range(8):
            c = tau + Fr(random.randint(1, 40), 8)
            ref = c * l0 + F0
            margins = [c * l + F - ref for (l, F) in N]
            if margins and min(margins) <= 0:
                eps_max = None
            else:
                eps_max = min(margins) if margins else Fr(10 ** 6)
            checks["cvals"] += 1
            # (iv): no right line needed
            for eps in (Fr(0), Fr(random.randint(0, 40), 8)):
                for (l, F) in M:
                    if c * l + F <= ref + eps:
                        assert F <= F0 + eps + c * (l0 - l)
                        assert F <= F0 + eps + c * (l0 - lM)
                        checks["iv"] += 1
            if eps_max is None:
                continue
            eps = eps_max * Fr(random.randint(0, 99), 100)   # pointwise margin: every N-point has J' > ref + eps
            assert all(c * l + F > ref + eps for (l, F) in N)
            pts = [(l, F, "M") for (l, F) in M] + [(l, F, "N") for (l, F) in N]
            for (l, F, lab) in pts:
                if c * l + F <= ref + eps:
                    checks["near"] += 1
                    assert lab == "M"
                    assert (c - tau) * (l - l0) <= g + eps
                    assert F >= F0 - (c * g + tau * eps) / (c - tau)
    print("=" * 100)
    print("(A) Lemma 1.1 revised: real g, pointwise margin, item (iv)")
    for k, v in checks.items():
        print(f"    {k:16s} {v}")
    assert checks["gneg_boundedM"] == 0
    print("    all assertions passed; no set with least admissible g < 0 has a bounding program in M")


def part_B(sets=3000):
    n_a = n_b = n_c = 0
    for _ in range(sets):
        M = rnd_points(random.randint(2, 10))
        l0 = random.randint(0, 30)
        F0 = Fr(random.randint(0, 60 * 8), 8)
        longer = [(l, F) for (l, F) in M if l > l0]
        if not longer:
            continue
        tau = Fr(random.randint(0, 40), 8)
        g = max(F0 - F - tau * (l - l0) for (l, F) in M)          # least admissible offset
        for (l, F) in longer:
            x = l - l0
            s = (F0 - F) / x
            assert s <= tau + g / x                                # (a)
            if s > tau:
                assert g >= (s - tau) * x                          # (b)
            n_a += 1
            n_b += 1
        # (c) with the reference attained by pi_0 = (l0, F0)
        splus = max([Fr(0)] + [(F0 - F) / (l - l0) for (l, F) in longer])
        for lam in (splus * Fr(random.randint(1, 99), 100), splus + Fr(random.randint(1, 40), 8)):
            better = [(l, F) for (l, F) in longer if lam * l + F < lam * l0 + F0]
            tie_or_better = [(l, F) for (l, F) in longer if lam * l + F <= lam * l0 + F0]
            if lam < splus:
                assert better
            if lam > splus:
                assert not tie_or_better
            n_c += 1
    print("=" * 100)
    print("(B) Lemma 1.5")
    print(f"    (a) secant <= tau + g/x: {n_a} points; (b) g >= (s1 - tau) x1: {n_b} points; (c) secant decides: {n_c} values of lambda")
    print("    all assertions passed")


def mapset(pts, lam):
    vals = [lam * l + F for (l, F) in pts]
    best = min(vals)
    return sorted(i for i, v in enumerate(vals) if v == best)


def part_C(sets=2000):
    n = 0
    for _ in range(sets):
        pts = rnd_points(random.randint(2, 12))
        r = random.randint(2, 9)
        dup = [(l, r * F) for (l, F) in pts]
        lams = [Fr(random.randint(1, 400), 16) for _ in range(5)]
        # breakpoints of the duplicated set
        for i in range(len(dup)):
            for j in range(len(dup)):
                if dup[i][0] < dup[j][0]:
                    s = (dup[i][1] - dup[j][1]) / (dup[j][0] - dup[i][0])
                    if s > 0:
                        lams.append(s)
        for lam in lams:
            assert mapset(dup, lam) == mapset(pts, lam / r)
            n += 1
    print("=" * 100)
    print("(C) Lemma 3.0 (duplication): lambda-MAPs of r-fold fits = (lambda/r)-MAPs of the original fits")
    print(f"    {sets} point sets, r in 2..9, {n} values of lambda (random and every positive breakpoint); all equal")


if __name__ == "__main__":
    part_A()
    part_B()
    part_C()
