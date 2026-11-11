"""(a) Lemma 3.1 with adversarially aligned centres (rank-one internal layers at full energy, linear-regime
first layer), checking dev <= (3H+2) K0^{H/2} tau on the typical event E;  (b) (G3) tails as used;
(c) toy check of Lemma 2.2 (PAC-Bayes with Hoeffding constant 2 Lambda^2/n)."""
import numpy as np, itertools
rng = np.random.default_rng(2026)
def cube(d): return np.array(list(itertools.product([-1.0, 1.0], repeat=d)))

print("== (a) Lemma 3.1, aligned centres ==")
d = 5; X = cube(d); Xb = np.hstack([np.ones((len(X), 1)), X])
for H in [2, 3, 4]:
    L = H+1
    for N in [100, 400]:
        for gamma in [1.2, 2.0]:
            tau = N**((1-gamma)/2); tL = np.sqrt(2*np.log(2*L))
            if N < (np.sqrt(d+1)+tL)**2: continue
            K0 = 30.0
            u = rng.standard_normal(N); u /= np.linalg.norm(u)
            W1 = 0.05*np.outer(u, np.ones(d+1))*np.sqrt(N)          # small, linear regime, aligned with u
            Ws = [np.sqrt(K0/L)*np.outer(u, u) for _ in range(H-1)]    # rank one, op norm sqrt(K0/L)
            v = np.sqrt(K0/L/N)*u
            def fwd(W1, Ws, v):
                h = np.tanh(Xb @ W1.T)
                for W in Ws: h = np.tanh(h @ W.T)
                return h @ v
            k0 = max(1.0, (d/N)*np.sum(W1**2) + sum(np.sum(W**2) for W in Ws) + N*np.sum(v**2))
            z0 = fwd(W1, Ws, v); worst = 0; inE = 0; T = 200
            for _ in range(T):
                x1 = rng.standard_normal(W1.shape); Zs = [rng.standard_normal((N, N)) for _ in Ws]; ze = rng.standard_normal(N)
                okE = (np.linalg.norm(x1, 2) <= np.sqrt(N)+np.sqrt(d+1)+tL) and all(np.linalg.norm(Z, 2) <= 2*np.sqrt(N)+tL for Z in Zs) and (np.linalg.norm(ze) <= np.sqrt(N)+tL)
                if not okE: continue
                inE += 1
                z = fwd(W1 + tau/np.sqrt(d)*x1, [W + tau/np.sqrt(N)*Z for W, Z in zip(Ws, Zs)], v + tau/N*ze)
                worst = max(worst, np.abs(z - z0).max())
            bound = (3*H+2)*k0**(H/2)*tau
            print(f"H={H} N={N} gamma={gamma}: K0={k0:.1f} frac in E={inE/T:.2f} (>=0.5) max dev={worst:.4f} bound={bound:.3f} ratio={worst/bound:.4f}")

print("== (b) (G3) tails ==")
for (p, q) in [(50, 50), (200, 200), (300, 7)]:
    vals = np.array([np.linalg.norm(rng.standard_normal((p, q)), 2) for _ in range(400)])
    for t in [0.5, 1.0, 1.5]:
        emp = np.mean(vals >= np.sqrt(p)+np.sqrt(q)+t)
        print(f"p={p} q={q} t={t}: empirical {emp:.4f} <= exp(-t^2/2)={np.exp(-t*t/2):.4f}")

print("== (c) toy Lemma 2.2 (PAC-Bayes) ==")
# one-parameter model z_w(x)=w*tanh(3x) (unbounded output, clipped loss), prior N(0,1),
# labels y = clip(0.3 x + noise); Gibbs posterior exp(-Lam * unclipped empirical loss).
ws = np.linspace(-12, 12, 24001); dw = ws[1]-ws[0]
prior = np.exp(-ws**2/2)/np.sqrt(2*np.pi)
xt = rng.uniform(-1, 1, 200000); yt = np.clip(0.3*xt + rng.choice([-0.7, 0.7], xt.size), -1, 1)
ft = np.tanh(3*xt)
# population clipped loss L_D(w) by Monte Carlo on a large test set, vectorised over a coarse grid then interpolated
wg_ = np.linspace(-12, 12, 481)
LD_coarse = np.array([np.mean((np.clip(w*ft, -1, 1) - yt)**2) for w in wg_])
LD = np.interp(ws, wg_, LD_coarse)
for n, Lam, dlt in [(50, 10.0, 0.1), (200, 30.0, 0.1), (200, 100.0, 0.05)]:
    viol = 0; R = 400
    for _ in range(R):
        x = rng.uniform(-1, 1, n); y = np.clip(0.3*x + rng.choice([-0.7, 0.7], n), -1, 1); f = np.tanh(3*x)
        A1 = np.sum(f*f); B1 = np.sum(f*y); C1 = np.sum(y*y)
        Lhat_unclip = (ws**2*A1 - 2*ws*B1 + C1)/n
        logpost = -Lam*Lhat_unclip + np.log(prior); mx = logpost.max()
        post = np.exp(logpost - mx); Zp = post.sum()*dw; post /= Zp
        lnZ = mx + np.log(Zp)                                   # ln Z' = ln E_mu exp(-Lam Lhat')
        lhs = np.sum(post*LD)*dw
        rhs = -lnZ/Lam + np.log(1/dlt)/Lam + 2*Lam/n
        viol += lhs > rhs
    print(f"n={n} Lam={Lam} delta'={dlt}: violation frequency {viol/R:.3f} (must be <= {dlt})")
