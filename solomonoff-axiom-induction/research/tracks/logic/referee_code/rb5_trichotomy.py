"""rb5_trichotomy.py -- referee B (thread `logic`): Prop 4.1 (arithmetical shape of the trichotomy)
in a propositional model of Sigma_1 sentences, and the machine-dependence construction of
Prop 4.5(c), with exact posteriors.  Independent of the developer's c4 (whose "Sigma_1 sentences"
are arbitrary sets of worlds; here they must also be MONOTONE formulas, closed under & and v, as
Sigma_1 sentences are up to Q-equivalence).

Seed 20261016.  Output: rb5_trichotomy.out (stdout).

Model (Part A).  Sigma_1 atoms s_0..s_{m-1} (m = 3..6) with a random actual truth assignment v0
(v0 plays the standard model N).  An assignment v is a "model" of the background iff v >= v0
coordinatewise: Q proves exactly the true atoms (Sigma_1-completeness) and nothing about the false
ones.  A Sigma_1 sentence is a random nonempty monotone DNF over the atoms (true iff v0 satisfies
it; then every v >= v0 does, so Q proves it); Pi_1 = negations of Sigma_1 sentences (Pi_1* is the
same class, as ~s1 & ~s2 = ~(s1 v s2)).  A theory is a random set of propositional formulas, i.e. a
random set of assignments; it is consistent iff it has a model v >= v0, and proves phi iff all its
models v >= v0 satisfy phi.  A prior is a random finite list of theories with dyadic weights;
data D are labelled Sigma_1 / Pi_1 / arbitrary sentences, consistent with the background.
Checks: Prop 4.1 (a) true Sigma_1 has Bel_D = 1; (b) false Pi_1 has (0,1,0); (c) with the three
theories D+pi, D+~pi, D in the prior, D true (v0 satisfies D), pi true Pi_1 not entailed: all three
values > 0; (d) the dual for false Sigma_1; the one-sided table (Indep > 0 on Sigma_1 => false;
Indep > 0 on Pi_1 => true; Dis > 0 on true Sigma_1 never; Bel > 0 on false Pi_1 never).

Part B (Prop 4.5(c), exact).  A toy universal machine V: a prefix-free code (random lengths
satisfying Kraft) for a list of theories, among them T+gamma, T+~gamma, T and incompatible ones.
V'(0^i 1) := T+gamma for i < j, V'(0^j p) := V(p).  Check that V' is prefix-free, that its Kraft
sum is at most 1, and that lim Bel / lim Dis >= 2^j - 1, for j = 1..10 (and the mirror V'').
"""
import itertools
import random
from fractions import Fraction

SEED = 20261016
rng = random.Random(SEED)


def monotone_dnf(m):
    """Random nonempty monotone DNF: set of assignments (as int masks) satisfying it."""
    terms = []
    for _ in range(rng.randint(1, 3)):
        t = frozenset(i for i in range(m) if rng.random() < 0.4)
        if not t:
            t = frozenset([rng.randrange(m)])
        terms.append(t)
    sat = set()
    for v in range(1 << m):
        if any(all(v >> i & 1 for i in t) for t in terms):
            sat.add(v)
    return frozenset(sat)


def part_a(trials=4000):
    print("== A: Prop 4.1 in the monotone-Sigma_1 propositional model ==")
    viol = {"a": 0, "b": 0, "c": 0, "d": 0, "tab": 0}
    cnt = {"a": 0, "b": 0, "c": 0, "d": 0}
    events = {"Bel>0 on false S1": 0, "Dis>0 on true P1": 0, "Indep>0 on false S1": 0,
              "Indep>0 on true P1": 0, "Dis>0 on true S1": 0, "Bel>0 on false P1": 0,
              "Indep>0 on true S1": 0, "Indep>0 on false P1": 0}
    for _ in range(trials):
        m = rng.randint(3, 6)
        allv = frozenset(range(1 << m))
        v0 = rng.randrange(1 << m)
        bg = frozenset(v for v in allv if v & v0 == v0)          # models of the background (v >= v0)
        # data: a few labelled sentences; true data w.p. 0.7, otherwise arbitrary consistent
        true_data = rng.random() < 0.7
        D = []
        for _ in range(rng.randint(0, 3)):
            kind = rng.choice(["S1", "P1", "any"])
            if kind == "S1":
                phi = monotone_dnf(m)
            elif kind == "P1":
                phi = allv - monotone_dnf(m)
            else:
                phi = frozenset(v for v in allv if rng.random() < 0.5)
            lab = (v0 in phi) if true_data else rng.random() < 0.5
            D.append(phi if lab else allv - phi)
        dset = bg.intersection(*D) if D else bg
        if not dset:
            continue                                             # inconsistent data: skip
        # query sentences
        sig = monotone_dnf(m)                                    # a Sigma_1 sentence
        pi = allv - monotone_dnf(m)                              # a Pi_1 sentence
        # prior: random theories (sets of assignments) + optional special theories
        theories = []
        for _ in range(rng.randint(3, 10)):
            u = rng.random()
            if u < 0.1:
                theories.append(frozenset())                     # inconsistent
            elif u < 0.6:
                theories.append(frozenset(v for v in dset if rng.random() < 0.6))
            else:
                theories.append(frozenset(v for v in allv if rng.random() < 0.5))
        special = rng.random() < 0.6
        if special:
            theories += [dset & pi, dset - pi, dset, dset & sig, dset - sig]
        ws = [Fraction(rng.randint(1, 32), 2 ** rng.randint(5, 9)) for _ in theories]
        compat = []
        for w, th in zip(ws, theories):
            mods = th & bg
            if mods and mods <= dset:
                compat.append((w, mods))
        Zm = sum((w for w, _ in compat), Fraction(0))
        if Zm == 0:
            continue

        def tri(phi):
            bel = sum((w for w, md in compat if md <= phi), Fraction(0)) / Zm
            dis = sum((w for w, md in compat if not (md & phi)), Fraction(0)) / Zm
            return bel, dis, 1 - bel - dis

        sig_true, pi_true = v0 in sig, v0 in pi
        bs, ds, is_ = tri(sig)
        bp, dp, ip = tri(pi)
        # (a) a true Sigma_1 sentence: test with sig if true
        if sig_true:
            cnt["a"] += 1
            if bs != 1:
                viol["a"] += 1
        # (b) a false Pi_1 sentence
        if not pi_true:
            cnt["b"] += 1
            if (bp, dp, ip) != (0, 1, 0):
                viol["b"] += 1
        # (c) true data, true pi not entailed, special theories present
        if special and true_data and pi_true and not dset <= pi:
            cnt["c"] += 1
            if min(bp, dp, ip) <= 0:
                viol["c"] += 1
        # (d) true data, false sigma not refuted (dset meets sigma), special theories present
        if special and true_data and not sig_true and (dset & sig):
            cnt["d"] += 1
            if min(bs, ds, is_) <= 0:
                viol["d"] += 1
        # table
        events["Bel>0 on false S1"] += (not sig_true) and bs > 0
        events["Dis>0 on true P1"] += pi_true and dp > 0
        events["Indep>0 on false S1"] += (not sig_true) and is_ > 0
        events["Indep>0 on true P1"] += pi_true and ip > 0
        events["Dis>0 on true S1"] += sig_true and ds > 0
        events["Bel>0 on false P1"] += (not pi_true) and bp > 0
        events["Indep>0 on true S1"] += sig_true and is_ > 0
        events["Indep>0 on false P1"] += (not pi_true) and ip > 0
    for k in ("a", "b", "c", "d"):
        print(f"  ({k}) {viol[k]} violations in {cnt[k]} applicable instances")
    print("  event counts:", events)
    impossible = ["Dis>0 on true S1", "Bel>0 on false P1", "Indep>0 on true S1", "Indep>0 on false P1"]
    possible = ["Bel>0 on false S1", "Dis>0 on true P1", "Indep>0 on false S1", "Indep>0 on true P1"]
    ok = all(events[e] == 0 for e in impossible) and all(events[e] > 0 for e in possible) \
        and all(viol[k] == 0 for k in ("a", "b", "c", "d"))
    print(f"  one-sided pattern (the four impossible events never occur, the four possible ones do): {ok}")
    assert ok


def part_b():
    print("== B: Prop 4.5(c), reweighting the universal machine ==")
    ok = True
    for trial in range(30):
        # toy V: lengths for theories; labels 'TG' (T+gamma), 'TN' (T+~gamma), 'T', 'X' (incompatible)
        labels = ["TG", "TN", "T"] + ["X"] * rng.randint(0, 5) + [rng.choice(["TG", "TN", "T"]) for _ in range(rng.randint(0, 4))]
        # build a prefix-free code by assigning codewords from a random complete-ish binary tree
        code = {}
        frontier = [""]
        while len(frontier) < len(labels):
            i = rng.randrange(len(frontier))
            w = frontier.pop(i)
            frontier += [w + "0", w + "1"]
        rng.shuffle(frontier)
        for w, lab in zip(frontier, labels):
            code[w] = lab
        for j in range(1, 11):
            Vp = {}
            for i in range(j):
                Vp["0" * i + "1"] = "TG"
            for w, lab in code.items():
                Vp["0" * j + w] = lab
            words = list(Vp)
            pf = all(not (a != b and b.startswith(a)) for a in words for b in words)
            kraft = sum((Fraction(1, 2 ** len(w)) for w in words), Fraction(0))
            bel = sum((Fraction(1, 2 ** len(w)) for w, lab in Vp.items() if lab == "TG"), Fraction(0))
            dis = sum((Fraction(1, 2 ** len(w)) for w, lab in Vp.items() if lab == "TN"), Fraction(0))
            ratio_ok = dis > 0 and bel / dis >= 2 ** j - 1
            # mirror V''
            Vpp = {("0" * i + "1"): "TN" for i in range(j)}
            Vpp.update({"0" * j + w: lab for w, lab in code.items()})
            bel2 = sum((Fraction(1, 2 ** len(w)) for w, lab in Vpp.items() if lab == "TG"), Fraction(0))
            dis2 = sum((Fraction(1, 2 ** len(w)) for w, lab in Vpp.items() if lab == "TN"), Fraction(0))
            mirror_ok = bel2 > 0 and bel2 / dis2 <= Fraction(1, 2 ** j - 1)
            if not (pf and kraft <= 1 and ratio_ok and mirror_ok):
                ok = False
    print(f"  30 random toy machines, j = 1..10: V' prefix-free, Kraft <= 1, ratio >= 2^j - 1, "
          f"mirror <= 1/(2^j - 1): {ok}")
    assert ok


if __name__ == "__main__":
    print(f"seed {SEED}")
    part_a()
    part_b()
    print("all assertions passed")
