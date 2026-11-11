"""research-notes/A-tight-conditioning-fails.md (script added in revision 1), Proposition 7.4 and Remark 7.5: how near-atomic is the A' law, and what density ratio does the
Lipschitz transfer of Theorem 7.2 need?  Also the TUBE energy floor on A' data (Remark 7.6).

Setting of Theorem 7.2 with c = 1, t = 1, n = 2^d, a = a_d = 2^{-d/3} (Corollary 4.5):
  K_2 = max{n/c + t, K_mem},  r = (1/n) (L/K_2)^{L/2}.
* A' input density is (M r^d)^{-1} on X; uniform on [-1,1]^d is 2^{-d}; ratio r^{-d}.
* Transfer radius rho_tr = 2 sqrt(d) (L/K_2)^{L/2}: by Lemma 3.1(b) every network of energy <= K_2 changes by at
  most 2 over this distance, and by more only beyond it.  For a law with density <= K 2^{-d},
     P[test point within rho of some training input] <= n K vol(B_d(rho)) 2^{-d}            (exact volume)
                                                     <= n K (2 pi e rho^2/d)^{d/2} 2^{-d}   (Gamma bound).
  Columns: log10 of the exact-volume bound for K = 1 (uniform law); log10 of the K needed to make it 1/2;
  and the closed-form exponent valid for EVERY c > 0 (uses only K_2 >= K_mem >= (H+1) 2^{d/H} at n = 2^d):
     log2 P <= log2 K - (L/(2H)) d^2 + (d/2) log2(8 pi e).
* TUBE floor (Remark 7.6): every TUBE_rho-feasible network on A' data with a conflicting cluster has energy
  > L ((2 - 2 rho)/r)^{2/L};  reported at rho = 1/2 relative to K_2.
"""
import math

def Kmem(d, s, a, H):
    alpha = 0.5 * math.log(4 * math.sqrt(2 * d))
    return d * (d + 1) * alpha ** 2 + (H + 1) * max((8 * d * s) ** (1.0 / H), 9 / (2 * a))

def log10_vol(d, rho):
    return (d / 2) * math.log10(math.pi) - math.lgamma(d / 2 + 1) / math.log(10) + d * math.log10(rho)

c, t = 1.0, 1.0
print(f"{'H':>2} {'d':>3} {'log10 r':>8} {'log10 ratio r^-d':>16} {'log10 P_unif(rho_tr), exact vol':>32} "
      f"{'log10 K for P=1/2':>17} {'all-c exponent (log10)':>23} {'TUBE floor/K_2':>14}")
for H in (2, 3):
    L = H + 1
    for d in (20, 30, 40):
        M = 2 ** d; n = M
        a = (max(c, 1.0) / M) ** (1 / 3)
        km = Kmem(d, min(n, M), a, H)
        K2 = max(n / c + t, km)
        lr = -math.log10(n) + (L / 2) * math.log10(L / K2)
        ratio = -d * lr
        rho_tr = 2 * math.sqrt(d) * (L / K2) ** (L / 2)
        lP = math.log10(n) + log10_vol(d, rho_tr) - d * math.log10(2)
        need = math.log10(0.5) - lP
        allc = (-(L / (2 * H)) * d * d + (d / 2) * math.log2(8 * math.pi * math.e)) * math.log10(2)
        # gamma-bound check: exact vol <= (2 pi e rho^2/d)^{d/2}
        assert log10_vol(d, rho_tr) <= (d / 2) * math.log10(2 * math.pi * math.e * rho_tr ** 2 / d) + 1e-9
        # all-c closed form dominates the c=1 value
        assert lP <= allc + 1e-9
        floor = L * ((2 - 2 * 0.5) / 10 ** lr) ** (2 / L)
        print(f"{H:>2} {d:>3} {lr:>8.1f} {ratio:>16.1f} {lP:>32.1f} {need:>17.1f} {allc:>23.1f} {floor / K2:>14.3g}")

print("\nClosed forms at c = 1 (n = 2^d, K_2 = n + t): log2(ratio) = d log2 n + (L d/2) log2(K_2/L) ~ (1 + L/2) d^2;")
for H in (2, 3):
    L = H + 1
    for d in (20, 40):
        n = 2 ** d; K2 = n + 1
        print(f"  H={H} d={d}: log2 ratio = {d * math.log2(n) + (L * d / 2) * math.log2(K2 / L):.1f}, "
              f"(1+L/2) d^2 = {(1 + L / 2) * d * d:.1f}")
