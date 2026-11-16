"""Referee's check of Example 2.3, Example 7.1, Proposition 3.5 and Proposition 8.2(a) of
research/prove-c/property-online.md, and of the sentence after Theorem 6.2 that carries
Example 2.3 over to rehearsal.

Part 1. Example 2.3, simulated directly from its definition (three answers, two tests, the rule
        of Theorem 2.1 with the least minimiser), for many (n, eta, beta, delta): the count of
        the answer 1 against the formula min(floor(n/2), N*), and N* against the two lower bounds.
Part 2. Dependence on the choice among minimisers: the same example with the GREATEST minimiser.
Part 3. Example 2.3 under rehearsal (L = 1, the question's parity is a fair coin in every round):
        the count of the answer 1, and the exact rate of the deployed imitator (rule of a
        uniformly chosen round), against the bound of the lead's corollary and against the
        bound (K(B) + 2)/n of Rule NH.
Part 4. Example 7.1 for the rule of Theorem 2.1, Rule N and Rule NH.
Part 5. Proposition 3.5 against Rule N, Rule NH, the rule of Theorem 2.1 and the quadratic rule,
        by the adversary of the proof; and exhaustively (all adversaries) for m <= 3 and Rule NH.

Usage: python3 property-online_check_ex23.py
"""
import itertools
import math
import random


def G(v, s):
    return (v + 1.0) ** -0.5 * math.exp(s * s / (2.0 * (v + 1.0)))


def cN(s, v):
    return 0.5 * (G(v + 1, s + 1.0) - G(v + 1, s - 1.0))


class Book:
    __slots__ = ("s", "v", "sign", "pure")

    def __init__(self):
        self.s, self.v, self.sign, self.pure = 0, 0, 0, True

    def push(self, g):
        if g:
            self.s += g
            self.v += 1
            if self.sign == 0 and self.pure:
                self.sign = g
            elif g != self.sign:
                self.pure = False

    def cH(self):
        return self.sign * 2.0 ** (self.v - 1) if (self.v >= 1 and self.pure) else 0.0


def slope(rule, bk, eta):
    if rule == "lead":
        return math.sinh(eta * bk.s)
    if rule == "N":
        return cN(bk.s, bk.v)
    if rule == "NH":
        return 0.5 * cN(bk.s, bk.v) + 0.5 * bk.cH()
    if rule == "quad":
        return float(bk.s)
    raise ValueError(rule)


# ---------------------------------------------------------------- Example 2.3
def in_B(x, y):
    return y == 1


def in_D(x, y):
    return (y == 1 and x % 2 == 1) or (y == 2 and x % 2 == 0)


def f23(x):
    return 0 if x % 2 == 1 else 2


def answer23(rule, bB, bD, beta, delta, eta, x, greatest=False):
    cB, cD = slope(rule, bB, eta), slope(rule, bD, eta)
    sc = [beta * cB * in_B(x, y) + delta * cD * in_D(x, y) for y in (0, 1, 2)]
    m = min(sc)
    ys = [y for y in (0, 1, 2) if sc[y] <= m + 1e-15 * max(1.0, abs(m))]
    return ys[-1] if greatest else ys[0]


def run23(rule, n, eta, beta, delta, questions, greatest=False):
    bB, bD = Book(), Book()
    count = 0
    answers_one_at_odd = []        # for the deployed rate under rehearsal
    for t in range(1, n + 1):
        # the rule of round t at an odd and at an even question (needed for the deployed imitator)
        a_odd = answer23(rule, bB, bD, beta, delta, eta, 3, greatest)
        a_even = answer23(rule, bB, bD, beta, delta, eta, 2, greatest)
        answers_one_at_odd.append((a_odd == 1, a_even == 1))
        x = questions(t)
        a = a_odd if x % 2 == 1 else a_even
        y = f23(x)
        count += (a == 1)
        bB.push(in_B(x, a) - in_B(x, y))
        bD.push(in_D(x, a) - in_D(x, y))
    return count, answers_one_at_odd


def Nstar(eta, beta, delta):
    N = 0
    while beta * math.sinh(eta * N) < delta * math.sinh(eta):
        N += 1
    return N


def part1():
    print("== Part 1: Example 2.3, fixed order x_t = t + 1, least minimiser ==")
    print(f"{'n':>7} {'eta':>9} {'beta':>9} {'delta':>6} {'count':>7} {'formula':>8} {'N*':>6} "
          f"{'asinh bound':>12} {'(1/2)sqrt(n)ln n':>17} {'Thm 2.1 bound':>14}")
    bad = 0
    cases = []
    for n in (1, 2, 3, 4, 5, 7, 10, 30, 100, 400, 1000, 10000, 100000):
        cases.append((n, 1 / math.sqrt(n), 1 / (2 * n), 0.5))
    cases += [(1000, 0.3, 1e-4, 0.5), (1000, 0.01, 1e-3, 0.25), (5000, 2.0, 1e-9, 0.9), (200, 1 / math.sqrt(200), 0.5, 0.5),
              (200, 0.07, 0.9, 0.1), (3000, 0.02, 1e-12, 1e-3)]
    for n, eta, beta, delta in cases:
        cnt, _ = run23("lead", n, eta, beta, delta, lambda t: t + 1)
        ns = Nstar(eta, beta, delta)
        formula = min(n // 2, ns)
        lb = math.asinh(eta * delta / beta) / eta
        half = 0.5 * math.sqrt(n) * math.log(n)
        bound = (math.log(2 / beta) + n * math.log(math.cosh(eta))) / eta
        ok = cnt == formula and ns >= lb - 1e-9 and cnt <= bound + 1e-9
        bad += not ok
        print(f"{n:>7} {eta:>9.5f} {beta:>9.2e} {delta:>6.2f} {cnt:>7} {formula:>8} {ns:>6} {lb:>12.2f} "
              f"{half:>17.2f} {bound:>14.2f}" + ("" if ok else "   <-- MISMATCH"))
    # the particular parameters of the example for all n up to 3000: count >= (1/2) sqrt(n) ln n
    worst = min(run23("lead", n, 1 / math.sqrt(n), 1 / (2 * n), 0.5, lambda t: t + 1)[0]
                - 0.5 * math.sqrt(n) * math.log(n) for n in range(1, 3001))
    print(f"eta = 1/sqrt(n), beta = 1/(2n), delta = 1/2, all n = 1..3000: min of count - (1/2) sqrt(n) ln n = {worst:.4f}")
    assert bad == 0 and worst >= 0
    print()


def part2():
    print("== Part 2: the same example with the greatest minimiser (also a rule of Theorem 2.1) ==")
    for n in (100, 10000):
        cnt, _ = run23("lead", n, 1 / math.sqrt(n), 1 / (2 * n), 0.5, lambda t: t + 1, greatest=True)
        print(f"n = {n}: number of rounds with the answer 1 = {cnt}")
    print("(so the example depends on the choice among minimisers; Theorem 2.1 allows every choice)\n")


def part3():
    print("== Part 3: Example 2.3 under rehearsal (L = 1; the parity of the question is a fair coin) ==")
    print("count = number of rehearsal rounds whose asked answer is 1; rate = (1/n) sum_t Pr_x[a_t(x) = 1],")
    print("the probability that a deployed call gets the answer the human never gives (exact, given the rehearsal)")
    print(f"{'n':>8} {'rule':>5} {'mean count':>11} {'N*':>6} {'mean rate':>10} {'N*/n':>9} "
          f"{'lead bound':>11} {'ratio':>6} {'(K(B)+2)/n':>11}")
    rnd = random.Random(1)
    for n in (400, 10000, 100000):
        eta, beta, delta = 1 / math.sqrt(n), 1 / (2 * n), 0.5
        ns = Nstar(eta, beta, delta)
        for rule in ("lead", "NH"):
            reps = 20 if n <= 10000 else 5
            cs, rs = [], []
            for _ in range(reps):
                cnt, a1 = run23(rule, n, eta, beta, delta, lambda t: rnd.randrange(2, 10 ** 9))
                cs.append(cnt)
                rs.append(sum(0.5 * o + 0.5 * e for o, e in a1) / n)
            lead_bound = (math.log(2 / beta) + 0.5) / math.sqrt(n)
            mc, mr = sum(cs) / reps, sum(rs) / reps
            print(f"{n:>8} {rule:>5} {mc:>11.1f} {ns:>6} {mr:>10.5f} {ns / n:>9.5f} {lead_bound:>11.5f} "
                  f"{mr / lead_bound:>6.3f} {(math.log2(1 / beta) + 2) / n:>11.6f}")
            if rule == "NH":
                assert max(cs) <= math.log2(1 / beta) + 2
    print()


def part4():
    print("== Part 4: Example 7.1 (family {answer = 1}, f(x) = x mod 2, x_t = t, least minimiser) ==")
    for rule in ("lead", "N", "NH"):
        bk = Book()
        wrong = 0
        maxabs = 0
        n = 2000
        for t in range(1, n + 1):
            c = slope(rule, bk, 1 / math.sqrt(n))
            a = 1 if c < 0 else 0          # scores: 0 for the answer 0, c for the answer 1; least minimiser
            y = t % 2
            wrong += a != y
            bk.push((a == 1) - (y == 1))
            maxabs = max(maxabs, abs(bk.s))
        print(f"rule {rule:>4}: wrong answers {wrong} of {n}; max |S_t| = {maxabs}")
        assert wrong == n and maxabs <= 1
    print()


def part5():
    print("== Part 5: Proposition 3.5 (2^m table tests of weight 2^-m; the human answers 1 - a_t(t)) ==")
    for rule in ("lead", "N", "NH", "quad"):
        row = []
        for m in (1, 2, 3, 5, 8, 10):
            tabs = list(itertools.product((0, 1), repeat=m))
            books = {c: Book() for c in tabs}
            cstar = []
            for t in range(m):
                sc = [0.0, 0.0]
                for c in tabs:
                    sl = slope(rule, books[c], 1 / math.sqrt(m))
                    sc[1 - c[t]] += 2.0 ** -m * sl       # (t, y) in B_c iff y != c(t)
                a = 0 if sc[0] <= sc[1] else 1
                y = 1 - a
                cstar.append(y)
                for c in tabs:
                    books[c].push((a != c[t]) - (y != c[t]))
            bstar = books[tuple(cstar)]
            row.append((m, bstar.s, bstar.v))
            assert bstar.s == m and bstar.pure
        print(f"rule {rule:>4}: (m, N_m(B_c*), V) = {row}")
    # exhaustive: Rule NH, m <= 3, all adversaries (any questions, any answers, n rounds): the largest
    # count for a test that the human never satisfied, against K(B) + 2 = m + 2
    for m, n in ((1, 6), (2, 6), (3, 5)):
        tabs = list(itertools.product((0, 1), repeat=m))
        best = 0

        def rec(books, t):
            nonlocal best
            for c in tabs:
                bk = books[c]
                if bk.pure and bk.sign >= 0:
                    best = max(best, bk.v)
            if t == n:
                return
            for x in range(m):
                sc = [0.0, 0.0]
                for c in tabs:
                    sc[1 - c[x]] += 2.0 ** -m * slope("NH", books[c], None)
                mn = min(sc)
                for a in (0, 1):
                    if sc[a] <= mn + 1e-12:
                        for y in (0, 1):
                            nb = {}
                            for c in tabs:
                                b2 = Book()
                                b2.s, b2.v, b2.sign, b2.pure = books[c].s, books[c].v, books[c].sign, books[c].pure
                                b2.push((a != c[x]) - (y != c[x]))
                                nb[c] = b2
                            rec(nb, t + 1)
        rec({c: Book() for c in tabs}, 0)
        print(f"Rule NH, m = {m}, all adversaries with {n} rounds (ties to the adversary): "
              f"largest one-sided count = {best}; lower bound m = {m}; upper bound m + 2 = {m + 2}")
        assert m <= best <= m + 2
    print()


if __name__ == "__main__":
    part1()
    part2()
    part3()
    part4()
    part5()
    print("all checks passed")
