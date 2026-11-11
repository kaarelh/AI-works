"""Training loss (per sample) of the atom-mean fit for n = lam * 2^d uniform cube draws, fair +-1 labels.
Prediction: r ~= 1 - (1 - e^{-lam})/lam."""
import numpy as np
rng = np.random.default_rng(3)
d = 16; M = 2 ** d
for lam in [0.5, 1.0, 1.5, 3.0]:
    n = int(lam * M); vals = []
    for _ in range(5):
        x = rng.integers(0, M, size=n); y = rng.choice([-1.0, 1.0], size=n)
        cnt = np.bincount(x, minlength=M); s = np.bincount(x, weights=y, minlength=M)
        ybar = s[x] / cnt[x]
        vals.append(np.mean((y - ybar) ** 2))
    print(f"lam={lam}: simulated r={np.mean(vals):.4f}  predicted={1 - (1 - np.exp(-lam)) / lam:.4f}")
