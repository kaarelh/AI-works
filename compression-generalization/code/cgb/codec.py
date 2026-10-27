"""Compressed networks ("students") and their code lengths.

A `QuantMLP` is a ReLU network that reads only a subset J of the input
coordinates and whose weights are integers times per-layer step sizes on a
log grid.  Its description is

    |J| and J (enumerative subset code), depth, hidden widths,
    for each layer: step exponents for W and b, then the integer weights
    (min of a dense KT code and a sparse support+KT code, plus 1 flag bit).

Optionally the weights are coded relative to a reference network that is a
function of a seed fixed before seeing the data (`ref`), in which case the
integers are round((W - W_ref)/step); `ref` costs nothing (see the
"initialization is free" lemma in the theory note), but we still charge
`seed_bits` for the seed.
"""

import math

import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F

from . import coding
from .models import MLP, np_forward


class QuantMLP:
    def __init__(self, n_inputs, coords, qweights, steps, ref=None, seed_bits=0.0):
        """qweights: list of (qW, qb) int arrays; steps: list of (sW, sb) given
        as integer exponents e with step = 2^(e/4)."""
        self.n = n_inputs
        self.coords = np.asarray(coords, dtype=np.int64)
        self.qweights = [(np.asarray(a, dtype=np.int64), np.asarray(b, dtype=np.int64)) for a, b in qweights]
        self.steps = [(int(a), int(b)) for a, b in steps]
        self.ref = ref
        self.seed_bits = seed_bits

    @staticmethod
    def step_value(e):
        return 2.0 ** (e / 4.0)

    def weights(self):
        out = []
        for li, ((qW, qb), (eW, eb)) in enumerate(zip(self.qweights, self.steps)):
            W = qW * self.step_value(eW)
            b = qb * self.step_value(eb)
            if self.ref is not None:
                W = W + self.ref[li][0]
                b = b + self.ref[li][1]
            out.append((W.astype(np.float64), b.astype(np.float64)))
        return out

    @property
    def widths(self):
        return [self.qweights[0][0].shape[1]] + [qW.shape[0] for qW, _ in self.qweights]

    def logits(self, X):
        return np_forward(self.weights(), X[:, self.coords])

    def predict(self, X):
        z = self.logits(X)
        if z.shape[1] == 1:
            return (z[:, 0] > 0).astype(np.int64)
        return z.argmax(axis=1)

    def description(self):
        d = coding.Description()
        d.add("input subset", coding.subset(self.n, len(self.coords)))
        w = self.widths
        d.add("architecture", coding.elias_delta(len(w) - 1) + sum(coding.elias_delta(h) for h in w[1:-1]))
        d.add("reference flag", 1.0)
        if self.ref is not None:
            d.add("seed", self.seed_bits)
        for li, ((qW, qb), (eW, eb)) in enumerate(zip(self.qweights, self.steps)):
            d.add("steps", coding.signed_int(eW) + coding.signed_int(eb))
            d.add(f"layer{li} W", coding.best_tensor_code(qW))
            d.add(f"layer{li} b", coding.best_tensor_code(qb))
        return d

    @property
    def bits(self):
        return self.description().bits


# ----------------------------------------------------------------------------
# Quantization-aware training with a straight-through estimator.
# ----------------------------------------------------------------------------

class _STERound(torch.autograd.Function):
    @staticmethod
    def forward(ctx, x):
        return torch.round(x)

    @staticmethod
    def backward(ctx, g):
        return g


def ste_quant(w, step):
    return _STERound.apply(w / step) * step


class QATNet(nn.Module):
    """A float MLP whose forward pass uses weights quantized at fixed steps."""

    def __init__(self, mlp, steps_exp):
        super().__init__()
        self.mlp = mlp
        self.steps_exp = steps_exp
        self.widths = mlp.widths

    def forward(self, x):
        L = len(self.mlp.layers)
        for i, lin in enumerate(self.mlp.layers):
            eW, eb = self.steps_exp[i]
            W = ste_quant(lin.weight, QuantMLP.step_value(eW))
            b = ste_quant(lin.bias, QuantMLP.step_value(eb))
            x = F.linear(x, W, b)
            if i < L - 1:
                x = F.relu(x)
        return x


def quantize_mlp(mlp, n_inputs, coords, steps_exp, ref=None, seed_bits=0.0):
    q = []
    for i, lin in enumerate(mlp.layers):
        eW, eb = steps_exp[i]
        W = lin.weight.detach().double().numpy()
        b = lin.bias.detach().double().numpy()
        if ref is not None:
            W = W - ref[i][0]
            b = b - ref[i][1]
        q.append((np.round(W / QuantMLP.step_value(eW)).astype(np.int64),
                  np.round(b / QuantMLP.step_value(eb)).astype(np.int64)))
    return QuantMLP(n_inputs, coords, q, steps_exp, ref=ref, seed_bits=seed_bits)


def default_steps(mlp, rel):
    """Step exponents set to `rel` times each layer's weight RMS (log grid)."""
    out = []
    for lin in mlp.layers:
        rmsW = float(lin.weight.detach().pow(2).mean().sqrt()) + 1e-12
        rmsb = float(lin.bias.detach().pow(2).mean().sqrt()) + 1e-12
        rmsb = max(rmsb, rmsW)
        out.append((int(round(4 * math.log2(rel * rmsW))), int(round(4 * math.log2(rel * rmsb)))))
    return out


def distill(student, Xs_pool, y_pool, *, steps=3000, batch=256, lr=3e-3, seed=0,
            qat_steps_exp=None):
    """Train `student` (an MLP on the selected coordinates) to match teacher
    labels y_pool on a pool Xs_pool of inputs drawn independently of the
    training set (already restricted to the student's coordinates).  With
    qat_steps_exp, trains through the quantizer (straight-through)."""
    g = torch.Generator().manual_seed(seed)
    net = student if qat_steps_exp is None else QATNet(student, qat_steps_exp)
    Xp = torch.as_tensor(Xs_pool, dtype=torch.float32)
    yp = torch.as_tensor(y_pool)
    opt = torch.optim.Adam(student.parameters(), lr=lr)
    sched = torch.optim.lr_scheduler.CosineAnnealingLR(opt, T_max=steps)
    N = Xp.shape[0]
    binary = student.widths[-1] == 1
    for t in range(steps):
        idx = torch.randint(0, N, (batch,), generator=g)
        out = net(Xp[idx])
        if binary:
            loss = F.binary_cross_entropy_with_logits(out[:, 0], yp[idx].float())
        else:
            loss = F.cross_entropy(out, yp[idx])
        opt.zero_grad()
        loss.backward()
        opt.step()
        sched.step()
    return student
