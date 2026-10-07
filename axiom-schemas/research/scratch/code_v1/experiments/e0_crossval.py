"""E0 (computed): cross-validate the normal-configuration algorithm for Min(D) against an independent
bounded brute-force enumerator (the prior referee's data-directed enumerator rc_enum.enum_covering,
de Bruijn LEVELS, written from scratch by referee C; imported read-only from research/prior).

For each data set D:
  (a) every computed minimal template covers D and is in the class;
  (b) every enumerated covering template of the class (size <= SMAX) is >= some computed minimal template
      (completeness / well-foundedness of the computed Min within the bound);
  (c) every computed minimal template of size <= SMAX within the enumerator's arity/argument bounds is
      enumerated (up to equivalence);
  (d) no enumerated covering template is strictly below a computed minimal template (minimality).
Checks (b) and (d) are run with our matcher and, independently, with the referee's matcher (rc_core.geq).

usage: python3 experiments/e0_crossval.py [SMAX] [NSETS] [class: F|full]
"""
import sys
import os
import time
import random
import itertools
import json

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..'))
REF = os.path.join(HERE, '..', '..', 'research', 'prior', 'induction', 'referee_C')
sys.path.insert(0, os.path.abspath(REF))
sys.setrecursionlimit(100000)

import rc_core as RC                      # noqa: E402
from rc_enum import enum_covering         # noqa: E402
from rc_pool import pool as rc_pool       # noqa: E402
from dtrc.syntax import pp, BINDERS, LEAVES, kids, rebuild, size   # noqa: E402
from dtrc.templates import geq, covers_all, canon, is_DT0, metas    # noqa: E402
from dtrc.mincover import MinCover        # noqa: E402

HEADMAP = {'0': '0', 'S': 'S', '+': '+', '*': '*', '=': '=', 'not': '~', 'and': '&', 'or': '|', 'imp': '>',
           'all': 'A', 'ex': 'E'}
INV = {v: k for k, v in HEADMAP.items()}


def to_ref(t, D=0):
    h = t[0]
    if h == 'v':
        return ('v', D - 1 - t[1])
    if h == '0':
        return ('0',)
    if h in ('M', 'C'):
        return (h, t[1], tuple(to_ref(a, D) for a in t[2]))
    nh = HEADMAP[h]
    nd = D + 1 if h in BINDERS else D
    return (nh,) + tuple(to_ref(k, nd) for k in t[1:])


def from_ref(t, D=0):
    h = t[0]
    if h == 'v':
        return ('v', D - 1 - t[1])
    if h == '0':
        return ('0',)
    if h in ('M', 'C'):
        return (h, t[1], tuple(from_ref(a, D) for a in t[2]))
    nh = INV[h]
    nd = D + 1 if nh in BINDERS else D
    return (nh,) + tuple(from_ref(k, nd) for k in t[1:])


def within_bounds(T, amax, ar_F, ar_T):
    occ = []

    def walk(t):
        if t[0] == 'M':
            occ.append(t)
            return
        if t[0] in LEAVES:
            return
        for k in kids(t):
            walk(k)
    walk(T)
    for o in occ:
        ar = len(o[2])
        if o[1][0].isupper():
            if ar not in ar_F:
                return False
        elif ar not in ar_T:
            return False
        if any(size(a) > amax for a in o[2]):
            return False
    return True


def data_sets(nsets, seed=5):
    P = rc_pool(seed=11, n=30)
    names = list(P)
    rng = random.Random(seed)
    pairs = list(itertools.combinations(names, 2))
    rng.shuffle(pairs)
    sets = []
    for a, b in pairs[:nsets]:
        sets.append(('Ind(%s),Ind(%s)' % (a, b), [RC.Ind(P[a]), RC.Ind(P[b])]))
    # some non-induction data sets (mixed shapes, coincidences)
    extra = [
        ('C8.1', ['(forall x. x=0) & ((forall x. x=x) & 0=0)', '(forall x. ~x=0) & ((forall x. ~x=x) & ~0=0)']),
        ('add0 numerals', ['S0+0=S0', 'SS0+0=SS0', '0+0=0']),
        ('add0 vs 0add', ['S0+0=S0', '0+S0=S0']),
        ('Q4 vs Q6', ['forall x. x+0=x', 'forall x. x*0=0']),
        ('Q5 vs Q7', ['forall x. forall y. x+Sy=S(x+y)', 'forall x. forall y. x*Sy=x*y+x']),
        ('Ind vs Q', ['(0=0 & forall x. (x=x -> Sx=Sx)) -> forall x. x=x', 'forall x. ~Sx=0']),
        ('swap', ['forall x. forall y. x+y=y+x', 'forall x. forall y. y+x=x+y']),
        ('proj', ['forall x. forall y. (x=y -> y=x)', 'forall x. forall y. (y=x -> x=y)']),
    ]
    from dtrc.syntax import parse
    for name, ss in extra:
        sets.append((name, [to_ref(parse(s)) for s in ss]))
    return sets


def main():
    SMAX = int(sys.argv[1]) if len(sys.argv) > 1 else 13
    NSETS = int(sys.argv[2]) if len(sys.argv) > 2 else 40
    CLS = sys.argv[3] if len(sys.argv) > 3 else 'F'
    ar_T = (0,) if CLS == 'F' else (0, 1)
    ar_F = (0, 1, 2)
    amax = 3
    t0 = time.time()
    agg = {'sets': 0, 'enumerated': 0, 'a_fail': 0, 'b_fail': 0, 'b_fail_ref': 0, 'c_fail': 0, 'd_fail': 0,
           'min_total': 0, 'min_in_bounds': 0}
    rows = []
    for name, Dref in data_sets(NSETS):
        D = [from_ref(d) for d in Dref]
        mins = MinCover(D, term_arity0=(CLS == 'F')).minimal()
        req = RC.is_DT
        enum = enum_covering(Dref, SMAX, amax=amax, ar_F=ar_F, ar_T=ar_T, require=req)
        enum_m = [canon(from_ref(T)) for T in enum]
        a_fail = sum(1 for M in mins if not (covers_all(M, D) and is_DT0(M)))
        b_fail = sum(1 for T in enum_m if not any(geq(T, M) for M in mins))
        mins_ref = [to_ref(M) for M in mins]
        b_fail_ref = sum(1 for T in enum if not any(RC.geq(T, Mr) for Mr in mins_ref))
        inb = [M for M in mins if size(M) <= SMAX and within_bounds(M, amax, ar_F, ar_T)]
        c_fail = sum(1 for M in inb if not any(geq(M, T) and geq(T, M) for T in enum_m))
        d_fail = sum(1 for M in mins for T in enum_m if geq(M, T) and not geq(T, M))
        agg['sets'] += 1
        agg['enumerated'] += len(enum_m)
        agg['a_fail'] += a_fail
        agg['b_fail'] += b_fail
        agg['b_fail_ref'] += b_fail_ref
        agg['c_fail'] += c_fail
        agg['d_fail'] += d_fail
        agg['min_total'] += len(mins)
        agg['min_in_bounds'] += len(inb)
        rows.append((name, len(enum_m), len(mins), len(inb), a_fail, b_fail, b_fail_ref, c_fail, d_fail))
    dt = time.time() - t0
    print('E0 cross-validation: class=%s SMAX=%d amax=%d ar_F=%s ar_T=%s  (%.1fs)' % (CLS, SMAX, amax, ar_F, ar_T, dt))
    print('%-46s %6s %5s %5s %3s %3s %3s %3s %3s' % ('data set', 'enum', 'min', 'inB', 'a', 'b', 'bR', 'c', 'd'))
    for r in rows:
        print('%-46s %6d %5d %5d %3d %3d %3d %3d %3d' % ((r[0][:46],) + r[1:]))
    print('TOTAL', json.dumps(agg))


if __name__ == '__main__':
    main()
