"""Shared helpers for the experiments (results go to ../results)."""
import json
import math
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..'))
sys.path.insert(0, ROOT)
RESULTS = os.path.join(ROOT, 'results')
os.makedirs(RESULTS, exist_ok=True)

import bai  # noqa: E402,F401  (sets up the dtrc path)
from dtrc.syntax import parse, pp, canon_params, num, ZERO, S  # noqa: E402
from dtrc.templates import canon, geq, equiv  # noqa: E402
from bai.theory import Component, Theory  # noqa: E402
from bai.pool import (forall_of, specialise, term_patterns, generalisations, min_theories,  # noqa: E402
                      skeleton_theories, mem_theory)


def save(name, text, data=None):
    with open(os.path.join(RESULTS, name + '.md'), 'w') as f:
        f.write(text)
    if data is not None:
        with open(os.path.join(RESULTS, name + '.json'), 'w') as f:
            json.dump(data, f, indent=1, default=str)


def md_table(header, rows):
    out = '| ' + ' | '.join(str(h) for h in header) + ' |\n'
    out += '|' + '|'.join(['---'] * len(header)) + '|\n'
    for r in rows:
        out += '| ' + ' | '.join(str(x) for x in r) + ' |\n'
    return out


def fmt(x, nd=3):
    if x is None:
        return '-'
    if isinstance(x, float):
        if x == 0:
            return '0'
        if abs(x) < 10 ** -nd:
            return '%.0e' % x
        return ('%.' + str(nd) + 'f') % x
    return str(x)


FALSE_SENTENCE = parse('0=S0')
TRUE_UNUSED_SCHEMA = parse('?u*0=0')


def classify_vs(T, P):
    """class of a single template T relative to the target template P"""
    if equiv(T, P):
        return 'H_sch'
    if geq(T, P):
        return 'over-general'
    if geq(P, T):
        return 'over-specific'
    return 'other'


def e1_hand_pool(P, var='t', frag2=True, star=True):
    """hand-specified alternatives for the universal phi(x), given as the template P = phi(?t)"""
    A = forall_of(P, var)
    pool = [
        Theory([A], 'H_all', {'cls': 'H_all'}),
        Theory([Component(P, {var: 'closed'})], 'H_sch', {'cls': 'H_sch'}),
        Theory([Component(P, {var: 'open'})], 'H_open', {'cls': 'H_open'}),
        Theory([A, Component(P, {var: 'closed'})], 'H_all+sch', {'cls': 'H_all+sch'}),
        Theory([A, Component(P, {var: 'open'})], 'H_all+open', {'cls': 'H_all+sch'}),
        Theory([specialise(P, var, ZERO), specialise(P, var, ('S', ('M', 'z', ())))], 'overspec{0,S}',
               {'cls': 'over-specific'}),
        Theory([specialise(P, var, p) for p in term_patterns(1)], 'frag1', {'cls': 'fragmented'}),
        Theory([Component(P), specialise(P, var, ('S', ('M', 'z', ())))], 'spare_nested', {'cls': 'spare'}),
        Theory([Component(P), FALSE_SENTENCE], 'spare_false', {'cls': 'spare'}),
        Theory([Component(P), TRUE_UNUSED_SCHEMA], 'spare_schema', {'cls': 'spare'}),
    ]
    if frag2:
        pool.append(Theory([specialise(P, var, p) for p in term_patterns(2)], 'frag2', {'cls': 'fragmented'}))
    for i, G in enumerate(generalisations(P)):
        if not star and G[0] == 'M':
            continue
        pool.append(Theory([G], 'gen%d:%s' % (i, pp(G)), {'cls': 'over-general'}))
    if star:
        pool.append(Theory([parse('?P')], 'bare?P', {'cls': 'over-general'}))
    return pool


def dedupe(pool):
    seen, out = set(), []
    for th in pool:
        if th.key in seen:
            continue
        seen.add(th.key)
        out.append(th)
    return out


def has_star(th):
    from bai.lik import spine
    return any(spine(c.T)[0] == '*' or spine(c.T)[:2] == ('all', '*') for c in th.comps)
