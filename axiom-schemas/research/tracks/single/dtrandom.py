# Track "single": random DT° templates and random substitutions (for the computational checks).
import random
from dtcore import *

TERM_CONSTS = ('0', 'pa')


def rand_term(rng, depth, size, holes_n=0, p_hole=0.4, consts=TERM_CONSTS, allow_add=True):
    """random term over bound vars < depth, holes < holes_n, constants, S, add; size <= size"""
    leaves = [(c,) for c in consts] + [V(k) for k in range(depth)]
    hl = [H(m) for m in range(holes_n)]
    if size <= 1 or rng.random() < 0.45:
        if hl and rng.random() < p_hole:
            return rng.choice(hl)
        return rng.choice(leaves)
    if allow_add and size >= 3 and rng.random() < 0.35:
        a = rng.randint(1, size - 2)
        return add(rand_term(rng, depth, a, holes_n, p_hole, consts, allow_add),
                   rand_term(rng, depth, size - 1 - a, holes_n, p_hole, consts, allow_add))
    return S(rand_term(rng, depth, size - 1, holes_n, p_hole, consts, allow_add))


def rand_formula_body(rng, n, size=5):
    """random closed formula body with holes < n (may contain internal binders)"""
    r = rng.random()
    if r < 0.45 or size < 4:
        return eq(rand_term(rng, 0, 2, n, 0.6), rand_term(rng, 0, 2, n, 0.6))
    if r < 0.6:
        return NOT(rand_formula_body(rng, n, size - 1))
    if r < 0.75:
        return AND(eq(rand_term(rng, 0, 2, n, 0.6), rand_term(rng, 0, 1, n, 0.6)),
                   eq(rand_term(rng, 0, 1, n, 0.6), rand_term(rng, 0, 2, n, 0.6)))
    if r < 0.88:
        # internal binder: Ay (term = term) with y available
        return ALL(eq(rand_term(rng, 1, 2, n, 0.5), rand_term(rng, 1, 2, n, 0.5)))
    return IMP(eq(rand_term(rng, 0, 1, n, 0.6), Z), eq(rand_term(rng, 0, 2, n, 0.6), Z))


def rand_body(rng, srt, n):
    if srt == 'T':
        r = rng.random()
        if n > 0 and r < 0.3:
            return H(rng.randrange(n))
        return rand_term(rng, 0, rng.randint(1, 3), n, 0.5)
    return rand_formula_body(rng, n)


MSPECS = [('f', 1), ('g', 2), ('c', 0), ('P', 1), ('Q', 2), ('A', 0)]


def rand_template(rng, nmeta=None, max_derived=2, nclauses=None):
    """random DT° template: a conjunction of clauses Ax..Ay body; metavariables placed inside"""
    if nmeta is None:
        nmeta = rng.choice([1, 1, 2])
    specs = rng.sample(MSPECS, nmeta)
    if nclauses is None:
        nclauses = rng.choice([2, 2, 3])
    # occurrence plan: list of (name, kind) kind in {'pat','der'}
    plan = []
    for (nm, ar) in specs:
        plan.append((nm, ar, 'pat'))
        for _ in range(rng.randint(0 if ar else 1, max_derived)):
            plan.append((nm, ar, 'der' if ar else 'pat'))
    rng.shuffle(plan)
    # ensure pattern occurrence placed in a clause with enough binders
    clauses = [[] for _ in range(nclauses)]
    for item in plan:
        clauses[rng.randrange(nclauses)].append(item)
    out = []
    for cl in clauses:
        need = max([ar for (_, ar, k) in cl if k == 'pat'] + [0])
        nb = max(need, rng.choice([0, 1, 1, 2]))
        nb = min(nb, 2) if need <= 2 else need
        parts = []
        for (nm, ar, kind) in cl:
            if kind == 'pat':
                args = tuple(V(k) for k in rng.sample(range(nb), ar))
            else:
                args = tuple(rand_term(rng, nb, rng.randint(1, 2), 0) for _ in range(ar))
                if is_pattern_args(args) and ar > 0:
                    args = (S(args[0]),) + args[1:]
            occ = M(nm, *args)
            if msort(nm) == 'F':
                parts.append(occ if rng.random() < 0.7 else NOT(occ))
            else:
                other = rand_term(rng, nb, rng.randint(1, 2), 0)
                lhs = occ if rng.random() < 0.7 else S(occ)
                parts.append(eq(lhs, other) if rng.random() < 0.5 else eq(other, lhs))
        if not parts:
            parts.append(eq(rand_term(rng, nb, 2, 0), rand_term(rng, nb, 1, 0)))
        f = parts[0]
        for g in parts[1:]:
            f = AND(f, g) if rng.random() < 0.6 else IMP(f, g)
        for _ in range(nb):
            f = ALL(f)
        out.append(f)
    T = out[0]
    for g in out[1:]:
        T = AND(T, g)
    assert is_DT0(T), pp(T)
    return T


def arities(T):
    return {o[1]: len(o[2]) for o in occurrences(T)}


def rand_theta(rng, T):
    return {nm: rand_body(rng, msort(nm), n) for nm, n in arities(T).items()}


def rich_thetas(T):
    """substitutions used to certify non-anchors: constants, projections, S-wrapped holes, atoms"""
    ars = arities(T)
    out = []
    def options(nm, n):
        if msort(nm) == 'T':
            o = [Z, PA, S(Z), add(Z, Z)] + [H(m) for m in range(n)] + [S(H(m)) for m in range(n)]
            if n >= 2:
                o.append(add(H(0), H(1)))
            return o
        o = [eq(Z, Z), NOT(eq(Z, Z)), eq(PA, Z)]
        o += [eq(H(m), Z) for m in range(n)] + [eq(H(m), H(m)) for m in range(n)]
        if n >= 2:
            o.append(eq(H(0), H(1)))
            o.append(eq(H(1), H(0)))
        if n >= 1:
            o.append(ALL(eq(V(0), H(0))))
        return o
    names = sorted(ars)
    import itertools
    for combo in itertools.product(*[options(nm, ars[nm]) for nm in names]):
        out.append(dict(zip(names, combo)))
        if len(out) > 400:
            break
    return out
