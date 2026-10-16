"""c3_threshold.py -- independent finite checks of the dyadic arithmetic behind notes.md section 3
(Theorem 3.1 threshold theories, Theorem 3.2 threshold machine G*, Remark 3.4 coin-free sum) and
behind the unsound companion G** of Theorem 4.4.

Written from the statements in notes.md, not from scout N1's c3_threshold.py.
Seed 20261016.  Output: c3_threshold.out (stdout).

Finite stand-in.  A tape space of finitely many tapes with dyadic weights (total 1).  A tape is
inconsistent (proves everything) or consistent; a consistent tape proves a set of "Pi_1 atoms".
Only true atoms are provable by consistent tapes (this is (Pi_1 T)); false atoms are proved only by
inconsistent tapes.  A data set D is a set of atoms, proved iff every atom is proved (its
conjunction is a Pi_1* sentence whose O-set is the intersection of the atoms' O-sets).
  U(O_D) = mass of tapes proving D (inconsistent ones included), Inc = mass of inconsistent tapes,
  M(D) = U(O_D) - Inc  (the proof-requiring weight).
Checks:
  T1  T_k := {atoms pi : U(O_pi) > I'_k + 2^-(k+2)}, I'_k the (k+2)-bit truncation of Inc, contains
      every atom of belief >= 2^-k and only atoms of positive belief (hence true), k = 0..14.
  T2  the threshold machine: for r uniform in [0,1], A_r := {Pi_1* sentences S : U(O_S) > r}
      (S ranging over conjunctions of atoms).  A_r is true for r > Inc, and
      nu_{G*}(D) := Leb{ r > Inc : A_r proves D } = min_{pi in D} U(O_pi) - Inc >= M(D).
  T3  the companion's dyadic facts: for random r in (Inc, 1) (truncated to 40 bits), the prefixes w
      of r with U_w := {S : U(O_S) > 0.w} consistent are exactly those with 0.w >= Inc (0.w > Inc
      when Inc is irrational, as Inc_0 is); they form a
      final segment of the prefixes; and A_r is contained in U_w for every prefix w.
  T4  coin-free sum (Remark 3.4): an interval of length l >= 2^-k contains at least
      2^(L-k-1) dyadic rationals of level L, for every L >= k+1 (random intervals, k <= 12).
"""
import random
from fractions import Fraction
from math import floor

SEED = 20261016
rng = random.Random(SEED)


def dyadic_weights(m, bits=16):
    cuts = sorted(rng.sample(range(1, 2 ** bits), m - 1))
    pts = [0] + cuts + [2 ** bits]
    return [Fraction(pts[i + 1] - pts[i], 2 ** bits) for i in range(m)]


def instance():
    n_true, n_false = rng.randint(4, 10), rng.randint(1, 5)
    atoms = [("t", i) for i in range(n_true)] + [("f", i) for i in range(n_false)]
    m = rng.randint(6, 40)
    ws = dyadic_weights(m)
    p_inc = rng.choice([0.05, 0.2, 0.4])
    tapes = []
    for _ in range(m):
        if rng.random() < p_inc:
            tapes.append(None)
        else:
            q = rng.random()
            tapes.append(frozenset(a for a in atoms if a[0] == "t" and rng.random() < q))
    return atoms, ws, tapes


def U(ws, tapes, S):
    return sum(w for w, th in zip(ws, tapes) if th is None or S <= th)


def run(trials=400):
    t1 = t2 = t3 = t4 = 0
    eq3 = 0
    n1 = n2 = n3 = n4 = 0
    for _ in range(trials):
        atoms, ws, tapes = instance()
        inc = sum(w for w, th in zip(ws, tapes) if th is None)
        Uat = {a: U(ws, tapes, frozenset([a])) for a in atoms}
        bel = {a: Uat[a] - inc for a in atoms}
        # T1
        for k in range(15):
            sc = 2 ** (k + 2)
            Ip = Fraction(floor(inc * sc), sc)
            Tk = {a for a in atoms if Uat[a] > Ip + Fraction(1, sc)}
            for a in atoms:
                n1 += 1
                if bel[a] >= Fraction(1, 2 ** k) and a not in Tk:
                    t1 += 1
                if a in Tk and not (bel[a] > 0 and a[0] == "t"):
                    t1 += 1
        # T2: data sets D (random subsets of atoms)
        for _ in range(10):
            D = frozenset(rng.sample(atoms, rng.randint(1, min(4, len(atoms)))))
            M = U(ws, tapes, D) - inc
            # A_r proves D iff some conjunction S with U(O_S) > r implies D: the conjunction D itself
            # or atoms individually; since U(O_D) <= min_a U(O_a), this is r < min_a U(O_a).
            nu = max(Fraction(0), min(Uat[a] for a in D) - inc) if inc < 1 else Fraction(0)
            n2 += 1
            if nu < M:
                t2 += 1
            # truth of A_r for r > inc: every S with U(O_S) > r > inc has positive belief, hence
            # consists of true atoms; check on a grid of r
            for _ in range(5):
                r = inc + (1 - inc) * Fraction(rng.randint(1, 999), 1000)
                for a in atoms:
                    if Uat[a] > r and a[0] != "t":
                        t2 += 1
        # T3
        if inc < 1:
            for _ in range(5):
                r = inc + (1 - inc) * Fraction(rng.randint(1, 10 ** 6 - 1), 10 ** 6)
                bits = []
                x = r
                for _i in range(40):
                    x *= 2
                    b = int(x >= 1)
                    bits.append(b)
                    x -= b
                seen_consistent = False
                for L in range(41):
                    w_val = sum(Fraction(b, 2 ** (i + 1)) for i, b in enumerate(bits[:L]))
                    Uw = {a for a in atoms if Uat[a] > w_val}
                    cons = all(a[0] == "t" for a in Uw)
                    n3 += 1
                    # in the finite model Inc is dyadic, so 0.w = Inc can occur; then U_w is
                    # consistent (false atoms have U(O) = Inc exactly).  Inc_0 itself is irrational
                    # (`fundamentals` Thm 3.2), so this boundary case does not arise for SAI.
                    if w_val == inc:
                        eq3 += 1
                    if cons != (w_val >= inc):
                        t3 += 1
                    if seen_consistent and not cons:
                        t3 += 1                    # consistency must be upward closed
                    seen_consistent |= cons
                    Ar = {a for a in atoms if Uat[a] > r}
                    if not Ar <= Uw:
                        t3 += 1
    # T4
    for _ in range(2000):
        k = rng.randint(0, 12)
        length = Fraction(rng.randint(2 ** 20, 2 ** 21), 2 ** 21) * Fraction(1, 2 ** k)   # in [2^-k-1, 2^-k]
        length = max(length, Fraction(1, 2 ** k))
        a = Fraction(rng.randint(0, 2 ** 30), 2 ** 30) * (1 - length)
        for L in range(k + 1, k + 8):
            lo = floor(a * 2 ** L) + 1
            hi = -(-((a + length) * 2 ** L) // 1) - 1      # strictly inside (a, a+length)
            cnt = max(0, hi - lo + 1)
            n4 += 1
            if cnt < 2 ** (L - k - 1):
                t4 += 1
    print(f"seed {SEED}; {trials} random tape spaces")
    print(f"T1 threshold theories: {t1} violations in {n1} (atom, k) checks")
    print(f"T2 threshold machine: nu_G*(D) >= M(D) and A_r true for r > Inc: {t2} violations in {n2} data sets")
    print(f"T3 companion prefixes: {t3} violations in {n3} (tape, prefix) checks "
          f"({eq3} boundary cases 0.w = Inc, where U_w is consistent; impossible for irrational Inc_0)")
    print(f"T4 dyadics in intervals of length >= 2^-k: {t4} violations in {n4} (interval, level) checks")
    assert t1 == t2 == t3 == t4 == 0
    print("all assertions passed")


if __name__ == "__main__":
    run()
