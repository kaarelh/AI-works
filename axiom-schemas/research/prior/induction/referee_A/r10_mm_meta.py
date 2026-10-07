# R10: P9(c) with X, Y metavariables: lgg == pattern iff roots differ & some motive has its x free & the X column
# varies & the Y column varies.
import random
from rcore import *
r = random.Random(21)
def mm(phi, xv, yv):
    X, Y = K(xv), K(yv)
    return ('st', ('der', ('imp', ('eq', X, ZERO), ('iff', phi, sb(phi, xv, ZERO)))),
                  ('der', ('imp', ('eq', X, Y), ('iff', phi, sb(phi, xv, Y)))),
                  ('der', ('imp', ('eq', X, S_(Y)), ('iff', phi, sb(phi, xv, S_(Y))))),
                  ('der', sb(phi, xv, ZERO)), ('der', ('imp', sb(phi, xv, Y), sb(phi, xv, S_(Y)))), ('der', phi))
V = lambda s: ('?', s)
X, Y = V('X'), V('Y')
SIG = ('st', ('der', ('imp', ('eq', X, ZERO), ('iff', V('f'), V('p')))), ('der', ('imp', ('eq', X, Y), ('iff', V('f'), V('c')))),
       ('der', ('imp', ('eq', X, S_(Y)), ('iff', V('f'), V('t')))), ('der', V('p')), ('der', ('imp', V('c'), V('t'))), ('der', V('f')))
def occurs(v, f):
    if is_ov(f): return f[0] == v
    return len(f) > 1 and any(occurs(v, a) for a in f[1:])
mis = 0; tot = 0
pairs = [('x', 'y'), ('x', 'z'), ('n', 'y'), ('n', 'k'), ('y', 'x')]
while tot < 20000:
    recs = []
    for _ in range(r.randint(1, 4)):
        xv, yv = r.choice(pairs) if r.random() < .5 else ('x', 'y')
        phi = rform(r, r.randint(0, 3), [xv, 'u', 'z' if yv != 'z' else 'n'])
        if occurs(yv, phi) or not free_for(phi, xv, K(yv)): continue
        recs.append((phi, xv, yv))
    if not recs: continue
    tot += 1
    L = au([mm(*q) for q in recs])
    cond = (len({p[0] for p, a, b in recs}) > 1 and any(a in fv(p) for p, a, b in recs)
            and len({a for p, a, b in recs}) > 1 and len({b for p, a, b in recs}) > 1)
    mis += variant(L, SIG) != cond
print(f'E3 with X,Y metavariables: {tot} random canonical sets; mismatches with (roots differ & some x free & X varies & Y varies) = {mis}')
