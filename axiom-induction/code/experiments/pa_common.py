"""PA mixture (Q's axioms + induction instances): generator, candidate pools, tags and reporting, shared by
E2, E3(b) and E7.

Q axioms (dtrc numbering): Q1 Ax ~Sx=0; Q2 AxAy (Sx=Sy -> x=y); Q3 Ax (~x=0 -> Ey x=Sy); Q4 Ax x+0=x;
Q5 AxAy x+Sy=S(x+y); Q6 Ax x*0=0; Q7 AxAy x*Sy=x*y+x.  T* = Q1..Q7 + T_Ind.

Tags (pa_classify; proofs in the track notes, Props X9, X10, X11):
  equiv = 'yes'     deductively equivalent to T*: all of Q1, Q2, Q4..Q7 present (Q3 follows from T_Ind), a
                    full-induction template present (T_Ind, IndSwap, or a connective fragment T_f), every other
                    component a theorem of T* (Q3, an induction instance or specialisation of T_Ind, an atomic
                    fragment, the true sentence Ax 0+x=x);
  equiv = 'weaker'  sound and strictly weaker than T*: components only Q axioms and induction-type templates
                    (T_Ind, IndSwap, fragments, specialisations and instances of T_Ind), and either one of
                    Q1, Q2, Q4..Q7 missing (Prop X11: explicit models) or no full-induction template (only
                    atomic fragments or none: contained in Q + open induction, Prop X10, given Shepherdson 1964);
  equiv = 'no'      unsound (a false sentence, a template more general than T_Ind, or a template the dtrc PA
                    refuter refutes);
  equiv = 'unknown' otherwise (e.g. Q + a Min template that the budgeted refuter did not refute).
  sound = True / False / 'unrefuted' (the refuter is budgeted: 'unrefuted' is not 'sound').
"""
import random

from common import parse, pp, Component, Theory, dedupe
from dtrc.schemas import Q_AXIOMS, T_IND
from dtrc.datasets import NEAR_PA
from dtrc.templates import equiv, geq, canon, metas, is_DT0, meta_sort
from dtrc.mincover import aligned_min
from bai.pool import partial_instantiate, skeleton_theories
from bai.grammar import Grammar

QSENT = [parse(s) for s in Q_AXIOMS.values()]
ROOTS = ['=', '<', 'not', 'and', 'or', 'imp', 'iff', 'all', 'ex']
CONNECTIVES = ['not', 'and', 'or', 'imp', 'iff', 'all', 'ex']
W_TRUE = [0.05] * 7 + [0.65]


def motive_frag(f):
    h0 = ('h', 0)
    if f in ('=', '<'):
        return (f, ('M', 'a', (h0,)), ('M', 'b', (h0,)))
    if f == 'not':
        return ('not', ('M', 'P1', (h0,)))
    if f in ('all', 'ex'):
        return (f, ('M', 'P1', (h0, ('v', 0))))
    return (f, ('M', 'P1', (h0,)), ('M', 'P2', (h0,)))


def T_frag(f):
    T = partial_instantiate(T_IND, {'P': motive_frag(f)})
    assert is_DT0(T), pp(T)
    return T


def t_star():
    return Theory(QSENT + [T_IND], 'T*', {'cls': 'true', 'equiv': 'yes', 'sound': True})


def motive_root(d):
    """root of the motive of an induction instance (via the unique match against T_Ind), else None"""
    from dtrc.templates import match
    th = match(T_IND, d)
    if th is None:
        return None
    return th['P'][0]


QCANON = {}
for _i, _q in enumerate(QSENT):
    QCANON[_q] = 'Q%d' % (_i + 1)
NEEDED_Q = {'Q1', 'Q2', 'Q4', 'Q5', 'Q6', 'Q7'}      # Q3 follows from T_Ind (Prop X11)
FALSE_SENTENCES = {parse('0=S0')}
TRUE_THEOREMS = {parse('forall x. 0+x=x')}           # theorems of T*, not of every sub-theory


def _full_ind_canons():
    out = {canon(T_IND), canon(NEAR_PA['IndSwap'])}
    out |= {canon(T_frag(f)) for f in CONNECTIVES}
    return out


def _atomic_ind_canons():
    return {canon(T_frag('=')), canon(T_frag('<'))}


_FULL, _ATOM = None, None
_REFUTED = {}          # canon(template) -> bool (refuted by the budgeted dtrc PA refuter)


def _refuted(T, data):
    c = canon(T)
    r = _REFUTED.get(c)
    if r is None:
        r = bool(refuted_template(T, data))
        _REFUTED[c] = r
    return r


def pa_classify(th, data=()):
    """set th.tags['equiv'] in {'yes', 'weaker', 'no', 'unknown'} and th.tags['sound'] (see module
    docstring).  `data` seeds the refuter's search for data-derived templates (results are cached per
    template, so trimmed sub-theories reuse their parent's results)."""
    global _FULL, _ATOM
    if _FULL is None:
        _FULL, _ATOM = _full_ind_canons(), _atomic_ind_canons()
    qs, full, true_extra, unsound = set(), False, False, False
    ind_formula = False          # an induction-type template with a formula metavariable (strength unknown)
    unknown = []
    for c in th.comps:
        T = c.T
        if T in QCANON:
            qs.add(QCANON[T])
            continue
        if T in FALSE_SENTENCES:
            unsound = True
            continue
        if T in TRUE_THEOREMS:
            true_extra = True
            continue
        k = canon(T)
        if k in _FULL:
            full = True
        elif k in _ATOM:
            pass                                  # term-only induction template (atomic motive)
        elif geq(T_IND, T):
            # a specialisation or instance of T_Ind: a theorem of T*; with a formula metavariable it may
            # still give full induction (pa track Prop 4.8(a)), without one it has a fixed skeleton
            if any(meta_sort(m) == 'F' for m in metas(T)):
                ind_formula = True
        elif geq(T, T_IND):
            unsound = True                        # strictly more general than T_Ind: has false instances
        elif _refuted(T, data):
            unsound = True
        else:
            unknown.append(T)
    tags = th.tags
    if unsound:
        tags.update(equiv='no', sound=False)
        return th
    tags['sound'] = True if not unknown else 'unrefuted'
    if unknown:
        tags['equiv'] = 'unknown'
    elif not NEEDED_Q <= qs:
        # Prop X11: a model of (Q minus some Q_i, i != 3) + every induction instance, falsifying Q_i
        tags['equiv'] = 'unknown' if true_extra else 'weaker'
    elif full:
        tags['equiv'] = 'yes'
    elif ind_formula or true_extra:
        tags['equiv'] = 'unknown'
    else:
        # only term-only induction templates: contained in some I-Sigma_k (pa Prop 4.8(b)); atomic fragments
        # only: contained in Q + open induction (Prop X10)
        tags['equiv'] = 'weaker'
    return th


def pa_hand_pool():
    """the fixed (data-independent) members of the PA pools"""
    frs = {f: T_frag(f) for f in ROOTS}
    pool = [t_star(),
            Theory(QSENT + list(frs.values()), 'frag-complete', {'cls': 'fragmented'}),
            Theory(QSENT + [frs['='], frs['<']], 'frag-atoms', {'cls': 'fragmented'})]
    for i in range(7):
        pool.append(Theory(QSENT[:i] + QSENT[i + 1:] + [T_IND], 'T*-Q%d' % (i + 1), {'cls': 'sub-T*'}))
    pool += [Theory(QSENT + [T_IND, frs['and']], 'spare-nested(T_and)', {'cls': 'spare'}),
             Theory(QSENT + [T_IND, parse('forall x. 0+x=x')], 'spare-true(0+x=x)', {'cls': 'spare'}),
             Theory(QSENT + [T_IND, parse('0=S0')], 'spare-false(0=1)', {'cls': 'spare'}),
             Theory(QSENT + [NEAR_PA['IndSwap']], 'IndSwap (equivalent, uncited)', {'cls': 'equivalent-uncited'}),
             Theory(QSENT + [parse('(?A & forall x. (?P(x) -> ?P(Sx))) -> forall x. ?P(x)')], 'Ind-any-base',
                    {'cls': 'over-general'}),
             Theory(QSENT + [parse('?A -> forall x. ?P(x)')], 'Ind-any-antecedent', {'cls': 'over-general'}),
             Theory([parse('?P')], 'bare?P', {'cls': 'over-general'}),
             Theory([parse('forall x. forall y. ?P(x, y)'), parse('forall x. ?P(x)'), T_IND], 'Q-lumped',
                    {'cls': 'over-general'})]
    for th in pool:
        pa_classify(th)
    return pool


PA_BUILD_POINTS = [8, 16, 32, 64]


def pa_builder(seed, refuter=True):
    """data-derived PA theories built from D_b only: frag-observed@b (Q + the fragments of the motive roots
    seen in D_b), skeleton clusters (DTRC without refutation, k = 4, 6, 8), DTRC with the dtrc PA refuter,
    and Q + Min of random subsets of the induction data of D_b"""
    def builder(Db, b):
        rng = random.Random((500 + seed) * 1000 + b)
        out = []
        seen_roots = []
        for d in Db:
            r = motive_root(d)
            if r and r not in seen_roots:
                seen_roots.append(r)
        if seen_roots:
            out.append(Theory(QSENT + [T_frag(f) for f in seen_roots], 'frag-observed@%d' % b,
                              {'cls': 'fragmented'}))
        for k, temps in skeleton_theories(Db, ks=(4, 6, 8)):
            out.append(Theory(temps, 'skel%d@%d' % (k, b), {'cls': 'skeleton'}))
        if refuter:
            from dtrc.refute import TemplateRefuter
            from dtrc.dtrc import DTRC
            R = TemplateRefuter('PA', budget=40, data_budget=10, seed=seed)
            m = DTRC(R).fit(list(Db))
            temps = []
            for c in m.clusters:
                temps.extend(c.acc[:1] if c.acc else c.data)
            out.append(Theory(temps, 'DTRC@%d' % b, {'cls': 'dtrc'}))
        ind = [d for d in Db if not any(d == q for q in QSENT)]
        for i in range(8):
            k = rng.choice([2, 3])
            if len(ind) < k:
                break
            D = rng.sample(ind, k)
            try:
                mins, _ = aligned_min(D)
            except Exception:
                continue
            for T in mins[:1]:
                if not metas(T):
                    continue
                out.append(Theory(QSENT + [T], 'Q+min%d@%d' % (i, b), {'cls': 'min'}))
        for th in out:
            pa_classify(th, Db)
        return out
    return builder


def causal_pa_pool(data, seed, extra_fixed=(), refuter=True):
    """the PA pool that uses only data already seen (CausalPool); evaluate it with trim=True and
    tagger=pa_classify to add Trim(T, D_n) (e.g. SeenQ(D_n) = Trim(T*, D_n))"""
    from bai.pool import CausalPool
    fixed = pa_hand_pool() + list(extra_fixed)
    for th in extra_fixed:
        pa_classify(th)
    return CausalPool(dedupe(fixed), pa_builder(seed, refuter), PA_BUILD_POINTS, data)


def build_pa_pool(data, seed, n_dtrc=40, refuter=True):
    """the pre-referee ("legacy") E2/E3 pool, kept for comparison: data-derived members are built from the
    first 16, 40 and 64 data, so at smaller n they use data the learner has not seen (referee M1)"""
    rng = random.Random(500 + seed)
    pool = pa_hand_pool()
    seen_roots = []
    for d in data[:64]:
        r = motive_root(d)
        if r and r not in seen_roots:
            seen_roots.append(r)
    pool.append(pa_classify(Theory(QSENT + [T_frag(f) for f in seen_roots], 'frag-observed64',
                                   {'cls': 'fragmented'})))
    sub = data[:n_dtrc]
    for k, temps in skeleton_theories(sub, ks=(4, 6, 8)):
        pool.append(pa_classify(Theory(temps, 'skel%d' % k, {'cls': 'skeleton'}), sub))
    if refuter:
        from dtrc.refute import TemplateRefuter
        from dtrc.dtrc import DTRC
        R = TemplateRefuter('PA', budget=40, data_budget=10, seed=seed)
        for n in (16, n_dtrc):
            m = DTRC(R).fit(data[:n])
            temps = []
            for c in m.clusters:
                temps.extend(c.acc[:1] if c.acc else c.data)
            pool.append(pa_classify(Theory(temps, 'DTRC(n=%d)' % n, {'cls': 'dtrc'}), data[:n]))
    ind = [d for d in data[:64] if not any(d == q for q in QSENT)]
    for i in range(8):
        k = rng.choice([2, 3])
        if len(ind) < k:
            break
        D = rng.sample(ind, k)
        try:
            mins, _ = aligned_min(D)
        except Exception:
            continue
        for T in mins[:1]:
            if not metas(T):
                continue
            pool.append(pa_classify(Theory(QSENT + [T], 'Q+min%d' % i, {'cls': 'min'}), D))
    return dedupe(pool)


_REFUTER = {}


def refuted_template(T, data):
    """True if the dtrc PA refuter finds an instance of T that is false in N (a sound, budgeted check: False
    means 'not refuted', not 'true')"""
    from dtrc.refute import TemplateRefuter
    from dtrc.templates import match
    R = _REFUTER.get('PA')
    if R is None:
        R = TemplateRefuter('PA', budget=60, data_budget=10, seed=0)
        _REFUTER['PA'] = R
    if not metas(T):
        return R.oracle.refutes(T)
    cov = [d for d in data if match(T, d) is not None][:20]
    return bool(R.refuted(T, cov))


def pa_heldout(Q, seed, n=6, exclude=()):
    """held-out induction instances (motives from Q, drawn until n instances outside `exclude`, e.g. the
    training stream) and false probe sentences"""
    rng = random.Random(9000 + seed)
    from dtrc.templates import instantiate
    from dtrc.syntax import canon_params
    excl = set(exclude)
    inst = []
    tries = 0
    while len(inst) < n and tries < 10000:
        tries += 1
        d = canon_params(instantiate(T_IND, {'P': Q.sample_form(rng, 1, 0, False)}))
        if d not in excl and d not in inst:
            inst.append(d)
    false = [parse('0=S0'), parse('forall x. x+0=0'), parse('(0=0 & forall x. (0<x -> 0<Sx)) -> forall x. 0<x'),
             parse('forall x. S x = x'), parse('forall x. forall y. y=x')]
    return inst, false
