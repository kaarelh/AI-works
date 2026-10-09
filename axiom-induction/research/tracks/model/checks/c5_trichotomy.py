"""c5: the trichotomy true/false/independent (notes, section 7).

Propositional sentences over atoms are identified with their sets of models (valuations).  A consistent theory T is a
nonempty set of valuations Mod(T); T |- s iff Mod(T) is a subset of Mod(s).
Checks:
  (1) Bel(s) := pi(T |- s) is totally monotone (a belief function) for random posteriors over random theories
      (k-monotonicity checked for k = 2, 3 on random triples of sentences);
  (2) the constructed P (push each T's mass to one model of T) satisfies Bel <= P <= Pl for every sentence;
  (3) renormalisation R(s) = Bel(s)/(Bel(s)+Dis(s)) is incoherent on Example 7.4 (LP infeasible), and on random posteriors
      it is incoherent most of the time;
  (4) the 50/50 rule H(s) = Bel(s) + Ind(s)/2 is incoherent already for the single empty theory (Example 7.5).
Coherence of an assignment g on a set of sentences := some probability on valuations has P(s) = g(s) for all of them (LP).
"""
import itertools
import random
import numpy as np
from scipy.optimize import linprog

out = []
rng = random.Random(7)


def all_sentences(nv):
    """All sentences up to equivalence = all subsets of the nv valuations (as frozensets)."""
    return [frozenset(c) for r in range(nv + 1) for c in itertools.combinations(range(nv), r)]


def bel_dis_ind(post, sentences):
    B, D, I = {}, {}, {}
    for s in sentences:
        comp = frozenset(range(NV)) - s
        b = sum(w for T, w in post if T <= s)
        d = sum(w for T, w in post if T <= comp)
        B[s], D[s], I[s] = b, d, 1 - b - d
    return B, D, I


def coherent(assign, nv):
    """Is there a probability vector x on valuations with sum_{v in s} x_v = assign[s] for all s?"""
    sents = list(assign)
    Aeq = [[1.0 if v in s else 0.0 for v in range(nv)] for s in sents] + [[1.0] * nv]
    beq = [assign[s] for s in sents] + [1.0]
    res = linprog(np.zeros(nv), A_eq=Aeq, b_eq=beq, bounds=[(0, 1)] * nv, method='highs')
    return res.status == 0


# ---------- Example 7.4: T1 = {a}, T2 = {b}, T3 = {not(a and b)}, atoms a, b; valuations 0..3 = (a,b) in 00,01,10,11
NV = 4
val = {v: ((v >> 1) & 1, v & 1) for v in range(NV)}
a = frozenset(v for v in range(NV) if val[v][0])
b = frozenset(v for v in range(NV) if val[v][1])
nab = frozenset(range(NV)) - (a & b)
post = [(a, 1/3), (b, 1/3), (nab, 1/3)]
S = all_sentences(NV)
B, D, I = bel_dis_ind(post, S)
R = {s: B[s] / (B[s] + D[s]) for s in S if B[s] + D[s] > 0}
out.append(f"Ex 7.4: R(a) = {R[a]:.3f}, R(b) = {R[b]:.3f}, R(a and b) = {R[a & b]:.3f};"
           f" coherent on {{a, b, a&b}}: {coherent({a: R[a], b: R[b], a & b: R[a & b]}, NV)}")

# ---------- Example 7.5: the empty theory, atoms b, c; 50/50 rule
post0 = [(frozenset(range(NV)), 1.0)]
B0, D0, I0 = bel_dis_ind(post0, S)
Hh = {s: B0[s] + I0[s] / 2 for s in S}
bb, cc = a, b   # rename: first atom plays b, second plays c
out.append(f"Ex 7.5: H(b) = {Hh[bb]}, H(b&c) = {Hh[bb & cc]}, H(b&~c) = {Hh[bb - cc]};"
           f" coherent on these three: {coherent({bb: Hh[bb], bb & cc: Hh[bb & cc], bb - cc: Hh[bb - cc]}, NV)}")

# ---------- random posteriors over 3 atoms
NV = 8
S = all_sentences(NV)
viol_k2 = viol_k3 = 0
bracket_fail = 0
renorm_incoh = 0
half_incoh = 0
trials = 300
for trial in range(trials):
    k = rng.randint(1, 5)
    post = []
    ws = [rng.random() for _ in range(k)]
    tot = sum(ws)
    for j in range(k):
        T = frozenset(v for v in range(NV) if rng.random() < 0.5) or frozenset([rng.randrange(NV)])
        post.append((T, ws[j] / tot))
    B, D, I = bel_dis_ind(post, S)
    # (1) 2- and 3-monotonicity on random sentence pairs/triples
    for _ in range(50):
        x, y, z = rng.sample(S, 3)
        if B[x | y] + 1e-12 < B[x] + B[y] - B[x & y]:
            viol_k2 += 1
        lhs = B[x | y | z]
        rhs = (B[x] + B[y] + B[z] - B[x & y] - B[x & z] - B[y & z] + B[x & y & z])
        if lhs + 1e-12 < rhs:
            viol_k3 += 1
    # (2) bracket: P from one model per theory
    x = np.zeros(NV)
    for T, w in post:
        x[min(T)] += w
    for s in S:
        Ps = sum(x[v] for v in s)
        if not (B[s] - 1e-12 <= Ps <= 1 - D[s] + 1e-12):
            bracket_fail += 1
    # (3) renormalisation on all decided sentences
    Rr = {s: B[s] / (B[s] + D[s]) for s in S if B[s] + D[s] > 1e-12}
    if not coherent(Rr, NV):
        renorm_incoh += 1
    # (4) 50/50 on all sentences
    Hh = {s: B[s] + I[s] / 2 for s in S}
    if not coherent(Hh, NV):
        half_incoh += 1
out.append(f"random posteriors (3 atoms, {trials} trials): 2-monotonicity violations {viol_k2}, "
           f"3-monotonicity violations {viol_k3}, bracket Bel<=P<=Pl failures {bracket_fail}")
out.append(f"   renormalisation incoherent in {renorm_incoh}/{trials} trials; 50/50 incoherent in {half_incoh}/{trials} trials")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
