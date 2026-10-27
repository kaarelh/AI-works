"""Decompose-Force-Sample-Branch (DFSB): the Part-1 procedure.

Recursively explain the rarity of C by exact structure, and sample only
what is left:

  T  constants and literals: exact.
  F  literals forced by unit propagation on the Tseitin encoding of the
     subproblem: P(h) = D(F) * P(h|F).
  D  the children of h's top gate split into variable-disjoint groups:
       AND:  P(h) = prod_j P(h_j)
       OR:   P(h) = 1 - prod_j (1 - P(h_j))
  S  dense leaf: a pilot of 64K ln(2m/delta) samples has hit rate >= 1/(4K);
     estimated by Monte Carlo.
  E  envelope leaf: a syntactic envelope phi of h (rules of compile.py) has
     P(h)/E[phi] >= 1/(4K); estimated by envelope importance sampling.
  B  otherwise branch on the variable shared by the most children:
       P(h) = (1-q) P(h|x=0) + q P(h|x=1).

Two phases: phase 1 builds the tree with pilot samples (its randomness
affects only the shape of the tree, never validity); phase 2 estimates every
leaf with fresh samples to relative accuracy eps/(3d) at confidence
delta/#leaves, where d is the largest number of leaves on one derivation,
and combines leaf intervals by interval arithmetic through the exact,
monotone node operations. The output interval is valid with probability
>= 1 - delta for every circuit; it is tight when every leaf is (K-dense
leaves within the node budget), which is the class of circuits whose ideal
K-explanation tree is small.
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field

import numpy as np

from .circuit import Circuit
from .cnf import UP
from .compile import EnvelopeCompiler
from .dist import Product
from .envelope import envelope_estimate
from .nnf import NNF, to_nnf
from .stats import Estimate, kl_interval, sequential_mean


# ------------------------------------------------------------- tree nodes
@dataclass
class TNode:
    kind: str  # const lit force and or branch mc env loose
    v: int = -1  # NNF node
    val: float = 0.0
    lits: list = field(default_factory=list)
    var: int = -1
    children: list = field(default_factory=list)
    env: object = None
    lo: float = 0.0
    hi: float = 1.0
    cost: int = 0


def nnf_forced(N: NNF, v: int, n: int, probe: bool = False):
    """Input literals implied by node v being true, via unit propagation on
    the Tseitin encoding of v's cone (opaque nodes unconstrained). Returns a
    dict {var: bit}, or None if v is refuted."""
    def lit_of(u):
        k = N.kind[u]
        if k == "L":
            i, b = N.data[u]
            return (i + 1) if b else -(i + 1)
        return n + 1 + u

    cls = []
    for u in N.cone(v):
        k = N.kind[u]
        if k == "T":
            cls.append([lit_of(u)])
        elif k == "F":
            cls.append([-lit_of(u)])
        elif k == "A":
            a = lit_of(u)
            ch = [lit_of(c) for c in N.data[u]]
            cls += [[-a, c] for c in ch]
            cls.append([a] + [-c for c in ch])
        elif k == "O":
            a = lit_of(u)
            ch = [lit_of(c) for c in N.data[u]]
            cls += [[a, -c] for c in ch]
            cls.append([-a] + ch)
    cls.append([lit_of(v)])
    up = UP(cls)
    ok, val = up.propagate([])
    if not ok:
        return None
    if probe:
        for i in range(n):
            if not (N.sup[v] >> i) & 1 or (i + 1) in val:
                continue
            for b in (True, False):
                ok2, _ = up.propagate([(i + 1) if b else -(i + 1)], base=val)
                if not ok2:
                    ok3, val = up.propagate([-(i + 1) if b else (i + 1)], base=val)
                    if not ok3:
                        return None
                    break
    return {x - 1: int(b) for x, b in val.items() if 1 <= x <= n}


class DFSB:
    def __init__(self, C: Circuit, D: Product, K: float = 64.0, node_budget: int = 2000,
                 rng=None, use_envelopes: bool = True, shannon_env: int = 3, probe_root: bool = True,
                 env_tau: float | None = 0.05):
        self.C = C
        self.D = D
        self.K = K
        self.budget = node_budget
        self.rng = np.random.default_rng() if rng is None else rng
        self.use_env = use_envelopes
        self.shannon_env = shannon_env
        self.N = to_nnf(C)
        self.nodes = 0
        self.pilot_evals = 0
        self.probe_root = probe_root
        self.pilot_delta = 0.05
        self.env_tau = env_tau

    # ---------------------------------------------------------- phase 1
    def _pilot_size(self) -> int:
        return int(64 * self.K * math.ceil(math.log(2 * self.budget / self.pilot_delta)))

    def _pilot_dense(self, v: int) -> bool:
        N = self._pilot_size()
        X = self.D.sample(N, self.rng)
        self.pilot_evals += N
        return int(self.N.eval_batch(X, v).sum()) >= N / (4 * self.K)

    def _pilot_env(self, v: int):
        comp = EnvelopeCompiler(self.N, self.D, shannon=self.shannon_env, tau=self.env_tau, rng=self.rng)
        r = comp.env(v, {}, 0)
        E = comp.E
        E.root = r
        if E.kind[r] == "ONE" or E.mass(self.D) >= 1.0:
            return None
        Np = self._pilot_size()
        X = E.sample(self.D, Np, self.rng, E.log_masses(self.D)[0])
        self.pilot_evals += Np
        c = self.N.eval_batch(X, v)
        phi = E.evaluate(X)
        w = np.where(c, 1.0 / np.maximum(phi, 1e-300), 0.0)
        return E if w.sum() >= Np / (4 * self.K) else None

    def build(self, v: int, root: bool = False) -> TNode:
        N = self.N
        self.nodes += 1
        k = N.kind[v]
        if k == "T":
            return TNode("const", v, val=1.0)
        if k == "F":
            return TNode("const", v, val=0.0)
        if k == "L":
            return TNode("lit", v, val=self.D.lit_prob(*N.data[v]))
        if self.nodes > self.budget:
            return TNode("loose", v)
        # F: forced literals
        f = nnf_forced(N, v, self.C.n, probe=root and self.probe_root)
        if f is None:
            return TNode("const", v, val=0.0)
        if f:
            child = N.restrict(v, f)
            return TNode("force", v, lits=sorted(f.items()), children=[self.build(child)])
        # D: variable-disjoint groups
        if k in ("A", "O"):
            groups = _groups(N, N.data[v])
            if len(groups) > 1:
                mk = N.AND if k == "A" else N.OR
                subs = [mk([N.data[v][j] for j in g]) for g in groups]
                return TNode("and" if k == "A" else "or", v, children=[self.build(s) for s in subs])
        # S: dense
        if self._pilot_dense(v):
            return TNode("mc", v)
        # E: envelope leaf
        if self.use_env:
            E = self._pilot_env(v)
            if E is not None:
                return TNode("env", v, env=E)
        # B: branch
        x = _branch_var(N, v)
        if x is None:
            return TNode("loose", v)
        return TNode("branch", v, var=x, children=[self.build(N.restrict(v, {x: 0})),
                                                    self.build(N.restrict(v, {x: 1}))])

    # ---------------------------------------------------------- phase 2
    def estimate(self, eps: float = 0.1, delta: float = 0.05, max_leaf_samples: int = 10**6) -> Estimate:
        self.pilot_delta = delta
        # circuit-level forcing (unit propagation, probing, Gaussian elimination)
        from .cnf import forced_input_literals

        rho0 = forced_input_literals(self.C) if self.probe_root else {}
        if rho0 is None:
            return Estimate(0.0, 0.0, 0.0, 0, 0, delta, "refuted by propagation")
        if rho0:
            inner = self.build(self.N.restrict(self.N.root, rho0), root=True)
            root = TNode("force", self.N.root, lits=sorted(rho0.items()), children=[inner])
        else:
            root = self.build(self.N.root, root=True)
        leaves = _leaves(root)
        d = max(1, _depth_leaves(root))
        el = eps / (3 * d)
        dl = delta / max(1, len(leaves))
        total = 0
        for t in leaves:
            if t.kind == "mc":
                v = t.v

                def draw(k, v=v):
                    return self.N.eval_batch(self.D.sample(k, self.rng), v).astype(float)

                e = sequential_mean(draw, el, dl, max_samples=max_leaf_samples)
                t.lo, t.hi, t.cost = e.lo, e.hi, e.samples
            elif t.kind == "env":
                Cv = _NodeAsCircuit(self.N, t.v)
                e = envelope_estimate(Cv, self.D, t.env, eps=el, delta=dl,
                                      max_samples=max_leaf_samples, rng=self.rng)
                t.lo, t.hi, t.cost = e.lo, e.hi, e.evaluations
            elif t.kind == "loose":
                # valid trivial bounds; Monte Carlo upper bound with the leaf budget
                def draw(k, v=t.v):
                    return self.N.eval_batch(self.D.sample(k, self.rng), v).astype(float)

                e = sequential_mean(draw, el, dl, max_samples=min(max_leaf_samples, 10**5))
                t.lo, t.hi, t.cost = e.lo, e.hi, e.samples
            total += t.cost
        lo, hi = _combine(root, self.D)
        val = math.exp(0.5 * (math.log(lo) + math.log(hi))) if lo > 0 else hi / 2
        return Estimate(val, lo, hi, total, total + self.pilot_evals, delta,
                        f"tree nodes {self.nodes}, leaves {len(leaves)}, d={d}, "
                        f"kinds {_kind_counts(root)}")


class _NodeAsCircuit:
    """Adapter so envelope_estimate can evaluate an NNF node like a circuit."""

    def __init__(self, N, v):
        self.N, self.v = N, v

    def eval_bits(self, X):
        return self.N.eval_batch(X, self.v)


def _groups(N: NNF, ch) -> list[list[int]]:
    parent = list(range(len(ch)))

    def find(a):
        while parent[a] != a:
            parent[a] = parent[parent[a]]
            a = parent[a]
        return a

    owner: dict[int, int] = {}
    for j, c in enumerate(ch):
        s = N.sup[c]
        while s:
            low = s & -s
            i = low.bit_length() - 1
            if i in owner:
                ra, rb = find(owner[i]), find(j)
                if ra != rb:
                    parent[ra] = rb
            else:
                owner[i] = j
            s ^= low
    out: dict[int, list[int]] = {}
    for j in range(len(ch)):
        out.setdefault(find(j), []).append(j)
    return list(out.values())


def _branch_var(N: NNF, v: int):
    ch = N.children(v)
    if not ch:
        s = N.sup[v]
        return (s & -s).bit_length() - 1 if s else None
    cnt: dict[int, int] = {}
    for c in ch:
        s = N.sup[c]
        while s:
            low = s & -s
            i = low.bit_length() - 1
            cnt[i] = cnt.get(i, 0) + 1
            s ^= low
    if not cnt:
        return None
    return max(cnt, key=lambda i: (cnt[i], -i))


def _leaves(t: TNode) -> list[TNode]:
    if t.kind in ("mc", "env", "loose"):
        return [t]
    out = []
    for c in t.children:
        out += _leaves(c)
    return out


def _depth_leaves(t: TNode) -> int:
    if t.kind in ("mc", "env", "loose"):
        return 1
    if t.kind == "and":
        return sum(_depth_leaves(c) for c in t.children)
    if t.children:
        return max(_depth_leaves(c) for c in t.children)
    return 0


def _kind_counts(t: TNode, acc=None) -> dict:
    acc = {} if acc is None else acc
    acc[t.kind] = acc.get(t.kind, 0) + 1
    for c in t.children:
        _kind_counts(c, acc)
    return acc


def _dn(x: float) -> float:
    """Round a nonnegative float result down by one ulp (outward rounding)."""
    return max(0.0, math.nextafter(x, 0.0)) if x > 0 else 0.0


def _up(x: float, positive: bool) -> float:
    """Round up by one ulp; stays positive if the exact value is positive."""
    if x == math.inf:
        return x
    return max(math.nextafter(x, math.inf), math.ulp(0.0)) if positive else max(x, 0.0)


def _lit_bounds(D: Product, i: int, b: int) -> tuple[float, float]:
    v = D.lit_prob(i, b)
    return _dn(v), min(1.0, _up(v, v > 0))


def _combine(t: TNode, D: Product) -> tuple[float, float]:
    """Interval for the target of t from its children's intervals, with every
    floating-point operation rounded outwards (so underflow never turns a
    positive upper end into 0)."""
    k = t.kind
    if k == "const":
        return t.val, t.val
    if k == "lit":
        return _dn(t.val), min(1.0, _up(t.val, t.val > 0))
    if k in ("mc", "env", "loose"):
        return t.lo, t.hi
    if k == "force":
        lo, hi = _combine(t.children[0], D)
        for i, b in t.lits:
            wl, wh = _lit_bounds(D, i, b)
            lo, hi = _dn(lo * wl), _up(hi * wh, hi > 0 and wh > 0)
        return lo, min(hi, 1.0)
    if k == "and":
        lo, hi = 1.0, 1.0
        for c in t.children:
            l, h = _combine(c, D)
            lo, hi = _dn(lo * l), _up(hi * h, hi > 0 and h > 0)
        return lo, min(hi, 1.0)
    if k == "or":
        # 1 - prod(1 - x_i) for independent children, via sums of log(1 - x);
        # log1p/expm1 are accurate to a few ulps: widen by a relative 2^-45 per child
        slo, shi = 0.0, 0.0
        for c in t.children:
            l, h = _combine(c, D)
            slo += math.log1p(-min(l, 1.0)) if l < 1 else -math.inf
            shi += math.log1p(-min(h, 1.0)) if h < 1 else -math.inf
        wid = (len(t.children) + 2) * 2.0 ** -45
        lo = _dn(-math.expm1(slo) * (1 - wid))
        hi_raw = -math.expm1(shi)
        hi = min(1.0, _up(hi_raw * (1 + wid), shi < 0))
        return lo, hi
    if k == "branch":
        q1l, q1h = _lit_bounds(D, t.var, 1)
        q0l, q0h = _lit_bounds(D, t.var, 0)
        l0, h0 = _combine(t.children[0], D)
        l1, h1 = _combine(t.children[1], D)
        lo = _dn(_dn(q0l * l0) + _dn(q1l * l1))
        hi = _up(_up(q0h * h0, q0h > 0 and h0 > 0) + _up(q1h * h1, q1h > 0 and h1 > 0),
                 (q0h > 0 and h0 > 0) or (q1h > 0 and h1 > 0))
        return lo, min(hi, 1.0)
    raise ValueError(k)


def dfsb_estimate(C: Circuit, D: Product, eps: float = 0.1, delta: float = 0.05, K: float = 64.0,
                  node_budget: int = 2000, rng=None, **kw) -> Estimate:
    return DFSB(C, D, K=K, node_budget=node_budget, rng=rng, **kw).estimate(eps, delta)
