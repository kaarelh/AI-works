"""(1) TUBE with replacement: probability that NO atom carries both labels (fair +-1 labels, n iid uniform inputs
    on M atoms): exact value E[2^{s-n}] by Monte Carlo vs the bound of Lemma 6.2 in A.md,
        exp(-n2 mu1/(4M)) + exp(-mu1^2/(2 n1)),  n1 = floor(n/2), n2 = n - n1, mu1 = M(1-(1-1/M)^{n1}).
(2) Memorization energy: construction K_mem (Lemma 2.1) vs the capacity lower bound of Proposition 8.2,
        K >= H ((1-a) sqrt(s) / D_{d,H})^{2/H},  D_{d,H} = sqrt(2 log 2)(d+1) + (H-1)/2,
    for s = 2^d (all cube points), a = 1/2.
(3) Claim A' radius r(n) = (1/n) (L / K2)^{L/2} with K2 = max{n/c + t, K_mem}, c = 1, t = 1; and the competitor
    lower bound 1 - (r/2) B^L m^H sqrt(d) for width-m, weight-B networks (m = B = n here).
"""
import math
import numpy as np

rng = np.random.default_rng(7)
print("(1) P(no conflicting atom): Monte Carlo vs bound")
for M, lam in [(2 ** 8, 1.0), (2 ** 10, 0.25), (2 ** 10, 1.0), (2 ** 12, 0.1), (2 ** 14, 0.05)]:
    n = int(lam * M); reps = 20000
    hits = 0
    for _ in range(reps):
        x = rng.integers(0, M, size=n); y = rng.integers(0, 2, size=n)
        pos = np.bincount(x, weights=y, minlength=M); cnt = np.bincount(x, minlength=M)
        hits += int(np.all((pos == 0) | (pos == cnt)))
    n1 = n // 2; n2 = n - n1; mu1 = M * (1 - (1 - 1 / M) ** n1)
    bound = math.exp(-n2 * mu1 / (4 * M)) + math.exp(-mu1 ** 2 / (2 * n1))
    print(f"    M={M} n={n}: MC P(no conflict)={hits/reps:.4f}, bound={min(1.0, bound):.4f}")

print("(2) memorization energy for s = 2^d points, a = 1/2: construction vs capacity lower bound")
for H in [1, 2, 3, 4]:
    for d in [10, 20, 40]:
        s = 2 ** d; a = 0.5
        alpha = 0.5 * math.log(4 * math.sqrt(2 * d))
        if H >= 2:
            Kup = d * (d + 1) * alpha ** 2 + (H + 1) * max((8 * d * s) ** (1 / H), 9 / (2 * a))
        else:
            Kup = float("nan")
        D = math.sqrt(2 * math.log(2)) * (d + 1) + (H - 1) / 2
        Klow = H * ((1 - a) * math.sqrt(s) / D) ** (2 / H)
        print(f"    H={H} d={d}: K_mem(upper)={Kup:.3e}  K_low={Klow:.3e}  ratio={Kup/Klow:.2f}")

print("(3) Claim A' radius and competitor bound (c=1, t=1, H=2, lambda=1, a=n^{-1/3})")
for d in [20, 30, 40]:
    n = 2 ** d; H = 2; L = H + 1; a = n ** (-1 / 3)
    alpha = 0.5 * math.log(4 * math.sqrt(2 * d))
    Kmem = d * (d + 1) * alpha ** 2 + (H + 1) * max((8 * d * n) ** (1 / H), 9 / (2 * a))
    K2 = max(n + 1.0, Kmem)
    r = (1 / n) * (L / K2) ** (L / 2)
    m = B = n
    comp = 1 - (r / 2) * B ** L * m ** H * math.sqrt(d)
    print(f"    d={d}: r(n)={r:.3e} (log2 r = {math.log2(r):.1f}); competitor class (m=B=n) risk >= {comp:.6f} "
          f"if r B^L m^H sqrt(d) small; here (r/2)B^L m^H sqrt d = {(r/2)*B**L*m**H*math.sqrt(d):.3e}")
