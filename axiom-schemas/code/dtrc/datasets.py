"""Seeded, reproducible datasets: PA-mix, ZF-mix and stress sets.

Every datum is a pair (sentence, label) with label = name of the target it was generated from (or
'MISTAKE:...' for injected mistakes).  Sentences are in closure-normal form (parameters w0, w1, ...).
"""
import random
from .syntax import (ZERO, S, EQ, LT, IN, NOT, AND, OR, IMP, IFF, ALL, EX, H, P, num, has_hole, canon_params,
                     parse, size, shift, pp)
from .schemas import (Ind, Sep, Rep, EInd, Q_AXIOMS, ZF_AXIOMS, T_IND, T_SEP, T_REP, T_EIND, U_AXIOMS,
                      axioms, pa_targets, zf_targets)
from .templates import instantiate


# ------------------------------------------------------------------------------------ arithmetic
def rand_pa_term(rng, nb, params, depth, nholes=1):
    r = rng.random()
    if depth <= 0 or r < 0.45:
        opts = ['0', 'h'] * 2 + (['p'] if params else []) + (['v'] * 2 if nb else [])
        k = rng.choice(opts)
        if k == '0':
            return ZERO if rng.random() < 0.7 else S(ZERO)
        if k == 'h':
            return H(rng.randrange(nholes))
        if k == 'p':
            return P(rng.choice(params))
        return ('v', rng.randrange(nb))
    k = rng.choice(['S', 'S', '+', '*'])
    if k == 'S':
        return S(rand_pa_term(rng, nb, params, depth - 1, nholes))
    return (k, rand_pa_term(rng, nb, params, depth - 1, nholes), rand_pa_term(rng, nb, params, depth - 1, nholes))


def rand_pa_formula(rng, nb, params, depth, nholes=1):
    r = rng.random()
    if depth <= 0 or r < 0.3:
        rel = rng.choice(['=', '=', '<'])
        return (rel, rand_pa_term(rng, nb, params, 2, nholes), rand_pa_term(rng, nb, params, 2, nholes))
    k = rng.choice(['not', 'and', 'or', 'imp', 'all', 'ex', 'ball', 'bex'])
    if k == 'not':
        return NOT(rand_pa_formula(rng, nb, params, depth - 1, nholes))
    if k in ('and', 'or', 'imp'):
        return (k, rand_pa_formula(rng, nb, params, depth - 1, nholes),
                rand_pa_formula(rng, nb, params, depth - 1, nholes))
    body = rand_pa_formula(rng, nb + 1, params, depth - 1, nholes)
    if k in ('all', 'ex'):
        return (k, body)
    bound = shift(rand_pa_term(rng, nb, params, 1, nholes), 1)
    guard = LT(('v', 0), bound)
    return ALL(IMP(guard, body)) if k == 'ball' else EX(AND(guard, body))


def pa_motive(rng, p_param=0.4, p_closed=0.08, depth=3):
    params = []
    if rng.random() < p_param:
        params = ['a'] if rng.random() < 0.7 else ['a', 'b']
    for _ in range(200):
        m = rand_pa_formula(rng, 0, params, rng.randint(1, depth))
        if size(m) > 22:
            continue
        if rng.random() < p_closed or has_hole(m):
            return m
    return EQ(H(0), H(0))


def rand_closed_term(rng, depth=2, params=()):
    r = rng.random()
    if depth <= 0 or r < 0.4:
        if params and rng.random() < 0.3:
            return P(rng.choice(params))
        return num(rng.randrange(4))
    k = rng.choice(['S', '+', '*'])
    if k == 'S':
        return S(rand_closed_term(rng, depth - 1, params))
    return (k, rand_closed_term(rng, depth - 1, params), rand_closed_term(rng, depth - 1, params))


def universal_instance(rng, T, p_numeral=0.6, p_param=0.15, dist='mixed'):
    """instance of a one-term-metavariable template ?t-schema.
    dist='numerals': a numeral 0..7 (the regime the task specifies: universal axioms observed only through
    numeral instances).  dist='mixed' (v1 default): a numeral w.p. p_numeral, a random closed term, or the
    parameter form w0 (which is the closure-normal form of the axiom itself) w.p. p_param."""
    if dist == 'numerals':
        return canon_params(instantiate(T, {'t': num(rng.randrange(8))}))
    r = rng.random()
    if r < p_numeral:
        t = num(rng.randrange(8))
    elif r < 1 - p_param:
        t = rand_closed_term(rng, 2)
    else:
        t = P('a')
    return canon_params(instantiate(T, {'t': t}))


# ------------------------------------------------------------------------------------ set theory
def rand_zf_formula(rng, nvars_free, nb, params, depth):
    """free variables: holes h0..h_{nvars_free-1}; nb internal bound vars; params"""
    def var():
        opts = [('h', i) for i in range(nvars_free)] * 2 + [('v', i) for i in range(nb)] * 2 + \
            [('p', p) for p in params]
        return rng.choice(opts)
    r = rng.random()
    if depth <= 0 or r < 0.3:
        rel = rng.choice(['in', 'in', '='])
        return (rel, var(), var())
    k = rng.choice(['not', 'and', 'or', 'imp', 'ball', 'bex', 'ball', 'bex', 'all', 'ex'])
    if k == 'not':
        return NOT(rand_zf_formula(rng, nvars_free, nb, params, depth - 1))
    if k in ('and', 'or', 'imp'):
        return (k, rand_zf_formula(rng, nvars_free, nb, params, depth - 1),
                rand_zf_formula(rng, nvars_free, nb, params, depth - 1))
    body = rand_zf_formula(rng, nvars_free, nb + 1, params, depth - 1)
    if k in ('all', 'ex'):
        return (k, body)
    u = shift(var(), 1)
    guard = IN(('v', 0), u)
    return ALL(IMP(guard, body)) if k == 'ball' else EX(AND(guard, body))


def zf_body(rng, nholes, need, p_param=0.4, depth=3):
    params = []
    if rng.random() < p_param:
        params = ['c'] if rng.random() < 0.7 else ['c', 'd']
    for _ in range(300):
        m = rand_zf_formula(rng, nholes, 0, params, rng.randint(1, depth))
        if size(m) > 20:
            continue
        if all(_has_h(m, i) for i in need):
            return m
    return IN(H(need[0]), H(need[0])) if need else EQ(H(0), H(0))


def _has_h(t, i):
    if t[0] == 'h':
        return t[1] == i
    if t[0] in ('v', 'p', '0'):
        return False
    from .syntax import kids
    return any(_has_h(k, i) for k in kids(t))


# ------------------------------------------------------------------------------------ mixes
def pa_mix(seed, n_ind=30, n_univ=(8, 6, 4), q_copies=1, mistakes=0, true_nontargets=0, univ_dist='numerals'):
    """v2: the universal axioms are observed through numeral instances only (univ_dist='numerals', as the task
    specifies); univ_dist='mixed' reproduces the v1 distribution (numerals, closed terms, parameter form)."""
    rng = random.Random(seed)
    data = []
    for k, s in Q_AXIOMS.items():
        for _ in range(q_copies):
            data.append((parse(s), k))
    for _ in range(n_ind):
        data.append((Ind(pa_motive(rng)), 'Ind'))
    for (name, n) in zip(['U_add0', 'U_mul0', 'U_0add'], n_univ):
        for _ in range(n):
            data.append((universal_instance(rng, U_AXIOMS[name], dist=univ_dist), name))
    data += pa_mistakes(rng, mistakes)
    data += pa_true_nontargets(rng, true_nontargets)
    rng.shuffle(data)
    return data


def pa_mistakes(rng, n):
    """injected mistakes: wrong induction step clause, wrong 'axiom', capture-like slips"""
    out = []
    kinds = ['ind_wrong_step', 'ind_wrong_base', 'bad_add0', 'ind_wrong_concl']
    for i in range(n):
        k = kinds[i % len(kinds)]
        m = pa_motive(rng)
        from .syntax import plug
        if k == 'ind_wrong_step':      # phi(0) & Ax(phi(x) -> phi(x)) -> Ax phi(x)
            s = IMP(AND(plug(m, [ZERO]), ALL(IMP(plug(m, [('v', 0)]), plug(m, [('v', 0)])))), ALL(plug(m, [('v', 0)])))
        elif k == 'ind_wrong_base':    # phi(S0) & Ax(phi(x) -> phi(Sx)) -> Ax phi(x)
            s = IMP(AND(plug(m, [S(ZERO)]), ALL(IMP(plug(m, [('v', 0)]), plug(m, [S(('v', 0))])))),
                    ALL(plug(m, [('v', 0)])))
        elif k == 'ind_wrong_concl':   # phi(0) & Ax(phi(x) -> phi(Sx)) -> Ax phi(Sx)... true; non-instance
            s = IMP(AND(plug(m, [ZERO]), ALL(IMP(plug(m, [('v', 0)]), plug(m, [S(('v', 0))])))),
                    ALL(plug(m, [S(('v', 0))])))
        else:
            s = parse('%d+0=0' % (1 + rng.randrange(3)))
        out.append((canon_params(s), 'MISTAKE:' + k))
    return out


def pa_true_nontargets(rng, n):
    pool = ['forall x. x=x', 'forall x. forall y. x+y=y+x', '0<1', 'forall x. x<Sx', '2*2=4']
    return [(parse(pool[i % len(pool)]), 'MISTAKE:true_nontarget') for i in range(n)]


def zf_mix(seed, n_sep=12, n_rep=10, n_eind=10, ax_copies=1, mistakes=0):
    rng = random.Random(seed)
    data = []
    for k, s in ZF_AXIOMS.items():
        for _ in range(ax_copies):
            data.append((parse(s), k))
    for _ in range(n_sep):
        data.append((Sep(zf_body(rng, 2, [0])), 'Sep'))
    for _ in range(n_rep):
        data.append((Rep(zf_body(rng, 3, [0, 1])), 'Rep'))
    for _ in range(n_eind):
        data.append((EInd(zf_body(rng, 1, [0])), 'EInd'))
    data += zf_mistakes(rng, mistakes)
    rng.shuffle(data)
    return data


def zf_mistakes(rng, n):
    out = []
    for i in range(n):
        k = ['sep_capture', 'eind_wrong', 'naive'][i % 3]
        if k == 'sep_capture':        # b free in phi
            body = zf_body(rng, 3, [0, 2])  # hole 2 = b (captured)
            s = instantiate(parse('forall a. exists b. forall x. (x in b <-> (x in a & ?P(x, a, b)))'), {'P': body})
        elif k == 'eind_wrong':       # Ax(phi(x) -> phi(x)) -> Ax phi(x)
            body = zf_body(rng, 1, [0])
            s = instantiate(parse('(forall x. (?P(x) -> ?P(x))) -> forall x. ?P(x)'), {'P': body})
        else:
            s = parse('forall a. exists b. forall x. (x in b <-> ~x in a)')
        out.append((canon_params(s), 'MISTAKE:' + k))
    return out


# ------------------------------------------------------------------------------------ held-out
def _fresh(gen, n, exclude, tries=40):
    """n distinct sentences from gen(), none in exclude (v2: held-out sets are de-duplicated against the
    training data); fewer if the generator cannot supply them"""
    out, seen = [], set(exclude)
    k = 0
    while len(out) < n and k < tries * n:
        k += 1
        s = canon_params(gen())
        if s in seen:
            continue
        seen.add(s)
        out.append(s)
    return out


def heldout_universal(rng, T):
    """broad held-out distribution over inst(T) for a ?t-schema: numerals 0..39, closed terms of depth <= 3,
    the parameter form"""
    r = rng.random()
    if r < 0.5:
        t = num(rng.randrange(40))
    elif r < 0.85:
        t = rand_closed_term(rng, 3)
    else:
        t = P('a')
    return canon_params(instantiate(T, {'t': t}))


def heldout_pa(seed, n=40, exclude=()):
    """held-out genuine instances per target (v2: disjoint from `exclude`, the training data).  Ground axioms
    get their single sentence (reported separately: it is always a training datum)."""
    rng = random.Random(10 ** 6 + seed)
    exclude = set(canon_params(s) for s in exclude)
    out = {'Ind': _fresh(lambda: Ind(pa_motive(rng)), n, exclude)}
    for name, T in U_AXIOMS.items():
        out[name] = _fresh(lambda: heldout_universal(rng, T), n // 2, exclude)
    for k, s in Q_AXIOMS.items():
        out[k] = [parse(s)]
    return out


def heldout_zf(seed, n=30, exclude=()):
    rng = random.Random(10 ** 6 + seed)
    exclude = set(canon_params(s) for s in exclude)
    out = {'Sep': _fresh(lambda: Sep(zf_body(rng, 2, [0])), n, exclude),
           'Rep': _fresh(lambda: Rep(zf_body(rng, 3, [0, 1])), n, exclude),
           'EInd': _fresh(lambda: EInd(zf_body(rng, 1, [0])), n, exclude)}
    for k, s in ZF_AXIOMS.items():
        out[k] = [parse(s)]
    return out


# ------------------------------------------------------------------------------------ near-miss targets
NEAR_PA = {
    'U_add0': parse('?t+0=?t'),
    'U_add1': parse('?t+1=S?t'),
    'U_mul1': parse('?t*1=?t'),
    'U_0add': parse('0+?t=?t'),
    'U_add00': parse('(?t+0)+0=?t+0'),          # nested in U_add0 (every instance is a U_add0 instance)
    'Ind': T_IND,
    'IndSwap': parse('(forall x. (?P(x) -> ?P(Sx))) & ?P(0) -> forall x. ?P(x)'),
    'IndCurry': parse('?P(0) -> (forall x. (?P(x) -> ?P(Sx))) -> forall x. ?P(x)'),
}

NEAR_ZF = {
    'Sep': T_SEP,
    'SepSwap': parse('forall a. exists b. forall x. (x in b <-> (?P(x, a) & x in a))'),
    'Rep': T_REP,
    'EInd': T_EIND,
    'FoundS': parse('(exists x. ?P(x)) -> exists x. (?P(x) & forall y in x. ~?P(y))'),     # foundation schema
    'Found': parse(ZF_AXIOMS['Found']),
}


# v2 (referee F3): "hard" ZF targets -- true schemas/axioms with similar shapes whose cross merges are not
# refuted by bot or by a naive-comprehension instance alone.
HARD_ZF = {
    'Sep': T_SEP,
    # Separation from the union of a:  {x in U a : phi}
    'SepU': parse('forall a. exists b. forall x. (x in b <-> ((exists y. (y in a & x in y)) & ?P(x, a)))'),
    'Rep': T_REP,
    # Collection
    'Coll': parse('forall a. ((forall x. (x in a -> exists y. ?P(x, y, a))) -> '
                  'exists b. forall x. (x in a -> exists y. (y in b & ?P(x, y, a))))'),
    'EInd': T_EIND,
    # induction along z in y in x (well-founded)
    'EInd2': parse('(forall x. ((forall y. (y in x -> forall z. (z in y -> ?P(z)))) -> ?P(x))) -> forall x. ?P(x)'),
    'FoundS': NEAR_ZF['FoundS'],
    # weak (bounding) forms of Union and Power (untagged track, Prop. 7.1)
    'UnionW': parse('forall a. exists b. forall x. ((exists y. (y in a & x in y)) -> x in b)'),
    'PowerW': parse('forall a. exists b. forall x. ((forall y. (y in x -> y in a)) -> x in b)'),
}


def schema_instance(T, lang, rng, univ_dist='mixed'):
    """a random instance of a target template (ground targets: the sentence itself)"""
    from .templates import metas
    ms = metas(T)
    if not ms:
        return T
    if 't' in ms:
        return universal_instance(rng, T, dist=univ_dist)
    ar = ms['P']
    if lang == 'PA':
        return canon_params(instantiate(T, {'P': pa_motive(rng)}))
    need = [0] if ar <= 2 else [0, 1]
    return canon_params(instantiate(T, {'P': zf_body(rng, ar, need)}))


def near_miss_pa(seed, n=10):
    rng = random.Random(seed)
    data = []
    for name, T in NEAR_PA.items():
        for _ in range(n):
            if name.startswith('U_'):
                data.append((universal_instance(rng, T), name))
            else:
                data.append((canon_params(instantiate(T, {'P': pa_motive(rng)})), name))
    rng.shuffle(data)
    return data


def near_miss_zf(seed, n=8):
    rng = random.Random(seed)
    data = []
    for name, T in NEAR_ZF.items():
        if name == 'Found':
            data.append((T, name))
            continue
        for _ in range(n):
            if name in ('Sep', 'SepSwap'):
                b = zf_body(rng, 2, [0])
            elif name == 'Rep':
                b = zf_body(rng, 3, [0, 1])
            else:
                b = zf_body(rng, 1, [0])
            data.append((canon_params(instantiate(T, {'P': b})), name))
    rng.shuffle(data)
    return data
