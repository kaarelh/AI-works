"""World oracles and template refutation search.

refute_sentence(s): sound one-sided oracle (PA: standard model N; ZF: V via HF search + generic case
analysis).  A sentence is *refuted* iff the evaluator certifies it False.

TemplateRefuter.refuted(T, data): searches small instances of the template T (bodies from fixed pools,
uniform assignments, seeded random combinations, and 'cross-filled' bodies read off different data by
matching) and returns True as soon as one instance is refuted.  Results are cached per canonical template.
"""
import random
import time
import zlib
from .syntax import (ZERO, S, EQ, LT, IN, NOT, ALL, EX, AND, OR, IMP, H, P, language_of, pp, canon_params)
from .templates import instantiate, metas, match, canon, meta_sort
from .oracle_pa import PAEval
from .oracle_zf import ZFEval


class Oracle:
    def __init__(self, lang, steps=None):
        self.lang = lang
        if lang == 'PA':
            self.ev = PAEval(max_steps=steps or 30000)
        else:
            self.ev = ZFEval(max_steps=steps or 4000)
        self.calls = 0
        self.time = 0.0

    def truth(self, s):
        t = time.time()
        self.calls += 1
        r = self.ev.truth(s)
        self.time += time.time() - t
        return r

    def refutes(self, s):
        return self.truth(s) is False


# ------------------------------------------------------------------------------------ body pools
def _pa_terms(n):
    ts = [ZERO, S(ZERO)] + [H(i) for i in range(n)] + [S(H(i)) for i in range(n)]
    return ts


def pa_formula_pool(n):
    top, bot = EQ(ZERO, ZERO), EQ(S(ZERO), ZERO)
    pool = [top, bot]
    hs = [H(i) for i in range(n)]
    for h in hs:
        pool += [EQ(h, ZERO), NOT(EQ(h, ZERO)), EQ(h, S(ZERO)), LT(ZERO, h), LT(h, S(S(ZERO)))]
    for a in hs:
        for b in hs:
            if a != b:
                pool += [EQ(a, b), LT(a, b), NOT(EQ(a, b)), EQ(a, S(b))]
    if n:
        pool += [EX(EQ(S(ZERO), ('+', ('v', 0), H(0)))),          # h0 <= 1 style
                 ALL(EQ(('+', H(0), ('v', 0)), ('+', ('v', 0), H(0)))),
                 EQ(H(0), P('w0')), NOT(EQ(H(0), P('w0'))), LT(H(0), P('w0'))]
    pool += [EQ(P('w0'), ZERO), ALL(EQ(('v', 0), ZERO)), EX(EQ(('v', 0), S(ZERO)))]
    return pool


def pa_term_pool(n):
    hs = [H(i) for i in range(n)]
    pool = [ZERO, S(ZERO)] + hs + [S(h) for h in hs] + [S(S(ZERO))]
    for a in hs:
        for b in hs:
            pool += [('+', a, b), ('*', a, b)]
    pool += [P('w0')] + [('+', h, S(ZERO)) for h in hs] + [('*', h, S(S(ZERO))) for h in hs]
    return pool


def zf_formula_pool(n):
    top = ALL(EQ(('v', 0), ('v', 0)))
    bot = NOT(top)
    pool = [top, bot]
    hs = [H(i) for i in range(n)]
    empty = lambda h: ALL(NOT(IN(('v', 0), h)))
    for h in hs:
        pool += [empty(h), NOT(empty(h)), IN(h, h), NOT(IN(h, h)), EQ(h, h), NOT(EQ(h, h))]
    for a in hs:
        for b in hs:
            if a != b:
                pool += [IN(a, b), NOT(IN(a, b)), EQ(a, b), NOT(EQ(a, b))]
    for h in hs:
        pool += [IN(h, P('w0')), IN(P('w0'), h), EQ(h, P('w0')), NOT(EQ(h, P('w0')))]
    pool += [empty(P('w0')), IN(P('w0'), P('w0')), ALL(IN(('v', 0), ('v', 0)))]
    return pool


def zf_term_pool(n):
    return [H(i) for i in range(n)] + [P('w0'), P('w1')]


def body_pool(lang, sort, n):
    if lang == 'PA':
        return pa_formula_pool(n) if sort == 'F' else pa_term_pool(n)
    return zf_formula_pool(n) if sort == 'F' else zf_term_pool(n)


# ------------------------------------------------------------------------------------ refuter
def _tuples_with_sum(total, sizes):
    """index tuples (i_1..i_k), 0 <= i_j < sizes[j], with sum = total"""
    if len(sizes) == 1:
        if total < sizes[0]:
            yield (total,)
        return
    for i in range(min(total, sizes[0] - 1) + 1):
        for rest in _tuples_with_sum(total - i, sizes[1:]):
            yield (i,) + rest


class TemplateRefuter:
    def __init__(self, lang, budget=80, data_budget=20, steps=None, seed=0):
        self.lang = lang
        self.oracle = Oracle(lang, steps)
        self.budget, self.data_budget = budget, data_budget
        self.seed = seed
        self.cache = {}        # canon template -> dict(refuted, witness, tried)
        self.templates_tested = 0
        self.time = 0.0

    def _state(self, T):
        c = canon(T)
        st = self.cache.get(c)
        if st is None:
            st = {'refuted': False, 'witness': None, 'tried': set(), 'generic_done': False, 'T': c}
            self.cache[c] = st
            self.templates_tested += 1
        return st

    def _try(self, st, inst):
        inst = canon_params(inst)
        if inst in st['tried']:
            return False
        st['tried'].add(inst)
        if self.oracle.refutes(inst):
            st['refuted'] = True
            st['witness'] = inst
            return True
        return False

    def _generic(self, st):
        """parallel assignments (every metavariable takes the j-th body of its pool), then all index tuples
        in order of increasing index sum (diagonal enumeration), up to the budget"""
        T = st['T']
        ms = metas(T)
        names = sorted(ms)
        if not names:
            self._try(st, T)
            return
        pools = [body_pool(self.lang, meta_sort(m), ms[m]) for m in names]
        n = 0
        L = max(len(p) for p in pools)
        seen = set()
        for j in range(min(L, self.budget // 2)):
            idx = tuple(min(j, len(p) - 1) for p in pools)
            seen.add(idx)
            n += 1
            if self._try(st, instantiate(T, {m: p[i] for m, p, i in zip(names, pools, idx)})):
                return
        k = len(names)
        total = 0
        while n < self.budget:
            progressed = False
            for idx in _tuples_with_sum(total, [len(p) for p in pools]):
                progressed = True
                if idx in seen:
                    continue
                seen.add(idx)
                n += 1
                if self._try(st, instantiate(T, {m: p[i] for m, p, i in zip(names, pools, idx)})):
                    return
                if n >= self.budget:
                    return
            total += 1
            if not progressed and total > sum(len(p) for p in pools):
                return

    def _data_guided(self, st, data):
        T = st['T']
        names = sorted(metas(T))
        if not names or not data:
            return
        thetas = []
        for d in data:
            th = match(T, d)
            if th is not None:
                thetas.append(th)
        if len(thetas) < 2 and len(names) < 2:
            return
        rng = random.Random(zlib.crc32(repr(T).encode()) ^ (self.seed + 7))
        n = 0
        tries = 0
        while n < self.data_budget and tries < 4 * self.data_budget:
            tries += 1
            theta = {m: rng.choice(thetas)[m] for m in names}
            inst = instantiate(T, theta)
            if canon_params(inst) in st['tried']:
                continue
            n += 1
            if self._try(st, inst):
                return

    def refuted(self, T, data=None):
        t = time.time()
        st = self._state(T)
        if not st['refuted'] and not st['generic_done']:
            self._generic(st)
            st['generic_done'] = True
        if not st['refuted'] and data:
            self._data_guided(st, data)
        self.time += time.time() - t
        return st['refuted']

    def witness(self, T):
        return self._state(T)['witness']

    def stats(self):
        return {'oracle_calls': self.oracle.calls, 'templates_tested': self.templates_tested,
                'oracle_time': round(self.oracle.time, 3), 'refuter_time': round(self.time, 3)}
