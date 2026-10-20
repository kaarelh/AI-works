"""Monte Carlo check of Lemma 5.1 (i),(ii),(iii),(v) and Lemma 6.2 on small cubes with tanh kernel."""
import numpy as np, math, sys
from scipy.stats import norm
sys.path.insert(0, '.')
from b_cube import composite, levels
from d_gram import kraw
rng = np.random.default_rng(11)
theta = 13/20; cth = math.sqrt(2*math.pi)*(math.exp(-1)-0.35)

def setup(d, gains):
    D = d+1
    F, A, gam, _ = composite(gains, 500)
    W = levels(F, D)
    a = [W[j]/math.comb(D, j) for j in range(D+1)]
    lam = np.array([A*(a[q]+a[q+1]) for q in range(d+1)])
    Kr = kraw(d)
    X = 1-2*((np.arange(2**d)[:, None] >> np.arange(d)[None, :]) & 1)
    H = (X[:, None, :] != X[None, :, :]).sum(2)
    Kh = (lam[:, None]*Kr).sum(0)
    K = Kh[H]
    f = np.prod(X, 1)
    return lam, Kr, X, H, K, f

def run(d, gains, n, trials, nsamp):
    lam, Kr, X, H, K, f = setup(d, gains)
    M = 2**d
    Kinv = np.linalg.inv(K)
    worst = {'i': -np.inf, 'ii': np.inf, 'iii': -np.inf, 'v': -np.inf, '62': np.inf, 'mm': -np.inf}
    for t in range(trials):
        idx = rng.integers(0, M, size=n)
        Sp = np.unique(idx); s = len(Sp)
        KS = K[np.ix_(Sp, Sp)]; L = np.linalg.cholesky(KS)
        acc = []
        while sum(len(a) for a in acc) < nsamp:
            Z = rng.normal(size=(200000, s))@L.T
            ok = np.all(f[Sp][None, :]*Z > 0, axis=1)
            acc.append(Z[ok])
        G = np.vstack(acc)[:nsamp]
        mS = G.mean(0)
        B = K[:, Sp]@np.linalg.inv(KS)          # regression coefficients
        mfull = B@mS
        sig2 = np.diag(K) - np.einsum('ij,ij->i', B, K[:, Sp])
        sig = np.sqrt(np.maximum(sig2, 1e-300))
        # q_S(x) = E Phi(f(x) mu_x / sig_x)
        mu = G@B.T                                # nsamp x M
        with np.errstate(divide='ignore', invalid='ignore'):
            q = np.where(sig[None, :] > 1e-9, norm.cdf(f[None, :]*mu/sig[None, :]), (f[None, :]*mu > 0).astype(float)).mean(0)
            # mean vs "median" claim: Pr{Y>mu}<=1-1/e  where Y=f G(x)
            pYgt = np.where(sig[None, :] > 1e-9, norm.sf(f[None, :]*(mfull[None, :]-mu)/sig[None, :]), 0).mean(0)
        # (i)
        nk = mfull@Kinv@mfull
        worst['i'] = max(worst['i'], nk - s)
        # (ii) q> theta => f m > cth sigma_x  (only meaningful when sig>0)
        sel = (q > theta) & (sig > 1e-6)
        if sel.any(): worst['ii'] = min(worst['ii'], np.min(f[sel]*mfull[sel] - cth*sig[sel]))
        worst['mm'] = max(worst['mm'], pYgt[sig > 1e-6].max() - (1-math.exp(-1)))
        for v in range(0, d-1):
            tau = sum(math.comb(d, qq)*lam[qq] for qq in range(v+1, d+1))
            # (iii)
            lhs = np.mean(sig2 < tau/2); rhs = 2*s*lam[v+1]/tau
            worst['iii'] = max(worst['iii'], lhs - rhs)
            # (v)
            Qh = (lam[v+1:, None]*Kr[v+1:, :]).sum(0)
            QSS = Qh[H[np.ix_(idx, idx)]]
            # m_{>v} via Walsh projection: m_{>v} = Q_v(.,S') alpha
            alpha = np.linalg.solve(KS, mS)
            mhi = Qh[H[:, Sp]]@alpha
            lhs5 = np.mean(mhi[idx]**2); rhs5 = s/n*np.linalg.eigvalsh(QSS)[-1]
            worst['v'] = max(worst['v'], lhs5 - rhs5)
            # Lemma 6.2: F_theta >= err_v(f) - C0 n lam_{v+1}/tau ; err_v(f) >= ABFR lower bound
            t_ = (d-v-1)//2
            err_lb = sum(math.comb(d, i) for i in range(t_+1))/2**d
            Fth = np.mean(q <= theta)
            C0 = 2+2/cth**2
            worst['62'] = min(worst['62'], Fth - (err_lb - C0*n*lam[v+1]/tau))
    print(f'd={d} gains={gains} n={n}: max(||m||_K^2 - s)={worst["i"]:.3e}; min over q>theta of (fm - c sigma)={worst["ii"]:.3e}; '
          f'max(Pr{{Y>mu}}-(1-1/e))={worst["mm"]:.3e}; max (iii) lhs-rhs={worst["iii"]:.3e}; max (v) lhs-rhs={worst["v"]:.3e}; min L6.2 slack={worst["62"]:.3e}')

if __name__ == '__main__':
    for d, g, n in [(6, (3.0, 1.0), 5), (6, (1.0, 1.0, 1.0), 4), (7, (3.0, 2.0), 4), (5, (1.0, 1.0), 6)]:
        run(d, g, n, 6, 60000)
