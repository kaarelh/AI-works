"""c4_trichotomy.py -- finite check of the arithmetical shape of the trichotomy (notes.md 4.1,
Proposition 4.1) in a finite model of "Sigma_1-completeness of Q".

Seed 20261016.  Output: c4_trichotomy.out (stdout).

The finite model.  Worlds W = {0, 1, ..., m}; world 0 plays the standard model N, worlds 1..m play
nonstandard models of the background B (B holds in every world).  A sentence is a set of worlds
(where it holds).  The only arithmetical input of Proposition 4.1 is (Sigma_1 C): every model of
B >= Q satisfies every true Sigma_1 sentence.  So:
  * a Sigma_1 sentence is a set X with (0 in X  =>  X = W)   [true Sigma_1 => true everywhere];
  * a Pi_1 sentence is the complement of a Sigma_1 sentence: a set P with (0 not in P => P = {}).
A theory is a set Mod of worlds (Mod = {} is inconsistent); it proves phi iff Mod <= phi.
A random theory is a finite list of theories with dyadic weights (a theory-machine law).
Data D = a finite set of sentences labelled true; it is true if every datum contains world 0.
Checks (Prop 4.1):
  (a) a true Sigma_1 sentence (= W) has Bel_D = 1;
  (b) a false Pi_1 sentence (= {}) has (Bel, Dis, Indep) = (0, 1, 0);
  (c) if the data are true and a true Pi_1 sentence pi is not entailed by the data (the
      intersection of the data is not contained in pi), and the prior contains the three theories
      [data + pi], [data + not pi], [data] (positive weights), then Bel, Dis, Indep of pi are > 0;
  (d) dually for a false Sigma_1 sentence not refuted by the data.
Also tabulated: the one-sided errors (positive Bel on a false Sigma_1 sentence and positive Dis on
a true Pi_1 sentence occur; positive Dis on a true Sigma_1 or positive Bel on a false Pi_1 never).
"""
import random
from fractions import Fraction

SEED = 20261016
rng = random.Random(SEED)


def rand_subset(U, p=0.5):
    return frozenset(x for x in U if rng.random() < p)


def run(trials=3000):
    viol = {"a": 0, "b": 0, "c": 0, "d": 0}
    counts = {"c": 0, "d": 0}
    one_sided = {"Bel>0 on false S1": 0, "Dis>0 on true P1": 0, "Dis>0 on true S1": 0, "Bel>0 on false P1": 0}
    for _ in range(trials):
        m = rng.randint(2, 7)
        W = frozenset(range(m + 1))
        nonstd = W - {0}
        # data: true sentences (contain world 0), random shapes
        D = [frozenset({0}) | rand_subset(nonstd) for _ in range(rng.randint(0, 3))]
        dataset = frozenset.intersection(W, *D) if D else W
        # random prior: random theories plus (sometimes) the three special ones
        pi = frozenset({0}) | rand_subset(nonstd)          # a true Pi_1 sentence
        sig = rand_subset(nonstd)                           # a false Sigma_1 sentence
        theories = []
        for _ in range(rng.randint(3, 12)):
            u = rng.random()
            if u < 0.15:
                theories.append(frozenset())               # inconsistent
            elif u < 0.6:
                theories.append(dataset & (rand_subset(W, 0.6) | frozenset([0])) if rng.random() < 0.5
                                else dataset & rand_subset(W, 0.6))
            else:
                theories.append(rand_subset(W, 0.6))
        special = rng.random() < 0.6
        if special:
            theories += [dataset & pi, dataset - pi, dataset, dataset & (W - sig), dataset & sig]
        raw = [rng.randint(1, 64) for _ in theories]
        tot = sum(raw)
        ws = [Fraction(r, tot) for r in raw]
        compat = [(w, Mod) for w, Mod in zip(ws, theories) if Mod and Mod <= dataset]
        Z = sum(w for w, _ in compat)
        if Z == 0:
            continue

        def tri(phi):
            bel = sum(w for w, Mod in compat if Mod <= phi) / Z
            dis = sum(w for w, Mod in compat if not (Mod & phi)) / Z
            return bel, dis, 1 - bel - dis

        # (a) true Sigma_1 = W
        if tri(W)[0] != 1:
            viol["a"] += 1
        # (b) false Pi_1 = {}
        if tri(frozenset()) != (0, 1, 0):
            viol["b"] += 1
        # (c)
        if special and not dataset <= pi:
            counts["c"] += 1
            if min(tri(pi)) <= 0:
                viol["c"] += 1
        # (d) false Sigma_1 sig not refuted by the data: dataset not disjoint from sig
        if special and (dataset & sig):
            counts["d"] += 1
            if min(tri(sig)) <= 0:
                viol["d"] += 1
        b, d, _ = tri(sig)
        one_sided["Bel>0 on false S1"] += b > 0
        b, d, _ = tri(pi)
        one_sided["Dis>0 on true P1"] += d > 0
        one_sided["Dis>0 on true S1"] += tri(W)[1] > 0
        one_sided["Bel>0 on false P1"] += tri(frozenset())[0] > 0
    print(f"seed {SEED}; {trials} random finite world models")
    print(f"(a) true Sigma_1 has Bel = 1: violations {viol['a']}")
    print(f"(b) false Pi_1 has (0,1,0): violations {viol['b']}")
    print(f"(c) unentailed true Pi_1, three theories present: all three values > 0 in "
          f"{counts['c'] - viol['c']}/{counts['c']}")
    print(f"(d) unrefuted false Sigma_1, three theories present: all three values > 0 in "
          f"{counts['d'] - viol['d']}/{counts['d']}")
    print("one-sided errors (instances where the event occurs):", one_sided)
    assert all(v == 0 for v in viol.values())
    assert one_sided["Dis>0 on true S1"] == 0 and one_sided["Bel>0 on false P1"] == 0
    assert one_sided["Bel>0 on false S1"] > 0 and one_sided["Dis>0 on true P1"] > 0
    print("all assertions passed")


if __name__ == "__main__":
    run()
