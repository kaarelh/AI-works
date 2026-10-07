"""Minimal covering DT° templates of a finite set of sentences.

Normal-form argument (see notes, Prop. E1): every covering DT° template T is at least as general as a
*normal configuration* on the common-prefix tree C(D):
  * pattern occurrences sit at slots (disagreement positions) and are applied to exactly the bound
    variables occurring free in the slot's column (push pattern occurrences down while the data agree);
  * every other occurrence M_rho(t) sits at a slot or an interior node pi of C(D); its arguments are
    forced by the data (substitution into a body with a free hole is injective);
  * no own slot is derivable from another own slot (else specialise M_sigma := M_rho(t)).
The normal configurations are finitely many; Min(D) = their minimal elements (up to equivalence).
This module enumerates them (with caps) and filters minimal ones by subsumption tests.
"""
import itertools
from .syntax import BINDERS, LEAVES, kids, rebuild, unshift, child_sort, free_indices, sort_of
from .templates import abstract, canon, geq, covers_all, rigid_size


class Node:
    __slots__ = ('path', 'sort', 'depth', 'cols', 'slot', 'head', 'children', 'parent', 'idx', 'proto')

    def __init__(self, path, sort, depth, cols, parent):
        self.path, self.sort, self.depth, self.cols, self.parent = path, sort, depth, cols, parent
        self.slot, self.head, self.children, self.idx, self.proto = False, None, [], -1, None


def _key(c):
    h = c[0]
    if h in LEAVES:
        return c
    if h in ('M', 'C'):
        return (h, c[1], len(c[2]))
    return (h, len(c) - 1)


def build_tree(D, term_arity0=True):
    """common-prefix tree of D.  With term_arity0 (class DT°_F: term metavariables are 0-ary), an atom
    whose subtree contains a term disagreement with a free bound variable becomes a (formula) slot."""
    root, nodes = _build_tree(D)
    if term_arity0:
        root, nodes = _f_slots(root, nodes)
    return root, nodes


def _f_slots(root, nodes):
    from .syntax import ATOM_HEADS

    def has_open_slot(nd):
        if nd.slot:
            return any(free_indices(c) for c in nd.cols)
        return any(has_open_slot(c) for c in nd.children)
    changed = False
    for nd in nodes:
        if not nd.slot and nd.proto is not None and nd.proto[0] in ATOM_HEADS and has_open_slot(nd):
            nd.slot, nd.children, nd.proto = True, [], None
            changed = True
    if not changed:
        return root, nodes
    out = []

    def walk(nd):
        nd.idx = len(out)
        out.append(nd)
        for c in nd.children:
            walk(c)
    walk(root)
    return root, out


def _build_tree(D):
    nodes = []

    def go(cols, sort, depth, path, parent):
        nd = Node(path, sort, depth, cols, parent)
        nd.idx = len(nodes)
        nodes.append(nd)
        k0 = _key(cols[0])
        if all(_key(c) == k0 for c in cols):
            nd.proto = cols[0]
            h = cols[0][0]
            if h not in LEAVES:
                ks = [kids(c) for c in cols]
                cs = child_sort(h) if h not in ('M', 'C') else 'T'
                nd_depth = depth + 1 if h in BINDERS else depth
                for i in range(len(ks[0])):
                    nd.children.append(go(tuple(k[i] for k in ks), cs, nd_depth, path + (i,), nd))
        else:
            nd.slot = True
        return nd
    root = go(tuple(D), 'F', 0, (), None)
    return root, nodes


def _body_match(body, c, r, binding):
    """first-order match of a metavariable body (holes = unknown argument terms) against content c; the
    hole arguments live in the occurrence context, r = body binders passed."""
    h = body[0]
    if h == 'h':
        u = unshift(c, r)
        if u is None:
            return False
        m = body[1]
        old = binding.get(m)
        if old is None:
            binding[m] = u
            return True
        return old == u
    if h != c[0]:
        return False
    if h in LEAVES:
        return body == c
    if h in ('M', 'C') and (body[1] != c[1] or len(body[2]) != len(c[2])):
        return False
    kb, kc = kids(body), kids(c)
    if len(kb) != len(kc):
        return False
    nr = r + 1 if h in BINDERS else r
    return all(_body_match(a, b, nr, binding) for a, b in zip(kb, kc))


class MinCover:
    """computes the normal configurations and minimal covering DT° templates of D"""

    def __init__(self, D, max_sprime=4096, max_configs=4000, term_arity0=True):
        self.D = list(dict.fromkeys(D))
        self.term_arity0 = term_arity0
        self.root, self.nodes = build_tree(self.D, term_arity0)
        self.slots = [n for n in self.nodes if n.slot]
        self.max_sprime, self.max_configs = max_sprime, max_configs
        self.truncated = False
        # own pattern data per slot
        self.own_args, self.bodies = {}, {}
        for s in self.slots:
            fv = set()
            for c in s.cols:
                fv |= free_indices(c)
            args = tuple(('v', j) for j in sorted(fv))
            self.own_args[s.idx] = args
            self.bodies[s.idx] = [abstract(c, args, s.depth) for c in s.cols]
        # derivations rho -> pi
        self.src = {n.idx: [] for n in self.nodes}
        anc = {}
        for n in self.nodes:
            a, p = set(), n.parent
            while p is not None:
                a.add(p.idx)
                p = p.parent
            anc[n.idx] = a
        for rho in self.slots:
            bl = self.bodies[rho.idx]
            nar = len(self.own_args[rho.idx])
            for pi in self.nodes:
                if pi is rho or pi.sort != rho.sort or pi.idx in anc[rho.idx] or rho.idx in anc[pi.idx]:
                    continue
                binding = {}
                ok = True
                for b, c in zip(bl, pi.cols):
                    if not _body_match(b, c, 0, binding):
                        ok = False
                        break
                if ok and len(binding) == nar:
                    t = tuple(binding[m] for m in range(nar))
                    self.src[pi.idx].append((rho.idx, t))
        self.anc = anc
        self._slotset = {s.idx for s in self.slots}

    # -------------------------------------------------------------- enumeration
    def _sprime_candidates(self):
        """independent own-sets S' (no member derivable from another member), by backtracking"""
        slot_ids = [s.idx for s in self.slots]
        dfrom = {s: {r for (r, _) in self.src[s] if r in self._slotset} for s in slot_ids}
        forced = set()
        for s in slot_ids:
            if not self.src[s] and not any(self.src[a] for a in self.anc[s]):
                forced.add(s)
        for s in forced:
            if dfrom[s] & forced:
                return []          # cannot happen for data from a DT° target? keep safe
        free = [s for s in slot_ids if s not in forced]
        out = []
        if len(free) > 22:
            # fallback: one representative per mutual-derivability class (greedy), flagged as truncated
            self.truncated = True
            Sp = set(forced)
            for s in free:
                if not (dfrom[s] & Sp) and not any(s in dfrom[t] for t in Sp):
                    Sp.add(s)
            return [frozenset(Sp)]
        cur = set(forced)

        def rec(i):
            if len(out) >= self.max_sprime:
                self.truncated = True
                return
            if i == len(free):
                out.append(frozenset(cur))
                return
            s = free[i]
            # include s
            if not (dfrom[s] & cur) and not any(s in dfrom[t] for t in cur):
                cur.add(s)
                rec(i + 1)
                cur.discard(s)
            rec(i + 1)
        rec(0)
        return out

    def _options(self, nd, Sp, contains):
        """list of fragment choices for subtree nd under own-set Sp; each choice is a template fragment"""
        if nd.idx in Sp:
            return [('M', ('P' if nd.sort == 'F' else 'f') + 'own%d' % nd.idx, self.own_args[nd.idx])]
        opts = []
        if not contains[nd.idx]:
            for (r, t) in self.src[nd.idx]:
                if r in Sp:
                    opts.append(('M', ('P' if nd.sort == 'F' else 'f') + 'own%d' % r, t))
        if nd.slot:
            return opts
        # rigid continuation
        if not nd.children:
            opts.append(nd.proto)
            return opts
        child_opts = []
        for ch in nd.children:
            co = self._options(ch, Sp, contains)
            if not co:
                return opts
            child_opts.append(co)
        n = 1
        for co in child_opts:
            n *= len(co)
        if n > self.max_configs:
            self.truncated = True
            # keep a bounded subset: first options of each child, cycling
            prods = itertools.islice(itertools.product(*child_opts), self.max_configs)
        else:
            prods = itertools.product(*child_opts)
        for combo in prods:
            opts.append(rebuild(nd.proto, combo))
            if len(opts) > self.max_configs:
                self.truncated = True
                break
        return opts

    def configurations(self):
        out = []
        for Sp in self._sprime_candidates():
            contains = {}
            for n in reversed(self.nodes):     # children after parents in self.nodes -> reverse = bottom-up
                contains[n.idx] = (n.idx in Sp) or any(contains[c.idx] for c in n.children)
            opts = self._options(self.root, Sp, contains)
            for T in opts:
                out.append(T)
                if len(out) > self.max_configs * 4:
                    self.truncated = True
                    return out
        return out

    def minimal(self):
        seen, cands = set(), []
        for T in self.configurations():
            c = canon(T)
            if c not in seen:
                seen.add(c)
                cands.append(c)
        # more specific first (heuristic order for the filter)
        cands.sort(key=lambda T: -rigid_size(T))
        mins = []
        for T in cands:
            if any(geq(T, M) for M in mins):     # T is above (or equivalent to) a kept one
                continue
            mins = [M for M in mins if not geq(M, T)]
            mins.append(T)
        return mins


def min_covering(D, **kw):
    mc = MinCover(D, **kw)
    return mc.minimal(), mc


def common_prefix_size(D):
    root, nodes = _build_tree(list(dict.fromkeys(D)))
    return sum(1 for n in nodes if not n.slot)


def check_covering(Ts, D):
    return all(covers_all(T, D) for T in Ts)
