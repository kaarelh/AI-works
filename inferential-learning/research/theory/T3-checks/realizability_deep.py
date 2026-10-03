"""Independent stress test of T3 Thm 2.4(a) (written by a referee during verification; added to T3-checks) with deeper trees, SUP-under-DEF, multiple bridge uses,
interval exports, side-condition-dependent informativeness, non-singleton root sets.
Brute force = tree CSP by DP over arbitrary subsets (root: any nonempty subset)."""
import itertools, random, sys
QN = 4
VALS = [(p, q) for p in (0, 1) for q in range(QN)]
ATOMS = {"p": lambda v: v[0] == 1, "~p": lambda v: v[0] == 0, "bot": lambda v: False, "top": lambda v: True}
for a in range(QN):
    ATOMS[f"Q={a}"] = (lambda a: lambda v: v[1] == a)(a)
    ATOMS[f"Q!={a}"] = (lambda a: lambda v: v[1] != a)(a)
    ATOMS[f"Q~{a}"] = (lambda a: lambda v: abs(v[1]-a) <= 1)(a)
    ATOMS[f"Q~~{a}"] = (lambda a: lambda v: abs(v[1]-a) <= 2)(a)
NAMES = [n for n in ATOMS if "~" not in n or n in ("~p",)]
ALLN = list(ATOMS)
SUBSETS = [frozenset(s) for r in range(len(VALS)+1) for s in itertools.combinations(VALS, r)]
def holds(M, G, f): return all(ATOMS[f](v) for v in M if all(ATOMS[g](v) for g in G))
def sat(fs): return any(all(ATOMS[f](v) for f in fs) for v in VALS)
# bridge kinds: (eps-prefix, sigma) ; informative iff {sigma} U {eps(v): v} unsat
BK = [("Q=", "top"), ("Q=", "p"), ("Q~", "top"), ("Q~", "~p"), ("Q~~", "Q!=1"), ("Q~~", "top"), ("Q~", "Q!=1"), ("Q~~", "Q=0"), ("Q~~", "Q=3")]
def informative(k):
    e, s = k; return not sat([s] + [f"{e}{v}" for v in range(QN)])
def rand_inst(rng, allow_uninf=False):
    # nodes 0 root; DEF nodes 1..nd; SUP nodes after
    nd = rng.randint(1, 3); ns = rng.randint(0, 2)
    kind = {0: "ROOT"}; parent = {}
    for i in range(1, nd+1):
        kind[i] = "DEF"; parent[i] = rng.randrange(0, i)
    for j in range(nd+1, nd+1+ns):
        kind[j] = "SUP"; parent[j] = rng.randrange(0, j)  # any earlier (SUP has only SUP descendants: ok, DEF ids are smaller)
    asm = {j: rng.choice(NAMES) for j in kind if kind[j] == "SUP"}
    nodes = list(kind)
    J = []
    for _ in range(rng.randint(1, 6)):
        c = rng.choice(nodes); G = tuple(rng.sample(NAMES, rng.choice([0, 0, 1]))); J.append((c, G, rng.choice(NAMES)))
    U = []
    for c in range(1, nd+1):
        for _ in range(rng.choice([0, 0, 1, 1, 2])):
            k = rng.choice(BK if allow_uninf else [b for b in BK if informative(b)])
            t = rng.randrange(QN); p = parent[c]
            U.append((c, k, t)); J += [(c, (), f"Q={t}"), (p, (), k[1]), (p, (), f"{k[0]}{t}")]
    C = {c for c in range(1, nd+1) if rng.random() < 0.25}
    return kind, parent, asm, J, U, C
def brute(inst):
    kind, parent, asm, J, U, C = inst
    children = {c: [d for d in parent if parent[d] == c] for c in kind}
    # value of SUP nodes determined from nearest non-SUP ancestor's value
    def supval(base_M, node):
        # returns dict of M for SUP descendants (all descendants of non-SUP node that are SUP, through SUP chains)
        out = {}
        stack = [(d, base_M) for d in children[node] if kind[d] == "SUP"]
        while stack:
            d, Mp = stack.pop(); Md = frozenset(v for v in Mp if ATOMS[asm[d]](v)); out[d] = Md
            stack += [(e, Md) for e in children[d] if kind[e] == "SUP"]
        return out
    def local_ok(node, M):
        if node == 0 and len(M) == 0: return False
        if node in C and len(M) == 0: return False
        vals = {node: M}; vals.update(supval(M, node))
        return all(holds(vals[c], G, f) for (c, G, f) in J if c in vals)
    def bridge_ok(c, Mc, Mp):
        for (cc, k, t) in U:
            if cc != c: continue
            e, s = k
            for v in range(QN):
                if holds(Mc, (), f"Q={v}") and not all((not ATOMS[s](x)) or ATOMS[f"{e}{v}"](x) for x in Mp): return False
        return True
    nonsup = [c for c in kind if kind[c] != "SUP"]
    # DP bottom-up over non-SUP tree (DEF children of non-SUP nodes)
    feas = {}
    for node in sorted(nonsup, reverse=True):
        dch = [d for d in children[node] if kind[d] == "DEF"]
        fs = []
        for M in SUBSETS:
            if not local_ok(node, M): continue
            if all(any(bridge_ok(d, Md, M) for Md in feas[d]) for d in dch): fs.append(M)
        feas[node] = fs
    return len(feas[0]) > 0
def criterion(inst):
    kind, parent, asm, J, U, C = inst
    def base(c):
        A = []
        while kind[c] == "SUP": A.append(asm[c]); c = parent[c]
        return c, tuple(A)
    Js = []
    for (c, G, f) in J:
        b, A = base(c); Js.append((b, G + A, f))
    anc = {0} | set(C); ch = True
    while ch:
        ch = False
        for (c, k, t) in U:
            if informative(k) and parent[c] in anc and c not in anc: anc.add(c); ch = True
    for c in anc:
        if not any(all((not all(ATOMS[g](v) for g in G)) or ATOMS[f](v) for (cc, G, f) in Js if cc == c) for v in VALS): return False
    return True
if __name__ == "__main__":
    rng = random.Random(int(sys.argv[1]) if len(sys.argv) > 1 else 11)
    N = int(sys.argv[2]) if len(sys.argv) > 2 else 400
    mism = real = 0
    for i in range(N):
        inst = rand_inst(rng); b = brute(inst); cr = criterion(inst); real += b
        if b != cr:
            mism += 1; print("MISMATCH", inst, b, cr)
            if mism > 3: break
    print(f"N={N} realizable={real} mismatches={mism}")
