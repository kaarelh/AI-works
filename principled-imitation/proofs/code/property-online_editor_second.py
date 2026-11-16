"""Editor's checks in the second round, part property-online.

Written by the editor after the second check (verification/property-online-second.md).
It shares no code with the other scripts of this part.
Run from proofs/code/:   python3 property-online_editor_second.py > property-online_editor_second.out

Parts
  1  Example 2.5: the score table from the set definitions; a search over every choice among the
     minimisers for parameters other than those of the first round (n not a square, other rates
     and weights); Rule NH on the same family against every adversary (all reachable states).
  2  Proposition 3.9: all reachable ledger states (every choice among the least entries); the
     stated bound and the sharper bound that the second check observed.
  3  Proposition 3.10 in exact rational arithmetic.
  4  Proposition 6.7 and finding F1 of the second check: the constants; in Example 6.5 the mean
     of Delta_n over rehearsals is of order 1/n while |Delta_n| is of order 1/sqrt(n).
  5  Proposition 2.4: step (2) of the proof on random data; the bound on small games, for every
     adversary and every choice among the minimisers.
  6  Proposition 6.6: the algebra of steps (3) to (5); C(mu0) < 0 for large mu0; the drift
     argument on a reflected walk.
  7  Theorem 3.3: inequality (1.1) for the potential of Rule NH on all histories of length <= 9;
     all reachable states of small games (every adversary, every exact minimiser).
  8  Lemma 6.1 and Theorem 6.2: exact enumeration with rational probabilities on a scaffold whose
     runs have variable length; the same with a call drawn uniformly among the calls of the run.
  9  Small arithmetic used in the decisions (F2, F5, the idea of the proof of Pr5).
"""
import math
import random
import itertools
from fractions import Fraction

TOL = 1e-12


# ----------------------------------------------------------------------------------------------
# Potentials of Rule NH (Lemma 1.4(c), (d)); a test's state is (s, v, pur) with
# pur = 0 (no non-zero increment yet), +1 or -1 (pure with that sign), 2 (not pure).
# ----------------------------------------------------------------------------------------------
def G(v, s):
    return math.exp(s * s / (2.0 * (v + 1))) / math.sqrt(v + 1)


def c_N(s, v):
    return 0.5 * (G(v + 1, s + 1) - G(v + 1, s - 1))


def u_H(v, pur):
    if v == 0:
        return 1.0
    return 2.0 ** (v - 1) if pur in (1, -1) else 0.0


def c_H(v, pur):
    return pur * 2.0 ** (v - 1) if (v >= 1 and pur in (1, -1)) else 0.0


def u_NH(state):
    s, v, pur = state
    return 0.5 * G(v, s) + 0.5 * u_H(v, pur)


def c_NH(state):
    s, v, pur = state
    return 0.5 * c_N(s, v) + 0.5 * c_H(v, pur)


def step(state, g):
    s, v, pur = state
    if g == 0:
        return state
    if pur == 0:
        p2 = g
    elif pur == g:
        p2 = pur
    else:
        p2 = 2
    return (s + g, v + 1, p2)


def argmins(scores):
    m = min(scores)
    return [i for i, sc in enumerate(scores) if sc <= m + TOL * max(1.0, abs(m))]


# ----------------------------------------------------------------------------------------------
# Part 1. Example 2.5
# ----------------------------------------------------------------------------------------------
def in_B(x, y):
    return int(y == 1)


def in_D(x, y):
    typ = x[0]
    if typ == "o":
        return int(y == 1)
    if typ == "obar":
        return int(y in (0, 2))
    return int(y == 2)          # type e


def n_star(beta, delta, eta):
    N = 0
    while beta * math.sinh(eta * N) < delta * math.sinh(eta):
        N += 1
    return N


def ex25_all_choices(n, beta, delta, eta):
    """Adversary of the proof against the rule of Theorem 2.1; ALL choices among the minimisers.
    The state (N, S(D)) determines the scores, so the set of reachable states is followed."""
    Ns = n_star(beta, delta, eta)
    states = {(0, 0)}
    ok = True
    for t in range(1, n + 1):
        new = set()
        for (N, SD) in states:
            if N >= Ns or SD == 0:
                typ = "e"
            elif SD == -1:
                typ = "o"
            else:
                typ = "obar"
            x = (typ, t)
            b, d = beta * math.sinh(eta * N), delta * math.sinh(eta * SD)
            sc = [b * in_B(x, y) + d * in_D(x, y) for y in (0, 1, 2)]
            m = min(sc)
            for a in (0, 1, 2):
                if sc[a] != m:          # exact minimisers; the ties of the example are exact zeros
                    continue
                if N >= Ns:
                    f = 0
                elif typ == "e":
                    f = 0 if a == 2 else 2
                else:
                    f = 0
                new.add((N + in_B(x, a) - in_B(x, f), SD + in_D(x, a) - in_D(x, f)))
        states = new
        if min(N for N, _ in states) < min(t // 2, Ns):
            ok = False
    return Ns, min(N for N, _ in states), max(N for N, _ in states), ok


def nh_family25_worst(n, beta, delta):
    """Rule NH on the family {B, D} of Example 2.5: every sequence of question types, every human
    with answers in {0, 2} (so the human never satisfies B), every exact minimiser.
    Returns the largest N_n(B) over all of these."""
    start = ((0, 0, 0), (0, 0, 0))
    states = {start}
    best = 0
    for t in range(1, n + 1):
        new = set()
        for (sB, sD) in states:
            cB, cD = beta * c_NH(sB), delta * c_NH(sD)
            for typ in ("e", "o", "obar"):
                x = (typ, t)
                sc = [cB * in_B(x, y) + cD * in_D(x, y) for y in (0, 1, 2)]
                for a in argmins(sc):
                    for f in (0, 2):
                        new.add((step(sB, in_B(x, a) - in_B(x, f)), step(sD, in_D(x, a) - in_D(x, f))))
        states = new
        best = max(best, max(sB[0] for sB, _ in states))
    return best, len(states)


def part1():
    print("Part 1. Example 2.5")
    rng = random.Random(1)
    ok = True
    for _ in range(3000):
        beta, delta, eta = rng.uniform(1e-6, .5), rng.uniform(1e-6, .5), rng.uniform(.001, 1.5)
        N, SD = rng.randint(0, 30), rng.randint(-5, 5)
        b, d = beta * math.sinh(eta * N), delta * math.sinh(eta * SD)
        for typ, tab in (("e", [0, b, d]), ("o", [0, b + d, 0]), ("obar", [d, b, d])):
            x = (typ, 1)
            sc = [b * in_B(x, y) + d * in_D(x, y) for y in (0, 1, 2)]
            ok &= all(abs(p - q) < 1e-12 for p, q in zip(sc, tab))
    print("  score table of the proof = scores from the set definitions (3000 random states):", ok)
    print("  every choice among the minimisers, adversary of the proof:")
    print("        n       beta   delta     eta      N*  min(n//2,N*)  least N_n  largest N_n  holds at every t")
    cases = [(n, 1 / (2 * n), 0.5, 1 / math.sqrt(n)) for n in (1, 2, 3, 7, 50, 333, 1000, 12345, 40000)]
    cases += [(5000, 0.01, 0.2, 0.3), (5000, 1e-6, 0.9, 0.05), (2001, 1e-4, 0.5, 1.0), (3000, 0.3, 0.3, 0.02),
              (4000, 1e-12, 0.5, 0.2)]
    allok = True
    for n, beta, delta, eta in cases:
        Ns, lo, hi, ok = ex25_all_choices(n, beta, delta, eta)
        allok &= ok
        print(f"  {n:7d}  {beta:9.2e}  {delta:5.2f}  {eta:7.4f}  {Ns:6d}  {min(n // 2, Ns):12d}  {lo:9d}  {hi:11d}  {ok}")
    print("  N_t(B) >= min(floor(t/2), N*) at every t, for every choice, in all cases:", allok)
    print("  Rule NH on the same two tests, every adversary who never answers 1, every exact minimiser:")
    for n in (10, 20, 40):
        beta = 1 / (2 * n)
        best, ns = nh_family25_worst(n, beta, 0.5)
        print(f"    n = {n:3d}, beta = 1/(2n): largest N_n(B) = {best}  (bound K(B) + 2 = log2(n) + 3 = {math.log2(n) + 3:.2f});"
              f" {ns} states after round n")
    print()


# ----------------------------------------------------------------------------------------------
# Part 2. Proposition 3.9 (ledger rule)
# ----------------------------------------------------------------------------------------------
def ledger_reachable(nY, sections):
    """sections[tau][k] = frozenset of answers (the section of test k at type tau).
    All ledger states reachable under every sequence of question types and human answers and
    every choice among the least entries."""
    M = len(sections)
    start = tuple(tuple(0 for _ in range(nY)) for _ in range(M))
    seen = {start}
    todo = [start]
    while todo:
        st = todo.pop()
        for tau in range(M):
            row = st[tau]
            m = min(row)
            for a in range(nY):
                if row[a] != m:
                    continue
                for y in range(nY):
                    r = list(row)
                    r[a] += 1
                    r[y] -= 1
                    ns = st[:tau] + (tuple(r),) + st[tau + 1:]
                    if ns not in seen:
                        seen.add(ns)
                        todo.append(ns)
    return seen


def part2():
    print("Part 2. Proposition 3.9 (ledger rule): all reachable ledger states")
    rng = random.Random(7)
    print("  inst  |Y|  M  tests  states  max|S(B)|  M(|Y|-1)  M  max_B #(types with section not empty, not Y)  entries in {-1,0,1}, at most one -1")
    allok = True
    sharp = True
    attained = 0
    for inst in range(16):
        nY = rng.choice([2, 3, 4])
        M = rng.choice([1, 2, 3, 4]) if nY < 4 else rng.choice([1, 2, 3])
        d = rng.choice([1, 2, 3])
        sections = []
        while len(sections) < M:                      # M distinct types
            sec = tuple(frozenset(y for y in range(nY) if rng.random() < 0.5) for _ in range(d))
            if sec not in sections:
                sections.append(sec)
        reach = ledger_reachable(nY, sections)
        worst = 0
        inv = True
        for st in reach:
            for row in st:
                inv &= all(e in (-1, 0, 1) for e in row) and sum(1 for e in row if e == -1) <= 1 and sum(row) == 0
            for k in range(d):
                S = sum(st[tau][y] for tau in range(M) for y in sections[tau][k])
                worst = max(worst, abs(S))
        nontriv = max(sum(1 for tau in range(M) if 0 < len(sections[tau][k]) < nY) for k in range(d))
        allok &= worst <= M * (nY - 1)
        sharp &= inv and worst <= nontriv
        attained += int(worst == nontriv)
        print(f"  {inst:4d}  {nY:3d}  {M}  {d:5d}  {len(reach):6d}  {worst:9d}  {M * (nY - 1):8d}  {M}  {nontriv:8d}  {inv}")
    print("  stated bound M(|Y|-1) holds in every instance:", allok)
    print("  sharper bound holds in every instance (|S(B)| <= number of types whose section of B is neither empty nor Y):", sharp)
    print(f"  the sharper bound is attained in {attained} of 16 instances")
    print()


# ----------------------------------------------------------------------------------------------
# Part 3. Proposition 3.10
# ----------------------------------------------------------------------------------------------
def b_val(v, k, y):
    return max(v[k], 0) if y == 1 else max(-v[k], 0)


def part3():
    print("Part 3. Proposition 3.10, exact rational arithmetic (the adversary of the proof)")
    rng = random.Random(3)

    def run(imit, n):
        S = [Fraction(0), Fraction(0)]
        for t in range(n):
            if S[0] == 0 and S[1] == 0:
                v = (Fraction(1), Fraction(1))
            else:
                mx = max(abs(S[0]), abs(S[1]))
                v = (-S[1] / mx, S[0] / mx)
            assert all(-1 <= c <= 1 for c in v) and S[0] * v[0] + S[1] * v[1] == 0
            a = imit(S, v)
            y = 1 - a
            for k in range(2):
                g = b_val(v, k, a) - b_val(v, k, y)
                assert g == (2 * a - 1) * v[k]
                S[k] += g
        return S

    imitators = {
        "always 1": lambda S, v: 1,
        "random": lambda S, v: rng.randint(0, 1),
        "quadratic rule": lambda S, v: min((0, 1), key=lambda a: sum(S[k] * b_val(v, k, a) for k in range(2))),
        "one-rate rule": lambda S, v: min((0, 1), key=lambda a: sum(math.sinh(0.3 * float(S[k])) * float(b_val(v, k, a)) for k in range(2))),
    }
    for name, im in imitators.items():
        n = 14
        S = run(im, n)
        sq = S[0] ** 2 + S[1] ** 2
        print(f"  {name:15s} n = {n}: S_1^2 + S_2^2 = {float(sq):8.3f} >= n: {sq >= n};  max_k |S_k| = {float(max(abs(S[0]), abs(S[1]))):6.3f}"
              f" >= sqrt(n/2) = {math.sqrt(n / 2):.3f}: {max(abs(S[0]), abs(S[1])) ** 2 * 2 >= n}")
    print()


# ----------------------------------------------------------------------------------------------
# Part 4. Proposition 6.7 and finding F1
# ----------------------------------------------------------------------------------------------
def binom_logpmf(n, k, p):
    return math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1) + k * math.log(p) + (n - k) * math.log(1 - p)


def tv_binom(n, p, q):
    return 0.5 * sum(abs(math.exp(binom_logpmf(n, k, p)) - math.exp(binom_logpmf(n, k, q))) for k in range(n + 1))


def ex65_law(n, p):
    """Example 6.5 (one question, one test B = {(x0, 1)}, least answer among the minimisers) with a
    human who answers 1 with probability p.  The slope of Rule NH has the sign of the book
    (checked below), so a_t = 1 exactly if the book is negative.  Returns the law of the number of
    rounds t <= n with a_t = 1, as a list indexed by that number."""
    law = {(0, 0): 1.0}                     # (book, count) -> probability
    for t in range(n):
        new = {}
        for (S, c), pr in law.items():
            a = 1 if S < 0 else 0
            for y, py in ((1, p), (0, 1 - p)):
                key = (S + a - y, c + a)
                new[key] = new.get(key, 0.0) + pr * py
        law = new
    out = [0.0] * (n + 1)
    for (S, c), pr in law.items():
        assert S in (-1, 0)
        out[c] += pr
    return out


def part4():
    print("Part 4. Proposition 6.7; the mean and the size of Delta_n in Example 6.5 (finding F1)")
    worst_ratio = max(math.log((1 + u) / (1 - u)) / (8 * u / 3) for u in [i / 10000 for i in range(1, 5001)])
    print(f"  max over 0 < u <= 1/2 of ln((1+u)/(1-u)) / (8u/3) = {worst_ratio:.6f} (must be <= 1)")
    print("        n   theta       n*kappa   (direct KL)*n   TV exact   1/sqrt(3)   (1-TV)/2")
    worst_tv = 0.0
    for n in list(range(1, 400)) + [1000, 5000, 20000]:
        th = 1 / (4 * math.sqrt(n))
        p, q = 0.5 + th, 0.5 - th
        kappa = 2 * th * math.log((1 + 2 * th) / (1 - 2 * th))
        direct = p * math.log(p / q) + q * math.log(q / p)
        tv = tv_binom(n, p, q)
        worst_tv = max(worst_tv, tv)
        assert abs(kappa - direct) < 1e-12 and n * kappa <= 2 / 3 and tv <= math.sqrt(n * kappa / 2) + 1e-12
        if n in (1, 2, 3, 10, 100, 1000, 20000):
            print(f"  {n:7d}  {th:7.5f}  {n * kappa:8.5f}  {n * direct:13.5f}  {tv:9.5f}  {1 / math.sqrt(3):9.5f}  {(1 - tv) / 2:8.5f}")
    print(f"  largest exact TV over all n examined = {worst_tv:.4f} (at n = 1); so (1 - TV)/2 >= {(1 - worst_tv) / 2:.4f} >= 0.211")
    # the slope of Rule NH for one test has the sign of the book whenever |book| <= 1
    sign_ok = True
    for v in range(0, 60):
        for s in (-1, 0, 1):
            for pur in (0, 1, -1, 2):
                if (pur == 0) != (v == 0):
                    continue
                if pur in (1, -1) and s != pur * v:
                    continue
                if pur == 2 and (v < 2 or (v - abs(s)) % 2):
                    continue
                c = c_NH((s, v, pur))
                sign_ok &= (c > 0) == (s > 0) and (c < 0) == (s < 0)
    print("  one test: the slope of Rule NH has the sign of the book (all states with |book| <= 1, V < 60):", sign_ok)
    print("  Example 6.5, fair coin: Delta_n = (fraction of rounds with a_t = 1) - 1/2, exact law by dynamic programming")
    print("        n      E Delta_n     -1/(2n)    E|Delta_n|   E|Delta_n|*sqrt(n)   Pr[|Delta_n| >= 1/(4 sqrt n)]")
    for n in (10, 100, 400, 1600):
        law = ex65_law(n, 0.5)
        mean = sum(pr * (c / n - 0.5) for c, pr in enumerate(law))
        mabs = sum(pr * abs(c / n - 0.5) for c, pr in enumerate(law))
        th = 1 / (4 * math.sqrt(n))
        tail = sum(pr for c, pr in enumerate(law) if abs(c / n - 0.5) >= th - 1e-15)
        print(f"  {n:7d}  {mean:+.6f}  {-1 / (2 * n):+.6f}  {mabs:.6f}   {mabs * math.sqrt(n):.4f}              {tail:.4f}")
    print("  the same rule against the two humans of Proposition 6.7: Pr[|r_hat - P(1|x0)| >= 1/(4 sqrt n)]")
    for n in (10, 100, 400, 1600):
        th = 1 / (4 * math.sqrt(n))
        res = []
        for p in (0.5 + th, 0.5 - th):
            law = ex65_law(n, p)
            res.append(sum(pr for c, pr in enumerate(law) if abs(c / n - p) >= th - 1e-15))
        print(f"    n = {n:5d}:  under P+ {res[0]:.4f},  under P- {res[1]:.4f}   (the proposition: at least 0.21 for one of the two)")
    print()


# ----------------------------------------------------------------------------------------------
# Part 5. Proposition 2.4
# ----------------------------------------------------------------------------------------------
def part5():
    print("Part 5. Proposition 2.4")
    rng = random.Random(5)
    worst = -1e9
    strict = 0
    for _ in range(20000):
        k = rng.randint(1, 8)
        p = [rng.random() for _ in range(k)]
        tot = rng.choice([1.0, rng.uniform(0.05, 1.0)])
        sm = sum(p)
        p = [pi * tot / sm for pi in p]
        z = [rng.randint(-12, 12) for _ in range(k)]
        eta = rng.uniform(0.01, 2.0)
        eta2 = eta * rng.uniform(0.01, 1.0)

        def Gam(e):
            return math.log(sum(0.5 * pi * (math.exp(e * zi) + math.exp(-e * zi)) for pi, zi in zip(p, z))) / e
        diff = Gam(eta2) - Gam(eta)
        worst = max(worst, diff)
        strict += int(diff < -1e-12)
    print(f"  step (2): largest Gamma(eta') - Gamma(eta) over 20000 random cases with eta' <= eta, weights of sum <= 1: {worst:.3e} (must be <= 0);")
    print(f"            strictly negative in {strict} cases (it is 0 when all books are 0 and the weights sum to 1)")

    # small games: every adversary, every exact minimiser; the state is the vector of books
    def game(nX, nY, tests, weights, c, depth):
        d = len(tests)
        states = {tuple([0] * d)}
        ratio = 0.0
        sum_eta = 0.0
        for t in range(1, depth + 1):
            eta = c / math.sqrt(t)
            sum_eta += eta
            new = set()
            for S in states:
                sl = [weights[k] * math.sinh(eta * S[k]) for k in range(d)]
                for x in range(nX):
                    sc = [sum(sl[k] for k in range(d) if (x, y) in tests[k]) for y in range(nY)]
                    for a in argmins(sc):
                        for y in range(nY):
                            new.add(tuple(S[k] + ((x, a) in tests[k]) - ((x, y) in tests[k]) for k in range(d)))
            states = new
            for S in states:
                for k in range(d):
                    bound = math.log(2 / weights[k]) / eta + 0.5 * sum_eta
                    ratio = max(ratio, abs(S[k]) / bound)
        return ratio, len(states)

    worst = 0.0
    for g in range(8):
        nX, nY, d = rng.choice([1, 2, 3]), rng.choice([2, 3]), rng.choice([2, 3])
        tests = [frozenset((x, y) for x in range(nX) for y in range(nY) if rng.random() < 0.5) for _ in range(d)]
        w = [rng.random() for _ in range(d)]
        tot = rng.choice([1.0, 0.5])
        w = [wi * tot / sum(w) for wi in w]
        for c in (0.5, 1.0, 2.0):
            r, ns = game(nX, nY, tests, w, c, 9)
            worst = max(worst, r)
    print(f"  8 random small games, c in {{0.5, 1, 2}}, 9 rounds, all adversaries and all minimisers: largest |S_t(B)| / bound = {worst:.4f} (must be <= 1)")
    print(f"  constants: 1 + ln 2 = {1 + math.log(2):.4f} <= 1.70;  (1 + ln 2)^2 = {(1 + math.log(2)) ** 2:.3f}")
    print()


# ----------------------------------------------------------------------------------------------
# Part 6. Proposition 6.6
# ----------------------------------------------------------------------------------------------
def C_of(mu):
    return (2 / mu) * (1 + math.e * math.log(8 * math.e / mu ** 2))


def part6():
    print("Part 6. Proposition 6.6")
    ok = True
    for i in range(1, 1001):
        mu = i / 1000
        lam = mu / (2 * math.e)
        rho = 1 - lam * mu / 2 + (math.e / 2) * lam ** 2
        ok &= abs(rho - (1 - mu ** 2 / (8 * math.e))) < 1e-14
        ok &= (1 + mu) / (2 * math.e) <= 1 / math.e + 1e-15
        ok &= abs((1 / lam) * math.log(8 * math.e * math.exp(1 / math.e) / mu ** 2) - C_of(mu)) < 1e-9 * C_of(mu)
        for j in range(0, 400):
            r = 1 / mu + j * 0.25
            ok &= math.sqrt(r * r - 2 * mu * r + 1) <= r - mu / 2 + 1e-12
    for i in range(-1000, 1001):
        u = i / 1000
        ok &= math.exp(u) <= 1 + u + (math.e / 2) * u * u + 1e-15
    print("  steps (3) to (5): rho = 1 - mu^2/(8e); (1+mu)/(2e) <= 1/e; sqrt(r^2-2mu r+1) <= r - mu/2 for r >= 1/mu;"
          " e^u <= 1+u+(e/2)u^2 on [-1,1]; C(mu) = (1/lambda) ln(8e e^(1/e)/mu^2), for 0 < mu <= 1:", ok)
    root = math.sqrt(8 * math.e * math.exp(1 / math.e))
    print(f"  C(1) = {C_of(1):.3f}, C(0.5) = {C_of(0.5):.2f}, C(0.082) = {C_of(0.082):.1f}; C(mu0) < 0 for mu0 > {root:.3f}, for instance C(6) = {C_of(6):.4f}")
    print("  (so the statement needs mu0 <= 1, or at least C(mu0) >= 0, in the degenerate case where all books vanish)")
    print("  drift argument on the walk r -> r+1 with probability (1-mu)/2, r -> r-1 otherwise (from 0: to 1),")
    print("  which has E[r_t^2 | past] = r_{t-1}^2 - 2 mu r_{t-1} + 1 and steps of size 1:")
    print("     mu     max_n E r_n   C(mu)     max_n E exp(lambda r_n)   8e e^(1/e)/mu^2")
    for mu in (0.05, 0.2, 0.5, 1.0):
        lam = mu / (2 * math.e)
        law = {0: 1.0}
        best_r = best_e = 0.0
        for t in range(3000):
            new = {}
            for r, pr in law.items():
                if pr < 1e-18:
                    continue
                if r == 0:
                    new[1] = new.get(1, 0.0) + pr
                else:
                    new[r + 1] = new.get(r + 1, 0.0) + pr * (1 - mu) / 2
                    new[r - 1] = new.get(r - 1, 0.0) + pr * (1 + mu) / 2
            law = new
            best_r = max(best_r, sum(r * pr for r, pr in law.items()))
            best_e = max(best_e, sum(math.exp(lam * r) * pr for r, pr in law.items()))
        print(f"    {mu:4.2f}   {best_r:10.4f}   {C_of(mu):8.2f}   {best_e:12.4f}              {8 * math.e * math.exp(1 / math.e) / mu ** 2:10.1f}")
    print()


# ----------------------------------------------------------------------------------------------
# Part 7. Theorem 3.3
# ----------------------------------------------------------------------------------------------
def part7():
    print("Part 7. Theorem 3.3 (Rule NH)")
    worst = -1e9
    worst_nz = -1e9
    eq_h = 0.0
    count = 0
    for k in range(0, 10):
        for hist in itertools.product((-1, 0, 1), repeat=k):
            st = (0, 0, 0)
            for g in hist:
                st = step(st, g)
            # the state computed step by step agrees with the definitions on the history
            nz = [g for g in hist if g != 0]
            pur = 0 if not nz else (nz[0] if all(g == nz[0] for g in nz) else 2)
            assert st == (sum(hist), len(nz), pur)
            for g in (-1, 0, 1):
                st2 = step(st, g)
                lhs, rhs = u_NH(st2), u_NH(st) + g * c_NH(st)
                worst = max(worst, (lhs - rhs) / max(1.0, rhs))
                if g != 0:
                    worst_nz = max(worst_nz, (lhs - rhs) / max(1.0, rhs))
                eq_h = max(eq_h, abs(u_H(st2[1], st2[2]) - u_H(st[1], st[2]) - g * c_H(st[1], st[2])))
                count += 1
    print(f"  (1.1) for (G/2 + u^H/2, c^NH) on all {count} pairs (history of length <= 9, increment): largest (left - right)/max(1, right) = {worst:.3e} (must be <= 0 up to rounding);")
    print(f"        for increments +1 and -1 alone the largest value is {worst_nz:.3e} (an equality for the increment 0)")
    print(f"  halving part alone: largest |left - right| = {eq_h:.1e} (an identity)")
    print(f"  u^H along a pure history with v = 0, 1, 2, 3, 4 non-zero increments: {[u_H(v, 1 if v else 0) for v in range(5)]}")

    rng = random.Random(11)

    def search(nX, nY, tests, weights, depth):
        d = len(tests)
        lam = [math.log(1 / w) for w in weights]
        kb = [math.log2(1 / w) for w in weights]
        tot = sum(weights)
        start = tuple([(0, 0, 0)] * d)
        states = {start}
        r1 = r2 = r3 = 0.0
        nstates = 1
        for t in range(1, depth + 1):
            new = set()
            for st in states:
                sl = [weights[k] * c_NH(st[k]) for k in range(d)]
                for x in range(nX):
                    sc = [sum(sl[k] for k in range(d) if (x, y) in tests[k]) for y in range(nY)]
                    for a in argmins(sc):
                        for y in range(nY):
                            new.add(tuple(step(st[k], ((x, a) in tests[k]) - ((x, y) in tests[k])) for k in range(d)))
            states = new
            nstates = len(states)
            for st in states:
                r3 = max(r3, sum(weights[k] * u_NH(st[k]) for k in range(d)) / tot)
                for k in range(d):
                    s, v, pur = st[k]
                    r1 = max(r1, s * s / ((v + 1) * (2 * lam[k] + 2 * math.log(2) + math.log(v + 1))))
                    if pur in (1, -1, 0):
                        r2 = max(r2, v / (kb[k] + 2))
        return r1, r2, r3, nstates

    print("  all reachable states of small games (every sequence of questions and human answers, every exact minimiser):")
    print("  game  |X| |Y| tests  rounds  states at the end  max S^2/RHS(i)  max V/(K+2), pure  max (sum pi u)/(sum pi)")
    w1 = w2 = w3 = 0.0
    for g in range(8):
        nX, nY, d = rng.choice([1, 2, 3]), rng.choice([2, 3]), rng.choice([2, 3])
        tests = [frozenset((x, y) for x in range(nX) for y in range(nY) if rng.random() < 0.5) for _ in range(d)]
        w = [rng.random() for _ in range(d)]
        tot = rng.choice([1.0, 0.6])
        w = [wi * tot / sum(w) for wi in w]
        if g % 3 == 2:
            w[0] /= 256
        depth = 10 if d == 3 else 12
        r1, r2, r3, ns = search(nX, nY, tests, w, depth)
        w1, w2, w3 = max(w1, r1), max(w2, r2), max(w3, r3)
        print(f"  {g:4d}  {nX:3d} {nY:3d} {d:5d}  {depth:6d}  {ns:17d}  {r1:14.4f}  {r2:17.4f}  {r3:22.6f}")
    # the family of Proposition 3.5 with m = 3 (8 tests of weight 1/8)
    m = 3
    tests = [frozenset((x, y) for x in range(m) for y in (0, 1) if y != c[x]) for c in itertools.product((0, 1), repeat=m)]
    r1, r2, r3, ns = search(m, 2, tests, [1 / 8] * 8, 8)
    w1, w2, w3 = max(w1, r1), max(w2, r2), max(w3, r3)
    print(f"  Prop. 3.5, m = 3: 8 rounds, {ns} states: max S^2/RHS(i) = {r1:.4f}, max V/(K+2) over pure histories = {r2:.4f} (K + 2 = 5), max potential ratio = {r3:.6f}")
    print(f"  largest ratios over all games: (i) {w1:.4f}, (ii) {w2:.4f}, potential {w3:.12f} (all must be <= 1; the potential ratio is 1 while no book has moved)")
    assert w3 <= 1 + 1e-12
    print()


# ----------------------------------------------------------------------------------------------
# Part 8. Lemma 6.1 and Theorem 6.2: exact enumeration
# ----------------------------------------------------------------------------------------------
L8 = 3
Y8 = (0, 1, 2)
X8 = tuple(range(7))
F = Fraction
P8 = {  # the human: P(y | x); never the answer 2 at the questions 3, ..., 6
    0: (F(1, 2), F(1, 4), F(1, 4)),
    1: (F(1, 5), F(3, 5), F(1, 5)),
    2: (F(1, 3), F(1, 3), F(1, 3)),
    3: (F(2, 3), F(1, 3), F(0)),
    4: (F(1, 4), F(3, 4), F(0)),
    5: (F(1, 2), F(1, 2), F(0)),
    6: (F(9, 10), F(1, 10), F(0)),
}
TESTS8 = [
    frozenset((x, 1) for x in X8),                                         # "the answer is 1"
    frozenset((x, y) for x in X8 for y in (1, 2) if x % 2 == 0),           # "not 0, at an even question"
    frozenset((x, 0) for x in (0, 1, 2)) | frozenset((x, 1) for x in (5, 6)),
    frozenset((x, 2) for x in (3, 4, 5, 6)),                               # never satisfied by the human
]
W8 = [0.4, 0.3, 0.2, 0.1]


def run8(rule, z):
    """The calls of the run of a rule (a tuple indexed by the question) on the top-level input z."""
    calls = [z]
    a1 = rule[z]
    if a1 != 0:
        calls.append(2 + a1)
        a2 = rule[2 + a1]
        if a2 != 2:
            calls.append(5 + a2)
    return calls


def part8():
    print("Part 8. Lemma 6.1 and Theorem 6.2: exact enumeration (rational probabilities)")
    print("  scaffold: L = 3, runs of 1, 2 or 3 calls depending on the answers; 7 questions, 3 answers, 4 set tests,")
    print("  weights 0.4, 0.3, 0.2, 0.1; Rule NH, the least answer among the minimisers; the test B3 is never satisfied by the human")
    d = len(TESTS8)
    start = tuple([(0, 0, 0)] * d)
    law = {start: F(1)}
    ES = [F(0)] * d            # sum over rounds of E g_t(B)
    ED = [F(0)] * d            # sum over rounds of E d_B(a_t)
    ES_wrong = [F(0)] * d      # the same as ES if the asked call were uniform among the calls of the run
    EN3 = F(0)                 # sum over rounds of E n_{B3}(a_t)
    maxN3 = 0
    lengths = set()
    print("     n   states   max_B |E S_n - (n/L) E Delta_n|   max_B |E Delta_n|   least bound (a)   max N_n(B3)   (L/n) E N_n(B3)   L(K+2)/n   wrong protocol: max_B |E S'_n - (n/L) E Delta_n|")
    for t in range(1, 13):
        new = {}
        for st, pr in law.items():
            sl = [W8[k] * c_NH(st[k]) for k in range(d)]
            rule = []
            for x in X8:
                sc = [sum(sl[k] for k in range(d) if (x, y) in TESTS8[k]) for y in Y8]
                rule.append(argmins(sc)[0])
            rule = tuple(rule)
            for z in (0, 1):
                calls = run8(rule, z)
                lengths.add(len(calls))
                for k in range(d):
                    nB = sum(F(int((x, rule[x]) in TESTS8[k])) for x in calls)
                    mB = sum(sum(P8[x][y] for y in Y8 if (x, y) in TESTS8[k]) for x in calls)
                    ED[k] += pr * F(1, 2) * (nB - mB)
                    if k == 3:
                        EN3 += pr * F(1, 2) * nB
                    # a call drawn uniformly among the calls of the run (not the protocol of the note)
                    ES_wrong[k] += pr * F(1, 2) * (nB - mB) / len(calls)
                for J in range(1, L8 + 1):
                    pj = pr * F(1, 2) * F(1, L8)
                    if J > len(calls):
                        new[st] = new.get(st, F(0)) + pj          # void round
                        continue
                    x = calls[J - 1]
                    for y in Y8:
                        py = P8[x][y]
                        if py == 0:
                            continue
                        gs = [int((x, rule[x]) in TESTS8[k]) - int((x, y) in TESTS8[k]) for k in range(d)]
                        st2 = tuple(step(st[k], gs[k]) for k in range(d))
                        new[st2] = new.get(st2, F(0)) + pj * py
                        for k in range(d):
                            ES[k] += pj * py * gs[k]
        law = new
        assert sum(law.values()) == 1
        maxN3 = max(maxN3, max(st[3][0] for st in law))
        assert all(st[3][2] in (0, 1) for st in law)               # the history of B3 is pure (+)
        gap = max(abs(ES[k] - ED[k] / L8) for k in range(d))
        assert gap == 0                                             # Theorem 6.2(a), exactly, in every round
        gapw = max(abs(ES_wrong[k] - ED[k] / L8) for k in range(d))
        if t in (1, 2, 3, 4, 6, 8, 10, 12):
            delta = [float(ED[k]) / t for k in range(d)]
            bound = min(L8 * math.sqrt((1 + 1 / t) * (2 * math.log(1 / W8[k]) + 1.39 + math.log(t + 1)) / t) for k in range(d))
            print(f"  {t:4d}  {len(law):7d}   {str(gap):>10s}                        {max(abs(x) for x in delta):.5f}            {bound:.3f}"
                  f"              {maxN3}          {float(L8 * ES[3] / t):.5f}          {L8 * (math.log2(10) + 2) / t:.3f}     {float(gapw):.5f}")
        assert ES[3] == EN3 / L8                                    # one-sided identity of Theorem 6.2(c)
    print(f"  lengths of runs that occur: {sorted(lengths)};  E S_n(B) = (n/L) E Delta_n(B) exactly in every round: {gap == 0};"
          f"  E N_n(B3) = sum_t E n_B3(a_t) / L exactly: True")
    print(f"  N_n(B3) <= {maxN3} in every branch (Theorem 3.3(ii): at most K(B3) + 2 = {math.log2(10) + 2:.2f})")
    print()


# ----------------------------------------------------------------------------------------------
# Part 9. Small arithmetic used in the decisions
# ----------------------------------------------------------------------------------------------
def part9():
    print("Part 9. Arithmetic")
    ok = all(math.sqrt(n) / (math.sqrt(1 + n / math.ceil(math.sqrt(n)) ** 2) + math.sqrt(n) / math.ceil(math.sqrt(n)))
             >= (math.sqrt(2) - 1) * math.sqrt(n) - 1e-12 for n in range(1, 200001))
    print("  Proposition 3.6(a) with d = ceil(sqrt n) tests gives at least (sqrt 2 - 1) sqrt n, for n = 1, ..., 200000:", ok)
    bad = [n for n in range(1, 3 * 10 ** 6 + 1, 1) if n // 2 < 0.5 * math.sqrt(n) * math.log(n) - 1e-9]
    print("  floor(n/2) >= 0.5 sqrt(n) ln n for n = 1, ..., 3000000: violations", len(bad))
    print(f"  K(B) + 2 for pi(B) = 1/(2n): log2(2n) + 2 = log2(n) + 3, e.g. n = 10^6: {math.log2(2e6) + 2:.3f} = {math.log2(1e6) + 3:.3f}")
    print(f"  if the halving potential doubled at every non-zero increment the bound would be K + 1; it is 1, 1, 2, 4, ..., which gives K + 2")
    print(f"  2 ln 2 = {2 * math.log(2):.5f} <= 1.39;  e/(e-1) = {math.e / (math.e - 1):.5f} < 1.582")
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
    part9()
    print("all parts finished")
