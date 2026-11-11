"""Robust memorizer with deterministic neuron allocation (n_j ~ N|gamma_j|/A) instead of random
feature sampling; features that receive no neuron are dropped (their coefficient mass is reported).
Same network form as E-finite-prior-scale.md Section 4 (Proposition 4.4); a variant of the
proposition's construction that isolates the noise mechanism (Section 7, item 4).
Reports, per run: tau, Pi*, the total coefficient mass A = sum|gamma_j|, the dropped coefficient
mass, the energy kappa_N(w0), max|z-r| on the cube under prior noise (median and max over the draws),
and the median of the same error for a 'naive' memorizer (no 1/Pi* compensation, tanh features)."""
import numpy as np, itertools, sys
from numpy.polynomial.hermite_e import hermegauss
from nets import cube, xbar, forward, energy
xg, wg = hermegauss(120); wg = wg/np.sqrt(2*np.pi)
EG = lambda f: np.sum(wg*f(xg))
def kappa(q): return EG(lambda g: 1/np.cosh(np.sqrt(q)*g)**2)
def pistar(H, tau):
    q, P = 1.0, 1.0
    for l in range(1, H):
        P *= kappa(tau**2*q); q = EG(lambda g: np.tanh(tau*np.sqrt(q)*g)**2)
    return P

def expansion(d, target, alpha, act):
    X = cube(d); feats, coefs = [np.r_[alpha, np.zeros(d)]], [target.mean()/float(act(alpha))]
    for k in range(1, d+1):
        bk = 1 if k % 2 == 0 else 0
        V = np.array(list(itertools.product([-1, 1], repeat=k)))
        ck = np.mean(np.prod(V, 1)*act(alpha*(V.sum(1)-bk)))
        for S in itertools.combinations(range(d), k):
            rh = np.mean(target*np.prod(X[:, S], 1))
            if abs(rh) < 1e-14: continue
            for uvec in V:
                om = np.zeros(d+1); om[0] = -alpha*bk; om[[j+1 for j in S]] = alpha*uvec
                feats.append(om); coefs.append(rh/ck*2.0**(-k)*np.prod(uvec))
    return np.array(feats), np.array(coefs)

def network(feats, coefs, N, H, R):
    A = np.abs(coefs).sum()
    nj = np.floor(N*np.abs(coefs)/A).astype(int)
    rem = N - nj.sum(); order = np.argsort(-(N*np.abs(coefs)/A - nj)); nj[order[:rem]] += 1
    keep = nj > 0
    rows = feats[keep]*np.sign(coefs[keep])[:, None]; g = np.abs(coefs[keep]); nk = nj[keep]
    W1 = np.repeat(rows, nk, axis=0)
    c = np.repeat(g/nk, nk)
    Ws = [np.tile(c/R**(H-1), (N, 1))] + [np.full((N, N), R/N) for _ in range(H-2)]
    v = np.full(N, R/N)
    dropped = np.abs(coefs[~keep]).sum()
    return (W1, Ws, v), A, dropped

def noisy_errs(w0, d, tau, r, reps, rng):
    X = cube(d); W1, Ws, v = w0; N = W1.shape[0]; out = []
    for _ in range(reps):
        w = (W1 + tau/np.sqrt(d)*rng.standard_normal(W1.shape),
             [W + tau/np.sqrt(N)*rng.standard_normal(W.shape) for W in Ws], v + tau/N*rng.standard_normal(N))
        out.append(np.abs(forward(w, X) - r).max())
    return np.array(out)

def run(d, n, H, gamma, N, alpha, R, reps, seed):
    rng = np.random.default_rng(seed); M = 2**d; X = cube(d)
    idx = rng.integers(0, M, n); y = rng.choice([-1.0, 1.0], n)
    r = np.zeros(M); cnt = np.zeros(M); np.add.at(r, idx, y); np.add.at(cnt, idx, 1)
    r[cnt > 0] /= cnt[cnt > 0]
    tau = N**((1-gamma)/2); taud = np.sqrt((d+1)/d)
    psi1 = lambda u: np.tanh(np.asarray(u, float)[..., None] + tau*taud*xg) @ wg
    Pi = pistar(H, tau)
    feats, coefs = expansion(d, r/Pi, alpha, psi1)
    w0, A, dropped = network(feats, coefs, N, H, R)
    errs = noisy_errs(w0, d, tau, r, reps, rng)
    # naive memorizer: tanh features, no compensation (A-tight-conditioning-fails.md Lemma 2.1 style, deterministic allocation)
    f2, c2 = expansion(d, r, alpha, np.tanh)
    w0n, An, _ = network(f2, c2, N, H, R)
    errs_n = noisy_errs(w0n, d, tau, r, reps, rng)
    print(f"d={d} n={n} H={H} gamma={gamma} N={N} alpha={alpha} R={R}: tau={tau:.3f} Pi*={Pi:.4f} A={A:.1f} "
          f"dropped-coef mass={dropped:.3f} kappa(w0)={energy(w0,d):.1f}  ROBUST: max|z-r| median={np.median(errs):.3f} max={errs.max():.3f}"
          f"  | NAIVE: median={np.median(errs_n):.3f}  | n={n}")
    sys.stdout.flush()

if __name__ == "__main__":
    for args in [(6, 64, 2, 1.0, 2000, 5.0, 5.0), (6, 64, 2, 1.0, 8000, 5.0, 5.0), (6, 64, 2, 1.0, 8000, 5.0, 10.0),
                 (6, 64, 2, 1.25, 8000, 5.0, 5.0), (6, 64, 2, 2.0, 4000, 5.0, 5.0),
                 (6, 64, 3, 1.0, 3000, 5.0, 3.0), (6, 64, 3, 1.0, 6000, 5.0, 3.0)]:
        run(*args, reps=6, seed=3)
