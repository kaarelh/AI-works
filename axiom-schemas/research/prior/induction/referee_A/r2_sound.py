# R2: soundness of the W-guarded verifier (P6.3/P6.4): adversarial instantiations of lgg(D) for random genuine D.
import random
from rcore import *
r = random.Random(77)
VS = ['x', 'y', 'z', 'n']
def motive(r): return rform(r, r.randint(0, 3), VS)
def instantiate(L, r, pool):
    th = {}
    def ap(t):
        if isv(t):
            if t[1] not in th: th[t[1]] = r.choice(pool)
            return th[t[1]]
        return (t[0],) + tuple(ap(a) for a in t[1:])
    return ap(L)
acc_sub_true = 0; bad = 0; tot = 0; meta_bad = 0; meta_acc = 0
for trial in range(6000):
    use_meta = trial % 2 == 1
    D = []
    for _ in range(r.randint(1, 4)):
        p = motive(r); v = r.choice(VS) if use_meta else 'x'
        D.append(ind(p, v))
    L = au(D)
    # adversarial pool: motives, their substitution images under many terms, terms, variables
    P0 = motive(r)
    pool = [P0, sb(P0, 'x', ZERO), sb(P0, 'x', S_(K('x'))), sb(P0, 'y', ZERO), sb(P0, 'y', S_(K('y'))),
            sb(P0, 'x', S_(S_(K('x')))), sb(P0, 'x', S_(ZERO)), motive(r), K('x'), K('y'), ZERO, S_(K('x')), S_(K('y'))]
    for _ in range(40):
        q = instantiate(L, r, pool)
        tot += 1
        if subs_true(q):
            # an accepted query of the guarded verifier: it must be a genuine induction
            v = q[1][2][0]
            if v not in OV: bad += 1; continue
            if q != ind(q[1][1], v): bad += 1
            else:
                acc_sub_true += 1
print(f'{tot} adversarial instances of lgg(D); {acc_sub_true} have W-true Sub premises; non-genuine among them: {bad}')
# bounded validity of genuine conclusions for small motives (evidence only)
r = random.Random(5); cnt = 0; fails = 0
for _ in range(400):
    p = rform(r, 2, ['x', 'y'])
    c = ind(p)[-1]
    if closure_true(c, range(6), mod=lambda v: v % 6 if False else v) is False:
        fails += 1
    cnt += 1
print('note: bounded truth over a finite initial segment is not a model of arithmetic; skipped as evidence')
