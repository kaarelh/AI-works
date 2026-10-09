# zf.py -- ZF schemas and checked schematic derivations between them (track "pa", notes.md section 1(b)).
# Language {in, =}.  Schemas (motive = (distinguished variables, formula); other free variables are parameters):
#   SepJ(u.phi)      AX EY Au (u in Y <-> u in X & phi)                                  (Jech's wording)
#   ReplJ(x,y.psi)   Ax Ay Az (psi & psi[z/y] -> y = z) -> AX EY Ay (y in Y <-> Ex (x in X & psi))   (image form)
#   ReplK(x,y.psi)   AA (Ax (x in A -> Ey (psi & Au (psi[u/y] -> u = y))) -> EB Ax (x in A -> Ey (y in B & psi)))
#                    (bounding form with E! spelled out, as in Kunen; called ReplS in the axiom-schemas paper)
#   Coll(x,y.psi)    AA (Ax (x in A -> Ey psi) -> EB Ax (x in A -> Ey (y in B & psi)))
#   EInd(x.chi)      Ax (Ay (y in x -> chi[y/x]) -> chi) -> Ax chi
#   Found            AS (Ex x in S -> Ex (x in S & Ay (y in x -> ~ y in S)))               (single sentence)
from nd import *

a, b, x, y, z, u, w = (V(c) for c in 'abxyzuw')
X, Y, A, B, Sv = V('X'), V('Y'), V('A'), V('B'), V('S')

def _fr(name, avoid):
    """a bound-variable name for the schema's own binder, fresh for the motive (no capture of parameters)."""
    for c in [name] + [name + str(i) for i in range(1, 100)]:
        if c not in avoid: return c
    raise ValueError

def SepJ(m):
    (uv,), phi = m
    av = fv(phi) | {uv}
    Xn, Yn = _fr('X', av), _fr('Y', av)
    return ALL(Xn, EX(Yn, ALL(uv, IFF(mem(V(uv), V(Yn)), AND(mem(V(uv), V(Xn)), phi)))))

def ReplJ(m):
    (xv, yv), psi = m
    av = fv(psi) | {xv, yv}
    Xn, Yn, zn = _fr('X', av), _fr('Y', av), _fr('z', allvars(psi) | {xv, yv})
    return IMP(ALL(xv, ALL(yv, ALL(zn, IMP(AND(psi, subst(psi, yv, V(zn))), eq(V(yv), V(zn)))))),
               ALL(Xn, EX(Yn, ALL(yv, IFF(mem(V(yv), V(Yn)), EX(xv, AND(mem(V(xv), V(Xn)), psi)))))))

def ReplK(m):
    (xv, yv), psi = m
    av = fv(psi) | {xv, yv}
    An, Bn, un = _fr('A', av), _fr('B', av), _fr('u', allvars(psi) | {xv, yv})
    return ALL(An, IMP(ALL(xv, IMP(mem(V(xv), V(An)),
                                   EX(yv, AND(psi, ALL(un, IMP(subst(psi, yv, V(un)), eq(V(un), V(yv)))))))),
                       EX(Bn, ALL(xv, IMP(mem(V(xv), V(An)), EX(yv, AND(mem(V(yv), V(Bn)), psi)))))))

def Coll(m):
    (xv, yv), psi = m
    av = fv(psi) | {xv, yv}
    An, Bn = _fr('A', av), _fr('B', av)
    return ALL(An, IMP(ALL(xv, IMP(mem(V(xv), V(An)), EX(yv, psi))),
                       EX(Bn, ALL(xv, IMP(mem(V(xv), V(An)), EX(yv, AND(mem(V(yv), V(Bn)), psi)))))))

def EInd(m):
    (xv,), chi = m
    yn = _fr('y', allvars(chi) | {xv})
    return IMP(ALL(xv, IMP(ALL(yn, IMP(mem(V(yn), V(xv)), subst(chi, xv, V(yn)))), chi)), ALL(xv, chi))

FOUND = ALL('S', IMP(EX('x', mem(x, Sv)), EX('x', AND(mem(x, Sv), ALL('y', IMP(mem(y, x), NOT(mem(y, Sv))))))))
ZAX = {'Found': FOUND}
ZSCH = {'SepJ': SepJ, 'ReplJ': ReplJ, 'ReplK': ReplK, 'Coll': Coll, 'EInd': EInd}

Pu = pred('P', u)            # unary schematic motive (with hidden parameters)
Rxy = pred('R', x, y)        # binary schematic motive

def cite(name, m):
    return lambda pf: pf.ax(name, m)

def d_sep_from_replj(pf, phi_u, get_repl):
    """SepJ(u.phi) from ReplJ(x,y. phi(x) & y = x).  phi_u has distinguished variable u."""
    ph = lambda t: subst(phi_u, 'u', t)
    psi = AND(ph(x), eq(y, x))
    # functionality
    h = pf.hyp(AND(psi, AND(ph(x), eq(z, x))))
    l1 = pf.tc([h], eq(y, x))
    l2 = pf.tc([h], eq(z, x))
    l3 = pf.refl(z)
    l4 = pf.subst(l2, l3, 'w', eq(w, z))                       # x = z
    l5 = pf.subst(l4, l1, 'w', eq(y, w))                       # y = z
    l6 = pf.impI(l5, AND(psi, AND(ph(x), eq(z, x))))
    l7 = pf.allI(l6, 'z'); l8 = pf.allI(l7, 'y'); l9 = pf.allI(l8, 'x')
    l10 = get_repl(pf)
    l11 = pf.tc([l9, l10], ALL('X', EX('Y', ALL('y', IFF(mem(y, Y), EX('x', AND(mem(x, X), psi)))))))
    l12 = pf.allE(l11, X)
    Bf = ALL('y', IFF(mem(y, Y), EX('x', AND(mem(x, X), psi))))
    l13 = pf.hyp(Bf)
    l14 = pf.allE(l13, u)                                     # u in Y <-> Ex(x in X & phi(x) & u = x)
    E = EX('x', AND(mem(x, X), AND(ph(x), eq(u, x))))
    l15 = pf.hyp(AND(mem(x, X), AND(ph(x), eq(u, x))))
    l16 = pf.tc([l15], eq(u, x))
    l17 = pf.refl(u)
    l18 = pf.subst(l16, l17, 'w', eq(w, u))                   # x = u
    l19 = pf.tc([l15], mem(x, X))
    l20 = pf.subst(l18, l19, 'w', mem(w, X))                  # u in X
    l21 = pf.tc([l15], ph(x))
    l22 = pf.subst(l18, l21, 'w', ph(w))                      # phi(u)
    l23 = pf.tc([l20, l22], AND(mem(u, X), ph(u)))
    l24 = pf.hyp(E)
    l25 = pf.exE(l24, l23, 'x')
    l26 = pf.impI(l25, E)
    l27 = pf.hyp(AND(mem(u, X), ph(u)))
    l28 = pf.tc([l27, l17], AND(mem(u, X), AND(ph(u), eq(u, u))))
    l29 = pf.exI(l28, 'x', AND(mem(x, X), AND(ph(x), eq(u, x))), u)
    l30 = pf.impI(l29, AND(mem(u, X), ph(u)))
    l31 = pf.tc([l14, l26, l30], IFF(mem(u, Y), AND(mem(u, X), ph(u))))
    l32 = pf.allI(l31, 'u')
    body = ALL('u', IFF(mem(u, Y), AND(mem(u, X), ph(u))))
    l33 = pf.exI(l32, 'Y', body, Y)
    l34 = pf.exE(l12, l33, 'Y')
    return pf.allI(l34, 'X')

def d_found_from_eind(pf, get_eind):
    """Found from EInd(x. ~ x in S) (pure logic)."""
    EP = EX('x', mem(x, Sv))
    gb = AND(mem(x, Sv), ALL('y', IMP(mem(y, x), NOT(mem(y, Sv)))))
    Ng = NOT(EX('x', gb))
    Af = ALL('y', IMP(mem(y, x), NOT(mem(y, Sv))))
    l1 = pf.hyp(EP); l2 = pf.hyp(Ng); l3 = pf.hyp(Af); l4 = pf.hyp(mem(x, Sv))
    l5 = pf.tc([l3, l4], gb)
    l6 = pf.exI(l5, 'x', gb, x)
    l7 = pf.tc([l2, l6], BOT)
    l8 = pf.impI(l7, mem(x, Sv))
    l9 = pf.tc([l8], NOT(mem(x, Sv)))
    l10 = pf.impI(l9, Af)
    l11 = pf.allI(l10, 'x')
    l12 = get_eind(pf)
    l13 = pf.tc([l11, l12], ALL('x', NOT(mem(x, Sv))))
    l14 = pf.hyp(mem(w, Sv))
    l15 = pf.allE(l13, w)
    l16 = pf.tc([l14, l15], BOT)
    l17 = pf.exE(l1, l16, 'w')
    l18 = pf.impI(l17, Ng)
    l19 = pf.tc([l18], EX('x', gb))
    l20 = pf.impI(l19, EP)
    return pf.allI(l20, 'S')

def d_replk_from_coll(pf, psi, get_coll):
    """ReplK(x,y.psi) from Coll(x,y.psi) (pure logic: the E! antecedent implies the E antecedent)."""
    uniq = lambda yy: AND(subst(psi, 'y', yy), ALL('u', IMP(subst(psi, 'y', u), eq(u, yy))))
    Ant = ALL('x', IMP(mem(x, A), EX('y', uniq(y))))
    l1 = pf.hyp(Ant)
    l2 = pf.hyp(mem(x, A))
    l3 = pf.allE(l1, x)
    l4 = pf.tc([l2, l3], EX('y', uniq(y)))
    l5 = pf.hyp(uniq(w))
    l6 = pf.tc([l5], subst(psi, 'y', w))
    l7 = pf.exI(l6, 'y', psi, w)
    l8 = pf.exE(l4, l7, 'w')
    l9 = pf.impI(l8, mem(x, A))
    l10 = pf.allI(l9, 'x')
    l11 = get_coll(pf)
    l12 = pf.allE(l11, A)
    l13 = pf.tc([l10, l12], EX('B', ALL('x', IMP(mem(x, A), EX('y', AND(mem(y, B), psi))))))
    l14 = pf.impI(l13, Ant)
    return pf.allI(l14, 'A')

def d_replj_from_coll_sep(pf, psi, get_coll, get_sep):
    """ReplJ(x,y.psi) from Coll(x,y.psi) and two Separation instances:
    SepJ(u. Ey psi(u,y)) and SepJ(u. Ex (x in X & psi(x,u)))."""
    R = lambda s, t: subst(subst(psi, 'y', t), 'x', s)
    Fun = ALL('x', ALL('y', ALL('z', IMP(AND(R(x, y), R(x, z)), eq(y, z)))))
    l1 = pf.hyp(Fun)
    s1 = (('u',), EX('y', R(u, y)))
    l2 = get_sep(pf, s1)
    l3 = pf.allE(l2, X)                                        # EY Au (u in Y <-> u in X & Ey R(u,y))
    DA = ALL('u', IFF(mem(u, A), AND(mem(u, X), EX('y', R(u, y)))))
    l4 = pf.hyp(DA)
    l5 = pf.hyp(mem(x, A))
    l6 = pf.allE(l4, x)
    l7 = pf.tc([l5, l6], EX('y', R(x, y)))
    l8 = pf.impI(l7, mem(x, A))
    l9 = pf.allI(l8, 'x')
    l10 = get_coll(pf)
    l11 = pf.allE(l10, A)
    l12 = pf.tc([l9, l11], EX('B', ALL('x', IMP(mem(x, A), EX('y', AND(mem(y, B), R(x, y)))))))
    DB = ALL('x', IMP(mem(x, A), EX('y', AND(mem(y, B), R(x, y)))))
    l13 = pf.hyp(DB)
    s2 = (('u',), EX('x', AND(mem(x, X), R(x, u))))
    l14 = get_sep(pf, s2)
    l15 = pf.allE(l14, B)                                      # EY Au (u in Y <-> u in B & Ex (x in X & R(x,u)))
    DY = ALL('u', IFF(mem(u, Y), AND(mem(u, B), EX('x', AND(mem(x, X), R(x, u))))))
    l16 = pf.hyp(DY)
    l17 = pf.allE(l16, y)
    E = EX('x', AND(mem(x, X), R(x, y)))
    l18 = pf.hyp(E)
    l19 = pf.hyp(AND(mem(x, X), R(x, y)))
    l20 = pf.tc([l19], R(x, y))
    l21 = pf.exI(l20, 'y', R(x, y), y)                         # Ey R(x,y)
    l22 = pf.tc([l6, l19, l21], mem(x, A))
    l23 = pf.allE(l13, x)
    l24 = pf.tc([l22, l23], EX('y', AND(mem(y, B), R(x, y))))
    l25 = pf.hyp(AND(mem(w, B), R(x, w)))
    l26 = pf.allE(l1, x); l27 = pf.allE(l26, w); l28 = pf.allE(l27, y)
    l29 = pf.tc([l25, l20, l28], eq(w, y))
    l30 = pf.tc([l25], mem(w, B))
    l31 = pf.subst(l29, l30, 'z', mem(z, B))                   # y in B
    l32 = pf.exE(l24, l31, 'w')
    l33 = pf.exE(l18, l32, 'x')
    l34 = pf.tc([l17, l33, l18], mem(y, Y))
    l35 = pf.impI(l34, E)
    l36 = pf.tc([l17, l35], IFF(mem(y, Y), E))
    l37 = pf.allI(l36, 'y')
    body = ALL('y', IFF(mem(y, Y), EX('x', AND(mem(x, X), R(x, y)))))
    l38 = pf.exI(l37, 'Y', body, Y)
    l39 = pf.exE(l15, l38, 'Y')
    l40 = pf.exE(l12, l39, 'B')
    l41 = pf.exE(l3, l40, 'A')
    l42 = pf.allI(l41, 'X')
    return pf.impI(l42, Fun)
