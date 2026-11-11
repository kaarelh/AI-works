"""E-finite-prior-scale.md Lemma 3.1 (gamma>1): for prior perturbations xi in the typical event E,
sup_cube |z_{w0+D xi} - z_{w0}| <= (3H+2) K0^{H/2} N^{(1-gamma)/2}.
We take w0 = balanced clone of a random width-3 teacher (weights <= B) and check the bound,
the typical-event radii, and that the observed deviation scales like N^{(1-gamma)/2}."""
import numpy as np
from nets import *
rng = np.random.default_rng(1)
d = 6; X = cube(d)
for H in [2, 3]:
    L = H+1
    C, B = 3, 1.5
    U1 = rng.uniform(-B, B, (C, d+1)); Us = [rng.uniform(-B, B, (C, C)) for _ in range(H-1)]; u = rng.uniform(-B, B, C)
    for N in [60, 240, 960]:
        k = np.full(C, N//C); k[:N % C] += 1
        grp = np.repeat(np.arange(C), k)
        W1 = U1[grp]
        Ws = [U[np.ix_(grp, grp)]/k[grp][None, :] for U in Us]
        v = u[grp]/k[grp]
        w0 = (W1, Ws, v)
        z0 = forward(w0, X)
        K0 = max(1.0, energy(w0, d))
        t = np.sqrt(2*np.log(2*L))
        Nmin = (np.sqrt(d+1)+t)**2
        for gamma in [1.5, 2.0, 3.0]:
            bound = (3*H+2)*K0**(H/2)*N**((1-gamma)/2)
            devs = []; inE = 0
            for rep in range(20):
                w, (xi1, Zs, zeta) = perturb(w0, d, gamma, rng)
                ok = (np.linalg.norm(xi1, 2) <= np.sqrt(N)+np.sqrt(d+1)+t) and \
                     all(np.linalg.norm(Z, 2) <= 2*np.sqrt(N)+t for Z in Zs) and \
                     (np.linalg.norm(zeta) <= np.sqrt(N)+t)
                inE += ok
                devs.append(np.abs(forward(w, X)-z0).max())
            devs = np.array(devs)
            print(f"H={H} N={N} (N>=Nmin={Nmin:.1f}: {N>=Nmin}) gamma={gamma}: K0={K0:.2f}, frac in E={inE/20:.2f}, "
                  f"max dev={devs.max():.4f}, bound={bound:.4f}, dev*N^((g-1)/2)={devs.mean()*N**((gamma-1)/2):.3f}")
