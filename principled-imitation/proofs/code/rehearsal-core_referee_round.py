#!/usr/bin/env python3
"""Editor of part rehearsal-core, referee round: checks of what the referee round added to the
text of Sections 1 to 3 of the note (research/sections/rehearsal-core.md) and to the proof file.

Written from the statements, without reuse of an earlier script.  Blocks 1(a), 2 and 3 are exact
(fractions and integers); blocks 1(b), 1(c) and 1(d) are exact enumerations in floating point.
There is no sampling: the instances of block 1 are drawn with a fixed seed and then evaluated
exactly.

Blocks:
 1. V1(c) of the note, which is Theorem 13.1(b3) of the proof file (finding F5 of the referee of
    the mathematics: the note printed no argument for it).
    (a) For a sampler A, every test B of pairs has Delta(B) <= beta(A)/L, and the test
        B_P = {(x, y) : A(y|x) > P(y|x)} has Delta(B_P) = beta(A)/L.  Exact, on a scaffold of
        horizon 3 whose questions and length depend on the answers, for all 64 tests.
    (b) The certificate: beta(A)/L <= max over the hypotheses nu with w(nu) >= 2^-K0 of the
        recorded difference of B_nu, plus sqrt(2 (K0 ln 2 + ln(1/delta))/m), fails with
        probability at most delta.  The joint law of the recorded differences after m rounds is
        computed exactly (m-fold convolution), and with it the probability of failure.
    (c) The step of the proof: for each hypothesis nu, Delta(B_nu) exceeds the recorded
        difference by sqrt(2 ln(1/(w(nu) delta))/m) with probability at most w(nu) delta.
    (d) The inequality behind (c) on a grid: for independent variables with values in
        {-1, 0, 1}, Pr[mean <= expectation - t] <= exp(-m t^2/2).
    (e) Why (c) is stated for a sampler: an answerer that looks at the history can have
        Delta(B) = 0 for every test of pairs and beta(A)/L = 1/4.
 2. R7 of the note, which is Proposition 5.6 of the proof file, when the class does not contain
    the human and the recorded answers can have probability zero under every hypothesis (finding
    F9 of the referee of the mathematics).  The protocol is enumerated exactly, with three
    different imitators for the case that no hypothesis fits, and for every set X0 of inputs.
 3. Numbers of the section text: the 350 working years of Section 3.1 and where R1 is empty
    (finding F21); R7 in bits (finding F13 of the reader); R3 for a person (reader, Part G);
    the sentence on N8 after R3; the 300 rounds of Section 3.5; V1(c) for a person.
"""
import itertools
import math
import random
from collections import defaultdict
from fractions import Fraction as F

import numpy as np

OUT = []


def say(s=""):
    print(s)
    OUT.append(s)


# -------------------------------------------------------------------------------------------
# The scaffold of blocks 1 and 2.  Inputs 0, 1, 2; answers 0, 1; horizon L = 3.
# z is uniform on {0, 1}.  Call 1 is at the input z.  Call 2 is made only if the first answer
# is 1, and is at the input 2.  Call 3 is made only if z = 1, and is at the input given by the
# second answer.  So runs have 1, 2 or 3 calls, and the questions depend on the answers.
L = 3
X = (0, 1, 2)
D0 = {0: F(1, 2), 1: F(1, 2)}


def nxt(z, ys):
    j = len(ys) + 1
    if j == 1:
        return z
    if j == 2:
        return 2 if ys[0] == 1 else None
    if j == 3:
        return ys[1] if z == 1 else None
    return None


def runs(kern):
    """All runs of the scaffold when the sampler kern (input -> Pr[answer 1]) answers:
    a list of (inputs, answers, probability)."""
    out = []

    def go(z, xs, ys, p):
        x = nxt(z, ys)
        if x is None:
            out.append((tuple(xs), tuple(ys), p))
            return
        for y in (0, 1):
            q = kern[x] if y == 1 else 1 - kern[x]
            if q:
                go(z, xs + [x], ys + [y], p * q)

    for z, pz in D0.items():
        go(z, [], [], pz)
    return out


def pr(kern, x, y):
    return kern[x] if y == 1 else 1 - kern[x]


PAIRS = [(x, y) for x in X for y in (0, 1)]
ALL_TESTS = [frozenset(c) for r in range(len(PAIRS) + 1) for c in itertools.combinations(PAIRS, r)]


def beta_over_L(A, P):
    """beta(A)/L: the expected number of unfaithful calls of a run of the sampler A, over L.
    For two answers the total variation at x is |A(1|x) - P(1|x)|."""
    return sum(p * sum(abs(A[x] - P[x]) for x in xs) for xs, _, p in runs(A)) / L


def Delta(A, P, B):
    """(expected number of calls of a run of A whose pair (question, answer) lies in B, minus
    the expected number of its calls at which the human's answer would lie in B) / L."""
    tot = 0
    for xs, ys, p in runs(A):
        for x, y in zip(xs, ys):
            tot += p * ((1 if (x, y) in B else 0) - sum(pr(P, x, yy) for yy in (0, 1) if (x, yy) in B))
    return tot / L


def test_of(A, nu):
    return frozenset((x, y) for (x, y) in PAIRS if pr(A, x, y) > pr(nu, x, y))


def round_law(A, P):
    """The law of one validation round: {(asked?, x, answer of A, answer of the human): prob}.
    J is uniform on {1, ..., L}; a round with J beyond the end of the run asks nothing."""
    law = defaultdict(F)
    for xs, ys, p in runs(A):
        law[(0, None, None, None)] += p * F(L - len(xs), L)
        for x, y in zip(xs, ys):
            for yp in (0, 1):
                q = pr(P, x, yp)
                if q:
                    law[(1, x, y, yp)] += p * F(1, L) * q
    assert sum(law.values()) == 1
    return law


def g_of(o, B):
    a, x, ya, yp = o
    if not a:
        return 0
    return (1 if (x, ya) in B else 0) - (1 if (x, yp) in B else 0)


say("== 1. V1(c) of the note (Theorem 13.1(b3)) ==")
rng = random.Random(20261128)


def rand_sampler(den=20):
    return {x: F(rng.randint(0, den), den) for x in X}


# (a) exact identity and inequality, 40 random instances
n_strict = 0
for _ in range(40):
    A, P = rand_sampler(), rand_sampler()
    b = beta_over_L(A, P)
    BP = test_of(A, P)
    assert Delta(A, P, BP) == b, "Delta(B_P) != beta/L"
    for B in ALL_TESTS:
        d = Delta(A, P, B)
        assert d <= b, "a test exceeds beta/L"
        if d < b:
            n_strict += 1
say("  (a) 40 random pairs (A, P) of samplers, exact: Delta(B_P) = beta(A)/L in all 40, and Delta(B) <= beta(A)/L")
say(f"      for all 64 tests B in all 40 (strictly below in {n_strict} of the {40 * 64} cases)")

# (b) the certificate, exact joint law of the recorded differences
weights = [F(1, 2), F(1, 4), F(1, 8), F(1, 16)]   # total 15/16; the human is the third: K = 3


def joint_fail(A, cls, human_idx, K0, m, deltas):
    P = cls[human_idx]
    fam = [i for i, w in enumerate(weights) if w >= F(1, 2 ** K0)]
    assert human_idx in fam
    tests = [test_of(A, cls[i]) for i in fam]
    law = round_law(A, P)
    vec = defaultdict(float)
    for o, p in law.items():
        vec[tuple(g_of(o, B) for B in tests)] += float(p)
    d = len(fam)
    arr = np.zeros((2 * m + 1,) * d)
    arr[(m,) * d] = 1.0
    for _ in range(m):
        new = np.zeros_like(arr)
        for v, p in vec.items():
            new += p * np.roll(arr, shift=v, axis=tuple(range(d)))
        arr = new
    assert abs(arr.sum() - 1) < 1e-9
    grids = np.meshgrid(*([np.arange(-m, m + 1)] * d), indexing="ij")
    mx = np.maximum.reduce(grids) / m          # the largest recorded difference
    b = float(beta_over_L(A, P))
    res = {}
    for delta in deltas:
        slack = math.sqrt(2 * (K0 * math.log(2) + math.log(1 / delta)) / m)
        res[delta] = float(arr[mx + slack < b - 1e-12].sum())
    return b, res


worst = 0.0
lines = []
for inst in range(6):
    cls = [rand_sampler() for _ in range(4)]
    # an imitator far from the human, so that the certificate can fail at all
    P = cls[2]
    if inst % 2 == 0:
        A = {x: (1 - P[x]) * F(9, 10) + P[x] * F(1, 10) for x in X}
    else:
        A = rand_sampler()
    for K0, m in ((3, 20), (3, 40), (4, 16)):
        b, res = joint_fail(A, cls, 2, K0, m, (0.5, 0.1, 0.01))
        for delta, pf in res.items():
            worst = max(worst, pf / delta)
        if inst == 0:
            lines.append(f"      instance 1, K0 = {K0}, m = {m}: beta(A)/L = {b:.4f}; Pr[the bound of (c) fails] = "
                         + ", ".join(f"{pf:.2e} (delta = {delta})" for delta, pf in res.items()))
say("  (b) 6 instances (4 hypotheses of weights 1/2, 1/4, 1/8, 1/16; the human is the third, K = 3), K0 = 3 with")
say("      m = 20, 40 and K0 = 4 with m = 16, delta = 0.5, 0.1, 0.01; joint law of the recorded differences exact:")
for ln in lines:
    say(ln)
say(f"      largest value of Pr[the bound of (c) fails]/delta over the 54 cases = {worst:.2e} (<= 1)")
# A case made as tight as a test of pairs allows: one call per run at one input, a class that
# consists of the human alone (K = K0 = 0), P(1|x) = 1/4 and A(1|x) = 3/4.  Then B_P = {(x, 1)},
# beta(A)/L = 1/2, and the recorded difference of a round is +1, 0, -1 with probabilities
# 9/16, 6/16, 1/16.
base = np.array([1 / 16, 6 / 16, 9 / 16])
tight = 0.0
tight_at = None
for m in range(1, 201):
    dist = np.array([1.0])
    for _ in range(m):
        dist = np.convolve(dist, base)
    sums = np.arange(-m, m + 1)
    for delta in (0.9, 0.5, 0.1, 0.01):
        slack = math.sqrt(2 * math.log(1 / delta) / m)
        pf = float(dist[sums / m + slack < 0.5 - 1e-12].sum())
        if pf / delta > tight:
            tight, tight_at = pf / delta, (m, delta, pf)
say(f"      one call per run, the class is the human alone (K0 = 0), P(1|x) = 1/4, A(1|x) = 3/4, m = 1, ..., 200, delta = 0.9, 0.5, 0.1, 0.01:")
say(f"      largest value of Pr[the bound of (c) fails]/delta = {tight:.4f} (<= 1), at m = {tight_at[0]}, delta = {tight_at[1]} (probability {tight_at[2]:.4f})")

# (c) the step for one hypothesis
worst_c = 0.0
for inst in range(20):
    cls = [rand_sampler() for _ in range(4)]
    P = cls[2]
    A = rand_sampler()
    law = round_law(A, P)
    for i, nu in enumerate(cls):
        B = test_of(A, nu)
        pm = defaultdict(float)
        for o, p in law.items():
            pm[g_of(o, B)] += float(p)
        base = np.array([pm[-1], pm[0], pm[1]])
        Dl = float(Delta(A, P, B))
        for m in (10, 30, 100, 300):
            dist = np.array([1.0])
            for _ in range(m):
                dist = np.convolve(dist, base)
            sums = np.arange(-m, m + 1)
            for delta in (0.5, 0.1, 0.01):
                target = float(weights[i]) * delta
                t = math.sqrt(2 * math.log(1 / target) / m)
                pf = float(dist[Dl - sums / m >= t - 1e-12].sum())
                worst_c = max(worst_c, pf / target)
say(f"  (c) 20 instances, each hypothesis, m = 10, 30, 100, 300, delta = 0.5, 0.1, 0.01: largest value of")
say(f"      Pr[Delta(B_nu) - recorded difference >= sqrt(2 ln(1/(w(nu) delta))/m)]/(w(nu) delta) = {worst_c:.4f} (<= 1)")

# (d) the inequality on a grid
worst_d = 0.0
arg = None
for pp in np.linspace(0, 1, 21):
    for pmn in np.linspace(0, 1 - pp, 11):
        base = np.array([pmn, 1 - pp - pmn, pp])
        mean = pp - pmn
        for m in (1, 2, 5, 20, 80):
            dist = np.array([1.0])
            for _ in range(m):
                dist = np.convolve(dist, base)
            sums = np.arange(-m, m + 1)
            for t in np.linspace(0.02, 2.0, 100):
                pf = float(dist[sums / m <= mean - t + 1e-12].sum())
                bound = math.exp(-m * t * t / 2)
                if pf / bound > worst_d:
                    worst_d, arg = pf / bound, (float(pp), float(pmn), m, float(t))
say(f"  (d) variables in {{-1, 0, 1}} on a grid of laws, m = 1, 2, 5, 20, 80, 100 values of t: largest value of")
say(f"      Pr[mean <= expectation - t]/exp(-m t^2/2) = {worst_d:.4f} (<= 1), at Pr[+1] = {arg[0]:.2f}, Pr[-1] = {arg[1]:.2f}, m = {arg[2]}, t = {arg[3]:.2f}")

# (e) an answerer that looks at the history.  Two calls, at the inputs 0 and 1, in every run.
# The human answers each with a fair coin.  A answers the first call with a fair coin and
# repeats that answer at the second call.
runs_e = [((0, 1), (y, y), F(1, 2)) for y in (0, 1)]          # runs of A: (inputs, answers, prob)
beta_e = sum(p * (abs(F(1, 2) - F(1, 2)) + F(1, 2)) for _, _, p in runs_e)   # TV(point mass, fair coin) = 1/2
pairs_e = [(x, y) for x in (0, 1) for y in (0, 1)]
tests_e = [frozenset(c) for r in range(5) for c in itertools.combinations(pairs_e, r)]
deltas_e = set()
for B in tests_e:
    d = F(0)
    for xs, ys, p in runs_e:
        for x, y in zip(xs, ys):
            d += p * ((1 if (x, y) in B else 0) - sum(F(1, 2) for yy in (0, 1) if (x, yy) in B))
    deltas_e.add(d / 2)
assert deltas_e == {F(0)} and beta_e / 2 == F(1, 4)
say(f"  (e) an answerer that repeats its first answer at the second call, against a human who answers both calls with a fair coin (L = 2):")
say(f"      Delta(B) = 0 for all {len(tests_e)} tests of pairs, and beta(A)/L = {beta_e / 2}: the identity of (a) needs an imitator that looks at the input only")

# -------------------------------------------------------------------------------------------
say()
say("== 2. R7 (Proposition 5.6) when no hypothesis fits the recorded answers ==")
SUBSETS = [frozenset(c) for r in range(1, len(X) + 1) for c in itertools.combinations(X, r)]


def coverage(cls, wts, human, fallback, n):
    """Rehearsal with n rounds, enumerated exactly.  The imitator of a round is the mixture
    given the data if some hypothesis gives the data positive probability, and fallback(data)
    otherwise.  The data are kept as a multiset of pairs: the mixture, the sets of asked inputs
    and the two humans below depend on the data only through it.  Returns
      acc[X0] = sum over t <= n of Pr[no question of rounds < t lay in X0, and the run of round t
                has a call in X0]   (R7 says: at most L; divided by n it is the probability of
                R7 for the deployed run of the mixture of a uniformly drawn round),
      uni     = the same sum for the event 'the run has a call at an input that was never asked
                before' (the union of the events for the three singletons),
      nofit   = Pr[no hypothesis fits the data at the start of round n]."""
    dist = {(): F(1)}
    acc = {S: F(0) for S in SUBSETS}
    uni = F(0)
    nofit = F(0)
    for t in range(1, n + 1):
        new = defaultdict(F)
        nofit = F(0)
        for D, pD in dist.items():
            liks = []
            for nu in cls:
                lk = F(1)
                for x, y in D:
                    lk *= pr(nu, x, y)
                liks.append(lk)
            xi = sum(w * lk for w, lk in zip(wts, liks))
            if xi > 0:
                M = {x: sum(w * lk * nu[x] for w, lk, nu in zip(wts, liks, cls)) / xi for x in X}
            else:
                M = fallback(D)
                nofit += pD
            rs = runs(M)
            asked = {x for x, _ in D}
            for S in SUBSETS:
                if not (asked & S):
                    acc[S] += pD * sum(p for xs, _, p in rs if set(xs) & S)
            uni += pD * sum(p for xs, _, p in rs if set(xs) - asked)
            for xs, _, p in rs:
                stay = F(L - len(xs), L)
                if stay:
                    new[D] += pD * p * stay
                for x in xs:
                    h1 = human(x, D, t)
                    for y, q in ((1, h1), (0, 1 - h1)):
                        if q:
                            new[tuple(sorted(D + ((x, y),)))] += pD * p * F(1, L) * q
        assert sum(new.values()) == 1
        dist = dict(new)
    return acc, uni, nofit


funcs = [{0: F(0), 1: F(0), 2: F(0)}, {0: F(1), 1: F(1), 2: F(0)}, {0: F(0), 1: F(1), 2: F(1)}]
w_funcs = [F(1, 2), F(1, 4), F(1, 8)]
coin = {0: F(1, 2), 1: F(1, 2), 2: F(1, 2)}


def human_sampler(x, D, t):                      # a sampler that is not in the class
    return {0: F(7, 10), 1: F(2, 5), 2: F(1, 2)}[x]


def human_process(x, D, t):                      # not a sampler: depends on the round and on the data
    return F((t + x + sum(y for _, y in D)) % 3, 2)


fallbacks = {
    "the mixture under the prior weights": lambda D: {x: sum(w * nu[x] for w, nu in zip(w_funcs, funcs)) / sum(w_funcs) for x in X},
    "always the answer 1": lambda D: {x: F(1) for x in X},
    "a rule that depends on the data": lambda D: {x: F(1 + (len(D) + x) % 2, 3) for x in X},
}
n_cov = 8
worst2 = F(0)
for hname, human in (("a sampler outside the class", human_sampler), ("a process that depends on the round and the data", human_process)):
    for fname, fb in fallbacks.items():
        acc, uni, nofit = coverage(funcs, w_funcs, human, fb, n_cov)
        top = max(acc.values())
        worst2 = max(worst2, top / L)
        assert top <= L and uni <= len(X) * L
        say(f"  class of three functions; human: {hname}; when no hypothesis fits: {fname}")
        say(f"    n = {n_cov}: Pr[no hypothesis fits the data at the start of round n] = {float(nofit):.4f}; largest sum over the rounds, over the 7 sets X0, = {float(top):.4f} <= L = {L};")
        say(f"    so R7: {float(top / n_cov):.4f} <= L/n = {L / n_cov:.4f}; three singletons at once: {float(uni / n_cov):.4f} <= 3 L/n = {3 * L / n_cov:.4f}")
# control: a class in which some hypothesis always fits
acc, uni, nofit = coverage(funcs + [coin], w_funcs + [F(1, 8)], human_sampler, fallbacks["always the answer 1"], n_cov)
assert nofit == 0 and max(acc.values()) <= L
say(f"  control (a fair coin added to the class, so that some hypothesis always fits): Pr[no hypothesis fits] = {float(nofit):.1f}; largest sum = {float(max(acc.values())):.4f} <= {L}")
say(f"  largest ratio of a sum to L in the six cases with a class that can fail to fit: {float(worst2):.4f} (<= 1)")

# -------------------------------------------------------------------------------------------
say()
say("== 3. Numbers of the section text ==")
ln2 = math.log(2)
Lc, Kc = 10, 1e4
nq = Lc * Kc * ln2 / 0.1
say(f"  Section 3.1: L = 10, K = 1e4, 0.1 unfaithful calls per run: n = L K ln 2/0.1 = {nq:.4g} answers; at one hour each, {nq / 2000:.1f} working years of 2000 hours")
say(f"  Section 3.1 (finding F21): L K ln 2/n is below the trivial bound L on the number of unfaithful calls only for n > K ln 2, and below 1,")
say(f"    as a bound on the probability of an unfaithful run, only for n > L K ln 2; for K = 100, L = 10 these are n > {100 * ln2:.1f} and n > {10 * 100 * ln2:.1f}")
nn, LL = 1e5, 10
say(f"  Section 3.3, R7 in bits: n = 1e5, L = 10: log2(n/L) = {math.log2(nn / LL):.2f}; for delta = 0.1, log2(delta n/L) = {math.log2(0.1 * nn / LL):.2f};")
say(f"    a prefix-free language has at most 2^b programs of at most b bits: 2^9 L/n = {2 ** 9 * LL / nn:.4f} <= 0.1 < 2^10 L/n = {2 ** 10 * LL / nn:.4f}; 2^13 L/n = {2 ** 13 * LL / nn:.2f}, 2^14 L/n = {2 ** 14 * LL / nn:.2f}")
plain = sum(2 ** i for i in range(0, 10))
say(f"    (all binary strings as programs: {plain} strings have fewer than 9.97 bits, and {plain} L/n = {plain * LL / nn:.4f} > 0.1: the count 2^b needs a prefix-free language, or a whole number b)")
Kp, th, dl = 1e9, 0.1, 0.1
n1 = Kp * ln2 / (th * dl)
n2 = Kp * ln2 / (2 * th ** 2 * dl ** 2)
say(f"  Section 3.4, R3 for a person: K = 1e9, theta = 0.1, excess failure 0.1: K ln 2/(theta delta) = {n1:.3g} answers = {n1 / 2000:.3g} working years at an hour each;")
say(f"    for a human who varies, K ln 2/(2 theta^2 delta^2) = {n2:.3g} answers")
say("  Section 3.4, the sentence on N8: with g critical steps in 2k + 1 copies each, L = g (2k + 1) and theta = (k + 1)/L; theta g = "
    + ", ".join(f"{F(k + 1, 2 * k + 1)} (k = {k})" for k in (0, 1, 5, 100)) + ": between 1/2 and 1")
say(f"  Section 3.5: m = 300 rounds without a recorded disagreement certify, at delta = 0.05, beta(A) <= L ln(20)/300 = {math.log(20) / 300:.5f} L;")
say(f"    by R3 with k + 1 >= theta L and theta = 0.1 the excess failure is at most {math.log(20) / 300 / 0.1:.4f}")
say(f"  Section 3.5, V1(c) for a person: the term sqrt(2 (K0 ln 2 + ln(1/delta))/m) is below 1 only for m > 2 K0 ln 2 = {2 * 1e9 * ln2:.3g} when K0 = 1e9")

with open(__file__.replace(".py", ".out"), "w") as fh:
    fh.write("\n".join(OUT) + "\n")
