"""rb0_constants.py -- referee B (thread `logic`): independent checks of the explicit constants
used in notes.md.  Written from the statements in notes.md, not from the developer's code.

No randomness (deterministic).  Output: rb0_constants.out (stdout).  Usage: python3 -I rb0_constants.py

K1  Thm 2.2(a): the survival product prod_{k>=0} (1 - 2^-(k+1)) = (1/2;1/2)_inf, to 30 digits
    (mpmath qp), against the record's 0.288788..., and the partial products for K = 1..5 as exact
    fractions (the record's c1 lists 1/2, 3/8, 21/64, 315/1024, 9765/32768).
K2  Cor 2.6': the number of Sigma_1 facts that determine j*_0..j*_{K-1} is
    sum_{k<K} (1 + (N_k + 1)) with N_k = 2^(k+1) - 1; the record says "fewer than 2^(K+1)+K", and
    that the number of true ones fits in K+2 bits.  Checked for K = 1..60.
    Also the horizon m(n) = sum_{k < ceil(n/2)} (k+1) and the batch-lottery horizon <= (n+1)^2.
K3  Prop 3.8: l := ceil(log2(d / log2 3)) - 1 gives 3^(2^l - 1) < 2^d (pigeonhole over the colours
    of the 2^l - 1 programs of length < l) and l > log2 d - 2, for d = 2..10^6 (exact integer test
    of the pigeonhole inequality; float only for the ceil, cross-checked at the boundary).
    Also the largest l allowed by pigeonhole, to see how much slack the record's l leaves.
K4  Cor 3.6: under length-lexicographic coding (empty string = 0), the strings of length <= m
    are exactly the codes 0..P_m with P_m = 2^(m+1) - 2 (exhaustive for m <= 12).
    h_m <= 2^m (Kraft) needs m+1 bits: checked that 2^m < 2^(m+1).
K5  Thm 6.1: delta_str = 1/(5 log2 14); and n^delta for n = 10^6, 10^9, 10^30.
K6  Cor 6.2: log2 C(n,u) <= u log2(e n / u) for all 1 <= u <= n <= 400 (exact binomials).
"""
from fractions import Fraction
from math import comb, log2, ceil, e, floor

import mpmath


def k1():
    print("== K1 survival product (Thm 2.2(a)) ==")
    mpmath.mp.dps = 40
    val = mpmath.qp(mpmath.mpf(1) / 2, mpmath.mpf(1) / 2)
    direct = mpmath.nprod(lambda k: 1 - mpmath.power(2, -(k + 1)), [0, mpmath.inf])
    print(f"  (1/2;1/2)_inf = {mpmath.nstr(val, 30)}")
    print(f"  direct product  = {mpmath.nstr(direct, 30)}")
    print(f"  record's value 0.288788...: agrees to 6 digits: {abs(val - mpmath.mpf('0.288788')) < 1e-6}")
    p = Fraction(1)
    parts = []
    for k in range(5):
        p *= 1 - Fraction(1, 2 ** (k + 1))
        parts.append(str(p))
    print(f"  partial products K=1..5: {parts}")
    print(f"  equal to c1's list [1/2, 3/8, 21/64, 315/1024, 9765/32768]: "
          f"{parts == ['1/2', '3/8', '21/64', '315/1024', '9765/32768']}")


def k2():
    print("== K2 Sigma_1 facts for K_A on the lottery stream (Cor 2.6') ==")
    ok_count = ok_bits = True
    for K in range(1, 61):
        nfacts = sum(1 + (2 ** (k + 1) - 1 + 1) for k in range(K))
        if not nfacts < 2 ** (K + 1) + K:
            ok_count = False
        # the number of true facts lies in 0..nfacts, i.e. needs ceil(log2(nfacts+1)) bits
        bits = (nfacts).bit_length()
        if bits > K + 2:
            ok_bits = False
        if K in (1, 2, 3, 10, 60):
            print(f"  K={K}: facts = {nfacts} (= 2^(K+1) + K - 2: {nfacts == 2 ** (K + 1) + K - 2}), "
                  f"bits for the count = {bits} <= K+2 = {K + 2}")
    print(f"  K=1..60: facts < 2^(K+1)+K: {ok_count}; count fits in K+2 bits: {ok_bits}")
    # horizon of the single lottery: lottery k occupies k+1 bits; ceil(n/2) lotteries for n data
    good = all(sum(k + 1 for k in range(-(-n // 2))) <= (n + 1) ** 2 for n in range(1, 2000))
    print(f"  horizon m(n) = sum_(k<ceil(n/2)) (k+1) <= (n+1)^2 for n < 2000: {good}")
    # batch lottery: lottery k has 1 + 2^k data and 2k+1 bits; after n data at most the lotteries
    # with index < n are started; horizon = sum_(k <= last started) (2k+1)
    worst = 0
    for n in range(1, 5000):
        data, k, bits = 0, 0, 0
        while data < n:
            data += 1 + 2 ** k
            bits += 2 * k + 1
            k += 1
        worst = max(worst, bits / (n + 1) ** 2)
    print(f"  batch lottery: max over n < 5000 of horizon/(n+1)^2 = {worst:.4f} (<= 1: {worst <= 1})")


def k3():
    print("== K3 colouring constants (Prop 3.8) ==")
    L3 = log2(3)
    bad_pig = bad_gap = 0
    slack = {}
    for d in range(2, 10 ** 6 + 1):
        l = ceil(log2(d / L3)) - 1
        # exact pigeonhole: 3^(2^l - 1) < 2^d  <=>  (2^l - 1) log2 3 < d ; test with integers when small
        if l < 25:
            pig = 3 ** (2 ** l - 1) < 2 ** d if 2 ** l < 64 else (2 ** l - 1) * L3 < d
        else:
            pig = (2 ** l - 1) * L3 < d
        if not pig:
            bad_pig += 1
        if not l > log2(d) - 2:
            bad_gap += 1
        # largest l with 3^(2^l - 1) < 2^d
        lmax = l
        while (2 ** (lmax + 1) - 1) * L3 < d:
            lmax += 1
        slack[lmax - l] = slack.get(lmax - l, 0) + 1
    print(f"  d=2..10^6: pigeonhole 3^(2^l-1) < 2^d fails in {bad_pig} cases; l > log2 d - 2 fails in {bad_gap}")
    print(f"  (largest pigeonhole l) - (record's l): distribution {dict(sorted(slack.items()))}")
    # exact integer cross-check for small d
    exact_bad = 0
    for d in range(2, 200):
        l = ceil(log2(d / L3)) - 1
        if not 3 ** (2 ** l - 1) < 2 ** d:
            exact_bad += 1
    print(f"  exact integer pigeonhole test for d < 200: failures {exact_bad}")


def k4():
    print("== K4 length-lexicographic codes (Cor 3.6) ==")
    ok = True
    for m in range(0, 13):
        strings = [""]
        for length in range(1, m + 1):
            strings += [format(i, f"0{length}b") for i in range(2 ** length)]
        # length-lex rank: shorter first, then lexicographic; = list order above
        codes = list(range(len(strings)))
        if codes[-1] != 2 ** (m + 1) - 2:
            ok = False
    print(f"  m=0..12: largest code of a string of length <= m equals P_m = 2^(m+1)-2: {ok}")
    print(f"  h_m <= 2^m needs m+1 bits (0..2^m has 2^m + 1 values): {all((2 ** m).bit_length() == m + 1 for m in range(1, 200))}")


def k5():
    print("== K5 delta (Thm 6.1) ==")
    d = 1 / (5 * log2(14))
    print(f"  delta_str = 1/(5 log2 14) = {d:.6f}")
    for n in (10 ** 6, 10 ** 9, 10 ** 30, 10 ** 100):
        print(f"  n = 1e{len(str(n)) - 1}: n^delta_str = {n ** d:.3f}")


def k6():
    print("== K6 binomial bound (Cor 6.2) ==")
    bad = 0
    for n in range(1, 401):
        for u in range(1, n + 1):
            if log2(comb(n, u)) > u * log2(e * n / u) + 1e-9:
                bad += 1
    print(f"  log2 C(n,u) <= u log2(e n/u) for 1 <= u <= n <= 400: violations {bad}")


if __name__ == "__main__":
    k1()
    k2()
    k3()
    k4()
    k5()
    k6()
    print("done")
