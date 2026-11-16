"""Editor's checks for proofs/property-online.md (written while deciding the findings of the two
verification reports). Each part checks a statement that the editor added or changed, or re-checks
a main statement with an implementation that shares no code with the prover's scripts.

Part 1  Example 2.5 (added by the editor): the rule of Theorem 2.1 (one rate) gives at least
        min(floor(n/2), N*) answers in a test the human never satisfies, for EVERY choice among
        the minimisers. Exhaustive over all tie-breakings by a search over reachable states.
Part 2  Proposition 2.4 in its sharpened form (finding m4 of the adversary's report):
        |S_t(B)| <= ln(2/pi(B))/eta_t + (1/2) sum_{s<=t} eta_s <= sqrt(t) (ln(2/pi(B))/c + c).
Part 3  Proposition 3.9 (finding m1): the ledger rule keeps the books of a fixed finite family bounded.
Part 4  Proposition 3.10 (finding m2): two tests with values in [0, 1] force max |S_n| >= sqrt(n/2).
Part 5  Proposition 6.6 (finding m3): condition (I) fails at S = (1, 1) for a test and its
        complement, and holds with ratio 1/2 on the line of reachable books.
Part 6  Proposition 6.7 (added by the editor): the two-point lower bound for the sampling error.
Part 7  floor(n/2) >= (1/2) sqrt(n) ln n for all n >= 1 (used in Proposition 8.2(a)).
Part 8  Theorem 3.3 (Rule NH) on random families against three adversaries, own implementation.

Usage: python3 property-online_editor_checks.py > property-online_editor_checks.out
Only the standard library and numpy are used; all seeds are fixed.
"""
import math

import numpy as np


# ----------------------------------------------------------------------------------------------
# Part 1. Example 2.5
# ----------------------------------------------------------------------------------------------
# Questions have a type in {o, obar, e}; there are infinitely many questions of each type, and the
# adversary uses a fresh one in every round. Answers {0, 1, 2}.
#   B = all pairs with answer 1                                             (weight beta)
#   D = {(x,1): x of type o} + {(x,0),(x,2): x of type obar} + {(x,2): x of type e}  (weight delta)
# The human never answers 1. Adversary: if S(D) = 0 a question of type e, and the human gives the
# one of the answers 0, 2 that the imitator does not give (2 if the imitator gives 1); if
# S(D) = -1 a question of type o, human answers 0; if S(D) = +1 a question of type obar, human
# answers 0.
D_SECTION = {"o": {1}, "obar": {0, 2}, "e": {2}}


def minimisers(qtype, N, SD, beta, delta, eta):
    """All answers that minimise the score of Theorem 2.1 at a question of the given type."""
    sc = []
    for y in (0, 1, 2):
        s = 0.0
        if y == 1:
            s += beta * math.sinh(eta * N)          # S(B) = N because the human never answers 1
        if y in D_SECTION[qtype]:
            s += delta * math.sinh(eta * SD)
        sc.append(s)
    m = min(sc)
    return [y for y in (0, 1, 2) if sc[y] <= m + 1e-15 * (1.0 + abs(m))]


def step(N, SD, a):
    """One round of the adversary of Example 2.5 against the imitator's answer a."""
    qtype = "e" if SD == 0 else ("o" if SD == -1 else "obar")
    if qtype == "e":
        human = 2 if a in (0, 1) else 0
    else:
        human = 0
    gB = 1 if a == 1 else 0
    gD = (1 if a in D_SECTION[qtype] else 0) - (1 if human in D_SECTION[qtype] else 0)
    return N + gB, SD + gD


def n_star(beta, delta, eta):
    N = 0
    while beta * math.sinh(eta * N) < delta * math.sinh(eta):
        N += 1
    return N


def part1():
    print("Part 1. Example 2.5: least count of answers in B over ALL choices among minimisers")
    print("        n       beta   eta      N*   min(n//2, N*)   least count   largest count   0.5 sqrt(n) ln n")
    ok = True
    for n, beta in [(100, 1 / 200), (400, 1 / 800), (2500, 1 / 5000), (10000, 1 / 20000),
                    (10000, 1e-9), (40000, 1 / 80000)]:
        eta, delta = 1 / math.sqrt(n), 0.5
        Ns = n_star(beta, delta, eta)
        # reachable states (N, S_D) after t rounds, over all tie-breakings
        states = {(0, 0)}
        for t in range(n):
            new = set()
            for (N, SD) in states:
                qtype = "e" if SD == 0 else ("o" if SD == -1 else "obar")
                for a in minimisers(qtype, N, SD, beta, delta, eta):
                    new.add(step(N, SD, a))
            states = new
            assert all(abs(SD) <= 1 for (_, SD) in states)
            lo = min(N for (N, _) in states)
            if lo < min((t + 1) // 2, Ns):
                ok = False
        lo = min(N for (N, _) in states)
        hi = max(N for (N, _) in states)
        print(f"   {n:6d}   {beta:8.2e}  {eta:.4f}  {Ns:5d}   {min(n // 2, Ns):13d}   {lo:11d}   {hi:13d}   {0.5 * math.sqrt(n) * math.log(n):16.1f}")
    print("   least count >= min(t//2, N*) at every time t <= n, for every tie-breaking:", ok)
    print()


# ----------------------------------------------------------------------------------------------
# Part 2. Proposition 2.4, sharpened
# ----------------------------------------------------------------------------------------------
def random_family(rng, d, nx, ny):
    T = (rng.random((d, nx, ny)) < 0.5).astype(float)
    return T


def run_decreasing(T, pi, c, n, human, rng):
    """Rule of Proposition 2.4: minimise sum_B pi(B) sinh(eta_t S_{t-1}(B)) b_B(x, y), eta_t = c/sqrt(t).
    Returns the largest ratio of |S_t(B)| to the two bounds, over t <= n and B."""
    d, nx, ny = T.shape
    S = np.zeros(d)
    worst_a = worst_b = 0.0
    sum_eta = 0.0
    lam2 = np.log(2.0 / pi)
    for t in range(1, n + 1):
        eta = c / math.sqrt(t)
        sum_eta += eta
        F = np.tensordot(pi * np.sinh(eta * S), T, axes=(0, 0))       # F[x, y]
        a = F.argmin(axis=1)                                          # the rule: answer for every x
        x, y = human(S, a, T, pi, rng)
        S += T[:, x, a[x]] - T[:, x, y]
        bound_a = lam2 / eta + 0.5 * sum_eta
        bound_b = math.sqrt(t) * (lam2 / c + c)
        worst_a = max(worst_a, float(np.max(np.abs(S) / bound_a)))
        worst_b = max(worst_b, float(np.max(np.abs(S) / bound_b)))
    return worst_a, worst_b


def human_random(P):
    def h(S, a, T, pi, rng):
        x = int(rng.integers(T.shape[1]))
        y = int(rng.choice(T.shape[2], p=P[x]))
        return x, y
    return h


def human_greedy(S, a, T, pi, rng):
    """Adversary: the question and the answer that make the largest book as large as possible."""
    d, nx, ny = T.shape
    best, arg = -1.0, (0, 0)
    for x in range(nx):
        base = T[:, x, a[x]]
        for y in range(ny):
            val = float(np.max(np.abs(S + base - T[:, x, y])))
            if val > best:
                best, arg = val, (x, y)
    return arg


def human_l2(S, a, T, pi, rng):
    """Adversary: the question and the answer that make the sum of squared books largest."""
    d, nx, ny = T.shape
    best, arg = -1.0, (0, 0)
    for x in range(nx):
        base = T[:, x, a[x]]
        for y in range(ny):
            val = float(np.sum((S + base - T[:, x, y]) ** 2))
            if val > best:
                best, arg = val, (x, y)
    return arg


def part2():
    print("Part 2. Proposition 2.4 (sharpened): largest |S_t(B)| / bound over t <= n and all tests")
    print("   bound a = ln(2/pi)/eta_t + (1/2) sum_{s<=t} eta_s ;  bound b = sqrt(t) (ln(2/pi)/c + c)")
    rng = np.random.default_rng(11)
    worst = 0.0
    print("    d    c   weights   human      ratio to a   ratio to b")
    for d, wkind in [(8, "equal"), (40, "equal"), (40, "2^-k")]:
        T = random_family(rng, d, 10, 3)
        if wkind == "equal":
            pi = np.full(d, 1.0 / d)
        else:
            pi = 2.0 ** -np.arange(1, d + 1)
        P = rng.dirichlet(np.ones(3), size=10)
        for c in (0.5, 1.0, 2.0):
            for name, h in [("random", human_random(P)), ("greedy-max", human_greedy), ("greedy-l2", human_l2)]:
                ra, rb = run_decreasing(T, pi, c, 1500, h, rng)
                worst = max(worst, ra, rb)
                print(f"   {d:3d}  {c:3.1f}   {wkind:7s}   {name:10s}   {ra:8.3f}     {rb:8.3f}")
    print(f"   largest ratio: {worst:.3f}  (must be <= 1)")
    print()


# ----------------------------------------------------------------------------------------------
# Part 3. The ledger rule (Proposition 3.9)
# ----------------------------------------------------------------------------------------------
def part3():
    print("Part 3. Proposition 3.9 (ledger rule): books of a fixed finite family stay bounded")
    rng = np.random.default_rng(5)
    print("   tests  |X|  |Y|  types   rounds   largest |S_t(B)|   bound types*(|Y|-1)   sqrt(rounds)")
    for d, nx, ny, n in [(3, 6, 3, 30000), (5, 8, 3, 30000), (8, 12, 4, 30000)]:
        T = (rng.random((d, nx, ny)) < 0.5).astype(int)
        types = {}
        tindex = []
        for x in range(nx):
            key = T[:, x, :].tobytes()
            if key not in types:
                types[key] = len(types)
            tindex.append(types[key])
        ntypes = len(types)
        Dl = np.zeros((ntypes, ny), dtype=int)       # ledger: imitator's count minus human's count
        S = np.zeros(d, dtype=int)
        worst = 0
        for t in range(n):
            # the rule: at a question of type tau answer with a least entry of the ledger of tau
            a = [int(np.argmin(Dl[tindex[x]])) for x in range(nx)]
            # adversary: the (x, y) that makes the largest book largest; ties at random
            best, cands = -1, []
            for x in range(nx):
                for y in range(ny):
                    val = int(np.max(np.abs(S + T[:, x, a[x]] - T[:, x, y])))
                    if val > best:
                        best, cands = val, [(x, y)]
                    elif val == best:
                        cands.append((x, y))
            x, y = cands[int(rng.integers(len(cands)))]
            S += T[:, x, a[x]] - T[:, x, y]
            Dl[tindex[x], a[x]] += 1
            Dl[tindex[x], y] -= 1
            assert Dl.max() <= 1 and Dl.min() >= -(ny - 1) and (Dl.sum(axis=1) == 0).all()
            worst = max(worst, int(np.max(np.abs(S))))
        print(f"   {d:5d}  {nx:3d}  {ny:3d}  {ntypes:5d}   {n:6d}   {worst:16d}   {ntypes * (ny - 1):19d}   {math.sqrt(n):12.0f}")
    print()


# ----------------------------------------------------------------------------------------------
# Part 4. Two tests with values in [0, 1] (Proposition 3.10)
# ----------------------------------------------------------------------------------------------
def G(v, s):
    return (v + 1.0) ** -0.5 * math.exp(s * s / (2.0 * (v + 1.0)))


def part4():
    print("Part 4. Proposition 3.10: two tests with values in [0, 1]; questions are vectors v in [-1, 1]^2")
    print("   b_k(v, 1) = max(v_k, 0), b_k(v, 0) = max(-v_k, 0); the human gives the answer the imitator does not give;")
    print("   the adversary's v is orthogonal to the books and has maximum norm 1 (floating point)")
    print("   rule         n     |S_n|_2^2    max_k |S_n(B_k)|   sqrt(n/2)   largest |<v, S>| seen")
    for rule in ("Pr5", "N"):
        for n in (1000, 100000):
            eta = 1 / math.sqrt(n)
            S = [0.0, 0.0]
            V = [0, 0]
            worst_ip = 0.0
            for t in range(n):
                if S[0] == 0.0 and S[1] == 0.0:
                    v = (1.0, 1.0)
                else:
                    m = max(abs(S[0]), abs(S[1]))
                    v = (-S[1] / m, S[0] / m)
                worst_ip = max(worst_ip, abs(v[0] * S[0] + v[1] * S[1]))
                # scores of the answers 1 and 0: sum_k pi_k slope_k b_k(v, y), pi_k = 1/2
                if rule == "Pr5":
                    sl = [math.sinh(eta * S[k]) for k in range(2)]
                else:
                    sl = [0.5 * (G(V[k] + 1, S[k] + 1.0) - G(V[k] + 1, S[k] - 1.0)) for k in range(2)]
                s1 = sum(0.5 * sl[k] * max(v[k], 0.0) for k in range(2))
                s0 = sum(0.5 * sl[k] * max(-v[k], 0.0) for k in range(2))
                a = 1 if s1 < s0 else 0
                sign = 1.0 if a == 1 else -1.0                 # the increment vector is sign * v
                for k in range(2):
                    g = sign * v[k]
                    if g != 0.0:
                        V[k] += 1
                    S[k] += g
            n2 = S[0] ** 2 + S[1] ** 2
            print(f"   {rule:5s}   {n:7d}   {n2:11.1f}   {max(abs(S[0]), abs(S[1])):16.1f}   {math.sqrt(n / 2):9.1f}   {worst_ip:.2e}")
    print()


# ----------------------------------------------------------------------------------------------
# Part 5. Condition (I) of Proposition 6.6
# ----------------------------------------------------------------------------------------------
def part5():
    print("Part 5. Proposition 6.6, condition (I): one question, Y = {0,1}, tests B = {(x0,1)} and its complement, weights 1/2,")
    print("        human a fair coin. m(S) = sum_B pi(B) S(B) (P b_B) - min_y sum_B pi(B) S(B) b_B(y)")

    def m(S):
        sB, sC = S
        score = {1: 0.5 * sB, 0: 0.5 * sC}
        avg = 0.5 * score[1] + 0.5 * score[0]
        return avg - min(score.values())

    def norm(S):
        return math.sqrt(0.5 * S[0] ** 2 + 0.5 * S[1] ** 2)

    for S in [(1.0, 1.0), (2.0, 2.0), (1.0, -1.0), (-3.0, 3.0), (1.0, 0.0)]:
        print(f"   S = {S}:  m(S) = {m(S):.4f},  |S|_pi = {norm(S):.4f},  ratio = {m(S) / norm(S):.4f}")
    print("   reachable books satisfy S(complement) = -S(B): ratio 1/2 there; ratio 0 at S = (1, 1)")
    print()


# ----------------------------------------------------------------------------------------------
# Part 6. Proposition 6.7: two-point lower bound
# ----------------------------------------------------------------------------------------------
def binom_pmf(n, p):
    logs = [math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)
            + k * math.log(p) + (n - k) * math.log(1 - p) for k in range(n + 1)]
    return [math.exp(v) for v in logs]


def part6():
    print("Part 6. Proposition 6.7: theta = 1/(4 sqrt(n)); TV(Bin(n, 1/2+theta), Bin(n, 1/2-theta)) and (1 - TV)/2")
    print("        n     theta      n*KL    bound 2/3   exact TV   bound 1/sqrt(3)   (1-TV)/2")
    for n in (1, 2, 4, 16, 100, 1000, 10000):
        th = 1 / (4 * math.sqrt(n))
        kl = 2 * th * math.log((0.5 + th) / (0.5 - th))
        p, q = binom_pmf(n, 0.5 + th), binom_pmf(n, 0.5 - th)
        tv = 0.5 * sum(abs(a - b) for a, b in zip(p, q))
        print(f"   {n:6d}   {th:.5f}   {n * kl:.4f}   {2 / 3:.4f}      {tv:.4f}     {1 / math.sqrt(3):.4f}            {(1 - tv) / 2:.4f}")
        assert n * kl <= 2 / 3 + 1e-12 and tv <= 1 / math.sqrt(3)
    print()


# ----------------------------------------------------------------------------------------------
# Part 7
# ----------------------------------------------------------------------------------------------
def part7():
    bad = [n for n in range(1, 1000001) if n // 2 < 0.5 * math.sqrt(n) * math.log(n)]
    print("Part 7. floor(n/2) >= (1/2) sqrt(n) ln n for 1 <= n <= 10^6: violations:", len(bad))
    slack = min((n // 2) - 0.5 * math.sqrt(n) * math.log(n) for n in range(1, 1000001))
    print(f"   least slack: {slack:.4f} (at n = 1 the two sides are 0); for n > 10^6 use sqrt(n) >= ln n + 1")
    print()


# ----------------------------------------------------------------------------------------------
# Part 8. Rule NH, own implementation
# ----------------------------------------------------------------------------------------------
def part8():
    print("Part 8. Theorem 3.3 (Rule NH), own implementation: largest S^2 / right side of (i), and largest V/(K(B)+2) over pure histories")
    rng = np.random.default_rng(3)
    print("    d   weights   human          n     max ratio (i)   max ratio (ii)   one-sided test: count / bound")
    for d, wkind in [(12, "equal"), (40, "2^-k")]:
        nx, ny = 10, 4
        T = (rng.random((d, nx, ny)) < 0.4).astype(float)
        T[0, :, ny - 1] = 0.0               # the last answer is never in test 0: a human who gives it never satisfies test 0
        T[0, :, 0] = 1.0                    # the first answer (the imitator's choice when all scores tie) is in test 0
        pi = np.full(d, 1.0 / d) if wkind == "equal" else 2.0 ** -np.arange(1, d + 1)
        if wkind != "equal":
            pi = pi[::-1].copy()            # test 0 gets the smallest weight
        Lam = np.log(1.0 / pi)
        Kb = np.log2(1.0 / pi)
        P = rng.dirichlet(np.ones(ny), size=nx)
        for hname in ("random", "greedy-l2", "never-in-B0"):
            n = 3000
            S = np.zeros(d)
            V = np.zeros(d)
            sign = np.zeros(d)              # common sign of the non-zero increments, 0 if none yet
            pure = np.ones(d, dtype=bool)
            r1 = r2 = 0.0
            count0 = 0
            for t in range(n):
                cN = 0.5 * ((V + 2.0) ** -0.5) * (np.exp((S + 1.0) ** 2 / (2.0 * (V + 2.0))) - np.exp((S - 1.0) ** 2 / (2.0 * (V + 2.0))))
                cH = np.where(pure & (V >= 1), sign * np.exp2(np.minimum(V, 1000.0) - 1.0), 0.0)
                F = np.tensordot(pi * (0.5 * cN + 0.5 * cH), T, axes=(0, 0))
                a = F.argmin(axis=1)
                if hname == "random":
                    x = int(rng.integers(nx)); y = int(rng.choice(ny, p=P[x]))
                elif hname == "greedy-l2":
                    x, y = human_l2(S, a, T, pi, rng)
                else:
                    # the human always gives the last answer; the question is one at which the imitator's answer
                    # lies in test 0, if there is one
                    xs = [xx for xx in range(nx) if T[0, xx, a[xx]] == 1.0]
                    x = xs[int(rng.integers(len(xs)))] if xs else int(rng.integers(nx))
                    y = ny - 1
                g = T[:, x, a[x]] - T[:, x, y]
                count0 += int(T[0, x, a[x]])
                nz = g != 0
                newsign = np.where(nz & (sign == 0), g, sign)
                pure = pure & ~(nz & (sign != 0) & (g != sign))
                sign = newsign
                S += g
                V += nz
                rhs = (V + 1.0) * (2.0 * Lam + 2.0 * math.log(2.0) + np.log(V + 1.0))
                r1 = max(r1, float(np.max(S ** 2 / rhs)))
                if np.any(pure & (V >= 1)):
                    r2 = max(r2, float(np.max(np.where(pure & (V >= 1), V / (Kb + 2.0), 0.0))))
            extra = f"{count0} / {Kb[0] + 2:.2f}" if hname == "never-in-B0" else ""
            print(f"   {d:3d}   {wkind:7s}   {hname:12s}  {n:5d}   {r1:11.3f}     {r2:11.3f}       {extra}")
    print()


if __name__ == "__main__":
    part1()
    part2()
    part3()
    part4()
    part5()
    part6()
    part7()
    part8()
    print("all parts finished")
