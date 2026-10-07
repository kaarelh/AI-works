# Prop B6: the substitution-free (Tarski-style) form of induction is a first-order pattern with ONE
# metavariable, recovered by lgg from two root-diverse instances; contrast with the raw form.
import itertools, random
from raw_common import *
from raw_search import pretty, rename_pretty

P = MV('P')
target = IndEq(P)
print('IndEq(P) =', rename_pretty(target))

phis = [eq(add(X, Z), X), eq(add(Z, X), X), NOT(eq(X, S(X))), OR(eq(X, Z), NOT(eq(X, Z))),
        IMP(eq(X, Z), eq(add(X, X), Z)), eq(g(3, X), X)]
# two root-diverse instances already recover the pattern exactly
for a, b in itertools.combinations(phis, 2):
    L = lgg_list([IndEq(a), IndEq(b)])
    rec = canon(L) == canon(target)
    spec = is_instance(L, target)      # L is always an instance (specialization) of IndEq(P)
    assert spec
    if a[0] != b[0]: assert rec
print('every pair from the sample: lgg is a specialization of IndEq(P); root-diverse pairs recover it exactly: True')
print('lgg(IndEq(x+0=x), IndEq(0+x=x)) =', rename_pretty(lgg_list([IndEq(phis[0]), IndEq(phis[1])])))
# F' pairs: lgg = IndEq(g_n(z)=x), sound (an instance of IndEq(P))
L = lgg_list([IndEq(eq(g(1, X), X)), IndEq(eq(g(4, X), X))])
print("F' pair (n=1,m=4) in equational form: lgg =", rename_pretty(L), '; instance of IndEq(P):', is_instance(L, target))

# sanity check (bounded evaluation, B=25) that IndEq(phi) and Ind(phi) have the same truth value,
# for random quantifier-free phi with only x free, and that both are true.
B = 25
def bev(f, env):
    h = f[0]
    if h == 'eq': return tval(f[1], env) == tval(f[2], env)
    if h == 'not': return not bev(f[1], env)
    if h == 'and': return bev(f[1], env) and bev(f[2], env)
    if h == 'or': return bev(f[1], env) or bev(f[2], env)
    if h == 'imp': return (not bev(f[1], env)) or bev(f[2], env)
    if h == 'all': return all(bev(f[2], {**env, f[1]: n}) for n in range(B))
    raise ValueError(h)
rng = random.Random(1)
def rterm(d):
    if d == 0 or rng.random() < 0.3: return rng.choice([Z, X])
    r = rng.random()
    if r < 0.4: return S(rterm(d - 1))
    if r < 0.75: return add(rterm(d - 1), rterm(d - 1))
    return mul(rterm(d - 1), rterm(d - 1))
def rform(d):
    if d == 0 or rng.random() < 0.4: return eq(rterm(2), rterm(2))
    r = rng.random()
    if r < 0.25: return NOT(rform(d - 1))
    return rng.choice([AND, OR, IMP])(rform(d - 1), rform(d - 1))
agree = 0; N = 400
for _ in range(N):
    f = rform(2)
    a, b = bev(IndEq(f), {}), bev(Ind(f), {})
    assert a == b, pretty(f)
    agree += 1
print('bounded check (B=%d): IndEq(phi) and Ind(phi) agree on %d random phi (q.f., x only free)' % (B, agree))

# capture under universal-closure semantics: psi(x,y) := x=0 v ~x=y ; the closure  Ay IndEq(psi) is false
psi = OR(eq(X, Z), NOT(eq(X, Y)))
inst = IndEq(psi)
print('free variables of IndEq(psi):', sorted(v[0] for v in free_vars(inst)))
vals = [bev(inst, {Y: b}) for b in range(6)]
print('IndEq(x=0 v ~x=y) at y=0..5 (bounded):', vals, ' -> universal closure false; the guard y notin FV(P) excludes it')
