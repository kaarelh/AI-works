"""Adversary's check of the claim "the two-sided rate cannot be improved beyond the logarithm"
(research/prove-c/property-online.md, Section 3.3, Proposition 3.6 and the summary).

Three computations.

(A) FINITE FAMILIES OF SET TESTS: THE BOOKS CAN BE KEPT BOUNDED FOR ALL n.
    For a small instance (questions, answers, set tests) the game "can the adversary ever push
    some book outside [-c, c]?" is a safety game on the integer vectors of books. Its exact
    solution (greatest fixed point: a state is safe if for every question there is an answer of
    the imitator such that every answer of the human leads to a safe state) gives the least c
    for which SOME rule keeps max_B |S_t(B)| <= c for every t, on every sequence. It is compared
    with (i) the "ledger" rule: for each type of question keep, for every answer, (number of times
    I gave it) - (number of times the human gave it), and give the answer with the least value;
    its books are bounded by (number of question types at which the test separates two answers)
    x (|Y| - 1) for all n; (ii) the largest |S_t(B)| that the adversary can reach against Rule N,
    Rule NH and the rule of Proposition 2.4 within n rounds (exhaustive over all sequences and
    all tie-breaks, by memoised search over the states of the books).

(B) TESTS WITH VALUES IN [0, 1]: sqrt(n/2) IS FORCED BY TWO TESTS (Spencer's lower bound for
    balancing games with real vectors, as reported by Barany, arXiv:2412.08238, Section 1).
    Questions x = (v_1, v_2) in [-1, 1]^2, answers {0, 1}, tests b_k(x, 1) = max(v_k, 0),
    b_k(x, 0) = max(-v_k, 0), weights 1/2. The adversary asks a question whose vector is
    orthogonal to the current books and has maximum norm 1, and the human gives the answer the
    imitator does not give. Then S_1(B_1)^2 + S_2(B_2)^2 >= n whatever the rule.

(C) THE RULE OF PROPOSITION 2.4 (rate eta_t = c / sqrt(t)): the standard analysis of exponential
    weights with a non-increasing rate gives |S_n(B)| <= ln(2/pi(B))/eta_n + (1/2) sum_{t<=n} eta_t
    <= sqrt(n) (ln(2/pi(B))/c + c), without the factor (1 + ln n) of Proposition 2.4. Checked
    here on every reachable state (exhaustive) and on long adversarial runs.

Usage: python3 property-online_attack_finite.py > property-online_attack_finite.out
"""
import itertools
import math
import random

TOL = 1e-12


def G(v, s):
    return (v + 1.0) ** -0.5 * math.exp(s * s / (2.0 * (v + 1.0)))


def cN(s, v):
    return 0.5 * (G(v + 1, s + 1.0) - G(v + 1, s - 1.0))


# ------------------------------------------------------------------ (A) safety game, ledger, rules
def increments(inst):
    """g[x][a][y] = tuple of increments of the tests."""
    X, Y, tests = inst["X"], inst["Y"], inst["tests"]
    K = len(tests)
    return [[[tuple(tests[k][x][a] - tests[k][x][y] for k in range(K)) for y in range(Y)]
             for a in range(Y)] for x in range(X)]


def safe_bound(inst, cmax=8):
    """Least c such that the imitator can keep all books in [-c, c] for ever (exact), or None."""
    X, Y = inst["X"], inst["Y"]
    K = len(inst["tests"])
    g = increments(inst)
    for c in range(0, cmax + 1):
        box = set(itertools.product(range(-c, c + 1), repeat=K))
        W = set(box)
        changed = True
        while changed:
            changed = False
            for S in list(W):
                ok_state = True
                for x in range(X):
                    ok_x = False
                    for a in range(Y):
                        if all(tuple(S[k] + g[x][a][y][k] for k in range(K)) in W for y in range(Y)):
                            ok_x = True
                            break
                    if not ok_x:
                        ok_state = False
                        break
                if not ok_state:
                    W.discard(S)
                    changed = True
        if tuple([0] * K) in W:
            return c
    return None


def ledger_bound(inst):
    """max over tests of (number of question types at which the test separates two answers) x (|Y| - 1)."""
    X, Y, tests = inst["X"], inst["Y"], inst["tests"]
    types = {}
    for x in range(X):
        types.setdefault(tuple(tuple(tests[k][x]) for k in range(len(tests))), []).append(x)
    best = 0
    for k in range(len(tests)):
        m = sum(1 for sig in types if len(set(sig[k])) > 1)
        best = max(best, m * (Y - 1))
    return best, len(types)


def ledger_worst(inst, n):
    """Largest |S_t(B)| reachable against the ledger rule within n rounds (exhaustive, all tie-breaks)."""
    X, Y, tests = inst["X"], inst["Y"], inst["tests"]
    K = len(tests)
    sig = [tuple(tuple(tests[k][x]) for k in range(K)) for x in range(X)]
    types = sorted(set(sig))
    tix = [types.index(s) for s in sig]
    start = tuple(tuple(0 for _ in range(Y)) for _ in types)
    seen = {start}
    frontier = [start]
    worst = 0
    for t in range(n):
        nf = []
        for st in frontier:
            for x in range(X):
                z = st[tix[x]]
                m = min(z)
                for a in range(Y):
                    if z[a] == m:
                        for y in range(Y):
                            zz = list(z)
                            zz[a] += 1
                            zz[y] -= 1
                            ns = list(st)
                            ns[tix[x]] = tuple(zz)
                            ns = tuple(ns)
                            if ns not in seen:
                                seen.add(ns)
                                nf.append(ns)
                                # books of the tests in this state
                                for k in range(K):
                                    S = sum(ns[i][yy] * types[i][k][yy] for i in range(len(types)) for yy in range(Y))
                                    worst = max(worst, abs(S))
        frontier = nf
        if not frontier:
            break
    return worst, len(seen)


def rule_worst(inst, rule, n, par=1.0, max_states=400000):
    """Largest |S_t(B)| reachable within t rounds against a rule, for t = 1..n (exhaustive over sequences
    and tie-breaks; state of a test = (S, V, sign pattern); 'decr' also needs the clock)."""
    X, Y, tests, pis = inst["X"], inst["Y"], inst["tests"], inst["pi"]
    K = len(tests)
    g = increments(inst)
    start = (0, tuple((0, 0, 0) for _ in range(K)))        # (clock, per test (S, V, sgn)); sgn: 0 none, 1, -1, 2 mixed
    seen = {start}
    frontier = [start]
    worst_by_t = []
    worst = 0
    ratio_sharp = 0.0     # for 'decr': |S| / (ln(2/pi)/eta_t + 0.5 sum_{s<=t} eta_s)
    ratio_24 = 0.0        # for 'decr': |S| / bound of Proposition 2.4
    for t in range(n):
        nf = []
        for clock, st in frontier:
            sl = []
            for k in range(K):
                S, V, sg = st[k]
                if rule == "N":
                    sl.append(cN(S, V))
                elif rule == "NH":
                    cH = sg * 2.0 ** (V - 1) if sg in (1, -1) else 0.0
                    sl.append(0.5 * cN(S, V) + 0.5 * cH)
                elif rule == "decr":
                    sl.append(math.sinh(par / math.sqrt(t + 1) * S))
            moves = set()
            for x in range(X):
                F = [sum(pis[k] * sl[k] * tests[k][x][y] for k in range(K)) for y in range(Y)]
                m = min(F)
                for a in range(Y):
                    if F[a] <= m + TOL:
                        for y in range(Y):
                            moves.add(g[x][a][y])
            for mv in moves:
                ns = []
                for k in range(K):
                    S, V, sg = st[k]
                    if mv[k] != 0:
                        nsg = mv[k] if sg == 0 else (sg if sg == mv[k] else 2)
                        ns.append((S + mv[k], V + 1, nsg))
                    else:
                        ns.append((S, V, sg))
                key = ((t + 1) if rule == "decr" else 0, tuple(ns))
                if key not in seen:
                    seen.add(key)
                    nf.append(key)
                    for k in range(K):
                        worst = max(worst, abs(ns[k][0]))
                        if rule == "decr":
                            eta_t = par / math.sqrt(t + 1)
                            sharp = math.log(2 / pis[k]) / eta_t + 0.5 * sum(par / math.sqrt(s) for s in range(1, t + 2))
                            b24 = math.sqrt(t + 1) / par * (math.log(2 / pis[k]) + par * par / 2 * (1 + math.log(t + 1)))
                            ratio_sharp = max(ratio_sharp, abs(ns[k][0]) / sharp)
                            ratio_24 = max(ratio_24, abs(ns[k][0]) / b24)
        frontier = nf
        worst_by_t.append(worst)
        if len(seen) > max_states or not frontier:
            break
    return worst_by_t, len(seen), ratio_sharp, ratio_24


def random_set_instance(rng, X, Y, K, weights="equal"):
    tests = []
    for _ in range(K):
        while True:
            tb = [[rng.randint(0, 1) for _ in range(Y)] for _ in range(X)]
            if any(len(set(row)) > 1 for row in tb):
                break
        tests.append(tb)
    pi = [1.0 / K] * K if weights == "equal" else [2.0 ** -(k + 1) for k in range(K)]
    return {"X": X, "Y": Y, "tests": tests, "pi": pi}


def hypercube_instance(d):
    """The family of Proposition 3.6: X = {-1,1}^d, Y = {0,1}, B_k = {y = 1[x_k = 1]}, weights 1/d."""
    xs = list(itertools.product((-1, 1), repeat=d))
    tests = [[[1 if y == (1 if x[k] == 1 else 0) else 0 for y in (0, 1)] for x in xs] for k in range(d)]
    return {"X": len(xs), "Y": 2, "tests": tests, "pi": [1.0 / d] * d}


def part_A():
    print("(A) finite families of set tests: least bound c* that some rule guarantees for all n (exact safety game),")
    print("    the ledger rule (guaranteed bound, and worst case found by exhaustive search), and the largest |S_t(B)|")
    print("    the adversary can reach against Rule N / Rule NH within n rounds (exhaustive; '+' = search cut off by size)")
    print(f"{'instance':28s} {'c*':>3s} {'ledger bound':>12s} {'ledger worst':>12s} | {'n':>3s} {'N: worst':>9s} {'NH: worst':>9s} "
          f"| worst |S_t| against N at t = 1, 2, 4, 8, 16, 32, n")
    rng = random.Random(7)
    insts = []
    for (X, Y, K, w, n) in ((1, 2, 1, "equal", 60), (2, 2, 2, "equal", 60), (2, 3, 2, "equal", 40), (3, 2, 2, "equal", 40),
                             (3, 2, 3, "dyadic", 30), (2, 3, 3, "equal", 26), (3, 3, 2, "equal", 30), (4, 2, 3, "equal", 30),
                             (3, 3, 3, "dyadic", 20)):
        for rep in range(2):
            insts.append((f"random X={X} Y={Y} K={K} {w} #{rep}", random_set_instance(rng, X, Y, K, w), n))
    insts.append(("hypercube d=2 (Prop. 3.6)", hypercube_instance(2), 60))
    insts.append(("hypercube d=3 (Prop. 3.6)", hypercube_instance(3), 40))
    insts.append(("hypercube d=4 (Prop. 3.6)", hypercube_instance(4), 24))
    for name, inst, n in insts:
        cstar = safe_bound(inst)
        lb, ntypes = ledger_bound(inst)
        lw, _ = ledger_worst(inst, 400)
        wN, sN, _, _ = rule_worst(inst, "N", n)
        wNH, sNH, _, _ = rule_worst(inst, "NH", n)
        cut = "+" if len(wN) < n else " "
        pts = [wN[min(t, len(wN)) - 1] for t in (1, 2, 4, 8, 16, 32) if t <= len(wN)] + [wN[-1]]
        print(f"{name:28s} {str(cstar):>3s} {lb:12d} {lw:12d} | {len(wN):3d}{cut} {wN[-1]:8d} {wNH[-1]:9d} | {pts}")
    print()


# ------------------------------------------------------------------ (B) two valued tests force sqrt(n/2)
def part_B():
    print("(B) two tests with values in [0, 1] (weights 1/2), questions = vectors of [-1, 1]^2 orthogonal to the books,")
    print("    the human gives the other answer: max_k |S_n(B_k)| against sqrt(n/2) and the bound (3.2) of Theorem 3.1")
    print(f"{'rule':>8s} {'n':>8s} {'max_k |S_n|':>12s} {'sqrt(n/2)':>10s} {'bound (3.2)':>12s}")
    for rule in ("N", "lead"):
        for n in (100, 1000, 10000, 100000):
            S = [0.0, 0.0]
            V = [0, 0]
            eta = 1 / math.sqrt(n)
            for t in range(n):
                if abs(S[0]) < 1e-300 and abs(S[1]) < 1e-300:
                    v = (1.0, 1.0)
                else:
                    m = max(abs(S[0]), abs(S[1]))
                    v = (-S[1] / m, S[0] / m)
                # scores of the answers 1 and 0: sum_k pi_k c_k b_k(x, y)
                if rule == "N":
                    c = [cN(S[k], V[k]) for k in range(2)]
                else:
                    c = [math.sinh(eta * S[k]) for k in range(2)]
                F1 = sum(0.5 * c[k] * max(v[k], 0.0) for k in range(2))
                F0 = sum(0.5 * c[k] * max(-v[k], 0.0) for k in range(2))
                a = 1 if F1 < F0 else 0
                eps = 1.0 if a == 1 else -1.0            # the human answers 1 - a: increment eps * v
                for k in range(2):
                    gk = eps * v[k]
                    if gk != 0.0:
                        S[k] += gk
                        V[k] += 1
            bound = math.sqrt((n + 1) * (2 * math.log(2) + math.log(n + 1)))
            print(f"{rule:>8s} {n:8d} {max(abs(S[0]), abs(S[1])):12.2f} {math.sqrt(n / 2):10.2f} {bound:12.2f}")
    print()


# ------------------------------------------------------------------ (C) decreasing rate without ln n
def part_C():
    print("(C) the rule of Proposition 2.4 (eta_t = c/sqrt(t)): largest |S_t(B)| / bound over ALL reachable states")
    print("    'sharp' = ln(2/pi)/eta_t + (1/2) sum_{s<=t} eta_s  (standard analysis; no ln t);  'Prop 2.4' = the file's bound")
    rng = random.Random(11)
    print(f"{'instance':34s} {'c':>4s} {'n':>3s} {'states':>8s} {'max |S|/sharp':>14s} {'max |S|/Prop 2.4':>17s}")
    for (X, Y, K, w, n) in ((1, 2, 1, "equal", 40), (2, 2, 2, "equal", 26), (2, 3, 2, "dyadic", 22), (3, 2, 3, "dyadic", 18),
                             (2, 3, 3, "equal", 16)):
        for c in (0.5, 1.0, 2.0):
            inst = random_set_instance(rng, X, Y, K, w)
            wb, ns, rs, r24 = rule_worst(inst, "decr", n, par=c, max_states=600000)
            print(f"{'random X=%d Y=%d K=%d %s' % (X, Y, K, w):34s} {c:4.1f} {len(wb):3d} {ns:8d} {rs:14.4f} {r24:17.4f}")
    # long adversarial runs on the hypercube family of Proposition 3.6 (the adversary of its proof)
    print("    long runs, family and adversary of Proposition 3.6 (d tests of weight 1/d), c = 1:")
    print(f"{'d':>6s} {'n':>8s} {'max_t max_k |S_t|':>18s} {'sharp bound at n':>17s} {'Prop 2.4 at n':>14s} {'max_t ratio to sharp':>21s}")
    for d, n in ((8, 2000), (32, 20000), (100, 20000)):
        S = [0.0] * d
        worst = 0.0
        worst_ratio = 0.0
        cum_eta = 0.0
        for t in range(1, n + 1):
            eta = 1.0 / math.sqrt(t)
            cum_eta += eta
            # question: signs with |<x, S>| <= max|S| (greedy), as in the proof of Proposition 3.6
            x = []
            part = 0.0
            for k in range(d):
                s = 1 if part * S[k] <= 0 else -1
                x.append(s)
                part += s * S[k]
            # score of answer 1 minus score of answer 0 = sum_k pi_k sinh(eta S_k) x_k
            diff = sum(math.sinh(eta * S[k]) * x[k] for k in range(d)) / d
            a = 1 if diff < 0 else 0
            eps = 1 if a == 1 else -1
            for k in range(d):
                S[k] += eps * x[k]
            m = max(abs(v) for v in S)
            worst = max(worst, m)
            worst_ratio = max(worst_ratio, m / (math.log(2 * d) / eta + 0.5 * cum_eta))
        sharp = math.log(2 * d) * math.sqrt(n) + 0.5 * cum_eta
        b24 = math.sqrt(n) * (math.log(2 * d) + 0.5 * (1 + math.log(n)))
        print(f"{d:6d} {n:8d} {worst:18.1f} {sharp:17.1f} {b24:14.1f} {worst_ratio:21.4f}")


if __name__ == "__main__":
    part_A()
    part_B()
    part_C()
