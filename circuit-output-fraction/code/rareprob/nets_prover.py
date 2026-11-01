"""Prover-assisted certificates for the failure probability of ReLU MLPs on
the cube: certified partitions with checkable leaf certificates, exact
enumeration leaves and sampled (open) leaves.

Setting (rareprob.nets): f(x) = W_{L+1} relu(... relu(W_1 x + b_1) ...) + b_{L+1}
on x in {-1,+1}^d, D uniform, the event E = [f(x) < t] and p = |E| / 2^d. As
everywhere in this project the float64 weights stand for their exact binary
values and f is evaluated in exact real arithmetic (comparison with t exact).

The argument (Part 2 of the paper, specialised)
-----------------------------------------------
An argument is a binary decision tree over the input coordinates (a
partition of the cube into subcubes) whose leaves are labelled

  SAFE(cert)   cert proves f >= t on the whole subcube (no failing point);
  FAIL(cert)   cert proves f < t on the whole subcube (every point fails);
  ENUM         the verifier enumerates the subcube (meet in the middle);
  OPEN         the subcube belongs to the envelope that is sampled;

plus a sample budget N for the open part. Two certificate kinds:

  'lin'   linear bound propagation (CROWN / DeepPoly type) with slopes chosen
          by the prover: every unstable unit relaxed from below gets a slope
          alpha in [0, 1] (alpha z <= relu(z) for all z), every unit relaxed
          from above a chord through its interval; intermediate intervals
          (two or more hidden layers) are recomputed by the verifier itself.
          For one hidden layer, the best slopes give the value of the LP
          (triangle) relaxation over the subcube's box.
  'quad'  a degree-2 (Shor / S-lemma) certificate that uses x_i^2 = 1 and is
          therefore NOT limited by the box relaxation: after the layers >= 2
          are relaxed linearly, f >= sum_j G_j h_j + C with h = relu(z_1);
          each first-layer unit gets a valid quadratic minorant (G_j > 0) or
          majorant (G_j < 0) q_j(z) = kap z^2 + bet z + gam on its interval,
          chosen by the prover's parameters theta_j, so f(y) >= Y^T M Y on
          the subcube, Y = (y, 1) with y the free coordinates; the prover
          supplies mu in R^{r+1} and a shift s with M - diag(mu) - s I PSD,
          which the verifier checks by one Cholesky factorisation; then
          f >= Y^T (diag(mu) + s I) Y = sum(mu) + (r + 1) s on the subcube.

Verifier output: with F the exact count of failing points in ENUM and FAIL
leaves, Z the number of points in OPEN leaves and [l, u] the Hoeffding-KL
interval (level delta) for the failing fraction among N uniform samples of
the open union,
    p in [ (F + Z l) / 2^d , (F + Z u) / 2^d ].
With no open leaf the interval is the exact value of p, deterministically.

Soundness on every net and every argument
-----------------------------------------
* Partition. The verifier parses the tree itself: every split must be on a
  coordinate that is free in the node's subcube, every split has two
  children (x_i = -1 first), so the leaves partition the cube (or the
  subcube `root`); their sizes are summed with Python integers and must add
  up to its size. A malformed tree is rejected (output [0, 1]). The
  verifier's work is polynomial in the size of the argument: an ENUM leaf
  with more than max_enum_r free inputs is demoted to OPEN, and at most
  max_samples samples are drawn.
* Leaf certificates never need to be trusted: a leaf whose certificate is
  missing, malformed, non-finite, or fails its check is DEMOTED to an open
  leaf (its points join the sampled envelope), which keeps the interval
  valid (the envelope estimator is sound whatever the envelope is). The
  verifier recomputes every interval, chord slope, quadratic coefficient and
  matrix itself from the net and the prover's free parameters (alpha in
  [0, 1] after clipping, theta in [0, 1]^2 after clipping, mu, s); a free
  parameter can only make a bound weaker, never wrong.
* Arithmetic. The SAFE/FAIL checks run in outward-rounded interval
  arithmetic: every quantity is a pair of floats enclosing the exact real
  number that the certificate's mathematics refers to, and soundness rests
  on two elementary facts about IEEE binary64 (section "outward rounding"
  below), not on a global rounding budget. In particular
  - the side on which an unstable ReLU is relaxed is chosen from the
    enclosure of its exact backward coefficient G_j: from below if G_j >= 0
    surely, from above if G_j <= 0 surely; otherwise the unit is dropped and
    charged G_lo,j U_j (valid since 0 <= h_j <= U_j);
  - chord slopes are U / dn(U - L) rounded up, valid by construction;
  - the quadratic pieces of 'quad' are validated by interval evaluation of
    their defining inequalities (the verifier picks the constant term as
    the best value that this proof allows), M is enclosed entrywise, and
    the PSD test covers every symmetric matrix in that enclosure (Cholesky
    with Higham's backward-error bound, gradual underflow included, after an
    exact power-of-two scaling);
  - gradual underflow, underflow to zero and overflow are covered by the
    same enclosures; a bound that is not finite rejects the certificate.
* Points. An enumerated or sampled point is classified from its float64
  value, whose error is at most tau for any summation order (tau is a
  forward error bound for the whole cube: Higham's gamma terms plus the
  underflow of every product, propagated layer by layer; no absolute floor,
  so tau scales with the net). Points with |f_float - t| <= tau, and points
  whose float value is not finite, are re-evaluated in exact rational
  arithmetic. So the counts F are exact for the exact-arithmetic net, and
  sampled indicators are exact.
* Sampling. Exact uniform draws from the open union (a uniform integer
  below Z by rejection, then the leaf containing it), indicator of failure
  in {0, 1}, Hoeffding-KL interval at level delta (stats.kl_interval): the
  only randomness, so Pr[p not in output] <= delta.

None of this uses training or any property of the weights; any finite
float64 weights are accepted (non-finite weights or threshold raise
ValueError: then f is not a real function).

The prover
----------
`prove` builds such a tree breadth first: at each node it tries 'lin' with
default slopes, then slopes optimised by projected supergradient ascent on
the bound (only where the default bound is within `opt_window` standard
deviations of t), 'lin' for FAIL, then 'quad' (Adam on a smoothed
eigenvalue objective) for nodes whose 'lin' bound is within a window of t;
it splits the remaining nodes on the coordinate chosen by strong branching
(largest worse-child bound among the top-k coordinates by influence on the
unstable units), stops at r <= r_leaf (ENUM), and finally replaces every
subtree whose verification costs more than enumerating its subcube by ENUM.
With open_policy="auto" (or "both") it then turns failure-containing
subtrees into OPEN leaves, top down, wherever sampling them (to ratio
1 + eps) is cheaper than verifying them. The prover's search uses plain
floating point; it accepts a leaf only if the rigorous check clears t by
2^-30 |f|_abs, and checks 'quad' certificates exactly as the verifier will,
so that its certificates survive the verifier's differently batched (and so
differently rounded) recomputation.
`knuth_estimate` estimates the size and cost of the prover's tree from
random root-to-leaf probes; `witness_lower_bound` checks a list of failing
points (lower bounds need no deduction).

Costs are counted in floating-point operations of the verifier as
implemented (matrix products; every leaf recomputes its first-layer offsets)
and reported in forward-pass equivalents (fpe): flops / flops of one
evaluation of the net. `verify` also reports its wall-clock time and the
number of exact rational re-evaluations of points.
"""

from __future__ import annotations

import math
import time
from dataclasses import dataclass, field
from fractions import Fraction

import numpy as np

from .nets import MLP
from .stats import kl_interval

U53 = 2.0 ** -53  # unit roundoff of binary64, rounding to nearest
ETA = 2.0 ** -1074  # smallest positive float; one rounding below 2^-1022 errs by at most ETA / 2

# leaf / node codes of the serialised tree
SPLIT, SAFE, FAIL, ENUM, OPEN = "split", "safe", "fail", "enum", "open"
_DEBUG = False


# ---------------------------------------------------------------------------
# outward rounding
#
# Two facts about IEEE binary64 with rounding to nearest (gradual underflow
# included) make every enclosure below rigorous:
#  (R1) one operation +, -, *, / or sqrt of floats whose computed result r is
#       not NaN has its exact result in [nextafter(r, -inf), nextafter(r, inf)]
#       (also when r overflowed to +-inf, and in the subnormal range);
#  (R2) a matrix product C = fl(A @ B) of floats with inner dimension n,
#       computed by the classical algorithm in any summation order, with or
#       without fused multiply-adds, satisfies |C - A B| <= g_n |A||B| + n ETA
#       entrywise (Higham, Lemma 3.5, with the underflow model
#       fl(x op y) = (x op y)(1 + d) + e, |d| <= u, |e| <= ETA / 2, e = 0 for
#       + and -), where g_n >= n u / (1 - n u); and E = fl(|A| @ |B|) bounds
#       |A||B| <= (E + n ETA) / (1 - g_n) <= E (1 + 2 g_n) + 2 n ETA.
# Sums of floats are the case of (R2) without products (no underflow term).
# Non-finite values propagate (NaN compares false, infinities stay infinite)
# and every certificate whose final bound is not finite is rejected.


def _dn(x):
    return np.nextafter(x, -np.inf)


def _up(x):
    return np.nextafter(x, np.inf)


def _gam(n: int) -> float:
    """A float >= gamma_n = n u / (1 - n u) for n < 2^40 (exactly n (1 + 2^-12) u)."""
    return (n + n / 4096.0) * U53


def _cg(n: int) -> float:
    """A float >= 1 + 2 gamma_n >= 1 / (1 - gamma_n)."""
    return math.nextafter(1.0 + 2.0 * _gam(n), math.inf)


def _midrad(lo, hi):
    """A midpoint and a radius with [lo, hi] inside [mid - rad, mid + rad]."""
    mid = 0.5 * lo + 0.5 * hi
    return mid, np.maximum(_up(hi - mid), _up(mid - lo))


def _imm_pt(Am, Ar, B, Babs):
    """Enclosure (lo, hi) of every A @ B with |A - Am| <= Ar (entrywise; Ar
    None: A = Am) and B exact (Babs = |B|). By (R2):
    |A B - fl(Am B)| <= g_n |Am||B| + n ETA + Ar |B| <= V |B| + n ETA with
    V = up(g_n |Am| + Ar)."""
    n = Am.shape[-1]
    C = Am @ B
    V = _up(_gam(n) * np.abs(Am))
    if Ar is not None:
        V = _up(V + Ar)
    R = _up(_up((V @ Babs) * _cg(n)) + 3 * n * ETA)
    return _dn(C - R), _up(C + R)


def _imm_iv(Am, Ar, Bm, Br):
    """Enclosure (lo, hi) of every A @ B with |A - Am| <= Ar, |B - Bm| <= Br:
    |A B - fl(Am Bm)| <= (g_n |Am| + Ar)(|Bm| + Br) + |Am| Br + n ETA."""
    n = Am.shape[-1]
    cg = _cg(n)
    C = Am @ Bm
    Aabs = np.abs(Am)
    V = _up(_up(_gam(n) * Aabs) + Ar)
    Bb = _up(np.abs(Bm) + Br)
    R = _up(_up(_up((V @ Bb) * cg) + _up((Aabs @ Br) * cg)) + 5 * n * ETA)
    return _dn(C - R), _up(C + R)


def _mul_iv(alo, ahi, blo, bhi):
    """Elementwise enclosure of the products of [alo, ahi] and [blo, bhi]."""
    p1, p2, p3, p4 = alo * blo, alo * bhi, ahi * blo, ahi * bhi
    lo = np.minimum(np.minimum(p1, p2), np.minimum(p3, p4))
    hi = np.maximum(np.maximum(p1, p2), np.maximum(p3, p4))
    return _dn(lo), _up(hi)


def _sum_lo(T):
    """A float <= the exact sum of the floats T over the last axis, for any
    summation order: |fl(sum) - sum| <= gamma_n sum|T| <= 2 g_n fl(sum|T|)."""
    n = T.shape[-1]
    s = T.sum(-1)
    E = np.abs(T).sum(-1)
    return _dn(s - _up(_up(E * (2.0 * _gam(n))) + 3 * n * ETA))


def _mv_up(Aabs, x):
    """A float array >= the exact Aabs @ x (Aabs, x >= 0)."""
    n = Aabs.shape[-1]
    return _up(_up((Aabs @ x) * _cg(n)) + 2 * n * ETA)


def _poly_iv(k, b, z):
    """Enclosure of k z^2 + b z (floats; k >= 0)."""
    zz_lo, zz_hi = _dn(z * z), _up(z * z)
    lo = _dn(_dn(k * zz_lo) + _dn(b * z))
    hi = _up(_up(k * zz_hi) + _up(b * z))
    return lo, hi


def _round_down(q: Fraction) -> float:
    """The greatest float64 <= q (-inf if there is none)."""
    try:
        x = float(q)
    except OverflowError:
        return -math.inf if q < 0 else np.finfo(float).max
    while math.isfinite(x) and Fraction(x) > q:  # stepping below -FMAX gives -inf: correct
        x = math.nextafter(x, -math.inf)
    return x


def _round_up(q: Fraction) -> float:
    """The least float64 >= q (inf if there is none)."""
    try:
        x = float(q)
    except OverflowError:
        return math.inf if q > 0 else -np.finfo(float).max
    while math.isfinite(x) and Fraction(x) < q:  # stepping above FMAX gives inf: correct
        x = math.nextafter(x, math.inf)
    return x


def _subcube(root, d: int) -> np.ndarray:
    """A subcube vector in {-1, 0, +1}^d (int8), validated BEFORE the cast
    (a cast first would truncate, e.g. 0.6 to 0)."""
    if root is None:
        return np.zeros(d, dtype=np.int8)
    r = np.asarray(root, dtype=np.float64)
    if r.shape != (d,) or not np.all((r == -1.0) | (r == 0.0) | (r == 1.0)):
        raise ValueError("root must be a vector in {-1, 0, +1}^d")
    return r.astype(np.int8)


def _cholesky_ok(A: np.ndarray) -> bool:
    """Textbook Cholesky (inner products in any order, then one division /
    one square root per entry). True iff it runs to completion with
    positive finite pivots."""
    n = A.shape[0]
    R = np.zeros_like(A)
    for j in range(n):
        s = A[j, j] - R[:j, j] @ R[:j, j]
        if not (s > 0.0) or not math.isfinite(s):
            return False
        rjj = math.sqrt(s)
        R[j, j] = rjj
        if j + 1 < n:
            R[j, j + 1:] = (A[j, j + 1:] - R[:j, j] @ R[:j, j + 1:]) / rjj
            if not np.isfinite(R[j, j + 1:]).all():
                return False
    return True


def _psd_box(Alo: np.ndarray, Ahi: np.ndarray) -> bool:
    """True only if every symmetric matrix A with Alo <= A <= Ahi (entrywise;
    Alo, Ahi symmetric) is positive semidefinite.

    With mid, rad the midpoint-radius form, scaled exactly by a power of two
    so that the largest entry is about 1 (PSD is invariant under positive
    scaling; the scaling rounds only below 2^-1022, by at most ETA / 2, which
    is added to rad): every such A is mid + D with ||D||_2 <= ||rad||_F =: fr.
    Cholesky of Af = fl(mid - c I) runs to completion => R^T R = Af + dA with
    |dA| <= g_{n+1} |R^T||R| + uf (Higham, Thm 10.3; uf = (2n + 4 rmax) ETA
    for the underflow of products and divisions, rmax >= max r_jj), hence
    lambda_min(Af) >= -h, h = g (1 + 2g)(tr Af + n uf) + n uf. Forming Af
    errs on the diagonal by at most ed = 2u max|Af_ii|. So A >= (c - h - ed -
    fr) I, and we check c >= h + ed + fr with every term rounded up."""
    n = Alo.shape[0]
    if not (np.isfinite(Alo).all() and np.isfinite(Ahi).all()):
        return False
    mid, rad = _midrad(Alo, Ahi)
    top = max(float(np.abs(mid).max()), float(rad.max()))
    if not math.isfinite(top):
        return False
    if top == 0.0:
        return True
    e = math.frexp(top)[1]
    mid = np.ldexp(mid, -e)
    rad = _up(_up(np.ldexp(rad, -e)) + ETA)
    sq = _up(rad * rad)
    fr = float(_up(math.sqrt(float(_mv_up(sq.reshape(1, -1), np.ones(n * n))[0]))))
    g = _gam(n + 1)
    dmax = float(np.abs(np.diag(mid)).max())
    c_try = 2.0 * (fr + 4.0 * g * (n * dmax + 1.0)) + 64.0 * n * n * ETA
    for _ in range(2):
        Af = mid - c_try * np.eye(n)
        if not _cholesky_ok(Af):
            return False
        dA = np.diag(Af)
        amax = float(np.abs(dA).max())
        tr = float(-_sum_lo(-dA.reshape(1, -1))[0])  # >= exact trace of Af
        rmax = 2.0 * max(1.0, amax)
        uf = float(_up((2 * n + 4 * rmax) * ETA))
        h = float(_up(_up(_up(g * _cg(n + 1)) * _up(max(tr, 0.0) + n * uf)) + n * uf))
        ed = float(_up(2.0 * U53 * amax))
        need = float(_up(_up(h + ed) + fr))
        if c_try >= need:
            return True
        c_try = 2.0 * need  # retry once with a larger shift
    return False


# ---------------------------------------------------------------------------
# the net, as seen by the verifier


class CertNet:
    """Float arrays of an MLP plus everything the verifier needs once."""

    def __init__(self, net: MLP):
        self.Ws = [np.ascontiguousarray(np.asarray(W, dtype=np.float64)) for W in net.Ws]
        self.bs = [np.ascontiguousarray(np.asarray(b, dtype=np.float64).ravel()) for b in net.bs]
        if not all(np.isfinite(W).all() for W in self.Ws) or not all(np.isfinite(b).all() for b in self.bs):
            raise ValueError("non-finite weights")
        if self.Ws[-1].shape[0] != 1:
            raise ValueError("scalar output expected")
        self.absW = [np.abs(W) for W in self.Ws]
        self.absb = [np.abs(b) for b in self.bs]
        self.t = float(net.threshold)
        if not math.isfinite(self.t):
            raise ValueError("non-finite threshold")
        self.d = self.Ws[0].shape[1]
        self.L = len(self.Ws) - 1
        self.widths = [W.shape[0] for W in self.Ws[:-1]]
        dims = [self.d] + self.widths + [1]
        # [W_k | b_k] for the backward passes, and the first layer transposed
        self.We = [np.ascontiguousarray(np.concatenate([W, b[:, None]], 1)) for W, b in zip(self.Ws, self.bs)]
        self.Weabs = [np.abs(W) for W in self.We]
        self.W1T = np.ascontiguousarray(self.Ws[0].T)
        self.absW1T = np.abs(self.W1T)
        # products x0_i W_ji with x0 in {-1, 0, 1} are exact, so the offsets
        # c = W_1 x0 + b_1 and the radii err by at most g_{d+1} ||[W_1 b_1]_j||_1
        with np.errstate(all="ignore"):
            row1 = _mv_up(self.Weabs[0], np.ones(self.d + 1))
            self.err1 = _up(_up(_gam(self.d + 1) * row1) + 3 * (self.d + 1) * ETA)
        # forward error bound for points: |f_float(x) - f(x)| <= tau_pt on the
        # whole cube, any summation order (also the split sums of enum_count)
        rho = np.ones(self.d)  # >= |h_k(x)|
        err = np.zeros(self.d)  # >= |h_k computed - h_k exact|
        with np.errstate(all="ignore"):
            for k in range(self.L + 1):
                n = self.Ws[k].shape[1] + 3
                Wr = _mv_up(self.absW[k], _up(rho + err))
                err = _up(_up(_mv_up(self.absW[k], err) + _up(_gam(n) * _up(Wr + self.absb[k]))) + 3 * n * ETA)
                rho = _up(_mv_up(self.absW[k], rho) + self.absb[k])
        self.absf = float(rho[0])
        self.tau_pt = float(err[0])
        if math.isfinite(self.tau_pt):
            T, tau = Fraction(self.t), Fraction(self.tau_pt)
            self.pt_fail = _round_down(T - tau)  # f_float < this  => f < t exactly
            self.pt_safe = _round_up(T + tau)  # f_float >= this => f >= t exactly
        else:  # every point is re-evaluated exactly
            self.pt_fail, self.pt_safe = -math.inf, math.inf
        self.fpe_flops = 2.0 * sum(a * b for a, b in zip(dims[:-1], dims[1:]))
        self._exact = None
        self.n_exact_evals = 0

    # ---- point evaluation ---------------------------------------------------
    def forward(self, X: np.ndarray) -> np.ndarray:
        h = np.asarray(X, dtype=np.float64)
        with np.errstate(all="ignore"):
            for W, b in zip(self.Ws[:-1], self.bs[:-1]):
                h = np.maximum(h @ W.T + b, 0.0)
            return (h @ self.Ws[-1].T + self.bs[-1])[..., 0]

    def exact_f(self, x) -> Fraction:
        """f(x) in exact rational arithmetic (x in {-1,+1}^d)."""
        if self._exact is None:
            self._exact = ([[[Fraction(float(v)) for v in row] for row in W] for W in self.Ws],
                           [[Fraction(float(v)) for v in b] for b in self.bs])
        Wf, bf = self._exact
        self.n_exact_evals += 1
        h = [int(v) for v in x]
        for k in range(self.L + 1):
            z = []
            for row, b in zip(Wf[k], bf[k]):
                s = b
                if k == 0:
                    for w, xi in zip(row, h):
                        s = s + w if xi > 0 else s - w
                else:
                    for w, hi in zip(row, h):
                        if hi:
                            s += w * hi
                z.append(s)
            h = [v if v > 0 else 0 for v in z] if k < self.L else z
        return h[0]

    def _ambiguous(self, fvals: np.ndarray):
        """Sure failures (count) and the indices that need exact evaluation
        (|f_float - t| <= tau or f_float not finite). A value that is not
        finite decides nothing, whatever the thresholds (with tau = inf the
        thresholds are -inf and +inf, and inf >= inf would otherwise read an
        overflowed output as safe)."""
        fin = np.isfinite(fvals)
        sure_fail = fin & (fvals < self.pt_fail)
        sure_safe = fin & (fvals >= self.pt_safe)
        return int(np.count_nonzero(sure_fail)), np.nonzero(~(sure_fail | sure_safe))[0]

    def classify(self, X: np.ndarray, fvals: np.ndarray) -> int:
        """Exact number of failing points among the rows of X, given their
        float64 values fvals (computed in any summation order)."""
        fails, amb = self._ambiguous(fvals)
        T = Fraction(self.t)
        for i in amb:
            if self.exact_f(X[i]) < T:
                fails += 1
        return fails

    # ---- cost model (flops of the implementation) ------------------------------
    def flops_point_enum(self) -> float:
        """Per enumerated point in a meet-in-the-middle sweep: one addition of
        the two first-layer half tables, the ReLUs, the later layers."""
        m = self.widths
        f = 2.0 * m[0]
        for a, b in zip(m[:-1], m[1:]):
            f += 2.0 * a * b + b
        return f + 2.0 * m[-1]

    def flops_enum(self, r: int) -> float:
        r1 = r // 2
        r2 = r - r1
        tables = 2.0 * self.widths[0] * (self.d + r1 * 2 ** r1 + r2 * 2 ** r2)
        return tables + (2.0 ** r) * self.flops_point_enum()

    def flops_node(self) -> float:
        """Parsing one node (copying its subcube vector)."""
        return float(self.d)

    def _flops_back(self, R: int, k0: int, stop_h1: bool = False) -> float:
        """One interval backward pass of R rows from h_k0: two matrix products
        (value and error bound) per layer."""
        dims = [self.d] + self.widths
        return sum(4.0 * R * dims[k] * (dims[k - 1] + 1) for k in range(k0, 1 if stop_h1 else 0, -1))

    def flops_lin(self, r: int = 0) -> float:
        """One 'lin' check as implemented (the free inputs do not matter: the
        first-layer offsets and radii are recomputed for every subcube): two
        products for the first layer, 2 m_k backward rows for every hidden
        layer k >= 2 (intermediate bounds), and the output pass."""
        f = 4.0 * self.d * self.widths[0]
        for k in range(2, self.L + 1):
            f += self._flops_back(2 * self.widths[k - 1], k - 1)
        return f + self._flops_back(1, self.L)

    def flops_quad(self, r: int) -> float:
        """'lin' up to h_1, the interval matrix M ((r+1) x (r+1)), its
        PSD test (Cholesky)."""
        n = r + 1
        m1 = self.widths[0]
        f = 4.0 * self.d * m1
        for k in range(2, self.L + 1):
            f += self._flops_back(2 * self.widths[k - 1], k - 1)
        f += self._flops_back(1, self.L, stop_h1=True)
        return f + 8.0 * m1 * n + 6.0 * m1 * n * n + 6.0 * m1 * n + n ** 3 / 3.0 + 20.0 * n * n

    # ---- interval bounds over subcubes ------------------------------------------
    def layer1(self, X0: np.ndarray):
        """X0: (B, d) in {-1, 0, +1} (0 = free). Returns enclosures (clo, chi)
        of the offsets c = W_1 x0 + b_1 and (L1, U1) of z_1 over each subcube."""
        X0 = np.asarray(X0, dtype=np.float64)
        if not np.all((X0 == 0.0) | (X0 == 1.0) | (X0 == -1.0)):
            raise ValueError("subcubes must be vectors in {-1, 0, +1}^d")  # (the error bound needs exact products)
        F = (X0 == 0.0).astype(np.float64)
        with np.errstate(all="ignore"):  # overflow gives infinite enclosures: undecided
            c = X0 @ self.W1T + self.bs[0]
            rad = F @ self.absW1T
            clo, chi = _dn(c - self.err1), _up(c + self.err1)
            radhi = _up(rad + self.err1)
            return clo, chi, _dn(clo - radhi), _up(chi + radhi)

    def intervals(self, X0: np.ndarray):
        """Enclosures [L_k, U_k] of every hidden pre-activation over each
        subcube; layers >= 2 by backward bound propagation with the verifier's
        own (adaptive) slopes. Also returns the layer-1 offsets (clo, chi)."""
        X0 = np.asarray(X0, dtype=np.float64)
        clo, chi, L1, U1 = self.layer1(X0)
        ivs = [(L1, U1)]
        for k in range(2, self.L + 1):
            m = self.widths[k - 1]
            G0 = np.concatenate([self.Ws[k - 1], -self.Ws[k - 1]], 0)
            b0 = np.concatenate([self.bs[k - 1], -self.bs[k - 1]])
            lb = self._backward(X0, G0, b0, k - 1, ivs, None)
            ivs.append((lb[:, :m], -lb[:, m:]))
        return ivs, clo, chi

    def _backward(self, X0, G0, b0, k0, ivs, alphas, stop_h1=False):
        """Rigorous lower bound, over each subcube (rows of X0), of
        G0[r] . h_k0(x) + b0[r] for every row r of the exact G0 (R, m_k0),
        b0 (R,) (h_k = relu(z_k), k0 >= 1). alphas: None or a list over hidden
        layers (index k - 1 for layer k) of (B, m_k) slopes or None.
        Returns lb (B, R); with stop_h1, returns (Glo, Ghi, parts): the
        enclosure (B, R, m_1) of the coefficient on h_1 and the lower bounds
        (B, R, *) whose sum bounds the constant from below."""
        B = X0.shape[0]
        R, m = G0.shape
        Glo = Ghi = np.broadcast_to(G0, (B, R, m))
        parts = [np.broadcast_to(np.asarray(b0, dtype=np.float64)[None, :, None], (B, R, 1))]
        with np.errstate(all="ignore"):
            for k in range(k0, 0, -1):
                if stop_h1 and k == 1:
                    return Glo, Ghi, parts
                Lk, Uk = ivs[k - 1]
                al = None if alphas is None else alphas[k - 1]
                Llo, Lhi, cst = _relax(Glo, Ghi, Lk, Uk, al)
                parts.append(cst)
                mid, rad = _midrad(Llo, Lhi)
                mk = mid.shape[-1]
                lo, hi = _imm_pt(mid.reshape(-1, mk), rad.reshape(-1, mk), self.We[k - 1], self.Weabs[k - 1])
                lo = lo.reshape(B, R, -1)
                hi = hi.reshape(B, R, -1)
                parts.append(lo[..., -1:])  # >= Lambda . b_k
                Glo, Ghi = lo[..., :-1], hi[..., :-1]
            # the coefficient on x, minimised over the subcube
            X = np.asarray(X0, dtype=np.float64)[:, None, :]
            T = np.where(X == 1.0, Glo, np.where(X == -1.0, -Ghi, -np.maximum(np.abs(Glo), np.abs(Ghi))))
            parts.append(T)
            return _sum_lo(np.concatenate([np.broadcast_to(p, (B, R, p.shape[-1])) for p in parts], -1))

    # ---- certificate checks ----------------------------------------------------------
    def check_lin(self, X0: np.ndarray, alphas, sign: int, ivs=None):
        """Rigorous lower bound of sign * f over each subcube with the given
        slopes. Returns an array of floats (B,) (-inf where not finite)."""
        X0 = np.asarray(X0, dtype=np.float64)
        if ivs is None:
            ivs, _, _ = self.intervals(X0)
        lb = self._backward(X0, sign * self.Ws[-1], sign * self.bs[-1], self.L, ivs, alphas)[:, 0]
        return np.where(np.isfinite(lb), lb, -np.inf)

    def quad_matrix(self, x0: np.ndarray, alphas, theta, sign: int = 1, ivs=None, cdat=None):
        """Entrywise enclosure (Mlo, Mhi) of a symmetric matrix M (n x n,
        n = r + 1) with Y^T M Y <= sign * f on the subcube x0 (Y = (free
        coordinates, 1)), built from the prover's theta exactly as the
        verifier builds it. cdat: the subcube's layer-1 offsets (clo, chi)."""
        x0 = np.asarray(x0, dtype=np.float64).reshape(1, -1)
        free = np.nonzero(x0[0] == 0.0)[0]
        m1 = self.widths[0]
        theta = np.asarray(theta, dtype=np.float64)
        if theta.shape != (m1, 2):
            raise ValueError("theta: wrong shape")
        theta = np.clip(np.nan_to_num(theta, nan=0.0), 0.0, 1.0)
        if ivs is None:
            ivs, clo, chi = self.intervals(x0)
        else:
            clo, chi = cdat
        Glo, Ghi, parts = self._backward(x0, sign * self.Ws[-1], sign * self.bs[-1], self.L, ivs, alphas,
                                         stop_h1=True)
        Glo, Ghi = Glo[0, 0], Ghi[0, 0]
        const = _sum_lo(np.concatenate([np.broadcast_to(p, (1, 1, p.shape[-1])) for p in parts], -1))[0, 0]
        L1, U1 = ivs[0][0][0], ivs[0][1][0]
        with np.errstate(all="ignore"):
            kap, bet, gam, charge = _quad_coeffs(Glo, Ghi, L1, U1, theta)
            Dlo, Dhi = _mul_iv(Glo, Ghi, kap, kap)
            Blo, Bhi = _mul_iv(Glo, Ghi, bet, bet)
            Clo, _ = _mul_iv(Glo, Ghi, gam, gam)
            # sign * f >= Y^T M Y with M = sum_j D_j v_j v_j^T + (linear terms) + const e_n e_n^T,
            # v_j = (W_1[j, free], c_j); const is a float lower bound, used as an exact number
            const = float(_sum_lo(np.concatenate([[const], Clo, charge]).reshape(1, -1))[0])
            Vlo = np.concatenate([self.Ws[0][:, free], clo[0][:, None]], 1)
            Vhi = np.concatenate([self.Ws[0][:, free], chi[0][:, None]], 1)
            Plo, Phi = _mul_iv(Vlo, Vhi, Dlo[:, None], Dhi[:, None])
            Vm, Vr = _midrad(Vlo, Vhi)
            Pm, Pr = _midrad(Plo, Phi)
            Mlo, Mhi = _imm_iv(Vm.T, Vr.T, Pm, Pr)
            Bm, Br = _midrad(Blo, Bhi)
            llo, lhi = _imm_iv(Vm.T, Vr.T, Bm[:, None], Br[:, None])
            llo, lhi = llo[:, 0], lhi[:, 0]
            hlo, hhi = _dn(0.5 * llo[:-1]), _up(0.5 * lhi[:-1])
            Mlo[:-1, -1] = _dn(Mlo[:-1, -1] + hlo)
            Mhi[:-1, -1] = _up(Mhi[:-1, -1] + hhi)
            Mlo[-1, :-1] = _dn(Mlo[-1, :-1] + hlo)
            Mhi[-1, :-1] = _up(Mhi[-1, :-1] + hhi)
            Mlo[-1, -1] = _dn(_dn(Mlo[-1, -1] + llo[-1]) + const)
            Mhi[-1, -1] = _up(_up(Mhi[-1, -1] + lhi[-1]) + const)
        # M is symmetric: both enclosures of an entry hold
        return np.maximum(Mlo, Mlo.T), np.minimum(Mhi, Mhi.T)

    def check_quad(self, x0: np.ndarray, alphas, theta, mu, shift, sign: int = 1, ivs=None, cdat=None):
        """Rigorous lower bound of sign * f over one subcube from a 'quad'
        certificate, or -inf if the PSD check fails or anything is
        malformed or not finite."""
        x0 = np.asarray(x0, dtype=np.float64).reshape(1, -1)
        n = int((x0[0] == 0.0).sum()) + 1
        try:
            mu = np.asarray(mu, dtype=np.float64).ravel()
            shift = float(shift)
        except (TypeError, ValueError):
            return -math.inf
        if mu.shape != (n,) or not np.isfinite(mu).all() or not math.isfinite(shift):
            return -math.inf
        try:
            Mlo, Mhi = self.quad_matrix(x0, alphas, theta, sign, ivs, cdat)
        except ValueError:
            return -math.inf
        with np.errstate(all="ignore"):
            Alo, Ahi = Mlo.copy(), Mhi.copy()
            idx = np.arange(n)
            Alo[idx, idx] = _dn(_dn(np.diag(Mlo) - mu) - shift)
            Ahi[idx, idx] = _up(_up(np.diag(Mhi) - mu) - shift)
            if not _psd_box(Alo, Ahi):
                return -math.inf
            lb = float(_sum_lo(np.concatenate([mu, [_dn(n * shift)]]).reshape(1, -1))[0])
        return lb if math.isfinite(lb) else -math.inf

    # ---- enumeration -----------------------------------------------------------------
    def enum_count(self, x0: np.ndarray, chunk: int = 1 << 18) -> int:
        """Exact number of failing points in the subcube x0 (meet in the
        middle over its free coordinates)."""
        x0 = np.asarray(x0, dtype=np.float64)
        free = np.nonzero(x0 == 0.0)[0]
        r = len(free)
        r1 = r // 2
        fa, fb = free[:r1], free[r1:]
        Ya = _half(len(fa))
        Yb = _half(len(fb))
        T = Fraction(self.t)
        fails = 0
        with np.errstate(all="ignore"):
            base = self.Ws[0] @ x0 + self.bs[0]
            A = Ya @ self.Ws[0][:, fa].T + base  # (2^r1, m1)
            Bt = Yb @ self.Ws[0][:, fb].T  # (2^r2, m1)
            rows = max(1, chunk // Bt.shape[0])
            for s in range(0, A.shape[0], rows):
                Z = (A[s:s + rows, None, :] + Bt[None, :, :]).reshape(-1, A.shape[1])
                h = np.maximum(Z, 0.0)
                for W, b in zip(self.Ws[1:-1], self.bs[1:-1]):
                    h = np.maximum(h @ W.T + b, 0.0)
                fv = (h @ self.Ws[-1].T + self.bs[-1])[:, 0]
                nf, amb = self._ambiguous(fv)
                nb = Bt.shape[0]
                for i in amb:
                    ia, ib = s + i // nb, i % nb
                    x = x0.copy()
                    x[fa] = Ya[ia]
                    x[fb] = Yb[ib]
                    if self.exact_f(x) < T:
                        nf += 1
                fails += nf
        return fails

    def enum_points(self, x0: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
        """All points of the subcube and their float values (prover side)."""
        x0 = np.asarray(x0, dtype=np.float64)
        free = np.nonzero(x0 == 0.0)[0]
        Y = _half(len(free))
        X = np.repeat(x0[None], Y.shape[0], 0)
        X[:, free] = Y
        return X, self.forward(X)


def _half(k: int) -> np.ndarray:
    idx = np.arange(1 << k, dtype=np.int64)
    return np.where((idx[:, None] >> np.arange(k)) & 1, 1.0, -1.0)


def _relax(Glo, Ghi, L, U, alpha):
    """Linear relaxation of h = relu(z), z in [L, U] ((B, m) enclosures), for
    an exact coefficient G in [Glo, Ghi] ((B, R, m)): returns the enclosure
    (Llo, Lhi) of a coefficient Lambda and lower bounds cst (B, R, m) with
    G h >= Lambda z + cst for every z in [L, U]:
      active (L >= 0): Lambda = G;  inactive (U <= 0): Lambda = 0;
      unstable, G >= 0 surely: relu(z) >= a z, a in [0, 1] (alpha, clipped);
      unstable, G <= 0 surely: relu(z) <= lam (z - L), lam = up(U / dn(U - L))
        >= U / (U - L); cst = Lambda (-L);
      unstable, sign of G unknown: Lambda = 0, cst = Glo U (0 <= h <= U)."""
    L = L[:, None, :]
    U = U[:, None, :]
    act = L >= 0.0
    ina = U <= 0.0
    uns = ~(act | ina)
    pos = Glo >= 0.0
    neg = (Ghi <= 0.0) & ~pos
    known = uns & (pos | neg)
    if alpha is None:
        a = (U >= -L).astype(np.float64)
    else:
        a = np.clip(np.nan_to_num(np.asarray(alpha, dtype=np.float64), nan=0.0), 0.0, 1.0)[:, None, :]
    lam = _up(U / _dn(U - L))
    s = np.where(pos, a, lam)
    Llo = np.where(act, Glo, np.where(known, _dn(Glo * s), 0.0))
    Lhi = np.where(act, Ghi, np.where(known, _up(Ghi * s), 0.0))
    cst = np.where(uns & neg, _dn(Llo * -L), np.where(uns & ~(pos | neg), _dn(Glo * U), 0.0))
    return Llo, Lhi, cst


def _quad_coeffs(Glo, Ghi, L, U, theta):
    """Per first-layer unit j a quadratic q_j(z) = kap z^2 + bet z + gam with
    q_j <= relu on [L_j, U_j] if G_j >= 0 surely (minorant) and q_j >= relu
    there if G_j <= 0 surely (majorant), from the prover's theta_j = (s, rho)
    in [0, 1]^2:
      minorant  s (1 - rho) z + s rho z (z - L) / (U - L) (convex; the second
                term is the quadratic through (L, 0), (0, 0), (U, U));
      majorant  rho * (the convex quadratic through (L, 0) and (U, U) with
                curvature min(-L, U) / (U - L)^2) + (1 - rho) * chord.
    The verifier computes kap and bet from theta in floating point and then
    PROVES validity by interval evaluation, choosing gam as the best value
    for which the proof goes through (for k = kap >= 0):
      minorant: q(L) <= 0, q(0) <= 0, q(U) <= U  (convexity does the rest);
      majorant: q(L) >= 0, q'(L) >= 0, and [(q - z)(U) >= 0, (q - z)'(U) <= 0]
                or [(q - z)(0) >= 0, (q - z)'(0) >= 0].
    A unit whose proof fails gets an always-valid piece: 0 from below, the
    chord lam (z - L) from above. Active units get q = z, inactive ones
    q = 0; units whose G straddles 0 get q = 0 and the charge Glo U.
    Returns kap, bet, gam (floats, (m,)) and charge (lower bounds, (m,))."""
    m = L.shape[0]
    act = L >= 0.0
    ina = U <= 0.0
    uns = ~(act | ina)
    pos = uns & (Glo >= 0.0)
    neg = uns & (Ghi <= 0.0) & ~pos
    strad = uns & ~pos & ~neg
    kap = np.zeros(m)
    bet = np.where(act, 1.0, 0.0)
    gam = np.zeros(m)
    charge = np.where(strad, _dn(Glo * U), 0.0)
    s, rho = theta[:, 0], theta[:, 1]
    w = U - L
    # minorants
    k = s * rho / w
    b = s * (1.0 - rho) - s * rho * L / w
    _, PL = _poly_iv(k, b, L)
    _, PU = _poly_iv(k, b, U)
    g = np.minimum(0.0, np.minimum(-PL, -_up(PU - U)))
    ok = pos & (k >= 0.0) & np.isfinite(k) & np.isfinite(b) & np.isfinite(g)
    kap = np.where(ok, k, kap)
    bet = np.where(ok, b, bet)
    gam = np.where(ok, g, gam)
    # majorants
    K = np.minimum(-L, U) / (w * w)
    k = rho * K * (1.0 - 2.0 ** -20)
    bp = U / w - k * w
    b = bp - 2.0 * k * L
    PLlo, _ = _poly_iv(k, b, L)
    PUlo, _ = _poly_iv(k, b, U)
    dL = _dn(_dn(2.0 * k * L) + b)  # <= q'(L)
    dU = _up(_up(_up(2.0 * k * U) + b) - 1.0)  # >= (q - z)'(U)
    d0 = _dn(b - 1.0)  # <= (q - z)'(0)
    g_u = np.maximum(-PLlo, _up(U - PUlo))
    g_0 = np.maximum(-PLlo, 0.0)
    fin = (k >= 0.0) & np.isfinite(k) & np.isfinite(b) & (dL >= 0.0)
    ok_u = neg & fin & (dU <= 0.0) & np.isfinite(g_u)
    ok_0 = neg & fin & ~ok_u & (d0 >= 0.0) & np.isfinite(g_0)
    lam = _up(U / _dn(U - L))
    g_ch = _up(lam * -L)
    chord = neg & ~ok_u & ~ok_0
    kap = np.where(ok_u | ok_0, k, kap)
    bet = np.where(ok_u | ok_0, b, np.where(chord, lam, bet))
    gam = np.where(ok_u, g_u, np.where(ok_0, g_0, np.where(chord, g_ch, gam)))
    return kap, bet, gam, charge


# ---------------------------------------------------------------------------
# the verifier


@dataclass
class VerifyResult:
    lo: float  # p >= lo (with probability >= 1 - delta; surely if exact)
    hi: float
    exact: bool  # no open leaf: [lo, hi] is p itself (rounded outwards)
    F: int  # exact number of failing points in ENUM and FAIL leaves
    Z: int  # number of points in OPEN leaves (after demotions)
    n_samples: int = 0
    sample_fails: int = 0
    leaves: dict = field(default_factory=dict)  # leaf kind -> count (as accepted)
    demoted: int = 0  # leaves whose certificate failed (sampled instead)
    rejected: str | None = None  # whole argument rejected (output [0, 1])
    flops: dict = field(default_factory=dict)
    fpe: float = 0.0  # verifier cost in forward-pass equivalents
    seconds: float = 0.0  # wall-clock of the verifier
    exact_evals: int = 0  # points re-evaluated in rational arithmetic (not in fpe)
    arg_bytes: int = 0

    @property
    def ratio(self) -> float:
        return self.hi / self.lo if self.lo > 0 else (1.0 if self.hi == 0 else math.inf)

    def contains(self, p) -> bool:
        return self.lo <= p <= self.hi


def argument_bytes(arg) -> int:
    """Size of the deductive part of an argument: 1 byte per node kind,
    1 byte per split coordinate (2 for d > 255), 8 bytes per number."""
    n = 0
    for node in arg.get("tree", []):
        n += 1
        if node[0] == SPLIT:
            n += 1 if node[1] < 256 else 2
        elif node[0] in (SAFE, FAIL):
            cert = node[1]
            for key in ("alpha", "theta", "mu"):
                v = cert.get(key)
                if v is None:
                    continue
                if key == "alpha":
                    n += 8 * sum(0 if a is None else int(np.size(a)) for a in v)
                else:
                    n += 8 * int(np.size(v))
            if cert.get("kind") == "quad":
                n += 8
    return n + 8  # the sample budget


def _uniform_ints(rng: np.random.Generator, Z: int, N: int) -> list:
    """N exact uniform integers in [0, Z)."""
    if Z < 2 ** 62:
        return [int(v) for v in rng.integers(0, Z, size=N)]
    nb = Z.bit_length()
    nbytes = (nb + 7) // 8
    out = []
    while len(out) < N:
        v = int.from_bytes(rng.bytes(nbytes), "little") >> (8 * nbytes - nb)
        if v < Z:
            out.append(v)
    return out


def _norm_alphas(cn: CertNet, al, B: int = 1):
    """Normalise a certificate's slopes to the list format of _backward;
    raises ValueError if malformed."""
    if al is None:
        return None
    if not isinstance(al, (list, tuple)) or len(al) != cn.L:
        raise ValueError("alpha: one entry per hidden layer expected")
    out = []
    for k, a in enumerate(al):
        if a is None:
            out.append(None)
            continue
        a = np.asarray(a, dtype=np.float64).ravel()
        if a.shape != (cn.widths[k],):
            raise ValueError("alpha: wrong length")
        out.append(np.repeat(a[None], B, 0))
    return out


def verify(net, arg, delta: float = 0.05, rng: np.random.Generator | None = None,
           max_samples: int = 10 ** 8, chunk: int = 512, max_enum_r: int = 30, root=None) -> VerifyResult:
    """Check an argument and return the interval for p (see module docstring).

    Sound for every net and every argument: Pr[p not in [lo, hi]] <= delta
    (and p in [lo, hi] surely if the result is exact). Malformed trees give
    [0, 1]; failed leaf certificates are demoted to sampled leaves. The
    verifier's work is polynomial in the size of the argument: an ENUM leaf
    with more than max_enum_r free inputs is demoted to OPEN, and at most
    max_samples samples are drawn. With `root` (a subcube in {-1, 0, +1}^d)
    the argument is a partition of that subcube and the interval is for the
    failing fraction of the subcube."""
    t0 = time.time()
    cn = net if isinstance(net, CertNet) else CertNet(net)
    ev0 = cn.n_exact_evals
    rng = rng if rng is not None else np.random.default_rng()
    d = cn.d
    root = _subcube(root, d)
    total = 1 << int((root == 0).sum())
    flops = {"parse": 0.0, "lin": 0.0, "quad": 0.0, "enum": 0.0, "sample": 0.0}
    res = VerifyResult(0.0, 1.0, False, 0, 0, flops=flops)

    def done():
        res.exact_evals = cn.n_exact_evals - ev0
        res.seconds = time.time() - t0
        return res

    try:
        res.arg_bytes = argument_bytes(arg)
    except Exception:
        res.arg_bytes = -1
    # ---- parse the tree (preorder, child x_i = -1 first)
    tree = arg.get("tree") if isinstance(arg, dict) else None
    if not isinstance(tree, (list, tuple)) or len(tree) == 0:
        res.rejected = "no tree"
        return done()
    leaves = []  # (x0 int8 array, node)
    stack = [root]
    pos = 0
    try:
        while stack:
            x0 = stack.pop()
            if pos >= len(tree):
                raise ValueError("tree ends early")
            node = tree[pos]
            pos += 1
            kind = node[0]
            if kind == SPLIT:
                i = node[1]
                if not isinstance(i, (int, np.integer)) or isinstance(i, bool) or not 0 <= int(i) < d:
                    raise ValueError("bad split coordinate")
                i = int(i)
                if x0[i] != 0:
                    raise ValueError("split on a fixed coordinate")
                xm = x0.copy()
                xm[i] = -1
                xp = x0.copy()
                xp[i] = 1
                stack.append(xp)
                stack.append(xm)
            elif kind in (SAFE, FAIL, ENUM, OPEN):
                leaves.append((x0, node))
            else:
                raise ValueError("unknown node kind")
        if pos != len(tree):
            raise ValueError("trailing nodes")
    except Exception as e:  # malformed: no verdict
        res.rejected = f"malformed tree: {e}"
        return done()
    sizes = [1 << int((x0 == 0).sum()) for x0, _ in leaves]
    if sum(sizes) != total:  # cannot happen for a parsed binary trie
        res.rejected = "leaves do not partition the cube"
        return done()
    flops["parse"] = float(len(tree)) * cn.flops_node()
    # ---- leaf checks
    F = 0
    open_leaves = []
    counts = {SAFE: 0, FAIL: 0, ENUM: 0, OPEN: 0, "lin": 0, "quad": 0}
    lin_jobs = {}  # (sign, alpha-layout key) -> list of (index, x0, alphas)
    demoted = 0
    for idx, (x0, node) in enumerate(leaves):
        kind = node[0]
        r = int((x0 == 0).sum())
        if kind == ENUM and r > max_enum_r:
            demoted += 1
            open_leaves.append(x0)
            continue
        if kind == ENUM:
            flops["enum"] += cn.flops_enum(r)
            F += cn.enum_count(x0)
            counts[ENUM] += 1
            continue
        if kind == OPEN:
            open_leaves.append(x0)
            counts[OPEN] += 1
            continue
        sign = 1 if kind == SAFE else -1
        cert = node[1] if len(node) > 1 else None
        try:
            if not isinstance(cert, dict):
                raise ValueError("no certificate")
            ck = cert.get("kind")
            if ck == "lin":
                al = _norm_alphas(cn, cert.get("alpha"), 1)
                key = (sign, tuple(a is None for a in al) if al is not None else None)
                lin_jobs.setdefault(key, []).append((idx, x0, al))
                continue
            if ck == "quad":
                al = _norm_alphas(cn, cert.get("alpha"), 1)
                flops["quad"] += cn.flops_quad(r)
                lb = cn.check_quad(x0, al, cert.get("theta"), cert.get("mu"), cert.get("shift"), sign)
                ok = (lb >= cn.t) if sign == 1 else (lb > -cn.t)
                if ok:
                    counts[kind] += 1
                    counts["quad"] += 1
                    if kind == FAIL:
                        F += 1 << r
                    continue
                raise ValueError("quad certificate does not certify")
            raise ValueError("unknown certificate kind")
        except Exception:
            demoted += 1
            open_leaves.append(x0)
    # batched 'lin' checks (grouped by sign and slope layout)
    for (sign, _), jobs in lin_jobs.items():
        for s in range(0, len(jobs), chunk):
            part = jobs[s:s + chunk]
            X0 = np.array([x0 for _, x0, _ in part], dtype=np.float64)
            flops["lin"] += len(part) * cn.flops_lin()
            try:
                if part[0][2] is None:
                    al = None
                else:
                    al = [None if part[0][2][k] is None else np.concatenate([a[k] for _, _, a in part], 0)
                          for k in range(cn.L)]
                lb = cn.check_lin(X0, al, sign)
            except Exception:
                lb = np.full(len(part), -np.inf)
            for (idx, x0, _), v in zip(part, lb):
                kind = leaves[idx][1][0]
                ok = (v >= cn.t) if sign == 1 else (v > -cn.t)
                if ok:
                    counts[kind] += 1
                    counts["lin"] += 1
                    if kind == FAIL:
                        F += 1 << int((x0 == 0).sum())
                else:
                    demoted += 1
                    open_leaves.append(x0)
    res.F = F
    res.demoted = demoted
    res.leaves = counts
    Z = sum(1 << int((x0 == 0).sum()) for x0 in open_leaves)
    res.Z = Z
    # ---- sampling inside the open union
    if Z == 0:
        q = Fraction(F, total)
        res.lo, res.hi, res.exact = _round_down(q), _round_up(q), True
    else:
        N = int(arg.get("samples", 0)) if isinstance(arg.get("samples", 0), (int, np.integer)) else 0
        N = max(0, min(N, max_samples))
        if N == 0:
            res.lo = _round_down(Fraction(F, total))
            res.hi = min(1.0, _round_up(Fraction(F + Z, total)))
        else:
            OL = np.array(open_leaves, dtype=np.float64)
            fails = 0
            done_n = 0
            B = 1 << 16
            while done_n < N:
                k = min(B, N - done_n)
                X = _draw_open(rng, OL, Z, k)
                fails += cn.classify(X, cn.forward(X))
                done_n += k
            flops["sample"] = float(N) * cn.fpe_flops
            res.n_samples, res.sample_fails = N, fails
            l, u = kl_interval(fails / N, N, delta, rel_err=2.0 ** -51)
            res.lo = _round_down(Fraction(F, total) + Fraction(Z, total) * Fraction(l))
            res.hi = min(1.0, _round_up(Fraction(F, total) + Fraction(Z, total) * Fraction(u)))
    res.fpe = sum(flops.values()) / cn.fpe_flops
    return done()


def _draw_open(rng: np.random.Generator, OL: np.ndarray, Z: int, k: int) -> np.ndarray:
    """k exact uniform points of the union of the disjoint subcubes OL (rows
    in {-1, 0, +1}^d, 0 = free) of total size Z: a uniform integer u below Z,
    the leaf whose range [cum_l, cum_{l+1}) contains u, and the free
    coordinates (in increasing order) set to the bits of u - cum_l."""
    free = OL == 0.0
    sizes = free.sum(1)
    if Z < 2 ** 62:
        cum = np.concatenate([[0], np.cumsum(np.left_shift(np.int64(1), sizes.astype(np.int64)))])
        us = rng.integers(0, Z, size=k, dtype=np.int64)
        li = np.searchsorted(cum, us, side="right") - 1
        off = us - cum[li]
        X = OL[li].copy()
        fm = free[li]
        rank = np.cumsum(fm, axis=1) - 1
        bit = (off[:, None] >> np.where(fm, rank, 0)) & 1
        return np.where(fm, np.where(bit == 1, 1.0, -1.0), X)
    cum = [0]
    for s in sizes:
        cum.append(cum[-1] + (1 << int(s)))
    X = np.empty((k, OL.shape[1]))
    for j, u in enumerate(_uniform_ints(rng, Z, k)):
        lo, hi = 0, len(cum) - 1
        while hi - lo > 1:  # cum[lo] <= u < cum[hi]
            mid = (lo + hi) // 2
            if cum[mid] <= u:
                lo = mid
            else:
                hi = mid
        off = u - cum[lo]
        x = OL[lo].copy()
        fr = np.nonzero(free[lo])[0]
        x[fr] = [1.0 if (off >> b) & 1 else -1.0 for b in range(len(fr))]
        X[j] = x
    return X


# ---------------------------------------------------------------------------
# the prover (untrusted: everything it outputs is checked by `verify`)


@dataclass
class ProverConfig:
    kinds: tuple = ("lin", "quad")  # certificate kinds to try
    fail_leaves: bool = True  # also certify subcubes where every point fails
    r_leaf: int = 6  # nodes with r <= r_leaf that are not certified become ENUM leaves
    alpha_iters: int = 40  # supergradient steps for the slopes
    opt_window: float = math.inf  # optimise slopes only if the default bound is within opt_window * std(f) of t
    warm_start: bool = False  # start a child's slope ascent from its parent's optimised slopes
    cert_margin: float = 2.0 ** -30  # certify only with a margin cert_margin * |f|_abs (rounding differences
    # between the prover's batched checks and the verifier's may move a bound by ~1e-15 |f|_abs)
    quad_rmin: int = 5  # try 'quad' only on subcubes with at least this many free inputs
    quad_window: float = 3.0  # ... whose 'lin' bound is within quad_window * std(f) of t
    quad_iters: int = 300
    strong_k: int = 4  # strong branching over the top-k coordinates
    node_budget: int = 3_000_000  # when exceeded, the frontier becomes `budget_leaf` leaves
    budget_leaf: str = "enum"  # "enum" (exact certificate) or "open" (sampled)
    chunk: int = 2048
    collapse: bool = True  # replace a subtree by ENUM when that is cheaper to verify
    open_policy: str = "none"  # "none" (exact certificate), "auto" (sample where cheaper), "both"
    eps: float = 0.1  # target ratio 1 + eps for the sampled part (open_policy="auto")
    delta: float = 0.05
    seed: int = 0


@dataclass
class ProofInfo:
    nodes: int = 0
    leaves: dict = field(default_factory=dict)
    seconds: float = 0.0
    predicted_flops: float = 0.0
    predicted_fpe: float = 0.0
    fails_known: int | None = None  # prover's count of failing points (if it enumerated all)
    open_points: int = 0
    open_fails: int = 0
    depth_hist: dict = field(default_factory=dict)
    r_hist: dict = field(default_factory=dict)  # r -> number of certified leaves
    budget_hit: bool = False
    precollapse: dict = field(default_factory=dict)
    hybrid: object = None


def _uns_mask(L, U):
    return (L < 0.0) & (U > 0.0)


def _h1_coeffs(cn: CertNet, X0: np.ndarray, sign: int, ivs):
    """The prover's floating-point backward pass to h_1 with default slopes
    on layers >= 2: coefficients G (B, m1) and constant (B,)."""
    B = X0.shape[0]
    G = np.repeat(sign * cn.Ws[-1], B, 0)
    const = np.full(B, sign * float(cn.bs[-1][0]))
    with np.errstate(all="ignore"):
        for k in range(cn.L, 1, -1):
            Lk, Uk = ivs[k - 1]
            act = Lk >= 0.0
            uns = _uns_mask(Lk, Uk)
            lam = np.where(uns, Uk / np.where(uns, Uk - Lk, 1.0), 0.0)
            slope = np.where(act, 1.0, np.where(uns, np.where(G >= 0.0, (Uk >= -Lk).astype(float), lam), 0.0))
            const = const + (G * np.where(uns & (G < 0.0), -lam * Lk, 0.0)).sum(1)
            Lam = G * slope
            const = const + Lam @ cn.bs[k - 1]
            G = Lam @ cn.Ws[k - 1]
    return G, const


def _lin_float(cn: CertNet, X0: np.ndarray, sign: int, ivs, c, alpha1=None):
    """The prover's floating-point value of the 'lin' bound (default slopes
    on layers >= 2; alpha1 or the default on layer 1); c: layer-1 offsets."""
    G, const = _h1_coeffs(cn, X0, sign, ivs)
    L1, U1 = ivs[0]
    F = (X0 == 0.0).astype(np.float64)
    with np.errstate(all="ignore"):
        uns = _uns_mask(L1, U1)
        lam = np.where(uns, U1 / np.where(uns, U1 - L1, 1.0), 0.0)
        a = (U1 >= -L1).astype(np.float64) if alpha1 is None else alpha1
        slope = np.where(L1 >= 0.0, 1.0, np.where(uns, np.where(G >= 0.0, a, lam), 0.0))
        off = np.where(uns & (G < 0.0), -lam * L1, 0.0)
        Lam = G * slope
        g = Lam @ cn.Ws[0]
        return const + (G * off).sum(1) + (Lam * c).sum(1) - (np.abs(g) * F).sum(1)


def _opt_alpha(cn: CertNet, X0: np.ndarray, sign: int, ivs, c, iters: int, target: float | None = None,
               init=None):
    """Projected supergradient ascent (Adam) on the first-layer slopes of the
    lower bound of sign * f over each subcube (c: layer-1 offsets). Returns
    alpha (B, m1) and the (non-rigorous) bound values. With a target, a
    subcube leaves the ascent once its value exceeds the target by a small
    margin, or when, every 10 steps, its progress over the last 10 steps
    extrapolated to the remaining steps would not reach the target. init:
    starting slopes (B, m1), NaN rows for the default (the prover passes the
    parent's optimised slopes)."""
    G, const = _h1_coeffs(cn, X0, sign, ivs)
    L1, U1 = ivs[0]
    W1 = cn.Ws[0]
    F = (X0 == 0.0).astype(np.float64)
    with np.errstate(all="ignore"):
        act = L1 >= 0.0
        uns = _uns_mask(L1, U1)
        pos = uns & (G >= 0.0)
        neg = uns & (G < 0.0)
        lam = np.where(uns, U1 / np.where(uns, U1 - L1, 1.0), 0.0)
        base_slope = np.where(act, 1.0, np.where(neg, lam, 0.0))
        off = np.where(neg, -lam * L1, 0.0)
        const1 = const + (G * off).sum(1)
        alpha = np.where(pos, (U1 >= -L1).astype(np.float64), 0.0)
        if init is not None:
            alpha = np.where(pos & np.isfinite(init), np.clip(np.nan_to_num(init), 0.0, 1.0), alpha)
        # non-finite inputs (huge weights): such subcubes are not optimised
        bad = ~(np.isfinite(G).all(1) & np.isfinite(c).all(1) & np.isfinite(base_slope).all(1) & np.isfinite(const1))
        G, c, base_slope = (np.where(bad[:, None], 0.0, a) for a in (G, c, base_slope))
        const1 = np.where(bad, -np.inf, const1)

        def value(alpha, ix):
            slope = np.where(pos[ix], alpha, base_slope[ix])
            Lam1 = G[ix] * slope
            g = Lam1 @ W1
            val = const1[ix] + (Lam1 * c[ix]).sum(1) - (np.abs(g) * F[ix]).sum(1)
            return val, g

        ix = np.arange(X0.shape[0])
        best_val, g = value(alpha, ix)
        best = alpha.copy()
        m = np.zeros_like(alpha)
        v = np.zeros_like(alpha)
        lr = 0.1
        if target is not None:
            margin = 1e-6 * (abs(target) + np.abs(best_val[np.isfinite(best_val)]).max(initial=1.0))
        prev = best_val.copy()
        for it in range(1, iters + 1):
            if target is not None and it % 10 == 1 and it > 1:
                gain = best_val[ix] - prev[ix]
                keep = (best_val[ix] < target + margin) & (best_val[ix] + gain * (iters - it + 1) / 10.0 >= target)
                prev[ix] = best_val[ix]
                ix, g = ix[keep], g[keep]
                m, v = m[keep], v[keep]
                if ix.size == 0:
                    break
            a = alpha[ix]
            sg = np.sign(g) * F[ix]
            grad = np.where(pos[ix], G[ix] * (c[ix] - sg @ W1.T), 0.0)
            m = 0.9 * m + 0.1 * grad
            v = 0.999 * v + 0.001 * grad * grad
            step = lr * (m / (1 - 0.9 ** it)) / (np.sqrt(v / (1 - 0.999 ** it)) + 1e-12)
            a = np.clip(a + step, 0.0, 1.0)
            alpha[ix] = a
            val, g = value(a, ix)
            better = val > best_val[ix]
            best_val[ix[better]] = val[better]
            best[ix[better]] = a[better]
    return best, best_val


def _quad_family(G, L, U, th):
    """Batched prover-side version of the verifier's quadratic family
    (without the verifier's constant terms): kap, bet, gam (B, m) and their
    derivatives with respect to theta = (s, rho)."""
    act = L >= 0.0
    uns = _uns_mask(L, U)
    pos = uns & (G > 0.0)
    neg = uns & (G < 0.0)
    w = np.where(uns, U - L, 1.0)
    s, rho = th[..., 0], th[..., 1]
    kap = np.where(pos, s * rho / w, 0.0)
    bet = np.where(act, 1.0, np.where(pos, s * ((1 - rho) - rho * L / w), 0.0))
    gam = np.zeros_like(kap)
    dk = np.zeros(th.shape)
    db = np.zeros(th.shape)
    dg = np.zeros(th.shape)
    dk[..., 0] = np.where(pos, rho / w, 0.0)
    dk[..., 1] = np.where(pos, s / w, 0.0)
    db[..., 0] = np.where(pos, (1 - rho) - rho * L / w, 0.0)
    db[..., 1] = np.where(pos, s * (-1 - L / w), 0.0)
    K = np.where(uns, np.minimum(-L, U) / w ** 2, 0.0)
    kap = np.where(neg, rho * K, kap)
    bet = np.where(neg, U / w - rho * K * w - 2 * rho * K * L, bet)
    gam = np.where(neg, rho * K * L ** 2 - (U / w - rho * K * w) * L, gam)
    dk[..., 1] += np.where(neg, K, 0.0)
    db[..., 1] += np.where(neg, -K * w - 2 * K * L, 0.0)
    dg[..., 1] += np.where(neg, K * L ** 2 + K * w * L, 0.0)
    return kap, bet, gam, dk, db, dg


def _quad_shift(cn: CertNet, x0, theta, mu, sign, ivb, cdat):
    """The prover's shift for given theta and mu: the least eigenvalue of the
    centre of the verifier's enclosure of M - diag(mu), minus a few times the
    verifier's margin; retried with larger margins. Returns (shift, bound)."""
    Mlo, Mhi = cn.quad_matrix(x0, None, theta, sign, ivb, cdat)
    mid, rad = _midrad(Mlo, Mhi)
    A0 = mid - np.diag(mu)
    if not (np.isfinite(A0).all() and np.isfinite(rad).all()):
        return None, -math.inf
    lam = float(np.linalg.eigvalsh(A0)[0])
    n = A0.shape[0]
    with np.errstate(all="ignore"):
        scale = float(np.abs(A0).max()) + float(rad.max())
        marg = float(np.sqrt((rad * rad).sum())) + 4.0 * (n + 2) * U53 * (n * scale) + 1e-14 * scale
    for f in (2.0, 16.0, 256.0):
        s = lam - f * marg
        lb = cn.check_quad(x0, None, theta, mu, s, sign, ivb, cdat)
        if math.isfinite(lb):
            return s, cn.check_quad(x0, None, theta, mu, s, sign)  # exactly as the verifier will
    return None, -math.inf


def _opt_quad(cn: CertNet, X0: np.ndarray, sign: int, iters: int):
    """Adam on the smoothed objective sum(mu) + n * softmin(eig(M(theta) -
    diag(mu))) for a batch of subcubes with the same number r of free
    inputs. Returns a list of certificates (dicts) and their rigorous
    bounds (as checked by the verifier's own code)."""
    B = X0.shape[0]
    ivs, clo, chi = cn.intervals(X0)
    with np.errstate(all="ignore"):
        c = 0.5 * clo + 0.5 * chi
    G, const = _h1_coeffs(cn, X0, sign, ivs)
    L1, U1 = ivs[0]
    W1 = cn.Ws[0]
    free = X0 == 0.0
    r = int(free[0].sum())
    n = r + 1
    idx = np.nonzero(free)[1].reshape(B, r)
    V = np.transpose(W1[:, idx], (1, 0, 2))  # (B, m1, r)
    Vt = np.concatenate([V, c[:, :, None]], 2)  # (B, m1, n)
    m1 = W1.shape[0]
    th = np.zeros((B, m1, 2))
    th[..., 0] = 1.0
    th[..., 1] = 0.5

    def build(th):
        kap, bet, gam, dk, db, dg = _quad_family(G, L1, U1, th)
        M = np.einsum("bjp,bj,bjq->bpq", Vt, G * kap, Vt, optimize=True)
        lin = np.einsum("bj,bjp->bp", G * bet, Vt)
        M[:, :, -1] += lin / 2
        M[:, -1, :] += lin / 2
        M[:, -1, -1] += const + (G * gam).sum(1)
        return M, dk, db, dg

    certs, bounds = [None] * B, np.full(B, -np.inf)
    with np.errstate(all="ignore"):
        M, *_ = build(th)
        good = np.isfinite(M).all(axis=(1, 2)) & np.isfinite(G).all(1) & np.isfinite(Vt).all(axis=(1, 2))
        if not good.any():
            return certs, bounds
        mu = np.where(np.isfinite(M), M, 0.0).diagonal(axis1=1, axis2=2).copy()
        params = [th, mu]
        mom = [np.zeros_like(th), np.zeros_like(mu)]
        vel = [np.zeros_like(th), np.zeros_like(mu)]
        best = np.full(B, -np.inf)
        best_th, best_mu = th.copy(), mu.copy()
        taus = np.geomspace(0.05, 1e-4, iters)  # smoothing of the minimum eigenvalue
        eye = np.eye(n)
        gi = np.nonzero(good)[0]
        for it in range(iters):
            M, dk, db, dg = build(th)
            S = M - mu[:, :, None] * eye
            ok = good & np.isfinite(S).all(axis=(1, 2))
            if not ok.any():
                break
            gi = np.nonzero(ok)[0]
            w, Vv = np.linalg.eigh(S[gi])
            val = np.full(B, -np.inf)
            val[gi] = mu[gi].sum(1) + n * w[:, 0]
            better = val > best
            best = np.where(better, val, best)
            best_th[better] = th[better]
            best_mu[better] = mu[better]
            z = -(w - w[:, :1]) / taus[it]
            e = np.exp(z)
            pz = e / e.sum(1, keepdims=True)
            P = np.einsum("bik,bk,bjk->bij", Vv, pz, Vv, optimize=True)
            gmu = np.zeros_like(mu)
            gmu[gi] = 1 - n * np.diagonal(P, axis1=1, axis2=2)
            PV = np.einsum("bjp,bpq->bjq", Vt[gi], P)
            q = (PV * Vt[gi]).sum(2)
            sv = PV[:, :, -1]
            p22 = P[:, -1, -1]
            Gg = G[gi]
            gth = np.zeros_like(th)
            gth[gi] = ((n * Gg * q)[..., None] * dk[gi] + (n * Gg * sv)[..., None] * db[gi]
                       + (n * Gg * p22[:, None])[..., None] * dg[gi])
            grads = [np.nan_to_num(gth), np.nan_to_num(gmu)]
            for i in range(2):
                mom[i] = 0.9 * mom[i] + 0.1 * grads[i]
                vel[i] = 0.999 * vel[i] + 0.001 * grads[i] ** 2
                mh = mom[i] / (1 - 0.9 ** (it + 1))
                vh = vel[i] / (1 - 0.999 ** (it + 1))
                params[i] += 0.05 * mh / (np.sqrt(vh) + 1e-12)
            np.clip(params[0], 0.0, 1.0, out=params[0])
            th, mu = params
    for b in np.nonzero(np.isfinite(best))[0]:
        x0 = X0[b:b + 1]
        ivb = [(Lk[b:b + 1], Uk[b:b + 1]) for Lk, Uk in ivs]
        try:
            s, lb = _quad_shift(cn, x0, best_th[b], best_mu[b], sign, ivb, (clo[b:b + 1], chi[b:b + 1]))
        except (ValueError, np.linalg.LinAlgError, FloatingPointError) as e:
            if _DEBUG:
                print("quad prover failure:", repr(e))
            s, lb = None, -math.inf
        if s is not None:
            certs[b] = {"kind": "quad", "alpha": None, "theta": best_th[b].copy(), "mu": best_mu[b].copy(),
                        "shift": s}
            bounds[b] = lb
    return certs, bounds


def _split_scores(cn: CertNet, X0: np.ndarray, ivs):
    """Influence of each free coordinate on the unstable first-layer units,
    weighted by the coefficients of the backward pass."""
    G, _ = _h1_coeffs(cn, X0, 1, ivs)
    L1, U1 = ivs[0]
    uns = _uns_mask(L1, U1)
    with np.errstate(all="ignore"):
        wgt = np.nan_to_num(np.abs(G) * np.where(uns, np.minimum(-L1, U1), 0.0))
        sc = np.nan_to_num(wgt @ cn.absW[0])
    return np.where(X0 == 0.0, sc + 1e-300, -1.0)


def _choose_split(cn: CertNet, X0: np.ndarray, ivs, c, k: int):
    """Strong branching: among the top-k coordinates by score, the one whose
    worse child has the largest default 'lin' bound (prover-side floats; for
    one hidden layer the children's first-layer intervals are updated from
    the parent's by one column)."""
    sc = _split_scores(cn, X0, ivs)
    B, d = X0.shape
    k = max(1, min(k, int((X0[0] == 0).sum())))
    top = np.argsort(-sc, axis=1)[:, :k]
    if k == 1:
        return top[:, 0]
    kids = np.repeat(X0[:, None, :], 2 * k, 1).reshape(B, k, 2, d)
    for j in range(k):
        kids[np.arange(B), j, 0, top[:, j]] = -1.0
        kids[np.arange(B), j, 1, top[:, j]] = 1.0
    flat = kids.reshape(-1, d)
    with np.errstate(all="ignore"):
        if cn.L == 1:
            L1, U1 = ivs[0]
            rad = 0.5 * (U1 - L1)
            col = np.transpose(cn.Ws[0][:, top], (1, 2, 0))  # (B, k, m1)
            sgn = np.array([-1.0, 1.0])[None, None, :, None]
            cc = (c[:, None, None, :] + sgn * col[:, :, None, :]).reshape(-1, c.shape[1])
            rr = np.repeat(rad[:, None, :] - np.abs(col), 2, axis=1).reshape(-1, c.shape[1])
            lb = _lin_float(cn, flat, 1, [(cc - rr, cc + rr)], cc)
        else:
            ivc, clo, chi = cn.intervals(flat)
            lb = _lin_float(cn, flat, 1, ivc, 0.5 * clo + 0.5 * chi)
    worst = np.nan_to_num(lb, nan=-np.inf).reshape(B, k, 2).min(2)
    return top[np.arange(B), worst.argmax(1)]


def _std_f(cn: CertNet, rng, n=20000):
    X = rng.choice([-1.0, 1.0], size=(n, cn.d))
    v = cn.forward(X)
    with np.errstate(all="ignore"):
        s = float(np.std(v[np.isfinite(v)])) if np.isfinite(v).any() else math.inf
    return s if math.isfinite(s) else math.inf


def prove(net, cfg: ProverConfig | None = None, verbose: bool = False, root=None):
    """Build an argument for `verify` (for the subcube `root`, default the
    whole cube). Returns (arg, ProofInfo)."""
    cfg = cfg or ProverConfig()
    t_start = time.time()
    cn = net if isinstance(net, CertNet) else CertNet(net)
    rng = np.random.default_rng(cfg.seed)
    d, t = cn.d, cn.t
    sig = _std_f(cn, rng)
    margin = cfg.cert_margin * cn.absf if math.isfinite(cn.absf) else math.inf
    t_safe, mt_safe = t + margin, -t + margin  # SAFE needs lb(f) >= t_safe, FAIL lb(-f) > mt_safe
    # node storage
    X0s = [_subcube(root, d)]
    kind = [None]
    cert = [None]
    split = [-1]
    kids = [None]
    nfail = [0]  # prover's failure count of a leaf (ENUM: enumerated; FAIL: all)
    depth = [0]
    warm = [None]  # the parent's optimised slopes (prover-side warm start)
    frontier = [0]
    info = ProofInfo()
    while frontier:
        nxt = []
        for s0 in range(0, len(frontier), cfg.chunk):
            ids = frontier[s0:s0 + cfg.chunk]
            X0 = np.array([X0s[i] for i in ids], dtype=np.float64)
            rr = (X0 == 0.0).sum(1)
            ivs, clo, chi = cn.intervals(X0)
            with np.errstate(all="ignore"):
                c = 0.5 * clo + 0.5 * chi
            done = np.zeros(len(ids), dtype=bool)
            # SAFE by 'lin'
            if "lin" in cfg.kinds:
                lb0 = cn.check_lin(X0, None, 1, ivs)
                best_lb = lb0.copy()
                for b in np.nonzero(lb0 >= t_safe)[0]:
                    kind[ids[b]], cert[ids[b]] = SAFE, {"kind": "lin", "alpha": None}
                    done[b] = True
                sel = np.nonzero(~done & (lb0 >= t - cfg.opt_window * sig))[0]
                if sel.size and cfg.alpha_iters > 0:
                    ivs_s = [(Lk[sel], Uk[sel]) for Lk, Uk in ivs]
                    init = np.array([warm[ids[b]] if warm[ids[b]] is not None else np.full(cn.widths[0], np.nan)
                                     for b in sel])
                    al, fval = _opt_alpha(cn, X0[sel], 1, ivs_s, c[sel], cfg.alpha_iters, target=t, init=init)
                    if cfg.warm_start:
                        for j, b in enumerate(sel):
                            warm[ids[b]] = al[j]
                    cand = np.nonzero(fval >= t_safe)[0]
                    best_lb[sel] = np.maximum(best_lb[sel], fval)
                    if cand.size:
                        alist = [al[cand]] + [None] * (cn.L - 1)
                        lb1 = cn.check_lin(X0[sel[cand]], alist, 1, [(Lk[cand], Uk[cand]) for Lk, Uk in ivs_s])
                        for j, b in enumerate(sel[cand]):
                            if lb1[j] >= t_safe:
                                kind[ids[b]] = SAFE
                                cert[ids[b]] = {"kind": "lin", "alpha": [al[cand[j]].copy()] + [None] * (cn.L - 1)}
                                done[b] = True
            else:
                best_lb = np.full(len(ids), -np.inf)
            # FAIL by 'lin'
            if cfg.fail_leaves and "lin" in cfg.kinds:
                sel = np.nonzero(~done)[0]
                if sel.size:
                    ivs_s = [(Lk[sel], Uk[sel]) for Lk, Uk in ivs]
                    ub0 = cn.check_lin(X0[sel], None, -1, ivs_s)
                    cand = sel[ub0 > -t - min(2 * sig, cfg.opt_window * sig)]  # optimise slopes only near t
                    for j, b in enumerate(sel):
                        if ub0[j] > mt_safe:
                            kind[ids[b]], cert[ids[b]] = FAIL, {"kind": "lin", "alpha": None}
                            nfail[ids[b]] = 1 << int(rr[b])
                            done[b] = True
                    cand = np.array([b for b in cand if not done[b]], dtype=int)
                    if cand.size and cfg.alpha_iters > 0:
                        ivs_c = [(Lk[cand], Uk[cand]) for Lk, Uk in ivs]
                        al, _ = _opt_alpha(cn, X0[cand], -1, ivs_c, c[cand], cfg.alpha_iters, target=-t)
                        alist = [al] + [None] * (cn.L - 1)
                        ub1 = cn.check_lin(X0[cand], alist, -1, ivs_c)
                        for j, b in enumerate(cand):
                            if ub1[j] > mt_safe:
                                kind[ids[b]] = FAIL
                                cert[ids[b]] = {"kind": "lin", "alpha": [al[j].copy()] + [None] * (cn.L - 1)}
                                nfail[ids[b]] = 1 << int(rr[b])
                                done[b] = True
            # SAFE by 'quad'
            if "quad" in cfg.kinds:
                sel = np.nonzero(~done & (rr >= cfg.quad_rmin) & (rr > cfg.r_leaf)
                                 & (best_lb >= t - cfg.quad_window * sig))[0]
                for rv in np.unique(rr[sel]):
                    grp = sel[rr[sel] == rv]
                    for g0 in range(0, len(grp), 256):
                        gg = grp[g0:g0 + 256]
                        certs, lbq = _opt_quad(cn, X0[gg], 1, cfg.quad_iters)
                        for j, b in enumerate(gg):
                            if lbq[j] >= t_safe and certs[j] is not None:
                                kind[ids[b]], cert[ids[b]] = SAFE, certs[j]
                                done[b] = True
            # leaves and splits
            rest = np.nonzero(~done)[0]
            leafs = rest[rr[rest] <= cfg.r_leaf]
            for b in leafs:
                i = ids[b]
                kind[i] = ENUM
                X, fv = cn.enum_points(X0[b])
                nfail[i] = cn.classify(X, fv)
            spl = rest[rr[rest] > cfg.r_leaf]
            if spl.size:
                over = len(X0s) + 2 * spl.size > cfg.node_budget
                if over:
                    info.budget_hit = True
                    for b in spl:
                        if cfg.budget_leaf == "enum":
                            kind[ids[b]] = ENUM
                            if rr[b] <= 22:
                                X, fv = cn.enum_points(X0[b])
                                nfail[ids[b]] = cn.classify(X, fv)
                        else:
                            kind[ids[b]] = OPEN
                else:
                    ivs_s = [(Lk[spl], Uk[spl]) for Lk, Uk in ivs]
                    var = _choose_split(cn, X0[spl], ivs_s, c[spl], cfg.strong_k)
                    for b, v in zip(spl, var):
                        i = ids[b]
                        kind[i], split[i] = SPLIT, int(v)
                        ch = []
                        for sval in (-1, 1):
                            x = X0s[i].copy()
                            x[int(v)] = sval
                            X0s.append(x)
                            kind.append(None)
                            cert.append(None)
                            split.append(-1)
                            kids.append(None)
                            nfail.append(0)
                            depth.append(depth[i] + 1)
                            warm.append(warm[i])
                            ch.append(len(X0s) - 1)
                            nxt.append(len(X0s) - 1)
                        kids[i] = ch
                        warm[i] = None
        if verbose:
            print(f"  level done: {len(frontier)} nodes, next {len(nxt)}, total {len(X0s)}, "
                  f"{time.time() - t_start:.1f}s", flush=True)
        frontier = nxt
    # ---- costs bottom-up, collapse
    N = len(X0s)
    info.precollapse = {"nodes": N, "safe": sum(1 for k in kind if k == SAFE),
                        "fail": sum(1 for k in kind if k == FAIL), "enum": sum(1 for k in kind if k == ENUM)}
    rv = np.array([int((x == 0).sum()) for x in X0s])
    cost = np.zeros(N)
    fsum = np.zeros(N, dtype=object)
    has_open = np.zeros(N, dtype=bool)
    for i in range(N - 1, -1, -1):
        k = kind[i]
        if k == SPLIT:
            a, b = kids[i]
            cost[i] = cost[a] + cost[b] + cn.flops_node()
            fsum[i] = fsum[a] + fsum[b]
            has_open[i] = has_open[a] or has_open[b]
            if cfg.collapse and not has_open[i] and cn.flops_node() + cn.flops_enum(int(rv[i])) <= cost[i]:
                kind[i], kids[i], split[i] = ENUM, None, -1
                cost[i] = cn.flops_node() + cn.flops_enum(int(rv[i]))
                nfail[i] = int(fsum[i])
        elif k == SAFE or k == FAIL:
            cost[i] = cn.flops_node() + (cn.flops_quad(int(rv[i])) if cert[i]["kind"] == "quad" else cn.flops_lin())
            fsum[i] = nfail[i]
        elif k == ENUM:
            cost[i] = cn.flops_node() + cn.flops_enum(int(rv[i]))
            fsum[i] = nfail[i]
        else:  # OPEN
            has_open[i] = True
            fsum[i] = 0
    fails_known = None if has_open[0] else int(fsum[0])
    info.fails_known = fails_known
    info.seconds = time.time() - t_start

    def serialise(samples):
        tree = []
        lv, rh = {}, {}
        pred = 0.0
        for i in _preorder(kind, kids):
            k = kind[i]
            pred += cn.flops_node()
            if k == SPLIT:
                tree.append((SPLIT, split[i]))
                continue
            lv[k] = lv.get(k, 0) + 1
            if k in (SAFE, FAIL):
                tree.append((k, cert[i]))
                lv[cert[i]["kind"]] = lv.get(cert[i]["kind"], 0) + 1
                rh[int(rv[i])] = rh.get(int(rv[i]), 0) + 1
                pred += cn.flops_quad(int(rv[i])) if cert[i]["kind"] == "quad" else cn.flops_lin()
            elif k == ENUM:
                tree.append((ENUM,))
                pred += cn.flops_enum(int(rv[i]))
            else:
                tree.append((OPEN,))
        pred += samples * cn.fpe_flops
        return {"tree": tree, "samples": samples}, lv, dict(sorted(rh.items())), len(tree), pred

    open_ids = [i for i in _preorder(kind, kids) if kind[i] == OPEN]
    Zo0 = sum(1 << int(rv[i]) for i in open_ids)
    arg, lv, rh, nn, pred = serialise(0)
    info.nodes, info.leaves, info.r_hist = nn, lv, rh
    info.predicted_flops, info.predicted_fpe = pred, pred / cn.fpe_flops
    info.open_points = Zo0
    if cfg.open_policy == "none" or not fails_known:
        return arg, info
    # ---- hybrid: sample where that is cheaper than enumerating (needs the count)
    Ftot = fails_known
    Lg = math.log(2.0 / cfg.delta)

    def n_samp(Fo, Zo):
        """Samples for which the KL interval of the open part has half-width
        about eps * Ftot / 2 points: Bernstein-like term (many hits) and the
        no-hit term L / N (few hits)."""
        return 1.2 * max(8.0 * Lg * Fo * Zo / (cfg.eps ** 2 * Ftot ** 2), 3.0 * Lg * Zo / (cfg.eps * Ftot))

    Fo, Zo = 0, 0
    stack = [0]  # top-down greedy over the nodes whose subtree contains failures
    while stack:
        i = stack.pop()
        if kind[i] in (SAFE, FAIL, OPEN) or fsum[i] == 0:
            continue
        Zi = 1 << int(rv[i])
        extra_cost = (n_samp(Fo + int(fsum[i]), Zo + Zi) - n_samp(Fo, Zo)) * cn.fpe_flops
        if extra_cost < cost[i]:
            kind[i], kids[i], split[i] = OPEN, None, -1
            Fo += int(fsum[i])
            Zo += Zi
        elif kind[i] == SPLIT:
            stack.extend(kids[i])
    samples = int(math.ceil(n_samp(Fo, Zo))) if Zo else 0
    harg, hlv, hrh, hnn, hpred = serialise(samples)
    hinfo = ProofInfo(nodes=hnn, leaves=hlv, seconds=info.seconds, predicted_flops=hpred,
                      predicted_fpe=hpred / cn.fpe_flops, fails_known=fails_known, open_points=Zo,
                      open_fails=Fo, r_hist=hrh, budget_hit=info.budget_hit, precollapse=info.precollapse)
    if cfg.open_policy == "auto":
        return harg, hinfo
    arg["hybrid"] = harg  # open_policy == "both": the exact argument carries the hybrid one
    info.hybrid = hinfo
    return arg, info


def _preorder(kind, kids):
    out = []
    stack = [0]
    while stack:
        i = stack.pop()
        out.append(i)
        if kind[i] == SPLIT:
            a, b = kids[i]
            stack.append(b)
            stack.append(a)
    return out


def knuth_estimate(net, cfg: ProverConfig | None = None, probes: int = 64, seed: int = 0):
    """Knuth's (1975) unbiased estimate of the size and verification cost of
    the prover's tree BEFORE collapsing, from `probes` random root-to-leaf
    paths that follow the prover's own rule (certify with 'lin' (optimised
    slopes) for SAFE or FAIL, then 'quad' if enabled; leaf at r <= r_leaf;
    else strong-branching split and a uniformly random child). For a path
    ending at depth D the estimates are 2^(D+1) - 1 nodes and 2^D leaves,
    and the leaf's verification cost times 2^D (plus the splits)."""
    cfg = cfg or ProverConfig()
    cn = net if isinstance(net, CertNet) else CertNet(net)
    rng = np.random.default_rng(seed)
    d, t = cn.d, cn.t
    sig = _std_f(cn, rng)
    X = np.zeros((probes, d))
    depth = np.zeros(probes, dtype=int)
    alive = np.ones(probes, dtype=bool)
    out_kind = [None] * probes
    est_cost = np.zeros(probes)
    while alive.any():
        ids = np.nonzero(alive)[0]
        X0 = X[ids]
        rr = (X0 == 0.0).sum(1)
        ivs, clo, chi = cn.intervals(X0)
        with np.errstate(all="ignore"):
            c = 0.5 * clo + 0.5 * chi
        lb = cn.check_lin(X0, None, 1, ivs)
        if cfg.alpha_iters:
            al, _ = _opt_alpha(cn, X0, 1, ivs, c, cfg.alpha_iters)
            lb = np.maximum(lb, cn.check_lin(X0, [al] + [None] * (cn.L - 1), 1, ivs))
        ub = -cn.check_lin(X0, None, -1, ivs) if cfg.fail_leaves else np.full(len(ids), np.inf)
        if cfg.fail_leaves and cfg.alpha_iters:
            al2, _ = _opt_alpha(cn, X0, -1, ivs, c, cfg.alpha_iters)
            ub = np.minimum(ub, -cn.check_lin(X0, [al2] + [None] * (cn.L - 1), -1, ivs))
        decided = (lb >= t) | (ub < t)
        if "quad" in cfg.kinds:
            sel = np.nonzero(~decided & (rr >= cfg.quad_rmin) & (rr > cfg.r_leaf) & (lb >= t - cfg.quad_window * sig))[0]
            for rv in np.unique(rr[sel]):
                grp = sel[rr[sel] == rv]
                _, lq = _opt_quad(cn, X0[grp], 1, cfg.quad_iters)
                for j, b in enumerate(grp):
                    if lq[j] >= t:
                        decided[b] = True
                        out_kind[ids[b]] = "quad"
        for j, i in enumerate(ids):
            w = 2.0 ** depth[i]
            if decided[j]:
                if out_kind[i] is None:
                    out_kind[i] = "safe" if lb[j] >= t else "fail"
                est_cost[i] += w * (cn.flops_node() + (cn.flops_quad(int(rr[j])) if out_kind[i] == "quad" else cn.flops_lin()))
                alive[i] = False
            elif rr[j] <= cfg.r_leaf:
                out_kind[i] = "enum"
                est_cost[i] += w * (cn.flops_node() + cn.flops_enum(int(rr[j])))
                alive[i] = False
            else:
                est_cost[i] += w * cn.flops_node()
        spl = np.nonzero(alive[ids])[0]
        if spl.size:
            ivs_s = [(Lk[spl], Uk[spl]) for Lk, Uk in ivs]
            var = _choose_split(cn, X0[spl], ivs_s, c[spl], cfg.strong_k)
            for j, v in zip(spl, var):
                i = ids[j]
                X[i, int(v)] = rng.choice([-1.0, 1.0])
                depth[i] += 1
    nodes = 2.0 ** (depth + 1) - 1
    leaves = 2.0 ** depth
    kinds = {}
    for k, w in zip(out_kind, leaves):
        kinds[k] = kinds.get(k, 0.0) + w / probes
    return {"nodes": float(nodes.mean()), "nodes_se": float(nodes.std() / math.sqrt(probes)),
            "leaves": float(leaves.mean()), "leaf_kinds": kinds,
            "fpe": float(est_cost.mean() / cn.fpe_flops), "fpe_se": float(est_cost.std() / math.sqrt(probes) / cn.fpe_flops),
            "depth_mean": float(depth.mean()), "depth_min": int(depth.min()), "depth_max": int(depth.max()),
            "probes": probes}


def witness_lower_bound(net, points) -> tuple[float, int]:
    """Lower bounds need no deduction: the verifier checks a list of claimed
    failing points (exactly, with the same tie handling as everywhere) and
    returns (lower bound on p rounded down, number of distinct failing points
    in the list). Cost: one evaluation per listed point."""
    cn = net if isinstance(net, CertNet) else CertNet(net)
    P = np.asarray(points, dtype=np.float64).reshape(-1, cn.d)
    P = P[np.all((P == 1.0) | (P == -1.0), axis=1)]
    P = np.unique(P, axis=0)
    k = cn.classify(P, cn.forward(P)) if len(P) else 0
    return _round_down(Fraction(k, 1 << cn.d)), k
