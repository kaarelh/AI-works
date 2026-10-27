"""Fully connected ReLU networks with explicit weight lists, plus training."""

import math

import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F

torch.set_num_threads(max(1, torch.get_num_threads()))


class MLP(nn.Module):
    """x -> relu(W1 x + b1) -> ... -> W_L h + b_L.  Output dim 1 = binary logit."""

    def __init__(self, widths, init_scale=1.0, seed=0, zero_last=False):
        super().__init__()
        self.widths = list(widths)
        g = torch.Generator().manual_seed(seed)
        layers = []
        for a, b in zip(widths[:-1], widths[1:]):
            lin = nn.Linear(a, b)
            # PyTorch default init (U(-1/sqrt(a), 1/sqrt(a)) for W and b), drawn
            # from an explicit generator so the init is a function of the seed.
            bound = 1.0 / math.sqrt(a)
            with torch.no_grad():
                lin.weight.copy_((torch.rand(b, a, generator=g) * 2 - 1) * bound * init_scale)
                lin.bias.copy_((torch.rand(b, generator=g) * 2 - 1) * bound * init_scale)
            layers.append(lin)
        if zero_last:
            with torch.no_grad():
                layers[-1].weight.zero_()
                layers[-1].bias.zero_()
        self.layers = nn.ModuleList(layers)

    def forward(self, x):
        for lin in self.layers[:-1]:
            x = F.relu(lin(x))
        return self.layers[-1](x)

    def weights(self):
        """List of (W, b) as float64 numpy arrays."""
        return [(l.weight.detach().double().numpy().copy(), l.bias.detach().double().numpy().copy())
                for l in self.layers]

    def num_params(self):
        return sum(p.numel() for p in self.parameters())


def deterministic_dct_init(model, scale=1.0):
    """A data-independent, randomness-free init for an image MLP: the first
    layer's rows are the lowest-frequency 2-D DCT basis vectors (cycled with
    alternating sign if there are more units than needed), its bias 0.01,
    hidden layers identity-like, the last layer 0.  Costs 0 bits to describe."""
    from .certify import dct_basis
    with torch.no_grad():
        first = model.layers[0]
        d = first.weight.shape[1]
        B, freq = dct_basis(int(round(math.sqrt(d))))
        order = np.argsort(freq, kind="stable")
        H = first.weight.shape[0]
        rows = np.stack([B[:, order[i % d]] * (1 if (i // d) % 2 == 0 else -1) for i in range(H)])
        first.weight.copy_(torch.as_tensor(rows * scale, dtype=torch.float32))
        first.bias.fill_(0.01)
        for lin in model.layers[1:-1]:
            a, b = lin.weight.shape
            lin.weight.copy_(torch.eye(a, b))
            lin.bias.fill_(0.01)
        model.layers[-1].weight.zero_()
        model.layers[-1].bias.zero_()


def np_forward(weights, X, chunk=1 << 16):
    """Float64 forward pass of a weight list on numpy inputs; returns logits."""
    outs = []
    for s in range(0, X.shape[0], chunk):
        h = X[s:s + chunk].astype(np.float64)
        for W, b in weights[:-1]:
            h = np.maximum(h @ W.T + b, 0.0)
        W, b = weights[-1]
        outs.append(h @ W.T + b)
    return np.concatenate(outs, axis=0)


def np_predict(weights, X):
    z = np_forward(weights, X)
    if z.shape[1] == 1:
        return (z[:, 0] > 0).astype(np.int64)
    return z.argmax(axis=1)


def train(model, X, y, *, epochs=200, lr=1e-3, batch=128, wd=0.0, opt="adam",
          seed=0, loss="auto", stop_train_err=None, stop_loss=None, max_steps=None, verbose=False,
          extra_loss=None, weight_noise=0.0):
    """Trains `model` on (X, y).  Binary tasks: y in {0,1}, BCE on one logit.
    Multi-class: cross-entropy.  Stops early once the training error is
    <= stop_train_err (checked every epoch) if given."""
    Xt = torch.as_tensor(X, dtype=torch.float32)
    yt = torch.as_tensor(y)
    binary = model.widths[-1] == 1
    if opt == "adam":
        optim = torch.optim.Adam(model.parameters(), lr=lr, weight_decay=wd)
    elif opt == "adamw":
        optim = torch.optim.AdamW(model.parameters(), lr=lr, weight_decay=wd)
    else:
        optim = torch.optim.SGD(model.parameters(), lr=lr, momentum=0.9, weight_decay=wd)
    g = torch.Generator().manual_seed(seed + 7)
    noise_scale = [float(p.detach().pow(2).mean().sqrt()) * weight_noise for p in model.parameters()]
    n = Xt.shape[0]
    steps = 0
    hist = []
    for ep in range(epochs):
        perm = torch.randperm(n, generator=g)
        for s in range(0, n, batch):
            idx = perm[s:s + batch]
            if weight_noise > 0:
                saved = [p.detach().clone() for p in model.parameters()]
                with torch.no_grad():
                    for p, sc in zip(model.parameters(), noise_scale):
                        p.add_(torch.randn(p.shape, generator=g) * sc)
            out = model(Xt[idx])
            if binary:
                L = F.binary_cross_entropy_with_logits(out[:, 0], yt[idx].float())
            else:
                L = F.cross_entropy(out, yt[idx])
            if extra_loss is not None:
                L = L + extra_loss(model)
            optim.zero_grad()
            L.backward()
            if weight_noise > 0:
                with torch.no_grad():
                    for p, q in zip(model.parameters(), saved):
                        p.copy_(q)
            optim.step()
            steps += 1
            if max_steps is not None and steps >= max_steps:
                break
        err, mloss = train_error(model, Xt, yt, with_loss=True)
        hist.append(err)
        if verbose and (ep % 10 == 0):
            print(f"  epoch {ep} train err {err:.4f} loss {mloss:.5f}")
        if stop_train_err is not None and err <= stop_train_err and (stop_loss is None or mloss <= stop_loss):
            break
        if max_steps is not None and steps >= max_steps:
            break
    return {"epochs": ep + 1, "steps": steps, "train_err": hist[-1], "train_loss": mloss}


@torch.no_grad()
def train_error(model, Xt, yt, chunk=1 << 15, with_loss=False):
    wrong = 0
    tot = 0.0
    for s in range(0, Xt.shape[0], chunk):
        out = model(Xt[s:s + chunk])
        ys = yt[s:s + chunk]
        if out.shape[1] == 1:
            pred = (out[:, 0] > 0).long()
            if with_loss:
                tot += F.binary_cross_entropy_with_logits(out[:, 0], ys.float(), reduction="sum").item()
        else:
            pred = out.argmax(1)
            if with_loss:
                tot += F.cross_entropy(out, ys, reduction="sum").item()
        wrong += (pred != ys).sum().item()
    if with_loss:
        return wrong / Xt.shape[0], tot / Xt.shape[0]
    return wrong / Xt.shape[0]
