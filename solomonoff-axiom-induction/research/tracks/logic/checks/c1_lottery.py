"""c1_lottery.py -- independent finite checks for the lottery results of notes.md section 2
(Theorem 2.2, the batch lottery of 2.5, Theorem 2.9(b)/Corollary 2.10, Proposition 2.7).

Written from the statements in notes.md, not from scout N1's c1_lottery.py.
Seed 20261016.  Output: c1_lottery.out (stdout).  Runtime: a few seconds.

Model.  A lottery k has tickets 0..N_k.  A deterministic theory is represented, per lottery,
by (asserts_Lot_k, R_k) where R_k is the set of tickets it refutes; it is inconsistent iff for
some k it asserts Lot_k and refutes every ticket of lottery k (this is the only source of
inconsistency in the lottery language when numerals are distinct).  The random lottery theory
draws winner J_k uniformly and refutes all other tickets.  Exact rational arithmetic.

Part A1  single lottery per index: the diagonal j*_e kills every consistent theory that proves
         all Lot_k at its own lottery; survival probability of the random theory equals
         prod_k (1 - 2^-(k+1)) by exhaustive enumeration of winner vectors, K = 1..5.
Part A2  batch lottery (lottery k: 2^(2k+1) tickets, diagonalise every e < 2^k): exhaustive
         survival probability >= prod_k (1 - 2^-(k+1)), K = 1..3; every e < 2^K killed.
Part A3  true lottery bookkeeping (Theorem 2.9(b)): t_k = least refuted ticket (or 0), j*_k != t_k;
         data true; a theory that refutes no true ticket refutes no ticket at all; conditional on
         survival the probability that the random theory picks every true winner is prod 1/N_k.
Part C   co-r.e. adversary (Proposition 2.7): random co-r.e. removal processes on lottery blocks;
         the adversary that commits, in each block, to the first consistent stage proves the
         final data and is consistent.

Revision note (notes-final.md; referee B, issue 11).  What these parts test, precisely:
  * A1's survival enumeration draws the reported tickets j*_k at random, so it tests only the
    product identity prod_k (1 - 2^-(k+1)); the diagonal is tested separately, against random
    lists of theories.  Referee B's rb1 B tests it against an adversarial list.
  * A3's check "a theory that refutes no true ticket refutes no ticket" is a consequence of the
    definition t := min(refuted) and so a tautology; it is bookkeeping, not evidence.  Referee B's
    rb3 is the exhaustive truth-table version of Thm 2.9(b) and Cor 2.10(iii).
  The code is unchanged; its output is byte-identical to the development round's.
"""
import itertools
import random
from fractions import Fraction
from math import prod

SEED = 20261016
rng = random.Random(SEED)


def tickets(N):
    return range(N + 1)


def random_theory(Ns, kind):
    """Return list over lotteries of (asserts_Lot, refuted_set)."""
    th = []
    for N in Ns:
        if kind == "strong":          # refute all but one ticket
            keep = rng.randrange(N + 1)
            R = set(tickets(N)) - {keep}
            th.append((True, R))
        elif kind == "random":
            R = {j for j in tickets(N) if rng.random() < rng.choice([0.2, 0.5, 0.9])}
            if len(R) == N + 1:
                R.discard(rng.randrange(N + 1))
            th.append((rng.random() < 0.9, R))
        elif kind == "weak":
            th.append((True, set()))
        elif kind == "noLot":
            th.append((rng.random() < 0.5, set(rng.sample(list(tickets(N)), rng.randint(0, N)))))
        else:
            raise ValueError(kind)
    if kind == "random" and rng.random() < 0.25:   # make it inconsistent somewhere
        k = rng.randrange(len(Ns))
        th[k] = (True, set(tickets(Ns[k])))
    return th


def consistent(th, Ns):
    return all(not (a and len(R) == N + 1) for (a, R), N in zip(th, Ns))


def part_a1():
    print("== A1: single lottery per index ==")
    K = 10
    Ns = [2 ** (k + 1) - 1 for k in range(K)]
    kinds = ["strong", "random", "weak", "noLot"]
    trials, kills = 0, 0
    for trial in range(200):
        theories = [random_theory(Ns, rng.choice(kinds)) for _ in range(K)]
        jstar = []
        for e in range(K):
            a, R = theories[e][e]
            if consistent(theories[e], Ns) and a:
                jstar.append(min(set(tickets(Ns[e])) - R))
            else:
                jstar.append(0)
        for e in range(K):
            th = theories[e]
            if not consistent(th, Ns):
                continue
            trials += 1
            # theory e proves all data iff it asserts every Lot_k and refutes every j*_k
            proves_all = all(th[k][0] and jstar[k] in th[k][1] for k in range(K))
            assert not proves_all
            a, R = th[e]
            assert (not a) or (jstar[e] not in R)   # fails at its own lottery
            kills += 1
    print(f"  {trials} consistent listed theories; every one fails the data at its own lottery: {kills == trials}")
    for Kt in range(1, 6):
        jst = [rng.randrange(Ns[k] + 1) for k in range(Kt)]
        good = sum(1 for J in itertools.product(*[tickets(Ns[k]) for k in range(Kt)])
                   if all(J[k] != jst[k] for k in range(Kt)))
        total = prod(Ns[k] + 1 for k in range(Kt))
        exact = Fraction(good, total)
        formula = prod(Fraction(2 ** (k + 1) - 1, 2 ** (k + 1)) for k in range(Kt))
        assert exact == formula
        print(f"  K={Kt}: survival by enumeration {exact} = prod formula ({float(exact):.6f})")
    print(f"  infinite product prod_k (1 - 2^-(k+1)) ~ {prod(1 - 2.0 ** -(k + 1) for k in range(300)):.6f}")


def part_a2():
    print("== A2: batch lottery ==")
    for Kt in range(1, 4):
        Ns = [2 ** (2 * k + 1) - 1 for k in range(Kt)]
        nth = 2 ** Kt          # theories e < 2^Kt cover every lottery's victims
        theories = [random_theory(Ns, rng.choice(["strong", "random", "weak", "noLot"])) for _ in range(nth)]
        reported = []
        for k in range(Kt):
            S = set()
            for e in range(2 ** k):
                a, R = theories[e][k]
                if consistent(theories[e], Ns) and a:
                    S.add(min(set(tickets(Ns[k])) - R))
                else:
                    S.add(0)
            assert len(S) <= 2 ** k < Ns[k] + 1
            reported.append(S)
        good = sum(1 for J in itertools.product(*[tickets(Ns[k]) for k in range(Kt)])
                   if all(J[k] not in reported[k] for k in range(Kt)))
        total = prod(Ns[k] + 1 for k in range(Kt))
        surv = Fraction(good, total)
        bound = prod(1 - Fraction(1, 2 ** (k + 1)) for k in range(Kt))
        assert surv >= bound
        killed = all(not (consistent(theories[e], Ns) and all(theories[e][k][0] and reported[k] <= theories[e][k][1]
                                                              for k in range(Kt)))
                     for e in range(2 ** (Kt - 1)))
        assert killed
        print(f"  K={Kt}: tickets {[N + 1 for N in Ns]}, reported losers per lottery {[len(S) for S in reported]}; "
              f"survival {surv} = {float(surv):.4f} >= bound {float(bound):.4f}; every e < 2^(K-1) killed: {killed}")


def part_a3():
    print("== A3: true lottery bookkeeping ==")
    K = 8
    Ns = [2 ** (k + 1) - 1 for k in range(K)]
    bad = 0
    for trial in range(500):
        th = random_theory(Ns, rng.choice(["strong", "random", "weak", "noLot"]))
        for k in range(K):
            a, R = th[k]
            t = min(R) if R else 0                      # the true winner of lottery k
            if consistent(th, Ns) and a:
                cand = [j for j in tickets(Ns[k]) if j != t and j not in R]
                assert cand, "j* must exist"
                js = cand[0]
            else:
                js = min(j for j in tickets(Ns[k]) if j != t)
            if js == t:                                  # data must be true: j* != t
                bad += 1
            # "true at lottery k" = does not refute the true ticket t; that forces R empty
            if t not in R and R:
                bad += 1
    print(f"  500 random theories x {K} lotteries: violations of (j* != t, true => refutes nothing): {bad}")
    assert bad == 0
    for Kt in range(1, 5):
        jst = [rng.randrange(Ns[k] + 1) for k in range(Kt)]
        t = [rng.choice([j for j in tickets(Ns[k]) if j != jst[k]]) for k in range(Kt)]
        surv = [J for J in itertools.product(*[tickets(Ns[k]) for k in range(Kt)])
                if all(J[k] != jst[k] for k in range(Kt))]
        allt = sum(1 for J in surv if all(J[k] == t[k] for k in range(Kt)))
        frac = Fraction(allt, len(surv))
        assert frac == prod(Fraction(1, Ns[k]) for k in range(Kt))
        print(f"  K={Kt}: P(random theory picks every true winner | survival) = {frac} = prod 1/N_k")


def part_c(trials=2000):
    print("== C: co-r.e. streams over lottery blocks (Proposition 2.7) ==")
    ok = 0
    for _ in range(trials):
        K = rng.randint(1, 5)
        Ns = [rng.randint(1, 6) for _ in range(K)]
        adversary = []
        final_data = []
        for k in range(K):
            N = Ns[k]
            # candidate block: Lot_k, negative literals, positive literals
            cands = [("Lot",)] + [("neg", j) for j in tickets(N)] + [("pos", j) for j in tickets(N)]

            def cons(X):
                pos = {c[1] for c in X if c[0] == "pos"}
                neg = {c[1] for c in X if c[0] == "neg"}
                if pos & neg:
                    return False
                if ("Lot",) in X and len(neg) == N + 1:
                    return False
                return True

            # a random removal order; the final set is the remainder after a random number of
            # removals, conditioned on being consistent (removals continue until consistent, then
            # a random number more)
            order = cands[:]
            rng.shuffle(order)
            cur = set(cands)
            stages = [set(cur)]
            i = 0
            while not cons(cur):
                cur.discard(order[i]); i += 1
                stages.append(set(cur))
            extra = rng.randint(0, len(order) - i)
            for x in order[i:i + extra]:
                cur.discard(x)
                stages.append(set(cur))
            final = cur
            # adversary of Prop 2.7: first stage whose remainder is consistent
            commit = next(st for st in stages if cons(st))
            adversary.append(commit)
            final_data.append(final)
        good = all(final_data[k] <= adversary[k] and
                   (lambda X, N: (not ({c[1] for c in X if c[0] == "pos"} & {c[1] for c in X if c[0] == "neg"}))
                    and not (("Lot",) in X and len({c[1] for c in X if c[0] == "neg"}) == N + 1))(adversary[k], Ns[k])
                   for k in range(K))
        ok += good
    print(f"  {trials} random co-r.e. removal processes: adversary consistent and proves the final data in {ok}")
    assert ok == trials


if __name__ == "__main__":
    print(f"seed {SEED}")
    part_a1()
    part_a2()
    part_a3()
    part_c()
    print("all assertions passed")
