# Track "single": witness events of the general anchor theorem (Theorem D) and wrong candidates.
#   (R*)  at every occurrence (pattern or derived) of every metavariable the data contents do not all
#         have the same head symbol
#   (N)   every argument position of every metavariable is used (hole present) by some datum's value
#   (U°)  no coincidence: for every occurrence sigma and every rigid-or-occurrence position r of T*,
#         incomparable with sigma, of the same sort: if d|r = (d|sigma)[u/Y_sigma] for all data d, then
#         r is an occurrence of the same metavariable with args t_r = t_sigma[u]
#   (U_pat) the same, with sigma restricted to pattern occurrences          [WRONG candidate]
#   (R)   at pattern occurrences only (= value heads not all equal)         [WRONG candidate as part]
#   (D)   distinct metavariables of the same type differ in some datum      [special case of U]
from dtcore import *
from dtfeat import Prefix


def skeleton_positions(T):
    """positions of rigid (non-metavariable) nodes and of occurrences, with binder depth and sort"""
    out = {}
    for p, t, d, srt in positions(T):
        out[p] = (t, d, srt)
    return out


def events(Tstar, thetas):
    D = [instantiate(Tstar, th) for th in thetas]
    occ = occurrences(Tstar)
    pos = skeleton_positions(Tstar)
    res = {}
    # (R*) and (R)
    Rstar, Rpat = True, True
    for (p, nm, args, d) in occ:
        heads = {node_key(sub(s, p)) for s in D}
        if len(heads) == 1:
            Rstar = False
            if is_pattern_args(args):
                Rpat = False
    for nm in metas(Tstar):
        vh = {node_key(th[nm]) for th in thetas}
        if len(vh) == 1:
            Rpat = False
    res['R*'], res['R'] = Rstar, Rpat
    # (N)
    Nok = True
    ar = {o[1]: len(o[2]) for o in occ}
    for nm, n in ar.items():
        for m in range(n):
            if not any(m in holes(th[nm]) for th in thetas):
                Nok = False
    res['N'] = Nok
    # (D)
    Dok = True
    nms = sorted(ar)
    for a in nms:
        for b in nms:
            if a < b and msort(a) == msort(b) and ar[a] == ar[b]:
                if all(th[a] == th[b] for th in thetas):
                    Dok = False
    res['D'] = Dok
    # (U°), (U_pat)
    Uall, Upat = True, True
    witnesses = []
    occd = {o[0]: o for o in occ}
    for (sp, nm, args, d) in occ:
        Ys = set()
        for a in args:
            Ys |= fv(a)
        for r, (t, dr, sr) in pos.items():
            if r == sp or comparable(r, sp):
                continue
            if sr != msort(nm):
                continue
            umap = {}
            if not all(Prefix.align(sub(s, sp), sub(s, r), umap) for s in D):
                continue
            valid = False
            if r in occd and occd[r][1] == nm:
                if set(umap) >= Ys:
                    ta = tuple(subst_free(a, umap) for a in args)
                    valid = (ta == occd[r][2])
                else:
                    valid = None   # undetermined: (N) fails
            if valid is False:
                Uall = False
                witnesses.append((sp, r, tuple(sorted(umap.items()))))
                if is_pattern_args(args):
                    Upat = False
    res['U'] = Uall
    res['Upat'] = Upat
    res['Uwit'] = witnesses
    res['pred'] = Rstar and Nok and Uall
    return res, D


def anchor_by_features(Tstar, D):
    """D anchor iff every template realizing a D-feature is >= T* (syntactic sufficient check) --
    returns (all_geq, list of non-subsuming feature templates)"""
    P = Prefix(D)
    bad = [T for T in P.feature_templates() if not subsumes(T, Tstar)]
    return (not bad), bad
