"""Prover-free analytic upper bounds and exact-mass envelopes for the failure
probability of ReLU MLPs (rareprob.nets) on the uniform cube.

Setting. f is an MLP from nets.py; D is uniform on {-1,+1}^d; the rare event is
[F(x) < t] with F the net in EXACT real arithmetic on its float64 weights (each
float stands for its binary value) and t = net.threshold. Every bound below is
an upper bound on Pr_D[F(x) < t + tau] with tau = forward_error_bound(net), so it
also bounds the probability of [f_fl(x) < t] for f evaluated in float64 in ANY
summation order (the reference p_exact of experiments/nets is one such order),
and of [F(x) < t].

Everything is for an arbitrary net of the architecture: no assumption on the
weights is used in any soundness argument; the trained-net structure only
affects how tight the bounds are.

What is here
------------
* Floating point: forward_error_bound (|f_fl - F| <= tau on the cube, any
  summation order), fails_exact (the exact indicator [F(x) < t], rechecked in
  rational arithmetic in the ambiguous band).

* Quantised linear forms and exact dynamic programming. quantize() writes a
  form z = v.x + b as z = q (n.x) + b + r.x with n integer, q a power of two
  and |r.x| <= e for every x in the box (e = sum_i |v_i - q n_i|, rounded up).
  form_dp() computes the exact law of the integer vector s = N x (k <= 3 rows)
  under any product measure on the cube by convolution over the inputs (exact
  in float64 for the uniform measure and d <= 53; otherwise with a stated
  relative error bound); sample_backward() draws x exactly-up-to-rounding from
  any reweighting of that law (backward sampling through the stored DP tables).

* Bounds (one hidden layer, f = c + sum_j a_j relu(z_j), z_j = w_j.x + b_j;
  "even form": f = c' + lam.x + sum_j (a_j/2)|z_j| with lam = (1/2) sum_j a_j w_j):
  - chernoff_holder: Pr[F < t'] <= exp(theta (t' - C)) prod_k (E exp(-(theta/rho_k)
    F_k))^{rho_k} (Markov, then Hoelder over parts F_k of f: groups of <= 3
    hidden units in relu or even form, plus the linear part), sum_k rho_k = 1:
    the tree-reweighted (convex) upper bound on the log-partition function of
    -theta f for this decomposition. Each group's moment generating function is
    bounded from the exact DP law of its quantised forms, the rounding interval
    resolved pessimistically. Optimised over theta and rho (any values valid).
  - decoupling_floor: min_theta exp(theta (t - C)) prod_k E exp(-theta F_k), the
    value under independence of the parts. Lemma: every Hoelder / Brascamp-Lieb /
    Finner-type bound E prod_k Y_k <= prod_k ||Y_k||_{p_k} (p_k >= 1) is >=
    prod_k E Y_k, so this is a floor for all decoupled Chernoff bounds with the
    same parts (computed with cell maxima, so it does not exceed the true floor
    up to quantisation in the safe direction). independent_units_chernoff is the
    same with cell minima (not a bound; for comparison).
  - mcdiarmid: bounded differences with the certified mean (mean_lower_bound).

* Envelopes (exact mass, exact sampler, two-sided intervals by the envelope
  estimator of the paper, Thm. envelope):
  - TiltEnvelope: phi(x) = exp(theta (t' - g(x))) for an affine g with g <= F on
    the cube (per-unit linear relaxations: relu(z) >= s z, s in [0,1], for
    a_j > 0 and relu(z) <= kappa z + nu on the pre-activation range for
    a_j < 0; or a CROWN-type backward pass for two hidden layers). Mass
    exp(theta (t' - g_0)) prod_i cosh(theta gamma_i); sampler: independent
    tilted coins (exact for their float probabilities, and E_Q W = p / Z holds
    exactly for those). Box barrier: g <= F on the box gives g(0) <= F(0), so by
    Jensen Z >= exp(theta (t' - F(0))) >= 1 whenever F(0) < t.
  - GroupTiltEnvelope: the same with a group S of hidden units (|S| <= 2) kept
    exactly: phi(x) = exp(theta (t' - H_S(N_S x) - g_rest(x))) with H_S the
    pessimistic value of sum_{j in S} a_j relu(z_j) on the quantisation cell.
    Mass by DP under the tilted product measure (with a certified error bar
    logZ_err); sampler by backward DP.
  - SignPatternEnvelope: phi = exp(theta (t' - g)) prod_{j in N} (1 + e^{alpha_j z_j})
    for a set N of negative-weight units (a softplus bound on their relus),
    i.e. a positive mixture of 2^|N| tilts over their sign patterns: exact mass
    by summing over the patterns, exact sampler (pattern, then coins).
  - envelope_interval: the two-sided interval (KL, sequential) from any of them.
  Barrier for all of them (every positive mixture of tilts): E_D e^{beta.x} =
  prod cosh beta_i >= 1, so Z >= phi(0); when domination is proved by
  inequalities valid on all of R^d (as here), phi(0) >= exp(theta (t' - F(0))),
  so Z > 1 whenever F(0) < t.

* small_width_interval: for at most 3 hidden units, a deterministic interval
  for p from the exact joint DP law of all pre-activations (exact up to the
  quantisation cells, however rare the event).

* Perturb-and-MAP (Hazan and Jaakkola 2012): log sum_x e^{-theta F(x)} <=
  E max_x [-theta F(x) + sum_b gamma_b(x_b)] for i.i.d. zero-mean Gumbel
  perturbations of blocks of coordinates; perturb_map_bound turns n MAP calls
  into a certified upper bound on p (Chernoff, empirical Bernstein). It does
  not decouple the hidden units (the MAP call sees the whole net), but every
  call is an NP-hard optimisation over the cube; EnumMAPOracle answers them by
  enumeration for d <= 30.

* cube_tilt_envelope: a TiltEnvelope whose affine minorant is certified on
  the CUBE by one exact minimisation of F(x) - gam.x (a MAP call) instead of
  a box relaxation; it escapes the box barrier but not the cube barrier: it
  exists only when symmetric_gap > 0.

* Oracle diagnostics from the full table (d <= 30): symmetric_gap (the cube
  barrier for affine minorants: if min_x (F(x) + F(-x))/2 < t, every tilt
  envelope has Z >= 1, whatever certifies its minorant), best_tilt_oracle,
  moment_bounds.

Findings on the trained nets (experiments/nets_analytic, results/summary.txt):
(1) every decoupled bound is >= 0.2 (>= 0.6 on every net with exact p <= 1e-3),
and every envelope with exact mass and exact sampler whose domination is
proved by box-valid inequalities has Z >= 1 (no gain over Monte Carlo) on all
nets except one. The reasons are structural: the concentration of f comes
from cancellations BETWEEN hidden units (sum_j a_j w_j ~ 0, and the parts of
the positive- and negative-weight units are strongly correlated), which every
decoupled bound discards (decoupling floor >> p on the MSE nets) and Hoelder
pays for a second time (comonotone variance (sum_k sd F_k)^2 is 37-450 times
Var f on the squared-loss nets, 13-17 on the logistic ones); positive mixtures of tilts fail by the box barrier (F(0) < t on every
squared-loss net with d <= 28); bounds on the positive units alone are
vacuous (Pr[E+ <= max_x(t - c' - L - E-)] >= 0.98); few-form envelopes cannot
contain the failures (hindsight K* >= 843 for p <= 4e-4).
(2) Methods that call an exact optimisation over the cube escape the box
barrier: perturb-and-MAP certifies roughly half of the log-rarity
(U ~ p^0.5; exact for subcubes, ~75% for halfspaces, O(1) nats per small
ball), and the cube-certified tilt gives two-sided intervals with K = 221 at
p = 6e-8 when symmetric_gap > 0; but each MAP call is a verification problem
(HiGHS: seconds for width 32 up to d = 64, minutes to unsolved for width 64).
(3) Where F(0) - t is large (long logistic training at d = 64), the
sign-pattern envelope has Z = 4.9e-3 (exact mass, exact sampler).
(4) With <= 3 hidden units, small_width_interval is exact.

Soundness of each method is stated in its docstring; experiments/nets_analytic/
check_soundness.py checks them by brute force on small adversarial nets.
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field
from fractions import Fraction

import numpy as np

from .nets import MLP
from .stats import Estimate, sequential_mean

U = 2.0 ** -53


def gamma(n: int) -> float:
    """gamma_n = n u / (1 - n u): the classical bound on the relative error of
    an n-term floating-point dot product, any summation order."""
    return n * U / (1.0 - n * U)


def _up(x: float, rel: float = 2.0 ** -40) -> float:
    """x enlarged by a relative 2^-40 (covers the rounding of the few
    operations that produced it); used for quantities that must be upper
    bounds."""
    return x + abs(x) * rel + 1e-300 if x >= 0 else x * (1 - rel)


# --------------------------------------------------------------------------
# floating point
# --------------------------------------------------------------------------


def _absmv(Wabs: np.ndarray, v: np.ndarray, n: int) -> np.ndarray:
    """Upper bound of |W| v (v >= 0) computed in float, rounded up."""
    r = Wabs @ v
    return r * (1 + gamma(n + 2)) + 1e-300


def box_bounds(net: MLP) -> list[tuple[np.ndarray, np.ndarray]]:
    """Interval bounds [lo, hi] on every hidden pre-activation over the box
    [-1,1]^d (interval arithmetic, rounded outwards)."""
    lo_h = -np.ones(net.d)
    hi_h = np.ones(net.d)
    out = []
    for k, (W, b) in enumerate(zip(net.Ws[:-1], net.bs[:-1])):
        Wp, Wn = np.maximum(W, 0.0), np.minimum(W, 0.0)
        mid_lo = Wp @ lo_h + Wn @ hi_h + b
        mid_hi = Wp @ hi_h + Wn @ lo_h + b
        slack = _absmv(np.abs(W), np.maximum(np.abs(lo_h), np.abs(hi_h)), W.shape[1]) * gamma(W.shape[1] + 2) \
            + np.abs(b) * gamma(2)
        lo, hi = mid_lo - slack, mid_hi + slack
        out.append((lo, hi))
        lo_h, hi_h = np.maximum(lo, 0.0), np.maximum(hi, 0.0)
    return out


def forward_error_bound(net: MLP) -> float:
    """tau with |f_fl(x) - F(x)| <= tau for every x in {-1,+1}^d, where f_fl is
    the net evaluated in float64 with the dot products summed in any order.

    Layer by layer: if the inputs of a layer carry an error at most E (vector)
    and have magnitude at most A, the computed pre-activation fl(W h_fl + b)
    differs from W h + b by at most |W| E + gamma_{n+1} (|W| (A + E) + |b|);
    relu is 1-Lipschitz. A comes from box_bounds."""
    E = np.zeros(net.d)
    A = np.ones(net.d)
    bnds = box_bounds(net)
    for k, (W, b) in enumerate(zip(net.Ws, net.bs)):
        n = W.shape[1]
        Wa = np.abs(W)
        E = _absmv(Wa, E, n) + gamma(n + 1) * (_absmv(Wa, A + E, n) + np.abs(b))
        E = E * (1 + 1e-6)
        if k < len(net.Ws) - 1:
            lo, hi = bnds[k]
            A = np.maximum(np.abs(lo), np.abs(hi))
    return float(E[0]) * 1.01 + 1e-300


def exact_output(net: MLP, x) -> Fraction:
    """F(x) in rational arithmetic (weights at their exact binary values)."""
    h = [Fraction(int(v)) for v in x]
    for k, (W, b) in enumerate(zip(net.Ws, net.bs)):
        z = []
        for r in range(W.shape[0]):
            s = Fraction(float(b[r]))
            for i, w in enumerate(W[r]):
                if h[i]:
                    s += Fraction(float(w)) * h[i]
            z.append(s)
        h = z if k == len(net.Ws) - 1 else [max(v, Fraction(0)) for v in z]
    return h[0]


def fails_exact(net: MLP, X: np.ndarray, tau: float | None = None) -> np.ndarray:
    """The exact indicator [F(x) < t] for the rows of X (+-1 entries): the float
    forward pass decides every row with |f_fl - t| > tau; the others (in
    practice none) are recomputed in rational arithmetic."""
    if tau is None:
        tau = forward_error_bound(net)
    f = net.forward(X)
    out = f < net.threshold
    amb = np.nonzero(np.abs(f - net.threshold) <= tau)[0]
    t = Fraction(float(net.threshold))
    for r in amb:
        out[r] = exact_output(net, X[r]) < t
    return out


# --------------------------------------------------------------------------
# quantised forms and exact DP over the inputs
# --------------------------------------------------------------------------


@dataclass
class Forms:
    """k linear forms z_j = V_j.x + b_j written as z_j = q s_j + b_j + r_j.x with
    s = N x integer and |r_j.x| <= e_j on the box [-1,1]^d."""

    N: np.ndarray  # (k, d) int64
    q: float  # a power of two
    b: np.ndarray  # (k,)
    e: np.ndarray  # (k,) rounded up

    @property
    def S(self) -> np.ndarray:
        return np.abs(self.N).sum(axis=1)

    def z_lo(self, s: np.ndarray, j: int) -> np.ndarray:
        """Lower end of the interval of z_j on the cell s_j (float, rounded down)."""
        v = self.q * s + self.b[j] - self.e[j]
        return v - np.abs(v) * 2.0 ** -50 - 1e-300

    def z_hi(self, s: np.ndarray, j: int) -> np.ndarray:
        v = self.q * s + self.b[j] + self.e[j]
        return v + np.abs(v) * 2.0 ** -50 + 1e-300


def quantize(V: np.ndarray, b: np.ndarray, q: float) -> Forms:
    """Round V to the grid q Z (q a power of two). V/q, the rounding and q N are
    exact in float64, and so is the residual R = V - q N (|R| <= q/2 and R is a
    multiple of an ulp of V); e_j = sum_i |R_ji| is summed with fsum (correctly
    rounded) and enlarged by a relative 2^-50."""
    V = np.atleast_2d(np.asarray(V, dtype=float))
    m, e2 = math.frexp(q)
    if m != 0.5:
        raise ValueError("q must be a power of two")
    N = np.round(V / q)
    R = V - q * N
    e = np.array([math.fsum(np.abs(r)) * (1 + 2.0 ** -50) for r in R])
    return Forms(N.astype(np.int64), float(q), np.atleast_1d(np.asarray(b, dtype=float)).copy(), e)


def grid_for(V: np.ndarray, budget: int) -> float:
    """The largest power of two q such that every row of round(V/q) has l1 norm
    at most budget (so each DP axis has at most 2 budget + 1 cells)."""
    V = np.atleast_2d(np.asarray(V, dtype=float))
    q = 2.0 ** math.ceil(math.log2(np.abs(V).sum(axis=1).max() / budget + 1e-300))
    while np.abs(np.round(V / q)).sum(axis=1).max() > budget:
        q *= 2
    while q > 2.0 ** -60 and np.abs(np.round(V / (q / 2))).sum(axis=1).max() <= budget:
        q /= 2
    return q


@dataclass
class DPLaw:
    """Law of s = N x under the product measure Pr[x_i = +1] = pi_i, as a dense
    array over prod_j [-S_j, S_j] (index = s + S). rel bounds the relative error
    of every entry (0: exact)."""

    P: np.ndarray
    S: np.ndarray
    rel: float
    tables: list | None = None  # the partial laws after 0..d inputs (for sampling)

    def values(self, j: int) -> np.ndarray:
        """s_j at every cell (broadcastable against P)."""
        k = self.P.ndim
        shape = [1] * k
        shape[j] = -1
        return (np.arange(self.P.shape[j]) - self.S[j]).reshape(shape)


def form_dp(N: np.ndarray, pi=None, keep: bool = False) -> DPLaw:
    """Exact law of s = N x (N integer, k x d with k <= 3) for independent x_i
    with Pr[x_i = +1] = pi_i (uniform if pi is None; pi may also be a pair
    (pi_plus, pi_minus) of separately computed probabilities, which avoids the
    cancellation in 1 - pi_i for nearly deterministic coins), by d convolution steps on
    the box prod_j [-S_j, S_j], S_j = sum_i |N_ji| (every partial sum stays in
    the box, so the cyclic shifts never wrap around).

    Floating point: for the uniform measure every entry is c / 2^i with an
    integer c < 2^i, exact for d <= 53 (rel = 0). Otherwise each step computes
    pi P + (1 - pi) P' with nonnegative terms (relative error <= 3u per step,
    on top of the inherited one), so rel = gamma(3 d)."""
    N = np.atleast_2d(np.asarray(N, dtype=np.int64))
    k, d = N.shape
    S = np.abs(N).sum(axis=1)
    shape = tuple(int(2 * s + 1) for s in S)
    if np.prod(shape) > 5e7:
        raise ValueError("DP too large")
    P = np.zeros(shape)
    P[tuple(int(s) for s in S)] = 1.0
    tables = [P.copy()] if keep else None
    uniform = pi is None
    for i in range(d):
        sh = tuple(int(v) for v in N[:, i])
        up = np.roll(P, sh, axis=tuple(range(k)))
        dn = np.roll(P, tuple(-v for v in sh), axis=tuple(range(k)))
        if uniform:
            P = 0.5 * up + 0.5 * dn
        else:
            pp, pm = _coin(pi, i)
            P = pp * up + pm * dn
        if keep:
            tables.append(P.copy())
    rel = 0.0 if (uniform and d <= 53) else gamma(3 * d + 3)
    return DPLaw(P, S, rel, tables)


def sample_backward(law: DPLaw, N: np.ndarray, pi: np.ndarray | None, weights: np.ndarray, n: int,
                    rng: np.random.Generator) -> np.ndarray:
    """Draw n inputs x from the measure proportional to pi(x) w(N x), where
    w = weights (an array over the cells of law) and pi the product measure of
    the DP: first s ~ P(s) w(s) / Z, then x_d, ..., x_1 backwards, x_i = +1
    with probability pi_i P_{i-1}(s - N_i) / P_i(s). The probabilities are
    floats: the law sampled is within total variation (d + #cells + 4) 2^-52 of
    the ideal one (each categorical or Bernoulli draw from a float probability
    vector is off by at most 2^-53 per category, and the probabilities carry a
    relative error below 2^-40); envelope_interval widens by this amount."""
    N = np.atleast_2d(np.asarray(N, dtype=np.int64))
    k, d = N.shape
    if law.tables is None:
        raise ValueError("form_dp(..., keep=True) needed")
    tw = law.P * weights
    flat = tw.ravel() / tw.sum()
    cells = rng.choice(flat.size, size=n, p=flat)
    idx = np.array(np.unravel_index(cells, law.P.shape))  # (k, n)
    X = np.empty((n, d))
    for i in range(d - 1, -1, -1):
        Pp = law.tables[i]
        col = N[:, i][:, None]
        ip, im = idx - col, idx + col  # previous index if x_i = +1 / -1
        vp = Pp[tuple(ip)] if np.all((ip >= 0) & (ip < np.array(Pp.shape)[:, None])) else _safe_get(Pp, ip)
        vm = Pp[tuple(im)] if np.all((im >= 0) & (im < np.array(Pp.shape)[:, None])) else _safe_get(Pp, im)
        cp_, cm_ = (0.5, 0.5) if pi is None else _coin(pi, i)
        a = cp_ * vp
        bb = cm_ * vm
        pr = a / (a + bb)
        xp = rng.random(n) < pr
        X[:, i] = np.where(xp, 1.0, -1.0)
        idx = np.where(xp[None, :], ip, im)
    return X


def _coin(pi, i):
    if isinstance(pi, tuple):
        return pi[0][i], pi[1][i]
    return pi[i], 1.0 - pi[i]


def _safe_get(P: np.ndarray, ix: np.ndarray) -> np.ndarray:
    ok = np.all((ix >= 0) & (ix < np.array(P.shape)[:, None]), axis=0)
    out = np.zeros(ix.shape[1])
    if ok.any():
        out[ok] = P[tuple(ix[:, ok])]
    return out


# --------------------------------------------------------------------------
# one hidden layer: structure
# --------------------------------------------------------------------------


def one_layer(net: MLP):
    if len(net.Ws) != 2:
        raise ValueError("one hidden layer required")
    W, b = net.Ws[0], net.bs[0]
    a = net.Ws[1][0].copy()
    c = float(net.bs[1][0])
    return W, b, a, c


def unit_cells(net: MLP, j: int, budget: int = 4096):
    """For hidden unit j: the exact law of its quantised pre-activation and the
    pessimistic value of a_j relu(z_j) on every cell (a lower bound on the
    unit's contribution to F for every x in the cell)."""
    W, b, a, c = one_layer(net)
    q = grid_for(W[j:j + 1], budget)
    fm = quantize(W[j:j + 1], b[j:j + 1], q)
    law = form_dp(fm.N)
    s = law.values(0)
    if a[j] >= 0:
        v = a[j] * np.maximum(fm.z_lo(s, 0), 0.0)
    else:
        v = a[j] * np.maximum(fm.z_hi(s, 0), 0.0)
    return law.P.ravel(), _down_vec(v.ravel())


def _down_vec(v: np.ndarray) -> np.ndarray:
    """v lowered by a relative 2^-48 (covers the rounding of a_j * max(z, 0))."""
    return v - np.abs(v) * 2.0 ** -48 - 1e-300


def group_cells(net: MLP, G: list[int], budget: int, form: str = "relu", values: str = "pess"):
    """For a group of 1-3 hidden units: the exact joint law of their quantised
    forms (one cell per value of s = N x) and, per cell, the smallest
    (values="pess") or largest (values="opt") value over the cell of

      form "relu":  sum_{j in G} a_j relu(z_j)
      form "even":  sum_{j in G} (a_j / 2) |z_j|   (f = c' + L(x) + sum_j (a_j/2)|z_j|)

    The pessimistic values are lower bounds on the group's contribution for
    every x in the cell (z_j lies in [z_lo, z_hi] there), which is what the
    upper bounds need; "opt" gives upper bounds (used only to bound the
    decoupling floor from below)."""
    W, b, a, c = one_layer(net)
    q = grid_for(W[G], budget)
    fm = quantize(W[G], b[G], q)
    law = form_dp(fm.N)
    val = np.zeros(law.P.shape)
    for r, j in enumerate(G):
        s = law.values(r)
        zl, zh = fm.z_lo(s, r), fm.z_hi(s, r)
        if form == "relu":
            lo_v, hi_v = np.maximum(zl, 0.0), np.maximum(zh, 0.0)  # relu increasing
        else:
            lo_v = np.where((zl <= 0) & (zh >= 0), 0.0, np.minimum(np.abs(zl), np.abs(zh)))
            hi_v = np.maximum(np.abs(zl), np.abs(zh))
        coef = a[j] if form == "relu" else 0.5 * a[j]
        small, large = (lo_v, hi_v) if coef >= 0 else (hi_v, lo_v)
        v = coef * (small if values == "pess" else large)
        val = val + (_down_vec(v) if values == "pess" else v + np.abs(v) * 2.0 ** -48)
    val = _down_vec(val) if values == "pess" else val + np.abs(val) * 2.0 ** -48
    return law.P.ravel(), val.ravel()


def linear_part(net: MLP):
    """f = c' + lam.x + sum_j (a_j/2)|z_j| with lam = (1/2) sum_j a_j w_j and
    c' = c + (1/2) sum_j a_j b_j; returns (c'_fl, lam_fl, err) with
    |c' + lam.x - (c'_fl + lam_fl.x)| <= err on the box."""
    W, b, a, c = one_layer(net)
    m, d = W.shape
    lam = 0.5 * (a @ W)
    cp = c + 0.5 * float(a @ b)
    err = 4 * gamma(m + d + 4) * (0.5 * float(np.abs(a) @ np.abs(W) @ np.ones(d) + np.abs(a) @ np.abs(b)) + abs(c))
    return float(cp), lam, float(err) + 1e-300


def _compress(P: np.ndarray, v: np.ndarray, bins: int = 4000):
    """Merge cells into at most `bins` value classes, each represented by the
    smallest value in it (keeps a lower bound on the contribution) and the
    total probability."""
    keep = P > 0
    P, v = P[keep], v[keep]
    if v.size <= bins:
        return P, v
    lo, hi = v.min(), v.max()
    edges = np.linspace(lo, hi, bins + 1)
    ix = np.clip(np.searchsorted(edges, v, side="right") - 1, 0, bins - 1)
    Pb = np.bincount(ix, weights=P, minlength=bins)
    vb = np.full(bins, np.inf)
    np.minimum.at(vb, ix, v)
    ok = Pb > 0
    return Pb[ok], vb[ok]


def _lse(logw: np.ndarray, P: np.ndarray) -> float:
    m = logw.max()
    return float(m + math.log(np.dot(P, np.exp(logw - m))))


# --------------------------------------------------------------------------
# bounds
# --------------------------------------------------------------------------


@dataclass
class Bound:
    value: float  # an upper bound on p (may exceed 1: trivial)
    log_value: float
    note: str = ""
    params: dict = field(default_factory=dict)


def _groups_data(net, groups, budget, form, values="pess"):
    data = []
    for G in groups:
        P, v = group_cells(net, G, budget, form, values)
        Pc, vc = _compress(P, v)
        if values == "opt":  # _compress keeps bin minima; for "opt" keep the cells
            Pc, vc = P[P > 0], v[P > 0]
        data.append(("cells", Pc, vc))
    return data


def _Lambda(item, u: float) -> float:
    """log E exp(-u F_k) for a group: cells (P, v) or the linear part lam
    (log prod_i cosh(u lam_i))."""
    if item[0] == "cells":
        return _lse(-u * item[2], item[1])
    lam = item[1]
    y = np.abs(u * lam)
    return float(np.sum(y + np.log1p(np.exp(-2 * y)) - math.log(2)))


def _tilted_mean(item, u: float) -> float:
    """-d/du Lambda(u) = E_u[F_k] under the tilt."""
    if item[0] == "cells":
        P, v = item[1], item[2]
        lw = -u * v
        w = P * np.exp(lw - lw.max())
        return float(np.dot(w, v) / w.sum())
    lam = item[1]
    return float(-np.sum(lam * np.tanh(u * lam)))


def _setup(net, groups, form, budget, values="pess"):
    W, b, a, c = one_layer(net)
    m = W.shape[0]
    if groups is None:
        groups = [[j] for j in range(m) if a[j] != 0.0]
    if budget is None:
        budget = {1: 4096, 2: 300, 3: 60}[max(len(G) for G in groups)]
    data = _groups_data(net, groups, budget, form, values)
    if form == "relu":
        const, err = c, 0.0
    else:
        cp, lam, err = linear_part(net)
        const = cp
        data.append(("lin", lam))
    return data, const, err, groups


def chernoff_holder(net: MLP, groups: list[list[int]] | None = None, form: str = "even",
                    budget: int | None = None, restarts: int = 4,
                    rng: np.random.Generator | None = None) -> Bound:
    """Rigorous upper bound on Pr[F < t + tau] for a one-hidden-layer net.
    Write F = C + sum_k F_k with the groups' parts F_k (form "relu":
    F_k = sum_{j in G_k} a_j relu(z_j), C = c; form "even": F_k = sum_{j in G_k}
    (a_j/2)|z_j| plus one more part lam.x, C = c' up to a rounding allowance).
    Then for every theta >= 0 and rho_k > 0 with sum_k rho_k = 1

        Pr[F < t'] <= E exp(theta (t' - F))                                  (Markov)
                    = exp(theta (t' - C)) E prod_k exp(-theta F_k)
                   <= exp(theta (t' - C)) prod_k (E exp(-(theta/rho_k) F_k))^{rho_k}   (Hoelder)

    the tree-reweighted (convex) upper bound on the log-partition function for
    this decomposition. E exp(-u F_k) is bounded above via the exact DP law of
    the group's quantised forms with F_k replaced by its smallest value on each
    cell (group_cells), and exactly for the linear part (prod_i cosh(u lam_i)),
    so the bound holds for every net and every grid.

    Parametrised by u_k = theta / rho_k > 0: theta = 1 / sum_k (1/u_k) and
    log bound = theta [ (t' - C) + sum_k Lambda_k(u_k) / u_k ],
    Lambda_k(u) = log E exp(-u F_k); minimised over log u by L-BFGS (any u is
    valid; the optimiser only finds good ones).

    Floating point: the log-sum-exps are computed in float64 (relative error
    far below 1e-12) and the final log bound is increased by
    1e-9 (1 + |terms|)."""
    from scipy.optimize import minimize

    data, C, err, groups = _setup(net, groups, form, budget)
    tp = _up(float(net.threshold) + forward_error_bound(net)) + err
    rng = rng or np.random.default_rng(0)

    def obj(w):
        u = np.exp(w)
        terms, grads = [], []
        with np.errstate(all="ignore"):
            for item, uk in zip(data, u):
                L = _Lambda(item, uk)
                Ev = _tilted_mean(item, uk)
                terms.append(L / uk)
                grads.append((-Ev * uk - L) / uk)  # u d/du (L/u)
            inv = 1.0 / u
            H = inv.sum()
            A = (tp - C) + sum(terms)
            val, g = A / H, (np.array(grads) * H + A * inv) / H ** 2
        if not (math.isfinite(val) and np.all(np.isfinite(g))):
            return 1e300, np.zeros_like(w)
        return val, g

    best = None
    for r in range(restarts):
        w0 = np.full(len(data), math.log(10.0 ** rng.uniform(0, 3)))
        res = minimize(obj, w0, jac=True, method="L-BFGS-B", bounds=[(-40.0, 40.0)] * len(data))
        if best is None or res.fun < best.fun:
            best = res
    u = np.exp(best.x)
    theta = 1.0 / float(np.sum(1.0 / u))
    with np.errstate(all="ignore"):
        terms = [_Lambda(item, uk) / uk for item, uk in zip(data, u)]
        logb = theta * ((tp - C) + math.fsum(terms))
        logb = logb + 1e-9 * (1 + abs(logb) + theta * (abs(tp - C) + math.fsum(abs(x) for x in terms)))
    if not math.isfinite(logb):
        logb = 0.0  # the trivial bound p <= 1
    return Bound(math.exp(min(logb, 0.0)), logb,
                 note=f"{form} form, {len(groups)} groups of size <= {max(len(G) for G in groups)}",
                 params={"theta": theta, "groups": len(groups)})


def decoupling_floor(net: MLP, groups: list[list[int]] | None = None, form: str = "even",
                     budget: int | None = None, rigorous_floor: bool = True) -> float:
    """min_theta exp(theta (t - C)) prod_k E exp(-theta F_k): the Chernoff value if
    the groups were independent. Every Hoelder / Brascamp-Lieb / Finner-type
    bound E prod_k Y_k <= prod_k ||Y_k||_{p_k} with p_k >= 1 (Y_k =
    exp(-theta F_k) >= 0) is at least prod_k E Y_k, because ||Y||_p >= ||Y||_1
    on a probability space (Jensen); so this value is a FLOOR for every such
    decoupled Chernoff bound with this decomposition, whatever the exponents.
    With rigorous_floor the cells use their largest values (values="opt"), so
    the computed number is <= the true floor (up to quantisation, made
    pessimistic in the right direction); otherwise the cell minima are used."""
    from scipy.optimize import minimize_scalar

    data, C, err, groups = _setup(net, groups, form, budget, "opt" if rigorous_floor else "pess")
    t = float(net.threshold)

    def lb(lt):
        th = math.exp(lt)
        return th * (t - C) + sum(_Lambda(item, th) for item in data)

    best = min((minimize_scalar(lb, bounds=(lo, lo + 4), method="bounded") for lo in range(-6, 10, 3)),
               key=lambda r: r.fun)
    return math.exp(min(best.fun, 0.0))


def independent_units_chernoff(net: MLP, form: str = "even") -> float:
    """NOT a bound: decoupling_floor with singleton groups."""
    return decoupling_floor(net, None, form, None, rigorous_floor=False)


def mean_lower_bound(net: MLP, budget: int = 4096) -> float:
    """A certified lower bound on E F (one hidden layer): c + sum_j E of the
    pessimistic per-cell value of a_j relu(z_j) (exact DP law per unit)."""
    W, b, a, c = one_layer(net)
    tot = [c]
    for j in range(W.shape[0]):
        if a[j] == 0:
            continue
        P, v = unit_cells(net, j, budget)
        tot.append(float(np.dot(P, v)) - abs(float(np.dot(P, np.abs(v)))) * 2.0 ** -40)
    return math.fsum(tot) - 2.0 ** -40 * math.fsum(abs(x) for x in tot)


def mcdiarmid(net: MLP) -> Bound:
    """Bounded differences: flipping x_i changes F by at most
    c_i = 2 sum_j |a_j| |w_ji| (relu is 1-Lipschitz), so for s = E F - t' > 0,
    Pr[F < t'] <= exp(-2 s^2 / sum_i c_i^2) (McDiarmid). E F is bounded below
    by mean_lower_bound."""
    W, b, a, c = one_layer(net)
    ci = 2 * np.abs(a) @ np.abs(W)
    V = float(np.sum(ci ** 2)) * (1 + 1e-12)
    tp = _up(float(net.threshold) + forward_error_bound(net))
    s = mean_lower_bound(net) - tp
    if s <= 0:
        return Bound(1.0, 0.0, "mean bound below threshold")
    lb = -2 * s * s / V * (1 - 1e-12)
    return Bound(math.exp(lb), lb, params={"sum_ci2": V, "margin": s})


# --------------------------------------------------------------------------
# envelopes
# --------------------------------------------------------------------------


def _relu_upper_line(lo: float, hi: float, kappa: float) -> tuple[float, float]:
    """(kappa, nu) with relu(z) <= kappa z + nu on [lo, hi], kappa in [0, 1]:
    nu = max(-kappa lo, (1 - kappa) hi) (the line must clear relu at both ends;
    relu - line is convex, so the ends suffice)."""
    if hi <= 0:
        return 0.0, 0.0
    if lo >= 0:
        return 1.0, 0.0
    return kappa, max(-kappa * lo, (1.0 - kappa) * hi)


def affine_minorant_1(net: MLP, sig: np.ndarray, kap: np.ndarray, skip=()):
    """For a one-hidden-layer net: an affine g(x) = g0 + gamma.x with g(x) <= F(x)
    on the box [-1,1]^d (hence on the cube): each unit j not in `skip`
    contributes a_j sig_j z_j (a_j > 0, sig_j in [0,1]; relu(z) >= sig z for all
    real z) or a_j (kap_j z_j + nu_j) (a_j < 0; relu(z) <= kap z + nu on the
    unit's range from box_bounds). The constant c is included. Returns (g0,
    gamma, err) where err bounds the rounding of g0 + gamma.x (subtract it)."""
    W, b, a, c = one_layer(net)
    lo, hi = box_bounds(net)[0]
    m, d = W.shape
    coef = np.zeros(m)
    const = [c]
    for j in range(m):
        if j in skip or a[j] == 0:
            continue
        if a[j] > 0:
            coef[j] = a[j] * sig[j]
            const.append(a[j] * sig[j] * b[j])
        else:
            k, nu = _relu_upper_line(lo[j], hi[j], kap[j])
            coef[j] = a[j] * k
            const.append(a[j] * (k * b[j] + nu))
    gam = coef @ W
    g0 = math.fsum(const)
    err = gamma(m + d + 4) * (np.abs(coef) @ np.abs(W) @ np.ones(d) + math.fsum(abs(x) for x in const)) * 4 + 1e-300
    return g0, gam, float(err)


@dataclass
class TiltEnvelope:
    """phi(x) = exp(theta (t' - g(x))) >= 1 whenever F(x) < t' (because g <= F),
    represented through its sampler: independent coins with
    Pr[x_i = +1] = pi_i, pi_i = e^{-theta gamma_i} / (2 cosh(theta gamma_i)) (as
    floats). Its exact mass for the float pi is Z (see logZ)."""

    pi: np.ndarray
    alpha: np.ndarray  # log(D/Q)(x) = A0 + alpha.x exactly for the float pi
    A0: float
    logZ: float  # certified: A0 + alpha.x <= logZ whenever F(x) < t'
    net: MLP
    note: str = ""

    def sample(self, n: int, rng: np.random.Generator) -> np.ndarray:
        from .dist import Product
        Xb = Product(self.pi).sample(n, rng)
        return np.where(Xb, 1.0, -1.0) if Xb.dtype == bool else 2.0 * Xb - 1.0

    def weight(self, X: np.ndarray, fails: np.ndarray) -> np.ndarray:
        lw = self.A0 + X @ self.alpha - self.logZ
        w = np.where(fails, np.exp(np.minimum(lw, 0.0)), 0.0)
        return w


def _tilt_from_affine(net: MLP, g0: float, gam: np.ndarray, err: float, theta: float, note=""):
    """Build the TiltEnvelope for the affine minorant g = g0 + gam.x (minus err)."""
    tp = _up(float(net.threshold) + forward_error_bound(net))
    gmax = float(np.max(np.abs(gam))) if gam.size else 0.0
    if gmax > 0:
        # any theta is valid; |theta gamma_i| <= 17 keeps every float pi_i
        # strictly inside (0, 1), so Q > 0 everywhere and log(D/Q) is finite
        theta = min(theta, 17.0 / gmax)
    from scipy.special import expit
    y = theta * gam
    pi = expit(-2.0 * y)  # e^{-y} / (e^{y} + e^{-y}), stably
    with np.errstate(divide="ignore"):
        lp, lq = np.log(pi), np.log1p(-pi)
    alpha = 0.5 * (lq - lp)  # log(D/Q) = sum_i [x_i=1](-log 2 - lp) + [x_i=-1](-log 2 - lq)
    A0 = float(np.sum(-math.log(2) - 0.5 * (lp + lq)))
    # on failures gam.x < t' - g0 + err, so alpha.x <= theta (t' - g0 + err) + sum |alpha - theta gam|
    dev = float(np.sum(np.abs(alpha - y)))
    logZ = A0 + theta * (tp - g0 + err) + dev
    logZ = logZ + 1e-12 * (1 + abs(A0) + abs(theta * (tp - g0)) + dev)
    if not np.all(np.isfinite(alpha)):
        raise ValueError("degenerate tilt")
    return TiltEnvelope(pi, alpha, A0, float(logZ), net, note)


def tilt_envelope(net: MLP, restarts: int = 3, rng: np.random.Generator | None = None) -> TiltEnvelope:
    """The best exponential-tilt envelope from per-unit affine relaxations (one
    hidden layer): minimise log Z = theta (t' - g0) + sum_i log cosh(theta gamma_i)
    over theta > 0, sig in [0,1]^{m+}, kap in [0,1]^{m-}. Domination holds for
    every parameter value (the optimiser only affects the mass)."""
    from scipy.optimize import minimize

    W, b, a, c = one_layer(net)
    m = W.shape[0]
    tp = float(net.threshold)
    rng = rng or np.random.default_rng(0)

    def logZ(p):
        th = math.exp(p[0])
        s = 1 / (1 + np.exp(-p[1:]))
        g0, gam, err = affine_minorant_1(net, s, s)
        return th * (tp - g0) + float(np.sum(np.logaddexp(th * gam, -th * gam) - math.log(2)))

    best = None
    for r in range(restarts):
        p0 = np.concatenate([[rng.uniform(-2, 3)], rng.normal(0, 1, m)])
        res = minimize(logZ, p0, method="L-BFGS-B", bounds=[(-12.0, 8.0)] + [(-30.0, 30.0)] * m)
        if best is None or res.fun < best.fun:
            best = res
    th = math.exp(best.x[0])
    s = 1 / (1 + np.exp(-best.x[1:]))
    g0, gam, err = affine_minorant_1(net, s, s)
    return _tilt_from_affine(net, g0, gam, err, th, note="affine relaxation, one hidden layer")


def affine_minorant_deep(net: MLP, slope: str = "adaptive"):
    """CROWN-type affine lower bound g(x) <= F(x) on the box for any depth:
    backward pass; a relu whose coefficient lam is >= 0 is bounded below by
    alpha z (alpha = 1 if lo >= 0, 0 if hi <= 0, else [hi > -lo]), one with
    lam < 0 above by the chord hi (z - lo) / (hi - lo). Intermediate bounds from
    box_bounds. Returns (g0, gamma, err)."""
    bnds = box_bounds(net)
    L = len(net.Ws)
    lam = net.Ws[-1][0].copy()
    const = [float(net.bs[-1][0])]
    absacc = abs(const[0])
    for k in range(L - 2, -1, -1):
        lo, hi = bnds[k]
        slope_v = np.zeros_like(lam)
        off = np.zeros_like(lam)
        for j in range(lam.size):
            if hi[j] <= 0:
                continue
            if lo[j] >= 0:
                slope_v[j] = 1.0
                continue
            if lam[j] >= 0:
                slope_v[j] = 1.0 if hi[j] > -lo[j] else 0.0
            else:
                slope_v[j] = hi[j] / (hi[j] - lo[j])
                off[j] = -slope_v[j] * lo[j]
        lam2 = lam * slope_v
        const.append(float(np.dot(lam, off)))
        const.append(float(np.dot(lam2, net.bs[k])))
        absacc += float(np.abs(lam) @ np.abs(off) + np.abs(lam2) @ np.abs(net.bs[k]))
        lam = lam2 @ net.Ws[k]
    g0 = math.fsum(const)
    err = 1e-10 * (1 + absacc + float(np.abs(lam).sum()))  # generous rounding allowance
    return g0, lam, err


def tilt_envelope_deep(net: MLP) -> TiltEnvelope:
    """Tilt envelope from affine_minorant_deep, theta optimised."""
    from scipy.optimize import minimize_scalar

    g0, gam, err = affine_minorant_deep(net)
    tp = float(net.threshold)

    def lz(lt):
        th = math.exp(lt)
        return th * (tp - g0) + float(np.sum(np.logaddexp(th * gam, -th * gam) - math.log(2)))

    r = minimize_scalar(lz, bounds=(-8, 8), method="bounded")
    return _tilt_from_affine(net, g0, gam, err, math.exp(r.x), note="CROWN affine minorant")


@dataclass
class GroupTiltEnvelope:
    """phi(x) = exp(theta (t' - c - H_S(N_S x) - g_rest(x))) where g_rest is the
    affine relaxation of the units outside S and H_S(s) <= sum_{j in S} a_j
    relu(z_j) for every x in the cell s. Since F >= c + H_S + g_rest, phi >= 1
    whenever F < t'. Mass: exp(theta (t' - c - g_rest0)) prod_i cosh(theta gamma_i)
    * sum_s P_pi(s) exp(-theta H_S(s)) with P_pi the DP law of s under the
    tilted coins; sampler: s, then x backwards (sample_backward)."""

    net: MLP
    S: list
    fm: Forms
    law: DPLaw
    H: np.ndarray
    pi: np.ndarray
    theta: float
    g0: float
    gam: np.ndarray
    err: float
    logZ: float  # the computed log mass
    logZ_err: float = 0.0  # |logZ - log(exact mass)| <= logZ_err

    def sample(self, n: int, rng: np.random.Generator) -> np.ndarray:
        hmin = self.H[self.law.P > 0].min()
        with np.errstate(under="ignore"):
            wts = np.exp(-self.theta * np.maximum(self.H - hmin, 0.0))
        return sample_backward(self.law, self.fm.N, self.pi, wts, n, rng)

    def weight(self, X: np.ndarray, fails: np.ndarray) -> np.ndarray:
        """W = 1[fail] / phi(x) with phi = Z Q(x) / D(x) computed from the ideal
        tilted measure. log phi(x) = theta (t' - c - H_S(s) - g_rest(x)) >= 0 on
        failures; we evaluate it directly from its definition."""
        tp = _up(float(self.net.threshold) + forward_error_bound(self.net))
        s = (X @ self.fm.N.T).astype(np.int64)  # exact (integers)
        Hx = self.H[tuple((s + self.fm.N.__abs__().sum(axis=1)).T)]
        logphi = self.theta * (tp - self.g0 - Hx - X @ self.gam + self.err)
        return np.where(fails, np.exp(-np.maximum(logphi, 0.0)), 0.0)

    @property
    def Z(self) -> float:
        return math.exp(min(self.logZ, 700.0))


def group_tilt_envelope(net: MLP, S: list[int], budget: int = 300, theta: float | None = None,
                        restarts: int = 2, rng: np.random.Generator | None = None) -> GroupTiltEnvelope:
    """Build a GroupTiltEnvelope keeping the units S exactly (|S| <= 2 with the
    default budget). Parameters (theta, the slopes of the other units) are
    chosen to minimise the mass; domination holds for any choice."""
    from scipy.optimize import minimize

    W, b, a, c = one_layer(net)
    m = W.shape[0]
    tp = _up(float(net.threshold) + forward_error_bound(net))
    q = grid_for(W[S], budget)
    fm = quantize(W[S], b[S], q)
    law0 = form_dp(fm.N)
    H = np.zeros(law0.P.shape)
    for r, j in enumerate(S):
        sv = law0.values(r)
        z = fm.z_lo(sv, r) if a[j] >= 0 else fm.z_hi(sv, r)
        H = H + _down_vec(a[j] * np.maximum(z, 0.0))
    H = _down_vec(H)
    rng = rng or np.random.default_rng(0)
    c_noconst = 0.0

    def build(p):
        th = math.exp(p[0])
        s = 1 / (1 + np.exp(-p[1:]))
        g0, gam, err = affine_minorant_1(net, s, s, skip=set(S))
        return th, g0, gam, err

    def logZ_of(p, exact=False):
        th, g0, gam, err = build(p)
        from scipy.special import expit
        gmax = float(np.max(np.abs(gam))) if gam.size else 0.0
        if gmax > 0:
            th = min(th, 17.0 / gmax)  # non-degenerate coins (any theta is valid)
        y = th * gam
        pi = (expit(-2.0 * y), expit(2.0 * y))  # e^{-+y} / (2 cosh y), each to a relative ulp
        law = form_dp(fm.N, pi, keep=exact)
        lw = -th * H
        mx = lw[law.P > 0].max()  # over reachable cells only
        with np.errstate(over="ignore", under="ignore"):
            tot = float(np.sum(np.where(law.P > 0, law.P * np.exp(np.minimum(lw - mx, 0.0)), 0.0)))
        if not (tot > 0 and math.isfinite(tot)):
            return 1e300, (th, g0, gam, err, pi, law)
        inner = math.log(tot) + mx
        lz = th * (tp - g0 + err) + float(np.sum(np.logaddexp(y, -y) - math.log(2))) + inner
        return lz, (th, g0, gam, err, pi, law)

    best = None
    for r in range(restarts):
        p0 = np.concatenate([[rng.uniform(-2, 3)], rng.normal(0, 1, m)])
        bnds = [(-12.0, 8.0)] + [(-30.0, 30.0)] * m
        res = minimize(lambda p: logZ_of(p)[0], p0, method="L-BFGS-B", bounds=bnds, options={"maxiter": 200})
        if best is None or res.fun < best.fun:
            best = res
    lz, (th, g0, gam, err, pi, law) = logZ_of(best.x, exact=True)
    if lz >= 1e300:
        raise ValueError("degenerate group envelope")
    # rounding: the three summands of lz are each computed with a relative
    # error far below 1e-12 (sums of at most 1e6 nonnegative terms, logs,
    # products), the DP entries carry law.rel, and the float coins differ from
    # the ideal ones by a relative 2^-52 each
    y = th * gam
    lz_err = 1e-12 * (1 + abs(th * (tp - g0 + err)) + float(np.sum(np.abs(y))) + abs(lz)) \
        + 2 * law.rel + net.d * 2.0 ** -50
    return GroupTiltEnvelope(net, list(S), fm, law, H, pi, th, g0, gam, err, float(lz), float(lz_err))


def envelope_interval(env, eps: float = 0.1, delta: float = 0.05, max_samples: int = 10 ** 6,
                      rng: np.random.Generator | None = None) -> Estimate:
    """The envelope estimator: x ~ Q (the envelope's sampler), W = 1[F(x) < t] /
    phi(x) in [0, 1], E W = p / Z with p = Pr[F < t] (exact indicator). The KL
    sequential interval for E W at level delta, multiplied by Z, contains p with
    probability >= 1 - delta for every net. For GroupTiltEnvelope the sampled
    law is within total variation eta of the ideal one (sample_backward), so the
    interval for E W is widened by eta on both sides."""
    rng = rng or np.random.default_rng()
    net = env.net
    tau = forward_error_bound(net)

    def draw(k):
        out = []
        for s in range(0, k, 1 << 17):  # bounded memory per chunk
            X = env.sample(min(1 << 17, k - s), rng)
            out.append(env.weight(X, fails_exact(net, X, tau)))
        return np.concatenate(out)

    if env.logZ > 0:  # worse than the trivial envelope phi = 1 (Monte Carlo)
        raise ValueError("envelope mass above 1: use plain Monte Carlo")
    est = sequential_mean(draw, eps, delta, max_samples=max_samples)
    Z = math.exp(env.logZ)
    if isinstance(env, SignPatternEnvelope):
        # the subset T is drawn from float probabilities (total variation
        # <= (#subsets + 2) 2^-52 from the ideal mixture weights), the coins
        # exactly (dist._bernoulli); weights and mass carry relative errors
        # bounded by env.logZ_err
        eta = ((1 << len(env.N)) + 2) * 2.0 ** -52
        lo, hi = max(0.0, est.lo - eta), min(1.0, est.hi + eta)
        zl, zh = Z * math.exp(-env.logZ_err), Z * math.exp(env.logZ_err)
        lo, hi = lo * math.exp(-env.logZ_err), hi * math.exp(env.logZ_err)
    elif isinstance(env, GroupTiltEnvelope):
        # sampled law within total variation eta of Q = D phi / Z; Z known to
        # within a factor exp(+-logZ_err)
        eta = (net.d + env.law.P.size + 4) * 2.0 ** -52
        lo, hi = max(0.0, est.lo - eta), min(1.0, est.hi + eta)
        zl, zh = Z * math.exp(-env.logZ_err), Z * math.exp(env.logZ_err)
    else:
        # E_Q W = p / Z exactly for the float coins (TiltEnvelope.weight uses
        # the same logZ); the weights themselves carry a relative rounding
        # error below 1e-12
        lo, hi = est.lo, est.hi
        zl, zh = Z, Z
    return Estimate(est.value * Z, lo * zl * (1 - 1e-12), min(1.0, hi * zh * (1 + 1e-12)),
                    est.samples, est.evaluations, delta, note=f"Z={Z:.3e}")


# --------------------------------------------------------------------------
# narrow nets: exact deterministic interval by DP over all hidden forms
# --------------------------------------------------------------------------


def small_width_interval(net: MLP, budget: int | None = None) -> tuple[float, float]:
    """For a one-hidden-layer net with at most 3 hidden units: a deterministic
    interval [lo, hi] containing p = Pr[F < t]. The joint law of the quantised
    pre-activations s = N x is exact (form_dp); on each cell F lies between
    c + (smallest value of sum_j a_j relu(z_j) on the cell) and c + (largest),
    so cells whose largest value is < t fail entirely and cells whose smallest
    value is >= t do not fail at all:

        lo = D(cells with c + max < t),   hi = D(cells with c + min < t).

    Exact cell probabilities (uniform measure, d <= 53); the comparisons use
    values rounded outward (group_cells). Cost poly(d) * (2 budget + 1)^m: the
    regime where analytic DP is exact, independent of how rare the event is."""
    W, b, a, c = one_layer(net)
    m = W.shape[0]
    if m > 3:
        raise ValueError("at most 3 hidden units")
    budget = budget or {1: 1 << 16, 2: 2000, 3: 150}[m]
    G = list(range(m))
    P, vlo = group_cells(net, G, budget, "relu", "pess")
    _, vhi = group_cells(net, G, budget, "relu", "opt")
    t = float(net.threshold)
    # F >= c_lo + vlo and F <= c_hi + vhi on each cell (c is a float, exact)
    # (the float sum c + v is within (|c| + |v|) 2^-53 of the exact one)
    lo = float(P[c + vhi < t - (abs(c) + np.abs(vhi)) * 2.0 ** -50 - 1e-300].sum())
    hi = float(P[c + vlo < t + (abs(c) + np.abs(vlo)) * 2.0 ** -50 + 1e-300].sum())
    return lo, min(1.0, hi)


# --------------------------------------------------------------------------
# sign-pattern (softplus) envelope: a positive mixture of tilts
# --------------------------------------------------------------------------


@dataclass
class SignPatternEnvelope:
    """phi(x) = exp(theta (t' - g(x))) prod_{j in N} (1 + exp(alpha_j z_j(x)))

    for a one-hidden-layer net, where N is a set of units with a_j < 0,
    alpha_j >= theta |a_j|, and g = g0 - err + gam.x is the affine relaxation
    of all other units (affine_minorant_1 with N skipped: relu(z) >= s z for
    a_j > 0, the chord of the box range for a_j < 0). Domination, for every x
    in R^d (in particular every cube point):

        exp(theta (t' - F)) = exp(theta (t' - [c + sum_{j not in N} a_j relu(z_j)]))
                              * prod_{j in N} exp(theta |a_j| relu(z_j))
                           <= exp(theta (t' - g)) prod_{j in N} max(1, e^{alpha_j z_j})
                           <= phi,

    so phi >= 1 wherever F < t'. Expanding the product over the subsets T of N
    (the "sign patterns" of the units in N),

        phi(x) = sum_T exp(A_T + beta_T . x),
        A_T = theta (t' - g0 + err) + sum_{j in T} alpha_j b_j,
        beta_T = -theta gam + sum_{j in T} alpha_j w_j,

    a positive mixture of 2^|N| tilts: exact mass Z = sum_T e^{A_T} prod_i
    cosh(beta_T,i) and exact sampler (T with probability proportional to its
    term, then independent coins Pr[x_i = +1] = e^{beta_i} / (2 cosh beta_i)).

    Barrier: E_D e^{beta . x} = prod_i cosh beta_i >= 1, so Z >= phi(0) =
    e^{theta (t' - g0 + err)} prod_{j in N} (1 + e^{alpha_j b_j})
    >= exp(theta (t' - F(0))): if F(0) < t then Z > 1 for every choice of the
    parameters (the same holds for every positive mixture of tilts whose
    domination is proved by inequalities valid on all of R^d)."""

    net: MLP
    theta: float
    g0: float
    gam: np.ndarray
    err: float
    N: list
    alpha: np.ndarray  # (|N|,)
    tp: float  # t'
    logZ: float
    logZ_err: float
    log_terms: np.ndarray  # log mass of each subset T (bit r of T <-> N[r])

    def _beta(self, T: np.ndarray) -> np.ndarray:
        W, b, a, c = one_layer(self.net)
        bits = ((T[:, None] >> np.arange(len(self.N))) & 1).astype(float)  # (n, |N|)
        return -self.theta * self.gam[None, :] + bits @ (self.alpha[:, None] * W[self.N])

    def sample(self, n: int, rng: np.random.Generator) -> np.ndarray:
        from .dist import _bernoulli
        from scipy.special import expit
        lt = self.log_terms
        pr = np.exp(lt - lt.max())
        T = rng.choice(lt.size, size=n, p=pr / pr.sum())
        B = self._beta(T)
        q = expit(2.0 * B)  # e^{beta} / (2 cosh beta)
        return np.where(_bernoulli(q, rng.random(q.shape), rng), 1.0, -1.0)

    def log_phi(self, X: np.ndarray) -> np.ndarray:
        W, b, a, c = one_layer(self.net)
        Zp = X @ W[self.N].T + b[self.N]
        return self.theta * (self.tp - self.g0 + self.err - X @ self.gam) \
            + np.sum(np.logaddexp(0.0, Zp * self.alpha[None, :]), axis=1)

    def weight(self, X: np.ndarray, fails: np.ndarray) -> np.ndarray:
        """W = 1[F(x) < t] / phi(x) (in [0, 1] by domination; clipped against
        rounding, which is covered by logZ_err)."""
        return np.where(fails, np.exp(-np.maximum(self.log_phi(X), 0.0)), 0.0)

    @property
    def Z(self) -> float:
        return math.exp(min(self.logZ, 700.0))


def _subset_lse(A0: float, base: np.ndarray, Wn: np.ndarray, bn: np.ndarray, grad: bool = False,
                chunk: int = 1 << 14):
    """log sum_T exp(A0 + sum_{r in T} bn_r + sum_i log cosh(base_i + sum_{r in T} Wn_ri))
    over all subsets T of range(len(bn)); optionally also the softmax average
    of tanh(beta_T) (a d-vector), of sum_{r in T} bn_r + tanh(beta_T).(beta_T - base)
    pieces needed for gradients, and the per-subset log terms."""
    k = len(bn)
    nT = 1 << k
    logs = np.empty(nT)
    for s in range(0, nT, chunk):
        T = np.arange(s, min(s + chunk, nT))
        bits = ((T[:, None] >> np.arange(k)) & 1).astype(float)
        B = base[None, :] + bits @ Wn
        y = np.abs(B)
        logs[s:s + len(T)] = A0 + bits @ bn + np.sum(y + np.log1p(np.exp(-2 * y)) - math.log(2), axis=1)
    m = logs.max()
    w = np.exp(logs - m)
    tot = w.sum()
    lz = m + math.log(tot)
    if not grad:
        return lz, logs
    Et = np.zeros(Wn.shape[1])
    Ebeta_t = 0.0
    EA = 0.0
    for s in range(0, nT, chunk):
        T = np.arange(s, min(s + chunk, nT))
        bits = ((T[:, None] >> np.arange(k)) & 1).astype(float)
        B = base[None, :] + bits @ Wn
        th = np.tanh(B)
        ww = w[s:s + len(T)] / tot
        Et += ww @ th
        Ebeta_t += float(ww @ np.sum(th * B, axis=1))
        EA += float(ww @ (bits @ bn))
    return lz, logs, Et, Ebeta_t, EA


def sign_pattern_envelope(net: MLP, n_split: int | None = None, restarts: int = 3,
                          rng: np.random.Generator | None = None,
                          theta_grid=(0.3, 1.0, 3.0, 10.0, 30.0, 100.0)) -> SignPatternEnvelope:
    """The SignPatternEnvelope with N = the n_split negative-weight units of
    largest |a_j| ||w_j||_1 (the others get the chord relaxation of their box
    range), theta and the slopes s_j of the positive units chosen to minimise
    log Z (L-BFGS with the analytic gradient, started from every theta in
    theta_grid and from `restarts` random points; domination holds for every
    parameter value). n_split = None tries 0, 4, 8, 12, 16 (capped by the
    number of negative units) and keeps the smallest mass; n_split = 0 is the
    plain tilt with chord relaxations."""
    W, b, a, c = one_layer(net)
    neg_count = int(np.sum(a < 0))
    if n_split is None:
        cands = sorted(set(min(k, neg_count) for k in (0, 4, 8, 12, 16)))
        envs = [sign_pattern_envelope(net, k, restarts, rng, theta_grid) for k in cands]
        return min(envs, key=lambda e: e.logZ)
    return _sign_pattern_fixed(net, n_split, restarts, rng or np.random.default_rng(0), theta_grid)


def _sign_pattern_fixed(net, n_split, restarts, rng, theta_grid):
    from scipy.optimize import minimize

    W, b, a, c = one_layer(net)
    m, d = W.shape
    tp = _up(float(net.threshold) + forward_error_bound(net))
    lo, hi = box_bounds(net)[0]
    neg = [j for j in range(m) if a[j] < 0 and hi[j] > 0]  # units with hi <= 0 never fire
    neg.sort(key=lambda j: -abs(a[j]) * np.abs(W[j]).sum())
    N = sorted(neg[:n_split])
    pos = np.nonzero(a > 0)[0]
    kap = np.where(hi > lo, np.clip(hi / np.maximum(hi - lo, 1e-300), 0.0, 1.0), 0.0)

    def parts(lt, sp):
        th = math.exp(lt)
        sig = np.zeros(m)
        sig[pos] = 1 / (1 + np.exp(-sp))
        g0, gam, err = affine_minorant_1(net, sig, kap, skip=set(N))
        al = th * np.abs(a[N]) * (1 + 2.0 ** -50)
        return th, sig, g0, gam, err, al

    def obj(p):
        lt, sp = p[0], p[1:]
        th, sig, g0, gam, err, al = parts(lt, sp)
        Wn = al[:, None] * W[N]
        bn = al * b[N]
        base = -th * gam
        A0 = th * (tp - g0 + err)
        with np.errstate(over="ignore"):
            lz, logs, Et, Ebt, EA = _subset_lse(A0, base, Wn, bn, grad=True)
        # d/d(log theta): every A_T and beta_T is proportional to theta
        g_lt = A0 + EA + Ebt
        # d/ds_j (a_j > 0): gam += a_j s_j w_j, g0 += a_j s_j b_j
        ds = -th * a[pos] * (b[pos] + W[pos] @ Et)
        s = sig[pos]
        g_sp = ds * s * (1 - s)
        if not math.isfinite(lz):
            return 1e300, np.zeros_like(p)
        return lz, np.concatenate([[g_lt], g_sp])

    starts = [np.concatenate([[math.log(th0)], np.zeros(len(pos))]) for th0 in theta_grid]
    starts += [np.concatenate([[rng.uniform(-3, 4)], rng.normal(0, 1, len(pos))]) for _ in range(restarts)]
    best = None
    for p0 in starts:
        res = minimize(obj, p0, jac=True, method="L-BFGS-B",
                       bounds=[(-12.0, 8.0)] + [(-30.0, 30.0)] * len(pos))
        if best is None or res.fun < best.fun:
            best = res
    th, sig, g0, gam, err, al = parts(best.x[0], best.x[1:])
    Wn = al[:, None] * W[N]
    bn = al * b[N]
    lz, logs = _subset_lse(th * (tp - g0 + err), -th * gam, Wn, bn)
    # rounding: each log term is a sum of <= d + |N| + 2 float terms of size
    # <= max|beta| + |A|, each with a relative error below 2^-50
    scale = abs(th * (tp - g0 + err)) + float(np.abs(bn).sum()) + float(np.abs(th * gam).sum() + np.abs(Wn).sum())
    lz_err = 1e-12 * (1 + scale) + (d + len(N) + 4) * 2.0 ** -50 * (1 + scale)
    return SignPatternEnvelope(net, th, g0, gam, err, list(N), al, tp, float(lz), float(lz_err), logs)


# --------------------------------------------------------------------------
# perturb-and-MAP: upper bounds on the log-partition function from MAP calls
# --------------------------------------------------------------------------


def _half_table(net: MLP, dtype=np.float64, rows: int = 16):
    """f_fl on the whole cube as a (2^k1, 2^k2) table, x = (u, v) with u the
    first k1 = d // 2 coordinates (bit i of the row index is u_i = +1) and v
    the rest (meet in the middle on the first layer)."""
    from .nets import _half_inputs
    d = net.d
    if d > 30:
        raise ValueError("table only for d <= 30")
    k1 = d // 2
    k2 = d - k1
    W, b = net.Ws[0], net.bs[0]
    A = _half_inputs(k1) @ W[:, :k1].T + b
    B = _half_inputs(k2) @ W[:, k1:].T
    F = np.empty((1 << k1, 1 << k2), dtype=dtype)
    for s in range(0, 1 << k1, rows):
        h = np.maximum(A[s:s + rows, None, :] + B[None, :, :], 0.0)
        for Wl, bl in zip(net.Ws[1:-1], net.bs[1:-1]):
            h = np.maximum(h @ Wl.T + bl, 0.0)
        F[s:s + rows] = (h @ net.Ws[-1].T + net.bs[-1])[..., 0]
    return F, k1, k2


class EnumMAPOracle:
    """An exact MAP oracle for d <= 30 (by enumeration; a stand-in for a
    complete MILP / branch-and-bound solver, whose dual bound would serve the
    same purpose for larger d). Answers, for a perturbation g(x) = gA[u] +
    gB[v], an UPPER bound on max_x [-theta F(x) + g(x)] with F the exact net:
    the float table value f_fl is within tau of F, so the computed maximum plus
    theta tau (plus a relative 2^-40 for the float additions) is an upper
    bound. Also sound bounds Fmin <= min F, Fmax >= max F."""

    def __init__(self, net: MLP, dtype=np.float64):
        self.net = net
        self.F, self.k1, self.k2 = _half_table(net, dtype)
        self.tau = forward_error_bound(net) + (0.0 if dtype == np.float64 else
                                               float(np.abs(self.F).max()) * 2.0 ** -22)
        self.Fmin = float(self.F.min()) - self.tau
        self.Fmax = float(self.F.max()) + self.tau
        self.calls = 0

    def max_perturbed(self, theta: float, gA: np.ndarray, gB: np.ndarray, rows: int = 512) -> float:
        self.calls += 1
        best = -np.inf
        gB = gB.astype(self.F.dtype)
        for s in range(0, self.F.shape[0], rows):
            V = (-theta) * self.F[s:s + rows] + gB[None, :]
            V += gA[s:s + rows, None].astype(self.F.dtype)
            best = max(best, float(V.max()))
        mag = theta * max(abs(self.Fmin), abs(self.Fmax)) + float(np.abs(gA).max() + np.abs(gB).max())
        return best + theta * self.tau + mag * 2.0 ** -40 * (1 if self.F.dtype == np.float64 else 2.0 ** 18)


def _block_gumbels(k: int, block: int, rng: np.random.Generator):
    """Zero-mean Gumbel perturbations for the coordinates of one half (k
    coordinates, bit i of the index <-> coordinate i), in blocks of `block`
    consecutive coordinates: returns g (2^k,) with g[u] = sum over blocks of
    gamma_block(u restricted to the block), and S = sum over blocks of
    max_v gamma_block(v)."""
    idx = np.arange(1 << k)
    g = np.zeros(1 << k)
    S = 0.0
    for s0 in range(0, k, block):
        L = min(block, k - s0)
        gam = rng.gumbel(size=1 << L) - np.euler_gamma
        g += gam[(idx >> s0) & ((1 << L) - 1)]
        S += float(gam.max())
    return g, S


def perturb_map_samples(oracle: EnumMAPOracle, theta: float, block: int, n: int,
                        rng: np.random.Generator) -> np.ndarray:
    """n i.i.d. copies of R = M - S, M = max_x [-theta F(x) + sum_b gamma_b(x_b)]
    (upper-bounded by the oracle), S = sum_b max_v gamma_b(v). By Hazan and
    Jaakkola (2012, Thm. 1; blocks: the same induction over the blocks),
    log sum_x e^{-theta F(x)} <= E M, and E S = d log 2 (the maximum of N
    i.i.d. zero-mean Gumbels has mean log N), so log E_D e^{-theta F} <= E R.
    Always -theta Fmax <= R <= -theta Fmin."""
    out = np.empty(n)
    for r in range(n):
        gA, SA = _block_gumbels(oracle.k1, block, rng)
        gB, SB = _block_gumbels(oracle.k2, block, rng)
        out[r] = oracle.max_perturbed(theta, gA, gB) - (SA + SB)
    return out


def maurer_pontil_upper(X: np.ndarray, delta: float) -> float:
    """One-sided empirical Bernstein bound (Maurer and Pontil 2009, Thm. 4):
    for i.i.d. X_i in [0, 1], with probability >= 1 - delta,
    E X <= mean + sqrt(2 V ln(2/delta) / n) + 7 ln(2/delta) / (3 (n - 1)),
    V the unbiased sample variance. Rounded up generously."""
    X = np.clip(np.asarray(X, dtype=float), 0.0, 1.0)
    n = X.size
    L = math.log(2.0 / delta)
    V = float(X.var(ddof=1))
    ub = float(X.mean()) + math.sqrt(2 * V * L / n) + 7 * L / (3 * (n - 1))
    return min(1.0, ub * (1 + 1e-12) + 1e-15)


def perturb_map_bound(oracle: EnumMAPOracle, theta: float, block: int, n: int, delta: float,
                      rng: np.random.Generator) -> Bound:
    """Rigorous upper bound on p = Pr[F < t] (probability >= 1 - delta):

        p <= E e^{theta (t - F)} = e^{theta t} E_D e^{-theta F} <= exp(theta t + E R),

    with E R bounded above from n samples by maurer_pontil_upper on
    X = (R + theta Fmax) / (theta (Fmax - Fmin)) in [0, 1] (the oracle's R is
    an upper bound on the ideal R, so X is too; clipping at 1 keeps it one).
    Gumbels are generated in floating point; their deviation from the ideal
    law shifts E R by far less than the added 1e-9 d.
    Sound for every net given a MAP oracle that returns upper bounds; theta
    and block must be fixed before the samples are drawn."""
    R = perturb_map_samples(oracle, theta, block, n, rng)
    rng_w = theta * (oracle.Fmax - oracle.Fmin)
    X = (R + theta * oracle.Fmax) / rng_w
    ub = maurer_pontil_upper(X, delta)
    ER = ub * rng_w - theta * oracle.Fmax + 1e-9 * oracle.net.d
    logb = theta * float(oracle.net.threshold) + ER
    logb += 1e-12 * (1 + abs(logb) + theta * abs(oracle.Fmax))
    return Bound(math.exp(min(logb, 0.0)), logb, note=f"perturb-MAP, block {block}",
                 params={"theta": theta, "block": block, "n": n, "R_mean": float(R.mean()),
                         "R_sd": float(R.std(ddof=1)), "map_calls": n})


# --------------------------------------------------------------------------
# oracle diagnostics from the full table (d <= 30): ceilings of method families
# --------------------------------------------------------------------------


def symmetric_gap(F: np.ndarray, t: float) -> float:
    """min_x (F(x) + F(-x)) / 2 - t over the cube (x -> -x reverses both half
    indices). If negative, EVERY exponential-tilt envelope exp(theta (t - g))
    with an affine g <= F on the cube (any certificate, not only box
    relaxations) has mass >= 1: g0 = (g(x) + g(-x))/2 <= (F(x) + F(-x))/2 for
    every x, and E_D e^{-theta gam.x} >= 1, so Z >= e^{theta (t - g0)} > 1."""
    n = F.shape[0]
    best = math.inf
    for s in range(0, n, 256):
        e = min(n, s + 256)
        blk = F[s:e].astype(np.float64) + F[n - s - 1:(n - e - 1 if n - e - 1 >= 0 else None):-1, ::-1]
        best = min(best, float(blk.min()))
    return 0.5 * best - t


def _table_argmin(F: np.ndarray, th: float, uA: np.ndarray, uB: np.ndarray, rows: int = 256):
    """min over the table of th F[a, b] - uA[a] - uB[b] (float64, row chunks)
    and its position (a, b)."""
    best, pos = math.inf, (0, 0)
    for s in range(0, F.shape[0], rows):
        V = th * F[s:s + rows].astype(np.float64) - uA[s:s + rows, None] - uB[None, :]
        i = int(np.argmin(V))
        if V.flat[i] < best:
            best, pos = float(V.flat[i]), (s + i // F.shape[1], i % F.shape[1])
    return best, pos


def best_tilt_oracle(F: np.ndarray, t: float, iters: int = 200, seed: int = 0) -> dict:
    """The smallest mass of an exponential-tilt envelope exp(theta (t - g0 - gam.x))
    with g0 + gam.x <= F on the WHOLE cube (exact domination, checked against
    the table): minimise theta t - min_x (theta F(x) - u.x) + sum_i log cosh u_i
    over (theta, u = theta gam), a convex function (subgradient: x*), by
    L-BFGS, with |u_i| <= 17 (as in _tilt_from_affine). A ceiling for the
    tilt family (the inner minimum is the NP-hard verification problem; see
    cube_tilt_envelope for the certified version)."""
    from scipy.optimize import minimize
    from .nets import _half_inputs
    k1 = int(round(math.log2(F.shape[0])))
    k2 = int(round(math.log2(F.shape[1])))
    HA, HB = _half_inputs(k1), _half_inputs(k2)
    gap = symmetric_gap(F, t)
    if gap <= 0:
        return {"logZ": 0.0, "barred": True, "sym_gap": gap}
    if float(F.min()) > t:
        # p = 0: the constant minorant g = min F > t gives Z -> 0 as theta -> oo
        return {"logZ": -math.inf, "barred": False, "sym_gap": gap, "theta": math.inf}

    def obj(p):
        th = math.exp(p[0])
        u = p[1:]
        mn, (a_, b_) = _table_argmin(F, th, HA @ u[:k1], HB @ u[k1:])
        xs = np.concatenate([HA[a_], HB[b_]])
        lz = th * t - mn + float(np.sum(np.logaddexp(u, -u) - math.log(2)))
        g = np.concatenate([[th * (t - float(F[a_, b_]))], xs + np.tanh(u)])
        return lz, g

    rng = np.random.default_rng(seed)
    best = None
    for r in range(3):
        p0 = np.concatenate([[rng.uniform(-1, 3)], np.zeros(k1 + k2)])
        res = minimize(obj, p0, jac=True, method="L-BFGS-B", options={"maxiter": iters},
                       bounds=[(-10.0, 12.0)] + [(-17.0, 17.0)] * (k1 + k2))
        if best is None or res.fun < best.fun:
            best = res
    return {"logZ": float(min(best.fun, 0.0)), "barred": False, "sym_gap": gap,
            "theta": math.exp(best.x[0])}


def cube_tilt_envelope(net: MLP, oracle: "EnumMAPOracle", iters: int = 200, seed: int = 0,
                       starts: int = 3) -> TiltEnvelope:
    """An exponential-tilt envelope whose affine minorant is certified on the
    CUBE by an exact minimisation instead of a box relaxation (escaping the
    box barrier):

        g0 := a lower bound on min_x (F(x) - gam.x)  (one MAP call),
        phi(x) = exp(theta (t' - g0 - gam.x)) >= 1 whenever F(x) < t',

    because F(x) >= g0 + gam.x at every cube point. Mass, sampler and weights
    as for tilt_envelope (exact). The pair (theta, gam) is chosen by
    minimising log Z = theta (t' - g0(gam)) + sum_i log cosh(theta gam_i), a
    convex function, with one MAP call per evaluation (here the table of
    `oracle`, so this is best_tilt_oracle; any choice is valid). The final g0
    is recomputed from the oracle's certified upper bound on
    max_x (gam.x - F(x)). Barred (Z >= 1 for every gam) when
    symmetric_gap(F, t) < 0. Returns the envelope; .note records the number of
    MAP calls used."""
    from .nets import _half_inputs
    F = oracle.F
    t = float(net.threshold)
    if symmetric_gap(F, t) <= 0:
        raise ValueError("cube barrier: min_x (F(x) + F(-x))/2 < t, every tilt envelope has Z >= 1")
    from scipy.optimize import minimize
    k1, k2 = oracle.k1, oracle.k2
    HA, HB = _half_inputs(k1), _half_inputs(k2)
    calls = [0]

    def obj(p):
        calls[0] += 1
        th = math.exp(p[0])
        u = p[1:]
        mn, (a_, b_) = _table_argmin(F, th, HA @ u[:k1], HB @ u[k1:])
        lz = th * t - mn + float(np.sum(np.logaddexp(u, -u) - math.log(2)))
        g = np.concatenate([[th * (t - float(F[a_, b_]))], np.concatenate([HA[a_], HB[b_]]) + np.tanh(u)])
        return lz, g

    rng = np.random.default_rng(seed)
    best = None
    for r in range(starts):
        p0 = np.concatenate([[rng.uniform(-1, 3)], np.zeros(k1 + k2)])
        res = minimize(obj, p0, jac=True, method="L-BFGS-B", options={"maxiter": iters},
                       bounds=[(-10.0, 12.0)] + [(-17.0, 17.0)] * (k1 + k2))
        if best is None or res.fun < best.fun:
            best = res
    th = math.exp(best.x[0])
    gam = best.x[1:] / th
    # certified offset: max_x (gam.x - F(x)) <= M (oracle upper bound, theta = 1)
    M = oracle.max_perturbed(1.0, HA @ gam[:k1], HB @ gam[k1:])
    g0 = -M - 1e-12 * (1 + abs(M) + float(np.abs(gam).sum()))
    env = _tilt_from_affine(net, g0, gam, 0.0, th, note=f"cube-certified tilt, {calls[0] + 1} MAP calls")
    return env


def moment_bounds(P: np.ndarray, v: np.ndarray, t: float, kmax: int = 60) -> dict:
    """From the exact law of f (probabilities P on values v): the polynomial
    Markov bounds E (f - mu)^{2k} / (mu - t)^{2k}, k = 1..kmax/2 (what any
    exact-moment method of order 2k can certify; computing E f^{2k} exactly
    needs the joint law of 2k hidden units)."""
    mu = float(np.dot(P, v))
    if mu <= t:
        return {"best": 1.0, "order": 0, "by_order": {}}
    out = {}
    for k in range(2, kmax + 1, 2):
        out[k] = float(np.dot(P, (v - mu) ** k) / (mu - t) ** k)
    kb = min(out, key=out.get)
    return {"best": min(1.0, out[kb]), "order": kb, "by_order": out}


# --------------------------------------------------------------------------
# diagnostics (exhaustive; d <= 28)
# --------------------------------------------------------------------------


def enumerate_outputs(net: MLP, fn, block: int = 1 << 20):
    """Call fn(X, f) on consecutive blocks of the enumeration of {-1,+1}^d."""
    from .nets import all_inputs
    d = net.d
    for s in range(0, 1 << d, block):
        X = all_inputs(d, s, min(s + block, 1 << d))
        fn(X, net.forward(X))


def output_histogram(net: MLP, bins: int = 200000, lo: float | None = None, hi: float | None = None):
    """Exact counts of f over the cube in fine bins (by enumeration), with the
    smallest value seen in each bin: enough for the exact (oracle) Chernoff
    bound up to the bin resolution (using bin minima keeps it an upper bound)."""
    W, b = net.Ws[0], net.bs[0]
    if lo is None:
        lo, hi = -50.0, 50.0
    edges = np.linspace(lo, hi, bins + 1)
    cnt = np.zeros(bins)
    mn = np.full(bins, np.inf)

    def fn(X, f):
        ix = np.clip(np.searchsorted(edges, f, side="right") - 1, 0, bins - 1)
        cnt[:] += np.bincount(ix, minlength=bins)
        np.minimum.at(mn, ix, f)

    enumerate_outputs(net, fn)
    ok = cnt > 0
    return cnt[ok], mn[ok]


def oracle_chernoff(cnt: np.ndarray, vmin: np.ndarray, t: float, d: int) -> float:
    """min_theta exp(theta t) E exp(-theta f) from exact counts (bin minima):
    the best any Chernoff (MGF) bound can do; not a method, a ceiling."""
    from scipy.optimize import minimize_scalar
    P = cnt / 2.0 ** d

    def lb(lt):
        th = math.exp(lt)
        return th * t + _lse(-th * vmin, P)

    r = minimize_scalar(lb, bounds=(-6, 8), method="bounded")
    return math.exp(min(r.fun, 0.0))
