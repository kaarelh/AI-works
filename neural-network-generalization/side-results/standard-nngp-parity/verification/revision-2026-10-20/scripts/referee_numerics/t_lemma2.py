# Lemma 2(b): P(sum mu_k Z_k^2 > s) <= exp(-(s - 2 log2 tr)/(4 mu_max)); exact for equal eigenvalues (chi2),
# exact numerical inversion (Imhof via characteristic function) for two-level spectra.
import numpy as np
from scipy.stats import chi2
from scipy.integrate import quad
L2 = np.log(2)
worst = -np.inf
for n in [1,2,3,5,10,30,100,1000,10000]:
    for x in np.linspace(2*L2+1e-6, 40, 4000):   # s = x * n (mu=1), bound nontrivial for s > 2log2 n
        s = x*n
        lp = chi2.logsf(s, n); lb = -(s-2*L2*n)/4
        worst = max(worst, lp-lb)
print("equal eigenvalues: max over grid of log P - log bound =", worst, "(must be <=0)")
# Imhof for spectrum: one eigenvalue 1, m eigenvalues eps
def imhof_sf(lams, s):
    lams = np.asarray(lams)
    def integrand(u):
        th = 0.5*np.sum(np.arctan(lams*u)) - 0.5*s*u
        rho = np.prod((1+(lams*u)**2)**0.25)
        return np.sin(th)/(u*rho)
    val, _ = quad(integrand, 0, np.inf, limit=2000)
    return 0.5 + val/np.pi
worst2 = -np.inf
for m, eps in [(10,0.1),(100,0.01),(100,0.1),(1000,0.001),(5,0.5)]:
    lams = np.r_[1.0, np.full(m, eps)]; tr = lams.sum()
    for s in np.linspace(2*L2*tr+0.1, 2*L2*tr+30, 60):
        p = imhof_sf(lams, s)
        if p > 1e-12:
            worst2 = max(worst2, np.log(p) + (s-2*L2*tr)/4)
print("two-level spectra (Imhof): max log P - log bound =", worst2)
# -log(1-x) <= 2 log2 x on [0,1/2]
xs = np.linspace(1e-12, 0.5, 10**6); print("max -log(1-x)-2log2 x on (0,1/2]:", np.max(-np.log1p(-xs)-2*L2*xs))
