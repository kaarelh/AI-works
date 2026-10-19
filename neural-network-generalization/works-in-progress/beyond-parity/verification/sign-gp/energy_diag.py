"""Mechanism diagnostic (d=12, L=2, seed 0): Gaussian energy per distinct sample of
  (a) the regression interpolant of the +-1 labels:   y^T K_XX^{-1} y / s
  (b) the sign-posterior mean m_X = E[G_X | signs]:    m_X^T K_XX^{-1} m_X / s   (<= 1 by the paper's lemma)
together with the mean |m_X| and the projection of the cube-wide posterior mean / regression mean onto
the target (corr = E_x[f(x) m(x)]) and the posterior-mean amplitude on degree<=3 Fourier levels.
Writes energy_diag.json."""
import json, os, sys
import numpy as np
from scipy.linalg import cho_factor, cho_solve
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from common import cube, gram
from signgp import sample_signs, Predictor
import targets as T
from run_sweep import train_inputs

d, L, seed = 12, 2, 0
Xc = cube(d)
out = []
for n in (200, 800):
    idx = train_inputs(d, n, seed)
    KXX = gram(Xc[idx], Xc[idx], d, L)
    Kcx = gram(Xc, Xc[idx], d, L)
    P = Predictor(Kcx, KXX, idx)
    cf = cho_factor(KXX, lower=True)
    s = len(idx)
    for t in T.TARGETS:
        f = T.target_values(t, d)
        y = f[idx]
        rng = np.random.default_rng([n, T.TARGETS.index(t), 5])
        G, nb = sample_signs(KXX, y, n_keep=1500, burn=300, n_chains=2, rng=rng)
        mX = G.reshape(-1, s).mean(0)
        e_reg = float(y @ cho_solve(cf, y) / s)
        e_post = float(mX @ cho_solve(cf, mX) / s)
        # mean of per-sample energies (E ||xi||^2 / s, should be ~1 by the radius argument)
        Gs = G.reshape(-1, s)[::10]
        e_samp = float(np.mean(np.einsum("ij,ji->i", Gs, cho_solve(cf, Gs.T))) / s)
        m_cube = P.A @ mX
        r_cube = P.A @ y
        out.append(dict(n=n, n_distinct=s, target=t, energy_reg=e_reg, energy_postmean=e_post,
                        energy_samples=e_samp, mean_abs_mX=float(np.mean(np.abs(mX))),
                        corr_postmean=float(np.mean(f * m_cube)), corr_reg=float(np.mean(f * r_cube))))
        print(json.dumps({k: (round(v, 3) if isinstance(v, float) else v) for k, v in out[-1].items()}), flush=True)
json.dump(out, open(os.path.join(HERE, "energy_diag.json"), "w"), indent=1)
