"""c4: how cheap is a property separating a fresh test input from m i.i.d. training inputs?
(notes.md, section 2.4, Proposition 2.12.)

Inputs are uniform n-bit strings (n = 48).  For a test input x*, let sigma be the least l such that no
training input shares the length-l prefix of x* (i.e. 1 + the longest common prefix with a training input).
The prefix property Q = {x : x starts with that prefix} separates x* from the training set, and
K(Q) <= sigma + 2 log2(sigma + 1) + O(1).  Proposition 2.12 uses l = ceil(log2 m) + 1, for which
Pr[no training input shares the prefix] = (1 - 2^{-l})^m >= 1/2.  We print:
  * the empirical distribution of sigma - log2 m,
  * the frequency of sigma <= ceil(log2 m) + 1 (proved >= 1/2),
  * m * E[2^{-(sigma + 2 log2(sigma+1))}], the shape of the lower bound on SFI's in-distribution error
    (up to the machine constant 2^{-c}), which decays like 1/log^2 m when multiplied by m.
Seeded.
"""
import math
import numpy as np

SEED = 3
rng = np.random.default_rng(SEED)
n = 48
TRIALS = 2000
out = []
for m in [10, 100, 1000, 10000]:
    sig = []
    for _ in range(TRIALS):
        train = rng.integers(0, 2 ** n, size=m, dtype=np.int64)
        xs = int(rng.integers(0, 2 ** n, dtype=np.int64))
        # longest common prefix (from the top bit) between xs and any training input
        xor = np.bitwise_xor(train, xs)
        lcp = np.where(xor == 0, n, n - np.floor(np.log2(np.maximum(xor, 1))).astype(int) - 1)
        sig.append(int(lcp.max()) + 1)
    sig = np.array(sig)
    l0 = math.ceil(math.log2(m)) + 1
    frac = np.mean(sig <= l0)
    lb = np.mean(2.0 ** (-(sig + 2 * np.log2(sig + 1))))
    out.append(f"m={m:6d}: sigma - log2 m: mean {np.mean(sig - math.log2(m)):+.2f}, "
               f"quantiles 10/50/90% = {np.quantile(sig - math.log2(m), [0.1, 0.5, 0.9]).round(2).tolist()}; "
               f"Pr[sigma <= ceil(log2 m)+1 = {l0}] = {frac:.3f} (proved >= 0.5, exact {(1 - 2.0 ** -l0) ** m:.3f}); "
               f"m * E[2^-(sigma+2log2(sigma+1))] = {m * lb:.4f}; times log2(m)^2: {m * lb * math.log2(m) ** 2:.3f}")
txt = "\n".join(out)
print(txt)
with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write(txt + "\n")
