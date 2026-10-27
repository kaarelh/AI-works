"""Affine (F_2-linear) structure.

* Certified affine gates: algebraic normal forms (ANF) are propagated gate by
  gate (AND = product, OR = a + b + ab, NOT = 1 + a, XOR = sum, with x^2 = x),
  keeping the linear part as a bitmask and aborting a gate when its nonlinear
  part exceeds a cap. A non-aborted ANF is exact (the ANF of a Boolean function
  is unique and the rules are identities), so a gate whose ANF has degree <= 1
  computes that affine form on every input. Certification is deductive; no
  claim is ever based on testing.
* The exact affine / triangular presolve: C = [Ax = b] AND [solved-form
  conjuncts] AND R gives p = M * E_D[W] with W in [0, 1] and an exact factor M
  (M = 2^-r when all pivots are uniform coordinates).
* Affine-union envelopes by abstract interpretation (lists E+(g), E-(g) of
  affine subspaces with g^-1(1) in the union of E+(g), g^-1(0) in that of
  E-(g)), sampled with the Karp-Luby-Madras estimator, i.e. the envelope
  estimator with phi = sum_j 1_{V_j}.
* XOR-propagation-tree (XPT) arguments: a prover-supplied case-split tree whose
  closed leaves are refuted by gate propagation plus Gaussian elimination and
  whose open leaves are affine subspaces.
* Exact mass and exact sampling of D restricted to {Ax = b} under any product
  distribution, by dynamic programming over live partial syndromes along a
  linear order of the coordinates (2^{lambda_i} states at position i).

Every interval returned here contains p with probability >= 1 - delta for
every circuit, every product distribution and (for XPT) every argument; a
method that cannot certify anything returns [0, 1] or its deterministic upper
bound.

Floating point. Circuits are evaluated by Circuit.eval_packed, so a threshold
gate means [fl-sum of w_i g_i, left to right, >= t - 1e-12]; the propagator
reasons about exactly that function (rounded addition is monotone). Masses are
carried as (mantissa, binary exponent, relative-error bound) with proven
bounds (no logarithms), intervals are rounded outward, and a value that would
underflow is replaced by a valid bound (the smallest positive double for an
upper end), never by 0.
"""

from __future__ import annotations

import math
import sys
from dataclasses import dataclass, field
from fractions import Fraction

import numpy as np

from .circuit import Circuit, unpack_bits
from .dist import Product
from .stats import Estimate, sequential_mean

ONES = np.uint64(0xFFFFFFFFFFFFFFFF)


# ============================================================ rounding helpers
U53 = 2.0 ** -53            # unit roundoff of IEEE double (round to nearest)
TINY = sys.float_info.min   # smallest positive normal double


def _gamma(k: int) -> float:
    """gamma_k = k u / (1 - k u): (1 + d_1)...(1 + d_k) with |d_i| <= u lies in
    [1 - gamma_k, 1 + gamma_k] (Higham, Lemma 3.1); inflated slightly so that
    the bound survives its own rounding."""
    ku = k * U53
    if ku >= 0.25:
        return math.inf
    return 1.01 * ku / (1.0 - ku)


def _down(x: float) -> float:
    """A float <= every real whose correctly rounded value is x (x >= 0)."""
    return max(0.0, math.nextafter(x, -math.inf))


def _up(x: float) -> float:
    """A float >= every real whose correctly rounded value is x."""
    return math.nextafter(x, math.inf)


def _ldexp(x: float, e: int) -> float:
    try:
        return math.ldexp(x, e)
    except OverflowError:
        return math.inf


def _ldexp_down(x: float, e: int) -> float:
    """A float <= x * 2^e (x >= 0); exact unless the result is subnormal."""
    y = _ldexp(x, e)
    return y if y >= TINY or x == 0.0 else _down(y)


def _ldexp_up(x: float, e: int) -> float:
    """A float >= x * 2^e (x >= 0); positive whenever x > 0."""
    y = _ldexp(x, e)
    return y if y >= TINY or x == 0.0 else _up(y)


def _scaled_interval(a_lo: float, a_hi: float, mant: float, exp: int, rel: float) -> tuple[float, float]:
    """Outward-rounded [a_lo * M, a_hi * M] for an unknown M > 0 with
    mant * 2^exp = M (1 + theta), |theta| <= rel <= 1/4."""
    if rel > 0.25:
        return 0.0, 1.0
    f_lo = 1.0 if rel == 0 else _down(1.0 - rel)        # <= 1 / (1 + rel)
    f_hi = 1.0 if rel == 0 else _up(1.0 + 2.0 * rel)    # >= 1 / (1 - rel)
    lo = _ldexp_down(_down(_down(a_lo * mant) * f_lo), exp) if a_lo > 0 else 0.0
    hi = _ldexp_up(_up(_up(a_hi * mant) * f_hi), exp) if a_hi > 0 else 0.0
    return lo, min(hi, 1.0)


def _log2_note(a_lo: float, a_hi: float, mant: float, exp: int) -> str:
    """log2 of the interval ends before conversion to floats (for the note)."""
    f = lambda a: (math.log2(a * mant) + exp) if a > 0 else -math.inf  # noqa: E731
    return f"log2 bounds [{f(a_lo):.4f}, {f(a_hi):.4f}]"


# ====================================================================== GF(2)
def parity(x: int) -> int:
    return bin(x).count("1") & 1


def bit_list(mask: int) -> list[int]:
    out = []
    while mask:
        low = mask & -mask
        out.append(low.bit_length() - 1)
        mask ^= low
    return out


def gf2_rank(vectors) -> int:
    basis: dict[int, int] = {}
    for v in vectors:
        v = int(v)
        while v:
            t = v.bit_length() - 1
            if t in basis:
                v ^= basis[t]
            else:
                basis[t] = v
                break
    return len(basis)


class Affine:
    """The affine subspace {x : row . x = rhs for every row}, rows in echelon
    form: rows[p] = (row, rhs) with p the highest set bit of row, all p
    distinct. The empty constraint set is the whole cube."""

    __slots__ = ("rows",)

    def __init__(self, rows=None):
        self.rows: dict[int, tuple[int, int]] = dict(rows) if rows else {}

    @classmethod
    def single(cls, mask: int, rhs: int) -> "Affine":
        A = cls()
        A.add(mask, rhs)
        return A

    def copy(self) -> "Affine":
        return Affine(self.rows)

    def reduce(self, row: int, rhs: int = 0) -> tuple[int, int]:
        """Cancel leading bits that are pivots. Returns (residual, rhs'): the
        residual is 0 iff row is in the row space, and then the form row . x
        equals rhs' on V (for rhs = 0)."""
        rows = self.rows
        while row:
            t = row.bit_length() - 1
            r = rows.get(t)
            if r is None:
                break
            row ^= r[0]
            rhs ^= r[1]
        return row, rhs

    def add(self, row: int, rhs: int) -> bool:
        """Intersect with {row . x = rhs}; returns False if the result is empty.
        rhs must be 0 or 1 and row a nonnegative integer (anything else would
        silently corrupt the system, so it raises)."""
        if rhs not in (0, 1) or row < 0:
            raise ValueError(f"Affine.add: bad constraint ({row!r}, {rhs!r})")
        row, rhs = self.reduce(int(row), int(rhs))
        if row == 0:
            return rhs == 0
        self.rows[row.bit_length() - 1] = (row, rhs)
        return True

    def meet(self, other: "Affine") -> "Affine | None":
        if len(other.rows) > len(self.rows):
            self, other = other, self
        S = self.copy()
        for row, rhs in other.rows.values():
            if not S.add(row, rhs):
                return None
        return S

    def form_value(self, mask: int, c: int = 0):
        """The constant value of mask . x + c on V, or None if not constant."""
        r, acc = self.reduce(mask, c)
        return acc if r == 0 else None

    def subset_of(self, other: "Affine") -> bool:
        """self is contained in other (self nonempty)."""
        for row, rhs in other.rows.values():
            r, acc = self.reduce(row, 0)
            if r != 0 or acc != rhs:
                return False
        return True

    @property
    def rank(self) -> int:
        return len(self.rows)

    def support(self) -> int:
        s = 0
        for row, _ in self.rows.values():
            s |= row
        return s

    def key(self):
        """Canonical (reduced row echelon) form, for deduplication."""
        red: dict[int, tuple[int, int]] = {}
        piv = sorted(self.rows)
        for p in piv:
            row, rhs = self.rows[p]
            for q in reversed([q for q in piv if q < p]):
                if (row >> q) & 1:
                    row ^= red[q][0]
                    rhs ^= red[q][1]
            red[p] = (row, rhs)
        return frozenset(red.values())

    def contains(self, x: int) -> bool:
        return all(parity(row & x) == rhs for row, rhs in self.rows.values())

    def contains_packed(self, X: np.ndarray) -> np.ndarray:
        """Packed membership words for packed points X of shape (n, W)."""
        ok = np.full(X.shape[1], ONES, dtype=np.uint64)
        for row, rhs in self.rows.values():
            idx = bit_list(row)
            par = np.bitwise_xor.reduce(X[idx], axis=0)
            ok &= par if rhs else ~par
        return ok

    def sample_packed_uniform(self, X: np.ndarray, rng: np.random.Generator) -> np.ndarray:
        """Overwrite the pivot rows of packed points X so that they lie in V.
        If the coordinates of X in supp(V) are i.i.d. uniform bits independent
        of the rest, the output is distributed as the input law conditioned on
        V (the pivots are a function of the free coordinates)."""
        for p in sorted(self.rows):
            row, rhs = self.rows[p]
            rest = bit_list(row ^ (1 << p))
            if rest:
                v = np.bitwise_xor.reduce(X[rest], axis=0)
                X[p] = ~v if rhs else v
            else:
                X[p] = np.full(X.shape[1], ONES if rhs else np.uint64(0), dtype=np.uint64)
        return X


FULL = Affine()


def uniform_mask(D: Product) -> int:
    m = 0
    for i, q in enumerate(D.q):
        if q == 0.5:
            m |= 1 << i
    return m


def restrict_to(V: Affine, U: int) -> Affine:
    """The constraints of V that are supported in U: the smallest affine
    superset of V cut out by forms on U (eliminate coordinates outside U
    first)."""
    # Gaussian elimination to reduced row echelon form, choosing pivots
    # outside U whenever the row has a coordinate outside U; the rows whose
    # pivot lies in U then form a basis of rowspace(V) cap F_2^U.
    piv: dict[int, tuple[int, int]] = {}
    for row, rhs in V.rows.values():
        for p, (r2, b2) in piv.items():
            if (row >> p) & 1:
                row ^= r2
                rhs ^= b2
        out_bits = row & ~U
        if row == 0:
            continue
        p = (out_bits or row).bit_length() - 1
        for q in list(piv):
            r2, b2 = piv[q]
            if (r2 >> p) & 1:
                piv[q] = (r2 ^ row, b2 ^ rhs)
        piv[p] = (row, rhs)
    W = Affine()
    for p, (row, rhs) in piv.items():
        if row & ~U == 0:
            W.add(row, rhs)
    return W


# ======================================================================= ANF
@dataclass(frozen=True)
class ANF:
    """An F_2 polynomial: lin . x + const + sum of nonlinear monomials (each a
    bitmask with at least two bits)."""

    lin: int
    const: int
    nonlin: frozenset

    def is_affine(self) -> bool:
        return not self.nonlin

    def terms(self) -> int:
        return bin(self.lin).count("1") + self.const + len(self.nonlin)

    def monomials(self):
        if self.const:
            yield 0
        m = self.lin
        while m:
            low = m & -m
            yield low
            m ^= low
        yield from self.nonlin


ANF_ZERO = ANF(0, 0, frozenset())
ANF_ONE = ANF(0, 1, frozenset())


def anf_var(i: int) -> ANF:
    return ANF(1 << i, 0, frozenset())


def anf_add(a: ANF, b: ANF) -> ANF:
    return ANF(a.lin ^ b.lin, a.const ^ b.const, a.nonlin ^ b.nonlin)


def _from_monos(monos, cap: int):
    lin, const, non = 0, 0, set()
    for m in monos:
        if m == 0:
            const ^= 1
        elif m & (m - 1) == 0:
            lin ^= m
        else:
            non ^= {m}
    if len(non) > cap:
        return None
    return ANF(lin, const, frozenset(non))


def anf_mul(a: ANF, b: ANF, cap: int, work: int):
    if a.terms() * b.terms() > work:
        return None
    acc: dict[int, int] = {}
    for x in a.monomials():
        for y in b.monomials():
            m = x | y
            acc[m] = acc.get(m, 0) ^ 1
    return _from_monos((m for m, v in acc.items() if v), cap)


def anf_gate(op: str, kids: list, param, cap: int, work: int):
    """ANF of a gate from its children's ANFs (None = unknown)."""
    if op == "CONST":
        return ANF_ONE if param else ANF_ZERO
    if any(k is None for k in kids):
        return None
    if op == "NOT":
        return anf_add(kids[0], ANF_ONE)
    if op == "XOR":
        r = kids[0]
        for k in kids[1:]:
            r = anf_add(r, k)
        return r if len(r.nonlin) <= cap else None
    if op == "AND":
        r = kids[0]
        for k in kids[1:]:
            r = anf_mul(r, k, cap, work)
            if r is None:
                return None
        return r
    if op == "OR":  # a or b = a + b + ab
        r = kids[0]
        for k in kids[1:]:
            ab = anf_mul(r, k, cap, work)
            if ab is None:
                return None
            r = anf_add(anf_add(r, k), ab)
            if len(r.nonlin) > cap:
                return None
        return r
    return None  # THR and anything else: opaque


def anf_all(C: Circuit, cap: int = 64, work: int = 1 << 13, gates=None) -> dict[int, ANF | None]:
    """ANF of every gate in the cone of the output (or of `gates`)."""
    cone = C.cone() if gates is None else sorted(gates)
    A: dict[int, ANF | None] = {}
    for v in cone:
        op = C.ops[v]
        if op == "IN":
            A[v] = anf_var(v)
        else:
            A[v] = anf_gate(op, [A[u] for u in C.args[v]], C.params[v], cap, work)
    return A


def certified_affine(C: Circuit, cap: int = 64, work: int = 1 << 13, anf=None) -> dict[int, tuple[int, int]]:
    """{gate: (mask, c)} for every gate in the cone certified to compute the
    affine form mask . x + c."""
    A = anf_all(C, cap, work) if anf is None else anf
    return {v: (a.lin, a.const) for v, a in A.items() if a is not None and a.is_affine()}


def solved_form(C: Circuit, g: int, i: int, sup: list[int], cap: int = 64, work: int = 1 << 13,
                max_gates: int = 400) -> bool:
    """Certify g(x) = x_i XOR G(x_{-i}) by a symbolic ANF in which x_i is one
    symbol and every gate of cone(g) whose syntactic support avoids i is an
    opaque symbol (an "atom"). Substituting Boolean functions for symbols is a
    homomorphism of Boolean rings, so the identity holds for all x."""
    if not (sup[g] >> i) & 1:
        return False
    cone = [v for v in C.cone(g) if (sup[v] >> i) & 1]
    if len(cone) > max_gates:
        return False
    atom_bit: dict[int, int] = {}
    A: dict[int, ANF | None] = {}

    def val(u):
        if (sup[u] >> i) & 1:
            return A[u]
        if C.ops[u] == "CONST":
            return ANF_ONE if C.params[u] else ANF_ZERO
        if u not in atom_bit:
            atom_bit[u] = len(atom_bit) + 1
        return anf_var(atom_bit[u])

    for v in cone:
        if v == i:
            A[v] = anf_var(0)
            continue
        A[v] = anf_gate(C.ops[v], [val(u) for u in C.args[v]], C.params[v], cap, work)
    a = A.get(g)
    if a is None or not (a.lin & 1):
        return False
    return all(not (m & 1) for m in a.nonlin)


# ================================================================ AND-spine
def and_spine(C: Circuit, root: int | None = None, stop=None) -> list[tuple[int, int]]:
    """Conjuncts (g, b) with C = AND_j [g_j = b_j] identically, reached from
    the output through AND gates, NOT-OR (De Morgan) and double negation.
    Gates with stop(g) true (e.g. certified affine ones) are not entered."""
    root = C.output if root is None else root
    out, seen = [], set()
    stack = [(root, 1)]
    while stack:
        g, b = stack.pop()
        if (g, b) in seen:
            continue
        seen.add((g, b))
        op = C.ops[g]
        if stop is not None and stop(g):
            out.append((g, b))
        elif op == "NOT":
            stack.append((C.args[g][0], 1 - b))
        elif (op == "AND" and b == 1) or (op == "OR" and b == 0):
            stack.extend((u, b) for u in C.args[g])
        else:
            out.append((g, b))
    return out


def _copy_cone(C: Circuit, R: Circuit, g: int, inmap: dict[int, int]) -> int:
    val: dict[int, int] = {}
    for v in C.cone(g):
        if C.ops[v] == "IN":
            val[v] = inmap.get(v, v)
        else:
            val[v] = R.add(C.ops[v], [val[u] for u in C.args[v]], C.params[v])
    return val[g]


# ================================================================== presolve
@dataclass
class Presolve:
    """C = [Ax = b] AND (solved-form conjuncts) AND R, rewritten as
    p = M * E_{x ~ D}[W(x)], W = reduced(x) * prod_{p in P_nu} D_p(pi_p(x)) / max_p
    with reduced = R o pi, which does not read the pivot coordinates."""

    n: int
    infeasible: bool = False
    rref: dict = field(default_factory=dict)        # pivot -> (row mask incl. pivot, rhs)
    solved: list = field(default_factory=list)       # (gate, polarity, pivot), in order
    residual: list = field(default_factory=list)     # (gate, polarity)
    reduced: Circuit | None = None
    uniform_pivots: int = 0
    nonuniform: list = field(default_factory=list)   # pivots p with D_p != 1/2
    log2_M: float = 0.0                              # log2 of the factor M (for notes only)
    M_mant: float = 1.0                              # M_mant * 2^M_exp = M (1 + theta),
    M_exp: int = 0                                   # |theta| <= M_rel (M_rel = 0: exact)
    M_rel: float = 0.0

    @property
    def rank(self) -> int:
        return len(self.rref) + len(self.solved)


def presolve(C: Circuit, D: Product | None = None, anf_cap: int = 64, use_solved: bool = True,
             max_candidates: int = 64, anf=None) -> Presolve:
    n = C.n
    D = Product.uniform(n) if D is None else D
    U = uniform_mask(D)
    P = Presolve(n)
    A = anf_all(C, anf_cap) if anf is None else anf
    sup = C.supports()
    sf_cache: dict[int, bool] = {}

    def stop(g):
        # do not split certified affine gates, nor AND/OR gates that are in
        # solved form x_i XOR G(x_{-i}) for some uniform i (e.g. XOR gadgets)
        a = A.get(g)
        if a is not None and a.is_affine():
            return True
        if not use_solved or C.ops[g] not in ("AND", "OR"):
            return False
        if g not in sf_cache:
            sf_cache[g] = any(solved_form(C, g, i, sup, anf_cap)
                              for i in bit_list(sup[g] & U)[:max_candidates])
        return sf_cache[g]

    spine = and_spine(C, stop=stop)
    rows, resid = [], []
    for g, b in spine:
        a = A.get(g)
        if C.ops[g] == "CONST":
            if int(C.params[g]) != b:
                P.infeasible = True
                return P
            continue
        if a is not None and a.is_affine():
            if a.lin == 0:
                if a.const != b:
                    P.infeasible = True
                    return P
                continue
            rows.append((a.lin, b ^ a.const))
        else:
            resid.append((g, b))
    supR = 0
    for g, _ in resid:
        supR |= sup[g]
    # Gaussian elimination to reduced row echelon form, choosing pivots in U
    # (uniform coordinates) and outside the residual's support when possible.
    q = D.q
    rref: dict[int, tuple[int, int]] = {}
    for row, rhs in rows:
        for p, (r2, b2) in rref.items():
            if (row >> p) & 1:
                row ^= r2
                rhs ^= b2
        if row == 0:
            if rhs:
                P.infeasible = True
                return P
            continue
        cand = bit_list(row)
        p = min(cand, key=lambda i: (q[i] != 0.5, (supR >> i) & 1, abs(q[i] - 0.5), i))
        for t in list(rref):
            r2, b2 = rref[t]
            if (r2 >> p) & 1:
                rref[t] = (r2 ^ row, b2 ^ rhs)
        rref[p] = (row, rhs)
    P.rref = rref
    piv_aff = 0
    aff_sup = 0
    for p, (row, _) in rref.items():
        piv_aff |= 1 << p
        aff_sup |= row
    # solved-form conjuncts x_i XOR G(x_{-i}) = b with i uniform, i not read by
    # the affine rows, by earlier G's, and not already a pivot
    solved, used_piv, solved_sup = [], piv_aff, 0
    if use_solved:
        changed = True
        while changed:
            changed = False
            for k, (g, b) in enumerate(resid):
                cands = [i for i in bit_list(sup[g] & U & ~used_piv & ~aff_sup & ~solved_sup)]
                others = 0
                for j, (h, _) in enumerate(resid):
                    if j != k:
                        others |= sup[h]
                cands.sort(key=lambda i: ((others >> i) & 1, i))
                for i in cands[:max_candidates]:
                    if solved_form(C, g, i, sup, anf_cap):
                        solved.append((g, b, i))
                        used_piv |= 1 << i
                        solved_sup |= sup[g] & ~(1 << i)
                        resid.pop(k)
                        changed = True
                        break
                if changed:
                    break
    # earlier G's must not read later pivots: enforced since candidates avoid
    # solved_sup (the union of supports of the earlier G's); also G_j must not
    # read its own pivot (it does not: G = g|_{x_i = 0}).
    P.solved = solved
    P.residual = resid
    R = Circuit(n)
    inmap: dict[int, int] = {}
    for p, (row, rhs) in rref.items():
        free = bit_list(row ^ (1 << p))
        if not free:
            inmap[p] = R.const(rhs)
        else:
            x = R.XOR(*free) if len(free) > 1 else free[0]
            inmap[p] = R.NOT(x) if rhs else x
    for g, b, i in solved:
        mm = dict(inmap)
        mm[i] = R.const(0)
        G = _copy_cone(C, R, g, mm)
        inmap[i] = R.NOT(G) if b else G
    outs = []
    for g, b in resid:
        h = _copy_cone(C, R, g, inmap)
        outs.append(h if b else R.NOT(h))
    if not outs:
        R.set_output(R.const(1))
    else:
        R.set_output(R.AND(*outs) if len(outs) > 1 else outs[0])
    P.reduced = R
    nonu = [p for p in rref if q[p] != 0.5]
    P.nonuniform = nonu
    P.uniform_pivots = len(rref) - len(nonu) + len(solved)
    # M = 2^-(uniform pivots) * prod max(q_p, 1 - q_p), as a renormalised
    # product: each factor (1 - q_p is one rounding) and each product is one
    # rounding, frexp is exact, so M_mant * 2^M_exp = M (1 + theta) with
    # |theta| <= gamma_{2k}; no logarithms, no underflow.
    mant, e = 1.0, -P.uniform_pivots
    for p in nonu:
        qp = float(q[p])
        mant *= qp if qp >= 0.5 else 1.0 - qp
        mant, de = math.frexp(mant)
        e += de
    P.M_mant, P.M_exp = mant, e
    P.M_rel = _gamma(2 * len(nonu)) if nonu else 0.0
    P.log2_M = math.log2(mant) + e
    return P


def _pivot_weight(P: Presolve, D: Product, X: np.ndarray, k: int) -> np.ndarray:
    w = np.ones(k)
    for p in P.nonuniform:
        row, rhs = P.rref[p]
        free = bit_list(row ^ (1 << p))
        if free:
            v = np.bitwise_xor.reduce(X[free], axis=0)
            bits = unpack_bits(v, k) ^ bool(rhs)
        else:
            bits = np.full(k, bool(rhs))
        qp = float(D.q[p])
        mx = max(qp, 1 - qp)
        w *= np.where(bits, qp, 1 - qp) / mx
    return w


def presolve_estimate(C: Circuit, D: Product | None = None, eps: float = 0.1, delta: float = 0.05,
                      rng=None, max_samples: int = 10**6, anf_cap: int = 64, inner=None,
                      pre: Presolve | None = None) -> Estimate:
    """Sound interval for p from the presolve. The residual mean E[W] is
    estimated by the doubling KL rule (or, if all pivots are uniform and
    `inner(Cr, D, eps, delta)` is given, by that sound estimator on the
    reduced circuit). The certified upper bound p <= M always holds. The
    interval is [a_lo M, a_hi M] rounded outward; when it lies below the
    floating-point range the upper end is the smallest positive double and the
    note gives the bounds in log2 form."""
    rng = np.random.default_rng() if rng is None else rng
    D = Product.uniform(C.n) if D is None else D
    P = presolve(C, D, anf_cap) if pre is None else pre
    if P.infeasible:
        return Estimate(0.0, 0.0, 0.0, 0, 0, delta, "presolve: inconsistent affine spine, p = 0")
    n = C.n
    mant, ex, rel = P.M_mant, P.M_exp, P.M_rel
    note = f"presolve: rank {P.rank} (affine {len(P.rref)}, solved {len(P.solved)}), log2 M = {P.log2_M:.3f}"
    if inner is not None and not P.nonuniform:
        e = inner(P.reduced, D, eps, delta)   # M = 2^-k exactly here
        lo, hi = _scaled_interval(e.lo, min(e.hi, 1.0), mant, ex, rel)
        val = min(max(_ldexp(e.value * mant, ex), lo), hi)
        return Estimate(val, lo, hi, e.samples, e.evaluations, delta,
                        note + " | " + e.note + "; " + _log2_note(e.lo, e.hi, mant, ex))
    Cr = P.reduced
    # W is computed with relative error <= gamma_{3k} (k biased pivots: 1 - q,
    # a division and a product each), i.e. absolute error <= gamma_{3k} as
    # W <= 1; the Bernoulli sampler of a biased D is off by <= n 2^-53 in total
    # variation. Both shift E[W] by at most tau.
    k = len(P.nonuniform)
    tau = (_gamma(3 * k + 2) + (n + 2) * U53) if np.any(D.q != 0.5) else 0.0

    def draw(kk):
        X = D.sample_packed(kk, rng)
        y = unpack_bits(Cr.eval_packed(X), kk).astype(float)
        if P.nonuniform:
            y *= _pivot_weight(P, D, X, kk)
        return y

    est = sequential_mean(draw, 0.999 * eps if tau == 0 else 0.99 * eps, delta, max_samples=max_samples)
    a_lo = _down(max(0.0, est.lo - tau)) if tau else est.lo
    a_hi = min(1.0, _up(est.hi + tau)) if tau else est.hi
    lo, hi = _scaled_interval(a_lo, a_hi, mant, ex, rel)
    val = min(max(_ldexp(est.value * mant, ex), lo), hi)
    if hi < 1e-300:
        note += "; " + _log2_note(a_lo, a_hi, mant, ex)
    return Estimate(val, lo, hi, est.samples, est.samples, delta, note)


# ===================================================== product-measure pieces
class TooWide(Exception):
    pass


def valid_order(order, n: int):
    """order as a list of Python ints if it is a permutation of range(n),
    otherwise None (explicit checks: no assert, which python -O removes)."""
    if order is None or isinstance(order, (str, bytes)):
        return None
    try:
        out = list(order)
    except TypeError:
        return None
    if len(out) != n or not all(isinstance(i, (int, np.integer)) and not isinstance(i, bool) for i in out):
        return None
    out = [int(i) for i in out]
    return out if sorted(out) == list(range(n)) else None


class LinearOrderDP:
    """D(V) and exact sampling from D restricted to V = {Ax = b} along a
    linear order of the coordinates. After position t the state is the
    partial syndrome s = A_{<=t} x_{<=t}; it is kept only if it is live,
    s in b + col(A_{>t}). Live states form a coset of
    col(A_{<=t}) cap col(A_{>t}), of size 2^{lambda_t} with
    lambda_t = rank A_{<=t} + rank A_{>t} - rank A.

    Floating point: every level is renormalised by an exact power of two and
    must stay in the normal range (otherwise TooWide is raised and callers
    relax the piece). A stored value is fl(fl(f0 * fl(1 - q)) + fl(f1 * q))
    with f0, f1 stored values of the previous level, so each level multiplies
    the relative error by at most (1 + u)^4 (three roundings, plus at most u
    times the normal sum for a product that underflows). Hence
    mass_m * 2^mass_e = D(V) (1 + theta) with |theta| <= gamma_{4n} <= rel =
    gamma_{5n+5} (tested against exact rationals). A mass of 0 is exact: it
    means that no state survives, by exact integer logic."""

    def __init__(self, V: Affine, D: Product, order=None, max_width: int = 16):
        n = D.n
        if order is None:
            order = list(range(n))
        else:
            order = valid_order(order, n)
            if order is None:
                raise TooWide("the order is not a permutation of the coordinates")
        rows = list(V.rows.values())
        m = len(rows)
        cols = [0] * n
        b = 0
        for j, (row, rhs) in enumerate(rows):
            b |= rhs << j
            for i in bit_list(row):
                if i >= n:
                    raise TooWide("constraint on a coordinate outside the distribution")
                cols[i] |= 1 << j
        # suffix bases col(A_{>t}) for t = 0..n
        suffix: list[dict[int, int]] = [None] * (n + 1)
        basis: dict[int, int] = {}
        suffix[n] = dict(basis)
        for t in range(n - 1, -1, -1):
            v = cols[order[t]]
            while v:
                tt = v.bit_length() - 1
                if tt in basis:
                    v ^= basis[tt]
                else:
                    basis[tt] = v
                    break
            suffix[t] = dict(basis)

        def live(s, t):
            v = s ^ b
            B = suffix[t]
            while v:
                tt = v.bit_length() - 1
                if tt in B:
                    v ^= B[tt]
                else:
                    return False
            return True

        self.order, self.n, self.m = order, n, m
        self.levels = [([0], np.array([1.0]))] if live(0, 0) else [([], np.array([]))]
        self.trans = []
        self.width = 0
        scale_exp = 0  # true F_t = stored F_t * 2^scale_exp, exactly
        cap = 1 << max_width
        for t in range(1, n + 1):
            i = order[t - 1]
            qi = float(D.q[i])
            q0 = 1.0 - qi
            a = cols[i]
            prev_states, prev_prob = self.levels[-1]
            pidx = {s: k for k, s in enumerate(prev_states)}
            new: dict[int, float] = {}
            for s, f in zip(prev_states, prev_prob):
                f = float(f)
                if qi < 1 and live(s, t):
                    new[s] = new.get(s, 0.0) + f * q0
                s1 = s ^ a
                if qi > 0 and live(s1, t):
                    new[s1] = new.get(s1, 0.0) + f * qi
            if len(new) > cap:
                raise TooWide(f"{len(new)} live states at position {t}")
            self.width = max(self.width, len(new).bit_length() - 1 if new else 0)
            states = list(new)
            prob = np.array([new[s] for s in states], dtype=float)
            if len(states) and prob.min() < TINY:
                raise TooWide("a live state's mass left the normal floating-point range")
            p1 = np.empty(len(states))
            i0 = np.empty(len(states), dtype=np.int64)
            i1 = np.empty(len(states), dtype=np.int64)
            for k, s in enumerate(states):
                j0 = pidx.get(s, -1)
                j1 = pidx.get(s ^ a, -1)
                f1 = float(prev_prob[j1]) * qi if j1 >= 0 else 0.0
                p1[k] = min(1.0, f1 / prob[k])
                i0[k], i1[k] = j0, j1
            if len(states):
                _, e = math.frexp(float(prob.max()))
                prob = np.ldexp(prob, -e)   # exact while the values stay normal
                scale_exp += e
                if prob.min() < TINY:
                    raise TooWide("a live state's mass left the normal floating-point range")
            self.trans.append((p1, i0, i1))
            self.levels.append((states, prob))
        last_states, last_prob = self.levels[-1]
        self.b = b
        self.rel = _gamma(5 * n + 5)
        if b in last_states:
            self.mass_m = float(last_prob[last_states.index(b)])
            self.mass_e = scale_exp
        else:
            self.mass_m, self.mass_e = 0.0, 0  # exactly: no point of V has positive probability

    @property
    def mass(self) -> float:
        """D(V) as a float (may underflow; use mass_m, mass_e for tiny masses)."""
        return _ldexp(self.mass_m, self.mass_e)

    def sample(self, N: int, rng: np.random.Generator) -> np.ndarray:
        """(N, n) bool samples from D conditioned on V (requires mass > 0)."""
        if not self.mass_m > 0:
            raise ValueError("LinearOrderDP.sample: V has probability 0")
        X = np.zeros((N, self.n), dtype=bool)
        states, _ = self.levels[-1]
        cur = np.full(N, states.index(self.b), dtype=np.int64)
        for t in range(self.n, 0, -1):
            p1, i0, i1 = self.trans[t - 1]
            u = rng.random(N) < p1[cur]
            X[:, self.order[t - 1]] = u
            cur = np.where(u, i1[cur], i0[cur])
        return X


class Piece:
    """An affine subspace with its D-mass, as mass_m * 2^mass_e = D(V)(1 + theta)
    with |theta| <= rel, and an exact D|V sampler: closed form (exact mass
    2^-codim) when every constraint is on uniform coordinates, otherwise the
    linear-order dynamic program (which raises TooWide above the cap)."""

    def __init__(self, V: Affine, D: Product, U: int, order=None, max_width: int = 16):
        self.V = V
        self.D = D
        if V.support() & ~U == 0:
            self.dp = None
            self.mass_m, self.mass_e, self.rel = 0.5, 1 - V.rank, 0.0
        else:
            self.dp = LinearOrderDP(V, D, order, max_width)
            self.mass_m, self.mass_e, self.rel = self.dp.mass_m, self.dp.mass_e, self.dp.rel

    @property
    def mass(self) -> float:
        return _ldexp(self.mass_m, self.mass_e)

    def sample_packed(self, N: int, rng: np.random.Generator) -> np.ndarray:
        from .circuit import pack_rows
        if self.dp is not None:
            return pack_rows(self.dp.sample(N, rng))
        W = (N + 63) // 64
        if np.all(self.D.q == 0.5):
            X = rng.integers(0, 2**64, size=(self.D.n, W), dtype=np.uint64)
        else:
            X = self.D.sample_packed(N, rng)
            for i in bit_list(self.V.support()):
                X[i] = rng.integers(0, 2**64, size=W, dtype=np.uint64)
        return self.V.sample_packed_uniform(X, rng)


def make_pieces(spaces: list[Affine], D: Product, max_width: int = 16, orders=None):
    """Pieces for a list of subspaces; a subspace whose dynamic program is too
    wide (or leaves the floating-point range, or comes with an invalid order)
    is replaced by its constraints on uniform coordinates (a superset)."""
    U = uniform_mask(D)
    out, relaxed = [], 0
    for k, V in enumerate(spaces):
        try:
            out.append(Piece(V, D, U, None if orders is None else orders[k], max_width))
        except TooWide:
            relaxed += 1
            out.append(Piece(restrict_to(V, U), D, U))
    return out, relaxed


# ================================================================ KLM / IS
def klm_estimate(C: Circuit, D: Product, pieces: list[Piece], eps: float = 0.1, delta: float = 0.05,
                 rng=None, max_samples: int = 10**6, note: str = "") -> Estimate:
    """Interval for p assuming C^-1(1) is contained in the union of the
    pieces (phi = number of pieces containing x): pick a piece with
    probability proportional to its mass, X ~ D|piece, W = C(X)/phi(X) in
    [0, 1], E W = p / Z.

    Floating point (all bounds proved, none heuristic). Masses are scaled by a
    common power of two 2^E; a piece whose scaled mass would leave the normal
    range (below 2^-1000 of the largest) is not sampled and its mass, at most
    2^-999 * 2^E each, is added to the upper end (p <= D(C and union of the
    sampled pieces) + their masses). With computed masses G_j = mu_j (1 +
    theta_j), |theta_j| <= rel, and selection proportional to G_j, the
    Karp-Luby-Madras identity becomes sum_j G_j * E W in [(1 - rel) p,
    (1 + rel) p]; the scaled total is an exactly rounded rational sum (one
    rounding). The realised sampler differs from the ideal one by at most tau
    in total variation: the cumulative selection probabilities are correctly
    rounded (2u each) and the uniform draw has 53-bit granularity (T 2^-52
    in all); a dynamic-programming sampler multiplies path probabilities
    that telescope exactly, with relative error gamma_{3n} plus at most 3u +
    2^-53 per coordinate; the Bernoulli coordinates of D cost 2^-53 each.
    The interval for E W is widened by tau and the result is rounded
    outward."""
    rng = np.random.default_rng() if rng is None else rng
    n = C.n
    pieces = [P for P in pieces if P.mass_m > 0]
    if not pieces:
        return Estimate(0.0, 0.0, 0.0, 0, 0, delta, note + "empty envelope: p = 0")
    E = max(P.mass_e for P in pieces)
    kept = [P for P in pieces if P.mass_e - E >= -1000]
    n_drop = len(pieces) - len(kept)
    slack = n_drop * 2.0 ** -999        # scaled upper bound on the dropped masses
    T = len(kept)
    scaled = [math.ldexp(P.mass_m, P.mass_e - E) for P in kept]   # exact: normal range
    exact_cum = []
    acc = Fraction(0)
    for x in scaled:
        acc += Fraction(x)
        exact_cum.append(acc)
    Zs = float(acc)                      # correctly rounded: relative error <= u
    rel = max(P.rel for P in kept)
    eta = 2.0 * (rel + 2 * U53)
    if eta > 0.25:
        return Estimate(0.0, 0.0, 1.0, 0, 0, delta, note + "mass bounds too weak; trivial interval")
    tau = (2 * T + 16 * n + 32) * 2.0 ** -52
    cum = np.array([float(c / acc) for c in exact_cum])
    cum[-1] = 1.0
    evals = [0]

    def draw(k):
        j = np.searchsorted(cum, rng.random(k), side="right")
        j = np.minimum(j, T - 1)
        out = np.zeros(k)
        for t in np.unique(j):
            idx = np.nonzero(j == t)[0]
            kk = len(idx)
            X = kept[t].sample_packed(kk, rng)
            c = unpack_bits(C.eval_packed(X), kk)
            phi = np.zeros(kk)
            for Pc in kept:
                phi += unpack_bits(Pc.V.contains_packed(X), kk)
            w = np.zeros(kk)
            ok = c & (phi > 0)
            w[ok] = 1.0 / phi[ok]
            out[idx] = w
        evals[0] += k
        return out

    est = sequential_mean(draw, 0.99 * eps, delta, max_samples=max_samples)
    a_lo = _down(max(0.0, est.lo - tau))
    a_hi = min(1.0, _up(est.hi + tau))
    # p in [Zs a_lo (1 - eta), Zs a_hi (1 + eta) + slack] * 2^E, rounded outward
    lo_s = _down(_down(Zs * a_lo) * _down(1.0 - eta)) if a_lo > 0 else 0.0
    hi_s = _up(_up(Zs * a_hi) * _up(1.0 + eta))
    hi_s = _up(hi_s + slack) if slack else hi_s
    lo = _ldexp_down(lo_s, E) if lo_s > 0 else 0.0
    hi = min(1.0, _ldexp_up(hi_s, E))
    val = min(max(_ldexp(est.value * Zs, E), lo), hi)
    zl = math.log2(Zs) + E
    msg = note + f"affine envelope: {T} pieces, mass {_ldexp(Zs, E):.4g}"
    if n_drop:
        msg += f" (+{n_drop} negligible pieces bounded)"
    if hi < 1e-300:
        msg += f"; log2 mass {zl:.4f}; log2 bounds [{(math.log2(lo_s) + E) if lo_s > 0 else -math.inf:.4f}, " \
               f"{math.log2(hi_s) + E:.4f}]"
    return Estimate(val, lo, hi, est.samples, evals[0], delta, msg)


# =========================================================== affine envelope
def _simplify(L: list[Affine]) -> list[Affine]:
    if len(L) == 1:   # nothing to deduplicate (and S.key() costs O(rank^2))
        return [FULL] if L[0].rank == 0 else list(L)
    seen, out = set(), []
    for S in L:
        if S.rank == 0:
            return [FULL]
        k = S.key()
        if k not in seen:
            seen.add(k)
            out.append(S)
    if len(out) <= 64:
        keep = []
        for a, S in enumerate(out):
            if not any(b != a and (T.rank < S.rank or (T.rank == S.rank and b < a)) and S.subset_of(T)
                       for b, T in enumerate(out)):
                keep.append(S)
        out = keep
    return out


def _mass_proxy(L: list[Affine]) -> float:
    return sum(2.0 ** -S.rank for S in L)


def _meet(L1, L2, cap):
    if len(L1) * len(L2) <= cap:
        out = []
        for S in L1:
            for T in L2:
                M = S.meet(T)
                if M is not None:
                    out.append(M)
        out = _simplify(out)
        if len(out) <= cap:
            return out
    return L1 if _mass_proxy(L1) <= _mass_proxy(L2) else L2  # g = a AND b implies a


def _join(L1, L2, cap):
    L = _simplify(L1 + L2)
    return L if len(L) <= cap else [FULL]


def affine_envelope(C: Circuit, cap: int = 16, anf_cap: int = 64, anf=None) -> list[Affine]:
    """Affine subspaces V_1..V_T with C^-1(1) contained in their union, by
    abstract interpretation over unions of affine subspaces. Invariant (proved
    by induction over the gates): g^-1(1) is in the union of E+(g) and
    g^-1(0) in that of E-(g). An empty list certifies p = 0."""
    A = anf_all(C, anf_cap) if anf is None else anf
    Ep: dict[int, list] = {}
    En: dict[int, list] = {}
    for v in C.cone():
        a = A.get(v)
        if a is not None and a.is_affine():
            if a.lin == 0:
                Ep[v], En[v] = ([FULL], []) if a.const else ([], [FULL])
            else:
                Ep[v] = [Affine.single(a.lin, 1 ^ a.const)]
                En[v] = [Affine.single(a.lin, a.const)]
            continue
        op, ch = C.ops[v], C.args[v]
        if op == "NOT":
            Ep[v], En[v] = En[ch[0]], Ep[ch[0]]
        elif op in ("AND", "OR"):
            P = Ep if op == "AND" else En   # side that meets
            Q = En if op == "AND" else Ep   # side that joins
            m, j = P[ch[0]], Q[ch[0]]
            for u in ch[1:]:
                m = _meet(m, P[u], cap)
                j = _join(j, Q[u], cap)
            (Ep[v], En[v]) = (m, j) if op == "AND" else (j, m)
        elif op == "XOR":
            p1, n1 = Ep[ch[0]], En[ch[0]]
            for u in ch[1:]:
                p2, n2 = Ep[u], En[u]
                p1, n1 = (_join(_meet(p1, n2, cap), _meet(n1, p2, cap), cap),
                          _join(_meet(p1, p2, cap), _meet(n1, n2, cap), cap))
            Ep[v], En[v] = p1, n1
        elif op == "CONST":
            Ep[v], En[v] = ([FULL], []) if C.params[v] else ([], [FULL])
        else:  # THR or opaque
            Ep[v], En[v] = [FULL], [FULL]
    return Ep[C.output]


def affine_envelope_estimate(C: Circuit, D: Product | None = None, eps: float = 0.1, delta: float = 0.05,
                             rng=None, cap: int = 16, anf_cap: int = 64, max_samples: int = 10**6,
                             max_width: int = 16) -> Estimate:
    D = Product.uniform(C.n) if D is None else D
    spaces = affine_envelope(C, cap, anf_cap)
    pieces, relaxed = make_pieces(spaces, D, max_width)
    note = f"(relaxed {relaxed}) " if relaxed else ""
    return klm_estimate(C, D, pieces, eps, delta, rng, max_samples, note)


# ===================================================== XPT arguments (Part 2)
class Contradiction(Exception):
    pass


def thr_sum(w, bits) -> float:
    """The weighted sum exactly as Circuit.eval_packed computes it: start at
    0.0 and add w_i * float(bit_i) left to right in IEEE double."""
    s = 0.0
    for wi, b in zip(w, bits):
        s += wi * (1.0 if b else 0.0)
    return s


class Propagator:
    """Gate propagation plus Gaussian elimination on certified affine gates.
    Rules: (X1) gate semantics forwards and backwards; (X2) a certified affine
    gate with a known value adds its form to the affine system S; (X3) a
    certified affine gate whose form is constant on V(S) gets that value. All
    rules are valid inferences about the true gate values of any x that
    satisfies the current state.

    Threshold gates are reasoned about as the evaluator computes them: the
    left-to-right rounded sum of thr_sum compared with t - 1e-12. With finite
    weights the partial sums are never NaN and rounded addition is monotone,
    so the sum is monotone in every occurrence of every child (nondecreasing
    for w > 0, nonincreasing for w < 0); setting each unknown occurrence
    independently to its extreme value bounds the sum over all consistent
    inputs (a relaxation when a child occurs twice). Non-finite weights only
    allow forward evaluation with all children known."""

    def __init__(self, C: Circuit, anf_cap: int = 64):
        self.C = C
        self.cone = C.cone()
        self.aff = certified_affine(C, anf_cap)

    @staticmethod
    def _thr_extreme(ch, w, cv, high, fixed=None, fixed_b=None) -> float:
        bits = []
        for u, wi, c in zip(ch, w, cv):
            if u == fixed:
                bits.append(fixed_b)
            elif c is not None:
                bits.append(c)
            else:   # the value that makes w_i * b largest (high) or smallest
                bits.append(int(wi > 0) if high else int(wi < 0))
        return thr_sum(w, bits)

    def run(self, S: Affine, sigma: dict[int, int]):
        C = self.C
        added = set()

        def setv(g, b):
            old = sigma.get(g)
            if old is None:
                sigma[g] = b
                return True
            if old != b:
                raise Contradiction
            return False

        changed = True
        while changed:
            changed = False
            for v in self.cone:
                f = self.aff.get(v)
                val = sigma.get(v)
                if f is not None:
                    if val is not None and v not in added:
                        added.add(v)
                        if not S.add(f[0], val ^ f[1]):
                            raise Contradiction
                        changed = True
                    elif val is None:
                        cv = S.form_value(f[0], f[1])
                        if cv is not None:
                            changed |= setv(v, cv)
                            val = cv
                op = C.ops[v]
                if op == "IN":
                    continue
                ch = C.args[v]
                if op == "CONST":
                    changed |= setv(v, int(C.params[v]))
                    continue
                cv = [sigma.get(u) for u in ch]
                val = sigma.get(v)
                if op == "NOT":
                    if cv[0] is not None:
                        changed |= setv(v, 1 - cv[0])
                    elif val is not None:
                        changed |= setv(ch[0], 1 - val)
                elif op in ("AND", "OR"):
                    dom = 0 if op == "AND" else 1     # dominating child value
                    if any(c == dom for c in cv):
                        changed |= setv(v, dom)
                    elif all(c == 1 - dom for c in cv):
                        changed |= setv(v, 1 - dom)
                    val = sigma.get(v)
                    if val == 1 - dom:
                        for u in ch:
                            changed |= setv(u, 1 - dom)
                    elif val == dom:
                        unk = [u for u, c in zip(ch, cv) if c is None]
                        if len(unk) == 1 and all(c in (None, 1 - dom) for c in cv):
                            changed |= setv(unk[0], dom)
                elif op == "XOR":
                    unk = [u for u, c in zip(ch, cv) if c is None]
                    if not unk:
                        changed |= setv(v, sum(cv) & 1)
                    elif len(unk) == 1 and val is not None:
                        s = sum(c for c in cv if c is not None)
                        # a child listed twice cancels; infer only for a single occurrence
                        if ch.count(unk[0]) == 1:
                            changed |= setv(unk[0], (val ^ s) & 1)
                elif op == "THR":
                    w, t = C.params[v]
                    tt = t - 1e-12  # the comparison of Circuit.eval_packed
                    if all(c is not None for c in cv):
                        changed |= setv(v, int(thr_sum(w, cv) >= tt))
                        continue
                    if not all(math.isfinite(wi) for wi in w):
                        continue
                    if self._thr_extreme(ch, w, cv, high=False) >= tt:
                        changed |= setv(v, 1)
                    elif not self._thr_extreme(ch, w, cv, high=True) >= tt:
                        changed |= setv(v, 0)
                    val = sigma.get(v)
                    if val is None:
                        continue
                    for u in dict.fromkeys(u for u, c in zip(ch, cv) if c is None):
                        for bb in (0, 1):
                            if val == 1 and not self._thr_extreme(ch, w, cv, True, u, bb) >= tt:
                                changed |= setv(u, 1 - bb)   # u = bb cannot reach the threshold
                            elif val == 0 and self._thr_extreme(ch, w, cv, False, u, bb) >= tt:
                                changed |= setv(u, 1 - bb)   # u = bb forces the threshold
        return S, sigma


def _is_int(x) -> bool:
    return isinstance(x, (int, np.integer))


def parse_split(C: Circuit, node):
    """The split of an internal node, normalised to ('gate', g) or
    ('form', mask, c) with c in {0, 1}, or None if the node is not a
    well-formed internal node (it is then treated as an open leaf, which is
    always sound). Explicit type and range checks on every prover field."""
    if not isinstance(node, dict):
        return None
    sp, ch = node.get("split"), node.get("children")
    if not isinstance(sp, (list, tuple)) or not isinstance(ch, (list, tuple)) or len(ch) != 2 or not sp:
        return None
    if not isinstance(sp[0], str):
        return None
    if sp[0] == "gate":
        if len(sp) == 2 and _is_int(sp[1]) and 0 <= int(sp[1]) < len(C.ops):
            return ("gate", int(sp[1]))
        return None
    if sp[0] == "form":
        if len(sp) not in (2, 3) or not isinstance(sp[1], (list, tuple)):
            return None
        if not all(_is_int(i) and 0 <= int(i) < C.n for i in sp[1]):
            return None
        c = sp[2] if len(sp) == 3 else 0
        if not _is_int(c) or int(c) not in (0, 1):
            return None
        mask = 0
        for i in sp[1]:
            mask ^= 1 << int(i)
        return ("form", mask, int(c))
    return None


def _apply(state, split, branch):
    """Add the branch assumption of a parsed split to a copy of the state."""
    S, sigma = state
    S, sigma = S.copy(), dict(sigma)
    if split[0] == "form":
        if not S.add(split[1], branch ^ split[2]):
            raise Contradiction
    else:
        g = split[1]
        if sigma.get(g, branch) != branch:
            raise Contradiction
        sigma[g] = branch
    return S, sigma


def xpt_check(C: Circuit, arg, anf_cap: int = 64):
    """Deterministic part of the XPT verifier. Returns (open leaves, stats):
    the list of (V_leaf, order) for open leaves, for closed leaves whose
    refutation failed and for malformed nodes (all treated as open, which is
    sound), and counters. The walk is iterative (no recursion limit), and an
    order is used only if it is a permutation of range(n)."""
    Pg = Propagator(C, anf_cap)
    stats = dict(nodes=0, closed=0, open=0, downgraded=0, bad_orders=0)
    leaves = []
    stack = [(arg, Affine(), {C.output: 1})]
    while stack:
        node, S0, sig0 = stack.pop()
        stats["nodes"] += 1
        try:
            S, sigma = Pg.run(S0.copy(), dict(sig0))
        except Contradiction:
            stats["closed"] += 1  # no x with C(x) = 1 reaches this node, whatever its label
            continue
        sp = parse_split(C, node)
        if sp is not None:
            kids = []
            for b in (0, 1):
                try:
                    S1, sig1 = _apply((S, sigma), sp, b)
                except Contradiction:
                    stats["closed"] += 1
                    continue
                kids.append((node["children"][b], S1, sig1))
            stack.extend(reversed(kids))   # visit branch 0 first
            continue
        order = None
        if isinstance(node, dict):
            if isinstance(node.get("leaf"), str) and node.get("leaf") == "closed":
                stats["downgraded"] += 1
            if node.get("order") is not None:
                order = valid_order(node.get("order"), C.n)
                stats["bad_orders"] += order is None
        stats["open"] += 1
        leaves.append((S, order))
    return leaves, stats


def xpt_verify(C: Circuit, D: Product | None, arg, eps: float = 0.1, delta: float = 0.05, rng=None,
               anf_cap: int = 64, max_width: int = 16, max_samples: int = 10**6) -> Estimate:
    """XPT verifier: the deterministic check gives 1_C <= sum over open leaves
    of 1_{V_leaf} for every argument; then the KLM estimator. Sound for every
    circuit and every argument: malformed nodes become open leaves, malformed
    orders are ignored, and wide orders relax the piece."""
    D = Product.uniform(C.n) if D is None else D
    try:
        leaves, st = xpt_check(C, arg, anf_cap)
    except Exception as ex:  # defensive: an unforeseen input; the whole cube is a valid piece
        leaves = [(Affine(), None)]
        st = dict(nodes=0, closed=0, open=1, downgraded=0, bad_orders=0)
        st["error"] = type(ex).__name__
    spaces = [S for S, _ in leaves]
    orders = [o for _, o in leaves]
    pieces, relaxed = make_pieces(spaces, D, max_width, orders)
    note = f"XPT: {st['nodes']} nodes, {st['closed']} closed, {st['open']} open ({st['downgraded']} downgraded); "
    if st["bad_orders"]:
        note += f"{st['bad_orders']} malformed orders ignored; "
    if relaxed:
        note += f"{relaxed} relaxed; "
    return klm_estimate(C, D, pieces, eps, delta, rng, max_samples, note)


def xpt_honest(C: Circuit, splits: list, anf_cap: int = 64) -> dict:
    """An argument that splits on `splits` (each ('gate', g) or
    ('form', [i, ...], c)) in order on every branch, closing a branch as soon
    as propagation refutes it."""
    Pg = Propagator(C, anf_cap)

    def build(state, depth):
        try:
            S, sigma = Pg.run(state[0].copy(), dict(state[1]))
        except Contradiction:
            return {"leaf": "closed"}
        if depth == len(splits):
            return {"leaf": "open"}
        sp = list(splits[depth])
        node = {"split": sp, "children": [None, None]}
        parsed = parse_split(C, node)
        if parsed is None:
            raise ValueError(f"xpt_honest: malformed split {sp!r}")
        kids = []
        for b in (0, 1):
            try:
                st = _apply((S, sigma), parsed, b)
            except Contradiction:
                kids.append({"leaf": "closed"})
                continue
            kids.append(build(st, depth + 1))
        node["children"] = kids
        return node

    return build((Affine(), {C.output: 1}), 0)


# ================================================= barrier quantities (small)
def cut_connectivity(rows: list[int], Y: int, n: int) -> int:
    """lambda_V(Y) = rank H_Y + rank H_Z - rank H for V = {Hx = s}."""
    full = (1 << n) - 1
    Z = full ^ Y
    return gf2_rank([r & Y for r in rows]) + gf2_rank([r & Z for r in rows]) - gf2_rank(rows)


def balanced_connectivity(rows: list[int], n: int) -> int:
    """lambda_bal = min over n/3 < |Y| <= 2n/3 (brute force; small n only)."""
    best = None
    for Y in range(1, 1 << n):
        k = bin(Y).count("1")
        if 3 * k > n and 3 * k <= 2 * n:
            lam = cut_connectivity(rows, Y, n)
            if best is None or lam < best:
                best = lam
                if best == 0:
                    break
    return best


def order_profile(rows: list[int], order: list[int]) -> list[int]:
    """lambda at every prefix of a linear order (the DP's log-width profile)."""
    n = len(order)
    prof = []
    for t in range(1, n):
        Y = 0
        for i in order[:t]:
            Y |= 1 << int(i)
        prof.append(cut_connectivity(rows, Y, n))
    return prof
