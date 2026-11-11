"""In-situ test of Proposition 4.4 / Lemma 4.3 under the finite-scale prior, exact law on the cube.
Given layer l-1 activations on the M=2^d cube points, the layer-l noise rows are i.i.d. N(0, tau^2 G/N),
G = Gram matrix of h^{l-1} over cube points; we sample them by Cholesky in chunks (exact law), so only
per-layer sums and the M x M Gram matrix are stored.  Measured: |S-g_phi|, |q1-Eq1|, |q1-1|,
|hbar^l - psi(u_l)|, |q_l - Upsilon(u_l)|, readout noise, chain error |R hbar^H - Pi* S| vs Xi(observed),
and max|z - r|."""
import numpy as np, itertools, sys
from numpy.polynomial.hermite_e import hermegauss
xg, wg = hermegauss(100); wg = wg/np.sqrt(2*np.pi)
def cube(d): return np.array(list(itertools.product([-1.0, 1.0], repeat=d)))
def psi(u, q):  return np.tanh(np.asarray(u)[..., None] + np.sqrt(np.asarray(q))[..., None]*xg) @ wg
def ups(u, q):  return (np.tanh(np.asarray(u)[..., None] + np.sqrt(np.asarray(q))[..., None]*xg)**2) @ wg
def varpi(q):   return float((1/np.cosh(np.sqrt(q)*xg)**2) @ wg)
def Fq(q):      return float((np.tanh(np.sqrt(q)*xg)**2) @ wg)
def pistar(H, tau):
    q, P = 1.0, 1.0
    for l in range(1, H): P *= varpi(tau**2*q); q = Fq(tau**2*q)
    return P
def expansion(d, target, alpha, act):
    X = cube(d); feats = [np.r_[alpha, np.zeros(d)]]; coefs = [target.mean()/float(act(np.array(alpha)))]
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

CH = 200000
def run(d, n, H, gamma, N, alpha, R, seed):
    rng = np.random.default_rng(seed); M = 2**d; X = cube(d); Xb = np.hstack([np.ones((M, 1)), X])
    idx = rng.integers(0, M, n); y = rng.choice([-1.0, 1.0], n)
    r = np.zeros(M); cnt = np.zeros(M); np.add.at(r, idx, y); np.add.at(cnt, idx, 1); r[cnt > 0] /= cnt[cnt > 0]
    tau = N**((1-gamma)/2); s1 = tau*np.sqrt((d+1)/d)
    phi1 = lambda u: psi(u, np.full(np.shape(u), s1**2))
    Pi = pistar(H, tau)
    feats, coefs = expansion(d, r/Pi, alpha, phi1)
    A = np.abs(coefs).sum()
    nj = np.floor(N*np.abs(coefs)/A).astype(np.int64); rem = N - nj.sum()
    order = np.argsort(-(N*np.abs(coefs)/A - nj)); nj[order[:rem]] += 1
    keep = nj > 0
    rows = feats[keep]*np.sign(coefs[keep])[:, None]; gam = np.abs(coefs[keep]); nk = nj[keep]
    P1 = Xb @ rows.T                                   # (M, J) noiseless preactivations
    g_phi = phi1(P1) @ gam                             # E S
    Eq1 = (ups(P1, np.full(P1.shape, s1**2)) @ nk)/N
    # layer 1, exact: for each unique row j, n_j neurons with i.i.d. N(0, s1^2) noise (same across x? no:
    # the noise is (tau/sqrt d) nu.xbar, a Gaussian vector over x with covariance s1^2 * (Xb Xb^T)/(d+1))
    Cx = np.linalg.cholesky((Xb @ Xb.T)/(d+1)*s1**2 + 1e-12*np.eye(M))
    S = np.zeros(M); sq = np.zeros(M); G = np.zeros((M, M))
    for j in range(len(nk)):
        left = int(nk[j])
        while left > 0:
            m = min(left, CH); left -= m
            hh = np.tanh(P1[:, j][None, :] + rng.standard_normal((m, M)) @ Cx.T)   # (m, M)
            S += (gam[j]/nk[j])*hh.sum(0); sq += (hh**2).sum(0); G += hh.T @ hh
    q1 = sq/N
    devS = np.abs(S - g_phi).max(); devq1 = np.abs(q1 - Eq1).max(); varphi = np.abs(q1 - 1).max()
    u = S/R**(H-1); q = q1; hm, qd = [], []
    for l in range(2, H+1):
        Cch = np.linalg.cholesky(G + 1e-9*np.eye(M))*(tau/np.sqrt(N))
        hs = np.zeros(M); sq = np.zeros(M); Gn = np.zeros((M, M)); left = N
        while left > 0:
            m = min(left, CH); left -= m
            hh = np.tanh(u[None, :] + rng.standard_normal((m, M)) @ Cch.T)
            hs += hh.sum(0); sq += (hh**2).sum(0); Gn += hh.T @ hh
        hbar = hs/N; ql = sq/N
        hm.append(np.abs(hbar - psi(u, tau**2*q)).max())
        if l <= H-1: qd.append(np.abs(ql - ups(u, tau**2*q)).max())
        u = R*hbar; q = ql; G = Gn
    out_noise = (np.linalg.cholesky(G + 1e-9*np.eye(M)) @ rng.standard_normal(M))*(tau/N)
    z = u + out_noise
    u0 = max(hm + qd); Sbar = max(1.0, np.abs(S).max())
    fbar = varphi + H*(u0 + 4*Sbar**2/R**2)
    Xi = 2*R**(H-1)*u0 + 2*H*Sbar*fbar + 16*Sbar**3/(3*R**2)
    chain = np.abs(u - Pi*S).max()
    ld = (d+1)*np.log(2) + np.log(8*H)
    print(f"H={H} g={gamma} N={N:>8} R={R:>4}: Pi*={Pi:.3f} A={A:.1f} Sbar={Sbar:.2f} | dS={devS:.1e} dq1={devq1:.1e} |q1-1|={varphi:.1e} "
          f"dhbar={max(hm):.1e} dq={max(qd) if qd else 0:.1e} [sqrt(2ld/N)={np.sqrt(2*ld/N):.1e}] out={np.abs(out_noise).max():.1e} | "
          f"chain={chain:.4f} Xi={Xi:.3f} {'OK' if (Xi <= 1 and chain <= Xi) else ('VIOLATION' if Xi <= 1 else 'Xi>1')} | max|z-r|={np.abs(z-r).max():.4f}")
    sys.stdout.flush()

for (H, gamma, R, Ns) in [(2, 1.0, 5.0, [10**4, 10**5, 10**6]), (2, 1.0, 40.0, [10**5, 10**6, 10**7]),
                          (3, 1.0, 4.0, [10**4, 10**5, 10**6]), (3, 1.0, 30.0, [10**6, 10**7]),
                          (2, 1.25, 40.0, [10**5, 10**6]), (3, 2.0, 30.0, [10**5, 10**6])]:
    for N in Ns:
        run(6, 64, H, gamma, N, 5.0, R, seed=11)
