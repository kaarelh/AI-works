"""Checks for small-learner-width.md (Proposition 6.1 of red-team.md, corrected): the lemmas.

(1) Bernstein step (Lemma E(ii)): exact binomial upper tails for losses in {0, b} and for three-point losses,
    against the threshold sqrt(2 b mu l / n) + 2 b l / (3 n), l = ln(1/delta').
(2) Perturbation bound (Lemma C): random networks with kappa_N(w) = K, random and sign-gradient perturbations
    of sup-norm xi (called dp below), compared with xi [ (d+1) K^{H/2} + N sum_{j<H} K^{j/2} ] and with
    xi H (d+N+1) (K+1)^{H/2}.
(3) Cloning (Lemma A): random competitors, exact clone at width N >= m and kappa_N(clone) <= E_*.
(4) Exponent arithmetic of Remark 7 (two-point law of B-tempered-likelihood.md Proposition 9.1 and
    Lemma 9.2 at c = 1; eta is the quantity of Proposition 9.1).
Run: python3 check_lemmas.py > check_lemmas.out
"""
import numpy as np
from scipy import stats

rng = np.random.default_rng(20261111)


# ---------------------------------------------------------------- (1) Bernstein
def bernstein_check():
    worst = 0.0
    worst_case = None
    cases = 0
    for delta_p in [0.0125, 0.05, 0.25]:
        l = np.log(1 / delta_p)
        for n in [5, 10, 30, 100, 300, 1000, 3000, 10**4, 10**5, 10**6]:
            for b in [1.0, 4.0, 25.0, 100.0, 1e4, 1e6]:
                for mu in np.concatenate([np.geomspace(1e-6, 1.0, 40), np.linspace(1.0, 4.0, 13)]):
                    if mu >= b:
                        continue
                    p = mu / b
                    t = np.sqrt(2 * b * mu * l / n) + 2 * b * l / (3 * n)
                    # P(hat L - mu >= t) with hat L = b K / n, K ~ Bin(n, p)
                    kmin = int(np.ceil(n * (mu + t) / b - 1e-12))
                    tail = stats.binom.sf(kmin - 1, n, p)
                    cases += 1
                    if tail / delta_p > worst:
                        worst, worst_case = tail / delta_p, (delta_p, n, b, mu, tail)
    print("(1a) two-point losses {0,b}: %d cases; max exact tail / delta' = %.4f at (delta', n, b, mu, tail) = %s"
          % (cases, worst, worst_case))
    # three-point losses {0, a, b}: Monte Carlo free (exact via trinomial convolution for moderate n)
    worst3 = 0.0
    cases3 = 0
    for delta_p in [0.0125, 0.05]:
        l = np.log(1 / delta_p)
        for n in [10, 30, 100, 300]:
            for b in [4.0, 25.0, 100.0]:
                for a_frac in [0.1, 0.3, 0.6]:
                    a = a_frac * b
                    for pa in [0.01, 0.05, 0.2]:
                        for pb in [1e-4, 1e-3, 1e-2, 5e-2]:
                            if pa + pb >= 1:
                                continue
                            mu = pa * a + pb * b
                            var = pa * a**2 + pb * b**2 - mu**2
                            t = np.sqrt(2 * b * mu * l / n) + 2 * b * l / (3 * n)
                            # exact distribution of the sum: counts (ka, kb) multinomial
                            ka = np.arange(n + 1)
                            tail = 0.0
                            for kb in range(n + 1):
                                pk_b = stats.binom.pmf(kb, n, pb)
                                if pk_b < 1e-300:
                                    continue
                                # given kb, ka ~ Bin(n - kb, pa / (1 - pb))
                                q = pa / (1 - pb)
                                need = (n * (mu + t) - kb * b) / a  # ka >= need
                                kmin = int(np.ceil(need - 1e-12))
                                if kmin <= 0:
                                    tail += pk_b
                                elif kmin <= n - kb:
                                    tail += pk_b * stats.binom.sf(kmin - 1, n - kb, q)
                            cases3 += 1
                            assert var <= b * mu + 1e-12
                            worst3 = max(worst3, tail / delta_p)
    print("(1b) three-point losses {0,a,b}: %d cases; max exact tail / delta' = %.4f" % (cases3, worst3))


# ---------------------------------------------------------------- network utilities
def forward(W1, Ws, v, X):
    """X: (n, d). Returns outputs (n,)."""
    Xb = np.hstack([np.ones((X.shape[0], 1)), X])
    h = np.tanh(Xb @ W1.T)
    for W in Ws:
        h = np.tanh(h @ W.T)
    return h @ v


def energy(W1, Ws, v, d, N):
    return d / N * np.sum(W1**2) + sum(np.sum(W**2) for W in Ws) + N * np.sum(v**2)


def random_net(d, N, H, K):
    """Random parameter with kappa_N = K exactly, random split of energy across layers."""
    parts = rng.dirichlet(np.ones(H + 1)) * K
    W1 = rng.standard_normal((N, d + 1))
    W1 *= np.sqrt(parts[0] * N / d) / np.linalg.norm(W1)
    Ws = []
    for l in range(1, H):
        W = rng.standard_normal((N, N))
        if rng.random() < 0.5:  # rank one, aligned (large operator norm)
            u = rng.standard_normal(N); w = rng.standard_normal(N)
            W = np.outer(u, w)
        W *= np.sqrt(parts[l]) / np.linalg.norm(W)
        Ws.append(W)
    v = rng.standard_normal(N)
    v *= np.sqrt(parts[H] / N) / np.linalg.norm(v)
    return W1, Ws, v


def perturbation_check():
    worst_sharp, worst_closed, cases = 0.0, 0.0, 0
    for trial in range(1500):
        H = int(rng.integers(1, 5))
        d = int(rng.integers(1, 9))
        N = int(rng.integers(1, 25))
        K = float(rng.choice([0.3, 2.0, 10.0, 60.0, 400.0]))
        W1, Ws, v = random_net(d, N, H, K)
        assert abs(energy(W1, Ws, v, d, N) - K) < 1e-8 * max(1, K)
        X = rng.uniform(-1, 1, size=(300, d))
        X[:20] = np.sign(X[:20])  # cube corners
        z = forward(W1, Ws, v, X)
        dp = 10.0 ** rng.uniform(-6, -2)
        sharp = dp * ((d + 1) * K ** (H / 2) + N * sum(K ** (j / 2) for j in range(H)))
        closed = dp * H * (d + N + 1) * (K + 1) ** (H / 2)
        assert sharp <= closed * (1 + 1e-12)
        for mode in range(3):
            if mode == 0:
                s1 = rng.choice([-1, 1], W1.shape); ss = [rng.choice([-1, 1], W.shape) for W in Ws]
                sv = rng.choice([-1, 1], v.shape)
            else:
                # sign-gradient direction at the worst input (finite-difference free: analytic backprop)
                i = int(np.argmax(np.abs(z)))
                x = X[i:i + 1]
                xb = np.hstack([np.ones((1, 1)), x])
                hs = [xb]
                h = np.tanh(xb @ W1.T); hs.append(h)
                for W in Ws:
                    h = np.tanh(h @ W.T); hs.append(h)
                g_v = hs[-1][0]
                delta = v * (1 - hs[-1][0] ** 2)
                gWs = []
                for k in range(len(Ws) - 1, -1, -1):
                    gWs.insert(0, np.outer(delta, hs[k + 1][0]))
                    delta = (Ws[k].T @ delta) * (1 - hs[k + 1][0] ** 2)
                gW1 = np.outer(delta, xb[0])
                sgn = 1 if mode == 1 else -1
                s1 = sgn * np.sign(gW1); ss = [sgn * np.sign(G) for G in gWs]; sv = sgn * np.sign(g_v)
            z2 = forward(W1 + dp * s1, [W + dp * S for W, S in zip(Ws, ss)], v + dp * sv, X)
            diff = np.max(np.abs(z2 - z))
            worst_sharp = max(worst_sharp, diff / sharp)
            worst_closed = max(worst_closed, diff / closed)
            cases += 1
    print("(2) perturbation: %d perturbed networks; max |dz| / sharper form = %.4f; max |dz| / closed form = %.4f"
          " (must be <= 1)" % (cases, worst_sharp, worst_closed))


def clone_check():
    worst_err, worst_ratio, cases = 0.0, 0.0, 0
    for trial in range(400):
        H = int(rng.integers(1, 5)); d = int(rng.integers(1, 7)); m = int(rng.integers(1, 7))
        B = float(rng.choice([0.5, 1.0, 3.0]))
        U1 = rng.uniform(-B, B, (m, d + 1)); Us = [rng.uniform(-B, B, (m, m)) for _ in range(H - 1)]
        u = rng.uniform(-B, B, m)
        N = int(rng.integers(m, 5 * m + 3))
        # balanced groups
        k = np.array([N // m + (1 if j < N % m else 0) for j in range(m)])
        grp = np.repeat(np.arange(m), k)
        W1 = U1[grp]
        Ws = [U[np.ix_(grp, grp)] / k[grp][None, :] for U in Us]
        v = u[grp] / k[grp]
        X = rng.uniform(-1, 1, (200, d))
        g = forward(U1, Us, u, X); z = forward(W1, Ws, v, X)
        Estar = d * (d + 1) * B**2 + 2 * H * m**2 * B**2
        worst_err = max(worst_err, np.max(np.abs(g - z)))
        worst_ratio = max(worst_ratio, energy(W1, Ws, v, d, N) / Estar)
        assert np.max(np.abs(g)) <= m * B + 1e-12
        cases += 1
    print("(3) cloning: %d competitors; max |clone - g| = %.2e; max kappa_N(clone)/E_* = %.4f (must be <= 1)"
          % (cases, worst_err, worst_ratio))


def two_point_window():
    print("(4) two-point law at c = 1, class width floor(n^a), weights n^a:")
    for L in [2, 3, 4, 5, 6]:
        H = L - 1
        thr = L / (2 * (2 * L - 1))
        row = []
        for a in [thr - 0.02, thr + 0.02]:
            vals = []
            for logn in [20, 60, 200]:
                import mpmath as mp
                mp.mp.dps = 40
                n = mp.mpf(10) ** logn
                m = mp.floor(n ** a); B = n ** a
                delta0 = mp.tanh(1) ** (-H) / (m**H * B**L)
                eta = delta0 * ((n + 1) / L) ** (mp.mpf(L) / 2)
                vals.append(float(mp.log10(eta)))
            row.append("a=%.3f: log10 eta at n=1e20,1e60,1e200: %s" % (a, ", ".join("%.1f" % x for x in vals)))
        print("    L=%d  threshold L/(2(2L-1)) = %.4f ; %s" % (L, thr, " | ".join(row)))


if __name__ == "__main__":
    bernstein_check()
    perturbation_check()
    clone_check()
    two_point_window()
