# search for false sentence instances of a schema (exact truth evaluation, see raw_common.truth)
import random, itertools
from raw_common import *

POOL = {'T': [Z, S(Z), X, S(X), S(S(Z))],
        'F': [eq(Z, Z), eq(Z, S(Z)), eq(X, Z), NOT(eq(X, Z)), eq(X, X)],
        'V': [X]}

def instances(L, pool=POOL, cap=60000, rng=None):
    ms = meta_sorts(L)
    names = sorted(ms)
    choices = []
    for nm in names:
        srt = ms[nm]
        if len(srt) != 1:      # ill-sorted metavariable (cannot happen for lggs of well-formed formulas)
            raise ValueError('mixed sorts %s' % srt)
        choices.append(pool[next(iter(srt))])
    total = 1
    for c in choices: total *= len(c)
    if total <= cap:
        it = itertools.product(*choices)
    else:
        rng = rng or random.Random(0)
        it = (tuple(rng.choice(c) for c in choices) for _ in range(cap))
    for combo in it:
        yield dict(zip(names, combo))

def find_false(L, pool=POOL, cap=60000):
    """returns (instance, theta) for the first false sentence instance found, else None"""
    n_checked = 0
    for th in instances(L, pool, cap):
        s = subst_meta(L, th)
        if not is_sentence(s): continue
        try:
            if not truth(s):
                return s, th
        except NotExact:
            continue
        n_checked += 1
    return None

def pretty(f):
    """infix printer"""
    if is_var(f): return f[1]
    h = f[0]
    if len(f) == 1: return h
    if h == 'S':
        k, t = 0, f
        while not is_var(t) and t[0] == 'S': k, t = k + 1, t[1]
        inner = pretty(t)
        if t == Z: return 'S' * k + '0'
        return 'S' * k + (inner if (is_var(t) or len(t) == 1) else '(' + inner + ')')
    if h == 'add': return '(' + pretty(f[1]) + '+' + pretty(f[2]) + ')'
    if h == 'mul': return '(' + pretty(f[1]) + '*' + pretty(f[2]) + ')'
    if h == 'eq':
        a, b = pretty(f[1]), pretty(f[2])
        if a.startswith('(') and a.endswith(')') and a.count('(') == 1: a = a[1:-1]
        if b.startswith('(') and b.endswith(')') and b.count('(') == 1: b = b[1:-1]
        return a + '=' + b
    if h == 'not': return '~' + pretty(f[1])
    if h == 'and': return '(' + pretty(f[1]) + ' & ' + pretty(f[2]) + ')'
    if h == 'or': return '(' + pretty(f[1]) + ' v ' + pretty(f[2]) + ')'
    if h == 'imp': return '(' + pretty(f[1]) + ' -> ' + pretty(f[2]) + ')'
    if h in ('all', 'ex'): return ('A' if h == 'all' else 'E') + pretty(f[1]) + '.' + pretty(f[2])
    return show(f)

def rename_pretty(L):
    return pretty(canon(L))
