"""r5 (referee): section 7 of notes.md.

(1) Prop 7.2 / 7.3 re-checked independently: Bel is k-monotone for k = 2, 3, 4 (all sentence tuples on 2 atoms;
    random tuples on 3 atoms), and the bracketing Bel <= P <= Pl.
(2) The remark after c5: "The coherent cases are essentially those where every theory is complete."  We classify random
    posteriors (same generator design as c5, independent code and seed): for the 50/50 rule H = Bel + Ind/2 we test the
    alternative characterisation "every theory in the support has at most 2 models"; for renormalisation we count how
    many coherent cases have all theories complete.
Sentences = sets of valuations; a consistent theory = nonempty set of valuations Mod(T); T |- s iff Mod(T) <= s.
Coherence of an assignment g = existence of a probability x on valuations with x(s) = g(s) for all s (LP).
"""
import itertools
import random
import numpy as np
from scipy.optimize import linprog

out = []
rng = random.Random(505)

def sentences(nv):
    return [frozenset(c) for r in range(nv + 1) for c in itertools.combinations(range(nv), r)]

def bel(post, s):
    return sum(w for T, w in post if T <= s)

def coherent(assign, nv):
    keys = list(assign)
    Aeq = [[1.0 if v in s else 0.0 for v in range(nv)] for s in keys] + [[1.0] * nv]
    beq = [assign[s] for s in keys] + [1.0]
    res = linprog(np.zeros(nv), A_eq=Aeq, b_eq=beq, bounds=[(0, 1)] * nv, method='highs')
    return res.status == 0

def kmono_violations(post, sents, k, samples=None):
    viol = 0
    tuples = itertools.combinations(sents, k) if samples is None else (rng.sample(sents, k) for _ in range(samples))
    for tup in tuples:
        union = frozenset().union(*tup)
        rhs = 0.0
        for r in range(1, k + 1):
            for I in itertools.combinations(tup, r):
                inter = frozenset.intersection(*I)
                rhs += (-1) ** (r + 1) * bel(post, inter)
        if bel(post, union) + 1e-12 < rhs:
            viol += 1
    return viol

# (1) exhaustive on 2 atoms (4 valuations, 16 sentences) for random posteriors; sampled on 3 atoms
S2 = sentences(4)
v2 = v3 = v4 = 0
for _ in range(40):
    k = rng.randint(1, 4)
    post = [(frozenset(v for v in range(4) if rng.random() < 0.5) or frozenset([rng.randrange(4)]), rng.random())
            for _ in range(k)]
    tot = sum(w for _, w in post)
    post = [(T, w / tot) for T, w in post]
    v2 += kmono_violations(post, S2, 2)
    v3 += kmono_violations(post, S2, 3)
    v4 += kmono_violations(post, S2, 4, samples=2000)
out.append(f"(1) 2 atoms, 40 random posteriors, all pairs/triples and 2000 sampled 4-tuples: violations of 2-, 3-, 4-monotonicity = {v2}, {v3}, {v4}")

# (2) classification on 3 atoms
NV = 8
S3 = sentences(NV)
trials = 300
stats = {'half_coh': 0, 'half_coh_allle2': 0, 'allle2': 0, 'allle2_coh': 0, 'half_coh_allcomplete': 0,
         'ren_coh': 0, 'ren_coh_allcomplete': 0, 'bracket_fail': 0}
for _ in range(trials):
    k = rng.randint(1, 5)
    post = []
    for _ in range(k):
        T = frozenset(v for v in range(NV) if rng.random() < 0.5) or frozenset([rng.randrange(NV)])
        post.append((T, rng.random()))
    tot = sum(w for _, w in post)
    post = [(T, w / tot) for T, w in post]
    allle2 = all(len(T) <= 2 for T, _ in post)
    allcomplete = all(len(T) == 1 for T, _ in post)
    B = {s: bel(post, s) for s in S3}
    D = {s: bel(post, frozenset(range(NV)) - s) for s in S3}
    H = {s: B[s] + (1 - B[s] - D[s]) / 2 for s in S3}
    hc = coherent(H, NV)
    Rr = {s: B[s] / (B[s] + D[s]) for s in S3 if B[s] + D[s] > 1e-12}
    rc = coherent(Rr, NV)
    # bracketing with an independently chosen completion: the max-index model of each theory
    x = np.zeros(NV)
    for T, w in post:
        x[max(T)] += w
    for s in S3:
        Ps = sum(x[v] for v in s)
        if not (B[s] - 1e-12 <= Ps <= 1 - D[s] + 1e-12):
            stats['bracket_fail'] += 1
    stats['half_coh'] += hc
    stats['half_coh_allle2'] += hc and allle2
    stats['half_coh_allcomplete'] += hc and allcomplete
    stats['allle2'] += allle2
    stats['allle2_coh'] += allle2 and hc
    stats['ren_coh'] += rc
    stats['ren_coh_allcomplete'] += rc and allcomplete
out.append(f"(2) 3 atoms, {trials} random posteriors; bracketing failures: {stats['bracket_fail']}")
out.append(f"    50/50 rule coherent in {stats['half_coh']} trials; of these, every theory complete in "
           f"{stats['half_coh_allcomplete']}, every theory with <= 2 models in {stats['half_coh_allle2']}")
out.append(f"    trials with every theory having <= 2 models: {stats['allle2']}, of which 50/50-coherent: {stats['allle2_coh']}")
out.append(f"    renormalisation coherent in {stats['ren_coh']} trials; of these, every theory complete in {stats['ren_coh_allcomplete']}")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
