"""Compare Thm 2.4's abstract realizability (R2: DEF value arbitrary) with realizability in the
Def 1.3 frame semantics (one frame per world; DEF = push-forward, undeformed params rigid).
Toy: params (p1,p2) in {0,1}^2; frame = partial map Lambda -> Q in {0,1,2}; root principal at lam*;
DEF c1, c2 children of root, each deforming D={2} toward 0 (limit semantics).
Structures: (p1, p2, Q). Atoms over these."""
import itertools
LAM = [(a, b) for a in (0, 1) for b in (0, 1)]
ATOMS = {"top": lambda s: True, "p1=0": lambda s: s[0] == 0, "p1=1": lambda s: s[0] == 1,
         "Q=1": lambda s: s[2] == 1, "Q=2": lambda s: s[2] == 2, "bot": lambda s: False}
def frames():
    for assign in itertools.product([None, 0, 1, 2], repeat=4):
        yield {lam: q for lam, q in zip(LAM, assign) if q is not None}
def def13_realizable(J, C):
    for F in frames():
        for lam in F:  # actual point in dom
            M = {0: [(lam[0], lam[1], F[lam])]}
            for c in (1, 2):
                pt = (lam[0], 0)
                M[c] = [(pt[0], pt[1], F[pt])] if pt in F else []
            if any(len(M[c]) == 0 for c in C): continue
            if all(all(ATOMS[f](s) for s in M[c]) for (c, f) in J): return True
    return False
def thm24_criterion(J, C):
    anc = {0} | set(C)
    S = [(a, b, q) for a in (0, 1) for b in (0, 1) for q in (0, 1, 2)]
    return all(any(all(ATOMS[f](s) for (cc, f) in J if cc == c) for s in S) for c in anc)
cases = {"silent change of undeformed parameter": ([(0, "p1=1"), (1, "p1=0")], {1}),
         "identically-declared sibling DEF contexts disagree": ([(1, "Q=1"), (2, "Q=2")], {1, 2})}
for name, (J, C) in cases.items():
    print(name, "| Thm 2.4 criterion:", thm24_criterion(J, C), "| Def 1.3 realizable:", def13_realizable(J, C))
