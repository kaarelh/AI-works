# R9: P9(d) guard learning on canonical Metamath-style data (Lemma setting:guard: keep guards true on all data).
import random
from rcore import *
r = random.Random(12)
X, Y = 'x', 'y'
def canon_mm(phi):  # canonical: psi = phi[0/x], chi = phi[y/x], th = phi[Sy/x], y not occurring in phi
    return dict(phi=phi, psi=sb(phi, X, ZERO), chi=sb(phi, X, K(Y)), th=sb(phi, X, S_(K(Y))))
def occurs(v, f):
    if is_ov(f): return f[0] == v
    return any(occurs(v, a) for a in f[1:]) if len(f) > 1 else False
data = []
while len(data) < 200:
    phi = rform(r, r.randint(0, 3), ['x', 'z', 'n'])
    if occurs('y', phi): continue
    if not free_for(phi, X, K(Y)): continue
    data.append(canon_mm(phi))
fam = {f'{v} notfree {M}': (lambda d, v=v, M=M: v not in fv(d[M])) for v in (X, Y) for M in ('phi', 'psi', 'chi', 'th')}
learned = [g for g, f in fam.items() if all(f(d) for d in data)]
print('guards true on all 200 canonical records:', learned)
# one non-canonical but valid use: psi := phi[0/x] & y = y
d = data[0]; d2 = dict(d); d2['psi'] = ('and', d['psi'], ('eq', K(Y), K(Y)))
print('after one non-canonical record (psi := phi[0/x] & y=y):', [g for g, f in fam.items() if all(f(e) for e in data + [d2])])
