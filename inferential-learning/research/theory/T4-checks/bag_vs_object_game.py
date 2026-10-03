"""Exact minimax mistake counts: step-level (object) feedback vs bag-level (coherence) feedback.

Game (Section 4 of T4):
  * finite step universe S (bitmask over m steps), hypothesis class H (list of distinct step sets);
  * state = version space V (bitmask over H);
  * learner announces an accepted set A (any subset of S, improper allowed);
  * adversary picks a hypothesis h in V with h != A and returns a feedback item consistent with h:
      positive :  s in h \\ A                      -> V' = {h' in V : s in h'}
      object   :  s in A \\ h  (step-level blame)   -> V' = {h' in V : s not in h'}
      bag(r)   :  B subset of A, |B|<=r, B not<= h  -> V' = {h' in V : B not<= h'}
  * M(V) = min_A max_feedback 1 + M(V');  M(V)=0 iff some A equals every h in V (|V|=1).
  * if some feedback leaves V unchanged, that A is useless (value = infinity).

We compare  M_obj (positive + object)  with  M_bag(r) (positive + bag of size <= r).
"""
import itertools, functools, math, random, sys

INF = 10**9


def solve(H, m, mode, r=None):
    n = len(H)
    full = (1 << n) - 1
    masks_A = list(range(1 << m))
    # precompute, for each step s, bitmask of hypotheses containing s
    contains = [sum(1 << i for i, h in enumerate(H) if (h >> s) & 1) for s in range(m)]
    # bag subsets: all nonempty subsets of steps of size <= r
    if mode == 'bag':
        rr = m if r is None else r
        bags = [b for b in range(1, 1 << m) if bin(b).count('1') <= rr]
        bag_cont = {}
        for b in bags:
            bag_cont[b] = sum(1 << i for i, h in enumerate(H) if (b & h) == b)  # hyps containing B
    sys.setrecursionlimit(10000)

    @functools.lru_cache(maxsize=None)
    def M(V):
        hyps = [i for i in range(n) if (V >> i) & 1]
        if len(hyps) == 1:
            return 0
        best = INF
        for A in masks_A:
            worst = 0
            useless = False
            for i in hyps:
                h = H[i]
                if h == A:
                    continue
                # positive feedback
                pos = h & ~A
                for s in range(m):
                    if (pos >> s) & 1:
                        V2 = V & contains[s]
                        if V2 == V:
                            useless = True; break
                        worst = max(worst, 1 + M(V2))
                if useless: break
                neg = A & ~h
                if neg == 0:
                    continue
                if mode == 'obj':
                    for s in range(m):
                        if (neg >> s) & 1:
                            V2 = V & ~contains[s]
                            if V2 == V:
                                useless = True; break
                            worst = max(worst, 1 + M(V2))
                else:
                    for b in bags:
                        if (b & A) == b and (b & h) != b:
                            V2 = V & ~bag_cont[b]
                            if V2 == V:
                                useless = True; break
                            worst = max(worst, 1 + M(V2))
                if useless: break
                if worst >= best: break
            if useless:
                continue
            best = min(best, worst)
        return best

    return M(full)


def single_culprit(n):
    S = (1 << n) - 1
    return [S & ~(1 << j) for j in range(n)], n


def k_culprit(n, k):
    S = (1 << n) - 1
    H = []
    for K in itertools.combinations(range(n), k):
        h = S
        for j in K:
            h &= ~(1 << j)
        H.append(h)
    return H, n


if __name__ == '__main__':
    print("single-culprit class H_n = {S minus {j}}: |H| = n")
    print(" n | log2|H| | M_obj | M_bag(r=1..n)")
    for n in range(2, 7):
        H, m = single_culprit(n)
        mo = solve(H, m, 'obj')
        mb = [solve(H, m, 'bag', r) for r in range(1, n + 1)]
        print(f" {n} | {math.log2(n):5.2f}   | {mo:5d} | {mb}")
    print()
    print("k-culprit classes H = {S minus K : |K| = k}")
    for (n, k) in [(4, 2), (5, 2), (6, 2), (6, 3)]:
        H, m = k_culprit(n, k)
        mo = solve(H, m, 'obj')
        mb = [solve(H, m, 'bag', r) for r in range(1, n + 1)]
        print(f" n={n} k={k} |H|={len(H)} log2|H|={math.log2(len(H)):.2f}  M_obj={mo}  M_bag(r=1..n)={mb}")
    print()
    print("random classes: check M_obj <= floor(log2|H|) and M_bag(unbounded) <= |H|-1, and M_obj <= M_bag")
    rng = random.Random(0)
    worst_ratio = 0
    for trial in range(150):
        m = rng.randint(3, 5)
        nh = rng.randint(2, 8)
        H = list({rng.randrange(1 << m) for _ in range(nh)})
        if len(H) < 2:
            continue
        mo = solve(H, m, 'obj')
        mb = solve(H, m, 'bag')
        mb1 = solve(H, m, 'bag', 1)
        assert mo <= math.floor(math.log2(len(H))), (H, mo)
        assert mb <= len(H) - 1, (H, mb)
        assert mo <= mb and mb1 == mo, (H, mo, mb, mb1)
        worst_ratio = max(worst_ratio, mb / max(mo, 1))
    print(" all assertions passed; max M_bag/M_obj over random classes =", worst_ratio)
