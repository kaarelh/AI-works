# A3: realizability. inst(sigma) contains improper instances; every instance with W-true Sub premises
# is a genuine induction instance (so the W-guarded verifier is sound for the genuine set G).
from common import *
import random
rng = random.Random(3)
U = motives_upto(5, ('x', 'y'))
# improper instances of sigma_x
imp1 = ind_raw(eq(x, Z), x, eq(Z, Z), eq(Z, Z))           # false Sub premise (B is not P[Sx/x]); conclusion false
imp2 = ind_raw(S(Z), x, S(Z), S(Z))                        # P is a term, not a formula
imp3 = ind_raw(('Sub', Z, x, Z, Z), x, Z, Z)               # P is a Sub judgment
for s in (imp1, imp2, imp3):
    print('instance of sigma_x:', is_instance(s, SIGMA_X), '| Sub premises W-true:', sub_premises_true(s), '|', show(s)[:110])
print('imp1 conclusion is false (bounded check):', not ev_closure(imp1[-1], B=10, Bfree=3))
# every instance of sigma_x with W-true Sub premises is ind(P): exhaustive over P, A, B in U
cnt = 0; tot = 0
Uext = U + [subst(p, x, S(x)) for p in U]
for P in U[:150]:
    for A in [subst(P, x, Z)] + rng.sample(Uext, 30):
        for B in [subst(P, x, S(x))] + rng.sample(Uext, 30):
            s = ind_raw(P, x, A, B); tot += 1
            if sub_premises_true(s):
                cnt += 1; assert s == ind(P)
print(f'x fixed: {tot} instances checked, {cnt} with W-true Sub premises, all equal to ind(P): True')
# x metavariable: X must be an object variable for Sub to be W-true
cnt = 0; tot = 0
for P in U[:150]:
    for X in (x, y, Z, S(x), add(x, Z)):
        for A in (subst(P, X, Z) if is_objvar(X) else P, P):
            for B in (subst(P, X, S(X)) if is_objvar(X) else P, P):
                s = ind_raw(P, X, A, B); tot += 1
                if sub_premises_true(s): cnt += 1; assert s == ind(P, X)
print(f'x metavariable: {tot} instances checked, {cnt} W-true, all genuine: True')
# guarded acceptance below the target: for random data D, accepted & Sub-true steps are genuine
bad = 0
for _ in range(3000):
    D = [ind(p) for p in rng.sample(U, rng.randint(1, 3))]
    L = lgg_list(D)
    q = ind(rng.choice(U))
    if is_instance(q, L) and not (q[0] == 'st' and sub_premises_true(q) and q == ind(q[1][1])): bad += 1
print('random D, accepted genuine-looking queries that are not genuine:', bad)
