"""Checks for small-learner-width.md (Proposition 6.1 of red-team.md, corrected).

(1) The exact class bound Exc of Corollary 2, eq. (5.1), is at most the simplified bound (5.2) of
    Corollary 3, on a large parameter grid (mpmath, n up to 1e300).
(2) Lambda_N <= (H+5) ln(2n) under the hypotheses of Corollary 3 (step 4 of the proof of (5.2)).
    Lambda_N is the logarithm of Section 1 (the log-cardinality per coordinate of the grid of Lemma D).
(3) Log-log slopes of Exc (Bernstein form) and of the Hoeffding form (Remark 5), for learner and
    competitor width n^a and competitor weights n^w (w is the weight exponent omega of Corollary 3(ii)).
(4) Values of both forms in case (i) of Corollary 3 (Remark 5 and Section 5).
(5) The A2 setting of red-team.md (Corollary 3(iii)): Bbar = 1, d = 10, N = floor(n^(1/2-eps)).
(6) The constant of Corollary 3(i): for 0 < a < 1/4,
    sup_{t >= 1} t^(-a) sqrt(ln 2t) = 2^a / sqrt(2 e a)   (attained at ln 2t = 1/(2a)), and in case (i)
    (5.2) <= C_{L,a,delta} n^(2a-1/2),
    C_{L,a,delta} = 5 sqrt(2) sqrt(l) + 4 sqrt((2H+1)(H+5)) 2^a / sqrt(2 e a) + (8L-1)(1+l),  l = ln(4/delta).
Run: python3 check_explicit_bound.py > check_explicit_bound.out
"""
import itertools
import mpmath as mp

mp.mp.dps = 60


def lam(n, N, d, H, c=1):
    K = mp.mpf(n) / c + 1
    return mp.log(2 + 2 * n * mp.sqrt(K * N) * H * (d + N + 1) * (K + 1) ** (mp.mpf(H) / 2))


def dev(n, N, d, H, delta, c=1):
    P = N * (d + 1) + (H - 1) * N ** 2 + N
    return 4 * mp.sqrt((P * lam(n, N, d, H, c) + mp.log(4 / mp.mpf(delta))) / (2 * n))


def exc(n, N, d, H, Bbar, delta, form="bernstein", c=1):
    """Exact excess bound of Corollary 2 (class version), competitor width bound = N."""
    L = H + 1
    l = mp.log(4 / mp.mpf(delta))
    Estar = d * (d + 1) * Bbar ** 2 + 2 * (L - 1) * N ** 2 * Bbar ** 2
    U1 = N * Bbar + 1
    base = c * (Estar + 1) / n + mp.mpf(4) / n + dev(n, N, d, H, delta, c)
    if form == "bernstein":
        return base + U1 * mp.sqrt(2 * l / n) + 2 * U1 ** 2 * l / (3 * n)
    return base + U1 ** 2 * mp.sqrt(l / (2 * n))


def simple(n, alpha, H, Bbar, delta):
    L = H + 1
    l = mp.log(4 / mp.mpf(delta))
    a = mp.mpf(alpha)
    return (5 * mp.sqrt(2) * Bbar * n ** (a - mp.mpf(1) / 2) * mp.sqrt(l)
            + 4 * mp.sqrt((2 * H + 1) * (H + 5)) * n ** (a - mp.mpf(1) / 2) * mp.sqrt(mp.log(2 * n))
            + (8 * L - 1) * (1 + l) * Bbar ** 2 * n ** (2 * a - 1))


def main():
    ns = [2, 3, 5, 10, 30, 100, 10**3, 10**4, 10**6, 10**9, 10**12, 10**20, 10**40, 10**80, 10**150, 10**300]
    alphas = [0, 0.01, 0.05, 0.1, 0.124, 0.125, 0.2, 0.249, 0.25, 0.3, 0.4, 0.45, 0.49, 0.4999]
    Hs = [1, 2, 3, 4, 6]
    deltas = [1e-9, 0.01, 0.05, 0.5, 0.99]
    worst_ratio = mp.mpf(0)
    worst_lam = mp.mpf(0)
    count = 0
    for n, alpha, H, delta in itertools.product(ns, alphas, Hs, deltas):
        n = mp.mpf(n)
        na = n ** mp.mpf(alpha)
        Ns = sorted({1, int(mp.floor(na)), int(mp.ceil(na)), int(mp.floor(2 * na))})
        Ns = [N for N in Ns if 1 <= N <= 2 * na]
        ds = sorted({1, int(mp.floor(na))})
        Bbars = [mp.mpf(1), na, n ** mp.mpf(0.3), mp.mpf(100), n ** mp.mpf(0.6)]
        for N, d, Bbar in itertools.product(Ns, ds, Bbars):
            if d > na or Bbar < 1:
                continue
            e = exc(n, N, d, H, Bbar, delta)
            s = simple(n, alpha, H, Bbar, delta)
            r = e / s
            worst_ratio = max(worst_ratio, r)
            lr = lam(n, N, d, H) / ((H + 5) * mp.log(2 * n))
            worst_lam = max(worst_lam, lr)
            count += 1
    print("(1) cases checked:", count)
    print("    max Exc / simplified bound = %s  (must be <= 1)" % mp.nstr(worst_ratio, 6))
    print("(2) max Lambda_N / ((H+5) ln 2n) = %s  (must be <= 1)" % mp.nstr(worst_lam, 6))

    print("(3) local slopes d ln(term)/d ln n between n=1e100 and 1e200; L=3, delta=0.05, N=ceil(n^a), d=floor(n^a), Bbar=n^w")
    H, delta = 2, 0.05
    for alpha, omega in [(0.05, 0.05), (0.1, 0.1), (0.125, 0.125), (0.15, 0.15), (0.2, 0.2), (0.24, 0.24),
                         (0.4, 0.0), (0.45, 0.0), (0.3, 0.15), (0.3, 0.25)]:
        sl = {}
        for form in ["bernstein", "hoeffding"]:
            vals = []
            for n in [mp.mpf(10) ** 100, mp.mpf(10) ** 200]:
                na = n ** mp.mpf(alpha)
                N = int(mp.ceil(na))
                d = int(mp.floor(na))
                Bbar = n ** mp.mpf(omega)
                vals.append(exc(n, N, d, H, Bbar, delta, form))
            sl[form] = (mp.log(vals[1]) - mp.log(vals[0])) / (100 * mp.log(10))
        print("    alpha=%.3f omega=%.3f  Bernstein-form slope %+.4f (pred max(a+w-1/2, a-1/2, 2a+2w-1) = %+.4f)"
              "  Hoeffding-form slope %+.4f (pred 2a+2w-1/2 = %+.4f)" % (
                  alpha, omega, float(sl["bernstein"]), max(alpha + omega - 0.5, alpha - 0.5, 2 * alpha + 2 * omega - 1),
                  float(sl["hoeffding"]), 2 * alpha + 2 * omega - 0.5))

    print("(4) values of Exc (Bernstein form) and Hoeffding form; L=3, delta=0.05, N=ceil(n^a), d=floor(n^a), Bbar=n^a")
    for alpha in [0.1, 0.2, 0.24]:
        for n in [mp.mpf(10) ** 6, mp.mpf(10) ** 12, mp.mpf(10) ** 20, mp.mpf(10) ** 40, mp.mpf(10) ** 100]:
            na = n ** mp.mpf(alpha)
            N = int(mp.ceil(na)); d = int(mp.floor(na))
            e_b = exc(n, N, d, 2, na, 0.05, "bernstein")
            e_h = exc(n, N, d, 2, na, 0.05, "hoeffding")
            print("    alpha=%.2f n=1e%-3d  Exc_Bernstein=%s  Exc_Hoeffding=%s  simplified=%s" % (
                alpha, int(mp.log10(n)), mp.nstr(e_b, 4), mp.nstr(e_h, 4), mp.nstr(simple(n, alpha, 2, na, 0.05), 4)))

    print("(5) A2 setting: Bbar=1 (fixed), d=10, N=floor(n^(1/2-eps)), L=3, delta=0.05")
    for eps in [0.1, 0.2]:
        for n in [mp.mpf(10) ** 20, mp.mpf(10) ** 40, mp.mpf(10) ** 80]:
            N = int(mp.floor(n ** (mp.mpf(0.5) - eps)))
            e_b = exc(n, N, 10, 2, mp.mpf(1), 0.05, "bernstein")
            e_h = exc(n, N, 10, 2, mp.mpf(1), 0.05, "hoeffding")
            print("    eps=%.1f n=1e%-3d  Exc_Bernstein=%s  Exc_Hoeffding=%s" % (
                eps, int(mp.log10(n)), mp.nstr(e_b, 4), mp.nstr(e_h, 4)))


def const_check():
    """(6) The constant C_{L,a,delta} of Corollary 3(i)."""
    print("(6) constant of Corollary 3(i), 0 < a < 1/4")
    worst_sup = mp.mpf(0)
    violations = 0
    at_star = []
    grid = [mp.mpf(10) ** (mp.mpf(k) / 20) for k in range(0, 20 * 420 + 1)]  # t from 1 to 1e420
    for a in [0.001, 0.005, 0.01, 0.05, 0.1, 0.15, 0.2, 0.24, 0.249, 0.2499]:
        a = mp.mpf(a)
        bound = 2 ** a / mp.sqrt(2 * mp.e * a)
        tstar = mp.exp(1 / (2 * a)) / 2
        val_star = tstar ** (-a) * mp.sqrt(mp.log(2 * tstar))
        at_star.append(val_star / bound)
        for t in grid:
            r = t ** (-a) * mp.sqrt(mp.log(2 * t)) / bound
            worst_sup = max(worst_sup, r)
            if r > 1 + mp.mpf(10) ** (-40):
                violations += 1
    print("    (6a) over 10 values of a and %d grid points t in [1, 1e420]: max of t^(-a) sqrt(ln 2t) / (2^a/sqrt(2 e a))"
          " = 1 - %s; grid points with ratio > 1 + 1e-40: %d" % (len(grid), mp.nstr(1 - worst_sup, 3), violations))
    print("         value at the critical point t* = e^(1/(2a))/2 divided by the bound: min 1 - %s, max 1 + %s"
          % (mp.nstr(1 - min(at_star), 3), mp.nstr(max(at_star) - 1, 3)))
    ns = [2, 3, 5, 10, 30, 100, 10**3, 10**4, 10**6, 10**9, 10**12, 10**20, 10**40, 10**80, 10**150, 10**300]
    alphas = [0.001, 0.01, 0.05, 0.1, 0.124, 0.125, 0.15, 0.2, 0.24, 0.249, 0.2499]
    worst_s, worst_e, count = mp.mpf(0), mp.mpf(0), 0
    for n, alpha, H, delta in itertools.product(ns, alphas, [1, 2, 3, 4, 6], [1e-9, 0.01, 0.05, 0.5, 0.99]):
        n = mp.mpf(n); a = mp.mpf(alpha); L = H + 1
        l = mp.log(4 / mp.mpf(delta))
        C = (5 * mp.sqrt(2) * mp.sqrt(l) + 4 * mp.sqrt((2 * H + 1) * (H + 5)) * 2 ** a / mp.sqrt(2 * mp.e * a)
             + (8 * L - 1) * (1 + l))
        target = C * n ** (2 * a - mp.mpf(1) / 2)
        na = n ** a
        worst_s = max(worst_s, simple(n, alpha, H, na, delta) / target)
        N = int(mp.ceil(na)); d = max(1, int(mp.floor(na)))
        worst_e = max(worst_e, exc(n, N, d, H, na, delta) / target)
        count += 1
    print("    (6b) case (i), %d combinations (n from 2 to 1e300, 0.001 <= a <= 0.2499, H <= 6, delta from 1e-9 to 0.99):"
          % count)
    print("         max (5.2) / (C n^(2a-1/2)) = %s; max Exc / (C n^(2a-1/2)) = %s  (both must be <= 1)"
          % (mp.nstr(worst_s, 6), mp.nstr(worst_e, 6)))


if __name__ == "__main__":
    main()
    const_check()
