"""A first discrete learner (my feasibility check): thresholded low-degree Fourier expansion with composition.

1. Empirical Fourier coefficients c_S = mean(y chi_S) of the labels on every character of degree <= K (K = 4), computed
   by matrix products (degree k costs about 2 n d^2 C(d, k-2) FLOPs).
2. Keep S if |c_S| > c * sqrt(2 ln(N_k / delta) / n), with N_k = C(d, k): a union bound over the characters of that
   degree (delta = 0.1).
3. Composition: products S1 xor S2 of kept characters are new candidates, tested against a threshold with N = the
   number of such products. Repeat until nothing new is kept.
4. Predict sign( c_0 + sum_kept c_S chi_S ).
This is the 'truncated Fourier expansion' picture of the trajectory study, with the network's noisy continuous search
replaced by exhaustive enumeration and a union-bound acceptance rule.
"""
import itertools, math, numpy as np


class SparseFourier:
    def __init__(self, K=4, c=1.0, delta=0.1, compose=True):
        self.K, self.c, self.delta, self.compose = K, c, delta, compose
        self.name = f"sparse-fourier-K{K}-c{c}"

    def fit(self, X, y, rng):
        X = np.asarray(X, dtype=np.float64); y = np.asarray(y, dtype=np.float64); n, d = X.shape
        flops = 0.0
        kept = {(): float(y.mean())}
        thr = lambda N: self.c * math.sqrt(2 * math.log(max(N, 1) / self.delta) / n)
        # degree 1 and 2
        c1 = X.T @ y / n; flops += 2 * n * d
        for i in range(d):
            if abs(c1[i]) > thr(d):
                kept[(i,)] = c1[i]
        if self.K >= 2:
            Xy = X * y[:, None]; c2 = Xy.T @ X / n; flops += 2 * n * d * d + n * d
            t = thr(math.comb(d, 2))
            for i, j in itertools.combinations(range(d), 2):
                if abs(c2[i, j]) > t:
                    kept[(i, j)] = c2[i, j]
        if self.K >= 3:
            t = thr(math.comb(d, 3))
            for i in range(d):
                M = (X * (y * X[:, i])[:, None]).T @ X / n; flops += 2 * n * d * d + 2 * n * d
                for j, k in itertools.combinations(range(i + 1, d), 2):
                    if abs(M[j, k]) > t:
                        kept[(i, j, k)] = M[j, k]
        if self.K >= 4:
            t = thr(math.comb(d, 4))
            for i, j in itertools.combinations(range(d), 2):
                M = (X * (y * X[:, i] * X[:, j])[:, None]).T @ X / n; flops += 2 * n * d * d + 3 * n * d
                for k, l in itertools.combinations(range(j + 1, d), 2):
                    if abs(M[k, l]) > t:
                        kept[(i, j, k, l)] = M[k, l]
        # composition: products of kept characters
        if self.compose:
            for _ in range(4):
                base = [S for S in kept if S]
                cand = set()
                for A, B in itertools.combinations(base, 2):
                    S = tuple(sorted(set(A) ^ set(B)))
                    if S and S not in kept and len(S) > self.K:
                        cand.add(S)
                if not cand:
                    break
                t = thr(len(cand)); new = 0
                for S in cand:
                    v = float(np.mean(y * np.prod(X[:, list(S)], axis=1))); flops += 2 * n * len(S)
                    if abs(v) > t:
                        kept[S] = v; new += 1
                if not new:
                    break
        items = list(kept.items())

        def predict(Z):
            Z = np.asarray(Z, dtype=np.float64)
            f = np.zeros(len(Z))
            for S, v in items:
                f += v * (np.prod(Z[:, list(S)], axis=1) if S else 1.0)
            return np.where(f > 0, 1.0, -1.0)

        return dict(predict=predict, flops=flops, info=dict(size=len(items)))
