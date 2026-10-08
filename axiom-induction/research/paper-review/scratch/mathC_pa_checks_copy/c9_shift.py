# c9_shift.py -- a template with a RIGID atom beside its formula metavariable can still give full induction
# (notes-final.md section 4.3, Remark 4.8).  The template T_or0 = Ind(lambda x. x=0 v F(x)) is not read-once in the
# sense of Prop. 4.7 (the atom x=0 is rigid), and no instance of it is logically equivalent to Ind(P).  Yet
#     Q1, Q2 + Ind(chi) |- Ind(P),   chi(x) := x=0 v Ey (x = Sy & P(y)),
# by a shift of the motive.  Checked by nd.py; deterministic; output c9_shift.out.
import math
from nd import *
from arith import AX, Ind, Pm

x, y, w, z = V('x'), V('y'), V('w'), V('z')
P = lambda t: pred('P', t)
def chi(t):
    return OR(eq(t, Z), EX('y', AND(eq(t, S(y)), P(y))))
CHI = (('x',), chi(x))

def d_ind_from_shift(pf):
    H = AND(P(Z), ALL('x', IMP(P(x), P(S(x)))))
    l1 = pf.hyp(H)
    l2 = pf.tc([l1], P(Z))
    l3 = pf.tc([l1], ALL('x', IMP(P(x), P(S(x)))))
    # base: chi(0)
    l4 = pf.refl(Z)
    l5 = pf.tc([l4], chi(Z))
    # step: chi(x) -> chi(Sx); first chi(x) -> P(x) by cases
    l6 = pf.hyp(eq(x, Z))
    l9 = pf.subst(l6, pf.refl(x), 'z', eq(z, x))               # 0 = x
    l10 = pf.subst(l9, l2, 'z', P(z))                          # P(x)
    l11 = pf.impI(l10, eq(x, Z))                               # x=0 -> P(x)
    Bw = AND(eq(x, S(w)), P(w))
    l12 = pf.hyp(Bw)
    l13 = pf.tc([l12], P(w))
    l14 = pf.allE(l3, w)                                       # P(w) -> P(Sw)
    l15 = pf.tc([l13, l14], P(S(w)))
    l16 = pf.tc([l12], eq(x, S(w)))
    l17 = pf.subst(l16, pf.refl(x), 'z', eq(z, x))             # Sw = x
    l18 = pf.subst(l17, l15, 'z', P(z))                        # P(x)
    Ey = EX('y', AND(eq(x, S(y)), P(y)))
    l19 = pf.hyp(Ey)
    l20 = pf.exE(l19, l18, 'w')                                # P(x) under Ey..
    l21 = pf.impI(l20, Ey)
    l22 = pf.hyp(chi(x))
    l23 = pf.tc([l22, l11, l21], P(x))                         # chi(x) |- P(x)
    l24 = pf.refl(S(x))
    l25 = pf.tc([l24, l23], AND(eq(S(x), S(x)), P(x)))
    l26 = pf.exI(l25, 'y', AND(eq(S(x), S(y)), P(y)), x)
    l27 = pf.tc([l26], chi(S(x)))
    l28 = pf.impI(l27, chi(x))
    l29 = pf.allI(l28, 'x')                                    # Ax (chi(x) -> chi(Sx))
    l30 = pf.ax('Ind', CHI)
    l31 = pf.tc([l5, l29, l30], ALL('x', chi(x)))
    # conclusion: P(x) for arbitrary x, from chi(Sx), Q1 and Q2
    l32 = pf.allE(l31, S(x))                                   # Sx=0 v Ey (Sx = Sy & P(y))
    l33 = pf.ax('Q1'); l34 = pf.allE(l33, x)                   # ~ Sx = 0
    l35 = pf.tc([l32, l34], EX('y', AND(eq(S(x), S(y)), P(y))))
    Cw = AND(eq(S(x), S(w)), P(w))
    l36 = pf.hyp(Cw)
    l37 = pf.ax('Q2'); l38 = pf.allE(l37, x); l39 = pf.allE(l38, w)    # Sx = Sw -> x = w
    l40 = pf.tc([l36, l39], eq(x, w))
    l41 = pf.subst(l40, pf.refl(x), 'z', eq(z, x))             # w = x
    l42 = pf.tc([l36], P(w))
    l43 = pf.subst(l41, l42, 'z', P(z))                        # P(x)
    l44 = pf.exE(l35, l43, 'w')
    l45 = pf.allI(l44, 'x')
    return pf.impI(l45, H)

if __name__ == '__main__':
    out = []
    pf = Proof(AX, {'Ind': Ind})
    d_ind_from_shift(pf)
    pf.check_closed(Ind((('x',), Pm)))
    st = pf.stats()
    out.append('Q1, Q2 + Ind(x=0 v Ey(x=Sy & P(y))) |- Ind(P): checked, %d lines, %d written symbols, axioms cited %s'
               % (st['lines'], st['written'], sorted(set(pf.cited))))
    out.append('code length %.1f bits (LAM = log2 23, 8 axioms); a direct citation of Ind(P) costs %.1f bits'
               % (pf.bits(math.log2(23), 8), math.log2(10) + math.log2(8) + math.log2(23) * size(Pm)))
    print('\n'.join(out))
    open('c9_shift.out', 'w').write('\n'.join(out) + '\n')
