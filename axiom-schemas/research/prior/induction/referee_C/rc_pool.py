# Referee C: motive pool (independent of so_pool), richer than the authors': includes v, E, *,
# internal rebinding, shielding patterns, and random motives.
import random
from rc_core import *

y0, y1 = V(0), V(1)   # inside a motive body: relative levels of the motive's own binders
HAND = {
    'x=x': EQ(X, X), '~x=0': NOT(EQ(X, Z())), 'x=0': EQ(X, Z()), '0=x': EQ(Z(), X), '0=0': EQ(Z(), Z()),
    'Sx=S0': EQ(S(X), S(Z())), '~Sx=0': NOT(EQ(S(X), Z())), 'x*x=x': EQ(MUL(X, X), X),
    'Sx*Sx=0': EQ(MUL(S(X), S(X)), Z()),                       # shielded only
    'x=0|~x=0': OR(EQ(X, Z()), NOT(EQ(X, Z()))),
    'x=0&Ay.y=y': AND(EQ(X, Z()), ALL(EQ(y0, y0))),             # rebinding-style
    'Ey.x=y*y': EX(EQ(X, MUL(y0, y0))),
    'Ay.Sx=y': ALL(EQ(S(X), y0)),                                # shielded under a binder
    'Ay.x*y=y*x': ALL(EQ(MUL(X, y0), MUL(y0, X))),               # unshielded via y
    'Ay.S(x+y)=0': ALL(EQ(S(ADD(X, y0)), Z())),                  # x+y contains y: unshielded
    'Ey.(x+0)*y=0': EX(EQ(MUL(ADD(X, Z()), y0), Z())),           # parent x+0: shielded
    'Ey.Az.y=z': EX(ALL(EQ(y0, y1))),                            # closed, quantified
    '0=0>0=S0': IMP(EQ(Z(), Z()), EQ(Z(), S(Z()))),             # closed
    'Ax.x=x-ish': ALL(EQ(y0, y0)),                               # closed quantified (x rebound)
    'SSx=x+S0': EQ(S(S(X)), ADD(X, S(Z()))),                     # x shielded everywhere
    '~(x=x)': NOT(EQ(X, X)),
    'Ey.y=x': EX(EQ(y0, X)),
}

def rand_term(rng, depth, nb, xprob=0.4):
    """random term over 0, S, +, *, x (hole) and internal variables y_0..y_{nb-1}"""
    if depth == 0 or rng.random() < 0.35:
        r = rng.random()
        if r < xprob: return X
        if nb and r < xprob + 0.3: return V(rng.randrange(nb))
        return Z()
    k = rng.choice(['S', 'S', '+', '*'])
    if k == 'S': return S(rand_term(rng, depth - 1, nb, xprob))
    return (k, rand_term(rng, depth - 1, nb, xprob), rand_term(rng, depth - 1, nb, xprob))

def rand_motive(rng, depth=3, nb=0):
    if depth == 0 or rng.random() < 0.3:
        return EQ(rand_term(rng, 2, nb), rand_term(rng, 2, nb))
    k = rng.choice(['~', '&', '|', '>', 'A', 'E', '='])
    if k == '=': return EQ(rand_term(rng, 2, nb), rand_term(rng, 2, nb))
    if k == '~': return NOT(rand_motive(rng, depth - 1, nb))
    if k in BIND: return (k, rand_motive(rng, depth - 1, nb + 1))
    return (k, rand_motive(rng, depth - 1, nb), rand_motive(rng, depth - 1, nb))

def pool(seed=1, n=30):
    rng = random.Random(seed)
    P = dict(HAND)
    while len(P) < len(HAND) + n:
        m = rand_motive(rng, 3)
        if size(m) <= 12: P['r:' + ppm(m)] = m
    return P

def pR(ms): return len({root(m) for m in ms}) >= 2
def pN(ms): return any(x_free(m) for m in ms)
def pB(ms): return any(unshielded(m) for m in ms)
