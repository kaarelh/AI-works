"""Coded MLPs for image tasks: weights = init + basis-coded quantized update.

For layer l with input basis M_l (orthonormal, d_in x d_in; identity or the
2-D DCT for the first layer of an image model), the compressed network g has

    W_l = W0_l + (step_l[band] * q_l) M_l^T,     b_l = b0_l + step_b_l * qb_l,

where W0, b0 are the initialization of the trained network f (a function of
a seed fixed in advance), q_l are integer matrices and the steps are on a
log grid, one per (layer, band of basis columns).  The description is

    architecture, per layer: band layout id, step exponents,
    per band: the integers q_l[:, band] (min of dense/sparse KT codes),
    biases likewise.

Training of g ("QAT") uses a straight-through estimator for the rounding,
optionally with a rate penalty lam * sum |c| / step that drives
coefficients to zero.
"""

import math

import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F

from . import coding
from .certify import dct_basis


class _Round(torch.autograd.Function):
    @staticmethod
    def forward(ctx, x):
        return torch.round(x)

    @staticmethod
    def backward(ctx, g):
        return g


def band_ids_for(basis_kind, d_in, band_edges=None):
    """Integer band id for each basis column."""
    if basis_kind == "dct":
        side = int(round(math.sqrt(d_in)))
        _, freq = dct_basis(side)
        edges = list(band_edges) + [10 ** 9]
        ids = np.zeros(d_in, dtype=np.int64)
        for j, (a, b) in enumerate(zip(edges[:-1], edges[1:])):
            ids[(freq >= a) & (freq < b)] = j
        return ids
    return np.zeros(d_in, dtype=np.int64)


class CodedMLP(nn.Module):
    def __init__(self, f_weights, init_weights, basis_kinds, band_edges=(0, 4, 8, 14, 22, 32),
                 rel_step=0.25, start="f"):
        """f_weights, init_weights: lists of (W, b) numpy arrays (the trained
        network and its initialization).  basis_kinds: per layer 'id' or 'dct'."""
        super().__init__()
        self.L = len(f_weights)
        self.basis_kinds = list(basis_kinds)
        self.band_edges = tuple(band_edges)
        self.W0 = []
        self.b0 = []
        self.M = []
        self.bands = []
        self.C = nn.ParameterList()
        self.cb = nn.ParameterList()
        self.step_exp = []      # per layer: np.array of exponents per band
        self.bstep_exp = []
        for l, ((W, b), (W0, b0), kind) in enumerate(zip(f_weights, init_weights, basis_kinds)):
            d_in = W.shape[1]
            if kind == "dct":
                B, _ = dct_basis(int(round(math.sqrt(d_in))))
            else:
                B = np.eye(d_in)
            ids = band_ids_for(kind, d_in, band_edges)
            D = (W - W0) @ B if start == "f" else np.zeros_like(W)  # coefficients of the update
            nb = int(ids.max()) + 1
            exps = np.zeros(nb, dtype=np.int64)
            for j in range(nb):
                rms = float(np.sqrt(np.mean(D[:, ids == j] ** 2))) + 1e-8
                exps[j] = int(round(4 * math.log2(rel_step * rms)))
            rmsb = float(np.sqrt(np.mean((b - b0) ** 2))) + 1e-8
            rmsb = max(rmsb, float(np.sqrt(np.mean(D ** 2))))
            self.step_exp.append(exps)
            self.bstep_exp.append(int(round(4 * math.log2(rel_step * rmsb))))
            self.register_buffer(f"W0_{l}", torch.as_tensor(W0, dtype=torch.float32))
            self.register_buffer(f"b0_{l}", torch.as_tensor(b0, dtype=torch.float32))
            self.register_buffer(f"M_{l}", torch.as_tensor(B, dtype=torch.float32))
            self.register_buffer(f"steps_{l}", torch.as_tensor(2.0 ** (exps[ids] / 4.0), dtype=torch.float32))
            self.bands.append(ids)
            self.C.append(nn.Parameter(torch.as_tensor(D, dtype=torch.float32)))
            self.cb.append(nn.Parameter(torch.as_tensor(b - b0 if start == "f" else np.zeros_like(b), dtype=torch.float32)))
        self.widths = [f_weights[0][0].shape[1]] + [W.shape[0] for W, _ in f_weights]

    def set_steps(self, layer, exps):
        self.step_exp[layer] = np.asarray(exps, dtype=np.int64)
        ids = self.bands[layer]
        getattr(self, f"steps_{layer}").copy_(torch.as_tensor(2.0 ** (self.step_exp[layer][ids] / 4.0)))

    def _layer(self, l, quant=True):
        st = getattr(self, f"steps_{l}")
        C = self.C[l]
        if quant:
            C = _Round.apply(C / st[None, :]) * st[None, :]
        W = getattr(self, f"W0_{l}") + C @ getattr(self, f"M_{l}").T
        bs = 2.0 ** (self.bstep_exp[l] / 4.0)
        cb = _Round.apply(self.cb[l] / bs) * bs if quant else self.cb[l]
        return W, getattr(self, f"b0_{l}") + cb

    def forward(self, x, quant=True):
        for l in range(self.L):
            W, b = self._layer(l, quant)
            x = F.linear(x, W, b)
            if l < self.L - 1:
                x = F.relu(x)
        return x

    def rate_penalty(self):
        """sum |c| / step: a differentiable proxy for the number of nonzeros."""
        tot = 0.0
        for l in range(self.L):
            st = getattr(self, f"steps_{l}")
            tot = tot + (self.C[l].abs() / st[None, :]).sum()
        return tot

    def integers(self):
        out = []
        for l in range(self.L):
            st = getattr(self, f"steps_{l}").detach().double().numpy()
            q = np.round(self.C[l].detach().double().numpy() / st[None, :]).astype(np.int64)
            bs = 2.0 ** (self.bstep_exp[l] / 4.0)
            qb = np.round(self.cb[l].detach().double().numpy() / bs).astype(np.int64)
            out.append((q, qb))
        return out

    def weights(self):
        """The compressed network's weights as float64 numpy (exactly what is coded)."""
        out = []
        for l, (q, qb) in enumerate(self.integers()):
            ids = self.bands[l]
            st = 2.0 ** (self.step_exp[l][ids] / 4.0)
            W0 = getattr(self, f"W0_{l}").double().numpy()
            M = getattr(self, f"M_{l}").double().numpy()
            W = W0 + (q * st[None, :]) @ M.T
            b = getattr(self, f"b0_{l}").double().numpy() + qb * 2.0 ** (self.bstep_exp[l] / 4.0)
            out.append((W, b))
        return out

    def description(self, seed_bits=32.0):
        d = coding.Description()
        d.add("architecture", coding.elias_delta(self.L) + sum(coding.elias_delta(h) for h in self.widths[1:-1]))
        d.add("seed", seed_bits)
        for l, (q, qb) in enumerate(self.integers()):
            d.add("basis", 1.0)  # identity or DCT (band layout fixed in advance)
            for j in range(int(self.bands[l].max()) + 1):
                d.add("steps", coding.signed_int(int(self.step_exp[l][j])))
                d.add(f"layer{l} W", coding.best_tensor_code(q[:, self.bands[l] == j]))
            d.add("steps", coding.signed_int(self.bstep_exp[l]))
            d.add(f"layer{l} b", coding.best_tensor_code(qb))
        return d


def init_weights_of(widths, seed, init_scale=1.0):
    from .models import MLP
    return MLP(widths, init_scale=init_scale, seed=seed).weights()
