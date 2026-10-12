"""c3: the minimax step of Thm 3.8 in notes.md and notes-final.md, on small finite instances.

Setting: X = {0,1,2}, Y = {0,1}, horizon n = 3, the 8 functions f: X -> Y.
For a history-aware predictor P and an input policy Delta we compute

  V = min over random functions G (distributions on the 8 functions)
      max over f of  E_{x ~ Delta_f}[ -log G(f|x) ] - E_{x ~ Delta_f}[ L_P(f, x) ]

with an epigraph formulation solved by SLSQP (several restarts).  The theorem says:
  * non-peeking Delta (Delta(x_i | h_{i-1})):  V <= 0;
  * peeking Delta (Delta(x_i | f, h_{i-1})):  V <= C_dir = max_pi I_pi(f -> x).
For the peeking case we compute a lower estimate of C_dir by maximising I_pi(f->x) over pi
(random restarts); V <= estimate implies V <= C_dir.  A designed peeking policy shows V > 0.
Seed 7.  Output saved to c3_minimax.out.
"""
import itertools, math
import numpy as np
from scipy.optimize import minimize

SEED = 7
rng = np.random.default_rng(SEED)
X = (0, 1, 2); Y = (0, 1); n = 3
FUNCS = list(itertools.product(Y, repeat=len(X)))
NF = len(FUNCS)
ALLH = {k: list(itertools.product(itertools.product(X, Y), repeat=k)) for k in range(n + 1)}

def lg(p):
    return -math.log2(p) if p > 0 else math.inf

def paths(Delta, peek):
    """for each f: list of (prob, history h) of the process with that f"""
    out = []
    for f in FUNCS:
        lst = []
        for xs in itertools.product(X, repeat=n):
            h = tuple((x, f[x]) for x in xs)
            p = 1.0
            for i, x in enumerate(xs):
                p *= (Delta[(f, h[:i])] if peek else Delta[h[:i]])[x]
            if p > 0:
                lst.append((p, h))
        out.append(lst)
    return out

def LP(P, h):
    return sum(lg(P[(h[:i], x)][y]) for i, (x, y) in enumerate(h))

def cons_mask(h):
    D = set(h)
    return np.array([all(g[x] == y for x, y in D) for g in FUNCS], dtype=float)

def game_value(Delta, P, peek, restarts=6):
    PS = paths(Delta, peek)
    rows = []  # per f: list of (prob, mask), and E[L_P]
    for fi in range(NF):
        lst = [(p, cons_mask(h)) for p, h in PS[fi]]
        ELP = sum(p * LP(P, h) for p, h in PS[fi])
        rows.append((lst, ELP))
    finite = [fi for fi in range(NF) if math.isfinite(rows[fi][1])]
    def phi(G, fi):
        lst, ELP = rows[fi]
        return sum(p * -math.log2(max(float(m @ G), 1e-300)) for p, m in lst) - ELP
    best = math.inf; bestG = None
    for r in range(restarts):
        G0 = rng.dirichlet(np.ones(NF))
        z0 = np.concatenate([G0, [max(phi(G0, fi) for fi in finite)]])
        cons = [{"type": "eq", "fun": lambda z: z[:NF].sum() - 1}]
        for fi in finite:
            cons.append({"type": "ineq", "fun": (lambda z, fi=fi: z[NF] - phi(z[:NF], fi))})
        res = minimize(lambda z: z[NF], z0, method="SLSQP", constraints=cons,
                       bounds=[(1e-9, 1)] * NF + [(None, None)], options={"maxiter": 500, "ftol": 1e-12})
        G = np.clip(res.x[:NF], 1e-12, None); G /= G.sum()
        val = max(phi(G, fi) for fi in finite)
        if val < best:
            best, bestG = val, G
    return best, bestG

def directed_info(pi, Delta, peek):
    """I_pi(f -> x) = E[log Delta(x|f) / Deltabar(x||y)]"""
    PS = paths(Delta, peek)
    joint = {}
    for fi in range(NF):
        for p, h in PS[fi]:
            joint[(fi, h)] = pi[fi] * p
    cache = {}
    def pref(hp, x=None):
        key = (hp, x)
        if key not in cache:
            k = len(hp)
            cache[key] = sum(w for (fi, h), w in joint.items() if h[:k] == hp and (x is None or h[k][0] == x))
        return cache[key]
    I = 0.0
    for (fi, h), w in joint.items():
        if w == 0:
            continue
        f = FUNCS[fi]
        for i, (x, y) in enumerate(h):
            dfx = (Delta[(f, h[:i])] if peek else Delta[h[:i]])[x]
            dbar = pref(h[:i], x) / pref(h[:i])
            I += w * math.log2(dfx / dbar)
    return I

def cdir_lower(Delta, peek, restarts=4):
    best = 0.0
    for r in range(restarts):
        z0 = rng.normal(size=NF)
        f = lambda z: -directed_info(np.exp(z) / np.exp(z).sum(), Delta, peek)
        res = minimize(f, z0, method="Nelder-Mead", options={"maxiter": 400, "xatol": 1e-4, "fatol": 1e-6})
        best = max(best, -res.fun)
    return best

def rand_nonpeek():
    return {h: rng.dirichlet(np.ones(len(X)) * 0.7) for k in range(n) for h in ALLH[k]}

def rand_peek():
    return {(f, h): rng.dirichlet(np.ones(len(X)) * 0.7) for f in FUNCS for k in range(n) for h in ALLH[k]}

def rand_P():
    return {(h, x): rng.dirichlet(np.ones(len(Y)) * 0.7) for k in range(n) for h in ALLH[k] for x in X}

def bayes_P(prior):
    Pb = {}
    for k in range(n):
        for h in ALLH[k]:
            D = set(h)
            cons = [gj for gj, g in enumerate(FUNCS) if all(g[x] == y for x, y in D)]
            b = sum(prior[gj] for gj in cons)
            for x in X:
                Pb[(h, x)] = (np.ones(len(Y)) / 2 if b == 0 else
                              np.array([sum(prior[gj] for gj in cons if FUNCS[gj][x] == y) / b for y in Y]))
    return Pb

def copy_P(q=0.9):
    """order-exploiting predictor: y_i = y_{i-1} with prob q (uniform at i = 1)"""
    Pc = {}
    for k in range(n):
        for h in ALLH[k]:
            for x in X:
                if k == 0:
                    Pc[(h, x)] = np.array([0.5, 0.5])
                else:
                    yl = h[-1][1]
                    Pc[(h, x)] = np.array([q if y == yl else 1 - q for y in Y])
    return Pc

print("Non-peeking policies (theorem: V <= 0)")
maxV = -math.inf
for inst in range(8):
    Delta = rand_nonpeek()
    for kind, P in (("random", rand_P()), ("bayes", bayes_P(rng.dirichlet(np.ones(NF) * 0.5))), ("copy", copy_P())):
        V, G = game_value(Delta, P, peek=False)
        maxV = max(maxV, V)
        print(f"  instance {inst} P={kind:6s}: V = {V:+.5f}")
print(f"max V over non-peeking instances = {maxV:+.6f}")
assert maxV <= 1e-4

print("\nPeeking policies (theorem: V <= C_dir; lower estimate of C_dir shown)")
worst = -math.inf
for inst in range(4):
    Delta = rand_peek()
    P = bayes_P(rng.dirichlet(np.ones(NF) * 0.5))
    V, G = game_value(Delta, P, peek=True)
    C = cdir_lower(Delta, peek=True)
    worst = max(worst, V - C)
    print(f"  instance {inst}: V = {V:+.5f}, C_dir >= {C:.5f}")
# designed leaking policy: x_1 = f(2) (as an input index), then x_2 = 2, then x_3 = 0
Dl = {}
for f in FUNCS:
    for k in range(n):
        for h in ALLH[k]:
            v = np.zeros(len(X))
            if k == 0:
                v[f[2]] = 1.0
            elif k == 1:
                v[2] = 1.0
            else:
                v[0] = 1.0
            Dl[(f, h)] = v
Pl = {}
for k in range(n):
    for h in ALLH[k]:
        for x in X:
            if k == 1 and x == 2:  # predict f(2) = first input index
                Pl[(h, x)] = np.array([1.0 if y == h[0][0] else 0.0 for y in Y])
            else:
                Pl[(h, x)] = np.array([0.5, 0.5])
V, G = game_value(Dl, Pl, peek=True)
C = cdir_lower(Dl, peek=True)
worst = max(worst, V - C)
print(f"  designed leak (x_1 = f(2)): V = {V:+.5f}, C_dir >= {C:.5f}")
assert V > 0.5
print(f"max over peeking instances of V - C_dir_lower = {worst:+.6f} (must be <= 0 up to solver error)")
assert worst <= 1e-3
print("ALL CHECKS PASSED")
