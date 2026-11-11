# Lemma C (perturbation) and Lemma A (cloning) of RT-width.fixed.md, independent implementation.
import numpy as np
rng = np.random.default_rng(2026)

def forward(W, v, x):
    h = np.concatenate([[1.0], x])
    for M in W:
        h = np.tanh(M @ h)
    return v @ h

def energy(W, v, d):
    N = W[0].shape[0]
    return (d / N) * np.sum(W[0]**2) + sum(np.sum(M**2) for M in W[1:]) + N * np.sum(v**2)

def random_net(d, N, H, K):
    # random direction, then rescale layers so that kappa_N = K exactly with a random energy split
    W = [rng.normal(size=(N, d + 1))] + [rng.normal(size=(N, N)) for _ in range(H - 1)]
    v = rng.normal(size=N)
    split = rng.dirichlet(np.ones(H + 1) * rng.choice([0.2, 1.0, 5.0]))
    a = [(d / N) * np.sum(W[0]**2)] + [np.sum(M**2) for M in W[1:]] + [N * np.sum(v**2)]
    W = [W[i] * np.sqrt(split[i] * K / a[i]) for i in range(H)]
    v = v * np.sqrt(split[H] * K / a[H])
    return W, v

def bound_sharp(eta, d, N, H, K):
    return eta * ((d + 1) * K**(H / 2) + N * sum(K**(j / 2) for j in range(H)))

def bound_closed(eta, d, N, H, K):
    return eta * H * (d + N + 1) * (K + 1)**(H / 2)

def grad_z_wrt_params(W, v, x):
    # backprop of z_w(x) w.r.t. all parameters
    hs = [np.concatenate([[1.0], x])]
    for M in W:
        hs.append(np.tanh(M @ hs[-1]))
    gv = hs[-1].copy()
    g = v.copy()
    gW = [None] * len(W)
    for l in range(len(W) - 1, -1, -1):
        dpre = g * (1 - hs[l + 1]**2)
        gW[l] = np.outer(dpre, hs[l])
        g = W[l].T @ dpre
    return gW, gv

worst_sharp = 0.0; worst_closed = 0.0; n_inst = 0; viol = 0
for trial in range(600):
    H = int(rng.integers(1, 5)); d = int(rng.integers(1, 7)); N = int(rng.integers(1, 13))
    K = float(rng.choice([0.3, 2.0, 10.0, 60.0]))
    W, v = random_net(d, N, H, K)
    assert abs(energy(W, v, d) - K) < 1e-8 * max(1, K)
    eta = float(rng.choice([1e-4, 1e-2, 0.1]))
    x = rng.uniform(-1, 1, size=d) * rng.choice([1.0, 0.0])
    x = np.where(rng.random(d) < 0.5, np.sign(x) + (x == 0), x)  # some corners
    z0 = forward(W, v, x)
    best = 0.0
    for sgn in [1.0, -1.0]:
        # projected sign-gradient ascent inside the l_inf box of radius eta
        dW = [np.zeros_like(M) for M in W]; dv = np.zeros_like(v)
        for it in range(25):
            Wp = [W[i] + dW[i] for i in range(H)]; vp = v + dv
            gW, gv = grad_z_wrt_params(Wp, vp, x)
            dW = [np.clip(dW[i] + sgn * eta * 0.5 * np.sign(gW[i]), -eta, eta) for i in range(H)]
            dv = np.clip(dv + sgn * eta * 0.5 * np.sign(gv), -eta, eta)
        val = abs(forward([W[i] + dW[i] for i in range(H)], v + dv, x) - z0)
        best = max(best, val)
        # also pure random corner perturbation
        dW = [eta * rng.choice([-1, 1], size=M.shape) for M in W]; dv = eta * rng.choice([-1, 1], size=v.shape)
        best = max(best, abs(forward([W[i] + dW[i] for i in range(H)], v + dv, x) - z0))
    bs = bound_sharp(eta, d, N, H, K); bc = bound_closed(eta, d, N, H, K)
    n_inst += 1
    if best > bs * (1 + 1e-9) or bs > bc * (1 + 1e-12):
        viol += 1
    worst_sharp = max(worst_sharp, best / bs); worst_closed = max(worst_closed, best / bc)
print("Lemma C: instances=%d violations=%d max |dz|/sharp=%.3f max |dz|/closed=%.3f" % (n_inst, viol, worst_sharp, worst_closed))

# Lemma A: clone exactness and energy <= E_*
worst_err = 0.0; worst_ratio = 0.0
for trial in range(300):
    H = int(rng.integers(1, 5)); d = int(rng.integers(1, 6)); m = int(rng.integers(1, 6))
    N = m + int(rng.integers(0, 3 * m + 5)); B = float(rng.uniform(0.1, 3))
    U1 = rng.uniform(-B, B, size=(m, d + 1)); Us = [rng.uniform(-B, B, size=(m, m)) for _ in range(H - 1)]
    u = rng.uniform(-B, B, size=m)
    # balanced groups
    q, r = divmod(N, m)
    sizes = [q + 1 if j < r else q for j in range(m)]
    grp = np.concatenate([[j] * sizes[j] for j in range(m)])
    k = np.array(sizes, dtype=float)
    W1 = U1[grp, :]
    Ws = [M[np.ix_(grp, grp)] / k[grp][None, :] for M in Us]
    vv = u[grp] / k[grp]
    Wl = [W1] + Ws
    E = energy(Wl, vv, d); Estar = d * (d + 1) * B**2 + 2 * H * m**2 * B**2
    for _ in range(20):
        x = rng.uniform(-3, 3, size=d)
        g = forward([U1] + Us, u, x); z = forward(Wl, vv, x)
        worst_err = max(worst_err, abs(g - z))
    worst_ratio = max(worst_ratio, E / Estar)
print("Lemma A: max |clone - g| = %.2e on R^d samples; max kappa_N(clone)/E_* = %.3f" % (worst_err, worst_ratio))
