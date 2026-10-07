# (4) If the induction variable is a metavariable X (needed when humans induct on x, n, y, ...),
# the variable NAME is a further failure set: data that induct on few names leave a cover by
# sigma[X->x] etc. Also: the k=8 PA picture with world negatives (two false Pi_1 steps).
from rev_common import *
SIGX = sigma_V(True)
rng = random.Random(5)
G = [ax_V(Q[3]), ax_V(Q[5])]
inds = []
for r in ('eq', 'not', 'and', 'imp', 'or'):
    while True:
        f = rand_formula(rng, 2, root=r)
        if free_in(f, x): inds.append(ind_V(f, x)); break
D = G + inds
print('lgg of the induction data (all on variable x):', show(lgg_list(inds))[:100])
print('  >= sigma with X metavariable?', match(lgg_list(inds), SIGX) is not None)
q_y = ind_V(('eq', ('add', y, Z), y), y)          # induction on y, root eq
q_x = ind_V(('eq', ('add', x, Z), x), x)          # same formula on x
for k in (3, 4):
    print(f'k={k}: induction on y accepted: {in_cap_vs(q_y, D, k)}; same on x accepted: {in_cap_vs(q_x, D, k)}')
