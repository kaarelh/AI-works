"""Second check, shift-abstain: Theorem 5.3(b) as rewritten by the editor, and
Example 5.7(b) for the top (cumulative) set used in Ab2(d) of the note.

Part 1. Finite model of (P2) with c2 = 0: a random class H of functions on X
with weights; the tests are the difference sets {g != g'} with complexity
log(1/w(g)) + log(1/w(g')) (minimum over pairs), plus random extra tests.
For every human f in H, every set A of asked inputs, every alpha on a grid:
D = f restricted to A; C = ratio set; K_D = log(1/max weight consistent).
Claim: if some member of C differs from f at x, then sep(x;A) <= K + K_D + log(1/alpha).
We also count the cases with f not in C (the case the prover's proof missed).

Part 2. Example 5.7(b): posterior weights after n = d - c0 independent
questions; membership of the fill-ins in the cumulative set for alpha = 2^(-c0-1)
and in the ratio set for alpha = 2^(-c0).
"""
import random, math, itertools

def part1(seed, nX=5, nH=10):
    rng = random.Random(seed)
    X = list(range(nX))
    H = []
    while len(H) < nH:
        g = tuple(rng.randint(0, 1) for _ in X)
        if g not in H: H.append(g)
    raw = [rng.random() ** 3 + 1e-3 for _ in H]
    tot = sum(raw) * (1 + rng.random())  # W < 1
    w = [r / tot for r in raw]
    lw = [math.log2(1 / x) for x in w]
    tests = {}
    for i, j in itertools.combinations(range(nH), 2):
        Q = frozenset(x for x in X if H[i][x] != H[j][x])
        c = lw[i] + lw[j]
        if Q and c < tests.get(Q, math.inf): tests[Q] = c
    for _ in range(6):
        Q = frozenset(x for x in X if rng.random() < 0.5)
        if Q: tests[Q] = min(tests.get(Q, math.inf), rng.uniform(0, 12))
    def sep(x, A):
        return min([c for Q, c in tests.items() if x in Q and not (Q & A)], default=math.inf)
    viol = 0; cases = 0; fout = 0
    for fi in range(nH):
        f = H[fi]; K = lw[fi]
        for r in range(nX + 1):
            for A in itertools.combinations(X, r):
                A = frozenset(A)
                cons = [i for i in range(nH) if all(H[i][x] == f[x] for x in A)]
                KD = min(lw[i] for i in cons)
                wmax = max(w[i] for i in cons)
                for alpha in [1, 0.5, 0.2, 0.05, 0.01]:
                    C = [i for i in cons if w[i] >= alpha * wmax]
                    if fi not in C: fout += 1
                    for x in X:
                        if any(H[i][x] != f[x] for i in C):
                            cases += 1
                            if sep(x, A) > K + KD + math.log2(1 / alpha) + 1e-9:
                                viol += 1
    return cases, viol, fout

tc = tv = tf = 0
for seed in range(40):
    c, v, fo = part1(seed)
    tc += c; tv += v; tf += fo
print("Theorem 5.3(b): %d (f, A, alpha, x) cases with a member of the ratio set differing from f; violations: %d; (f,A,alpha) cases with f not in the ratio set: %d" % (tc, tv, tf))

# Part 2
print("Example 5.7(b), posterior after n = d - c0 independent questions:")
for d, c0 in [(4, 1), (6, 2), (10, 3), (12, 5)]:
    n = d - c0
    pP = 0.5 * 2.0 ** (-n)          # prior 1/2 times likelihood 2^-n
    pg = 2.0 ** (-d - 1)            # each consistent linear function
    m = 2 ** c0                     # number of consistent linear functions
    Z = pP + m * pg
    wP, wg = pP / Z, pg / Z
    ratio_ok = wg >= 2.0 ** (-c0) * wP * (1 - 1e-12)
    # cumulative set: order P first (largest), then the m equal fill-ins
    alpha = 2.0 ** (-c0 - 1)
    cum = wP >= alpha * wP
    s = wP
    for i in range(m):
        s += wg
        cum = cum and (wg >= alpha * s * (1 - 1e-12))
    alpha2 = 2.0 ** (-c0)
    s = wP; cum2 = True
    for i in range(m):
        s += wg
        cum2 = cum2 and (wg >= alpha2 * s * (1 - 1e-12))
    print("  d=%d c0=%d: w(P|D)=%.4f, each fill-in %.4g (ratio %.4g); all fill-ins in ratio set at alpha=2^-c0: %s; in cumulative set at alpha=2^-(c0+1): %s; at alpha=2^-c0: %s"
          % (d, c0, wP, wg, wg / wP, ratio_ok, cum, cum2))
