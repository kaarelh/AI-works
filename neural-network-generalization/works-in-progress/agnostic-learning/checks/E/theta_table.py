"""theta_{L,gamma} of E-finite-prior-scale.md Theorem 2.7, the comparison exponents, and the
discontinuity of the proven threshold at gamma = 1 (Section 6)."""
import numpy as np
def theta(H, g):
    if H == 1: return 1.0
    if g == 1.0:
        L = H+1; return 1.0/(4+16*(L-2)*3**(L-2))
    if g >= 2-1/H: return 1.0/H
    return max((g-1)/(g*H-1), (g-1)/(H*(H-1)*(2-g)))
print("gamma  " + "  ".join(f"H={H}(L={H+1})" for H in [1,2,3,4]))
for g in [1.0, 1.05, 1.1, 1.2, 1.25, 1.3, 1.4, 1.5, 1.6, 1.667, 1.75, 1.8, 2.0, 3.0]:
    print(f"{g:5.3f}  " + "  ".join(f"{theta(H,g):10.4f}" for H in [1,2,3,4]))
for H in [2,3,4]:
    print(f"H={H}: crossover of the two routes at gamma={2-2/H+1/H**2:.4f}; full 1/H reached at gamma={2-1/H:.4f}; "
          f"red-team sketch exponent (gamma-1)/(2(L-2)) at gamma=1.5: {0.5/(2*(H-1)):.4f} vs ours {theta(H,1.5):.4f}")

# Discontinuity at gamma = 1 (Section 6): for 1 < gamma < 2-1/H the threshold is the max of two
# increasing functions of gamma that tend to 0 as gamma -> 1+, while theta_{L,1} = 1/D_H > 0.
def theta_gt1(H, g):
    return max((g-1)/(g*H-1), (g-1)/(H*(H-1)*(2-g)))
for H in [2, 3, 4, 5]:
    L = H+1; DH = 4+16*(L-2)*3**(L-2); t1 = 1.0/DH
    lo, hi = 1.0, 2-1/H
    for _ in range(200):
        mid = (lo+hi)/2
        if theta_gt1(H, mid) < t1: lo = mid
        else: hi = mid
    print(f"H={H}: theta_(L,1)=1/{DH}={t1:.5f}; the gamma>1 value is below it for 1<gamma<{lo:.5f} "
          f"(closed form (D_H-1)/(D_H-H)={(DH-1)/(DH-H):.5f}); value at gamma=1.001: {theta_gt1(H, 1.001):.6f}")
