"""Referee's checks of Section 4 of research/prove-c/one-mind.md (the trap scaffold; R5). Exact computations only.

(A) Class A, Proposition 4.2(a),(b): the law of the number C of unfaithful calls of a run, by enumeration of
    all top-level inputs (and all answer patterns for the mixture), for small N and L, against the formulas.
(B) Class A, the one-round removal probabilities of both drivers by enumeration, against closed forms that the
    referee derived independently; then the exact law of k after n = N rounds, E[k] against the stated bound,
    and Proposition 4.2(c) on a grid (all L <= sqrt(N)).
(C) Corollary 4.4(a): the constants.
(D) Class B, Proposition 4.3(b): exact law of C for the mixture, against the stated bound, on a grid.
(E) Class B, Proposition 4.3(a): the chain of inequalities on a grid, and the exact failure of one natural rule.
(F) Remark 4.5 and Corollary 4.4(b): g_0 in class B; the plurality; which sets of good runs make (b) exact.
Usage: python3 one-mind_check_traps.py
"""
import itertools
import math
from math import comb


# ---------------------------------------------------------------- (A)
def law_C_draw_enum(N, L, k):
    """Posterior draw per run, class A, U = {0..k-1}: exact law of C by enumeration of z and the driver."""
    law = [0.0] * (L + 1)
    for z in itertools.product(range(N), repeat=L):
        pz = N ** (-L)
        law[0] += pz * N / (N + k)                       # driver g_0
        for d in range(k):                               # driver g_d
            flag, c = -1, 0
            for a in z:
                ans = (a == d) if flag < 0 else (flag == d)
                if ans:
                    c += 1                               # the human g_0 answers 0 everywhere
                    if flag < 0:
                        flag = a
            law[c] += pz / (N + k)
    return law


def law_C_mix_enum(N, L, k):
    """Per-call mixture, class A, U = {0..k-1}: exact law of C by enumeration of z and of the answers."""
    law = [0.0] * (L + 1)
    q = 1.0 / (N + k)

    def rec(z, j, flag, c, p):
        if j == L:
            law[c] += p
            return
        a = z[j]
        target = a if flag < 0 else flag                 # the one trap that answers 1 at this input
        p1 = q if target < k else 0.0                    # ... if it is still in the posterior
        if p1 > 0:
            rec(z, j + 1, a if flag < 0 else flag, c + 1, p * p1)
        rec(z, j + 1, flag, c, p * (1 - p1))

    for z in itertools.product(range(N), repeat=L):
        rec(z, 0, -1, 0, N ** (-L))
    return law


def law_C_draw_formula(N, L, k):
    law = [0.0] * (L + 1)
    for i in range(1, L + 1):
        law[L - i + 1] = k / (N + k) * (1 - 1 / N) ** (i - 1) / N
    law[0] = 1 - sum(law)
    return law


def law_C_mix_formula(N, L, k):
    law = [0.0] * (L + 1)
    e0, q = k / (N * (N + k)), 1.0 / (N + k)
    for tau in range(1, L + 1):
        for b in range(L - tau + 1):
            law[1 + b] += (1 - e0) ** (tau - 1) * e0 * comb(L - tau, b) * q ** b * (1 - q) ** (L - tau - b)
    law[0] = (1 - e0) ** L
    return law


def part_A():
    print("(A) class A, law of C: enumeration against the formulas of Proposition 4.2(a),(b)")
    worst = 0.0
    cases = 0
    for N, L in ((2, 3), (3, 4), (4, 4), (3, 6), (5, 3)):
        for k in range(N + 1):
            d1, d2 = law_C_draw_enum(N, L, k), law_C_draw_formula(N, L, k)
            m1, m2 = law_C_mix_enum(N, L, k), law_C_mix_formula(N, L, k)
            worst = max(worst, max(abs(a - b) for a, b in zip(d1 + m1, d2 + m2)))
            for c in range(1, L + 1):                    # tails: (a) exact, (b) bound
                assert abs(sum(d1[c:]) - k / (N + k) * (1 - (1 - 1 / N) ** (L - c + 1))) < 1e-12
            for m in range(L):
                assert sum(m1[m + 1:]) <= comb(L, m + 1) * N ** (-(m + 1)) + 1e-15 <= (L / N) ** (m + 1) / math.factorial(m + 1) + 2e-15
            cases += 1
    assert worst < 1e-12
    print(f"   {cases} cases (N <= 5, L <= 6, every k): largest difference between enumeration and formula = {worst:.2e}; "
          f"tail formula of (a) and tail bound of (b) hold")


# ---------------------------------------------------------------- (B)
def removal_draw_enum(N, L, k):
    """Posterior-draw driver, class A, U = {0..k-1}: Pr[the question of a round removes a trap], by enumeration."""
    tot = 0.0
    for z in itertools.product(range(N), repeat=L):
        for J in range(L):
            p = N ** (-L) / L
            tot += p * N / (N + k) * (z[J] < k)          # driver g_0: asked (z_J, 0)
            for d in range(k):
                flag = -1
                for j in range(J):                       # flag before call J
                    if flag < 0 and z[j] == d:
                        flag = z[j]
                tested = z[J] if flag < 0 else flag
                tot += p / (N + k) * (tested < k)
    return tot


def removal_draw_formula(N, L, k):
    """Referee's closed form: driver g_0 removes w.p. k/N; driver g_d removes g_d if d occurs at or before
    call J, and otherwise removes the trap of the J-th symbol, which is uniform on the other N - 1 symbols."""
    if k == 0:
        return 0.0
    q = 1 - 1 / N
    s = sum((1 - q ** J) + q ** J * (k - 1) / (N - 1) for J in range(1, L + 1)) / L
    return N / (N + k) * k / N + k / (N + k) * s


def removal_mix_enum(N, L, k):
    tot = 0.0
    q = 1.0 / (N + k)

    def rec(z, j, J, flag, p):
        nonlocal tot
        a = z[j]
        target = a if flag < 0 else flag
        if j == J:
            tot += p * (target < k)
            return
        p1 = q if target < k else 0.0
        if p1 > 0:
            rec(z, j + 1, J, a if flag < 0 else flag, p * p1)
        rec(z, j + 1, J, flag, p * (1 - p1))

    for z in itertools.product(range(N), repeat=L):
        for J in range(L):
            rec(z, 0, J, -1, N ** (-L) / L)
    return tot


def removal_mix_formula(N, L, k):
    e0 = k / (N * (N + k))
    return sum((1 - e0) ** (J - 1) * k / N + 1 - (1 - e0) ** (J - 1) for J in range(1, L + 1)) / L


def law_of_k(N, L, n, removal):
    """Exact law of the number k of surviving traps after n rounds (each round removes at most one trap)."""
    import numpy as np
    p = np.zeros(N + 1)
    p[N] = 1.0
    tr = np.array([removal(N, L, k) for k in range(N + 1)])
    for _ in range(n):
        new = p * (1 - tr)
        new[:-1] += (p * tr)[1:]
        p = new
    return p


def mix_tails(N, L, c0):
    """Per-call mixture, class A: Pr[C >= 2] and Pr[C >= c0] as arrays over k = 0..N (formula of 4.2(b))."""
    import numpy as np
    from scipy.stats import binom
    k = np.arange(N + 1)
    e0, q = k / (N * (N + k)), 1.0 / (N + k)
    t2 = np.zeros(N + 1)
    tc = np.zeros(N + 1)
    for tau in range(1, L + 1):
        first = (1 - e0) ** (tau - 1) * e0
        t2 += first * binom.sf(0, L - tau, q)                 # B >= 1
        tc += first * (binom.sf(c0 - 2, L - tau, q) if c0 >= 2 else 1.0)   # B >= c0 - 1
    return t2, tc


def part_B():
    import numpy as np
    print("(B) class A: one-round removal probabilities, enumeration against closed forms")
    worst = 0.0
    for N, L in ((2, 3), (3, 4), (4, 4), (5, 3), (3, 5)):
        for k in range(N + 1):
            worst = max(worst, abs(removal_draw_enum(N, L, k) - removal_draw_formula(N, L, k)),
                        abs(removal_mix_enum(N, L, k) - removal_mix_formula(N, L, k)))
            # the per-trap bound used in the proof: each surviving trap is removed w.p. <= 1/N + L/N^2
            if k:
                assert removal_draw_formula(N, L, k) / k <= 1 / N + L / N ** 2 + 1e-15
                assert removal_mix_formula(N, L, k) / k <= 1 / N + L / N ** 2 + 1e-15
            # cross-check of mix_tails against the enumerated law
            t2, tc = mix_tails(N, L, 3)
            law = law_C_mix_enum(N, L, k)
            assert abs(t2[k] - sum(law[2:])) < 1e-12 and abs(tc[k] - sum(law[3:])) < 1e-12
    assert worst < 1e-12
    print(f"   largest difference = {worst:.2e}")
    print("   Proposition 4.2(c) on a grid: n = N, every L <= sqrt(N); rehearsal by either driver; c0 = ceil(L/4)")
    print("       N   rehearsal driver   min E[k]/(N(1-1/N-L/N^2)^n)   min over L of Pr_draw[C >= L/4] n/L   max over L of Pr_mix[C >= 2]/((L/n)^2/2)   max Pr_mix[C>=c0]/bound")
    for N in (100, 144, 225, 400, 900, 1600):
        ks = np.arange(N + 1)
        for name, removal in (("posterior draw", removal_draw_formula), ("mixture", removal_mix_formula)):
            r_k, r_draw, r_mix2, r_mixc = math.inf, math.inf, 0.0, 0.0
            for L in range(1, math.isqrt(N) + 1):
                p = law_of_k(N, L, N, removal)
                assert abs(p.sum() - 1) < 1e-9
                Ek = float(p @ ks)
                bound_k = N * (1 - 1 / N - L / N ** 2) ** N
                assert Ek >= bound_k
                r_k = min(r_k, Ek / bound_k)
                c0 = math.ceil(L / 4)
                pr_draw = float(p @ (ks / (N + ks))) * (1 - (1 - 1 / N) ** (L - c0 + 1))
                assert pr_draw >= 0.11 * L / N
                r_draw = min(r_draw, pr_draw * N / L)
                t2, tc = mix_tails(N, L, c0)
                tail2, tailc = float(p @ t2), float(p @ tc)
                if L >= 2:
                    assert tail2 <= (L / N) ** 2 / 2
                    r_mix2 = max(r_mix2, tail2 / ((L / N) ** 2 / 2))
                bc = (L / N) ** c0 / math.factorial(c0)
                assert tailc <= bc + 1e-18
                r_mixc = max(r_mixc, tailc / bc)
            print(f"   {N:6d}   {name:15s} {r_k:20.4f} {r_draw:32.4f} {r_mix2:36.4f} {r_mixc:28.4f}")


# ---------------------------------------------------------------- (C)
def part_C():
    print("(C) constants of Proposition 4.2(c) and Corollary 4.4(a)")
    v = 0.5 * (1 - 1.1 / 100) ** 100
    print(f"   (1/2)(1 - 1.1/N)^N at N = 100: {v:.5f} (>= 0.165);  0.165 * 0.95 * 0.75 = {0.165 * 0.95 * 0.75:.5f} (>= 0.117 > 0.11)")
    assert v >= 0.165 and 0.165 * 0.95 * 0.75 >= 0.117
    assert all((1 - 1.1 / N) ** N <= (1 - 1.1 / (N + 1)) ** (N + 1) for N in range(2, 5000))      # increasing in N
    worst = 0.0
    for n in range(100, 3000, 7):
        for L in range(1, math.isqrt(n) + 1):
            c0 = math.ceil(L / 4)
            lhs = (L / n) ** c0 / math.factorial(c0)
            rhs = (4 * math.e / n) ** (L / 4)
            assert lhs <= rhs
            worst = max(worst, lhs / rhs)
            assert 1 - (1 - 1 / n) ** (L - c0 + 1) >= (3 * L / (4 * n)) * (1 - L / (2 * n)) >= 0.95 * 3 * L / (4 * n)
    print(f"   (L/n)^c0/c0! <= (4e/n)^(L/4) for all n in [100, 3000), L <= sqrt(n): largest ratio {worst:.4f}; "
          f"1 - (1-1/n)^(L-c0+1) >= 0.95 * 3L/(4n) holds")
    print(f"   (3/2)^3/3! = {1.5 ** 3 / 6:.4f} (<= 0.57, Corollary 4.4(b))")


# ---------------------------------------------------------------- (D)
def law_C_mix_B(N, L, s, cap):
    """Class B, human g_astar, posterior uniform on a set S of s members containing astar: exact law of
    min(C, cap) for a run of the per-call mixture, and Pr[Dm]. States: flag in {none, astar, other}."""
    st = {("none", 0): 1.0}
    p_dm = 0.0
    for _ in range(L):
        new = {}

        def add(key, p):
            if p:
                key = (key[0], min(key[1], cap))
                new[key] = new.get(key, 0.0) + p

        for (flag, c), p in st.items():
            if flag == "none":
                # input (b, 0): b = astar w.p. 1/N; b another member of S w.p. (s-1)/N; b removed w.p. (N-s)/N
                add(("astar", c), p * (1 / N) * (1 / s))             # correct answer 1; the flag becomes astar
                add(("none", c + 1), p * (1 / N) * (1 - 1 / s))      # the mixture answers 0, the human 1
                add(("other", c + 1), p * ((s - 1) / N) * (1 / s))   # the draw is g_b: answer 1, the human 0
                add(("none", c), p * ((s - 1) / N) * (1 - 1 / s))
                add(("none", c), p * ((N - s) / N))
            elif flag == "astar":                                    # the human answers 1; the draw does iff it is g_astar
                add(("astar", c), p * (1 / s))
                add(("astar", c + 1), p * (1 - 1 / s))
            else:                                                    # flag a != astar: the human answers 0
                add(("other", c + 1), p * (1 / s))
                add(("other", c), p * (1 - 1 / s))
        st = new
    law = [0.0] * (cap + 1)
    for (flag, c), p in st.items():
        law[c] += p
        if flag == "astar":
            p_dm += p
    return law, p_dm


def part_D():
    print("(D) class B, Proposition 4.3(b): exact Pr[C > m] for the mixture against L/(2n^2) + (3L/(2n))^(m+1)/(m+1)!")
    print("       n     largest ratio exact/bound over L <= n, s in {n, ..., 2n}, m = 0..5     largest Pr[Dm]/(L/(2n^2))")
    for n in (16, 17, 24, 40, 64, 100, 200):
        N = 2 * n
        worst = worst_dm = 0.0
        for L in sorted(set(list(range(1, min(n, 12) + 1)) + [n // 4, n // 2, n])):
            for s in sorted(set([n, n + 1, (3 * n) // 2, N - 1, N])):
                law, p_dm = law_C_mix_B(N, L, s, 7)
                assert p_dm <= L / (2 * n * n) + 1e-15
                worst_dm = max(worst_dm, p_dm / (L / (2 * n * n)))
                for m in range(6):
                    exact = sum(law[m + 1:])
                    bound = L / (2 * n * n) + (3 * L / (2 * n)) ** (m + 1) / math.factorial(m + 1)
                    assert exact <= bound + 1e-15, (n, L, s, m, exact, bound)
                    worst = max(worst, exact / bound)
        print(f"   {n:6d} {worst:30.4f} {worst_dm:50.4f}")


# ---------------------------------------------------------------- (E)
def part_E():
    print("(E) class B, Proposition 4.3(a)")
    worst = math.inf
    for n in range(16, 400):
        N = 2 * n
        for L in range(1, n + 1):
            m0 = L - math.ceil(L / 4) + 1
            assert m0 >= 3 * L / 4
            exact = (1 - (n + 1) / N) * (1 - (1 - 1 / N) ** m0)
            mid = ((n - 1) / (2 * n)) * (3 * L / (8 * n)) * (1 - L / (4 * n))
            assert exact >= mid - 1e-15 and mid >= (15 / 32) * (9 / 32) * L / n - 1e-15 and (15 / 32) * (9 / 32) >= 1 / 8
            worst = min(worst, exact / (L / (8 * n)))
    print(f"   the chain (1-(n+1)/N)(1-(1-1/N)^m0) >= ((n-1)/(2n))(3L/(8n))(1-L/(4n)) >= (135/1024) L/n >= L/(8n) holds for all "
          f"16 <= n < 400, L <= n; smallest ratio of the first expression to L/(8n): {worst:.4f}")
    # one natural rule, exactly: test the triggers of n distinct indices; if all answers are 0 deploy an untested member.
    # Human astar uniform. C = number of unfaithful calls of the deployed member's run.
    print("   the rule 'ask n distinct triggers, deploy an untested member', exact Pr[C >= L/4] (human uniform on the class):")
    print("       n     L    exact      L/(8n)    ratio")
    for n, L in ((16, 1), (16, 4), (16, 16), (60, 12), (200, 50), (200, 200), (1000, 100)):
        N = 2 * n
        c0 = math.ceil(L / 4)
        # with probability (n-1)/N the human is untested and is not the deployed member ahat (then ahat != astar).
        # Run of g_ahat: before the first occurrence i of ahat it answers 0, unfaithful exactly where the symbol is astar;
        # from call i on it answers 1 and the human answers 0: L - i + 1 unfaithful calls.
        pr = 0.0
        for i in list(range(1, L + 1)) + [None]:
            if i is None:
                pi, tail_len, sure = (1 - 1 / N) ** L, L, 0
            else:
                pi, tail_len, sure = (1 - 1 / N) ** (i - 1) / N, i - 1, L - i + 1
            # among the tail_len earlier symbols (each not ahat), each is astar w.p. 1/(N-1)
            need = max(0, c0 - sure)
            q = 1 / (N - 1)
            pr += pi * sum(comb(tail_len, b) * q ** b * (1 - q) ** (tail_len - b) for b in range(need, tail_len + 1))
        pr *= (n - 1) / N
        assert pr >= L / (8 * n)
        print(f"   {n:6d} {L:5d} {pr:10.5f} {L / (8 * n):10.5f} {pr / (L / (8 * n)):8.3f}")


# ---------------------------------------------------------------- (F)
def part_F():
    print("(F) Remark 4.5 and Corollary 4.4(b)")
    # the plurality of the posterior at the inputs that g_0 visits, class B, by enumeration for small N
    N = 5
    members = list(range(1, N + 1))

    def g(a, x):                                         # x = (b, s)
        b, s = x
        return 1 if (s == 0 and b == a) or s == a else 0

    for r in range(2, N + 1):
        for S in itertools.combinations(members, r):
            for b in members:                            # g_0 only visits inputs (b, 0)
                ones = sum(g(a, (b, 0)) for a in S)
                if r >= 3:
                    assert ones < r - ones               # strict plurality 0
                else:
                    assert ones <= r - ones              # with two survivors a tie is possible
    print("   class B, N = 5: with >= 3 surviving members the plurality answer is 0 at every input (b, 0); with 2 it can be a tie")
    # g_0 in class B: C ~ Binomial(L, 1/N)
    for N, L in ((32, 16), (120, 12), (400, 200)):
        for m in range(4):
            tail = sum(comb(L, c) * N ** (-c) * (1 - 1 / N) ** (L - c) for c in range(m + 1, L + 1))
            assert tail <= (L / N) ** (m + 1) / math.factorial(m + 1)
    print("   g_0 in class B: Pr[C > m] = Pr[Bin(L, 1/N) > m] <= (L/N)^(m+1)/(m+1)! checked")
    # which set of good runs makes Corollary 4.4(b) a statement about failure?
    print("   class B, N = 2n: the human system's own run has >= L/4 answers 1 with probability 1 - (1-1/N)^m0:")
    print("       n     L    human system outside {fewer than L/4 ones}    lower bound L/(8n) for a deployed member")
    for n, L in ((16, 16), (60, 12), (200, 50), (1000, 100)):
        N = 2 * n
        m0 = L - math.ceil(L / 4) + 1
        print(f"   {n:6d} {L:5d} {1 - (1 - 1 / N) ** m0:24.5f} {L / (8 * n):36.5f}")
    print("   so a set of good runs that does not refer to the human cannot be 'few answers 1' in class B; with")
    print("   G_astar = {fewer than L/4 calls answered differently from g_astar} the human system tolerates ceil(L/4)-1")
    print("   faults with failure 0 and a deployed member fails with probability >= L/(8n) (Proposition 4.3(a)).")


if __name__ == "__main__":
    part_A()
    part_B()
    part_C()
    part_D()
    part_E()
    part_F()
    print("all assertions passed")
