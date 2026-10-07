# Track "cases", revision: a bounded search for covering second-order templates that miss a probe instance
# (used for Prop A2' (Q1, PA language) and Thm E' (several metavariables, set theory)).
#
# Data: two (or more) ground de Bruijn trees in st_core format (any function/predicate heads; binders
# 'all','ex','exu').  Search space ("single-group templates"): the common rigid part of the data; one
# metavariable G occurring at a set of pairwise incomparable positions (size <= gmax), each occurrence applied
# to an argument tuple of a fixed arity a <= amax, arguments drawn from the bound variables in scope and a
# given list of closed terms (repeats allowed); at every remaining disagreement position a fresh metavariable
# applied to all bound variables in scope (a pattern occurrence, which covers anything there).
# DT-degree: some G-occurrence must be a pattern occurrence (pairwise distinct bound variables);
# SO-degree: no condition.  Matching: st_core.covers (complete SO-degree matcher: projection/imitation per node).
# Why one group suffices (for the anchor theorems' proofs): a template that covers D and is not >= T* has a
# metavariable M whose occurrences cannot be reconciled (proof of Thm E / A2'); replacing every other
# metavariable by fresh fully-applied single occurrences keeps coverage and keeps M's failure.  The search is
# still bounded (group size, arity, argument pool), so its verdict "no covering template misses a probe" is
# evidence, not proof.
import itertools
from st_core import covers, kids, rebuild, BINDERS, M, V, is_determinate

def positions(t, p=()):
    out = [p]
    for i, k in enumerate(kids(t)):
        out += positions(k, p + (i,))
    return out

def at(t, p):
    for i in p: t = kids(t)[i]
    return t

def depth(t, p):
    d = 0
    for i in p:
        if t[0] in BINDERS: d += 1
        t = kids(t)[i]
    return d

def same_node(ts):
    t0 = ts[0]
    return all(t[0] == t0[0] and len(t) == len(t0) and (len(kids(t0)) > 0 or t == t0) for t in ts)

def regions(D):
    """allowed metavariable positions (all proper prefixes rigid-common) and the disagreement frontier"""
    allowed, frontier = [], []
    def walk(p):
        allowed.append(p)
        ts = [at(d, p) for d in D]
        if not same_node(ts):
            frontier.append(p); return
        for i in range(len(kids(ts[0]))): walk(p + (i,))
    walk(())
    return allowed, frontier

def prefix(p, q): return len(p) <= len(q) and q[:len(p)] == p

def replace(t, p, new):
    if not p: return new
    ks = list(kids(t)); ks[p[0]] = replace(ks[p[0]], p[1:], new)
    return rebuild(t, ks)

def build(D0, frontier, group, args):
    T = D0
    fresh = [f for f in frontier if not any(prefix(g, f) for g in group)]
    for i, f in enumerate(fresh):
        d = depth(D0, f)
        T = replace(T, f, M('F%d' % i, *[V(k) for k in range(d)]))
    for g, a in zip(group, args):
        T = replace(T, g, M('G', *a))
    return T

def is_pattern(a): return all(x[0] == 'v' for x in a) and len(set(a)) == len(a)

def search(D, probes, closed_args, gmax=3, amax=2, degree='DT', limit=None, stop_first=True, a3max=1):
    """returns (number of covering templates examined, list of witnesses (T, missed probe))"""
    allowed, frontier = regions(D)
    D0 = D[0]
    witnesses, ncover = [], 0
    for gsize in range(1, gmax + 1):
        for group in itertools.combinations(allowed, gsize):
            if any(prefix(p, q) for p in group for q in group if p != q): continue
            pools = []
            for g in group:
                d = depth(D0, g)
                pools.append([V(k) for k in range(d)] + list(closed_args))
            for a in range(0, amax + 1):
                if gsize >= 3 and a > a3max: continue
                for args in itertools.product(*[list(itertools.product(pl, repeat=a)) for pl in pools]):
                    if degree == 'DT' and not any(is_pattern(x) for x in args): continue
                    T = build(D0, frontier, group, args)
                    if degree == 'DT' and not is_determinate(T): continue
                    if not all(covers(T, d) for d in D): continue
                    ncover += 1
                    for q in probes:
                        if not covers(T, q):
                            witnesses.append((T, q))
                            break
                    if witnesses and stop_first: return ncover, witnesses
    return ncover, witnesses
