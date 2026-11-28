"""Checks made by the editor of shift-abstain in the referee round (proofs/shift-abstain.md, Section 12.7).

They concern the passages that were added to Section 7.4 of the proof file after the two reports on
Theorem 7.6 (verification/shift-abstain-ab5-check.md and -attack.md).  The script was written before
its author had read any code of the lead's script or of the two referees' scripts; their saved outputs
were read.

 (1) Item 3a of Theorem 7.6 (one count for all steps): the probability, exact over the questions, that
     some sequence (c_0, c_1, .., c_T) of members of V with T <= ceil(1/eps) - 1 has a union of
     disagreement sets of P-mass above rho = (ceil(1/eps) b ln 2 + ln(2/delta))/n, against delta; and
     P(R(z)) <= rho for the batches tried on the good event.
 (2) Remark 7.10(a): for a batch of r runs of exactly L calls each, "nothing is refused" holds with
     eps*r in the place of eps*m (by a dynamic programme over the runs, exact up to floating point, for
     one or two members); the counterexample of the check report to the form with eps*m; and an example
     with runs of different lengths in which the form with eps*r fails as well.
 (3) Remark 7.8(ii), the rock as a rate: if two members of V differ from each other at every point of a
     set Q, the rule answers at most 2*floor(eps*m) batch positions in Q.  Exhaustive on small cases.
 (4) Example 7.9(b): the number of runs of a batch that contain a wrong answer is at most floor(eps*m).
 (5) Example 7.9(c): the obvious input-by-input rule, the batch rule, and the input-by-input rule that
     refuses an input at which two or more members differ from h; soundness of the last, exhaustively.
 (6) Remark 7.8(ii): after a successful audit Bat_eps, run again, may still refuse; Bat_(2 eps) does not.
 (7) Remark 7.8(ii): the Occam count without abstention (exact); frozen enumeration on the point
     functions; the two prices of Corollary 7.7.

Run:  python3 shift-abstain_referee_round.py      (fixed seeds; about 15 seconds; below 1 GB)
"""
import itertools
import math
import random
from collections import defaultdict

import numpy as np
from fractions import Fraction

random.seed(20261128)


# ------------------------------------------------------------------------------------------------
# The rule Bat_eps on a batch given as multiplicities of the inputs.  Functions are tuples over the
# inputs 0..k-1.  V is a list of functions, h one of them.  thr is eps*m (a Fraction or an int).
# Returns (alive, steps): alive[x] says whether input x is still answered.
# ------------------------------------------------------------------------------------------------
def bat(V, h, cnt, thr, pick_last=False):
    k = len(cnt)
    diff = [[x for x in range(k) if c[x] != h[x]] for c in V]
    alive = [True] * k
    steps = []
    while True:
        cand = [i for i, d in enumerate(diff) if sum(cnt[x] for x in d if alive[x]) > thr]
        if not cand:
            return alive, steps
        i = cand[-1] if pick_last else cand[0]
        steps.append(i)
        for x in diff[i]:
            alive[x] = False


def asked_set_law(P, n):
    """Exact law of the set of asked inputs after n rounds; P[x] are Fractions with sum <= 1."""
    rest = 1 - sum(P)
    law = {0: Fraction(1)}
    for _ in range(n):
        new = defaultdict(Fraction)
        for A, pr in law.items():
            if rest:
                new[A] += pr * rest
            for x, px in enumerate(P):
                if px:
                    new[A | (1 << x)] += pr * px
        law = new
    return law


def mass(P, xs):
    return sum((P[x] for x in xs), Fraction(0))


def multisets(k, m):
    """All vectors of multiplicities of k inputs with total m."""
    for comb in itertools.combinations_with_replacement(range(k), m):
        cnt = [0] * k
        for x in comb:
            cnt[x] += 1
        yield cnt


def kl(a, p):
    if p <= 0:
        return math.inf
    if a >= 1:
        return math.log(1 / p)
    return a * math.log(a / p) + (1 - a) * math.log((1 - a) / (1 - p))


# ------------------------------------------------------------------------------------------------
def part1():
    print("(1) item 3a of Theorem 7.6: one count for all steps (exact over the questions)")
    eps_list = [Fraction(1), Fraction(1, 2), Fraction(2, 5), Fraction(1, 3), Fraction(3, 10), Fraction(1, 4)]
    deltas = [0.5, 0.2, 0.05]
    worst = 0.0
    worst_pair = 0.0
    n_inst = n_checks = n_bad_positive = 0
    batch_cases = batch_viol = 0
    for inst in range(160):
        k = random.choice([3, 4])
        ny = random.choice([2, 2, 3])
        allf = list(itertools.product(range(ny), repeat=k))
        size = random.choice([2, 3, 4, 5])
        Hb = random.sample(allf, size)
        f = random.choice(Hb)
        b = math.log2(size)                    # the smallest b with |H_b| <= 2^b
        den = random.choice([6, 8, 10, 12])
        w = [random.randint(0, 4) for _ in range(k)]
        if sum(w) == 0:
            w[0] = 1
        total = Fraction(random.choice([1, 1, 1, 2]), random.choice([2, 3])) if random.random() < 0.3 else Fraction(1)
        P = [Fraction(wi, sum(w)) * total for wi in w]
        n = random.choice([2, 3, 4, 5, 6, 8])
        law = asked_set_law(P, n)
        n_inst += 1
        for eps in eps_list:
            tmax = math.ceil(1 / eps) - 1
            for delta in deltas:
                rho = (math.ceil(1 / eps) * b * math.log(2) + math.log(2 / delta)) / n
                gamma = (2 * b * math.log(2) + math.log(1 / delta)) / n
                pr_bad = Fraction(0)
                pr_bad_pair = Fraction(0)
                for A, pr in law.items():
                    V = [c for c in Hb if all(c[x] == f[x] for x in range(k) if A >> x & 1)]
                    bad = False
                    s = min(tmax, len(V) - 1)
                    if s >= 1:
                        for c0 in V:
                            others = [c for c in V if c is not c0]
                            for S in itertools.combinations(others, s):
                                U = [x for x in range(k) if any(c[x] != c0[x] for c in S)]
                                if float(mass(P, U)) > rho:
                                    bad = True
                                    break
                            if bad:
                                break
                    if bad:
                        pr_bad += pr
                    # the event of item 3 (pairs), for comparison
                    if any(float(mass(P, [x for x in range(k) if c[x] != c2[x]])) > gamma
                           for c, c2 in itertools.combinations(V, 2)):
                        pr_bad_pair += pr
                    # on the good event: the rule's refused set, for all batches of length <= 4
                    if not bad and delta == deltas[0]:
                        for m in range(1, 5):
                            for cnt in multisets(k, m):
                                for h in V:
                                    for last in (False, True):
                                        alive, steps = bat(V, h, cnt, eps * m, last)
                                        R = set()
                                        for i in steps:
                                            R |= {x for x in range(k) if V[i][x] != h[x]}
                                        batch_cases += 1
                                        if float(mass(P, R)) > rho + 1e-12 or len(steps) > tmax:
                                            batch_viol += 1
                n_checks += 1
                if pr_bad > 0:
                    n_bad_positive += 1
                worst = max(worst, float(pr_bad) / delta)
                worst_pair = max(worst_pair, float(pr_bad_pair) / (delta / 2))
    print(f"    instances {n_inst}; (instance, eps, delta) checks {n_checks}; with Pr[bad] > 0: {n_bad_positive}")
    print(f"    largest Pr[some sequence has mass above rho]/delta: {worst:.4f} (the proof gives less than 1)")
    print(f"    for comparison, largest Pr[not E]/(delta/2) for the pairs of item 3: {worst_pair:.4f}")
    print(f"    batches on the good event: {batch_cases}; violations of P(R(z)) <= rho or T <= ceil(1/eps) - 1: {batch_viol}")
    print("    rho against gamma/eps for b = 30, delta = 0.05 (both times n):")
    for eps in (1.0, 0.99, 0.5, 0.1, 0.01):
        b, delta = 30, 0.05
        rho_n = math.ceil(1 / eps - 1e-12) * b * math.log(2) + math.log(2 / delta)
        g_n = (2 * b * math.log(2) + math.log(1 / delta)) / eps
        print(f"      eps={eps:<5} rho*n={rho_n:10.2f}  (gamma/eps)*n={g_n:10.2f}  ratio={g_n / rho_n:.3f}")
    b, delta = 1, 0.5
    eps = 0.99
    rho_n = 2 * b * math.log(2) + math.log(2 / delta)
    g_n = (2 * b * math.log(2) + math.log(1 / delta)) / eps
    print(f"      rho is not always the smaller one: b=1, delta=0.5, eps=0.99: rho*n={rho_n:.3f}, (gamma/eps)*n={g_n:.3f}")


# ------------------------------------------------------------------------------------------------
def shift_axis(a, c, cap, axis):
    """The law of min(cap, count + c) along one axis, from the law of the count."""
    if c == 0:
        return a
    a = np.moveaxis(a, axis, 0)
    out = np.zeros_like(a)
    if c <= cap:
        out[c:cap] = a[0:cap - c]
        out[cap] = a[cap - c:].sum(axis=0)
    else:
        out[cap] = a.sum(axis=0)
    return np.moveaxis(out, 0, axis)


def refusal_probability(types, r, thr):
    """Pr[some member has more than thr batch positions in its disagreement set] for r independent
    runs, by a dynamic programme over the runs (exact up to floating point; no subtraction is used).
    types = [(probability, counts)], counts = positions of one run in each member's disagreement set.
    A count is capped at floor(thr) + 1, which means "above thr"."""
    k = len(types[0][1])
    cap = math.floor(thr) + 1
    st = np.zeros((cap + 1,) * k)
    st[(0,) * k] = 1.0
    for _ in range(r):
        new = np.zeros_like(st)
        for q, counts in types:
            if q:
                a = st
                for axis, c in enumerate(counts):
                    a = shift_axis(a, c, cap, axis)
                new += q * a
        st = new
    if k == 1:
        return float(st[cap])
    return float(st[cap, :].sum() + st[:cap, cap].sum())


def part2():
    print("(2) Remark 7.10(a): a batch of r runs")
    g = 0.002
    eps = math.e ** 2 * g
    L, b, dp = 20, 1, 0.01
    need = b * math.log(2) + math.log(1 / dp)
    types = [(g, (L,)), (1 - g, (0,))]
    r = 33
    p = refusal_probability(types, r, eps * r * L)
    print(f"    the counterexample of the check report: gamma={g}, eps=e^2*gamma={eps:.4f}, L={L}, r={r}: "
          f"eps*m={eps * r * L:.2f} >= {need:.2f}, Pr[refusal]={p:.4f} (1-(1-gamma)^r={1 - (1 - g) ** r:.4f}) > delta'={dp}")
    r = math.ceil(need / eps)
    p = refusal_probability(types, r, eps * r * L)
    print(f"    the same with r={r} (eps*r={eps * r:.2f} >= {need:.2f}): Pr[refusal]={p:.2e} <= delta'={dp}; "
          f"bound e^(-eps*r)={math.exp(-eps * r):.2e}")
    # random instances, runs of exactly L calls
    worst_kl = worst_simple = 0.0
    cases = viol = 0
    for inst in range(400):
        L = random.choice([2, 3, 5, 8, 20])
        k = random.choice([1, 2])
        ntypes = random.choice([2, 3, 4])
        small = random.uniform(0.002, 0.02)
        probs = [random.random() for _ in range(ntypes)]
        s = sum(probs)
        probs = [small * q / s for q in probs]
        types = [(1 - small, tuple([0] * k))]
        for q in probs:
            if random.random() < 0.5:           # a run that lies in a disagreement set with all its calls, or not at all
                counts = tuple(random.choice([0, L]) for _ in range(k))
            else:
                counts = tuple(random.randint(0, L) for _ in range(k))
            types.append((q, counts))
        pc = [sum(q * c[i] for q, c in types) / L for i in range(k)]
        if max(pc) <= 0:
            continue
        eps = math.e ** 2 * max(pc) * random.choice([1.0, 1.0, 1.5, 3.0])
        if eps >= 1 or eps < 0.004:
            continue
        for target in (1.0, 2.5, 5.0):
            r = max(1, math.ceil(target / eps))
            if (math.floor(eps * r * L) + 2) ** k > 20000:
                continue
            p = refusal_probability(types, r, eps * r * L)
            bound_kl = sum(math.exp(-r * kl(eps, q)) for q in pc if q > 0)
            bound_simple = sum(1 for q in pc if q > 0) * math.exp(-eps * r)
            cases += 1
            if p > bound_kl * (1 + 1e-9) or bound_kl > bound_simple * (1 + 1e-9):
                viol += 1
            worst_kl = max(worst_kl, p / bound_kl)
            worst_simple = max(worst_simple, p / bound_simple)
    print(f"    runs of exactly L calls, {cases} (instance, r) cases with eps >= e^2*max_c P(Delta(c)): violations of "
          f"Pr[refusal] <= sum_c exp(-r*kl(eps||p_c)) <= (number of members)*e^(-eps*r): {viol}")
    print(f"    largest Pr[refusal]/sum_c exp(-r*kl): {worst_kl:.4f}; largest Pr[refusal]/((number of members)*e^(-eps*r)): {worst_simple:.4f}")
    # runs of different lengths: the form with eps*r fails
    g = 0.002
    eps = math.e ** 2 * g
    for L in (6, 20):
        r = math.ceil(need / eps)
        # a long run: L calls, all in Delta(c), probability g; a short run: one call outside Delta(c).
        # P_Pi(Delta(c)) = g.  With j long runs the batch has m = j*L + (r - j) calls.
        p = 0.0
        for j in range(0, r + 1):
            m = j * L + (r - j)
            if j * L > eps * m:
                p += math.comb(r, j) * g ** j * (1 - g) ** (r - j)
        print(f"    runs of different lengths (L calls in Delta(c) with probability {g}, else one call outside), L={L}, r={r}: "
              f"eps*r={eps * r:.2f} >= {need:.2f}, yet Pr[refusal]={p:.4f} > delta'={dp}")


# ------------------------------------------------------------------------------------------------
def part3():
    print("(3) Remark 7.8(ii): the rock as a rate, exhaustively (4 inputs with two answers, h and up to 3 other members in every order, m <= 5)")
    k = 4
    # h is the zero function; a member is the bit mask of the inputs at which it differs from h
    cases = viol_rock = viol_item1 = attained = 0
    batches = []
    for m in range(1, 6):
        for cnt in multisets(k, m):
            tot = [sum(cnt[x] for x in range(k) if mask >> x & 1) for mask in range(16)]
            batches.append((m, tot))
    for size in (1, 2, 3):
        for others in itertools.permutations(range(1, 16), size):
            members = (0,) + others
            pair_masks = [g1 ^ g2 for g1, g2 in itertools.combinations(members, 2)]
            for m, tot in batches:
                for thr in range(0, m + 1):          # thr = floor(eps*m); "more than eps*m" is "more than thr"
                    alive = 15
                    while True:
                        for c in others:              # the first member above the threshold is taken
                            if tot[c & alive] > thr:
                                alive &= ~c
                                break
                        else:
                            break
                    cases += 1
                    for d in pair_masks:
                        a = tot[d & alive]
                        if a > 2 * thr:
                            viol_rock += 1
                        elif a == 2 * thr and thr > 0:
                            attained += 1
                    for c in others:                  # item 1 with every member as the human
                        if tot[c & alive] > thr:
                            viol_item1 += 1
    print(f"    (V, batch, floor(eps*m)) cases: {cases}; more than 2*floor(eps*m) answered positions in a set on which "
          f"two members differ everywhere: {viol_rock}; the bound attained in {attained} (pair, case) instances; "
          f"violations of item 1: {viol_item1}")


# ------------------------------------------------------------------------------------------------
def part4():
    print("(4) Example 7.9(b): runs of a batch that contain a wrong answer")
    cases = viol = 0
    worst = 0.0
    for inst in range(4000):
        k = random.choice([4, 5, 6])
        allf = list(itertools.product(range(2), repeat=k))
        V = random.sample(allf, random.choice([2, 3, 4, 6]))
        h = V[0]
        L = random.choice([1, 2, 3])
        r = random.choice([1, 2, 3, 5, 8])
        runs = [[random.randrange(k) for _ in range(L)] for _ in range(r)]
        cnt = [0] * k
        for run in runs:
            for x in run:
                cnt[x] += 1
        m = r * L
        for eps in (Fraction(1, 10), Fraction(1, 4), Fraction(1, 2), Fraction(3, 4)):
            alive, steps = bat(V, h, cnt, eps * m)
            for f in V:                                # every member of V as the human
                bad_runs = sum(1 for run in runs if any(alive[x] and h[x] != f[x] for x in run))
                wrong = sum(cnt[x] for x in range(k) if alive[x] and h[x] != f[x])
                cases += 1
                if bad_runs > wrong or wrong > eps * m or bad_runs > eps * L * r:
                    viol += 1
                if eps * m >= 1:
                    worst = max(worst, bad_runs / math.floor(eps * m))
    print(f"    cases {cases}; violations of (runs with a wrong answer) <= (wrong answers) <= eps*m = eps*L*r: {viol}; "
          f"largest (runs with a wrong answer)/floor(eps*m): {worst:.3f}")


# ------------------------------------------------------------------------------------------------
def part5():
    print("(5) Example 7.9(c): three rules on a stream that begins with eps*m copies of the input 0")
    N, n, m, eps = 1000, 100, 2000, 0.05
    k0 = int(eps * m)
    for seed in (11, 12):
        rnd = random.Random(seed)
        asked = {rnd.randint(1, N) for _ in range(n)}
        draws = [rnd.randint(1, N) for _ in range(m - k0)]
        stream = [0] * k0 + draws
        # members: h = 0 and c_i = 1 on {0, i} for i not asked.  Delta(c_i) = {0, i}.
        # (i) the obvious rule: count[i] = answered inputs in Delta(c_i); answer unless a member that
        #     differs at the input has reached floor(eps*m).
        zeros_answered = 0
        own = defaultdict(int)
        refused_draws = answered = 0
        for z in stream:
            if z == 0:
                if zeros_answered < k0:        # every count is zeros_answered + own[i] >= zeros_answered
                    full = any(zeros_answered + own[i] >= k0 for i in own)
                    if not full:
                        zeros_answered += 1
                        answered += 1
            elif z in asked:
                answered += 1
            else:
                if zeros_answered + own[z] >= k0:
                    refused_draws += 1
                else:
                    own[z] += 1
                    answered += 1
        # (ii) the batch rule
        mult = defaultdict(int)
        for z in draws:
            mult[z] += 1
        thr = eps * m
        steps = 0
        zeros_alive = True
        refused_batch = 0
        dead = set()
        while True:
            cand = [i for i in sorted(mult) if i not in asked and i not in dead
                    and (k0 if zeros_alive else 0) + mult[i] > thr]
            if not cand:
                break
            i = cand[0]
            steps += 1
            refused_batch += (k0 if zeros_alive else 0) + mult[i]
            zeros_alive = False
            dead.add(i)
        # (iii) the rule that refuses where two or more members differ from h
        unasked_members = N - len(asked)
        cnt3 = defaultdict(int)
        refused3_zeros = refused3_draws = 0
        for z in stream:
            if z == 0:
                if unasked_members >= 2:
                    refused3_zeros += 1
                # (with fewer than two members the single one would be counted; not the case here)
            elif z in asked:
                pass
            else:
                if cnt3[z] < k0:
                    cnt3[z] += 1
                else:
                    refused3_draws += 1
        unasked_draws = sum(1 for z in draws if z not in asked)
        print(f"    seed {seed}: N={N}, n={n}, m={m}, eps={eps}: P-mass of the unasked inputs {1 - len(asked) / N:.3f}; "
              f"unasked among the {m - k0} draws: {unasked_draws}")
        print(f"      obvious rule: refuses {refused_draws} of the {m - k0} draws; batch rule: {steps} step(s), refuses {refused_batch} "
              f"positions ({k0} copies of 0 and {refused_batch - k0} draws); rule (iii): refuses {refused3_zeros} copies of 0 and {refused3_draws} draws")
    # soundness of rule (iii), exhaustively: functions on 3 inputs with two answers, V of 2 to 4 members,
    # every member as the human, every ordered stream of length <= 5, every threshold
    k = 3
    allf = list(itertools.product(range(2), repeat=k))
    cases = viol = 0
    for size in (2, 3, 4):
        for V in itertools.combinations(allf, size):
            for h in V:
                diffs = {x: [c for c in V if c[x] != h[x]] for x in range(k)}
                for m in range(1, 6):
                    for stream in itertools.product(range(k), repeat=m):
                        for thr in range(0, m + 1):
                            count = defaultdict(int)
                            answered = []
                            for z in stream:
                                d = diffs[z]
                                if len(d) >= 2:
                                    continue
                                if len(d) == 1:
                                    if count[d[0]] >= thr:
                                        continue
                                    count[d[0]] += 1
                                answered.append(z)
                            for f in V:
                                cases += 1
                                if sum(1 for z in answered if h[z] != f[z]) > thr:
                                    viol += 1
    print(f"    soundness of rule (iii): {cases} (V, h, human, stream, threshold) cases; more than floor(eps*m) wrong answers in {viol}")


# ------------------------------------------------------------------------------------------------
def part6():
    print("(6) Remark 7.8(ii): after the audit")
    V = [(1, 0, 0, 0), (1, 1, 1, 0), (0, 0, 0, 1), (1, 1, 0, 0)]
    f = (1, 1, 0, 0)
    batch = [3, 1, 2, 2, 2, 1]
    k, m = 4, len(batch)
    eps = Fraction(1, 2)
    cnt = [batch.count(x) for x in range(k)]
    alive, steps = bat(V, V[0], cnt, eps * m)
    before = sum(cnt[x] for x in range(k) if alive[x])
    V2 = [c for c in V if c[3] == f[3]]                 # the audit asked input 3
    within = all(sum(cnt[x] for x in range(k) if c[x] != f[x]) <= eps * m for c in V2)
    alive2, steps2 = bat(V2, V2[0], cnt, eps * m)
    after = sum(cnt[x] for x in range(k) if alive2[x])
    alive3, steps3 = bat(V2, V2[0], cnt, 2 * eps * m)
    print(f"    the instance of the attack report: answered before the audit {before}/{m}; after the audit of input 3 every "
          f"member that fits is within eps*m of the human: {within}; Bat_eps run again answers {after}/{m}; "
          f"Bat_(2 eps) makes {len(steps3)} step(s)")
    # in general: if every member that fits is within eps*m of the human, Bat_(2 eps) makes no step
    cases = viol = refuse_again = 0
    k = 4
    allf = list(itertools.product(range(2), repeat=k))
    for inst in range(20000):
        V = random.sample(allf, random.choice([2, 3, 4, 5]))
        f = random.choice(V)
        m = random.choice([2, 3, 4, 6, 8])
        cnt = [0] * k
        for _ in range(m):
            cnt[random.randrange(k)] += 1
        eps = random.choice([Fraction(1, 4), Fraction(1, 3), Fraction(1, 2)])
        if all(sum(cnt[x] for x in range(k) if c[x] != f[x]) <= eps * m for c in V):
            cases += 1
            for h in V:
                _, st = bat(V, h, cnt, 2 * eps * m)
                if st:
                    viol += 1
                _, st1 = bat(V, h, cnt, eps * m)
                if st1:
                    refuse_again += 1
    print(f"    random instances in which every member is within eps*m of the human: {cases}; Bat_(2 eps) makes a step in {viol} "
          f"(V, h) cases; Bat_eps makes a step in {refuse_again}")


# ------------------------------------------------------------------------------------------------
def part7():
    print("(7) Remark 7.8(ii): comparisons")
    # the Occam count: Pr[some member of H_b that fits differs from f on mass above t], exact, t = (b ln 2 + ln(1/delta))/n
    worst = 0.0
    checks = 0
    for inst in range(200):
        k = random.choice([3, 4])
        allf = list(itertools.product(range(2), repeat=k))
        size = random.choice([2, 3, 4, 6])
        Hb = random.sample(allf, size)
        f = random.choice(Hb)
        b = math.log2(size)
        w = [random.randint(1, 4) for _ in range(k)]
        P = [Fraction(wi, sum(w)) for wi in w]
        n = random.choice([2, 4, 6, 9])
        law = asked_set_law(P, n)
        for delta in (0.5, 0.2, 0.05):
            t = (b * math.log(2) + math.log(1 / delta)) / n
            pr_bad = Fraction(0)
            for A, pr in law.items():
                for c in Hb:
                    if all(c[x] == f[x] for x in range(k) if A >> x & 1):
                        if float(mass(P, [x for x in range(k) if c[x] != f[x]])) > t:
                            pr_bad += pr
                            break
            checks += 1
            worst = max(worst, float(pr_bad) / delta)
    print(f"    without abstention: {checks} exact checks of Pr[a member that fits differs from the human on mass above "
          f"(b ln 2 + ln(1/delta))/n] < delta; largest ratio to delta {worst:.4f}")
    # frozen enumeration on the point functions: the refused mass is the mass of the unasked inputs
    b = 16
    N = 2 ** b - 1
    rnd = random.Random(5)
    for n in (1000, 10000, 60000):
        asked = {rnd.randrange(N) for _ in range(n)}
        gamma = (2 * b * math.log(2) + math.log(10)) / n
        print(f"    point functions, b={b} (N={N} inputs, uniform law, the zero function as the human), n={n}: frozen enumeration refuses "
              f"mass {1 - len(asked) / N:.4f} (at least 1 - n/N = {1 - n / N:.4f}); Bat_eps with eps=0.1 and h the zero function refuses "
              f"at most 9 inputs, of mass 9/N = {9 / N:.1e}, for every batch (bound gamma/eps = {min(1.0, gamma / 0.1):.3f}, delta = 0.1)")
    # prices
    print("    price for a refused mass of at most eps' = 0.01 at b = 30, delta = 0.05: Corollary 7.7 with item 3, and with item 3a")
    b, delta, e2 = 30, 0.05, 0.01
    for eps in (1.0, 0.5, 0.1, 0.01):
        n3 = (2 * b * math.log(2) + math.log(1 / delta)) / (eps * e2)
        n3a = (math.ceil(1 / eps - 1e-12) * b * math.log(2) + math.log(2 / delta)) / e2
        print(f"      eps={eps:<5} item 3: n={n3:10.0f}   item 3a: n={n3a:10.0f}   ratio {n3 / n3a:.3f}")
    # the bound of Ab2(d) with alpha = 2^(-K)
    K, L, delta = 20, 10, 0.05
    alpha = 2.0 ** (-K)
    term = L * (K * math.log(2) + math.log(1 / (alpha * delta))) / alpha
    print(f"    Ab2(d), deterministic human, alpha=2^(-K), K={K}, L={L}, delta={delta}: the third term is {term:.3e}/n, "
          f"that is {term / (L * K * 2 ** K):.3f} * L*K*2^K / n")


if __name__ == "__main__":
    part1()
    part2()
    part3()
    part4()
    part5()
    part6()
    part7()
    print("done")
