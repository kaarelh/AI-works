# Referee C, r8: cross-check of covering-template COUNTS between the independent enumerator and the
# authors' outputs (same bounds: size <= 14, args <= 3, formula arity <= 2, term arity <= 1).
from rc_core import *
from rc_enum import enum_covering
x = V(0)
s1 = AND(ALL(EQ(x, Z())), AND(ALL(EQ(x, x)), EQ(Z(), Z())))
s2 = AND(ALL(NOT(EQ(x, Z()))), AND(ALL(NOT(EQ(x, x))), NOT(EQ(Z(), Z()))))
A = enum_covering([s1, s2], 14, amax=3, ar_F=(0, 1, 2), ar_T=(0, 1))
print('C8.1 data: SO° covering templates %d (authors c4: 7241), determinate %d (authors: 11)' % (len(A), sum(map(is_DT, A))))
B = enum_covering([Ind(EQ(X, X)), Ind(NOT(EQ(X, Z())))], 14, amax=3, ar_F=(0, 1, 2), ar_T=(0, 1))
print('anchor pair: SO° covering %d (authors c2: 26 + 7777 = 7803), determinate %d (authors: 26)' % (len(B), sum(map(is_DT, B))))
