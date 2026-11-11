"""Check the perturbation bound in the proof of Proposition 6.1 (redteam.md, Sec. 6.3).

Claim: for w with kappa_N(w) <= K and any w' with ||w - w'||_inf <= delta',
  e_1 <= delta' (d+1) sqrt(N),
  e_l <= sqrt(K) e_{l-1} + delta' N^{3/2}        (l = 2..H),
  |z_w(x) - z_w'(x)| <= sqrt(K/N) e_H + delta' N  <= delta' H (d+N+1) (K+1)^{H/2}.

We test (i) each one-step inequality with the ACTUAL e_{l-1}, (ii) the chained bound,
(iii) the final closed form, on random and adversarial instances, including a
projected-sign-gradient ascent over the l_inf box (the worst perturbation we can find).
"""
import numpy as np

rng = np.random.default_rng(12345)


def forward(params, x):
    W1, Ws, v = params
    xb = np.concatenate([[1.0], x])
    hs = [xb]
    h = np.tanh(W1 @ xb)
    hs.append(h)
    for W in Ws:
        h = np.tanh(W @ h)
        hs.append(h)
    return v @ h, hs


def grad(params, x):
    """Gradient of z wrt all parameters (backprop)."""
    W1, Ws, v = params
    z, hs = forward(params, x)
    gv = hs[-1].copy()
    gh = v.copy()
    gWs = [None] * len(Ws)
    for k in range(len(Ws) - 1, -1, -1):
        ga = gh * (1 - hs[k + 2] ** 2)
        gWs[k] = np.outer(ga, hs[k + 1])
        gh = Ws[k].T @ ga
    ga = gh * (1 - hs[1] ** 2)
    gW1 = np.outer(ga, hs[0])
    return (gW1, gWs, gv)


def energy(params, d, N):
    W1, Ws, v = params
    return d / N * np.sum(W1 ** 2) + sum(np.sum(W ** 2) for W in Ws) + N * np.sum(v ** 2)


def random_params(d, N, H, K, mode):
    """Random w with kappa_N(w) = K exactly; energy split depends on mode."""
    if mode == "dirichlet":
        f = rng.dirichlet(np.ones(H + 1))
    elif mode == "equal":
        f = np.ones(H + 1) / (H + 1)
    elif mode == "internal-heavy":
        f = np.ones(H + 1) * 0.02
        f[1:H] = (1 - 0.02 * 2) / max(H - 1, 1)
        if H == 1:
            f = np.array([0.5, 0.5])
        f = f / f.sum()
    else:
        raise ValueError
    W1 = rng.standard_normal((N, d + 1))
    W1 *= np.sqrt(f[0] * K * N / d) / np.linalg.norm(W1)
    Ws = []
    for l in range(H - 1):
        W = rng.standard_normal((N, N))
        if mode == "internal-heavy":  # rank one => op norm = Frobenius norm
            u = rng.standard_normal(N)
            W = np.outer(u, u)
        W *= np.sqrt(f[1 + l] * K) / np.linalg.norm(W)
        Ws.append(W)
    v = rng.standard_normal(N)
    v *= np.sqrt(f[H] * K / N) / np.linalg.norm(v)
    return (W1, Ws, v)


def rank_one_linear(d, N, H, K, x):
    """Adversarial: preactivations ~0 at x (tanh' ~ 1), rank-one internal layers aligned with 1."""
    xb = np.concatenate([[1.0], x])
    # first-layer rows orthogonal to xb so that h^1(x) = 0
    R = rng.standard_normal((N, d + 1))
    R -= np.outer(R @ xb, xb) / (xb @ xb)
    f = np.ones(H + 1) / (H + 1)
    W1 = R * np.sqrt(f[0] * K * N / d) / np.linalg.norm(R)
    u = np.ones(N) / np.sqrt(N)
    Ws = [np.sqrt(f[1 + l] * K) * np.outer(u, u) for l in range(H - 1)]
    v = np.sqrt(f[H] * K / N) * np.ones(N) / np.sqrt(N)
    return (W1, Ws, v)


def perturb(params, delta, mode, x=None, steps=0):
    W1, Ws, v = params
    if mode == "random-sign":
        P = (W1 + delta * rng.choice([-1, 1], W1.shape),
             [W + delta * rng.choice([-1, 1], W.shape) for W in Ws],
             v + delta * rng.choice([-1, 1], v.shape))
        return P
    if mode == "pgd":
        # projected sign-gradient ascent on +/-(z_w'(x) - z_w(x)) inside the l_inf box
        best = None
        z0, _ = forward(params, x)
        for sgn in (+1, -1):
            P = perturb(params, delta, "random-sign")
            for _ in range(steps):
                g = grad(P, x)
                P = (np.clip(P[0] + sgn * delta * 0.5 * np.sign(g[0]), W1 - delta, W1 + delta),
                     [np.clip(Pw + sgn * delta * 0.5 * np.sign(gw), W - delta, W + delta)
                      for Pw, gw, W in zip(P[1], g[1], Ws)],
                     np.clip(P[2] + sgn * delta * 0.5 * np.sign(g[2]), v - delta, v + delta))
            z1, _ = forward(P, x)
            if best is None or abs(z1 - z0) > best[0]:
                best = (abs(z1 - z0), P)
        return best[1]
    raise ValueError


def check(params, P, x, d, N, H, K, delta):
    z, hs = forward(params, x)
    z2, hs2 = forward(P, x)
    e = [np.linalg.norm(hs[l] - hs2[l]) for l in range(1, H + 1)]
    out = abs(z - z2)
    viol = []
    # one-step checks with actual e_{l-1}
    if e[0] > delta * (d + 1) * np.sqrt(N) * (1 + 1e-12):
        viol.append("e1")
    for l in range(1, H):
        if e[l] > np.sqrt(K) * e[l - 1] + delta * N ** 1.5 + 1e-15:
            viol.append(f"e{l+1}")
    if out > np.sqrt(K / N) * e[H - 1] + delta * N + 1e-15:
        viol.append("out-step")
    closed = delta * H * (d + N + 1) * (K + 1) ** (H / 2)
    # chained exact bound (before the final simplification)
    chained = delta * ((d + 1) * K ** (H / 2) + N * sum(K ** (j / 2) for j in range(H)))
    if out > chained * (1 + 1e-12):
        viol.append("chained")
    if chained > closed * (1 + 1e-12):
        viol.append("closed>=chained FAILS")
    return out / closed, out / chained, viol


worst = {}
max_closed = 0.0
nviol = 0
ntests = 0
for H in (1, 2, 3, 4):
    for d in (1, 3, 8):
        for N in (2, 5, 16, 40):
            for K in (0.5, 3.0, 20.0, 200.0):
                for wmode in ("dirichlet", "equal", "internal-heavy", "rank1-linear"):
                    for delta in (1e-6, 1e-3, 1e-1):
                        x = rng.uniform(-1, 1, d)
                        if wmode == "rank1-linear":
                            params = rank_one_linear(d, N, H, K, x)
                        else:
                            params = random_params(d, N, H, K, wmode)
                        assert abs(energy(params, d, N) - K) < 1e-8 * max(1, K)
                        for pmode in ("random-sign", "pgd"):
                            P = perturb(params, delta, pmode, x=x, steps=25)
                            r_closed, r_chain, viol = check(params, P, x, d, N, H, K, delta)
                            ntests += 1
                            max_closed = max(max_closed, r_closed)
                            if viol:
                                nviol += 1
                                print("VIOLATION", H, d, N, K, wmode, delta, pmode, viol)
                            key = (H,)
                            if key not in worst or r_chain > worst[key][0]:
                                worst[key] = (r_chain, r_closed, d, N, K, wmode, delta, pmode)

print(f"tests: {ntests}, instances with any violated inequality: {nviol}")
print(f"max over all instances of |dz|/closed-form bound: {max_closed:.4f}")
for H in sorted(worst):
    r_chain, r_closed, d, N, K, wmode, delta, pmode = worst[H]
    print(f"H={H[0]}: max |dz|/chained-bound = {r_chain:.4f} (|dz|/closed-form = {r_closed:.2e}) "
          f"at d={d}, N={N}, K={K}, w-mode={wmode}, delta'={delta}, pert={pmode}")

# Symbolic check of the last simplification:
# (d+1) K^{H/2} + N sum_{j<H} K^{j/2} <= H (d+N+1) (K+1)^{H/2}  for all K >= 0, d,N >= 1, H >= 1
import itertools
mx = 0
for H in range(1, 9):
    for d, N in itertools.product((1, 2, 10, 1000), (1, 2, 10, 1000)):
        for K in np.concatenate([[0.0], np.logspace(-4, 8, 200)]):
            lhs = (d + 1) * K ** (H / 2) + N * sum(K ** (j / 2) for j in range(H))
            rhs = H * (d + N + 1) * (K + 1) ** (H / 2)
            mx = max(mx, lhs / rhs)
print(f"max over grid of chained/closed-form ratio: {mx:.4f} (must be <= 1)")
