"""Context-width compilation: any circuit into an equivalent DNNF.

In the NNF of C, the overlap of an AND gate g is S_g = the variables shared by
two of its children; the context of a gate h is
    kappa(h) = var(h) & union of S_g over the AND gates g from which h is reachable;
the context width cw is max_h |kappa(h)|. Conditioning every gate on its
context makes every AND decomposable:

  N[h, sigma]  (sigma an assignment to kappa(h)) = h restricted by sigma, built
               from its children's M-nodes with the same operation as h;
  M[h, pi]     (pi an assignment to kappa(g) & var(h) for a parent g)
               = SUM over tau (assignments to the rest of kappa(h)) of
                 PROD(literals of tau, N[h, pi + tau])    (a Shannon expansion).

The result has O(|C| cw 2^cw) nodes and is returned as an Envelope whose
supp is exactly C^{-1}(1) (OR -> SUM, AND -> PROD), so the envelope estimator
applies with K = expected ambiguity, and it is exact (K = 1) when every OR is
deterministic.
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


def _bits(mask: int) -> list[int]:
    out = []
    while mask:
        low = mask & -mask
        out.append(low.bit_length() - 1)
        mask ^= low
    return out


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


def _compile_ctx(N: NNF, root: int | None, max_cw: int) -> Envelope | None:
    root = N.root if root is None else root
    cone = N.cone(root)
    if any(N.kind[g] == "X" for g in cone):
        return None
    _, kappa = contexts(N, root)
    if max((bin(k).count("1") for k in kappa.values()), default=0) > max_cw:
        return None
    E = Envelope()
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
            r = E.PROD(ch) if k == "A" else E.SUM(ch)
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
                terms.append(E.PROD([E.lit(v, b) for v, b in zip(free, tau)]
                                    + [Nn(c, tuple(d2[v] for v in kvars[c]))]))
            r = E.SUM(terms)
        memoM[key] = r
        return r

    E.root = Mm(root, ())
    return E
