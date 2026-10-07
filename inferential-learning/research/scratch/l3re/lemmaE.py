import numpy as np, itertools, random
from scipy.optimize import minimize, linprog
rng = np.random.default_rng(0)

def proj(x, V):
    # Euclidean projection of x onto conv(V) via QP over simplex weights
    k = len(V); V = np.array(V, float)
    f = lambda l: np.sum((l @ V - x) ** 2)
    g = lambda l: 2 * (l @ V - x) @ V.T
    cons = [{'type': 'eq', 'fun': lambda l: l.sum() - 1, 'jac': lambda l: np.ones(k)}]
    best = None
    for _ in range(3):
        l0 = rng.dirichlet(np.ones(k))
        r = minimize(f, l0, jac=g, bounds=[(0, 1)] * k, constraints=cons, method='SLSQP',
                     options={'ftol': 1e-14, 'maxiter': 500})
        if best is None or r.fun < best.fun: best = r
    return best.x @ V

def in_hull(v, V):
    V = np.array(V, float); k = len(V)
    A = np.vstack([V.T, np.ones(k)]); b = np.append(v, 1)
    r = linprog(np.zeros(k), A_eq=A, b_eq=b, bounds=[(0, None)] * k)
    return r.status == 0

def arb(P, V):
    # max_{y in [-1,1]^S} min_W <y, W-P>  as LP: max s s.t. <y,W-P> >= s
    V = np.array(V, float); n = len(P)
    c = np.zeros(n + 1); c[-1] = -1
    A = np.hstack([-(V - P), np.ones((len(V), 1))]); b = np.zeros(len(V))
    r = linprog(c, A_ub=A, b_ub=b, bounds=[(-1, 1)] * n + [(None, None)])
    return -r.fun

def l1dist(P, V):
    # min_{w in conv V} ||w-P||_1 as LP
    V = np.array(V, float); k, n = V.shape
    # vars: lambda (k), e (n);  -e <= lambda V - P <= e
    c = np.concatenate([np.zeros(k), np.ones(n)])
    A1 = np.hstack([V.T, -np.eye(n)]); A2 = np.hstack([-V.T, -np.eye(n)])
    A = np.vstack([A1, A2]); b = np.concatenate([P, -P])
    Aeq = np.concatenate([np.ones(k), np.zeros(n)])[None]
    r = linprog(c, A_ub=A, b_ub=b, A_eq=Aeq, b_eq=[1], bounds=[(0, None)] * (k + n))
    return r.fun

dom_viol = 0; conv_ok = 0; conv_tot = 0; arbl1 = 0
for trial in range(300):
    n = rng.integers(2, 6)
    allv = list(itertools.product([0, 1], repeat=n))
    m = rng.integers(1, len(allv))
    V = [allv[i] for i in rng.choice(len(allv), m, replace=False)]
    x = rng.random(n)
    xs = proj(x, V)
    for w in V:
        lhs = np.sum((x - np.array(w)) ** 2); rhs = np.sum((xs - np.array(w)) ** 2) + np.sum((x - xs) ** 2)
        if lhs < rhs - 1e-6: dom_viol += 1
    # converse: an actual world v outside V
    outside = [v for v in allv if v not in V]
    if outside:
        v = np.array(outside[0], float); conv_tot += 1
        vs = proj(v, V)
        if (not in_hull(v, V)) and np.sum((v - vs) ** 2) > 1e-6: conv_ok += 1
    if abs(arb(x, V) - l1dist(x, V)) > 1e-6: arbl1 += 1
print('dominance violations', dom_viol)
print('converse holds', conv_ok, '/', conv_tot)
print('Arb != l1-distance count', arbl1)
# counterexample
V = [(1, 0), (0, 1)]; x = np.array([.6, .6])
print('Arb', arb(x, V), 'l1', l1dist(x, V), 'proj', proj(x, V))
br = lambda p, w: np.sum((np.array(p) - np.array(w)) ** 2)
print('Brier (1,0) in (0,1):', br((1, 0), (0, 1)), ' x in (0,1):', br(x, (0, 1)), ' x in (1,0):', br(x, (1, 0)), ' proj:', br((.5, .5), (0, 1)), br((.5, .5), (1, 0)))
print('unsound min example', (0.9 - 1) ** 2, (0 - 1) ** 2)
