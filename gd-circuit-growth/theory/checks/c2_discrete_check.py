"""C2, Proposition C2.6: the diagonal network trained by discrete GD or minibatch SGD.

Updates u <- u*(1 - 2 eta g), v <- v*(1 + 2 eta g), with g the full-batch or minibatch gradient of the square loss
in w.  Checks, at every step:
  (i)   w = -2 u v sinh(2 psi), psi = sum_j artanh(2 eta g_j), and 0 < u v <= alpha^2;
  (iii) first escape of level eps happens only after tau_batch >= Theta_eps (1 - 4 eta^2 G^2),
        tau_batch = eta * sum_j |r_j|_{B_j};
  (iv)  N_eps <= (c eta sum_j |g_j|_2)^2 / Theta_eps^2,   c = 1/(1 - 4 eta^2 G^2);
  (v)   (full batch) N_eps <= kappa_B tau^2 / (Theta_eps - Phi)^2.
Same instance as c2_diag_check.py: d = 10, all characters of degree <= 3 (D = 176).
"""
import itertools, math, sys
import numpy as np
sys.dont_write_bytecode = True

d, k = 10, 3
SETS = [S for j in range(k + 1) for S in itertools.combinations(range(d), j)]
D = len(SETS)


def chars(X):
    C = np.ones((len(X), D))
    for j, S in enumerate(SETS):
        for i in S:
            C[:, j] *= X[:, i]
    return C


def run(name, n, alpha, eta, steps, batch=None, seed=0):
    rng = np.random.default_rng(seed)
    X = rng.choice([-1.0, 1.0], size=(n, d))
    y = {"maj3": np.sign(X[:, :3].sum(1)), "par2": X[:, 0] * X[:, 1],
         "and3": np.where((X[:, :3] > 0).all(1), 1.0, -1.0)}[name]
    C = chars(X)
    u = alpha * np.ones(D); v = alpha * np.ones(D)
    psi = np.zeros(D)
    tau_b, sum_g2, G = 0.0, 0.0, 0.0
    phi_full = 0.0
    tau_full = 0.0
    eps_list = [1e-3, 1e-2, 1e-1]
    first = {e: None for e in eps_list}
    worst = dict(i=0.0, iv=0.0, v=0.0, uv=0.0)
    for it in range(steps):
        idx = np.arange(n) if batch is None else rng.integers(0, n, batch)
        w = u * u - v * v
        rb = y[idx] - C[idx] @ w
        g = -(C[idx].T @ rb) / len(idx)
        z = 2 * eta * g
        assert np.max(np.abs(z)) < 1
        G = max(G, float(np.max(np.abs(g))))
        u = u * (1 - z); v = v * (1 + z)
        psi = psi + np.arctanh(z)
        tau_b += eta * math.sqrt(np.mean(rb ** 2))
        r_full = y - C @ w
        tau_full += eta * math.sqrt(np.mean(r_full ** 2))
        sum_g2 += eta * np.linalg.norm(g)
        Gj = float(np.max(np.abs(z)))
        phi_full += 0.5 * Gj ** 3 / (3 * (1 - Gj ** 2))
        w_new = u * u - v * v
        # (i)
        worst["i"] = max(worst["i"], float(np.max(np.abs(w_new + 2 * u * v * np.sinh(2 * psi)) / np.maximum(np.abs(w_new), alpha ** 2))))
        worst["uv"] = max(worst["uv"], float(np.max(u * v)) / alpha ** 2)
        cfac = 1 / (1 - 4 * eta ** 2 * G ** 2)
        for e in eps_list:
            Th = 0.25 * math.asinh(e / (2 * alpha ** 2))
            B = np.where(np.abs(w_new) >= e)[0]
            N = len(B)
            if N and first[e] is None:
                first[e] = (it + 1, tau_b, Th * (1 - 4 * eta ** 2 * G ** 2))
            if N:
                worst["iv"] = max(worst["iv"], N / ((cfac * sum_g2) ** 2 / Th ** 2))
                if batch is None and Th > phi_full:
                    kap = float(np.linalg.eigvalsh(C[:, B].T @ C[:, B] / n)[-1])
                    worst["v"] = max(worst["v"], N / (kap * tau_full ** 2 / (Th - phi_full) ** 2))
    w = u * u - v * v
    return dict(first=first, worst=worst, final_loss=0.5 * float(np.mean((y - C @ w) ** 2)), G=G,
                N_final=int(np.sum(np.abs(w) >= 1e-2)))


if __name__ == "__main__":
    for name, n, alpha, eta, steps, batch in [("maj3", 400, 1e-3, 0.05, 2000, None), ("maj3", 400, 1e-3, 0.02, 5000, 32),
                                               ("and3", 400, 1e-3, 0.05, 2000, None), ("and3", 400, 1e-3, 0.02, 5000, 32),
                                               ("par2", 100, 1e-3, 0.1, 1000, None), ("par2", 100, 1e-3, 0.02, 5000, 16)]:
        r = run(name, n, alpha, eta, steps, batch)
        kind = "GD" if batch is None else f"SGD(b={batch})"
        print(f"{name} n={n} {kind} eta={eta} steps={steps}: final loss {r['final_loss']:.2e}, N(1e-2)={r['N_final']}, "
              f"max_j 2 eta|g_j|_inf = {2 * eta * r['G']:.3f}")
        print(f"   (i) max rel. error of w = -2uv sinh(2psi): {r['worst']['i']:.1e};  max uv/alpha^2 = {r['worst']['uv']:.6f} (<= 1)")
        for e, f in r["first"].items():
            if f:
                print(f"   (iii) eps={e:.0e}: first escape at step {f[0]}, tau_batch={f[1]:.3f} >= {f[2]:.3f}: {f[1] >= f[2]}")
        print(f"   (iv) max N / bound = {r['worst']['iv']:.3f} (<= 1)" +
              (f";  (v) max N / bound = {r['worst']['v']:.3f} (<= 1)" if batch is None else ""))
