"""Share of the first level pair in the tail variance of the tanh NNGP kernel (paper, Section 8).

For odd F and odd r the paper writes
    tau_r = A * sum_{odd j >= r+2} W_j,     lambda_{r+1} = A * W_{r+2} / binom(D, r+2),
with D = d+1 and W_j = binom(D, j) a_j = sum_m c_m P(walk on {-1,1}^D is at distance j after m steps).
This script computes
    theta_r = binom(D, r+2) lambda_{r+1} / tau_r = W_{r+2} / sum_{odd j >= r+2} W_j
for the depth-2 tanh kernel (one hidden layer, first-layer gain sigma_1; theta_r does not depend on
the readout gain), at d = 160, 200, 400, 800, 1600, 3200, and reports
  * the range of theta_r * sqrt(r) over odd r <= 0.065 d, and where its minimum sits;
  * the two-level ratio W_{j+2}/W_j of the pair masses at j ~ 0.1 d and j ~ 0.25 d.
The coefficients c_m come from the Hermite formula of Lemma 4.1, computed by `tanh_layer` of
spectrum.py, for m <= 3*3201 + 400 = 10003 (the largest retained coefficient is printed; the omitted
ones are smaller still);
the pair masses come from the exact Ehrenfest recursion, so every term is nonnegative and no
cancellation occurs.  These are numerical observations: the paper proves neither
theta_r >= c r^(-1/2) nor theta_r <= C r^(-1/2).  In the computed range the data support the
lower bound; the maximum of theta_r*sqrt(r) still grows with d, so they do not settle the upper
bound.  Output: theta.txt.
"""
import math
import numpy as np
from spectrum import tanh_layer

DS = [160, 200, 400, 800, 1600, 3200]
SIGMAS = [1.0, 0.5, 2.0]


def pair_masses(c, D):
    """W_j = sum_m c_m P(X_m = j), j = 0..D, by the exact Ehrenfest recursion (streaming in m)."""
    mmax = len(c) - 1
    j = np.arange(D + 1)
    up = (D - j) / D          # distance j -> j+1
    dn = j / D                # distance j -> j-1
    p = np.zeros(D + 1)
    p[0] = 1.0
    W = np.zeros(D + 1)
    for m in range(1, mmax + 1):
        new = np.zeros(D + 1)
        new[1:] += p[:-1] * up[:-1]
        new[:-1] += p[1:] * dn[1:]
        p = new
        if c[m] > 0:
            W += c[m] * p
    return W


def nearest_odd(x):
    k = int(math.floor(x))
    k = k if k % 2 == 1 else k - 1          # largest odd integer <= x
    return k if x - k <= 1 else k + 2


def main():
    lines = []
    mmax = 3 * (max(DS) + 1) + 400
    if mmax % 2 == 0:
        mmax += 1
    for s1 in SIGMAS:
        c, v, _ = tanh_layer(s1, mmax)
        lines.append(f"L=2, sigma_1={s1:g}: sum_(m<={mmax}) c_m = {c.sum():.12f}, log c_{mmax} = {math.log(c[mmax]):.1f}")
        for d in DS:
            D = d + 1
            W = pair_masses(c, D)
            odd = np.zeros(D + 1)
            odd[1::2] = W[1::2]
            suffix = np.cumsum(odd[::-1])[::-1]          # suffix[j] = sum_{odd i >= j} W_i
            rs = np.arange(1, D - 1, 2)
            rs = rs[rs <= 0.065 * d]
            th = W[rs + 2] / suffix[rs + 2]
            ts = th * np.sqrt(rs)
            imin, imax = int(np.argmin(ts)), int(np.argmax(ts))
            j10, j25 = nearest_odd(0.1 * d), nearest_odd(0.25 * d)
            lines.append(
                f"  d={d:5d}: odd r<=0.065d (r<={rs.max()}): theta_r*sqrt(r) in [{ts.min():.3f}, {ts.max():.3f}]"
                f" (min at r={rs[imin]}, max at r={rs[imax]});"
                f" W_(j+2)/W_j at j={j10}: {W[j10 + 2] / W[j10]:.3f}, at j={j25}: {W[j25 + 2] / W[j25]:.3f}")
    open("theta.txt", "w").write("\n".join(lines) + "\n")
    print("\n".join(lines))


if __name__ == "__main__":
    main()
