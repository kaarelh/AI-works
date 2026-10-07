# e2: worked examples for Theorems B, F, G.
#  (1) DT° version of the referee's infinite-antichain data {Ind(x=x), Ind(0=x)}: Min(D) is finite
#      (Theorem B); list it; compare with the bounded brute-force enumerator.
#  (2) |Min(D)| = 4^n for D_n = {Ax(x=x) & C_n, Ax(0=0) & C_n}, C_n = n copies of 0=0 (Prop. G2).
#  (3) infinite thickness: s = Ax(0=0) & 0=0 lies in inst(Ax P(x) & P(t)) for every closed t, and
#      these instance sets are pairwise different.
#  (4) the counterexample to "(R*)&(N)&(U_pat)" (Prop. D4) and to "(R)&(N)&(D)" (Prop. D5).
import time
from dtcore import *
from dtfeat import Prefix
from dtenum import enumerate_covering, minimal_elements
from dtwitness import events
X, Y = H(0), H(1)

print('(1) D = {Ind(x=x), Ind(0=x)}')
D = [Ind(eq(X, X)), Ind(eq(Z, X))]
P = Prefix(D)
mins, reps = P.minimal()
print('    |Sat(D)| (up to equivalence) =', len(reps), '  |Min(D)| =', len(mins), '  lgg exists:', P.lgg_exists()[0])
for m in mins:
    print('      ', pp(m), '   <= T_ind?', subsumes(T_IND, m))
t = time.time()
E = enumerate_covering(D, 24, amax=2, arities_T=(0, 1), arities_F=(0, 1), consts=('0',), funcs=(('S', 1), ('add', 2)))
m2, _ = minimal_elements(E)
print('    brute force (size<=24, args<=2): %d covering DT° templates, %d minimal, same set: %s, every enumerated template above a Sat-minimal one: %s  (%.0fs)' % (
    len(E), len(m2), len(m2) == len(mins) and all(any(equivalent(a, b) for b in mins) for a in m2),
    all(any(subsumes(U, mm) for mm in mins) for U in E), time.time() - t))
E23 = [U for U in E if size(U) <= 23]
m23, _ = minimal_elements(E23)
print('    restricted to size<=23 (the prior bound): %d minimal (prior C8.2 reported 8); not truly minimal (artifacts of the bound): %d' % (len(m23), sum(1 for U in m23 if not any(equivalent(U, mm) for mm in mins))))
print('    acceptance after D: Ind(f(x)=x)-type queries')
for phi in [eq(add(X, Z), X), eq(S(X), X), eq(X, S(X)), eq(Z, Z), eq(add(Z, X), X)]:
    print('      ', pp(Ind(phi)), P.accepts(Ind(phi)))

print('(2) exponentially many minimal templates')
for n in range(1, 7):
    c = eq(Z, Z)
    for _ in range(n - 1):
        c = AND(c, eq(Z, Z))
    Dn = [AND(ALL(eq(V(0), V(0))), c), AND(ALL(eq(Z, Z)), c)]
    Pn = Prefix(Dn)
    t = time.time()
    if n <= 3:
        mins, reps = Pn.minimal()
        nm = len(mins)
    else:
        nm = None
    print('    n=%d  |D|=%d  #equation features=%d  |Min(D)|=%s  lgg exists: %s  (%.1fs)' % (
        n, sum(size(d) for d in Dn), len(Pn.eq_features()), nm, Pn.lgg_exists()[0], time.time() - t))

print('(3) infinite thickness')
s = AND(ALL(eq(Z, Z)), eq(Z, Z))
ts = [Z, S(Z), add(Z, Z), PA, S(S(Z))]
Tt = [AND(ALL(M('P', V(0))), M('P', t)) for t in ts]
print('    s =', pp(s), ' covered by', [pp(T) for T in Tt], ':', [covers(T, s) for T in Tt])
w = [instantiate(T, {'P': eq(X, X)}) for T in Tt]
print('    separating instances (P = z=z):', [[covers(T, x) for x in w] for T in Tt])

print('(4a) Prop. D4: (R*),(N),(D),(U_pat) hold but D is not an anchor')
Tu = AND(ALL(ALL(eq(S(M('f', V(1), V(0))), Z))), ALL(ALL(eq(M('f', V(1), S(V(0))), Z))))
ths = [{'f': X}, {'f': Y}, {'f': S(X)}]
ev, Du = events(Tu, ths)
print('    T* =', pp(Tu))
for d in Du:
    print('      datum', pp(d))
print('    events:', {k: ev[k] for k in ('R*', 'R', 'N', 'D', 'Upat', 'U')})
Pu = Prefix(Du)
q = instantiate(Tu, {'f': Z})
print('    q = T*[f:=0] =', pp(q), ' in Acc(D):', Pu.accepts(q), ' violated:', Pu.which_fail(q))
print('    minimal covering templates:', [pp(m) for m in Pu.minimal()[0]])

print('(4b) Prop. D5: (R),(N),(D) hold, (R*) holds, but a coincidence with a rigid position')
Tv = AND(eq(S(Z), Z), ALL(ALL(AND(eq(M('f', V(1)), V(0)), eq(V(0), M('f', PA))))))
ths = [{'f': Z}, {'f': X}]
ev, Dv = events(Tv, ths)
print('    T* =', pp(Tv))
for d in Dv:
    print('      datum', pp(d))
print('    events:', {k: ev[k] for k in ('R*', 'R', 'N', 'D', 'Upat', 'U')}, ' witnesses:', ev['Uwit'])
Pv = Prefix(Dv)
q = instantiate(Tv, {'f': S(X)})
print('    q = T*[f:=Sz] =', pp(q), ' in Acc(D):', Pv.accepts(q))
print('    minimal covering templates:', [pp(m) for m in Pv.minimal()[0]])

print('(4c) all-projection coincidence: f(x,y) values z1, z2 vs a rigid bound variable')
Tw = AND(ALL(ALL(eq(M('f', V(1), V(0)), Z))), ALL(eq(V(0), Z)))
ths = [{'f': X}, {'f': Y}]
ev, Dw = events(Tw, ths)
print('    T* =', pp(Tw), ' data:', [pp(d) for d in Dw])
print('    events:', {k: ev[k] for k in ('R*', 'R', 'N', 'D', 'Upat', 'U')})
print('    minimal covering templates:', [pp(m) for m in Prefix(Dw).minimal()[0]])
