"""Referee round, part property-batch: checks written by the editor of the section source.

Run:  python3 proofs/code/property-batch_referee_round.py > proofs/code/property-batch_referee_round.out
(from the project folder; about one minute; no input files; fixed seeds).

Written independently of property-batch_editor_second.py, block (S3), which nobody but its author had
read.  Everything is exact rational arithmetic (fractions.Fraction).  In particular membership in the
matching set M_N of Corollary 2.6 is decided exactly: for a test with weight pi, k of the N recorded
runs in it and probability q' under the candidate law,

    kl(k/N || q') <= ln(2/(pi*delta))/N   <=>   (k/(N q'))^k ((N-k)/(N(1-q')))^(N-k) <= 2/(pi*delta),

and both sides of the second inequality are rational numbers when q', pi and delta are.

Blocks:
 (A) Remark 5.5(a) on random small cases (a scaffold of one call: a run is one of a few outcomes).
 (B) Remark 5.5(a): the term N*q cannot be removed (an imitator that never gives what the human gives).
 (C) Remark 5.5(a), its example: a scaffold of three calls whose inputs depend on the answers, and an
     answerer that follows the human until the first call at an input of the rare kind.
 (D) Remark 5.5(b): the numbers of the example.
 (E) Remark 5.5(c) (added in the referee round): two tests that never occurred and that cover a kind of
     input.
 (F) Proposition 5.4 for the fair coin (the clause added to Section 8.2 of the note).
 (G) Proposition 6.4: the collision statistic and the bound printed in Section 8.7 of the note.
 (H) Arithmetic of the sentences added to Sections 8.3 and 8.6 of the note.
"""
import itertools
import math
import random
from fractions import Fraction as Fr


def hdr(s):
    print()
    print(s)


def compositions(n, k):
    """All vectors of k nonnegative integers with sum n."""
    if k == 1:
        yield (n,)
        return
    for first in range(n + 1):
        for rest in compositions(n - first, k - 1):
            yield (first,) + rest


def multinomial(counts):
    n = sum(counts)
    c = 1
    for k in counts:
        c *= math.comb(n, k)
        n -= k
    return c


def kl_ok(k, N, qprime, pi, delta):
    """Exact test of kl(k/N || q') <= ln(2/(pi*delta))/N."""
    if qprime == 0:
        return k == 0
    if qprime == 1:
        return k == N
    lhs = Fr(1)
    if k > 0:
        lhs *= (Fr(k, N) / qprime) ** k
    if k < N:
        lhs *= (Fr(N - k, N) / (1 - qprime)) ** (N - k)
    return lhs <= Fr(2) / (pi * delta)


def matches(law, counts, outcomes_of_tests, weights, N, delta):
    """Is `law` (a list of Fractions over the outcomes) in the matching set made from `counts`?"""
    for B, pi in zip(outcomes_of_tests, weights):
        k = sum(counts[i] for i in B)
        qprime = sum(law[i] for i in B)
        if not kl_ok(k, N, qprime, pi, delta):
            return False
    return True


def prob_sample(Q, counts):
    p = Fr(multinomial(counts))
    for q, k in zip(Q, counts):
        if k:
            if q == 0:
                return Fr(0)
            p *= q ** k
    return p


def prob_match(Q, Qprime, tests, weights, N, delta):
    """Exact probability, over N independent runs with law Q, that Qprime lies in the matching set."""
    total = Fr(0)
    for counts in compositions(N, len(Q)):
        p = prob_sample(Q, counts)
        if p and matches(Qprime, counts, tests, weights, N, delta):
            total += p
    return total


def random_law(rng, size, den):
    """A random probability vector with denominators den; zeros are allowed."""
    cuts = sorted(rng.randint(0, den) for _ in range(size - 1))
    parts = [b - a for a, b in zip([0] + cuts, cuts + [den])]
    return [Fr(p, den) for p in parts]


# ---------------------------------------------------------------------------------------------------
hdr("(A) Remark 5.5(a): Q' agrees with Q outside E, Q(E) = q.  Claim: Pr[Q' in M_N] >= 1 - delta - N q.")
print("    The proof gives the sharper bound 1 - delta - (1 - (1-q)^N); both are compared with the exact value.")
rng = random.Random(20261128)
n_cases = 0
n_positive = 0
n_proper = 0
worst_slack = None
worst_case = None
worst_proper_slack = None
worst_proper = None
violations = 0
for trial in range(6000):
    size = rng.choice([4, 5, 6])
    N = rng.choice([1, 2, 3, 4, 5, 6])
    delta = rng.choice([Fr(1, 20), Fr(1, 10), Fr(1, 5), Fr(1, 2)])
    # the event E: one or two outcomes, of small total probability under Q
    e_size = rng.choice([1, 2])
    E = list(range(e_size))
    den = rng.choice([20, 40, 100])
    qnum = rng.randint(0, max(1, den // (2 * N)))
    q = Fr(qnum, den)
    inside = [q * w for w in random_law(rng, e_size, 10)]
    outside = [(1 - q) * w for w in random_law(rng, size - e_size, 10)]
    Q = inside + outside
    inside2 = [q * w for w in random_law(rng, e_size, 10)]           # any law on E with the same mass
    Qp = inside2 + outside
    # tests: random sets of outcomes, and always the sets that isolate the deviation
    tests = [tuple(E)] + [(i,) for i in E]
    for _ in range(rng.choice([1, 2, 3])):
        B = tuple(i for i in range(size) if rng.random() < 0.5)
        if B and len(B) < size:
            tests.append(B)
    raw = [Fr(1, 2 ** rng.randint(1, 4)) for _ in tests]
    s = sum(raw)
    weights = [w / s for w in raw] if s > 1 else raw
    assert sum(weights) <= 1
    # Q' agrees with Q outside E
    assert all(Q[i] == Qp[i] for i in range(e_size, size)) and sum(Qp[:e_size]) == q
    pm = prob_match(Q, Qp, tests, weights, N, delta)
    sharp = 1 - delta - (1 - (1 - q) ** N)
    plain = 1 - delta - N * q
    assert plain <= sharp
    n_cases += 1
    if plain > 0:
        n_positive += 1
    if pm < sharp:
        violations += 1
    slack = pm - sharp
    case = (size, N, delta, q, Q, Qp, tests, weights, pm, sharp, plain)
    if worst_slack is None or slack < worst_slack:
        worst_slack = slack
        worst_case = case
    if q > 0 and Q != Qp:
        n_proper += 1
        if worst_proper_slack is None or slack < worst_proper_slack:
            worst_proper_slack = slack
            worst_proper = case
print("    %d random cases (4 to 6 outcomes, N = 1..6, delta in {1/20, 1/10, 1/5, 1/2}); the bound 1 - delta - N q is positive in %d;"
      % (n_cases, n_positive))
print("    in %d of them q > 0 and Q' differs from Q" % n_proper)
print("    cases with Pr[Q' in M_N] below the sharper bound: %d" % violations)
for label, wc in (("all cases", worst_case), ("cases with q > 0 and Q' different from Q", worst_proper)):
    size, N, delta, q, Q, Qp, tests, weights, pm, sharp, plain = wc
    print("    %s: smallest value of Pr[Q' in M_N] - (1 - delta - (1 - (1-q)^N)) found: %.6f" % (label, float(pm - sharp)))
    print("      there: N = %d, delta = %s, q = %s, Pr[Q' in M_N] = %.6f, sharper bound = %.6f, 1 - delta - N q = %.6f"
          % (N, delta, q, float(pm), float(sharp), float(plain)))
    print("      Q  = %s" % [str(x) for x in Q])
    print("      Q' = %s" % [str(x) for x in Qp])
    print("      tests = %s with weights %s" % (tests, [str(w) for w in weights]))

# The coupling of the proof, checked directly: tau'_i := tau_i outside E, a draw from Q'(.|E) inside E.
# Its law must be Q'.  (An identity; checked on the random laws above in exact arithmetic.)
ok = True
rng = random.Random(7)
for trial in range(2000):
    size = rng.choice([3, 4, 5, 6])
    e_size = rng.choice([1, 2])
    q = Fr(rng.randint(1, 9), 10)
    Q = [q * w for w in random_law(rng, e_size, 10)] + [(1 - q) * w for w in random_law(rng, size - e_size, 10)]
    Qp = [q * w for w in random_law(rng, e_size, 10)] + Q[e_size:]
    cond = [x / q for x in Qp[:e_size]]                               # Q'(. | E)
    law = [q * c for c in cond] + Q[e_size:]                          # law of tau'
    ok &= (law == Qp)
print("    the coupled run tau' has the law Q' in 2000 random cases: %s" % ok)

# ---------------------------------------------------------------------------------------------------
hdr("(B) Remark 5.5(a): the term N q is needed, and the bound is not far from the truth.")
print("    Outcomes e1, e2 in E and o1, o2 outside.  Q(e1) = q, Q(e2) = 0; Q'(e1) = 0, Q'(e2) = q; Q = Q' outside E.")
print("    Tests {e1} and {o1}.  Q' gives {e1} the probability 0, so Q' matches only if no recorded run is e1.")
for N, delta, q in ((2, Fr(1, 10), Fr(1, 40)), (5, Fr(1, 10), Fr(1, 100)), (6, Fr(1, 5), Fr(1, 20)),
                    (6, Fr(1, 20), Fr(1, 6)), (4, Fr(1, 2), Fr(1, 4))):
    Q = [q, Fr(0), (1 - q) * Fr(3, 10), (1 - q) * Fr(7, 10)]
    Qp = [Fr(0), q, (1 - q) * Fr(3, 10), (1 - q) * Fr(7, 10)]
    tests = [(0,), (2,)]
    weights = [Fr(1, 2), Fr(1, 2)]
    pm = prob_match(Q, Qp, tests, weights, N, delta)
    none_in_E = (1 - q) ** N
    print("    weights 1/2, 1/2; N = %d, delta = %-5s q = %-6s Pr[Q' in M_N] = %.6f <= (1-q)^N = %.6f;  bounds: sharper %.6f, 1 - delta - N q = %.6f;"
          "  N q = %.4f, Pr[Q' not in M_N] = %.4f"
          % (N, str(delta) + ",", str(q) + ",", float(pm), float(none_in_E), float(none_in_E - delta),
             float(1 - delta - N * q), float(N * q), float(1 - pm)))
    assert pm <= none_in_E and pm >= none_in_E - delta
print("    In each row the imitator is excluded at least as often as a run meets E: with probability at least 1 - (1-q)^N,")
print("    which is close to N q when N q is small, and 1 - e^(-c) in the limit for q = c/N.")
print("    So 'much rarer than 1/N' cannot be replaced by 'of frequency about 1/N' for every behaviour.")
# How close can Pr[Q' not in M_N] come to delta + 1 - (1-q)^N ?  A search over this family, with almost all
# the weight on the test outside E.
best = None
for N in range(1, 9):
    for delta in (Fr(1, 20), Fr(1, 10), Fr(1, 5), Fr(1, 3), Fr(1, 2)):
        for q in (Fr(1, 200), Fr(1, 100), Fr(1, 50), Fr(1, 20)):
            for pnum in range(1, 40):
                p = Fr(pnum, 40)
                Q = [q, Fr(0), (1 - q) * p, (1 - q) * (1 - p)]
                Qp = [Fr(0), q, (1 - q) * p, (1 - q) * (1 - p)]
                weights = [Fr(1, 1024), Fr(1023, 1024)]
                pm = prob_match(Q, Qp, [(0,), (2,)], weights, N, delta)
                bound_fail = delta + 1 - (1 - q) ** N
                ratio = (1 - pm) / bound_fail
                assert ratio <= 1
                if best is None or ratio > best[0]:
                    best = (ratio, N, delta, q, p, pm, bound_fail)
ratio, N, delta, q, p, pm, bound_fail = best
print("    search over 6240 members of this family (weights 1/1024 and 1023/1024, N = 1..8): the largest value of")
print("    Pr[Q' not in M_N] / (delta + 1 - (1-q)^N) is %.4f, at N = %d, delta = %s, q = %s, Q(o1 | not E) = %s:"
      % (float(ratio), N, delta, q, p))
print("    Pr[Q' not in M_N] = %.6f against delta + 1 - (1-q)^N = %.6f; never above 1." % (float(1 - pm), float(bound_fail)))

# ---------------------------------------------------------------------------------------------------
hdr("(C) The example of Remark 5.5(a) on a scaffold whose inputs depend on the answers.")
print("    z uniform on {0,1,2}.  Call 1 at input z.  Call 2 at input 5 (the rare kind) if z = 2 and the first answer")
print("    is 1, else at input 3 + (first answer).  After a call at input 5 there is a third call, at input 6 + (second answer).")
P1 = {0: Fr(1, 2), 1: Fr(1, 3), 2: Fr(1, 10), 3: Fr(1, 4), 4: Fr(2, 3), 5: Fr(1, 5), 6: Fr(1, 2), 7: Fr(3, 4)}


def second_input(z, y1):
    return 5 if (z == 2 and y1 == 1) else 3 + y1


def run_law(answer_prob):
    """answer_prob(history, x) -> probability of the answer 1; history = tuple of (input, answer) so far."""
    law = {}
    for z in (0, 1, 2):
        for y1 in (0, 1):
            h1 = ()
            p1 = answer_prob(h1, z)
            w1 = Fr(1, 3) * (p1 if y1 else 1 - p1)
            x2 = second_input(z, y1)
            for y2 in (0, 1):
                h2 = ((z, y1),)
                p2 = answer_prob(h2, x2)
                w2 = w1 * (p2 if y2 else 1 - p2)
                if x2 != 5:
                    law[(z, y1, y2)] = w2
                else:
                    x3 = 6 + y2
                    for y3 in (0, 1):
                        h3 = ((z, y1), (x2, y2))
                        p3 = answer_prob(h3, x3)
                        law[(z, y1, y2, y3)] = w2 * (p3 if y3 else 1 - p3)
    return law


def human(history, x):
    return P1[x]


def make_imitator(at_rare, after_rare):
    """Follows the human until the first call at input 5; from that call on it answers 1 with the given
    probabilities (at the call itself, and at the call after it given the answer at input 5)."""
    def answer(history, x):
        met = (x == 5) or any(inp == 5 for inp, _ in history)
        if not met:
            return P1[x]
        if x == 5:
            return at_rare
        return after_rare[history[-1][1]]
    return answer


Qh = run_law(human)
assert sum(Qh.values()) == 1
runs = sorted(Qh)
in_E = [len(r) == 4 for r in runs]                                    # a run meets input 5 iff it has three calls
qE = sum(Qh[r] for r, e in zip(runs, in_E) if e)
print("    %d complete runs; the human system meets the rare kind with probability q = %s" % (len(runs), qE))
tests_named = [
    ("the second answer is 1", lambda r: r[2] == 1),
    ("the first two answers agree", lambda r: r[1] == r[2]),
    ("the run has three calls and the last answer is 1", lambda r: len(r) == 4 and r[3] == 1),
    ("the answer at input 5 is 1", lambda r: len(r) == 4 and r[2] == 1),
    ("z = 2 and the first answer is 0", lambda r: r[0] == 2 and r[1] == 0),
]
tests = [tuple(i for i, r in enumerate(runs) if f(r)) for _, f in tests_named]
weights = [Fr(1, 4), Fr(1, 4), Fr(1, 4), Fr(1, 8), Fr(1, 8)]
Qvec = [Qh[r] for r in runs]
all_ok = True
for at_rare, after in ((Fr(1), {0: Fr(1), 1: Fr(1)}), (Fr(0), {0: Fr(0), 1: Fr(1)}), (Fr(1, 2), {0: Fr(9, 10), 1: Fr(1, 10)})):
    Qi = run_law(make_imitator(at_rare, after))
    agree = all(Qi[r] == Qh[r] for r, e in zip(runs, in_E) if not e)
    mass = sum(Qi[r] for r, e in zip(runs, in_E) if e)
    tv = sum(abs(Qi[r] - Qh[r]) for r in runs) / 2
    Qivec = [Qi[r] for r in runs]
    for N, delta in ((2, Fr(1, 10)), (3, Fr(1, 5)), (4, Fr(1, 10))):
        pm = prob_match(Qvec, Qivec, tests, weights, N, delta)
        sharp = 1 - delta - (1 - (1 - qE) ** N)
        plain = 1 - delta - N * qE
        all_ok &= agree and mass == qE and pm >= sharp
        print("    imitator: answer 1 with probability %-4s at input 5, and then with probability %s or %s (after the answer 0 or 1 there);"
              "  the laws agree outside E: %s, Q'(E) = %s, TV(Q', Q) = %.4f;  N = %d, delta = %-4s  Pr[Q' in M_N] = %.6f >= %.6f >= %.6f"
              % (at_rare, after[0], after[1], agree, mass, float(tv), N, delta, float(pm), float(sharp), float(plain)))
print("    in all nine rows: the two run laws agree outside E, Q'(E) = q, and the bound holds: %s" % all_ok)

# ---------------------------------------------------------------------------------------------------
hdr("(D) Remark 5.5(b): the numbers of the example.")
N, delta, pi = 1000, 0.05, 0.5
a = math.log(2 / (pi * delta)) / N
print("    N = 1000, delta = 0.05, pi(R) = 1/2: a_N(R) = %.5f, 1 - exp(-a_N(R)) = %.5f, tol_N(R) = sqrt(a_N(R)/2) = %.5f"
      % (a, 1 - math.exp(-a), math.sqrt(a / 2)))
print("    kl(0 || 0.02) = ln(1/0.98) = %.5f > a_N(R): an imitator that gives the test R the probability 0.02 does not match" % (-math.log(0.98)))
print("    the same comparison in exact arithmetic: 0.98^1000 = %.3e < pi delta / 2 = 1/80 = %.4f: %s"
      % (float(Fr(98, 100) ** 1000), 1 / 80, Fr(98, 100) ** 1000 < Fr(1, 80)))

# ---------------------------------------------------------------------------------------------------
hdr("(E) Remark 5.5(c): tests B1, B2 that never occurred, with E inside their union.")
print("    Claim: every matching Q' has Q'(E) <= Q'(B1) + Q'(B2) <= (1 - e^(-a(B1))) + (1 - e^(-a(B2))) < a(B1) + a(B2).")
print("    Checked exactly, as (1 - Q'(B_i))^N >= pi_i delta / 2, on the scaffold of block (C) with")
print("    B1 = 'the answer at input 5 is 0', B2 = 'the answer at input 5 is 1' (their union is E), and on random cases.")
B1 = tuple(i for i, r in enumerate(runs) if len(r) == 4 and r[2] == 0)
B2 = tuple(i for i, r in enumerate(runs) if len(r) == 4 and r[2] == 1)
E_idx = tuple(i for i, e in enumerate(in_E) if e)
assert set(B1) | set(B2) == set(E_idx)
rng = random.Random(11)
checked = 0
held = True
largest = Fr(0)
for trial in range(400):
    N = rng.choice([1, 2, 3, 4, 6, 10, 20])
    delta = rng.choice([Fr(1, 20), Fr(1, 10), Fr(1, 2)])
    w1, w2 = rng.choice([(Fr(1, 2), Fr(1, 2)), (Fr(1, 4), Fr(1, 8)), (Fr(1, 16), Fr(1, 2))])
    # a random candidate law on the runs of the scaffold
    cand = random_law(rng, len(runs), 200)
    counts = [0] * len(runs)                                           # a sample in which neither test occurred:
    outside = [i for i in range(len(runs)) if i not in E_idx]          # no recorded run lies in E
    for _ in range(N):
        counts[rng.choice(outside)] += 1
    if matches(cand, counts, [B1, B2], [w1, w2], N, delta):
        checked += 1
        q1 = sum(cand[i] for i in B1)
        q2 = sum(cand[i] for i in B2)
        qEc = sum(cand[i] for i in E_idx)
        a1 = math.log(2 / float(w1 * delta)) / N
        a2 = math.log(2 / float(w2 * delta)) / N
        held &= ((1 - q1) ** N >= w1 * delta / 2) and ((1 - q2) ** N >= w2 * delta / 2) and qEc <= q1 + q2
        held &= float(qEc) < a1 + a2
        largest = max(largest, Fr(qEc) / Fr(a1 + a2))
print("    %d random matching candidates on that scaffold: Q'(E) < a(B1) + a(B2) in all: %s; largest ratio Q'(E)/(a(B1)+a(B2)) = %.4f"
      % (checked, held, float(largest)))
# the largest probability of E that matching allows, against the bound
for N, delta, w1, w2 in ((100, Fr(1, 20), Fr(1, 2), Fr(1, 2)), (1000, Fr(1, 20), Fr(1, 4), Fr(1, 4)), (3835, Fr(1, 20), Fr(1, 2 ** 20), Fr(1, 2 ** 20))):
    a1 = math.log(2 / float(w1 * delta)) / N
    a2 = math.log(2 / float(w2 * delta)) / N
    print("    N = %4d, delta = 1/20, weights %s and %s: a(B1) + a(B2) = %.5f; largest Q'(B1) + Q'(B2) of a matching law = %.5f"
          % (N, w1, w2, a1 + a2, (1 - math.exp(-a1)) + (1 - math.exp(-a2))))

# ---------------------------------------------------------------------------------------------------
hdr("(F) Proposition 5.4 for the fair coin: one call at a uniform input among u, the human a uniformly random function.")
print("    Claim printed in Section 8.2: the coin is matching with probability at least 1 - delta - N^2/(2u)")
print("    (Proposition 5.4 has 1 - delta - C(N,2)/u).  Exact, over all 2^u functions and all u^N samples of inputs.")


def coin_matching_probability(u, N, delta, tests, weights):
    coin_freq = [sum(Fr(1, 2 * u) for (x, y) in B) for B in tests]     # each pair (x, y) has probability 1/(2u)
    good = 0
    total = 0
    for f in itertools.product((0, 1), repeat=u):
        for xs in itertools.product(range(u), repeat=N):
            total += 1
            ok = True
            for B, pi, cq in zip(tests, weights, coin_freq):
                k = sum(1 for x in xs if (x, f[x]) in B)
                if not kl_ok(k, N, cq, pi, delta):
                    ok = False
                    break
            good += ok
    return Fr(good, total)


for u, N, delta in ((6, 2, Fr(1, 10)), (6, 3, Fr(1, 5)), (8, 2, Fr(1, 20)), (8, 3, Fr(1, 10))):
    tests = [frozenset((x, 1) for x in range(u)),                                  # the answer is 1
             frozenset((x, y) for x in range(u) for y in (0, 1) if x % 2 == y),    # the answer is the parity of the input
             frozenset((x, 0) for x in range(u // 2)),                             # a small input answered 0
             frozenset((0, y) for y in (0, 1))]                                    # the input is 0
    weights = [Fr(1, 4)] * 4
    pr = coin_matching_probability(u, N, delta, tests, weights)
    b54 = 1 - delta - Fr(math.comb(N, 2), u)
    bnote = 1 - delta - Fr(N * N, 2 * u)
    print("    u = %d, N = %d, delta = %-4s  Pr[the coin is matching] = %.6f >= 1 - delta - C(N,2)/u = %.6f >= 1 - delta - N^2/(2u) = %.6f: %s"
          % (u, N, delta, float(pr), float(b54), float(bnote), pr >= b54 >= bnote))

# ---------------------------------------------------------------------------------------------------
hdr("(G) Proposition 6.4: the collision statistic c = 1[y1 = y2] - A(y1|x) - A(y2|x) + sum_y A(y|x)^2.")
rng = random.Random(3)
ok_mean = True
ok_range = True
ok_beta = True
worst = Fr(0)
for trial in range(3000):
    qn = rng.choice([2, 3, 4, 5])
    P = random_law(rng, qn, 12)
    A = random_law(rng, qn, 12)
    sumA2 = sum(a * a for a in A)
    mean = Fr(0)
    for y1 in range(qn):
        for y2 in range(qn):
            c = (1 if y1 == y2 else 0) - A[y1] - A[y2] + sumA2
            ok_range &= (Fr(-1, 2) <= c <= 2)
            mean += P[y1] * P[y2] * c
    d2 = sum((p - a) ** 2 for p, a in zip(P, A))
    ok_mean &= (mean == d2)
    tv = sum(abs(p - a) for p, a in zip(P, A)) / 2
    ok_beta &= (4 * tv * tv <= qn * d2)                                # TV <= (sqrt(q)/2) d, squared
    if d2 > 0:
        worst = max(worst, 4 * tv * tv / (qn * d2))
print("    3000 random pairs of laws on q = 2..5 answers: E[c | x] = sum_y (P - A)^2 exactly: %s; -1/2 <= c <= 2: %s;"
      % (ok_mean, ok_range))
print("    TV(P, A) <= (sqrt(q)/2) sqrt(sum_y (P - A)^2): %s (largest ratio of the squares %.4f)" % (ok_beta, float(worst)))
print("    so with D the mean of sum_y (P - A)^2 over a uniformly chosen position of a run of A (zero at positions the run")
print("    does not reach): beta(A) <= (L/2) sqrt(q D) by the Cauchy-Schwarz inequality, as Proposition 6.4(c) says.")
for m, delta in ((10 ** 4, 0.05), (10 ** 6, 0.05), (10 ** 8, 0.05)):
    slack = 2.5 * math.sqrt(math.log(1 / delta) / (2 * m))
    for qn in (2, 10):
        print("    m = %.0e rounds, delta = %.2f, q = %2d: with average statistic 0 the certificate reads beta(A)/L <= (1/2) sqrt(q * %.5f) = %.4f"
              % (m, delta, qn, slack, 0.5 * math.sqrt(qn * slack)))

# ---------------------------------------------------------------------------------------------------
hdr("(H) Arithmetic of sentences added to the note.")
K = 1e9
print("    Section 8.3: sqrt((2 K ln 2 + 2 ln(2/delta))/N) < 1 needs N > 2 K ln 2 + 2 ln(2/delta); for K = 1e9 bits: 2 K ln 2 = %.3e runs" % (2 * K * math.log(2)))
print("    Section 8.3: if TV(Q_nu, Q) >= 1/3 the right side of Pr4 is at least 1 for that nu, whatever N is: 3 * (1/3) = 1")
print("    Section 8.3: r(nu) = sqrt((K_nu ln 2 + ln(2/delta))/(2N)) = sqrt(a/2) with a = (ln(1/w(nu)) + ln(2/delta))/N: the error of Pr3 for a test of weight w(nu)")
for u, K in ((5, 2), (5, 20), (8, 30), (1024, 200)):
    beta = math.log2(4 * u + 2)
    nmax = min(u // 4, int((K - 2) // beta))
    vals = []
    for n in range(0, nmax + 1):
        v = Fr(u - n, u) * Fr(2 * u, 2 * u + 1) / (1 + Fr((4 * u + 2) ** n, 2 ** K - 1))
        vals.append(float(v))
    print("    Section 8.6, Pr2(b): u = %4d, K = %3d: n <= min{u/4, (K-2)/log2(4u+2)} = %d; least value of the formula for these n: %.4f (> 0.51: %s)"
          % (u, K, nmax, min(vals), min(vals) > 0.51))
print("    Section 8.6, Pr2(b): closing the class as in Corollary 4.6 with weights (C_R - 1) : 1 multiplies the value by (C_R - 1)/C_R = 1 - 1/C_R")
print("    Section 8.6, Pr2(c): (3/4)(16/17)(10/11)(4/5) = %.5f > 0.51" % (0.75 * 16 / 17 * 10 / 11 * 0.8))
