import itertools, random
random.seed(5)
def rand_tree(n):
    par = {0: None}
    for v in range(1, n): par[v] = random.randrange(v)
    adj = {v: set() for v in range(n)}
    for v in range(1, n): adj[v].add(par[v]); adj[par[v]].add(v)
    return adj
def rand_subtree(adj, n):
    # random connected subset grown from random start
    start = random.randrange(n); S = {start}
    while random.random() < 0.6:
        fr = [w for v in S for w in adj[v] if w not in S]
        if not fr: break
        S.add(random.choice(fr))
    return S
def proj(models, vars_, shared):
    idx = [vars_.index(x) for x in shared]
    return set(tuple(m[k] for k in idx) for m in models)
tested = 0; fails = 0; neg_fail = 0; neg_tested=0
for t in range(40000):
    n = random.randint(2, 5)
    adj = rand_tree(n)
    natoms = random.randint(2, 6)
    occ = {a: rand_subtree(adj, n) for a in range(natoms)}
    ctx = [sorted(a for a in range(natoms) if v in occ[a]) for v in range(n)]
    if any(len(c) == 0 or len(c) > 4 for c in ctx): continue
    local = []
    for c in ctx:
        allm = list(itertools.product([0, 1], repeat=len(c)))
        local.append(set(m for m in allm if random.random() < 0.6))
    if any(not L for L in local): continue
    edges = [(v, w) for v in range(n) for w in adj[v] if v < w]
    if any(proj(local[v], ctx[v], [x for x in ctx[v] if x in ctx[w]]) != proj(local[w], ctx[w], [x for x in ctx[v] if x in ctx[w]]) for v, w in edges):
        continue
    tested += 1
    allv = sorted(set(x for c in ctx for x in c))
    G = []
    for g in itertools.product([0, 1], repeat=len(allv)):
        gv = dict(zip(allv, g))
        if all(tuple(gv[x] for x in c) in local[k] for k, c in enumerate(ctx)): G.append(gv)
    for k, c in enumerate(ctx):
        if set(tuple(g[x] for x in c) for g in G) != local[k]: fails += 1; break
print("Thm 4.6 random trees: tested", tested, "failures", fails)

# Negative control: violate running intersection (atom occurrences disconnected) and see failures occur
random.seed(9)
for t in range(40000):
    n = random.randint(3, 5)
    adj = rand_tree(n)
    natoms = random.randint(2, 5)
    occ = {a: set(v for v in range(n) if random.random() < 0.5) for a in range(natoms)}
    ctx = [sorted(a for a in range(natoms) if v in occ[a]) for v in range(n)]
    if any(len(c) == 0 or len(c) > 4 for c in ctx): continue
    local = []
    for c in ctx:
        allm = list(itertools.product([0, 1], repeat=len(c)))
        local.append(set(m for m in allm if random.random() < 0.6))
    if any(not L for L in local): continue
    edges = [(v, w) for v in range(n) for w in adj[v] if v < w]
    if any(proj(local[v], ctx[v], [x for x in ctx[v] if x in ctx[w]]) != proj(local[w], ctx[w], [x for x in ctx[v] if x in ctx[w]]) for v, w in edges):
        continue
    neg_tested += 1
    allv = sorted(set(x for c in ctx for x in c))
    G = [g for g in itertools.product([0,1], repeat=len(allv)) if all(tuple(dict(zip(allv,g))[x] for x in c) in local[k] for k,c in enumerate(ctx))]
    if not G: neg_fail += 1
print("negative control (no running intersection): tested", neg_tested, "globally inconsistent", neg_fail)
