"""c1: weak function semimeasures versus random partial functions (notes.md Example 2.4, Thm 3.5(iii)).

Checks, for the 3-input weak semimeasure tau of notes.md Example 2.4:
  (a) tau satisfies every weak (one-point) inequality, and so does tau^{(x)k} for k = 1, 2;
  (b) tau violates a Moebius inequality (so tau is not the containment functional of any
      random partial function);
  (c) the three events E1, E2, E3 are pairwise inconsistent;
  (d) by linear programming: the largest c such that some random partial function law rho
      (a sub-probability on (Y + {bot})^S) satisfies rho(F contains D) >= c * tau^{(x)k}(D)
      for every D with tau^{(x)k}(D) > 0 equals (2/3)^k, for k = 1, 2, 3.
The proof in notes.md gives the upper bound (2/3)^k; the LP shows it is attained for k <= 3.

Deterministic (no randomness).  Output: c1_weak_vs_random_function.out.txt
"""
import itertools
from fractions import Fraction as Fr

import numpy as np
from scipy.optimize import linprog
from scipy.sparse import lil_matrix

BOT = None
Y = (0, 1)


def block_tau():
    """tau on partial functions over inputs {0,1,2} = {a,b,c}; D is a frozenset of (x,y)."""
    a, b, c = 0, 1, 2
    t = {}
    t[frozenset()] = Fr(1)
    for x in (a, b, c):
        for y in Y:
            t[frozenset({(x, y)})] = Fr(1, 2)
    E1 = frozenset({(a, 0), (b, 1)})
    E2 = frozenset({(b, 0), (c, 1)})
    E3 = frozenset({(c, 0), (a, 1)})
    for E in (E1, E2, E3):
        t[E] = Fr(1, 2)
    return t, (E1, E2, E3)


def partial_functions(inputs):
    """All partial functions with domain a subset of `inputs`, as frozensets."""
    out = []
    for vals in itertools.product((BOT,) + Y, repeat=len(inputs)):
        out.append(frozenset((x, v) for x, v in zip(inputs, vals) if v is not BOT))
    return out


def product_tau(k, t1):
    """tau^{(x)k} on inputs {0..3k-1}; block j uses inputs 3j,3j+1,3j+2."""
    def val(D):
        r = Fr(1)
        for j in range(k):
            Dj = frozenset((x - 3 * j, y) for (x, y) in D if 3 * j <= x < 3 * j + 3)
            r *= t1.get(Dj, Fr(0))
            if r == 0:
                return r
        return r
    return val


def check_weak(val, inputs):
    bad = 0
    n = 0
    for D in partial_functions(inputs):
        dom = {x for x, _ in D}
        for x in inputs:
            if x in dom:
                continue
            n += 1
            if sum(val(D | {(x, y)}) for y in Y) > val(D):
                bad += 1
    return n, bad


def moebius(val, D, S):
    """sum over E with dom E subset of S of (-1)^{|E|} val(D u E)."""
    total = Fr(0)
    for E in partial_functions(S):
        total += (-1) ** len(E) * val(D | E)
    return total


def lp_best_c(k, t1):
    inputs = list(range(3 * k))
    val = product_tau(k, t1)
    # support constraints: D with tau > 0 are products of per-block positive D's
    pos_block = [D for D in t1 if t1[D] > 0]
    Ds = []
    for combo in itertools.product(pos_block, repeat=k):
        D = frozenset((x + 3 * j, y) for j, Dj in enumerate(combo) for (x, y) in Dj)
        Ds.append(D)
    points = list(itertools.product((BOT,) + Y, repeat=3 * k))
    npts = len(points)
    # variables: rho(point) for each point, then c.  maximise c.
    A = lil_matrix((len(Ds) + 1, npts + 1))
    bvec = np.zeros(len(Ds) + 1)
    for i, D in enumerate(Ds):
        tv = float(val(D))
        # c*tv - sum_{points extending D} rho <= 0
        for pi, pt in enumerate(points):
            if all(pt[x] == y for (x, y) in D):
                A[i, pi] = -1.0
        A[i, npts] = tv
    # total mass <= 1
    for pi in range(npts):
        A[len(Ds), pi] = 1.0
    bvec[len(Ds)] = 1.0
    cobj = np.zeros(npts + 1)
    cobj[npts] = -1.0
    res = linprog(cobj, A_ub=A.tocsr(), b_ub=bvec, bounds=[(0, None)] * (npts + 1),
                  method="highs")
    return res.status, -res.fun, len(Ds), npts


def main():
    lines = []
    t1, (E1, E2, E3) = block_tau()
    val1 = lambda D: t1.get(D, Fr(0))
    n, bad = check_weak(val1, [0, 1, 2])
    lines.append(f"(a) block tau: {n} one-point inequalities checked, violations = {bad}")
    val2 = product_tau(2, t1)
    n2, bad2 = check_weak(val2, list(range(6)))
    lines.append(f"(a) tau^(x)2 on 6 inputs: {n2} one-point inequalities checked, violations = {bad2}")
    m = moebius(val1, frozenset(), [0, 1, 2])
    lines.append(f"(b) Moebius sum over S={{a,b,c}} at D=empty: {m} (negative => not a random partial function)")

    def consistent(D1, D2):
        d1 = dict(D1)
        return all(d1.get(x, y) == y for x, y in D2)
    pairs = [(i, j, consistent(Ei, Ej)) for (i, Ei), (j, Ej) in
             itertools.combinations(enumerate((E1, E2, E3), 1), 2)]
    lines.append(f"(c) pairwise consistency of E1,E2,E3: {pairs} (all False expected)")
    lines.append(f"    sum of tau(E_i) = {sum(val1(E) for E in (E1, E2, E3))} > 1")
    for k in (1, 2, 3):
        status, c, nD, npts = lp_best_c(k, t1)
        lines.append(f"(d) k={k}: LP status={status}, constraints={nD}, variables={npts}, "
                     f"max c = {c:.12f}, (2/3)^k = {(2/3)**k:.12f}, diff = {c-(2/3)**k:.2e}")
    out = "\n".join(lines)
    print(out)
    with open(__file__.replace(".py", ".out.txt"), "w") as f:
        f.write(out + "\n")


if __name__ == "__main__":
    main()
