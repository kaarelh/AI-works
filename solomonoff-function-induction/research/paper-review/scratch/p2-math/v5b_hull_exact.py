"""Exact check of hull lemma (iii): compute, for each distinct point, the exact set of c>0 where it is the unique
minimising point (an interval computed from pairwise comparisons), and compare with 'vertex of C'. Seed 2026."""
import random, math
from fractions import Fraction as Fr
random.seed(2026)
def vertices(P):
    # P: distinct points (l, R) with rational coords. Vertex of conv(P)+orthant = exposed by some (c,1), c>0, uniquely,
    # OR the least-R point with least l among them (exposed by c -> 0+), OR least-l point with least R (c -> inf).
    pass
mism = 0; tot = 0; examples = []
for _ in range(3000):
    P = list({(random.randint(0, 25), Fr(random.randint(0, 20), 20)) for _ in range(random.randint(2, 10))})
    for a in P:
        lo, hi = Fr(0), None   # open interval of c where a strictly beats every other point
        ok = True
        for b in P:
            if b == a: continue
            dl = b[0] - a[0]; dR = b[1] - a[1]
            # need c*a_l + a_R < c*b_l + b_R  <=>  c*dl + dR > 0
            if dl == 0:
                if dR <= 0: ok = False
            elif dl > 0:
                # c > -dR/dl
                lo = max(lo, -dR/dl)
            else:
                # c < dR/(-dl)
                bound = dR/(-dl)
                hi = bound if hi is None else min(hi, bound)
        interval_nonempty = ok and (hi is None or hi > lo)
        # vertex test: a is extreme point of conv(P)+R^2_{>=0}: no other point dominates it weakly with one strict,
        # and it is not a convex combination of points/rays: equivalently exposed => same as above for polyhedra.
        # Independent vertex test via lower-left hull construction:
        tot += 1
        # build lower-left boundary vertices
        best = {}
        for (l, R) in P:
            best[l] = min(R, best.get(l, Fr(10**9)))
        Q = sorted(best.items())
        hull = []
        for p in Q:
            while len(hull) >= 2:
                (x1, y1), (x2, y2) = hull[-2], hull[-1]
                if (x2-x1)*(p[1]-y1) - (y2-y1)*(p[0]-x1) <= 0: hull.pop()
                else: break
            hull.append(p)
        k = min(range(len(hull)), key=lambda i: (hull[i][1], hull[i][0]))
        V = set(hull[:k+1])
        if interval_nonempty != (a in V):
            mism += 1
            if len(examples) < 3: examples.append((sorted(P), a, interval_nonempty, a in V))
print(f"hull (iii) exact: {mism} mismatches in {tot} point tests")
for e in examples: print(e)
