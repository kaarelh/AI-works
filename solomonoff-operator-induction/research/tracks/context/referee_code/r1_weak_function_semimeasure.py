"""r1 (referee): an order-independent sub-probability predictor that is NOT Bayesian for any random
partial function, and a computable "function semimeasure" that no random-partial-function law dominates.

Target claims (context notes):
  * Prop 5.1 title/reading: "order-independent predictors are Bayesian predictors for random partial functions";
    "requiring order independence singles out exactly the Bayesian predictors over random (partial) functions".
  * Cor 5.2: "if M_F dominates every lower-semicomputable function semimeasure (H1(a)) ...".
  The notes' definition of a function semimeasure is the weak one:
      nu(empty) = 1,   sum_y nu(D + (x,y)) <= nu(D)   for all finite partial functions D and x not in dom D.

Construction ("complete graph"): fix k >= 3.  Points x_{ij} for 0 <= i < j < k.  Cylinders
      D_i = { x_{ij} -> (0 if i < j else 1) : j != i }      (x_{ij} means x_{min,max}).
  D_i and D_j disagree at x_{ij}, so the k cylinders are pairwise incompatible.
  Define nu(empty) = 1 and, for D nonempty, nu(D) = (1/2) * #{ i : D is contained in D_i }.

We check exhaustively (k = 3, 4, 5): the one-step inequality for every partial function D and every x
outside dom D; that the induced predictor q(y|x,D) = nu(D+(x,y))/nu(D) is order independent on every
total labelling (all orders); that sum_i nu(D_i) = k/2 > 1.  For any probability measure mu on partial
functions (any random partial function, hence any function-machine semimeasure mu_T and M_F itself),
pairwise incompatible cylinders have total mass <= 1, so mu >= c*nu forces c <= 2/k.  An LP over all
probability measures on {0,1,undefined}^X computes the best domination constant exactly for k = 3, 4.

The block mixture nu = sum_n 2^-n nu_n with k_n = 4^n (fresh points per block, uniform labels outside
the block) is computable, satisfies the weak inequality, and has pairwise incompatible cylinders of total
mass >= 2^(n-1) in block n, so NO random-partial-function law dominates it with a positive constant.
Deterministic (no randomness).
"""
import itertools
import math
from fractions import Fraction

import numpy as np
from scipy.optimize import linprog

out = []


def build(k):
    pts = [(i, j) for i in range(k) for j in range(i + 1, k)]
    idx = {p: t for t, p in enumerate(pts)}
    cyl = []
    for i in range(k):
        D = {}
        for j in range(k):
            if j == i:
                continue
            p = (min(i, j), max(i, j))
            D[idx[p]] = 0 if i < j else 1
        cyl.append(D)
    return pts, cyl


def nu_factory(cyl):
    def nu(D):
        if not D:
            return Fraction(1)
        cnt = sum(1 for C in cyl if all(x in C and C[x] == y for x, y in D.items()))
        return Fraction(cnt, 2)
    return nu


for k in [3, 4, 5]:
    pts, cyl = build(k)
    n = len(pts)
    nu = nu_factory(cyl)
    # all partial functions on n points: values in {0,1,None}
    ok_ineq = True
    worst = Fraction(0)
    count = 0
    for vals in itertools.product([0, 1, None], repeat=n):
        D = {x: v for x, v in enumerate(vals) if v is not None}
        nD = nu(D)
        for x in range(n):
            if x in D:
                continue
            s = nu({**D, x: 0}) + nu({**D, x: 1})
            count += 1
            if s > nD:
                ok_ineq = False
                worst = max(worst, s - nD)
    # pairwise incompatibility
    incompat = all(any(x in cyl[b] and cyl[b][x] != y for x, y in cyl[a].items())
                   for a in range(k) for b in range(k) if a != b)
    total = sum(nu(C) for C in cyl)
    # order independence of the induced predictor on all total labellings, all orders (k <= 4)
    oi_ok = True
    if n <= 6:
        for lab in itertools.product([0, 1], repeat=n):
            prods = set()
            for perm in itertools.permutations(range(n)):
                D = {}
                prod = Fraction(1)
                for x in perm:
                    den = nu(D)
                    if den == 0:
                        prod = Fraction(0)
                        break
                    prod *= nu({**D, x: lab[x]}) / den
                    D[x] = lab[x]
                prods.add(prod)
            if len(prods) != 1:
                oi_ok = False
    out.append(f"k={k}: {n} points; one-step inequality checked on {count} (D,x) pairs: {ok_ineq}; "
               f"cylinders pairwise incompatible: {incompat}; sum_i nu(D_i) = {total} (= k/2); "
               f"order independence on all labellings x all orders: {oi_ok if n <= 6 else 'not run (n>6)'}")
    # LP: best c such that some probability measure mu on {0,1,U}^n has mu(D) >= c nu(D) for all D with nu(D)>0
    if n <= 6:
        atoms = list(itertools.product([0, 1, 2], repeat=n))  # 2 = undefined
        A_ub, b_ub = [], []
        for vals in itertools.product([0, 1, None], repeat=n):
            D = {x: v for x, v in enumerate(vals) if v is not None}
            if not D:
                continue
            v = nu(D)
            if v == 0:
                continue
            row = [-1.0 if all(a[x] == y for x, y in D.items()) else 0.0 for a in atoms] + [float(v)]
            A_ub.append(row)  # -mu(D) + c nu(D) <= 0
            b_ub.append(0.0)
        A_eq = [[1.0] * len(atoms) + [0.0]]
        res = linprog(c=[0.0] * len(atoms) + [-1.0], A_ub=A_ub, b_ub=b_ub, A_eq=A_eq, b_eq=[1.0],
                      bounds=[(0, None)] * len(atoms) + [(0, None)], method="highs")
        out.append(f"      LP: best constant c with mu >= c*nu over all probability measures on partial functions: "
                   f"{-res.fun:.6f} (upper bound 2/k = {2 / k:.6f})")

# a two-point example that is order independent but violates inclusion-exclusion
nu2 = {(): 1.0, (("a", 0),): 0.6, (("b", 0),): 0.6, (("a", 0), ("b", 0)): 0.0}
out.append("two-point example: nu(a->0)=nu(b->0)=0.6, nu(a->0,b->0)=0 is a weak function semimeasure "
           "(0.6<=1, 0<=0.6) and order independent, but a random partial function would need "
           f"P(f(a)=0 or f(b)=0) = 0.6+0.6-0 = {0.6 + 0.6:.1f} > 1.")

# block mixture totals
for nblk in range(1, 8):
    kn = 4 ** nblk
    out.append(f"block n={nblk}: k_n={kn} pairwise incompatible cylinders, total nu-mass >= 2^-n * k_n/2 = "
               f"{kn / 2 / 2 ** nblk:.0f}; so any mu >= c*nu needs c <= {2 ** nblk * 2 / kn:.2e}")

txt = "\n".join(out)
print(txt)
with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write(txt + "\n")
