# Referee C, r6: SOCL's enumeration (derived fillers with a FIXED argument tuple u, no metavariables
# inside arguments) is incomplete for DT, and the resulting verifier can be UNSOUND for a target in DT.
#   target  T* = Ax(f(x)=f(x)) & (f(f(0)) = f(f(0)))          (determinate: f(x) is a pattern occurrence)
#   data    f := lambda z. Sz   ->  Ax(Sx=Sx) & (SS0=SS0)
#           f := lambda z. z+0  ->  Ax(x+0=x+0) & ((0+0)+0=(0+0)+0)
#   query   q = Ax(Sx=Sx) & (0=0)   not in inst(T*)
# (1) independent code: q lies in every DT° covering template of size <= 16 (so in Acc_SOCL),
#     but T* is in VS_DT(D) and misses q (so the true DT-cautious verifier rejects q).
# (2) the authors' own enumerator + is_determinate + minimal (c6) gives Min(D) all of which accept q.
import sys
from rc_core import *
from rc_enum import enum_covering
def f(t): return MV('f', t)
x = V(0)
Tstar = AND(ALL(EQ(f(x), f(x))), EQ(f(f(Z())), f(f(Z()))))
D = [instantiate(Tstar, {'f': S(HOLE(0))}), instantiate(Tstar, {'f': ADD(HOLE(0), Z())})]
q = AND(ALL(EQ(S(x), S(x))), EQ(Z(), Z()))
print('T* =', pp(Tstar), ' DT:', is_DT(Tstar), ' SO°:', is_SO(Tstar))
print('data:', [pp(d) for d in D], ' covered by T*:', [det_match(Tstar, d) is not None for d in D])
print('q =', pp(q), ' in inst(T*):', det_match(Tstar, q) is not None)
Ts = [T for T in enum_covering(D, 16, amax=3, ar_F=(0, 1), ar_T=(0, 1)) if is_DT(T)]
print('(1) DT° covering templates of D (size <= 16, args <= 3): %d; all contain q: %s'
      % (len(Ts), all(det_match(T, q) is not None for T in Ts)))
mins = [T for T in Ts if not any(geq(T, U) and not geq(U, T) for U in Ts)]
print('    minimal ones:', [pp(T) for T in mins])

sys.path.insert(0, '..')
import so_core as sc, so_enum as se
def conv(t, depth=0):
    # level-based -> authors' index-based representation
    h = t[0]
    if h == 'v': return ('v', depth - 1 - t[1])
    if h == '0': return ('0',)
    m = {'S': 'S', '+': 'add', '=': 'eq', '&': 'and', 'A': 'all'}
    if h == 'A': return ('all', conv(t[1], depth + 1))
    return (m[h],) + tuple(conv(c, depth) for c in children(t))
Dau = [conv(d) for d in D]; qau = conv(q)
F = se.enumerate_covering(Dau, 16, amax=3, maxar=2, arities_T=(0, 1), arities_F=(0, 1, 2))
DTau = [T for T in F if sc.is_determinate(T)]
mins_au = []
for T in DTau:
    if not any(sc.subsumes(T, U) and not sc.subsumes(U, T) for U in DTau):
        if not any(sc.subsumes(T, U) and sc.subsumes(U, T) for U in mins_au): mins_au.append(T)
print('(2) authors\' enumerator: %d determinate covering templates; Min(D) =' % len(DTau),
      [sc.pp(T) for T in mins_au])
print('    SOCL accepts q (q in inst(T) for all T in Min(D)):', all(sc.covers(T, qau) for T in mins_au))
