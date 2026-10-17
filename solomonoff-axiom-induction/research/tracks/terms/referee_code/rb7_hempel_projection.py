#!/usr/bin/env python3
"""rb7_hempel_projection.py -- referee B: a propositional analogue of Theorem 2.1(d), independent of t1.

Semantic representation (unlike t1, which manipulates formulas): a formula over the atoms o0, o1, o2
(observational) and t0, t1 (theoretical) is the set of its models among the 32 valuations; an observational
formula is a set closed under changing t0, t1.  For an axiom set A (with background B):
  consistent iff Mod(B) & Mod(A) is nonempty;  B u A |- phi iff Mod(B) & Mod(A) <= Mod(phi);
  observational content T_O(A) is represented by S(A) := proj_obs(Mod(B) & Mod(A)) (phi in T_O iff S <= Mod(phi)).
A theory machine G: a depth-3 binary tree whose nodes emit random clauses; a tape is a leaf (uniform).
G^O emits at each node the strongest observational consequence of B u A^G_w (the cylinder over S).
Checked, for three backgrounds B (one with observational consequences), 30 machines each:
  (1) for every tape: consistency agrees; the observational contents agree (S equal);
  (2) the law agrees on every data set D (all single data and all pairs from a pool of 24 observational
      formulas, both labels), class by class for 40 random classes Theta of contents;
  (3) control: dropping the theoretical axioms (instead of projecting) changes the law.
Seed 20261016.  Writes rb7_hempel_projection.out next to itself.
"""
import itertools
import os
import random

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "rb7_hempel_projection.out")
LOG = []
SEED = 20261016
ATOMS = ["o0", "o1", "o2", "t0", "t1"]
VALS = list(itertools.product((0, 1), repeat=5))
ALL = frozenset(range(32))


def log(x=""):
    print(x)
    LOG.append(x)


def models(pred):
    return frozenset(i for i, v in enumerate(VALS) if pred(dict(zip(ATOMS, v))))


def proj(M):
    return frozenset(VALS[i][:3] for i in M)


def cyl(S):
    return frozenset(i for i, v in enumerate(VALS) if v[:3] in S)


def is_obs(M):
    return cyl(proj(M)) == M


def rand_clause(rng):
    lits = rng.sample(ATOMS, rng.randint(1, 3))
    sign = {a: rng.random() < 0.5 for a in lits}
    return models(lambda v: any(v[a] == sign[a] for a in lits))


NODES = [""] + ["".join(p) for n in (1, 2, 3) for p in itertools.product("01", repeat=n)]
LEAVES = ["".join(p) for p in itertools.product("01", repeat=3)]


def rand_machine(rng):
    return {w: [rand_clause(rng) for _ in range(rng.choice((0, 0, 1, 1, 2)))] for w in NODES}


def axioms_on(G, leaf):
    out = []
    for i in range(4):
        out += G[leaf[:i]]
    return out


def mod_of(axs):
    M = ALL
    for a in axs:
        M &= a
    return M


def project_machine(G, B):
    """G^O: at node w emit the cylinder of proj(Mod(B) & Mod(A^G_w)) (one observational formula)."""
    GO = {}
    for w in NODES:
        A = []
        for i in range(len(w) + 1):
            A += G[w[:i]]
        GO[w] = [cyl(proj(B & mod_of(A)))]
    return GO


def drop_machine(G):
    return {w: [a for a in G[w] if is_obs(a)] for w in NODES}


def event(G, B, leaf, D, theta):
    M = B & mod_of(axioms_on(G, leaf))
    if not M:
        return False
    for phi, b in D:
        target = phi if b else (ALL - phi)
        if not M <= target:
            return False
    return theta is None or proj(M) in theta


def law(G, B, D, theta=None):
    return sum(event(G, B, leaf, D, theta) for leaf in LEAVES)


def main():
    rng = random.Random(SEED)
    log("rb7_hempel_projection.py -- referee B: propositional analogue of Thm 2.1(d), semantic implementation")
    backgrounds = {
        "B1 = (t0 -> o0) & (t1 -> ~o2)": models(lambda v: (not v["t0"] or v["o0"]) and (not v["t1"] or not v["o2"])),
        "B2 = t0 & (t0 -> o1)  [B |- o1]": models(lambda v: v["t0"] and v["o1"]),
        "B3 = (t0 <-> ~t1) & (t0 -> o0) & (t1 -> o1)  [B |- o0 | o1]":
            models(lambda v: (v["t0"] != v["t1"]) and (not v["t0"] or v["o0"]) and (not v["t1"] or v["o1"])),
    }
    pool = []
    while len(pool) < 24:
        S = frozenset(o for o in itertools.product((0, 1), repeat=3) if rng.random() < 0.5)
        if 0 < len(S) < 8 and cyl(S) not in pool:
            pool.append(cyl(S))
    datasets = [()] + [((p, b),) for p in pool for b in (0, 1)]
    datasets += [((p, b), (q, c)) for p, q in itertools.combinations(pool, 2) for b in (0, 1) for c in (0, 1)]
    contents = [frozenset(s) for r in range(1, 9) for s in itertools.combinations(list(itertools.product((0, 1), repeat=3)), r)]
    ok = True
    for name, B in backgrounds.items():
        tape_bad = law_bad = class_bad = checks = cchecks = 0
        drop_differs = 0
        for _ in range(30):
            G = rand_machine(rng)
            GO = project_machine(G, B)
            GD = drop_machine(G)
            for leaf in LEAVES:
                M = B & mod_of(axioms_on(G, leaf))
                MO = B & mod_of(axioms_on(GO, leaf))
                if bool(M) != bool(MO) or (M and proj(M) != proj(MO)):
                    tape_bad += 1
            thetas = [frozenset(rng.sample(contents, 60)) for _ in range(40)]
            differs = False
            for D in datasets:
                checks += 1
                if law(G, B, D) != law(GO, B, D):
                    law_bad += 1
                if law(G, B, D) != law(GD, B, D):
                    differs = True
            for D in datasets[:200]:
                for th in thetas:
                    cchecks += 1
                    if law(G, B, D, th) != law(GO, B, D, th):
                        class_bad += 1
            drop_differs += differs
        log(f"  {name}: 30 machines x 8 tapes: tape-wise consistency/content disagreements {tape_bad}; law on "
            f"{checks} data sets: disagreements {law_bad}; class-wise ({cchecks} checks): disagreements {class_bad}; "
            f"control (drop theoretical axioms) changes the law for {drop_differs}/30 machines")
        ok &= tape_bad == 0 and law_bad == 0 and class_bad == 0 and drop_differs > 0
    log("")
    log("all referee checks behaved as expected" if ok else "SOME REFEREE CHECK DID NOT BEHAVE AS EXPECTED")
    with open(OUT, "w") as fh:
        fh.write("\n".join(LOG) + "\n")


if __name__ == "__main__":
    main()
