"""Depth-L generalisation of attach.py.  MLP: out = w_L . relu(W_{L-1} ... relu(W_1 x~)).
Paths: N independent scalar chains out = sum_k a_k relu(b_k^{L-2} ... relu(b_k^1 relu(w_k . x~))).
Both are L-homogeneous.  Also records participation-ratio rank of each hidden layer."""
import numpy as np, itertools, json, sys

def cube(d):
    X = np.array(list(itertools.product([-1.0, 1.0], repeat=d)))
    return np.hstack([X, np.ones((len(X), 1))])

def run(arch, alpha, seed, L=4, d=8, N=32, A=1.0, B=0.8, lr=0.05, tmax=1e5, rec_every=0):
    rng = np.random.default_rng(seed)
    Xt = cube(d); X = Xt[:, :d]; n = len(Xt); D = d + 1
    y = A * X[:, 0] + B * X[:, 1] * X[:, 2]
    chi1, chi23 = X[:, 0], X[:, 1] * X[:, 2]
    if arch == "mlp":
        shapes = [(N, D)] + [(N, N)] * (L - 2) + [(N,)]
        fans = [D] + [N] * (L - 1)
    else:  # paths: first layer (N,D), then L-2 per-path scalars, then readout
        shapes = [(N, D)] + [(N,)] * (L - 2) + [(N,)]
        fans = [D] + [1] * (L - 2) + [N]
    P = [alpha * rng.standard_normal(s) / np.sqrt(f) for s, f in zip(shapes, fans)]
    T1 = T2 = None; t = 0.0; step = 0; log = []
    while t < tmax:
        hs, zs = [Xt], []
        for l in range(L - 1):
            z = hs[-1] @ P[l].T if (arch == "mlp" or l == 0) else hs[-1] * P[l]
            zs.append(z); hs.append(np.maximum(z, 0))
        out = hs[-1] @ P[-1]
        r = (out - y) / n
        G = [None] * L
        G[-1] = hs[-1].T @ r
        delta = np.outer(r, P[-1]) * (zs[-1] > 0)
        for l in range(L - 2, -1, -1):
            if arch == "mlp" or l == 0:
                G[l] = delta.T @ hs[l]
                if l > 0: delta = (delta @ P[l]) * (zs[l - 1] > 0)
            else:
                G[l] = (delta * hs[l]).sum(0)
                delta = delta * P[l] * (zs[l - 1] > 0)
        gn = np.sqrt(sum((g ** 2).sum() for g in G))
        eta = lr if gn * lr < 0.05 else 0.05 / gn
        P = [p - eta * g for p, g in zip(P, G)]
        t += eta; step += 1
        c1, c23 = (out * chi1).mean(), (out * chi23).mean()
        if T1 is None and c1 >= A / 2: T1 = t
        if T2 is None and c23 >= B / 2: T2 = t
        if rec_every and step % rec_every == 0:
            e = dict(t=t, loss=float(((out - y) ** 2).mean() / 2), c1=float(c1), c23=float(c23))
            for l in range(1, L):
                hc = hs[l] - hs[l].mean(0)
                ev = np.clip(np.linalg.eigvalsh(hc.T @ hc / n), 0, None)
                e[f"pr{l}"] = float(ev.sum() ** 2 / (ev ** 2).sum()) if ev.sum() > 0 else 0.0
            log.append(e)
        if T1 is not None and T2 is not None and t > T2 * 1.2 + 5:
            break
    return dict(arch=arch, L=L, alpha=alpha, seed=seed, T1=T1, T2=T2, log=log)

if __name__ == "__main__":
    L = int(sys.argv[1]); alphas = [float(a) for a in sys.argv[2].split(",")]
    res = []
    for arch in ["mlp", "paths"]:
        for alpha in alphas:
            for seed in range(3):
                o = run(arch, alpha, seed, L=L)
                res.append({k: o[k] for k in ("arch", "L", "alpha", "seed", "T1", "T2")})
                print(json.dumps(res[-1]), flush=True)
    json.dump(res, open(f"deep_L{L}.json", "w"), indent=1)
