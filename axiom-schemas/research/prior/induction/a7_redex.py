# A7: Lean-style representation; the motive is recorded as a lambda term M = lam(x, phi) and the induction
# conclusion keeps the beta-redexes unreduced:  |- (M 0 & forall n (M n -> M (S n))) -> forall n (M n).
# (Lean: Nat.rec {motive} zero succ t : motive t, with motive explicit in the elaborated term.)
# beta-conversion is a trusted step.  The pattern has ONE metavariable P (M = lam(x, P), x the bound name,
# alpha-normalized; with de Bruijn indices the name disappears).
from common import *
import random, math
rng = random.Random(8)
def lam(v, b): return ('lam', v, b)
def app(m, t): return ('app', m, t)
def ind_redex(phi, v=x):
    M = lam(v, phi)
    return ('st', IMP(AND(app(M, Z), ALL(n, IMP(app(M, n), app(M, S(n))))), ALL(n, app(M, n))))
SIG_R = ind_redex(MV('P'))
U = motives_upto(5, ('x', 'y'))
bad = 0; tot = 0
for i in range(len(U)):
    for j in range(i + 1, len(U)):
        L = lgg_list([ind_redex(U[i]), ind_redex(U[j])]); tot += 1
        if equiv(L, SIG_R) != (U[i][0] != U[j][0]): bad += 1
print(f'redex encoding, all {tot} pairs: lgg == pattern <=> motive roots differ (vacuity irrelevant): mismatches = {bad}')
print('two vacuous motives with different roots form an anchor:', equiv(lgg_list([ind_redex(eq(Z, Z)), ind_redex(NOT(eq(Z, S(Z))))]), SIG_R))
# beta-normalizing the conclusion gives the Sub-encoded conclusion
def beta(t):
    if is_var(t) or len(t) == 1: return t
    t = (t[0],) + tuple(beta(a) for a in t[1:])
    if t[0] == 'app' and t[1][0] == 'lam': return subst(t[1][2], t[1][1], t[2])
    return t
ok = all(beta(ind_redex(p)[1]) == IMP(AND(subst(p, x, Z), ALL(n, IMP(subst(p, x, n), subst(p, x, S(n))))), ALL(n, subst(p, x, n)))
         for p in U if 'n' not in {q for q in free_vars(p)})
print('beta-normal form of the redex conclusion == induction conclusion (motive renamed to n):', ok)
# constants
print('coupon: v=1, c=2, rho=0.4 -> N >=', math.ceil(math.log(2 / 0.01) / 0.4), '(Thm coupon); exact: sum_f p_f^N <= 0.01 at N = 10')
phi0 = eq(add(x, Z), x); s0 = ind_redex(phi0)
print(f'escalations from one example ind(x+0=x): paper bound mu(s0)-mu(sigma) = {mu(s0)-mu(SIG_R)}; tuple bound |phi0| = {size(phi0)}')
# tightness: generalize phi0 one symbol at a time with fresh constants; every query is a genuine instance here
fresh = iter([C('v%d' % i) for i in range(50)])
chain = [eq(add(MV('a'), Z), x), eq(add(MV('a'), MV('b')), x), eq(add(MV('a'), MV('b')), MV('c')), eq(MV('d'), MV('c')), MV('e')]
def ground_with(g, formula_fill):
    th = {}
    def ap(t, ctx):
        if is_var(t):
            if t[1] not in th: th[t[1]] = formula_fill() if ctx == 'f' else next(fresh)
            return th[t[1]]
        if t[0] in ATOM_P: return (t[0],) + tuple(ap(a, 't') for a in t[1:])
        return (t[0],) + tuple(ap(a, ctx) for a in t[1:])
    return ap(g, 'f')
data = [s0]; esc = 0
for g in chain:
    q = ind_redex(ground_with(g, lambda: lt(next(fresh), Z)))
    if not is_instance(q, lgg_list(data)): esc += 1
    data.append(q)
print('forced escalations with genuine queries:', esc, '; final lgg == pattern:', equiv(lgg_list(data), SIG_R))
