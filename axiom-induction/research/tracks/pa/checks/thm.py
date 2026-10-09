# thm.py -- checked derivations of a small library of induction THEOREMS in Q + Ind (track "pa", notes-final.md
# section 3, "theorem data").  Each derivation takes a provider get_ind(pf, motive) -> line index of a closed line
# |- Ind(motive), so it runs in T_Ind (cite), in T_CVI (Ind derived from CVI, arith.d_ind_from_cvi) or in T_LNP.
# Lemmas can be derived in-line or cited (when a theory has adopted them as axioms): get_lemma(pf, name) -> line.
#
# Variable conventions (the checker refuses capture in allE, so names are chosen to avoid it): the induction
# variable is always 'x' (arith.d_ind_from_cvi requires this); parameters are a, b, q; 'z' is the placeholder of
# subst lines.  Every derivation is checked line by line by nd.Proof and its conclusion by check_closed.
from nd import *
import arith
from arith import AX

x, a, b, q, z, v = V('x'), V('a'), V('b'), V('q'), V('z'), V('v')

def sym(pf, li, s, t):
    """from line li |- s = t derive |- t = s (two lines: refl t... via subst)."""
    r = pf.refl(s)                                       # s = s
    return pf.subst(li, r, 'z', eq(z, s))                # (z = s)[s/z] = (s = s)  ==>  t = s

# ---------------------------------------------------------------------------------------------- theorems
THM = {
    'snx':   ALL('x', NOT(eq(S(x), x))),                                         # Ax ~(Sx = x)
    'mul0':  ALL('x', eq(mul(Z, x), Z)),                                         # Ax 0*x = 0
    'add0l': ALL('x', eq(add(Z, x), x)),                                         # Ax 0+x = x  (= Q4L)
    'addSl': ALL('a', ALL('v', eq(add(S(a), v), S(add(a, v))))),                 # Aa Av Sa+v = S(a+v) (= Q5L)
    'comm':  ALL('q', ALL('x', eq(add(x, q), add(q, x)))),                       # Aq Ax x+q = q+x
    'assoc': ALL('a', ALL('b', ALL('x', eq(add(add(a, b), x), add(a, add(b, x)))))),
}

def d_snx(pf, get_ind, get_lemma=None):
    m = NOT(eq(S(x), x))
    l1 = pf.ax('Q1'); l2 = pf.allE(l1, Z)                                       # ~(S0 = 0)
    l3 = pf.hyp(m)
    l4 = pf.ax('Q2'); l5 = pf.allE(l4, S(x)); l6 = pf.allE(l5, x)               # SSx = Sx -> Sx = x
    l7 = pf.tc([l3, l6], NOT(eq(S(S(x)), S(x))))
    l8 = pf.impI(l7, m); l9 = pf.allI(l8, 'x')
    l10 = get_ind(pf, (('x',), m))
    return pf.tc([l2, l9, l10], ALL('x', m))

def d_mul0(pf, get_ind, get_lemma=None):
    m = eq(mul(Z, x), Z)
    l1 = pf.ax('Q6'); l2 = pf.allE(l1, Z)                                       # 0*0 = 0
    l3 = pf.hyp(m)
    l4 = pf.ax('Q7'); l5 = pf.allE(l4, Z); l6 = pf.allE(l5, x)                  # 0*Sx = 0*x + 0
    l7 = pf.ax('Q4'); l8 = pf.allE(l7, mul(Z, x))                               # 0*x + 0 = 0*x
    l9 = pf.subst(l8, l6, 'z', eq(mul(Z, S(x)), z))                             # 0*Sx = 0*x
    l10 = pf.subst(l3, l9, 'z', eq(mul(Z, S(x)), z))                            # 0*Sx = 0
    l11 = pf.impI(l10, m); l12 = pf.allI(l11, 'x')
    l13 = get_ind(pf, (('x',), m))
    return pf.tc([l2, l12, l13], ALL('x', m))

def d_add0l(pf, get_ind, get_lemma=None):
    return arith.d_q4l_from_right(pf, get_ind)                                  # |- Ax 0+x = x

def d_addSl(pf, get_ind, get_lemma=None):
    """Aa Av (Sa+v = S(a+v)), by induction on x with parameter a, then renaming x to v (so that a later allE with
    the term x does not capture)."""
    m = eq(add(S(a), x), S(add(a, x)))
    l1 = pf.ax('Q4')
    l2 = pf.allE(l1, S(a))                                                      # Sa+0 = Sa
    l3 = pf.allE(l1, a)                                                         # a+0 = a
    l5 = sym(pf, l3, add(a, Z), a)                                              # a = a+0
    l6 = pf.subst(l5, l2, 'z', eq(add(S(a), Z), S(z)))                          # Sa+0 = S(a+0)
    l7 = pf.hyp(m)
    l8 = pf.ax('Q5'); l9 = pf.allE(l8, S(a)); l10 = pf.allE(l9, x)              # Sa+Sx = S(Sa+x)
    l11 = pf.subst(l7, l10, 'z', eq(add(S(a), S(x)), S(z)))                     # Sa+Sx = SS(a+x)
    l12 = pf.allE(l8, a); l13 = pf.allE(l12, x)                                 # a+Sx = S(a+x)
    l15 = sym(pf, l13, add(a, S(x)), S(add(a, x)))                              # S(a+x) = a+Sx
    l16 = pf.subst(l15, l11, 'z', eq(add(S(a), S(x)), S(z)))                    # Sa+Sx = S(a+Sx)
    l17 = pf.impI(l16, m); l18 = pf.allI(l17, 'x')
    l19 = get_ind(pf, (('x',), m))
    l20 = pf.tc([l6, l18, l19], ALL('x', m))                                    # Ax (Sa+x = S(a+x))
    l21 = pf.allE(l20, v); l22 = pf.allI(l21, 'v')                              # rename: Av (Sa+v = S(a+v))
    return pf.allI(l22, 'a')

def lemma_inline(name, get_ind):
    f = {'add0l': d_add0l, 'addSl': d_addSl}[name]
    return lambda pf: f(pf, get_ind)

def d_comm(pf, get_ind, get_lemma):
    """Aq Ax (x+q = q+x) by induction on x with parameter q, from the lemmas add0l and addSl."""
    m = eq(add(x, q), add(q, x))
    L1 = get_lemma(pf, 'add0l')                                                 # Ax 0+x = x
    L2 = get_lemma(pf, 'addSl')                                                 # Aa Av Sa+v = S(a+v)
    l1 = pf.allE(L1, q)                                                         # 0+q = q
    l2 = pf.ax('Q4'); l3 = pf.allE(l2, q)                                       # q+0 = q
    l4 = sym(pf, l3, add(q, Z), q)                                              # q = q+0
    l5 = pf.subst(l4, l1, 'z', eq(add(Z, q), z))                                # 0+q = q+0     (base)
    l6 = pf.hyp(m)
    l7 = pf.allE(L2, x); l8 = pf.allE(l7, q)                                    # Sx+q = S(x+q)
    l9 = pf.subst(l6, l8, 'z', eq(add(S(x), q), S(z)))                          # Sx+q = S(q+x)
    l10 = pf.ax('Q5'); l11 = pf.allE(l10, q); l12 = pf.allE(l11, x)             # q+Sx = S(q+x)
    l13 = sym(pf, l12, add(q, S(x)), S(add(q, x)))                              # S(q+x) = q+Sx
    l14 = pf.subst(l13, l9, 'z', eq(add(S(x), q), z))                           # Sx+q = q+Sx   (step)
    l15 = pf.impI(l14, m); l16 = pf.allI(l15, 'x')
    l17 = get_ind(pf, (('x',), m))
    l18 = pf.tc([l5, l16, l17], ALL('x', m))
    return pf.allI(l18, 'q')

def d_assoc(pf, get_ind, get_lemma=None):
    """Aa Ab Ax ((a+b)+x = a+(b+x)), by induction on x with parameters a, b (uses Q4, Q5 only)."""
    m = eq(add(add(a, b), x), add(a, add(b, x)))
    l1 = pf.ax('Q4'); l2 = pf.allE(l1, add(a, b))                               # (a+b)+0 = a+b
    l3 = pf.allE(l1, b)                                                         # b+0 = b
    l4 = sym(pf, l3, add(b, Z), b)                                              # b = b+0
    l5 = pf.subst(l4, l2, 'z', eq(add(add(a, b), Z), add(a, z)))                # (a+b)+0 = a+(b+0)  (base)
    l6 = pf.hyp(m)
    l7 = pf.ax('Q5'); l8 = pf.allE(l7, add(a, b)); l9 = pf.allE(l8, x)          # (a+b)+Sx = S((a+b)+x)
    l10 = pf.subst(l6, l9, 'z', eq(add(add(a, b), S(x)), S(z)))                 # (a+b)+Sx = S(a+(b+x))
    l11 = pf.allE(l7, a); l12 = pf.allE(l11, add(b, x))                         # a+S(b+x) = S(a+(b+x))
    l13 = sym(pf, l12, add(a, S(add(b, x))), S(add(a, add(b, x))))              # S(a+(b+x)) = a+S(b+x)
    l14 = pf.subst(l13, l10, 'z', eq(add(add(a, b), S(x)), z))                  # (a+b)+Sx = a+S(b+x)
    l15 = pf.allE(l7, b); l16 = pf.allE(l15, x)                                 # b+Sx = S(b+x)
    l17 = sym(pf, l16, add(b, S(x)), S(add(b, x)))                              # S(b+x) = b+Sx
    l18 = pf.subst(l17, l14, 'z', eq(add(add(a, b), S(x)), add(a, z)))          # (a+b)+Sx = a+(b+Sx)  (step)
    l19 = pf.impI(l18, m); l20 = pf.allI(l19, 'x')
    l21 = get_ind(pf, (('x',), m))
    l22 = pf.tc([l5, l20, l21], ALL('x', m))
    l23 = pf.allI(l22, 'b')
    return pf.allI(l23, 'a')

DERIV = {'snx': d_snx, 'mul0': d_mul0, 'add0l': d_add0l, 'addSl': d_addSl, 'comm': d_comm, 'assoc': d_assoc}

# ---------------------------------------------------------------------------------------------- providers
def ind_cite(pf, m):
    return pf.ax('Ind', m)

def ind_via_cvi(pf, m):
    (xv,), phi = m
    assert xv == 'x'
    return arith.d_ind_from_cvi(pf, phi, lambda p: p.ax('CVI', m))

def ind_via_lnp(pf, m):
    (xv,), phi = m
    assert xv == 'x'
    cvi = lambda p: arith.d_cvi_from_lnp_neg(p, phi, lambda pp: pp.ax('LNP', (('x',), NOT(phi))))
    return arith.d_ind_from_cvi(pf, phi, cvi)

def lemmas_inline(get_ind):
    return lambda pf, name: DERIV[name](pf, get_ind)

def lemmas_cited(pf, name):
    return pf.ax(name)

AXT = dict(AX)
AXT.update(THM)          # theories that adopt theorems as axioms cite them by name
