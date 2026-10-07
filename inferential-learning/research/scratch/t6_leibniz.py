import itertools, random
random.seed(1)
def congruence_closure(n, ops, pairs):
    # smallest congruence containing pairs; ops: list of (arity, table dict tuple->val)
    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]; x = parent[x]
        return x
    def union(a, b):
        a, b = find(a), find(b)
        if a != b: parent[a] = b; return True
        return False
    for a, b in pairs: union(a, b)
    changed = True
    while changed:
        changed = False
        for ar, tab in ops:
            for args in itertools.product(range(n), repeat=ar):
                for args2 in itertools.product(range(n), repeat=ar):
                    if all(find(x) == find(y) for x, y in zip(args, args2)):
                        if union(tab[args], tab[args2]): changed = True
    return [find(x) for x in range(n)]
def all_congruences(n, ops):
    # principal-generated closure over all subsets of pairs is too big; do BFS over joins
    seen = set(); out = []
    base = tuple(congruence_closure(n, ops, []))
    def canon(lab):
        m = {}; return tuple(m.setdefault(l, len(m)) for l in lab)
    frontier = [canon(base)]
    seen.add(canon(base))
    while frontier:
        cur = frontier.pop()
        out.append(cur)
        for a in range(n):
            for b in range(a+1, n):
                if cur[a] != cur[b]:
                    pairs = [(x, y) for x in range(n) for y in range(n) if cur[x] == cur[y]] + [(a, b)]
                    nl = canon(congruence_closure(n, ops, pairs))
                    if nl not in seen: seen.add(nl); frontier.append(nl)
    return out
def leibniz(n, ops, D, congs):
    best = None
    for c in congs:
        if all((c[a] != c[b]) or ((a in D) == (b in D)) for a in range(n) for b in range(n)):
            if best is None or len(set(c)) < len(set(best)): best = c
    # check it is the largest: every compatible congruence refines best
    for c in congs:
        if all((c[a] != c[b]) or ((a in D) == (b in D)) for a in range(n) for b in range(n)):
            assert all(best[a] == best[b] for a in range(n) for b in range(n) if c[a] == c[b])
    return best
bad = 0; tests = 0
for t in range(400):
    n = random.randint(2, 6)
    ops = [(2, {args: random.randrange(n) for args in itertools.product(range(n), repeat=2)}),
           (1, {args: random.randrange(n) for args in itertools.product(range(n), repeat=1)})]
    congs = all_congruences(n, ops)
    theta = random.choice(congs)               # quotient A = A'/theta, h = quotient map (surjective)
    classes = sorted(set(theta)); m = len(classes); idx = {c: k for k, c in enumerate(classes)}
    h = [idx[theta[x]] for x in range(n)]
    opsA = []
    for ar, tab in ops:
        tA = {}
        for args in itertools.product(range(n), repeat=ar):
            key = tuple(h[a] for a in args); val = h[tab[args]]
            assert tA.get(key, val) == val; tA[key] = val
        opsA.append((ar, tA))
    congsA = all_congruences(m, opsA)
    for _ in range(4):
        D = set(x for x in range(m) if random.random() < 0.5)
        T = set(x for x in range(n) if h[x] in D)
        OmA = leibniz(m, opsA, D, congsA)
        OmT = leibniz(n, ops, T, congs)
        tests += 1
        for a in range(n):
            for b in range(n):
                if (OmT[a] == OmT[b]) != (OmA[h[a]] == OmA[h[b]]): bad += 1
print("Thm 5.2(a) claim Omega(h^-1 D) = h^-1(Omega D): tests", tests, "mismatching pairs", bad)
