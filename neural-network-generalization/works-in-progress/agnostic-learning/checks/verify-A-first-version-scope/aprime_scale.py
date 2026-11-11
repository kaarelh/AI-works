"""Scope check 2: how 'continuous' is the A-prime law, and does the mechanism survive bounded densities?

A.md Theorem 7.2: K_2 = max{n/c + t, K_mem}, r = (1/n) (L/K_2)^{L/2}; near-minimizers have
Lip <= (K_2/L)^{L/2}/sqrt(d) (Lemma 3.1(b)), so they move by <= 1/n across a cluster of diameter r sqrt(d).
The A-prime input density is (M r^d)^{-1} on X; relative to the uniform density 2^{-d} on [-1,1]^d
its ratio is r^{-d}.

For a law with density <= K * uniform, P(test point within distance rho of one of n training points)
<= n K vol(B_d(rho)) / 2^d.  The memorization mechanism needs Theta(1) of this probability at the scale
rho_res = (1/2) sqrt(d) (L/K_2)^{L/2} (beyond it the Lipschitz bound allows the fitted value to change by >= 1/2).
"""
import math

def log10_ball_vol(d, rho):
    # log10 of volume of Euclidean ball of radius rho in R^d
    return (d / 2) * math.log10(math.pi) - math.lgamma(d / 2 + 1) / math.log(10) + d * math.log10(rho)

def Kmem(d, s, a, H):
    alpha = 0.5 * math.log(4 * math.sqrt(2 * d))
    return d * (d + 1) * alpha ** 2 + (H + 1) * max((8 * d * s) ** (1.0 / H), 9 / (2 * a))

c, t = 1.0, 1.0
print(f"{'H':>2} {'d':>3} {'log10 n':>8} {'K_mem/n':>8} {'log10 r':>8} {'log10 dens.ratio r^-d':>21} "
      f"{'log10 P_unif(within rho_res)':>28} {'log10 K needed':>15}")
for H in (2, 3):
    L = H + 1
    for d in (20, 30, 40):
        M = 2 ** d; n = M
        a = (max(c, 1.0) / M) ** (1 / 3)
        km = Kmem(d, min(n, M), a, H)
        K2 = max(n / c + t, km)
        log10r = -math.log10(n) + (L / 2) * math.log10(L / K2)
        log10ratio = -d * log10r
        rho_res = 0.5 * math.sqrt(d) * (L / K2) ** (L / 2)
        log10P = math.log10(n) + log10_ball_vol(d, rho_res) - d * math.log10(2)   # K = 1 (uniform)
        log10Kneeded = -log10P   # density ratio needed for Theta(1) near-duplicate probability
        print(f"{H:>2} {d:>3} {math.log10(n):>8.2f} {km/n:>8.3g} {log10r:>8.1f} {log10ratio:>21.1f} "
              f"{log10P:>28.1f} {log10Kneeded:>15.1f}")

print("\nWidth needed by the refutation at a FIXED accuracy a (Remark 4.7 / Section 5.2 item 3):")
for d in (20, 30, 40):
    M = 2 ** d
    for a in (0.1, 0.3):
        N0 = math.floor(64 * math.log(2) * d * (d + 1) * M / a ** 2) + 1
        beta1 = 0.4848291069
        exc = (math.sqrt(beta1) - a) ** 2
        print(f"  d={d}, n=2^d={M:.3g}, a={a}: N_0={N0:.3g}, N_0/n={N0/M:.3g}, limiting certified excess {exc:.3f}")
