"""Small-init GD on a depth-3 ReLU net: shared MLP vs ensemble of independent path-circuits.

Target on {-1,1}^d: f(x) = A*x1 + B*x2*x3.  Population (full-cube) GD on square loss.
MLP:   out = w3 . relu(W2 relu(W1 x~))           (x~ = [x, 1])
Paths: out = sum_k a_k relu(b_k relu(w_k . x~))  (no cross-talk between circuits)
Both are 3-homogeneous in their parameters.  We record T1, T2: first times the
Fourier coefficients of the output on {1} and {2,3} reach half their target value.
"""
import numpy as np, itertools, sys, json

def cube(d):
    X = np.array(list(itertools.product([-1.0, 1.0], repeat=d)))
    return np.hstack([X, np.ones((len(X), 1))])

def run(arch, alpha, seed, d=8, N=32, A=1.0, B=0.8, lr=0.05, tmax=4000.0, rec=False):
    rng = np.random.default_rng(seed)
    Xt = cube(d); X = Xt[:, :d]; n = len(Xt)
    y = A * X[:, 0] + B * X[:, 1] * X[:, 2]
    chi1 = X[:, 0]; chi23 = X[:, 1] * X[:, 2]
    D = d + 1
    if arch == "mlp":
        W1 = alpha * rng.standard_normal((N, D)) / np.sqrt(D)
        W2 = alpha * rng.standard_normal((N, N)) / np.sqrt(N)
        w3 = alpha * rng.standard_normal(N) / np.sqrt(N)
        P = [W1, W2, w3]
    else:
        w = alpha * rng.standard_normal((N, D)) / np.sqrt(D)
        b = alpha * rng.standard_normal(N)
        a = alpha * rng.standard_normal(N) / np.sqrt(N)
        P = [w, b, a]
    T1 = T2 = None; t = 0.0; log = []
    step = 0
    while t < tmax:
        if arch == "mlp":
            W1, W2, w3 = P
            z1 = Xt @ W1.T; h1 = np.maximum(z1, 0)
            z2 = h1 @ W2.T; h2 = np.maximum(z2, 0)
            out = h2 @ w3
            r = (out - y) / n
            g3 = h2.T @ r
            d2 = np.outer(r, w3) * (z2 > 0)
            g2 = d2.T @ h1
            d1 = (d2 @ W2) * (z1 > 0)
            g1 = d1.T @ Xt
            G = [g1, g2, g3]
        else:
            w, b, a = P
            z1 = Xt @ w.T; h1 = np.maximum(z1, 0)
            z2 = h1 * b; h2 = np.maximum(z2, 0)
            out = h2 @ a
            r = (out - y) / n
            ga = h2.T @ r
            d2 = np.outer(r, a) * (z2 > 0)
            gb = (d2 * h1).sum(0)
            d1 = d2 * b * (z1 > 0)
            gw = d1.T @ Xt
            G = [gw, gb, ga]
        # gradient-norm-capped step keeps the discretisation stable once weights are O(1)
        gn = np.sqrt(sum((g**2).sum() for g in G))
        eta = lr if gn * lr < 0.05 else 0.05 / gn
        P = [p - eta * g for p, g in zip(P, G)]
        t += eta; step += 1
        c1 = (out * chi1).mean(); c23 = (out * chi23).mean()
        if T1 is None and c1 >= A / 2: T1 = t
        if T2 is None and c23 >= B / 2: T2 = t
        if rec and step % 20 == 0:
            entry = dict(t=t, loss=float(((out - y) ** 2).mean() / 2), c1=float(c1), c23=float(c23))
            # effective rank (participation ratio) of the centred hidden representations
            for name, h in (("h1", h1), ("h2", h2)):
                hc = h - h.mean(0)
                ev = np.linalg.eigvalsh(hc.T @ hc / n)
                ev = np.clip(ev, 0, None)
                entry["pr_" + name] = float(ev.sum() ** 2 / (ev ** 2).sum()) if ev.sum() > 1e-30 else 0.0
            log.append(entry)
        if T1 is not None and T2 is not None and t > max(T1, T2) * 1.3 + 5:
            break
    return dict(arch=arch, alpha=alpha, seed=seed, T1=T1, T2=T2, log=log)

if __name__ == "__main__":
    alphas = [0.3, 0.1, 0.03, 0.01]
    res = []
    for arch in ["mlp", "paths"]:
        for alpha in alphas:
            for seed in range(3):
                out = run(arch, alpha, seed)
                res.append({k: out[k] for k in ("arch", "alpha", "seed", "T1", "T2")})
                print(json.dumps(res[-1]), flush=True)
    json.dump(res, open("attach_results.json", "w"), indent=1)
