# e6: escalations of the cautious DT° verifier (Theorem F).
#   (1) along every chain, each escalated query strictly decreases the potential
#       (|C|, sum(depth - |Y|), #equation features) lexicographically, and the chain length after
#       the first datum d1 is <= |d1| + sum_p b(p) + #incomparable position pairs of d1.
#   (2) greedy adversarial search for LONG chains (heuristic lower bounds on Esc).
# usage: python3 e6_escalation.py TRIALS SEED
import sys, random, time
from dtcore import *
from dtfeat import Prefix
from dtrandom import rand_term

TR = int(sys.argv[1]) if len(sys.argv) > 1 else 40
SEED = int(sys.argv[2]) if len(sys.argv) > 2 else 5
rng = random.Random(SEED)


def rand_sentence(rng, size, depth=0):
    if size <= 3:
        return eq(rand_term(rng, depth, 1), rand_term(rng, depth, 1))
    r = rng.random()
    if r < 0.25:
        a = rng.randint(1, size - 2)
        return eq(rand_term(rng, depth, a), rand_term(rng, depth, size - 1 - a))
    if r < 0.4:
        return NOT(rand_sentence(rng, size - 1, depth))
    if r < 0.75:
        a = rng.randint(3, max(3, size - 4))
        return AND(rand_sentence(rng, a, depth), rand_sentence(rng, max(3, size - 1 - a), depth))
    return ALL(rand_sentence(rng, size - 1, depth + 1))


def mutate(rng, s):
    """replace a random subterm/subformula by a random one of the same sort and similar size"""
    cand = [(p, t, d, srt) for (p, t, d, srt) in positions(s)]
    p, t, d, srt = rng.choice(cand)
    n = max(1, size(t) + rng.choice([-1, 0, 0, 1]))
    new = rand_term(rng, d, min(n, 3)) if srt == 'T' else rand_sentence(rng, max(3, n), d)
    def put(u, path, v):
        if not path:
            return v
        ks = list(kids(u))
        ks[path[0]] = put(ks[path[0]], path[1:], v)
        return rebuild(u, ks)
    return put(s, p, new)


def bound(d1):
    ps = list(positions(d1))
    n = len(ps)
    sb = sum(d for (_, _, d, _) in ps)
    pairs = sum(1 for (p, _, _, _) in ps for (q, _, _, _) in ps if p != q and not comparable(p, q))
    return n + sb + pairs, n


results = []
viol = 0
t0 = time.time()
for trial in range(TR):
    d1 = rand_sentence(rng, rng.randint(8, 16))
    D = [d1]
    P = Prefix(D)
    pot = P.potential()
    length = 0
    stall = 0
    while stall < 400:
        cands = []
        for _ in range(30):
            base = rng.choice(D)
            q = mutate(rng, base)
            if rng.random() < 0.3:
                q = mutate(rng, q)
            if size(q) > 2 * size(d1):
                continue
            if not P.accepts(q):
                cands.append(q)
        if not cands:
            stall += 30
            continue
        # adversary: choose the escalation that destroys least (largest new potential)
        best, bestpot, bestP = None, None, None
        for q in cands:
            P2 = Prefix(D + [q])
            p2 = P2.potential()
            if bestpot is None or p2 > bestpot:
                best, bestpot, bestP = q, p2, P2
        if not bestpot < pot:
            viol += 1
        D.append(best)
        P, pot = bestP, bestpot
        length += 1
        stall = 0
    b, n = bound(d1)
    results.append((n, length, b))
print('trials', TR, 'seed', SEED, 'time %.1fs' % (time.time() - t0))
print('potential-decrease violations:', viol)
print('  |d1|  chain_after_d1  theorem_bound')
for n, L, b in sorted(results):
    print('  %4d  %5d  %7d' % (n, L, b))
print('max chain/|d1| = %.2f' % max(L / n for n, L, b in results))
print('all chains within bound:', all(L <= b for n, L, b in results))
