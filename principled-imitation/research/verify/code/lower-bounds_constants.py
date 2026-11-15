#!/usr/bin/env python3
"""Referee's recomputation of the constants in research/prove/lower-bounds.md
and in Section 4 of note.md.  Every inequality that the proofs obtain by a
chain of simplifications is evaluated on a grid in its exact form; the script
stops at the first violation.  Exact rational arithmetic is used where a
claim is an identity.
"""
import itertools, math, random
from fractions import Fraction as Fr
from math import comb, log, log2, sqrt, e


def p_hit(L, N):
    return 1 - (1 - 1 / N) ** L


def c_def20():
    for N0 in range(1, 200):
        for L in range(1, 60):
            p = p_hit(L, N0)
            assert (L / N0) * (1 - L / (2 * N0)) <= p + 1e-12 <= L / N0 + 2e-12
    print("Definition 2.0: (L/N0)(1 - L/(2N0)) <= p <= L/N0 on 1 <= N0 < 200, 1 <= L < 60")


def c_cor22():
    worst1 = worst2 = worst3 = 1e9
    for L in range(1, 40):
        for k in range(1, 400):                 # N0 = L k, delta = 1/(2k)
            delta = 1 / (2 * k)
            N0 = L * k
            exact = max(0.0, N0 - delta * (N0 + L) / p_hit(L, N0))   # n >= 0 always
            claim = L / (4 * delta) - L
            assert exact >= claim - 1e-9, (L, delta)
            if delta <= 0.25:
                worst1 = min(worst1, exact - claim)
        for i in range(1, 400):                 # item 2: any delta <= 1/6
            delta = i / 2400
            N0 = math.ceil(L / (2 * delta) - 1e-12)
            exact = max(0.0, N0 - delta * (N0 + L) / p_hit(L, N0))
            claim = L / (4 * delta) - 1.5 * L
            assert exact >= claim - 1e-9, (L, delta)
            worst2 = min(worst2, exact - claim)
        for k in range(1, 400):                 # item 3: N0 = L/eps, delta = eps/4
            eps = 1 / k
            N0 = L * k
            exact = max(0.0, N0 - (eps / 4) * (N0 + L) / p_hit(L, N0))
            claim = 0.75 * (1 - eps) / (1 - eps / 2) * L / eps
            assert exact >= claim - 1e-9, (L, eps)
            assert claim >= 0.75 * (1 - eps) * L / eps - 1e-9
            worst3 = min(worst3, exact - claim)
    print(f"Corollary 2.2: items 1, 2, 3 hold on the grid (least slack {worst1:.3f}, {worst2:.3f}, {worst3:.3f})")
    # how much item 1 leaves on the table: exact bound / (L/(4 delta))
    for L, delta in ((1, 0.05), (4, 0.05), (4, 0.01), (10, 0.01)):
        N0 = round(L / (2 * delta))
        exact = N0 - delta * (N0 + L) / p_hit(L, N0)
        print(f"   L={L} delta={delta}: N0 - delta(N0+L)/p = {exact:.2f};  L/(4delta) - L = {L/(4*delta)-L:.2f};"
              f"  Prop 2.3 protocol needs {math.ceil(N0 * (1 - delta / p_hit(L, N0)))}")


def c_prop23():
    for L in range(1, 30):
        for k in range(1, 200):
            delta = 1 / (2 * k); N0 = L * k
            n = math.ceil(L / (4 * delta) - 1e-12)
            assert n <= N0 and (1 - n / N0) * p_hit(L, N0) <= delta + 1e-12
    print("Proposition 2.3: n = ceil(L/(4 delta)) questions give failure (1 - n/N0) p <= delta when N0 = L/(2 delta)")


def c_prop25():
    worst = 1e9
    for L in range(1, 60):
        for i in range(1, 500):
            delta = i / 1000
            N0 = math.ceil(L / sqrt(2 * delta) - 1e-12)
            exact = N0 * p_hit(L, N0) - delta * (N0 + L)
            claim = L * (1 - sqrt(2 * delta) - delta) - delta
            assert exact >= claim - 1e-9, (L, delta, exact, claim)
            worst = min(worst, exact - claim)
    print(f"Proposition 2.5: N0 p - delta(N0+L) >= L(1 - sqrt(2 delta) - delta) - delta for N0 = ceil(L/sqrt(2 delta)) (least slack {worst:.4f})")


def c_thm31():
    for N in range(1, 60):
        for k in range(0, N + 1):
            lhs = Fr(sum(range(1, k + 1)) + (N - k) * k, N)
            assert lhs == Fr(k) - Fr(k * (k - 1), 2 * N)
            kap = Fr(k, N)
            assert lhs >= N * (kap - kap * kap / 2) >= N * kap / 2
    for L in range(1, 40):
        for k in range(1, 400):
            delta = 1 / (2 * k); N = L * k
            exact = (N / 2) * (1 - 2 * L / N - delta / p_hit(L, N))
            claim = (1 - 10 * delta) * L / (8 * delta)
            assert exact >= claim - 1e-9
    print("Theorem 3.1: step 1 identity and inequalities (exact arithmetic); step 4: (N/2)(1 - 2L/N - delta/p) >= (1-10 delta)L/(8 delta)")


def c_prop32():
    for N in range(2, 300):
        mean = Fr(sum(min(a, N - 1) for a in range(1, N + 1)), N)
        assert mean == Fr((N - 1) * (N + 2), 2 * N) <= Fr(N + 1, 2)
    print("Proposition 3.2: E min(a, N-1) = (N-1)(N+2)/(2N) <= (N+1)/2 (exact)")


def c_thm33():
    worst = 0
    u = 4.0
    while u < 200:
        gamma = u * 2 ** (-u)
        assert gamma <= 0.25 + 1e-15
        assert u - log2(u) >= u / 2 - 1e-12
        const = u / (u - log2(u)) + log(2)
        assert const <= 2.7
        worst = max(worst, const)
        u += 0.01
    print(f"Theorem 3.3(3): for u >= 4: gamma <= 1/4, u - log u >= u/2, u/(u - log u) + ln 2 <= {worst:.4f} <= 2.7"
          f" (limit 1 + ln 2 = {1 + log(2):.4f})")
    # the count itself: n_B + K ln2/gamma <= 1 + const K L/(eps u)
    rng = random.Random(1)
    for _ in range(20000):
        L = rng.randint(1, 500); eps = rng.uniform(1e-6, min(1.0, L / 16)); K = rng.uniform(0.01, 5000)
        u = log2(L / eps)
        if u < 4:
            continue
        gamma = u * eps / L
        nB = math.ceil(L * K / (eps * (u - log2(u))))
        total = nB + K * log(2) / gamma
        assert total <= 1 + 2.7 * K * L / (eps * u) + 1e-6 * total
        assert L * K / (nB * log2(1 / gamma)) <= eps * (1 + 1e-12)
    print("   question count n_B + K ln2/gamma <= 1 + 2.7 K L/(eps log2(L/eps)) and failure bound <= eps on 20000 random (L, eps, K)")


def c_rem35():
    for L in range(1, 80):
        for N0 in range(1, L + 1):
            p = p_hit(L, N0)
            assert p >= 1 - 1 / e - 1e-12
        for delta in (0.001, 0.01, 0.05, 0.1, 0.125):
            for N0 in range(1, L + 1):
                assert delta * (N0 + L) / p_hit(L, N0) <= 3.2 * delta * L
            for N0 in range(L, int(L / (8 * delta)) + 1):
                assert N0 - delta * (N0 + L) / p_hit(L, N0) >= N0 / 2 - 1e-9
    print("Remark 3.5: both numerical claims hold on the grid")


def c_thm41():
    # exact success probabilities of the protocol of Theorem 4.1(3)
    for N in range(1, 7):
        for n in range(0, N + 1):
            subsets = list(itertools.combinations(range(N), n))
            for i in range(N):
                # member f_0 and member f_i under shift i
                s0 = Fr(sum(1 if i in I else Fr(1, 2) for I in subsets), len(subsets))
                assert s0 == Fr(1, 2) + Fr(n, 2 * N)
                for j in range(N):
                    if j == i:
                        continue
                    sj = Fr(sum(1 if (i in I or j in I) else Fr(1, 2) for I in subsets), len(subsets))
                    assert sj >= Fr(1, 2) + Fr(n, 2 * N)
    print("Theorem 4.1(3): the protocol's success probabilities are 1/2 + n/(2N) (f_0, f_i) and at least that (f_j), exactly, N <= 6")


def c_thm53():
    for m in range(0, 6):
        for B in range(1, 10):
            for k in range(1, 30):
                delta = Fr(1, 2 * k)
                L = B * (2 * m + 1)
                assert Fr(B) / (4 * delta) - B == (1 - 4 * delta) * L / (4 * (2 * m + 1) * delta)
    print("Theorem 5.3(3): B/(4 delta) - B = (1 - 4 delta) L/(4 (2m+1) delta) (exact)")


def c_ex55_prop54():
    for L in range(1, 200):
        for i in range(0, 101):
            beta = i / 100
            assert 1 - (1 - beta / L) ** L >= beta - beta * beta / 2 - 1e-12
    for Bp in (1, 3, 10):
        for delta in (0.01, 0.1):
            best = max(N * (1 - delta * N / Bp) for N in range(1, 5000))
            assert best <= Bp / (4 * delta) + 1e-9
    print("Example 5.5: 1 - (1 - beta/L)^L >= beta - beta^2/2;  Proposition 5.4(c): max_N N(1 - delta N/B') <= B'/(4 delta)")


def kl_bern(a, b):
    return a * log(a / b) + (1 - a) * log((1 - a) / (1 - b))


def binom_pmf(L, p):
    return [comb(L, k) * p ** k * (1 - p) ** (L - k) for k in range(L + 1)]


def tv_binom(L, t):
    a, b = binom_pmf(L, 0.5 + t), binom_pmf(L, 0.5 - t)
    return 0.5 * sum(abs(x - y) for x, y in zip(a, b))


def c_sec6():
    for i in range(1, 2501):
        th = i / 10000                                   # theta in (0, 1/4]
        k = kl_bern(0.5 + th, 0.5 - th)
        assert abs(k - 2 * th * log((1 + 2 * th) / (1 - 2 * th))) < 1e-12
        assert k <= 16 * th * th + 1e-15
        assert abs(log((0.5 + th) / (0.5 - th))) <= log(3) + 1e-12
    # Theorem 6.1, consequences
    for q in (0.5, 1, 7, 100, 12345):                    # q = n/K
        th = sqrt(1 / (32 * q))
        assert th <= 0.25 + 1e-15
        val = (th / 2) * (1 - th * sqrt(8 * q))
        assert abs(val - sqrt(1 / q) / (16 * sqrt(2))) < 1e-12
    for i in range(1, 626):
        ep = i / 10000                                   # eps' in (0, 1/16]
        nq = 1 / (512 * ep * ep)                         # n/K at the threshold
        th = 4 * ep
        assert abs((th / 2) * (1 - th * sqrt(8 * nq)) - ep) < 1e-12
    print("Theorem 6.1: kl(theta) <= 16 theta^2 on (0, 1/4]; consequence 1 equals sqrt(K/n)/(16 sqrt 2); threshold of consequence 2 is K/(512 eps'^2)")
    # Lemma 6.2
    worst_all = worst_odd = 1e9
    for L in list(range(1, 80)) + [101, 150, 200, 301, 400]:
        for i in range(1, 400):
            t = i / 400 / sqrt(2 * L)
            tv = tv_binom(L, t)
            base = t * sqrt(L) * (1 - 2 * L * t * t)
            worst_all = min(worst_all, tv / base)
            if L % 2 == 1:
                worst_odd = min(worst_odd, tv / (sqrt(2) * base))
    assert worst_all >= 1 and worst_odd >= 1
    # where the smallest ratio sits: L = 2 (the file's Section 8 says L = 1)
    def min_ratio(L):
        return min(tv_binom(L, i / 400 / sqrt(2 * L)) /
                   ((i / 400 / sqrt(2 * L)) * sqrt(L) * (1 - 2 * L * (i / 400 / sqrt(2 * L)) ** 2)) for i in range(1, 400))
    assert abs(min_ratio(2) - sqrt(2)) < 1e-3 and min_ratio(1) >= 2 - 1e-9
    print(f"   smallest ratio by L: L=1: {min_ratio(1):.4f}, L=2: {min_ratio(2):.4f}, L=3: {min_ratio(3):.4f}, L=4: {min_ratio(4):.4f}"
          " (the minimum sqrt 2 is at L = 2, so the sqrt(2L) form is attained there in the limit)")
    for j in range(1, 2000):
        assert comb(2 * j, j) / 4 ** j >= 1 / (2 * sqrt(j)) - 1e-15
    print(f"Lemma 6.2: TV/(theta sqrt(L)(1 - 2 L theta^2)) >= {worst_all:.4f}; odd L, against sqrt(2L): >= {worst_odd:.4f}; C(2j,j)4^-j >= 1/(2 sqrt j), j < 2000")
    # Theorem 6.3, consequences
    for L in (1, 4, 9, 64):
        for q in (max(0.5, L / 8), 10 * L, 1000 * L):   # q = n/K >= max(1/2, L/8)
            th = sqrt(1 / (32 * q))
            val = (th * sqrt(L) / 4) * (1 - 2 * L * th * th) * (1 - th * sqrt(8 * q))
            assert val >= sqrt(L / q) / (64 * sqrt(2)) - 1e-12
        for i in range(1, 157):
            ep = i / 10000                               # eps in (0, 1/64]
            th = 16 * ep / sqrt(L)
            assert th <= 0.25 + 1e-12 and 2 * L * th * th <= 0.5
            nq = L / (8192 * ep * ep)
            val = (th * sqrt(L) / 4) * (1 - 2 * L * th * th) * (1 - th * sqrt(8 * nq))
            assert val >= ep - 1e-12                     # at the threshold the bound is still >= eps
    print("Theorem 6.3: consequence 1 >= sqrt(L K/n)/(64 sqrt 2); consequence 2: at n = L K/(8192 eps^2) the bound is still >= eps")
    # Theorem 6.3 against a protocol: q questions at each input, deploy Bern(1/2 +- theta) with the MAP sign.
    print("   Theorem 6.3 against the equal-allocation protocol (exact): lower bound <= E TV")
    for L, q in ((1, 4), (5, 16), (9, 64), (21, 64), (21, 256)):
        th = sqrt(1 / (32 * q))
        pm = binom_pmf(q, 0.5 + th)
        wrong = sum(pm[k] for k in range(q + 1) if 2 * k < q) + 0.5 * sum(pm[k] for k in range(q + 1) if 2 * k == q)
        tau = tv_binom(L, th)
        lb = (tau / 4) * (1 - th * sqrt(8 * q))
        assert lb <= tau * wrong + 1e-12
        print(f"      L={L:3d} n/K={q:4d} theta={th:.4f}: bound {lb:.5f} <= {tau * wrong:.5f}")


def c_thm63_sign():
    """The display of Theorem 6.3 is a chain  avg Err >= A >= C  with
    A = (tau_L/4)(1 - theta sqrt(8n/K)),  C = (theta sqrt(L)/4)(1 - 2 L theta^2)(1 - theta sqrt(8n/K)).
    If both brackets of C are negative, C is positive and is NOT a lower bound."""
    K, th, L, n = 1, 0.25, 16, 8
    A = (tv_binom(L, th) / 4) * (1 - th * sqrt(8 * n / K))
    C = (th * sqrt(L) / 4) * (1 - 2 * L * th * th) * (1 - th * sqrt(8 * n / K))
    pm = binom_pmf(n, 0.5 + th)
    wrong = sum(pm[k] for k in range(n + 1) if 2 * k < n) + 0.5 * pm[n // 2]
    err = tv_binom(L, th) * wrong            # protocol: n questions at the one input, deploy the MAP sign
    assert A < 0 < err < C
    print(f"Theorem 6.3, display: K={K}, theta={th}, L={L}, n={n}: A = {A:.4f} (valid, negative), C = {C:.4f},"
          f" but a protocol has Err = {err:.4f} < C: the second inequality needs 1 - theta sqrt(8n/K) >= 0")


def c_thm71_and_note():
    for i in range(1, 501):
        delta = i / 10000                                # (0, 1/20]
        assert 1 / (4 * delta) - 1 >= 4 - 1e-12
        for L in (1, 2, 7, 100):
            assert log2(L / (2 * delta) + 1) <= log2(L / delta) + 1e-12
    # note.md, proof of N2
    for L in range(1, 60):
        for i in range(1, 126):
            gamma = i / 2000                             # (0, 1/16]
            N = math.ceil(L / (8 * gamma) - 1e-12)
            u = L / N
            assert u <= 0.5 + 1e-12
            qq = p_hit(L, N)
            assert qq >= 1 - math.exp(-u) - 1e-12 >= u * (1 - u / 2) - 2e-12 >= 0.75 * u - 3e-12
            # if (3/8)(L/N)(1 - n/N) <= gamma then n > N/2 >= L/(16 gamma)
            n_min = N * (1 - (8 * gamma / 3) * (N / L))
            assert n_min > N / 2 - 1e-9 and N / 2 >= L / (16 * gamma) - 1e-9
            assert 2 * N < L / (4 * gamma) + 2 + 1e-9    # K <= log2(L/(4 gamma) + 2)
    print("Theorem 7.1(A) arithmetic; note.md Theorem N2: every step of the proof on the grid gamma in (0, 1/16], L < 60")


def c_cor17():
    rng = random.Random(5)
    for _ in range(200000):
        # R, R' laws on {f(x), f'(x), other, abstain}
        a = [rng.random() for _ in range(4)]; s = sum(a); R = [v / s for v in a]
        b = [max(0.0, v + rng.uniform(-0.2, 0.2)) for v in R]; s = sum(b); Rp = [v / s for v in b]
        gamma = 0.5 * sum(abs(x - y) for x, y in zip(R, Rp))
        s_f = 1 - R[0] - R[3]; s_fp = 1 - Rp[1] - Rp[3]
        assert s_f + s_fp >= 1 - gamma - min(R[3], Rp[3]) - 1e-12
        assert (1 - R[0]) + (1 - Rp[1]) >= 1 - gamma - 1e-12        # Theorem 1.6(4)
    print("Theorem 1.6(4) and Corollary 1.7: the two inequalities hold for 200000 random pairs of answer laws at their exact TV")


if __name__ == "__main__":
    c_def20(); c_cor22(); c_prop23(); c_prop25(); c_thm31(); c_prop32(); c_thm33(); c_rem35()
    c_thm41(); c_thm53(); c_ex55_prop54(); c_sec6(); c_thm63_sign(); c_thm71_and_note(); c_cor17()
    print("all checks passed")
