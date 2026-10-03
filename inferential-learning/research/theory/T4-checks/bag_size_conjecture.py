"""Test the conjecture  M_bag^(r) <= r * M_obj  (bag size r costs at most a factor r over objects)
on random small classes and on structured classes."""
import random
from bag_vs_object_game import solve, single_culprit, k_culprit
rng = random.Random(3); tested = 0; worst = 0.0; viol = []
classes = [single_culprit(n) for n in range(2, 6)] + [k_culprit(5, 2), k_culprit(4, 2)]
for t in range(140):
    m = rng.randint(3, 4); H = list({rng.randrange(1 << m) for _ in range(rng.randint(2, 7))})
    if len(H) >= 2: classes.append((H, m))
for H, m in classes:
    mo = solve(H, m, 'obj')
    for r in range(1, m + 1):
        mb = solve(H, m, 'bag', r)
        tested += 1; worst = max(worst, mb / (r * mo))
        if mb > r * mo: viol.append((H, m, r, mb, mo))
print("tested", tested, "(class, r) pairs; max M_bag^(r)/(r*M_obj) =", round(worst, 3), "; violations:", viol[:5])
