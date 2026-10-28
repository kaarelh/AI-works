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
          from above the chord through its interval; intermediate intervals
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
  verifier recomputes every interval, slope of a chord, quadratic
  coefficient and matrix itself from the net and the prover's free
  parameters (alpha in [0, 1] after clipping, theta in [0, 1]^2 after
  clipping, mu, s); a free parameter can only make a bound weaker, never
  wrong.
* Floating point. Every computed bound is a straight-line program in +, -,
  x, |.| and max(., 0) of the float inputs (weights, biases, the subcube,
  the prover's parameters and the verifier's own slopes, which are treated
  as exact parameters whose validity is checked separately). For any
  evaluation order its error is at most gamma_D times the same program run
  on absolute values (Higham, Lemma 3.1 / 3.4), with D < 2^20 operations
  along any path (asserted), so gamma_D < 2^-32; we carry the absolute
  version along and subtract REL = 2^-30 times it (plus 2^-1000 for
  underflow). Chord slopes are fl(U / fl(U - L)) (1 + 2^-26), which exceeds
  U / (U - L) exactly; they are re-checked and replaced by 1 (always valid
  for L <= 0) otherwise. Units whose backward coefficient G_j is so small
  that its sign is uncertain (|G_j| <= 5 REL |G|_abs) are dropped and
  charged 5 REL |G|_abs max(U_j, 0), so the choice of relaxation side never
  depends on a rounded sign.
* PSD check. Higham (Thm 10.3): if Cholesky in floating point runs to
  completion on A_f (any order of the inner products), then
  R^T R = A_f + dA with |dA| <= gamma_{n+1} |R^T||R|, hence
  lambda_min(A_f) >= -gamma tr(A_f) / (1 - gamma) (use ||R||_F^2 = tr(R^T R)).
  We run our own textbook Cholesky on A_f = fl(A - c I) with c larger than
  that, plus the Frobenius norm of the entrywise error bound of A; so the
  exact matrix M - diag(mu) - s I is PSD. (We use gamma_{2n+4}.)
* Points. An enumerated or sampled point is classified from its float64
  value, whose error is at most REL (|f|_abs + 1) =: tau for any summation
  order (|f|_abs the absolute forward pass over the cube); thresholds
  t +- tau are rounded outwards once (Fractions). Points with
  |f_float - t| <= tau are re-evaluated in exact rational arithmetic. So the
  counts F are exact for the exact-arithmetic net, and sampled indicators
  are exact.
* Sampling. Exact uniform draws from the open union (a uniform integer
  below Z by rejection, then the leaf containing it), indicator of failure
  in {0, 1}, Hoeffding-KL interval at level delta (stats.kl_interval): the
  only randomness, so Pr[p not in output] <= delta.

None of this uses training or any property of the weights.

The prover
----------
`prove` builds such a tree breadth first: at each node it tries 'lin' with
default and then optimised slopes (projected supergradient ascent on the
exact bound), 'lin' for FAIL, then 'quad' (Adam on a smoothed eigenvalue
objective) for nodes whose 'lin' bound is within a window of t; it splits
the remaining nodes on the coordinate chosen by strong branching (largest
worse-child bound among the top-k coordinates by influence on the unstable
units), stops at r <= r_leaf (ENUM), and finally replaces every subtree
whose verification costs more than enumerating its subcube by ENUM. With
open_policy="auto" (or "both") it then turns failure-containing subtrees
into OPEN leaves, top down, wherever sampling them (to ratio 1 + eps) is
cheaper than verifying them. `knuth_estimate` estimates the size and cost of
the prover's tree from random root-to-leaf probes; `witness_lower_bound`
checks a list of failing points (lower bounds need no deduction).
Costs are counted in floating-point operations and reported in forward-pass
equivalents (fpe): flops / flops of one evaluation of the net (see the cost
model in CertNet: an incremental verifier that updates the first-layer
offsets along the tree).
"""

from __future__ import annotations

import math
import time
from dataclasses import dataclass, field
from fractions import Fraction

import numpy as np

from .nets import MLP
from .stats import kl_interval

U53 = 2.0 ** -53
REL = 2.0 ** -30
TINY = 2.0 ** -1000
LAM_UP = 1.0 + 2.0 ** -26  # chord slopes are inflated by this (>> the 2^-30 rounding budget)

# leaf / node codes of the serialised tree
SPLIT, SAFE, FAIL, ENUM, OPEN = "split", "safe", "fail", "enum", "open"
_DEBUG = False


def _lo(x, err):
    """A float <= every real v with |v - x| <= err (x, err computed floats;
    err may itself be off by a relative 2^-40)."""
    return x - err * (1.0 + 2.0 ** -40) - np.abs(x) * 2.0 ** -50 - TINY


def _hi(x, err):
    return x + err * (1.0 + 2.0 ** -40) + np.abs(x) * 2.0 ** -50 + TINY


def _gamma(n: int) -> float:
    return n * U53 / (1.0 - n * U53)


def _round_down(q: Fraction) -> float:
    x = float(q)
    while Fraction(x) > q:
        x = math.nextafter(x, -math.inf)
    return x


def _round_up(q: Fraction) -> float:
    x = float(q)
    while Fraction(x) < q:
        x = math.nextafter(x, math.inf)
    return x


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
        # longest chain of floating-point operations along any path of any
        # computed quantity (bounds, matrices, Cholesky pivots): well below 2^20
        n_ops = 8 * sum(dims) + 4 * (self.d + 2) ** 2 + 64
        if n_ops >= 2 ** 20:
            raise ValueError("network too large for the fixed rounding budget REL")
        rho = np.ones(self.d)
        for k in range(self.L + 1):
            rho = self.absW[k] @ rho + self.absb[k]
            if not np.isfinite(rho).all() or rho.max() > 1e290:
                raise ValueError("weights too large for float64 bounds")
        self.absf = float(rho[0])
        self.tau_pt = REL * (self.absf * (1.0 + 2.0 ** -40) + 1.0)
        T, tau = Fraction(self.t), Fraction(self.tau_pt)
        self.pt_fail = _round_down(T - tau)  # f_float < this  => f < t exactly
        self.pt_safe = _round_up(T + tau)  # f_float >= this => f >= t exactly
        self.fpe_flops = 2.0 * sum(a * b for a, b in zip(dims[:-1], dims[1:]))
        self._exact = None
        self.n_exact_evals = 0

    # ---- point evaluation ---------------------------------------------------
    def forward(self, X: np.ndarray) -> np.ndarray:
        h = np.asarray(X, dtype=np.float64)
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

    def classify(self, X: np.ndarray, fvals: np.ndarray) -> int:
        """Exact number of failing points among the rows of X, given their
        float64 values fvals (computed in any summation order)."""
        fails = int(np.count_nonzero(fvals < self.pt_fail))
        amb = np.nonzero((fvals >= self.pt_fail) & (fvals < self.pt_safe))[0]
        T = Fraction(self.t)
        for i in amb:
            if self.exact_f(X[i]) < T:
                fails += 1
        return fails

    # ---- cost model (flops) ----------------------------------------------------
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
        tables = 2.0 * self.widths[0] * (r1 * 2 ** r1 + r2 * 2 ** r2)
        return tables + (2.0 ** r) * self.flops_point_enum()

    # The counts below are those of a verifier that walks the tree top down and
    # updates the first-layer offsets c = W_1 x0 + b_1, their absolute version
    # and the radii sum_{i free} |W_1[:, i]| by one column per edge (charged to
    # every node as flops_node), so that a leaf only pays for its free
    # coordinates. (The numpy implementation recomputes them per leaf, which
    # costs O(m_1 d) more per leaf and gives the same guarantees.)
    def flops_node(self) -> float:
        return 6.0 * self.widths[0] + 1.0

    def _back_flops(self, ktop: int, r: int) -> float:
        """One backward pass (value and absolute version) from layer ktop
        to the free inputs, for one row."""
        dims = [r] + self.widths + [1]
        f = 0.0
        for k in range(ktop, 1, -1):
            f += 2.0 * (2.0 * dims[k] * dims[k - 1]) + 12.0 * dims[k - 1]
        # first layer: Lam_1 . c (fixed part) and Lam_1 W_1[:, free]
        f += 2.0 * (2.0 * dims[1] + 2.0 * dims[1] * r) + 2.0 * r
        return f

    def flops_lin(self, r: int) -> float:
        """One 'lin' check: intermediate bounds (2 m_k rows for every hidden
        layer k >= 2) and the output pass."""
        m = self.widths
        f = 0.0
        for k in range(2, self.L + 1):
            f += 2 * m[k - 1] * self._back_flops(k, r)
        return f + self._back_flops(self.L + 1, r)

    def flops_quad(self, r: int) -> float:
        """'lin' up to h_1, the quadratic coefficients, M and its absolute
        version, the Cholesky factorisation."""
        n = r + 1
        m1 = self.widths[0]
        return self.flops_lin(r) + 40.0 * m1 + 2.0 * (2.0 * m1 * n * n + 2.0 * m1 * n) + n ** 3 / 3.0 + 4.0 * n * n

    # ---- interval bounds over subcubes ------------------------------------------
    def layer1(self, X0: np.ndarray):
        """X0: (B, d) in {-1, 0, +1} (0 = free). Returns c (B, m1), c_abs, and
        the padded enclosures L1 <= z_1 <= U1 over each subcube."""
        X0 = np.asarray(X0, dtype=np.float64)
        F = (X0 == 0.0).astype(np.float64)
        c = X0 @ self.Ws[0].T + self.bs[0]
        c_abs = np.abs(X0) @ self.absW[0].T + self.absb[0]
        rad = F @ self.absW[0].T
        err = REL * (c_abs + rad)
        return c, c_abs, _lo(c - rad, err), _hi(c + rad, err)

    def intervals(self, X0: np.ndarray):
        """Padded enclosures [L_k, U_k] of every hidden pre-activation over
        each subcube; layers >= 2 by backward bound propagation with the
        verifier's own (adaptive) slopes. Also returns layer-1 c, c_abs."""
        X0 = np.asarray(X0, dtype=np.float64)
        c, c_abs, L1, U1 = self.layer1(X0)
        ivs = [(L1, U1)]
        B = X0.shape[0]
        for k in range(2, self.L + 1):
            m = self.widths[k - 1]
            eye = np.eye(m)
            Lam = np.concatenate([eye, -eye], 0)[None].repeat(B, 0)  # (B, 2m, m)
            val, vabs, extra = self._backward(Lam, np.abs(Lam), k, ivs, X0, None)
            lb = _lo(val, REL * vabs + extra)
            low = lb[:, :m]
            up = -lb[:, m:]
            ivs.append((low, up))
        return ivs, c, c_abs

    @staticmethod
    def _relax(G, Gabs, L, U, alpha):
        """Slopes and offsets relaxing h = relu(z), z in [L, U], on the side
        given by the sign of the coefficient G (lower if G >= 0). Shapes:
        G, Gabs (B, R, m); L, U (B, m); alpha None or (B, m). Returns slope,
        offset (B, R, m) and the charge for sign-uncertain units (B, R)."""
        L = L[:, None, :]
        U = U[:, None, :]
        act = L >= 0.0
        ina = U <= 0.0
        uns = ~(act | ina)
        with np.errstate(divide="ignore", invalid="ignore", over="ignore"):
            lam = np.where(uns, U / np.where(uns, U - L, 1.0) * LAM_UP, 0.0)
            # re-check lam (U - L) >= U exactly; otherwise use 1 (valid: L <= 0)
            chk = lam * U - lam * L - U
            chk_abs = lam * U + lam * np.abs(L) + U
            ok = np.isfinite(chk) & (chk - REL * chk_abs - TINY >= 0.0)
        lam = np.where(uns & ~ok, 1.0, lam)
        if alpha is None:
            a_lo = (U >= -L).astype(np.float64)
        else:
            a_lo = np.clip(np.nan_to_num(alpha, nan=0.0), 0.0, 1.0)[:, None, :]
        pos = G >= 0.0
        slope = np.where(act, 1.0, np.where(ina, 0.0, np.where(pos, a_lo, lam)))
        off = np.where(uns & ~pos, -lam * L, 0.0)
        unc = uns & (np.abs(G) <= 5.0 * REL * Gabs)
        slope = np.where(unc, 0.0, slope)
        off = np.where(unc, 0.0, off)
        charge = (np.where(unc, 5.0 * REL * Gabs * np.maximum(U, 0.0), 0.0)).sum(-1)
        return slope, off, charge

    def _backward(self, Lam, Lam_abs, ktop, ivs, X0, alphas, stop_h1=False):
        """Lower bound of Lam . z_ktop over each subcube (ktop = L + 1 is the
        output). Lam: (B, R, m_ktop). alphas: None or list over hidden layers
        (index k - 1 for layer k) of (B, m_k) arrays or None.
        Returns (val, val_abs, extra) with val - extra a lower bound up to
        rounding REL * val_abs; with stop_h1, returns the coefficients on
        h_1 instead: (G, G_abs, const, const_abs, extra)."""
        B, R, _ = Lam.shape
        const = np.zeros((B, R))
        cabs = np.zeros((B, R))
        extra = np.zeros((B, R))
        for k in range(ktop, 1, -1):  # z_k = W_k h_{k-1} + b_k
            W, b = self.Ws[k - 1], self.bs[k - 1]
            const += Lam @ b
            cabs += Lam_abs @ self.absb[k - 1]
            G = Lam @ W
            Gabs = Lam_abs @ self.absW[k - 1]
            if stop_h1 and k == 2:
                return G, Gabs, const, cabs, extra
            Lk, Uk = ivs[k - 2]
            al = None if alphas is None else alphas[k - 2]
            slope, off, charge = self._relax(G, Gabs, Lk, Uk, al)
            Lam = G * slope
            Lam_abs = Gabs * np.abs(slope)
            const += (G * off).sum(-1)
            cabs += (Gabs * np.abs(off)).sum(-1)
            extra += charge
        const += Lam @ self.bs[0]
        cabs += Lam_abs @ self.absb[0]
        g = Lam @ self.Ws[0]
        gabs = Lam_abs @ self.absW[0]
        X0 = np.asarray(X0, dtype=np.float64)
        F = (X0 == 0.0).astype(np.float64)
        val = const + (g * X0[:, None, :]).sum(-1) - (np.abs(g) * F[:, None, :]).sum(-1)
        vabs = cabs + (gabs * np.abs(X0)[:, None, :]).sum(-1) + (gabs * F[:, None, :]).sum(-1)
        return val, vabs, extra

    # ---- certificate checks ----------------------------------------------------------
    def check_lin(self, X0: np.ndarray, alphas, sign: int, ivs=None):
        """Rigorous lower bound of sign * f over each subcube with the given
        slopes. Returns an array of floats (B,) (-inf where malformed)."""
        X0 = np.asarray(X0, dtype=np.float64)
        B = X0.shape[0]
        if ivs is None:
            ivs, _, _ = self.intervals(X0)
        Lam = np.full((B, 1, 1), float(sign))
        val, vabs, extra = self._backward(Lam, np.abs(Lam), self.L + 1, ivs, X0, alphas)
        lb = _lo(val, REL * vabs + extra)[:, 0]
        return np.where(np.isfinite(lb), lb, -np.inf)

    def quad_matrix(self, x0: np.ndarray, alphas, theta, sign: int = 1, ivs=None, c_data=None):
        """The matrix M (n x n, n = r + 1) of the quadratic minorant
        Y^T M Y <= sign * f on the subcube x0 (Y = (free coordinates, 1)),
        built from the prover's theta exactly as the verifier builds it,
        with its absolute version Ma and the charge `extra`."""
        x0 = np.asarray(x0, dtype=np.float64).reshape(1, -1)
        free = np.nonzero(x0[0] == 0.0)[0]
        m1 = self.widths[0]
        theta = np.asarray(theta, dtype=np.float64)
        if theta.shape != (m1, 2):
            raise ValueError("theta: wrong shape")
        theta = np.clip(np.nan_to_num(theta, nan=0.0), 0.0, 1.0)
        if ivs is None:
            ivs, c, c_abs = self.intervals(x0)
        else:
            c, c_abs = c_data
        Lam = np.full((1, 1, 1), float(sign))
        G, Gabs, const, cabs, extra = self._backward(Lam, np.abs(Lam), self.L + 1, ivs, x0, alphas, stop_h1=True)
        G, Gabs = G[0, 0], Gabs[0, 0]
        const, cabs, extra = float(const[0, 0]), float(cabs[0, 0]), float(extra[0, 0])
        L1, U1 = ivs[0][0][0], ivs[0][1][0]
        c, c_abs = c[0], c_abs[0]
        kap, bet, gam, ex2 = _quad_coeffs(G, Gabs, L1, U1, theta)
        extra += ex2
        V = self.Ws[0][:, free]
        Vt = np.concatenate([V, c[:, None]], 1)  # (m1, n)
        Vta = np.concatenate([np.abs(V), c_abs[:, None]], 1)
        M = (Vt.T * (G * kap)) @ Vt
        Ma = (Vta.T * (Gabs * np.abs(kap))) @ Vta
        lin = Vt.T @ (G * bet)
        lina = Vta.T @ (Gabs * np.abs(bet))
        M[:, -1] += lin / 2.0
        M[-1, :] += lin / 2.0
        Ma[:, -1] += lina / 2.0
        Ma[-1, :] += lina / 2.0
        M[-1, -1] += const + float((G * gam).sum())
        Ma[-1, -1] += cabs + float((Gabs * np.abs(gam)).sum())
        return M, Ma, extra

    def check_quad(self, x0: np.ndarray, alphas, theta, mu, shift, sign: int = 1, ivs=None, c_data=None):
        """Rigorous lower bound of sign * f over one subcube from a 'quad'
        certificate, or -inf if the PSD check fails or anything is
        malformed."""
        x0 = np.asarray(x0, dtype=np.float64).reshape(1, -1)
        n = int((x0[0] == 0.0).sum()) + 1
        mu = np.asarray(mu, dtype=np.float64).ravel()
        shift = float(shift)
        if mu.shape != (n,) or not np.isfinite(mu).all() or not math.isfinite(shift):
            return -math.inf
        try:
            M, Ma, extra = self.quad_matrix(x0, alphas, theta, sign, ivs, c_data)
        except ValueError:
            return -math.inf
        if not (np.isfinite(M).all() and np.isfinite(Ma).all()):
            return -math.inf
        A = M - np.diag(mu) - shift * np.eye(n)
        if not np.isfinite(A).all():
            return -math.inf
        g = _gamma(2 * n + 4)
        tr = float(np.trace(A))
        tau_ch = g * max(tr, 0.0) * (1.0 + 2.0 ** -30) / (1.0 - g) + n * TINY
        # entrywise bound on |A_computed - A_exact| (M's rounding and the two
        # subtractions); forming A - cm I adds at most REL (|A_ii| + cm) <=
        # 1.01 E_ii + REL cm on the diagonal, so 3 (tau_ch + ||E||_F) covers all
        Etot = REL * (Ma + np.diag(np.abs(mu) + abs(shift)))
        frob = float(np.sqrt((Etot * Etot).sum())) * (1.0 + 2.0 ** -40)
        cm = 3.0 * (tau_ch + frob) + TINY
        Af = A - cm * np.eye(n)
        if not _cholesky_ok(Af):
            return -math.inf
        tot = float(mu.sum()) + n * shift
        tot_abs = float(np.abs(mu).sum()) + n * abs(shift)
        lb = _lo(tot, REL * tot_abs + extra)
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
        base = self.Ws[0] @ x0 + self.bs[0]
        A = Ya @ self.Ws[0][:, fa].T + base  # (2^r1, m1)
        Bt = Yb @ self.Ws[0][:, fb].T  # (2^r2, m1)
        rows = max(1, chunk // Bt.shape[0])
        fails = 0
        for s in range(0, A.shape[0], rows):
            Z = (A[s:s + rows, None, :] + Bt[None, :, :]).reshape(-1, A.shape[1])
            h = np.maximum(Z, 0.0)
            for W, b in zip(self.Ws[1:-1], self.bs[1:-1]):
                h = np.maximum(h @ W.T + b, 0.0)
            fv = (h @ self.Ws[-1].T + self.bs[-1])[:, 0]
            nf = int(np.count_nonzero(fv < self.pt_fail))
            amb = np.nonzero((fv >= self.pt_fail) & (fv < self.pt_safe))[0]
            if amb.size:
                nb = Bt.shape[0]
                T = Fraction(self.t)
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


def _quad_coeffs(G, Gabs, L, U, theta):
    """Per first-layer unit, a valid quadratic minorant (G_j > 0) or
    majorant (G_j < 0) q_j(z) = kap z^2 + bet z + gam of relu(z) on
    [L_j, U_j], built from the prover's theta_j = (s, rho) in [0, 1]^2:
      minorant  s (1 - rho) z + s rho z (z - L) / (U - L)   (convex; the second
                term is the quadratic through (L, 0), (0, 0), (U, U)),
      majorant  rho * (the convex quadratic through (L, 0) and (U, U) with
                curvature min(-L, U) / (U - L)^2) + (1 - rho) * chord.
    The constant is moved by a small margin (down for a minorant, up for a
    majorant) and every validity condition is then checked in floating point
    with rounding margins; a unit that fails is replaced by an always-valid
    relaxation (0 from below; z - L from above). Units of uncertain sign are
    dropped and charged. Returns kap, bet, gam, charge."""
    m = G.shape[0]
    kap = np.zeros(m)
    bet = np.zeros(m)
    gam = np.zeros(m)
    extra = 0.0
    for j in range(m):
        Lj, Uj = float(L[j]), float(U[j])
        if Lj >= 0.0:  # active: h = z
            bet[j] = 1.0
            continue
        if Uj <= 0.0:  # inactive: h = 0
            continue
        if abs(G[j]) <= 5.0 * REL * Gabs[j]:  # sign uncertain: drop, charge
            extra += 5.0 * REL * Gabs[j] * Uj
            continue
        s, rho = float(theta[j, 0]), float(theta[j, 1])
        w = Uj - Lj
        if G[j] > 0.0:
            k_ = s * rho / w
            b_ = s * (1.0 - rho) - s * rho * Lj / w
            if not (math.isfinite(k_) and math.isfinite(b_) and k_ >= 0.0):
                continue  # zero minorant
            g_ = -4.0 * REL * (k_ * (Lj * Lj + Uj * Uj) + abs(b_) * (abs(Lj) + Uj) + Uj) - TINY
            if _lower_ok(k_, b_, g_, Lj, Uj):
                kap[j], bet[j], gam[j] = k_, b_, g_
            # else: zero minorant (kap = bet = gam = 0)
        else:
            K = min(-Lj, Uj) / (w * w)
            k_ = rho * K * (1.0 - 2.0 ** -20)
            bp = Uj / w * LAM_UP - k_ * w
            ok = False
            if math.isfinite(k_) and math.isfinite(bp) and k_ >= 0.0:
                b_ = bp - 2.0 * k_ * Lj
                g_ = k_ * Lj * Lj - bp * Lj
                g_ += 4.0 * REL * (k_ * (Lj * Lj + Uj * Uj) + abs(b_) * (abs(Lj) + Uj) + abs(g_) + Uj) + TINY
                ok = _upper_ok(k_, b_, g_, Lj, Uj)
            if ok:
                kap[j], bet[j], gam[j] = k_, b_, g_
            else:  # z - L + margin >= relu(z) on [L, U] (L < 0)
                g_ = -Lj + 4.0 * REL * (abs(Lj) + Uj) + TINY
                kap[j], bet[j], gam[j] = 0.0, 1.0, g_
                if not _upper_ok(0.0, 1.0, g_, Lj, Uj):  # cannot happen; be safe
                    raise AssertionError("fallback majorant rejected")
    return kap, bet, gam, extra


def _lower_ok(k, b, g, L, U) -> bool:
    """Rigorous check that q(z) = k z^2 + b z + g <= relu(z) on [L, U]
    (L < 0 < U, k >= 0): for convex q this holds iff q(L) <= 0, q(0) <= 0
    and q(U) <= U."""
    if not (k >= 0.0 and math.isfinite(k) and math.isfinite(b) and math.isfinite(g)):
        return False
    qL = k * L * L + b * L + g
    aL = k * L * L + abs(b * L) + abs(g)
    qU = k * U * U + b * U + g - U
    aU = k * U * U + abs(b * U) + abs(g) + U
    return _hi(qL, REL * aL) <= 0.0 and _hi(g, 0.0) <= 0.0 and _hi(qU, REL * aU) <= 0.0


def _upper_ok(k, b, g, L, U) -> bool:
    """Rigorous check that q(z) = k z^2 + b z + g >= relu(z) on [L, U]
    (L < 0 < U, k >= 0), via the sufficient conditions
    q(L) >= 0, q'(L) >= 0 (q increasing on [L, 0]) and
    [(q-z)(U) >= 0, (q-z)'(U) <= 0] or [(q-z)(0) >= 0, (q-z)'(0) >= 0]."""
    if not (k >= 0.0 and math.isfinite(k) and math.isfinite(b) and math.isfinite(g)):
        return False
    qL = k * L * L + b * L + g
    aL = k * L * L + abs(b * L) + abs(g)
    vU = k * U * U + b * U + g - U
    aU = k * U * U + abs(b * U) + abs(g) + U
    if k == 0.0:
        # q linear: q >= 0 on [L, 0] iff q(L), q(0) >= 0; q - z >= 0 on [0, U]
        # iff (q - z)(0) = g >= 0 and (q - z)(U) >= 0
        return _lo(qL, REL * aL) >= 0.0 and _lo(g, 0.0) >= 0.0 and _lo(vU, REL * aU) >= 0.0
    dL = 2.0 * k * L + b
    adL = 2.0 * k * abs(L) + abs(b)
    if _lo(qL, REL * aL) < 0.0 or _lo(dL, REL * adL) < 0.0:
        return False
    dU = 2.0 * k * U + b - 1.0
    adU = 2.0 * k * U + abs(b) + 1.0
    if _lo(vU, REL * aU) >= 0.0 and _hi(dU, REL * adU) <= 0.0:
        return True
    d0 = b - 1.0
    if _lo(g, REL * abs(g)) >= 0.0 and _lo(d0, REL * (abs(b) + 1.0)) >= 0.0:
        return True
    return False


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
    seconds: float = 0.0
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
    rng = rng if rng is not None else np.random.default_rng()
    d = cn.d
    root = np.zeros(d, dtype=np.int8) if root is None else np.asarray(root, dtype=np.int8).copy()
    if root.shape != (d,) or not np.all(np.isin(root, (-1, 0, 1))):
        raise ValueError("root must be a vector in {-1, 0, +1}^d")
    total = 1 << int((root == 0).sum())
    flops = {"parse": 0.0, "lin": 0.0, "quad": 0.0, "enum": 0.0, "sample": 0.0}
    res = VerifyResult(0.0, 1.0, False, 0, 0, flops=flops)
    try:
        res.arg_bytes = argument_bytes(arg)
    except Exception:
        res.arg_bytes = -1
    # ---- parse the tree (preorder, child x_i = -1 first)
    tree = arg.get("tree") if isinstance(arg, dict) else None
    if not isinstance(tree, (list, tuple)) or len(tree) == 0:
        res.rejected = "no tree"
        res.seconds = time.time() - t0
        return res
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
        res.seconds = time.time() - t0
        return res
    sizes = [1 << int((x0 == 0).sum()) for x0, _ in leaves]
    if sum(sizes) != total:  # cannot happen for a parsed binary trie
        res.rejected = "leaves do not partition the cube"
        res.seconds = time.time() - t0
        return res
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
            if part[0][2] is None:
                al = None
            else:
                al = []
                for k in range(cn.L):
                    if part[0][2][k] is None:
                        al.append(None)
                    else:
                        al.append(np.concatenate([a[k] for _, _, a in part], 0))
            for _, x0, _ in part:
                flops["lin"] += cn.flops_lin(int((x0 == 0).sum()))
            lb = cn.check_lin(X0, al, sign)
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
            done = 0
            B = 1 << 16
            while done < N:
                k = min(B, N - done)
                X = _draw_open(rng, OL, Z, k)
                fails += cn.classify(X, cn.forward(X))
                done += k
            flops["sample"] = float(N) * cn.fpe_flops
            res.n_samples, res.sample_fails = N, fails
            l, u = kl_interval(fails / N, N, delta, rel_err=2.0 ** -51)
            res.lo = _round_down(Fraction(F, total) + Fraction(Z, total) * Fraction(l))
            res.hi = min(1.0, _round_up(Fraction(F, total) + Fraction(Z, total) * Fraction(u)))
    res.fpe = sum(flops.values()) / cn.fpe_flops
    res.seconds = time.time() - t0
    return res


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
    """Coefficients G (B, m1) on h_1 and constant (B,) of the backward pass
    with default slopes on layers >= 2."""
    B = X0.shape[0]
    Lam = np.full((B, 1, 1), float(sign))
    G, Gabs, const, cabs, extra = cn._backward(Lam, np.abs(Lam), cn.L + 1, ivs, X0, None, stop_h1=True)
    return G[:, 0, :], const[:, 0] - extra[:, 0]


def _opt_alpha(cn: CertNet, X0: np.ndarray, sign: int, ivs, c, iters: int):
    """Projected supergradient ascent (Adam) on the first-layer slopes of the
    lower bound of sign * f over each subcube. Returns alpha (B, m1) and the
    (non-rigorous) bound values."""
    G, const = _h1_coeffs(cn, X0, sign, ivs)
    L1, U1 = ivs[0]
    W1 = cn.Ws[0]
    F = (X0 == 0.0).astype(np.float64)
    act = L1 >= 0.0
    uns = _uns_mask(L1, U1)
    pos = uns & (G >= 0.0)
    neg = uns & (G < 0.0)
    with np.errstate(divide="ignore", invalid="ignore"):
        lam = np.where(uns, U1 / np.where(uns, U1 - L1, 1.0), 0.0)
    base_slope = np.where(act, 1.0, np.where(neg, lam, 0.0))
    off = np.where(neg, -lam * L1, 0.0)
    const1 = const + (G * off).sum(1)
    alpha = np.where(pos, (U1 >= -L1).astype(np.float64), 0.0)

    def value(alpha):
        slope = np.where(pos, alpha, base_slope)
        Lam1 = G * slope
        g = Lam1 @ W1
        val = const1 + (Lam1 * c).sum(1) - (np.abs(g) * F).sum(1)
        return val, g

    best_val, g = value(alpha)
    best = alpha.copy()
    m = np.zeros_like(alpha)
    v = np.zeros_like(alpha)
    lr = 0.1
    for it in range(1, iters + 1):
        sg = np.sign(g) * F
        grad = np.where(pos, G * (c - sg @ W1.T), 0.0)
        m = 0.9 * m + 0.1 * grad
        v = 0.999 * v + 0.001 * grad * grad
        step = lr * (m / (1 - 0.9 ** it)) / (np.sqrt(v / (1 - 0.999 ** it)) + 1e-12)
        alpha = np.clip(alpha + step, 0.0, 1.0)
        val, g = value(alpha)
        better = val > best_val
        best_val = np.where(better, val, best_val)
        best[better] = alpha[better]
    return best, best_val


def _quad_family(G, L, U, th):
    """Batched prover-side version of the verifier's quadratic family
    (without the margins): kap, bet, gam (B, m) and their derivatives with
    respect to theta = (s, rho)."""
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
    Bq = U / w - K * w
    kap = np.where(neg, rho * K, kap)
    bet = np.where(neg, U / w - rho * K * w - 2 * rho * K * L, bet)
    gam = np.where(neg, rho * K * L ** 2 - (U / w - rho * K * w) * L, gam)
    dk[..., 1] += np.where(neg, K, 0.0)
    db[..., 1] += np.where(neg, -K * w - 2 * K * L, 0.0)
    dg[..., 1] += np.where(neg, K * L ** 2 + K * w * L, 0.0)
    return kap, bet, gam, dk, db, dg


def _opt_quad(cn: CertNet, X0: np.ndarray, sign: int, iters: int):
    """Adam on the smoothed objective sum(mu) + n * softmin(eig(M(theta) -
    diag(mu))) for a batch of subcubes with the same number r of free
    inputs. Returns a list of certificates (dicts) and their rigorous
    bounds (as checked by the verifier's own code)."""
    B = X0.shape[0]
    ivs, c, c_abs = cn.intervals(X0)
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

    M, *_ = build(th)
    mu = np.diagonal(M, axis1=1, axis2=2).copy()
    params = [th, mu]
    mom = [np.zeros_like(th), np.zeros_like(mu)]
    vel = [np.zeros_like(th), np.zeros_like(mu)]
    best = np.full(B, -np.inf)
    best_th, best_mu = th.copy(), mu.copy()
    taus = np.geomspace(0.05, 1e-4, iters)  # smoothing of the minimum eigenvalue
    eye = np.eye(n)
    for it in range(iters):
        M, dk, db, dg = build(th)
        S = M - mu[:, :, None] * eye
        w, Vv = np.linalg.eigh(S)
        val = mu.sum(1) + n * w[:, 0]
        better = val > best
        best = np.where(better, val, best)
        best_th[better] = th[better]
        best_mu[better] = mu[better]
        z = -(w - w[:, :1]) / taus[it]
        e = np.exp(z)
        pz = e / e.sum(1, keepdims=True)
        P = np.einsum("bik,bk,bjk->bij", Vv, pz, Vv, optimize=True)
        gmu = 1 - n * np.diagonal(P, axis1=1, axis2=2)
        PV = np.einsum("bjp,bpq->bjq", Vt, P)
        q = (PV * Vt).sum(2)
        sv = PV[:, :, -1]
        p22 = P[:, -1, -1]
        gth = (n * G * q)[..., None] * dk + (n * G * sv)[..., None] * db + (n * G * p22[:, None])[..., None] * dg
        grads = [gth, gmu]
        for i in range(2):
            mom[i] = 0.9 * mom[i] + 0.1 * grads[i]
            vel[i] = 0.999 * vel[i] + 0.001 * grads[i] ** 2
            mh = mom[i] / (1 - 0.9 ** (it + 1))
            vh = vel[i] / (1 - 0.999 ** (it + 1))
            params[i] += 0.05 * mh / (np.sqrt(vh) + 1e-12)
        np.clip(params[0], 0.0, 1.0, out=params[0])
        th, mu = params
    certs, bounds = [], []
    for b in range(B):
        x0 = X0[b:b + 1]
        ivb = [(Lk[b:b + 1], Uk[b:b + 1]) for Lk, Uk in ivs]
        try:
            Mv, Ma, extra = cn.quad_matrix(x0, None, best_th[b], sign, ivb, (c[b:b + 1], c_abs[b:b + 1]))
            A0 = Mv - np.diag(best_mu[b])
            lam = float(np.linalg.eigvalsh(A0)[0])
            # the verifier's margin (check_quad) for this matrix, times 4
            nn = A0.shape[0]
            Et = REL * (Ma + np.diag(np.abs(best_mu[b]) + abs(lam)))
            gm = _gamma(2 * nn + 4)
            marg = 3.0 * (gm * abs(float(np.trace(A0))) / (1 - gm) + float(np.sqrt((Et * Et).sum())))
            s = lam - 4.0 * marg - 1e-12 * (1.0 + abs(lam))
            cert = {"kind": "quad", "alpha": None, "theta": best_th[b].copy(), "mu": best_mu[b].copy(), "shift": s}
            lb = cn.check_quad(x0, None, cert["theta"], cert["mu"], s, sign, ivb, (c[b:b + 1], c_abs[b:b + 1]))
        except (ValueError, np.linalg.LinAlgError, FloatingPointError) as e:
            if _DEBUG:
                print("quad prover failure:", repr(e))
            cert, lb = None, -math.inf
        certs.append(cert)
        bounds.append(lb)
    return certs, np.array(bounds)


def _split_scores(cn: CertNet, X0: np.ndarray, ivs):
    """Influence of each free coordinate on the unstable first-layer units,
    weighted by the coefficients of the backward pass."""
    G, _ = _h1_coeffs(cn, X0, 1, ivs)
    L1, U1 = ivs[0]
    uns = _uns_mask(L1, U1)
    wgt = np.abs(G) * np.where(uns, np.minimum(-L1, U1), 0.0)
    sc = wgt @ cn.absW[0]
    return np.where(X0 == 0.0, sc + 1e-300, -1.0)


def _choose_split(cn: CertNet, X0: np.ndarray, ivs, k: int):
    """Strong branching: among the top-k coordinates by score, the one whose
    worse child has the largest default 'lin' bound (for f and, if better,
    for -f)."""
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
    lb = cn.check_lin(flat, None, 1).reshape(B, k, 2)
    worst = lb.min(2)
    return top[np.arange(B), worst.argmax(1)]


def _std_f(cn: CertNet, rng, n=20000):
    X = rng.choice([-1.0, 1.0], size=(n, cn.d))
    return float(cn.forward(X).std())


def prove(net, cfg: ProverConfig | None = None, verbose: bool = False, root=None):
    """Build an argument for `verify` (for the subcube `root`, default the
    whole cube). Returns (arg, ProofInfo)."""
    cfg = cfg or ProverConfig()
    t_start = time.time()
    cn = net if isinstance(net, CertNet) else CertNet(net)
    rng = np.random.default_rng(cfg.seed)
    d, t = cn.d, cn.t
    sig = _std_f(cn, rng)
    # node storage
    X0s = [np.zeros(d, dtype=np.int8) if root is None else np.asarray(root, dtype=np.int8).copy()]
    kind = [None]
    cert = [None]
    split = [-1]
    kids = [None]
    nfail = [0]  # prover's failure count of a leaf (ENUM: enumerated; FAIL: all)
    depth = [0]
    frontier = [0]
    info = ProofInfo()
    while frontier:
        nxt = []
        for s0 in range(0, len(frontier), cfg.chunk):
            ids = frontier[s0:s0 + cfg.chunk]
            X0 = np.array([X0s[i] for i in ids], dtype=np.float64)
            rr = (X0 == 0.0).sum(1)
            ivs, c, c_abs = cn.intervals(X0)
            done = np.zeros(len(ids), dtype=bool)
            # SAFE by 'lin'
            if "lin" in cfg.kinds:
                lb0 = cn.check_lin(X0, None, 1, ivs)
                best_lb = lb0.copy()
                for b in np.nonzero(lb0 >= t)[0]:
                    kind[ids[b]], cert[ids[b]] = SAFE, {"kind": "lin", "alpha": None}
                    done[b] = True
                sel = np.nonzero(~done)[0]
                if sel.size and cfg.alpha_iters > 0:
                    ivs_s = [(Lk[sel], Uk[sel]) for Lk, Uk in ivs]
                    al, _ = _opt_alpha(cn, X0[sel], 1, ivs_s, c[sel], cfg.alpha_iters)
                    alist = [al] + [None] * (cn.L - 1)
                    lb1 = cn.check_lin(X0[sel], alist, 1, ivs_s)
                    best_lb[sel] = np.maximum(best_lb[sel], lb1)
                    for j, b in enumerate(sel):
                        if lb1[j] >= t:
                            kind[ids[b]] = SAFE
                            cert[ids[b]] = {"kind": "lin", "alpha": [al[j].copy()] + [None] * (cn.L - 1)}
                            done[b] = True
            else:
                best_lb = np.full(len(ids), -np.inf)
            # FAIL by 'lin'
            if cfg.fail_leaves and "lin" in cfg.kinds:
                sel = np.nonzero(~done)[0]
                if sel.size:
                    ivs_s = [(Lk[sel], Uk[sel]) for Lk, Uk in ivs]
                    ub0 = cn.check_lin(X0[sel], None, -1, ivs_s)
                    cand = sel[ub0 > -t - 2 * sig]  # optimise slopes only near t
                    for j, b in enumerate(sel):
                        if ub0[j] > -t:
                            kind[ids[b]], cert[ids[b]] = FAIL, {"kind": "lin", "alpha": None}
                            nfail[ids[b]] = 1 << int(rr[b])
                            done[b] = True
                    cand = np.array([b for b in cand if not done[b]], dtype=int)
                    if cand.size and cfg.alpha_iters > 0:
                        ivs_c = [(Lk[cand], Uk[cand]) for Lk, Uk in ivs]
                        al, _ = _opt_alpha(cn, X0[cand], -1, ivs_c, c[cand], cfg.alpha_iters)
                        alist = [al] + [None] * (cn.L - 1)
                        ub1 = cn.check_lin(X0[cand], alist, -1, ivs_c)
                        for j, b in enumerate(cand):
                            if ub1[j] > -t:
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
                            if lbq[j] >= t and certs[j] is not None:
                                kind[ids[b]], cert[ids[b]] = SAFE, certs[j]
                                done[b] = True
            # leaves and splits
            rest = np.nonzero(~done)[0]
            leafs = rest[rr[rest] <= cfg.r_leaf]
            for b in leafs:
                i = ids[b]
                kind[i] = ENUM
                _, fv = cn.enum_points(X0[b])
                nfail[i] = int((fv < t).sum())
            spl = rest[rr[rest] > cfg.r_leaf]
            if spl.size:
                over = len(X0s) + 2 * spl.size > cfg.node_budget
                if over:
                    info.budget_hit = True
                    for b in spl:
                        if cfg.budget_leaf == "enum":
                            kind[ids[b]] = ENUM
                            _, fv = cn.enum_points(X0[b]) if rr[b] <= 22 else (None, None)
                            nfail[ids[b]] = int((fv < t).sum()) if fv is not None else 0
                        else:
                            kind[ids[b]] = OPEN
                else:
                    ivs_s = [(Lk[spl], Uk[spl]) for Lk, Uk in ivs]
                    var = _choose_split(cn, X0[spl], ivs_s, cfg.strong_k)
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
                            ch.append(len(X0s) - 1)
                            nxt.append(len(X0s) - 1)
                        kids[i] = ch
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
            cost[i] = cn.flops_node() + (cn.flops_quad(int(rv[i])) if cert[i]["kind"] == "quad" else cn.flops_lin(int(rv[i])))
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
                pred += cn.flops_quad(int(rv[i])) if cert[i]["kind"] == "quad" else cn.flops_lin(int(rv[i]))
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
        ivs, c, c_abs = cn.intervals(X0)
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
                est_cost[i] += w * (cn.flops_node() + (cn.flops_quad(int(rr[j])) if out_kind[i] == "quad" else cn.flops_lin(int(rr[j]))))
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
            var = _choose_split(cn, X0[spl], ivs_s, cfg.strong_k)
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
