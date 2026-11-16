"""Adversary's checks of research/prove-c/property-online.md (key property-online).

(1) Exhaustive game search (all questions, all human answers, all tie-breaks among minimisers)
    against Rule N and Rule NH on small random families of set tests, depth n. In every reachable
    state and for every test, check (3.1) [Rule N] and Theorem 3.3 (i), (ii) [Rule NH]; report the
    largest ratio left/right (a ratio > 1 would be a counterexample).
(2) Example 2.3: simulate the rule of Theorem 2.1 and compare the count with min(n//2, N*).
(3) Rehearsal, exact: a scaffold with L = 2, enumerate all coin outcomes for small n and check
    E Delta_n(B) = (L/n) E S_n(B) (Theorem 6.2(a)) exactly, and the one-sided bound (c).
(4) Proposition 8.1(a): brute-force posterior over all memorisers, N = 4, A = 2.
(5) Ledger rule: on a finite family of set tests and finite Y, the books stay bounded for all n
    (the bound (#question types) * (|Y| - 1)), on long adversarial runs.
(6) Condition (I) of Proposition 6.6 fails for a family that contains a test and its complement.
"""
import itertools
import math
import random

TOL = 1e-12


def G(v, s):
    return (v + 1.0) ** -0.5 * math.exp(s * s / (2.0 * (v + 1.0)))


def cN(s, v):
    return 0.5 * (G(v + 1, s + 1.0) - G(v + 1, s - 1.0))


def cH(s, v, pure):
    if v >= 1 and pure:
        return (1 if s > 0 else -1) * 2.0 ** (v - 1)
    return 0.0


# ---------------------------------------------------------------- (1) exhaustive game search
def search(X, Y, tests, w, rule, n):
    """tests[k] = set of (x, y). State per test: (s, v, pure). Explore all reachable states."""
    K = len(tests)
    start = tuple((0, 0, True) for _ in range(K))
    frontier = {start}
    worst = 0.0
    worst_pure = 0.0
    nstates = 0
    for t in range(1, n + 1):
        new = set()
        for st in frontier:
            slopes = []
            for k in range(K):
                s, v, pure = st[k]
                if rule == "N":
                    slopes.append(cN(s, v))
                else:
                    slopes.append(0.5 * cN(s, v) + 0.5 * cH(s, v, pure))
            for x in range(X):
                F = [sum(w[k] * slopes[k] * ((x, y) in tests[k]) for k in range(K)) for y in range(Y)]
                m = min(F)
                mins = [y for y in range(Y) if F[y] <= m + TOL * (1 + abs(m))]
                for a in mins:
                    for y in range(Y):
                        nxt = []
                        for k in range(K):
                            s, v, pure = st[k]
                            g = ((x, a) in tests[k]) - ((x, y) in tests[k])
                            if g != 0:
                                if v >= 1 and pure and (g > 0) != (s > 0):
                                    pure2 = False
                                else:
                                    pure2 = pure
                                nxt.append((s + g, v + 1, pure2))
                            else:
                                nxt.append((s, v, pure))
                        new.add(tuple(nxt))
        frontier = new
        nstates += len(frontier)
        for st in frontier:
            for k in range(K):
                s, v, pure = st[k]
                lam = math.log(1.0 / w[k])
                if rule == "N":
                    rhs = (v + 1) * (2 * lam + math.log(v + 1))
                else:
                    rhs = (v + 1) * (2 * lam + 2 * math.log(2) + math.log(v + 1))
                worst = max(worst, s * s / rhs)
                if rule == "NH" and pure and v >= 1:
                    worst_pure = max(worst_pure, v / (math.log2(1.0 / w[k]) + 2))
    return worst, worst_pure, nstates


def random_family(rng, X, Y, K, dyadic):
    tests = []
    for _ in range(K):
        tests.append({(x, y) for x in range(X) for y in range(Y) if rng.random() < 0.5})
    if dyadic:
        w = [2.0 ** -(k + 1) for k in range(K)]
    else:
        w = [1.0 / K] * K
    return tests, w


def part1():
    print("(1) exhaustive search: largest S^2/RHS over all reachable states (>1 = counterexample);")
    print("    for NH also the largest V/(K(B)+2) over pure histories (>1 = counterexample to 3.3(ii))")
    rng = random.Random(5)
    cases = [(2, 2, 2, False, 14), (2, 3, 2, True, 9), (3, 2, 3, True, 8), (1, 3, 3, False, 10), (2, 2, 4, True, 8)]
    for (X, Y, K, dy, n) in cases:
        for rep in range(2):
            tests, w = random_family(rng, X, Y, K, dy)
            rN = search(X, Y, tests, w, "N", n)
            rH = search(X, Y, tests, w, "NH", n)
            print(f"  X={X} Y={Y} K={K} {'dyadic' if dy else 'equal '} n={n:2d} #{rep}: "
                  f"N: {rN[0]:.4f} (states {rN[2]})   NH: two-sided {rH[0]:.4f}, pure {rH[1]:.4f} (states {rH[2]})")
    # one-sided stress: tests B_c = {y != c(x)} for all c, human = some c*, adversary picks questions
    print("  one-sided family of Prop. 3.5 (m=3: 8 tests 'y != c(x)', weight 1/8), human answers anything:")
    X, Y = 3, 2
    tests = [{(x, y) for x in range(X) for y in range(Y) if y != c[x]} for c in itertools.product(range(2), repeat=X)]
    w = [1.0 / 8] * 8
    rH = search(X, Y, tests, w, "NH", 9)
    print(f"    NH n=9: two-sided {rH[0]:.4f}, pure {rH[1]:.4f} (states {rH[2]})")
    print()


# ---------------------------------------------------------------- (2) Example 2.3
def part2():
    print("(2) Example 2.3: count of answers in B (human never answers 1) under the rule of Thm 2.1")
    for n in (100, 400, 2500, 10000):
        eta = 1 / math.sqrt(n)
        beta, delta = 1 / (2 * n), 0.5
        SB = SD = 0
        cnt = 0
        for t in range(1, n + 1):
            x = t + 1
            f = 0 if x % 2 else 2
            sc = [0.0, beta * math.sinh(eta * SB) + (delta * math.sinh(eta * SD) if x % 2 else 0.0),
                  (0.0 if x % 2 else delta * math.sinh(eta * SD))]
            a = min(range(3), key=lambda y: (sc[y], y))
            inB = lambda y: y == 1
            inD = lambda y: (y == 1 and x % 2 == 1) or (y == 2 and x % 2 == 0)
            SB += inB(a) - inB(f)
            SD += inD(a) - inD(f)
            cnt += inB(a)
        Nstar = 0
        while beta * math.sinh(eta * Nstar) < delta * math.sinh(eta):
            Nstar += 1
        print(f"  n={n:6d}: count {cnt:5d}  formula {min(n // 2, Nstar):5d}  0.5 sqrt(n) ln n = {0.5 * math.sqrt(n) * math.log(n):8.1f}")
    print()


# ---------------------------------------------------------------- (3) rehearsal, exact enumeration
def part3():
    """Scaffold: L = 2. Top-level z in {0,1} uniform. Call 1 asks q1 = z. Call 2 asks q2 = 2 + answer1
    (questions 2 or 3) if answer1 != 0, else the run stops after call 1 (T = 1).
    Y = {0,1,2}. Human P: q0 -> (0:.5,1:.5); q1 -> (1:.7,2:.3); q2 -> (0:.2,1:.8); q3 -> (2:1.0); never answers 2 at q0.
    Tests: B0 = {y = 2} (human gives 2 only at q1 and q3), B1 = {(q, 1)}, B2 = {(0,2),(2,2)} (never by human)."""
    P = {0: {0: .5, 1: .5, 2: 0}, 1: {0: 0, 1: .7, 2: .3}, 2: {0: .2, 1: .8, 2: 0}, 3: {0: 0, 1: 0, 2: 1.0}}
    tests = [{(q, 2) for q in range(4)}, {(q, 1) for q in range(4)}, {(0, 2), (2, 2)}]
    w = [1 / 3] * 3
    L = 2

    def run_calls(a, z):
        q1 = z
        a1 = a[q1]
        if a1 == 0:
            return [q1]
        return [q1, 2 + a1 - 1 + 0]  # q2 = 2 if a1 == 1, 3 if a1 == 2

    def dB(a, k):
        tot = 0.0
        for z in (0, 1):
            for q in run_calls(a, z):
                tot += 0.5 * (((q, a[q]) in tests[k]) - sum(P[q][y] for y in range(3) if (q, y) in tests[k]))
        return tot

    def rule_from(st, rule):
        slopes = []
        for (s, v, pure) in st:
            slopes.append(cN(s, v) if rule == "N" else 0.5 * cN(s, v) + 0.5 * cH(s, v, pure))
        a = {}
        for q in range(4):
            F = [sum(w[k] * slopes[k] * ((q, y) in tests[k]) for k in range(3)) for y in range(3)]
            m = min(F)
            a[q] = min(y for y in range(3) if F[y] <= m + TOL)
        return a

    print("(3) rehearsal, exact enumeration over all coins (scaffold with L = 2, 4 questions, 3 tests):")
    for rule in ("N", "NH"):
        for n in (1, 2, 3, 4, 6, 8):
            # distribution over states: dict state -> (prob, sum of d_B(a_t) so far per test)
            dist = {tuple((0, 0, True) for _ in range(3)): [1.0, [0.0] * 3]}
            for t in range(n):
                new = {}
                for st, (p, acc) in dist.items():
                    a = rule_from(st, rule)
                    d = [dB(a, k) for k in range(3)]
                    acc2 = [acc[k] + d[k] for k in range(3)]
                    # outcomes: z, J, y
                    for z in (0, 1):
                        calls = run_calls(a, z)
                        for J in range(1, L + 1):
                            if J > len(calls):
                                outs = [(None, 1.0)]
                            else:
                                q = calls[J - 1]
                                outs = [((q, y), P[q][y]) for y in range(3) if P[q][y] > 0]
                            for o, py in outs:
                                pr = p * 0.5 * (1 / L) * py
                                if o is None:
                                    nst = st
                                else:
                                    q, y = o
                                    nst = []
                                    for k in range(3):
                                        s, v, pure = st[k]
                                        g = ((q, a[q]) in tests[k]) - ((q, y) in tests[k])
                                        if g != 0:
                                            pure2 = pure and not (v >= 1 and (g > 0) != (s > 0))
                                            nst.append((s + g, v + 1, pure2))
                                        else:
                                            nst.append((s, v, pure))
                                    nst = tuple(nst)
                                if nst in new:
                                    # states merge: keep prob-weighted accumulators
                                    P0, A0 = new[nst]
                                    new[nst] = [P0 + pr, [A0[k] + pr * acc2[k] for k in range(3)]]
                                else:
                                    new[nst] = [pr, [pr * acc2[k] for k in range(3)]]
                # normalise accumulators back to per-state conditional sums times prob
                dist = {s_: [v_[0], [v_[1][k] / v_[0] for k in range(3)]] for s_, v_ in new.items()}
            EDelta = [sum(p * acc[k] for p, acc in dist.values()) / n for k in range(3)]
            ES = [sum(p * st[k][0] for st, (p, acc) in dist.items()) for k in range(3)]
            maxNB2 = max(st[2][0] for st in dist)
            line = "  ".join(f"B{k}: E Delta={EDelta[k]:+.6f} (L/n)E S={L * ES[k] / n:+.6f}" for k in range(3))
            print(f"  {rule:2s} n={n}: {line}  | max S(B2) {maxNB2} (bound K+2={math.log2(3) + 2:.2f}); "
                  f"one-sided E Delta(B2)={EDelta[2]:.4f} <= L(K+2)/n={L * (math.log2(3) + 2) / n:.4f}")
    print()


# ---------------------------------------------------------------- (4) Proposition 8.1(a) brute force
def part4():
    print("(4) Prop. 8.1(a): posterior probability of the bad answer at a new question, brute force vs formula")
    N, A, p, K = 4, 2, 0.4, 3
    f = {x: 1 + (x % A) for x in range(N)}
    hyps = [(f, 2.0 ** -K)]
    for D in itertools.chain.from_iterable(itertools.combinations(range(N), r) for r in range(N + 1)):
        for tau in itertools.product(range(1, A + 1), repeat=len(D)):
            m = {x: 0 for x in range(N)}
            for x, v in zip(D, tau):
                m[x] = v
            hyps.append((m, 0.5 * p ** len(D) * (1 - p) ** (N - len(D)) * A ** (-len(D))))
    print(f"  total prior weight {sum(h[1] for h in hyps):.6f} (must be 1/2 + 2^-K = {0.5 + 2 ** -K:.6f})")
    for k in range(N):
        Q = list(range(k))
        cons = [(h, wt) for h, wt in hyps if all(h[x] == f[x] for x in Q)]
        Z = sum(wt for _, wt in cons)
        x = k
        bad = sum(wt for h, wt in cons if h[x] == 0) / Z
        mu = 0.5 * (p / A) ** k / (0.5 * (p / A) ** k + 2 ** -K)
        print(f"  k={k}: brute {bad:.10f}  formula (1-p) mu_k = {(1 - p) * mu:.10f}")
    print()


# ---------------------------------------------------------------- (5) ledger rule
def part5():
    print("(5) ledger rule on finite families of set tests: max_B |S_t(B)| over long runs vs the bound types*(|Y|-1)")
    rng = random.Random(3)
    for (Xn, Y, K) in ((5, 3, 6), (20, 4, 10), (50, 2, 30)):
        tests = [{(x, y) for x in range(Xn) for y in range(Y) if rng.random() < 0.5} for _ in range(K)]
        types = {}
        for x in range(Xn):
            types.setdefault(tuple(tuple((x, y) in tests[k] for k in range(K)) for y in range(Y)), []).append(x)
        T = len(types)
        typ = {x: tuple(tuple((x, y) in tests[k] for k in range(K)) for y in range(Y)) for x in range(Xn)}
        D = {tt: [0] * Y for tt in types}
        S = [0] * K
        worst = 0
        n = 200000
        for t in range(n):
            # adversary: pick the question and the human answer greedily to push the largest book
            best = None
            for x in rng.sample(range(Xn), min(Xn, 8)):
                a = min(range(Y), key=lambda y: (D[typ[x]][y], y))
                for y in range(Y):
                    val = max(abs(S[k] + ((x, a) in tests[k]) - ((x, y) in tests[k])) for k in range(K))
                    if best is None or val > best[0]:
                        best = (val, x, a, y)
            _, x, a, y = best
            D[typ[x]][a] += 1
            D[typ[x]][y] -= 1
            for k in range(K):
                S[k] += ((x, a) in tests[k]) - ((x, y) in tests[k])
            worst = max(worst, max(abs(s) for s in S))
        print(f"  |X|={Xn} |Y|={Y} K={K}: question types {T}, max_t max_B |S_t| = {worst} over n={n}; "
              f"bound {T * (Y - 1)}; Rule N's bound (3.2) at n: {math.sqrt((n + 1) * (2 * math.log(K) + math.log(n + 1))):.0f}")
    print()


# ---------------------------------------------------------------- (6) condition (I)
def part6():
    print("(6) condition (I) of Prop. 6.6 with the family {B, complement of B}, Y = {0,1}, one question, fair-coin human:")
    for S in ((1.0, 1.0), (2.0, 2.0), (1.0, -1.0)):
        piB = piC = 0.5
        # score of y: piB S_B 1[y=1] + piC S_C 1[y=0]
        F = [piC * S[1], piB * S[0]]
        human = 0.5 * F[0] + 0.5 * F[1]
        m = human - min(F)
        norm = math.sqrt(piB * S[0] ** 2 + piC * S[1] ** 2)
        print(f"  S = {S}: m_x(S) = {m:.3f}, ||S||_pi = {norm:.3f}, ratio {m / norm:.3f}")
    print("  (the direction S = (1, 1) gives ratio 0, so (I) fails for every mu0 > 0; reachable books satisfy")
    print("   S(B) = -S(complement), and on that line the ratio is 1/2)")
    print()


if __name__ == "__main__":
    part2()
    part4()
    part6()
    part3()
    part5()
    part1()
