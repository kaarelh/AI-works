"""Lemma 4.3 (noisy chain): maximise |R hbar^H - Pi* S| / Xi over all admissible perturbation
sequences (q1 in [1-phi,1], each hbar/q deviation in [-u0,u0], S in [-Sbar,Sbar]) with
differential evolution, for several (H, tau, R, u0, phi).  Psi, Upsilon, varpi by Gauss-Hermite (200 nodes)."""
import numpy as np
from numpy.polynomial.hermite_e import hermegauss
from scipy.optimize import differential_evolution
xg, wg = hermegauss(200); wg = wg/np.sqrt(2*np.pi)
psi = lambda u, q: np.dot(wg, np.tanh(u + np.sqrt(max(q,0))*xg))
ups = lambda u, q: np.dot(wg, np.tanh(u + np.sqrt(max(q,0))*xg)**2)
varpi = lambda q: np.dot(wg, 1/np.cosh(np.sqrt(max(q,0))*xg)**2)
F = lambda q: ups(0.0, q)

def run_chain(z, H, tau, R, u0, phi, Sbar):
    # z = [S/Sbar, q1 frac, dh_2..dh_H, dq_2..dq_{H-1}] all in [-1,1]
    S = z[0]*Sbar
    q = 1.0 - phi*(z[1]+1)/2
    dh = z[2:2+H-1]; dq = z[2+H-1:]
    u = S/R**(H-1)
    for l in range(2, H+1):
        hbar = psi(u, tau**2*q) + u0*dh[l-2]
        if l <= H-1:
            q = min(max(ups(u, tau**2*q) + u0*dq[l-2], 0.0), 1.0)
        u = R*hbar
    return u, S

worst_all = 0
for H in [2, 3, 4]:
    for tau in [1.0, 0.5]:
        qs = [1.0]
        for l in range(1, H-1): qs.append(F(tau**2*qs[-1]))
        Pi = np.prod([varpi(tau**2*q) for q in qs[:H-1]])
        for (R, Sbar) in [(2.0, 1.0), (4.0, 1.0), (10.0, 1.0), (20.0, 1.25), (40.0, 1.982), (80.0, 3.25)]:
            for (u0, phi) in [(1e-5, 1e-4), (1e-4, 1e-3), (1e-3, 5e-3), (5e-3, 2e-2)]:
                fbar = phi + H*(u0 + 4*Sbar**2/R**2)
                Xi = 2*R**(H-1)*u0 + 2*H*Sbar*fbar + 16*Sbar**3/(3*R**2)
                if Xi > 1: continue
                dim = 2 + (H-1) + (H-2)
                obj = lambda z: -abs(run_chain(z, H, tau, R, u0, phi, Sbar)[0] - Pi*run_chain(z, H, tau, R, u0, phi, Sbar)[1])/Xi
                res = differential_evolution(obj, [(-1, 1)]*dim, seed=0, maxiter=120, tol=1e-10, polish=True)
                ratio = -res.fun
                worst_all = max(worst_all, ratio)
                print(f"H={H} tau={tau} R={R} u0={u0} phi={phi}: Xi={Xi:.3f}  max |R hbar^H - Pi* S|/Xi = {ratio:.4f}")
print("overall worst ratio:", worst_all, "(Lemma 4.3 claims <= 1)")
