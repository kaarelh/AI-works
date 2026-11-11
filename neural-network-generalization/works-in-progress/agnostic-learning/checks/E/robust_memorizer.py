"""Noise-robust memorizer (E-finite-prior-scale.md Proposition 4.4, Section 4) and its behaviour under
finite-scale prior noise.  Features are sampled i.i.d. as in Step 2 of the proof, but with m far below
the m_f of the proposition, so sampling error dominates at these sizes (Section 7, item 4).

Noise level tau = N^{(1-gamma)/2} (tau=1 is mean field, gamma=1).  Construction:
  r = ybar on seen atoms, r~ = r / Pi*,  first-layer features psi_1(omega.xbar),
  psi_1(u) = E tanh(u + tau*tau_d*G),  tau_d^2=(d+1)/d,
  layer 2 weights c_j / R^{H-1} (same for every row), layers 3..H weights R/N, readout R/N.
We sample perturbations xi ~ N(0,I) at the prior's standardized scales and measure
max_cube |z - r|.  We also report the energy kappa_N(w0)."""
import numpy as np, itertools, sys
from numpy.polynomial.hermite_e import hermegauss
from nets import cube, xbar, forward, energy

xg, wg = hermegauss(120); wg = wg/np.sqrt(2*np.pi)
EG = lambda f: np.sum(wg*f(xg))

def kappa(q): return EG(lambda g: 1/np.cosh(np.sqrt(q)*g)**2)
def pistar(H, tau):
    q, P = 1.0, 1.0
    for l in range(1, H):
        P *= kappa(tau**2*q)
        q = EG(lambda g: np.tanh(tau*np.sqrt(q)*g)**2)
    return P

def build(d, r, H, tau, N, m, alpha, R, rng):
    M = 2**d; X = cube(d)
    Pi = pistar(H, tau); rt = r/Pi
    taud = np.sqrt((d+1)/d)
    psi1 = lambda u: np.tanh(np.asarray(u, float)[..., None] + tau*taud*xg) @ wg
    feats, coefs = [], []
    # constant feature
    rhat0 = rt.mean()
    feats.append(np.r_[alpha, np.zeros(d)]); coefs.append(rhat0/float(psi1(alpha)))
    for k in range(1, d+1):
        bk = 1 if k % 2 == 0 else 0
        V = np.array(list(itertools.product([-1, 1], repeat=k)))
        ck = np.mean(np.prod(V, 1)*psi1(alpha*(V.sum(1)-bk)))
        for S in itertools.combinations(range(d), k):
            chi = np.prod(X[:, S], 1)
            rh = np.mean(rt*chi)
            if abs(rh) < 1e-14: continue
            for uvec in V:
                om = np.zeros(d+1); om[0] = -alpha*bk; om[[j+1 for j in S]] = alpha*uvec
                feats.append(om); coefs.append(rh/ck*2.0**(-k)*np.prod(uvec))
    feats = np.array(feats); coefs = np.array(coefs)
    A = np.abs(coefs).sum()
    # exact expansion check with psi_1 features
    Phi = psi1(xbar(X) @ feats.T)   # (M, J)
    exp_err = np.abs(Phi @ coefs - rt).max()
    # sample m signed features
    p = np.abs(coefs)/A
    J = rng.choice(len(coefs), size=m, p=p)
    rows = feats[J]*np.sign(coefs[J])[:, None]
    gpsi = (A/m)*psi1(xbar(X) @ rows.T).sum(1)
    samp_err = np.abs(gpsi - rt).max()
    # network
    kt = np.full(m, N//m); kt[:N % m] += 1
    grp = np.repeat(np.arange(m), kt)
    W1 = rows[grp]
    c = A/(m*kt[grp])
    W2 = np.tile(c/R**(H-1), (N, 1))
    Ws = [W2] + [np.full((N, N), R/N) for _ in range(H-2)]
    v = np.full(N, R/N)
    w0 = (W1, Ws, v)
    return w0, dict(Pi=Pi, A=A, exp_err=exp_err, samp_err=samp_err, nfeat=len(coefs))

def run(d, n, H, gamma, N, m, alpha, R, a_target, reps, seed):
    rng = np.random.default_rng(seed)
    M = 2**d; X = cube(d)
    idx = rng.integers(0, M, n); y = rng.choice([-1.0, 1.0], n)
    r = np.zeros(M); cnt = np.zeros(M)
    np.add.at(r, idx, y); np.add.at(cnt, idx, 1)
    seen = cnt > 0; r[seen] /= cnt[seen]
    tau = N**((1-gamma)/2)
    w0, info = build(d, r, H, tau, N, m, alpha, R, rng)
    K = energy(w0, d)
    z0 = forward(w0, X)
    W1, Ws, v = w0
    errs = []
    for rep in range(reps):
        xi1 = rng.standard_normal(W1.shape); Zs = [rng.standard_normal(W.shape) for W in Ws]; ze = rng.standard_normal(N)
        w = (W1 + tau/np.sqrt(d)*xi1, [W + tau/np.sqrt(N)*Z for W, Z in zip(Ws, Zs)], v + tau/N*ze)
        errs.append(np.abs(forward(w, X) - r).max())
    errs = np.array(errs)
    print(f"d={d} n={n} H={H} gamma={gamma} N={N} m={m} alpha={alpha} R={R}: tau={tau:.3f} Pi*={info['Pi']:.4f} "
          f"A={info['A']:.1f} expansion err={info['exp_err']:.1e} sampling err={info['samp_err']:.3f} "
          f"kappa(w0)={K:.1f} n={n}; noiseless max|z0-r|={np.abs(z0-r).max():.3f}; "
          f"noisy max|z-r| over {reps} draws: median={np.median(errs):.3f}, max={errs.max():.3f}")
    sys.stdout.flush()
    return errs

if __name__ == "__main__":
    d, n = 6, 64
    for (H, gamma, N, m, alpha, R) in [(2, 1.0, 1000, 500, 4.0, 5.0), (2, 1.0, 4000, 1000, 4.0, 5.0),
                                         (2, 1.0, 8000, 2000, 4.0, 5.0), (2, 1.5, 4000, 1000, 4.0, 5.0),
                                         (3, 1.0, 2000, 1000, 4.0, 3.0), (3, 1.0, 5000, 2000, 4.0, 3.0)]:
        run(d, n, H, gamma, N, m, alpha, R, 0.2, reps=6, seed=3)
