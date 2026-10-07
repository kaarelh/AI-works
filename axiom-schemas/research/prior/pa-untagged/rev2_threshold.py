# (2) Exact threshold for PA-shaped targets R* = G (m ground premise-free steps) u inst(sigma_ind).
# Claim, positive data with G in D:       exact  <=>  Sub_ind(D) not covered by k-1 failure sets.
# Claim, plus negatives forbidding every merge of two ground axioms (world-refuted false Pi_1 steps):
#                                          exact  <=>  Sub_ind(D) not covered by k-m failure sets.
# Paper: sufficient "not covered by k" (Thm untagged(a)); blocking "covered by k-k'+1 = k-m" (Prop diversity(a)).
from rev_common import *
NEG = [ax_V(ALL(x, eq(Z, S(Z)))), ax_V(ALL(x, ALL(y, eq(Z, S(Z)))))]
rng = random.Random(7)
ROOTSETS = [('eq',), ('eq','lt'), ('eq','not'), ('eq','lt','not'), ('eq','and','imp'),
            ('eq','lt','not','and','or','imp','all','ex')]
stats = {'pos_ok': 0, 'pos_bad': 0, 'neg_ok': 0, 'neg_bad': 0}
dist = {}
trials = 0
while trials < 300:
    m = rng.choice([1, 2, 3])
    G = [ax_V(A) for A in rng.sample(Q, m)]
    roots = rng.choice(ROOTSETS)
    n = rng.choice([2, 3, 4, 5])
    if m + n > 8: continue
    inds = []
    while len(inds) < n:
        f = rand_formula(rng, 2, root=rng.choice(roots), roots=roots)
        if free_in(f, x): inds.append(ind(f))
    D = G + inds
    if len(set(D)) < len(D): continue
    k = rng.choice(range(m + 1, m + 4))
    mc = min_cover([theta(s) for s in inds], cap=k + 1)
    mc = mc if mc is not None else 99
    e_pos = exact(D, k)
    e_neg = exact(D, k, NEG)
    pred_pos = mc > k - 1
    pred_neg = mc > k - m
    stats['pos_ok' if e_pos == pred_pos else 'pos_bad'] += 1
    stats['neg_ok' if e_neg == pred_neg else 'neg_bad'] += 1
    key = (m, k, min(mc, k + 2), e_pos, e_neg); dist[key] = dist.get(key, 0) + 1
    trials += 1
print(stats)
print('cases where positive-only is NOT exact but negatives make it exact:',
      sum(v for (m, k, mc, ep, en), v in dist.items() if (not ep) and en))
print('cases with paper Thm(a) silent (cover <= k) yet exact (positive only):',
      sum(v for (m, k, mc, ep, en), v in dist.items() if mc <= k and ep))
print('cases with paper Prop(a) silent (cover > k-m) yet NOT exact (positive only):',
      sum(v for (m, k, mc, ep, en), v in dist.items() if mc > k - m and not ep))
