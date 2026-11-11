"""E-finite-prior-scale.md Lemma 4.3 (noisy chain): random and sign-adversarial perturbation sequences satisfying the
hypotheses; check |R hbar^H - Pi* S| <= Xi."""
import numpy as np
from numpy.polynomial.hermite_e import hermegauss
xg, wg = hermegauss(150); wg = wg/np.sqrt(2*np.pi)
psi = lambda u, q: np.sum(wg*np.tanh(u + np.sqrt(q)*xg))
ups = lambda u, q: np.sum(wg*np.tanh(u + np.sqrt(q)*xg)**2)
varpi = lambda q: np.sum(wg/np.cosh(np.sqrt(q)*xg)**2)
F = lambda q: ups(0.0, q)
rng = np.random.default_rng(7)
worst_ratio = 0.0; count = 0
for H in [2, 3, 4]:
    for tau in [1.0, 0.6, 0.2]:
        qs = [1.0]
        for l in range(1, H-1): qs.append(F(tau**2*qs[-1]))
        Pi = np.prod([varpi(tau**2*q) for q in qs[:H-1]])
        for R in [2.0, 4.0, 10.0, 20.0, 50.0]:
            for Sbar in [1.25, 2.0]:
                for (u0, phi) in [(1e-5, 1e-4), (1e-4, 1e-3), (1e-3, 1e-3), (1e-2, 5e-3), (3e-2, 2e-2)]:
                    fbar = phi + H*(u0 + 4*Sbar**2/R**2)
                    Xi = 2*R**(H-1)*u0 + 2*H*Sbar*fbar + 16*Sbar**3/(3*R**2)
                    if Xi > 1: continue
                    for trial in range(40):
                        S = rng.uniform(-Sbar, Sbar)
                        mode = trial % 3   # 0 random, 1 all +, 2 all -
                        sgn = (lambda: rng.uniform(-1, 1)) if mode == 0 else ((lambda: 1.0) if mode == 1 else (lambda: -1.0))
                        q = 1.0 + phi*sgn() if mode != 0 else 1.0 - phi*rng.uniform(0, 1)
                        q = min(max(q, 0.0), 1.0)
                        u = S/R**(H-1)
                        for l in range(2, H+1):
                            hbar = psi(u, tau**2*q) + u0*sgn()
                            if l <= H-1:
                                qn = ups(u, tau**2*q) + u0*sgn(); qn = min(max(qn, 0.0), 1.0)
                            u_next = R*hbar
                            if l <= H-1: q = qn
                            u = u_next
                        err = abs(u - Pi*S)
                        worst_ratio = max(worst_ratio, err/Xi); count += 1
print(f"checked {count} chains; max err/Xi = {worst_ratio:.4f} (claim <= 1)")
