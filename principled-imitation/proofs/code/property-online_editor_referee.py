"""Editor's checks in the referee round, part property-online.

Written by the editor of the section source in the referee round, for the three passages that the
editor added to proofs/property-online.md in that round (Remark 3.3a, Example 6.5a, Remark 7.2a)
and for the sentences of the note that rest on them.  Standard library only.  It shares no code
with the other scripts of this part: Rule NH is programmed here from the formula as the note
prints it,
    slope = (1/4)*(G_{V+1}(S+1) - G_{V+1}(S-1)) + sign*2^(V-2)   (last term only if V >= 1 and
    all non-zero increments had one sign),      G_v(s) = (v+1)^(-1/2) * exp(s^2/(2(v+1))).
Run from proofs/code/:
    python3 property-online_editor_referee.py > property-online_editor_referee.out

Parts
  1  Example 6.5a: the play on every sequence of questions (claim (a)); the expected number of
     calls of a deployed run that break the kept property, exactly, against the closed form of
     claim (b); the numbers of claim (c); the mirrored example for ties to the greatest answer;
     a simulation of rehearsal and deployment.
  2  Remark 3.3a: all reachable states of games with two tests that cover every answer at one
     question, for every sequence of questions, every human who never enters the second test and
     every exact minimiser: the bounds (i) and (ii) of Theorem 3.3.
  3  The second part of the potential of Rule NH along a history (the sentence of the note's
     idea of the proof of Pr5): 1/2, 1/2, 1, 2, 4, ... and 0 after a change of sign.
  4  Arithmetic of sentences of the note: (1-(1-q)^n)/(n q) >= 1 - (n-1) q/2; the number of
     tests of price at most k bits; K + 1 bits and K + 3 rounds for the tests of a class.
"""
import math
import random
import itertools
from fractions import Fraction

TOL = 1e-12


def G(v, s):
    return math.exp(s * s / (2.0 * (v + 1))) / math.sqrt(v + 1)


def slope(state):
    """state = (S, V, sign) with sign 0 (no non-zero increment yet), +1 or -1 (all non-zero
    increments had this sign), 2 (both signs occurred)."""
    S, V, sign = state
    c = 0.25 * (G(V + 1, S + 1) - G(V + 1, S - 1))
    if V >= 1 and sign in (1, -1):
        c += sign * 2.0 ** (V - 2)
    return c


def step(state, g):
    S, V, sign = state
    if g == 0:
        return state
    if sign == 0:
        new_sign = g
    elif sign == g:
        new_sign = sign
    else:
        new_sign = 2
    return (S + g, V + 1, new_sign)


def minimisers(states, weights, tests, x, answers):
    """Exact minimisers of the score sum_B pi(B)*slope(B)*1[(x, y) in B] over the answers."""
    scores = []
    for y in answers:
        sc = 0.0
        for st, w, B in zip(states, weights, tests):
            if (x, y) in B:
                sc += w * slope(st)
        scores.append(sc)
    best = min(scores)
    return [y for y, sc in zip(answers, scores) if sc <= best + TOL]


def increments(tests, x, a, y):
    return [int((x, a) in B) - int((x, y) in B) for B in tests]


START = (0, 0, 0)

# ----------------------------------------------------------------------------------------------
# Part 1.  Example 6.5a
# ----------------------------------------------------------------------------------------------
print("Part 1. Example 6.5a")
X1, X2 = "x1", "x2"
ANS = [0, 1]


def example(mirror=False):
    """Tests and human of Example 6.5a; mirror=True exchanges the answers 0 and 1."""
    if not mirror:
        B1 = {(X1, 1), (X2, 1)}          # "the answer is 1"
        B2 = {(X2, 0)}                   # "the answer to x2 is 0"
        f = {X1: 0, X2: 1}
    else:
        B1 = {(X1, 0), (X2, 0)}
        B2 = {(X2, 1)}
        f = {X1: 1, X2: 0}
    return [B1, B2], f


def play(questions, weights, mirror=False):
    """Returns, for each round t, the rule's answers (a_t(x1), a_t(x2)) and the increments."""
    tests, f = example(mirror)
    pick = max if mirror else min        # greatest or least answer among the minimisers
    states = [START, START]
    rules, incs = [], []
    for x in questions:
        rule = {q: pick(minimisers(states, weights, tests, q, ANS)) for q in (X1, X2)}
        g = increments(tests, x, rule[x], f[x])
        states = [step(st, gi) for st, gi in zip(states, g)]
        rules.append(rule)
        incs.append(g)
    return rules, incs


def check_claim_a(n_max, weights, mirror=False):
    tests, f = example(mirror)
    bad_answer = 1 - f[X2]               # the answer to x2 that the human never gives
    ok = True
    count = 0
    for n in range(1, n_max + 1):
        for qs in itertools.product((X1, X2), repeat=n):
            rules, incs = play(qs, weights, mirror)
            tau = qs.index(X2) + 1 if X2 in qs else None
            later_x1 = None
            if tau is not None:
                for t in range(tau + 1, n + 1):
                    if qs[t - 1] == X1:
                        later_x1 = t
                        break
            for t in range(1, n + 1):
                before_or_at = (tau is None) or (t <= tau)
                # a_t(x2) is the never-given answer exactly for t <= tau
                if (rules[t - 1][X2] == bad_answer) != before_or_at:
                    ok = False
                # the imitator's answer is in B2 in round tau only
                if (incs[t - 1][1] == 1) != (t == tau):
                    ok = False
                # it differs from the human's in round tau and in the first later round with x1
                differs = rules[t - 1][qs[t - 1]] != f[qs[t - 1]]
                if differs != (t == tau or t == later_x1):
                    ok = False
            count += 1
    return ok, count


for w, name in [((0.5, 0.5), "(0.5, 0.5)"), ((0.3, 0.1), "(0.3, 0.1)"),
                ((0.01, 0.5), "(0.01, 0.5)"), ((0.6, 2.0 ** -20), "(0.6, 2^-20)")]:
    ok, cnt = check_claim_a(13, w)
    print(f"   claim (a), weights {name}: holds on all {cnt} sequences of 1 to 13 questions: {ok}")
ok, cnt = check_claim_a(13, (0.5, 0.5), mirror=True)
print(f"   claim (a), answers exchanged and ties to the greatest answer, weights (0.5, 0.5): {ok}"
      f" ({cnt} sequences)")


def expected_delta_exact(n, q, weights):
    """E Delta_n(B2) by enumeration of all sequences of n questions, with exact probabilities."""
    tests, f = example()
    total = Fraction(0)
    for qs in itertools.product((X1, X2), repeat=n):
        prob = Fraction(1)
        for x in qs:
            prob *= q if x == X2 else 1 - q
        rules, _ = play(qs, weights)
        cnt = sum(1 for r in rules if r[X2] == 0)       # rounds t with a_t(x2) = 0
        total += prob * q * Fraction(cnt, n)             # d_{B2}(a_t) = q * 1[a_t(x2) = 0]
    return total


print("   claim (b): E Delta_n(B2) by enumeration against (1 - (1-q)^n)/n, as rational numbers")
print("        n      q    enumeration            closed form            equal   bound (K(B2)+2)/n, pi2 = 1/2")
all_equal = True
for n in (1, 2, 5, 9, 12):
    for q in (Fraction(1, 2), Fraction(1, 10), Fraction(1, 100)):
        e = expected_delta_exact(n, q, (0.5, 0.5))
        c = (1 - (1 - q) ** n) / n
        all_equal = all_equal and (e == c)
        if (n, q) in ((1, Fraction(1, 2)), (5, Fraction(1, 10)), (12, Fraction(1, 10)),
                      (12, Fraction(1, 100))):
            print(f"       {n:2d}  {str(q):>5}    {float(e):.12f}         {float(c):.12f}"
                  f"         {e == c}    {3.0 / n:.4f}")
print(f"   equal in all 15 cases (n = 1, 2, 5, 9, 12; q = 1/2, 1/10, 1/100): {all_equal}")

print("   claim (c): a deployed run that asks x2 answers it against the human with probability")
print("              (1 - (1-q)^n)/(n q) >= 1 - (n-1) q/2")
print("        n        q      n q    Pr[meets x2 and breaks]   bound 3/n   Pr[breaks | meets x2]   1-(n-1)q/2")
for n, q in ((1000, 1e-2), (1000, 1e-3), (1000, 1e-4), (10000, 1e-5), (100000, 1e-7)):
    p_break = -math.expm1(n * math.log1p(-q)) / n
    print(f"   {n:6d}  {q:7.0e}  {n * q:7.3f}         {p_break:.3e}          {3.0 / n:.1e}"
          f"           {p_break / q:.4f}             {1 - (n - 1) * q / 2:.4f}")

# a simulation of rehearsal and deployment (fixed seed)
rng = random.Random(20261128)
n, q, reps = 200, 0.002, 20000
meets = breaks = 0
for _ in range(reps):
    qs = [X2 if rng.random() < q else X1 for _ in range(n)]
    rules, _ = play(qs, (0.5, 0.5))
    T = rng.randrange(n)
    x = X2 if rng.random() < q else X1
    if x == X2:
        meets += 1
        breaks += int(rules[T][X2] == 0)
# to see the conditional probability with fewer repetitions, condition on the deployed question
cond_meets = cond_breaks = 0
for _ in range(reps):
    qs = [X2 if rng.random() < q else X1 for _ in range(n)]
    rules, _ = play(qs, (0.5, 0.5))
    T = rng.randrange(n)
    cond_meets += 1
    cond_breaks += int(rules[T][X2] == 0)
exact = (1 - (1 - q) ** n) / (n * q)
print(f"   simulation, n = {n}, q = {q}: {reps} rehearsals each with one deployed run:"
      f" the run asks x2 in {meets} of them and answers 0 in {breaks} of these;")
print(f"      with the deployed question fixed to x2, {reps} rehearsals: answer 0 at the rate"
      f" {cond_breaks / cond_meets:.4f}; closed form {exact:.4f}")

# ----------------------------------------------------------------------------------------------
# Part 2.  Remark 3.3a: reachable states of games with a clash
# ----------------------------------------------------------------------------------------------
print("Part 2. Remark 3.3a: games in which two tests cover every answer at one question")


def reachable_check(questions, answers, tests, weights, kept, rounds):
    """All reachable vectors of test states, for every sequence of questions, every human answer
    that is outside the tests listed in `kept`, and every exact minimiser.  Returns the largest
    ratios of the two bounds of Theorem 3.3 and the number of states visited."""
    lam = [math.log(1.0 / w) for w in weights]
    kbits = [math.log2(1.0 / w) for w in weights]
    frontier = {tuple([START] * len(tests))}
    seen_total = 0
    worst_i = 0.0
    worst_ii = 0.0
    worst_kept = 0
    for _ in range(rounds):
        new = set()
        for states in frontier:
            for x in questions:
                human_answers = [y for y in answers
                                 if all((x, y) not in tests[k] for k in kept)]
                for a in minimisers(states, weights, tests, x, answers):
                    for y in human_answers:
                        g = increments(tests, x, a, y)
                        new.add(tuple(step(st, gi) for st, gi in zip(states, g)))
        frontier = new
        seen_total += len(frontier)
        for states in frontier:
            for k, (S, V, sign) in enumerate(states):
                bound_i = (V + 1) * (2 * lam[k] + 1.39 + math.log(V + 1))
                worst_i = max(worst_i, S * S / bound_i)
                if sign in (0, 1, -1):
                    worst_ii = max(worst_ii, V / (kbits[k] + 2))
                if k in kept:
                    # the human never enters the test, so S = V = number of the imitator's
                    # answers in it
                    assert S == V and S >= 0
                    worst_kept = max(worst_kept, S)
    return worst_i, worst_ii, worst_kept, seen_total


# three questions, three answers; at the question "c" every answer lies in B1 or B2
QUESTIONS = ["a", "b", "c"]
ANSWERS3 = [0, 1, 2]
B1 = {("c", 0), ("c", 1), ("a", 2), ("b", 2)}            # "the answer breaks property 1"
B2 = {("c", 2), ("a", 1)}                                # "the answer breaks property 2"
B3 = {("a", 0), ("b", 1), ("c", 1)}                      # a third test
assert all((("c", y) in B1) or (("c", y) in B2) for y in ANSWERS3)
print("     weights (B1, B2, B3)      rounds   states   max S^2/bound(i)   max V/(K+2), pure"
      "   max rounds in B2   bound for B2")
for weights in [(0.4, 0.4, 0.2), (0.5, 0.01, 0.2), (0.05, 0.6, 0.3), (0.3, 2.0 ** -6, 0.3)]:
    wi, wii, wk, seen = reachable_check(QUESTIONS, ANSWERS3, [B1, B2, B3], weights, kept=[1],
                                        rounds=10)
    print(f"     {str(weights):24s}   {10:4d}   {seen:6d}        {wi:.3f}              {wii:.3f}"
          f"               {wk:2d}             {math.log2(1.0 / weights[1]) + 2:.2f}")
# the example of Remark 3.3a(d) / Example 6.5a in the game: two questions, two answers
EX_TESTS, EX_F = example()
wi, wii, wk, seen = reachable_check([X1, X2], ANS, EX_TESTS, (0.5, 0.5), kept=[1], rounds=14)
print(f"     tests of Example 6.5a, every human who never enters B2, 14 rounds, {seen} states:"
      f" max rounds in B2 = {wk} (bound 3.00), max S^2/bound(i) = {wi:.3f}")

# ----------------------------------------------------------------------------------------------
# Part 3.  The second part of the potential of Rule NH
# ----------------------------------------------------------------------------------------------
print("Part 3. The second part of the potential (idea of the proof of Pr5)")


def second_part_slope(V, sign):
    return sign * 2.0 ** (V - 2) if (V >= 1 and sign in (1, -1)) else 0.0


u2 = 0.5
V, sign = 0, 0
values = [u2]
for _ in range(6):                     # six increments +1
    u2 = u2 + 1 * second_part_slope(V, sign)
    V, sign = V + 1, 1
    values.append(u2)
print("   along a history of increments +1 (V = 0, 1, ..., 6):", values)
u2_after_change = u2 + (-1) * second_part_slope(V, sign)
print("   after one increment -1:", u2_after_change)
print("   so it stays at 1/2 at the first non-zero increment and doubles at each later one,"
      " and 2^(V-2) <= 1/pi gives V <= log2(1/pi) + 2")

# ----------------------------------------------------------------------------------------------
# Part 4.  Arithmetic of sentences of the note
# ----------------------------------------------------------------------------------------------
print("Part 4. Arithmetic")
ok = True
worst = 1.0
for n in list(range(1, 60)) + [100, 1000, 10 ** 4, 10 ** 6]:
    for j in range(1, 400):
        q = j / 400.0
        lhs = -math.expm1(n * math.log1p(-q)) / (n * q) if q < 1 else 1.0 / n
        rhs = 1 - (n - 1) * q / 2
        if lhs < rhs - 1e-12:
            ok = False
        if rhs > 0:
            worst = min(worst, lhs - rhs)
print(f"   (1-(1-q)^n)/(n q) >= 1 - (n-1) q/2 on a grid of n and q: {ok}"
      f" (least difference {worst:.1e}: rounding at n = 1, where the two sides are equal)")
# number of tests of price at most k bits: weights 2^(-length) over a complete prefix code
for k in (1, 3, 8):
    # the densest case: 2^k tests of weight exactly 2^(-k); one more test of that weight would
    # make the total exceed 1
    assert (2 ** k) * Fraction(1, 2 ** k) == 1 and (2 ** k + 1) * Fraction(1, 2 ** k) > 1
print("   at most 2^k tests can have weight >= 2^(-k) when the weights sum to at most 1"
      " (2^k of them reach the total 1): checked for k = 1, 3, 8")
for K in (1, 10, 1000):
    w_f = 2.0 ** -K
    price = math.log2(1.0 / (w_f / 2))
    assert abs(price - (K + 1)) < 1e-9 and abs(price + 2 - (K + 3)) < 1e-9
print("   a test of weight w(f)/2 = 2^(-K)/2 has the price K + 1 bits, and (ii) gives K + 3;"
      " a test of weight pi/2 has log2(1/pi) + 3 in (ii)")
