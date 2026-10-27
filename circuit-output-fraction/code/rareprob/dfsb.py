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
      P(h) = D(F) * P(h|F); a conflict means P(h) = 0. At the root also
      failed-literal probing, alternating with Gaussian elimination on the
      affine equations implied by C = 1 (affine_rows: XOR/NOT conjuncts,
      atoms read through their truth tables). All of it acts on the NNF and
      on the functions of atoms, so rewriting an atom-sized gate into an
      equivalent circuit on the same support (R8) changes neither the NNF
      nor the tree.
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
combines leaf intervals (clipped to [0, 1]) by interval arithmetic through the
exact, monotone node operations, rounded outwards, both in the linear domain
and in the log domain (so that p below the float range keeps tight log
bounds, which the note reports). Every leaf estimator is the doubling rule
of stats.sequential_mean, capped at the sample size `sample_cap` that
suffices (with probability 1 - delta/#leaves) for a leaf certified by phase
1: mean >= 1/(16K) for S-leaves and box-free E-leaves; for E-leaves with
boxes (envelope.envelope_estimate, which re-estimates the boxes), the larger
of the caps for importance-sampling mean >= 1/(64K) at accuracy eta/4 and
for box densities >= 1/(16K) at accuracy eta/(8L). At the cap a leaf returns its
current interval, which is still valid. Loose leaves get the same Monte
Carlo rule with the smaller cap min(that cap, loose_cap). Every box fill of
the rejection sampler of an E-leaf is truncated after
T = ceil(16 K ln(8 F / delta)) draws, F = sum over E-leaves with boxes of
(boxes per derivation) * (cap), the number of fills phase 2 can make; a
truncated leaf gets [0, 1]. Boxes of a certified E-leaf have mass >= 1/(16K),
so on the good event of phase 1 no fill is truncated except with probability
delta/8. (Phase-1 pilots truncate fills likewise; that only fails (E) tests.)

Implementation choices within the paper's parameters: the atom size is the
fixed exact_support = 12 (not floor(c log2 |C|)), and (R7) judges density
by a pilot of 512 samples with threshold env_tau = 0.05 (compile.py).

So the running time is polynomial in |C|, K, m, 1/eps and log(1/delta) on
every circuit, the output interval is valid with probability >= 1 - delta
on every circuit, and it is tight with probability >= 1 - 2 delta when the
ideal K-explanation tree has at most m nodes (for p below the normal float
range, the tight bounds are the log bounds in the note).
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field
from fractions import Fraction

import numpy as np

from .circuit import Circuit
from .cnf import UP, gauss_forced
from .compile import EnvelopeCompiler
from .dist import Product
from .envelope import _exp_down, _exp_up, _max_boxes_per_derivation, envelope_estimate
from .nnf import NNF, to_nnf
from .stats import Estimate, kl_interval, sequential_mean, sum_rel_err


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
    llo: float | None = None  # log bounds of an exact leaf (valid below the float range)
    lhi: float | None = None


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


def _gf2_complement(vecs: list[int], k: int) -> list[int]:
    """A basis of {m in GF(2)^k : parity(m & v) = 0 for every v in vecs}."""
    piv: dict[int, int] = {}  # pivot bit -> reduced row
    for v in vecs:
        for b, r in piv.items():
            if (v >> b) & 1:
                v ^= r
        if v:
            b = v.bit_length() - 1
            for b2 in list(piv):
                if (piv[b2] >> b) & 1:
                    piv[b2] ^= v
            piv[b] = v
    # reduced row echelon form: a free coordinate j yields the solution e_j +
    # sum of the pivots b whose row has bit j
    out = []
    for j in range(k):
        if j in piv:
            continue
        m = 1 << j
        for b, r in piv.items():
            if (r >> j) & 1:
                m |= 1 << b
        out.append(m)
    return out


def affine_rows(C: Circuit, a: int) -> list[tuple[int, int]] | None:
    """Affine equations over GF(2) implied by C(x) = 1, as (mask, c) meaning
    XOR_{i in mask} x_i = c, or None if they are inconsistent.

    Gates whose support has at most `a` variables (the atoms of (R8)) are
    black boxes read through their truth tables, so the result depends only
    on their functions: rewriting such a gate into an equivalent circuit with
    the same support leaves it unchanged. Top-level conjuncts are found by
    descending through AND gates with more than `a` variables. An atom
    conjunct contributes every affine equation that holds on all of its
    satisfying assignments (the affine hull); a larger conjunct contributes
    one equation if it is an XOR/NOT of inputs, constants and atoms whose
    truth tables are affine functions."""
    sup = C.supports()
    tables: dict[int, tuple[list[int], np.ndarray]] = {}

    def table(g: int):
        """(support of g, truth table of g over it): g's cone is copied into
        a circuit on its k <= a support variables (cost O(cone), not O(|C|))
        and evaluated by the circuit evaluator on all 2^k assignments."""
        r = tables.get(g)
        if r is None:
            vs = [i for i in range(C.n) if (sup[g] >> i) & 1]
            k = len(vs)
            cone, stack = set(), [g]
            while stack:
                u = stack.pop()
                if u not in cone:
                    cone.add(u)
                    stack.extend(C.args[u])
            sub = Circuit(k)
            m = {v: j for j, v in enumerate(vs)}
            for u in sorted(cone):
                if C.ops[u] != "IN":
                    m[u] = sub.add(C.ops[u], [m[x] for x in C.args[u]], C.params[u])
            sub.set_output(m[g])
            X = ((np.arange(1 << k)[:, None] >> np.arange(k)) & 1).astype(bool)
            tt = np.asarray(sub.eval_bits(X), dtype=bool)
            r = tables[g] = (vs, tt)
        return r

    def popc(x: int) -> int:
        return bin(x).count("1")

    def is_clause(g: int) -> bool:
        """g is an OR of literals on at least two distinct variables."""
        if C.ops[g] != "OR":
            return False
        vs = set()
        for u in C.args[g]:
            if C.ops[u] == "NOT":
                u = C.args[u][0]
            if C.ops[u] != "IN":
                return False
            vs.add(u)
        return len(vs) >= 2 and len(vs) == len(C.args[g])

    affm: dict[int, tuple[int, int] | None] = {}

    def aff(g: int):
        """(mask, c) with gate g = XOR_{mask} x ^ c as a function, or None."""
        if g in affm:
            return affm[g]
        op = C.ops[g]
        r = None
        if op != "IN" and popc(sup[g]) <= a:
            vs, tt = table(g)
            k = len(vs)
            c = int(tt[0])
            coef = [int(tt[1 << j]) ^ c for j in range(k)]
            rows = np.arange(1 << k)
            par = np.zeros(1 << k, dtype=np.int64)
            for j in range(k):
                if coef[j]:
                    par ^= (rows >> j) & 1
            if np.array_equal(tt.astype(np.int64), par ^ c):
                r = (sum(1 << vs[j] for j in range(k) if coef[j]), c)
        elif op == "IN":
            r = (1 << g, 0)
        elif op == "NOT":
            s = aff(C.args[g][0])
            r = None if s is None else (s[0], s[1] ^ 1)
        elif op == "XOR":
            m, c = 0, 0
            for u in C.args[g]:
                s = aff(u)
                if s is None:
                    m = None
                    break
                m ^= s[0]
                c ^= s[1]
            r = None if m is None else (m, c)
        affm[g] = r
        return r

    out: list[tuple[int, int]] = []
    stack, seen = [C.output], set()
    while stack:
        g = stack.pop()
        if g in seen:
            continue
        seen.add(g)
        op = C.ops[g]
        if op != "IN" and popc(sup[g]) <= a:  # an atom conjunct: its affine hull
            if is_clause(g):  # 2^k - 1 points, k >= 2: their hull is everything
                continue
            vs, tt = table(g)
            sat = np.nonzero(tt)[0]
            if sat.size == 0:
                return None
            x0 = int(sat[0])
            span = [int(x) ^ x0 for x in sat[1:]]
            for m in _gf2_complement(span, len(vs)):
                mask = sum(1 << vs[j] for j in range(len(vs)) if (m >> j) & 1)
                out.append((mask, popc(m & x0) & 1))
            continue
        if op == "AND":
            stack.extend(C.args[g])
            continue
        s = aff(g)
        if s is not None:
            out.append((s[0], 1 ^ s[1]))  # XOR(mask) ^ c = 1
    return out


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
        # with the relative error sequential_mean allows for its float sums
        lo, hi = kl_interval(mu0 * (1.0 - t), N, dj, rel_err=sum_rel_err(N))
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
        # small-cone canonicalisation threshold (R8): by default the atom threshold
        self.small_cone = exact_support if small_cone is None else small_cone
        self.N = atom_nnf(C, exact_support, self.small_cone)
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

    def _exact_fraction(self, v: int) -> Fraction:
        """Rule (T'): D(h) for a node of small support, exactly (rational
        arithmetic over the truth table, with OBDD-style sharing)."""
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

        return prob(tt, 0)

    def _exact(self, v: int) -> tuple[float, float]:
        """Rule (T'): float bounds on D(h), rounded outwards."""
        return _frac_bounds(self._exact_fraction(v))

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

    def _fill_cap(self, fills: float, delta: float) -> int:
        """Draws after which one box fill is truncated: with box masses
        >= 1/(16K), all of `fills` fills succeed within it except with
        probability delta/8."""
        return int(math.ceil(16 * self.K * math.log(8 * max(fills, 1.0) / delta)))

    def _pilot_is(self, E, v: int, lm) -> bool:
        """The (E) pilot: N0 samples of W = h/phi from E's proposal; accept if
        their sum is at least N0/(4K)."""
        Np = self._pilot_size()
        L = max(1, _max_boxes_per_derivation(E))
        cap = self._fill_cap(3 * self.budget * Np * L, self.pilot_delta)
        try:
            X = E.sample(self.D, Np, self.rng, lm, fill_cap=cap)
        except RuntimeError:  # a box fill was truncated: the test fails
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
            P = self._exact_fraction(v)
            lo, hi = _frac_bounds(P)
            llo, lhi = _frac_log_bounds(P)
            return TNode("exact", v, lo=lo, hi=hi, llo=llo, lhi=lhi)
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

    def _root_force(self):
        """Rule (F) at the root: unit propagation and failed-literal probing
        on the Tseitin encoding of the canonicalised NNF, alternating with
        Gaussian elimination on the affine equations of affine_rows (atoms
        read by their truth tables), to a fixpoint. Returns (literals, the
        restricted root), or None if C(x) = 1 is refuted. Everything here
        depends on C only through the NNF and the functions of its atoms, so
        a rewrite of an atom-sized gate (R8) does not change the tree."""
        N, n = self.N, self.C.n
        rows = affine_rows(self.C, self.small_cone)
        if rows is None:
            return None
        lits: dict[int, int] = {}
        cur = N.root
        while N.kind[cur] not in ("T", "F"):
            f = nnf_forced(N, cur, n, probe=True)
            if f is None:
                return None
            new = {i: b for i, b in f.items() if i not in lits}
            lits.update(new)
            g = gauss_forced(rows, lits) if rows else {}
            if g is None:
                return None
            g = {i: b for i, b in g.items() if i not in lits}
            lits.update(g)
            new.update(g)
            if not new:
                break
            cur = N.restrict(cur, new)
        if N.kind[cur] == "F":
            return None
        return lits, cur

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
        if self.probe_root:
            rf = self._root_force()
            if rf is None:
                return Estimate(0.0, 0.0, 0.0, 0, 0, delta, "refuted by propagation")
            lits, cur = rf
            self.nodes += 1 if lits else 0  # the force node, counted as build counts it
            inner = self.build(cur, after_force=True)
            root = TNode("force", self.N.root, lits=sorted(lits.items()), children=[inner]) if lits else inner
        else:
            root = self.build(self.N.root, root=True)
        leaves = _leaves(root)
        d = max(1, _depth_leaves(root))
        el = eps / (3 * d)
        dl = delta / max(1, len(leaves))
        K = self.K

        def capped(c):
            return c if max_leaf_samples is None else max(1, min(c, max_leaf_samples))

        caps: dict[int, int] = {}
        fills = 0.0  # box fills phase 2 can make: (boxes per derivation) * cap per E-leaf
        for t in leaves:
            if t.kind == "env":
                used = t.env.used_boxes()
                if used:
                    L = max(1, _max_boxes_per_derivation(t.env))
                    caps[id(t)] = capped(max(sample_cap(64 * K, el / 4, dl / 2),
                                             sample_cap(16 * K, el / (8 * L), dl / (2 * len(used)))))
                    fills += L * caps[id(t)]
                else:
                    caps[id(t)] = capped(sample_cap(16 * K, 0.999 * el, dl))
        fill_cap = self._fill_cap(fills, delta)
        total = 0
        for t in leaves:
            if t.kind == "mc":
                self._mc_leaf(t, el, dl, capped(sample_cap(16 * K, el, dl)))
            elif t.kind == "loose":
                self._mc_leaf(t, el, dl, capped(min(sample_cap(16 * K, el, dl), self.loose_cap)))
            elif t.kind == "env":
                try:
                    e = envelope_estimate(_NodeAsCircuit(self.N, t.v), self.D, t.env, eps=el, delta=dl,
                                          max_samples=caps[id(t)], rng=self.rng, fill_cap=fill_cap)
                    t.lo, t.hi, t.cost = e.lo, e.hi, e.evaluations
                except RuntimeError:  # a box fill was truncated: no verdict for this leaf
                    t.lo, t.hi, t.cost = 0.0, 1.0, 0
            total += t.cost
        lo, hi, L, H = _combine(root, self.D)
        lo = min(lo, hi)
        if L > -math.inf:
            val = min(max(math.exp(0.5 * (L + H)), lo), hi)
        else:
            val = hi / 2
        note = (f"tree nodes {self.nodes}, leaves {len(leaves)}, d={d}, "
                f"kinds {_kind_counts(root)}")
        if L > -math.inf and lo < _NORMAL2:  # below the normal float range: report log bounds
            ln10 = math.log(10)  # the quotients below are rounded outwards
            note += f"; log10 p in [{L / ln10 * (1 + 2.0 ** -48)!r}, {H / ln10 * (1 - 2.0 ** -48)!r}]"
        return Estimate(val, lo, hi, total, total + self.pilot_evals, delta, note)


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


_NORMAL2 = 2.0 ** -1021  # twice the smallest positive normal double
_LOG_REL = 2.0 ** -50  # relative error allowance of a computed log quantity
_LOG_ABS = 2.0 ** -60


def _ldn(y: float, scale: float | None = None) -> float:
    """A computed log value y rounded down: y minus 2^-50 (scale, default
    |y|) minus 2^-60; scale bounds the magnitudes that entered y's rounding."""
    if y == -math.inf:
        return y
    return y - _LOG_REL * (abs(y) if scale is None else scale) - _LOG_ABS


def _lup(y: float, scale: float | None = None) -> float:
    """A computed log value y rounded up, capped at 0 (log of a probability)."""
    if y == -math.inf:
        return y
    return min(0.0, y + _LOG_REL * (abs(y) if scale is None else scale) + _LOG_ABS)


def _fin(x: float) -> float:
    return abs(x) if x > -math.inf else 0.0


def _log_lo(x: float) -> float:
    """A lower bound on log x for a float x >= 0."""
    return _ldn(math.log(x)) if x > 0 else -math.inf


def _log_hi(x: float) -> float:
    """An upper bound on log min(x, 1) for a float x >= 0."""
    return _lup(math.log(min(x, 1.0))) if x > 0 else -math.inf


def _frac_bounds(P: Fraction) -> tuple[float, float]:
    f = float(P)  # correctly rounded
    if Fraction(f) == P:
        return f, f
    return _dn(f), min(1.0, _up(f, P > 0))


def _frac_log_bounds(P: Fraction) -> tuple[float, float]:
    """Bounds on log P for a rational P in [0, 1]; math.log of a big int is
    accurate to a few ulps of its result."""
    if P <= 0:
        return -math.inf, -math.inf
    a, b = math.log(P.numerator), math.log(P.denominator)
    y = a - b
    s = abs(a) + abs(b) + abs(y)
    return _ldn(y, s), _lup(y, s)


def _lit_log_bounds(D: Product, i: int, b: int) -> tuple[float, float]:
    q = float(D.q[i])
    if b:
        y = math.log(q) if q > 0 else -math.inf
    else:
        y = math.log1p(-q) if q < 1 else -math.inf
    return _ldn(y), _lup(y)


def _logsumexp(vals: list[float]) -> tuple[float, float]:
    """(log sum_i e^{v_i} as computed, the magnitude scale of its rounding)."""
    M = max(vals)
    if M == -math.inf:
        return -math.inf, 0.0
    y = M + math.log(math.fsum(math.exp(v - M) for v in vals))
    return y, abs(y) + abs(M) + len(vals) + 2


def _combine(t: TNode, D: Product) -> tuple[float, float, float, float]:
    """(lo, hi, L, H) with D(target of t) in [lo, hi] and its log in [L, H],
    from the children's intervals, every floating-point operation rounded
    outwards. The float bounds are computed in the linear domain (tight when
    p is in the normal float range) and the log bounds in the log domain
    (tight below it); each is tightened by the other at every node."""
    lo, hi, L, H = _combine_raw(t, D)
    hi = min(hi, 1.0)
    L = max(L, _log_lo(lo))
    H = min(H, _log_hi(hi))
    lo = max(lo, _exp_down(L))
    hi = min(hi, _exp_up(H))
    return lo, hi, L, H


def _combine_raw(t: TNode, D: Product) -> tuple[float, float, float, float]:
    k = t.kind
    if k == "const":
        return t.val, t.val, (0.0 if t.val else -math.inf), (0.0 if t.val else -math.inf)
    if k == "lit":
        lo, hi = _dn(t.val), min(1.0, _up(t.val, t.val > 0))
        return lo, hi, _log_lo(lo), _log_hi(hi)
    if k in ("mc", "env", "loose", "exact"):
        hi = min(t.hi, 1.0)
        lo = min(max(t.lo, 0.0), hi)
        L, H = _log_lo(lo), _log_hi(hi)
        if t.llo is not None:
            L, H = max(L, t.llo), min(H, t.lhi)
        return lo, hi, L, H
    if k == "force":
        lo, hi, L, H = _combine(t.children[0], D)
        Ls, Hs = [L], [H]
        for i, b in t.lits:
            wl, wh = _lit_bounds(D, i, b)
            lo, hi = _dn(lo * wl), _up(hi * wh, hi > 0 and wh > 0)
            ll, lh = _lit_log_bounds(D, i, b)
            Ls.append(ll)
            Hs.append(lh)
        return lo, min(hi, 1.0), _ldn(math.fsum(Ls)), _lup(math.fsum(Hs))
    if k == "and":
        lo, hi = 1.0, 1.0
        Ls, Hs = [], []
        for c in t.children:
            l, h, ll, lh = _combine(c, D)
            lo, hi = _dn(lo * l), _up(hi * h, hi > 0 and h > 0)
            Ls.append(ll)
            Hs.append(lh)
        return lo, min(hi, 1.0), _ldn(math.fsum(Ls)), _lup(math.fsum(Hs))
    if k == "or":
        # linear domain: 1 - prod(1 - x_i) for independent children, via sums
        # of log(1 - x); log1p/expm1 are accurate to a few ulps: widen by a
        # relative 2^-45 per child
        slo, shi = 0.0, 0.0
        Ls, Hs = [], []
        for c in t.children:
            l, h, ll, lh = _combine(c, D)
            slo += math.log1p(-min(l, 1.0)) if l < 1 else -math.inf
            shi += math.log1p(-min(h, 1.0)) if h < 1 else -math.inf
            Ls.append(ll)
            Hs.append(lh)
        wid = (len(t.children) + 2) * 2.0 ** -45
        lo = _dn(-math.expm1(slo) * (1 - wid))
        hi_raw = -math.expm1(shi)
        hi = min(1.0, _up(hi_raw * (1 + wid), shi < 0))
        # log domain: the union bound above; below, 1 - prod(1 - x_i) >=
        # 1 - e^{-S} with S = sum_i x_i, and 1 - e^{-S} >= S (1 - S/2)
        y, s = _logsumexp(Hs)
        H = _lup(y, s)
        ls, s = _logsumexp(Ls)
        ls = _ldn(ls, s)
        if ls == -math.inf:
            L = -math.inf
        elif ls <= -1.0:
            yy = _exp_up(ls) / 2
            z = ls + math.log1p(-yy)
            L = _ldn(z, abs(z) + abs(ls) + 4)
        else:
            z = math.log(-math.expm1(-_exp_down(ls)))
            L = _ldn(z, abs(z) + 4)
        return lo, hi, max(L, _log_lo(lo)), min(H, _log_hi(hi))
    if k == "branch":
        q1l, q1h = _lit_bounds(D, t.var, 1)
        q0l, q0h = _lit_bounds(D, t.var, 0)
        l0, h0, L0, H0 = _combine(t.children[0], D)
        l1, h1, L1, H1 = _combine(t.children[1], D)
        lo = _dn(_dn(q0l * l0) + _dn(q1l * l1))
        hi = _up(_up(q0h * h0, q0h > 0 and h0 > 0) + _up(q1h * h1, q1h > 0 and h1 > 0),
                 (q0h > 0 and h0 > 0) or (q1h > 0 and h1 > 0))
        a0l, a0h = _lit_log_bounds(D, t.var, 0)
        a1l, a1h = _lit_log_bounds(D, t.var, 1)
        # log domain: log(e^{a0 + L0} + e^{a1 + L1}); the scale covers the
        # rounding of the two sums as well
        ylo, s = _logsumexp([a0l + L0, a1l + L1])
        L = _ldn(ylo, s + _fin(a0l) + _fin(L0) + _fin(a1l) + _fin(L1))
        yhi, s = _logsumexp([a0h + H0, a1h + H1])
        H = _lup(yhi, s + _fin(a0h) + _fin(H0) + _fin(a1h) + _fin(H1))
        return lo, min(hi, 1.0), L, H
    raise ValueError(k)


def dfsb_estimate(C: Circuit, D: Product, eps: float = 0.1, delta: float = 0.05, K: float = 64.0,
                  node_budget: int = 2000, rng=None, max_leaf_samples: int | None = None, **kw) -> Estimate:
    return DFSB(C, D, K=K, node_budget=node_budget, rng=rng, **kw).estimate(eps, delta, max_leaf_samples)
