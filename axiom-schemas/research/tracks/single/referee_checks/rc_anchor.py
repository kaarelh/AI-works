# Referee's independent implementation of the witness events (R*), (N), (U) of Theorem D,
# plus the weaker candidates, and two independent "ground truths" for anchor status:
#   feat_truth  : search an adversarial finite set of instances of T* for one outside Feat(D)
#                 (uses Theorem C: Acc(D) = Feat(D); a found instance is certified by T_0/T_phi,
#                  which are explicit covering templates, so non-anchor answers are unconditional)
#   enum_truth  : brute force over covering templates (rc_enum), bounded; a covering template not
#                 >= T* that misses an instance of T* certifies non-anchor without any theory.
import itertools
from rc_core import *
from rc_random import candidate_bodies


def events(Tstar, D):
    thetas = [match(Tstar, d) for d in D]
    assert all(th is not None for th in thetas)
    occs = occurrences(Tstar)                     # (p, occ, b)
    skel = [(p, s, b) for (p, s, b) in all_positions(Tstar) if s[0] != '?']
    mt = metas(Tstar)
    res = {}
    # (R*) at every occurrence; (R) at pattern occurrences only
    Rstar = True
    R = True
    for p, o, b in occs:
        roots = {root_sym(sub_at(d, p)) for d in D}
        if len(roots) == 1:
            Rstar = False
            if is_pattern_args(o[2]):
                R = False
    # Plotkin-style (R): roots of the VALUES not all equal (holes count)
    Rval = all(len({root_sym(th[nm]) for th in thetas}) > 1 for nm in mt)
    res['R*'] = Rstar
    res['R'] = Rval
    # (N)
    Nok = True
    for nm, lst in mt.items():
        ar = len(lst[0][1])
        for m in range(ar):
            if not any(m in holes(th[nm]) for th in thetas):
                Nok = False
    res['N'] = Nok
    # (D): distinct metavariables of the same sort differ in some datum (value-wise)
    Dok = True
    names = list(mt)
    for a, b2 in itertools.combinations(names, 2):
        if sort_of(('?', a, ())) == sort_of(('?', b2, ())) and len(mt[a][0][1]) == len(mt[b2][0][1]):
            if all(th[a] == th[b2] for th in thetas):
                Dok = False
    res['D'] = Dok
    # (U) over all occurrences, and restricted to pattern occurrences
    U = True
    Upat = True
    witnesses = []
    rpos = [(p, s) for (p, s, b) in skel] + [(p, o) for (p, o, b) in occs]
    for sp, so, sb in occs:
        Ystar = fv(('?', 'tmp', so[2]))
        for rp, rs in rpos:
            if comparable(sp, rp) or sort_of(sub_at(D[0], sp)) != sort_of(sub_at(D[0], rp)):
                continue
            # validity
            valid = False
            if rs[0] == '?' and rs[1] == so[1]:
                u0 = solve_eq(list(zip(so[2], rs[2])))
                if u0 is not None:
                    valid = True
            if valid:
                continue
            u = solve_eq([(sub_at(d, sp), sub_at(d, rp)) for d in D])
            if u is not None:
                U = False
                witnesses.append((sp, rp, u))
                if is_pattern_args(so[2]):
                    Upat = False
    res['U'] = U
    res['Upat'] = Upat
    return res, witnesses


def feat_truth(Tstar, D, extra_rng=None, n_random=0):
    """True iff no instance from an adversarial candidate set lies outside Feat(D)."""
    info = DataInfo(D)
    mt = metas(Tstar)
    names = list(mt)
    cands = [candidate_bodies(nm, len(mt[nm][0][1])) for nm in names]
    for combo in itertools.product(*cands):
        th = dict(zip(names, combo))
        q = inst(Tstar, th)
        if not info.has_features(q):
            return False, q
    if extra_rng is not None:
        from rc_random import rbody
        for _ in range(n_random):
            th = {nm: rbody(extra_rng, nm, len(mt[nm][0][1])) for nm in names}
            q = inst(Tstar, th)
            if not info.has_features(q):
                return False, q
    return True, None
