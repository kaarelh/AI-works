"""Editor's checks of the referee round for part one-mind (proofs/one-mind.md, Section 10.5), 28 November 2026.

The referee round changed the text of Section 5.1 of the note and no statement of the proof file.
Three passages of the new text contain steps or numbers that are not printed in that form in the
proof file. This script checks them. It shares no code with the earlier scripts of this part.
Everything is exact: rational arithmetic (fractions) or full enumeration; the random number
generator only draws the instances.

Parts
  V1  The proof of R4 as printed in the note. On random instances (a scaffold whose questions depend
      on the answers, runs of different lengths, a deterministic human, hypotheses that answer at
      random, an arbitrary posterior) and for every top-level input z:
        E[m | z]  >=  (1/L) * sum_j p_j * (1 - p_1 - ... - p_{j-1})
                   =  (1/L) * (u - u^2/2 + sum_j p_j^2 / 2)
                  >=  u * (L + 1) / (2 L^2),
      where p_j is the probability that the run of a posterior draw first goes wrong at call j,
      u = sum_j p_j, and m is the probability that the mixture gives to a wrong answer at the
      asked question (0 if the run has no call with the drawn index).  E[m | z] is computed by
      enumeration of the draw, of all its answers and of the asked index.  Control: the number of
      cases in which the stronger claim E[m | z] >= u/L would be false.
  V2  The summary sentence of R5 in the note: "a run answered by the committee has two or more
      unfaithful calls with probability at most 2 (L/n)^2".
      Class A (N = n, K = 1): exact probability by a dynamic programme over the calls, for every
      number k of surviving traps; compared with (L/n)^2 / 2 (Proposition 4.2(b)) and 2 (L/n)^2.
      Class B (N = 2n): exact probability for the posterior that is uniform on s >= n members,
      the human among them; compared with L/(2 n^2) + (3L/(2n))^2 / 2 (Proposition 4.3(b), m = 1)
      and with 2 (L/n)^2.
  V3  The example after R4 (Example 3.1) at a question that was not asked before: the law of the
      three answers of a posterior draw (the human with probability 1/2, a filled-in function
      otherwise) is at total variation (3/2) eps (1 - eps) from the human system's, and the three
      answers of one function are at total variation 1 - (1 - eps)^3 or 1 - eps^3.
  V4  Arithmetic of the sentences that quote bounds: the constants 56 and 80 of the form of R6(c)
      in total variation; the bounds of R1 and R4 in the class of L + 1 functions of R6(a).

Run:  python3 one-mind_referee_round.py > one-mind_referee_round.out     (a few seconds)
"""
import itertools
import math
import random
from fractions import Fraction as F

FAILED = []


def check(cond, what):
    if not cond:
        FAILED.append(what)
        print("   !!! FAILED:", what)


# --------------------------------------------------------------------------------------------
# V1.  The printed proof of R4
# --------------------------------------------------------------------------------------------
def random_instance(rng, nz, nx, na, L, nh):
    """Scaffold: nxt[(z, answers so far)] is an input in range(nx) or None (stop).
    Human: a function f on the inputs.  Hypotheses: nh random samplers with rational entries.
    Posterior: random rational weights that add up to 1."""
    nxt = {}
    for z in range(nz):
        for d in range(L):
            for ys in itertools.product(range(na), repeat=d):
                if d > 0 and nxt.get((z, ys[:-1])) is None:
                    nxt[(z, ys)] = None
                else:
                    stop = d > 0 and rng.random() < 0.25
                    nxt[(z, ys)] = None if stop else rng.randrange(nx)
    f = [rng.randrange(na) for _ in range(nx)]
    hyps = []
    for _ in range(nh):
        kind = rng.random()
        h = []
        for x in range(nx):
            if kind < 0.3:                      # a function
                y = rng.randrange(na)
                row = [F(int(a == y)) for a in range(na)]
            elif kind < 0.6:                    # the human, perturbed
                e = F(rng.randrange(0, 4), 8)
                other = rng.choice([a for a in range(na) if a != f[x]])
                row = [F(0)] * na
                row[f[x]] = 1 - e
                row[other] += e
            else:                               # a random sampler
                cuts = sorted(rng.randrange(0, 9) for _ in range(na - 1))
                parts = [cuts[0]] + [cuts[i] - cuts[i - 1] for i in range(1, na - 1)] + [8 - cuts[-1]]
                row = [F(c, 8) for c in parts]
            h.append(row)
        hyps.append(h)
    raw = [F(rng.randrange(1, 10)) for _ in range(nh)]
    tot = sum(raw)
    post = [r / tot for r in raw]
    return nxt, f, hyps, post


def part_v1():
    print("V1. The proof of R4 as printed in the note")
    rng = random.Random(20261128)
    cases = 0
    worst_first = None      # smallest value of E[m|z] - (1/L) sum_j p_j (1 - sum_{i<j} p_i)
    worst_last = None       # smallest value of (1/L)(...) - u (L+1)/(2 L^2)
    equal_first = 0
    control = 0             # cases in which the stronger claim E[m|z] >= u/L would be false
    for _ in range(400):
        L = rng.choice([1, 2, 3, 4])
        nz, nx, na, nh = rng.choice([2, 3]), rng.choice([2, 3, 4]), rng.choice([2, 3]), rng.choice([2, 3, 5])
        nxt, f, hyps, post = random_instance(rng, nz, nx, na, L, nh)
        # the mixture's probability of a wrong answer at each input
        ebar = [sum(post[i] * (1 - hyps[i][x][f[x]]) for i in range(nh)) for x in range(nx)]
        for z in range(nz):
            # the human system's run on z
            xs, ys = [], ()
            while len(ys) < L and nxt[(z, ys)] is not None:
                x = nxt[(z, ys)]
                xs.append(x)
                ys = ys + (f[x],)
            Tf = len(xs)
            # p_j: the run of a posterior draw first goes wrong at call j (j = 1 .. Tf)
            p = []
            for j in range(Tf):
                pj = F(0)
                for i in range(nh):
                    right_before = F(1)
                    for x in xs[:j]:
                        right_before *= hyps[i][x][f[x]]
                    pj += post[i] * right_before * (1 - hyps[i][xs[j]][f[xs[j]]])
                p.append(pj)
            u = sum(p, F(0))
            # E[m | z] by enumeration of the draw, of its answers and of the asked index
            Em = F(0)
            u_direct = F(0)
            for i in range(nh):
                stack = [((), F(1))]
                while stack:
                    ys, pr = stack.pop()
                    if pr == 0:
                        continue
                    if len(ys) == L or nxt[(z, ys)] is None:
                        # a complete run of hypothesis i with probability pr
                        inputs = [nxt[(z, ys[:d])] for d in range(len(ys))]
                        wrong = any(ys[d] != f[inputs[d]] for d in range(len(ys)))
                        if wrong or len(ys) != Tf:
                            u_direct += post[i] * pr
                        for J in range(1, L + 1):
                            if J <= len(ys):
                                Em += post[i] * pr * F(1, L) * ebar[inputs[J - 1]]
                        continue
                    x = nxt[(z, ys)]
                    for a in range(na):
                        stack.append((ys + (a,), pr * hyps[i][x][a]))
            check(u_direct == u, "V1: u is the probability that the draw's run is not the human system's run")
            mid = F(1, L) * sum((p[j] * (1 - sum(p[:j], F(0))) for j in range(Tf)), F(0))
            mid2 = F(1, L) * (u - u * u / 2 + sum((q * q for q in p), F(0)) / 2)
            low = u * (L + 1) / (2 * L * L)
            check(Em >= mid, "V1: E[m|z] >= (1/L) sum_j p_j (1 - p_1 - ... - p_{j-1})")
            check(mid == mid2, "V1: the identity for the middle expression")
            check(mid >= low, "V1: the middle expression is at least u (L+1)/(2 L^2)")
            check(sum((q * q for q in p), F(0)) * L >= u * u, "V1: sum p_j^2 >= u^2 / L")
            cases += 1
            d1, d2 = Em - mid, mid - low
            equal_first += int(d1 == 0)
            control += int(Em < u / L)
            worst_first = d1 if worst_first is None else min(worst_first, d1)
            worst_last = d2 if worst_last is None else min(worst_last, d2)
    print(f"   {cases} pairs (instance, top-level input); L from 1 to 4; hypotheses: functions, perturbed humans, samplers")
    print(f"   smallest E[m|z] - (1/L) sum_j p_j (1 - sum_(i<j) p_i): {float(worst_first):.6f}  (equal in {equal_first} cases)")
    print(f"   smallest (1/L) sum_j p_j (1 - sum_(i<j) p_i) - u (L+1)/(2 L^2): {float(worst_last):.6f}")
    print(f"   control: the stronger claim E[m|z] >= u/L is false in {control} of the {cases} cases")


# --------------------------------------------------------------------------------------------
# V2.  The summary sentence of R5
# --------------------------------------------------------------------------------------------
def at_least_two(L, steps):
    """steps(flag) -> list of (probability, unfaithful?, new flag).  Flags are small labels.
    Returns Pr[at least two unfaithful calls in L calls], exactly."""
    dist = {("empty", 0): F(1)}
    for _ in range(L):
        new = {}
        for (flag, c), pr in dist.items():
            for q, bad, nf in steps(flag):
                key = (nf, min(2, c + int(bad)))
                new[key] = new.get(key, F(0)) + pr * q
        dist = new
    check(sum(dist.values()) == 1, "V2: the dynamic programme keeps total probability 1")
    return sum((pr for (flag, c), pr in dist.items() if c == 2), F(0))


def part_v2():
    print("V2. The committee has two or more unfaithful calls with probability at most 2 (L/n)^2")
    # Class A: g_0 has posterior mass N/(N+k), each of the k surviving traps 1/(N+k); the human is g_0.
    worstA_prop, worstA_two, casesA = F(0), F(0), 0
    for n in (100, 144, 225, 400, 900):
        N = n
        for L in sorted({1, 2, 3, 5, 8, math.isqrt(n) // 2, math.isqrt(n)}):
            for k in sorted({0, 1, 2, N // 4, N // 2, N - 1, N}):
                def steps(flag, N=N, k=k):
                    if flag == "empty":
                        hit = F(k, N) * F(1, N + k)       # the symbol is a surviving trap and the draw is that trap
                        return [(hit, True, "trap"), (1 - hit, False, "empty")]
                    return [(F(1, N + k), True, "trap"), (1 - F(1, N + k), False, "trap")]
                pr = at_least_two(L, steps)
                b_prop = F(L, n) ** 2 / 2
                b_two = 2 * F(L, n) ** 2
                check(pr <= b_prop, f"V2: class A, n={n}, L={L}, k={k}: Proposition 4.2(b) with m = 1")
                check(pr <= b_two, f"V2: class A, n={n}, L={L}, k={k}: at most 2 (L/n)^2")
                worstA_prop = max(worstA_prop, pr / b_prop)
                worstA_two = max(worstA_two, pr / b_two)
                casesA += 1
    print(f"   class A: {casesA} cases (n from 100 to 900, L <= sqrt(n), every tested number of surviving traps)")
    print(f"      largest ratio to (L/n)^2/2: {float(worstA_prop):.4f};  to 2 (L/n)^2: {float(worstA_two):.4f}")
    # Class B: N = 2n; the posterior is uniform on s >= n traps, the human g_a* among them (or it is the human alone).
    worstB_prop, worstB_two, casesB = F(0), F(0), 0
    for n in (16, 20, 32, 50, 64, 100):
        N = 2 * n
        for L in sorted({1, 2, 3, 4, 8, n // 2, n}):
            for s in sorted({n, n + 1, (3 * n) // 2, N - 1, N}):
                def steps(flag, N=N, s=s):
                    if flag == "empty":
                        return [
                            (F(1, N) * F(1, s), False, "human"),          # symbol a*, the draw is the human: right, flag a*
                            (F(1, N) * (1 - F(1, s)), True, "empty"),     # symbol a*, another draw answers 0: wrong
                            (F(s - 1, N) * F(1, s), True, "other"),       # a surviving trap is drawn at its own symbol: wrong
                            (F(s - 1, N) * (1 - F(1, s)), False, "empty"),
                            (F(N - s, N), False, "empty"),                # a refuted trap's symbol: every survivor answers 0
                        ]
                    if flag == "human":                                   # the human answers 1 at every later call
                        return [(F(1, s), False, "human"), (1 - F(1, s), True, "human")]
                    return [(F(1, s), True, "other"), (1 - F(1, s), False, "other")]
                pr = at_least_two(L, steps)
                b_prop = F(L, 2 * n * n) + F(3 * L, 2 * n) ** 2 / 2
                b_two = 2 * F(L, n) ** 2
                check(pr <= b_prop, f"V2: class B, n={n}, L={L}, s={s}: Proposition 4.3(b) with m = 1")
                check(pr <= b_two, f"V2: class B, n={n}, L={L}, s={s}: at most 2 (L/n)^2")
                check(b_prop <= b_two, f"V2: class B, n={n}, L={L}: the bound of the proposition is at most 2 (L/n)^2")
                worstB_prop = max(worstB_prop, pr / b_prop)
                worstB_two = max(worstB_two, pr / b_two)
                casesB += 1
    print(f"   class B: {casesB} cases (n from 16 to 100, L <= n, s surviving members from n to 2n)")
    print(f"      largest ratio to L/(2n^2) + (3L/(2n))^2/2: {float(worstB_prop):.4f};  to 2 (L/n)^2: {float(worstB_two):.4f}")
    # the inequality between the bounds, for all L >= 1:  L/(2n^2) + (9/8)(L/n)^2 <= (13/8)(L/n)^2
    ok = all(F(L, 2 * n * n) + F(9, 8) * F(L, n) ** 2 <= F(13, 8) * F(L, n) ** 2
             for n in range(16, 200) for L in range(1, n + 1))
    check(ok, "V2: L/(2n^2) + (9/8)(L/n)^2 <= (13/8)(L/n)^2 for 1 <= L <= n")
    print("   L/(2n^2) + (9/8)(L/n)^2 <= (13/8)(L/n)^2 for all 16 <= n < 200, 1 <= L <= n:", ok)


# --------------------------------------------------------------------------------------------
# V3.  The example after R4 at a question not asked before
# --------------------------------------------------------------------------------------------
def part_v3():
    print("V3. The example after R4 at a question not asked before")
    for eps in (F(1, 100), F(1, 10), F(1, 4), F(1, 3), F(1, 2)):
        pr1 = 1 - eps                                        # the human answers 1 ("right") with probability 1 - eps
        human = {}
        for ys in itertools.product((0, 1), repeat=3):
            q = F(1)
            for y in ys:
                q *= pr1 if y == 1 else eps
            human[ys] = q
        filled = {ys: F(0) for ys in human}                  # a posterior draw from the functions: (c, c, c), c ~ P
        filled[(1, 1, 1)] = pr1
        filled[(0, 0, 0)] = eps
        draw = {ys: (human[ys] + filled[ys]) / 2 for ys in human}
        tv = sum(abs(draw[ys] - human[ys]) for ys in human) / 2
        check(tv == F(3, 2) * eps * (1 - eps), f"V3: eps={eps}: TV of the draw's run is (3/2) eps (1 - eps)")
        tv1 = 1 - human[(1, 1, 1)]                           # a function that answers 1
        tv0 = 1 - human[(0, 0, 0)]                           # a function that answers 0
        check(tv1 == 1 - (1 - eps) ** 3 and tv0 == 1 - eps ** 3, f"V3: eps={eps}: TV of a function's run")
        check(min(tv1, tv0) >= 1 - (1 - eps) ** 3, f"V3: eps={eps}: at least 1 - (1 - eps)^3 for eps <= 1/2")
        print(f"   eps = {str(eps):>5}: TV(draw) = {float(tv):.6f} = (3/2) eps (1-eps);  TV(function) = {float(tv1):.6f} or {float(tv0):.6f}")


# --------------------------------------------------------------------------------------------
# V4.  Arithmetic
# --------------------------------------------------------------------------------------------
def part_v4():
    print("V4. Arithmetic of quoted bounds")
    check(2 * 28 == 56 and 2 * 40 == 80, "V4: TV <= sqrt(2 H^2) turns 28 and 40 into 56 and 80")
    print("   TV <= sqrt(2 H^2): 2*28 = 56, 2*40 = 80")
    for L in (1, 2, 8, 100):
        K = math.log2(L + 1)
        r1 = L * K * math.log(2.0)
        r4 = 2 * L * L / (L + 1) * K * math.log(2.0)
        check(abs(r1 - L * math.log(L + 1)) < 1e-9 and abs(r4 - 2 * L * L / (L + 1) * math.log(L + 1)) < 1e-9,
              "V4: R1 and R4 with K = log2(L+1)")
        check(r4 < 2 * r1 + 1e-12 and (L > 1 or abs(r4 - r1) < 1e-12), "V4: the bound of R4 is less than twice that of R1")
        print(f"   L = {L:>3}: L ln(L+1) = {r1:9.3f}, (2L^2/(L+1)) ln(L+1) = {r4:9.3f}, driver bound L^2 = {L * L}")


if __name__ == "__main__":
    part_v1()
    part_v2()
    part_v3()
    part_v4()
    print()
    print("FAILED CHECKS:", len(FAILED))
    for w in FAILED:
        print("  ", w)
