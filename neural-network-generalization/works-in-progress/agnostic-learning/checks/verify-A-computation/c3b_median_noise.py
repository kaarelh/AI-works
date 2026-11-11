"""Sampling noise of the 400-replicate median of U_S at n/M = 16 (Table 5.1)."""
import numpy as np
from math import sqrt
rng = np.random.default_rng(7)
out = []
for d in (6, 8):
    M = 2**d; n = 16*M
    U = []
    for _ in range(8000):
        k = rng.multinomial(n, np.full(M, 1.0/M)); s = 2*rng.binomial(k, 0.5) - k
        km = k.min(); D0 = float(np.sum(s**2/k))
        U.append(((sqrt((D0+1)/km) + sqrt(D0/km))**2)/M)
    U = np.array(U)
    meds = [np.median(rng.choice(U, 400, replace=False)) for _ in range(2000)]
    line = (f"d={d}, n/M=16: median over 8000 reps = {np.median(U):.4f}; 400-rep medians: 2.5%..97.5% = "
            f"{np.percentile(meds, 2.5):.4f}..{np.percentile(meds, 97.5):.4f}")
    print(line); out.append(line)
open(__file__.replace('.py', '.out'), 'w').write("\n".join(out) + "\n")
