"""Lemma 2.1 (depth-two part), built explicitly as a width-N network.

r = ybar 1_T on {-1,1}^d (from a random cube sample, n = M), A0 = 3 sqrt(d) ||r||_2,
m0 = ceil(8 A0^2 ln(2M)/a^2) + 1.  Checks:
  exact mixture r = A0 E_pi tanh(omega . xbar) with ||omega||^2 <= F_d and total mass <= A0;
  sampled g with sup |g - r| <= a/2;
  width-N network (N in {m0, 2.5 m0 + 3}) computing t g exactly with kappa_N <= d F_d + 2 t^2 A0^2;
  R(tg) <= (1-t)^2 G + n t a;  near-minimizer budget c kappa(w_t) + R(tg) <= c d F_d + (1-th) G + n th a at t = th.
"""
import numpy as np
from math import log, ceil, tanh

rng = np.random.default_rng(11)


def FD(d):
    return 1 + (d + 1) * (d + 2) ** 2


def cube(d):
    return np.array([[1 if (i >> j) & 1 == 0 else -1 for j in range(d)] for i in range(2 ** d)], dtype=float)


def c_tanh(k, al):
    from math import comb
    b = 0 if k % 2 else 1
    return sum(comb(k, j) * (-1) ** j * tanh(al * (k - 2 * j - b)) for j in range(k + 1)) / 2 ** k


for d in [3, 4, 5]:
    M = 2 ** d; X = cube(d); Xb = np.hstack([np.ones((M, 1)), X])
    n = M
    idx = rng.integers(0, M, size=n); y = rng.choice([-1.0, 1.0], size=n)
    k = np.bincount(idx, minlength=M).astype(float); S = np.bincount(idx, weights=y, minlength=M)
    T = k > 0
    ybar = np.zeros(M); ybar[T] = S[T] / k[T]
    r = ybar.copy()
    Q = np.sum(r ** 2); G = np.sum(k[T] * ybar[T] ** 2)
    A0 = 3 * np.sqrt(d) * np.sqrt(Q)
    al = max(1.0, 0.5 * log(4 * np.sqrt(2 * d)))
    # Fourier coefficients and exact mixture
    rows, coefs = [], []
    for Smask in range(M):
        Sset = [j for j in range(d) if (Smask >> j) & 1]
        chi = np.prod(X[:, Sset], axis=1) if Sset else np.ones(M)
        rhat = np.mean(r * chi)
        if abs(rhat) < 1e-15:
            continue
        if not Sset:
            rows.append(np.eye(d + 1)[0]); coefs.append(rhat / tanh(1.0)); continue
        kk = len(Sset); b = 0 if kk % 2 else 1
        ck = c_tanh(kk, al)
        for umask in range(2 ** kk):
            u = np.array([1 if (umask >> j) & 1 == 0 else -1 for j in range(kk)], dtype=float)
            om = np.zeros(d + 1); om[0] = -al * b; om[1 + np.array(Sset)] = al * u
            rows.append(om); coefs.append(rhat / ck * np.prod(u) / 2 ** kk)
    rows = np.array(rows); coefs = np.array(coefs)
    recon = np.tanh(Xb @ rows.T) @ coefs
    assert np.max(np.abs(recon - r)) < 1e-10
    mass = np.sum(np.abs(coefs))
    assert mass <= A0 + 1e-12 and np.max(np.sum(rows ** 2, axis=1)) <= FD(d)
    # law pi: sign-adjusted rows with prob |coef|/A0, zero row with the rest
    srows = rows * np.sign(coefs)[:, None]
    probs = np.append(np.abs(coefs) / A0, 1 - mass / A0)
    allrows = np.vstack([srows, np.zeros(d + 1)])
    for a in [1.0, 0.5]:
        m0 = ceil(8 * A0 ** 2 * log(2 * M) / a ** 2) + 1
        for attempt in range(5):
            pick = rng.choice(len(allrows), size=m0, p=probs)
            om = allrows[pick]
            g = A0 / m0 * np.sum(np.tanh(Xb @ om.T), axis=1)
            if np.max(np.abs(g - r)) <= a / 2:
                break
        assert np.max(np.abs(g - r)) <= a / 2
        th = 1 / (18 * d * 1.0 + 1)
        for N in [m0, int(2.5 * m0) + 3]:
            base, extra = divmod(N, m0)
            kj = np.full(m0, base); kj[:extra] += 1
            assert kj.sum() == N and kj.min() >= N / (2 * m0)
            W1 = np.repeat(om, kj, axis=0)
            H1 = np.tanh(Xb @ W1.T)
            for t in [1.0, 0.37, th]:
                v = np.repeat(t * A0 / (m0 * kj), kj)
                z = H1 @ v
                kap = d / N * np.sum(W1 ** 2) + N * np.sum(v ** 2)
                assert np.max(np.abs(z - t * g)) < 1e-9
                assert kap <= d * FD(d) + 2 * t ** 2 * A0 ** 2 + 1e-9
                R = np.sum(k[T] * (z[T] - ybar[T]) ** 2)
                assert R <= (1 - t) ** 2 * G + n * t * a + 1e-9
                if t == th:
                    c = 1.0
                    lhs = c * kap + R
                    rhs = c * d * FD(d) + (1 - th) * G + n * th * a
                    assert lhs <= rhs + 1e-9
        print("d=%d M=%d Q=%.2f G=%.2f A0=%.2f mass/A0=%.3f a=%.1f m0=%d sup|g-r|/(a/2)=%.3f : all checks passed (N=m0 and N=2.5m0+3; t=1,0.37,theta)" % (
            d, M, Q, G, A0, mass / A0, a, m0, np.max(np.abs(g - r)) / (a / 2)))
