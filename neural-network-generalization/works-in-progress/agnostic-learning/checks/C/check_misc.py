"""Claim C, small constructions used in the text.
(1) Theorem C.5(c): the width-1 depth-L network with first-layer weight 2 on the constant coordinate, internal weights 2,
    readout 1/c_{L-1} computes exactly 1; its readout is <= 1.05.
(2) Remark C.4.1: parity on d bits within eps' uniformly, width d+1, weights O(d log(d/eps')):
    depth 2 with step gain A = log(2d/eps'); depth 3 with A = log(16(d+1)), the d+1 incoming weights of the summing
    neuron (the readout weights of the depth-2 circuit) all multiplied by A' = log(2/eps'), and readout weight 1.
"""
import numpy as np, itertools
from scipy.optimize import brentq
u_star = brentq(lambda u: u - np.tanh(2 * u), 0.5, 1.0)
print(f"fixed point of u = tanh(2u): {u_star:.6f}; tanh 2 = {np.tanh(2):.6f}")
for L in range(2, 12):
    c = np.tanh(2.0)
    for _ in range(L - 2):
        c = np.tanh(2 * c)
    print(f"  L={L}: c_(L-1) = {c:.6f}, readout = {1/c:.4f}, output = {c * (1/c):.12f}")

def parity_net(d, eps, depth):
    X = np.array(list(itertools.product([-1, 1], repeat=d))).T   # d x 2^d
    chi = np.prod(X, axis=0)
    t = (d + X.sum(0)) / 2.0
    y = np.array([(-1) ** (d - j) for j in range(d + 1)])
    cconst = (y[0] + y[d]) / 2.0
    A = np.log(2 * d / eps) if depth == 2 else np.log(16 * (d + 1))
    # first layer: d step neurons + constant neuron tanh(1); weights: inputs A/2, bias A(d/2 - j + 1/2)
    H = np.vstack([np.tanh(A / 2 * X.sum(0) + A * (d / 2 - j + 0.5)) for j in range(1, d + 1)] + [np.tanh(np.ones(X.shape[1]))])
    wout = np.concatenate([y[1:], [cconst / np.tanh(1.0)]])
    s = wout @ H
    maxw1 = max(A / 2, A * d / 2)
    if depth == 2:
        out = s; maxw = max(maxw1, np.abs(wout).max())
    else:
        Ap = np.log(2 / eps)
        out = np.tanh(Ap * s)          # layer 2 = last hidden layer (depth 3), readout 1
        maxw = max(maxw1, Ap * np.abs(wout).max())
    return np.abs(out - chi).max(), np.abs(s - chi).max(), maxw

for depth in [2, 3]:
    for d in [3, 6, 10]:
        for eps in [0.1, 0.01]:
            err, err1, maxw = parity_net(d, eps, depth)
            print(f"depth={depth} d={d:2d} eps'={eps}: sup|g - chi| = {err:.2e} (<= eps': {err <= eps}),  first-stage error {err1:.3f},  max |weight| = {maxw:.2f}")
