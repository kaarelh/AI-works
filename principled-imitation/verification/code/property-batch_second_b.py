"""Second checker, part property-batch: numerical checks of Proposition 5.4, Proposition 6.4,
Proposition 6.5 and Theorem 6.6.  Written independently of the editor's and the attack report's scripts.
Run:  python3 property-batch_second_b.py > property-batch_second_b.out
"""
from fractions import Fraction as Fr
from math import comb, log, sqrt, exp
import itertools, random

random.seed(2026)

def hdr(s):
    print("\n" + "=" * 78 + "\n" + s + "\n" + "=" * 78)

def kl(p, q):
    p = float(p); q = float(q)
    def t(a, b):
        if a == 0: return 0.0
        if b == 0: return float("inf")
        return a * log(a / b)
    return t(p, q) + t(1 - p, 1 - q)

# ---------------------------------------------------------------- Proposition 5.4
hdr("(G) Proposition 5.4: exact probability that the coin's run law lies in M_N (human = random function)")
for (u, N, delta) in [(6, 2, 0.5), (8, 3, 0.3), (10, 2, 0.2), (5, 3, 0.6)]:
    X = range(u)
    tests = [  # sets of pairs (x, y) with weights
        (lambda x, y: y == 0, 0.25),
        (lambda x, y: y == x % 2, 0.25),
        (lambda x, y: x == 0 and y == 1, 0.25),
        (lambda x, y: (x < u // 2) == (y == 1), 0.25),
    ]
    Qcoin = [sum(0.5 * (R(x, 0) + R(x, 1)) for x in X) / u for R, _ in tests]
    good = 0; total = 0
    for F in itertools.product([0, 1], repeat=u):
        for xs in itertools.product(X, repeat=N):
            total += 1
            ok = True
            for (R, pi), q in zip(tests, Qcoin):
                ph = sum(R(x, F[x]) for x in xs) / N
                if kl(ph, q) > log(2 / (pi * delta)) / N + 1e-12:
                    ok = False; break
            good += ok
    pr = good / total
    bound = 1 - delta - comb(N, 2) / u
    print("  u=%2d N=%d delta=%.2f: Pr[Q_coin in M_N] = %.4f >= 1 - delta - C(N,2)/u = %.4f : %s"
          % (u, N, delta, pr, bound, pr >= bound))

# ---------------------------------------------------------------- Proposition 6.4
hdr("(H) Proposition 6.4: the collision statistic")
def rand_law(q):
    v = [random.random() ** 2 for _ in range(q)]
    s = sum(v); return [a / s for a in v]
maxerr = 0.0; rng_ok = True
for trial in range(2000):
    q = random.randint(2, 6)
    P = rand_law(q); A = rand_law(q)
    Es = 0.0; mn = 9; mx = -9
    for y1 in range(q):
        for y2 in range(q):
            s = (y1 == y2) - A[y1] - A[y2] + sum(a * a for a in A)
            Es += P[y1] * P[y2] * s
            mn = min(mn, s); mx = max(mx, s)
    d2 = sum((p - a) ** 2 for p, a in zip(P, A))
    maxerr = max(maxerr, abs(Es - d2))
    rng_ok &= (mn >= -0.5 - 1e-12 and mx <= 2 + 1e-12)
print("  2000 random pairs of laws on q<=6 answers: max |E[s|x] - d(x)^2| = %.2e; -1/2 <= s <= 2: %s" % (maxerr, rng_ok))
# extremes of s
print("  s = -1/2 attained (A = (1/2,1/2,0..), y1 != y2 in its support): %.3f; s = 2 approached (A concentrated on y' != y1 = y2): %.3f"
      % (-0.5 - 0.5 + 0.25 + 0.25, 1 - 0 - 0 + 1))
# coverage of (b) and the inequality of (c) on a toy scaffold
L = 3; q = 3; nx = 5
viol = 0; trials = 3000; m = 150; delta = 0.1
beta_ok = True
for t in range(trials):
    if t % 300 == 0:
        P = [rand_law(q) for _ in range(nx)]; A = [rand_law(q) for _ in range(nx)]
        lenlaw = rand_law(L)  # Pr[len = 1..L]
        mu = rand_law(nx)
        d2 = [sum((p - a) ** 2 for p, a in zip(P[x], A[x])) for x in range(nx)]
        tvx = [0.5 * sum(abs(p - a) for p, a in zip(P[x], A[x])) for x in range(nx)]
        Elen = sum((i + 1) * lenlaw[i] for i in range(L))
        Ed2 = sum(mu[x] * d2[x] for x in range(nx))
        D2 = Elen * Ed2 / L                     # calls at inputs iid mu (inputs not depending on answers)
        beta = Elen * sum(mu[x] * tvx[x] for x in range(nx))
        beta_ok &= beta <= (L / 2) * sqrt(q * D2) + 1e-12 and (q > 2 or True)
    sb = 0.0
    for i in range(m):
        ln_ = random.choices(range(1, L + 1), lenlaw)[0]
        J = random.randint(1, L)
        if J > ln_: continue
        x = random.choices(range(nx), mu)[0]
        y1 = random.choices(range(q), P[x])[0]; y2 = random.choices(range(q), P[x])[0]
        sb += (y1 == y2) - A[x][y1] - A[x][y2] + sum(a * a for a in A[x])
    sb /= m
    if D2 > sb + 2.5 * sqrt(log(1 / delta) / (2 * m)):
        viol += 1
print("  (b) with m=%d, delta=%.2f: fraction of %d trials with D2 > sbar + (5/2)sqrt(ln(1/delta)/(2m)) = %.4f (<= delta)"
      % (m, delta, trials, viol / trials))
print("  (c) beta <= (L/2)sqrt(q D2) on 10 random toy scaffolds: %s" % beta_ok)
bin_ok = all(abs(sum((p - a) ** 2 for p, a in zip(P2, A2)) - 2 * (0.5 * sum(abs(p - a) for p, a in zip(P2, A2))) ** 2) < 1e-12
             for P2, A2 in [(rand_law(2), rand_law(2)) for _ in range(100)])
print("  binary answers: sum (P-A)^2 = 2 TV^2: %s" % bin_ok)

# ---------------------------------------------------------------- Proposition 6.5
hdr("(I) Proposition 6.5: one function for a family of decision rules (coin P0, uniform mu on u inputs)")
def rules_value(F, u):
    n1 = sum(F); n0 = u - n1
    a_eq = (n0 * n0 + n1 * n1) / u ** 2               # m=2: accept iff the two answers agree
    a_zero = n0 / u                                   # m=1: accept iff the answer is 0
    # m=2: accept iff y1 == parity(x1) and y2 != parity(x2)
    c_par = sum(1 for x in range(u) if F[x] == x % 2) / u
    a_par = c_par * (1 - c_par)
    return [a_eq, a_zero, a_par]
a0 = [0.5 + 0.0, 0.5, 0.25]
mD = [2, 1, 2]; piD = [1 / 3] * 3
for u, eta, samples in [(16, 0.2, None), (400, 0.1, 4000)]:
    coll = 1 / u
    bounds = [comb(m_, 2) * coll + m_ * sqrt(coll * log(2 / (p_ * eta)) / 2) for m_, p_ in zip(mD, piD)]
    bad = 0; tot = 0; means = [0.0] * 3
    it = itertools.product([0, 1], repeat=u) if samples is None else ([random.randint(0, 1) for _ in range(u)] for _ in range(samples))
    for F in it:
        v = rules_value(F, u); tot += 1
        means = [a + b for a, b in zip(means, v)]
        if any(abs(a - b) > c for a, b, c in zip(v, a0, bounds)):
            bad += 1
    means = [a / tot for a in means]
    print("  u=%d eta=%.2f: Pr_F[some rule deviates beyond its bound] = %.4f (<= eta); |E_F a_F - a0| = %s <= C(m,2)/u = %s"
          % (u, eta, bad / tot, ["%.4f" % abs(a - b) for a, b in zip(means, a0)], ["%.4f" % (comb(m_, 2) / u) for m_ in mD]))
    print("     bounds used: %s" % ["%.3f" % b for b in bounds])

# ---------------------------------------------------------------- Theorem 6.6
hdr("(J) Theorem 6.6: one input asked r times; exact total variation of the r answers")
def stirling2(n, k, memo={}):
    if (n, k) in memo: return memo[(n, k)]
    if n == k: r = 1
    elif k == 0 or k > n: r = 0
    else: r = k * stirling2(n - 1, k) + stirling2(n - 1, k - 1)
    memo[(n, k)] = r; return r
import sys
sys.setrecursionlimit(100000)
def exact_tv(s, r):
    tv = Fr(0)
    p0 = Fr(1, s ** r)
    ratio = Fr(1)  # prod_{i<j} (s/2 - i)/(s - i)
    falling = 1
    for j in range(1, r + 1):
        ratio *= Fr(s // 2 - (j - 1), s - (j - 1)) if j - 1 < s // 2 else 0
        falling *= (s - (j - 1))
        pH = Fr(2, s) ** r * ratio
        tv += stirling2(r, j) * falling * abs(pH - p0)
    return tv / 2
for s, r in [(4, 2), (4, 3), (256, 2), (256, 8), (65536, 128)]:
    t = exact_tv(s, r)
    print("  (s, r) = (%d, %d): exact TV = %.5f, bound C(r,2)/s = %.5f, within: %s" % (s, r, float(t), comb(r, 2) / s, t <= Fr(comb(r, 2), s)))

hdr("(K) Theorem 6.6(b): adaptive procedures on 2 inputs, s = 4, m = 2 (all) and m = 3 (random sample)")
s = 4; X = [0, 1]; Ys = range(s)
halves = list(itertools.combinations(Ys, s // 2))
def transcript_laws(strategy, m):
    """strategy: function(history tuple of (x,y)) -> next x.  Returns dicts transcript -> prob under
    P0 and under E_H P_H."""
    lawP0 = {}; lawH = {}
    # explicit enumeration over H = (H_0, H_1) instead of recursion with posteriors
    for H0 in halves:
        for H1 in halves:
            H = (H0, H1)
            def go(hist, pp0, ppH):
                if len(hist) == m:
                    lawP0[hist] = lawP0.get(hist, 0) + pp0 / len(halves) ** 2
                    lawH[hist] = lawH.get(hist, 0) + ppH / len(halves) ** 2
                    return
                x = strategy(hist)
                for y in Ys:
                    go(hist + ((x, y),), pp0 * Fr(1, s), ppH * (Fr(2, s) if y in H[x] else 0))
            go((), Fr(1), Fr(1))
    return lawP0, lawH
def tv_of(strategy, m):
    a, b = transcript_laws(strategy, m)
    keys = set(a) | set(b)
    return sum(abs(a.get(k, 0) - b.get(k, 0)) for k in keys) / 2
# m = 2: strategy = first input, and second input as a function of the first answer
best2 = Fr(0)
for x1 in X:
    for f2 in itertools.product(X, repeat=s):
        strat = lambda h, x1=x1, f2=f2: x1 if len(h) == 0 else f2[h[0][1]]
        best2 = max(best2, tv_of(strat, 2))
print("  m=2: max advantage over all %d deterministic adaptive procedures = %s = %.4f, bound C(2,2)/s = %.4f"
      % (2 * 2 ** s, best2, float(best2), 1 / s))
best3 = Fr(0)
rng = random.Random(5)
tried = 0
strategies = []
# always the same input (non-adaptive), plus random adaptive ones
strategies.append(lambda h: 0)
for _ in range(400):
    x1 = rng.choice(X); f2 = [rng.choice(X) for _ in range(s)]; f3 = {(a, b): rng.choice(X) for a in range(s) for b in range(s)}
    strategies.append(lambda h, x1=x1, f2=f2, f3=f3: x1 if len(h) == 0 else (f2[h[0][1]] if len(h) == 1 else f3[(h[0][1], h[1][1])]))
for st in strategies:
    best3 = max(best3, tv_of(st, 3)); tried += 1
print("  m=3: max advantage over %d procedures (the constant one and random adaptive ones) = %.4f, bound C(3,2)/s = %.4f"
      % (tried, float(best3), 3 / s))
