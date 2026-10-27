"""Context-width compilation: any circuit into an equivalent DNNF.

Context width is a parameter of an NNF N *as bracketed*: every AND gate keeps
the children it was built with. Build N with to_nnf(C, flatten=False), which
keeps the AND-tree of C; flattening merges nested ANDs and can raise the
context width from w (a window CNF as a left-deep chain in window order) to
n - 2 (the same CNF as one flat AND).

to_nnf also hash-conses structurally equal nodes, so AND gates of different
chains of C with equal children (two CNFs whose first clauses coincide)
become one node of N, whose context then collects the overlaps of both
chains; cw can exceed the bound for chains that share no gate of C. The
bounds stated below hold for chains that share no AND node of N as built.

In N, the overlap of an AND gate g is S_g = the variables shared by two of
its children; the context of a gate h is
    kappa(h) = var(h) & union of S_g over the AND gates g from which h is
               reachable (h itself included);
the context width cw is max_h |kappa(h)|. Conditioning every gate on its
context makes every AND decomposable:

  N[h, sigma]  (sigma an assignment to kappa(h)) = h restricted by sigma, built
               from its children's M-nodes with the same operation as h;
  M[h, pi]     (pi an assignment to kappa(g) & var(h) for a parent g)
               = SUM over tau (assignments to the rest of kappa(h)) of
                 PROD(literals of tau, N[h, pi + tau])    (a Shannon expansion).

The result has at most (|N| + 1)(cw + 3) 2^cw wires (|N| = wires of N). Nested
SUM (PROD) nodes are merged into their SUM (PROD) parents, which saves nodes,
but merging a shared node copies its children and can make the output
quadratic in |N|; if the merged construction exceeds that bound, it is
rebuilt without merging, which stays within it. It is returned
as an Envelope whose supp is exactly C^{-1}(1) (OR -> SUM, AND -> PROD), so the
envelope estimator applies with K = expected ambiguity, and it is exact
(K = 1) when every OR of N is deterministic.

path_order orders the clauses of a CNF along a path decomposition of its
primal graph; the left-deep AND-chain of the clauses in that order has
context width at most (width of the decomposition) + 1.
"""

from __future__ import annotations

from itertools import product

from .envelope import Envelope
from .nnf import NNF


def contexts(N: NNF, root: int):
    """(overlap S_g, context kappa(h)) as bitmask dicts over the cone of root."""
    cone = N.cone(root)
    S = {}
    for g in cone:
        if N.kind[g] == "A":
            seen, shared = 0, 0
            for c in N.data[g]:
                shared |= seen & N.sup[c]
                seen |= N.sup[c]
            S[g] = shared
        else:
            S[g] = 0
    A = {g: 0 for g in cone}
    for g in sorted(cone, reverse=True):  # parents (larger ids) before children
        A[g] |= S[g]
        for c in N.children(g):
            A[c] |= A[g]
    kappa = {g: N.sup[g] & A[g] for g in cone}
    return S, kappa


def context_width(N: NNF, root: int | None = None) -> int:
    root = N.root if root is None else root
    _, kappa = contexts(N, root)
    return max((bin(k).count("1") for k in kappa.values()), default=0)


def path_order(clauses, bags) -> list[int]:
    """Indices of `clauses` (lists of (var, val) literals) ordered by the first
    bag of the path decomposition `bags` (a sequence of variable sets) that
    contains all of the clause's variables. Raises ValueError if no bag
    contains some clause. If `bags` is a path decomposition of width k of the
    CNF's primal graph, the left-deep AND-chain of the clauses in this order has
    context width at most k + 1."""
    bags = [frozenset(int(v) for v in B) for B in bags]
    first: dict[int, int] = {}
    for idx, B in enumerate(bags):
        for v in B:
            first.setdefault(v, idx)
    key = []
    for ci, c in enumerate(clauses):
        vs = {int(v) for v, _ in c}
        if not vs:
            key.append((0, ci))
            continue
        if any(v not in first for v in vs):
            raise ValueError(f"clause {ci} has a variable in no bag")
        lo = max(first[v] for v in vs)
        if not vs <= bags[lo]:  # not a path decomposition: fall back to a scan
            lo = next((i for i, B in enumerate(bags) if vs <= B), None)
            if lo is None:
                raise ValueError(f"no bag contains clause {ci}")
        key.append((lo, ci))
    return [ci for _, ci in sorted(key)]


def _bits(mask: int) -> list[int]:
    out = []
    while mask:
        low = mask & -mask
        out.append(low.bit_length() - 1)
        mask ^= low
    return out


def _sum(E: Envelope, ch) -> int:
    """SUM node without merging SUM children (constants are simplified)."""
    out = [c for c in ch if E.kind[c] != "ZERO"]
    if not out:
        return E.zero()
    if len(out) == 1:
        return out[0]
    out = tuple(sorted(out))  # keep multiplicity
    s = 0
    for c in out:
        s |= E.sup[c]
    return E._mk("SUM", out, s)


def _prod(E: Envelope, ch) -> int:
    """PROD node without merging PROD children; children must be disjoint."""
    out = []
    for c in ch:
        k = E.kind[c]
        if k == "ZERO":
            return E.zero()
        if k != "ONE":
            out.append(c)
    if not out:
        return E.one()
    if len(out) == 1:
        return out[0]
    out = tuple(sorted(out))
    acc = 0
    for c in out:
        if acc & E.sup[c]:
            raise ValueError("PROD children must have disjoint supports")
        acc |= E.sup[c]
    return E._mk("PROD", out, acc)


def compile_ctx(N: NNF, root: int | None = None, max_cw: int = 12) -> Envelope | None:
    """Equivalent DNNF of the NNF node `root` as an Envelope, or None if the
    context width exceeds max_cw or the cone contains opaque gates.
    (Runs the recursive construction in a thread with a large stack, since
    deep AND-chains give deep recursion.)"""
    import sys
    import threading

    out = {}

    def work():
        old = sys.getrecursionlimit()
        sys.setrecursionlimit(max(old, 200_000))
        try:
            out["r"] = _compile_ctx(N, root, max_cw)
        except BaseException as e:  # pragma: no cover - re-raised below
            out["e"] = e
        finally:
            sys.setrecursionlimit(old)

    old_size = threading.stack_size()
    threading.stack_size(1 << 29)
    try:
        th = threading.Thread(target=work)
        th.start()
        th.join()
    finally:
        threading.stack_size(old_size)
    if "e" in out:
        raise out["e"]
    return out["r"]


class _OverBudget(Exception):
    pass


def _compile_ctx(N: NNF, root: int | None, max_cw: int) -> Envelope | None:
    root = N.root if root is None else root
    cone = N.cone(root)
    if any(N.kind[g] == "X" for g in cone):
        return None
    _, kappa = contexts(N, root)
    cw = max((bin(k).count("1") for k in kappa.values()), default=0)
    if cw > max_cw:
        return None
    budget = (sum(len(N.children(g)) for g in cone) + 1) * (cw + 3) * 2 ** cw
    try:
        return _build(N, root, cone, kappa, merge=True, budget=budget)
    except _OverBudget:
        return _build(N, root, cone, kappa, merge=False, budget=None)


def _build(N: NNF, root: int, cone, kappa, merge: bool, budget) -> Envelope:
    E = Envelope()
    wires = [0]

    def mk(is_prod: bool, ch) -> int:
        before = len(E.kind)
        if merge:
            r = E.PROD(ch) if is_prod else E.SUM(ch)
        else:
            r = _prod(E, ch) if is_prod else _sum(E, ch)
        if len(E.kind) > before and E.kind[r] in ("SUM", "PROD"):
            wires[0] += len(E.data[r])
            if budget is not None and wires[0] > budget:
                raise _OverBudget
        return r

    kvars = {g: _bits(kappa[g]) for g in cone}
    memoN: dict = {}
    memoM: dict = {}

    def Nn(h: int, sig: tuple) -> int:
        key = (h, sig)
        r = memoN.get(key)
        if r is not None:
            return r
        asg = dict(zip(kvars[h], sig))
        k = N.kind[h]
        if k == "T":
            r = E.one()
        elif k == "F":
            r = E.zero()
        elif k == "L":
            i, b = N.data[h]
            r = (E.one() if asg[i] == b else E.zero()) if i in asg else E.lit(i, b)
        else:
            ch = []
            for c in N.data[h]:
                pi = tuple((v, asg[v]) for v in kvars[h] if (N.sup[c] >> v) & 1)
                ch.append(Mm(c, pi))
            r = mk(k == "A", ch)
        memoN[key] = r
        return r

    def Mm(c: int, pi: tuple) -> int:
        key = (c, pi)
        r = memoM.get(key)
        if r is not None:
            return r
        d = dict(pi)
        free = [v for v in kvars[c] if v not in d]
        if not free:
            r = Nn(c, tuple(d[v] for v in kvars[c]))
        else:
            terms = []
            for tau in product((0, 1), repeat=len(free)):
                d2 = dict(d)
                d2.update(zip(free, tau))
                terms.append(mk(True, [E.lit(v, b) for v, b in zip(free, tau)]
                                + [Nn(c, tuple(d2[v] for v in kvars[c]))]))
            r = mk(False, terms)
        memoM[key] = r
        return r

    E.root = Mm(root, ())
    return E
