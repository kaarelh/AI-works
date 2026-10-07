# Track "cases", revision (referee F1/F2): the variable convention for Q1 and capture.
#
# Named first-order encoding (object variables are constants of the step signature, T1 terms) and de Bruijn
# first-order encoding (indices are constants '#k').  The first-order schema sigma_phi = phi[z/x] is learned
# by Plotkin lgg (T1 code) from closed instances.  Checks:
#  (1) the referee's counterexample phi(x) = Ey ~(y = x): capture instance Ey~(y=y) is an instance of the lgg,
#      a sentence, not a closed instance, and false in every structure (checked on all sizes 1..5);
#      a second example with a TRUE universal: phi(x) = Ey (y = Sx), capture Ey (y = Sy) is false in N.
#  (2) the decomposition of inst(sigma_phi) over a finite universe of substituted terms (size <= 3, over
#      0,S,add, the bound-variable names x,y and parameters p,q): closed / parameter / capture instances,
#      for several phi; the capture class is non-empty exactly as Prop A4' predicts:
#        named, sentences only (no parameters):  iff some x_i has a name bound at ALL its free occurrences;
#        named, free names read as parameters:   iff some free occurrence of some x_i is under a binder;
#        de Bruijn:                              iff all free occurrences of some x_i are under >= 1 binder.
#  (3) guard learning with the family {closed(z), nobound(z)} (most specific guards, lem:setting:guard):
#      closed data -> both learned -> accepted set = closed instances; one parameter datum -> closed(z)
#      dropped, nobound(z) kept -> accepted set = closed + parameter instances = inst_o(phi), never capture.
#  (4) the same in de Bruijn with the guard "no loose index in the value of z".
import sys, itertools
sys.path.insert(0, '/home/user/AI-works/inferential-learning/research/theory/T1-code')
from terms import lgg_list, match, show

Z = ('0',)
def S(t): return ('S', t)
def add(a, b): return ('add', a, b)
def eq(a, b): return ('eq', a, b)
def NOT(f): return ('not', f)
def AND(f, g): return ('and', f, g)
def IMP(f, g): return ('imp', f, g)
def ALL(v, f): return ('all', v, f)
def EX(v, f): return ('ex', v, f)
X, Y = ('x',), ('y',)
VARNAMES = {X, Y}
PARAMS = {('p',), ('q',)}

def subst_free(f, v, t):
    if f == v: return t
    if len(f) == 1 or f[0] == '?': return f
    if f[0] in ('all', 'ex') and f[1] == v: return f
    return (f[0],) + tuple(subst_free(a, v, t) for a in f[1:])

def sigma(phi): return subst_free(phi, X, ('?', 'z'))

def free_names(f, bound=()):
    if len(f) == 1: return {f} if (f in VARNAMES and f not in bound) else set()
    if f[0] in ('all', 'ex'): return free_names(f[2], bound + (f[1],))
    return set().union(*[free_names(a, bound) for a in f[1:]])

def names_in(t):
    if len(t) == 1: return {t} & (VARNAMES | PARAMS)
    return set().union(*[names_in(a) for a in t[1:]])

def binders_at_free_x(phi):
    """for each free occurrence of x: the set of names bound above it"""
    out = []
    def go(f, bound):
        if f == X:
            if X not in bound: out.append(set(bound))
            return
        if len(f) == 1: return
        if f[0] in ('all', 'ex'): go(f[2], bound + (f[1],)); return
        for a in f[1:]: go(a, bound)
    go(phi, ()); return out

# ---------------------------------------------------------------- finite structures (pure equality + S)
def eval_eq_only(f, n, env):
    h = f[0]
    if h == 'eq': return env[f[1]] == env[f[2]]
    if h == 'not': return not eval_eq_only(f[1], n, env)
    if h == 'and': return eval_eq_only(f[1], n, env) and eval_eq_only(f[2], n, env)
    if h == 'ex': return any(eval_eq_only(f[2], n, {**env, f[1]: d}) for d in range(n))
    if h == 'all': return all(eval_eq_only(f[2], n, {**env, f[1]: d}) for d in range(n))
    raise ValueError(h)

print('(1) capture, named encoding')
phi = EX(Y, NOT(eq(Y, X)))
L = lgg_list([subst_free(phi, X, Z), subst_free(phi, X, S(Z))])
cap = subst_free(phi, X, Y)
print('   phi = Ey~(y=x); lgg(phi(0), phi(S0)) =', show(L), '; equals sigma_phi:', L == sigma(phi) or
      (match(L, sigma(phi)) is not None and match(sigma(phi), L) is not None))
print('   capture z:=y gives', show(cap), '; instance of lgg:', match(L, cap) is not None,
      '; sentence:', not free_names(cap))
print('   truth of Ey~(y=y) in all pure-equality structures of size 1..5:',
      [eval_eq_only(cap, n, {}) for n in range(1, 6)])
print('   truth of Ey~(y=c) (closed instance, c any element) in sizes 1..5:',
      [all(eval_eq_only(EX(Y, NOT(eq(Y, ('c',)))), n, {('c',): c}) for c in range(n)) for n in range(1, 6)])
phi2 = EX(Y, eq(Y, S(X)))
L2 = lgg_list([subst_free(phi2, X, Z), subst_free(phi2, X, S(Z))])
cap2 = subst_free(phi2, X, Y)
print('   phi = Ey(y=Sx): lgg', show(L2), '; capture', show(cap2), '; instance of lgg:', match(L2, cap2) is not None,
      '; (Ax Ey(y=Sx) is true in N, Ey(y=Sy) is false in N: S has no fixed point)')

print('\n(2) decomposition of inst(sigma_phi) over substituted terms of size <= 3')
ATOMS = [Z] + sorted(VARNAMES) + sorted(PARAMS)
def terms_upto(k):
    T = {1: list(ATOMS)}
    for s in range(2, k + 1):
        T[s] = [S(t) for t in T[s - 1]]
        for a in range(1, s - 1):
            T[s] += [add(u, v) for u in T[a] for v in T[s - 1 - a]]
    return [t for s in T for t in T[s]]
TERMS = terms_upto(3)
PHIS = {
    'Ey~(y=x)':            EX(Y, NOT(eq(Y, X))),
    'Ey(y=Sx)':            EX(Y, eq(Y, S(X))),
    'x=x & Ay(x=y)':       AND(eq(X, X), ALL(Y, eq(X, Y))),
    'Ay(y=x -> x=y)':      ALL(Y, IMP(eq(Y, X), eq(X, Y))),
    'x+0=x  (no binder)':  eq(add(X, Z), X),
    'Ax(x=x) & x=0':       AND(ALL(X, eq(X, X)), eq(X, Z)),
    'Ay(x+y=y+x) & Ex(x=0)': AND(ALL(Y, eq(add(X, Y), add(Y, X))), EX(X, eq(X, Z))),
}
print('   %-24s %6s %7s %7s %7s | pred(sentences) pred(params) | free occurrences of x: binder sets' %
      ('phi', 'total', 'closed', 'param', 'capture'))
for nm, phi in PHIS.items():
    sg = sigma(phi)
    occ = binders_at_free_x(phi)
    cnt = {'closed': 0, 'param': 0, 'capture': 0, 'not-a-sentence': 0}
    capture_sent = 0
    for t in TERMS:
        # textual substitution at the z positions = fo instance of sigma (no capture check):
        th = {'z': t}
        def fo(u):
            if u[0] == '?': return th[u[1]]
            if len(u) == 1: return u
            return (u[0],) + tuple(fo(a) for a in u[1:])
        s = fo(sg)
        nb = names_in(t) & VARNAMES
        captured = any(nb & b for b in occ)
        if not nb and not (names_in(t) & PARAMS): cnt['closed'] += 1
        elif not nb: cnt['param'] += 1
        elif captured:
            cnt['capture'] += 1
            if not free_names(s): capture_sent += 1
        else: cnt['not-a-sentence'] += 1
    all_bound = set.intersection(*occ) if occ else set()
    pred_sent = bool(all_bound)                  # named, sentences only
    pred_par = any(b for b in occ)               # named, free names read as parameters
    print('   %-24s %6d %7d %7d %7d | capture sentences %3d (pred %-5s) capture formulas (pred %-5s) | %s' % (
        nm, len(TERMS), cnt['closed'], cnt['param'], cnt['capture'], capture_sent, pred_sent,
        pred_par, [sorted(n[0] for n in b) for b in occ]))
    assert (capture_sent > 0) == pred_sent and (cnt['capture'] > 0) == pred_par

print('\n(3) most specific guards from the family {closed(z), nobound(z)} (named encoding, phi = Ey~(y=x))')
phi = EX(Y, NOT(eq(Y, X)))
def is_closed(t): return not names_in(t)
def nobound(t): return not (names_in(t) & VARNAMES)
GUARDS = {'closed(z)': is_closed, 'nobound(z)': nobound}
def learn(data_terms):
    L = lgg_list([subst_free(phi, X, t) for t in data_terms])
    return L, {g for g, f in GUARDS.items() if all(f(t) for t in data_terms)}
def accepts(L, G, t):
    s = ('ex', ('y',), ('not', ('eq', ('y',), t)))      # textual instance of sigma (capture allowed)
    m = match(L, s)
    if m is None: return False
    (val,) = m.values()                                   # the single metavariable of the lgg
    return all(GUARDS[g](val) for g in G)
for D in ([Z, S(Z)], [Z, S(Z), add(('p',), S(Z))]):
    L, G = learn(D)
    print('   data terms %-28s lgg %-22s learned guards %s' % ([show(t) for t in D], show(L), sorted(G)))
    for q in (S(S(Z)), ('q',), Y, add(Y, ('p',))):
        kind = 'closed' if is_closed(q) else ('parameter' if nobound(q) else 'capture')
        print('       accept z := %-10s (%-9s): %s' % (show(q), kind, accepts(L, G, q)))
    print('       unguarded H1 verifier would accept the capture instance Ey~(y=y):', match(L, cap) is not None)

print('\n(4) de Bruijn first-order encoding, phi = E~(#0 = x)')
def dbphi(t): return ('ex', ('not', ('eq', ('#0',), t)))
Ld = lgg_list([dbphi(Z), dbphi(S(Z))])
capd = dbphi(('#0',))
def loose_free(t): return not any(len(u) == 1 and u[0].startswith('#') for u in [t] + list(_sub(t)))
def _sub(t):
    if len(t) == 1: return
    for a in t[1:]:
        yield a
        yield from _sub(a)
print('   lgg', show(Ld), '; capture E~(#0=#0) instance of lgg:', match(Ld, capd) is not None)
print('   learned guard "no loose index in z" (true on both data):', loose_free(Z) and loose_free(S(Z)),
      '; capture value #0 satisfies it:', loose_free(('#0',)))
print('   lambda convention (values have no loose indices, free names = parameters): capture impossible by sort.')
