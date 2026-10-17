"""c1_lottery.py -- finite checks for the lottery theorem (notes.md, section 3).

Seed 20261015. Output: c1_lottery.out (written by running this script with stdout redirected).

Part A. Truncated lottery stream against a finite list of deterministic theories.
  Lottery k has tickets 0..N_k with N_k + 1 = 2^(k+1). The random theory G draws the winner J_k
  uniformly and asserts: lambda_k ("lottery k has a winner among its tickets"), W(k, J_k), and
  not-W(k, j) for every other ticket j.
  A deterministic theory is represented by, for each lottery, whether it asserts lambda_k and the
  set R_k of tickets it refutes (asserts not-W(k, j)); a theory that asserts lambda_k and refutes
  every ticket of lottery k is inconsistent. The diagonal picks, at lottery e, the least ticket
  j*_e that the e-th theory does not refute (if that theory is consistent and asserts lambda_e).
  Checks:
    A1 every consistent deterministic theory of the list that asserts all lambda_k fails the datum
       not-W(e, j*_e) at its own lottery;
    A2 the probability that the random theory proves all data equals prod_k (1 - 2^-(k+1)), checked
       by exhaustive enumeration of all winner vectors for K <= 4 lotteries;
    A3 the posterior share of the deterministic theories in a mixture tends to 0 as lotteries are
       revealed, while the random theory keeps bounded loss;
    A4 the "majority vote" theory (refute every ticket refuted with probability > 1/2) is
       inconsistent for every lottery k >= 1.

Part B. Majority vote under bounded inconsistency arity (Proposition E2).
  Random finite "tape spaces": each tape carries a theory over a finite sentence class with a
  hypergraph of minimal inconsistent sets of size <= r (r = 2 is the literal case). A tape is
  inconsistent if its theory contains a minimal inconsistent set. Choose an event E of consistent
  tapes of conditional measure > 1 - eps, let D be the set of sentences proved on all of E, and
  form T := {phi : Pr[proves phi] > 1 - eps}. With eps = 1/(r+1), T must be consistent and contain D.
  We also record how often T is inconsistent for a larger eps (showing the threshold matters), and
  the lottery hypergraph (arity N + 2) where majority vote fails.
"""
import itertools
import math
import random
from fractions import Fraction

SEED = 20261015
random.seed(SEED)


def part_a():
    print("== Part A: truncated lottery ==")
    K = 12
    N = [2 ** (k + 1) - 1 for k in range(K)]  # tickets 0..N_k

    # A finite list of deterministic theories, one diagonalised per lottery.
    theories = []
    for e in range(K):
        kind = e % 4
        th = {"asserts": [True] * K, "refuted": []}
        for k in range(K):
            if kind == 0:   # strongest consistent: refute all but one ticket
                keep = random.randrange(N[k] + 1)
                R = set(range(N[k] + 1)) - {keep}
            elif kind == 1:  # random subset (proper)
                R = {j for j in range(N[k] + 1) if random.random() < 0.7}
                if len(R) == N[k] + 1:
                    R.discard(random.randrange(N[k] + 1))
            elif kind == 2:  # refute nothing (weak theory)
                R = set()
            else:            # inconsistent at a random lottery, otherwise strongest consistent
                keep = random.randrange(N[k] + 1)
                R = set(range(N[k] + 1)) - {keep}
            th["refuted"].append(R)
        if kind == 3:
            bad = random.randrange(K)
            th["refuted"][bad] = set(range(N[bad] + 1))
        theories.append(th)

    def consistent(th):
        return all(not (th["asserts"][k] and len(th["refuted"][k]) == N[k] + 1) for k in range(K))

    # Diagonal.
    jstar = []
    for e in range(K):
        th = theories[e]
        if consistent(th) and th["asserts"][e]:
            unref = [j for j in range(N[e] + 1) if j not in th["refuted"][e]]
            jstar.append(min(unref))
        else:
            jstar.append(0)
    print("j* =", jstar)

    # A1
    fails = []
    for e, th in enumerate(theories):
        if not consistent(th):
            fails.append((e, "inconsistent"))
            continue
        ok_all = all(jstar[k] in th["refuted"][k] for k in range(K))
        first_fail = next(k for k in range(K) if jstar[k] not in th["refuted"][k])
        fails.append((e, f"fails at lottery {first_fail}" + (" (own lottery)" if first_fail == e else "")))
        assert not ok_all
        assert jstar[e] not in th["refuted"][e]
    for e, s in fails:
        print(f"  theory {e}: {s}")
    print("A1 every consistent listed theory fails the datum at its own lottery: OK")

    # A2 exact survival probability
    for Kt in range(1, 5):
        total = 0
        good = 0
        for J in itertools.product(*[range(N[k] + 1) for k in range(Kt)]):
            total += 1
            if all(J[k] != jstar[k] for k in range(Kt)):
                good += 1
        exact = Fraction(good, total)
        formula = math.prod(Fraction(2 ** (k + 1) - 1, 2 ** (k + 1)) for k in range(Kt))
        assert exact == formula
        print(f"A2 K={Kt}: enumeration {exact} = product formula {formula} ({float(exact):.6f})")
    inf_prod = math.prod(1 - 2.0 ** -(k + 1) for k in range(200))
    print(f"A2 infinite product prod_k (1 - 2^-(k+1)) = {inf_prod:.6f}")

    # A3 posterior shares in a mixture: deterministic theory e has weight 2^-(e+2); the random
    # theory has weight 2^-3. Reveal lotteries one at a time.
    w_det = [2.0 ** -(e + 2) for e in range(K)]
    w_rand = 2.0 ** -3
    print("A3 lottery revealed | deterministic mass | random-theory mass | det. posterior share | random loss (bits)")
    for t in range(K + 1):
        det_mass = sum(w for e, w in enumerate(w_det)
                       if consistent(theories[e]) and all(jstar[k] in theories[e]["refuted"][k] for k in range(t)))
        rand_mass = w_rand * math.prod(1 - 2.0 ** -(k + 1) for k in range(t))
        share = det_mass / (det_mass + rand_mass)
        print(f"   {t:2d} | {det_mass:.6e} | {rand_mass:.6e} | {share:.6f} | {-math.log2(rand_mass / w_rand):.4f}")
    # A4 majority vote
    for k in range(K):
        p_refuted = Fraction(N[k], N[k] + 1)  # each ticket is refuted unless it wins
        maj = [j for j in range(N[k] + 1) if p_refuted > Fraction(1, 2)]
        incons = len(maj) == N[k] + 1
        if k >= 1:
            assert incons
        print(f"A4 lottery {k}: Pr[ticket refuted] = {p_refuted}; majority vote refutes {len(maj)}/{N[k]+1} tickets; inconsistent with lambda_k: {incons}")


def part_b(trials=400):
    print("== Part B: majority vote and inconsistency arity ==")
    results = {}
    for r in (2, 3, 5):
        eps_good = Fraction(1, r + 1)
        viol_good = 0
        viol_big_eps = {}
        count = 0
        nonempty_D = 0
        for _ in range(trials):
            nsent = 12
            # hypergraph of minimal inconsistent sets, each of size between 2 and r
            hyper = [frozenset(random.sample(range(nsent), random.randint(2, r))) for _h in range(8)]

            def incons(th):
                return any(h <= th for h in hyper)

            # a consistent core shared by most tapes, then random consistent extensions;
            # a fraction of tapes is inconsistent (proves everything)
            core = frozenset()
            for s in random.sample(range(nsent), nsent):
                if not incons(core | {s}) and random.random() < 0.5:
                    core = core | {s}
            ntapes = 60
            tapes = []
            for _t in range(ntapes):
                if random.random() < 0.08:
                    th = frozenset(range(nsent))  # inconsistent tape
                else:
                    th = core
                    for s in random.sample(range(nsent), nsent):
                        if s not in th and random.random() < 0.4 and not incons(th | {s}):
                            th = th | {s}
                tapes.append(th)
            cons = [i for i in range(ntapes) if not incons(tapes[i])]

            def prob(s):
                return Fraction(sum(1 for th in tapes if s in th), ntapes)  # inconsistent tapes contain everything

            for eps in (eps_good, Fraction(1, 2), Fraction(2, 3)):
                need = math.floor((1 - eps) * ntapes) + 1
                if len(cons) < need:
                    continue
                E = random.sample(cons, need)
                D = frozenset.intersection(*[tapes[i] for i in E])
                T = frozenset(s for s in range(nsent) if prob(s) > 1 - eps)
                ok = (not incons(T)) and D <= T
                if eps == eps_good:
                    count += 1
                    nonempty_D += bool(D)
                    if not ok:
                        viol_good += 1
                else:
                    viol_big_eps[eps] = viol_big_eps.get(eps, 0) + (not ok)
        results[r] = (count, viol_good)
        extra = "; ".join(f"eps={e}: {v} violations" for e, v in sorted(viol_big_eps.items()))
        print(f"  arity r={r}: trials with an event of measure > 1-1/(r+1): {count} (D nonempty in {nonempty_D}); "
              f"violations at eps=1/(r+1): {viol_good}; {extra}")
        assert viol_good == 0 and count > 0
    # the lottery: lambda_k and the refutations of all n = 2^(k+1) tickets form a minimal
    # inconsistent set of size n + 1; each refutation has probability 1 - 1/n.
    for eps in (Fraction(1, 3), Fraction(1, 10), Fraction(1, 100), Fraction(1, 1000)):
        k = 0
        while Fraction(2 ** (k + 1) - 1, 2 ** (k + 1)) <= 1 - eps:
            k += 1
        print(f"  lottery, threshold 1-{eps}: the majority set refutes every ticket of lottery {k} "
              f"(n = {2**(k+1)} tickets) and is inconsistent with lambda_{k}")
    return results


if __name__ == "__main__":
    print(f"seed {SEED}")
    part_a()
    part_b()
    print("all assertions passed")
