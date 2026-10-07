"""Brute-force check of T4 Thm 3.4(d) survivor characterization.
Propositional (0-ary-predicate first-order) hypotheses sharing one reading rho.
Calculus R_h = {one-step 'Taut' library: Pi |- phi whenever Pi |= phi tautologically}
              + {0-premise axiom steps |- tau for tau in T_h}.
Both are first-order complete: Cl_{R_h}(G) = {phi : T_h u G |= phi}.
g-steps: min #rule applications = 0 if rho(y) in rho(G); 1 if rho(y) in T_h or G |= y;
         else 1 + min |S| (S subset T_h) with G u S |= y.
"""
import itertools
N = 4  # atoms p0..p3
atoms = range(N)
vals = list(itertools.product([0,1], repeat=N))
# formulas as python functions + names
def lit(i, pos=True): return (('p%d'%i) if pos else ('~p%d'%i), (lambda v,i=i,pos=pos: v[i]==(1 if pos else 0)))
def imp(i,j): return ('p%d->p%d'%(i,j), lambda v,i=i,j=j: (not v[i]) or v[j])
# informal domain D*: occurrences reading as p0, ~p0, p3, ~p3 (negation-closed by toggling)
D = [lit(i,b) for i in range(4) for b in (True,False)]
chain = [imp(0,1), imp(1,2), imp(2,3)]
def models(T): return [v for v in vals if all(f(v) for _,f in T)]
def entails(T, G, y):
    return all(y[1](v) for v in models(list(T)+list(G)))
def steps():
    for r in range(0, 3):
        for G in itertools.combinations(range(len(D)), r):
            for y in range(len(D)):
                yield (G, y)
def valid(T, s):
    G, y = s
    return entails(T, [D[i] for i in G], D[y])
def gvalid(T, s, g):
    G, y = s
    Gf = [D[i] for i in G]
    if y in G: return True
    if g < 1: return False
    if entails([], Gf, D[y]): return True       # one Taut step
    for k in range(1, g):                         # k axioms + 1 Taut step
        for S in itertools.combinations(T, k):
            if entails(S, Gf, D[y]): return True
    return False
def V(T):
    return {tuple(int(f(v)) for _,f in D) for v in models(T)}
S_all = list(steps())
hyps = [list(c) for r in range(len(chain)+1) for c in itertools.combinations(chain, r)]
names = lambda T: '{'+','.join(n for n,_ in T)+'}'
for g in [2,3]:
    bad = []
    for Ts in hyps:
        for Th in hyps:
            st_s = {s for s in S_all if gvalid(Ts, s, g)}
            st_h = {s for s in S_all if gvalid(Th, s, g)}
            vd_s = {s for s in S_all if valid(Ts, s)}
            vd_h = {s for s in S_all if valid(Th, s)}
            survives = st_s <= st_h and V(Ts) <= V(Th)   # practice + complete object presentation (finite D)
            # designated contexts: none needed (all hyps consistent); adding A={p0} etc. changes nothing
            claimed = (vd_s == vd_h) and st_s <= st_h
            if survives != claimed:
                bad.append((names(Ts), names(Th), survives, claimed, sorted(vd_s - vd_h)))
    print('g=%d: mismatches between actual survivors and Thm 3.4(d) characterization: %d' % (g, len(bad)))
    for b in bad[:3]:
        print('   target', b[0], ' rival', b[1], ' survives', b[2], ' claimed', b[3], ' steps valid for target but not rival:',
              [([D[i][0] for i in G], D[y][0]) for G,y in b[4]][:3])
