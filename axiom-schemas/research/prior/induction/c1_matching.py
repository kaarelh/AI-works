# C1: matching second-order templates.  (a) determinate matching of the induction template: unique
# solution, motive recovered; (b) non-instances rejected; (c) non-pattern occurrences alone: many
# solutions (count exact); (d) timing.
import time
from so_core import *
from so_pool import *

print('== (a) T_ind against every pool instance: unique solution, recovered motive ==')
ok = True
for k, m in POOL.items():
    r = solve(T_IND, Ind(m))
    good = r is not None and r[1] == {'P': 1} and r[0]['P'] == m
    ok &= good
print('T_ind =', pp(T_IND), '| determinate:', is_determinate(T_IND), '| size', size(T_IND))
print('all %d pool instances matched with exactly one solution, P = motive:' % len(POOL), ok)

print('\n== (b) non-instances ==')
sstar = frame(eq(Z, Z), eq(X, X), eq(S(X), S(X)), eq(X, Z))
I1 = frame(eq(add(Z, Z), Z), eq(add(Z, Z), X), eq(add(Z, S(Z)), S(X)), eq(add(Z, Z), X))     # Track B's I*_1
Linf = frame(eq(Z, Z), eq(Z, S(Z)), eq(Z, S(Z)), eq(Z, S(Z)))                                # Track B's L_inf instance
for nm, s in [('s*', sstar), ('I*_1 (Track B)', I1), ('L_inf instance (Track B)', Linf)]:
    print('%-26s %-60s in inst(T_ind): %s   true in N: %s' % (nm, pp(s), covers(T_IND, s), truth(s)))

print('\n== (c) non-pattern occurrences: number of matchers ==')
T0 = M('P', Z)                     # P(0) alone (not determinate)
for n in range(1, 7):
    s = eq(Z, Z)
    for _ in range(n - 1): s = AND(s, eq(Z, Z))
    zeros = 2 * n
    r = solve(T0, s)
    print('P(0) vs a sentence with %2d occurrences of 0: %5d matchers (2^%d = %d)' % (zeros, r[1]['P'], zeros, 2 ** zeros))
TS = IMP(AND(M('P', S(Z)), ALL(IMP(M('P', S(V(0))), M('P', S(S(V(0))))))), ALL(M('P', S(V(0)))))
print('T_S =', pp(TS), '| determinate:', is_determinate(TS))
for k in ['Sx=S0', '~Sx=0', 'x=x', 'Sx=x']:
    r = solve(TS, Ind(POOL[k]))
    print('  T_S vs Ind(%s): %s' % (k, ('covered, matchers %s, P = %s' % (r[1], pp(r[0]['P'], 0, ('y',)))) if r else 'not covered'))
TA = IMP(AND(M('P', Z), M('B')), M('C'))
r = solve(TA, Ind(eq(add(Z, X), X)))
print('(P(0) & B) -> C  vs Ind(0+x=x): matchers per metavariable', r[1])

print('\n== (d) timing: determinate matching is linear-time in practice ==')
def bal(n):
    if n == 1: return X
    return add(bal(n // 2), bal(n - n // 2))
def big(n):
    return eq(bal(n), add(X, Z))
for n in (10, 100, 1000, 10000, 100000):
    m = big(n); s = Ind(m)
    t0 = time.time(); reps = 3
    for _ in range(reps): r = covers(T_IND, s)
    dt = (time.time() - t0) / reps
    print('motive size %6d, instance size %6d: covers=%s, %.4f s' % (size(m), size(s), r, dt))
