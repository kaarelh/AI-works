#!/usr/bin/env python3
"""rA1_alt_output_rule.py -- referee A, thread `terms`: what Prop 4.7's written construction needs.

Prop 4.7 says: "Compile as in Lemma 4.5 with phases 2 and 3 only (no certificate) ... the rest of the proof of
Thm 4.6(i)-(iii) applies".  Read literally, this takes
  (L1) Lemma 4.5's start rule (Z; c(s)Y) => (blk(#)Z; c(s0)Y), which pushes the separator onto r, and
  (L2) Thm 4.6's output rules  forall x forall z (C(x, eta st(s) z) -> R(x)^eta), with a free certificate z.
The thread's script t3_alternating.py instead uses the start rule (Z; c(s)Y) => (Z; c(s2) blk(#) Y) and the
exact output rules forall x (C(x, eta st(s)) -> R(x)^eta).  This script, which imports the thread's compiler
and fixed-point evaluator unchanged, shows that both literal readings fail:
  Part 1: (L1) gives wrong verdicts on start pairs (the record's self-check 7 found 1023; reproduced here).
  Part 2: with the script's start rule, the exact output rules are correct, and on the script's own machine
          the free-z rules happen to give no wrong verdict; but adding ONE transition that is unreachable from
          every start configuration (q0 reading '0' -> ACC, q0 reading '1' -> REJ; cell 0 of a start tape always
          holds '#') leaves every exact verdict unchanged and makes the free-z output rules derive R(t_x) for
          every x and not-R(t_x) for every x: the theory becomes inconsistent.
Deterministic.  Writes rA1_alt_output_rule.out next to itself.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "checks"))
import t3_alternating as T  # noqa: E402  (main() is guarded; importing runs nothing)

OUT = os.path.join(HERE, "rA1_alt_output_rule.out")
LOG = []


def log(s=""):
    print(s)
    LOG.append(s)


def verdicts(prog, x, z, tag):
    """Least-fixed-point membership of the start pair (x, tag st(s) z) (z = '' is the exact start pair)."""
    return T.accepts(prog, (x, tag + prog["code"]["s"] + z), tag, {})[0]


def main():
    ok = True
    G, S, d, kind = T.alt_machine()
    words = list(T.words(0, 9))

    # Part 1: Lemma 4.5's start rule (separator onto r) in the alternating compile, exact output rules.
    prog = T.compile_alt(G, S, d, kind)
    code, beta = prog["code"], prog["beta"]
    bad_rules = []
    for cur, nxts, conj in prog["rules"]:
        if cur[2][1:] == code["s"] and cur[3]:   # the start rule of either tag
            tag = cur[2][0]
            bad_rules.append(((cur[0], cur[1], cur[2], cur[3]), [(beta["#"], True, tag + code["s2"], True)], conj))
        else:
            bad_rules.append((cur, nxts, conj))
    prog_l1 = dict(prog, rules=bad_rules)
    mism = sum((verdicts(prog_l1, x, "", "0") != T.spec_Y(x)) + (verdicts(prog_l1, x, "", "1") != (not T.spec_Y(x)))
               for x in words)
    log("Part 1: alternating compile with Lemma 4.5's start rule (separator pushed onto r), exact output rules")
    log(f"  wrong verdicts on the 2*{len(words)} exact start pairs with |x| <= 9: {mism}")
    ok &= mism > 0

    # Part 2a: the script's compile; exact versus free-z output rules on the script's machine.
    log("Part 2a: the script's compile (separator onto l)")
    mism_exact = sum((verdicts(prog, x, "", "0") != T.spec_Y(x)) + (verdicts(prog, x, "", "1") != (not T.spec_Y(x)))
                     for x in words)
    log(f"  exact output rules: wrong verdicts on |x| <= 9: {mism_exact}")
    ok &= mism_exact == 0
    zs = [""] + [beta[a] for a in G] + [beta[a] + beta[b] for a in G for b in G] + ["0", "1", "01"]
    wrong_free = 0
    for x in words:
        for z in zs:
            if verdicts(prog, x, z, "0") and not T.spec_Y(x):
                wrong_free += 1
            if verdicts(prog, x, z, "1") and T.spec_Y(x):
                wrong_free += 1
    log(f"  free-z output rules, z among {len(zs)} test words (blocks of single tape symbols and pairs, raw bits): "
        f"wrong verdicts {wrong_free}  (the script's machine gets stuck on every garbage prefix)")

    # Part 2b: add transitions unreachable from start configurations.
    d2 = dict(d)
    d2[("q0", "0")] = [("ACC", "0", "S")]
    d2[("q0", "1")] = [("REJ", "1", "S")]
    prog2 = T.compile_alt(G, S, d2, kind)
    mism2 = sum((verdicts(prog2, x, "", "0") != T.spec_Y(x)) + (verdicts(prog2, x, "", "1") != (not T.spec_Y(x)))
                for x in words)
    acc_all = all(verdicts(prog2, x, prog2["beta"]["0"], "0") for x in words)
    rej_all = all(verdicts(prog2, x, prog2["beta"]["1"], "1") for x in words)
    n_out = sum(not T.spec_Y(x) for x in words)
    n_in = sum(T.spec_Y(x) for x in words)
    log("Part 2b: the same machine plus q0 --'0'--> ACC and q0 --'1'--> REJ (unreachable: a start tape is '#'x)")
    log(f"  exact output rules: wrong verdicts on |x| <= 9: {mism2}")
    log(f"  free-z output rules with z = blk(0): C(x, 0 st(s) blk(0)) holds for every x with |x| <= 9: {acc_all}"
        f"  -> R(t_x) derivable also for the {n_out} words outside Y")
    log(f"  free-z output rules with z = blk(1): C(x, 1 st(s) blk(1)) holds for every x with |x| <= 9: {rej_all}"
        f"  -> not-R(t_x) derivable also for the {n_in} words in Y")
    log("  so the free-z theory proves R(t_x) and not-R(t_x) for every x: inconsistent")
    ok &= mism2 == 0 and acc_all and rej_all
    log("")
    log("all expectations met" if ok else "SOME EXPECTATION FAILED")
    with open(OUT, "w") as fh:
        fh.write("\n".join(LOG) + "\n")


if __name__ == "__main__":
    main()
