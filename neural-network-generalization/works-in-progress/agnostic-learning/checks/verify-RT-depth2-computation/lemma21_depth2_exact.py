"""Exact small-cube check of redteam.md Lemma 2.1(2) (depth-two memorizer) and of the
energy/residual bookkeeping in the proof of Theorem 5.1.

For d in a small range, n = M = 2^d (lambda = 1), a random i.i.d. sample:
 1. r = ybar * 1_T; Fourier l1 bound  sum_S |rhat(S)| <= ||r||_2.
 2. Exact parity representation (README eqs (3)-(4)) with slope a_d = max{1, log(4 sqrt(2d))/2}:
    r(x) = sum_rows w_rho tanh(rho . xbar) EXACTLY, total weight <= A0 = 3 sqrt(d) ||r||_2,
    every row has ||rho||^2 <= F_d = 1 + (d+1)(d+2)^2.
 3. Sampling m0 = ceil(8 A0^2 ln(2M)/a^2) + 1 rows from pi; sup |g - r| <= a/2.
 4. Build the width-N depth-2 network explicitly (groups of sizes floor/ceil(N/m0)), readout t A0/(m0 k_j).
    Check output == t g, kappa_N <= d F_d + 2 t^2 A0^2, R(t g) <= (1-t)^2 G + n (t a + a^2/4).
 5. Theorem 5.1 chain: c F(w_t) - W = c kappa + R(tg) <= c d F_d + n(ta+a^2/4) + G[18 d c t^2 + (1-t)^2].
"""
import itertools, math, sys
import numpy as np

rng = np.random.default_rng(12345)

def FD(d):
    return 1 + (d + 1) * (d + 2) ** 2

def run(d, a, c=1.0, Ns=None, seed=0):
    rng = np.random.default_rng(seed)
    M = 2 ** d; n = M
    X = np.array(list(itertools.product([-1.0, 1.0], repeat=d)))
    Xb = np.hstack([np.ones((M, 1)), X])
    idx = rng.integers(0, M, size=n); ys = rng.choice([-1.0, 1.0], size=n)
    k = np.bincount(idx, minlength=M).astype(float)
    S = np.bincount(idx, weights=ys, minlength=M)
    seen = k > 0
    ybar = np.zeros(M); ybar[seen] = S[seen] / k[seen]
    Q = float(np.sum(ybar ** 2)); G = float(np.sum(k[seen] * ybar[seen] ** 2)); V = float(np.sum(S ** 2))
    W = float(np.sum((ys - ybar[idx]) ** 2))
    r = ybar.copy()
    # (1.1) decomposition check for a random f
    f = rng.normal(size=M)
    lhs = float(np.sum((f[idx] - ys) ** 2)); rhs = float(np.sum(k * (f - ybar) ** 2)) + W
    assert abs(lhs - rhs) < 1e-8 * max(1, lhs)
    # Fourier
    subsets = [s for kk in range(d + 1) for s in itertools.combinations(range(d), kk)]
    chi = {s: (np.prod(X[:, list(s)], axis=1) if len(s) else np.ones(M)) for s in subsets}
    rhat = {s: float(np.mean(r * chi[s])) for s in subsets}
    l1 = sum(abs(v) for v in rhat.values()); r2 = math.sqrt(Q)
    assert l1 <= r2 + 1e-12, (l1, r2)
    # parity representation
    ad = max(1.0, 0.5 * math.log(4 * math.sqrt(2 * d)))
    def bk(kk): return 0.0 if kk % 2 == 1 else 1.0
    def ccoef(kk):
        tot = 0.0
        for v in itertools.product([-1.0, 1.0], repeat=kk):
            tot += np.prod(v) * math.tanh(ad * (sum(v) - bk(kk)))
        return tot / 2 ** kk
    cks = {kk: ccoef(kk) for kk in range(1, d + 1)}
    for kk in range(1, d + 1):
        assert abs(cks[kk]) * 2 * math.sqrt(2 * kk) >= 1 - 1e-12
    rows, wts = [], []
    for s in subsets:
        if abs(rhat[s]) < 1e-15: continue
        if len(s) == 0:
            rows.append(np.sign(rhat[s]) * np.eye(d + 1)[0]); wts.append(abs(rhat[s]) / math.tanh(1.0)); continue
        kk = len(s); cc = cks[kk]
        for u in itertools.product([-1.0, 1.0], repeat=kk):
            sig = np.sign(rhat[s] / cc * np.prod(u))
            row = np.zeros(d + 1); row[0] = -ad * bk(kk); row[[1 + j for j in s]] = ad * np.array(u)
            rows.append(sig * row); wts.append(abs(rhat[s] / cc) / 2 ** kk)
    rows = np.array(rows); wts = np.array(wts)
    recon = (np.tanh(Xb @ rows.T) * wts).sum(axis=1)
    err_exact = float(np.max(np.abs(recon - r)))
    A0 = 3 * math.sqrt(d) * r2
    Wtot = float(wts.sum())
    maxrow2 = float(np.max(np.sum(rows ** 2, axis=1)))
    assert Wtot <= A0 + 1e-12 and maxrow2 <= FD(d)
    # pi: rows with probs wts/A0, plus zero row with the rest
    probs = np.append(wts / A0, 1 - Wtot / A0)
    allrows = np.vstack([rows, np.zeros(d + 1)])
    m0 = math.ceil(8 * A0 ** 2 * math.log(2 * M) / a ** 2) + 1
    tries = 0
    while True:
        tries += 1
        pick = rng.choice(len(probs), size=m0, p=probs)
        om = allrows[pick]
        g = (A0 / m0) * np.tanh(Xb @ om.T).sum(axis=1)
        if np.max(np.abs(g - r)) <= a / 2: break
        assert tries < 20
    out = dict(d=d, a=a, Q=Q, G=G, V=V, W=W, A0sq=A0 ** 2, Wtot_over_A0=Wtot / A0, maxrow2=maxrow2, FD=FD(d),
               err_exact=err_exact, m0=m0, sup_g_r=float(np.max(np.abs(g - r))), tries=tries,
               l1=l1, r2=r2, bound_m0=72 * d * n ** 3 * math.log(2 * M) + 2 if a == 1 / n else None)
    th = 1 / (18 * d * c + 1)
    if Ns is None: Ns = [m0, int(2.5 * m0) + 1]
    res = []
    for N in Ns:
        assert N >= m0
        base, extra = divmod(N, m0)
        kj = np.array([base + 1 if j < extra else base for j in range(m0)])
        assert kj.sum() == N and kj.min() >= N / (2 * m0)
        W1 = np.repeat(om, kj, axis=0)  # N x (d+1)
        for t in [0.0, th, 0.5, 1.0]:
            v = np.repeat(t * A0 / (m0 * kj), kj)
            z = np.tanh(Xb @ W1.T) @ v
            kap = (d / N) * np.sum(W1 ** 2) + N * np.sum(v ** 2)
            kap_bound = d * FD(d) + 2 * t ** 2 * A0 ** 2
            R = float(np.sum(k * (z - ybar) ** 2))
            R_bound = (1 - t) ** 2 * G + n * (t * a + a * a / 4)
            chain = c * kap + R
            chain_bound = c * d * FD(d) + n * (t * a + a * a / 4) + G * (18 * d * c * t ** 2 + (1 - t) ** 2)
            ok = (np.max(np.abs(z - t * g)) < 1e-9, kap <= kap_bound + 1e-9, R <= R_bound + 1e-9,
                  chain <= chain_bound + 1e-9)
            res.append((N, round(t, 5), float(np.max(np.abs(z - t * g))), kap, kap_bound, R, R_bound, chain, chain_bound, ok))
    return out, res

if __name__ == '__main__':
    cases = [(3, 1 / 8), (4, 1 / 16), (3, 0.25), (4, 0.25), (5, 0.25), (6, 0.25), (5, 0.5), (6, 0.5)]
    for (d, a) in cases:
        for seed in [0, 1]:
            out, res = run(d, a, seed=seed)
            print("d=%d a=%.4g seed=%d: Q=%.2f G=%.2f V=%.0f | exact-rep max err=%.2e | sum|rhat|=%.4f <= ||r||=%.4f | "
                  "Wtot/A0=%.4f | max row^2=%.2f <= F_d=%d | m0=%d (72dn^3ln2M+2=%s) | sup|g-r|=%.4f <= a/2=%.4f (tries %d)" % (
                      d, a, seed, out['Q'], out['G'], out['V'], out['err_exact'], out['l1'], out['r2'], out['Wtot_over_A0'],
                      out['maxrow2'], out['FD'], out['m0'],
                      ('%.3g' % out['bound_m0']) if out['bound_m0'] else '-', out['sup_g_r'], a / 2, out['tries']))
            for row in res:
                N, t, ezt, kap, kb, R, Rb, ch, chb, ok = row
                print("    N=%7d t=%.4f |z-tg|=%.1e kappa=%.3f<=%.3f  R=%.3f<=%.3f  cF-W=%.3f<=%.3f  ok=%s" % (
                    N, t, ezt, kap, kb, R, Rb, ch, chb, all(ok)))
                assert all(ok), row
    print("ALL LEMMA 2.1(2) / THM 5.1 BOOKKEEPING CHECKS PASSED")
