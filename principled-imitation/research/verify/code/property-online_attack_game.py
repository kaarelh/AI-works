"""Adversary's exhaustive search against the rules of research/prove-c/property-online.md.

The game of Definition 1.1 of that file: in round t the imitator's rule is a function of the
past; then a question x and the human's answer y arrive (any choice); a round may be void.
For a test B (a function b_B(x, y) in [0, 1]) the increment is g = b_B(x, a(x)) - b_B(x, y).

This script does NOT sample sequences. For each small instance (questions, answers, tests,
weights) and each rule it explores EVERY reachable state of the game up to a horizon n:
every question, every answer of the human, a void round, and every choice among the
minimisers of the score when there is a tie (ties are scores within TOL of the minimum; the
adversary resolves them). The state of a test is the multiset of its non-zero increments (all
potentials of Lemma 1.4 except the clock-k ones are functions of it), plus the number of rounds
in which both answers were in the test (for the counts N and h of Corollary 3.2); states are
memoised, so the search is exhaustive over sequences without enumerating them one by one.

In every reachable state and for every test the following are evaluated, and the largest
ratio (left side)/(right side) is reported; a ratio above 1 would be a counterexample.

  lead   Theorem 2.1:   |S| <= (ln(2/pi) + t ln cosh(eta)) / eta
  leadV  Remark 2.2(3): |S| <= ln(2/pi)/eta + eta V/2
  decr   Prop. 2.4:     |S| <= (sqrt(t)/c) (ln(2/pi) + (c^2/2)(1 + ln t))
  N      Theorem 3.1:   S^2 <= (V+1)(2 ln(1/pi) + ln(V+1));  Corollary 3.2 (a), (b), (c)
  NH     Theorem 3.3:   (i) S^2 <= (V+1)(2 ln(1/pi) + 2 ln 2 + ln(V+1));  (ii) pure => V <= log2(1/pi) + 2
  grid   Prop. 3.7:     (3.3) for i = 0..14, and the closed form when V >= 2 ln(2/pi)
  prod   Prop. 3.8:     |S| <= ln(2i(i+1)/pi)/eta_i + eta_i Q for i = 1..12; one-sided total <= 4 ln(4/pi)
  quad   Prop. 5.1:     sum_B pi S^2 <= sum_t sum_B pi g_t^2;  |S| <= sqrt(t/pi)
and, for every transition, that the weighted sum of potentials does not increase (Lemma 1.3).

Usage: python3 property-online_attack_game.py > property-online_attack_game.out
"""
import itertools
import math
import random
import sys
import time
from multiprocessing import Pool

MAX_STATES = 1500000   # per instance and rule; if reached, the search stops at that round and says so
TOL = 1e-12        # scores within TOL of the minimum count as ties
SLACK = 1e-9       # numerical slack allowed in the checks
LN2 = math.log(2.0)


# ----------------------------------------------------------------------------- potentials
def G(v, s):
    return (v + 1.0) ** -0.5 * math.exp(s * s / (2.0 * (v + 1.0)))


def cN(s, v):
    return 0.5 * (G(v + 1, s + 1.0) - G(v + 1, s - 1.0))


GRID_I = range(0, 46)
GRID_ETA = [2.0 ** -i for i in GRID_I]
GRID_RHO = [1.0 / ((i + 1) * (i + 2)) for i in GRID_I]
PROD_I = range(1, 46)
PROD_ETA = [2.0 ** -i for i in PROD_I]
PROD_RHO = [1.0 / (i * (i + 1)) for i in PROD_I]


class Summary:
    """Everything a rule needs to know about one test: derived from the multiset of increments."""
    __slots__ = ("S", "V", "Q", "sgn", "counts")

    def __init__(self, gvals, counts):
        self.counts = counts
        self.S = sum(g * c for g, c in zip(gvals, counts))
        self.V = sum(counts)
        self.Q = sum(g * g * c for g, c in zip(gvals, counts))
        pos = any(c and g > 0 for g, c in zip(gvals, counts))
        neg = any(c and g < 0 for g, c in zip(gvals, counts))
        self.sgn = 0 if not (pos or neg) else (2 if (pos and neg) else (1 if pos else -1))


def slope(rule, par, sm, gvals, t):
    """Slope of a test in round t + 1 (t rounds are over). Positive common factors are dropped."""
    S, V = sm.S, sm.V
    if rule == "lead":
        return math.sinh(par * S)
    if rule == "leadV":
        return math.exp(-V * par * par / 2) * math.sinh(par * S)
    if rule == "decr":
        return math.sinh(par / math.sqrt(t + 1) * S)
    if rule == "N":
        return cN(S, V)
    if rule == "NH":
        cH = 0.0
        if sm.sgn in (1, -1):
            cH = sm.sgn * 2.0 ** (V - 1)
        return 0.5 * cN(S, V) + 0.5 * cH
    if rule == "grid":
        return sum(r * math.exp(-(V + 1) * e * e / 2) * math.sinh(e) * math.sinh(e * S)
                   for r, e in zip(GRID_RHO, GRID_ETA))
    if rule == "prod":
        tot = 0.0
        for r, e in zip(PROD_RHO, PROD_ETA):
            pp = pm = 1.0
            for g, c in zip(gvals, sm.counts):
                if c:
                    pp *= (1 + e * g) ** c
                    pm *= (1 - e * g) ** c
            tot += r * e * (pp - pm) / 2
        return tot
    if rule == "quad":
        return S
    raise ValueError(rule)


def potential(rule, par, sm, gvals, t):
    """u(gamma) of Lemma 1.4 for the rule (for 'decr' and 'quad' see the special checks)."""
    S, V = sm.S, sm.V
    if rule == "lead":
        return math.cosh(par * S) / math.cosh(par) ** t
    if rule == "leadV":
        return math.cosh(par * S) * math.exp(-V * par * par / 2)
    if rule == "N":
        return G(V, S)
    if rule == "NH":
        uH = 1.0 if V == 0 else (2.0 ** (V - 1) if sm.sgn in (1, -1) else 0.0)
        return 0.5 * G(V, S) + 0.5 * uH
    if rule == "grid":
        return sum(r * math.cosh(e * S) * math.exp(-V * e * e / 2) for r, e in zip(GRID_RHO, GRID_ETA))
    if rule == "prod":
        tot = 0.0
        for r, e in zip(PROD_RHO, PROD_ETA):
            pp = pm = 1.0
            for g, c in zip(gvals, sm.counts):
                if c:
                    pp *= (1 + e * g) ** c
                    pm *= (1 - e * g) ** c
            tot += r * (pp + pm) / 2
        return tot
    return None


def checks(rule, par, sm, pi, t, both, is_set, human_zero, human_always, qsum):
    """List of (label, lhs, rhs) that must satisfy lhs <= rhs for one test in one state."""
    S, V, Q = sm.S, sm.V, sm.Q
    Lam = math.log(1 / pi)
    out = []
    if rule == "lead":
        out.append(("Thm 2.1", abs(S), (math.log(2 / pi) + t * math.log(math.cosh(par))) / par))
    elif rule == "leadV":
        out.append(("Rem 2.2(3)", abs(S), math.log(2 / pi) / par + par * V / 2))
    elif rule == "decr":
        if t >= 1:
            out.append(("Prop 2.4", abs(S), math.sqrt(t) / par * (math.log(2 / pi) + par * par / 2 * (1 + math.log(t)))))
    elif rule == "N":
        out.append(("Thm 3.1 (3.1)", S * S, (V + 1) * (2 * Lam + math.log(V + 1))))
        out.append(("Thm 3.1 (3.2)", abs(S), math.sqrt((t + 1) * (2 * Lam + math.log(t + 1)))))
        if is_set:
            n_plus = sum(c for g, c in zip(GV, sm.counts) if g > 0)
            n_minus = sum(c for g, c in zip(GV, sm.counts) if g < 0)
            Nc, h = n_plus + both, n_minus + both
            W = 2 * Lam + math.log(V + 1)
            out.append(("Cor 3.2(a) upper", Nc, h + math.sqrt((2 * h + 1) * W) + W))
            out.append(("Cor 3.2(a) lower", h - math.sqrt((2 * h + 1) * W), Nc))
            if h == 0:
                out.append(("Cor 3.2(b)", Nc, 2 * Lam + math.log(2 * Lam + 4) + 2))
            if human_always:    # the human's answer was in B in every non-void round
                out.append(("Cor 3.2(c)", n_minus, 2 * Lam + math.log(2 * Lam + 4) + 2))
    elif rule == "NH":
        out.append(("Thm 3.3(i)", S * S, (V + 1) * (2 * Lam + 2 * LN2 + math.log(V + 1))))
        out.append(("Thm 3.3(i) n", abs(S), math.sqrt((t + 1) * (2 * Lam + 1.39 + math.log(t + 1)))))
        if sm.sgn in (1, -1, 0):
            out.append(("Thm 3.3(ii)", V, math.log2(1 / pi) + 2))
    elif rule == "grid":
        L2 = math.log(2 / pi)
        for i in range(0, 15):
            e = 2.0 ** -i
            out.append(("Prop 3.7 (3.3)", abs(S), (L2 + math.log((i + 1) * (i + 2))) / e + e * V / 2))
        if V >= 2 * L2:
            out.append(("Prop 3.7 closed", abs(S), 3 / math.sqrt(2) * math.sqrt(V * L2)
                        + 2 * math.sqrt(2) * math.sqrt(V / L2) * math.log(3 + 0.5 * math.log2(V))))
    elif rule == "prod":
        for i in range(1, 13):
            e = 2.0 ** -i
            out.append(("Prop 3.8", abs(S), math.log(2 * i * (i + 1) / pi) / e + e * Q))
        if human_zero:
            out.append(("Prop 3.8 one-sided", S, 4 * math.log(4 / pi)))
    elif rule == "quad":
        out.append(("Prop 5.1", abs(S), math.sqrt(qsum / pi)))
    return out


# ----------------------------------------------------------------------------- the search
GV = ()   # distinct non-zero increment values of the instance (set per instance)


def explore(inst, rule, par, n):
    """Exhaustive search. Returns dict label -> (max ratio, witness), and the count of states."""
    global GV
    X, Y, tests, pis = inst["X"], inst["Y"], inst["tests"], inst["pi"]
    K = len(tests)
    gvals = sorted({round(tests[k][x][a] - tests[k][x][y], 12) for k in range(K) for x in range(X)
                    for a in range(Y) for y in range(Y)} - {0.0})
    GV = tuple(gvals)
    gi = {g: i for i, g in enumerate(gvals)}
    is_set = [all(v in (0, 1) for row in tests[k] for v in row) for k in range(K)]
    clock_t = rule in ("lead", "decr")
    zero = tuple(0 for _ in gvals)
    ones = tuple(True for _ in range(K))
    # state: (t if clock rule else 0, per-test counts, per-test both-count, flags 'human value always 0',
    #         flags 'human value always 1')
    start = (0, tuple(zero for _ in range(K)), tuple(0 for _ in range(K)), ones, ones)
    seen = {start}
    frontier = [start]
    truncated = None
    worst = {}
    n_states = 0
    max_pot_increase = -1e300

    def record(label, lhs, rhs, wit):
        if rhs <= 0:
            ratio = 0.0 if lhs <= rhs + SLACK else float("inf")
        else:
            ratio = lhs / rhs
        if label not in worst or ratio > worst[label][0]:
            worst[label] = (ratio, wit)

    for t in range(n):
        new_frontier = []
        if n_states > MAX_STATES:
            truncated = t
            break
        for st in frontier:
            n_states += 1
            _, counts, both, hz, ha = st
            sms = [Summary(gvals, counts[k]) for k in range(K)]
            sl = [slope(rule, par, sms[k], gvals, t) for k in range(K)]
            psi_old = None
            if rule not in ("decr", "quad"):
                psi_old = sum(pis[k] * potential(rule, par, sms[k], gvals, t) for k in range(K))
            elif rule == "decr" and t >= 1:
                eta_old = par / math.sqrt(t)
                psi_old = sum(pis[k] * math.cosh(eta_old * sms[k].S) for k in range(K))
            elif rule == "decr":
                psi_old = sum(pis)
            moves = set()
            if clock_t:
                moves.add(tuple(0.0 for _ in range(K)) + ((0,) * K) + ((True,) * K) + ((True,) * K))     # void round
            for x in range(X):
                F = [sum(pis[k] * sl[k] * tests[k][x][y] for k in range(K)) for y in range(Y)]
                m = min(F)
                for a in range(Y):
                    if F[a] <= m + TOL:
                        for y in range(Y):
                            g = tuple(round(tests[k][x][a] - tests[k][x][y], 12) for k in range(K))
                            b = tuple(1 if (is_set[k] and tests[k][x][a] == 1 and tests[k][x][y] == 1) else 0
                                      for k in range(K))
                            z = tuple(tests[k][x][y] == 0 for k in range(K))
                            o = tuple(tests[k][x][y] == 1 for k in range(K))
                            moves.add(g + b + z + o)
            for mv in moves:
                g, b, z, o = mv[:K], mv[K:2 * K], mv[2 * K:3 * K], mv[3 * K:]
                ncounts = []
                for k in range(K):
                    if g[k] != 0:
                        c = list(counts[k])
                        c[gi[g[k]]] += 1
                        ncounts.append(tuple(c))
                    else:
                        ncounts.append(counts[k])
                nboth = tuple(both[k] + b[k] for k in range(K))
                nhz = tuple(hz[k] and z[k] for k in range(K))
                nha = tuple(ha[k] and o[k] for k in range(K))
                nsms = [Summary(gvals, ncounts[k]) for k in range(K)]
                nq = sum(pis[k] * nsms[k].Q for k in range(K))
                # Lemma 1.3: the weighted sum of potentials does not increase
                if rule == "decr":
                    eta_new = par / math.sqrt(t + 1)
                    psi_new = sum(pis[k] * math.cosh(eta_new * nsms[k].S) for k in range(K))
                    inc = psi_new - math.cosh(eta_new) * psi_old
                elif rule == "quad":
                    inc = (sum(pis[k] * nsms[k].S ** 2 for k in range(K)) - nq) - \
                          (sum(pis[k] * sms[k].S ** 2 for k in range(K)) - sum(pis[k] * sms[k].Q for k in range(K)))
                else:
                    psi_new = sum(pis[k] * potential(rule, par, nsms[k], gvals, t + 1) for k in range(K))
                    inc = psi_new - psi_old
                if inc > max_pot_increase:
                    max_pot_increase = inc
                for k in range(K):
                    wit = (t + 1, k, ncounts[k])
                    for label, lhs, rhs in checks(rule, par, nsms[k], pis[k], t + 1, nboth[k], is_set[k], nhz[k],
                                                  nha[k], nq):
                        record(label, lhs, rhs, wit)
                if rule == "quad":
                    record("Prop 5.1 sum", sum(pis[k] * nsms[k].S ** 2 for k in range(K)), nq, (t + 1, -1, ()))
                key = ((t + 1) if clock_t else 0, tuple(ncounts), nboth if rule == "N" else tuple(0 for _ in range(K)),
                       nhz if rule == "prod" else ones, nha if rule == "N" else ones)
                if key not in seen:
                    seen.add(key)
                    new_frontier.append(key)
        frontier = new_frontier
    return worst, n_states, max_pot_increase, truncated


# ----------------------------------------------------------------------------- instances
def random_instance(rng, X, Y, K, kind, weights):
    tests = []
    for _ in range(K):
        if kind == "set":
            while True:
                tb = [[rng.randint(0, 1) for _ in range(Y)] for _ in range(X)]
                if any(len(set(row)) > 1 for row in tb):
                    break
        else:
            tb = [[rng.choice([0, 0.5, 1, 0.25]) for _ in range(Y)] for _ in range(X)]
        tests.append(tb)
    if weights == "equal":
        pi = [1.0 / K] * K
    elif weights == "dyadic":
        pi = [2.0 ** -(k + 1) for k in range(K)]
    elif weights == "small":
        pi = [0.5] + [2.0 ** -(3 * k + 4) for k in range(1, K)]
    else:
        raw = [rng.random() for _ in range(K)]
        tot = sum(raw) / rng.uniform(0.3, 1.0)
        pi = [r / tot for r in raw]
    return {"X": X, "Y": Y, "tests": tests, "pi": pi}


def example_2_3(beta, delta):
    """Two question types (odd, even), answers 0, 1, 2; tests B = {y = 1}, D = {odd, y = 1} + {even, y = 2}."""
    B = [[0, 1, 0], [0, 1, 0]]
    D = [[0, 1, 0], [0, 0, 1]]      # row 0: odd question, row 1: even question
    return {"X": 2, "Y": 3, "tests": [B, D], "pi": [beta, delta]}


def table_tests(m):
    """Proposition 3.5: X = {0..m-1}, Y = {0,1}, the 2^m tests 'y != c(x)', weight 2^-m each."""
    tests = []
    for c in itertools.product((0, 1), repeat=m):
        tests.append([[1 if y != c[x] else 0 for y in (0, 1)] for x in range(m)])
    return {"X": m, "Y": 2, "tests": tests, "pi": [2.0 ** -m] * len(tests)}


def class_instance(rng):
    """Corollary 3.4: X = 3 questions, Y = 3 answers, a class of 5 functions with weights w, tests
    B_nu = {y != nu(x)} of weight w(nu)/2, and two other set tests of weight 1/4 each."""
    X, Y = 3, 3
    funcs = set()
    while len(funcs) < 5:
        funcs.add(tuple(rng.randrange(Y) for _ in range(X)))
    funcs = sorted(funcs)
    w = [0.4, 0.3, 0.15, 0.1, 0.05]
    tests = [[[1 if y != f[x] else 0 for y in range(Y)] for x in range(X)] for f in funcs]
    pi = [wi / 2 for wi in w]
    for _ in range(2):
        tests.append([[rng.randint(0, 1) for _ in range(Y)] for _ in range(X)])
        pi.append(0.25)
    return {"X": X, "Y": Y, "tests": tests, "pi": pi}


def job(args):
    name, inst, rule, par, n = args
    t0 = time.time()
    worst, n_states, inc, truncated = explore(inst, rule, par, n)
    return name, rule, par, n, worst, n_states, inc, time.time() - t0, truncated


def main():
    rng = random.Random(20261115)
    jobs = []
    rules = [("lead", 0.35), ("lead", 1.0), ("leadV", 0.5), ("decr", 1.0), ("decr", 0.4), ("N", None),
             ("NH", None), ("grid", None), ("prod", None), ("quad", None)]
    specs = [(1, 2, 1, "set", "equal", 40), (1, 2, 2, "set", "dyadic", 30), (2, 2, 2, "set", "equal", 24),
             (2, 3, 2, "set", "random", 20), (2, 3, 3, "set", "small", 14), (3, 2, 3, "set", "dyadic", 14),
             (2, 2, 3, "set", "random", 14), (2, 3, 2, "frac", "equal", 10), (2, 2, 2, "frac", "small", 11),
             (3, 3, 4, "set", "random", 9)]
    for si, (X, Y, K, kind, weights, n) in enumerate(specs):
        for rep in range(3):
            inst = random_instance(rng, X, Y, K, kind, weights)
            for rule, par in rules:
                nn = n if rule not in ("grid", "prod") else max(4, n - 3)
                if rule in ("lead", "decr", "quad"):
                    nn = max(4, nn - 2)         # the clock is part of the state: more states
                jobs.append((f"rand{si}.{rep} X{X} Y{Y} K{K} {kind} {weights}", inst, rule, par, nn))
    for beta, delta in ((0.02, 0.5), (0.001, 0.5), (0.25, 0.75)):
        inst = example_2_3(beta, delta)
        for rule, par in rules:
            jobs.append((f"ex2.3 beta={beta} delta={delta}", inst, rule, par, 24 if rule not in ("grid", "prod") else 14))
    for m in (2, 3):
        inst = table_tests(m)
        for rule, par in rules:
            jobs.append((f"table m={m}", inst, rule, par, 12 if m == 2 else 7))
    for rep in range(2):
        inst = class_instance(rng)
        for rule, par in (("NH", None), ("N", None)):
            jobs.append((f"class3.4 rep{rep}", inst, rule, par, 8))
    with Pool(4) as pool:
        results = pool.map(job, jobs, chunksize=1)
    overall = {}
    worst_inc = {}
    total_states = 0
    n_trunc = 0
    for name, rule, par, n, worst, n_states, inc, dt, truncated in results:
        total_states += n_states
        if truncated is not None:
            n_trunc += 1
            print(f"note: {name}, rule {rule}: stopped after round {truncated} of {n} ({n_states} states)")
        key = rule if par is None else f"{rule}({par})"
        worst_inc[key] = max(worst_inc.get(key, -1e300), inc)
        for label, (ratio, wit) in worst.items():
            k2 = (key, label)
            if k2 not in overall or ratio > overall[k2][0]:
                overall[k2] = (ratio, name, n, wit)
    print(f"instances x rules explored: {len(results)} ({n_trunc} stopped early);  states visited: {total_states}")
    print(f"{'rule':12s} {'statement':22s} {'max lhs/rhs':>12s}   where (instance; horizon; (round, test, counts of increments))")
    bad = 0
    for (key, label), (ratio, name, n, wit) in sorted(overall.items()):
        flag = "" if ratio <= 1 + 1e-9 else "   <-- VIOLATION"
        bad += ratio > 1 + 1e-9
        print(f"{key:12s} {label:22s} {ratio:12.6f}   {name}; n={n}; {wit}{flag}")
    print()
    print("largest increase of the weighted sum of potentials in one round (Lemma 1.3; must be <= 0 up to rounding):")
    for key, inc in sorted(worst_inc.items()):
        print(f"    {key:12s} {inc: .3e}")
    print(f"\nviolations found: {bad}")


if __name__ == "__main__":
    main()
