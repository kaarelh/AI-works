"""Referee round of the editor of the part lower-bounds (28 November 2026).

Tests of the sentences that the referee round put into Section 4 of the note and into the block of
Section 6.1 (research/sections/lower-bounds.md): the statements in the order "result, then the class
and the scaffold", the ranges that were added, the description of Protocol AB, the scaffold of N5
with its cut-off, and the remark on other weights in "What S2 needs".

The script imports no other script of the project and needs only the standard library.  Rational
arithmetic (fractions) is used wherever a part says "exact"; the other parts are finite computations
in floating point with the margins printed.  Every part stops at the first failed assertion.  The run
takes about half a minute; the time is printed on standard error, so that the saved output does not
depend on it.

Usage:  python3 lower-bounds_referee_round.py > lower-bounds_referee_round.out

Letters as in the note: L calls, delta failure probability, N cells, d blocks, k tolerated faults,
g regions drawn, a advantage, ell bits.  The threshold of Protocol AB, which the note writes eta, is
gam here, as in Theorem 3.3 of the proof file.

(A) N2: the two bounds from n >= N - delta (N + L)/p, the converse with a random half of the cells
    (fewer than L/(4 delta) + 1 questions), the bound on K, the Bayes risk of the remark, and
    "at least L for delta <= 1/10" (exact);
(B) N2a: N p - delta (N + L) >= L (1 - sqrt(2 delta) - delta) - delta with N = ceil(L/sqrt(2 delta));
(C) N2b: the bound from Theorem 3.1, the identity in bits, and the protocol that searches half of
    the blocks (exact);
(D) N2c: the arithmetic of the threshold and of n_B, and Protocol AB as the note words it, with the
    law of its whole execution computed exactly on random small classes and scaffolds, and on a second
    family in which runs of the vote meet inputs that no run answered by a member meets;
(E) the rare-points class: the chain of inequalities, the least number of random questions for the
    best deployed system (exact law), "about a seventh", and the threshold 2^27;
(F) rehearsal on the classes of N2b: 4 d N = 2 d L/delta and the factor 16/(1 - 10 delta);
(G) N5: the identity for the bound, and the scaffold as the note words it, by brute force over all
    rules with at most k replacements (answers 0, 1 or declined);
(H) N6: the ranges of b, the two comparisons with R2, and the ratios of the constants;
(I) N2d: (a), (b), (c), the condition F < 1/4 - delta, and the numbers for a person;
(J) N3: ceil(2 a N) <= N, and the protocol with n questions, exactly, for N <= 6;
(K) S2: domination by a mixture on random instances (exact); the weights 2^(-2 ell - 1); Remark 4.4a:
    the length drawn with probability 4/((ell + 1)(ell + 2)(ell + 3)), the procedure that draws it,
    its mean, and the two factors.
"""
import itertools
import math
import random
import sys
import time
from fractions import Fraction as Fr

T0 = time.time()
random.seed(20261128)


def ceil_frac(x):
    return -((-x.numerator) // x.denominator)


def p_meet(L, N):
    """Probability that a run of L uniform cells among N meets a given cell (exact)."""
    return 1 - (1 - Fr(1, N)) ** L


# ------------------------------------------------------------------------------------------- (A)
print("(A) N2")
deltas = [Fr(1, q) for q in (6, 7, 8, 10, 12, 16, 20, 25, 40, 50, 64, 100, 128, 250, 1000)]
deltas += [Fr(3, 20), Fr(2, 13), Fr(1, 9), Fr(7, 100), Fr(3, 200)]
n_cases = n_int = 0
worst_gap = None
for L in list(range(1, 41)) + [50, 64, 100, 128, 250]:
    for dl in deltas:
        assert dl <= Fr(1, 6)
        x = Fr(L) / (2 * dl)
        N = ceil_frac(x)
        p = p_meet(L, N)
        lower = N - dl * (N + L) / p              # n >= N - delta (N + L)/p
        b1 = Fr(L) / (4 * dl) - Fr(3 * L, 2)
        assert lower >= b1, (L, dl)
        gap = lower - b1
        worst_gap = gap if worst_gap is None else min(worst_gap, gap)
        if x.denominator == 1:
            assert lower >= Fr(L) / (4 * dl) - L, (L, dl)
            n_int += 1
        # converse: ask ceil(N/2) random cells, deploy the member seen, else f0
        half = (N + 1) // 2
        fail = (1 - Fr(half, N)) * p
        assert fail <= p / 2 <= dl, (L, dl)
        assert half < Fr(L) / (4 * dl) + 1          # "fewer than L/(4 delta) + 1 questions suffice"
        # with equal weights K = log2(N + 1) <= log2(L/(2 delta) + 2)
        assert N + 1 <= x + 2
        # Bayes risk of "ask nothing, deploy f0" when the f_i have total weight eta < 1/2: eta p
        assert Fr(499, 1000) * p < dl
        # under each f_i that protocol fails with probability p, which is above delta for N >= 2
        if N >= 2 and x.denominator == 1:
            assert p > dl
        n_cases += 1
print(f"   {n_cases} pairs (L, delta) with delta <= 1/6: n >= L/(4 delta) - 3L/2 follows; least slack {float(worst_gap):.4f}")
print(f"   {n_int} of them with L/(2 delta) an integer: n >= L/(4 delta) - L follows")
print("   converse: ceil(N/2) < L/(4 delta) + 1 random cells give failure <= p/2 <= delta in every case")
print("   K <= log2(L/(2 delta) + 2); Bayes risk of deploying f0 unasked below delta for weight < 1/2")
# L/(4 delta) - 3L/2 >= L exactly when delta <= 1/10
for q in range(6, 200):
    dl = Fr(1, q)
    assert (Fr(1) / (4 * dl) - Fr(3, 2) >= 1) == (dl <= Fr(1, 10))
print("   L/(4 delta) - 3L/2 >= L exactly when delta <= 1/10")

# ------------------------------------------------------------------------------------------- (B)
print("(B) N2a")
n_cases = 0
least = None
for L in list(range(1, 41)) + [64, 100, 250]:
    for q in (2, 3, 4, 6, 8, 10, 16, 20, 50, 100, 400, 1000, 10000):
        dl = 1.0 / q
        N = math.ceil(L / math.sqrt(2 * dl) - 1e-12)
        p = 1 - (1 - 1 / N) ** L
        lhs = N * p - dl * (N + L)
        rhs = L * (1 - math.sqrt(2 * dl) - dl) - dl
        assert lhs >= rhs - 1e-9, (L, q, lhs, rhs)
        least = lhs - rhs if least is None else min(least, lhs - rhs)
        n_cases += 1
print(f"   {n_cases} pairs: N p - delta (N + L) >= L (1 - sqrt(2 delta) - delta) - delta; least slack {least:.4f}")
print(f"   the bound as a fraction of L: {1 - math.sqrt(2/100) - 1/100:.3f} at delta = 1/100, "
      f"{1 - math.sqrt(2/10000) - 1/10000:.3f} at delta = 1/10000")

# ------------------------------------------------------------------------------------------- (C)
print("(C) N2b")
n_cases = 0
for L in range(1, 41):
    for q in (20, 25, 40, 50, 100, 200, 1000):
        dl = Fr(1, q)
        x = Fr(L) / (2 * dl)
        if x.denominator != 1:
            continue
        N = int(x)
        p = p_meet(L, N)
        # Theorem 3.1 with d = 1: n >= (N/2)(1 - 2L/N - delta/p)
        lower = Fr(N, 2) * (1 - Fr(2 * L, N) - dl / p)
        assert lower >= (1 - 10 * dl) * L / (8 * dl), (L, dl)
        # searching a block: cells 1, ..., N - 1 in turn until an answer is 1
        mean = Fr(sum(min(c, N - 1) for c in range(1, N + 1)), N)
        assert mean == Fr((N - 1) * (N + 2), 2 * N) <= Fr(N + 1, 2) == Fr(L) / (4 * dl) + Fr(1, 2)
        for d in (1, 2, 3, 7, 16):
            chosen = (d + 1) // 2
            assert (1 - Fr(chosen, d)) * p <= p / 2 <= dl
            # identity in bits: d L/(8 delta) = K L/(8 delta log2(L/(2 delta))) with K = d log2 N
            K = d * math.log2(N)
            assert abs(d * L / (8 * float(dl)) - K * L / (8 * float(dl) * math.log2(L / (2 * float(dl))))) < 1e-6
        n_cases += 1
print(f"   {n_cases} pairs with N = L/(2 delta) an integer, delta <= 1/20: the bound (1 - 10 delta) d L/(8 delta) follows")
print("   half of the blocks searched completely: failure <= delta, expected questions per block <= L/(4 delta) + 1/2")

# ------------------------------------------------------------------------------------------- (D)
print("(D) N2c")
n_cases = 0
worst = 0.0
for u10 in range(40, 400, 3):                       # u = log2(L/delta) from 4 to 40
    u = u10 / 10
    for L in (1, 2, 5, 16, 100, 1000):
        dl = L / 2 ** u
        if dl >= 1:
            continue
        gam = dl * math.log2(L / dl) / L
        assert 0 < gam <= 0.25 + 1e-12
        for K in (0, 0.3, 1, 3.78, 10, 112, 1e4, 1e9):
            nB = max(1, math.ceil(L * K / (dl * math.log2(1 / gam))))
            questions = nB + K * math.log(2) / gam
            bound = 1 + 2.7 * K * L / (dl * math.log2(L / dl))
            assert questions <= bound * (1 + 1e-12), (u, L, K)
            assert L * K / (nB * math.log2(1 / gam)) <= dl * (1 + 1e-12)
            if K > 0:
                worst = max(worst, (questions - 1) / (bound - 1))
            n_cases += 1
print(f"   {n_cases} triples (L, delta, K) with L/delta >= 16: gamma <= 1/4, at most 1 + 2.7 K L/(delta log2(L/delta)) questions,")
print(f"   failure bound L K/(n_B log2(1/gamma)) <= delta; largest ratio of the count to the bound {worst:.4f}")


def ab_exact(m_inputs, members, weights, f_idx, zs, nxt, L, gam, nB):
    """Protocol AB as the note words it, with X0 = the inputs that occur in a run answered by a member.
    Returns (failure probability of the deployed run, largest value over all paths of
    a ln(1/(1-gam)) + b ln(1/gam), with b counted at inputs of X0, K ln 2)."""
    f = members[f_idx]

    def run(h, z):
        ys = []
        xs = []
        for _ in range(L):
            x = nxt(z, tuple(ys))
            if x is None:
                break
            xs.append(x)
            ys.append(h[x])
        return xs, ys

    X1 = set()
    for g_ in members:
        for z in zs:
            X1.update(run(g_, z)[0])
    X1 = sorted(X1)
    human_runs = {z: run(f, z) for z in zs}
    assert sum(weights) == 1
    lnK = math.log(1 / weights[f_idx])                # K ln 2
    worst_path = [0.0]
    worst_all = [0.0]                                 # the same sum with b counting all disagreements
    left = [0]                                        # steps (B) whose run has an input outside X1

    def post(V):
        W = sum(weights[i] for i in V)
        out = []
        for x in range(m_inputs):
            w1 = sum(weights[i] for i in V if members[i][x] == 1)
            out.append((Fr(W - w1, W), Fr(w1, W)))
        return out

    def step(V, done, hs, a, b, b_all=0):
        """Returns the probability that the deployed run is unfaithful, from this state on."""
        if done == nB:
            worst_path[0] = max(worst_path[0], a * math.log(1 / (1 - float(gam))) + b * math.log(1 / float(gam)))
            worst_all[0] = max(worst_all[0], a * math.log(1 / (1 - float(gam))) + b_all * math.log(1 / float(gam)))
            tot = Fr(0)
            for h in hs:                              # the vote of a uniformly chosen step (B)
                for z in zs:
                    if run(h, z) != human_runs[z]:
                        tot += Fr(1, len(hs) * len(zs))
            return tot
        pst = post(V)
        for x in X1:                                  # (A): a split input, the first in a fixed order
            if max(pst[x]) <= 1 - gam:                # gam is a fraction here: the comparison is exact
                V2 = frozenset(i for i in V if members[i][x] == f[x])
                return step(V2, done, hs, a + 1, b, b_all)
        h = tuple(0 if pst[x][0] >= pst[x][1] else 1 for x in range(m_inputs))   # the vote
        tot = Fr(0)
        for z in zs:                                  # (B): a run of the vote, one call audited
            xs, _ = run(h, z)
            if any(x not in X1 for x in xs):
                left[0] += 1
            for J in range(1, L + 1):
                pr = Fr(1, len(zs) * L)
                if J <= len(xs):
                    x = xs[J - 1]
                    V2 = frozenset(i for i in V if members[i][x] == f[x])
                    b2 = b + (1 if (x in X1 and h[x] != f[x]) else 0)
                    ball2 = b_all + (1 if h[x] != f[x] else 0)
                    tot += pr * step(V2, done + 1, hs + (h,), a, b2, ball2)
                else:
                    tot += pr * step(V, done + 1, hs + (h,), a, b, b_all)
        return tot

    fail = step(frozenset(range(len(members))), 0, (), 0, 0)
    return fail, worst_path[0], lnK, left[0], worst_all[0]


n_inst = 0
worst_ratio = 0.0
left_X1 = 0
for trial in range(60):
    m_inputs = random.choice((4, 5, 6))
    L = random.choice((2, 3))
    n_mem = random.choice((3, 4, 5, 6))
    mem = set()
    while len(mem) < n_mem:
        mem.add(tuple(random.randint(0, 1) for _ in range(m_inputs)))
    members = sorted(mem)
    raw = [random.randint(1, 6) for _ in members]
    weights = [Fr(r, sum(raw)) for r in raw]
    zs = (0, 1, 2)
    table = {}

    def nxt(z, ys, table=table, m_inputs=m_inputs):
        key = (z, ys)
        if key not in table:
            table[key] = None if (ys and random.random() < 0.15) else random.randrange(m_inputs)
        return table[key]

    # fill the table for every history, so that the scaffold is one fixed function
    for z in zs:
        for r in range(L):
            for ys in itertools.product((0, 1), repeat=r):
                nxt(z, ys)
    for gam in (Fr(1, 10), Fr(1, 4), Fr(2, 5)):
        for nB in (1, 2, 3):
            for f_idx in range(len(members)):
                fail, wp, lnK, left, _ = ab_exact(m_inputs, members, weights, f_idx, zs, nxt, L, gam, nB)
                left_X1 += 1 if left else 0
                assert wp <= lnK + 1e-9, (trial, gam, nB, f_idx, wp, lnK)
                bound = L * (lnK / math.log(2)) / (nB * math.log2(1 / float(gam)))
                assert float(fail) <= bound + 1e-12, (trial, gam, nB, f_idx)
                if bound < 1:
                    worst_ratio = max(worst_ratio, float(fail) / bound)
                n_inst += 1
print(f"   Protocol AB as worded in the note, exact law of the execution in {n_inst} cases (60 random classes and")
print("   scaffolds whose questions depend on the answers; gamma = 1/10, 1/4, 2/5; n_B = 1, 2, 3; every member as the human):")
print("   a ln(1/(1-gamma)) + b ln(1/gamma) <= K ln 2 on every path; Pr[deployed run unfaithful] <= L K/(n_B log2(1/gamma));")
print(f"   where that bound is below 1 the failure reaches {worst_ratio:.2f} of it; in {left_X1} cases a run of the vote meets")
print("   an input that occurs in no run answered by a member")

# A second family, built after the example for Theorem 3.3(5) of the proof file: the scaffold asks the inputs
# 0, 1, ..., m-2 in an order that depends on z, stops at the first answer 1, and asks the input m-1 last if all
# answers were 0.  Member i is 1 at input i, so its run stops there and no run of a member reaches m-1; the
# vote, which answers 0 while the weights are spread, runs on to m-1.
n_inst2 = 0
left2 = 0
would_fail = 0
worst_ratio2 = 0.0
below2 = 0
largest_fail2 = 0.0
for trial in range(40):
    m_inputs = random.choice((4, 5, 6))
    L = m_inputs
    members = []
    for i in range(m_inputs - 1):
        g_ = [0] * m_inputs
        g_[i] = 1
        g_[m_inputs - 1] = random.randint(0, 1)
        for j in range(i + 1, m_inputs - 1):
            g_[j] = random.randint(0, 1) if random.random() < 0.3 else 0
        members.append(tuple(g_))
    members = sorted(set(members))
    raw = [random.randint(1, 4) for _ in members]
    weights = [Fr(r, sum(raw)) for r in raw]
    orders = [tuple(range(m_inputs - 1))]
    for _ in range(random.choice((0, 1, 2))):
        o = list(range(m_inputs - 1))
        random.shuffle(o)
        orders.append(tuple(o))
    zs = tuple(range(len(orders)))

    def nxt2(z, ys, orders=orders, m_inputs=m_inputs):
        if any(ys):
            return None
        if len(ys) < m_inputs - 1:
            return orders[z][len(ys)]
        if len(ys) == m_inputs - 1:
            return m_inputs - 1
        return None

    for gam in (Fr(1, 8), Fr(1, 4), Fr(2, 5)):
        for nB in (1, 2, 3):
            for f_idx in range(len(members)):
                fail, wp, lnK, left, wall = ab_exact(m_inputs, members, weights, f_idx, zs, nxt2, L, gam, nB)
                assert wp <= lnK + 1e-9, (trial, gam, nB, f_idx, wp, lnK)
                bound = L * (lnK / math.log(2)) / (nB * math.log2(1 / float(gam)))
                assert float(fail) <= bound + 1e-12, (trial, gam, nB, f_idx)
                if bound < 1:
                    below2 += 1
                    worst_ratio2 = max(worst_ratio2, float(fail) / bound)
                largest_fail2 = max(largest_fail2, float(fail))
                left2 += 1 if left else 0
                would_fail += 1 if wall > lnK + 1e-9 else 0
                n_inst2 += 1
print(f"   second family, after the example for Theorem 3.3(5): {n_inst2} cases; in {left2} of them a run of the vote meets an input")
print("   that occurs in no run answered by a member; both inequalities hold in every case, with b counted at the inputs")
print(f"   that occur in a run answered by a member; counting all disagreements would break the first one in {would_fail} cases;")
assert worst_ratio2 == 0.0
print(f"   the bound on the failure is below 1 in {below2} cases, and the failure is 0 in each of them; the largest")
print(f"   failure in this family is {largest_fail2:.3f}, where the bound is above 1 (this family tests the first inequality)")

# ------------------------------------------------------------------------------------------- (E)
print("(E) the rare-points class")
n_cases = 0
for q in (8, 9, 10, 16, 32, 100, 1000):
    dl = 1 / q
    for L in (1, 2, 4, 16, 100):
        for K in (1, 2, 8, 32, 1000):
            lhs = math.log(2 * (1 - 2 * dl)) * (L * K / (4 * dl) - 1)
            assert lhs >= 0.1 * K * L / dl - 0.4 - 1e-9
            n_cases += 1
print(f"   {n_cases} triples with delta <= 1/8: ln(2(1 - 2 delta)) (L K/(4 delta) - 1) >= 0.1 K L/delta - 0.4")


def rare_least_n(d, L, dl, n_max=100000):
    """Least n such that the best deployed system after n independent questions drawn from the law of a
    call has average failure <= dl over the 2^d members (exact law of the number of unasked points)."""
    qd = 4 * dl / (L * d)                 # probability that one call is at a given rare point
    # E[1 - 2^(-V) | u unasked points], V = number of distinct unasked points met by the L calls
    fail_given_u = []
    for u in range(d + 1):
        dist = [0.0] * (u + 1)
        dist[0] = 1.0
        for _ in range(L):
            new = [0.0] * (u + 1)
            for v, pr in enumerate(dist):
                if pr == 0.0:
                    continue
                stay = 1 - (u - v) * qd
                new[v] += pr * stay
                if v < u:
                    new[v + 1] += pr * (u - v) * qd
            dist = new
        fail_given_u.append(sum(pr * (1 - 2.0 ** (-v)) for v, pr in enumerate(dist)))
    # number of asked rare points after n draws: Markov chain on 0..d
    asked = [0.0] * (d + 1)
    asked[0] = 1.0
    for n in range(n_max + 1):
        fail = sum(asked[j] * fail_given_u[d - j] for j in range(d + 1))
        lower = 2 * dl * (1 - 2 * dl) * (1 - qd) ** n
        assert fail >= lower - 1e-12, (d, L, dl, n)
        if fail <= dl:
            return n
        new = [0.0] * (d + 1)
        for j, pr in enumerate(asked):
            if pr == 0.0:
                continue
            new[j] += pr * (1 - (d - j) * qd)
            if j < d:
                new[j + 1] += pr * (d - j) * qd
        asked = new
    raise RuntimeError("n_max too small")


for (d, L, q) in ((4, 2, 8), (8, 4, 8), (8, 4, 16), (16, 4, 8), (32, 16, 32), (20, 10, 8)):
    dl = 1 / q
    n_star = rare_least_n(d, L, dl)
    lb = 0.1 * d * L / dl - 0.4
    r1 = math.ceil(L * d * math.log(2) / dl)
    assert lb <= n_star <= r1
    print(f"   K = {d:2d}, L = {L:2d}, delta = 1/{q}: least n for the best deployed system {n_star:5d}; "
          f"bound 0.1 K L/delta - 0.4 = {lb:7.1f}; R1 suffices with {r1:5d}; n/(K L/delta) = {n_star / (d * L / dl):.3f}")
print(f"   0.1/ln 2 = {0.1 / math.log(2):.4f} (a seventh is {1 / 7:.4f})")
# the bound exceeds 1 + 2.7 x/u (N2c) for some x = K L/delta only if u = log2(L/delta) > 27
for u10 in range(40, 271):
    u = u10 / 10
    slope = 0.1 - 2.7 / u
    assert slope <= 1e-12                 # then 0.1 x - 0.4 < 1 + 2.7 x/u for every x > 0
assert 0.1 - 2.7 / 27.01 > 0
print("   0.1 x - 0.4 > 1 + 2.7 x/u is impossible for u = log2(L/delta) <= 27 and possible for large x when u > 27")

# ------------------------------------------------------------------------------------------- (F)
print("(F) rehearsal on the classes of N2b")
for q in (20, 40, 100):
    dl = Fr(1, q)
    for L in (1, 4, 10):
        x = Fr(L) / (2 * dl)
        if x.denominator != 1:
            continue
        N = int(x)
        for d in (1, 5, 16):
            assert 4 * d * N == 2 * d * L / dl
            assert Fr(4 * d * N) / ((1 - 10 * dl) * d * L / (8 * dl)) == 16 / (1 - 10 * dl)
print("   4 d N = 2 d L/delta, and its ratio to (1 - 10 delta) d L/(8 delta) is 16/(1 - 10 delta) (exact)")

# ------------------------------------------------------------------------------------------- (G)
print("(G) N5")
for k in range(0, 6):
    for g in range(1, 8):
        for q in (5, 8, 20, 100):
            dl = Fr(1, q)
            L = g * (k + 1) + k
            assert Fr(g) / (4 * dl) - g == (1 - 4 * dl) * (L - k) / (4 * (k + 1) * dl)
print("   g/(4 delta) - g = (1 - 4 delta)(L - k)/(4 (k + 1) delta) with L = g (k + 1) + k (exact)")


def seq_outcomes(k, g, value_of_region, regions, budget):
    """All outcomes of the scaffold of N5, as the note words it, under every rule that replaces at most
    `budget` answers by 0, 1 or 'declined' (None).  Returns the set of (outcome, number of calls)."""
    L = g * (k + 1) + k
    results = set()

    def go(b_idx, calls, used, best):
        if b_idx == g:
            results.add((best, calls))
            return
        v = value_of_region[regions[b_idx]]

        def block(pos, c0, c1, calls, used):
            # pos = number of inputs of this region asked so far
            if c0 == k + 1 or c1 == k + 1:
                val = 1 if c1 == k + 1 else 0
                go(b_idx + 1, calls, used, max(best, val))
                return
            if calls == L or pos == 2 * k + 1:
                results.add((0, calls))                  # cut off: the outcome is 0
                return
            options = [v]
            if used < budget:
                options += [a for a in (0, 1, None) if a != v]
            for a in options:
                u2 = used + (1 if a != v else 0)
                block(pos + 1, c0 + (a == 0), c1 + (a == 1), calls + 1, u2)

        block(0, 0, 0, calls, used)

    go(0, 0, 0, 0)
    return results


n_cases = 0
for (k, g, N) in ((0, 1, 2), (0, 3, 3), (1, 1, 2), (1, 2, 3), (1, 3, 2), (2, 1, 2), (2, 2, 2), (2, 2, 3), (3, 1, 2), (3, 2, 2)):
    L = g * (k + 1) + k
    for member in range(N + 1):                          # 0 is f0; i >= 1 is the function that is 1 on region i
        value = {r: (1 if r == member else 0) for r in range(1, N + 1)}
        for regions in itertools.product(range(1, N + 1), repeat=g):
            truth = max(value[r] for r in regions)
            clean = seq_outcomes(k, g, value, regions, 0)
            assert clean == {(truth, g * (k + 1))}
            res = seq_outcomes(k, g, value, regions, k)
            assert all(o == truth and c <= L for (o, c) in res), (k, g, N, member, regions)
            n_cases += 1
    # k + 1 replacements can change the outcome
    value = {r: 0 for r in range(1, N + 1)}
    res = seq_outcomes(k, g, value, tuple([1] * g), k + 1)
    assert any(o == 1 for (o, c) in res)
print(f"   the scaffold as worded in the note, {n_cases} triples (member, regions drawn) in ten cases (k, g, N) with k <= 3:")
print("   every rule with at most k replacements leaves the outcome unchanged and the run within L calls;")
print("   the human system itself makes g (k + 1) calls; k + 1 replacements can change the outcome")

# ------------------------------------------------------------------------------------------- (H)
print("(H) N6")
assert 4 * Fr(1, 16) == Fr(1, 4)
for Lr in (1, 2, 16, 100, 4096):
    b = 16 * (1 / 64) / math.sqrt(Lr)
    assert b <= 0.25 and 2 * Lr * b * b <= 0.5 + 1e-12
for eps in (1 / 64, 1 / 100, 1e-3):
    for K in (1, 10, 1e9):
        n1 = K * math.log(2) / (2 * eps ** 2)
        assert abs(math.sqrt(K * math.log(2) / (2 * n1)) - eps) < 1e-12
        for Lr in (1, 16, 1000):
            n2 = (1 + eps) * Lr * K * math.log(2) / eps ** 2
            s = Lr * K * math.log(2) / (2 * n2)
            assert abs(s + math.sqrt(s * s + 2 * s) - eps) < 1e-12
print("   b = 4 eps <= 1/4 for eps <= 1/16; b = 16 eps/sqrt(L) <= 1/4 and 2 L b^2 = 512 eps^2 <= 1/2 for eps <= 1/64")
print("   sqrt(K ln 2/(2n)) = eps at n = K ln 2/(2 eps^2); s + sqrt(s^2 + 2s) = eps at n = (1 + eps) L K ln 2/eps^2")
print(f"   ratios of the constants: 512 ln 2/2 = {512 * math.log(2) / 2:.1f}; 8192 ln 2 = {8192 * math.log(2):.0f}")

# ------------------------------------------------------------------------------------------- (I)
print("(I) N2d")
n_cases = 0
for q in (5, 6, 8, 20, 50, 100, 1000):
    dl = Fr(1, q)
    for L in (1, 2, 5, 10, 1000):
        if (Fr(L) / (2 * dl)).denominator != 1:
            continue
        for r in (1, 3, 10, 1000):
            Fb = r * dl
            n_low = Fr(L) / (4 * dl) - L               # (a): n >= L/(4 delta) - L, delta < 1/4
            assert n_low > 0
            assert Fr(r * L) / n_low == 4 * Fb / (1 - 4 * dl)
            assert (4 * Fb / (1 - 4 * dl) < 1) == (Fb < Fr(1, 4) - dl)
            if dl <= Fr(1, 20):
                for d in (1, 4, 30):
                    n_low_b = (1 - 10 * dl) * d * L / (8 * dl)
                    K = d * math.log2(L / (2 * float(dl)))
                    amp = float(Fr(r * L) / n_low_b)
                    assert abs(amp - 8 * float(Fb) * math.log2(L / (2 * float(dl))) / ((1 - 10 * float(dl)) * K)) < 1e-9 * max(1, amp)
            for K in (0.5, 1, 3.78, 30, 1e3, 1e9):
                for kk in (0, 1, 9):
                    n_up = math.ceil(L * K * math.log(2) / ((kk + 1) * float(dl)))
                    assert r * L / max(n_up, 1) >= float(Fb) / (K * math.log(2) / (kk + 1) + float(dl) / L) * (1 - 1e-12)
            n_cases += 1
print(f"   {n_cases} triples (delta, L, r): (a) r L/n <= 4F/(1 - 4 delta), below 1 exactly when F < 1/4 - delta (exact);")
print("   (b) r L/n <= 8F log2(L/(2 delta))/((1 - 10 delta) K); (c) r L/n >= F/(K ln 2/(k + 1) + delta/L)")
K, L, dl = 1e9, 1000, 0.01
print(f"   K = 1e9, L = 1000, delta = 0.01: rehearsal breaks even at K ln 2 = {K * math.log(2):.3g} failed runs;")
print(f"   no protocol on the classes of (b) before (1 - 10 delta) K/(8 log2(L/(2 delta))) = {(1 - 10 * dl) * K / (8 * math.log2(L / (2 * dl))):.3g};")
print(f"   questions: L K ln 2/delta = {L * K * math.log(2) / dl:.3g}; 1 + 2.7 K L/(delta log2(L/delta)) = {1 + 2.7 * K * L / (dl * math.log2(L / dl)):.3g}")

# ------------------------------------------------------------------------------------------- (J)
print("(J) N3")
for N in range(1, 40):
    for a in (Fr(1, 1000), Fr(1, 7), Fr(1, 4), Fr(1, 3), Fr(49, 100), Fr(1, 2)):
        n = ceil_frac(2 * a * N)
        assert n <= N and Fr(n, 2 * N) >= a
n_cases = 0
for N in range(1, 7):
    for n in range(0, N + 1):
        subsets = list(itertools.combinations(range(1, N + 1), n))
        least = None
        for member in range(0, N + 1):                   # 0: zero function; j: the indicator of X_j
            for shift in range(1, N + 1):
                right = Fr(0)
                for I in subsets:
                    truth = 1 if member == shift else 0
                    if member in I:
                        pr = Fr(1)                       # the human is identified and deployed
                    elif shift in I:
                        pr = Fr(1) if truth == 0 else Fr(0)   # answers 0 on the asked sets
                    else:
                        pr = Fr(1, 2)                    # a fair coin on the sets not asked
                    right += pr / len(subsets)
                least = right if least is None else min(least, right)
        assert least == Fr(1, 2) + Fr(n, 2 * N), (N, n, least)
        n_cases += 1
print(f"   ceil(2 a N) <= N for a <= 1/2; the protocol with n questions has least success probability 1/2 + n/(2N) ({n_cases} pairs, N <= 6, exact)")

# ------------------------------------------------------------------------------------------- (K)
print("(K) S2")
for trial in range(300):
    n_laws = random.randint(1, 5)
    n_z = random.randint(1, 6)
    laws = []
    for _ in range(n_laws):
        raw = [random.randint(0, 5) for _ in range(n_z)]
        if sum(raw) == 0:
            raw[0] = 1
        laws.append([Fr(x, sum(raw)) for x in raw])
    rawp = [random.randint(1, 5) for _ in range(n_laws)]
    tot = sum(rawp) + random.randint(0, 5)               # total weight at most 1
    pi = [Fr(x, tot) for x in rawp]
    mix = [sum(pi[i] * laws[i][z] for i in range(n_laws)) / sum(pi) for z in range(n_z)]
    assert sum(mix) == 1
    phi = [Fr(random.randint(0, 9), random.randint(1, 4)) for _ in range(n_z)]
    for i in range(n_laws):
        assert all(laws[i][z] <= mix[z] / pi[i] for z in range(n_z))
        assert sum(laws[i][z] * phi[z] for z in range(n_z)) <= sum(mix[z] * phi[z] for z in range(n_z)) / pi[i]
print("   300 random families: D_i <= (mixture)/pi_i pointwise, and E_{D_i} phi <= E_mixture phi / pi_i (exact)")
M = 60
assert sum(Fr(2 ** ell, 2 ** (2 * ell + 1)) for ell in range(M + 1)) == 1 - Fr(1, 2 ** (M + 1))
print("   weights 2^(-2 ell - 1) of the programs of ell bits: total 1 - 2^(-M-1) up to length M (exact, M = 60)")

# Remark 4.4a: the length ell is drawn with probability q(ell) = 4/((ell + 1)(ell + 2)(ell + 3))
def q3(ell):
    return Fr(4, (ell + 1) * (ell + 2) * (ell + 3))


assert sum(q3(ell) for ell in range(M + 1)) == 1 - Fr(2, (M + 2) * (M + 3))
reach = Fr(1)
mean_partial = Fr(0)
for ell in range(M + 1):                                 # stop at length ell with probability 2/(ell + 3)
    assert reach == Fr(2, (ell + 1) * (ell + 2))         # probability that the length is at least ell
    assert reach * Fr(2, ell + 3) == q3(ell)
    if ell >= 1:
        mean_partial += reach                            # E[length] = sum over ell >= 1 of Pr[length >= ell]
    reach *= 1 - Fr(2, ell + 3)
assert mean_partial == 1 - Fr(2, M + 2)                  # so the mean length is 1
# total weight of the programs: sum over ell of 2^ell * 2^(-ell) q(ell) = 1; the factor is 1/pi_p
for ell in range(0, 30):
    pi_p = Fr(1, 2 ** ell) * q3(ell)
    assert 1 / pi_p == Fr(2 ** ell * (ell + 1) * (ell + 2) * (ell + 3), 4)
print("   Remark 4.4a: length ell drawn with probability 4/((ell + 1)(ell + 2)(ell + 3)): total 1 - 2/((M + 2)(M + 3)) up to")
print("   length M; the procedure that stops at length ell with probability 2/(ell + 3) reaches ell with probability")
print("   2/((ell + 1)(ell + 2)) and so draws this law; the mean length is 1; the factor 1/pi_p is")
print("   2^ell (ell + 1)(ell + 2)(ell + 3)/4 (exact, M = 60)")
for ell in (1, 10, 20, 40):
    f1 = 2 ** (2 * ell + 1)
    f2 = 2 ** ell * (ell + 1) * (ell + 2) * (ell + 3) / 4
    print(f"   ell = {ell:2d}: factor 2^(2 ell + 1) = {f1:.3g}; factor 2^ell (ell + 1)(ell + 2)(ell + 3)/4 = {f2:.3g}")
smaller = [Fr(2 ** ell * (ell + 1) * (ell + 2) * (ell + 3), 4) <= 2 ** (2 * ell + 1) for ell in range(0, 200)]
first = min(e for e in range(200) if all(smaller[e:]))
assert first == 6 and smaller[0] and not any(smaller[1:6])
assert all(Fr((ell + 1) * (ell + 2) * (ell + 3), 4) <= (ell + 2) ** 3 for ell in range(0, 200))
print("   the second factor is at most the first for ell = 0 and for every ell >= 6 (tested up to 199), larger for")
print("   ell = 1, ..., 5, and at most 2^ell (ell + 2)^3")
# the simpler law 1/((ell + 1)(ell + 2)) also adds up to 1 but has an infinite mean length
assert sum(Fr(1, (ell + 1) * (ell + 2)) for ell in range(M + 1)) == 1 - Fr(1, M + 2)
assert sum(Fr(ell, (ell + 1) * (ell + 2)) for ell in range(2000)) > 6
print("   (the law 1/((ell + 1)(ell + 2)) adds up to 1 as well, but its mean length is infinite: partial sums exceed 6)")

print("all assertions passed")
print(f"time {time.time() - T0:.1f} s", file=sys.stderr)
