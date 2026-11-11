"""Explicit construction of Lemma 2.1 (depth-two memorizer) of RT-depth2.fixed.md, from the note's recipe.

Steps built literally: Fourier coefficients of r = ybar 1_T; parity rows omega_{J,u} = alpha_d(-b_k, u on J);
empty set via tanh(e0.xbar)/tanh(1); signs absorbed; probability law pi with zero row; i.i.d. sampling of m0 rows
(resampled until sup|g - r| <= a/2); width-N network with balanced groups; readout t A0/(m0 k_l).
Checks: exact mixture identity; total mass <= A0; row norms <= F_d; sup|g-r| <= a/2; output = t g;
kappa_N <= d F_d + 2 t^2 A0^2 = d F_d + 18 d t^2 Q; R(tg) <= (1-t)^2 G + n t a;
c F - W = c kappa + R(tg) <= c d F_d + G[18 d c t^2 + (1-t)^2] + n t a, and at t = theta_c the Theorem 5.1 budget
c F(w_theta) - W <= c d F_d + (1 - theta) G + n theta a.
"""
import itertools
import math

import numpy as np

rng = np.random.default_rng(7)


def cube(d):
    return np.array(list(itertools.product([-1.0, 1.0], repeat=d)))


def build(d, n, a, Ns, ts, cs):
    X = cube(d); M = X.shape[0]
    idx = rng.integers(0, M, size=n)
    y = rng.choice([-1.0, 1.0], size=n)
    k = np.bincount(idx, minlength=M).astype(float)
    S = np.bincount(idx, weights=y, minlength=M)
    T = k > 0
    ybar = np.zeros(M); ybar[T] = S[T] / k[T]
    r = ybar.copy()
    Q = np.sum(r ** 2); G = np.sum(k[T] * ybar[T] ** 2); W = np.sum((y - ybar[idx]) ** 2)
    FD = 1 + (d + 1) * (d + 2) ** 2
    A0 = 3 * math.sqrt(d) * math.sqrt(Q)
    alpha = max(1.0, 0.5 * math.log(4 * math.sqrt(2 * d)))
    Xb = np.hstack([np.ones((M, 1)), X])
    rows, coefs = [], []
    for kk in range(0, d + 1):
        for J in itertools.combinations(range(d), kk):
            chi = np.prod(X[:, list(J)], axis=1) if kk else np.ones(M)
            rhat = np.mean(r * chi)
            if kk == 0:
                rows.append(np.eye(d + 1)[0]); coefs.append(rhat / math.tanh(1.0))
                continue
            b = 0 if kk % 2 == 1 else 1
            vs = np.array(list(itertools.product([-1.0, 1.0], repeat=kk)))
            cka = np.mean(np.prod(vs, axis=1) * np.tanh(alpha * (vs.sum(axis=1) - b)))
            assert abs(cka) >= 1 / (2 * math.sqrt(2 * kk)) - 1e-15
            for u in vs:
                om = np.zeros(d + 1); om[0] = -alpha * b
                for j, uj in zip(J, u):
                    om[1 + j] = alpha * uj
                rows.append(om); coefs.append(rhat / cka * np.prod(u) / 2 ** kk)
    rows = np.array(rows); coefs = np.array(coefs)
    mix = np.tanh(Xb @ rows.T) @ coefs
    assert np.allclose(mix, r, atol=1e-12), "mixture identity fails"
    mass = np.abs(coefs).sum()
    assert mass <= A0 + 1e-12
    assert (np.sum(rows ** 2, axis=1) <= FD).all()
    # absorb signs, build pi
    srows = rows * np.sign(coefs)[:, None]
    probs = np.abs(coefs) / A0
    srows = np.vstack([srows, np.zeros(d + 1)]); probs = np.append(probs, 1 - probs.sum())
    assert np.allclose(A0 * (np.tanh(Xb @ srows.T) @ probs), r, atol=1e-12)
    m0 = math.ceil(8 * A0 ** 2 * math.log(2 * M) / a ** 2) + 1
    tries = 0
    while True:
        tries += 1
        pick = rng.choice(len(probs), size=m0, p=probs)
        feats = np.tanh(Xb @ srows[pick].T)          # M x m0
        g = A0 / m0 * feats.sum(axis=1)
        if np.abs(g - r).max() <= a / 2:
            break
    out = []
    for N in Ns:
        if N < m0:
            continue
        base, extra = divmod(N, m0)
        kl = np.array([base + (1 if l < extra else 0) for l in range(m0)], dtype=float)
        assert kl.min() >= N / (2 * m0)
        W1 = np.repeat(srows[pick], kl.astype(int), axis=0)
        for t in ts:
            v = np.repeat(t * A0 / (m0 * kl), kl.astype(int))
            z = np.tanh(Xb @ W1.T) @ v
            kap = d / N * np.sum(W1 ** 2) + N * np.sum(v ** 2)
            R = np.sum(k[T] * (z[T] - ybar[T]) ** 2)
            ok = [np.allclose(z, t * g, atol=1e-10), kap <= d * FD + 2 * t ** 2 * A0 ** 2 + 1e-9,
                  np.isclose(2 * t ** 2 * A0 ** 2, 18 * d * t ** 2 * Q),
                  R <= (1 - t) ** 2 * G + n * t * a + 1e-9]
            for c in cs:
                lhs = c * kap + R
                ok.append(lhs <= c * d * FD + G * (18 * d * c * t ** 2 + (1 - t) ** 2) + n * t * a + 1e-9)
            out.append((N, t, kap, d * FD + 2 * t ** 2 * A0 ** 2, R, all(ok)))
        # Theorem 5.1 budget at t = theta_c
        for c in cs:
            th = 1 / (18 * d * c + 1)
            v = np.repeat(th * A0 / (m0 * kl), kl.astype(int))
            z = np.tanh(Xb @ W1.T) @ v
            kap = d / N * np.sum(W1 ** 2) + N * np.sum(v ** 2)
            R = np.sum(k[T] * (z[T] - ybar[T]) ** 2)
            F = kap + (R + W) / c
            ok2 = c * F - W <= c * d * FD + (1 - th) * G + n * th * a + 1e-9
            out.append((N, 'theta_c=%.4g (c=%g)' % (th, c), kap, None, R, ok2))
    return dict(d=d, M=M, n=n, Q=Q, G=G, A0=A0, m0=m0, mass=mass, tries=tries, out=out)


allok = True
for d, a in ((3, 1.0), (3, 0.5), (4, 1.0)):
    M = 2 ** d
    res = build(d, M, a, Ns=None or [0], ts=[1.0], cs=[1.0]) if False else None
    m_est = None
    res = build(d, M, a, Ns=[10 ** 9], ts=[], cs=[]) if False else None
    # first pass to get m0, then rebuild with concrete widths
    r0 = build(d, M, a, Ns=[], ts=[], cs=[])
    m0 = r0['m0']
    r1 = build(d, M, a, Ns=[m0 + 5000, int(2.5 * (m0 + 5000)) + 3], ts=[1.0, 0.37, 0.05], cs=[1.0, 0.1, 0.01])
    print("d=%d a=%.2f n=%d Q=%.3f G=%.3f A0=%.2f m0=%d mass/A0=%.3f tries=%d" % (
        d, a, r1['n'], r1['Q'], r1['G'], r1['A0'], r1['m0'], r1['mass'] / r1['A0'], r1['tries']))
    for (N, t, kap, bnd, R, ok) in r1['out']:
        allok &= bool(ok)
        print("   N=%d t=%s kappa=%.2f bound=%s R=%.4f ok=%s" % (N, t, kap, ("%.2f" % bnd) if bnd else '-', R, ok))
print("ALL OK:", allok)
