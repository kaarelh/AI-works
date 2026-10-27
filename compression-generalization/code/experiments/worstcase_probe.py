"""Theorem 4 (certified transfer with worst-case weight sets) on an MNIST MLP:
why it needs very fine quantization.

f = 784-100-10, Adam 10 epochs.  g = f with its first-layer update quantized
in the DCT basis at step rel * RMS(band); K = per-unit, per-band l2 balls
around g that contain f (radii = the actual residual norms), plus a box on
the output layer.  Reports the certified fraction of 5000 training points and
the ratio between the certified first-layer radius and the actual
first-layer error |R x|, and the bits needed for the quantized coefficients.
Writes results/mnist/t3_worstcase_probe.txt.
"""
import math
import os
import sys

import numpy as np
import torch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from cgb import coding
from cgb.certify import Layer, certify, contains, dct_bands, dct_basis
from cgb.data import load_images
from cgb.models import MLP, train, np_predict

torch.set_num_threads(1)
Xtr, ytr, Xte, yte = load_images("mnist")
f = MLP([784, 100, 10], seed=0)
init = f.weights()
train(f, Xtr, ytr, epochs=10, lr=1e-3, batch=128, seed=0)
F = f.weights()
lines = [f"f: 784-100-10, train err {np.mean(np_predict(F, Xtr) != ytr):.4f}, test err {np.mean(np_predict(F, Xte) != yte):.4f}"]
edges = [0, 4, 8, 14, 22, 32]
bands = dct_bands(edges)
B, freq = dct_basis()
X, y = Xtr[:5000].astype(np.float64), ytr[:5000]
xn = np.stack([np.linalg.norm(X @ P, axis=1) for P in bands], 1)
(W1, b1), (W2, b2) = F
W10 = init[0][0]
D = (W1 - W10) @ B
lines.append("rel_step | certified fraction | mean actual |R x| | mean certified radius | ratio | bits for coefficients | bits/coefficient")
for rel in [0.01, 0.02, 0.05, 0.1, 0.2]:
    q = np.zeros_like(D)
    ints = []
    for j in range(len(bands)):
        cols = np.flatnonzero((freq >= edges[j]) & (freq < (edges + [10 ** 9])[j + 1]))
        st = rel * (np.sqrt(np.mean(D[:, cols] ** 2)) + 1e-12)
        k = np.round(D[:, cols] / st)
        q[:, cols] = k * st
        ints.append(k.astype(np.int64))
    bits = sum(coding.best_tensor_code(k) for k in ints)
    G1 = W10 + q @ B.T
    R = W1 - G1
    r = np.stack([np.linalg.norm(R @ P, axis=1) for P in bands], 1) * (1 + 1e-9)
    layers = [Layer(G1, b1, 0.0, [("l2", r[:, j], P) for j, P in enumerate(bands)]), Layer(W2, b2, 0.0, [])]
    assert contains(layers, F)
    c = certify(layers, X, y)
    act = np.abs(X[:500] @ R.T)
    rad = xn[:500] @ r.T
    lines.append(f"{rel} | {c.mean():.4f} | {act.mean():.4f} | {rad.mean():.4f} | {rad.mean() / act.mean():.1f} | "
                 f"{bits:.0f} | {bits / D.size:.2f}")
lines.append("The output layer is kept exact here (in favour of the certificate); m = 60000 training points, so a "
             "description much longer than 60000 bits gives a vacuous bound.")
out = os.path.join(os.path.dirname(__file__), "..", "..", "results", "mnist", "t3_worstcase_probe.txt")
os.makedirs(os.path.dirname(out), exist_ok=True)
open(out, "w").write("\n".join(lines) + "\n")
print("\n".join(lines))
