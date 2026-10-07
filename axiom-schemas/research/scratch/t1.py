import sys; sys.path.insert(0,'/home/user/AI-works/axiom-schemas/research/tracks/untagged/code')
from dtlib import *
X = H(0); y = V(0)
mot = {'x=x': eq(X,X), '0=x': eq(Z,X), 'x=0': eq(X,Z), 'Sx=0': eq(S(X),Z), 'x+0=x': eq(add(X,Z),X),
       '~x=0': NOT(eq(X,Z)), '0+x=x': eq(add(Z,X),X), 'S0+x=Sx': eq(add(S(Z),X),S(X))}
for a,b in [('x=x','~x=0'),('x=x','x+0=x'),('x=x','0=x'),('x=0','Sx=0'),('0+x=x','S0+x=Sx')]:
    D = [Ind(mot[a]), Ind(mot[b])]
    ms = mincov(D)
    print(a, '|', b, '->', len(ms))
    for T in ms:
        print('   ', pp(T), ' <=T_ind?', subsumes(T_IND, T), ' >=T_ind?', subsumes(T, T_IND))
# C8.1 non-unitary
s1 = AND(ALL(eq(V(0),Z)), AND(ALL(eq(V(0),V(0))), eq(Z,Z)))
s2 = AND(ALL(NOT(eq(V(0),Z))), AND(ALL(NOT(eq(V(0),V(0)))), NOT(eq(Z,Z))))
for T in mincov([s1,s2]): print('C8.1', pp(T))
print(match(T_IND, Ind(mot['x+0=x'])))
