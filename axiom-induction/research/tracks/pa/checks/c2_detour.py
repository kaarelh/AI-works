# c2_detour.py -- under a derivation likelihood, a theory that splits T_Ind by main connective still derives
# induction for every motive, through a logically equivalent "wrapper" motive with a covered main connective.
# Checked schematic derivations of Ind(P) from Ind(w_f(P)), one per non-atomic root f, and their code lengths
# (track "pa", notes.md section 2).  Deterministic; output in c2_detour.out.
import math
from nd import *
import arith
from arith import AX, SCH, Ind, Pm, x, z

LAM = math.log2(23)
ZERO_EQ = eq(Z, Z)
WRAP = {
    'not': (lambda A: NOT(NOT(A))),
    'and': (lambda A: AND(A, A)),
    'or':  (lambda A: OR(A, A)),
    'imp': (lambda A: IMP(ZERO_EQ, A)),
    'all': (lambda A: ALL('z', A)),
    'ex':  (lambda A: EX('z', A)),
}

def wrap_from(pf, f, li, A):
    """from line li |- A derive |- w_f(A)"""
    if f == 'all': return pf.allI(li, 'z')
    if f == 'ex': return pf.exI(li, 'z', A, V('z'))
    return pf.tc([li], WRAP[f](A))

def unwrap(pf, f, li, A):
    """from line li |- w_f(A) derive |- A"""
    if f == 'all': return pf.allE(li, V('z'))
    if f == 'ex':
        h = pf.hyp(A)
        return pf.exE(li, h, 'z')
    if f == 'imp':
        r = pf.refl(Z)
        return pf.tc([li, r], A)
    return pf.tc([li], A)

def d_ind_from_wrapped(pf, f, phi=Pm):
    ph = lambda t: subst(phi, 'x', t)
    w = lambda t: WRAP[f](ph(t))
    H = AND(ph(Z), ALL('x', IMP(ph(x), ph(S(x)))))
    l1 = pf.hyp(H)
    l2 = pf.tc([l1], ph(Z))
    l3 = wrap_from(pf, f, l2, ph(Z))                       # w(P)(0)
    l4 = pf.hyp(w(x))
    l5 = unwrap(pf, f, l4, ph(x))                          # P(x)
    l6 = pf.tc([l1], ALL('x', IMP(ph(x), ph(S(x)))))
    l7 = pf.allE(l6, x)
    l8 = pf.tc([l5, l7], ph(S(x)))
    l9 = wrap_from(pf, f, l8, ph(S(x)))                    # w(P)(Sx)
    l10 = pf.impI(l9, w(x))
    l11 = pf.allI(l10, 'x')
    l12 = pf.ax('Ind', (('x',), WRAP[f](phi)))
    l13 = pf.tc([l3, l11, l12], ALL('x', w(x)))
    l14 = pf.allE(l13, x)
    l15 = unwrap(pf, f, l14, ph(x))
    l16 = pf.allI(l15, 'x')
    return pf.impI(l16, H)

if __name__ == '__main__':
    out = []
    def say(s=''):
        print(s); out.append(s)
    say('Ind(P) from the split template T_f, through the wrapper w_f (all derivations checked)')
    say('%-5s %-14s %6s %8s %4s %9s' % ('root', 'wrapper', 'lines', 'written', 'K', 'overhead'))
    NAX = 7 + 7   # Q1..Q7 and the 7 split templates
    for f in WRAP:
        pf = Proof(AX, SCH)
        d_ind_from_wrapped(pf, f)
        pf.check_closed(Ind((('x',), Pm)))
        st = pf.stats()
        ov = pf.bits(LAM, NAX) - (math.log2(len(Proof.RULES)) + math.log2(NAX) + LAM * size(Pm))
        say('%-5s %-14s %6d %8d %4d %9.1f' % (f, show(WRAP[f](Pm)), st['lines'], st['written'], st['meta_occ'], ov))
    say('No wrapper exists for the root "=": an atomic motive is not logically equivalent to an arbitrary formula.')
    say('overhead = bits of the derivation minus bits of a direct citation of Ind(P) (LAM = log2 23).')
    open('c2_detour.out', 'w').write('\n'.join(out) + '\n')
