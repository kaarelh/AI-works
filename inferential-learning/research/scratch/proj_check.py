import numpy as np, itertools
from scipy.optimize import minimize
rng = np.random.default_rng(0)
worst = 1e9; bad = 0
for trial in range(300):
    n = rng.integers(2, 6)
    allw = np.array(list(itertools.product([0, 1], repeat=n)), float)
    W = allw[rng.choice(len(allw), size=rng.integers(1, len(allw)), replace=False)]
    x = rng.random(n)
    m = len(W)
    f = lambda lam: np.sum((x - lam @ W)**2)
    cons = [{'type': 'eq', 'fun': lambda lam: lam.sum() - 1}]
    r = minimize(f, np.ones(m)/m, bounds=[(0, 1)]*m, constraints=cons, method='SLSQP', options={'ftol': 1e-14, 'maxiter': 500})
    xs = r.x @ W
    d = np.sum((x - xs)**2)
    for w in W:  # vertices; inequality is for all w in K, check vertices + random points
        lhs = np.sum((x - w)**2); rhs = d + np.sum((xs - w)**2)
        worst = min(worst, lhs - rhs)
        if lhs < rhs - 1e-7: bad += 1
    # unsound case: actual world outside W
    outside = [w for w in allw if not any((w == v).all() for v in W)]
    if outside:
        w0 = outside[0]
        if np.sum((xs - w0)**2) > np.sum((x - w0)**2) + 1e-9: pass
print("violations of Pythagorean projection inequality:", bad, " min slack:", worst)
# minimal unsound example from memo: K={0}, x=0.9, truth=1
print("memo example Brier before/after:", (0.9-1)**2, (0-1)**2)
