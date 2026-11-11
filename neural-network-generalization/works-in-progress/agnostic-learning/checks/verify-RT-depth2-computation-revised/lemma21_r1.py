"""Independent explicit build of Lemma 2.1 (depth two) and of the Theorem 5.1 objective chain, computed from the raw sample.
Cases: (A) d=6, r = ybar 1_T from a cube sample with n = M; (B) d=4, arbitrary r in [-1,1]^M (not a sample mean).
Width N = 2 m0 + 3 (not a multiple of m0); t in {0.2, theta_c (c=1, 0.01, d^-3), 1}."""
import numpy as np
from math import comb, log, ceil, tanh, sqrt
rng = np.random.default_rng(99)

def FD(d): return 1 + (d + 1) * (d + 2)**2
def cube(d): return np.array([[(-1.0) ** ((i >> j) & 1) for j in range(d)] for i in range(2**d)])
def ck_tanh(k, al):
    b = 0 if k % 2 else 1
    return sum(comb(k, i) * (-1)**i * np.tanh(al * (k - 2 * i - b)) for i in range(k + 1)) / 2**k

def build(d, r, a):
    M = 2**d; X = cube(d); Xb = np.hstack([np.ones((M, 1)), X])
    nr = np.sqrt(np.sum(r**2)); A0 = 3 * sqrt(d) * nr
    al = max(1.0, 0.5 * log(4 * sqrt(2 * d)))
    rows, w = [], []; l1 = 0.0
    for mask in range(M):
        J = [j for j in range(d) if (mask >> j) & 1]
        chi = np.prod(X[:, J], axis=1) if J else np.ones(M)
        rh = np.mean(r * chi); l1 += abs(rh)
        if abs(rh) < 1e-15: continue
        if not J:
            rows.append(np.eye(d + 1)[0]); w.append(rh / tanh(1.0)); continue
        k = len(J); b = 0 if k % 2 else 1; c = ck_tanh(k, al)
        assert abs(c) * 2 * sqrt(2 * k) >= 1
        for um in range(2**k):
            u = np.array([(-1.0) ** ((um >> j) & 1) for j in range(k)])
            om = np.zeros(d + 1); om[0] = -al * b; om[1 + np.array(J)] = al * u
            rows.append(om); w.append(rh * np.prod(u) / (2**k * c))
    rows = np.array(rows); w = np.array(w)
    assert l1 <= nr + 1e-12, (l1, nr)
    rec = np.tanh(Xb @ rows.T) @ w
    assert np.max(np.abs(rec - r)) < 1e-10
    mass = np.sum(np.abs(w)); assert mass <= A0 + 1e-12
    assert np.max(np.sum(rows**2, axis=1)) < FD(d)
    srows = np.vstack([rows * np.sign(w)[:, None], np.zeros(d + 1)])
    pr = np.append(np.abs(w) / A0, 1 - mass / A0)
    m0 = ceil(8 * A0**2 * log(2 * M) / a**2) + 1
    tries = 0
    while True:
        tries += 1
        pick = rng.choice(len(srows), size=m0, p=pr); om = srows[pick]
        g = A0 / m0 * np.tanh(Xb @ om.T).sum(axis=1)
        if np.max(np.abs(g - r)) <= a / 2: break
    return dict(M=M, X=X, Xb=Xb, A0=A0, om=om, g=g, m0=m0, mass=mass, l1=l1, nr=nr, tries=tries)

def width_net(B, N, t):
    m0 = B['m0']; base, extra = divmod(N, m0)
    kj = np.full(m0, base); kj[:extra] += 1
    assert kj.sum() == N and kj.min() >= N / (2 * m0)
    W1 = np.repeat(B['om'], kj, axis=0); v = np.repeat(t * B['A0'] / (m0 * kj), kj)
    return W1, v

if __name__ == '__main__':
    # (A) sample case
    d = 6; M = 2**d; n = M
    idx = rng.integers(0, M, n); y = rng.choice([-1.0, 1.0], n)
    k = np.bincount(idx, minlength=M).astype(float); S = np.bincount(idx, weights=y, minlength=M)
    T = k > 0; yb = np.where(T, S / np.maximum(k, 1), 0.0)
    Q = np.sum(yb**2); G = np.sum(k * yb**2); W = np.sum((y - yb[idx])**2)
    for a in [1.0, 0.7]:
        B = build(d, yb, a)
        N = 2 * B['m0'] + 3
        for c in [1.0, 0.01, d**-3.0]:
            th = 1 / (18 * d * c + 1)
            for t in sorted({0.2, th, 1.0}):
                W1, v = width_net(B, N, t)
                Z = np.tanh(B['Xb'] @ W1.T) @ v
                assert np.max(np.abs(Z - t * B['g'])) < 1e-9
                kap = d / N * np.sum(W1**2) + N * np.sum(v**2)
                assert kap <= d * FD(d) + 2 * t**2 * B['A0']**2 + 1e-8
                assert kap <= d * FD(d) + 18 * d * t**2 * Q + 1e-8
                F = kap + np.sum((Z[idx] - y)**2) / c          # raw-sample objective
                R = np.sum(k[T] * (Z[T] - yb[T])**2)
                assert abs(c * F - W - (c * kap + R)) < 1e-7 * max(1, c * F)     # (1.1)
                assert R <= (1 - t)**2 * G + n * t * a + 1e-9
                if t == th:
                    rhs = c * d * FD(d) + (1 - th) * G + n * th * a
                    assert c * F - W <= rhs + 1e-9
            print("(A) d=%d a=%.1f c=%.4g: m0=%d N=%d tries=%d mass/A0=%.3f l1/||r||=%.3f sup|g-r|/(a/2)=%.3f  kappa(t=1)=%.1f vs bound %.1f; all chain checks pass" % (
                d, a, c, B['m0'], N, B['tries'], B['mass'] / B['A0'], B['l1'] / B['nr'], np.max(np.abs(B['g'] - yb)) / (a / 2),
                d / N * np.sum(width_net(B, N, 1.0)[0]**2) + N * np.sum(width_net(B, N, 1.0)[1]**2), d * FD(d) + 2 * B['A0']**2))

    # (B) arbitrary r
    d = 4; M = 2**d
    for trial in range(3):
        r = rng.uniform(-1, 1, M)
        if trial == 2: r = np.sign(r)  # extreme +-1 pattern
        B = build(d, r, 0.8)
        N = 2 * B['m0'] + 3
        for t in [0.0, 0.3, 1.0]:
            W1, v = width_net(B, N, t)
            Z = np.tanh(B['Xb'] @ W1.T) @ v
            kap = d / N * np.sum(W1**2) + N * np.sum(v**2)
            assert np.max(np.abs(Z - t * B['g'])) < 1e-9 and kap <= d * FD(d) + 2 * t**2 * B['A0']**2 + 1e-8
        print("(B) d=4 trial %d: m0=%d tries=%d mass/A0=%.3f sup|g-r|/(a/2)=%.3f: pass" % (trial, B['m0'], B['tries'], B['mass'] / B['A0'], np.max(np.abs(B['g'] - r)) / 0.4))
