"""Sanity check (not a proof) of the intrinsic-dimension expectation bounds of Remark 8.5,
tanh L=2 unit-gain kernel, small d:
  derived here (Sec. 8.5):          E||Q_SS|| <= (e-1) n lam_{r+1} + tau_r log(tau_r / lam_{r+1})
  quoted form of Tropp Thm 7.2.1:   E||Q_SS|| <= (e-1) n lam_{r+1} + tau_r log(2 tau_r / lam_{r+1})
The derived bound is the smaller of the two, so it is the one tested by the ratio column 'ratio'.
Same seed and sampling as version 1 of this script, so the Monte Carlo means are unchanged."""
import numpy as np
from math import comb, e, log
from check_identities import kraw
from spec import spectrum
rng = np.random.default_rng(99)
for (d, r) in [(10, 1), (10, 3), (12, 1), (12, 3), (12, 5)]:
    sp = spectrum(d); lam = sp['lam']; Kr = kraw(d)
    tau = sum(comb(d, q) * lam[q] for q in range(r + 1, d + 1))
    Qh = np.array([lam[q] if q > r else 0.0 for q in range(d + 1)]) @ Kr
    for n in [20, 200, 600]:
        vals = []
        for _ in range(12):
            a = rng.integers(0, 2 ** d, size=n, dtype=np.int64)
            H = np.bitwise_count(a[:, None] ^ a[None, :]).astype(int)
            vals.append(np.linalg.eigvalsh(Qh[H])[-1])
        bnd2 = (e - 1) * n * lam[r + 1] + tau * log(2 * tau / lam[r + 1])
        bnd1 = (e - 1) * n * lam[r + 1] + tau * log(tau / lam[r + 1])
        print(f"d={d} r={r} n={n:5d}: E lmax={np.mean(vals):.3e}  max lmax={np.max(vals):.3e}  "
              f"derived bound={bnd1:.3e}  ratio={np.mean(vals)/bnd1:.3f}  "
              f"[quoted-form bound={bnd2:.3e}, ratio={np.mean(vals)/bnd2:.3f}; n lam={n*lam[r+1]:.2e}, tau={tau:.2e}]")
