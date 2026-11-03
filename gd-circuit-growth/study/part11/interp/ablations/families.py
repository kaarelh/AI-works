"""Target families for the ablation analysis (ABLATIONS.md): every target of the 11 toy suites, assigned by hand from its
definition in study/boolfuncs.py to the 9 groups of the structure atlas (ATLAS.md section 1; atlas_truth.py), and to
three coarse classes:

  character   parities, staircases, address/data multiplexers, compositions of parities and majorities (and polynomial
              thresholds of a few characters), DNF / CNF / decision lists / read-once formulas, random formulas: small
              juntas whose Fourier expansion is short or dominated by a few low-degree characters (ATLAS.md 1.1-1.3,
              1.5-1.7: learned "mostly as characters")
  halfspace   majorities and halfspaces (thresholds of an unsigned or weighted sum of inputs; also the dictator and
              AND of 3, which are halfspaces; inter2, an AND of two halfspaces), learned through degree-1 characters
              and, where one exists, a block (ATLAS.md 1.4)
  sum         symmetric and pure signed-sum targets, and signed-sum mixtures (a function of a signed sum times a
              parity, with a gate, two sums, a multiplexer of two sums, weighted sums u = s + a tau): ATLAS.md 1.8-1.9

Assignment rules (from the definitions): a threshold of an unweighted or weighted sum with one accept boundary is a
halfspace (f7_01 = [s <= 1] and fd_01 = [s >= 0] on unsigned sums, as the atlas puts f7_01); an even or arbitrary accept
set of a signed sum is symmetric / pure signed-sum; a sum combined with anything else is a mixture; the blind family's
non-symmetric controls (read-once formula, DNF, decision list) and Part 1-10's DNF, CNF and decision lists are formulas.
"""
GROUPS = ["Parities", "Staircases", "Multiplexers (address and data bits)", "Majorities and halfspaces", "Compositions",
          "DNF, CNF, decision lists, read-once formulas", "Random formulas", "Symmetric and pure signed-sum targets",
          "Signed-sum mixtures"]                                     # the atlas's 9 groups, in its order
SHORT = {"Parities": "parities", "Staircases": "staircases", "Multiplexers (address and data bits)": "multiplexers",
         "Majorities and halfspaces": "halfspaces", "Compositions": "compositions",
         "DNF, CNF, decision lists, read-once formulas": "formulas", "Random formulas": "random formulas",
         "Symmetric and pure signed-sum targets": "symmetric", "Signed-sum mixtures": "mixtures"}
COARSE = {"Parities": "character", "Staircases": "character", "Multiplexers (address and data bits)": "character",
          "Compositions": "character", "DNF, CNF, decision lists, read-once formulas": "character",
          "Random formulas": "character", "Majorities and halfspaces": "halfspace",
          "Symmetric and pure signed-sum targets": "sum", "Signed-sum mixtures": "sum"}

_G = {
    "Parities": "designed/par2 designed/par3 designed/par4 dlheld/par5",
    "Staircases": "designed/stair5 dlheld/stair6",
    "Multiplexers (address and data bits)": "dlheld/mux6 dlheld3/mux11",
    "Majorities and halfspaces": "designed/dict designed/and3 designed/maj3 designed/maj9 designed/thr10 dlheld/maj15 "
                                 "dlheld/thr30 dlheld/inter2 dlheld2/thr20 dlheld2/maj21 dlheld3/thrint dlfamdev/fd_01 "
                                 "dlheld7/f7_01",
    "Compositions": "designed/majpar designed/parmaj designed/mux designed/rmaj9 designed/andxor designed/sparsepoly "
                    "dlheld/majxor dlheld/majmaj5 dlheld/majpar5 dlheld2/xmaj dlheld3/par3or dlheld3/poly4 dlheld3/mixmaj",
    "DNF, CNF, decision lists, read-once formulas": "designed/dnf3 designed/dlist5 dlheld2/dnf4x2 dlheld3/cnf3 dlheld3/dlist8 "
                                                    "dlheld4/dnf3x3 dlheld6/h6_03 dlheld6/h6_04 dlheld6/h6_05 dlfamdev/fd_00 "
                                                    "dlfamdev/fd_03 dlfamdev/fd_07 dlheld7/f7_02 dlheld7/f7_04 dlheld7/f7_06",
    "Random formulas": "designed/rand0 designed/rand1 designed/rand2 designed/rand3 " +
                       " ".join(f"random/rf{i:02d}" for i in range(20)) +
                       " dlheld/hrf0 dlheld/hrf1 dlheld/hrf2 dlheld2/h2rf0 dlheld2/h2rf1 dlheld3/h3rf0 dlheld3/h3rf1 "
                       "dlheld4/h4rf0 dlheld4/h4rf1 dlheld5/h5rf0 dlheld5/h5rf1",
    "Symmetric and pure signed-sum targets": "dlheld2/sym8 dlheld3/sym9 dlsymdev/sym7 dlsymdev/ex3of8 dlsymdev/band11 "
                                             "dlsymdev/far9 dlsymdev/ssym9 dlheld4/sym11 dlheld4/ex4of9 dlheld4/tail13 "
                                             "dlheld4/band10 dlheld4/ssym8 dlheld5/h5s0 dlheld5/h5s2 dlheld5/h5s3 "
                                             "dlheld5/h5s5 dlheld5/h5s6 dlheld5/h5s7 dlheld6/h6_00 dlheld6/h6_01 "
                                             "dlheld6/h6_11 dlfamdev/fd_09 dlfamdev/fd_10 dlheld7/f7_05 dlheld7/f7_08",
    "Signed-sum mixtures": "dlsymdev/symxpar dlsymdev/twosym dlsymdev/thrsum dlheld4/symxor dlheld4/symand dlheld4/sumpar "
                           "dlheld4/majsym dlheld5/h5s1 dlheld5/h5s4 dlheld5/h5t0 dlheld5/h5t1 dlheld6/h6_02 dlheld6/h6_06 "
                           "dlheld6/h6_07 dlheld6/h6_08 dlheld6/h6_09 dlheld6/h6_10 dlfamdev/fd_02 dlfamdev/fd_04 "
                           "dlfamdev/fd_05 dlfamdev/fd_06 dlfamdev/fd_08 dlfamdev/fd_11 dlheld7/f7_00 dlheld7/f7_03 "
                           "dlheld7/f7_07 dlheld7/f7_09 dlheld7/f7_10 dlheld7/f7_11",
}
FAMILY = {}
for g, s in _G.items():
    for x in s.split():
        su, t = x.split("/")
        assert (su, t) not in FAMILY, x
        FAMILY[(su, t)] = g
# residue classes mod 3 (never learned by any learner of the study; THEORY.md P4e), kept apart where a table says so
MOD3 = {("dlheld6", "h6_00"), ("dlfamdev", "fd_10"), ("dlheld7", "f7_05")}


def family(su, t):
    return FAMILY[(su, t)]


def coarse(su, t):
    return COARSE[FAMILY[(su, t)]]


if __name__ == "__main__":                                          # check: every target of every suite, exactly once
    import os, sys
    HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, os.path.dirname(os.path.dirname(HERE)))
    import eval_dfg as E
    from collections import Counter
    TOY = ["designed", "random", "dlheld", "dlheld2", "dlheld3", "dlsymdev", "dlheld4", "dlheld5", "dlheld6", "dlfamdev", "dlheld7"]
    seen = set()
    for su in TOY:
        T = getattr(E.boolfuncs, E.DL[su])(30) if su in E.DL else E.TH.suite_targets(su, 30)[0]
        for t in T:
            assert (su, t) in FAMILY, (su, t)
            seen.add((su, t))
    assert seen == set(FAMILY), set(FAMILY) - seen
    print(len(FAMILY), "targets;", dict(Counter(FAMILY.values())))
    print("coarse:", dict(Counter(COARSE[g] for g in FAMILY.values())))
    A = ["designed", "dlsymdev", "dlfamdev", "dlheld6", "dlheld7"]
    print("ablation suites:", dict(Counter(FAMILY[k] for k in FAMILY if k[0] in A)))
