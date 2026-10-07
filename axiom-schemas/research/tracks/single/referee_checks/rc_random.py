# Referee's random DT° templates, bodies, and data (independent of the author's dtrandom.py).
import random
from rc_core import *

TERM_CONSTS = [Z, ('a',), ('b',)]


def rterm(rng, b, d, metas=None, occ_prob=0.0):
    """random object term at binder depth b; may contain term-metavariable occurrences"""
    if metas and rng.random() < occ_prob:
        tm = [m for m in metas if m[0].islower()]
        if tm:
            return rocc(rng, rng.choice(tm), metas[rng.choice(tm)] if False else None, b)
    r = rng.random()
    if d <= 0 or r < 0.45:
        if b > 0 and rng.random() < 0.6:
            return V(rng.randrange(b))
        return rng.choice(TERM_CONSTS[:2])
    if r < 0.85:
        return S(rterm(rng, b, d - 1))
    return ADD(rterm(rng, b, d - 1), rterm(rng, b, d - 1))


def rocc(rng, name, _unused, b, arity=None, pattern=None):
    raise NotImplementedError


def random_template(rng, metas, max_tries=200):
    """metas: dict name -> arity.  Build a conjunction of 2-3 components, each component a small
    formula under some binders containing occurrences.  Returns a DT° template using all metas."""
    names = list(metas)
    for _ in range(max_tries):
        comps = []
        ncomp = rng.choice([2, 2, 3])
        # decide pattern placement: each metavariable gets one pattern occurrence in a random comp
        for c in range(ncomp):
            comps.append([])
        for nm in names:
            comps[rng.randrange(ncomp)].append(('pat', nm))
        # extra derived occurrences
        for nm in names:
            for _k in range(rng.choice([0, 1, 1, 2])):
                comps[rng.randrange(ncomp)].append(('der', nm))
        parts = []
        okay = True
        for items in comps:
            f = build_component(rng, items, metas)
            if f is None:
                okay = False
                break
            parts.append(f)
        if not okay:
            continue
        T = parts[0]
        for f in parts[1:]:
            T = AND(T, f)
        if is_DT0(T) and set(metas) == set(metas_in(T)) and size(T) <= 40:
            return T
    return None


def metas_in(T):
    return list(metas(T).keys())


def occ_term(rng, nm, ar, kind, b):
    if kind == 'pat':
        if b < ar:
            return None
        ys = rng.sample(range(b), ar)
        return M(nm, *[V(y) for y in ys])
    args = [rterm(rng, b, 1) for _ in range(ar)]
    return M(nm, *args)


def build_component(rng, items, metas):
    """a formula under nb binders containing the listed occurrences"""
    need_b = max([metas[nm] for k, nm in items if k == 'pat'] + [0])
    nb = need_b + rng.choice([0, 0, 1])
    nb = min(nb, 3)
    b = nb
    atoms = []
    for kind, nm in items:
        o = occ_term(rng, nm, metas[nm], kind, b)
        if o is None:
            return None
        if nm[0].isupper():
            atoms.append(o)
        else:
            other = rterm(rng, b, 1)
            wrap = rng.random()
            if wrap < 0.2:
                o = S(o)
            atoms.append(EQ(o, other) if rng.random() < 0.5 else EQ(other, o))
    if not atoms:
        atoms.append(EQ(rterm(rng, b, 1), rterm(rng, b, 1)))
    if rng.random() < 0.3:
        atoms.append(EQ(rterm(rng, b, 1), rterm(rng, b, 1)))
    rng.shuffle(atoms)
    f = atoms[0]
    for a in atoms[1:]:
        f = rng.choice([AND, IMP])(f, a)
    if rng.random() < 0.2:
        f = NOT(f)
    for _ in range(nb):
        f = rng.choice([ALL, ALL, EX])(f)
    return f


def rbody(rng, name, ar, d=2):
    """random body for metavariable of given arity; holes z0..z_{ar-1}; may use own binders"""
    if name[0].islower():
        return rbterm(rng, ar, 0, d)
    return rbform(rng, ar, 0, d)


def rbterm(rng, ar, k, d):
    r = rng.random()
    if d <= 0 or r < 0.5:
        opts = []
        if ar > 0:
            opts += [('z', rng.randrange(ar))] * 3
        if k > 0:
            opts += [V(rng.randrange(k))]
        opts += [Z, Z, ('a',)]
        return rng.choice(opts)
    if r < 0.85:
        return S(rbterm(rng, ar, k, d - 1))
    return ADD(rbterm(rng, ar, k, d - 1), rbterm(rng, ar, k, d - 1))


def rbform(rng, ar, k, d):
    r = rng.random()
    if d <= 0 or r < 0.45:
        return rng.choice([EQ, IN])(rbterm(rng, ar, k, 1), rbterm(rng, ar, k, 1))
    if r < 0.6:
        return NOT(rbform(rng, ar, k, d - 1))
    if r < 0.8:
        return rng.choice([AND, IMP])(rbform(rng, ar, k, d - 1), rbform(rng, ar, k, d - 1))
    return rng.choice([ALL, EX])(rbform(rng, ar, k + 1, d - 1))


def candidate_bodies(name, ar):
    """a fixed, deliberately adversarial finite set of bodies (projections, constants, varied roots)"""
    zs = [('z', m) for m in range(ar)]
    if name[0].islower():
        out = list(zs) + [Z, ('a',), S(Z)] + [S(z) for z in zs]
        if ar >= 2:
            out.append(ADD(zs[0], zs[1]))
        if ar >= 1:
            out.append(ADD(zs[0], Z))
        return out
    out = [EQ(Z, Z), NOT(EQ(Z, Z)), ALL(EQ(V(0), V(0)))]
    for z in zs:
        out += [EQ(z, z), EQ(z, Z), NOT(EQ(Z, z)), IN(z, ('a',))]
    if ar >= 2:
        out += [EQ(zs[0], zs[1]), IN(zs[1], zs[0])]
    return out
