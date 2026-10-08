"""Candidate pools.

The posterior is computed by exact enumeration over a finite pool of theories.  The pool is a fixed list
built from the data and from hand-specified alternatives; the memorisation theory Mem(D_n) (the set of
distinct data seen so far) is added at each n.  Restricting the posterior to a pool is the same as
conditioning the full posterior on the event "the theory is in the pool".
"""
import itertools
import random

from dtrc.syntax import parse, canon_params, pp, kids, LEAVES, plug, positions, replace_at, ZERO, S
from dtrc.templates import instantiate, metas, is_DT0, canon, geq, match
from dtrc.mincover import aligned_min
from .theory import Component, Theory


# ------------------------------------------------------------------------------------ template helpers
def partial_instantiate(T, theta):
    """instantiate only the metavariables in theta (others stay)"""
    h = T[0]
    if h == 'M':
        args = tuple(partial_instantiate(a, theta) for a in T[2])
        if T[1] in theta:
            return plug(theta[T[1]], args)
        return ('M', T[1], args)
    if h in LEAVES:
        return T
    return (h,) + tuple(partial_instantiate(k, theta) for k in T[1:])


def forall_of(T, var='t'):
    """forall x T[x/?var] for a 0-ary term metavariable ?var not under binders"""
    def go(u, j):
        h = u[0]
        if h == 'M' and u[1] == var:
            return ('v', j)
        if h in LEAVES or h == 'M':
            return u
        if h in ('all', 'ex'):
            return (h, go(u[1], j + 1))
        return (h,) + tuple(go(k, j) for k in u[1:])
    return ('all', go(T, 0))


def rename_metas(T, ren):
    h = T[0]
    if h == 'M':
        return ('M', ren.get(T[1], T[1]), tuple(rename_metas(a, ren) for a in T[2]))
    if h in LEAVES:
        return T
    return (h,) + tuple(rename_metas(k, ren) for k in T[1:])


def term_patterns(depth, prefix='z'):
    """term patterns whose instance sets partition the closed terms (over 0, S, +, *): depth 0 is a single
    metavariable; depth d+1 expands every metavariable of a depth-d pattern by {0, S?, ?+?, ?*?}"""
    cnt = itertools.count()

    def fresh():
        return ('M', '%s%d' % (prefix, next(cnt)), ())

    pats = [fresh()]
    for _ in range(depth):
        new = []
        for p in pats:
            ms = [m for m in metas(p)]
            options = []
            for m in ms:
                options.append([ZERO, ('S', fresh()), ('+', fresh(), fresh()), ('*', fresh(), fresh())])
            for combo in itertools.product(*options):
                new.append(partial_instantiate(p, dict(zip(ms, combo))))
        pats = new
    return pats


def specialise(T, var, pattern):
    """T with the 0-ary term metavariable ?var replaced by a term pattern (fresh metavariable names)"""
    ms = metas(pattern)
    ren = {m: '%s_%s' % (var, m) for m in ms}
    return canon_params(partial_instantiate(T, {var: rename_metas(pattern, ren)}))


def generalisations(T, rounds=2):
    """templates strictly more general than T, obtained by up to `rounds` steps of: renaming one occurrence
    of a repeated 0-ary term metavariable apart; replacing a closed rigid term node by a fresh 0-ary term
    metavariable; replacing an atom by a fresh 0-ary formula metavariable"""
    out = {}
    frontier = [T]
    for r in range(rounds):
        nxt = []
        for U in frontier:
            for V in _gen_steps(U):
                try:
                    if not is_DT0(V):
                        continue
                except Exception:
                    continue
                c = canon(V)
                if c in out or c == canon(T):
                    continue
                if not geq(V, T) or geq(T, V):
                    continue
                out[c] = V
                nxt.append(V)
        frontier = nxt
    return list(out.values())


def _gen_steps(U):
    cnt = [0]
    used = set(metas(U))

    def fresh(sort):
        while True:
            name = ('g%d' if sort == 'T' else 'G%d') % cnt[0]
            cnt[0] += 1
            if name not in used:
                used.add(name)
                return name
    res = []
    occ = {}
    for p, u in positions(U):
        if u[0] == 'M' and not u[2] and u[1][0].islower():
            occ.setdefault(u[1], []).append(p)
    for m, ps in occ.items():
        if len(ps) > 1:
            for p in ps:
                res.append(replace_at(U, p, ('M', fresh('T'), ())))
    for p, u in positions(U):
        if u[0] in ('0', 'S', '+', '*') and not _has(u, 'v') and not _has(u, 'M'):
            res.append(replace_at(U, p, ('M', fresh('T'), ())))
        if u[0] in ('=', '<') and not _has(u, 'v'):
            res.append(replace_at(U, p, ('M', fresh('F'), ())))
    return res


def _has(t, head):
    if t[0] == head:
        return True
    if t[0] in LEAVES:
        return False
    return any(_has(k, head) for k in kids(t))


# ------------------------------------------------------------------------------------ data-derived
def min_theories(data, rng, sizes=(2, 3), per_size=6, max_templates=3):
    """single-template theories from Min of random subsets of the data (and of all the data)"""
    out = {}
    subsets = [list(data)]
    data = list(dict.fromkeys(data))
    for k in sizes:
        for _ in range(per_size):
            if len(data) >= k:
                subsets.append(rng.sample(data, k))
    for D in subsets:
        try:
            mins, mc = aligned_min(D)
        except Exception:
            continue
        for T in mins[:max_templates]:
            c = canon(T)
            if c not in out:
                out[c] = T
    return list(out.values())


def skeleton_theories(data, ks=(2, 3, 4)):
    """theories made of the Min templates of skeleton clusters (DTRC without refutation, stopped at k)"""
    from dtrc.dtrc import DTRC
    out = []
    data = list(dict.fromkeys(data))
    for k in ks:
        if len(data) <= k:
            continue
        try:
            m = DTRC(None, use_refutation=False, k_stop=k).fit(data)
        except Exception:
            continue
        temps = []
        for c in m.clusters:
            if c.acc:
                temps.append(c.acc[0])
            else:
                temps.extend(c.data)
        out.append((k, temps))
    return out


def mem_theory(data, name='Mem'):
    return Theory([Component(d) for d in dict.fromkeys(data)], name, {'cls': 'mem'})


# ------------------------------------------------------------------------------------ causal pools
def dedupe_theories(pool):
    seen, out = set(), []
    for th in pool:
        if th.key in seen:
            continue
        seen.add(th.key)
        out.append(th)
    return out


class CausalPool:
    """A pool that uses only data already seen: pool(n) = the fixed theories, plus the data-derived theories
    built from D_b for every build point b <= n (built once, on first use, and kept for all later n).
    builder(D_b, b) returns a list of theories; keep(theory) filters them (e.g. exact-L1 support);
    rejected names are collected in self.excluded."""

    def __init__(self, fixed, builder, build_points, data, keep=None):
        self.fixed = list(fixed)
        self.builder = builder
        self.bp = sorted(set(build_points))
        self.data = data
        self.keep = keep
        self.built = {}
        self.excluded = []

    def _build(self, b):
        if b not in self.built:
            ths = self.builder(self.data[:b], b)
            if self.keep is not None:
                self.excluded.extend(th.name for th in ths if not self.keep(th))
                ths = [th for th in ths if self.keep(th)]
            self.built[b] = ths
        return self.built[b]

    def __call__(self, n):
        out = list(self.fixed)
        for b in self.bp:
            if b > n:
                break
            out.extend(self._build(b))
        return dedupe_theories(out)

    def all_theories(self, nmax):
        return self(nmax)
