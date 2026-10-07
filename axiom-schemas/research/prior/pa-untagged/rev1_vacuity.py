# (1) For well-formed induction data, Sub_ind(D) is covered by the root failure sets of P
#     (one per formula root symbol), so Thm imitation:untagged(a) never applies once k >= #roots,
#     zeta = 0 for every law on well-formed instances, and pairwise-generic sets have <= #roots members.
from rev_common import *
rng = random.Random(1)
ROOTS = ('eq','lt','not','and','or','imp','all','ex')
pool = []
while len(pool) < 400:
    f = rand_formula(rng, 3, roots=ROOTS)
    if free_in(f, x): pool.append(ind(f))
ths = [theta(s) for s in pool]
assert all(t is not None for t in ths)
roots_P = {t['P'][0] for t in ths}
print('distinct P-roots in 400 random well-formed instances:', sorted(roots_P))
# for well-formed instances root(A)=root(B)=root(P)
print('root(A)=root(B)=root(P) always:', all(t['A'][0] == t['P'][0] == t['B'][0] for t in ths))
# cover by the root failure sets of P
cover = [('root','P',r) for r in sorted(roots_P)]
print('the', len(cover), 'P-root failure sets cover all 400:', all(any(t['P'][0] == F[2] for F in cover) for t in ths))
# pairwise genericity: lgg of two instances == sigma only if their P-roots differ
same_root_generic = 0; checked = 0
for i in range(150):
    for j in range(i+1, 150):
        if ths[i]['P'][0] == ths[j]['P'][0]:
            checked += 1
            L = lgg_list([pool[i], pool[j]])
            if match(L, SIG) is not None: same_root_generic += 1
print(f'same-root pairs checked: {checked}; of these with lgg >= sigma: {same_root_generic}')
# so a pairwise-generic set has distinct P-roots: size <= #roots; greedy max
best = []
for s, t in zip(pool, ths):
    if all(match(lgg_list([s, b]), SIG) is not None for b in best): best.append(s)
print('greedy pairwise-generic subset size:', len(best), '(<= #roots =', len(roots_P), ')')
# with k=8 (k'=8: 7 Q axioms + induction): Thm (a) needs Sub_ind(D) NOT covered by k=8 failure sets
print('Thm (a) hypothesis "not covered by k=8 failure sets" satisfiable by well-formed data (8 roots incl. lt)?', len(roots_P) > 8)
print('"k+1 = 9 pairwise-generic instances" achievable?', len(best) >= 9)
