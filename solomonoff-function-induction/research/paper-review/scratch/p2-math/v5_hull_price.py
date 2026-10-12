"""Independent randomized checks: hull lemma (iii)/(iv) and the price-of-private-randomness inequality
xi_lambda(D_beta) <= Rtilde(beta)^{min(lambda,2)} on random finite Kraft product classes. Seed 2026."""
import random, itertools, math
random.seed(2026)
# ---------- hull lemma
def minimisers(A, c):
    vals = [c*l + R for (l, R) in A]
    m = min(vals)
    return {i for i, v in enumerate(vals) if abs(v - m) < 1e-12}
def lower_hull_vertices(A):
    pts = sorted(set(A))
    # keep for each l the least R
    best = {}
    for l, R in pts:
        best[l] = min(R, best.get(l, math.inf))
    P = sorted(best.items())
    # monotone chain lower hull, then keep the decreasing part (orthant added)
    hull = []
    for p in P:
        while len(hull) >= 2:
            (x1, y1), (x2, y2) = hull[-2], hull[-1]
            if (x2-x1)*(p[1]-y1) - (y2-y1)*(p[0]-x1) <= 0:
                hull.pop()
            else:
                break
        hull.append(p)
    # cut at least-R point
    k = min(range(len(hull)), key=lambda i: (hull[i][1], hull[i][0]))
    return set(hull[:k+1])
mism = 0; tests = 0; iv_bad = 0
for _ in range(600):
    A = [(random.randint(0, 30), random.choice([random.random(), round(random.random(), 1)])) for _ in range(random.randint(2, 12))]
    V = lower_hull_vertices(A)
    cs = sorted({10**random.uniform(-3, 1) for _ in range(400)})
    for pt in set(A):
        # unique minimising point on an open interval (approximate by two consecutive grid c's both unique)
        uniq = [minimisers(A, c) and all(A[i] == pt for i in minimisers(A, c)) for c in cs]
        has = any(uniq[i] and uniq[i+1] for i in range(len(cs)-1))
        tests += 1
        if has != (pt in V):
            mism += 1
    # (iv): every minimiser h_c solves the constrained problem at L = l(h_c)
    for c in cs[::20]:
        for i in minimisers(A, c):
            L = A[i][0]
            best = min(R for (l, R) in A if l <= L)
            if A[i][1] > best + 1e-12:
                iv_bad += 1
print(f"hull (iii): {mism} mismatches in {tests} point tests (grid approximation of open intervals); (iv) first part violations: {iv_bad}")
A = [(0, 1.0), (10, 0.0), (20, 0.0)]
print("counterexample {(0,1),(10,0),(20,0)}: (20,0) minimiser for some c in grid?", any(2 in minimisers(A, c) for c in [10**(-k/10) for k in range(-10, 60)]))
# ---------- price inequality
viol = 0; worst = -1e9; n = 0
for trial in range(400):
    k = random.randint(1, 3)
    m = random.randint(1, 6)
    lens = [random.randint(1, 5) for _ in range(m)]
    s = sum(2.0**-l for l in lens)
    if s > 1:
        continue
    nus = []
    for _ in range(m):
        tab = []
        for _ in range(2*k):
            a = random.random(); b = random.random()*(1-a) if random.random() < 0.7 else 1-a
            if random.random() < 0.3:
                a, b = (1.0, 0.0) if random.random() < 0.5 else (0.0, 1.0)
            tab.append((a, b))
        nus.append(tab)
    for lam in (1.0, 1.3, 1.7, 2.0, 2.5, 4.0):
        g = min(lam, 2.0)
        for beta in itertools.product((0, 1), repeat=k):
            xi = 0.0; Rt = 0.0
            for l, tab in zip(lens, nus):
                like = 1.0; Q = 1.0
                for j in range(k):
                    a_ = tab[2*j][beta[j]]; b_ = tab[2*j+1][beta[j]]
                    like *= a_*b_; Q *= (a_ + b_)/2
                xi += 2.0**(-lam*l)*like; Rt += 2.0**(-l)*Q
            n += 1
            if xi > Rt**g*(1+1e-12) + 1e-300:
                viol += 1
            if xi > 0 and Rt > 0:
                worst = max(worst, math.log2(xi) - g*math.log2(Rt))
print(f"price inequality: {viol} violations in {n} checks; max log2(xi/R^gamma) = {worst:.3e}")
