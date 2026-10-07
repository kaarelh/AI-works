# Referee test of the algorithm claim (step 2 of "lgg, audit, escalate"):
#   "On raw induction data an unblocked refutation always exists, through one of two instances:
#    I*_a or the L_inf instance (0=0) & Ax(0=S0 -> 0=S0) -> Ax(0=S0)."
# For all pairs of quantifier-free motives of size <= SMAX (own enumerator), classify lgg(Ind f1, Ind f2):
#   sound?  (no false instance found in the pool)  /  has some I*_a (a<=12) or the L_inf instance  /
#   has a "closed collapse" instance A & Ax(B->C) -> Ax B with A, B, C closed q.f., A true, B->C true, B false
#   (then: W-leaves A and B->C, vacuous AI, &I, ->E, AE gives B (W-false): an unblocked 7-judgment refutation)
#   / none of these (refutation, if any, must go through a premise Ax(B->C) with x really occurring).
import sys, itertools
from collections import Counter
from rb_core import *

SMAX = int(sys.argv[1]) if len(sys.argv) > 1 else 5
terms = {1: [ZERO, X]}
for n in range(2, SMAX):
    lst = [S(t) for t in terms[n - 1]]
    for a in range(1, n - 1):
        for s in terms[a]:
            for t in terms[n - 1 - a]:
                lst += [ADD(s, t), MUL(s, t)]
    terms[n] = lst
forms = {}
for n in range(3, SMAX + 1):
    lst = []
    for a in range(1, n - 1):
        for s in terms[a]:
            for t in terms.get(n - 1 - a, []):
                lst.append(EQ(s, t))
    lst += [NEG(f) for f in forms.get(n - 1, [])]
    for a in range(3, n - 1):
        for f in forms.get(a, []):
            for h in forms.get(n - 1 - a, []):
                lst += [AND(f, h), OR(f, h), IMP(f, h)]
    forms[n] = lst
allf = [f for n in sorted(forms) for f in forms[n]]

Linf = IMP(AND(mv('A'), ALL(X, IMP(mv('B'), mv('C')))), ALL(X, mv('B')))
LinfI = apply(Linf, {'A': EQ(ZERO, ZERO), 'B': EQ(ZERO, S(ZERO)), 'C': EQ(ZERO, S(ZERO))})
def Istar(n):
    return IMP(AND(EQ(gn(n, ZERO), ZERO), ALL(X, IMP(EQ(gn(n, ZERO), X), EQ(gn(n, S(ZERO)), S(X))))),
               ALL(X, EQ(gn(n, ZERO), X)))
NAMED = [Istar(a) for a in range(13)] + [LinfI]

CLOSED_T = [ZERO, S(ZERO), S(S(ZERO))]
CLOSED_F = [EQ(ZERO, ZERO), EQ(ZERO, S(ZERO))]
def closed_collapse(L):
    """search an instance with every metavariable closed, A true, B false, (B->C) true; frame must be Ind-shaped"""
    srt = sorts(L)
    names = sorted(srt)
    choices = [CLOSED_T if next(iter(srt[n])) == 'T' else CLOSED_F for n in names]
    for combo in itertools.product(*choices):
        s = apply(L, dict(zip(names, combo)))
        A, B, C = s[1][1], s[1][2][2][1], s[1][2][2][2]
        if fv(A) or fv(B) or fv(C): continue
        if holds(A) and not holds(B):
            return s
    return None

stats = Counter(); examples = {}
for f1, f2 in itertools.combinations(allf, 2):
    if X not in fv(f1) and X not in fv(f2): continue
    L = antiunify([IND(f1), IND(f2)])
    fi = false_instance(L, cap=20000)
    if fi is None:
        cls = 'no false instance found (sound or pool too small)'
    elif any(inst_of(I, L) for I in NAMED):
        cls = 'unsound; has I*_a or the L_inf instance'
    elif closed_collapse(L) is not None:
        cls = 'unsound; NEITHER named instance, but a closed-collapse unblocked refutation exists'
    else:
        cls = 'unsound; NEITHER named instance and no closed-collapse instance'
    stats[cls] += 1
    if cls not in examples or len(examples[cls]) < 6:
        examples.setdefault(cls, []).append((show(f1), show(f2), show(normalize(L)), show(fi) if fi else None))
print('pairs of q.f. motives of size <= %d with x free in at least one: %d' % (SMAX, sum(stats.values())))
for k, v in sorted(stats.items()): print('  %6d  %s' % (v, k))
for k, ex in examples.items():
    print('examples:', k)
    for e in ex: print('   ', e)

# the explicit counterexample used in the report
D = [IND(EQ(MUL(X, ZERO), ZERO)), IND(EQ(MUL(ZERO, X), ZERO))]
L = antiunify(D)
print('\nmul pair lgg:', show(normalize(L)))
print('  has I*_a (a<=12) or L_inf instance:', any(inst_of(I, L) for I in NAMED))
c = closed_collapse(L)
print('  closed-collapse false instance:', show(c), ' true:', holds(c))
# the F pair
D = [IND(EQ(ADD(ZERO, X), X)), IND(EQ(ADD(S(ZERO), X), S(X)))]
L = antiunify(D)
print('F pair lgg (K_0):', show(normalize(L)))
print('  has I*_a (a<=12) or L_inf instance:', any(inst_of(I, L) for I in NAMED), '; closed collapse:', closed_collapse(L))
