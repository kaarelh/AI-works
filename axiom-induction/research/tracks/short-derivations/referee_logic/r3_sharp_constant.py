"""r3: the sharp constant in Lemma 2.2(iii) / Cor 2.3 (referee minor m-sharp).

(1) F(alpha) <= |alpha|(|alpha|+1)/2 for every formula (F = sum of subtree sizes over formula nodes): exhaustive over
    all formulas of size <= 9 in a small signature, and on 20000 random larger formulas. Hence Lemma 2.2(iii)
    gives size <= sum_J |alpha|(|alpha|+1)/2 <= (M + |phi|)(M + |phi| + 1)/2, half of the notes' (M + |phi|)^2.
(2) The constant 1/2 is attained by normal derivations with M >> |phi|: the family
      r, A.r, A.A.r, ..., A^k r  (vacuous Gens),  beta := A^k r -> b  (axiom),  b  (MP)
    has size/(M + |b|)^2 -> 1/2 and size/sumF -> 1 (Prop 2.4's family gives 1/(2(|a|+1)) <= 1/4).
Uses rk.py. Seeded; writes r3_sharp_constant.out.
"""
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rk  # noqa: E402

SEED = 2024
sys.setrecursionlimit(50000)
rng = random.Random(SEED)
out = []


def all_forms(n, depth):
    """All formulas of size exactly n over: 0-ary r, unary P, binary Q, constant a, parameter p0, indices."""
    terms = [('c', 'a', ()), ('p', 0)] + [('i', i) for i in range(depth)]
    res = []
    if n == 1:
        res.append(('R', 'r', ()))
    if n == 2:
        res += [('R', 'P', (t,)) for t in terms]
    if n == 3:
        res += [('R', 'Q', (s, t)) for s in terms for t in terms]
    if n >= 2:
        res += [('~', f) for f in all_forms(n - 1, depth)]
        res += [('A', f) for f in all_forms(n - 1, depth + 1)]
    for a in range(1, n - 1):
        for f in all_forms(a, depth):
            for g in all_forms(n - 1 - a, depth):
                res.append(('>', f, g))
    return res


viol, cnt, tight = 0, 0, 0
for n in range(1, 10):
    for f in all_forms(n, 0):
        cnt += 1
        F = rk.F(f)
        viol += F > n * (n + 1) // 2
        tight += F == n * (n + 1) // 2
out.append(f"(1) exhaustive, all closed formulas of size <= 9: {cnt}; "
           f"F > |a|(|a|+1)/2: {viol}; equality cases: {tight}")


def rnd(d=0):
    u = rng.random()
    if d > 6 or u < 0.25:
        return ('R', 'Q', (('c', 'a', ()), ('p', rng.randrange(3))))
    if u < 0.45:
        return ('~', rnd(d + 1))
    if u < 0.65:
        return ('A', rnd(d + 1))
    return ('>', rnd(d + 1), rnd(d + 1))


viol2, worst = 0, 0.0
for _ in range(20000):
    f = rnd()
    n = rk.sz(f)
    viol2 += rk.F(f) > n * (n + 1) // 2
    worst = max(worst, rk.F(f) / (n * (n + 1) / 2))
out.append(f"    20000 random formulas: violations {viol2}; max F/(|a|(|a|+1)/2) = {worst:.4f}")

r = ('R', 'r', ())
b = ('R', 'Q', (('c', 'a', ()), ('c', 'a', ())))
out.append("(2) family r, A.r, ..., A^k r (vacuous Gen), A^k r -> b, b;  b = Q(a,a)")
okall = True
for k in (1, 10, 100, 400):
    L = [(r, ('ax',))]
    for j in range(k):
        L.append((rk.gen(L[-1][0], 7), ('gen', len(L) - 1, 7)))   # p7 occurs nowhere: vacuous
    beta = rk.imp(L[-1][0], b)
    L.append((beta, ('ax',)))
    L.append((b, ('mp', k, k + 1)))
    ok, _ = rk.check(L, lambda f: f in (r, beta))
    S = rk.dsize(L)
    M = rk.sz(r) + rk.sz(beta)
    J = [r, beta, b]
    sF = sum(rk.F(x) for x in J)
    okall &= ok and rk.is_normal(L)
    out.append(f"    k={k:5d} valid={ok} normal={rk.is_normal(L)} size={S:9d} M={M:6d} size/sumF={S / sF:.4f} "
               f"size/(M+|b|)^2={S / (M + rk.sz(b)) ** 2:.4f}  size/((M+|b|)(M+|b|+1)/2)="
               f"{S / ((M + rk.sz(b)) * (M + rk.sz(b) + 1) / 2):.4f}")
out.append(f"verdict: {'sharp constant 1/2 confirmed; F <= |a|(|a|+1)/2 holds' if okall and viol == 0 and viol2 == 0 else 'FAILURE'}")
with open(os.path.splitext(os.path.abspath(__file__))[0] + '.out', 'w') as fh:
    fh.write('\n'.join(out) + '\n')
print('\n'.join(out))
