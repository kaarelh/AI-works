"""Referee's check of the bounds of Sections 2, 3 and 5 of research/prove-c/property-online.md on
ALL sequences of small games (exhaustive search over the adversary), and on long sequences with
greedy adversaries.

Independent implementation (plain Python floats; nothing imported from the prover's scripts).

The game (Definition 1.1): in round t the imitator fixes a rule a_t; the adversary then names a
question x and an answer y (the human's), or declares the round void. The theorems hold for ANY
minimiser of the score, so the adversary is also allowed to choose among tied minimisers at the
question it names (ties: scores within 1e-12 of the minimum).

Part A (exhaustive). For each rule and each small family, depth-first search over all adversary
sequences of length n. At every node are checked:
  * the invariant of Lemma 1.3:  Psi_t <= Psi_{t-1} (+ 1e-12),  Psi = sum_B pi(B) u(history of B);
  * the bound of the statement for every test.
Reported: the number of nodes, the largest value of (left side)/(bound) (must be <= 1), and the
worst case found for the one-sided counts.

Part B (long sequences): random tests, greedy adversaries, n = 3000.

Rules:
  lead    slope sinh(eta S)                               Theorem 2.1
  vclock  slope cosh(eta)^-V sinh(eta S)                  Remark 2.2(3), second form
  decr    slope sinh(eta_t S), eta_t = c/sqrt(t)          Proposition 2.4
  N       slope c^N(S, V)                                 Theorem 3.1, Corollary 3.2
  NH      slope (c^N + c^H)/2                             Theorem 3.3
  grid    Proposition 3.7 (i = 0..39)
  prod    Proposition 3.8 (i = 1..40)
  quad    slope S                                         Proposition 5.1

Usage: python3 property-online_check_game.py
"""
import itertools
import math
import random
import sys

TOL = 1e-12
sys.setrecursionlimit(10000)


def G(v, s):
    return (v + 1.0) ** -0.5 * math.exp(s * s / (2.0 * (v + 1.0)))


def cN(s, v):
    return 0.5 * (G(v + 1, s + 1.0) - G(v + 1, s - 1.0))


GRID_ETA = [2.0 ** -i for i in range(40)]
GRID_RHO = [1.0 / ((i + 1.0) * (i + 2.0)) for i in range(40)]
PROD_ETA = [2.0 ** -i for i in range(1, 41)]
PROD_RHO = [1.0 / (i * (i + 1.0)) for i in range(1, 41)]


class Test:
    """State of one test: the statistics of its history that the potentials need."""
    __slots__ = ("s", "v", "k", "sign", "pure", "pp", "pm", "q")

    def __init__(self):
        self.s = 0.0      # book
        self.v = 0        # number of non-zero increments
        self.k = 0        # length of the history (rounds, void rounds included)
        self.sign = 0     # sign of the non-zero increments while pure
        self.pure = True
        self.pp = [1.0] * len(PROD_ETA)   # prod_j (1 + eta_i g_j)
        self.pm = [1.0] * len(PROD_ETA)   # prod_j (1 - eta_i g_j)
        self.q = 0.0      # sum of squared increments

    def copy(self):
        c = Test.__new__(Test)
        c.s, c.v, c.k, c.sign, c.pure, c.q = self.s, self.v, self.k, self.sign, self.pure, self.q
        c.pp, c.pm = self.pp[:], self.pm[:]
        return c

    def push(self, g, need_prod):
        self.k += 1
        if g != 0.0:
            self.s += g
            self.v += 1
            self.q += g * g
            sg = 1 if g > 0 else -1
            if self.sign == 0 and self.pure:
                self.sign = sg
            elif sg != self.sign:
                self.pure = False
            if need_prod:
                for i, e in enumerate(PROD_ETA):
                    self.pp[i] *= 1 + e * g
                    self.pm[i] *= 1 - e * g


def u_H(T):
    if T.v == 0:
        return 1.0
    return 2.0 ** (T.v - 1) if T.pure else 0.0


def c_H(T):
    return T.sign * 2.0 ** (T.v - 1) if (T.v >= 1 and T.pure) else 0.0


def prodcosh_decr(k, c):
    p = 1.0
    for j in range(1, k + 1):
        p *= math.cosh(c / math.sqrt(j))
    return p


def potential(rule, T, par):
    """(u, slope) of the history of one test under the potential that belongs to the rule."""
    if rule == "lead":
        eta = par
        d = math.cosh(eta) ** T.k
        return math.cosh(eta * T.s) / d, math.tanh(eta) * math.sinh(eta * T.s) / d
    if rule == "vclock":
        eta = par
        d = math.cosh(eta) ** T.v
        return math.cosh(eta * T.s) / d, math.tanh(eta) * math.sinh(eta * T.s) / d
    if rule == "decr":
        c = par
        ek = c / math.sqrt(T.k) if T.k >= 1 else 0.0
        ek1 = c / math.sqrt(T.k + 1)
        d = prodcosh_decr(T.k, c)
        return math.cosh(ek * T.s) / d, math.tanh(ek1) * math.sinh(ek1 * T.s) / d
    if rule == "N":
        return G(T.v, T.s), cN(T.s, T.v)
    if rule == "NH":
        return 0.5 * G(T.v, T.s) + 0.5 * u_H(T), 0.5 * cN(T.s, T.v) + 0.5 * c_H(T)
    if rule == "grid":
        u = sum(r * math.cosh(e * T.s) * math.exp(-T.v * e * e / 2) for e, r in zip(GRID_ETA, GRID_RHO))
        c = sum(r * math.exp(-(T.v + 1) * e * e / 2) * math.sinh(e) * math.sinh(e * T.s)
                for e, r in zip(GRID_ETA, GRID_RHO))
        return u, c
    if rule == "prod":
        u = sum(r * (a + b) / 2 for r, a, b in zip(PROD_RHO, T.pp, T.pm))
        c = sum(r * e * (a - b) / 2 for r, e, a, b in zip(PROD_RHO, PROD_ETA, T.pp, T.pm))
        return u, c
    if rule == "quad":
        return T.s * T.s, T.s          # not a balancing potential; Psi <= Psi + sum pi g^2 is checked instead
    raise ValueError(rule)


def ratio(rule, T, pi, par, t, set_tests):
    """Largest (left side)/(bound) of the statements that belong to the rule, for one test."""
    S, V = abs(T.s), T.v
    L2 = math.log(2.0 / pi)
    Lam = math.log(1.0 / pi)
    out = 0.0
    if rule == "lead":
        eta = par
        out = max(out, S / ((L2 + t * math.log(math.cosh(eta))) / eta))
    elif rule == "vclock":
        eta = par
        out = max(out, S / ((L2 + V * math.log(math.cosh(eta))) / eta))
    elif rule == "decr":
        c = par
        if t >= 1:
            out = max(out, S / ((math.sqrt(t) / c) * (L2 + (c * c / 2) * (1 + math.log(t)))))
    elif rule == "N":
        out = max(out, S * S / ((V + 1) * (2 * Lam + math.log(V + 1))) if (2 * Lam + math.log(V + 1)) > 0 else
                  (0.0 if S == 0 else float("inf")))
        out = max(out, S / math.sqrt((t + 1) * (2 * Lam + math.log(t + 1))) if t >= 1 else 0.0)
        if set_tests and T.pure and V >= 1:      # Corollary 3.2(b), (c)
            out = max(out, V / (2 * Lam + math.log(2 * Lam + 4) + 2))
    elif rule == "NH":
        out = max(out, S * S / ((V + 1) * (2 * Lam + 2 * math.log(2) + math.log(V + 1))))
        if T.pure and V >= 1:                    # Theorem 3.3(ii)
            out = max(out, V / (math.log2(1.0 / pi) + 2))
    elif rule == "grid":
        best = min((L2 + math.log((i + 1.0) * (i + 2.0))) / e + e * V / 2 for i, e in enumerate(GRID_ETA))
        out = max(out, S / best)
        if V >= 2 * L2:
            b = (3 / math.sqrt(2)) * math.sqrt(V * L2) + 2 * math.sqrt(2) * math.sqrt(V / L2) * math.log(
                3 + 0.5 * math.log2(V))
            out = max(out, S / b)
    elif rule == "prod":
        best = min(math.log(2.0 * i * (i + 1) / pi) / e + e * T.q for i, e in zip(range(1, 41), PROD_ETA))
        out = max(out, S / best)
        out = max(out, S / (2 * math.log(4 / pi) + T.q / 2))
    elif rule == "quad":
        pass
    return out


class Game:
    def __init__(self, nx, ny, tests, pis):
        self.nx, self.ny = nx, ny
        self.tests = tests            # tests[k][x][y] in [0, 1]
        self.pis = pis
        self.set_tests = all(v in (0.0, 1.0) for B in tests for row in B for v in row)


def scores(game, rule, states, par, x):
    sl = [potential(rule, T, par)[1] for T in states]
    return [sum(p * c * B[x][y] for p, c, B in zip(game.pis, sl, game.tests)) for y in range(game.ny)]


def psi(game, rule, states, par):
    return sum(p * potential(rule, T, par)[0] for p, T in zip(game.pis, states))


def exhaustive(game, rule, par, n, allow_void=True):
    """DFS over all adversary sequences. Returns statistics."""
    need_prod = rule == "prod"
    stat = {"nodes": 0, "max_ratio": 0.0, "max_dpsi": -1e300, "one_sided_plus": {}, "one_sided_minus": {},
            "maxS": 0.0}

    def visit(states, t, quad_budget):
        stat["nodes"] += 1
        for kk, (T, p) in enumerate(zip(states, game.pis)):
            r = ratio(rule, T, p, par, t, game.set_tests)
            if r > stat["max_ratio"]:
                stat["max_ratio"] = r
            stat["maxS"] = max(stat["maxS"], abs(T.s))
            if T.pure and T.v >= 1:
                d = stat["one_sided_plus"] if T.sign > 0 else stat["one_sided_minus"]
                d[kk] = max(d.get(kk, 0), T.v)
        if rule == "quad":
            lhs = sum(p * T.s * T.s for p, T in zip(game.pis, states))
            assert lhs <= quad_budget + 1e-9, (lhs, quad_budget)
            assert all(abs(T.s) <= math.sqrt(t / p) + 1e-9 for p, T in zip(game.pis, states))
        if t == n:
            return
        psi0 = psi(game, rule, states, par)
        moves = []
        if allow_void:
            moves.append(None)
        for x in range(game.nx):
            sc = scores(game, rule, states, par, x)
            m = min(sc)
            for a in range(game.ny):
                if sc[a] <= m + TOL:
                    for y in range(game.ny):
                        moves.append((x, a, y))
        for mv in moves:
            new = [T.copy() for T in states]
            if mv is None:
                gs = [0.0] * len(new)
            else:
                x, a, y = mv
                gs = [B[x][a] - B[x][y] for B in game.tests]
            for T, g in zip(new, gs):
                T.push(g, need_prod)
            if rule != "quad":
                dpsi = psi(game, rule, new, par) - psi0
                stat["max_dpsi"] = max(stat["max_dpsi"], dpsi)
                assert dpsi <= 1e-9 * max(1.0, psi0), (rule, dpsi, mv)
            qb = quad_budget + sum(p * g * g for p, g in zip(game.pis, gs))
            visit(new, t + 1, qb)

    visit([Test() for _ in game.tests], 0, 0.0)
    return stat


def make_family(rnd, nx, ny, ntests, kind):
    tests = []
    for _ in range(ntests):
        if kind == "set":
            B = [[float(rnd.random() < 0.5) for _ in range(ny)] for _ in range(nx)]
        else:
            B = [[rnd.choice([0.0, 1.0, rnd.random(), rnd.random()]) for _ in range(ny)] for _ in range(nx)]
        tests.append(B)
    return tests


def part_a():
    rnd = random.Random(7)
    print("== Part A: exhaustive search over the adversary (void rounds and tie-breaking included) ==")
    print(f"{'family':<34}{'rule':<8}{'n':>3}{'nodes':>10}{'max ratio':>11}{'max dPsi':>11}   one-sided worst (test: count / bound)")
    fams = []
    # family 1: two questions, two answers, all 4 'atoms' {(x,y)} plus two unions; unequal weights summing to < 1
    atoms = [[[1.0 if (x, y) == (xx, yy) else 0.0 for y in range(2)] for x in range(2)]
             for xx in range(2) for yy in range(2)]
    unions = [[[1.0, 0.0], [1.0, 0.0]], [[1.0, 0.0], [0.0, 1.0]]]
    fams.append(("2x2: 4 atoms + 2 unions", Game(2, 2, atoms + unions, [0.3, 0.2, 0.1, 0.05, 0.2, 0.1]), 7, True))
    # family 2: one question, three answers, tests {0}, {1}, {0,1}, weights 2^-k
    f2 = [[[1.0, 0.0, 0.0]], [[0.0, 1.0, 0.0]], [[1.0, 1.0, 0.0]]]
    fams.append(("1x3: {0},{1},{0,1}, 2^-k", Game(1, 3, f2, [0.5, 0.25, 0.125]), 7, True))
    # family 3: the table tests of Proposition 3.5 for m = 3 (8 tests of weight 1/8)
    m = 3
    f3 = []
    for c in itertools.product([0, 1], repeat=m):
        f3.append([[1.0 if y != c[x] else 0.0 for y in range(2)] for x in range(m)])
    fams.append(("Prop 3.5 tables, m = 3", Game(3, 2, f3, [1.0 / 8] * 8), 5, False))
    # family 4: random set tests
    fams.append(("random sets 2x3, 5 tests", Game(2, 3, make_family(rnd, 2, 3, 5, "set"),
                                                  [0.4, 0.3, 0.1, 0.1, 0.05]), 5, True))
    # family 5: tests with values in [0,1]
    fams.append(("values in [0,1], 2x2, 4 tests", Game(2, 2, make_family(rnd, 2, 2, 4, "real"),
                                                       [0.4, 0.3, 0.2, 0.1]), 6, True))
    # family 6: a single test of weight 1 and a single test of tiny weight (edge cases)
    fams.append(("one test, pi = 1", Game(1, 2, [[[0.0, 1.0]]], [1.0]), 9, True))
    fams.append(("one test, pi = 1e-6", Game(1, 2, [[[0.0, 1.0]]], [1e-6]), 9, True))
    for name, game, n, void in fams:
        for rule, par in [("lead", 1.0 / math.sqrt(n)), ("lead", 2.0), ("vclock", 0.5), ("decr", 1.0),
                          ("N", None), ("NH", None), ("grid", None), ("prod", None), ("quad", None)]:
            if rule == "NH" and not game.set_tests:
                continue
            st = exhaustive(game, rule, par, n, allow_void=void)
            os_txt = ""
            if rule in ("N", "NH") and game.set_tests:
                parts = []
                for d in (st["one_sided_plus"], st["one_sided_minus"]):
                    for kk, cnt in sorted(d.items()):
                        p = game.pis[kk]
                        b = (math.log2(1 / p) + 2) if rule == "NH" else (
                            2 * math.log(1 / p) + math.log(2 * math.log(1 / p) + 4) + 2)
                        parts.append((cnt / b, f"{kk}: {cnt}/{b:.2f}"))
                parts.sort(reverse=True)
                os_txt = "; ".join(x[1] for x in parts[:3])
            lab = rule if par is None else f"{rule}"
            print(f"{name:<34}{lab:<8}{n:>3}{st['nodes']:>10}{st['max_ratio']:>11.4f}"
                  f"{(st['max_dpsi'] if rule != 'quad' else float('nan')):>11.1e}   {os_txt}")
            assert st["max_ratio"] <= 1 + 1e-9, (name, rule, st["max_ratio"])
    print()


def run_long(game, rule, par, n, adversary, rnd):
    need_prod = rule == "prod"
    states = [Test() for _ in game.tests]
    worst = 0.0
    P = [[rnd.random() for _ in range(game.ny)] for _ in range(game.nx)]
    for t in range(1, n + 1):
        psi0 = psi(game, rule, states, par) if rule != "quad" else None
        if adversary == "void-heavy" and rnd.random() < 0.5:
            gs = [0.0] * len(states)
        else:
            best = None
            xs = range(game.nx) if adversary in ("greedy", "opposite-greedy") else [rnd.randrange(game.nx)]
            for x in xs:
                sc = scores(game, rule, states, par, x)
                a = min(range(game.ny), key=lambda y: (sc[y], y))
                if adversary in ("random", "void-heavy"):
                    w = P[x]
                    y = rnd.choices(range(game.ny), weights=w)[0]
                    cand = [(0.0, x, a, y)]
                else:
                    cand = []
                    for y in range(game.ny):
                        if adversary == "opposite-greedy" and y == a and game.ny > 1:
                            continue
                        # value of the move for the adversary: largest ratio after the move
                        val = 0.0
                        for T, p, B in zip(states, game.pis, game.tests):
                            T2 = T.copy()
                            T2.push(B[x][a] - B[x][y], need_prod)
                            val = max(val, ratio(rule, T2, p, par, t, game.set_tests) if rule != "quad"
                                      else abs(T2.s) * math.sqrt(p))
                        cand.append((val, x, a, y))
                for c in cand:
                    if best is None or c[0] > best[0]:
                        best = c
            _, x, a, y = best
            gs = [B[x][a] - B[x][y] for B in game.tests]
        for T, g in zip(states, gs):
            T.push(g, need_prod)
        if rule != "quad":
            assert psi(game, rule, states, par) <= psi0 * (1 + 1e-9) + 1e-12
            worst = max(worst, max(ratio(rule, T, p, par, t, game.set_tests) for T, p in zip(states, game.pis)))
        else:
            worst = max(worst, max(abs(T.s) / math.sqrt(t / p) for T, p in zip(states, game.pis)))
    return worst, max(abs(T.s) for T in states)


def part_b():
    rnd = random.Random(11)
    n = 3000
    print(f"== Part B: long sequences, n = {n}; entries: largest (left side)/(bound) over all rounds and tests ==")
    games = [("12 random sets, 4x3, weights 2^-k", Game(4, 3, make_family(rnd, 4, 3, 12, "set"),
                                                        [2.0 ** -(k + 1) for k in range(12)])),
             ("10 tests in [0,1], 4x3, uniform", Game(4, 3, make_family(rnd, 4, 3, 10, "real"), [0.1] * 10))]
    rules = [("lead", 1.0 / math.sqrt(n)), ("vclock", 1.0 / math.sqrt(n)), ("decr", 1.0), ("N", None),
             ("NH", None), ("grid", None), ("prod", None), ("quad", None)]
    print(f"{'family':<36}{'adversary':<17}" + "".join(f"{r[0]:>8}" for r in rules))
    for name, game in games:
        for adv in ("random", "void-heavy", "greedy", "opposite-greedy"):
            row = []
            for rule, par in rules:
                if rule == "NH" and not game.set_tests:
                    row.append(float("nan"))
                    continue
                w, _ = run_long(game, rule, par, n, adv, random.Random(5))
                row.append(w)
                assert w <= 1 + 1e-9, (name, adv, rule, w)
            print(f"{name:<36}{adv:<17}" + "".join(f"{w:>8.3f}" for w in row))
    print()


if __name__ == "__main__":
    part_a()
    part_b()
    print("all checks passed")
