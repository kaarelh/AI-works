"""Dithered compression and training-data-only bounds on the ORIGINAL network.

Network f (one hidden layer):  z_f(x) = V relu(W x + b) + c,  W = W0 + A B^T,
where W0 is the (free) initialization, B an orthonormal basis of input space
(identity or 2-D DCT) and A the update's coefficient matrix.

Subtractive dithered quantization with a PUBLIC dither xi (iid U[-1/2,1/2],
drawn from fresh entropy after training, independent of the data):
    K = round(A / s + xi_A),   A_g = s (K - xi_A)          (same for b, V, c)
The error eps = A_g - A is iid uniform on [-s/2, s/2] given f, whatever f is.
g is described by the integers K and the steps; xi is public.

Certificate.  At input x (xh = B^T x), with per-coefficient steps s_ik:
    w_i  = sum_k s_ik |xh_k| / 2 + s^b_i / 2           (worst-case |eta_i|)
    v_i  = sum_k s_ik^2 xh_k^2 / 12 + (s^b_i)^2 / 12  (sub-Gaussian proxy of eta_i)
where eta_i = u^g_i - u^f_i is g's minus f's pre-activation.  For each class
c != y, F_yc = (z_g,y - z_g,c) - (z_f,y - z_f,c) is a function of independent
uniforms with bounded differences, so by McDiarmid
    P[|F - EF| >= t2 sqrt(Sigma/2)] <= 2 exp(-t2^2),
    Sigma <= sum_i a_i^2 12 v_i + 2 (s^V)^2 sum_i Hh_i^2 + 2 (s^c)^2,
    a_i = |V^g_yi - V^g_ci| + 2 s^V,   Hh_i = relu(u^g_i + 2 w_i),
and the bias |EF| <= sum_i (|V^g_yi - V^g_ci| + s^V) beta_i with
    beta_i <= min( sqrt(v_i)/2, sqrt(2 pi v_i) Phibar(uh_i / sqrt(v_i)) ),
    uh_i = (|u^g_i| - t1 sqrt(v_i))_+,
valid on the event that all |eta_i| <= t1 sqrt(v_i) (prob >= 1 - 2H exp(-t1^2/2)).
pi_g(x, y) = 1 iff for all c != y: z_g,y - z_g,c > t2 sqrt(Sigma/2) + bias.

Theorem (see theory/README.md): with probability >= 1 - delta - delta' over
the training sample and the dither,
    err_D(f) <= Occam(#{i : pi_g(x_i, y_i) = 0}, L(g), delta) + eta / delta',
    eta = 2 H exp(-t1^2 / 2) + 2 (C - 1) exp(-t2^2).
Binary networks (one logit, label y in {0,1}) use the same with the single
"difference row" V (and (C - 1) = 1, a_i = |V^g_i| + s^V, bias weights
|V^g_i| + s^V / 2, Sigma <= sum a_i^2 12 v_i + (s^V)^2 sum Hh_i^2 + (s^c)^2).
"""

import math
import secrets

import numpy as np
from scipy.special import log_ndtr, ndtr

from . import coding
from .certify import dct_basis


def step_matrix(unit_exp, band_exp, band_ids):
    """s_ik = 2^((unit_exp[i] + band_exp[band(k)]) / 4)."""
    return 2.0 ** ((np.asarray(unit_exp)[:, None] + np.asarray(band_exp)[band_ids][None, :]) / 4.0)


class DitheredNet:
    """A dithered one-hidden-layer network g together with its description."""

    def __init__(self, f_weights, init_weights, basis, band_ids, unit_exp, band_exp,
                 b_exp, V_exp, c_exp, seed=None):
        (W, b), (V, c) = f_weights
        (W0, b0), (V0, c0) = init_weights
        self.seed = secrets.randbits(63) if seed is None else int(seed)
        rng = np.random.default_rng(self.seed)
        self.B = basis
        self.band_ids = np.asarray(band_ids)
        self.unit_exp = np.asarray(unit_exp, dtype=np.int64)
        self.band_exp = np.asarray(band_exp, dtype=np.int64)
        self.b_exp, self.V_exp, self.c_exp = int(b_exp), int(V_exp), int(c_exp)
        self.S = step_matrix(self.unit_exp, self.band_exp, self.band_ids)   # H x d
        self.sb = 2.0 ** (self.b_exp / 4.0)
        self.sV = 2.0 ** (self.V_exp / 4.0)
        self.sc = 2.0 ** (self.c_exp / 4.0)
        A = (W - W0) @ basis
        self.W0, self.b0, self.V0, self.c0 = W0, b0, V0, c0
        xiA = rng.uniform(-0.5, 0.5, A.shape)
        xib = rng.uniform(-0.5, 0.5, b.shape)
        xiV = rng.uniform(-0.5, 0.5, V.shape)
        xic = rng.uniform(-0.5, 0.5, c.shape)
        self.KA = np.round(A / self.S + xiA).astype(np.int64)
        self.Kb = np.round((b - b0) / self.sb + xib).astype(np.int64)
        self.KV = np.round((V - V0) / self.sV + xiV).astype(np.int64)
        self.Kc = np.round((c - c0) / self.sc + xic).astype(np.int64)
        self.Ag = self.S * (self.KA - xiA)
        self.bg = b0 + self.sb * (self.Kb - xib)
        self.Vg = V0 + self.sV * (self.KV - xiV)
        self.cg = c0 + self.sc * (self.Kc - xic)
        self.Wg = W0 + self.Ag @ basis.T
        # sanity: errors are within half a step
        assert np.all(np.abs(self.Ag - A) <= self.S / 2 + 1e-12)

    def weights(self):
        return [(self.Wg, self.bg), (self.Vg, self.cg)]

    def description(self, seed_bits=32.0):
        d = coding.Description()
        H, dim = self.KA.shape
        d.add("architecture", coding.elias_delta(2) + coding.elias_delta(H))
        d.add("init seed", seed_bits)
        d.add("basis", 1.0)
        d.add("unit steps", sum(coding.signed_int(e) for e in self.unit_exp))
        d.add("band steps", sum(coding.signed_int(e) for e in self.band_exp))
        d.add("other steps", coding.signed_int(self.b_exp) + coding.signed_int(self.V_exp) + coding.signed_int(self.c_exp))
        for j in range(int(self.band_ids.max()) + 1):
            d.add("layer0 W", coding.best_tensor_code(self.KA[:, self.band_ids == j]))
        d.add("layer0 b", coding.best_tensor_code(self.Kb))
        d.add("layer1 W", coding.best_tensor_code(self.KV))
        d.add("layer1 b", coding.best_tensor_code(self.Kc))
        return d

    # ------------------------------------------------------------------
    def certificate(self, X, y, t1=6.5, t2=4.5, chunk=2048):
        """pi_g(x, y) for each row of X; also returns the slack array
        (margin minus threshold, min over c) for diagnostics."""
        C = self.Vg.shape[0]
        out = np.zeros(len(y), dtype=bool)
        slack = np.zeros(len(y))
        S2 = self.S ** 2
        for s in range(0, len(y), chunk):
            Xs = X[s:s + chunk].astype(np.float64)
            ys = y[s:s + chunk]
            Xh = Xs @ self.B
            ug = Xs @ self.Wg.T + self.bg                      # (N, H)
            w = np.abs(Xh) @ self.S.T / 2 + self.sb / 2          # (N, H)
            v = (Xh ** 2) @ S2.T / 12 + self.sb ** 2 / 12
            sv = np.sqrt(v)
            Hh = np.maximum(ug + 2 * w, 0.0)
            uh = np.maximum(np.abs(ug) - t1 * sv, 0.0)
            # beta <= min(sqrt(v)/2, sqrt(2 pi v) * Phibar(uh/sqrt(v)))
            tail = np.sqrt(2 * np.pi * v) * ndtr(-uh / sv)
            beta = np.minimum(sv / 2, tail)
            hg = np.maximum(ug, 0.0)
            if C == 1:
                sgn = (2 * ys - 1).astype(np.float64)
                margin = sgn * (hg @ self.Vg[0] + self.cg[0])
                a = np.abs(self.Vg[0]) + self.sV                 # (H,)
                Sigma = (12 * v) @ (a ** 2) + self.sV ** 2 * np.sum(Hh ** 2, 1) + self.sc ** 2
                bias = beta @ (np.abs(self.Vg[0]) + self.sV / 2)
                thr = t2 * np.sqrt(Sigma / 2) + bias
                sl = margin - thr
            else:
                z = hg @ self.Vg.T + self.cg                     # (N, C)
                Dv = np.abs(self.Vg[ys][:, None, :] - self.Vg[None, :, :])   # (N, C, H)
                a2 = (Dv + 2 * self.sV) ** 2
                Sigma = (np.einsum("nch,nh->nc", a2, 12 * v)
                         + 2 * self.sV ** 2 * np.sum(Hh ** 2, 1)[:, None] + 2 * self.sc ** 2)
                bias = np.einsum("nch,nh->nc", Dv + self.sV, beta)
                thr = t2 * np.sqrt(Sigma / 2) + bias
                marg = z[np.arange(len(ys)), ys][:, None] - z
                slc = marg - thr
                slc[np.arange(len(ys)), ys] = np.inf
                sl = slc.min(1)
            out[s:s + chunk] = sl > 1e-9 * (1 + np.abs(sl))
            slack[s:s + chunk] = sl
        return out, slack


def certificate_v2(g, X, y, t1=6.5, t2=4.5, chunk=2048, return_parts=False):
    """Sharper certificate (theory/README.md, Lemma D2).

    With tau_i = t1 sqrt(v_i) and G = {all |eta_i| <= tau_i}, write
    F = sum_i d_i phi_i(eta_i) + T_V + T_c (d_i = f's V_yi - V_ci).  On G,
    phi_i(eta_i) = phi_i(clip(eta_i, tau_i)), which is
      * eta_i clipped (mean 0, proxy v_i) if u_i >= tau_i  ("active"),
      * 0 if u_i <= -tau_i ("inactive"),
      * a 1-Lipschitz function of eta_i (proxy 2 v_i, mean <= beta_i) otherwise.
    On G the unit's type is known from g when |u^g_i| >= 2 tau_i; units with
    |u^g_i| < 2 tau_i are charged proxy 2 v_i and bias beta_i.  T_V given eta
    is a linear form in the V-dithers with proxy (s_V^2/6) sum relu(u_i+tau_i)^2
    <= (s_V^2/6) sum relu(u^g_i + 2 tau_i)^2 (binary: s_V^2/12), T_c proxy
    s_c^2/6 (binary s_c^2/12).  Threshold: t2 sqrt(2 P) + bias.
    """
    C = g.Vg.shape[0]
    out = np.zeros(len(y), dtype=bool)
    slack = np.zeros(len(y))
    parts = []
    S2 = g.S ** 2
    for s in range(0, len(y), chunk):
        Xs = X[s:s + chunk].astype(np.float64)
        ys = y[s:s + chunk]
        Xh = Xs @ g.B
        ug = Xs @ g.Wg.T + g.bg
        v = (Xh ** 2) @ S2.T / 12 + g.sb ** 2 / 12
        sv = np.sqrt(v)
        tau = t1 * sv
        act = ug >= 2 * tau
        inact = ug <= -2 * tau
        mid = ~(act | inact)
        wfac = np.where(act, 1.0, np.where(mid, 2.0, 0.0))      # proxy multiplier
        uh = np.maximum(np.abs(ug) - tau, 0.0)
        beta = np.where(mid, np.minimum(sv / 2, np.sqrt(2 * np.pi * v) * ndtr(-uh / sv)), 0.0)
        Hh2 = np.maximum(ug + 2 * tau, 0.0) ** 2
        hg = np.maximum(ug, 0.0)
        if C == 1:
            sgn = (2 * ys - 1).astype(np.float64)
            margin = sgn * (hg @ g.Vg[0] + g.cg[0])
            d = np.abs(g.Vg[0]) + g.sV / 2
            P = (wfac * v) @ (d ** 2) + g.sV ** 2 / 12 * Hh2.sum(1) + g.sc ** 2 / 12
            bias = beta @ d
            sl = margin - (t2 * np.sqrt(2 * P) + bias)
            if return_parts:
                parts.append((margin[:, None], (t2 * np.sqrt(2 * P) + bias)[:, None]))
        else:
            z = hg @ g.Vg.T + g.cg
            Dv = np.abs(g.Vg[ys][:, None, :] - g.Vg[None, :, :]) + g.sV   # (N, C, H) bound on |d_i|
            P = (np.einsum("nch,nh->nc", Dv ** 2, wfac * v)
                 + g.sV ** 2 / 6 * Hh2.sum(1)[:, None] + g.sc ** 2 / 6)
            bias = np.einsum("nch,nh->nc", Dv, beta)
            marg = z[np.arange(len(ys)), ys][:, None] - z
            slc = marg - (t2 * np.sqrt(2 * P) + bias)
            if return_parts:
                parts.append((marg, t2 * np.sqrt(2 * P) + bias))
            slc[np.arange(len(ys)), ys] = np.inf
            sl = slc.min(1)
        out[s:s + chunk] = sl > 1e-9 * (1 + np.abs(sl))
        slack[s:s + chunk] = sl
    if return_parts:
        return out, slack, (np.concatenate([p[0] for p in parts]), np.concatenate([p[1] for p in parts]))
    return out, slack


def bad_event_prob(H, C, t1=6.5, t2=4.5):
    """eta = 2 H exp(-t1^2/2) + 2 max(C-1, 1) exp(-t2^2)."""
    return 2 * H * math.exp(-t1 ** 2 / 2) + 2 * max(C - 1, 1) * math.exp(-t2 ** 2)
