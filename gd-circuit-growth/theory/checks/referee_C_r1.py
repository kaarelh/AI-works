"""Referee C r1: independent numerical stress tests of inequalities claimed Proved in C-bridge-and-certificates.md.
Short (well under a minute).  Writes nothing; output is captured in referee_C_r1.out."""
import math, itertools, sys
sys.dont_write_bytecode = True
import numpy as np
import c_common as cc

rng = np.random.default_rng(12345)

# (1) kl-inverse readings used in Theorem C1's additive form and in section 0
worst1 = worst2 = worst3 = -1.0
for q in np.concatenate([[0.0], np.logspace(-6, -0.01, 60)]):
    for eps in np.logspace(-6, 1, 60):
        p = cc.klinv_upper(float(q), float(eps))
        worst1 = max(worst1, p - (q + math.sqrt(2 * q * eps) + 2 * eps))
        worst2 = max(worst2, p - (q + math.sqrt(eps / 2)))
        if q == 0:
            worst3 = max(worst3, abs(p - (1 - math.exp(-eps))))
print(f"(1) max[klinv - (q+sqrt(2q e)+2e)] = {worst1:.2e} (<=0 expected); max[klinv - (q+sqrt(e/2))] = {worst2:.2e}; "
      f"max|klinv(0,e)-(1-e^-e)| = {worst3:.1e}")

# (2) Lemma C3.1(2): one GD step on a two-layer ReLU net, rho' <= rho (1 + eta*Ubar)^2 for ANY eta, any selection s(0);
#     and the per-layer-multiplier remark rho=a^2/m_a+|w|^2/m_w, rho' <= rho (1+eta sqrt(m_a m_w) Ubar)^2.
worst = 0.0; worst_m = 0.0
for trial in range(3000):
    d = rng.integers(2, 8); n = rng.integers(3, 40); M = rng.integers(1, 6)
    X = rng.choice([-1.0, 1.0], size=(n, d)); Xt = np.hstack([X, np.ones((n, 1))])
    if trial % 3 == 0:  # put some pre-activations exactly at 0 to exercise the subgradient choice
        Xt[:, -1] = 0.0
    lam = float(np.linalg.eigvalsh(Xt.T @ Xt / n)[-1])
    y = rng.standard_normal(n)
    a = rng.standard_normal(M) * 10 ** rng.uniform(-3, 1); W = rng.standard_normal((M, d + 1)) * 10 ** rng.uniform(-3, 1)
    if trial % 3 == 0:
        W[:, -1] = 0.0; W[:, :-1] = 0.0; W[0, 0] = 0.0
    eta = 10 ** rng.uniform(-3, 1)
    ma, mw = 10 ** rng.uniform(-1, 1), 10 ** rng.uniform(-1, 1)
    Z = Xt @ W.T; Hs = np.maximum(Z, 0); f = Hs @ a; r = y - f
    Ubar = math.sqrt(lam) * math.sqrt(np.mean(r * r))
    s = (Z > 0).astype(float) + (Z == 0) * rng.uniform(0, 1, Z.shape)  # arbitrary Clarke selection at 0
    A = Hs.T @ r / n                      # <r, sigma(w_j . x)>_n
    V = ((s * r[:, None]).T @ Xt) / n     # <r, s_j x>_n, shape (M, d+1)
    for (m_a, m_w, store) in ((1.0, 1.0, 0), (ma, mw, 1)):
        a2 = a + eta * m_a * A; W2 = W + eta * m_w * a[:, None] * V
        rho = a ** 2 / m_a + (W ** 2).sum(1) / m_w; rho2 = a2 ** 2 / m_a + (W2 ** 2).sum(1) / m_w
        ratio = np.max(rho2 / np.maximum(rho * (1 + eta * math.sqrt(m_a * m_w) * Ubar) ** 2, 1e-300))
        if store == 0:
            worst = max(worst, ratio)
        else:
            worst_m = max(worst_m, ratio)
print(f"(2) Lemma C3.1(2) one-step ratio max = {worst:.6f} (<=1); with per-layer multipliers max = {worst_m:.6f} (<=1)")

# (3) Lemma C3.2 Euler identity <W_l, df/dW_l> = f for a bias-free deep ReLU net with constant input
worst = 0.0
for trial in range(500):
    L = rng.integers(2, 5); d = 4; width = 5
    dims = [d + 1] + [width] * (L - 1) + [1]
    Ws = [rng.standard_normal((dims[l + 1], dims[l])) for l in range(L)]
    x = np.append(rng.choice([-1.0, 1.0], size=d), 1.0)
    hs = [x]; zs = []
    for l in range(L):
        z = Ws[l] @ hs[-1]; zs.append(z)
        hs.append(np.maximum(z, 0) if l < L - 1 else z)
    fval = float(zs[-1][0])
    b = np.ones(1); grads = [None] * L
    for l in range(L - 1, -1, -1):
        grads[l] = np.outer(b, hs[l])
        if l > 0:
            b = (zs[l - 1] > 0) * (Ws[l].T @ b)
    for l in range(L):
        worst = max(worst, abs(float(np.sum(Ws[l] * grads[l])) - fval) / (abs(fval) + 1e-12))
print(f"(3) Lemma C3.2 Euler identity max rel. error = {worst:.1e}")

# (4) Prop C2.6 item 5 (full-batch count with Phi_K) under large steps, and item 4
def chars(X, sets):
    C = np.ones((len(X), len(sets)))
    for j, S in enumerate(sets):
        for i in S:
            C[:, j] *= X[:, i]
    return C
d = 8; sets = [S for j in range(0, 3) for S in itertools.combinations(range(d), j)]; Dn = len(sets)
worst4 = worst5 = 0.0; viol = 0
for trial in range(30):
    n = int(rng.integers(20, 200)); X = rng.choice([-1.0, 1.0], size=(n, d)); C = chars(X, sets)
    y = np.sign(X[:, 0] + X[:, 1] + X[:, 2]) if trial % 2 else X[:, 0] * X[:, 1]
    alpha = 10 ** rng.uniform(-6, -2); eta = rng.uniform(0.05, 0.45)
    u = alpha * np.ones(Dn); v = alpha * np.ones(Dn)
    tau = 0.0; Phi = 0.0; gnorm = 0.0; G = 0.0
    for j in range(400):
        w = u * u - v * v; r = y - C @ w; g = -(C.T @ r) / n
        G = max(G, float(np.max(np.abs(g))))
        if 2 * eta * G >= 1:
            break
        z = 2 * eta * float(np.max(np.abs(g)))
        tau += eta * math.sqrt(np.mean(r * r)); Phi += 0.5 * z ** 3 / (3 * (1 - z * z)); gnorm += eta * float(np.linalg.norm(g))
        u = u * (1 - 2 * eta * g); v = v * (1 + 2 * eta * g)
        w = u * u - v * v
        c = 1 / (1 - 4 * eta ** 2 * G ** 2)
        for eps in (1e-3, 1e-2, 1e-1):
            Th = 0.25 * math.asinh(eps / (2 * alpha ** 2))
            B = np.where(np.abs(w) >= eps)[0]; N = len(B)
            if N == 0:
                continue
            b4 = (c * gnorm) ** 2 / Th ** 2
            worst4 = max(worst4, N / b4)
            if Th > Phi:
                kap = float(np.linalg.eigvalsh(C[:, B].T @ C[:, B] / n)[-1])
                b5 = kap * tau ** 2 / (Th - Phi) ** 2
                worst5 = max(worst5, N / b5)
print(f"(4) Prop C2.6 with eta up to 0.45: max N/bound item 4 = {worst4:.3f}, item 5 = {worst5:.3f} (<=1 expected)")

# (5) Prop C4.3 by simulation: online race first phase at the smallest admissible b/eta.
#     Library: identity and XOR on d=12 inputs (+-1 gates, M = 12 + 66), target y = x1 x2 (U*=1 for XOR(1,2));
#     add a noisy label flip with prob p so that U* = 1-2p and other gates have U=0; gamma = U*.
def sim(p_flip, delta, Theta, reps, seed):
    rr = np.random.default_rng(seed)
    d = 12
    gates = [(i,) for i in range(d)] + list(itertools.combinations(range(d), 2))
    Mn = len(gates); Ustar = 1 - 2 * p_flip; gamma = Ustar
    eta = Theta * gamma / (2 * Ustar ** 2)
    b_over_eta = 80 * Ustar * math.log(2 * Mn / delta) / (Theta * gamma ** 2) * 1.0001
    b = int(math.ceil(b_over_eta * eta)); eta = b / b_over_eta  # keep b/eta at its minimum, eta <= admissible
    fails = 0; t1s = []
    for rep in range(reps):
        S = np.zeros(Mn); i = 0
        while True:
            i += 1
            X = rr.choice([-1.0, 1.0], size=(b, d))
            y = X[:, 0] * X[:, 1] * np.where(rr.random(b) < p_flip, -1.0, 1.0)
            vals = np.empty((b, Mn))
            for m, gset in enumerate(gates):
                vals[:, m] = X[:, gset[0]] if len(gset) == 1 else X[:, gset[0]] * X[:, gset[1]]
            S += eta * (y @ vals) / b
            fired = np.where(np.abs(S) >= Theta)[0]
            if len(fired):
                t1 = i * eta
                ok = (list(fired) == [gates.index((0, 1))] and S[gates.index((0, 1))] > 0
                      and 0.75 * Theta / Ustar <= t1 <= 1.25 * Theta / Ustar + eta)
                fails += (not ok); t1s.append(t1)
                break
    return fails / reps, b, eta, np.mean(t1s) * b / eta
for p_flip in (0.0, 0.25):
    fr, b, eta, N1 = sim(p_flip, 0.05, 1.5, 200, 7)
    print(f"(5) Prop C4.3 sim: p_flip={p_flip} b={b} eta={eta:.3f} failure rate {fr:.3f} (delta=0.05); mean N1 = {N1:.0f}")
