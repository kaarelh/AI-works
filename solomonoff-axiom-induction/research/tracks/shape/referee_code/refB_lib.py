"""Referee B's independent library for checking thread `shape` (not derived from checks/shapelib.py).

Conventions (deliberately different from the developer's):
* Variables are 1..N; base variables are 1..m, auxiliary variables m+1..N.
* A literal is a nonzero int: +v means x_v = 1, -v means x_v = 0 (DIMACS style).
* A clause is a frozenset of literals (non-tautological); a theory is a list (or set) of clauses.
* A point of {0,1}^m is an int bitmask: bit (v-1) is the value of x_v.
* A partial assignment is a frozenset of literals (consistent: never both v and -v).
* Unit propagation state is a set of true literals; conflict is reported as None.
"""
from itertools import product, combinations
import math

# ----------------------------------------------------------------------------- basic


def bit(x, v):
    return (x >> (v - 1)) & 1


def popcount(x):
    return bin(x).count("1")


def lit_true_at(L, x):
    """Is literal L true at the full point x (bitmask over all variables in L's range)?"""
    v = abs(L)
    return bit(x, v) == (1 if L > 0 else 0)


def clause_true_at(C, x):
    return any(lit_true_at(L, x) for L in C)


def theory_true_at(F, x):
    return all(clause_true_at(C, x) for C in F)


def point_agrees(x, alpha):
    return all(lit_true_at(L, x) for L in alpha)


# ----------------------------------------------------------------------------- reasoners


def up(F, alpha, rounds=None):
    """Parallel unit propagation (k rounds; None = to the fixpoint).

    In each round every clause that has no true literal and exactly one non-falsified literal
    derives it; a clause with all literals falsified, or two opposite derivations, is a conflict.
    Returns the set of true literals, or None on conflict."""
    state = set(alpha)
    for L in alpha:
        if -L in state:
            return None
    t = 0
    while rounds is None or t < rounds:
        new = set()
        for C in F:
            rem = None
            cnt = 0
            sat = False
            for L in C:
                if L in state:
                    sat = True
                    break
                if -L not in state:
                    cnt += 1
                    rem = L
                    if cnt > 1:
                        break
            if sat or cnt > 1:
                continue
            if cnt == 0:
                return None
            new.add(rem)
        if not new:
            break
        for L in new:
            if -L in new:
                return None
        state |= new
        t += 1
    return state


def up_rounds_trace(F, alpha, rounds):
    """Like up() but returns the list of states after each round (None marks a conflict)."""
    out = []
    state = set(alpha)
    for t in range(rounds):
        nxt = up(F, state, 1)
        out.append(None if nxt is None else frozenset(nxt))
        if nxt is None:
            break
        state = nxt
    return out


def fc(R, alpha, rounds=None):
    """Forward chaining with directed rules R = [(premise frozenset, conclusion literal)].

    In each round every rule whose premise holds fires; a conclusion whose negation holds, or two
    opposite conclusions in one round, is a conflict. Returns the set of true literals or None."""
    state = set(alpha)
    for L in alpha:
        if -L in state:
            return None
    t = 0
    while rounds is None or t < rounds:
        new = set()
        for P, L in R:
            if P <= state and L not in state:
                if -L in state:
                    return None
                new.add(L)
        if not new:
            break
        for L in new:
            if -L in new:
                return None
        state |= new
        t += 1
    return state


# ----------------------------------------------------------------------------- semantics


def all_points(m):
    return range(1 << m)


def entailed(S, m, alpha):
    """S: collection of points (bitmasks over m base variables).

    Returns (consistent, set of base literals on variables outside alpha entailed by S and alpha)."""
    pts = [x for x in S if point_agrees(x, alpha)]
    if not pts:
        return False, set()
    dom = {abs(L) for L in alpha}
    out = set()
    for v in range(1, m + 1):
        if v in dom:
            continue
        vals = {bit(x, v) for x in pts}
        if len(vals) == 1:
            out.add(v if vals.pop() == 1 else -v)
    return True, out


def partial_assignments(vars_):
    """All partial assignments (frozensets of literals) to the given variables."""
    vars_ = list(vars_)
    for vals in product((None, 0, 1), repeat=len(vars_)):
        yield frozenset(v if b == 1 else -v for v, b in zip(vars_, vals) if b is not None)


def models(F, N):
    """All full assignments (bitmasks over N variables) satisfying F."""
    return [x for x in range(1 << N) if theory_true_at(F, x)]


def projection(F, N, m):
    mask = (1 << m) - 1
    return {x & mask for x in models(F, N)}


def all_clauses(vars_):
    """All nonempty non-tautological clauses over the given variables."""
    vars_ = list(vars_)
    out = []
    for vals in product((None, 0, 1), repeat=len(vars_)):
        C = frozenset(v if b == 1 else -v for v, b in zip(vars_, vals) if b is not None)
        if C:
            out.append(C)
    return out


def is_implicate(C, S):
    return all(clause_true_at(C, x) for x in S)


def prime_implicates(S, m):
    imp = [C for C in all_clauses(range(1, m + 1)) if is_implicate(C, S)]
    imps = set(imp)
    pis = []
    for C in imp:
        if not any((C - {L}) in imps for L in C if len(C) > 1):
            pis.append(C)
    return pis


def usable(F, N, S, m, rounds=None, check_proj=True, check_conflicts=False):
    """R-usability (R = UP_rounds) of the explicit theory F (N variables) for the law S over m base vars.

    Returns (ok, number of entailed literals checked, first failure or None)."""
    S = set(S)
    if check_proj and N <= 22:
        if projection(F, N, m) != S:
            return False, 0, "projection"
    n = 0
    for alpha in partial_assignments(range(1, m + 1)):
        cons, ent = entailed(S, m, alpha)
        res = up(F, alpha, rounds)
        if not cons:
            if check_conflicts and res is not None:
                return False, n, ("no conflict", alpha)
            continue
        if res is None:
            return False, n, ("conflict", alpha)
        base_derived = {L for L in res if abs(L) <= m}
        for L in base_derived:
            if L not in alpha and L not in ent:
                return False, n, ("unsound", alpha, L)
        n += len(ent)
        if not ent <= base_derived:
            return False, n, ("missing", alpha, ent - base_derived)
    return True, n, None


# ----------------------------------------------------------------------------- GF(2)


def span(rows):
    sp = {0}
    for r in rows:
        sp |= {s ^ r for s in sp}
    return sp


def rank(rows):
    basis = []
    for r in rows:
        for b in basis:
            r = min(r, r ^ b)
        if r:
            basis.append(r)
    return len(basis)


def affine_points(rows, consts, m):
    return [x for x in range(1 << m) if all(popcount(x & r) % 2 == c for r, c in zip(rows, consts))]


def law_from_system(rows, consts, m):
    pts = affine_points(rows, consts, m)
    return pts


def derived_equations(pts, m):
    """All u (bitmask) with u.x constant on the (nonempty) affine set pts; returns dict u -> constant."""
    x0 = pts[0]
    out = {}
    for u in range(1 << m):
        c = popcount(u & x0) % 2
        if all(popcount(u & x) % 2 == c for x in pts):
            out[u] = c
    return out


def circuits_of(deq):
    nz = [u for u in deq if u]
    return [u for u in nz if not any(w != u and (w & ~u) == 0 for w in nz)]


def support(u, m):
    return [v for v in range(1, m + 1) if bit(u, v)]


def eq_clauses(u, c, m):
    """All 2^(|u|-1) clauses of the equation u.x = c (over base variables)."""
    vs = support(u, m)
    out = []
    for vals in product((0, 1), repeat=len(vs)):
        if sum(vals) % 2 != c:
            # falsifying assignment vals -> clause
            out.append(frozenset(-v if b == 1 else v for v, b in zip(vs, vals)))
    return out


def xor_clauses(vs, c):
    """Clauses of x_{vs[0]} + ... = c over arbitrary variable ids (falsified exactly by violating tuples)."""
    out = []
    for vals in product((0, 1), repeat=len(vs)):
        if sum(vals) % 2 != c:
            out.append(frozenset(-v if b == 1 else v for v, b in zip(vs, vals)))
    return out


def chain_encoding(vs, c, next_var):
    """Chain encoding of XOR(vs) = c with fresh auxiliary variables starting at next_var.

    y1 = v1+v2, y_i = y_{i-1} + v_{i+1}, y_last + v_w = c. For |vs| <= 3 the equation is written directly.
    Returns (clauses, next free variable)."""
    w = len(vs)
    if w <= 3:
        return xor_clauses(vs, c), next_var
    F = []
    y = next_var
    F += xor_clauses([vs[0], vs[1], y], 0)
    for i in range(2, w - 1):
        F += xor_clauses([y, vs[i], y + 1], 0)
        y += 1
    F += xor_clauses([y, vs[w - 1]], c)
    return F, y + 1


# ----------------------------------------------------------------------------- codes


def elias_delta_len(n):
    """Length of the Elias delta code of n >= 1."""
    assert n >= 1
    L = n.bit_length() - 1
    return L + 2 * ((L + 1).bit_length() - 1) + 1


def ell_N(n):
    """A prefix code on the nonnegative integers: Elias delta of n+1 (the record's ell_N needs n = 0)."""
    return elias_delta_len(n + 1)


def ell_lst(F, m, N, ellN=ell_N):
    """The record's listing code length (Definition 1.6) with the given integer code."""
    lw = math.ceil(math.log2(N)) + 1 if N > 1 else 1
    return ellN(N - m) + ellN(len(F)) + sum(ellN(len(C)) + len(C) * lw for C in F)
