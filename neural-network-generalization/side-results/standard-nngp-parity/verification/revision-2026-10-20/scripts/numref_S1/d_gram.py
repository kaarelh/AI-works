"""Monte Carlo check of Prop 4.2 and Lemma 4.3 (tail Gram bound), including adversarial spectra."""
import numpy as np, math, sys
from scipy.linalg import eigh
rng = np.random.default_rng(7)

def kraw(d):
    # K[q,h] = sum_{|U|=q} chi_U(x)chi_U(y) for hamming distance h
    K = np.zeros((d+1, d+1))
    for q in range(d+1):
        for h in range(d+1):
            K[q, h] = sum((-1)**i*math.comb(h, i)*math.comb(d-h, q-i) for i in range(0, q+1))
    return K

def lmax(Mx):
    if Mx.shape[0] <= 300:
        return np.linalg.eigvalsh(Mx)[-1]
    from scipy.sparse.linalg import eigsh
    return eigsh(Mx, k=1, which='LA', tol=1e-8)[0][0]

def gram_test(d, lam, r, ns, trials, label):
    K = kraw(d)
    Qh = (lam[r+1:, None]*K[r+1:, :]).sum(0)   # Q_r as function of hamming distance
    tau = sum(math.comb(d, q)*lam[q] for q in range(r+1, d+1))
    assert abs(Qh[0]-tau) < 1e-9*tau
    l1 = lam[r+1]
    out = []
    for n in ns:
        vals = []
        for t in range(trials):
            X = rng.integers(0, 2, size=(n, d)).astype(np.int8)
            H = (X[:, None, :] != X[None, :, :]).sum(2) if n <= 600 else None
            if H is None:
                Xf = (1-2*X).astype(np.float32); H = ((d - Xf@Xf.T)/2).round().astype(int)
            vals.append(lmax(Qh[H]))
        Em = np.mean(vals); se = np.std(vals)/math.sqrt(trials)
        b1 = (math.e-1)*n*l1 + tau*math.log(tau/l1)
        # best theta version of Prop 4.2
        th = np.linspace(0.01, 6, 600)
        bth = np.min((np.exp(th)-1)/th*n*l1 + tau/th*math.log(tau/l1))
        out.append((n, Em/tau, se/tau, b1/tau, bth/tau))
        flag = 'VIOL' if Em - 3*se > bth else ''
        print(f'  [{label}] d={d} r={r} n={n}: E||Q||/tau={Em/tau:.4f}+-{se/tau:.4f}  bound(theta=1)/tau={b1/tau:.4f}  best-theta/tau={bth/tau:.4f}  intdim={tau/l1:.1f} {flag}')
    return out

def prop42_generic():
    print('Prop 4.2 on generic ensembles (min over theta of bound vs Monte Carlo):')
    th = np.linspace(0.005, 8, 1600)
    def bnd(mu, L, idim):
        return np.min((np.exp(th)-1)/th*mu + L/th*np.log(idim))
    # (1) balls in bins, nonuniform
    for N, n, eps in [(2, 1, 0.5), (2, 3, 0.5), (50, 1, 0.98), (50, 5, 0.9), (1000, 1000, 1.0), (10, 2, 0.6), (3, 1, 1.0)]:
        pis = np.full(N, (1-eps)/(N-1)) if N > 1 else np.ones(1)
        if eps < 1: pis[0] = eps
        else: pis = np.full(N, 1/N)
        tr = 20000 if n < 50 else 2000
        mx = np.array([np.bincount(rng.choice(N, n, p=pis), minlength=N).max() for _ in range(tr)])
        mu = n*pis.max(); idim = pis.sum()/pis.max()
        b = bnd(mu, 1.0, idim)
        print(f'  bins N={N} n={n} p0={pis[0]:.3f}: E max={mx.mean():.4f}+-{mx.std()/math.sqrt(tr):.4f}  bound={b:.4f} {"VIOL" if mx.mean()-3*mx.std()/math.sqrt(tr) > b else ""}')
    # (2) rank-one random directions with anisotropic covariance
    for N, n, decay in [(5, 1, 0.5), (5, 2, 0.1), (20, 3, 0.3), (20, 20, 0.9), (3, 1, 0.01)]:
        s = decay**np.arange(N); s = s/s.max()
        tr = 4000; vals = []
        for _ in range(tr):
            Y = np.zeros((N, N))
            for k in range(n):
                g = rng.normal(size=N)*np.sqrt(s); u = g/np.linalg.norm(g)  # unit vectors, L=1
                Y += np.outer(u, u)
            vals.append(np.linalg.eigvalsh(Y)[-1])
        # E uu^T estimated by MC (exact not closed form): use large sample
        G = rng.normal(size=(200000, N))*np.sqrt(s); U = G/np.linalg.norm(G, axis=1, keepdims=True)
        EM = n*(U.T@U)/len(U); ev = np.linalg.eigvalsh(EM)
        b = bnd(ev[-1], 1.0, ev.sum()/ev[-1])
        print(f'  rank1 N={N} n={n} decay={decay}: E lmax={np.mean(vals):.4f}  bound={b:.4f}  {"VIOL" if np.mean(vals) > b else ""}')

if __name__ == '__main__':
    prop42_generic()
    sys.path.insert(0, '.')
    from b_cube import composite, levels
    for d in [8, 10, 12]:
        D = d+1
        F, A, gam, _ = composite((1.0, 1.0), 600)
        W = levels(F, D)
        a = [W[j]/math.comb(D, j) for j in range(D+1)]
        lam = np.array([A*(a[q]+a[q+1]) for q in range(d+1)])
        for r in [1, 3, 5]:
            gram_test(d, lam, r, [1, 2, 5, 50, 400, 1500], 30 if d < 12 else 16, 'tanh(1,1)')
    # adversarial spectra (nonincreasing): flat, steep geometric, one-step
    d = 10
    specs = {
        'flat': np.ones(d+1),
        'geom1e-2': 1e-2**np.arange(d+1),
        'step': np.array([1.0]*4 + [1e-6]*(d-3)),
        'topheavy': np.array([1.0]*(d) + [0.999]),
    }
    for nm, lam in specs.items():
        for r in [0, 2, 5, 8, 9]:
            gram_test(d, lam, r, [1, 2, 10, 300, 1500], 24, nm)
