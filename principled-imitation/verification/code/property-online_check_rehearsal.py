"""Referee's check of Section 6 of research/prove-c/property-online.md (the rehearsal corollary)
by EXACT enumeration on a small scaffold, and by simulation for the high-probability statements.

The scaffold (horizon L = 2). z is 0, 1 or 2 with probabilities 0.5, 0.4, 0.1; rho is a fair coin.
If z = 2 the run has no call. Otherwise the first call is the question z; a second call, with the
question 2, is made if the first answer is 1 or if rho = 1. So runs have 0, 1 or 2 calls, the
second question depends on the first answer, and rounds can be void.

The human (a stateless sampler, not in any class): P(1|0) = 0.3, P(1|1) = 0.8, P(1|2) = 0.
Answers are 0 and 1. Tests (sets of pairs) and weights:
    B0 = {(0,1), (1,1)}      0.3      two-sided
    B1 = {(2,1)}             0.05     the human never satisfies it
    B2 = {(x,1) : all x}     0.2      two-sided
    B3 = {(1,0)}             0.1      two-sided, rare for the human
    B4 = {(2,0)}             0.25     the human always satisfies it at the question 2 (rate 1 there);
                                      as a set of pairs it is 'never violated' only at question 2
    B5 = {(x,y) : not (x = 2 and y = 1)}  0.1   the human always satisfies it
(weights sum to 1).

Part 1 (exact). Forward recursion over the law of the books (the state is the tuple of
(S, V, sign, pure) of all tests). Computed exactly, for n = 1..N:
    E S_n(B),  E V_n(B),  sum_t E d_B(a_t),  sum_t E n_B(a_t),  sum_t E m_B(a_t),
and checked:
    Lemma 6.1          E S_n(B) = sum_t E d_B(a_t) / L       (identity)
                       E V_n(B) <= sum_t E (n_B + m_B)(a_t) / L
    Theorem 6.2(a)     |E Delta_n(B)| = (L/n) |E S_n(B)| <= bound
    Theorem 6.2(b)     |pbar - qbar| <= sqrt((pbar + qbar + 1/n) W / n)
    Theorem 6.2(c)     for B1: E (1/n) sum_t n_B(a_t) <= L (K(B) + 2)/n;  for B5: the same for answers outside
    and, pathwise, the bounds of Theorems 2.1, 3.1, 3.3 at every reachable state.

Part 2 (simulation). Theorem 6.3: the event (6.1) for all tests at once, and (6.2), over repeated
rehearsals; Delta_n(B) is computed exactly for each rehearsal.

Part 3. Example 6.5 exactly (one question, a fair coin): the law of S_n and E Delta_n.

Usage: python3 property-online_check_rehearsal.py
"""
import math
import random
from collections import defaultdict

L = 2
PZ = {0: 0.5, 1: 0.4, 2: 0.1}
P1 = {0: 0.3, 1: 0.8, 2: 0.0}          # human's probability of the answer 1
TESTS = [
    lambda x, y: x in (0, 1) and y == 1,
    lambda x, y: x == 2 and y == 1,
    lambda x, y: y == 1,
    lambda x, y: x == 1 and y == 0,
    lambda x, y: x == 2 and y == 0,
    lambda x, y: not (x == 2 and y == 1),
]
PI = [0.3, 0.05, 0.2, 0.1, 0.25, 0.1]
NT = len(TESTS)
BT = [[[1.0 if B(x, y) else 0.0 for y in (0, 1)] for x in (0, 1, 2)] for B in TESTS]


def G(v, s):
    return (v + 1.0) ** -0.5 * math.exp(s * s / (2.0 * (v + 1.0)))


def cN(s, v):
    return 0.5 * (G(v + 1, s + 1.0) - G(v + 1, s - 1.0))


def slope(rule, st, eta):
    s, v, sign, pure = st
    if rule == "lead":
        return math.sinh(eta * s)
    if rule == "N":
        return cN(s, v)
    if rule == "NH":
        cH = sign * 2.0 ** (v - 1) if (v >= 1 and pure) else 0.0
        return 0.5 * cN(s, v) + 0.5 * cH
    raise ValueError(rule)


def push(st, g):
    s, v, sign, pure = st
    if g == 0:
        return st
    if sign == 0 and pure:
        return (s + g, v + 1, g, True)
    return (s + g, v + 1, sign, pure and g == sign)


def rule_of(rule, state, eta):
    """The rule a_t: answers to the questions 0, 1, 2 (least minimiser)."""
    sl = [slope(rule, st, eta) for st in state]
    a = []
    for x in (0, 1, 2):
        sc = [sum(PI[k] * sl[k] * BT[k][x][y] for k in range(NT)) for y in (0, 1)]
        a.append(0 if sc[0] <= sc[1] + 1e-14 else 1)
    return tuple(a)


def runs_of(a):
    """All runs of the rule a: list of (probability, list of questions)."""
    out = []
    for z, pz in PZ.items():
        for rho in (0, 1):
            if z == 2:
                out.append((pz * 0.5, []))
                continue
            xs = [z]
            if a[z] == 1 or rho == 1:
                xs.append(2)
            out.append((pz * 0.5, xs))
    return out


def stats_of_rule(a):
    """n_B(a), m_B(a) for all tests."""
    nB = [0.0] * NT
    mB = [0.0] * NT
    for p, xs in runs_of(a):
        for x in xs:
            for k in range(NT):
                nB[k] += p * BT[k][x][a[x]]
                mB[k] += p * (P1[x] * BT[k][x][1] + (1 - P1[x]) * BT[k][x][0])
    return nB, mB


def pathwise_ok(rule, state, t, eta):
    for st, p in zip(state, PI):
        s, v, sign, pure = st
        if rule == "lead":
            if abs(s) > (math.log(2 / p) + t * math.log(math.cosh(eta))) / eta + 1e-9:
                return False
        elif rule == "N":
            if s * s > (v + 1) * (2 * math.log(1 / p) + math.log(v + 1)) + 1e-9:
                return False
            if pure and v > 2 * math.log(1 / p) + math.log(2 * math.log(1 / p) + 4) + 2:
                return False
        elif rule == "NH":
            if s * s > (v + 1) * (2 * math.log(2 / p) + math.log(v + 1)) + 1e-9:
                return False
            if pure and v > math.log2(1 / p) + 2:
                return False
    return True


def exact(rule, N):
    eta = 1 / math.sqrt(N)       # for the rule of Theorem 2.1: tuned to the last round
    dist = {tuple((0, 0, 0, True) for _ in range(NT)): 1.0}
    sum_d = [0.0] * NT
    sum_n = [0.0] * NT
    sum_m = [0.0] * NT
    sum_g2 = [0.0] * NT          # sum_t E g_t^2 = E V_n
    rows = []
    for t in range(1, N + 1):
        new = defaultdict(float)
        for state, pr in dist.items():
            a = rule_of(rule, state, eta)
            nB, mB = stats_of_rule(a)
            for k in range(NT):
                sum_d[k] += pr * (nB[k] - mB[k])
                sum_n[k] += pr * nB[k]
                sum_m[k] += pr * mB[k]
            for p, xs in runs_of(a):
                for J in (1, 2):
                    if J > len(xs):
                        new[state] += pr * p / L
                        continue
                    x = xs[J - 1]
                    for y in (0, 1):
                        py = P1[x] if y == 1 else 1 - P1[x]
                        if py == 0.0:
                            continue
                        gs = [int(BT[k][x][a[x]] - BT[k][x][y]) for k in range(NT)]
                        ns = tuple(push(st, g) for st, g in zip(state, gs))
                        new[ns] += pr * p / L * py
                        for k in range(NT):
                            sum_g2[k] += pr * p / L * py * gs[k] * gs[k]
        dist = dict(new)
        assert abs(sum(dist.values()) - 1) < 1e-9
        assert all(pathwise_ok(rule, s, t, eta) for s in dist)
        ES = [sum(pr * s[k][0] for s, pr in dist.items()) for k in range(NT)]
        EabsS = [sum(pr * abs(s[k][0]) for s, pr in dist.items()) for k in range(NT)]
        EV = [sum(pr * s[k][1] for s, pr in dist.items()) for k in range(NT)]
        rows.append((t, len(dist), ES, EabsS, EV, sum_d[:], sum_n[:], sum_m[:], sum_g2[:]))
    return rows, dist


def part1():
    N = 14
    for rule in ("lead", "N", "NH"):
        rows, dist = exact(rule, N)
        print(f"== Part 1, rule {rule}: exact law of the books, n = 1..{N} "
              f"(reachable states at n = {N}: {rows[-1][1]}) ==")
        worst_id = 0.0
        for (t, ns, ES, EabsS, EV, sd, sn, sm, sg2) in rows:
            for k in range(NT):
                worst_id = max(worst_id, abs(ES[k] - sd[k] / L))                # Lemma 6.1, first claim
                assert abs(EV[k] - sg2[k]) < 1e-9
                assert EV[k] <= (sn[k] + sm[k]) / L + 1e-9                     # Lemma 6.1, second claim
        print(f"Lemma 6.1: max over n and B of |E S_n(B) - sum_t E d_B(a_t)/L| = {worst_id:.2e}")
        assert worst_id < 1e-9
        t, ns, ES, EabsS, EV, sd, sn, sm, sg2 = rows[-1]
        n = t
        print(f"{'test':>5} {'pi':>5} {'E Delta_n':>10} {'(L/n)E|S_n|':>12} {'bound (a)':>10} {'pbar':>8} {'qbar':>8} "
              f"{'|p-q|':>8} {'bound (b)':>10} {'E N or E M':>11} {'K(B)+2':>7}")
        for k in range(NT):
            p = PI[k]
            lam = math.log(1 / p)
            ED = sd[k] / n
            if rule == "lead":
                ba = L * (math.log(2 / p) + 0.5) / math.sqrt(n)
                W = None
            elif rule == "N":
                W = 2 * lam + math.log(n + 1)
                ba = L * math.sqrt((1 + 1 / n) * W / n)
            else:
                W = 2 * lam + 2 * math.log(2) + math.log(n + 1)
                ba = L * math.sqrt((1 + 1 / n) * W / n)
            pbar, qbar = sn[k] / n / L, sm[k] / n / L
            bb = math.sqrt((pbar + qbar + 1 / n) * W / n) if W else float("nan")
            assert abs(ED) <= (L / n) * EabsS[k] + 1e-12 <= ba + 1e-9
            if W:
                assert abs(pbar - qbar) <= bb + 1e-12
            extra = ""
            if k == 1:          # the human never satisfies B1
                EN = sn[k] / L
                extra = f"{EN:>11.4f} {math.log2(1 / p) + 2:>7.2f}"
                assert abs(EN - ES[k]) < 1e-9
                if rule == "NH":
                    assert EN <= math.log2(1 / p) + 2
            if k == 5:          # the human always satisfies B5: count of the imitator's answers outside it
                EM = -ES[k]
                extra = f"{EM:>11.4f} {math.log2(1 / p) + 2:>7.2f}"
                if rule == "NH":
                    assert EM <= math.log2(1 / p) + 2
            print(f"{'B' + str(k):>5} {p:>5.2f} {ED:>10.5f} {(L / n) * EabsS[k]:>12.5f} {ba:>10.4f} {pbar:>8.5f} "
                  f"{qbar:>8.5f} {abs(pbar - qbar):>8.5f} {bb:>10.4f} {extra}")
        # growth of the one-sided expected counts with n (must stay bounded for N and NH)
        print("E N_n(B1) for n = 2, 6, 10, 14:", " ".join(f"{rows[i][6][1] / L:.4f}" for i in (1, 5, 9, 13)))
        print()


def part2():
    print("== Part 2: Theorem 6.3 by simulation (Delta_n(B) exact for each rehearsal) ==")
    rnd = random.Random(3)
    for rule in ("lead", "NH"):
        for n, reps in ((50, 4000), (400, 1000)):
            eta = 1 / math.sqrt(n)
            for delta in (0.5, 0.05):
                viol61 = viol62 = 0
                worst = 0.0
                for _ in range(reps):
                    state = tuple((0, 0, 0, True) for _ in range(NT))
                    sd = [0.0] * NT
                    sn = [0.0] * NT
                    for t in range(n):
                        a = rule_of(rule, state, eta)
                        nB, mB = stats_of_rule(a)
                        for k in range(NT):
                            sd[k] += nB[k] - mB[k]
                            sn[k] += nB[k]
                        # one rehearsal round
                        u = rnd.random()
                        z = 0 if u < 0.5 else (1 if u < 0.9 else 2)
                        rho = rnd.random() < 0.5
                        xs = [] if z == 2 else ([z, 2] if (a[z] == 1 or rho) else [z])
                        J = rnd.randrange(1, L + 1)
                        if J <= len(xs):
                            x = xs[J - 1]
                            y = 1 if rnd.random() < P1[x] else 0
                            state = tuple(push(st, int(BT[k][x][a[x]] - BT[k][x][y]))
                                          for k, st in enumerate(state))
                    bad = False
                    for k in range(NT):
                        rhs = (L / n) * (abs(state[k][0]) + math.sqrt(2 * n * math.log(2 / (PI[k] * delta))))
                        worst = max(worst, abs(sd[k] / n) / rhs)
                        bad |= abs(sd[k] / n) > rhs
                    viol61 += bad
                    if rule == "NH":
                        k = 1
                        rhs = 1.582 * L * (math.log2(1 / PI[k]) + 2 + math.log(1 / PI[k]) + math.log(1 / delta)) / n
                        viol62 += sn[k] / n > rhs
                print(f"rule {rule:>4}, n = {n:>4}, delta = {delta:>4}: (6.1) violated in {viol61}/{reps} rehearsals "
                      f"(allowed: {delta * reps:.0f}); largest left/right = {worst:.3f}"
                      + (f"; (6.2) violated in {viol62}/{reps}" if rule == "NH" else ""))
                assert viol61 <= delta * reps and viol62 <= delta * reps
    print()


def part3():
    print("== Part 3: Example 6.5 (L = 1, one question, a fair coin, one test of weight 1), exact ==")
    for rule in ("lead", "N", "NH"):
        n = 40
        eta = 1 / math.sqrt(n)
        dist = {(0, 0, 0, True): 1.0}
        sum_d = 0.0
        for t in range(n):
            new = defaultdict(float)
            for st, pr in dist.items():
                c = slope(rule, st, eta)
                a = 1 if c < 0 else 0
                sum_d += pr * ((a == 1) - 0.5)
                for y in (0, 1):
                    new[push(st, (a == 1) - (y == 1))] += pr * 0.5
            dist = dict(new)
            assert all(abs(st[0]) <= 1 for st in dist)
        ES = sum(pr * st[0] for st, pr in dist.items())
        print(f"rule {rule:>4}: n = {n}; support of S_n = {sorted({st[0] for st in dist})}; "
              f"E Delta_n = {sum_d / n:+.5f} = E S_n / n = {ES / n:+.5f}; |E Delta_n| <= 1/n = {1 / n:.5f}; "
              f"every single rule has |d_B| = 1/2")
        assert abs(sum_d / n - ES / n) < 1e-12 and abs(sum_d / n) <= 1 / n + 1e-12
    print()


if __name__ == "__main__":
    part1()
    part2()
    part3()
    print("all checks passed")
