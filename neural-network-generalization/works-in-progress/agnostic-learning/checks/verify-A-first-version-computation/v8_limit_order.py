"""(1) Fixed-d behaviour: excess lower bound ~ beta(n/M) vs an upper bound for ALL near-minimizers obtained from the
zero-network comparator: Delta(z_w) <= Delta(0) + c t, Delta(0)=sum_x k_x ybar_x^2 (E Delta(0) = E|S| <= M), and
sum_x z^2 <= 2 (2 Delta(0) + c t)/k_min. Monte Carlo at d=8, c=1, t=1.
(2) Above-threshold slack: if c >= C_t n with C_t = 2(1+sqrt(t/2))^2/t then every w with kappa<=t/2 is in N_t."""
import math, numpy as np, mpmath as mp
rng = np.random.default_rng(3)
beta = lambda lam: float(mp.e ** (-lam) * (mp.ei(lam) - mp.euler - mp.log(lam)))
d = 8; M = 2 ** d; c = 1.0; t = 1.0
print("(1) d=8 fixed, c=1, t=1")
for lam in [1, 4, 16, 64, 256]:
    n = lam * M; ubs = []
    for _ in range(200):
        x = rng.integers(0, M, size=n); y = rng.choice([-1.0, 1.0], size=n)
        k = np.bincount(x, minlength=M); S = np.bincount(x, weights=y, minlength=M)
        seen = k > 0
        D0 = float(np.sum(S[seen] ** 2 / k[seen]))         # sum_x k_x ybar_x^2
        kmin = k.min()
        ubs.append(2 * (2 * D0 + c * t) / max(kmin, 1) / M if kmin > 0 else float("inf"))
    ubs = np.array(ubs)
    print(f"  lambda={lam:4d}: beta(lambda)={beta(lam):.4f}  median UB on excess of every near-minimizer={np.median(ubs):.4f}"
          f"  (8/lambda={8/lam:.4f})")
print("(2) C_t = 2(1+sqrt(t/2))^2/t:", {tt: round(2 * (1 + math.sqrt(tt / 2)) ** 2 / tt, 3) for tt in [0.1, 0.5, 1, 2]})
for tt in [0.5, 1.0, 2.0]:
    Ct = 2 * (1 + math.sqrt(tt / 2)) ** 2 / tt
    worst = tt / 2 + (1 / Ct) * (1 + math.sqrt(tt / 2)) ** 2      # F(w) bound with n/c = 1/Ct
    print(f"  t={tt}: sup over kappa<=t/2 of F <= {worst:.4f} <= t = {tt}: {worst <= tt + 1e-12}")
