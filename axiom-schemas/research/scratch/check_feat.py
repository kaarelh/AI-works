import sys
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/single')
from dtcore import *
from dtfeat import Prefix
from dtwitness import events, anchor_by_features
D = [eq(add(Z, Z), Z), eq(add(S(Z), Z), S(Z))]
P = Prefix(D)
print('C', sorted(P.C)); print('slots', sorted(P.slots), 'Y', P.Y)
print('eq features', P.eq_features())
for q in [eq(add(S(S(Z)),Z),S(S(Z))), eq(add(PA,Z),PA), eq(add(Z,Z),S(Z)), eq(add(S(Z),Z),Z)]:
    print(pp(q), P.accepts(q))
T = eq(add(M('z'), Z), M('z'))
print(anchor_by_features(T, D))
# (U) example
T2 = ALL(eq(Z, M('f', V(0))))
D2 = [ALL(eq(Z, Z)), ALL(eq(Z, V(0)))]
P2 = Prefix(D2)
print('eq2', P2.eq_features())
print(P2.accepts(ALL(eq(Z, S(V(0))))))
