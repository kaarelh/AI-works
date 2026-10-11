"""c8: explicit constants (notes-final.md: Theorem 3.5(b) and Remark 3.6a; Section 4.5 on the slides).

(1) Theorem 3.5(b) gives L <= 2m[(d+1)(5 + 2 log2(2d+4+L)) + 3] for the circuit prior of Section 3.2.
    The set of L >= 0 satisfying this is an interval [0, L*(m,d)] (the right side grows like log L).
    We compute L* by bisection on a log-spaced grid of m in [1e-3, 1e5] and d in [1, 1e4], and report
      max L* / (m (d+1) log2(2 (m+1) (d+2)))      over the whole grid (all m > 0 on the grid), and
      max L* / (m d log2(m d + 2))                 over the part of the grid with m >= 1 (referee m12's form),
    together with the location of the maxima.
(2) Vaintrob-Hanni slides, warm-up (slide 12): the tail inequality 3 (2/3)^(3C+26) < 3^(-C)/2000,
    in log form ln(6000) + 26 ln(2/3) + C ln(8/9) < 0, which is decreasing in C; and the union-bound
    sample size n = 2000((3C+26) ln 2 + C), at which 2^(3C+26) e^(-n/2000) = e^(-C).
(3) Slides, Appendix A at n = 4000 (ln M + 4), eps = eta = T = 1/2000, delta = 1/(2000 M):
    union bound M e^(-eps n) <= delta and Markov T e^(-eps n)/delta <= eta, for M = 1 .. 10^6 (log grid);
    final probability 1 - 2 delta = 1 - 1/(1000 M); average correct probability >= 1 - (eps + eta) = 0.999.
Deterministic.
"""
import math
import numpy as np

out = []


def P(s):
    print(s)
    out.append(s)


def Lstar(m, d):
    def rhs(L):
        return 2 * m * ((d + 1) * (5 + 2 * math.log2(2 * d + 4 + L)) + 3)
    lo, hi = 0.0, 1.0
    while hi <= rhs(hi):
        hi *= 2
    for _ in range(200):
        mid = (lo + hi) / 2
        if mid <= rhs(mid):
            lo = mid
        else:
            hi = mid
    return lo


ms = np.logspace(-3, 5, 161)
ds = np.unique(np.round(np.logspace(0, 4, 81)).astype(int))
best1 = (0, None); best2 = (0, None)
for m in ms:
    for d in ds:
        L = Lstar(m, d)
        r1 = L / (m * (d + 1) * math.log2(2 * (m + 1) * (d + 2)))
        if r1 > best1[0]:
            best1 = (r1, (m, d, L))
        if m >= 1:
            r2 = L / (m * d * math.log2(m * d + 2))
            if r2 > best2[0]:
                best2 = (r2, (m, d, L))
P(f"(1) grid: {len(ms)} values of m in [1e-3,1e5], {len(ds)} values of d in [1,1e4]")
P(f"    max L*/(m (d+1) log2(2(m+1)(d+2))) = {best1[0]:.3f} at m={best1[1][0]:.3g}, d={best1[1][1]}, L*={best1[1][2]:.4g}")
P(f"    max over m >= 1 of L*/(m d log2(m d + 2)) = {best2[0]:.3f} at m={best2[1][0]:.3g}, d={best2[1][1]}, L*={best2[1][2]:.4g}")
# behaviour of the referee's form for small m (it is not uniformly bounded there)
for m, d in ((1e-3, 10), (1e-3, 1000), (1e-3, 10000)):
    L = Lstar(m, d)
    P(f"    small m: m={m}, d={d}: L*/(m d log2(md+2)) = {L / (m * d * math.log2(m * d + 2)):.1f}")

# (2) warm-up
lhs0 = math.log(6000) + 26 * math.log(2 / 3)
P(f"(2) warm-up tail: ln(6000) + 26 ln(2/3) = {lhs0:.4f} < 0 and ln(8/9) = {math.log(8/9):.4f} < 0, so the inequality holds for all C >= 0")
okU = all(abs(((3 * C + 26) * math.log(2) - 2000 * ((3 * C + 26) * math.log(2) + C) / 2000) - (-C)) < 1e-9 for C in range(0, 1000))
P(f"    union bound at n = 2000((3C+26) ln2 + C): log of 2^(3C+26) e^(-n/2000) equals -C for C = 0..999: {okU}")

# (3) Appendix A
eps = eta = T = 1 / 2000
okA = True
for M in np.unique(np.round(np.logspace(0, 6, 61)).astype(int)):
    delta = 1 / (2000 * M)
    n = 4000 * (math.log(M) + 4)
    u = M * math.exp(-eps * n)
    mk = T * math.exp(-eps * n) / delta
    okA &= (u <= delta) and (mk <= eta)
P(f"(3) Appendix A at n = 4000(ln M + 4): union bound and Markov conditions hold for M = 1..1e6: {okA}; "
  f"e^-8 = {math.exp(-8):.3e} < 1/2000 = {1/2000:.1e}; confidence 1 - 2 delta = 1 - 1/(1000 M); accuracy >= 1 - (eps+eta) = {1 - eps - eta}")

with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write("\n".join(out) + "\n")
