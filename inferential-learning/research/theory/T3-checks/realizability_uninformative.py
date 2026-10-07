"""Variant: bridges export Q_parent in [a-1, a+1] (uninformative on Q in {0,1,2}: the intersection
over a of the conclusions is {1}, satisfiable). The criterion then becomes too strict: there are
realizable instances it rejects. Confirms the informativeness hypothesis in Thm 2.3 is needed."""
import realizability as R
for a in range(3):
    R.ATOMS[f"Q~{a}"] = (lambda a: lambda v: abs(v[1]-a) <= 1)(a)
R.NAMES = [n for n in R.NAMES]
def random_instance(rng):
    parent = {1: 0, 2: rng.choice([0, 1])}; J, bridges = [], []
    for _ in range(rng.randint(1, 5)):
        c = rng.choice([0, 1, 2]); G = rng.sample(R.NAMES, rng.choice([0, 0, 1])); J.append((c, tuple(G), rng.choice(R.NAMES)))
    for c in (1, 2):
        if rng.random() < 0.6:
            a = rng.randint(0, 2); s = rng.choice(["top", "p", "~p"]); p = parent[c]
            bridges.append((c, a, s)); J += [(c, (), f"Q={a}"), (p, (), s), (p, (), f"Q~{a}")]
    return parent, J, bridges, set(), []
def brute(parent, J, bridges, certC, certP):
    import itertools
    subsets = [frozenset(s) for r in range(len(R.VALS)+1) for s in itertools.combinations(R.VALS, r)]
    for w in R.VALS:
        for M1 in subsets:
            for M2 in subsets:
                M = {0: [w], 1: M1, 2: M2}
                if not all(R.holds(M[c], G, f) for (c, G, f) in J): continue
                if all(not (R.holds(M[c], (), f"Q={a2}") and R.holds(M[parent[c]], (), s)) or R.holds(M[parent[c]], (), f"Q~{a2}")
                       for (c, a, s) in bridges for a2 in range(3)):
                    return True
    return False
import random
rng = random.Random(7); mism = 0
for _ in range(600):
    inst = random_instance(rng)
    if brute(*inst) != R.criterion(*inst): mism += 1
print("mismatches with uninformative bridges:", mism)
