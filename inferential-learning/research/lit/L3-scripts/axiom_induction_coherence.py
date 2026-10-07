"""
L3 sanity check: are the read-outs of the user's 'Solomonoff axiom induction'
coherent probability assignments?

Setting: propositional atoms p,q. A 'hypothesis' is a finite axiom set A,
identified with its set of models Mod(A) (subset of the 4 valuations).
Weights mu(A). For a sentence phi (a set of valuations):
  pT(phi) = mu{A : Mod(A) subset of phi}            (A proves phi)
  pF(phi) = mu{A : Mod(A) disjoint from phi}       (A refutes phi)
  pI(phi) = 1 - pT - pF                            (independent)
Read-outs tested:
  R1 renormalise:   P(phi) = pT/(pT+pF)
  R2 half-split:    P(phi) = pT + pI/2
  R3 completion:    P(phi) = sum_A mu(A) * lambda_A(phi), lambda_A uniform on Mod(A)
A read-out is coherent iff some probability vector on the 4 valuations
reproduces it on all 16 sentences (all subsets of valuations).
We also check Bel = pT is a Dempster-Shafer belief function: pT <= P <= 1-pF for R3.
"""
import itertools
from fractions import Fraction as F

V = [(a, b) for a in (0, 1) for b in (0, 1)]          # valuations of (p,q)
SENT = [frozenset(s) for r in range(5) for s in itertools.combinations(range(4), r)]

def mod(pred):
    return frozenset(i for i, v in enumerate(V) if pred(*v))

def readouts(hyps):
    out = {}
    for phi in SENT:
        pT = sum(w for M, w in hyps if M <= phi)
        pF = sum(w for M, w in hyps if not (M & phi))
        pI = 1 - pT - pF
        r1 = pT / (pT + pF) if pT + pF > 0 else None
        r2 = pT + pI / 2
        r3 = sum(w * F(len(M & phi), len(M)) for M, w in hyps)
        out[phi] = (pT, pF, r1, r2, r3)
    return out

def coherent(P):
    """P: dict sentence->value (None = undefined, skipped). Coherent iff the
    atoms' values {P(frozenset({i}))} are >=0, sum to 1 and every defined
    sentence equals the sum over its valuations (additivity on a finite algebra)."""
    atoms = [P.get(frozenset({i})) for i in range(4)]
    if any(a is None for a in atoms):
        return False, "an atom-of-the-algebra value is undefined"
    if any(a < 0 for a in atoms) or sum(atoms) != 1:
        return False, f"atoms {atoms} not a distribution"
    for phi, val in P.items():
        if val is None:
            continue
        if val != sum(atoms[i] for i in phi):
            return False, f"additivity fails on {sorted(phi)}: {val} vs {sum(atoms[i] for i in phi)}"
    return True, "ok"

def show(name, hyps):
    ro = readouts(hyps)
    print(f"== {name}")
    for k, label in ((2, "R1 renormalise"), (3, "R2 half-split"), (4, "R3 random completion")):
        P = {phi: ro[phi][k] for phi in SENT}
        print(f"   {label:22s} coherent? {coherent(P)}")
    ok = all(ro[phi][0] <= ro[phi][4] <= 1 - ro[phi][1] for phi in SENT)
    print(f"   Bel <= R3 <= Pl on all sentences: {ok}")

p = lambda a, b: a == 1
q = lambda a, b: b == 1
# Example 1: A1 = {p, not q}, A2 = {q}, equal weights
A1 = mod(lambda a, b: a == 1 and b == 0)
A2 = mod(lambda a, b: b == 1)
show("A1={p,~q}, A2={q}, weights 1/2,1/2", [(A1, F(1, 2)), (A2, F(1, 2))])
# Example 2: single empty axiom set (everything contingent is independent)
show("A=empty (tautologies only)", [(frozenset(range(4)), F(1))])
# explicit violation for R1 in example 1: P(p)=1, P(q)=1/2, P(p&q)=0
ro = readouts([(A1, F(1, 2)), (A2, F(1, 2))])
print("   ex1 R1: P(p)=", ro[mod(p)][2], " P(q)=", ro[mod(q)][2], " P(p&q)=", ro[mod(lambda a, b: a and b)][2])
ro = readouts([(frozenset(range(4)), F(1))])
print("   ex2 R2: P(p)=", ro[mod(p)][3], " P(p&q)=", ro[mod(lambda a, b: a and b)][3], " P(p&~q)=", ro[mod(lambda a, b: a and not b)][3])
