"""Second checker of the part property-online: own numerical checks.

Written independently of proofs/code/property-online_*.py (scores are computed from the
definitions of the tests as sets, not from the tables in the proofs).

Parts
  A  Example 2.5: the adversary of the proof against several tie-breaking rules, with the
     rule of Theorem 2.1 implemented generically; and floor(n/2) >= sqrt(n) ln n / 2.
  B  Proposition 2.4 (sharpened bound), greedy adversaries.
  C  Proposition 3.9 (ledger rule): EXACT maximum of |S(B)| over all reachable ledger states
     on small instances (breadth-first search over every question/answer sequence).
  D  Proposition 3.10 with exact rational arithmetic.
  E  Proposition 6.7: the constants (KL bound, Pinsker, exact TV of the binomials).
  F  Theorem 3.3 (Rule NH): exhaustive search over all question/answer sequences of small games.
  G  Theorem 6.2 (rehearsal): exact d_B(a) by enumeration, Monte Carlo over rehearsals.
  H  Proposition 6.6: the algebra of steps (3) to (5).
"""
import math
import random
import itertools
from fractions import Fraction
from collections import deque

random.seed(12345)


# ------------------------------------------------------------------------------------------
# Part A. Example 2.5
# ------------------------------------------------------------------------------------------
def inB(x, y):
    return y == 1


def inD(x, y):
    typ = x[0]
    if typ == "o":
        return y == 1
    if typ == "obar":
        return y in (0, 2)
    return y == 2  # type e


def ex25_play(n, beta, delta, eta, tiebreak, seed=0):
    rng = random.Random(seed)
    SB = SD = 0
    counter = 0
    used = set()
    counts = []
    hist = []
    for t in range(1, n + 1):
        counter += 1
        if SD == 0:
            x = ("e", counter)
        elif SD == -1:
            x = ("o", counter)
        else:
            x = ("obar", counter)
        assert x not in used
        used.add(x)
        sc = []
        for y in (0, 1, 2):
            s = 0.0
            if inB(x, y):
                s += beta * math.sinh(eta * SB)
            if inD(x, y):
                s += delta * math.sinh(eta * SD)
            sc.append(s)
        m = min(sc)
        mins = [y for y in (0, 1, 2) if sc[y] == m]
        if tiebreak == "least":
            a = mins[0]
        elif tiebreak == "greatest":
            a = mins[-1]
        elif tiebreak == "random":
            a = rng.choice(mins)
        elif tiebreak == "prefer1":
            a = 1 if 1 in mins else mins[0]
        elif tiebreak == "history":
            a = mins[hash((tuple(hist[-3:]), x[0])) % len(mins)]
        # the human of the proof
        if x[0] == "e":
            f = 0 if a == 2 else 2
        else:
            f = 0
        assert f in (0, 2)
        SB += int(inB(x, a)) - int(inB(x, f))
        SD += int(inD(x, a)) - int(inD(x, f))
        assert abs(SD) <= 1
        hist.append((a, f))
        counts.append(SB)  # = N_t(B) since the human never answers 1
    return counts


def n_star(beta, delta, eta):
    N = 0
    while beta * math.sinh(eta * N) < delta * math.sinh(eta):
        N += 1
    return N


def partA():
    print("Part A. Example 2.5 (adversary of the proof, rule of Theorem 2.1 implemented from the set definitions)")
    print("     n   beta        N*   tiebreak    N_n(B)   min(n//2,N*)  holds at every t   0.5*sqrt(n)*ln n")
    allok = True
    for n, beta in [(100, 1 / 200), (900, 1 / 1800), (10000, 1 / 20000), (10000, 1e-9)]:
        eta, delta = 1 / math.sqrt(n), 0.5
        Ns = n_star(beta, delta, eta)
        for tb in ["least", "greatest", "random", "prefer1", "history"]:
            seeds = range(5) if tb == "random" else [0]
            for sd in seeds:
                c = ex25_play(n, beta, delta, eta, tb, sd)
                ok = all(c[t - 1] >= min(t // 2, Ns) for t in range(1, n + 1))
                allok &= ok
                if sd == 0:
                    print(f"  {n:5d}  {beta:9.2e}  {Ns:5d}   {tb:9s}  {c[-1]:7d}   {min(n // 2, Ns):10d}     {str(ok):5s}         {0.5 * math.sqrt(n) * math.log(n):8.1f}")
    print("  all plays satisfy N_t(B) >= min(floor(t/2), N*) for every t:", allok)
    # floor(n/2) >= sqrt(n) ln n / 2
    bad = [n for n in range(1, 2 * 10 ** 6 + 1) if n // 2 < 0.5 * math.sqrt(n) * math.log(n) - 1e-12]
    print("  floor(n/2) >= 0.5 sqrt(n) ln n for 1 <= n <= 2e6; violations:", len(bad))
    first = None
    for n in range(1, 10 ** 4):
        if all(math.sqrt(m) >= math.log(m) + 1 for m in range(n, n + 2000)):
            first = n
            break
    print("  sqrt(n) >= ln n + 1 fails at n = 2..", [n for n in range(2, 200) if math.sqrt(n) < math.log(n) + 1][-1],
          "and holds from n =", first, "on (checked to n+2000; the function sqrt(n)-ln(n) increases for n > 4)")
    # N* lower bound
    for n in [100, 10000, 10 ** 6]:
        eta = 1 / math.sqrt(n)
        Ns = n_star(1 / (2 * n), 0.5, eta)
        print(f"  n = {n}: N* = {Ns},  arcsinh(sqrt n)*sqrt n = {math.asinh(math.sqrt(n)) * math.sqrt(n):.1f},  0.5 sqrt(n) ln n = {0.5 * math.sqrt(n) * math.log(n):.1f}")
    print()


# ------------------------------------------------------------------------------------------
# Part B. Proposition 2.4
# ------------------------------------------------------------------------------------------
def partB():
    print("Part B. Proposition 2.4: |S_n(B)| <= ln(2/pi)/eta_n + 0.5*sum eta_t, eta_t = c/sqrt(t); greedy adversaries")
    worst = 0.0
    for trial in range(24):
        d = random.choice([3, 6, 12])
        nx = random.choice([2, 4])
        Y = [0, 1, 2]
        c = random.choice([0.3, 1.0, 2.5])
        tests = [{(x, y) for x in range(nx) for y in Y if random.random() < 0.4} for _ in range(d)]
        w = [random.random() for _ in range(d)]
        s = sum(w) * random.choice([1.0, 1.3])
        pi = [wi / s for wi in w]
        S = [0] * d
        sumeta = 0.0
        n = 1500
        mode = trial % 3
        for t in range(1, n + 1):
            eta = c / math.sqrt(t)
            sumeta += eta
            rule = {}
            for x in range(nx):
                sc = [sum(pi[k] * math.sinh(eta * S[k]) * ((x, y) in tests[k]) for k in range(d)) for y in Y]
                rule[x] = min(Y, key=lambda y: (sc[y], y))
            if mode == 0:
                x, y = random.randrange(nx), random.choice(Y)
            else:
                best = None
                for x in range(nx):
                    for y in Y:
                        newS = [S[k] + ((x, rule[x]) in tests[k]) - ((x, y) in tests[k]) for k in range(d)]
                        val = max(abs(newS[k]) / (math.log(2 / pi[k]) + 1) for k in range(d)) if mode == 1 else sum(v * v for v in newS)
                        if best is None or val > best[0]:
                            best = (val, x, y)
                _, x, y = best
            for k in range(d):
                S[k] += ((x, rule[x]) in tests[k]) - ((x, y) in tests[k])
            for k in range(d):
                bound = math.log(2 / pi[k]) / eta + 0.5 * sumeta
                worst = max(worst, abs(S[k]) / bound)
    print(f"  24 random games, n = 1500: largest |S_t(B)| / bound over all t and B = {worst:.3f} (must be <= 1)")
    print()


# ------------------------------------------------------------------------------------------
# Part C. Proposition 3.9: exact reachable maximum for the ledger rule
# ------------------------------------------------------------------------------------------
def partC():
    print("Part C. Proposition 3.9 (ledger rule): exact maximum of |S(B)| over ALL question/answer sequences")
    print("  instance  |Y|  types M  tests  max|S| reachable  bound M(|Y|-1)   reachable ledger states")
    allok = True
    sharp = True
    for inst in range(12):
        Ysz = random.choice([2, 3, 4])
        M = random.choice([1, 2, 3])
        ntests = random.choice([1, 2, 3])
        # a type is given by the sections of the tests; choose sections at random
        sections = [[frozenset(y for y in range(Ysz) if random.random() < 0.5) for _ in range(ntests)] for _ in range(M)]
        start = tuple(tuple([0] * Ysz) for _ in range(M))
        seen = {start}
        dq = deque([start])
        maxS = 0
        while dq:
            st = dq.popleft()
            for k in range(ntests):
                Sk = sum(st[tau][y] for tau in range(M) for y in sections[tau][k])
                maxS = max(maxS, abs(Sk))
            for tau in range(M):
                D = list(st[tau])
                a = min(range(Ysz), key=lambda y: (D[y], y))  # least entry, ties to least answer
                for yh in range(Ysz):
                    E = D[:]
                    E[a] += 1
                    E[yh] -= 1
                    ns = list(st)
                    ns[tau] = tuple(E)
                    ns = tuple(ns)
                    if ns not in seen:
                        seen.add(ns)
                        dq.append(ns)
        bound = M * (Ysz - 1)
        allok &= maxS <= bound
        inv = all(all(e in (-1, 0, 1) for e in D) and sum(e == -1 for e in D) <= 1 for st in seen for D in st)
        sharp &= inv and maxS <= M
        print(f"  {inst:6d}   {Ysz:3d}   {M:5d}   {ntests:5d}   {maxS:12d}   {bound:12d}   {len(seen):10d}")
    print("  every instance within the bound:", allok, "(the state space is finite, so the search is exhaustive for all n)")
    print("  sharper invariant (every ledger entry in {-1,0,1}, at most one -1 per type; hence |S(B)| <= M):", sharp)
    print()


# ------------------------------------------------------------------------------------------
# Part D. Proposition 3.10, exact rationals
# ------------------------------------------------------------------------------------------
def partD():
    print("Part D. Proposition 3.10 in exact rational arithmetic (any imitator; here three imitators)")
    for name in ["random", "always1", "sign-of-book"]:
        S = [Fraction(0), Fraction(0)]
        n = 16   # exact rationals: the sizes of the denominators grow exponentially, so n is small
        for t in range(n):
            if S == [0, 0]:
                v = (Fraction(1), Fraction(1))
            else:
                mx = max(abs(S[0]), abs(S[1]))
                v = (-S[1] / mx, S[0] / mx)
            assert all(-1 <= c <= 1 for c in v)
            if name == "random":
                a = random.randrange(2)
            elif name == "always1":
                a = 1
            else:
                a = 0 if (S[0] * v[0] + S[1] * v[1]) > 0 else 1
            y = 1 - a

            def b(k, vv, ans):
                return max(vv[k], 0) if ans == 1 else max(-vv[k], 0)

            for k in range(2):
                S[k] += b(k, v, a) - b(k, v, y)
        sq = S[0] ** 2 + S[1] ** 2
        print(f"  {name:13s} n = {n}: |S|^2 = {float(sq):9.1f} >= n: {sq >= n};  max_k |S_k| = {float(max(abs(S[0]), abs(S[1]))):6.1f} >= sqrt(n/2) = {math.sqrt(n / 2):.1f}")
    print()


# ------------------------------------------------------------------------------------------
# Part E. Proposition 6.7
# ------------------------------------------------------------------------------------------
def binom_pmf(n, p):
    lp, lq = math.log(p), math.log(1 - p)
    return [math.exp(math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1) + k * lp + (n - k) * lq) for k in range(n + 1)]


def partE():
    print("Part E. Proposition 6.7")
    worst = 0.0
    for i in range(1, 50001):
        u = 0.5 * i / 50000
        worst = max(worst, math.log((1 + u) / (1 - u)) / (8 * u / 3))
    print(f"  max over u in (0, 1/2] of ln((1+u)/(1-u)) / (8u/3) = {worst:.6f} (<= 1; equality would be at u = 1/2 only if tight)")
    print("       n    n*KL     TV(exact)   sqrt(n*KL/2)   (1-TV)/2   (1-1/sqrt3)/2")
    for n in [1, 2, 3, 10, 100, 1000, 10000]:
        th = 1 / (4 * math.sqrt(n))
        kl = 2 * th * math.log((1 + 2 * th) / (1 - 2 * th))
        P = binom_pmf(n, 0.5 + th)
        Q = binom_pmf(n, 0.5 - th)
        tv = 0.5 * sum(abs(p - q) for p, q in zip(P, Q))
        print(f"  {n:6d}   {n * kl:.4f}   {tv:.4f}      {math.sqrt(n * kl / 2):.4f}        {(1 - tv) / 2:.4f}     {(1 - 1 / math.sqrt(3)) / 2:.4f}")
    # the event-based argument against the best possible estimator: r_hat = fraction of ones
    print("  Monte Carlo, imitator r_hat = empirical frequency, n = 400: Pr[|r_hat - p| >= 1/(4 sqrt n)] under P+ and P-")
    n = 400
    th = 1 / (4 * math.sqrt(n))
    for sgn in (+1, -1):
        p = 0.5 + sgn * th
        hits = 0
        R = 20000
        for _ in range(R):
            k = sum(random.random() < p for _ in range(n))
            hits += abs(k / n - p) >= th
        print(f"    p = {p:.4f}: {hits / R:.3f} (the proposition says: >= 0.21 for at least one of the two)")
    print()


# ------------------------------------------------------------------------------------------
# Part F. Theorem 3.3: Rule NH, exhaustive small games
# ------------------------------------------------------------------------------------------
def G(v, s):
    return (v + 1) ** -0.5 * math.exp(s * s / (2 * (v + 1)))


def slope_NH(S, V, pure_sign):
    cN = 0.5 * (G(V + 1, S + 1) - G(V + 1, S - 1))
    cH = pure_sign * 2 ** (V - 1) if V >= 1 and pure_sign != 0 else 0.0
    return 0.5 * cN + 0.5 * cH


def partF():
    print("Part F. Theorem 3.3 (Rule NH): exhaustive search over all sequences of (question, answer), small games")
    print("  game  |X| |Y| tests  depth   nodes    max S^2/RHS(i)   max V/(K+2) over pure histories")
    overall = (0.0, 0.0)
    for g in range(6):
        nx, ny = 2, 3
        d = 3
        tests = [{(x, y) for x in range(nx) for y in range(ny) if random.random() < 0.45} for _ in range(d)]
        w = [random.random() + 0.05 for _ in range(d)]
        s = sum(w) * random.choice([1.0, 1.5])
        pi = [wi / s for wi in w]
        if g % 2 == 1:  # make one test light
            pi[0] = pi[0] / 64
        depth = 7
        r1 = r2 = 0.0
        nodes = 0

        def rec(state, k):
            nonlocal r1, r2, nodes
            nodes += 1
            for j in range(d):
                S, V, sg = state[j]
                lam = math.log(1 / pi[j])
                rhs = (V + 1) * (2 * lam + 2 * math.log(2) + math.log(V + 1))
                r1 = max(r1, S * S / rhs)
                if sg != 0 and sg != 9:
                    r2 = max(r2, V / (math.log2(1 / pi[j]) + 2))
            if k == depth:
                return
            slopes = [slope_NH(S, V, (sg if sg in (1, -1) else 0)) for (S, V, sg) in state]
            rule = {}
            for x in range(nx):
                sc = [sum(pi[j] * slopes[j] * ((x, y) in tests[j]) for j in range(d)) for y in range(ny)]
                rule[x] = min(range(ny), key=lambda y: (sc[y], y))
            for x in range(nx):
                for y in range(ny):
                    ns = []
                    for j in range(d):
                        S, V, sg = state[j]
                        gg = ((x, rule[x]) in tests[j]) - ((x, y) in tests[j])
                        if gg != 0:
                            if sg == 0:
                                sg2 = gg
                            elif sg == gg:
                                sg2 = sg
                            else:
                                sg2 = 9  # not pure
                            ns.append((S + gg, V + 1, sg2))
                        else:
                            ns.append((S, V, sg))
                    rec(tuple(ns), k + 1)

        rec(tuple((0, 0, 0) for _ in range(d)), 0)
        overall = (max(overall[0], r1), max(overall[1], r2))
        print(f"  {g:4d}   {nx:3d} {ny:3d} {d:5d}  {depth:5d}  {nodes:7d}     {r1:.4f}            {r2:.4f}")
    print(f"  largest ratios: {overall[0]:.4f} and {overall[1]:.4f} (both must be <= 1)")
    print()


# ------------------------------------------------------------------------------------------
# Part G. Theorem 6.2 under rehearsal
# ------------------------------------------------------------------------------------------
def partG():
    print("Part G. Theorem 6.2: rehearsal with Rule NH, L = 3, runs of variable length; d_B(a) computed exactly")
    # scaffold: z in {0,1,2} uniform; call 1 asks question z; if the answer is 0 the run stops,
    # otherwise call 2 asks question 3 + (answer), and if that answer is 2, call 3 asks question 6.
    Y = [0, 1, 2]
    L = 3
    P = {q: None for q in range(7)}
    rngP = random.Random(7)
    for q in range(7):
        w = [rngP.random() for _ in Y]
        w[1] = 0.0 if q in (0, 6) else w[1]   # the human never answers 1 at questions 0 and 6
        s = sum(w)
        P[q] = [wi / s for wi in w]
    tests = [
        {(q, 1) for q in range(7)},                    # B0: answer 1
        {(q, 2) for q in range(3)},                    # B1: answer 2 at top-level questions
        {(q, y) for q in range(7) for y in Y if (q + y) % 2 == 0},
        {(0, 1), (6, 1)},                              # B3: never satisfied by the human
    ]
    pi = [0.3, 0.2, 0.2, 0.1]

    def run_calls(rule, z):
        calls = [z]
        a = rule[z]
        if a == 0:
            return calls
        calls.append(3 + a)
        a2 = rule[3 + a]
        if a2 == 2:
            calls.append(6)
        return calls

    def dB(rule, k):
        tot = 0.0
        for z in range(3):
            for x in run_calls(rule, z):
                tot += ((x, rule[x]) in tests[k]) - sum(P[x][y] for y in Y if (x, y) in tests[k])
        return tot / 3

    n = 60
    R = 4000
    rng = random.Random(99)
    sumS = [0.0] * 4
    sumDelta = [0.0] * 4
    maxN3 = 0
    sumdep3 = 0.0
    for r in range(R):
        st = [(0, 0, 0)] * 4
        Dsum = [0.0] * 4
        for t in range(n):
            slopes = [slope_NH(S, V, (sg if sg in (1, -1) else 0)) for (S, V, sg) in st]
            rule = {}
            for x in range(7):
                sc = [sum(pi[j] * slopes[j] * ((x, y) in tests[j]) for j in range(4)) for y in Y]
                rule[x] = min(Y, key=lambda y: (sc[y], y))
            for k in range(4):
                Dsum[k] += dB(rule, k)
            z = rng.randrange(3)
            calls = run_calls(rule, z)
            J = rng.randrange(1, L + 1)
            if J <= len(calls):
                x = calls[J - 1]
                u = rng.random()
                y = 0 if u < P[x][0] else (1 if u < P[x][0] + P[x][1] else 2)
                ns = []
                for k in range(4):
                    S, V, sg = st[k]
                    gg = ((x, rule[x]) in tests[k]) - ((x, y) in tests[k])
                    if gg != 0:
                        sg2 = gg if sg == 0 else (sg if sg == gg else 9)
                        ns.append((S + gg, V + 1, sg2))
                    else:
                        ns.append((S, V, sg))
                st = ns
        for k in range(4):
            sumS[k] += st[k][0]
            sumDelta[k] += Dsum[k] / n
        maxN3 = max(maxN3, st[3][0])
        sumdep3 += Dsum[3] / n
    print("  test   (L/n) E S_n     E Delta_n     bound (a)")
    for k in range(4):
        W = 2 * math.log(1 / pi[k]) + 1.39 + math.log(n + 1)
        print(f"   B{k}    {L / n * sumS[k] / R:+.4f}      {sumDelta[k] / R:+.4f}      {L * math.sqrt((1 + 1 / n) * W / n):.4f}")
    print(f"  B3 (never satisfied by the human): largest N_n(B3) over {R} rehearsals = {maxN3}  (Theorem 3.3(ii): <= K+2 = {math.log2(1 / pi[3]) + 2:.2f})")
    print(f"  B3: E[calls per deployed run with answer in B3] = {sumdep3 / R:.4f}  (Theorem 6.2(c): <= L(K+2)/n = {L * (math.log2(1 / pi[3]) + 2) / n:.4f})")
    print()


# ------------------------------------------------------------------------------------------
# Part H. Proposition 6.6: the algebra of the proof
# ------------------------------------------------------------------------------------------
def partH():
    print("Part H. Proposition 6.6: algebra of steps (3)-(5)")
    ok = True
    for mu in [0.01, 0.1, 0.3, 0.5, 0.9, 1.0]:
        lam = mu / (2 * math.e)
        rho = 1 - lam * mu / 2 + lam ** 2 * math.e / 2
        ok &= abs(rho - (1 - mu ** 2 / (8 * math.e))) < 1e-14
        bound = math.exp(1 / math.e) / (1 - rho)
        C = (1 / lam) * math.log(bound)
        Cstated = (2 / mu) * (1 + math.e * math.log(8 * math.e / mu ** 2))
        ok &= abs(C - Cstated) < 1e-9 * Cstated
        # step (3): sqrt(r^2 - 2 mu r + 1) <= r - mu/2 for r >= 1/mu
        for r in [1 / mu, 1 / mu + 0.5, 3 / mu, 100 / mu]:
            ok &= math.sqrt(r * r - 2 * mu * r + 1) <= r - mu / 2 + 1e-12
        ok &= math.exp((1 + mu) / (2 * math.e)) <= math.exp(1 / math.e) + 1e-12
    # e^u <= 1 + u + (e/2) u^2 on [-1,1]
    ok &= all(math.exp(u) <= 1 + u + (math.e / 2) * u * u + 1e-15 for u in [i / 1000 - 1 for i in range(2001)])
    print("  rho = 1 - mu^2/(8e), C(mu) formula, step (3), e^u inequality, (1+mu)/(2e) <= 1/e:", ok)
    print()


if __name__ == "__main__":
    partA()
    partB()
    partC()
    partD()
    partE()
    partF()
    partG()
    partH()
    print("all parts finished")
