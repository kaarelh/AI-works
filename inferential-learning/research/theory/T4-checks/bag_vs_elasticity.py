"""Conjecture check: with unbounded (paddable) bags, the optimal learner does no better than the
cautious learner that never accepts outside the version-space intersection, whose worst case is the
positive elasticity (T1's escalation dimension).  Compare M_bag (exact minimax) with E (cautious game)."""
import functools, random, math, itertools
from bag_vs_object_game import solve

def elasticity(H, m):
    n = len(H)
    contains = [sum(1 << i for i, h in enumerate(H) if (h >> s) & 1) for s in range(m)]
    @functools.lru_cache(maxsize=None)
    def E(V):
        hyps = [i for i in range(n) if (V >> i) & 1]
        if len(hyps) <= 1:
            return 0
        inter = (1 << m) - 1
        for i in hyps: inter &= H[i]
        best = 0
        for i in hyps:
            extra = H[i] & ~inter
            for s in range(m):
                if (extra >> s) & 1:
                    V2 = V & contains[s]
                    if V2 != V:
                        best = max(best, 1 + E(V2))
        return best
    return E((1 << n) - 1)

if __name__ == '__main__':
    rng = random.Random(7)
    agree = disagree = 0
    examples = []
    for trial in range(300):
        m = rng.randint(2, 4)
        nh = rng.randint(2, 7)
        H = list({rng.randrange(1 << m) for _ in range(nh)})
        if len(H) < 2: continue
        mb = solve(H, m, 'bag')
        el = elasticity(H, m)
        mo = solve(H, m, 'obj')
        if mb == el: agree += 1
        else:
            disagree += 1
            if len(examples) < 5: examples.append((H, m, mb, el, mo))
    print("M_bag == cautious elasticity:", agree, " differ:", disagree)
    for ex in examples: print("  example H=%s m=%d M_bag=%d el=%d M_obj=%d" % ex)
