"""Lemma C of RT-width.fixed.md, adversarially.

For eta -> 0, sup_{|w'-w|_inf <= eta} |z_w(x) - z_w'(x)| / eta -> ||grad_w z_w(x)||_1.  We maximize
||grad_w z_w(x)||_1 over w with kappa_N(w) <= K and x in [-1,1]^d (projected gradient ascent with random
restarts, plus structured starts), and compare with the sharper bracket
    S = (d+1) K^{H/2} + N sum_{j=0}^{H-1} K^{j/2}
and the closed form C = H (d+N+1) (K+1)^{H/2}.  Then we test finite perturbations eta in {1e-3, 1e-1, 1}
(sign-gradient and random signs) against eta*S.
"""
import numpy as np
rng = np.random.default_rng(11)

def unpack(theta, d, N, H):
    i = 0
    W1 = theta[i:i+N*(d+1)].reshape(N, d+1); i += N*(d+1)
    Ws = []
    for _ in range(H-1):
        Ws.append(theta[i:i+N*N].reshape(N, N)); i += N*N
    v = theta[i:i+N]
    return W1, Ws, v

def scales(d, N, H):
    # kappa = |Lambda theta|^2 with Lambda diag
    return np.concatenate([np.full(N*(d+1), np.sqrt(d/N))] + [np.ones(N*N)]*(H-1) + [np.full(N, np.sqrt(N))])

def fwd_grad(theta, x, d, N, H):
    W1, Ws, v = unpack(theta, d, N, H)
    xb = np.concatenate([[1.0], x])
    hs = [xb]; pre = []
    a = W1 @ xb; pre.append(a); h = np.tanh(a); hs.append(h)
    for W in Ws:
        a = W @ h; pre.append(a); h = np.tanh(a); hs.append(h)
    z = v @ h
    g_v = h.copy()
    delta = v * (1 - h**2)
    gW = [None]*H
    for k in range(H-1, -1, -1):
        gW[k] = np.outer(delta, hs[k])
        if k > 0:
            delta = (Ws[k-1].T @ delta) * (1 - hs[k]**2)
    grad = np.concatenate([gW[0].ravel()] + [g.ravel() for g in gW[1:]] + [g_v])
    return z, grad

def l1grad(theta, x, d, N, H):
    return np.abs(fwd_grad(theta, x, d, N, H)[1]).sum()

def project(theta, lam, K):
    e = np.sum((lam*theta)**2)
    return theta if e <= K else theta*np.sqrt(K/e)

def num_grad(f, t, eps=1e-6):
    g = np.zeros_like(t)
    for i in range(t.size):
        tp = t.copy(); tp[i] += eps; tm = t.copy(); tm[i] -= eps
        g[i] = (f(tp) - f(tm))/(2*eps)
    return g

worst = 0.0; worst_case = None; rows = []
for trial in range(220):
    H = int(rng.integers(1, 5)); d = int(rng.integers(1, 5)); N = int(rng.integers(1, 7))
    K = float(rng.choice([0.5, 2.0, 8.0, 40.0, 300.0]))
    lam = scales(d, N, H); Pn = lam.size
    S = (d+1)*K**(H/2) + N*sum(K**(j/2) for j in range(H))
    C = H*(d+N+1)*(K+1)**(H/2)
    best = 0.0
    for start in range(4):
        theta = rng.standard_normal(Pn)/lam
        if start == 1:  # all mass in internal layers, aligned rank one
            W1, Ws, v = unpack(theta, d, N, H)
            W1[:] = 0; W1[:, 0] = 0.3
            for W in Ws: W[:] = 1.0
            v[:] = 1.0
            theta = np.concatenate([W1.ravel()] + [W.ravel() for W in Ws] + [v])
        theta = project(theta*np.sqrt(K)/np.linalg.norm(lam*theta), lam, K)
        x = rng.uniform(-1, 1, d)
        step = 0.05
        for it in range(150):
            f = lambda t: l1grad(t, x, d, N, H)
            gt = num_grad(f, theta)
            fx = lambda xx: l1grad(theta, np.clip(xx, -1, 1), d, N, H)
            gx = num_grad(fx, x)
            theta = project(theta + step*gt/ (np.linalg.norm(gt)+1e-12) * np.sqrt(K)/np.sqrt(Pn) * 3, lam, K)
            # move to boundary of the energy ellipsoid
            e = np.sum((lam*theta)**2); theta *= np.sqrt(K/e)
            x = np.clip(x + 0.1*np.sign(gx), -1, 1)
            best = max(best, l1grad(theta, x, d, N, H))
    r = best/S
    rows.append((H, d, N, K, best, S, C))
    if r > worst: worst, worst_case = r, (H, d, N, K, best, S, C)
print("(1) linearized worst case: max ||grad z||_1 / S = %.4f at (H,d,N,K,||grad||_1,S,C) = %s (must be <= 1)" % (worst, worst_case))
print("    max ||grad z||_1 / C = %.4f" % max(b/C for (_,_,_,_,b,_,C) in rows))

# (2) finite perturbations, eta not small: Lemma C has no smallness assumption
worst2 = 0.0; wc2 = None
for trial in range(3000):
    H = int(rng.integers(1, 5)); d = int(rng.integers(1, 6)); N = int(rng.integers(1, 12))
    K = float(rng.choice([0.5, 2.0, 8.0, 40.0, 300.0]))
    lam = scales(d, N, H); Pn = lam.size
    theta = rng.standard_normal(Pn)/lam; theta *= np.sqrt(K)/np.linalg.norm(lam*theta)
    S = (d+1)*K**(H/2) + N*sum(K**(j/2) for j in range(H))
    X = rng.uniform(-1, 1, (64, d)); X[:8] = np.sign(X[:8])
    for eta in [1e-3, 1e-1, 1.0, 5.0]:
        i = int(rng.integers(0, 64))
        _, g = fwd_grad(theta, X[i], d, N, H)
        for sgn in [1, -1]:
            th2 = theta + sgn*eta*np.sign(g)
            z1 = np.array([fwd_grad(theta, x, d, N, H)[0] for x in X]); z2 = np.array([fwd_grad(th2, x, d, N, H)[0] for x in X])
            r = np.max(np.abs(z1 - z2))/(eta*S)
            if r > worst2: worst2, wc2 = r, (H, d, N, K, eta)
print("(2) finite perturbations: max |dz|/(eta S) = %.4f at (H,d,N,K,eta) = %s (must be <= 1)" % (worst2, wc2))
