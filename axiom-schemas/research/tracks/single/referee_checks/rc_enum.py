# Referee's independent brute-force enumerator of DT° templates covering a finite data set D.
# Only uses the trivial fact (Lemma P) that a covering template's skeleton is a prefix of the data's
# common prefix, so its occurrences lie in A(D).  Within the bounds (occurrence count <= kmax,
# metavariable arity <= amax, vacuous derived arguments from a small pool) it is complete: every
# DT° template covering D is produced up to renaming of metavariables and permutation of their
# argument places.  It does NOT use saturation, features, forcing theory, etc.
import itertools
from rc_core import *


def cut_options(info, p, kmax):
    """list of antichains Q (tuples) in A(D) at/below p such that the template tree is complete"""
    if p not in info.C:
        return [(p,)]
    d0 = info.D[0]
    t = sub_at(d0, p)
    kids = children(t)
    opts = [(p,)]
    combos = [()]
    for i, c, add in kids:
        sub = cut_options(info, p + (i,), kmax)
        new = []
        for a in combos:
            for b in sub:
                if len(a) + len(b) <= kmax:
                    new.append(a + b)
        combos = new
    opts.extend(combos)
    return opts


def arg_pool(b, extra=True):
    pool = [V(i) for i in range(b)] + [Z]
    if extra:
        pool += [('a',), S(Z)]
        if b > 0:
            pool.append(S(V(0)))
    return pool


def read_args(beta, target, k, args):
    """match body beta (with holes) against target; fill args dict hole->term; False on clash"""
    tag = beta[0]
    if tag == 'z':
        if any(i < k for i in fv(target)):
            return False
        u = shift(target, -k)
        m = beta[1]
        if m in args:
            return args[m] == u
        args[m] = u
        return True
    if tag == '#':
        return target == beta
    if target[0] != tag or len(target) != len(beta):
        return False
    if tag in BINDERS:
        return read_args(beta[1], target[1], k + 1, args)
    for i in range(1, len(beta)):
        if not read_args(beta[i], target[i], k, args):
            return False
    return True


def enumerate_covering(D, kmax=5, amax=2, extra_pool=True, max_templates=10**7):
    info = DataInfo(D)
    D = info.D
    d0 = D[0]
    out = []
    seen = set()
    for Q in cut_options(info, (), kmax):
        Q = list(Q)
        n = len(Q)
        if n == 0:
            out.append(d0)
            continue
        subs = {q: [sub_at(d, q) for d in D] for q in Q}
        # pattern options per q: list of (args tuple, bodies)
        pat_opts = {}
        for q in Q:
            b = info.depth[q]
            need = set().union(*[fv(s) for s in subs[q]])
            opts = []
            for r in range(0, min(amax, b) + 1):
                for ys in itertools.combinations(range(b), r):
                    if not need <= set(ys):
                        continue
                    bodies = [abstract(s, list(ys)) for s in subs[q]]
                    opts.append((tuple(V(y) for y in ys), bodies))
            pat_opts[q] = opts
        for mask in range(1, 2 ** n):
            prim = [Q[i] for i in range(n) if mask >> i & 1]
            rest = [Q[i] for i in range(n) if not mask >> i & 1]
            if any(not pat_opts[q] for q in prim):
                continue
            for pchoice in itertools.product(*[pat_opts[q] for q in prim]):
                metas_ = []   # (name, sort, arity, bodies)
                occ = {}
                for j, q in enumerate(prim):
                    args, bodies = pchoice[j]
                    srt = info.sort[q]
                    name = ('f%d' if srt == 'i' else 'P%d') % j
                    metas_.append((name, srt, len(args), bodies))
                    occ[q] = M(name, *args)
                # options for each rest position
                rest_opts = []
                ok = True
                for q in rest:
                    srt = info.sort[q]
                    b = info.depth[q]
                    opts = []
                    for (name, s2, ar, bodies) in metas_:
                        if s2 != srt:
                            continue
                        forced = {}
                        good = True
                        for beta, tgt in zip(bodies, subs[q]):
                            if not read_args(beta, tgt, 0, forced):
                                good = False
                                break
                        if not good:
                            continue
                        free_places = [m for m in range(ar) if m not in forced]
                        pool = arg_pool(b, extra_pool)
                        for fill in itertools.product(pool, repeat=len(free_places)):
                            args = dict(forced)
                            for m, t in zip(free_places, fill):
                                args[m] = t
                            argt = tuple(args[m] for m in range(ar))
                            if all(plug(beta, argt) == tgt for beta, tgt in zip(bodies, subs[q])):
                                opts.append(M(name, *argt))
                    if not opts:
                        ok = False
                        break
                    rest_opts.append(opts)
                if not ok:
                    continue
                for rc in itertools.product(*rest_opts):
                    T = d0
                    for q in prim:
                        T = replace_at(T, q, occ[q])
                    for q, o in zip(rest, rc):
                        T = replace_at(T, q, o)
                    # drop unused metavariables is impossible (each primary occurs); check DT° and cover
                    if T in seen:
                        continue
                    seen.add(T)
                    out.append(T)
                    if len(out) > max_templates:
                        raise RuntimeError('too many')
    return out


def rigid_positions(T):
    return frozenset(p for (p, s, b) in all_positions(T) if s[0] != '?')


def minimal_elements(Ts, pool=None):
    """minimal elements of the generality preorder, up to equivalence"""
    Ts = list(Ts)
    rp = [rigid_positions(T) for T in Ts]
    if pool is not None:
        fp = [frozenset(i for i, q in enumerate(pool) if match(T, q) is not None) for T in Ts]
    else:
        fp = [None] * len(Ts)
    mins = []
    for i, T in enumerate(Ts):
        dominated = False
        for j, U in enumerate(Ts):
            if i == j:
                continue
            # need T >= U strictly
            if not rp[i] <= rp[j]:
                continue
            if fp[i] is not None and not fp[j] <= fp[i]:
                continue
            if geq(T, U) and not geq(U, T):
                dominated = True
                break
        if not dominated:
            mins.append(T)
    reps = []
    for T in mins:
        if not any(geq(T, U) and geq(U, T) for U in reps):
            reps.append(T)
    return reps
