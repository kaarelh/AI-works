"""Checks of the editor of the part "assumptions" in the referee round (28 November 2026).

Usage: python3 proofs/code/assumptions_editor_referee.py > proofs/code/assumptions_editor_referee.out

The script shares no code with the other scripts of this part. It checks the numbers and the small
arguments that the referee round put into the text of the note (research/sections/assumptions.md):

  block 1  the table and the counts of Section 9.1, the numbers of the paragraph on additive work
  block 2  the break-even numbers of test 5 (objection O22 of the proof file)
  block 3  Theorem I1 (Theorem 7.4(a) of the proof file): where its bound is below 1, the number of
           rounds for a failure probability delta, and, by exact enumeration of the protocol with one
           posterior draw per run, the one-round inequality that the printed idea states and the
           theorem itself
  block 4  the constant 1/16 of the two lower bounds in "What survives"
  block 5  the arithmetic of the example for the imitator built from tests (Pr6(b))
  block 6  the floors of Examples 3.3 and 3.3a as the note quotes them, and the count of Corollary 3.2'
  block 7  coverage (R7) for an imitator that is not a mixture: a rule computed from the recorded answers,
           as the imitator built from tests is; exact, for every set Q of inputs

Everything is exact (closed forms, or enumeration with rational arithmetic) except the choice of the
random instances of blocks 3 and 7, which is seeded.
"""
import itertools
import math
import random
from fractions import Fraction

LN2 = math.log(2.0)


def block1():
    print("== block 1: Section 9.1 of the note")
    theta = delta = 0.1
    rows = [("a working life of 1e5 hours, an hour per answer", 1e5),
            ("50 years, a year per answer", 50.0),
            ("1e4 people for a year, a year per answer", 1e4),
            ("1e6 people for 2000 hours, an hour per answer", 2e9)]
    for name, n in rows:
        print(f"  {name:48s} n = {n:10.3g}   K paid for = n theta delta / ln 2 = {n * theta * delta / LN2:.4g} bits")
    K = 1e9
    n = K * LN2 / (theta * delta)
    print(f"  K = 1e9, theta = delta = 0.1: n = K ln 2/(theta delta) = {n:.4g} answers = {n / 2000:.4g} years of 2000 hours")
    print(f"  a human who is not deterministic: K ln 2/(2 theta^2 delta^2) = {LN2 / (2 * theta**2 * delta**2):.4g} K")
    print(f"  certificate at confidence 0.95: ln 20/(theta delta) = {math.log(20) / (theta * delta):.2f}, so 300 answers")
    print(f"  twenty batches one after another: K <= 20 theta delta/ln 2 = {20 * theta * delta / LN2:.4f} bits")
    print("  additive work (Proposition 6.4), theta = k/L = 0.1, delta = 0.1:")
    c = 1 - 2 * 0.1 - 2 * 0.1
    print(f"    lower bound (1 - 2k/L - 2 delta) K = {c:.1f} K;  50 answers serve at most K = 50/{c:.1f} = {50 / c:.1f} bits")
    print(f"    bound of R3, K ln 2/(theta delta) = {LN2 / (theta * delta):.1f} K")


def block2():
    print("== block 2: break-even for one run (test 5; O22)")
    theta = delta = 0.1
    for K in (30, 1e3, 1e6, 1e9):
        need = (K * LN2 + math.log(20)) / (theta * delta)
        print(f"  K = {K:8.3g}: K ln 2/(theta delta) + ln 20/(theta delta) = {need:.4g} answers;"
              f" fewer than the L answers of one run only if L > {need:.3g}")


def runs_of(scaffold, g, L):
    """For each top-level input z: the list of inputs of the run answered by the function g."""
    out = []
    for tree in scaffold:
        hist = ()
        xs = []
        while len(xs) < L and hist in tree:
            x = tree[hist]
            xs.append(x)
            hist = hist + (g[x],)
        out.append(tuple(xs))
    return out


def random_instance(rng, nx, nz, L, m):
    """A scaffold whose next input depends on z and on the answers so far and which may stop early;
    a class of m functions X -> {0,1} with weights of total at most 1; the human is member 0."""
    scaffold = []
    for _ in range(nz):
        tree = {}
        frontier = [()]
        for depth in range(L):
            nxt = []
            for hist in frontier:
                if depth > 0 and rng.random() < 0.15:
                    continue                      # the run stops here
                tree[hist] = rng.randrange(nx)
                nxt += [hist + (0,), hist + (1,)]
            frontier = nxt
        scaffold.append(tree)
    funcs = []
    while len(funcs) < m:
        g = tuple(rng.randrange(2) for _ in range(nx))
        if g not in funcs:
            funcs.append(g)
    raw = [Fraction(rng.randrange(1, 9)) for _ in range(m)]
    total = sum(raw) * Fraction(rng.choice([1, 1, 2]))      # total weight 1 or 1/2
    w = [r / total for r in raw]
    return scaffold, funcs, w


def block3():
    print("== block 3: Theorem I1 (Theorem 7.4(a))")
    # (i) where the bound 2^K (1 - gamma/(2L))^n is below 1
    r_lo, r_hi = [], []
    for L in (1, 2, 3, 5, 10, 100, 1000):
        for gamma in (1.0, 0.9, 0.5, 0.1, 0.01, 0.001):
            for K in (0.5, 1, 3.78, 30, 1e3, 1e9):
                x = gamma / (2 * L)
                thr = K * LN2 / (-math.log1p(-x))          # the bound is below 1 exactly if n > thr
                lo = (2 * L / gamma - 1) * K * LN2
                hi = (2 * L / gamma) * K * LN2
                assert lo <= thr * (1 + 1e-12) and thr <= hi * (1 + 1e-12)
                r_lo.append(thr / lo)
                r_hi.append(thr / hi)
    print(f"  the bound is below 1 exactly if n > K ln 2/ln(1/(1 - gamma/(2L))); on a grid of {len(r_lo)} triples (L, gamma, K)")
    print(f"    this threshold lies between (2L/gamma - 1) K ln 2 and (2L/gamma) K ln 2:"
          f" its ratio to the first is between {min(r_lo):.4f} and {max(r_lo):.4f}, to the second between {min(r_hi):.4f} and {max(r_hi):.4f}")
    print("    example L = 1, gamma = 1: threshold K, against (2L/gamma - 1) K ln 2 = 0.693 K and (2L/gamma) K ln 2 = 1.386 K")
    # (ii) rounds for failure delta
    bad = 0
    for L in (1, 3, 10, 100):
        for gamma in (1.0, 0.3, 0.01):
            for K in (1, 30, 1e3):
                for d in (0.5, 0.1, 1e-3):
                    n = math.ceil((2 * L / gamma) * (K * LN2 + math.log(1 / d)))
                    val = K * LN2 + n * math.log1p(-gamma / (2 * L))       # ln of the bound
                    if val > math.log(d) + 1e-9:
                        bad += 1
    print(f"  n >= (2L/gamma)(K ln 2 + ln(1/delta)) rounds make the bound at most delta: {bad} violations on a grid of 108 cases")
    # (iii) exact enumeration of the protocol with one posterior draw per run
    rng = random.Random(20261128)
    n_inst = 0
    n_sets = 0
    worst_round = Fraction(0)        # largest E[R']/(R (1 - gamma/(2L))) over all surviving sets
    worst_thm = 0.0                  # largest ratio of the expected posterior weight to the bound of the theorem
    while n_inst < 60:
        L = rng.choice([1, 2, 3])
        nx, nz, m = rng.choice([4, 5, 6]), rng.choice([3, 4, 6]), rng.choice([4, 5, 6, 7])
        scaffold, funcs, w = random_instance(rng, nx, nz, L, m)
        runs = [runs_of(scaffold, g, L) for g in funcs]
        f = funcs[0]
        # run distance D(f, h): the runs differ exactly if h differs from f at an input of the run of f
        D = []
        for h in funcs:
            diff = sum(1 for z in range(nz) if any(h[x] != f[x] for x in runs[0][z]))
            D.append(Fraction(diff, nz))
        off = [i for i in range(m) if D[i] > 0]              # members whose runs differ from the human's
        if not off:
            continue
        gamma = min(D[i] for i in off)
        n_inst += 1
        factor = 1 - gamma / (2 * L)

        def step(S):
            """Law of the surviving set after one round that starts from the surviving set S (a frozenset
            of indices that contains 0): dictionary new set -> probability."""
            WS = sum(w[i] for i in S)
            law = {}
            for g in S:
                pg = w[g] / WS
                for z in range(nz):
                    xs = runs[g][z]
                    for J in range(1, L + 1):
                        p = pg * Fraction(1, nz) * Fraction(1, L)
                        if J <= len(xs):
                            x = xs[J - 1]
                            S2 = frozenset(i for i in S if funcs[i][x] == f[x])
                        else:
                            S2 = S
                        law[S2] = law.get(S2, 0) + p
            return law

        # the one-round inequality on every surviving set that contains the human
        others = list(range(1, m))
        for r in range(len(others) + 1):
            for sub in itertools.combinations(others, r):
                S = frozenset((0,) + sub)
                R = sum(w[i] for i in S if D[i] > 0)
                if R == 0:
                    continue
                law = step(S)
                ER = sum(p * sum(w[i] for i in S2 if D[i] > 0) for S2, p in law.items())
                n_sets += 1
                ratio = ER / (R * factor)
                worst_round = max(worst_round, ratio)
                assert ER <= R * factor, (ER, R, factor)
        # the theorem: expected posterior weight of the members whose runs differ, after n rounds
        K = math.log2(1 / w[0])
        dist = {frozenset(range(m)): Fraction(1)}
        for n in range(1, 13):
            new = {}
            for S, p in dist.items():
                for S2, q in step(S).items():
                    new[S2] = new.get(S2, 0) + p * q
            dist = new
            post = sum(p * sum(w[i] for i in S if D[i] > 0) / sum(w[i] for i in S) for S, p in dist.items())
            bound = 2 ** K * float(factor) ** n
            worst_thm = max(worst_thm, float(post) / bound)
            assert float(post) <= bound * (1 + 1e-12)
    print(f"  exact enumeration on {n_inst} random instances (L <= 3, scaffolds whose inputs depend on the answers,"
          " runs of unequal length, 4 to 7 functions, total weight 1 or 1/2):")
    print(f"    one round started from each of {n_sets} surviving sets: E[weight left on the members whose runs differ]"
          f" <= (1 - gamma/(2L)) times that weight in every case; largest ratio of the two sides {float(worst_round):.4f}")
    print(f"    after n = 1, ..., 12 rounds: expected posterior weight of those members <= 2^K (1 - gamma/(2L))^n in every case;"
          f" largest ratio {worst_thm:.4f}")
    # (iv) the inequality holds on average over the posterior, not for each member: an example
    #      inputs a, b, c; call 1 at a; call 2 at b if the first answer was 0, at c if it was 1 (L = 2, no z)
    a, b, c = 0, 1, 2
    scaffold = [{(): a, (0,): b, (1,): c}]
    f = (0, 0, 0)
    g = (1, 0, 0)            # leaves the human's run at the first call
    h = (0, 1, 0)            # leaves it at the second call
    funcs = [f, g, h]
    e = Fraction(1, 100)
    w = [e, 1 - 2 * e, e]
    runs = [runs_of(scaffold, u, 2) for u in funcs]
    D = [Fraction(int(any(u[x] != f[x] for x in runs[0][0]))) for u in funcs]
    gamma = min(d for d in D if d > 0)
    p_h = Fraction(0)        # probability that h is refuted in the first round
    removed = Fraction(0)    # expected weight removed from the members whose runs differ
    for i, u in enumerate(funcs):
        for J in (1, 2):
            x = runs[i][0][J - 1]
            pr = w[i] * Fraction(1, 2)
            gone = [j for j in range(3) if funcs[j][x] != f[x]]
            if 2 in gone:
                p_h += pr
            removed += pr * sum(w[j] for j in gone if D[j] > 0)
    R = sum(w[j] for j in range(3) if D[j] > 0)
    print("  an example with three functions (weights 0.01 for the human f, 0.98 for g, 0.01 for h; L = 2; both g and h at run distance 1):")
    print(f"    the member h is refuted in the first round with probability {float(p_h):.4f}, far below gamma/(2L) = {float(gamma / 4):.4f};")
    print(f"    the expected weight removed from g and h together is {float(removed):.4f} >= gamma/(2L) times their weight = {float(gamma / 4 * R):.4f}")
    assert p_h < gamma / 4 and removed >= gamma / 4 * R


def block4():
    print("== block 4: the constant 1/16 in 'What survives'")
    worst = None
    cases = 0
    for g in list(range(1, 200)) + [10**3, 10**6]:
        for N in list(range(10 * g, 60 * g + 1, max(1, g // 3))) + [10**3 * g, 10**6 * g]:
            delta = g / (2 * N)                    # N = g/(2 delta) is an integer, delta <= 1/20
            if delta > 1 / 20:
                continue
            lhs = (1 - 10 * delta) / (8 * math.log2(g / (2 * delta)))
            rhs = 1 / (16 * math.log2(g / delta))
            cases += 1
            r = lhs / rhs
            worst = r if worst is None else min(worst, r)
            assert lhs >= rhs
    print(f"  (1 - 10 delta)/(8 log2(g/(2 delta))) >= 1/(16 log2(g/delta)) for delta <= 1/20 and g/(2 delta) an integer:")
    print(f"    {cases} cases, smallest ratio of the two sides {worst:.4f}  (g stands for L in N2b and for the number of units in N8)")


def block5():
    print("== block 5: the imitator built from tests (Pr6(b)), arithmetic of the example in Section 10")
    L, bits = 10, 20
    for per_run in (0.1, 0.01):
        n = L * (bits + 2) / per_run
        print(f"  a test of weight 2^-{bits}, L = {L}: L (log2(1/pi) + 2)/n <= {per_run} calls per run from n = {n:.0f} answers"
              f" ({n / 2000:.2f} years of 2000 hours at an hour per answer)")


def block6():
    print("== block 6: floors quoted in Section 3.7, and the count of Corollary 3.2'")
    for ell, L in ((3, 4), (10, 100), (20, 1000)):
        print(f"  Example 3.3, seed of {ell} bits, L = {L}: (L - 1)/(2^ell + 1) = {(L - 1) / (2**ell + 1):.6g} unfaithful calls per run")
    a = Fraction(1, 32) / (Fraction(1, 2) + Fraction(1, 16))
    print(f"  Example 3.3a, one function g_sigma unrefuted: (1/32)/(1/2 + 1/16) = {a} = {float(a):.4f}; it grows with the number unrefuted:",
          ", ".join(f"{float(Fraction(k, 32) / (Fraction(1, 2) + Fraction(k, 16))):.4f}" for k in range(1, 9)))
    for n, L, dl in ((10**5, 10, 0.05), (10**6, 100, 0.1)):
        k = math.floor(math.log2(dl * n / L))
        print(f"  Corollary 3.2': n = {n}, L = {L}: all properties with a description of at most k = {k} bits are covered at once"
              f" with probability at least 1 - 2^k L/n = {1 - 2**k * L / n:.4f}")


def block7():
    print("== block 7: coverage (R7) for an imitator that is a rule computed from the recorded answers")
    rng = random.Random(20261129)
    worst = Fraction(0)
    n_inst, n_sets = 0, 0
    for _ in range(24):
        L = rng.choice([1, 2, 3])
        nx, nz = 4, rng.choice([2, 3, 4])
        scaffold, funcs, _w = random_instance(rng, nx, nz, L, 2)
        f = funcs[0]                                  # the human, a function; no class is used
        default = funcs[1]                            # what the rule answers where nothing is recorded
        n = rng.choice([4, 5, 6])
        n_inst += 1
        for qmask in range(1, 2 ** nx):
            Q = {x for x in range(nx) if qmask >> x & 1}
            # state: (recorded answers as a tuple over X with None for "not asked", some question lay in Q)
            dist = {((None,) * nx, False): Fraction(1)}
            total = Fraction(0)                       # sum over rounds of Pr[the run enters Q, no earlier question in Q]
            for _t in range(n):
                new = {}
                for (data, hit), p in dist.items():
                    rule = tuple(default[x] if data[x] is None else data[x] for x in range(nx))
                    xs_all = runs_of(scaffold, rule, L)
                    for z in range(nz):
                        xs = xs_all[z]
                        if not hit and any(x in Q for x in xs):
                            total += p * Fraction(1, nz)
                        for J in range(1, L + 1):
                            q = p * Fraction(1, nz) * Fraction(1, L)
                            if J <= len(xs):
                                x = xs[J - 1]
                                d2 = data[:x] + (f[x],) + data[x + 1:]
                                key = (d2, hit or x in Q)
                            else:
                                key = (data, hit)
                            new[key] = new.get(key, 0) + q
                dist = new
            n_sets += 1
            worst = max(worst, total / L)
            assert total <= L
    print(f"  {n_inst} random scaffolds (L <= 3, inputs that depend on the answers), the rule 'the recorded answer, or a fixed default',")
    print(f"    every nonempty set Q of the 4 inputs ({n_sets} cases), n = 4 to 6 rounds: the sum over the rounds of")
    print(f"    Pr[the run of the round enters Q and no earlier question lay in Q] is at most L in every case; largest ratio to L {float(worst):.4f}")


if __name__ == "__main__":
    block1()
    block2()
    block3()
    block4()
    block5()
    block6()
    block7()
