# R5: P9 (Metamath-style encoding).  (b) sufficiency tested EXACTLY in finite structures that satisfy the full
# induction schema (Z/N and rho_N, all definable sets), necessity counterexamples re-checked; (c) anchors.
import random, itertools
from rcore import *
r = random.Random(9)
def zmod(N): return lambda v: v % N
def rho(N):   # 0 -> 1 -> ... -> N-1 -> 1 ; quotient of N by n~m iff n=m or (n,m>=1 and n=m mod N-1)
    return lambda v: v if v < N else 1 + (v - 1) % (N - 1)
STRUCTS = [(f'Z/{N}', range(N), zmod(N)) for N in (2, 3, 4, 5)] + [(f'rho{N}', range(N), rho(N)) for N in (3, 4, 5)]
def holds(f, st):
    name, dom, mod = st
    return closure_true(f, dom, mod=mod)
X, Y = K('x'), K('y')
def prem(phi, psi, chi, th):
    return [('imp', ('eq', X, ZERO), ('iff', phi, psi)), ('imp', ('eq', X, Y), ('iff', phi, chi)),
            ('imp', ('eq', X, S_(Y)), ('iff', phi, th)), psi, ('imp', chi, th)]
def rf(vs, d=2): return rform(r, d, vs)
found = {}
tested = {}
for trial in range(60000):
    # biased construction: start from canonical, then perturb some components
    phi = rf(['x', 'z'], r.randint(0, 2))
    psi = sb(phi, 'x', ZERO) if r.random() < .5 else rf(['x', 'y', 'z'], 1)
    chi = sb(phi, 'x', Y) if r.random() < .5 else rf(['x', 'y', 'z'], 1)
    th = sb(phi, 'x', S_(Y)) if r.random() < .5 else rf(['x', 'y', 'z'], 1)
    if r.random() < 0.3: phi = rf(['x', 'y', 'z'], r.randint(0, 2))   # may violate y notin phi
    g = {'yphi': 'y' not in fv(phi), 'xchi': 'x' not in fv(chi), 'xth': 'x' not in fv(th), 'xpsi': 'x' not in fv(psi)}
    for st in STRUCTS:
        if all(holds(h, st) for h in prem(phi, psi, chi, th)):
            key = (g['yphi'], g['xchi'] or g['xth'])
            tested[key] = tested.get(key, 0) + 1
            if not holds(phi, st):
                found.setdefault(key, (st[0], phi, psi, chi, th))
print('instances with all premises true in an induction-satisfying finite structure, by (y notin phi, x notin chi or x notin th):', tested)
print('counterexamples found, by the same key:')
for k, v in found.items(): print('  ', k, v)
print('-> sufficiency of {y notin phi, (x notin chi or x notin th)} predicts NO counterexample under key (True, True)')
# necessity counterexamples in N (hand check + bounded check)
def cex_check(phi, psi, chi, th, B=40):
    ok = all(closure_true(h, range(B), freedom=range(12)) for h in prem(phi, psi, chi, th))
    return ok, closure_true(phi, range(B), freedom=range(12))
SSy = S_(S_(Y))
print('cex1 (violates only y notin phi): premises true (bounded), conclusion true?',
      cex_check(('not', ('eq', X, SSy)), ('not', ('eq', ZERO, SSy)), ('not', ('eq', Y, SSy)), ('not', ('eq', S_(Y), SSy))))
print('cex2 (violates only x notin chi and x notin th):',
      cex_check(('eq', X, ZERO), ('eq', ZERO, ZERO), ('eq', X, ZERO), ('eq', X, ZERO)))
# (c) anchors for canonical data, x,y fixed
def mm(phi):
    return ('st', ('der', ('imp', ('eq', X, ZERO), ('iff', phi, sb(phi, 'x', ZERO)))),
                  ('der', ('imp', ('eq', X, Y), ('iff', phi, sb(phi, 'x', Y)))),
                  ('der', ('imp', ('eq', X, S_(Y)), ('iff', phi, sb(phi, 'x', S_(Y))))),
                  ('der', sb(phi, 'x', ZERO)), ('der', ('imp', sb(phi, 'x', Y), sb(phi, 'x', S_(Y)))), ('der', phi))
V = lambda s: ('?', s)
SIG_MM = ('st', ('der', ('imp', ('eq', X, ZERO), ('iff', V('f'), V('p')))), ('der', ('imp', ('eq', X, Y), ('iff', V('f'), V('c')))),
          ('der', ('imp', ('eq', X, S_(Y)), ('iff', V('f'), V('t')))), ('der', V('p')), ('der', ('imp', V('c'), V('t'))), ('der', V('f')))
mmis = 0; tot = 0
for _ in range(20000):
    ph = [rform(r, r.randint(0, 3), ['x', 'z', 'n']) if r.random() < .7 else ('eq', rterm(r, 2, ['x', 'z']), rterm(r, 2, ['x'])) for _ in range(r.randint(1, 4))]
    L = au([mm(p) for p in ph]); tot += 1
    cond = len({p[0] for p in ph}) > 1 and any('x' in fv(p) for p in ph)
    mmis += variant(L, SIG_MM) != cond
print(f'E3 canonical anchors, {tot} random sets: mismatches with (roots differ & some x free) = {mmis}')
