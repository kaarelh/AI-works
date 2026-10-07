# R4: P8 (Lean-style redex encoding with a NAMED outer binder n). The pattern instantiates P under the
# binder 'all n'; a motive body with n free is captured. Check: instance of the learned pattern, well-formed
# body, beta-normal form false in N.
from rcore import *
def lam(v, b): return ('lam', K(v), b)
def app(m, t): return ('app', m, t)
N_ = K('n')
def ind_redex(body):
    M = lam('x', body)
    return ('st', ('imp', ('and', app(M, ZERO), ('all', N_, ('imp', app(M, N_), app(M, S_(N_))))), ('all', N_, app(M, N_))))
SIG_R = ind_redex(('?', 'P'))
def beta(t):
    # beta by first-order replacement of the lambda variable (substitution inside body; the body sits
    # where the pattern put it, so a free n in the body is already in the scope of the outer 'all n')
    if isv(t) or len(t) == 1: return t
    t = (t[0],) + tuple(beta(a) for a in t[1:])
    if t[0] == 'app' and t[1][0] == 'lam':
        body, v, arg = t[1][2], t[1][1][0], t[2]
        assert free_for(body, v, arg)
        return sb(body, v, arg)
    return t
anchor = [ind_redex(('eq', ('add', K('x'), ZERO), K('x'))), ind_redex(('not', ('eq', S_(K('x')), ZERO)))]
print('anchor lgg == pattern:', variant(au(anchor), SIG_R))
body = ('or', ('eq', K('x'), ZERO), ('not', ('eq', K('x'), N_)))     # x = 0  v  x != n   (n a parameter)
q = ind_redex(body)
print('query is an instance of the learned pattern:', more_general_eq(au(anchor), q), '; body well-formed:', is_fm(body))
c = beta(q[1])
print('beta-normal form:', c)
# the beta-normal form is a sentence?  free vars:
print('free variables of beta-normal form:', fv(c))
# truth in N: it is (0=0 v 0!=n) & forall n((n=0 v n!=n) -> (Sn=0 v Sn!=n)) -> forall n (n=0 v n!=n)
# antecedent: first conjunct true; second: if n=0 then S0=0 v S0!=0 -> true; if n!=0 premise false. So true.
# conclusion: forall n (n = 0) is false.  Check on a long initial segment (only quantifiers over n; no + or *):
print('true on [0,30) for every value of the free n (should be False):', closure_true(c, range(30)))
# what the community record of a parameterized induction looks like in this encoding (motive x+n = n+x):
rec = ind_redex(('eq', ('add', K('x'), N_), ('add', N_, K('x'))))
print('beta-normal form of the record for motive x+n=n+x:', beta(rec[1]))
print('  -> its consequent is forall n (n+n = n+n), not forall x (x+n = n+x): the record is mis-encoded')
