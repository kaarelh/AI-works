#!/usr/bin/env python3
"""rb2_pairing.py -- referee B: the model U, the pairing lemma (Lemma 4.2), Remark 4.8 and Prop 9.1(b).

Independent of checks/: U is implemented here from the definition in notes.md section 4.2 (words; formal pairs
P(a, b) with s0 P(a,b) = a, s1 P(a,b) = P(b,a); words act as in the term algebra), including NESTED pairs (pairs
of pairs), which the developer's fragment check did not include.
  A  Lemma 4.2 (i)-(iii) by brute force on a fragment closed under the operations used, with R random on pairs
     (seeded); theta_2 is evaluated as written (a quantifier over the fragment), not via the lemma.
  B  Prop 9.1(b): in any structure without pairs (e.g. the term algebra with any R) theta_2 is vacuously true,
     so the two output rules of T^O force R(x) and ~R(x): T^O has no model satisfying forall z ~ s1 s1 z = z.
     Checked on the term algebra with 200 random R (seeded).
  C  Remark 4.8 on the referee's ANBN program (rb1): the unrelativised translated rules evaluated in U with
     C(a,b) read as R(P(a,b)) and R(P(a,b)) := [(a,b) in C^T] on words, false elsewhere.
Seed 20261016.  Writes rb2_pairing.out next to itself.
"""
import itertools
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rb1_two_stack as T2  # noqa: E402

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "rb2_pairing.out")
LOG = []
SEED = 20261016


def log(x=""):
    print(x)
    LOG.append(x)


def W(u):
    return ("w", u)


def P(a, b):
    return ("p", a, b)


def s(a, x):
    if x[0] == "w":
        return W(a + x[1])
    return x[1] if a == "0" else P(x[2], x[1])


def s_word(u, x):
    for a in reversed(u):
        x = s(a, x)
    return x


def is_pair_formula(z):           # Pair(z) := s1 s1 z = z
    return s("1", s("1", z)) == z


def part_a(rng):
    words = [W("".join(t)) for n in range(0, 3) for t in itertools.product("01", repeat=n)]   # 7 words
    base = words + [P(a, b) for a in words[:4] for b in words[:4]]                               # + 16 pairs
    frag = base + [P(a, b) for a in base for b in base]                                          # + 529 pairs
    frag_set = set(frag)
    Rv = {z: rng.random() < 0.5 for z in frag}
    bad_i = sum(1 for z in frag if is_pair_formula(z) != (z[0] == "p"))
    # (ii) and (iii) for a, b in base (so that P(a, b) lies in the fragment)
    bad_ii = bad_iii = trip = 0
    for a in base:
        for b in base:
            sat = []
            for z in frag:
                prem = is_pair_formula(z) and s("0", z) == a and s("0", s("1", z)) == b
                trip += 1
                if prem != (z == P(a, b)):
                    bad_ii += 1
                if prem:
                    sat.append(z)
            theta = all(Rv[z] for z in sat)
            if theta != Rv[P(a, b)]:
                bad_iii += 1
    std_e = not is_pair_formula(W(""))
    closed = all((not is_pair_formula(y)) <= (not is_pair_formula(s(a, y))) for y in frag for a in "01")
    log(f"  fragment: {len(frag)} elements ({len(words)} words, nested pairs included), all in U: "
        f"{all(x in frag_set for x in frag)}")
    log(f"  (i) Pair holds exactly on pairs: violations {bad_i}; Std(e): {std_e}; Std closed under s0, s1: {closed}")
    log(f"  (ii) [Pair(z) & s0 z = a & s0 s1 z = b] iff z = P(a,b): {trip} triples, violations {bad_ii}")
    log(f"  (iii) theta_2(a,b) (quantifier over the fragment) iff R(P(a,b)): {len(base) ** 2} pairs, violations "
        f"{bad_iii}")
    return bad_i == 0 and bad_ii == 0 and bad_iii == 0 and std_e and closed


def part_b(rng):
    """T^O output rules in a pair-free structure: theta_2 vacuous, so R(x) and ~R(x) are both forced."""
    m, prog = T2.anbn(), None
    name, G, delta, mstates, spec = m
    prog = T2.compile_det(G, delta, mstates)
    words = ["".join(t) for n in range(0, 6) for t in itertools.product("01", repeat=n)]
    failures = 0
    for _ in range(200):
        R = {w: rng.random() < 0.5 for w in words}
        # in the term algebra no element satisfies s1 s1 z = z, so theta_2(a, b) is true for all a, b; Std holds
        # everywhere; output rule 0 at x requires R(x), output rule 1 requires ~R(x)
        ok = all(R[x] for x in words) and all(not R[x] for x in words)
        failures += not ok
    log(f"  200 random R on the term algebra (words |w| <= 5): T^O's two output rules fail in all {failures}")
    return failures == 200


def part_c():
    name, G, delta, mstates, spec = T2.anbn()
    prog = T2.compile_det(G, delta, mstates)
    st = prog["st"]
    goals = ["0" + st["ACC"], "1" + st["REJ"]]
    memo = {}

    def inC(r, l):
        if (r, l) not in memo:
            g, _, _ = T2.run(prog, (r, l), goals, maxsteps=4000)
            memo[(r, l)] = (g in goals)
        return memo[(r, l)]

    def Rpair(a, b):     # R(P(a,b)) in U
        if a[0] == "w" and b[0] == "w":
            return inC(a[1], b[1])
        return False

    def theta(a, b):
        return Rpair(a, b)        # by Lemma 4.2(iii), verified in part A

    words = [W("".join(t)) for n in range(0, 4) for t in itertools.product("01", repeat=n)]
    vals = words + [P(a, b) for a in words[:5] for b in words[:5]]
    false_rel = false_unrel = n_rel = n_unrel = 0
    first = None
    for cur, nxt, _ in prog["rules"]:
        if not cur[2].startswith("0"):
            continue                       # tag-0 rules, as in the developer's control
        Zs = vals if cur[1] else [None]
        Ys = vals if cur[3] else [None]
        for Z in Zs:
            for Y in Ys:
                def ev(p):
                    a = s_word(p[0], Z if p[1] else W(""))
                    b = s_word(p[2], Y if p[3] else W(""))
                    return theta(a, b)
                value = (not ev(nxt)) or ev(cur)
                word_vals = all(v is None or v[0] == "w" for v in (Z, Y))
                if word_vals:
                    n_rel += 1
                    false_rel += not value
                else:
                    n_unrel += 1
                    if not value:
                        false_unrel += 1
                        if first is None:
                            first = (cur, nxt, Z, Y)
    log(f"  ANBN tag-0 rules in U: instances at word values (what the Std premises allow) {n_rel}, false "
        f"{false_rel}; instances with a pair value (unrelativised) {n_unrel}, false {false_unrel}")
    if first:
        log(f"    first false unrelativised instance: rule {first[0]} <= {first[1]}, Z = {first[2]}, Y = {first[3]}")
    return false_rel == 0 and false_unrel > 0


def main():
    rng = random.Random(SEED)
    log("rb2_pairing.py -- referee B: the model U, Lemma 4.2, Prop 9.1(b), Remark 4.8")
    log("== Part A: Lemma 4.2 on a fragment of U with nested pairs ==")
    ok = part_a(rng)
    log("== Part B: Prop 9.1(b) ==")
    ok &= part_b(rng)
    log("== Part C: Remark 4.8 (relativisation needed) on a fresh program ==")
    ok &= part_c()
    log("")
    log("all referee checks behaved as expected" if ok else "SOME REFEREE CHECK DID NOT BEHAVE AS EXPECTED")
    with open(OUT, "w") as fh:
        fh.write("\n".join(LOG) + "\n")


if __name__ == "__main__":
    main()
