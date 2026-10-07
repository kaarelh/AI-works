"""DT° templates: second-order templates over the object language whose metavariables are applied to
metavariable-free argument terms, each metavariable having at least one *pattern occurrence* (a rigid
occurrence applied to pairwise distinct bound variables; any occurrence for 0-ary metavariables).

Instances: substitute closed lambda-bodies (holes ('h',m) for the arguments; parameters allowed, no free
de Bruijn index) and beta-reduce (one-step plugging).  inst(T) is read modulo injective renaming of
parameters (closure-normal form), so matching allows the template's rigid parameters to be renamed.

Matching a determinate template is unique and linear (read each metavariable off a pattern occurrence,
check the rest by plugging).
"""
from .syntax import (BINDERS, LEAVES, kids, rebuild, shift, unshift, plug, size, meta_sort, canon_params,
                     params_of, free_indices, pp)


def instantiate(T, theta):
    h = T[0]
    if h == 'M':
        args = tuple(instantiate(a, theta) for a in T[2])
        return plug(theta[T[1]], args)
    if h in LEAVES:
        return T
    return rebuild(T, [instantiate(k, theta) for k in kids(T)])


def meta_occurrences(T, depth=0, path=(), acc=None):
    """list of (name, args, depth, path) for all (rigid) metavariable occurrences"""
    if acc is None:
        acc = []
    h = T[0]
    if h == 'M':
        acc.append((T[1], T[2], depth, path))
        return acc
    if h in LEAVES:
        return acc
    nd = depth + 1 if h in BINDERS else depth
    for i, k in enumerate(kids(T)):
        meta_occurrences(k, nd, path + (i,), acc)
    return acc


def metas(T):
    """name -> arity"""
    out = {}
    for (n, args, d, p) in meta_occurrences(T):
        out[n] = len(args)
    return out


def is_pattern_args(args, depth):
    if any(a[0] != 'v' or a[1] >= depth for a in args):
        return False
    return len(set(args)) == len(args)


def _has_meta(t):
    if t[0] == 'M':
        return True
    if t[0] in LEAVES:
        return False
    return any(_has_meta(k) for k in kids(t))


def is_DT0(T):
    """every occurrence has metavariable-free args (DT°) and every metavariable has a pattern occurrence"""
    occ = meta_occurrences(T)
    pat = set()
    for (n, args, d, p) in occ:
        if any(_has_meta(a) for a in args):
            return False
        if is_pattern_args(args, d):
            pat.add(n)
    return all(n in pat for (n, _, _, _) in occ)


class _Clash(Exception):
    pass


def _rigid_walk(T, s, depth, occ, pmap, pinv):
    h = T[0]
    if h == 'M':
        occ.append((T[1], T[2], depth, s))
        return
    if h != s[0]:
        raise _Clash
    if h == 'v':
        if T[1] != s[1]:
            raise _Clash
        return
    if h == 'p':
        a, b = T[1], s[1]
        if a in pmap:
            if pmap[a] != b:
                raise _Clash
        else:
            if b in pinv:
                raise _Clash
            pmap[a] = b
            pinv[b] = a
        return
    if h in LEAVES:
        return
    if h == 'C':
        if T[1] != s[1] or len(T[2]) != len(s[2]):
            raise _Clash
    kT, ks = kids(T), kids(s)
    if len(kT) != len(ks):
        raise _Clash
    nd = depth + 1 if h in BINDERS else depth
    for a, b in zip(kT, ks):
        _rigid_walk(a, b, nd, occ, pmap, pinv)


def abstract(content, args, depth):
    """body b with plug(b, args) == content, for pattern args (distinct bound variables at the occurrence);
    None if content has a free bound variable outside args"""
    pos = {a[1]: i for i, a in enumerate(args)}

    def go(t, r):
        h = t[0]
        if h == 'v':
            k = t[1]
            if k < r:
                return t
            j = k - r
            if j in pos:
                return ('h', pos[j])
            raise _Clash
        if h in LEAVES:
            return t
        nr = r + 1 if h in BINDERS else r
        return rebuild(t, [go(k, nr) for k in kids(t)])
    try:
        return go(content, 0)
    except _Clash:
        return None


def rename_params_in(t, ren):
    h = t[0]
    if h == 'p':
        return ('p', ren.get(t[1], t[1]))
    if h in LEAVES:
        return t
    return rebuild(t, [rename_params_in(k, ren) for k in kids(t)])


def match(T, s):
    """unique matcher theta (dict name -> body) of the DT° template T against the sentence s, or None.
    Template parameters are matched up to injective renaming; the arguments of non-pattern occurrences are
    renamed accordingly before plugging."""
    occ, pmap, pinv = [], {}, {}
    try:
        _rigid_walk(T, s, 0, occ, pmap, pinv)
    except _Clash:
        return None
    theta = {}
    for (n, args, d, c) in occ:
        if n in theta:
            continue
        if is_pattern_args(args, d):
            b = abstract(c, args, d)
            if b is None:
                return None
            theta[n] = b
    if len(theta) != len({o[0] for o in occ}):
        raise ValueError('template not determinate: %s' % pp(T))
    for (n, args, d, c) in occ:
        if any(params_of(a) for a in args):
            unm = [p for a in args for p in params_of(a) if p not in pmap]
            if unm:
                # template parameters occurring only in arguments: match them injectively
                ren = dict(pmap)
                ren.update({p: '\x00' + p for p in unm})
                a2 = tuple(rename_params_in(a, ren) for a in args)
                if not _match_params(plug(theta[n], a2), c, pmap, pinv):
                    return None
                continue
            a2 = tuple(rename_params_in(a, pmap) for a in args)
        else:
            a2 = args
        if plug(theta[n], a2) != c:
            return None
    return theta


def _match_params(pat, tgt, pmap, pinv):
    """structural equality where parameters named '\x00p' are variables mapped injectively (extends pmap)"""
    h = pat[0]
    if h == 'p' and pat[1].startswith('\x00'):
        if tgt[0] != 'p':
            return False
        a, b = pat[1][1:], tgt[1]
        if a in pmap:
            return pmap[a] == b
        if b in pinv:
            return False
        pmap[a] = b
        pinv[b] = a
        return True
    if h != tgt[0]:
        return False
    if h in LEAVES:
        return pat == tgt
    if h in ('M', 'C') and (pat[1] != tgt[1] or len(pat[2]) != len(tgt[2])):
        return False
    kp, kt = kids(pat), kids(tgt)
    if len(kp) != len(kt):
        return False
    return all(_match_params(a, b, pmap, pinv) for a, b in zip(kp, kt))


def covers(T, s):
    return match(T, s) is not None


def covers_all(T, D):
    return all(match(T, s) is not None for s in D)


def freeze(T):
    h = T[0]
    if h == 'M':
        return ('C', T[1], tuple(freeze(a) for a in T[2]))
    if h in LEAVES:
        return T
    return rebuild(T, [freeze(k) for k in kids(T)])


def geq(T1, T2):
    """T1 is at least as general as T2 (T2 = T1 sigma, beta-normalized, up to parameter renaming)"""
    return match(T1, freeze(T2)) is not None


def equiv(T1, T2):
    return geq(T1, T2) and geq(T2, T1)


def canon(T):
    """rename metavariables (P0,P1,.. formula; f0,f1,.. term) in preorder of first occurrence, and
    parameters canonically"""
    ren, cnt = {}, [0, 0]

    def go(t):
        h = t[0]
        if h == 'M':
            if t[1] not in ren:
                if meta_sort(t[1]) == 'F':
                    ren[t[1]] = 'P%d' % cnt[0]
                    cnt[0] += 1
                else:
                    ren[t[1]] = 'f%d' % cnt[1]
                    cnt[1] += 1
            return ('M', ren[t[1]], tuple(go(a) for a in t[2]))
        if h in LEAVES:
            return t
        return rebuild(t, [go(k) for k in kids(t)])
    return canon_params(go(T))


def rigid_size(T):
    """number of rigid non-metavariable symbols"""
    h = T[0]
    if h == 'M':
        return 0
    if h in LEAVES:
        return 1
    return 1 + sum(rigid_size(k) for k in kids(T))


def n_metas(T):
    return len(metas(T))
