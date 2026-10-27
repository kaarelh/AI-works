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
  - envelope_interval: the two-sided interval (KL, sequential) from either.

Findings on the trained nets (experiments/nets_analytic): every upper bound
here is >= 0.2 (>= 0.6 on every net with exact p <= 1e-3) and every envelope has
Z >= 1, i.e. no gain over Monte Carlo. The reasons are structural: the
concentration of f comes from cancellations BETWEEN hidden units (the linear
parts cancel, sum_j a_j w_j ~ 0, and the even parts of the positive- and
negative-weight units are strongly positively correlated), which every
decoupled bound discards (decoupling floor >> p on the MSE nets) and Hoelder
pays for a second time (comonotone variance (sum_k sd F_k)^2 is 36-390 times
Var f); affine minorants fail by the box barrier (F(0) < t on the MSE nets);
few-form envelopes cannot contain the failures (oracle caps have K ~ 1/p).

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
        X = env.sample(k, rng)
        return env.weight(X, fails_exact(net, X, tau))

    if env.logZ > 0:  # worse than the trivial envelope phi = 1 (Monte Carlo)
        raise ValueError("envelope mass above 1: use plain Monte Carlo")
    est = sequential_mean(draw, eps, delta, max_samples=max_samples)
    Z = math.exp(env.logZ)
    if isinstance(env, GroupTiltEnvelope):
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
