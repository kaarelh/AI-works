# Track "single": the feature characterization of the cautious DT° verifier (Theorem C), the
# saturated templates Sat(D) (Theorem B), the lgg-existence criterion (Proposition G2) and the
# escalation potential (Theorem F).  Positions are tuples of child indices.
import itertools
from dtcore import *


class Prefix:
    """common prefix C(D) of a nonempty list of sentences, its slots and admissible positions"""
    def __init__(self, D):
        D = list(D)
        self.D = D
        self.C = {}        # pos -> (node_key, binder depth, sort)
        self.slots = {}    # pos -> (binder depth, sort)
        stack = [((), D, 0, 'F')]
        while stack:
            p, cols, bd, srt = stack.pop()
            k0 = node_key(cols[0])
            if all(node_key(c) == k0 for c in cols):
                self.C[p] = (k0, bd, srt)
                h = cols[0][0]
                dd = bd + 1 if h in BINDERS else bd
                cs = child_sort(h)
                n = len(kids(cols[0]))
                for i in range(n):
                    stack.append((p + (i,), [kids(c)[i] for c in cols], dd, cs))
            else:
                self.slots[p] = (bd, srt)
        self.A = dict((p, (v[1], v[2])) for p, v in self.C.items())
        self.A.update(self.slots)
        # Y_sigma: free (relative) indices occurring in some datum at sigma
        self.Y = {}
        for s in self.slots:
            y = set()
            for d in D:
                y |= fv(sub(d, s))
            self.Y[s] = tuple(sorted(y))
        self._eq = None

    # -------------------------------------------------------------- equation features
    @staticmethod
    def align(a, b, umap, j=0, extend=True):
        """does b = a[u/Y] for the free indices of a (relative), consistent with umap?"""
        if a[0] == 'v' and a[1] >= j:
            y = a[1] - j
            u = lower(b, j)
            if u is None:
                return False
            if y in umap:
                return umap[y] == u
            if not extend:
                return False
            umap[y] = u
            return True
        if node_key(a) != node_key(b):
            return False
        jj = j + 1 if a[0] in BINDERS else j
        return all(Prefix.align(x, z, umap, jj, extend) for x, z in zip(kids(a), kids(b)))

    def eq_features(self):
        """list of (sigma, r, umap): sigma a slot, r admissible, incomparable, same sort,
        d|r = (d|sigma)[u/Y_sigma] for every datum d (u forced, Lemma C.1)"""
        if self._eq is not None:
            return self._eq
        out = []
        for s, (bs, ss) in self.slots.items():
            for r, (br, sr) in self.A.items():
                if r == s or comparable(r, s) or sr != ss:
                    continue
                umap = {}
                if all(self.align(sub(d, s), sub(d, r), umap) for d in self.D):
                    out.append((s, r, tuple(sorted(umap.items()))))
        self._eq = out
        return out

    # -------------------------------------------------------------- membership in Feat(D) = Acc(D)
    def accepts(self, q):
        # Sym features
        for p, (k, bd, srt) in self.C.items():
            try:
                t = sub(q, p)
            except (IndexError, TypeError):
                return False
            if node_key(t) != k:
                return False
        # Scope features
        for s in self.slots:
            if not fv(sub(q, s)) <= set(self.Y[s]):
                return False
        # Equation features
        for (s, r, um) in self.eq_features():
            if not self.align(sub(q, s), sub(q, r), dict(um), extend=False):
                return False
        return True

    def which_fail(self, q):
        """list of features violated by q (for diagnostics)"""
        bad = []
        for p, (k, bd, srt) in self.C.items():
            try:
                t = sub(q, p)
                ok = node_key(t) == k
            except (IndexError, TypeError):
                ok = False
            if not ok:
                bad.append(('sym', p))
        if bad:
            return bad
        for s in self.slots:
            if not fv(sub(q, s)) <= set(self.Y[s]):
                bad.append(('scope', s))
        for (s, r, um) in self.eq_features():
            if not self.align(sub(q, s), sub(q, r), dict(um), extend=False):
                bad.append(('eq', s, r))
        return bad

    # -------------------------------------------------------------- templates realizing features
    def mname(self, s, idx):
        return ('P%d' if self.slots[s][1] == 'F' else 'f%d') % idx

    def build(self, fillers):
        """template: skeleton C(D), with fillers[pos] at the given positions"""
        d0 = self.D[0]
        def rec(p, t):
            if p in fillers:
                return fillers[p]
            if p not in self.C:
                raise ValueError('uncovered slot %r' % (p,))
            if t[0] in ('v',) or not kids(t):
                return t
            return rebuild(t, [rec(p + (i,), k) for i, k in enumerate(kids(t))])
        return rec((), d0)

    def pattern_filler(self, s, name):
        return ('M', name) + tuple(('v', y) for y in self.Y[s])

    def derived_filler(self, s, um, name):
        um = dict(um)
        return ('M', name) + tuple(um[y] for y in self.Y[s])

    def T0(self):
        """C(D) with a fresh pattern metavariable at every slot"""
        sl = sorted(self.slots)
        names = {s: self.mname(s, i) for i, s in enumerate(sl)}
        return self.build({s: self.pattern_filler(s, names[s]) for s in sl})

    def T_feature(self, feat):
        s0, r0, um = feat
        sl = sorted(self.slots)
        names = {s: self.mname(s, i) for i, s in enumerate(sl)}
        fil = {}
        for s in sl:
            if comparable(s, r0) and len(s) > len(r0):
                continue          # below r0: cut away
            fil[s] = self.pattern_filler(s, names[s])
        fil[r0] = self.derived_filler(s0, um, names[s0])
        return self.build(fil)

    def feature_templates(self):
        return [self.T0()] + [self.T_feature(f) for f in self.eq_features()]

    # -------------------------------------------------------------- saturated templates (Thm B)
    def cut_sets(self):
        """all antichains Q of admissible positions such that the skeleton C minus everything at or
        below Q is a prefix and every slot is at or below an element of Q"""
        def rec(p):
            if p in self.slots:
                return [[p]]
            res = [[p]] if p != () or True else []
            ch = []
            n = len(kids(sub(self.D[0], p)))
            for i in range(n):
                ch.append(rec(p + (i,)))
            combos = [[]]
            for opts in ch:
                combos = [a + b for a in combos for b in opts]
            return [[p]] + combos
        return rec(())

    def saturated(self, limit=None):
        """all saturated covering templates (Theorem B), canonical, deduplicated by text"""
        feats = {}
        for (s, r, um) in self.eq_features():
            feats.setdefault(r, []).append((s, um))
        out = {}
        for Q in self.cut_sets():
            Qs = [q for q in Q if q in self.slots]
            Qc = [q for q in Q if q not in self.slots]
            # every element of Q picks a source: itself (if a slot) or a slot of Q explaining it
            choices = []
            for q in Q:
                opts = []
                if q in self.slots:
                    opts.append((q, None))
                for (s, um) in feats.get(q, []):
                    if s in Qs:
                        opts.append((s, um))
                if not opts:
                    choices = None
                    break
                choices.append(opts)
            if choices is None:
                continue
            for pick in itertools.product(*choices):
                src = {q: pk[0] for q, pk in zip(Q, pick)}
                # sources must be self-sourced
                if any(src[s] != s for s in set(src.values())):
                    continue
                names = {s: self.mname(s, i) for i, s in enumerate(sorted(set(src.values())))}
                fil = {}
                for q, (s, um) in zip(Q, pick):
                    if um is None:
                        fil[q] = self.pattern_filler(s, names[s])
                    else:
                        fil[q] = self.derived_filler(s, um, names[s])
                T = canon(self.build(fil))
                out[T] = True
                if limit and len(out) > limit:
                    return list(out)
        return list(out)

    def minimal(self, limit=None):
        sat = self.saturated(limit)
        # remove equivalents, keep minimal
        reps = []
        for T in sat:
            if any(equivalent(T, R) for R in reps):
                continue
            reps.append(T)
        mins = [T for T in reps if not any((not equivalent(T, U)) and subsumes(T, U) for U in reps)]
        return mins, reps

    # -------------------------------------------------------------- lgg existence (Prop. G2)
    def lgg_exists(self):
        feats = self.eq_features()
        for (s, r, um) in feats:
            if r in self.C:
                return False, ('feature lands in the common prefix', s, r)
        arrow = {(s, r) for (s, r, um) in feats}
        sl = list(self.slots)
        # weakly connected components
        par = {s: s for s in sl}
        def find(a):
            while par[a] != a:
                par[a] = par[par[a]]
                a = par[a]
            return a
        for (s, r) in arrow:
            par[find(s)] = find(r)
        comps = {}
        for s in sl:
            comps.setdefault(find(s), []).append(s)
        for c in comps.values():
            if not any(all(x == s or (s, x) in arrow for x in c) for s in c):
                return False, ('component without source', c)
        return True, None

    def lgg(self):
        ok, why = self.lgg_exists()
        if not ok:
            return None
        feats = self.eq_features()
        arrow = {}
        for (s, r, um) in feats:
            arrow[(s, r)] = um
        par = {s: s for s in self.slots}
        def find(a):
            while par[a] != a:
                a = par[a]
            return a
        for (s, r) in arrow:
            par[find(s)] = find(r)
        comps = {}
        for s in self.slots:
            comps.setdefault(find(s), []).append(s)
        fil = {}
        for i, c in enumerate(sorted(comps.values())):
            src = next(s for s in sorted(c) if all(x == s or (s, x) in arrow for x in c))
            nm = self.mname(src, i)
            for x in c:
                fil[x] = self.pattern_filler(src, nm) if x == src else self.derived_filler(src, arrow[(src, x)], nm)
        return canon(self.build(fil))

    # -------------------------------------------------------------- potential (Thm F)
    def potential(self):
        return (len(self.C),
                sum(self.slots[s][0] - len(self.Y[s]) for s in self.slots),
                len(self.eq_features()))


def acc(D, q):
    return Prefix(D).accepts(q)
