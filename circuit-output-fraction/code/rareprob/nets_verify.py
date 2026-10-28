"""Deductive bounds on the failure probability of ReLU MLPs on the cube:
input branch and bound with neural-network-verification bounds.

Setting (rareprob.nets): f(x) = W_{L+1} relu(... relu(W_1 x + b_1) ...) + b_{L+1}
on x in {-1,+1}^d, D uniform, and the event E = [f(x) < t]. We want
p = Pr[E] = |E| / 2^d. The weights are float64 numbers; as everywhere in this
project they stand for their exact binary values, f is evaluated in exact real
arithmetic, and the comparison with t is exact. Every interval produced here is
ALSO valid when f is evaluated in float64 in any summation order (as by
MLP.forward or nets.exact_failure_count), because every decision keeps a
margin tau (below) that dominates the rounding error of any such evaluation.

What is computed
----------------
A *subcube* is a vector x0 in {-1,0,+1}^d: coordinates with x0_i = +-1 are
fixed, the others are free. Its box is {x : |x_i - x0_i| <= [x0_i = 0]}, which
contains the subcube's 2^r points (r free coordinates) and much more.

* bound(X0): for a batch of subcubes, a lower and an upper bound on f over
  the box, by linear bound propagation (CROWN / DeepPoly-type relaxations):
  every hidden pre-activation z_j gets an interval [l_j, u_j]; an unstable
  unit (l_j < 0 < u_j) is relaxed by alpha_j z_j <= relu(z_j) <= lam_j (z_j - l_j)
  with alpha_j in [0, 1] and lam_j >= u_j / (u_j - l_j); stable units are exact;
  the resulting linear function of x is minimised over the box exactly
  (h + g.x0 - |g|.r). Intermediate layers get CROWN bounds intersected with
  interval (IBP) bounds. For one hidden layer, the slopes alpha of the output
  bound can be optimised (projected supergradient ascent): every alpha in
  [0, 1] gives a valid bound, and the supremum over alpha is the LP
  (triangle) relaxation of the box problem, by minimax.
* bab(net, ...): breadth-first branch and bound on input coordinates.
  A subcube is SAFE if its lower bound is >= t + 2 tau (no point fails),
  FAILING if its upper bound is < t - 2 tau (every point fails), ENUMERATED
  if it has at most r_enum free coordinates (its 2^r points are evaluated;
  points with |f - t| <= tau are counted as ambiguous), and otherwise split
  on one free coordinate. When the node budget runs out, the remaining
  frontier is UNDECIDED. The output is the deterministic interval
      p in [ F / 2^d , (F + A + U) / 2^d ]
  with F the certified failing points, A the ambiguous ones and U the points
  of undecided subcubes. With no budget limit the tree resolves everything
  and the interval is [F, F + A] / 2^d: the exact p when A = 0 (A counts the
  points with |f - t| below the conservative rounding margin tau ~ 2^-30 M,
  in our runs 0, except up to a few hundred among millions of failing
  points in the nets with large p).
* estimate_undecided(...): the undecided subcubes are disjoint, so their
  union is an envelope with exact mass U / 2^d and an exact sampler (choose a
  subcube proportionally to its size, then its free bits uniformly); the
  envelope estimator of the paper (Sec. 3) samples inside it and returns a
  two-sided interval whose cost is about K / eps^2 samples, K = U / (p 2^d -
  F) (the undecided mass over the failure mass it contains).
* phase_bound(...) and bab(phase_depth=...): ReLU phase splitting inside a
  subcube (one hidden layer): the loosest concave units (a_j < 0) are split
  into their two phases, each phase constraint enters through a Lagrange
  multiplier beta_j >= 0 (beta-CROWN style); every multiplier is valid.
* The box barrier. A real point y of a subcube's box with f(y) < t proves
  that NO bound valid on the box (interval/CROWN/DeepPoly, the LP, any
  convex relaxation over the box, complete phase splitting of the ReLUs) can
  certify that subcube. milp_min(..., integer=False) finds such points with
  a MILP solver (scipy/HiGHS; the point is re-evaluated, so a found witness
  is checked); box_search is a cheaper local search. Diagnostics only: they
  never certify anything. milp_min(..., integer=True) minimises f over the
  subcube's POINTS (branch and cut); only its re-checked failing points are
  used (as witnesses of p >= 2^-d), never its optimality claims.
* oracle_tree_static / oracle_tree_greedy: the size of the branch-and-bound
  tree a PERFECT engine would need (a subcube decided as soon as it contains
  no failing point or only failing points), computed from the exact failing
  set. A diagnostic separating the geometry of the failing set from the
  looseness of the bounds.

Soundness on every net (adversarial weights included)
-----------------------------------------------------
1. Relaxations. alpha z <= relu(z) for every alpha in [0, 1] and every real z.
   lam (z - l) >= relu(z) on [l, u] (l < 0 < u) iff lam (u - l) >= u; we
   compute lam = fl(u / fl(u - l)) (1 + 2^-48), which exceeds u / (u - l) in
   exact arithmetic (three roundings of relative size 2^-53 each). Stable
   units are replaced by z or 0 only when the (padded) interval proves the
   sign. Hence, with the computed slopes, offsets and intervals taken as
   exact real parameters, the linear function L(x) built by the backward pass
   satisfies f(x) >= L(x) on the box, provided every true pre-activation range
   lies in its computed interval (item 3).
2. Rounding of the bound itself. The computed bound is a sum of products of
   the network's entries, the slopes, the offsets and x0, r. For any
   summation order, its error is at most gamma_n times the same expression
   with every entry replaced by its absolute value (Higham, Thm 3.5 /
   recursive summation), where n < 2^17 is the longest chain of operations
   (asserted at construction) so gamma_n < 2^-35. That absolute expression is
   at most M = max rho~_{L+1}, the absolute forward pass
   rho~_1 = |W_1| 1 + |b_1|, rho~_k = |W_k| (2.5 rho~_{k-1} + 2 tau_{k-1}) + |b_k|
   (slopes are at most 1 + 2^-47, and |lam (z - l)| <= lam (|z| + |l|) with
   |z| <= rho~ and |l| <= rho~ + tau). We use tau = 2^-30 (M + 1), so the
   exact value of the bound is within tau of the computed one (the +1 covers
   underflow). Weights that are not finite, or so large that rho~ exceeds
   1e300, are rejected (ValueError) rather than bounded. The phase-split
   bounds add terms beta_j z_j with unbounded multipliers; they subtract the
   extra margin 2^-30 sum_j beta_j (rho~_1j + tau_1).
3. Intermediate intervals are padded outwards by tau_k = 2^-30 (rho~_k + 1)
   (max over the layer), which covers their rounding error by item 2; the
   first layer's interval [W x0 + b - |W| r, W x0 + b + |W| r] is exact up to
   that rounding.
4. Decisions keep a margin of 2 tau: lower bound >= t + 2 tau gives
   f(x) >= t + tau > t exactly, and also f_float(x) >= t for any float64
   evaluation, whose error is at most gamma_n |f|_abs <= tau / 32.
   Symmetrically for failing subcubes, and for enumerated points with margin
   tau (points with t - tau <= f_computed < t + tau are ambiguous and go
   into the gap of the interval). The thresholds t +- 2 tau and t +- tau are
   computed in exact rational arithmetic and rounded outwards once, so the
   float comparisons imply the exact inequalities.
5. Branch and bound is a partition of the cube into subcubes, so the counts
   F, A, U and the safe count add up to 2^d exactly (Python integers).
None of this uses training, the data, or any property of the weights: the
interval is valid for every MLP. The node budget, the branching rule and the
slope optimiser affect only the width of the interval.

The sampling stage is sound by the envelope estimator argument: samples are
exact uniform draws from the undecided union, and the KL interval (stats) is
applied separately to the definite-failure indicator (lower end) and to the
definite-or-ambiguous indicator (upper end), with a union bound over the
doubling stages.
"""

from __future__ import annotations

import math
import time
from dataclasses import dataclass, field
from fractions import Fraction

import numpy as np

from .nets import MLP
from .stats import kl_interval

_LAM_UP = 1.0 + 2.0 ** -48
_TAU_SCALE = 2.0 ** -30


# --------------------------------------------------------------------------
# bounds on subcubes


class Bounder:
    """Linear-relaxation bounds of an MLP over batches of subcube boxes."""

    def __init__(self, net: MLP):
        self.Ws = [np.ascontiguousarray(W, dtype=np.float64) for W in net.Ws]
        self.bs = [np.asarray(b, dtype=np.float64).ravel() for b in net.bs]
        self.absW = [np.abs(W) for W in self.Ws]
        self.t = float(net.threshold)
        self.d = self.Ws[0].shape[1]
        self.L = len(self.Ws) - 1  # number of hidden layers
        self.widths = [W.shape[0] for W in self.Ws[:-1]]
        dims = [self.d] + self.widths + [1]
        # longest chain of floating-point operations in any computed quantity
        n_ops = sum(dims) * 4 + 64
        assert n_ops < 2 ** 17, "network too large for the fixed rounding margin"
        if not all(np.isfinite(W).all() for W in self.Ws) or not all(np.isfinite(b).all() for b in self.bs):
            raise ValueError("non-finite weights")
        rho = np.ones(self.d)
        self.tau_layer = []
        self.rho = []
        for k in range(self.L + 1):
            if k == 0:
                rho = self.absW[0] @ rho + np.abs(self.bs[0])
            else:
                rho = self.absW[k] @ (2.5 * rho + 2.0 * self.tau_layer[-1]) + np.abs(self.bs[k])
            if not np.isfinite(rho).all() or rho.max() > 1e300:
                raise ValueError("weights too large for float64 bound propagation")
            self.rho.append(rho)
            self.tau_layer.append(_TAU_SCALE * (float(rho.max()) + 1.0))
        self.tau = self.tau_layer[-1]  # margin on the output
        # decision thresholds, rounded outwards exactly (Fractions), so that a
        # float comparison with them implies the exact inequality
        T, tau = Fraction(self.t), Fraction(self.tau)
        self.thr_safe = _round(T + 2 * tau, up=True)  # box bound >= this: safe
        self.thr_fail = _round(T - 2 * tau, up=False)  # box bound < this: failing
        self.pt_safe = _round(T + tau, up=True)  # computed f >= this: point safe
        self.pt_fail = _round(T - tau, up=False)  # computed f < this: point fails
        self.flops_forward = sum(a * b for a, b in zip(dims[:-1], dims[1:]))

    # ---- plain evaluation -------------------------------------------------
    def forward(self, X: np.ndarray) -> np.ndarray:
        h = np.asarray(X, dtype=np.float64)
        for W, b in zip(self.Ws[:-1], self.bs[:-1]):
            h = np.maximum(h @ W.T + b, 0.0)
        return (h @ self.Ws[-1].T + self.bs[-1])[..., 0]

    # ---- the backward (CROWN) pass -----------------------------------------
    def _relax(self, l, u):
        """Slopes for the intervals [l, u] of one layer: lower slope default,
        upper slope lam and upper offset -lam l (0 for stable units)."""
        active = l >= 0.0
        unstable = (l < 0.0) & (u > 0.0)
        with np.errstate(divide="ignore", invalid="ignore"):
            lam_u = np.where(unstable, u / np.where(unstable, u - l, 1.0) * _LAM_UP, 0.0)
        lam = np.where(active, 1.0, lam_u)
        off = np.where(unstable, -lam * l, 0.0)
        return active, unstable, lam, off

    def _lower_linear(self, A, c0, k_top, X0, R, relax, alphas, keep=False):
        """Lower bound of A . h_{k_top} + c0 over each box.

        A: (B, q, m_{k_top}) (h_0 = x), c0: (B, q). relax[k-1] = (active,
        unstable, lam, off) of hidden layer k; alphas[k-1] the lower slopes.
        Returns the bound (B, q), and if keep also the coefficient on h_1
        (pre-relaxation) and on x."""
        A_h1 = None
        for k in range(k_top, 0, -1):
            active, unstable, lam, off = relax[k - 1]
            s_lo = np.where(unstable, alphas[k - 1], active.astype(np.float64))
            Ap = np.maximum(A, 0.0)
            An = np.minimum(A, 0.0)
            if k == 1 and keep:
                A_h1 = A
            Aeff = Ap * s_lo[:, None, :] + An * lam[:, None, :]
            c0 = c0 + np.einsum("bqm,bm->bq", An, off) + Aeff @ self.bs[k - 1]
            A = Aeff @ self.Ws[k - 1]
        val = c0 + np.einsum("bqd,bd->bq", A, X0) - np.einsum("bqd,bd->bq", np.abs(A), R)
        if keep:
            return val, A_h1, A
        return val

    def layer_bounds(self, X0, R):
        """Padded intervals [l_k, u_k] of every hidden layer's pre-activations
        over each box, and the relaxations built from them."""
        B = X0.shape[0]
        Z = X0 @ self.Ws[0].T + self.bs[0]
        rad = R @ self.absW[0].T
        tau = self.tau_layer[0]
        bounds = [(Z - rad - tau, Z + rad + tau)]
        relax = [self._relax(*bounds[0])]
        alphas = [self._default_alpha(*bounds[0])]
        for k in range(2, self.L + 1):
            # IBP
            lo_h = np.maximum(bounds[-1][0], 0.0)
            hi_h = np.maximum(bounds[-1][1], 0.0)
            cen = (lo_h + hi_h) / 2
            hr = (hi_h - lo_h) / 2
            Zc = cen @ self.Ws[k - 1].T + self.bs[k - 1]
            Zr = hr @ self.absW[k - 1].T
            # CROWN, all units of layer k at once
            Wk = np.broadcast_to(self.Ws[k - 1], (B,) + self.Ws[k - 1].shape)
            bk = np.broadcast_to(self.bs[k - 1], (B, self.Ws[k - 1].shape[0]))
            lo_c = self._lower_linear(Wk, bk, k - 1, X0, R, relax, alphas)
            hi_c = -self._lower_linear(-Wk, -bk, k - 1, X0, R, relax, alphas)
            tau = self.tau_layer[k - 1]
            lo = np.maximum(lo_c, Zc - Zr) - tau
            hi = np.minimum(hi_c, Zc + Zr) + tau
            bounds.append((lo, hi))
            relax.append(self._relax(lo, hi))
            alphas.append(self._default_alpha(lo, hi))
        return bounds, relax, alphas

    @staticmethod
    def _default_alpha(l, u):
        return (u >= -l).astype(np.float64)

    def bound(self, X0, alpha_iters: int = 0, want_upper: bool = True):
        """Lower and upper bounds of f over the boxes of the subcubes X0
        ((B, d) array with entries -1, 0, +1; 0 = free).

        Returns (lb, ub, score): score (B, d) ranks free coordinates for
        branching (looseness that fixing the coordinate removes). The bounds
        are on the exact real f; the caller keeps the 2 tau margin."""
        X0 = np.asarray(X0, dtype=np.float64)
        R = (X0 == 0).astype(np.float64)
        B = X0.shape[0]
        bounds, relax, alphas = self.layer_bounds(X0, R)
        WL = np.broadcast_to(self.Ws[-1], (B,) + self.Ws[-1].shape)
        bL = np.broadcast_to(self.bs[-1], (B, 1))
        lb, A_h1, A_x = self._lower_linear(WL, bL, self.L, X0, R, relax, alphas, keep=True)
        lb = lb[:, 0]
        if alpha_iters and self.L == 1:
            lb = np.maximum(lb, self._opt_alpha_1hidden(X0, R, bounds[0], relax[0], alphas[0], alpha_iters))
        ub = None
        if want_upper:
            ub = -self._lower_linear(-WL, -bL, self.L, X0, R, relax, alphas)[:, 0]
        # branching score: sum over unstable first-layer units of
        # |coefficient on h_1| * |W_ji|, plus |g_i| / 2 (the linear part)
        unst = relax[0][1]
        wcoef = np.abs(A_h1[:, 0, :]) * unst
        score = np.where(R > 0, wcoef @ self.absW[0] + 0.5 * np.abs(A_x[:, 0, :]), -1.0)
        return lb, ub, score

    def alpha_bound(self, X0, iters: int) -> np.ndarray:
        """Lower bound of f with optimised slopes (one hidden layer)."""
        X0 = np.asarray(X0, dtype=np.float64)
        R = (X0 == 0).astype(np.float64)
        bounds, relax, alphas = self.layer_bounds(X0, R)
        return self._opt_alpha_1hidden(X0, R, bounds[0], relax[0], alphas[0], iters)

    def phase_bound(self, X0, depth: int, iters: int = 30):
        """Lower bound of f over each subcube's box by splitting the phases of
        the `depth` unstable units with a_j < 0 whose chord is loosest (one
        hidden layer). For each of the 2^depth sign patterns s, the leaf
        problem is min f over {x in box : s_j z_j(x) >= 0}; on it those
        units are exact (z_j or 0), and for any beta >= 0
            min_leaf f >= min_box [ relaxed f - sum_j beta_j s_j z_j ],
        a linear function minimised in closed form. alpha (units with
        a_j > 0) and beta are optimised by projected supergradient ascent;
        every iterate is valid. Returns the minimum over the 2^depth leaves
        of the best leaf bound (B,), i.e. a valid lower bound of f over the
        box, and the number of leaves bounded."""
        assert self.L == 1
        X0 = np.asarray(X0, dtype=np.float64)
        R = (X0 == 0).astype(np.float64)
        B = X0.shape[0]
        a = self.Ws[1][0]
        c = self.bs[1][0]
        W, b = self.Ws[0], self.bs[0]
        bounds, relax, alphas = self.layer_bounds(X0, R)
        l, u = bounds[0]
        active, unstable, lam, off = relax[0]
        loose = np.where(unstable & (a < 0), -a * (-l * u) / np.where(unstable, u - l, 1.0), -np.inf)
        D = int(min(depth, max(0, int((loose > -np.inf).sum(1).min()))))
        sel = np.argsort(-loose, axis=1)[:, :D]  # (B, D)
        P = np.where((np.arange(1 << D)[:, None] >> np.arange(D)) & 1, 1.0, -1.0)  # (2^D, D) signs
        nl = P.shape[0]
        # expand to (B * nl) leaves
        Xl = np.repeat(X0, nl, axis=0)
        Rl = np.repeat(R, nl, axis=0)
        S = np.zeros((B * nl, W.shape[0]))  # phase sign per unit (0 = not fixed)
        for k in range(D):
            S[np.arange(B * nl), np.repeat(sel[:, k], nl)] = np.tile(P[:, k], B)
        act = np.repeat(active, nl, 0)
        unst = np.repeat(unstable, nl, 0)
        lam_l = np.repeat(lam, nl, 0)
        off_l = np.repeat(off, nl, 0)
        al = np.repeat(alphas[0], nl, 0)
        fixed = S != 0
        free_u = unst & ~fixed
        pos_u = free_u & (a > 0)
        # slopes of the parts that do not depend on alpha / beta
        s_fix = np.where(fixed, (S > 0).astype(np.float64),
                         np.where(free_u, np.where(a < 0, lam_l, 0.0), act.astype(np.float64)))
        h_fix = c + (a * s_fix) @ b + np.where(free_u & (a < 0), a * off_l, 0.0).sum(1)
        alpha = np.where(pos_u, al, 0.0)
        beta = np.zeros_like(alpha)
        best = np.full(B * nl, -np.inf)
        for it in range(iters):
            coef = a * (s_fix + alpha * pos_u) - beta * S  # coefficient on z_j
            g = coef @ W
            h = h_fix + (a * alpha * pos_u - beta * S) @ b
            val = h + np.einsum("bd,bd->b", g, Xl) - np.einsum("bd,bd->b", np.abs(g), Rl)
            # the beta terms are not covered by tau: subtract their own
            # rounding margin, 2^-30 sum_j beta_j (rho_1j + tau_1)
            val = val - _TAU_SCALE * (beta @ (self.rho[0] + self.tau_layer[0]))
            best = np.maximum(best, val)
            xs = Xl - np.sign(g) * Rl
            zst = xs @ W.T + b
            ga = a * zst * pos_u
            gb = -S * zst * fixed
            nrm = np.sqrt((ga ** 2).sum(1, keepdims=True) + (gb ** 2).sum(1, keepdims=True)) + 1e-12
            st = 0.5 / math.sqrt(it + 1) / nrm
            alpha = np.clip(alpha + st * ga, 0.0, 1.0)
            beta = np.maximum(beta + st * gb * np.maximum(1.0, np.abs(a).max()), 0.0)
        return best.reshape(B, nl).min(1), nl

    # ---- cost model (flops) ------------------------------------------------
    def crown_flops(self) -> float:
        """One call of bound() per subcube: first layer centre and radius,
        CROWN for deeper layers (all units, lower and upper), the output
        bound (lower and upper) and the branching score."""
        dims = [self.d] + self.widths
        fl = 2.0 * self.d * self.widths[0]
        for k in range(2, self.L + 1):
            # m_k rows pushed back through layers k-1..1, twice
            back = sum(dims[i] * dims[i - 1] for i in range(1, k))
            fl += 2.0 * self.widths[k - 1] * back + 2.0 * self.widths[k - 1] * self.widths[k - 2]
        fl += 2.0 * self.flops_forward + self.d * self.widths[0]
        return fl

    def phase_flops(self, depth: int, iters: int) -> float:
        return 2.0 * self.d * self.widths[0] + (1 << depth) * iters * 2.0 * self.d * self.widths[0]

    def alpha_flops(self, iters: int) -> float:
        return 2.0 * self.d * self.widths[0] + iters * 2.0 * self.d * self.widths[0]

    def enum_flops(self, r: int) -> float:
        """Evaluating the 2^r points of a subcube: the centre's first-layer
        pre-activations, then per point r * m_1 for the free columns and the
        rest of the network."""
        rest = self.flops_forward - self.d * self.widths[0]
        return self.d * self.widths[0] + (1 << r) * (r * self.widths[0] + self.widths[0] + rest)

    def full_enum_flops(self) -> float:
        """Meet-in-the-middle enumeration of the whole cube (as in
        nets.exact_failure_count): per point one addition of two first-layer
        tables, the ReLU and the rest of the network."""
        rest = self.flops_forward - self.d * self.widths[0]
        return float(2 ** self.d) * (2 * self.widths[0] + rest)

    def _opt_alpha_1hidden(self, X0, R, bnd, rel, alpha0, iters):
        """Projected supergradient ascent on the lower slopes of the units
        with a_j > 0 (one hidden layer). Every iterate is a valid bound; the
        best is returned."""
        a = self.Ws[1][0]
        c = self.bs[1][0]
        W, b = self.Ws[0], self.bs[0]
        active, unstable, lam, off = rel
        pos_u = unstable & (a > 0)
        # fixed part: units with a_j < 0 use the chord; stable units exact
        s_fixed = np.where(unstable, np.where(a < 0, lam, 0.0), active.astype(np.float64))
        h_fixed = c + (a * s_fixed) @ b + np.where(unstable & (a < 0), a * off, 0.0).sum(1)
        alpha = np.where(pos_u, alpha0, 0.0)
        best = np.full(X0.shape[0], -np.inf)
        step = 0.5
        for it in range(iters):
            s = s_fixed + alpha * pos_u
            S = a * s
            g = S @ W
            h = h_fixed + (a * alpha * pos_u) @ b
            val = h + np.einsum("bd,bd->b", g, X0) - np.einsum("bd,bd->b", np.abs(g), R)
            best = np.maximum(best, val)
            xs = X0 - np.sign(g) * R  # minimising vertex
            zst = xs @ W.T + b
            grad = a * zst * pos_u
            # normalised step per node
            nrm = np.sqrt((grad ** 2).sum(1, keepdims=True)) + 1e-12
            alpha = np.clip(alpha + step / math.sqrt(it + 1) * grad / nrm, 0.0, 1.0)
        return best

    # ---- exact evaluation of small subcubes ------------------------------
    def enumerate_subcubes(self, X0, chunk_points: int = 1 << 21, collect: list | None = None):
        """For subcubes with the same number r of free coordinates, the number
        of definitely failing (f < t - tau) and ambiguous (|f - t| <= tau)
        points of each. Returns two int arrays. If collect is a list, the
        failing points are appended to it (as int8 arrays)."""
        X0 = np.asarray(X0, dtype=np.float64)
        B, d = X0.shape
        R = X0 == 0
        r = int(R[0].sum())
        assert (R.sum(1) == r).all()
        if r == 0:
            f = self.forward(X0)
            if collect is not None:
                collect.append(X0[f < self.pt_fail].astype(np.int8))
            return (f < self.pt_fail).astype(np.int64), ((f >= self.pt_fail) & (f < self.pt_safe)).astype(np.int64)
        free = np.nonzero(R)[1].reshape(B, r)
        idx = np.arange(1 << r)
        P = np.where((idx[:, None] >> np.arange(r)) & 1, 1.0, -1.0)  # (2^r, r)
        W1, b1 = self.Ws[0], self.bs[0]
        nf = np.zeros(B, dtype=np.int64)
        na = np.zeros(B, dtype=np.int64)
        step = max(1, chunk_points // (1 << r))
        for s in range(0, B, step):
            sl = slice(s, s + step)
            Z0 = X0[sl] @ W1.T + b1  # (b, m)
            Wf = W1[:, free[sl]].transpose(1, 2, 0)  # (b, r, m)
            Z = Z0[:, None, :] + np.einsum("pr,brm->bpm", P, Wf)
            h = np.maximum(Z, 0.0)
            for W, bb in zip(self.Ws[1:-1], self.bs[1:-1]):
                h = np.maximum(h @ W.T + bb, 0.0)
            f = (h @ self.Ws[-1].T + self.bs[-1])[..., 0]
            nf[sl] = (f < self.pt_fail).sum(1)
            if collect is not None and nf[sl].any():
                bi, pi = np.nonzero(f < self.pt_fail)
                pts = X0[sl][bi].copy()
                fr = free[sl][bi]
                pts[np.arange(len(bi))[:, None], fr] = P[pi]
                collect.append(pts.astype(np.int8))
            na[sl] = ((f >= self.pt_fail) & (f < self.pt_safe)).sum(1)
        return nf, na


# --------------------------------------------------------------------------
# branch and bound


def _round(q: Fraction, up: bool) -> float:
    """The rational q rounded to a float in the given direction."""
    v = float(q)
    if up and Fraction(v) < q:
        v = math.nextafter(v, math.inf)
    if not up and Fraction(v) > q:
        v = math.nextafter(v, -math.inf)
    return v


def _dyadic(n: int, d: int, up: bool) -> float:
    """n / 2^d rounded to a float in the given direction."""
    q = Fraction(n, 1 << d)
    v = float(q)
    if up and Fraction(v) < q:
        v = math.nextafter(v, math.inf)
    if not up and Fraction(v) > q:
        v = math.nextafter(v, -math.inf)
    return v


@dataclass
class BabResult:
    d: int
    fail: int = 0  # points certified failing
    ambiguous: int = 0  # points within tau of the threshold (counted in hi only)
    safe: int = 0  # points certified safe
    undecided: int = 0  # points in undecided subcubes
    undecided_cubes: np.ndarray | None = None  # (n, d) int8 subcubes
    nodes_bounded: int = 0
    nodes_total: int = 0  # all tree nodes (bounded, enumerated, branched-unbounded)
    points_enumerated: int = 0
    leaves_enumerated: int = 0
    certified_safe_nodes: int = 0
    certified_fail_nodes: int = 0
    max_depth: int = 0
    seconds: float = 0.0
    flops: float = 0.0  # floating point operations, approximate
    fpe: float = 0.0  # the same in forward-pass equivalents
    levels: list = field(default_factory=list)
    stopped: str = ""
    fail_cubes: list = field(default_factory=list)  # certified failing subcubes (with collect)

    @property
    def lo(self) -> float:
        """F / 2^d rounded down to a float."""
        return _dyadic(self.fail, self.d, up=False)

    @property
    def hi(self) -> float:
        """(F + A + U) / 2^d rounded up to a float."""
        return _dyadic(self.fail + self.ambiguous + self.undecided, self.d, up=True)

    @property
    def exact(self) -> bool:
        return self.undecided == 0 and self.ambiguous == 0

    def summary(self) -> dict:
        return dict(d=self.d, fail=self.fail, ambiguous=self.ambiguous, safe=self.safe, undecided=self.undecided,
                    lo=self.lo, hi=self.hi, exact=self.exact, nodes_bounded=self.nodes_bounded,
                    nodes_total=self.nodes_total, points_enumerated=self.points_enumerated,
                    leaves_enumerated=self.leaves_enumerated, certified_safe_nodes=self.certified_safe_nodes,
                    certified_fail_nodes=self.certified_fail_nodes, max_depth=self.max_depth,
                    seconds=round(self.seconds, 3), flops=self.flops, fpe=self.fpe, stopped=self.stopped)


def bab(net: MLP, r_enum: int = 6, max_nodes: int = 10 ** 8, max_fpe: float = math.inf, alpha_iters: int = 0,
        alpha_max_free: int = 10, phase_depth: int = 0, phase_iters: int = 30, phase_max_free: int = 8,
        branch: str = "score", batch: int = 4096, probe: int = 512, min_rate: float = 0.01,
        stop_on_failure: bool = False, time_limit: float = math.inf, max_frontier: int = 1 << 24,
        bounder: Bounder | None = None,
        rng: np.random.Generator | None = None, verbose: bool = False, collect: list | None = None) -> BabResult:
    """Breadth-first input branch and bound (see the module docstring).

    r_enum: subcubes with at most this many free coordinates are enumerated.
    max_nodes, max_fpe: budgets on the number of tree nodes and on the cost
      (forward-pass equivalents, bounding and enumeration together); when
      processing the next level could exceed either, the frontier becomes the
      undecided set.
    alpha_iters: slope-optimisation iterations (one hidden layer), applied to
      the nodes that plain CROWN leaves undecided, at levels with at most
      alpha_max_free free coordinates.
    phase_depth, phase_iters, phase_max_free: at levels with at most
      phase_max_free free coordinates, nodes left undecided by the slopes are
      bounded again by Bounder.phase_bound (2^phase_depth phase leaves of the
      loosest units with a_j < 0; one hidden layer).
    branch: 'score' (per-node looseness score from the bound pass) or
      'static' (one global order: decreasing column sums of the product of
      the absolute weight matrices, sum_j |a_j| |W_ji| for one hidden layer).
    probe, min_rate: at a level with more than `probe` nodes, a random probe
      of `probe` nodes is bounded first; if less than a fraction min_rate of
      it is certified, the other nodes of the level are split without being
      bounded (they cannot be certified anyway at that rate; this saves cost
      and never affects validity). min_rate = 0 bounds every node.
    stop_on_failure: stop as soon as a failing point is certified (for
      certifying p = 0 or refuting it).
    max_frontier: the breadth-first frontier is capped at this many subcubes
      (memory); a level whose children could exceed it ends the run.
    collect: a list that receives the failing points found by enumeration
      (certified failing subcubes go to res.fail_cubes).
    Costs are counted in flops and in forward-pass equivalents (fpe).
    """
    t0 = time.time()
    rng = rng or np.random.default_rng(0)
    bd = bounder or Bounder(net)
    d = bd.d
    res = BabResult(d=d)
    thr_safe = bd.thr_safe
    thr_fail = bd.thr_fail
    col = np.abs(bd.Ws[-1])
    for k in range(bd.L, 0, -1):
        col = col @ bd.absW[k - 1]
    static_order = np.argsort(-col[0])
    frontier = np.zeros((1, d), dtype=np.int8)
    depth = 0

    def split(X, j):
        rows = np.arange(X.shape[0])
        Xp = X.copy()
        Xm = X.copy()
        Xp[rows, j] = 1
        Xm[rows, j] = -1
        return [Xp, Xm]

    def static_var(X):
        pos = np.argmax((X == 0)[:, static_order], axis=1)
        return static_order[pos]

    while frontier.shape[0] > 0:
        n = frontier.shape[0]
        r = d - depth
        npts = 1 << r
        lev = dict(depth=depth, free=r, nodes=n)
        res.max_depth = depth
        fpe_now = res.flops / bd.flops_forward
        level_fpe = n * (bd.enum_flops(r) if r <= r_enum else bd.crown_flops() + (
            bd.alpha_flops(alpha_iters) if alpha_iters and bd.L == 1 and r <= alpha_max_free else 0.0)) / bd.flops_forward
        over_budget = (res.nodes_total + n > max_nodes + 1 or fpe_now + level_fpe > max_fpe
                       or (r > r_enum and 2 * n > max_frontier))
        if (over_budget or time.time() - t0 > time_limit) and depth > 0:
            res.undecided += n * npts
            res.undecided_cubes = frontier
            res.stopped = "budget" if over_budget else "time"
            lev.update(undecided=n)
            res.levels.append(lev)
            break
        res.nodes_total += n
        if r <= r_enum:
            nf_tot = na_tot = 0
            for s in range(0, n, batch):
                nf, na = bd.enumerate_subcubes(frontier[s:s + batch], collect=collect)
                nf_tot += int(nf.sum())
                na_tot += int(na.sum())
            res.fail += nf_tot
            res.ambiguous += na_tot
            res.safe += n * npts - nf_tot - na_tot
            res.points_enumerated += n * npts
            res.leaves_enumerated += n
            res.flops += n * bd.enum_flops(r)
            lev.update(enumerated=n, fail_points=nf_tot)
            res.levels.append(lev)
            if verbose:
                print(lev, flush=True)
            break
        # probe
        if min_rate > 0 and n > probe:
            perm = rng.permutation(n)
            order = [frontier[perm[:probe]], frontier[perm[probe:]]]
        else:
            order = [frontier]
        children = []
        n_safe = n_fail = n_bounded = 0
        bound_rest = True
        for gi, group in enumerate(order):
            if gi == 1 and not bound_rest:
                for s in range(0, group.shape[0], batch):
                    X = group[s:s + batch]
                    children += split(X, static_var(X))
                continue
            g_safe = 0
            for s in range(0, group.shape[0], batch):
                X = group[s:s + batch]
                lb, ub, score = bd.bound(X)
                res.nodes_bounded += X.shape[0]
                n_bounded += X.shape[0]
                res.flops += X.shape[0] * bd.crown_flops()
                if alpha_iters and bd.L == 1 and r <= alpha_max_free:
                    und = np.nonzero((lb < thr_safe) & (ub >= thr_fail))[0]
                    if und.size:
                        lb_a = bd.alpha_bound(X[und], alpha_iters)
                        lb[und] = np.maximum(lb[und], lb_a)
                        res.flops += und.size * bd.alpha_flops(alpha_iters)
                if phase_depth and bd.L == 1 and r <= phase_max_free:
                    und = np.nonzero((lb < thr_safe) & (ub >= thr_fail))[0]
                    if und.size:
                        lb_p, _ = bd.phase_bound(X[und], phase_depth, phase_iters)
                        lb[und] = np.maximum(lb[und], lb_p)
                        res.flops += und.size * bd.phase_flops(phase_depth, phase_iters)
                safe = lb >= thr_safe
                fail = ub < thr_fail
                if collect is not None and fail.any():
                    res.fail_cubes.append(X[fail].copy())
                g_safe += int(safe.sum()) + int(fail.sum())
                n_safe += int(safe.sum())
                n_fail += int(fail.sum())
                keep = ~(safe | fail)
                X = X[keep]
                if X.shape[0] == 0:
                    continue
                j = static_var(X) if branch == "static" else np.argmax(score[keep], axis=1)
                children += split(X, j)
            if gi == 0 and len(order) == 2:
                bound_rest = g_safe >= min_rate * group.shape[0]
        res.safe += n_safe * npts
        res.fail += n_fail * npts
        res.certified_safe_nodes += n_safe
        res.certified_fail_nodes += n_fail
        lev.update(bounded=n_bounded, safe=n_safe, fail=n_fail)
        res.levels.append(lev)
        if verbose:
            print(lev, flush=True)
        frontier = np.concatenate(children) if children else frontier[:0]
        if stop_on_failure and res.fail > 0:
            res.undecided += frontier.shape[0] * (npts // 2)
            res.undecided_cubes = frontier
            res.stopped = "failure found"
            break
        depth += 1
    assert res.fail + res.ambiguous + res.safe + res.undecided == 1 << d
    res.seconds = time.time() - t0
    res.fpe = res.flops / bd.flops_forward
    return res


# --------------------------------------------------------------------------
# sampling inside the undecided subcubes (envelope estimator)


@dataclass
class TwoSided:
    lo: float
    hi: float
    samples: int
    det_lo: float
    det_hi: float
    Z_undecided: float
    hits: int

    @property
    def ratio(self) -> float:
        return self.hi / self.lo if self.lo > 0 else math.inf


def estimate_undecided(net: MLP, res: BabResult, eps: float, delta: float, rng: np.random.Generator,
                       max_samples: int = 10 ** 8, first: int = 1024, bounder: Bounder | None = None,
                       chunk: int = 1 << 18) -> TwoSided:
    """Two-sided interval for p from a B&B result: p = F/2^d + Z_u mu with
    Z_u the undecided mass and mu = Pr[fail | undecided union]. mu is
    estimated from exact uniform samples of the union (all undecided subcubes
    of a BFS frontier have the same size, so a uniform cube then uniform free
    bits is exact). Doubling batches, KL intervals at level delta_j = 6 delta /
    (pi^2 j^2); stops when hi <= (1 + eps) lo or at max_samples (still valid)."""
    bd = bounder or Bounder(net)
    d = res.d
    F = res.fail / 2.0 ** d
    if res.undecided == 0:
        return TwoSided(res.lo, res.hi, 0, res.lo, res.hi, 0.0, 0)
    cubes = res.undecided_cubes
    Zu = res.undecided / 2.0 ** d
    amb = res.ambiguous / 2.0 ** d
    N = kd = ka = 0
    j = 0
    k = first
    lo, hi = F, res.hi
    while N < max_samples:
        j += 1
        k = min(k, max_samples - N)
        for s0 in range(0, k, chunk):
            kk = min(chunk, k - s0)
            idx = rng.integers(0, cubes.shape[0], size=kk)
            X = cubes[idx].astype(np.float64)
            Z = rng.choice([-1.0, 1.0], size=X.shape)
            X = np.where(X == 0, Z, X)
            f = bd.forward(X)
            kd += int((f < bd.pt_fail).sum())
            ka += int(((f >= bd.pt_fail) & (f < bd.pt_safe)).sum())
        N += k
        dj = delta * 6.0 / (math.pi ** 2 * j * j)
        # kd / N is one correctly rounded division: relative error <= 2^-53
        l1, _ = kl_interval(kd / N, N, dj, rel_err=2.0 ** -52)
        _, h1 = kl_interval((kd + ka) / N, N, dj, rel_err=2.0 ** -52)
        # p = F + Zu mu; F and Zu are exact dyadic rationals; round outwards
        l = (F + Zu * l1) * (1 - 2.0 ** -50)
        h = min(res.hi, (F + amb + Zu * h1) * (1 + 2.0 ** -50))
        lo, hi = max(lo, l), min(hi, h)
        if lo > 0 and hi <= (1 + eps) * lo:
            break
        k = N
    return TwoSided(lo, hi, N, res.lo, res.hi, Zu, kd)


# --------------------------------------------------------------------------
# the box barrier


def box_search(net: MLP, X0: np.ndarray, iters: int = 200, starts: int = 4, lr: float = 0.05,
               rng: np.random.Generator | None = None) -> np.ndarray:
    """Smallest f found at real points of each subcube's box by projected
    gradient descent (starts: the box centre and random points). A value
    < t proves that no box-valid bound can certify the subcube safe. Not a
    bound in the other direction (local search)."""
    rng = rng or np.random.default_rng(0)
    X0 = np.asarray(X0, dtype=np.float64)
    R = X0 == 0
    best = np.full(X0.shape[0], np.inf)
    Ws, bs = net.Ws, net.bs
    for s in range(starts):
        Y = np.where(R, 0.0 if s == 0 else rng.uniform(-1, 1, X0.shape), X0)
        for it in range(iters):
            # forward with cache
            hs = [Y]
            pres = []
            h = Y
            for W, b in zip(Ws[:-1], bs[:-1]):
                z = h @ W.T + b
                pres.append(z)
                h = np.maximum(z, 0.0)
                hs.append(h)
            f = (h @ Ws[-1].T + bs[-1])[:, 0]
            best = np.minimum(best, f)
            g = np.broadcast_to(Ws[-1][0], (Y.shape[0], Ws[-1].shape[1]))
            for k in range(len(Ws) - 2, -1, -1):
                g = (g * (pres[k] > 0)) @ Ws[k]
            Y = np.where(R, np.clip(Y - lr * g, -1.0, 1.0), X0)
        h = Y
        for W, b in zip(Ws[:-1], bs[:-1]):
            h = np.maximum(h @ W.T + b, 0.0)
        best = np.minimum(best, (h @ Ws[-1].T + bs[-1])[:, 0])
    return best


def lp_bound_1hidden(net: MLP, x0: np.ndarray) -> float:
    """The LP (triangle) relaxation value over one subcube's box, for one
    hidden layer, by scipy's HiGHS: a diagnostic of how far the optimised
    slopes are from the LP optimum (floating-point solver: NOT used for
    certification)."""
    from scipy.optimize import linprog
    W, b = net.Ws[0], net.bs[0]
    a, c = net.Ws[1][0], net.bs[1][0]
    x0 = np.asarray(x0, dtype=np.float64)
    free = np.nonzero(x0 == 0)[0]
    r = len(free)
    m = W.shape[0]
    zc = W @ x0 + b
    rad = np.abs(W[:, free]).sum(1)
    l, u = zc - rad, zc + rad
    # variables: y (r), h (m)
    cvec = np.concatenate([np.zeros(r), a])
    A_ub, b_ub = [], []
    bounds = [(-1, 1)] * r
    hb = []
    for j in range(m):
        if l[j] >= 0:
            # h = z
            hb.append((None, None))
        elif u[j] <= 0:
            hb.append((0, 0))
        else:
            hb.append((0, None))
    bounds += hb
    A_eq, b_eq = [], []
    for j in range(m):
        row = np.zeros(r + m)
        if l[j] >= 0:
            row[:r] = -W[j, free]
            row[r + j] = 1
            A_eq.append(row)
            b_eq.append(zc[j])
        elif u[j] > 0:
            # h >= z
            row[:r] = W[j, free]
            row[r + j] = -1
            A_ub.append(row)
            b_ub.append(-zc[j])
            # h <= lam (z - l)
            lam = u[j] / (u[j] - l[j])
            row2 = np.zeros(r + m)
            row2[:r] = -lam * W[j, free]
            row2[r + j] = 1
            A_ub.append(row2)
            b_ub.append(lam * (zc[j] - l[j]))
    resl = linprog(cvec, A_ub=np.array(A_ub) if A_ub else None, b_ub=np.array(b_ub) if b_ub else None,
                   A_eq=np.array(A_eq) if A_eq else None, b_eq=np.array(b_eq) if b_eq else None,
                   bounds=bounds, method="highs")
    return float(resl.fun + c)


# --------------------------------------------------------------------------
# the tree a perfect deductive engine would need (diagnostic)


def oracle_tree_static(fail_points: np.ndarray, d: int, order=None, r_stop: int = 0) -> dict:
    """Input branch and bound with a PERFECT engine: a subcube is decided as
    soon as it contains no failing point (safe) or only failing points
    (failing); otherwise it is split on the next coordinate of the fixed
    `order` (default 0, 1, ..., d-1). Subcubes with <= r_stop free
    coordinates are leaves (enumerated). fail_points: (F, d) array of +-1,
    the exact failing set (from an exact run with collect=...).

    Returns the number of tree nodes, the number of impure (split) nodes per
    depth and the number of enumerated leaves. Diagnostic only: deciding a
    subcube exactly is itself a hard problem (the minimum of f over it), so
    this measures how much of the cost of real branch and bound is due to the
    geometry of the failing set and how much to the looseness of the bounds."""
    X = np.asarray(fail_points)
    order = np.arange(d) if order is None else np.asarray(order)
    F = X.shape[0]
    nodes = 1
    impure = []
    if F == 0:
        return dict(nodes=1, impure=[], leaves_enumerated=0, F=0)
    bits = (X[:, order] > 0).astype(np.int64)
    key = np.zeros(F, dtype=object) if d > 62 else np.zeros(F, dtype=np.int64)
    leaves = 0
    for k in range(0, d - r_stop + 1):
        # nodes at depth k that exist: children of impure nodes at depth k-1
        if k > 0:
            key = key * 2 + bits[:, k - 1]
        uniq, cnt = np.unique(key, return_counts=True)
        full = 1 << (d - k)
        n_imp = int((cnt < full).sum())
        if k == d - r_stop:
            leaves = n_imp
            break
        impure.append(n_imp)
        nodes += 2 * n_imp
        if n_imp == 0:
            break
    return dict(nodes=int(nodes), impure=impure, leaves_enumerated=int(leaves), F=int(F))


def oracle_tree_greedy(fail_points: np.ndarray, d: int, r_stop: int = 0) -> dict:
    """The same with an adaptive order: in every impure subcube, split the
    free coordinate on which its failing points are most unbalanced (if they
    all agree on it, one child is safe at once). A heuristic for a small
    tree; the tree of an optimal order can only be smaller."""
    X = (np.asarray(fail_points) > 0).astype(np.int8)
    F = X.shape[0]
    if F == 0:
        return dict(nodes=1, leaves_enumerated=0, F=0)
    nodes = 1
    leaves = 0
    stack = [(np.arange(F), np.ones(d, dtype=bool))]
    while stack:
        idx, free = stack.pop()
        r = int(free.sum())
        n = idx.size
        if n == 0 or n == (1 << r):
            continue  # pure
        if r <= r_stop:
            leaves += 1
            continue
        S = X[idx][:, free]
        ones = S.sum(0)
        j_loc = int(np.argmax(np.abs(2 * ones.astype(np.int64) - n)))
        j = np.nonzero(free)[0][j_loc]
        fr = free.copy()
        fr[j] = False
        nodes += 2
        m = X[idx, j] == 1
        stack.append((idx[m], fr))
        stack.append((idx[~m], fr))
    return dict(nodes=int(nodes), leaves_enumerated=int(leaves), F=int(F))


# --------------------------------------------------------------------------
# cost of Monte Carlo


def mc_cost(p: float, eps: float, delta: float) -> float:
    """Samples Monte Carlo needs for ratio 1 + eps: 3 ln(2/delta) / (eps^2 p)."""
    return 3.0 * math.log(2.0 / delta) / (eps * eps * p) if p > 0 else math.inf


# --------------------------------------------------------------------------
# diagnostics with a MILP solver (floating-point, NOT used for certification)


def milp_min(net: MLP, x0: np.ndarray, integer: bool = True, time_limit: float = 60.0, want_info: bool = False):
    """min f over the subcube x0 (integer=True: its points; False: its box)
    by the big-M MILP encoding of the ReLUs, solved by scipy's HiGHS. The
    intervals [l, u] come from Bounder (valid). Returns (value, x, status,
    mip nodes), or with want_info a dict that also has the solver's dual
    bound and f re-evaluated at x. HiGHS works with floating-point
    tolerances and its proof is not checkable here, so the value and the
    dual bound are diagnostics, NOT certificates; a returned point x is
    re-evaluated, which makes "f(x) < t" a checkable witness (a sound lower
    bound p >= 2^-d)."""
    from scipy.optimize import Bounds, LinearConstraint, milp
    bd = Bounder(net)
    x0 = np.asarray(x0, dtype=np.float64)
    free = np.nonzero(x0 == 0)[0]
    r = len(free)
    bounds, _, _ = bd.layer_bounds(x0[None], (x0 == 0)[None].astype(np.float64))
    # variable layout: y (r) | per hidden layer k: z_k (m), h_k (m), s_k (m)
    sizes = bd.widths
    nv = r + 3 * sum(sizes)
    off = [r]
    for m in sizes[:-1]:
        off.append(off[-1] + 3 * m)
    lo = np.full(nv, -np.inf)
    hi = np.full(nv, np.inf)
    integ = np.zeros(nv)
    lo[:r], hi[:r] = -1.0, 1.0
    if integer:
        integ[:r] = 1  # y in {-1, 0, 1} with |y| = 1 enforced below via y = 2 v - 1
    rows, rlo, rhi = [], [], []
    # y = 2 v - 1 trick: use extra binaries v for integrality of +-1
    extra = r if integer else 0
    nv2 = nv + extra
    lo = np.concatenate([lo, np.zeros(extra)])
    hi = np.concatenate([hi, np.ones(extra)])
    integ = np.concatenate([np.zeros(nv), np.ones(extra)])
    for i in range(extra):
        R = np.zeros(nv2)
        R[i] = 1.0
        R[nv + i] = -2.0
        rows.append(R)
        rlo.append(-1.0)
        rhi.append(-1.0)
    prev_idx = None  # indices of h_{k-1}
    for k, m in enumerate(sizes):
        zi = off[k] + np.arange(m)
        hi_idx = off[k] + m + np.arange(m)
        si = off[k] + 2 * m + np.arange(m)
        l, u = bounds[k][0][0], bounds[k][1][0]
        lo[zi], hi[zi] = l, u
        lo[hi_idx], hi[hi_idx] = 0.0, np.maximum(u, 0.0)
        lo[si], hi[si] = 0.0, 1.0
        integ[si] = 1
        W, b = bd.Ws[k], bd.bs[k]
        for j in range(m):
            R = np.zeros(nv2)
            R[zi[j]] = 1.0
            if k == 0:
                R[:r] = -W[j, free]
                rhs = b[j] + W[j] @ x0
            else:
                R[prev_idx] = -W[j]
                rhs = b[j]
            rows.append(R); rlo.append(rhs); rhi.append(rhs)
            # h >= z
            R = np.zeros(nv2); R[hi_idx[j]] = 1.0; R[zi[j]] = -1.0
            rows.append(R); rlo.append(0.0); rhi.append(np.inf)
            if l[j] < 0 < u[j]:
                # h <= z - l (1 - s)
                R = np.zeros(nv2); R[hi_idx[j]] = 1.0; R[zi[j]] = -1.0; R[si[j]] = -l[j]
                rows.append(R); rlo.append(-np.inf); rhi.append(-l[j])
                # h <= u s
                R = np.zeros(nv2); R[hi_idx[j]] = 1.0; R[si[j]] = -u[j]
                rows.append(R); rlo.append(-np.inf); rhi.append(0.0)
            elif l[j] >= 0:
                R = np.zeros(nv2); R[hi_idx[j]] = 1.0; R[zi[j]] = -1.0
                rows.append(R); rlo.append(-np.inf); rhi.append(0.0)
            else:
                hi[hi_idx[j]] = 0.0
        prev_idx = hi_idx
    cost = np.zeros(nv2)
    cost[prev_idx] = bd.Ws[-1][0]
    res = milp(cost, constraints=LinearConstraint(np.array(rows), rlo, rhi), integrality=integ,
               bounds=Bounds(lo, hi), options=dict(time_limit=time_limit))
    info = dict(status=int(res.status), message=str(res.message), nodes=getattr(res, "mip_node_count", None),
                dual_bound=(float(res.mip_dual_bound + bd.bs[-1][0])
                            if getattr(res, "mip_dual_bound", None) is not None else None),
                value=None, x=None, f_x=None)
    if res.x is None:
        return (info if want_info else (np.nan, None, res.status, None))
    x = x0.copy()
    x[free] = res.x[:r]
    if integer:
        x[free] = np.where(x[free] > 0, 1.0, -1.0)
    info.update(value=float(res.fun + bd.bs[-1][0]), x=x, f_x=float(bd.forward(x[None])[0]))
    if want_info:
        return info
    return float(res.fun + bd.bs[-1][0]), x, res.status, getattr(res, "mip_node_count", None)
