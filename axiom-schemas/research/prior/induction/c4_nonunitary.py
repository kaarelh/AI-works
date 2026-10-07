# C4: determinate second-order templates are not unitary: a two-element set with two incomparable
# minimal covering templates and no least general one.
from so_core import *
from so_enum import enumerate_covering

def sent(a, b, g):     # (Ax a) & ((Ax b) & g),  a, b motive bodies (hole = x), g closed
    return AND(ALL(plug(a, [V(0)])), AND(ALL(plug(b, [V(0)])), g))
s1 = sent(eq(X, Z), eq(X, X), eq(Z, Z))
s2 = sent(NOT(eq(X, Z)), NOT(eq(X, X)), NOT(eq(Z, Z)))
D = [s1, s2]
print('D =', pp(s1), ';', pp(s2))
F = enumerate_covering(D, 14, amax=3, maxar=2)
DT = [T for T in F if is_determinate(T)]
print('SO° covering templates (size <= 14): %d, determinate: %d' % (len(F), len(DT)))
def minimal(Ts):
    out = []
    for T in Ts:
        if not any(subsumes(T, U) and not subsumes(U, T) for U in Ts):
            out.append(T)
    return out
mDT = minimal(DT)
print('minimal determinate covering templates (subsumption order):')
for T in mDT: print('   ', size(T), pp(T))
G1 = canon(AND(ALL(M('P', V(0))), AND(ALL(M('Q', V(0))), M('P', Z))))
G2 = canon(AND(ALL(M('P', V(0))), AND(ALL(M('Q', V(0))), M('Q', Z))))
print('they are G1, G2:', set(mDT) == {G1, G2})
print('every determinate covering template is >= G1 or >= G2:', all(subsumes(T, G1) or subsumes(T, G2) for T in DT))
w1 = sent(eq(X, Z), eq(X, S(Z)), eq(Z, Z))      # in G1 only
w2 = sent(eq(X, S(Z)), eq(X, Z), eq(Z, Z))      # in G2 only
print('w1 =', pp(w1), ' in G1:', covers(G1, w1), ' in G2:', covers(G2, w1))
print('w2 =', pp(w2), ' in G1:', covers(G1, w2), ' in G2:', covers(G2, w2))
mF = minimal(F)
print('minimal templates among ALL SO° covering templates (incl. non-determinate): %d' % len(mF))
for T in mF: print('   ', size(T), pp(T), ' determinate' if is_determinate(T) else ' non-determinate')
# does any covering SO° template lie inside inst(G1) ∩ inst(G2)?  (it would have to be <= both)
inside = [T for T in F if subsumes(G1, T) and subsumes(G2, T)]
print('covering SO° templates below both G1 and G2:', len(inside))
if len(mF) == 2:
    a, b = mF
    print('the two minimal SO° templates are equivalent (mutual subsumption):', subsumes(a, b) and subsumes(b, a))
    print('they lie strictly below G1 and G2:', all(subsumes(G, T) and not subsumes(T, G) for G in (G1, G2) for T in mF))
