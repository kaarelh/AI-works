"""Independent stress test of T3 Prop 2.7 and Thm 2.4(b) (frame semantics, limit semantics).
Richer than realizability_frame.py: Lambda a random proper subset of {0,1,2}x{0,1}; ideal values may leave Lambda;
deeper trees; SUP chains; Gamma up to size 2; sigma atoms mentioning parameters."""
import itertools, random, sys

P1 = (0, 1, 2); P2 = (0, 1); QV = (0, 1, 2)
ALLPTS = [(x, y) for x in P1 for y in P2]
def atom(name):
    k, v = name.split(":")
    if k == "T": return lambda s: True
    if k == "F": return lambda s: False
    if k == "p1": return lambda s, v=int(v): s[0] == v
    if k == "p1!": return lambda s, v=int(v): s[0] != v
    if k == "p2": return lambda s, v=int(v): s[1] == v
    if k == "Q": return lambda s, v=int(v): s[2] == v
    if k == "Q!": return lambda s, v=int(v): s[2] != v
    if k == "Qle": return lambda s, v=int(v): s[2] <= v
    if k == "Qnear": return lambda s, v=int(v): abs(s[2] - v) <= 1
    if k == "Qp1": return lambda s, v=int(v): s[2] == (s[0] + v) % 3
    raise ValueError(name)
ATOMS = ["T:0", "F:0"] + [f"p1:{v}" for v in P1] + [f"p1!:{v}" for v in P1] + [f"p2:{v}" for v in P2] + \
        [f"Q:{v}" for v in QV] + [f"Q!:{v}" for v in QV] + [f"Qle:{v}" for v in QV]
F = {a: atom(a) for a in ATOMS + [f"Qnear:{v}" for v in QV] + [f"Qp1:{v}" for v in QV]}
STRUCTS = [(x, y, q) for x in P1 for y in P2 for q in QV]
# bridge kinds: (eps family, sigma). eps(t) is a function name prefix applied to t
EPS = {"eq": lambda t: f"Q:{t}", "near": lambda t: f"Qnear:{t}", "shift": lambda t: f"Qp1:{t}"}
SIG = ["T:0", "p1:1", "p2:0", "Q!:1", "p1!:0"]
def informative(e, s):
    # finite V0 = whole V (finite) -- exists finite unsat subset iff whole set unsat
    return not any(F[s](x) and all(F[EPS[e](v)](x) for v in QV) for x in STRUCTS)
BK = [(e, s) for e in EPS for s in SIG if informative(e, s)]

def rand_inst(rng):
    lam = [p for p in ALLPTS if rng.random() < 0.7] or [rng.choice(ALLPTS)]
    nd = rng.randint(1, 4); ns = rng.randint(0, 3)
    kind = {0: "ROOT"}; par = {}; decl = {}
    for i in range(1, nd + 1):
        kind[i] = "DEF"; par[i] = rng.randrange(0, i)
        D = rng.choice([(0,), (1,), (0, 1)])
        decl[i] = {d: rng.choice(P1 if d == 0 else P2) for d in D}
    for j in range(nd + 1, nd + 1 + ns):
        kind[j] = "SUP"; par[j] = rng.randrange(0, j)
    asm = {j: rng.choice(ATOMS) for j in kind if kind[j] == "SUP"}
    J = []
    for _ in range(rng.randint(1, 7)):
        c = rng.choice(list(kind))
        G = tuple(rng.sample(ATOMS, rng.choice([0, 0, 1, 2])))
        J.append((c, G, rng.choice(ATOMS)))
    U = []
    for c in range(1, nd + 1):
        for _ in range(rng.choice([0, 0, 1, 1, 2])):
            e, s = rng.choice(BK); t = rng.choice(QV); p = par[c]
            U.append((c, (e, s), t)); J += [(c, (), f"Q:{t}"), (p, (), s), (p, (), EPS[e](t))]
    C = {c for c in range(1, nd + 1) if rng.random() < 0.3}
    return lam, kind, par, decl, asm, J, U, C

def base(inst, c):
    lam, kind, par, decl, asm, J, U, C = inst
    A = []
    while kind[c] == "SUP":
        A.append(asm[c]); c = par[c]
    return c, tuple(A)

def collapsed(inst):
    return [(*base(inst, c)[:1], G + base(inst, c)[1], f) for (c, G, f) in inst[5]]

def hold(s, G, f): return (not all(F[g](s) for g in G)) or F[f](s)

def pts(inst, l):
    lam, kind, par, decl = inst[:4]
    pt = {0: l}
    for c in sorted(kind):
        if kind[c] == "DEF":
            x = list(pt[par[c]])
            for d, v in decl[c].items(): x[d] = v
            pt[c] = tuple(x)
    return pt

def frame_real(inst):
    lam, kind, par, decl, asm, J, U, C = inst
    Js = collapsed(inst)
    for assign in itertools.product([None] + list(QV), repeat=len(lam)):
        Fr = {p: q for p, q in zip(lam, assign) if q is not None}
        for l in Fr:
            pt = pts(inst, l); prop = {0: True}
            for c in sorted(kind):
                if kind[c] == "DEF": prop[c] = prop[par[c]] and pt[c] in Fr
            if any(not prop[c] for c in C): continue
            st = {c: (pt[c][0], pt[c][1], Fr[pt[c]]) for c in prop if prop[c]}
            if not all(hold(st[b], G, f) for (b, G, f) in Js if prop[b]): continue
            ok = True
            for (c, (e, s), t) in U:
                p = par[c]
                if not prop[p]: continue
                vs = [st[c][2]] if prop[c] else QV
                if not all(hold(st[p], (s,), EPS[e](v)) for v in vs): ok = False; break
            if ok: return True
    return False

def crit24(inst):
    lam, kind, par, decl, asm, J, U, C = inst
    anc = {0} | set(C); ch = True
    while ch:
        ch = False
        for (c, k, t) in U:
            if par[c] in anc and c not in anc: anc.add(c); ch = True
    Js = collapsed(inst)
    return all(any(all(hold(s, G, f) for (b, G, f) in Js if b == c) for s in STRUCTS) for c in anc)

def crit27(inst):
    lam, kind, par, decl, asm, J, U, C = inst
    Js = collapsed(inst); nonsup = [c for c in kind if kind[c] != "SUP"]
    for l in lam:
        pt = pts(inst, l); S = {0} | set(C); ch = True
        while ch:
            ch = False
            for c in list(S):
                if c != 0 and par[c] not in S: S.add(par[c]); ch = True
            for (c, k, t) in U:
                if par[c] in S and c not in S: S.add(c); ch = True
            P = {pt[c] for c in S}
            for c in nonsup:
                if c != 0 and c not in S and par[c] in S and pt[c] in P: S.add(c); ch = True
        good = True
        for x in {pt[c] for c in S}:
            if x not in lam: good = False; break
            cs = [c for c in S if pt[c] == x]
            if not any(all(hold((x[0], x[1], q), G, f) for (b, G, f) in Js if b in cs) for q in QV):
                good = False; break
        if good: return True
    return False

if __name__ == "__main__":
    rng = random.Random(int(sys.argv[1])); N = int(sys.argv[2])
    fr_n = nec = mis = gap = outside = 0
    for i in range(N):
        inst = rand_inst(rng)
        lam = inst[0]
        if any(p not in lam for l in lam for p in pts(inst, l).values()): outside += 1
        fr = frame_real(inst); c24 = crit24(inst); c27 = crit27(inst)
        fr_n += fr
        if fr and not c24: nec += 1; print("NEC VIOLATION", inst)
        if fr != c27: mis += 1; print("2.7 MISMATCH", fr, c27, inst)
        if c24 and not fr: gap += 1
    print(f"N={N} frame-real={fr_n} nec-viol={nec} prop27-mismatch={mis} gap={gap} inst-with-points-outside-Lambda={outside}")
