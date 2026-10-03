"""T6 check 4: local-to-global for context covers.
(a) running-intersection (tree) covers: mutually conservative adjacent local theories => global model (random test);
(b) the frustrated triangle (cyclic cover): pairwise conservative, globally inconsistent;
(c) probabilistic version of (b): pairwise-consistent marginals with no global distribution."""
import itertools, random
import numpy as np
from scipy.optimize import linprog

def proj(models, ctx_vars, shared):
    idx = [ctx_vars.index(x) for x in shared]
    return set(tuple(m[k] for k in idx) for m in models)

def global_models(contexts, local):
    allvars = sorted(set(x for c in contexts for x in c))
    out = []
    for g in itertools.product([0, 1], repeat=len(allvars)):
        gv = dict(zip(allvars, g))
        if all(tuple(gv[x] for x in c) in local[ci] for ci, c in enumerate(contexts)):
            out.append(gv)
    return out

random.seed(3)
# (a) path cover a-b-c-d with contexts {x0,x1,x2},{x2,x3},{x3,x4,x5}: running intersection holds
contexts = [["x0", "x1", "x2"], ["x2", "x3"], ["x3", "x4", "x5"]]
edges = [(0, 1), (1, 2)]
tested = 0
for t in range(20000):
    local = []
    for c in contexts:
        allm = list(itertools.product([0, 1], repeat=len(c)))
        local.append(set(m for m in allm if random.random() < 0.5))
    if any(len(L) == 0 for L in local):
        continue
    ok = True
    for (i, j) in edges:
        sh = [x for x in contexts[i] if x in contexts[j]]
        if proj(local[i], contexts[i], sh) != proj(local[j], contexts[j], sh):
            ok = False
    if not ok:
        continue
    tested += 1
    G = global_models(contexts, local)
    assert G, "counterexample!"
    # moreover every local model extends to a global one
    for ci, c in enumerate(contexts):
        assert set(tuple(g[x] for x in c) for g in G) == local[ci]
print("(a) tree cover: %d random mutually-conservative systems, all globally consistent and conservative: OK" % tested)

# (a2) [added after verification] random trees (2-5 nodes), random atom placement with running intersection
# (each atom occupies a random connected subtree), random local theories; keep the edge-conservative ones.
# Negative control: same, but atoms placed on arbitrary (possibly disconnected) node sets.
def random_system(rng, connected):
    nn = rng.randint(2, 5)
    par = {v: rng.randrange(v) for v in range(1, nn)}
    adj = {v: set() for v in range(nn)}
    for v, p in par.items():
        adj[v].add(p); adj[p].add(v)
    atoms_of = {v: [] for v in range(nn)}
    for a in range(rng.randint(2, 5)):
        if connected:
            sub = {rng.randrange(nn)}
            while rng.random() < 0.6:
                frontier = [u for s in sub for u in adj[s] if u not in sub]
                if not frontier:
                    break
                sub.add(rng.choice(frontier))
        else:
            sub = {v for v in range(nn) if rng.random() < 0.5} or {rng.randrange(nn)}
        for v in sub:
            atoms_of[v].append("y%d" % a)
    ctxs = [atoms_of[v] for v in range(nn)]
    if any(len(c) == 0 or len(c) > 4 for c in ctxs):
        return None
    loc = []
    for c in ctxs:
        allm = list(itertools.product([0, 1], repeat=len(c)))
        L = set(m for m in allm if rng.random() < 0.6)
        if not L:
            return None
        loc.append(L)
    for v, p in par.items():
        sh = [x for x in ctxs[v] if x in ctxs[p]]
        if proj(loc[v], ctxs[v], sh) != proj(loc[p], ctxs[p], sh):
            return None
    return ctxs, loc

rng2 = random.Random(5)
tested2 = 0
while tested2 < 2000:
    s = random_system(rng2, connected=True)
    if s is None:
        continue
    ctxs, loc = s; tested2 += 1
    G = global_models(ctxs, loc)
    for ci, c in enumerate(ctxs):
        assert set(tuple(g[x] for x in c) for g in G) == loc[ci], "counterexample to Thm 4.6!"
neg = bad = 0
while neg < 2000:
    s = random_system(rng2, connected=False)
    if s is None:
        continue
    ctxs, loc = s; neg += 1
    G = global_models(ctxs, loc)
    if any(set(tuple(g[x] for x in c) for g in G) != loc[ci] for ci, c in enumerate(ctxs)):
        bad += 1
print("(a2) %d random tree covers with running intersection and conservative edges: every local model extends: OK"
      % tested2)
print("     negative control (running intersection dropped, edges still conservative): %d of %d systems fail" % (bad, neg))
assert bad > 0

# (b) frustrated triangle
contexts = [["a", "b"], ["b", "c"], ["c", "a"]]
anti = set(m for m in itertools.product([0, 1], repeat=2) if m[0] != m[1])   # x <-> not y
local = [anti, anti, anti]
for (i, j) in [(0, 1), (1, 2), (2, 0)]:
    sh = [x for x in contexts[i] if x in contexts[j]]
    assert proj(local[i], contexts[i], sh) == proj(local[j], contexts[j], sh) == {(0,), (1,)}
print("(b) frustrated triangle: pairwise conservative on every overlap; global models:", global_models(contexts, local))

# (c) probabilistic: each context's marginal is uniform on {01,10}; single-variable marginals all 1/2
allv = list(itertools.product([0, 1], repeat=3))  # (a,b,c)
rows = []; rhs = []
for (x, y) in [(0, 1), (1, 2), (2, 0)]:
    for (u, w) in itertools.product([0, 1], repeat=2):
        rows.append([1.0 if (v[x], v[y]) == (u, w) else 0.0 for v in allv])
        rhs.append(0.5 if u != w else 0.0)
rows.append([1.0] * 8); rhs.append(1.0)
r = linprog(np.zeros(8), A_eq=np.array(rows), b_eq=np.array(rhs), bounds=[(0, None)] * 8, method="highs")
print("(c) global distribution with these pairwise marginals exists?", r.status == 0)
