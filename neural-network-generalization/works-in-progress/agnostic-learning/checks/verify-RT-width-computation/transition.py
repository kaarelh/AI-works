"""Closing sentence of Sec. 6.3: 'Parameter counting cannot help once N >~ sqrt(n), and A shows that the
clean-label-scaled learner fails at N >~ d^2 n. For depth >= 3 the width transition therefore lies between
sqrt(n) and n log^2 n.'

(a) Positive side on the cube example of Theorem 2.2: competitor g = 0 (E* = 0, U = 0), c = 1, n = M = 2^d.
    Largest N for which the deviation term T3 of Prop. 6.1 is <= eps; compare with sqrt(n), sqrt(n/ln n).
(b) Negative side: N0 = ceil(72 d n ln(2M)/a^2) + 1 of Theorem 2.2, for fixed a and for a = n^{-1/3};
    compare with n log2(n)^2.  Also the Theorem 2.2 excess lower bound at fixed a (constant excess).
(c) A2 / Sec. 0 item 1 cite Prop. 6.1 for 'N <= n^{1/2-eps}, every competitor of width <= N': with fixed B the
    Hoeffding term (U+1)^2 sqrt(ln(4/delta)/(2n)), U = N B, at N = n^{1/2-eps}.
"""
import mpmath as mp

mp.mp.dps = 50
delta = mp.mpf("0.05")
ld = mp.log(4 / delta)


def T3(n, N, d, L, K):
    H = L - 1
    P = N * (d + 1) + (L - 2) * N ** 2 + N
    logG = P * mp.log(2 + 2 * n * mp.sqrt(K * N) * H * (d + N + 1) * (K + 1) ** (mp.mpf(H) / 2))
    return 4 * mp.sqrt((logG + ld) / (2 * n))


def largest_N(n, d, L, eps, K):
    lo, hi = 1, int(mp.sqrt(n)) * 4 + 10
    if T3(n, 1, d, L, K) > eps:
        return 0
    while hi - lo > 1:
        mid = (lo + hi) // 2
        if T3(n, mid, d, L, K) <= eps:
            lo = mid
        else:
            hi = mid
    return lo


print("(a) cube example, zero competitor, c = 1: largest N with T3 <= eps")
for L in (3, 4):
    for eps in (mp.mpf("0.1"), mp.mpf("0.5")):
        for d in (20, 30, 40, 60, 100):
            n = mp.mpf(2) ** d
            K = 1 + n  # E* + 1 + n (U+1)^2 / c with E* = U = 0, c = 1
            Nst = largest_N(n, d, L, eps, K)
            print(f"L={L} eps={float(eps)} d={d:3d} n=2^{d}: N*={Nst:>14d}  N*/sqrt(n)={mp.nstr(Nst/mp.sqrt(n),4):>8}  "
                  f"N*/sqrt(n/ln n)={mp.nstr(Nst/mp.sqrt(n/mp.log(n)),4):>8}")

print()
print("(b) Theorem 2.2 width threshold N0 = ceil(72 d n ln(2M)/a^2) + 1, n = M = 2^d")
beta1 = mp.e ** -1 * (mp.ei(1) - mp.euler)
for d in (20, 30, 40, 60):
    n = mp.mpf(2) ** d
    M = n
    for a in (mp.mpf("0.25"), mp.mpf("0.5"), n ** (-mp.mpf(1) / 3)):
        N0 = mp.ceil(72 * d * n * mp.log(2 * M) / a ** 2) + 1
        print(f"d={d} a={mp.nstr(a,4):>10}: N0={mp.nstr(N0,4):>10}  N0/(n log2(n)^2)={mp.nstr(N0/(n*mp.log(n,2)**2),4):>8}  "
              f"N0/(d^2 n)={mp.nstr(N0/(d**2*n),4):>8}  N0/n^(5/3)/d^2={mp.nstr(N0/n**(mp.mpf(5)/3)/d**2,4)}")
print(f"beta(1) = {mp.nstr(beta1, 7)}; fixed-a asymptotic excess lower bound (sqrt(beta)-a)^2 at lambda = 1:")
for a in (mp.mpf("0.1"), mp.mpf("0.25"), mp.mpf("0.5"), mp.sqrt(beta1)):
    print(f"   a={mp.nstr(a,4)}: {mp.nstr(max(0, mp.sqrt(beta1) - a) ** 2, 5)}")

print()
print("(c) Sec. 0 item 1 / A2: N = n^{1/2-eps}, competitor width m = N, fixed B = 1, d = 10, L = 3, c = 1")
for eps in (mp.mpf("0.1"), mp.mpf("0.2"), mp.mpf("0.3")):
    for k in (20, 40, 80):
        n = mp.mpf(10) ** k
        N = mp.ceil(n ** (mp.mpf(1) / 2 - eps))
        B = 1
        d = 10
        L = 3
        U = N * B
        E = d * (d + 1) * B ** 2 + 2 * (L - 1) * N ** 2 * B ** 2
        K = E + 1 + n * (U + 1) ** 2
        T1 = (E + 1) / n
        t3 = T3(n, N, d, L, K)
        T4 = (U + 1) ** 2 * mp.sqrt(ld / (2 * n))
        T4B = (U + 1) * mp.sqrt(2 * ld / n) + 2 * (U + 1) ** 2 * ld / (3 * n)
        print(f"eps={float(eps)} n=1e{k}: T1={mp.nstr(T1,3):>9} T3={mp.nstr(t3,3):>9} Hoeffding T4={mp.nstr(T4,3):>9} "
              f"Bernstein T4B={mp.nstr(T4B,3):>9}")
