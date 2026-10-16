"""c2_majority.py -- independent finite checks of the majority-vote arguments of notes.md 2.4:
Proposition 2.3(a) (bounded inconsistency arity), the lottery as the counterexample to large
arity, and Proposition 2.4 (majority over true theories).

Written from the statements in notes.md, not from scout N1's code.
Seed 20261016.  Output: c2_majority.out (stdout).

Model (Part A).  A finite sentence set {0..n-1}; a random hypergraph H of "minimal inconsistent
sets", each of size between 1 and r (so every inconsistent set contains an inconsistent subset of
size <= r).  A tape space: finitely many tapes with dyadic weights summing to 1 (a cylinder [w]
with Pr_w normalised).  Each tape carries either an inconsistent theory (proves everything) or a
consistent set of sentences (one containing no hyperedge).  O_phi = tapes proving phi.
E = an event of consistent tapes with Pr(E) > 1 - eps; D = the sentences proved by every tape of
E (the "data").  T = {phi : Pr(O_phi) > 1 - eps}.  Claim (Prop 2.3(a)): with eps = 1/(r+1),
T contains no hyperedge and contains D.  Control: eps = 1/2 and 2/3 (where the claim may fail).

Part B.  The lottery with n tickets: its minimal inconsistent set {Lot} + all n refutations has
size n + 1; the majority set at threshold 1 - eps refutes every ticket once 1 - 1/n > 1 - eps.

Part C (Prop 2.4).  Sentences carry a truth value.  X = tapes whose theory is a set of true
sentences and proves D.  If Pr(X) > 1/2 then T_{1/2} = {phi : Pr(O_phi) > 1/2} contains only true
sentences and contains D.  Control: Pr(X) > 1/3 and T_{1/3} (where the claim may fail).
"""
import random
from fractions import Fraction

SEED = 20261016
rng = random.Random(SEED)


def dyadic_weights(m, bits=10):
    """m positive dyadic weights summing to exactly 1."""
    cuts = sorted(rng.sample(range(1, 2 ** bits), m - 1))
    pts = [0] + cuts + [2 ** bits]
    return [Fraction(pts[i + 1] - pts[i], 2 ** bits) for i in range(m)]


def part_a(trials=600):
    print("== A: majority vote under bounded inconsistency arity ==")
    for r in (1, 2, 3, 4, 6):
        stats = {}
        for eps in (Fraction(1, r + 1), Fraction(1, 2), Fraction(2, 3)):
            stats[eps] = [0, 0]   # [instances, violations]
        for _ in range(trials):
            n = rng.randint(6, 14)
            H = [frozenset(rng.sample(range(n), rng.randint(1, r))) for _ in range(rng.randint(1, 10))]

            def incons(S):
                return any(h <= S for h in H)

            m = rng.randint(10, 40)
            ws = dyadic_weights(m)
            tapes = []
            base = set()
            for s in rng.sample(range(n), n):        # a shared consistent core
                if rng.random() < 0.6 and not incons(base | {s}):
                    base.add(s)
            for i in range(m):
                if rng.random() < 0.1:
                    tapes.append(None)               # inconsistent theory
                else:
                    th = set(base) if rng.random() < 0.8 else set()
                    for s in rng.sample(range(n), n):
                        if rng.random() < 0.35 and not incons(th | {s}):
                            th.add(s)
                    tapes.append(frozenset(th))

            def pr_O(s):
                return sum(w for w, th in zip(ws, tapes) if th is None or s in th)

            cons_idx = [i for i in range(m) if tapes[i] is not None]
            for eps in stats:
                # build E greedily from a random order of consistent tapes until Pr(E) > 1 - eps
                order = cons_idx[:]
                rng.shuffle(order)
                E, mass = [], Fraction(0)
                for i in order:
                    if mass > 1 - eps:
                        break
                    E.append(i); mass += ws[i]
                if mass <= 1 - eps or not E:
                    continue
                D = frozenset.intersection(*[tapes[i] for i in E])
                T = frozenset(s for s in range(n) if pr_O(s) > 1 - eps)
                stats[eps][0] += 1
                if incons(T) or not D <= T:
                    stats[eps][1] += 1
        line = "; ".join(f"eps={str(e)}: {v[1]} violations in {v[0]}" for e, v in stats.items())
        print(f"  arity r={r}: {line}")
        assert stats[Fraction(1, r + 1)][1] == 0 and stats[Fraction(1, r + 1)][0] > 0


def part_b():
    print("== B: the lottery defeats every fixed threshold ==")
    for eps in (Fraction(1, 2), Fraction(1, 10), Fraction(1, 1000), Fraction(1, 10 ** 6)):
        k = 0
        while Fraction(1, 2 ** (k + 1)) >= eps:     # Pr[a given ticket is refuted] = 1 - 2^-(k+1)
            k += 1
        n = 2 ** (k + 1)
        print(f"  threshold 1-{eps}: lottery {k} ({n} tickets) has every refutation above threshold; "
              f"the majority set contains a minimal inconsistent set of size {n + 1}")


def part_c(trials=1500):
    print("== C: majority over true theories (Proposition 2.4) ==")
    res = {Fraction(1, 2): [0, 0], Fraction(1, 3): [0, 0]}
    for _ in range(trials):
        n = rng.randint(6, 14)
        truth = [rng.random() < 0.6 for _ in range(n)]
        m = rng.randint(8, 30)
        ws = dyadic_weights(m)
        tapes = []
        core = {s for s in range(n) if truth[s] and rng.random() < 0.5}
        for i in range(m):
            u = rng.random()
            if u < 0.1:
                tapes.append(None)
            elif u < 0.65:     # a true theory: core plus random true sentences
                tapes.append(frozenset(core | {s for s in range(n) if truth[s] and rng.random() < 0.3}))
            else:              # a theory with some false sentences
                tapes.append(frozenset({s for s in range(n) if rng.random() < 0.4} | core))
        for thr in res:
            true_idx = [i for i in range(m) if tapes[i] is not None and all(truth[s] for s in tapes[i])]
            rng.shuffle(true_idx)
            X, mass = [], Fraction(0)
            for i in true_idx:
                if mass > thr:
                    break
                X.append(i); mass += ws[i]
            if mass <= thr or not X:
                continue
            D = frozenset.intersection(*[tapes[i] for i in X])
            T = {s for s in range(n) if sum(w for w, th in zip(ws, tapes) if th is None or s in th) > thr}
            res[thr][0] += 1
            if not (D <= T and all(truth[s] for s in T)):
                res[thr][1] += 1
    for thr, (cnt, viol) in res.items():
        print(f"  threshold {thr}: X of mass > {thr} in {cnt} instances; T not contained in the truths or missing data: {viol}")
    assert res[Fraction(1, 2)][1] == 0 and res[Fraction(1, 2)][0] > 0


if __name__ == "__main__":
    print(f"seed {SEED}")
    part_a()
    part_b()
    part_c()
    print("all assertions passed")
