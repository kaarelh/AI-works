# Remark 8 (failure side) of RT-width.fixed.md imports A.md Theorem 4.4 / Corollary 4.5.
# The remark says: "The full excess beta(lambda)-o(1) needs a->0, and then N_0 = O(n^{5/3} log^2 n)".
# Theorem 4.4 holds for EVERY a in (0,1]; Corollary 4.5 is one choice a_d=(1/2^d)^{1/3}.
# Here: certified excess (4.3) of A.md at c=1, t=1, delta=0.01, n=M=2^d (lambda=1), H=2,
# for three accuracy schedules, with N_0/(n log2^2 n).
import mpmath as mp
mp.mp.dps = 50

beta1 = mp.e**-1 * (mp.ei(1) - mp.euler)  # beta(1)
def K_mem(d, s, a, H):
    alpha_d = mp.log(4 * mp.sqrt(2 * d)) / 2
    return d * (d + 1) * alpha_d**2 + (H + 1) * max((8 * d * s) ** (mp.mpf(1) / H), mp.mpf(9) / (2 * a))
def N0(d, s, a):
    return mp.floor(64 * mp.log(2) * d * (d + 1) * s / a**2) + 1
def cert_excess(d, a, H=2, c=1, t=1, delta=mp.mpf('0.01')):
    M = mp.mpf(2) ** d; n = M; lam = n / M; s = min(n, M)
    beta_n_lb = beta1 - n / M**2          # Lemma 4.3(c) of A.md
    eps = c * (K_mem(d, s, a, H) + t) / M + lam * a**2
    inner = max(beta_n_lb - mp.sqrt(2 * lam * mp.log(1 / delta) / M), 0)
    return max(mp.sqrt(inner) - mp.sqrt(eps), 0) ** 2, N0(d, s, a) / (n * mp.log(n, 2) ** 2)

print("beta(1) = %s" % mp.nstr(beta1, 8))
print("%6s | %-34s | %-34s | %-34s" % ("d", "a=0.1 fixed: excess, N0/(n log^2 n)", "a_d=1/log2(d): excess, N0/(n log^2 n)", "a_d=2^{-d/3} (Cor 4.5): excess, N0/(n log^2 n)"))
for d in [20, 30, 40, 60, 100, 200, 400, 1000, 4000]:
    r1 = cert_excess(d, mp.mpf('0.1'))
    r2 = cert_excess(d, 1 / mp.log(d, 2))
    r3 = cert_excess(d, mp.mpf(2) ** (-mp.mpf(d) / 3))
    print("%6d | %8s  %-24s | %8s  %-24s | %8s  %-24s" % (
        d, mp.nstr(r1[0], 4), mp.nstr(r1[1], 4), mp.nstr(r2[0], 4), mp.nstr(r2[1], 4), mp.nstr(r3[0], 4), mp.nstr(r3[1], 4)))
print("With a_d = 1/log2(d): N0 = O(n log^2 n (log log n)^2) and the certified excess tends to beta(1);")
print("so the full excess does not need width n^{5/3}; any a_d -> 0 with a_d >> 1/M gives N0 = n^{1+o(1)}.")
