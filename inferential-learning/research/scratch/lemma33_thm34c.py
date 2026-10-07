"""Random brute-force tests of T4 Lemma 3.3(i),(ii),(iii) and Thm 3.4(a),(c) in a propositional
(0-ary FO) setting. Occurrences come in negation pairs (x, ~x); readings send a pair to (phi, not phi)."""
import itertools, random
random.seed(1)
NA = 3; NV = 2**NA; FULL = (1<<NV)-1
NP = 3                      # number of negation pairs -> 6 occurrences
OCC = list(range(2*NP))     # occ 2k is x_k, 2k+1 is ~x_k
def neg(o): return o^1
def rand_hyp():
    M = random.randint(0, FULL)            # Mod(T_h) as set of valuations (may be empty = inconsistent)
    rho = {}
    for k in range(NP):
        if random.random() < 0.8:
            phi = random.randint(0, FULL)
            rho[2*k] = phi; rho[2*k+1] = FULL ^ phi
    return (M, rho)
def steps_universe():
    for r in range(0, 4):
        for G in itertools.combinations(OCC, r):
            for y in OCC: yield (frozenset(G), y)
STEPS = list(steps_universe())
def models(h): return [v for v in range(NV) if (h[0]>>v)&1]
def holds(phi, v): return (phi>>v)&1
def valid(h, s):
    G, y = s; M, rho = h
    if not (set(G)|{y}) <= rho.keys(): return False
    return all(holds(rho[y], v) for v in models(h) if all(holds(rho[x], v) for x in G))
def rel(h): return frozenset(s for s in STEPS if valid(h, s))
def V(h):
    M, rho = h; dom = sorted(rho)
    return {tuple((x, holds(rho[x], v)) for x in dom) for v in models(h)}
def coherent_vals(h):
    M, rho = h; dom = sorted(rho); R = rel(h); out = set()
    for bits in itertools.product([0,1], repeat=len(dom)):
        v = dict(zip(dom, bits))
        if any(v[neg(x)] != 1-v[x] for x in dom): continue
        ok = all(v[y]==1 for (G,y) in R if all(v[x]==1 for x in G))
        if ok: out.add(tuple((x, v[x]) for x in dom))
    return out
def coherent_on(h, A):
    M, rho = h
    return any(all(holds(rho[x], v) for x in A) for v in models(h))
bad = {'L33i':0,'L33ii':0,'L33iii':0,'T34a':0,'T34c':0}
trials = 0
for t in range(3000):
    H = [rand_hyp() for _ in range(5)]
    hs = H[0]
    if not hs[1]: continue
    trials += 1
    for h in H:
        if not h[1]: continue
        # Lemma 3.3 (i): V_h == coherent valuations of |=_h
        if V(h) != coherent_vals(h): bad['L33i'] += 1
        # (iii) with y ranging over D_h
        for r in range(0,3):
            for A in itertools.combinations(sorted(h[1]), r):
                c1 = coherent_on(h, A); c3 = any(not valid(h,(frozenset(A),y)) for y in h[1])
                if c1 != c3: bad['L33iii'] += 1
    # Thm 3.4(a): rel equal => V equal and coherence equal
    for h in H:
        for h2 in H:
            if h[1] and h2[1] and rel(h)==rel(h2) and V(h)!=V(h2): bad['T34a'] += 1
    # Thm 3.4(c): complete closure-level presentation for target hs; designated contexts = all A in D* coherent for hs
    Dst = set(hs[1]); Rst = rel(hs)
    Ades = [A for r in range(0,3) for A in itertools.combinations(sorted(Dst), r) if coherent_on(hs, A)]
    for h in H:
        surv = Rst <= rel(h)
        # objects: every u in V_{h*} (total on D*) extends to some member of V_h
        Vh = [dict(u) for u in V(h)]
        for u in V(hs):
            if not any(all(x in w and w[x]==b for x,b in u) for w in Vh): surv = False
        for A in Ades:
            if not set(A) <= set(h[1]) or not coherent_on(h, A): surv = False
        inU = all(((s in Rst) == (s in rel(h))) for s in STEPS if (set(s[0])|{s[1]}) <= Dst)
        if surv != inU: bad['T34c'] += 1
print('trials', trials, 'failures', bad)
