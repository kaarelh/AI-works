"""Check 3: rate-threshold theorem (separable components) and hull tracing (general case).
(i) Separable: hypotheses h_S, S subset of [m], cost sum k_j, risk R0 - sum r_j.  Brute force
    argmin_S c*cost + risk over all 2^m subsets equals {j : r_j/k_j > c} for every c tested.
(ii) General: random finite achievable sets A of (cost, risk) points.  For a fine grid of c,
    every minimiser lies on the lower convex hull; every hull vertex is the unique minimiser
    for some c; minimisers are monotone (c down => cost up, risk down).
(iii) Separable classes with several options per region: the global optimum is the product of
    per-region optima (each region picks its own hull vertex for slope c)."""
import itertools, random
random.seed(1)

# (i)
viol = 0
for trial in range(300):
    m = random.randint(1, 9)
    k = [random.randint(1, 60) for _ in range(m)]
    r = [random.random() * 0.05 for _ in range(m)]
    for c in [10 ** (-random.uniform(1, 5)) for _ in range(20)]:
        best = min(itertools.product([0, 1], repeat=m),
                   key=lambda S: sum(s * (c * kj - rj) for s, kj, rj in zip(S, k, r)))
        thr = tuple(int(rj / kj > c) for kj, rj in zip(k, r))
        if best != thr: viol += 1
print("(i) separable threshold rule: violations =", viol, "(of 6000 (instance,c) pairs)")

# (ii)
def lower_hull(P):
    P = sorted(set(P))
    Hh = []
    for p in P:
        while len(Hh) >= 2 and (Hh[-1][0]-Hh[-2][0])*(p[1]-Hh[-2][1]) - (Hh[-1][1]-Hh[-2][1])*(p[0]-Hh[-2][0]) <= 0:
            Hh.pop()
        Hh.append(p)
    out = [Hh[0]]
    for p in Hh[1:]:
        if p[1] < out[-1][1]: out.append(p)
    return out
bad_onhull = bad_vertex = bad_mono = 0
for trial in range(300):
    A = [(random.randint(0, 200), random.random()) for _ in range(random.randint(2, 40))]
    Hv = lower_hull(A)
    cs = sorted([10 ** (-random.uniform(-1, 4)) for _ in range(400)], reverse=True)
    sel = []
    for c in cs:
        val = min(c * a + b for a, b in A)
        mins = [p for p in A if abs(c * p[0] + p[1] - val) < 1e-12]
        for p in mins:
            # on hull boundary: no hull vertex strictly better for this c (always true) and p is
            # on a supporting line of slope -c: check val equals hull's min
            if abs(min(c*a+b for a, b in Hv) - val) > 1e-12: bad_onhull += 1
        sel.append(min(mins))
    for (a1, b1), (a2, b2) in zip(sel, sel[1:]):          # c decreasing
        if a2 < a1 or b2 > b1 + 1e-12: bad_mono += 1
    for i, v in enumerate(Hv):                              # each vertex uniquely selected somewhere
        lo = (Hv[i][1]-Hv[i+1][1])/(Hv[i+1][0]-Hv[i][0]) if i+1 < len(Hv) else 0.0
        hi = (Hv[i-1][1]-Hv[i][1])/(Hv[i][0]-Hv[i-1][0]) if i > 0 else float('inf')
        c = (lo + hi)/2 if hi < float('inf') else lo*2 + 1
        val = [c*a+b for a, b in A]
        if sorted(val)[0] != c*v[0]+v[1] or (len(val) > 1 and sorted(val)[1] - sorted(val)[0] < 1e-15 and A.count(v) == 1):
            bad_vertex += 1
print(f"(ii) general sets: minimisers off hull = {bad_onhull}, monotonicity violations = {bad_mono}, "
      f"vertices not selectable = {bad_vertex}")

# (iii)
viol = 0
for trial in range(200):
    regions = [[(0, random.random())] + [(random.randint(1, 50), random.random()) for _ in range(random.randint(1, 3))]
               for _ in range(random.randint(1, 4))]
    for c in [10 ** (-random.uniform(0, 3)) for _ in range(10)]:
        glob = min(itertools.product(*regions), key=lambda T: sum(c*a+b for a, b in T))
        loc = tuple(min(R, key=lambda p: c*p[0]+p[1]) for R in regions)
        if abs(sum(c*a+b for a, b in glob) - sum(c*a+b for a, b in loc)) > 1e-12: viol += 1
print("(iii) product classes: global optimum = product of local optima; violations =", viol)
