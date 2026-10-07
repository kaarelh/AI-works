# practice.py -- the PA and ZF practices of section (e): targets as DT deg templates and data generators.
import random
from dtlib import *

a1, a2 = P('a1'), P('a2')
X = H(0)
# ---------------------------------------------------------------- PA (closure-normal form: parameters a1, a2)
Q = {
    'Q1': NOT(eq(S(a1), Z)),
    'Q2': IMP(eq(S(a1), S(a2)), eq(a1, a2)),
    'Q3': eq(add(a1, Z), a1),
    'Q4': eq(add(a1, S(a2)), S(add(a1, a2))),
    'Q5': eq(mul(a1, Z), Z),
    'Q6': eq(mul(a1, S(a2)), add(mul(a1, a2), a1)),
    'Q7': IMP(NOT(eq(a1, Z)), EX(eq(a1, S(V(0))))),
}
# instance schemas of the universal axioms (observed through numeral / closed-term instances)
QS = {
    'Q1s': NOT(eq(S(M('tx')), Z)),
    'Q2s': IMP(eq(S(M('tx')), S(M('ty'))), eq(M('tx'), M('ty'))),
    'Q3s': eq(add(M('tx'), Z), M('tx')),
    'Q4s': eq(add(M('tx'), S(M('ty'))), S(add(M('tx'), M('ty')))),
    'Q5s': eq(mul(M('tx'), Z), Z),
    'Q6s': eq(mul(M('tx'), S(M('ty'))), add(mul(M('tx'), M('ty')), M('tx'))),
    'Q7s': IMP(NOT(eq(M('tx'), Z)), EX(eq(M('tx'), S(V(0))))),
}

def rand_term(rng, depth, vars_, params_=()):
    """random arithmetic term; vars_ = list of bound-variable terms available (incl. hole)"""
    if depth <= 0 or rng.random() < 0.35:
        return rng.choice([Z, S(Z)] + list(vars_) * 2 + list(params_))
    r = rng.random()
    if r < 0.4: return S(rand_term(rng, depth - 1, vars_, params_))
    if r < 0.75: return add(rand_term(rng, depth - 1, vars_, params_), rand_term(rng, depth - 1, vars_, params_))
    return mul(rand_term(rng, depth - 1, vars_, params_), rand_term(rng, depth - 1, vars_, params_))

ROOT_LAW = [('=', .45), ('imp', .15), ('not', .12), ('all', .08), ('and', .08), ('ex', .06), ('or', .06)]
def rand_motive(rng, depth=2, bound=0, params_=(), root=None):
    """random formula over hole x = ('h',0) and `bound` enclosing bound variables (indices 0..bound-1)"""
    vars_ = [X] + [V(i) for i in range(bound)]
    if root is None:
        r, acc = rng.random(), 0
        for f, p in ROOT_LAW:
            acc += p
            if r < acc: root = f; break
        else: root = '='
    if depth <= 0: root = '='
    if root == '=':
        return eq(rand_term(rng, 2, vars_, params_), rand_term(rng, 2, vars_, params_))
    if root == 'not': return NOT(rand_motive(rng, depth - 1, bound, params_))
    if root in ('and', 'or', 'imp'):
        return (root, rand_motive(rng, depth - 1, bound, params_), rand_motive(rng, depth - 1, bound, params_))
    return (root, rand_motive(rng, depth - 1, bound + 1, params_, root='='))

def pa_data(n, rng, p_ind=0.5, params_=()):
    out = []
    keys = sorted(Q)
    for _ in range(n):
        if rng.random() < p_ind:
            out.append(('Ind', canon_params(Ind(rand_motive(rng, 2, 0, params_)))))
        else:
            k = rng.choice(keys)
            out.append((k, Q[k]))
    return out

def rand_closed(rng, depth=2):
    if depth <= 0 or rng.random() < 0.4: return rng.choice([Z, S(Z), S(S(Z))])
    r = rng.random()
    if r < 0.5: return S(rand_closed(rng, depth - 1))
    if r < 0.8: return add(rand_closed(rng, depth - 1), rand_closed(rng, depth - 1))
    return mul(rand_closed(rng, depth - 1), rand_closed(rng, depth - 1))

def qs_instance(k, rng):
    T = QS[k]
    th = {'tx': rand_closed(rng), 'ty': rand_closed(rng)}
    return instantiate(T, th)

# ---------------------------------------------------------------- ZF (closure-normal form)
def v(i): return V(i)
ZF = {
    'Ext': IMP(ALL(IFF(mem(v(0), a1), mem(v(0), a2))), eq(a1, a2)),
    'Pair': EX(AND(mem(a1, v(0)), mem(a2, v(0)))),
    'Union': EX(ALL(IFF(mem(v(0), v(1)), EX(AND(mem(v(0), a1), mem(v(1), v(0))))))),
    'Power': EX(ALL(IFF(mem(v(0), v(1)), ALL(IMP(mem(v(0), v(1)), mem(v(0), a1)))))),
    'Inf': EX(AND(EX(AND(mem(v(0), v(1)), ALL(NOT(mem(v(0), v(1)))))),
                  ALL(IMP(mem(v(0), v(1)), EX(AND(mem(v(0), v(2)), ALL(IFF(mem(v(0), v(1)), OR(mem(v(0), v(2)), eq(v(0), v(2))))))))))),
    'Found': IMP(EX(mem(v(0), a1)), EX(AND(mem(v(0), a1), ALL(IMP(mem(v(0), v(1)), NOT(mem(v(0), a1))))))),
}
# Weak (bounding) forms of Union and Power, as in presentations that rely on Separation
ZFW = {
    'UnionW': EX(ALL(IMP(EX(AND(mem(v(0), a1), mem(v(1), v(0)))), mem(v(0), v(1))))),
    'PowerW': EX(ALL(IMP(ALL(IMP(mem(v(0), v(1)), mem(v(0), a1))), mem(v(0), v(1))))),
}
# schema templates
SEP = EX(ALL(IFF(mem(v(0), v(1)), AND(mem(v(0), a1), M('Fphi', v(0))))))
REP = IMP(ALL(IMP(mem(v(0), a1), EX(AND(M('Fpsi', v(1), v(0)), ALL(IMP(M('Fpsi', v(2), v(0)), eq(v(0), v(1)))))))),
          EX(ALL(IFF(mem(v(0), v(1)), EX(AND(mem(v(0), a1), M('Fpsi', v(0), v(1))))))))
EIND = IMP(ALL(IMP(ALL(IMP(mem(v(0), v(1)), M('Fchi', v(0)))), M('Fchi', v(0)))), ALL(M('Fchi', v(0))))
ZF_SCHEMAS = {'Sep': SEP, 'Rep': REP, 'EInd': EIND}

def rand_set_formula(rng, nh, depth=2, bound=0, params_=('p1',)):
    """random formula over holes h0..h_{nh-1}, `bound` enclosing bound vars, parameters"""
    terms = [H(j) for j in range(nh)] + [V(i) for i in range(bound)] + [P(p) for p in params_]
    if depth <= 0 or rng.random() < 0.35:
        a, b = rng.choice(terms), rng.choice(terms)
        return mem(a, b) if rng.random() < 0.75 else eq(a, b)
    r = rng.random()
    if r < 0.2: return NOT(rand_set_formula(rng, nh, depth - 1, bound, params_))
    if r < 0.55: return (rng.choice(['and', 'or', 'imp']), rand_set_formula(rng, nh, depth - 1, bound, params_),
                         rand_set_formula(rng, nh, depth - 1, bound, params_))
    q = rng.choice(['all', 'ex'])
    # bounded quantifier over a term
    t = rng.choice(terms)
    inner = rand_set_formula(rng, nh, depth - 1, bound + 1, params_)
    # inner context shifted: holes/params unaffected, existing bound vars shift automatically by construction
    if q == 'all': return ALL(IMP(mem(V(0), shift(t, 1)), inner))
    return EX(AND(mem(V(0), shift(t, 1)), inner))

def schema_instance(name, rng):
    if name == 'Sep':
        body = rand_set_formula(rng, 1)
        return canon_params(instantiate(SEP, {'Fphi': body}))
    if name == 'Rep':
        body = rand_set_formula(rng, 2)
        return canon_params(instantiate(REP, {'Fpsi': body}))
    if name == 'EInd':
        body = rand_set_formula(rng, 1)
        return canon_params(instantiate(EIND, {'Fchi': body}))
    raise KeyError(name)

def zf_data(n, rng, p_schema=0.6, single=None):
    single = single or ZF
    out = []
    for _ in range(n):
        if rng.random() < p_schema:
            k = rng.choice(['Sep', 'Rep', 'EInd'])
            out.append((k, schema_instance(k, rng)))
        else:
            k = rng.choice(sorted(single))
            out.append((k, single[k]))
    return out
