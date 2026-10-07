# Track C: motive pool (bodies with hole 0 = the induction variable x) and the witness predicates.
from so_core import *

y = V(0)   # inside a motive's own quantifier, its bound variable is index 0
POOL = {
    # atomic
    'x=x': eq(X, X), 'x=0': eq(X, Z), '0=x': eq(Z, X), '0=0': eq(Z, Z), 'Sx=x': eq(S(X), X),
    'x+0=x': eq(add(X, Z), X), '0+x=x': eq(add(Z, X), X), 'x+x=x': eq(add(X, X), X),
    'Sx=S0': eq(S(X), S(Z)), 'Sx=0': eq(S(X), Z), 'x+0=0': eq(add(X, Z), Z), 'S0=0': eq(S(Z), Z),
    # negations
    '~x=0': NOT(eq(X, Z)), '~Sx=0': NOT(eq(S(X), Z)), '~x=Sx': NOT(eq(X, S(X))), '~0=S0': NOT(eq(Z, S(Z))),
    '~x+0=S0': NOT(eq(add(X, Z), S(Z))),
    # binary connectives
    'x=0&x=x': AND(eq(X, Z), eq(X, X)), 'x=x->x=0': IMP(eq(X, X), eq(X, Z)), '0=0&x=x': AND(eq(Z, Z), eq(X, X)),
    'Sx=0->0=S0': IMP(eq(S(X), Z), eq(Z, S(Z))), '0=0->0=0': IMP(eq(Z, Z), eq(Z, Z)),
    # quantified
    'Ay.y+x=x+y': ALL(eq(add(y, X), add(X, y))), 'Ay.(x=y->y=x)': ALL(IMP(eq(X, y), eq(y, X))),
    'Ay.~Sy=x': ALL(NOT(eq(S(y), X))), 'Ay.y=y': ALL(eq(y, y)), 'Ay.y+Sx=S(y+x)': ALL(eq(add(y, S(X)), S(add(y, X)))),
}
NAMES_POOL = list(POOL)
HELD = [Ind(m) for m in POOL.values()]   # held-out genuine induction instances

def unshieldable_x(m):
    """does the motive have a free occurrence of x that is not inside any proper term t != x with
    FV(t) subset of {x}?  (occurrence directly under '=' or under a function symbol whose term
    contains a variable bound inside the motive)"""
    found = [False]
    def term_fv_ok(t, j):
        # FV(t) relative to the motive: holes allowed, internal bound vars (index < j) not allowed
        if t[0] == 'v': return False if t[1] < j else True
        return all(term_fv_ok(k, j) for k in kids(t))
    def walk(t, j, parent):
        if t[0] == 'h':
            if parent is None or parent[0] == 'eq' or not term_fv_ok(parent, j):
                found[0] = True
            return
        if t[0] in BINDERS:
            walk(t[1], j + 1, None); return
        if t[0] in FORM_HEADS:
            for k in kids(t): walk(k, j, t if t[0] == 'eq' else None)
            return
        for k in kids(t): walk(k, j, t)
    walk(m, 0, None)
    return found[0]

def pred_R(ms): return len({root(m) for m in ms}) >= 2
def pred_N(ms): return any(x_free(m) for m in ms)
def pred_B(ms): return any(unshieldable_x(m) for m in ms)
