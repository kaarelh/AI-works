# Referee C, r3: counterexample to C8.3 (finitary) in DT as defined (nested arguments allowed),
# and to the count "8 minimal templates" of C8.2 for D = {Ind(x=x), Ind(0=x)}.
#   T_k = (0=0 & Ax(f(x)=x -> f^k(Sx)=Sx)) -> Ax f(x)=x      (k >= 1)
#   U_k = (0=0 & Ax(f^k(x)=x -> f(Sx)=Sx)) -> Ax f(x)=x      (k >= 2)
# All are determinate, cover D, and are pairwise incomparable (instance-set witnesses).
import itertools
from rc_core import *

D = [Ind(EQ(X, X)), Ind(EQ(Z(), X))]
def f(t): return MV('f', t)
def fk(k, t):
    for _ in range(k): t = f(t)
    return t
x = V(0)
def T(k): return IMP(AND(EQ(Z(), Z()), ALL(IMP(EQ(f(x), x), EQ(fk(k, S(x)), S(x))))), ALL(EQ(f(x), x)))
def U(k): return IMP(AND(EQ(Z(), Z()), ALL(IMP(EQ(fk(k, x), x), EQ(f(S(x)), S(x))))), ALL(EQ(f(x), x)))
fam = [('T%d' % k, T(k)) for k in range(1, 7)] + [('U%d' % k, U(k)) for k in range(2, 6)]
for nm, t in fam:
    print('%-3s size %2d  DT=%s  SO°=%s  covers D: %s   %s' % (nm, size(t), is_DT(t), is_SO(t),
          [det_match(t, d) for d in D], pp(t)))

# pairwise incomparability via instance witnesses: instantiate with f := lambda z. z+0
w = {nm: instantiate(t, {'f': ADD(HOLE(0), Z())}) for nm, t in fam}
inc = True
for (n1, t1), (n2, t2) in itertools.permutations(fam, 2):
    if det_match(t2, w[n1]) is not None:     # w[n1] in inst(t1); must not be in inst(t2)
        inc = False; print('not separated', n1, n2)
print('pairwise: witness(f=z+0) of each template lies outside every other template:', inc)
print('syntactic generality between distinct members (should be none):',
      [(a, b) for (a, ta), (b, tb) in itertools.permutations(fam, 2) if geq(ta, tb)])

# Minimality of T_k (and U_k): every specialization T sigma by f := lambda z. beta, beta built from
# z, 0, S, + and fresh metavariables g (unary), h (binary), c (0-ary), of size <= 5, that is still
# determinate and still covers D, must be a renaming (beta = g(z)).
z = HOLE(0)
atoms = [z, Z(), MV('c')]
by = {1: atoms}
for n in range(2, 6):
    out = [S(t) for t in by[n - 1]] + [MV('g', t) for t in by[n - 1]]
    for a in range(1, n - 1):
        out += [ADD(p, q) for p in by[a] for q in by[n - 1 - a]] + [MV('h', p, q) for p in by[a] for q in by[n - 1 - a]]
    by[n] = out
betas = [b for n in by for b in by[n]]
def subst_f(t, beta):
    # replace f(u) by beta[u/z] (metavariable-level substitution; beta may contain g,h,c)
    if t[0] == 'M' and t[1] == 'f':
        u = subst_f(t[2][0], beta)
        def pl(b):
            if b == z: return u
            if b[0] in ('v', '0'): return b
            return remake(b, [pl(c) for c in children(b)])
        return pl(beta)
    if t[0] in ('v', 'h', '0'): return t
    return remake(t, [subst_f(c, beta) for c in children(t)])
for nm, t in [('T1', T(1)), ('T2', T(2)), ('T3', T(3)), ('U2', U(2))]:
    surv = []
    for beta in betas:
        t2 = subst_f(t, beta)
        if not is_DT(t2): continue
        if all(det_match(t2, d) is not None for d in D): surv.append(pp(beta, 1, 'z'))
    print('%s: specializations f:=lambda z.beta (|beta|<=5, %d candidates) that stay DT and cover D: %s'
          % (nm, len(betas), surv))
