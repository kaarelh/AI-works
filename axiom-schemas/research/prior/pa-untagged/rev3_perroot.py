# (3) At the edge k-1 = (#P-roots in the data), positive data only: the cautious H_k verifier
# learns induction separately per main connective: a well-formed induction instance q is accepted
# iff root(q's phi) occurs in the data and q is an instance of the lgg of that root class.
from rev_common import *
def min_hyps(D, k, neg=()):
    D = list(dict.fromkeys(D)); out = []
    for part in set_partitions_le_k(D, k):
        L = [lgg_list(b) for b in part]
        if any(is_instance(s, l) for s in neg for l in L): continue
        out.append(L)
    return out
def acc(q, H): return all(any(is_instance(q, l) for l in L) for L in H)

rng = random.Random(3)
DROOTS = ('eq', 'not', 'and')
G = [ax_V(Q[3])]
data = {}
for r in DROOTS:
    data[r] = []
    while len(data[r]) < 2:
        f = rand_formula(rng, 2, root=r)
        if free_in(f, x): data[r].append(ind(f))
D = G + [s for r in DROOTS for s in data[r]]
cls_lgg = {r: lgg_list(data[r]) for r in DROOTS}
for r in DROOTS: print('class lgg', r, ':', show(cls_lgg[r])[:110])
queries = []
while len(queries) < 120:
    f = rand_formula(rng, 3)
    if free_in(f, x): queries.append(ind(f))
illformed = ('st', ('Sub', Z, x, Z, Z), ('Sub', Z, x, S(x), Z), IMP(AND(Z, ALL(x, IMP(Z, Z))), ALL(x, Z)))
assert is_instance(illformed, SIG)
for k in (3, 4, 5):
    H = min_hyps(D, k)
    agree = disagree = 0; acc_in = acc_out = 0
    for q in queries:
        rq = theta(q)['P'][0]
        pred = rq in DROOTS and is_instance(q, cls_lgg[rq])
        a = acc(q, H)
        if a == pred: agree += 1
        else: disagree += 1
        if rq in DROOTS: acc_in += a
        else: acc_out += a
    n_in = sum(theta(q)['P'][0] in DROOTS for q in queries)
    print(f'k={k} (k-1={k-1}, data roots={len(DROOTS)}): per-root prediction agrees on {agree}/{len(queries)}; '
          f'accepted: {acc_in}/{n_in} with a data root, {acc_out}/{len(queries)-n_in} with another root; '
          f'ill-formed P:=0 accepted: {acc(illformed, H)}')
