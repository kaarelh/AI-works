#!/usr/bin/env python3
"""rb7_monadic.py -- referee B, thread `fundamentals`: a decidable first-order fragment.

Language: one unary predicate R, constants c_0..c_{n-1} (n <= 3), equality, variables x, y; sentences of
quantifier rank <= 2.  Validity is decided exactly: two structures with the same constant pattern (which constants
are equal, and the R-value of each) and the same numbers of non-constant elements in R and outside R, each capped
at the quantifier rank, satisfy the same sentences of that rank (Ehrenfeucht-Fraisse for monadic structures), so it
suffices to check every "capped" structure with caps 3 > rank.

R7.1  The lemma in the proof of Prop 1.8(d): if psi is consistent and proves R(c_j) for all j < n and
      exists x not R(x), then every c_j, j < n, occurs in psi.  Random psi built to meet the hypothesis often.
R7.2  Lemma 6.2a with B = {c_i != c_j : i < j}: (L1) every literal set with at most one literal per constant is
      consistent with B; (L2) B + Lambda proves R(c_y)^b only if R(c_y)^b is in Lambda (or Lambda inconsistent).
R7.3  Prop 1.8(d) upper bound: AND_{j<N} R(c_j) & exists x not R(x) is consistent and proves psi_{D_n} for N >= n.
Seed 20261016.  Output: rb7_monadic.out.
"""
import itertools
import os
import random

SEED = 20261016
rng = random.Random(SEED)
OUT = []
CAP = 3


def out(s=""):
    OUT.append(s)
    print(s)


# formulas: ('R', t), ('eq', t1, t2), ('not', f), ('and', f, g), ('or', f, g), ('imp', f, g), ('ex', v, f), ('all', v, f)
# terms: ('c', i) or ('v', name)

def set_partitions(items):
    if not items:
        yield []
        return
    first, rest = items[0], items[1:]
    for p in set_partitions(rest):
        for i in range(len(p)):
            yield p[:i] + [[first] + p[i]] + p[i + 1:]
        yield [[first]] + p


def structures(n):
    """capped canonical structures: domain = constant classes + r0 extra non-R elements + r1 extra R elements."""
    res = []
    for part in set_partitions(list(range(n))):
        ncl = len(part)
        for rv in itertools.product((0, 1), repeat=ncl):
            for r0 in range(CAP + 1):
                for r1 in range(CAP + 1):
                    size = ncl + r0 + r1
                    if size == 0:
                        continue
                    Rset = {i for i in range(ncl) if rv[i]} | set(range(ncl + r0, size))
                    const = {}
                    for ci, cl in enumerate(part):
                        for c in cl:
                            const[c] = ci
                    res.append((size, frozenset(Rset), const))
    return res


def ev_term(t, st, env):
    return st[2][t[1]] if t[0] == 'c' else env[t[1]]


def ev(f, st, env=None):
    env = env or {}
    op = f[0]
    if op == 'R':
        return ev_term(f[1], st, env) in st[1]
    if op == 'eq':
        return ev_term(f[1], st, env) == ev_term(f[2], st, env)
    if op == 'not':
        return not ev(f[1], st, env)
    if op == 'and':
        return ev(f[1], st, env) and ev(f[2], st, env)
    if op == 'or':
        return ev(f[1], st, env) or ev(f[2], st, env)
    if op == 'imp':
        return (not ev(f[1], st, env)) or ev(f[2], st, env)
    if op == 'ex':
        return any(ev(f[2], st, {**env, f[1]: d}) for d in range(st[0]))
    if op == 'all':
        return all(ev(f[2], st, {**env, f[1]: d}) for d in range(st[0]))
    raise ValueError(op)


def consts_in(f, acc=None):
    acc = set() if acc is None else acc
    if f[0] in ('R',):
        if f[1][0] == 'c':
            acc.add(f[1][1])
    elif f[0] == 'eq':
        for t in f[1:]:
            if t[0] == 'c':
                acc.add(t[1])
    elif f[0] in ('ex', 'all'):
        consts_in(f[2], acc)
    else:
        for g in f[1:]:
            consts_in(g, acc)
    return acc


def rank(f):
    if f[0] in ('R', 'eq'):
        return 0
    if f[0] in ('ex', 'all'):
        return 1 + rank(f[2])
    return max(rank(g) for g in f[1:])


def models(f, sts):
    return [st for st in sts if ev(f, st)]


def proves(psi, chi, sts):
    return all(ev(chi, st) for st in sts if ev(psi, st))


def AND(*fs):
    out_ = fs[-1]
    for g in reversed(fs[:-1]):
        out_ = ('and', g, out_)
    return out_


def rand_term(n, vars_):
    if vars_ and rng.random() < 0.6:
        return ('v', rng.choice(vars_))
    return ('c', rng.randrange(n))


def rand_open(n, vars_, depth):
    if depth == 0 or rng.random() < 0.35:
        if rng.random() < 0.65:
            return ('R', rand_term(n, vars_))
        return ('eq', rand_term(n, vars_), rand_term(n, vars_))
    op = rng.choice(['not', 'and', 'or', 'imp', 'ex', 'all'])
    if op == 'not':
        return ('not', rand_open(n, vars_, depth - 1))
    if op in ('ex', 'all'):
        if len(vars_) >= 2:
            return rand_open(n, vars_, depth - 1)
        v = 'x' if 'x' not in vars_ else 'y'
        return (op, v, rand_open(n, vars_ + [v], depth - 1))
    return (op, rand_open(n, vars_, depth - 1), rand_open(n, vars_, depth - 1))


def r7_1():
    n = 3
    sts = structures(n)
    target = [('R', ('c', j)) for j in range(n)] + [('ex', 'x', ('not', ('R', ('v', 'x'))))]
    hyp = 0
    viol = 0
    tried = 0
    for trial in range(6000):
        parts = []
        # pieces that tend to make the hypothesis true, with some constants possibly omitted
        for j in range(n):
            if rng.random() < 0.7:
                parts.append(('R', ('c', j)))
        r = rng.random()
        if r < 0.4:
            parts.append(('ex', 'x', ('not', ('R', ('v', 'x')))))
        elif r < 0.6:
            parts.append(('ex', 'x', ('and', ('not', ('R', ('v', 'x'))), ('not', ('eq', ('v', 'x'), ('c', rng.randrange(n)))))))
        for _ in range(rng.randint(0, 2)):
            parts.append(rand_open(n, [], 3))
        if rng.random() < 0.3:
            # universal pieces that could, if the lemma failed, give R(c_j) without c_j
            parts.append(('all', 'x', ('or', ('R', ('v', 'x')), ('eq', ('v', 'x'), ('c', rng.randrange(n))))))
        if not parts:
            continue
        psi = AND(*parts)
        if rank(psi) > 2:
            continue
        tried += 1
        if not models(psi, sts):
            continue
        if all(proves(psi, t, sts) for t in target):
            hyp += 1
            if consts_in(psi) != set(range(n)):
                viol += 1
    out(f"R7.1 Prop 1.8(d) lemma, n = {n} constants, {tried} random sentences of rank <= 2: {hyp} consistent and "
        f"proving R(c_0),...,R(c_(n-1)) and exists x not R(x); of these, {viol} omit some c_j  [0 claimed]")
    # negative control: without the existential datum, omissions occur (e.g. forall x R(x))
    neg = 0
    hyp2 = 0
    for trial in range(1500):
        parts = [('R', ('c', j)) for j in range(n) if rng.random() < 0.5]
        if rng.random() < 0.5:
            parts.append(('all', 'x', ('R', ('v', 'x'))))
        parts.append(rand_open(n, [], 2))
        psi = AND(*parts)
        if rank(psi) > 2 or not models(psi, sts):
            continue
        if all(proves(psi, ('R', ('c', j)), sts) for j in range(n)):
            hyp2 += 1
            neg += consts_in(psi) != set(range(n))
    out(f"     negative control (existential datum dropped): {hyp2} consistent sentences proving all R(c_j); "
        f"{neg} of them omit some c_j  [> 0 expected]")


def r7_0():
    """validate the capped decision procedure against all structures of size <= 6 (n = 2 constants)."""
    n = 2
    capped = structures(n)
    full = []
    for size in range(1, 7):
        for Rbits in range(1 << size):
            Rset = frozenset(i for i in range(size) if (Rbits >> i) & 1)
            for cv in itertools.product(range(size), repeat=n):
                full.append((size, Rset, dict(enumerate(cv))))
    dis = 0
    N = 400
    for trial in range(N):
        f = rand_open(n, [], 4)
        if rank(f) > 2:
            continue
        a = any(ev(f, st) for st in capped)
        b = any(ev(f, st) for st in full)
        c_ = all(ev(f, st) for st in capped)
        d = all(ev(f, st) for st in full)
        dis += (a != b) or (c_ != d)
    out(f"R7.0 decision procedure: satisfiability and validity over {len(capped)} capped structures vs all "
        f"{len(full)} structures of size <= 6 (2 constants), {N} random sentences of rank <= 2: disagreements {dis}")


def r7_2():
    n = 3
    sts = structures(n)
    B = AND(*[('not', ('eq', ('c', i), ('c', j))) for i in range(n) for j in range(i + 1, n)])
    l1 = 0
    l2 = 0
    cases = 0
    for labs in itertools.product((None, 0, 1), repeat=n):
        lits = [('R', ('c', i)) if b == 1 else ('not', ('R', ('c', i))) for i, b in enumerate(labs) if b is not None]
        th = AND(B, *lits) if lits else B
        cases += 1
        if not models(th, sts):
            l1 += 1
            continue
        for y in range(n):
            for b in (0, 1):
                f = ('R', ('c', y)) if b == 1 else ('not', ('R', ('c', y)))
                if proves(th, f, sts) and labs[y] != b:
                    l2 += 1
    out(f"R7.2 Lemma 6.2a with B = distinct constants, n = {n}: all {cases} literal sets with <= 1 literal per constant: "
        f"(L1) inconsistent ones: {l1}; (L2) proved literals not in the set: {l2}")


def r7_3():
    n = 3
    sts = structures(n)
    ok = 0
    tot = 0
    for N in range(n, n + 1):
        f = AND(*([('R', ('c', j)) for j in range(N)] + [('ex', 'x', ('not', ('R', ('v', 'x'))))]))
        target = [('R', ('c', j)) for j in range(n)] + [('ex', 'x', ('not', ('R', ('v', 'x'))))]
        tot += 1
        ok += bool(models(f, sts)) and all(proves(f, t, sts) for t in target)
    out(f"R7.3 Prop 1.8(d) upper bound sentence: consistent and proves psi_(D_n) in {ok} of {tot}")
    out(f"     (number of capped canonical structures checked per entailment: {len(sts)})")


if __name__ == "__main__":
    out(f"seed {SEED}")
    r7_0()
    r7_1()
    r7_2()
    r7_3()
    here = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(here, "rb7_monadic.out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")
