"""Shared helpers for the model-track checks: closed arithmetic terms and a PCFG on them.

Terms are nested tuples: ('0',), ('S', t), ('+', t, u), ('*', t, u).
The PCFG Q picks the root symbol f with probability p[f] and then the children independently.
"""
import math
import random

ARITY = {'0': 0, 'S': 1, '+': 2, '*': 2}


def size(t):
    return 1 + sum(size(c) for c in t[1:])


def value(t):
    f = t[0]
    if f == '0':
        return 0
    if f == 'S':
        return value(t[1]) + 1
    if f == '+':
        return value(t[1]) + value(t[2])
    return value(t[1]) * value(t[2])


def q_prob(t, p):
    """Q(t) = p[root] * product of Q(children)."""
    r = p[t[0]]
    for c in t[1:]:
        r *= q_prob(c, p)
    return r


def enumerate_terms(max_size, symbols=('0', 'S', '+', '*')):
    """All closed terms of size <= max_size over the given symbols, grouped by size."""
    by_size = {1: [('0',)] if '0' in symbols else []}
    for n in range(2, max_size + 1):
        out = []
        if 'S' in symbols:
            out += [('S', t) for t in by_size[n - 1]]
        for f in ('+', '*'):
            if f not in symbols:
                continue
            for k in range(1, n - 1):
                for a in by_size[k]:
                    for b in by_size[n - 1 - k]:
                        out.append((f, a, b))
        by_size[n] = out
    return by_size


def sample_term(p, rng, max_nodes=10_000):
    """Sample from the PCFG (subcritical, so finite a.s.); iterative to avoid recursion limits."""
    syms = list(p)
    weights = [p[s] for s in syms]
    count = [0]

    def rec():
        count[0] += 1
        if count[0] > max_nodes:
            raise RuntimeError('tree too large')
        f = rng.choices(syms, weights)[0]
        return (f,) + tuple(rec() for _ in range(ARITY[f]))

    return rec()


def mean_children(p):
    return sum(p[s] * ARITY[s] for s in p)


def show(t):
    f = t[0]
    if f == '0':
        return '0'
    if f == 'S':
        return 'S' + show(t[1])
    return '(' + show(t[1]) + f + show(t[2]) + ')'


def log2(x):
    return math.log(x, 2)
