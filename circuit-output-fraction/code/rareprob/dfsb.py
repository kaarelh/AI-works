"""Decompose-Force-Sample-Branch (DFSB): the Part-1 procedure.

Recursively explain the rarity of C by exact structure, and sample only
what is left. DFSB works on the NNF of C in which every gate whose support
has at most `small_cone` variables (default: `exact_support`) has been
replaced by its reduced OBDD (small-cone canonicalisation, nnf.to_nnf),
flattened with duplicate children removed, except that an *atom* (a node
whose support has at most `exact_support` variables) is never merged into a
larger parent. Opaque nodes are leaves: unit propagation ignores them and
branching picks their smallest variable. Rules, in this order, for a node h:

  T   constants and literals: exact.
  T'  h is an atom: exact, by summing D over the 2^|var(h)| assignments of
      its support in rational arithmetic (rounded outwards to floats).
      Atoms are leaves for D, B and the cutset Conf(C).
  F   literals forced by unit propagation on the Tseitin encoding of h,
      repeated on the restricted node until nothing new is derived:
      P(h) = D(F) * P(h|F); a conflict means P(h) = 0.
  D   the children of h's top gate split into variable-disjoint groups:
        AND:  P(h) = prod_j P(h_j)
        OR:   P(h) = 1 - prod_j (1 - P(h_j))
  S   dense leaf: a pilot of N0 = 64K ceil(ln(2m/delta)) samples has at least
      N0/(4K) hits; estimated by Monte Carlo.
  E   envelope leaf: a syntactic envelope phi of h (rules of compile.py)
      passes the same pilot for E_Q[h/phi]. If phi has boxes, their pilot
      masses are first re-estimated (level delta/(4 m r), at most
      sample_cap(16K, 1/(2L), .) samples each) to ratio 1 + 1/(2L) with lower
      ends >= 1/(16K) (L = boxes per derivation, r = boxes), else the test
      fails; then the pilot proposal is within a factor e of the exact one on
      every derivation, so acceptance certifies looseness <= 16 e K. A
      box-free envelope of mass 0 makes h an exact zero.
  B   otherwise branch on the variable shared by the most children (ties:
      smallest index): P(h) = (1-q) P(h|x=0) + q P(h|x=1).

Two phases: phase 1 builds the tree with pilot samples and a node budget m
(nodes beyond it become "loose" leaves); its randomness affects only the
shape of the tree, never validity. Phase 2 estimates every leaf with fresh
samples to relative accuracy eta = eps/(3d) at confidence delta/#leaves,
where d is the largest number of sampled leaves on one derivation, and
combines leaf intervals by interval arithmetic through the exact, monotone
node operations, rounded outwards. Every leaf estimator is the doubling rule
of stats.sequential_mean, capped at the sample size `sample_cap` that
suffices (with probability 1 - delta/#leaves) for a leaf certified by phase
1: mean >= 1/(16K) for S-leaves and box-free E-leaves; for E-leaves with
boxes (envelope.envelope_estimate, which re-estimates the boxes), the larger
of the caps for importance-sampling mean >= 1/(64K) at accuracy eta/4 and
for box densities >= 1/(16K) at accuracy eta/(8L). At the cap a leaf returns its
current interval, which is still valid. Loose leaves get the same Monte
Carlo rule with the smaller cap min(that cap, loose_cap). An E-leaf whose
box rejection sampler exceeds its (polynomial) cap gets [0, 1].

So the running time is polynomial in |C|, K, m, 1/eps and log(1/delta) on
every circuit, the output interval is valid with probability >= 1 - delta
on every circuit, and it is tight with probability >= 1 - 2 delta when the
ideal K-explanation tree has at most m nodes.
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field
from fractions import Fraction

import numpy as np

from .circuit import Circuit
from .cnf import UP
from .compile import EnvelopeCompiler
from .dist import Product
from .envelope import _max_boxes_per_derivation, envelope_estimate
from .nnf import NNF, to_nnf
from .stats import Estimate, kl_interval, sequential_mean


def _popcount(s: int) -> int:
    return bin(s).count("1")


# --------------------------------------------------------- atom-aware NNF
class AtomNNF(NNF):
    """NNF that flattens nested gates of the same kind, except that an atom
    (support of at most `atom` variables) is never merged into a non-atom
    parent. Atoms are therefore single children of every larger gate, so
    (D), (B) and Conf never look inside them."""

    def __init__(self, atom: int):
        super().__init__(flatten=True)
        self.atom = atom

    def _gate(self, kind: str, ch) -> int:
        unit, absorbing = ("T", "F") if kind == "A" else ("F", "T")
        flat = []
        for c in ch:
            k = self.kind[c]
            if k == absorbing:
                return self.false() if kind == "A" else self.true()
            if k != unit:
                flat.append(c)
        s = 0
        for c in flat:
            s |= self.sup[c]
        parent_atom = _popcount(s) <= self.atom
        out = []
        for c in flat:
            if self.kind[c] == kind and (parent_atom or _popcount(self.sup[c]) > self.atom):
                out.extend(self.data[c])
            else:
                out.append(c)
        out = tuple(sorted(set(out)))
        lits = {self.data[c] for c in out if self.kind[c] == "L"}
        if any((v, 1 - b) in lits for (v, b) in lits):
            return self.false() if kind == "A" else self.true()
        if not out:
            return self.true() if kind == "A" else self.false()
        if len(out) == 1:
            return out[0]
        return self._mk(kind, out, s)

    def AND(self, ch) -> int:
        return self._gate("A", ch)

    def OR(self, ch) -> int:
        return self._gate("O", ch)


def atom_nnf(C: Circuit, atom: int, small_cone: int) -> AtomNNF:
    """The canonicalised NNF of C (to_nnf, small cones as reduced OBDDs),
    rebuilt so that atoms are never merged into larger parents."""
    N0 = to_nnf(C, small_cone=small_cone, flatten=False)
    N = AtomNNF(atom)
    N.circuit = C
    m: dict[int, int] = {}
    for u in N0.cone(N0.root):  # children have smaller ids
        k = N0.kind[u]
        if k == "T":
            m[u] = N.true()
        elif k == "F":
            m[u] = N.false()
        elif k == "L":
            m[u] = N.lit(*N0.data[u])
        elif k == "X":
            m[u] = N._mk("X", N0.data[u], N0.sup[u])
        elif k == "A":
            m[u] = N.AND([m[c] for c in N0.data[u]])
        else:
            m[u] = N.OR([m[c] for c in N0.data[u]])
    N.root = m[N0.root]
    return N


# ------------------------------------------------------------- tree nodes
@dataclass
class TNode:
    kind: str  # const lit exact force and or branch mc env loose
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


def sample_cap(K: float, eta: float, delta: float, first: int = 1024) -> int:
    """A sample size N (a stage boundary of stats.sequential_mean, started at
    `first` and doubling) such that, for i.i.d. [0,1] samples of mean at
    least 1/K, the doubling rule at level delta has reached ratio 1 + eta by
    N samples with probability at least 1 - delta.

    At stage j (N = first 2^(j-1) samples) the empirical mean is below
    mu0 (1 - t), mu0 = 1/K, t = sqrt(2 ln(1/delta) / (N mu0)), with
    probability at most delta (multiplicative Chernoff bound); we return the
    first stage at which the KL interval at level 6 delta / (pi^2 j^2) has
    ratio <= 1 + eta at every mean >= mu0 (1 - t) (the ratio decreases with
    the mean, so checking mu0 (1 - t) suffices). This is
    O(K (log(1/delta) + log log K) / eta^2)."""
    mu0 = 1.0 / K
    for j in range(1, 200):
        N = first * 2 ** (j - 1)
        t = math.sqrt(2.0 * math.log(1.0 / delta) / (N * mu0))
        if t >= 1.0:
            continue
        dj = delta * 6.0 / (math.pi ** 2 * j * j)
        lo, hi = kl_interval(mu0 * (1.0 - t), N, dj)
        if lo > 0 and hi <= (1.0 + eta) * lo:
            return N
    raise ValueError("sample_cap: parameters out of range")


class DFSB:
    def __init__(self, C: Circuit, D: Product, K: float = 64.0, node_budget: int = 2000,
                 rng=None, use_envelopes: bool = True, shannon_env: int = 3, probe_root: bool = True,
                 env_tau: float | None = 0.05, exact_support: int = 12, small_cone: int | None = None,
                 use_dense: bool = True, loose_cap: int = 10**5):
        self.C = C
        self.D = D
        self.K = K
        self.budget = node_budget
        self.rng = np.random.default_rng() if rng is None else rng
        self.use_env = use_envelopes
        self.use_dense = use_dense
        self.shannon_env = shannon_env
        self.atom = exact_support
        # small-cone canonicalisation threshold: by default the atom threshold
        self.N = atom_nnf(C, exact_support, exact_support if small_cone is None else small_cone)
        self.nodes = 0
        self.pilot_evals = 0
        self.probe_root = probe_root
        self.pilot_delta = 0.05
        self.env_tau = env_tau
        self.loose_cap = loose_cap

    # ---------------------------------------------------------- phase 1
    def _pilot_size(self) -> int:
        return int(64 * self.K * math.ceil(math.log(2 * self.budget / self.pilot_delta)))

    def _pilot_dense(self, v: int) -> bool:
        N = self._pilot_size()
        X = self.D.sample(N, self.rng)
        self.pilot_evals += N
        return int(self.N.eval_batch(X, v).sum()) >= N / (4 * self.K)

    def _exact(self, v: int) -> tuple[float, float]:
        """Rule (T'): D(h) for a node of small support, exactly (rational
        arithmetic over the truth table, with OBDD-style sharing), rounded
        outwards to floats."""
        s = self.N.sup[v]
        vs = [i for i in range(self.C.n) if (s >> i) & 1]
        k = len(vs)
        X = np.zeros((1 << k, self.C.n), dtype=bool)
        if k:
            X[:, vs] = ((np.arange(1 << k)[:, None] >> np.arange(k)) & 1).astype(bool)
        tt = np.asarray(self.N.eval_batch(X, v), dtype=bool)
        q = [Fraction(float(self.D.q[i])) for i in vs]
        memo: dict = {}

        def prob(seg, depth):
            if seg.all():
                return Fraction(1)
            if not seg.any():
                return Fraction(0)
            key = (depth, seg.tobytes())
            r = memo.get(key)
            if r is None:
                # bit `depth` of the row index is the value of vs[depth]
                r = (1 - q[depth]) * prob(seg[0::2], depth + 1) + q[depth] * prob(seg[1::2], depth + 1)
                memo[key] = r
            return r

        P = prob(tt, 0)
        f = float(P)  # correctly rounded
        if Fraction(f) == P:
            return f, f
        return _dn(f), min(1.0, _up(f, P > 0))

    def _pilot_boxes(self, E) -> bool:
        """Re-estimate the pilot masses of E's boxes so that the proposal used
        by the envelope pilot is distorted by a factor at most e on every
        derivation: each box interval (doubling rule, level delta/(4 m r),
        at most sample_cap(16K, 1/(2L), .) samples) must reach ratio
        1 + 1/(2L) and have lower end >= 1/(16K). Returns False if some box
        fails; a box is abandoned as soon as its upper end is below 1/(16K)."""
        used = E.used_boxes()
        if not used:
            return True
        L = max(1, _max_boxes_per_derivation(E))
        eta_b = 1.0 / (2 * L)
        floor = 1.0 / (16 * self.K)
        db = self.pilot_delta / (4 * self.budget * len(used))
        cap = sample_cap(16 * self.K, eta_b, db)
        for j in used:
            b = E.boxes[j]
            total, N, stage, k, lo, hi = 0.0, 0, 0, 1024, 0.0, 1.0
            ok = False
            while N < cap:
                stage += 1
                k = min(k, cap - N)
                total += float(self._draw(b.eval, k).sum())
                N += k
                l, h = kl_interval(total / N, N, db * 6.0 / (math.pi ** 2 * stage * stage))
                lo, hi = max(lo, l), min(hi, h)
                if hi < floor:
                    break
                if lo >= floor and hi <= (1 + eta_b) * lo:
                    ok = True
                    break
                k = N
            self.pilot_evals += N
            if not ok:
                return False
            b.value, b.lo, b.hi = min(max(total / N, lo), hi), lo, hi
        return True

    def _pilot_is(self, E, v: int, lm) -> bool:
        """The (E) pilot: N0 samples of W = h/phi from E's proposal; accept if
        their sum is at least N0/(4K)."""
        Np = self._pilot_size()
        try:
            X = E.sample(self.D, Np, self.rng, lm)
        except RuntimeError:  # a box's rejection sampler hit its cap
            return False
        self.pilot_evals += Np
        c = self.N.eval_batch(X, v)
        phi = E.evaluate(X)
        w = np.where(c, 1.0 / np.maximum(phi, 1e-300), 0.0)
        return w.sum() >= Np / (4 * self.K)

    def _pilot_env(self, v: int):
        """Envelope for rule (E): an Envelope if the pilot accepts it, the
        string "zero" if a box-free envelope has mass exactly 0 (then D(h) = 0),
        or None. With boxes, a first pilot with the compiler's rough box masses
        screens out hopeless envelopes cheaply (declining (E) is always
        allowed); the decisive pilot uses the re-estimated masses."""
        comp = EnvelopeCompiler(self.N, self.D, shannon=self.shannon_env, tau=self.env_tau, rng=self.rng)
        r = comp.env(v, {}, 0)
        self.pilot_evals += comp.pilot_evals
        E = comp.E
        E.root = r
        if E.kind[r] == "ONE":
            return None
        used = E.used_boxes()
        lm, _ = E.log_masses(self.D)
        if lm[r] == -math.inf:
            # phi = 0 D-almost surely and phi >= 1_h, so D(h) = 0 (box-free case)
            return "zero" if not used else None
        if used:
            if lm[r] >= 0.0 or not self._pilot_is(E, v, lm):
                return None
            if not self._pilot_boxes(E):
                return None
            lm, _ = E.log_masses(self.D)
        if lm[r] >= 0.0:  # mass >= 1: no better than Monte Carlo
            return None
        return E if self._pilot_is(E, v, lm) else None

    def build(self, v: int, root: bool = False, after_force: bool = False) -> TNode:
        N = self.N
        self.nodes += 1
        k = N.kind[v]
        # T: constants and literals
        if k == "T":
            return TNode("const", v, val=1.0)
        if k == "F":
            return TNode("const", v, val=0.0)
        if k == "L":
            return TNode("lit", v, val=self.D.lit_prob(*N.data[v]))
        # T': atoms
        if _popcount(N.sup[v]) <= self.atom:
            lo, hi = self._exact(v)
            return TNode("exact", v, lo=lo, hi=hi)
        if self.nodes > self.budget:
            return TNode("loose", v)
        # F: forced literals, to a fixpoint (one tree node)
        if not after_force:
            lits: dict[int, int] = {}
            cur = v
            while True:
                f = nnf_forced(N, cur, self.C.n, probe=root and self.probe_root)
                if f is None:  # h refuted: D(h) = 0
                    return TNode("const", v, val=0.0)
                f = {i: b for i, b in f.items() if i not in lits}
                if not f:
                    break
                lits.update(f)
                cur = N.restrict(cur, f)
                if N.kind[cur] in ("T", "F"):
                    break
            if lits:
                return TNode("force", v, lits=sorted(lits.items()),
                             children=[self.build(cur, after_force=True)])
        # D: variable-disjoint groups
        if k in ("A", "O"):
            groups = _groups(N, N.data[v])
            if len(groups) > 1:
                mk = N.AND if k == "A" else N.OR
                subs = [mk([N.data[v][j] for j in g]) for g in groups]
                return TNode("and" if k == "A" else "or", v, children=[self.build(s) for s in subs])
        # S: dense
        if self.use_dense and self._pilot_dense(v):
            return TNode("mc", v)
        # E: envelope leaf
        if self.use_env:
            E = self._pilot_env(v)
            if isinstance(E, str):
                return TNode("const", v, val=0.0)
            if E is not None:
                return TNode("env", v, env=E)
        # B: branch
        x = _branch_var(N, v)
        if x is None:
            return TNode("loose", v)
        return TNode("branch", v, var=x, children=[self.build(N.restrict(v, {x: 0})),
                                                    self.build(N.restrict(v, {x: 1}))])

    # ---------------------------------------------------------- phase 2
    def _draw(self, f, k: int, batch: int = 1 << 15) -> np.ndarray:
        """k fresh values f(x), x ~ D, drawn in bounded batches."""
        out = []
        while k > 0:
            c = min(k, batch)
            out.append(np.asarray(f(self.D.sample(c, self.rng)), dtype=bool))
            k -= c
        return np.concatenate(out).astype(float) if out else np.zeros(0)

    def _mc_leaf(self, t: TNode, eta: float, dl: float, cap: int) -> None:
        e = sequential_mean(lambda k, v=t.v: self._draw(lambda X: self.N.eval_batch(X, v), k),
                            eta, dl, max_samples=cap)
        t.lo, t.hi, t.cost = e.lo, e.hi, e.samples

    def estimate(self, eps: float = 0.1, delta: float = 0.05, max_leaf_samples: int | None = None) -> Estimate:
        """Run both phases. `max_leaf_samples`, if given, lowers every leaf's
        cap further (valid, but may cost completeness)."""
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
        K = self.K

        def capped(c):
            return c if max_leaf_samples is None else max(1, min(c, max_leaf_samples))

        total = 0
        for t in leaves:
            if t.kind == "mc":
                self._mc_leaf(t, el, dl, capped(sample_cap(16 * K, el, dl)))
            elif t.kind == "loose":
                self._mc_leaf(t, el, dl, capped(min(sample_cap(16 * K, el, dl), self.loose_cap)))
            elif t.kind == "env":
                used = t.env.used_boxes()
                if used:
                    L = max(1, _max_boxes_per_derivation(t.env))
                    cap = max(sample_cap(64 * K, el / 4, dl / 2),
                              sample_cap(16 * K, el / (8 * L), dl / (2 * len(used))))
                else:
                    cap = sample_cap(16 * K, 0.999 * el, dl)
                try:
                    e = envelope_estimate(_NodeAsCircuit(self.N, t.v), self.D, t.env, eps=el, delta=dl,
                                          max_samples=capped(cap), rng=self.rng)
                    t.lo, t.hi, t.cost = e.lo, e.hi, e.evaluations
                except RuntimeError:  # box rejection sampler hit its cap
                    t.lo, t.hi, t.cost = 0.0, 1.0, 0
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
    """The variable shared by the most children of v (ties: smallest index)."""
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
    if k in ("mc", "env", "loose", "exact"):
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
                  node_budget: int = 2000, rng=None, max_leaf_samples: int | None = None, **kw) -> Estimate:
    return DFSB(C, D, K=K, node_budget=node_budget, rng=rng, **kw).estimate(eps, delta, max_leaf_samples)
