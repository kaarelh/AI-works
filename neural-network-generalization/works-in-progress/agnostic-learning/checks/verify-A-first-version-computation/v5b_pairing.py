"""Lemma 7.1(d) re-check with the paired (low-variance) estimator
   E[g y | p] = int_{ups_1<1/2} [ g(x(ups)) - g(x(ups + e_1/2)) ] d ups,
which is exactly the identity used in the proof. Tests |E[g y | p]| <= Lambda r / 4 per vertex, with
Lambda = ||v|| ||W^1_{:,1:d}||_F prod ||W^l||_F  (and the cruder B^L m^H sqrt d).
"""
import itertools, math
import numpy as np
rng = np.random.default_rng(7)

def paired(g, d, r, nmc=400000):
    P = np.array(list(itertools.product([-1.0, 1.0], repeat=d)))
    out = []
    for p in P:
        ups = rng.uniform(size=(nmc, d)); ups[:, 0] *= 0.5
        ups2 = ups.copy(); ups2[:, 0] += 0.5
        diff = g(p * (1 - r * ups)) - g(p * (1 - r * ups2))
        out.append((0.5 * diff.mean(), 0.5 * diff.std() / math.sqrt(nmc)))
    return out

d = 3
for Lam, r in [(4.0, 0.05), (1.0, 0.3)]:
    res = paired(lambda x: Lam * np.abs(x[:, 0]), d, r)
    print(f"g=Lam|x1| Lam={Lam} r={r}: E[gy|p] over vertices = {[round(e,6) for e,_ in res]}  (Lam r/4 = {Lam*r/4})")

worst = -1e9
for trial in range(200):
    H = int(rng.integers(1, 4)); m = int(rng.integers(1, 6)); B = float(rng.uniform(0.3, 2.0)); r = float(rng.uniform(0.01, 0.5))
    W1 = rng.uniform(-B, B, size=(m, d + 1)); mids = [rng.uniform(-B, B, size=(m, m)) for _ in range(H - 1)]
    v = rng.uniform(-B, B, size=m)
    def net(x):
        h = np.tanh(np.hstack([np.ones((len(x), 1)), x]) @ W1.T)
        for Wl in mids:
            h = np.tanh(h @ Wl.T)
        return h @ v
    Lam = np.linalg.norm(v) * np.linalg.norm(W1[:, 1:]) * np.prod([np.linalg.norm(Wl) for Wl in mids])
    assert Lam <= B ** (H + 1) * m ** H * math.sqrt(d) + 1e-12
    res = paired(net, d, r, nmc=20000)
    for e, se in res:
        worst = max(worst, (abs(e) - 3 * se) / (Lam * r / 4))
print(f"200 random nets: max over vertices of (|E[gy|p]| - 3 s.e.)/(Lam r/4) = {worst:.4f}  (must be <= 1)")
