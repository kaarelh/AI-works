# R3: P5 numbers as a function of the non-vacuity rate q (the notes state q >= 0.4).
import math, random
from rcore import *
p = {'eq': .6, 'imp': .2, 'all': .1, 'other': .1}
d = 0.01
def exact(N, q): return 1 - (1 - sum(v ** N for v in p.values())) * (1 - (1 - q) ** N)
def refined(N, q): return 2 * 0.6 ** N + (1 - q) ** N
def first(f, q): return next(N for N in range(1, 400) if f(N, q) <= d)
for q in (1.0, 0.95, 0.6, 0.5, 0.45, 0.43, 0.42, 0.41, 0.4):
    print(f'q={q:4}: theorem N={math.ceil(math.log(9/d)/min(0.4,q))}, refined-union N={first(refined,q)}, exact N={first(exact,q)}'
          f'  (exact P(fail) at N=10: {exact(10,q):.5f}; refined at N=11: {refined(11,q):.5f})')
# threshold q for exact N=10 and refined N=11
lo, hi = 0.3, 1.0
for _ in range(60):
    mid = (lo + hi) / 2
    if exact(10, mid) <= d: hi = mid
    else: lo = mid
print('exact N=10 holds iff q >= %.4f' % hi)
lo, hi = 0.3, 1.0
for _ in range(60):
    mid = (lo + hi) / 2
    if refined(11, mid) <= d: hi = mid
    else: lo = mid
print('refined-union N=11 holds iff q >= %.4f' % hi)
# simulation at q = 0.4 with the referee's own lgg (roots: eq .6, imp .2, all .1, not .1)
r = random.Random(11)
VS = ['x', 'y']
def mot(root, nonvac):
    while True:
        if root == 'eq': f = ('eq', rterm(r, 2, VS), rterm(r, 2, VS))
        elif root == 'not': f = ('not', rform(r, 2, VS))
        elif root == 'all': f = ('all', K('y'), rform(r, 2, VS))
        else: f = ('imp', rform(r, 2, VS), rform(r, 2, VS))
        if ('x' in fv(f)) == nonvac: return f
def draw(q):
    u = r.random(); root = 'eq' if u < .6 else 'imp' if u < .8 else 'all' if u < .9 else 'not'
    return mot(root, r.random() < q)
for N in (10, 11):
    T = 20000; fail = 0
    for _ in range(T):
        fail += not variant(au([ind(draw(0.4)) for _ in range(N)]), SIG_X)
    print(f'simulation q=0.4, N={N}: empirical P(fail) = {fail/T:.4f} (+-{2*math.sqrt(fail/T*(1-fail/T)/T):.4f}), exact = {exact(N,0.4):.4f}')
