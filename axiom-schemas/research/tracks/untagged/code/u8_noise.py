# u8: noise.  PA data (Q1..Q7 + raw induction) with three kinds of mistaken data:
#   M1 refutable false sentences (mutated Q axioms; a wrong-base induction variant whose antecedent is provable),
#   M2 false but unrefutable (for this oracle) sentences (J*_0 of the R1 theorem; a wrong-base variant needing Q1),
#   M3 true non-target sentences (theorems used as if axioms).
# DTRC with multiplicities; robust variant: clusters of multiplicity < s are not asserted; trimmed verifier.
import sys, random, itertools
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code')
from dtlib import *
from dtrc import World, DTRC
from practice import *

M1 = [eq(add(a1, Z), S(a1)), eq(mul(a1, Z), a1),
      IMP(AND(eq(Z, Z), ALL(IMP(eq(S(V(0)), V(0)), eq(S(S(V(0))), S(V(0)))))), ALL(eq(S(V(0)), V(0))))]
J0star = IMP(AND(eq(add(Z, Z), Z), ALL(IMP(eq(add(Z, V(0)), Z), eq(add(Z, S(V(0))), S(Z))))), ALL(eq(add(Z, V(0)), Z)))
indS_neg = IMP(AND(NOT(eq(S(Z), Z)), ALL(IMP(NOT(eq(V(0), Z)), NOT(eq(S(V(0)), Z))))), ALL(NOT(eq(V(0), Z))))
M2 = [J0star, indS_neg]
M3 = [eq(add(Z, a1), a1), NOT(eq(S(a1), a1))]
W = World('arith', B=3, budget=1500)
for nm, ms in (('M1', M1), ('M2', M2), ('M3', M3)):
    print(nm, [('refuted' if W.refute_sentence(m) else 'unrefuted') for m in ms])

rng = random.Random(11)
clean = pa_data(60, rng)
data = clean + [('M1', m) for m in M1] + [('M2', m) for m in M2] + [('M3', m) for m in M3]
rng.shuffle(data)
mult = {}
lab = {}
for k, s in data:
    mult[s] = mult.get(s, 0) + 1; lab.setdefault(s, set()).add(k)
A = DTRC(W)
A.run([s for _, s in data])
print('clusters:', len(A.clusters), ' coherence tests:', A.tests, ' [v2: passes to audit fixpoint=%d, |N_final|=%d]' % (A.rounds, len(W.neg)))
for C, Ts in zip(A.clusters, A.templates):
    m = sum(mult[s] for s in C)
    labs = sorted(set().union(*[lab[s] for s in C]))
    print('  labels=%-14s distinct=%2d multiplicity=%2d  #unrefuted min templates=%d  %s'
          % (','.join(labs), len(C), m, len(Ts), (pp(Ts[0])[:70] if Ts else '(incoherent: contributes nothing)')))
s_min = 2
print('robust variant: assert only clusters of multiplicity >= %d' % s_min)
asserted = [(C, Ts) for C, Ts in zip(A.clusters, A.templates) if sum(mult[s] for s in C) >= s_min and Ts]
bad = [m for m in M1 + M2 if any(all(covers(T, m) for T in Ts) for C, Ts in asserted)]
print('  mistakes accepted by asserted clusters:', [pp(b)[:60] for b in bad])

print()
print('absorption: J*_0 (false, unrefutable here) among non-diverse induction data Ind(n+x = n+...)')
def motive_n(n):   # S^n 0 + x = S^n x
    t = X
    for _ in range(n): t = S(t)
    return eq(add(num(n), X), t)
ind = [canon_params(Ind(motive_n(n))) for n in range(3)]
C = ind + [J0star]
B = DTRC(W)
print('  cluster {Ind(S^n0+x=S^nx): n<3} + J*_0 coherent:', B.coherent(C) is not None)
Ts = B.unrefuted_min(C)
print('  untrimmed unrefuted minimal templates:')
for T in Ts: print('     ', pp(T), '  <= T_ind:', subsumes(T_IND, T))
falseK = IMP(AND(eq(add(S(Z), Z), S(Z)), ALL(IMP(eq(add(S(Z), V(0)), S(Z)), eq(add(S(Z), S(V(0))), S(S(Z)))))), ALL(eq(add(S(Z), V(0)), S(Z))))
acc = lambda q: bool(Ts) and all(covers(T, q) for T in Ts)
print('  untrimmed verifier accepts J*_0:', acc(J0star), '; accepts the false J*_1 = (S0+0=S0 & Ax(S0+x=S0 -> S0+Sx=SS0)) -> Ax S0+x=S0:', acc(falseK))
def trimmed_accepts(C, q, e):
    found = False
    for r in range(e + 1):
        for E in itertools.combinations(C, r):
            rest = [c for c in C if c not in E]
            for T in B.unrefuted_min(rest):
                found = True
                if not covers(T, q): return False
    return found
print('  trimmed (e=1) accepts J*_0:', trimmed_accepts(C, J0star, 1), '; accepts J*_1:', trimmed_accepts(C, falseK, 1),
      '; accepts the genuine Ind(S^3 0 + x = S^3 x):', trimmed_accepts(C, canon_params(Ind(motive_n(3))), 1))

print()
print('fragmentation: online order puts J*_0 next to two K_0-shaped induction data before the diverse ones')
frag = [canon_params(Ind(motive_n(0))), J0star, canon_params(Ind(motive_n(1))),
        canon_params(Ind(NOT(eq(S(X), Z)))), canon_params(Ind(ALL(eq(add(V(0), X), add(X, V(0)))))),
        canon_params(Ind(IMP(eq(X, Z), eq(add(X, X), X))))]
F = DTRC(W); F.run(frag)
for C, Ts in zip(F.clusters, F.templates):
    print('  cluster of %d: %s  templates: %s' % (len(C), [pp(c)[:28] for c in C], [pp(T)[:60] for T in Ts]))
F2 = DTRC(W); F2.run(frag[2:] + frag[:2])
print('  same data, diverse instances first:', [len(C) for C in F2.clusters])
