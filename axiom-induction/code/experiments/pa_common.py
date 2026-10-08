"""PA mixture (Q's axioms + induction instances): generator, candidate pool and reporting, shared by E2/E3.

Deductive-equivalence tags (all relative to T* = Q1..Q7 + T_Ind; proofs in the track notes, Prop. X2):
  * a theory containing T* plus true sentences or plus templates whose instances are induction instances
    is equivalent (spare true slots);
  * frag-complete has exactly the instance set of T_Ind (every motive has one of the 9 roots), so it has
    the same axioms;
  * a theory Q + {T_f : f in F} with F containing a connective (not, and, or, imp, iff, all, ex) is
    equivalent: Ind(phi) follows in pure logic from Ind(f-wrapped phi), e.g. Ind(phi & phi), Ind(~~phi)
    or Ind(~~phi) (from T_not with P1 := ~phi), which are logically equivalent to Ind(phi) given the
    base and step of phi;
  * theories with only atomic fragments (=, <) are not known to be equivalent (tag 'unknown');
  * a theory with a false axiom (spare_false, unsound generalisations) is tagged 'unsound'.
"""
import random

from common import parse, pp, Component, Theory, dedupe
from dtrc.schemas import Q_AXIOMS, T_IND
from dtrc.datasets import NEAR_PA
from dtrc.templates import equiv, geq, canon, metas, is_DT0
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


def build_pa_pool(data, seed, n_dtrc=40, refuter=True):
    """the E2/E3 candidate pool (Mem(D_n) is added by evaluate)"""
    rng = random.Random(500 + seed)
    pool = [t_star()]
    frs = {f: T_frag(f) for f in ROOTS}
    pool.append(Theory(QSENT + list(frs.values()), 'frag-complete',
                       {'cls': 'fragmented', 'equiv': 'yes', 'sound': True}))
    seen_roots = []
    for d in data[:64]:
        r = motive_root(d)
        if r and r not in seen_roots:
            seen_roots.append(r)
    pool.append(Theory(QSENT + [frs[f] for f in seen_roots], 'frag-observed64',
                       {'cls': 'fragmented', 'equiv': 'yes' if set(seen_roots) & set(CONNECTIVES) else 'unknown',
                        'sound': True}))
    pool.append(Theory(QSENT + [frs['='], frs['<']], 'frag-atoms',
                       {'cls': 'over-specific', 'equiv': 'unknown', 'sound': True}))
    for i in range(7):
        pool.append(Theory(QSENT[:i] + QSENT[i + 1:] + [T_IND], 'T*-Q%d' % (i + 1),
                           {'cls': 'sub-T*', 'equiv': 'no', 'sound': True}))
    pool.append(Theory(QSENT + [T_IND, frs['and']], 'spare-nested(T_and)',
                       {'cls': 'spare', 'equiv': 'yes', 'sound': True}))
    pool.append(Theory(QSENT + [T_IND, parse('forall x. 0+x=x')], 'spare-true(0+x=x)',
                       {'cls': 'spare', 'equiv': 'yes', 'sound': True}))
    pool.append(Theory(QSENT + [T_IND, parse('0=S0')], 'spare-false(0=1)',
                       {'cls': 'spare', 'equiv': 'no', 'sound': False}))
    pool.append(Theory(QSENT + [NEAR_PA['IndSwap']], 'IndSwap (equivalent, uncited)',
                       {'cls': 'equivalent-uncited', 'equiv': 'yes', 'sound': True}))
    pool.append(Theory(QSENT + [parse('(?A & forall x. (?P(x) -> ?P(Sx))) -> forall x. ?P(x)')],
                       'Ind-any-base', {'cls': 'over-general', 'equiv': 'no', 'sound': False}))
    pool.append(Theory(QSENT + [parse('?A -> forall x. ?P(x)')], 'Ind-any-antecedent',
                       {'cls': 'over-general', 'equiv': 'no', 'sound': False}))
    pool.append(Theory([parse('?P')], 'bare?P', {'cls': 'over-general', 'equiv': 'no', 'sound': False}))
    pool.append(Theory([parse('forall x. forall y. ?P(x, y)'), parse('forall x. ?P(x)'), T_IND],
                       'Q-lumped', {'cls': 'over-general', 'equiv': 'no', 'sound': False}))
    # data-derived: skeleton clusters (no refutation) and DTRC (with refutation) on a subsample
    sub = data[:n_dtrc]
    for k, temps in skeleton_theories(sub, ks=(4, 6, 8)):
        pool.append(_tagged(Theory(temps, 'skel%d' % k), 'skeleton', sub))
    if refuter:
        from dtrc.refute import TemplateRefuter
        from dtrc.dtrc import DTRC
        R = TemplateRefuter('PA', budget=40, data_budget=10, seed=seed)
        for n in (16, n_dtrc):
            m = DTRC(R).fit(data[:n])
            temps = []
            for c in m.clusters:
                temps.extend(c.acc[:1] if c.acc else c.data)
            pool.append(_tagged(Theory(temps, 'DTRC(n=%d)' % n), 'dtrc', data[:n]))
    # Q + Min of random subsets of the data
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
            pool.append(_tagged(Theory(QSENT + [T], 'Q+min%d' % i), 'min', D))
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


def _tagged(th, cls, data=()):
    """tag a data-derived theory by comparing its non-Q templates with T_Ind and the fragments, and by
    searching for false instances of its templates with the dtrc PA refuter"""
    others = [c.T for c in th.comps if not any(c.T == q for q in QSENT)]
    has_q = all(any(c.T == q for c in th.comps) for q in QSENT)
    frs = [T_frag(f) for f in CONNECTIVES]
    tag = {'cls': cls}
    good_ind = any(equiv(T, T_IND) for T in others) or any(any(equiv(T, F) for F in frs) for T in others)
    nq = sum(1 for q in QSENT if any(c.T == q for c in th.comps))
    tag['n_Q'] = nq
    if good_ind and has_q:
        tag.update(equiv='yes')
    elif good_ind and all(equiv(T, T_IND) or any(equiv(T, F) for F in frs) for T in others):
        tag.update(equiv='no', cls='sub-T*', sound=True)      # T* minus unseen Q axioms
    else:
        tag.update(equiv='unknown')
    if any(geq(T, T_IND) and not equiv(T, T_IND) for T in others):
        tag.update(sound=False, equiv='no')
    ref = [T for T in others if refuted_template(T, data)]
    if ref:
        tag.update(sound=False, equiv='no', refuted=[pp(T) for T in ref])
    elif 'sound' not in tag:
        tag['sound'] = 'unrefuted'
    th.tags.update(tag)
    return th


def pa_heldout(Q, seed, n=6):
    """held-out induction instances (motives from Q) and false probe sentences"""
    rng = random.Random(9000 + seed)
    from dtrc.templates import instantiate
    from dtrc.syntax import canon_params
    inst = [canon_params(instantiate(T_IND, {'P': Q.sample_form(rng, 1, 0, False)})) for _ in range(n)]
    false = [parse('0=S0'), parse('forall x. x+0=0'), parse('(0=0 & forall x. (0<x -> 0<Sx)) -> forall x. 0<x'),
             parse('forall x. S x = x'), parse('forall x. forall y. y=x')]
    return inst, false
