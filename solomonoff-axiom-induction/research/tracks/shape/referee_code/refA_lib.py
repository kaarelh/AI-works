"""Referee A's own helpers for checking the `shape` record (written independently of checks/shapelib.py).

Conventions
* Variables 0..N-1; base variables 0..m-1, auxiliary variables m..N-1.
* A literal is an int: +(v+1) means x_v = 1, -(v+1) means x_v = 0.
* A clause is a frozenset of literals (a disjunction); a theory is a list of clauses.
* A partial assignment is a dict v -> 0/1.
* GF(2) vectors are Python ints (bit i = coordinate i).
"""
from itertools import product


def lit_var(L):
    return abs(L) - 1


def lit_val(L):
    return 1 if L > 0 else 0


def mk(v, val):
    return (v + 1) if val else -(v + 1)


def up_rounds(F, alpha, rounds=None):
    """Parallel unit propagation from alpha (dict). Returns (assignment dict, conflict flag).
    In each round every clause with all literals false except one unassigned literal derives it;
    a fully falsified clause or two opposite derivations in one round is a conflict."""
    a = dict(alpha)
    t = 0
    while rounds is None or t < rounds:
        new = {}
        for C in F:
            free = None
            nfree = 0
            sat = False
            for L in C:
                v = lit_var(L)
                if v in a:
                    if a[v] == lit_val(L):
                        sat = True
                        break
                else:
                    nfree += 1
                    free = L
                    if nfree > 1:
                        break
            if sat or nfree > 1:
                continue
            if nfree == 0:
                return a, True
            v, s = lit_var(free), lit_val(free)
            if v in new and new[v] != s:
                return a, True
            new[v] = s
        if not new:
            break
        a.update(new)
        t += 1
    return a, False


def models(F, N):
    """All satisfying assignments of F over N variables, as ints (bit v = x_v)."""
    out = []
    for x in range(1 << N):
        ok = True
        for C in F:
            if not any(((x >> lit_var(L)) & 1) == lit_val(L) for L in C):
                ok = False
                break
        if ok:
            out.append(x)
    return out


def projection(F, N, m):
    mask = (1 << m) - 1
    return sorted(set(x & mask for x in models(F, N)))


def partial_assignments(m):
    for vals in product((-1, 0, 1), repeat=m):
        yield {v: s for v, s in enumerate(vals) if s != -1}


def entailed(sols, alpha, m):
    """Base literals entailed by the law sols and alpha (dict) on variables outside alpha;
    None if alpha is inconsistent with the law."""
    cons = [x for x in sols if all(((x >> v) & 1) == s for v, s in alpha.items())]
    if not cons:
        return None
    out = []
    for v in range(m):
        if v in alpha:
            continue
        vals = set((x >> v) & 1 for x in cons)
        if len(vals) == 1:
            out.append((v, vals.pop()))
    return out


def usable(F, sols, m, rounds=None, alphas=None):
    """True iff UP_rounds on F answers every question of Q(sols) (over the alphas given, default all),
    with no conflict on consistent antecedents. Does not check the projection."""
    it = alphas if alphas is not None else partial_assignments(m)
    for alpha in it:
        imp = entailed(sols, alpha, m)
        if imp is None:
            continue
        a, conf = up_rounds(F, alpha, rounds)
        if conf:
            return False
        for v, s in imp:
            if a.get(v) != s:
                return False
    return True


def popcount(x):
    return bin(x).count("1")


def span(rows):
    out = {0}
    for r in rows:
        out |= {x ^ r for x in out}
    return out


def clauses_of_equation(u, c, varmap=None):
    """All clauses over supp(u) excluding the points with u.x != c, i.e. the CNF of u.x = c."""
    supp = [i for i in range(u.bit_length()) if (u >> i) & 1]
    out = []
    for bits in product((0, 1), repeat=len(supp)):
        if sum(bits) % 2 != c:  # beta violates u.x = c
            out.append(frozenset(mk(varmap[v] if varmap else v, 1 - b) for v, b in zip(supp, bits)))
    return out
