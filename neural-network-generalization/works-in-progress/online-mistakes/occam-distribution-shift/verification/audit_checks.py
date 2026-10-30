"""Independent finite checks for the Occam audit; not substitutes for proofs."""
from functools import lru_cache
from fractions import Fraction
from math import log
from random import Random

rng = Random(301026)

# Worst cumulative uniform-tier error over all query orders, for abstract finite
# hypothesis classes on four points. All 16 labelings have a finite random tier.
tier_cases = 0
for trial in range(40):
    tiers = [rng.randrange(1, 5) for _ in range(16)]
    sizes = [sum(v == j for v in tiers) for j in range(1, 5)]
    for target in range(16):
        @lru_cache(None)
        def worst(seen):
            if seen == 15:
                return Fraction(0)
            surviving = [h for h in range(16) if not ((h ^ target) & seen)]
            rank = min(tiers[h] for h in surviving)
            chosen = [h for h in surviving if tiers[h] == rank]
            return max(
                Fraction(sum(bool((h ^ target) & (1 << x)) for h in chosen), len(chosen))
                + worst(seen | (1 << x))
                for x in range(4) if not seen & (1 << x)
            )
        bound = sum(log(n) for n in sizes[:tiers[target]] if n) + tiers[target]
        assert float(worst(0)) <= bound + 1e-12
        tier_cases += 1
print(f"Uniform-tier arbitrary-order DP: {tier_cases} exact-rational cases passed")

# Generate random NAND DAGs, independently prune their value-1 proofs at 1^d,
# count proof-DAG vertices/edges, and exhaust every completion of each certificate.
nand_cases = 0
for trial in range(5000):
    d, s = rng.randrange(1, 7), rng.randrange(1, 18)
    gates = [(rng.randrange(d+2+j), rng.randrange(d+2+j)) for j in range(s)]
    def evaluate(x):
        vals = [bool(x & (1 << i)) for i in range(d)] + [False, True]
        for a, b in gates:
            vals.append(not (vals[a] and vals[b]))
        return vals
    vals = evaluate((1 << d) - 1)
    if not vals[-1]:
        continue
    visited, edge_count = set(), [0]
    def visit(v):
        if v in visited:
            return
        visited.add(v)
        if v < d+2:
            return
        a, b = gates[v-d-2]
        children = [a if not vals[a] else b] if vals[v] else [a, b]
        edge_count[0] += len(children)
        for child in children:
            visit(child)
    visit(d+1+s)
    true_gates = sum(v >= d+2 and vals[v] for v in visited)
    false_gates = sum(v >= d+2 and not vals[v] for v in visited)
    leaves = sum(v < d+2 for v in visited)
    cert = sum(1 << v for v in visited if v < d)
    assert false_gates <= true_gates
    assert len(visited)-1 <= edge_count[0] <= true_gates + 2*false_gates
    assert leaves <= false_gates+1 <= s//2+1
    assert cert.bit_count() <= s//2+1
    assert all(evaluate(x)[-1] for x in range(1 << d) if x & cert == cert)
    nand_cases += 1
print(f"NAND retained-DAG certificate checks: {nand_cases} true-output DAGs passed")

# Exact shared-DAG NAND minimum size for AND in d=2,3. A state is the set of
# computed truth tables; duplicate/no-op gates never help a minimum circuit.
for d in (2, 3):
    mask = (1 << (1 << d))-1
    base = {0, mask} | {sum(1 << x for x in range(1 << d) if x & (1 << i)) for i in range(d)}
    target = 1 << ((1 << d)-1)
    states = {frozenset()}
    found = None
    for s in range(1, 2*d-1):
        nxt = set()
        for state in states:
            avail = sorted(base | set(state))
            for ia, a in enumerate(avail):
                for b in avail[ia:]:
                    value = mask ^ (a & b)
                    if value == target:
                        found = s
                        break
                    if value not in base and value not in state:
                        nxt.add(state | {value})
                if found is not None:
                    break
            if found is not None:
                break
        if found is not None:
            break
        states = nxt
    assert found == 2*d-2
    print(f"Exact NAND AND_{d} minimum: {found} gates")
