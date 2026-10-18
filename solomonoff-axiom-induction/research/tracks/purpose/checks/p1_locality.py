"""p1_locality.py -- track `purpose`, target T1: locality of SAI's scores, the chain rule for questions about one
quantity, where it fails (normalised convention), and what random questions add.

Seed 20261017.  Writes p1_locality.out next to itself.  Exact rational arithmetic (fractions) where it matters.

Model.  A finite theory machine about one real quantity q is given by its outcomes: a list of (probability, set),
where the set is the set of values of q allowed by the random theory on that tape (a finite union of intervals;
here a closed interval [lo, hi] or a point), or None for an inconsistent theory.  By the decidability lemma of the
paper (lem:laws:decidable) the theory proves "q in I" iff its value set is contained in I, refutes it iff the set
misses I, and is consistent iff the set is non-empty.  So nu_G(D) is the probability that the set is non-empty and
contained in every positively answered I and disjoint from every negatively answered I.

Parts
  A. Semimeasure convention: for random machines and random interval data, the cumulative loss in every reveal order
     equals -log nu_G(D) + log nu_G(empty) and equals -log of the probability of proving the joint cell.
  B. Normalised convention: two machines with the same nu(D) and nu(empty) but different normalised losses; and one
     machine whose normalised loss depends on the order (exact rationals).
  C. Three-valued convention: telescoping with nu^3 (random instances).
  D. Random questions: the separation pseudometric of a dithered grid is min(d/Delta, 1); the expected log loss of
     near-point forecasts divided by log(1/s) tends to it; squared distance violates the triangle inequality.
  E. The author's example under random cells: uniform on 5 nearby values vs 5 scattered values, truth among them;
     expected SAI loss per datum under a dithered grid of width Delta (exact, by integrating over the dither).
"""
import itertools
import math
import os
import random
from fractions import Fraction as Fr

SEED = 20261017
OUT = []
HERE = os.path.dirname(os.path.abspath(__file__))


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def log2(x):
    return math.log2(float(x))


# ---------------- machines: outcomes (prob, (lo, hi)) or (prob, None) ----------------
def proves(S, I):          # S, I closed intervals (lo, hi); I may be a list of intervals (union)
    lo, hi = S
    return any(a <= lo and hi <= b for (a, b) in I)


def refutes(S, I):
    lo, hi = S
    return all(hi < a or lo > b for (a, b) in I)


def nu(G, D):
    """D: list of (I, label) with label in {1, 0, 'i'}; two-valued if no 'i'."""
    tot = Fr(0)
    for p, S in G:
        if S is None:
            continue
        ok = True
        for I, y in D:
            if y == 1 and not proves(S, I):
                ok = False
            elif y == 0 and not refutes(S, I):
                ok = False
            elif y == "i" and (proves(S, I) or refutes(S, I)):
                ok = False
            if not ok:
                break
        if ok:
            tot += p
    return tot


def rand_machine(rng, k=6, grid=12):
    ps = [Fr(rng.randint(1, 9)) for _ in range(k)]
    s = sum(ps)
    G = []
    for p in ps:
        if rng.random() < 0.15:
            G.append((p / s, None))
        else:
            a = rng.randint(0, grid - 1)
            b = min(grid, a + rng.choice([0, 0, 1, 2, 3]))
            G.append((p / s, (Fr(a), Fr(b))))
    return G


def rand_interval(rng, grid=12):
    a = rng.randint(-1, grid)
    b = rng.randint(a, grid + 1)
    return [(Fr(a) - Fr(1, 2), Fr(b) + Fr(1, 2))]


def main():
    rng = random.Random(SEED)

    # ------------------------------------------------------------------ A
    out("# p1_locality.py seed=%d" % SEED)
    out("\n== A. semimeasure convention: cumulative loss in every order = -log nu(D) + log nu(empty) = -log nu(prove joint cell) + log nu(empty)")
    n_inst, n_orders, worst = 0, 0, 0.0
    for _ in range(300):
        G = rand_machine(rng)
        q = Fr(rng.randint(0, 11)) + Fr(1, 3)        # the true value
        D = []
        for _ in range(rng.randint(1, 4)):
            I = rand_interval(rng)
            y = 1 if any(a <= q <= b for (a, b) in I) else 0
            D.append((I, y))
        if nu(G, D) == 0:
            continue
        n_inst += 1
        target = -log2(nu(G, D)) + log2(nu(G, []))
        # joint cell as a set of points on a fine grid: proving the joint cell <=> proving every datum
        for perm in itertools.permutations(range(len(D))):
            L, prev = 0.0, []
            for j in perm:
                cur = prev + [D[j]]
                L += -log2(nu(G, cur) / nu(G, prev))
                prev = cur
            n_orders += 1
            worst = max(worst, abs(L - target))
    out("   %d instances, %d reveal orders; max |cumulative loss - (-log nu(D) + log nu(empty))| = %.2e bits" % (
        n_inst, n_orders, worst))

    # ------------------------------------------------------------------ B
    out("\n== B. normalised convention is not local and depends on the order")
    I = [(Fr(0), Fr(1))]
    G1 = [(Fr(1, 2), (Fr(0), Fr(1))), (Fr(1, 2), (Fr(-5), Fr(5)))]      # proves 'q in [0,1]' w.p. 1/2, else silent
    G2 = [(Fr(1, 2), (Fr(0), Fr(1))), (Fr(1, 2), (Fr(3), Fr(4)))]       # proves it w.p. 1/2, else refutes it
    for name, G in (("G1 (else silent)", G1), ("G2 (else refutes)", G2)):
        D = [(I, 1)]
        semi = -log2(nu(G, D)) + log2(nu(G, []))
        norm = -log2(nu(G, D) / (nu(G, [(I, 1)]) + nu(G, [(I, 0)])))
        out("   %-18s nu(empty)=%s nu(D)=%s | semimeasure loss %.4f bits | normalised loss %.4f bits" % (
            name, nu(G, []), nu(G, D), semi, norm))
    # order dependence of the normalised loss for one machine (the shape of thm:basic:order (a)):
    # a = 'q in [0,1]', chi-like weaker datum 'q in [0,3]'.
    A = [(Fr(0), Fr(1))]
    AV = [(Fr(0), Fr(3))]
    G3 = [(Fr(1, 4), (Fr(0), Fr(1))),       # proves a (hence a-or-chi)
          (Fr(1, 4), (Fr(2), Fr(3))),       # refutes a, proves a-or-chi
          (Fr(1, 4), (Fr(5), Fr(6))),       # refutes both
          (Fr(1, 4), (Fr(2), Fr(9)))]       # refutes a, leaves a-or-chi open
    D = [(A, 1), (AV, 1)]

    def norm_loss(G, order):
        L, prev = 0.0, []
        for (Ii, y) in order:
            num = nu(G, prev + [(Ii, y)])
            den = nu(G, prev + [(Ii, 1)]) + nu(G, prev + [(Ii, 0)])
            L += -log2(num / den)
            prev = prev + [(Ii, y)]
        return L
    out("   G3: semimeasure loss %.4f bits in both orders; normalised loss %.4f (a first) vs %.4f (weaker datum first)" % (
        -log2(nu(G3, D)) + log2(nu(G3, [])), norm_loss(G3, D), norm_loss(G3, D[::-1])))

    # ------------------------------------------------------------------ C
    out("\n== C. three-valued convention: cumulative loss = -log nu3(D) + log nu3(empty), every order")
    worst, cnt = 0.0, 0
    for _ in range(300):
        G = rand_machine(rng)
        D = []
        for _ in range(rng.randint(1, 4)):
            Ii = rand_interval(rng)
            D.append((Ii, rng.choice([1, 0, "i"])))
        if nu(G, D) == 0:
            continue
        target = -log2(nu(G, D)) + log2(nu(G, []))
        for perm in itertools.permutations(range(len(D))):
            L, prev = 0.0, []
            for j in perm:
                cur = prev + [D[j]]
                # conditionals of nu3 over Y3 sum to one at each step (check)
                tot = sum(nu(G, prev + [(D[j][0], y)]) for y in (1, 0, "i"))
                assert tot == nu(G, prev), "nu3 conditionals do not sum to nu(prev)"
                L += -log2(nu(G, cur) / nu(G, prev))
                prev = cur
            worst = max(worst, abs(L - target))
            cnt += 1
    out("   %d (instance, order) pairs; three-valued conditionals sum to 1 at every step (asserted, exact); "
        "max deviation from telescoping %.2e bits" % (cnt, worst))

    # ------------------------------------------------------------------ D
    out("\n== D. random questions: separation probability of a dithered grid of width Delta, and near-point forecasts")
    Delta = 1.0
    for d in (0.1, 0.5, 0.9, 1.0, 2.5, 10.0):
        M = 200000
        u = (rng.random() for _ in range(M))
        # cells [k Delta - u, (k+1) Delta - u): x = 0 and y = d separated iff floor((0+u)/Delta) != floor((d+u)/Delta)
        sep = sum(1 for uu in u if math.floor(uu / Delta) != math.floor((d + uu * Delta) / Delta)) / M
        out("   d = %5.2f: separation probability (MC, %d dithers) %.4f, min(d/Delta, 1) = %.4f" % (d, M, sep, min(d / Delta, 1)))
    out("   near-point forecast P = (1-s) delta_y + s Unif[-R/2, R/2), truth x = 0, R = 64, Delta = 1 (exact over the dither):")
    R = 64.0
    for d in (0.25, 0.5, 1.0, 4.0):
        for s in (1e-2, 1e-4, 1e-8):
            # separated (prob min(d,1)): cell mass s*Delta/R ; not separated: 1 - s + s Delta/R
            ps = min(d / Delta, 1.0)
            L = ps * -math.log2(s * Delta / R) + (1 - ps) * -math.log2(1 - s + s * Delta / R)
            out("      d=%4.2f s=%.0e: E loss = %8.4f bits; E loss - sep*log2(1/s) = %.4f (sep*log2(R/Delta) = %.4f);"
                " ratio to log2(1/s) %.4f -> sep %.4f" % (d, s, L, L - ps * math.log2(1 / s), ps * math.log2(R / Delta),
                                                          L / math.log2(1 / s), ps))
    out("   squared distance on 0, 1, 2: d(0,2) = 4 > d(0,1) + d(1,2) = 2, so it is not a pseudometric and is no separation"
        " probability; |x-y| ^ Delta / Delta is (the dithered grid).")

    # ------------------------------------------------------------------ E
    out("\n== E. uniform on 5 nearby values {-2..2} vs 5 scattered values {-20,-10,0,10,20}, truth 0; expected loss per")
    out("   datum (bits) when the datum is the cell of a dithered grid of width Delta (exact: piecewise constant in u)")
    near = [-2, -1, 0, 1, 2]
    far = [-20, -10, 0, 10, 20]

    def exp_loss(pts, Delta, x=0.0):
        # dither u in [0, Delta): cell of x is [x - v, x - v + Delta) with v = (x + u) mod Delta; integrate over v exactly
        brk = sorted({0.0, Delta} | {((x - p) % Delta) for p in pts} | {((x - p + Delta) % Delta) for p in pts})
        brk = [b for b in brk if 0.0 <= b <= Delta]
        tot = 0.0
        for a, b in zip(brk[:-1], brk[1:]):
            if b - a < 1e-15:
                continue
            v = (a + b) / 2
            lo, hi = x - v, x - v + Delta
            m = sum(1 for p in pts if lo <= p < hi) / len(pts)
            tot += (b - a) * -math.log2(m)
        return tot / Delta
    for D_ in (0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0):
        out("   Delta = %6.1f: near %.4f, far %.4f bits" % (D_, exp_loss(near, D_), exp_loss(far, D_)))
    out("   (fixed cells of width Delta < 1 around the truth: both log2 5 = %.4f)" % math.log2(5))

    out("\n# done")
    with open(os.path.join(HERE, "p1_locality.out"), "w") as f:
        f.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
