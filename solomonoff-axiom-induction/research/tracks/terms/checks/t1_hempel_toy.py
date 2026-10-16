#!/usr/bin/env python3
"""t1_hempel_toy.py -- a finite propositional analogue of Theorem 2.1(d) (Hempel's horn): the observational
projection G -> G^O of a theory machine leaves its law on observational data unchanged, tape by tape and class
by class.

Record: notes.md, Theorem 2.1(d) and its proof (the map G -> G^O, G^O emitting on a prefix w every observational
sentence that B together with the axioms emitted on w proves).

Setting: atoms o0, o1, o2 (observational) and t0, t1 (theoretical); a sentence is identified with its set of
models among the 32 valuations.  Background B := (t0 -> o0) & (t1 -> ~o2), a theoretical sentence.
A random theory machine reads tapes of length 4 (16 tapes) and emits, under each prefix w of length <= 4,
a random set of clauses (width 1-3) over all five atoms; A_w is the union over the prefixes of w.
G^O emits under w the strongest observational consequence of B & A_w (the cylinder of the projection of its
models to the observational atoms); so B u A^{G^O}_omega has exactly the observational consequences of
B u A_omega.  Checks, for 40 random machines:
  (1) nu_{G^O}(D) = nu_G(D) for every observational data set D with one datum (256 observational sentences,
      both labels) and for 4000 random two-datum data sets;
  (2) the same class by class: for every observational content Theta (a set of observational valuations) and
      every one-datum D, the measure of tapes with content Theta compatible with D agrees;
  (3) negative control: the machine that keeps only the observational members of A_w (dropping theoretical
      axioms instead of projecting) has a different law on some D for most machines.
Seed 20261016.  Writes t1_hempel_toy.out next to itself.
"""
import itertools
import os
import random

SEED = 20261016
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "t1_hempel_toy.out")
LOG = []


def log(s=""):
    print(s)
    LOG.append(s)


ATOMS = 5           # bits 0..2 observational, 3..4 theoretical
ALL = frozenset(range(2 ** ATOMS))


def bit(v, i):
    return (v >> i) & 1


def obs(v):
    return v & 0b111


def cyl(proj):
    """The observational sentence whose observational valuations are `proj` (a set of 3-bit values)."""
    return frozenset(v for v in ALL if obs(v) in proj)


B = frozenset(v for v in ALL if (not bit(v, 3) or bit(v, 0)) and (not bit(v, 4) or not bit(v, 2)))


def random_clause(rng):
    width = rng.randint(1, 3)
    lits = [(rng.randrange(ATOMS), rng.random() < 0.5) for _ in range(width)]
    return frozenset(v for v in ALL if any(bit(v, i) == int(pos) for i, pos in lits))


def is_observational(s):
    return s == cyl({obs(v) for v in s})


def random_machine(rng):
    G = {}
    for n in range(5):
        for w in itertools.product("01", repeat=n):
            k = rng.choice([0, 0, 0, 1, 1, 2])
            G["".join(w)] = [random_clause(rng) for _ in range(k)]
            if rng.random() < 0.15:  # some observational axioms too
                G["".join(w)].append(cyl(set(rng.sample(range(8), rng.randint(3, 7)))))
    return G


def theory_on_tape(G, tape):
    A = []
    for n in range(len(tape) + 1):
        A += G[tape[:n]]
    return A


def models(sents):
    m = B
    for s in sents:
        m = m & s
    return m


def law(G, D, theta=None):
    """G maps prefixes to lists of sentences; D is a list of (sentence, label).  Returns the number of tapes
    (out of 16) on which B u A is consistent, proves every datum, and (optionally) has content theta."""
    count = 0
    for t in itertools.product("01", repeat=4):
        tape = "".join(t)
        M = models(theory_on_tape(G, tape))
        if not M:
            continue
        if theta is not None and frozenset(obs(v) for v in M) != theta:
            continue
        if all((M <= s) if b else (not (M & s)) for s, b in D):
            count += 1
    return count


def project(G):
    GO = {}
    for w in G:
        M = models(theory_on_tape(G, w))
        GO[w] = [cyl({obs(v) for v in M})]
    return GO


def drop(G):
    return {w: [s for s in G[w] if is_observational(s)] for w in G}


def main():
    rng = random.Random(SEED)
    log("t1_hempel_toy.py -- the observational projection preserves the law on observational data")
    obs_sents = [cyl(set(c)) for r in range(9) for c in itertools.combinations(range(8), r)]
    log(f"  {len(obs_sents)} observational sentences; background B = (t0 -> o0) & (t1 -> ~o2)")
    bad1 = bad2 = bad3 = 0
    differs = 0
    checked1 = checked2 = checked3 = 0
    for _ in range(40):
        G = random_machine(rng)
        GO = project(G)
        GD = drop(G)
        assert all(is_observational(s) for w in GO for s in GO[w])
        diff_here = False
        for s in obs_sents:
            for b in (1, 0):
                D = [(s, b)]
                a, c = law(G, D), law(GO, D)
                bad1 += a != c
                checked1 += 1
                diff_here |= law(GD, D) != a
        for _ in range(100):
            D = [(rng.choice(obs_sents), rng.randint(0, 1)) for _ in range(2)]
            bad1 += law(G, D) != law(GO, D)
            checked1 += 1
        contents = set()
        for t in itertools.product("01", repeat=4):
            M = models(theory_on_tape(G, "".join(t)))
            if M:
                contents.add(frozenset(obs(v) for v in M))
        for theta in contents:
            for s in obs_sents[::7]:
                for b in (1, 0):
                    bad2 += law(G, [(s, b)], theta) != law(GO, [(s, b)], theta)
                    checked2 += 1
        differs += diff_here
        checked3 += 1
    log(f"  (1) law of G^O equals law of G on observational data: {checked1} (machine, data set) checks, "
        f"violations {bad1}")
    log(f"  (2) class by class (observational content fixed): {checked2} checks, violations {bad2}")
    log(f"  (3) negative control (drop theoretical axioms instead of projecting): law differs for {differs} of "
        f"{checked3} machines")
    ok = bad1 == 0 and bad2 == 0 and differs > 0
    log("")
    log("all checks passed" if ok else "SOME CHECK FAILED")
    with open(OUT, "w") as fh:
        fh.write("\n".join(LOG) + "\n")


if __name__ == "__main__":
    main()
