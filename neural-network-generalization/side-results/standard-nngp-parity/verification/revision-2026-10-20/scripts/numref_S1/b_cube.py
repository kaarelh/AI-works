"""Composite tanh coefficients, Ehrenfest level masses, cube transfer (Lemma 3.3), (1.1), Lemma 4.4.
Plus an explicit-kernel spectrum check at d=8 (independent of the walk representation)."""
import numpy as np, mpmath as mp, itertools, math, sys
from a_tanh import logI, v_of
from scipy import special
mp.mp.dps = 30

def tanh_coefs(q, mmax):
    sig = math.sqrt(q)
    v = float(v_of(sig))
    c = np.zeros(mmax+1)
    for m in range(1, mmax+1, 2):
        c[m] = math.exp(2*m*math.log(sig) + 2*logI(m, sig) - special.gammaln(m+1) - math.log(v))
    return c, v

def compose(g, h, mmax):
    # (g o h) truncated at mmax; h[0]=0, all nonneg
    out = np.zeros(mmax+1); p = np.zeros(mmax+1); p[0] = 1.0
    for k in range(0, mmax+1):
        if k > 0:
            p = np.convolve(p, h)[:mmax+1]
        if g[k] != 0:
            out += g[k]*p
        if not p.any(): break
    return out

def composite(gains, mmax):
    q = gains[0]**2
    c, v = tanh_coefs(q, mmax)
    gam = 1/(6*(1+math.pi/(2*gains[0]))**4)
    F = c.copy(); layers = [c]
    for s in gains[1:-1]:
        q = s**2*v
        c2, v = tanh_coefs(q, mmax)
        layers.append(c2)
        F = compose(c2, F, mmax)
    A = gains[-1]**2*v
    return F, A, gam, layers

def levels(F, D):
    mmax = len(F)-1
    P = np.zeros(D+1); P[0] = 1.0
    W = np.zeros(D+1)
    i = np.arange(D+1)
    W += F[0]*P
    for m in range(1, mmax+1):
        newP = np.zeros(D+1)
        newP[1:] += P[:-1]*(D-i[:-1])/D
        newP[:-1] += P[1:]*i[1:]/D
        P = newP
        if F[m] > 0: W += F[m]*P
    return W

def logbinom(n, k):
    return special.gammaln(n+1)-special.gammaln(k+1)-special.gammaln(n-k+1)

def run(gains, Ds, mmax):
    F, A, gam, _ = composite(gains, mmax)
    tail = max(0.0, 1-F.sum())
    odd = F[1::2]
    m = np.arange(1, mmax+1, 2)
    viol32 = np.min(F[3::2]/F[1:-2:2]) / gam
    viol32b = np.min(F[1::2]/(gam**((m-1)/2)*F[1]))
    print(f'gains={gains}: sumF={F.sum():.15f} tail~{tail:.1e} gamma={gam:.3e} min c_(m+2)/(gamma c_m)={viol32:.4f} min c_m/(gamma^((m-1)/2)c1)={viol32b:.3e}')
    for D in Ds:
        d = D-1
        W = levels(F, D)
        # truncation error bound on W_j: tail * max over m>mmax of P(zeta_m=j) <= tail (crudely)
        worst_a = np.inf; worst_a_j = None
        for j in range(1, D-1, 2):
            if W[j] <= 0: continue
            rhs = gam*(D-j)*(D-j-1)/D**2*W[j]
            if W[j+2] < 1e3*tail: continue   # unreliable because of truncation
            ratio = W[j+2]/rhs
            if ratio < worst_a: worst_a, worst_a_j = ratio, j
        T = {}
        for r in range(1, d, 2):
            T[r] = W[r+2::2].sum()
        worst_b = 0; worst_b_r = None; worst_ratio = 0
        for r in range(1, d, 2):
            if r+3 <= D/2 and r+2 in T:
                ratio = T[r]/T[r+2]
                worst_ratio = max(worst_ratio, ratio)
                if ratio/(1+4/gam) > worst_b: worst_b, worst_b_r = ratio/(1+4/gam), r
        # Lemma 4.4: binom(D,r+2) <= tau_r/lambda_{r+1} = binom(D,r+2) T_r/W_{r+2} <= D^{r+2}/((r+2)! c_{r+2})
        worst44 = -np.inf; worst44low = np.inf; worst_log = -np.inf
        for r in range(1, d, 2):
            if r+2 > mmax or W[r+2] < 1e3*tail: continue
            lg_intdim = logbinom(D, r+2) + math.log(T[r]) - math.log(W[r+2])
            lg_ub = (r+2)*math.log(D) - special.gammaln(r+3) - math.log(F[r+2])
            worst44 = max(worst44, lg_intdim - lg_ub)
            worst44low = min(worst44low, lg_intdim - logbinom(D, r+2))
            Hr = math.log(math.e*D/r)
            claim = (3+math.log(1/gam))*r*Hr + math.log(1/F[1])
            worst_log = max(worst_log, lg_intdim - claim)
        print(f'  D={D}: min W_(j+2)/[gamma(D-j)(D-j-1)/D^2 W_j]={worst_a:.4f} (j={worst_a_j}); '
              f'max tau_r/tau_(r+2)={worst_ratio:.3f} (bound {1+4/gam:.1f}); '
              f'L4.4: max log(intdim/UB)={worst44:.3f}, min log(intdim/binom)={worst44low:.3f}, max(log intdim - (3+log1/g) r H_r - log1/c1)={worst_log:.2f}')
    return F, A

def spectrum_check(gains, d, mmax=400):
    D = d+1
    F, A, gam, layers = composite(gains, mmax)
    W = levels(F, D)
    a = np.array([W[j]/math.comb(D, j) for j in range(D+1)])
    lam_formula = np.array([A*(a[q]+a[q+1]) if q+1 <= D else A*a[q] for q in range(d+1)])
    # explicit kernel by Gaussian quadrature of each layer's dual (independent of series)
    gh_x, gh_w = np.polynomial.hermite_e.hermegauss(120)
    gh_w = gh_w/gh_w.sum()
    def dual(q, rho):
        s = math.sqrt(q)
        U = gh_x[:, None]; Z = gh_x[None, :]
        V = rho*U + math.sqrt(max(0, 1-rho*rho))*Z
        return (gh_w[:, None]*gh_w[None, :]*np.tanh(s*U)*np.tanh(s*V)).sum()
    # distinct values of x.y: d-2h
    q = gains[0]**2; qs = [q]
    vs = []
    for s in gains[1:]:
        v = float(np.sum(gh_w*np.tanh(math.sqrt(qs[-1])*gh_x)**2)); vs.append(v)
        qs.append(s**2*v)
    Aq = gains[-1]**2*vs[-1]
    kval = {}
    for h in range(d+1):
        rho = (1+d-2*h)/D
        for ql, vl in zip(qs[:-1], vs):
            rho = dual(ql, rho)/vl
        kval[h] = Aq*rho
    # eigenvalue on chi_U with |U|=k: sum_y K(0,y) chi_U(y) / M ... K(x,y) depends on hamming h
    # lambda_k = 2^{-d} sum_h binom-weighted K(h) Krawtchouk_k(h)
    lam_direct = []
    for k in range(d+1):
        tot = 0.0
        for h in range(d+1):
            kr = sum((-1)**i*math.comb(h, i)*math.comb(d-h, k-i) for i in range(0, k+1))
            tot += math.comb(d, h)*kval[h]*kr / math.comb(d, k)
        lam_direct.append(tot/2**d)
    lam_direct = np.array(lam_direct)
    print(f'spectrum d={d} gains={gains}: A formula {A:.12f} vs quad {Aq:.12f}; max rel diff lambda {np.max(np.abs(lam_direct/lam_formula-1)):.2e}')
    print('   lambda_q:', np.array2string(lam_formula, precision=4))

if __name__ == '__main__':
    for g, d in [((1.0, 1.0), 8), ((0.5, 2.0), 9), ((1.0, 3.0, 1.0), 8), ((2.0, 0.5, 1.5), 9)]:
        spectrum_check(g, d)
    mmax = int(sys.argv[1]) if len(sys.argv) > 1 else 1000
    configs = [(0.2, 1.0), (0.5, 1.0), (1.0, 1.0), (3.0, 1.0), (8.0, 1.0), (1.0, 1.0, 1.0), (0.3, 3.0, 1.0),
               (3.0, 0.3, 1.0), (1.0, 1.0, 1.0, 1.0), (0.5, 2.0, 2.0, 1.0)]
    for g in configs:
        run(g, [41, 101, 201, 301], mmax)
