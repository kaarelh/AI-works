"""Numbers added to research-notes/A-tight-conditioning-fails.md in the second referee round.

(1) Claim A' at finite d (Theorem 7.2 and Proposition 7.2a), with lambda = 1, c = t = 1, delta = 0.01, n = M = 2^d.
    Theorem 7.2:      E = sqrt(c (K_mem + t)) + (a + 2/n) sqrt(n),  B' = 2 E sqrt(n) + E^2.
    Proposition 7.2a: B'' = c (K_mem + t) + n a^2 + 7, valid when c (K_mem + t) <= n and n >= 100.
    In both cases 1 + e' = Phi(q_delta, 1/n) with
        Phi(q, u) = ( sqrt(1 + (sqrt(q) - sqrt(B/M))_+^2) - u )_+^2,  q_delta = (beta_n - sqrt(2 lam log(1/delta)/M))_+,
    and B = B' or B''. The accuracy a is optimised separately for each bound: for B'' the optimum is the closed form
    a* = min{a_int, a_kink, 1} of r1_table41.py (B'' = M eps(a) + 7); for B' the script minimises E(a) on a fine grid
    in log a. The certified excess e of Theorem 4.4 (atoms) is printed for comparison.
(2) Corollary 4.5 (a_d = (max{c_d,1}/2^d)^{1/3}) against Corollary 4.5a (a'_d = max{a_d, 1/d}), with c_d = 1, t = 1,
    n_d = 2^d (lambda_d = 1) and delta_d = exp(-2^{d/2}): the bound eps_bar_d, the displayed lower bound
        ( sqrt( (beta(1) - 2^{-d} - sqrt(2) 2^{-d/4})_+ ) - sqrt(eps_bar_d) )_+^2,
    and N_0/n, next to the closed-form bounds 45 d (d+1) 2^{2d/3} and 45 d^3 (d+1) on N_0/n.
"""
import math
import numpy as np
from scipy import stats

def beta_bin(n, M):
    k = np.arange(1, 600)
    return float(np.sum(stats.binom.pmf(k, float(n), 1.0 / M) / k))

def kmem(d, s, a, H):
    alpha = 0.5 * math.log(4 * math.sqrt(2 * d))
    return d * (d + 1) * alpha ** 2 + (H + 1) * max((8 * d * s) ** (1.0 / H), 9 / (2 * a))

def phi(q, u, B, M):
    x = max(0.0, math.sqrt(q) - math.sqrt(B / M)) ** 2
    return max(0.0, math.sqrt(1 + x) - u) ** 2

def a_closed(d, H, lam, c):
    M = 2.0 ** d; n = round(lam * M); s = min(n, M)
    a_kink = 9 / (2 * (8 * d * s) ** (1.0 / H))
    a_int = (9 * (H + 1) * c / (4 * (n / M) * M)) ** (1.0 / 3)
    return min(a_int, a_kink, 1.0)

def e_atoms(d, H, c, a, t=1.0, delta=0.01, lam=1.0):
    M = 2.0 ** d; n = round(lam * M); s = min(n, M)
    eps = c * (kmem(d, s, a, H) + t) / M + (n / M) * a ** 2
    q = max(0.0, beta_bin(n, M) - math.sqrt(2 * (n / M) * math.log(1 / delta) / M))
    return max(0.0, math.sqrt(q) - math.sqrt(eps)) ** 2

def e_aprime(d, H, c, a, sharper, t=1.0, delta=0.01, lam=1.0):
    M = 2.0 ** d; n = round(lam * M); s = min(n, M)
    K = kmem(d, s, a, H)
    if sharper:
        C = c * (K + t)
        assert C <= n and n >= 100, "hypotheses of Proposition 7.2a fail"
        B = C + n * a ** 2 + 7
    else:
        E = math.sqrt(c * (K + t)) + (a + 2 / n) * math.sqrt(n)
        B = 2 * E * math.sqrt(n) + E ** 2
    q = max(0.0, beta_bin(n, M) - math.sqrt(2 * (n / M) * math.log(1 / delta) / M))
    return phi(q, 1 / n, B, M) - 1, K

print("(1) Claim A' certified excess e' (lambda = 1, c = t = 1, delta = 0.01, n = 2^d)")
print(f"{'H':>2} {'d':>3} | {'Thm 7.2 e`':>10} {'its a':>9} | {'Prop 7.2a e``':>13} {'its a':>9} {'c(K+t)/n':>9} | {'Thm 4.4 e':>9}")
for (H, d) in [(2, 20), (2, 30), (2, 40), (2, 60), (3, 20), (3, 30), (3, 40), (4, 30)]:
    n = 2 ** d
    grid = np.linspace(-14, 0, 14001)
    def Eof(lg):
        a = 10.0 ** lg
        return math.sqrt(kmem(d, n, a, H) + 1.0) + (a + 2 / n) * math.sqrt(n)
    lg = min(grid, key=Eof)
    a_st = 10.0 ** lg
    e_st, _ = e_aprime(d, H, 1.0, a_st, sharper=False)
    a_sh = a_closed(d, H, 1.0, 1.0)
    e_sh, K = e_aprime(d, H, 1.0, a_sh, sharper=True)
    e44 = e_atoms(d, H, 1.0, a_sh)
    print(f"{H:>2} {d:>3} | {e_st:10.4f} {a_st:9.2e} | {e_sh:13.4f} {a_sh:9.2e} {(K + 1) / n:9.2e} | {e44:9.4f}")

print("\n(2) Corollary 4.5 against Corollary 4.5a (c_d = 1, t = 1, n_d = 2^d, delta_d = exp(-2^{d/2}))")
beta1 = 0.48482910699
print(f"{'H':>2} {'d':>4} | {'a_d':>9} {'eps_bar':>9} {'bound':>7} {'N0/n':>9} {'45d(d+1)2^(2d/3)':>17} | "
      f"{'a`_d':>9} {'eps_bar':>9} {'bound':>7} {'N0/n':>9} {'45d^3(d+1)':>11}")
for H in (2, 3):
    for d in (20, 40, 60, 100, 200, 400):
        out = []
        for a in ((1.0 / 2 ** d) ** (1 / 3), max((1.0 / 2 ** d) ** (1 / 3), 1.0 / d)):
            alpha = 0.5 * math.log(4 * math.sqrt(2 * d))
            epsbar = (d * (d + 1) * alpha ** 2 + 1) / 2 ** d \
                + (H + 1) * ((8 * d * 2.0 ** d) ** (1.0 / H) + 9 / (2 * a)) / 2 ** d + a ** 2
            q = max(0.0, beta1 - 2.0 ** (-d) - math.sqrt(2) * 2.0 ** (-d / 4))
            bound = max(0.0, math.sqrt(q) - math.sqrt(epsbar)) ** 2
            N0n = 64 * math.log(2) * d * (d + 1) / a ** 2      # N0/n up to the +1 of the floor
            out.append((a, epsbar, bound, N0n))
        (a1, e1, b1, n1), (a2, e2, b2, n2) = out
        print(f"{H:>2} {d:>4} | {a1:9.2e} {e1:9.2e} {b1:7.4f} {n1:9.2e} {45 * d * (d + 1) * 2.0 ** (2 * d / 3):17.2e} | "
              f"{a2:9.2e} {e2:9.2e} {b2:7.4f} {n2:9.2e} {45 * d ** 3 * (d + 1):11.2e}")
print(f"limit beta(1) = {beta1:.6f}")
