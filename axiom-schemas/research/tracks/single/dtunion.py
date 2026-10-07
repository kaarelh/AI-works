# Track "single" (revision): complexity of the cautious verifier over UNIONS H_k(DT°).
#   * brute-force union verifier (Prop F.6: all partitions into <= k blocks, Thm C per block)
#   * Lemma H.1: "q not in Acc(B)" iff B fits one of polynomially many q-relative failure TYPES
#       Sym-type   (p, h):     every d in B agrees with q on the strict ancestors of p and has root h != root(q|p)
#       Scope-type (sigma, y): every d in B agrees with q above sigma and y is not free in d|sigma (y free in q|sigma)
#       Eq-type    (sigma, r): every d in B agrees with q above sigma and r, the matcher e_d (d|r = (d|sigma)[e_d])
#                              exists, the e_d are pairwise compatible, and e_q does not exist or is
#                              incompatible with some e_d (d in B)
#   * Thm H.2: polynomial verifier for k = 2 (pairs of types + witnesses + 2-SAT)
#   * Thm H.3 / H.4: the graph-colouring and set-cover reductions
from dtcore import *
from dtfeat import Prefix


# ------------------------------------------------------------------ brute force (Prop F.6)
def partitions(items, k):
    """set partitions of items into at most k nonempty blocks"""
    if not items:
        yield []
        return
    first, rest = items[0], items[1:]
    for p in partitions(rest, k):
        for i in range(len(p)):
            yield p[:i] + [[first] + p[i]] + p[i + 1:]
        if len(p) < k:
            yield [[first]] + p


class BlockAcc:
    """cached single-template cautious verifier Acc(B) (Thm C) on index blocks of D"""
    def __init__(self, D):
        self.D = list(D)
        self.cache = {}

    def prefix(self, block):
        key = tuple(sorted(block))
        if key not in self.cache:
            self.cache[key] = Prefix([self.D[i] for i in key])
        return self.cache[key]

    def accepts(self, block, q):
        if not block:
            return False          # Acc(empty) = empty
        return self.prefix(block).accepts(q)


def acc_union_bf(D, q, k, BA=None):
    """q in the intersection of all k-unions of DT° templates covering D (Prop F.6)"""
    BA = BA or BlockAcc(D)
    idx = list(range(len(D)))
    return all(any(BA.accepts(B, q) for B in P) for P in partitions(idx, k))


# ------------------------------------------------------------------ Lemma H.1: failure types
def agree(d, q, p):
    """d agrees with q on the root symbols of all strict ancestors of p (then p is a position of d)"""
    t, u = d, q
    for i in p:
        if node_key(t) != node_key(u):
            return False
        t, u = kids(t)[i], kids(u)[i]
    return True


def ematch(t, u):
    """partial map e with u = t[e] on the free indices of t, or None"""
    um = {}
    if Prefix.align(t, u, um):
        return um
    return None


def compatible(e1, e2):
    return all(e2[y] == v for y, v in e1.items() if y in e2)


def failure_types(D, q):
    """list of types (kind, data, allowed:set, incompat:set of pairs, witnesses:set or None)"""
    pos = [(p, node, srt) for (p, node, _, srt) in positions(q)]
    types = []
    for (p, node, srt) in pos:
        ag = [i for i, d in enumerate(D) if agree(d, q, p)]
        hs = {}
        for i in ag:
            k = node_key(sub(D[i], p))
            if k != node_key(node):
                hs.setdefault(k, set()).add(i)
        for k, S_ in hs.items():
            types.append(('sym', (p, k), S_, set(), None))
        for y in sorted(fv(node)):
            S_ = {i for i in ag if y not in fv(sub(D[i], p))}
            types.append(('scope', (p, y), S_, set(), None))
    for (s, ns, ss) in pos:
        for (r, nr, sr) in pos:
            if r == s or comparable(r, s) or ss != sr:
                continue
            G, E = set(), {}
            for i, d in enumerate(D):
                if agree(d, q, s) and agree(d, q, r):
                    e = ematch(sub(d, s), sub(d, r))
                    if e is not None:
                        G.add(i)
                        E[i] = e
            if not G:
                continue
            inc = {(i, j) for i in G for j in G if i < j and not compatible(E[i], E[j])}
            eq_ = ematch(ns, nr)
            if eq_ is None:
                W = None
            else:
                W = {i for i in G if not compatible(E[i], eq_)}
                if not W:
                    continue
            types.append(('eq', (s, r), G, inc, W))
    return types


def block_fits(B, ty):
    kind, dat, allowed, inc, W = ty
    if not B or not set(B) <= allowed:
        return False
    if any((i, j) in inc for i in B for j in B if i < j):
        return False
    if W is not None and not (set(B) & W):
        return False
    return True


def fails_by_types(B, types):
    return any(block_fits(B, ty) for ty in types)


# ------------------------------------------------------------------ 2-SAT
def two_sat(n, clauses):
    """clauses: list of (lit, lit), lit = (var, value); returns True iff satisfiable"""
    N = 2 * n
    def node(l):
        v, val = l
        return 2 * v + (1 if val else 0)
    g = [[] for _ in range(N)]
    for a, b in clauses:
        na, nb = node(a), node(b)
        g[na ^ 1].append(nb)
        g[nb ^ 1].append(na)
    # Tarjan SCC (iterative)
    index = [0]; idx = [-1] * N; low = [0] * N; onst = [False] * N; st = []; comp = [-1] * N; c = [0]
    for s0 in range(N):
        if idx[s0] != -1:
            continue
        work = [(s0, 0)]
        while work:
            v, pi = work.pop()
            if pi == 0:
                idx[v] = low[v] = index[0]; index[0] += 1; st.append(v); onst[v] = True
            recurse = False
            for j in range(pi, len(g[v])):
                w = g[v][j]
                if idx[w] == -1:
                    work.append((v, j + 1)); work.append((w, 0)); recurse = True
                    break
                elif onst[w]:
                    low[v] = min(low[v], idx[w])
            if recurse:
                continue
            if low[v] == idx[v]:
                while True:
                    w = st.pop(); onst[w] = False; comp[w] = c[0]
                    if w == v:
                        break
                c[0] += 1
            if work:
                u = work[-1][0]
                low[u] = min(low[u], low[v])
    return all(comp[2 * v] != comp[2 * v + 1] for v in range(n))


def acc2_poly(D, q, types=None):
    """Thm H.2: the cautious verifier over H_2(DT°) in polynomial time"""
    D = list(D)
    n = len(D)
    if not Prefix(D).accepts(q):
        return False
    types = failure_types(D, q) if types is None else types
    for a in range(len(types)):
        for b in range(a, len(types)):
            t1, t2 = types[a], types[b]
            for w1 in (sorted(t1[4]) if t1[4] is not None else [None]):
                for w2 in (sorted(t2[4]) if t2[4] is not None else [None]):
                    cl = []
                    for i in range(n):
                        if i not in t1[2]:
                            cl.append(((i, False), (i, False)))
                        if i not in t2[2]:
                            cl.append(((i, True), (i, True)))
                    for (i, j) in t1[3]:
                        cl.append(((i, False), (j, False)))
                    for (i, j) in t2[3]:
                        cl.append(((i, True), (j, True)))
                    if w1 is not None:
                        cl.append(((w1, True), (w1, True)))
                    if w2 is not None:
                        cl.append(((w2, False), (w2, False)))
                    if two_sat(n, cl):
                        return False
    return True


# ------------------------------------------------------------------ reductions
def colouring_instance(n, edges):
    """Thm H.3.  Vertices 1..n, edges [(u,v)] oriented u -> v (u tail: 0, v head: S0).
    d_u = A^m ( S^u(tup_u) = 0  &  S^u(tup_u[c_u]) = 0 ),  q = A^m ( S^n 0 = 0 & S^(n+1) 0 = 0 )."""
    m = len(edges)
    def nest(k, t):
        for _ in range(k):
            t = S(t)
        return t
    def tup(items):
        t = Z
        for it in reversed(items):
            t = add(it, t)
        return t
    def wrap(f):
        for _ in range(m):
            f = ALL(f)
        return f
    D = []
    for u in range(1, n + 1):
        left = [V(m - 1 - i) if u in e else Z for i, e in enumerate(edges)]
        right = [(Z if u == e[0] else S(Z)) if u in e else Z for i, e in enumerate(edges)]
        D.append(wrap(AND(eq(nest(u, tup(left)), Z), eq(nest(u, tup(right)), Z))))
    q = wrap(AND(eq(nest(n, Z), Z), eq(nest(n + 1, Z), Z)))
    return D, q


def setcover_instance(n, sets):
    """Thm H.4.  Universe 1..n, family sets[j] (subsets).  Binder-free:
    d_u = /\\_j (c_uj = 0), c_uj = 0 if u in sets[j] else S0;  q = /\\_j (S0 = 0)."""
    def conj(fs):
        f = fs[-1]
        for g in reversed(fs[:-1]):
            f = AND(g, f)
        return f
    D = [conj([eq(Z if u in F else S(Z), Z) for F in sets]) for u in range(1, n + 1)]
    q = conj([eq(S(Z), Z) for _ in sets])
    return D, q
