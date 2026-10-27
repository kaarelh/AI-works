"""Structure of the failure set of small suite nets (exact enumeration):
mean failing input, pairwise Hamming distances, clusters under single bit
flips, and the 'even part' (1/2) sum_j a_j |z_j| on failing vs typical inputs
(writes results/failures.txt)."""

import os
import sys

os.environ.setdefault("OMP_NUM_THREADS", "1")
import numpy as np  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import all_inputs, load_net  # noqa: E402


def failing(net, block=1 << 20):
    out = []
    for s in range(0, 1 << net.d, block):
        X = all_inputs(net.d, s, min(s + block, 1 << net.d))
        out.append(X[net.forward(X) < net.threshold])
    return np.concatenate(out)


def clusters(F):
    codes = {tuple(x): i for i, x in enumerate(F.astype(int))}
    parent = list(range(len(F)))

    def find(i):
        while parent[i] != i:
            parent[i] = parent[parent[i]]
            i = parent[i]
        return i
    for i, x in enumerate(F.astype(int)):
        for j in range(F.shape[1]):
            y = x.copy()
            y[j] = -y[j]
            k = codes.get(tuple(y))
            if k is not None:
                parent[find(i)] = find(k)
    roots = [find(i) for i in range(len(F))]
    return np.bincount(np.unique(roots, return_inverse=True)[1])


def main():
    lines = []
    rng = np.random.default_rng(0)
    for name in ["mse_d24_w32_s1000", "mse_d24_w32_s1500"]:
        path = os.path.join(HERE, "..", "nets", name + ".npz")
        if not os.path.exists(path):
            continue
        net = load_net(path)
        F = failing(net)
        if len(F) > 4000:
            F = F[rng.choice(len(F), 4000, replace=False)]
        H = (net.d - F @ F.T) / 2
        iu = np.triu_indices(len(F), 1)
        sizes = clusters(F)
        line = (f"{name}: {len(F)} failing inputs (sampled to <= 4000); |mean failing input| per coordinate: "
                f"mean {np.abs(F.mean(0)).mean():.3f}, max {np.abs(F.mean(0)).max():.3f}; pairwise Hamming distance "
                f"median {np.median(H[iu]):.0f}, min {H[iu].min():.0f}; clusters under single flips: {len(sizes)} "
                f"(largest {sizes.max()}, singletons {int((sizes == 1).sum())})")
        if len(net.Ws) == 2:
            W, b, a, c = net.Ws[0], net.bs[0], net.Ws[1][0], net.bs[1][0]
            X = np.where(rng.random((100000, net.d)) < 0.5, -1.0, 1.0)
            even = lambda Y: 0.5 * np.abs(Y @ W.T + b) @ a  # noqa: E731
            lin = lambda Y: 0.5 * (Y @ W.T + b) @ a  # noqa: E731
            line += (f"; ||sum_j a_j w_j|| = {np.linalg.norm(a @ W):.3g} vs sum_j |a_j| ||w_j|| = "
                     f"{np.sum(np.abs(a) * np.linalg.norm(W, axis=1)):.3g}; even part mean {even(X).mean():.3f} "
                     f"(failing {even(F).mean():.3f}), linear part sd {lin(X).std():.3f} (failing mean "
                     f"{lin(F).mean():.3f}, typical mean {lin(X).mean():.3f})")
        print(line, flush=True)
        lines.append(line)
    open(os.path.join(HERE, "results", "failures.txt"), "w").write("\n".join(lines) + "\n")


if __name__ == "__main__":
    main()
