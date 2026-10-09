"""c14: when is Hanni's 50/50 rule H(s) = Bel(s) + Ind(s)/2 coherent? (referee issue m4; notes-final Prop 7.6)

Claim (proved in the notes): over finitely many atoms, H is coherent (some probability on valuations has P(s) = H(s) for
every sentence s) iff every theory with positive posterior mass has at most 2 models.
We test both directions by linear programming:
  (1) exhaustively on 2 atoms: every posterior supported on 1 or 2 theories out of all 15 consistent theories, with
      weights (1/2,1/2) and (0.3,0.7), plus 3000 random posteriors on up to 5 theories;
  (2) 600 random posteriors on 3 atoms (8 valuations), with theories biased towards few models so both cases occur.
We also count, for renormalisation R(s) = Bel(s)/(Bel(s)+Dis(s)), how many coherent cases have all theories complete
(the original notes' remark "coherent cases are essentially those where every theory is complete", refuted by the
referee for the 50/50 rule).
"""
import itertools
import random
import numpy as np
from scipy.optimize import linprog

out = []
rng = random.Random(1414)


def sentences(nv):
    return [frozenset(c) for r in range(nv + 1) for c in itertools.combinations(range(nv), r)]


def coherent(assign, nv):
    keys = list(assign)
    Aeq = [[1.0 if v in s else 0.0 for v in range(nv)] for s in keys] + [[1.0] * nv]
    beq = [assign[s] for s in keys] + [1.0]
    res = linprog(np.zeros(nv), A_eq=Aeq, b_eq=beq, bounds=[(0, 1)] * nv, method='highs')
    return res.status == 0


def rules(post, S, nv):
    full = frozenset(range(nv))
    B = {s: sum(w for T, w in post if T <= s) for s in S}
    D = {s: sum(w for T, w in post if T <= full - s) for s in S}
    H = {s: B[s] + (1 - B[s] - D[s]) / 2 for s in S}
    R = {s: B[s] / (B[s] + D[s]) for s in S if B[s] + D[s] > 1e-12}
    return H, R


def run(posts, nv):
    S = sentences(nv)
    agree = disagree = 0
    ren_coh = ren_coh_complete = 0
    n_le2 = 0
    for post in posts:
        H, R = rules(post, S, nv)
        hc = coherent(H, nv)
        le2 = all(len(T) <= 2 for T, w in post if w > 0)
        n_le2 += le2
        if hc == le2:
            agree += 1
        else:
            disagree += 1
        if coherent(R, nv):
            ren_coh += 1
            ren_coh_complete += all(len(T) == 1 for T, w in post if w > 0)
    return agree, disagree, n_le2, ren_coh, ren_coh_complete


# (1) two atoms
NV = 4
theories = [frozenset(c) for r in range(1, NV + 1) for c in itertools.combinations(range(NV), r)]
posts = []
for T in theories:
    posts.append([(T, 1.0)])
for T1, T2 in itertools.combinations(theories, 2):
    posts.append([(T1, 0.5), (T2, 0.5)])
    posts.append([(T1, 0.3), (T2, 0.7)])
for _ in range(3000):
    k = rng.randint(1, 5)
    ts = rng.sample(theories, k)
    ws = [rng.random() for _ in ts]
    z = sum(ws)
    posts.append([(T, w / z) for T, w in zip(ts, ws)])
a, d, n2, rc, rcc = run(posts, NV)
out.append(f"(1) 2 atoms, {len(posts)} posteriors (all 1- and 2-theory supports, plus random): "
           f"criterion agrees with LP coherence in {a}, disagrees in {d}; supports with all theories <= 2 models: {n2}")
out.append(f"    renormalisation coherent in {rc}; of these, all theories complete in {rcc}")

# (2) three atoms
NV = 8
posts = []
for _ in range(600):
    k = rng.randint(1, 4)
    post = []
    for _ in range(k):
        m = rng.choice([1, 1, 2, 2, 2, 3, 4, 6])
        post.append((frozenset(rng.sample(range(NV), m)), rng.random()))
    z = sum(w for _, w in post)
    posts.append([(T, w / z) for T, w in post])
a, d, n2, rc, rcc = run(posts, NV)
out.append(f"(2) 3 atoms, {len(posts)} random posteriors: criterion agrees with LP coherence in {a}, disagrees in {d}; "
           f"supports with all theories <= 2 models: {n2}")
out.append(f"    renormalisation coherent in {rc}; of these, all theories complete in {rcc}")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
