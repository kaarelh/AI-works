"""Chernoff bound for Gaussian quadratic forms in a regime with non-negligible
probabilities: P(||t||^2 > s) <= exp(-(s - 2 log2 tr Q)/(4 lambda_max)), t ~ N(0,Q)."""
import numpy as np
from math import log
from check_identities import kraw
from spec import spectrum
rng = np.random.default_rng(7)
for (d, r, n) in [(10, 1, 3), (10, 1, 8), (10, 3, 6), (12, 3, 10)]:
    sp = spectrum(d); lam = sp['lam']; Kr = kraw(d)
    Qh = np.array([lam[q] if q > r else 0.0 for q in range(d + 1)]) @ Kr
    a = rng.integers(0, 2 ** d, size=n, dtype=np.int64)
    H = np.bitwise_count(a[:, None] ^ a[None, :]).astype(int)
    Q = Qh[H]; ev, U = np.linalg.eigh(Q); ev = np.clip(ev, 0, None)
    tr, lmax = ev.sum(), ev[-1]
    Z = rng.standard_normal((2_000_000, n))
    sq = (Z ** 2 * ev).sum(1)
    line = f"d={d} r={r} n={n} tr/lmax={tr/lmax:.2f}:"
    ok = True
    for mult in [1.5, 2.0, 3.0, 4.0, 6.0]:
        s = mult * tr
        emp = (sq > s).mean(); bnd = np.exp(-(s - 2 * log(2) * tr) / (4 * lmax))
        ok &= emp <= bnd
        line += f"  s={mult}tr: {emp:.2e}<= {bnd:.2e}"
    print(line, " ALL OK" if ok else " VIOLATION")
