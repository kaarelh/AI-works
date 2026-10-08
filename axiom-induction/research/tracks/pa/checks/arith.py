# arith.py -- axioms, schemas and checked schematic derivations for PA-style axiomatisations (track "pa").
# Base theory B = Q (Q1..Q7, closed universal forms) + Dlt (definition of <).  Schemas: Ind, CVI (course-of-values,
# "strong" induction), LNP (least number principle).  Variants Q4L, Q5L (recursion on the left argument of +).
#
# Every derivation is a function of a motive phi (a formula whose distinguished free variable is 'x'), so it can be
# run schematically (phi = P(x), P a predicate metavariable) and on concrete motives.  Proofs are built with
# nd.Proof, which checks each line.
from nd import *

x, y, z, u, v, w = (V(c) for c in 'xyzuvw')

AX = {
    'Q1': ALL('u', NOT(eq(S(u), Z))),
    'Q2': ALL('u', ALL('v', IMP(eq(S(u), S(v)), eq(u, v)))),
    'Q3': ALL('u', OR(eq(u, Z), EX('v', eq(u, S(v))))),
    'Q4': ALL('u', eq(add(u, Z), u)),
    'Q5': ALL('u', ALL('v', eq(add(u, S(v)), S(add(u, v))))),
    'Q6': ALL('u', eq(mul(u, Z), Z)),
    'Q7': ALL('u', ALL('v', eq(mul(u, S(v)), add(mul(u, v), u)))),
    'Dlt': ALL('u', ALL('v', IFF(lt(u, v), EX('z', eq(add(u, S(V('z'))), v))))),
    # left-recursive variants of Q4, Q5 ("Q5 as written versus variants")
    'Q4L': ALL('u', eq(add(Z, u), u)),
    'Q5L': ALL('u', ALL('v', eq(add(S(u), v), S(add(u, v))))),
}

def fresh(avoid, base='y'):
    for c in [base] + [base + str(i) for i in range(1, 100)]:
        if c not in avoid: return c
    raise ValueError

def Ind(m):
    (xv,), phi = m
    return IMP(AND(subst(phi, xv, Z), ALL(xv, IMP(phi, subst(phi, xv, S(V(xv)))))), ALL(xv, phi))

def CVI(m):
    (xv,), phi = m
    yv = fresh(allvars(phi) | {xv})
    return IMP(ALL(xv, IMP(ALL(yv, IMP(lt(V(yv), V(xv)), subst(phi, xv, V(yv)))), phi)), ALL(xv, phi))

def LNP(m):
    (xv,), phi = m
    yv = fresh(allvars(phi) | {xv})
    return IMP(EX(xv, phi), EX(xv, AND(phi, ALL(yv, IMP(lt(V(yv), V(xv)), NOT(subst(phi, xv, V(yv))))))))

SCH = {'Ind': Ind, 'CVI': CVI, 'LNP': LNP}
Pm = pred('P', x)                   # the schematic motive P(x)

def ph_of(phi):
    return lambda t: subst(phi, 'x', t)

# --------------------------------------------------------------------------------------------------- derivations
# Each derivation appends lines to pf and returns the index of a line  |- goal  with no hypotheses.
# A "provider" is a function pf -> line index of a closed line; it lets one derivation cite or derive a form.

def cite(name, m):
    return lambda pf: pf.ax(name, m)

def d_ind_from_cvi(pf, phi, get_cvi):
    """Ind(phi) from CVI(phi) over Q + Dlt (uses Q3, Q4, Q5, Dlt)."""
    ph = ph_of(phi)
    H = AND(ph(Z), ALL('x', IMP(ph(x), ph(S(x)))))
    G = ALL('y', IMP(lt(y, x), ph(y)))
    l1 = pf.hyp(H)
    l2 = pf.hyp(G)
    l3 = pf.ax('Q3')
    l4 = pf.allE(l3, x)                                   # x=0 v Ev x=Sv
    l5 = pf.hyp(eq(x, Z))
    l6 = pf.tc([l1], ph(Z))
    l7 = pf.refl(x)
    l8 = pf.subst(l5, l7, 'z', eq(z, x))                  # 0 = x
    l9 = pf.subst(l8, l6, 'z', ph(z))                     # phi(x)
    l10 = pf.impI(l9, eq(x, Z))
    l11 = pf.hyp(eq(x, S(w)))
    l12 = pf.ax('Dlt')
    l13 = pf.allE(l12, w)
    l14 = pf.allE(l13, x)                                 # w<x <-> Ez w+Sz=x
    l15 = pf.ax('Q5')
    l16 = pf.allE(l15, w)
    l17 = pf.allE(l16, Z)                                 # w+S0 = S(w+0)
    l18 = pf.ax('Q4')
    l19 = pf.allE(l18, w)                                 # w+0 = w
    l20 = pf.subst(l19, l17, 'z', eq(add(w, S(Z)), S(z))) # w+S0 = Sw
    l22 = pf.subst(l11, l7, 'z', eq(z, x))                # Sw = x
    l23 = pf.subst(l22, l20, 'z', eq(add(w, S(Z)), z))    # w+S0 = x
    l24 = pf.exI(l23, 'z', eq(add(w, S(z)), x), Z)
    l25 = pf.tc([l14, l24], lt(w, x))
    l26 = pf.allE(l2, w)
    l27 = pf.tc([l25, l26], ph(w))
    l28 = pf.tc([l1], ALL('x', IMP(ph(x), ph(S(x)))))
    l29 = pf.allE(l28, w)
    l30 = pf.tc([l27, l29], ph(S(w)))
    l31 = pf.subst(l22, l30, 'z', ph(z))                  # phi(x)
    Ev = EX('v', eq(x, S(v)))
    l32 = pf.hyp(Ev)
    l33 = pf.exE(l32, l31, 'w')
    l34 = pf.impI(l33, Ev)
    l35 = pf.tc([l4, l10, l34], ph(x))
    l36 = pf.impI(l35, G)
    l37 = pf.allI(l36, 'x')
    l38 = get_cvi(pf)
    l39 = pf.tc([l37, l38], ALL('x', ph(x)))
    return pf.impI(l39, H)

def d_cvi_from_ind(pf, phi, get_ind_theta):
    """CVI(phi) from Ind(theta), theta(x) = Ay(y<x -> phi(y)), over Q + Dlt (uses Q1..Q5, Dlt)."""
    ph = ph_of(phi)
    theta = ALL('y', IMP(lt(y, x), ph(y)))
    Prog = ALL('x', IMP(theta, ph(x)))
    l1 = pf.hyp(Prog)
    l2 = pf.hyp(lt(y, Z))
    l3 = pf.ax('Dlt')
    l4 = pf.allE(l3, y)                                   # Av (y<v <-> Ez y+Sz=v)
    l5 = pf.allE(l4, Z)
    l6 = pf.tc([l2, l5], EX('z', eq(add(y, S(z)), Z)))
    l7 = pf.hyp(eq(add(y, S(z)), Z))
    l9 = pf.ax('Q5')
    l10 = pf.allE(l9, y)
    l11 = pf.allE(l10, z)                                 # y+Sz = S(y+z)
    l12 = pf.subst(l11, l7, 'u', eq(u, Z))                # S(y+z) = 0
    l13 = pf.ax('Q1')
    l14 = pf.allE(l13, add(y, z))
    l15 = pf.tc([l12, l14], BOT)
    l16 = pf.exE(l6, l15, 'z')
    l17 = pf.tc([l16], ph(y))
    l18 = pf.impI(l17, lt(y, Z))
    l19 = pf.allI(l18, 'y')                               # theta(0)
    l20 = pf.hyp(theta)
    l21 = pf.hyp(lt(y, S(x)))
    l22 = pf.allE(l4, S(x))
    l23 = pf.tc([l21, l22], EX('z', eq(add(y, S(z)), S(x))))
    l24 = pf.hyp(eq(add(y, S(z)), S(x)))
    l25 = pf.subst(l11, l24, 'u', eq(u, S(x)))            # S(y+z) = Sx
    l26 = pf.ax('Q2')
    l27 = pf.allE(l26, add(y, z))
    l28 = pf.allE(l27, x)
    l29 = pf.tc([l25, l28], eq(add(y, z), x))
    l30 = pf.ax('Q3')
    l31 = pf.allE(l30, z)
    l32 = pf.hyp(eq(z, Z))
    l33 = pf.subst(l32, l29, 'u', eq(add(y, u), x))       # y+0 = x
    l34 = pf.ax('Q4')
    l35 = pf.allE(l34, y)
    l36 = pf.subst(l35, l33, 'u', eq(u, x))               # y = x
    l37 = pf.allE(l1, x)                                  # theta -> phi(x)
    l38 = pf.tc([l20, l37], ph(x))
    l39 = pf.refl(y)
    l40 = pf.subst(l36, l39, 'u', eq(u, y))               # x = y
    l41 = pf.subst(l40, l38, 'u', ph(u))                  # phi(y)
    l42 = pf.impI(l41, eq(z, Z))
    l43 = pf.hyp(eq(z, S(v)))
    l44 = pf.subst(l43, l29, 'u', eq(add(y, u), x))       # y+Sv = x
    l45 = pf.exI(l44, 'z', eq(add(y, S(z)), x), v)
    l46 = pf.allE(l4, x)
    l47 = pf.tc([l45, l46], lt(y, x))
    l48 = pf.allE(l20, y)
    l49 = pf.tc([l47, l48], ph(y))
    Ev = EX('v', eq(z, S(v)))
    l50 = pf.hyp(Ev)
    l51 = pf.exE(l50, l49, 'v')
    l52 = pf.impI(l51, Ev)
    l53 = pf.tc([l31, l42, l52], ph(y))
    l54 = pf.exE(l23, l53, 'z')
    l55 = pf.impI(l54, lt(y, S(x)))
    l56 = pf.allI(l55, 'y')
    l57 = pf.impI(l56, theta)
    l58 = pf.allI(l57, 'x')
    l59 = get_ind_theta(pf)
    l60 = pf.tc([l19, l58, l59], ALL('x', theta))
    l61 = pf.allE(l60, x)
    l62 = pf.tc([l61, l37], ph(x))
    l63 = pf.allI(l62, 'x')
    return pf.impI(l63, Prog)

def d_lnp_from_cvi_neg(pf, phi, get_cvi_neg):
    """LNP(phi) from CVI(~phi): pure logic."""
    ph = ph_of(phi)
    EP = EX('x', ph(x))
    goal_body = AND(ph(x), ALL('y', IMP(lt(y, x), NOT(ph(y)))))
    Ng = NOT(EX('x', goal_body))
    A = ALL('y', IMP(lt(y, x), NOT(ph(y))))
    l1 = pf.hyp(EP)
    l2 = pf.hyp(Ng)
    l3 = pf.hyp(A)
    l4 = pf.hyp(ph(x))
    l5 = pf.tc([l3, l4], goal_body)
    l6 = pf.exI(l5, 'x', goal_body, x)
    l7 = pf.tc([l2, l6], BOT)
    l8 = pf.impI(l7, ph(x))
    l9 = pf.tc([l8], NOT(ph(x)))
    l10 = pf.impI(l9, A)
    l11 = pf.allI(l10, 'x')
    l12 = get_cvi_neg(pf)
    l13 = pf.tc([l11, l12], ALL('x', NOT(ph(x))))
    l14 = pf.hyp(ph(w))
    l15 = pf.allE(l13, w)
    l16 = pf.tc([l14, l15], BOT)
    l17 = pf.exE(l1, l16, 'w')
    l18 = pf.impI(l17, Ng)
    l19 = pf.tc([l18], EX('x', goal_body))
    return pf.impI(l19, EP)

def d_cvi_from_lnp_neg(pf, phi, get_lnp_neg):
    """CVI(phi) from LNP(~phi): pure logic."""
    ph = ph_of(phi)
    Prog = ALL('x', IMP(ALL('y', IMP(lt(y, x), ph(y))), ph(x)))
    NA = NOT(ALL('x', ph(x)))
    NE = NOT(EX('x', NOT(ph(x))))
    l1 = pf.hyp(Prog)
    l2 = pf.hyp(NA)
    l3 = pf.hyp(NE)
    l4 = pf.hyp(NOT(ph(x)))
    l5 = pf.exI(l4, 'x', NOT(ph(x)), x)
    l6 = pf.tc([l3, l5], BOT)
    l7 = pf.impI(l6, NOT(ph(x)))
    l8 = pf.tc([l7], ph(x))
    l9 = pf.allI(l8, 'x')
    l10 = pf.tc([l2, l9], BOT)
    l11 = pf.impI(l10, NE)
    l12 = pf.tc([l11], EX('x', NOT(ph(x))))
    l13 = get_lnp_neg(pf)
    Mb = AND(NOT(ph(x)), ALL('y', IMP(lt(y, x), NOT(NOT(ph(y))))))
    l14 = pf.tc([l12, l13], EX('x', Mb))
    M = AND(NOT(ph(w)), ALL('y', IMP(lt(y, w), NOT(NOT(ph(y))))))
    l15 = pf.hyp(M)
    l16 = pf.tc([l15], ALL('y', IMP(lt(y, w), NOT(NOT(ph(y))))))
    l17 = pf.hyp(lt(y, w))
    l18 = pf.allE(l16, y)
    l19 = pf.tc([l17, l18], ph(y))
    l20 = pf.impI(l19, lt(y, w))
    l21 = pf.allI(l20, 'y')
    l22 = pf.allE(l1, w)
    l23 = pf.tc([l15, l21, l22], BOT)
    l24 = pf.exE(l14, l23, 'w')
    l25 = pf.impI(l24, NA)
    l26 = pf.tc([l25], ALL('x', ph(x)))
    return pf.impI(l26, Prog)

# ---- recursion conventions for +:  textbook (Q4, Q5: recursion on the right) versus left (Q4L, Q5L)
def d_q4_from_left(pf, get_ind):
    """Q4 (Au u+0=u) from Q4L, Q5L and Ind(x+0=x)."""
    m = eq(add(x, Z), x)
    l1 = pf.ax('Q4L')
    l2 = pf.allE(l1, Z)                                   # 0+0 = 0
    l3 = pf.hyp(m)
    l4 = pf.ax('Q5L')
    l5 = pf.allE(l4, x)
    l6 = pf.allE(l5, Z)                                   # Sx+0 = S(x+0)
    l7 = pf.subst(l3, l6, 'u', eq(add(S(x), Z), S(u)))    # Sx+0 = Sx
    l8 = pf.impI(l7, m)
    l9 = pf.allI(l8, 'x')
    l10 = get_ind(pf, ((('x',), m)))
    l11 = pf.tc([l2, l9, l10], ALL('x', m))
    return l11

def d_q5_from_left(pf, get_ind):
    """Q5 (Au Av u+Sv = S(u+v)) from Q4L, Q5L and Ind(Ay x+Sy = S(x+y))."""
    m = ALL('y', eq(add(x, S(y)), S(add(x, y))))
    l1 = pf.ax('Q4L')
    l2 = pf.allE(l1, S(y))                                # 0+Sy = Sy
    l3 = pf.allE(l1, y)                                   # 0+y = y
    l4 = pf.refl(add(Z, y))
    l5 = pf.subst(l3, l4, 'u', eq(u, add(Z, y)))          # y = 0+y
    l6 = pf.subst(l5, l2, 'u', eq(add(Z, S(y)), S(u)))    # 0+Sy = S(0+y)
    l7 = pf.allI(l6, 'y')                                 # m(0)
    l8 = pf.hyp(m)
    l9 = pf.allE(l8, y)                                   # x+Sy = S(x+y)
    l10 = pf.ax('Q5L')
    l11 = pf.allE(l10, x)
    l12 = pf.allE(l11, S(y))                              # Sx+Sy = S(x+Sy)
    l13 = pf.subst(l9, l12, 'u', eq(add(S(x), S(y)), S(u)))   # Sx+Sy = SS(x+y)
    l14 = pf.allE(l11, y)                                 # Sx+y = S(x+y)
    l15 = pf.refl(add(S(x), y))
    l16 = pf.subst(l14, l15, 'u', eq(u, add(S(x), y)))    # S(x+y) = Sx+y
    l17 = pf.subst(l16, l13, 'u', eq(add(S(x), S(y)), S(u)))  # Sx+Sy = S(Sx+y)
    l18 = pf.allI(l17, 'y')                               # m(Sx)
    l19 = pf.impI(l18, m)
    l20 = pf.allI(l19, 'x')
    l21 = get_ind(pf, (('x',), m))
    return pf.tc([l7, l20, l21], ALL('x', m))

def d_q4l_from_right(pf, get_ind):
    """Q4L (Au 0+u=u) from Q4, Q5 and Ind(0+x=x)."""
    m = eq(add(Z, x), x)
    l1 = pf.ax('Q4')
    l2 = pf.allE(l1, Z)                                   # 0+0 = 0
    l3 = pf.hyp(m)
    l4 = pf.ax('Q5')
    l5 = pf.allE(l4, Z)
    l6 = pf.allE(l5, x)                                   # 0+Sx = S(0+x)
    l7 = pf.subst(l3, l6, 'u', eq(add(Z, S(x)), S(u)))    # 0+Sx = Sx
    l8 = pf.impI(l7, m)
    l9 = pf.allI(l8, 'x')
    l10 = get_ind(pf, (('x',), m))
    return pf.tc([l2, l9, l10], ALL('x', m))

def d_q5l_from_right(pf, get_ind):
    """Q5L (Au Av Su+v = S(u+v)) from Q4, Q5 and Ind(Sp+x = S(p+x)) with parameter p."""
    p = V('p')
    m = eq(add(S(p), x), S(add(p, x)))
    l1 = pf.ax('Q4')
    l2 = pf.allE(l1, S(p))                                # Sp+0 = Sp
    l3 = pf.allE(l1, p)                                   # p+0 = p
    l4 = pf.refl(add(p, Z))
    l5 = pf.subst(l3, l4, 'u', eq(u, add(p, Z)))          # p = p+0
    l6 = pf.subst(l5, l2, 'u', eq(add(S(p), Z), S(u)))    # Sp+0 = S(p+0)
    l7 = pf.hyp(m)
    l8 = pf.ax('Q5')
    l9 = pf.allE(l8, S(p))
    l10 = pf.allE(l9, x)                                  # Sp+Sx = S(Sp+x)
    l11 = pf.subst(l7, l10, 'u', eq(add(S(p), S(x)), S(u)))   # Sp+Sx = SS(p+x)
    l12 = pf.allE(l8, p)
    l13 = pf.allE(l12, x)                                 # p+Sx = S(p+x)
    l14 = pf.refl(add(p, S(x)))
    l15 = pf.subst(l13, l14, 'u', eq(u, add(p, S(x))))    # S(p+x) = p+Sx
    l16 = pf.subst(l15, l11, 'u', eq(add(S(p), S(x)), S(u)))  # Sp+Sx = S(p+Sx)
    l17 = pf.impI(l16, m)
    l18 = pf.allI(l17, 'x')
    l19 = get_ind(pf, (('x',), m))
    l20 = pf.tc([l6, l18, l19], ALL('x', m))
    return pf.allI(l20, 'p')
