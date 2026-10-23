"""Section B4.1: complexity terms of Theorem B2.1 for representative norm values (no network needed).
Margin gamma = 1 with zero train margin error; q = 1.1, delta = 0.05; the confidence term is included."""
import numpy as np
import nnbounds as nb
D = 31
def bound(C, kappa, n, gamma=1.0):
    margins = np.full(n, 10.0)   # all train margins large: ramp loss 0 at every grid gamma <= 4
    j = nb.grid_index(C, 1.0, 1.1); phij = 1.1 ** j
    k = int(round(np.log(4 / gamma) / np.log(1.1)))
    g = 4 * 1.1 ** (-k)
    return 2 * kappa * phij / (g * np.sqrt(n)) + np.sqrt(np.log((j + 1) * (j + 2) * (k + 1) * (k + 2) / 0.05) / (2 * n))
print("Frobenius P_F = ||a||(||[W1 b1]|| ||W2||) for ||W1|| in {6,10}, ||W2|| in {11,15}, ||a|| in {1,3}; also init-like 0.088")
for n in [256, 2048, 16384]:
    vals = []
    for (w1, w2, a) in [(11.3, 11.3, 0.088), (6, 11, 1), (10, 15, 1), (6, 11, 3), (10, 15, 3)]:
        vals.append(f"P={w1*w2*a:6.1f}: {bound(w1*w2*a, nb.KAPPA_FROB(D), n):7.2f}")
    print(f"n={n:5d}  " + " | ".join(vals))
print("path norm phi")
for n in [256, 2048, 16384]:
    print(f"n={n:5d}  " + " | ".join(f"phi={phi:5.0f}: {bound(phi, nb.KAPPA_PATH(D), n):7.2f}" for phi in [2, 10, 30, 100, 1000]))
print("largest phi with bound <= 0.5 at gamma=1:")
for n in [256, 2048, 16384, 10**6]:
    phis = np.exp(np.linspace(np.log(0.5), np.log(1e4), 4000))
    ok = [phi for phi in phis if bound(phi, nb.KAPPA_PATH(D), n) <= 0.5]
    print(f"   n={n}: phi <= {max(ok) if ok else float('nan'):.2f}")
