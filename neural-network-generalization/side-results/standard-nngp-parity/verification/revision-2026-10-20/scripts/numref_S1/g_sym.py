"""Restriction lemma (2.1) and Cor 2.3 for symmetric h at large d (exact level sums)."""
import numpy as np, math
from scipy.special import gammaln
from scipy.stats import binom

def beta_ub(j, m):
    if j >= m: return 1.0
    t = (m-j-1)//2
    return 1.0-float(binom.cdf(t, m, 0.5))

def kraw_norm(d, wmax, s):
    # normalized Krawtchouk k_w(s)=K_w(s)/sqrt(C(d,w)), recurrence (w+1)K_{w+1}=(d-2s)K_w-(d-w+1)K_{w-1}
    K = np.zeros((wmax+1, len(s))); K[0] = 1.0
    if wmax >= 1: K[1] = d-2*s
    for w in range(1, wmax):
        K[w+1] = ((d-2*s)*K[w] - (d-w+1)*K[w-1])/(w+1)
    lc = np.array([0.5*(gammaln(d+1)-gammaln(w+1)-gammaln(d-w+1)) for w in range(wmax+1)])
    return K/np.exp(lc)[:, None]

def test(d, u, mode, rng):
    s = np.arange(d+1); P = binom.pmf(s, d, 0.5)
    par = (-1.0)**s
    c = d/2
    if mode == 'abfr':
        mid = np.sort(np.argsort(np.abs(s-c))[:u+1]); roots = (mid[:-1]+mid[1:])/2
        h = np.ones(d+1)
        for r0 in roots: h = h*(s-r0)/math.sqrt(d)
        h *= np.sign(h[mid[0]])*par[mid[0]]
    else:
        al = rng.normal(size=u+1); al[0] *= rng.choice([0, 1, 3])
        h = al@kraw_norm(d, u, s)
    kn = kraw_norm(d, u+2, s)
    alpha = (kn*(h*P)[None, :]).sum(1)          # coefficients in orthonormal basis (exact for deg<=u)
    W2 = np.zeros(d+1); W2[:u+3] = alpha**2      # W2[w] = sum_{|U|=w} hat h(U)^2
    recon = alpha@kn
    err = np.max(np.abs(recon-h)*np.sqrt(P))/max(1e-300, np.sqrt((h**2*P).sum()))
    fh = par*h
    out = []
    for q in [0.0, 0.3, 0.6]:
        pos = fh[(fh > 0) & (P > 1e-30)]
        if len(pos) == 0: continue
        a = np.quantile(pos, q)
        lhs = P[fh >= a].sum()
        R = W2[1:].sum()/a**2
        rho = u/d
        cor = min(0.5+math.e*math.sqrt(J*rho/math.pi)+0.5*math.exp(-J/(8*math.e**2*rho))+R*math.exp(-J)
                  for J in range(1, int(math.e**2*u)+1))
        best = np.inf
        ms = np.arange(d+1)
        for p in np.concatenate([np.geomspace(1e-3, 1, 40)]):
            pm = binom.pmf(ms, d, p)
            for j in range(0, min(d, 3*u+40)):
                b = sum(pm[m]*beta_ub(j, m) for m in range(d+1) if pm[m] > 1e-16) + pm[pm <= 1e-16].sum()
                tail = sum(W2[w]*binom.sf(j, w, p) for w in range(1, u+3))/a**2
                best = min(best, b+tail)
        out.append((a, lhs, best, cor))
    return err, out

if __name__ == '__main__':
    rng = np.random.default_rng(3)
    worst = np.inf; worstc = np.inf
    for d in [60, 200, 600]:
        for u in [1, 2, 3, 5, 8, 12]:
            for mode in ['abfr', 'rand', 'rand']:
                err, out = test(d, u, mode, rng)
                for a, lhs, best, cor in out:
                    worst = min(worst, best-lhs); worstc = min(worstc, cor-lhs)
                    if best < lhs or cor < lhs:
                        print('VIOLATION', d, u, mode, a, lhs, best, cor)
                print(f'd={d} u={u} {mode}: recon err={err:.1e} ' + ' '.join(f'[LHS={l:.4f} RHS2.1={b:.4f} Cor={c:.3f}]' for _, l, b, c in out))
    print('min slack (2.1):', worst, ' min slack Cor2.3:', worstc)
