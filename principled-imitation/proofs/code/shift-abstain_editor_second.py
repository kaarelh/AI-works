"""Editor of the part shift-abstain, second round: checks made while deciding the findings of
verification/shift-abstain-second.md.  Written independently of the scripts of that report.

 (1) Corollary 3.6(a) / Theorem 3.3(a),(c): exact optimum over ALL deterministic learners by a
     dynamic programme over information states (not the block formula of the second check).
 (2) Example 4.5a: the quoted numbers, the inequality of item 3, item 2 by exact enumeration.
 (3) Theorem 5.3(b) in a finite model of (P2).
 (4) Proposition 6.2(4): exact enumeration of Protocol R[Nov_s] on small instances.
 (5) Example 5.7(b) for the cumulative (top) set with alpha = 2^(-c0-1) (finding N6).
 (6) Arithmetic behind the accepted corrections (Corollary 3.5 remark, Theorem 7.3 (L1),
     findings N4 and N10).
 (7) Theorem 4.5: what its integrality hypothesis is worth (a computation, not a proof).
 (8) Finding N14: a human without a preferred answer above 1 - eta, at an input asked for ever.

Run: python3 shift-abstain_editor_second.py > shift-abstain_editor_second.out   (a few seconds)
"""
import itertools, math, random
from fractions import Fraction as F
from functools import lru_cache

print("(1) thresholds: exact optimum over all deterministic learners (information-state DP)")

def opt_table(N):
    """V(x, lo, hi, q): least total number of mistakes, summed over the thresholds s in [lo, hi]
    that are still consistent, from position x on, with q questions left.  Label of x under s
    is 1[x <= s].  A prediction reveals nothing; a question splits the consistent range."""
    @lru_cache(maxsize=None)
    def V(x, lo, hi, q):
        if x > N - 1 or lo > hi:
            return 0
        if lo == hi:                      # the human is known: no further mistake
            return 0
        below = max(0, min(hi, x - 1) - lo + 1)      # members with s < x  (label 0)
        above = (hi - lo + 1) - below                # members with s >= x (label 1)
        rest = V(x + 1, lo, hi, q)
        best = min(below, above) + rest   # predict 1 is wrong for 'below', predict 0 for 'above'
        if q > 0:
            best = min(best, V(x + 1, max(lo, x), hi, q - 1) + V(x + 1, lo, min(hi, x - 1), q - 1))
        return best
    return V

viol = 0
rows = {}
for N in range(2, 27):
    V = opt_table(N)
    for Q in range(0, N):
        tot = V(1, 0, N - 1, Q)           # = N * min E[Sil], s uniform
        lb = F(1, 4) * (F(N * N, Q + 1) - (Q + 1))          # N * bound of Theorem 3.3(a)
        if tot < lb: viol += 1; print("  VIOLATION (a)", N, Q, tot, lb)
        if 2 * (Q + 1) <= N and F(tot, N) * (Q + 1) < F(3 * N, 16):
            viol += 1; print("  VIOLATION 3N/16", N, Q)
        if N % (Q + 1) == 0:
            c_learner = F(N, 1) * (F(N, Q + 1) - 1) / 2      # N * E[Sil] of the learner of (c)
            if tot > c_learner: viol += 1; print("  VIOLATION (c)", N, Q)
            if not (c_learner / N * (Q + 1) < F(N, 2)): viol += 1; print("  VIOLATION (c) < N/2", N, Q)
        rows[(N, Q)] = tot
print("  N = 2..26, all Q < N: violations of Theorem 3.3(a), of the form 3N/16, or of (c):", viol)
print("  N*E[Sil] at N = 16, Q = 0..5:", [rows[(16, Q)] for Q in range(6)], "(the prover's table: 64 40 28 21 16 13)")
viol = 0; cases = 0
for h in range(1, 26):
    N = h + 1
    for s in [F(1, 20), F(1, 10), F(1, 4), F(3, 8), F(1, 2), 1, 2, 4, 8]:
        Qmin = next(Q for Q in range(0, N) if F(rows[(N, Q)], N) <= s)   # average, weaker than "every member"
        bound = min(F(h + 1, 2), F(3 * (h + 1), 1) / (16 * s)) - 1
        cases += 1
        if Qmin < bound: viol += 1; print("  VIOLATION 3.6(a)", h, s, Qmin, bound)
print("  Corollary 3.6(a), consequence: h = 1..25, 9 tolerances s: %d cases, violations: %d" % (cases, viol))
# the note's old sentence 'not before about 3*2^K/(16 j)': false for small j
N = 16
for j in [F(1, 20), F(1, 4)]:
    Qmin = next(Q for Q in range(0, N) if F(rows[(N, Q)], N) <= j)
    print("  N = 16 = 2^4, tolerance j = %s: least Q with optimum average <= j is %d; 3N/(16j) = %s, N*min{1/2, 3/(16j)} - 1 = %s"
          % (j, Qmin, F(3 * N, 1) / (16 * j), N * min(F(1, 2), F(3, 1) / (16 * j)) - 1))

print("(2) Example 4.5a")
L = 10
for sigma, N1s in [(1e-3, (55, 167)), (1e-4, (551, 1673)), (1e-5, (5516, 16741))]:
    pi = 1 - (1 - 4 * sigma) ** (1 / L)
    out = []
    for N1 in N1s:
        a = 1 - (1 - N1 * pi) ** L
        out.append("N1 = %d: a = %.4f, N1/2 = %.1f, a/(8 sigma) - 1/2 = %.1f, 1/(1-a)^2 = %.2f" % (N1, a, N1 / 2, a / (8 * sigma) - 0.5, 1 / (1 - a) ** 2))
    print("  sigma = %g: " % sigma + "; ".join(out))
bad = 0; cnt = 0
rng = random.Random(1)
for _ in range(200000):
    L_ = rng.randint(1, 60); N1 = rng.randint(1, 5000); pi = rng.random() / N1
    if pi <= 0 or pi >= 1: continue
    sig = (1 - (1 - pi) ** L_) / 4; a = 1 - (1 - N1 * pi) ** L_
    cnt += 1
    if N1 / 2 < a / (8 * sig) - 0.5 - 1e-9: bad += 1
print("  item 3, N1/2 >= a/(8 sigma) - 1/2 on %d random (L, N1, pi): violations %d" % (cnt, bad))
def item2(L_, N1, pi):
    cells = [0] + list(range(1, N1 + 1))          # 0 is the common cell c0
    pr = [1 - N1 * pi] + [pi] * N1
    worst_sil = F(0); aborts = {}
    for human in [None] + cells:                  # None is f0; c is the indicator of cell c
        f = lambda x: 1 if (human is not None and x == human) else 0
        ans0 = f(0)                               # the one question, at c0
        sil = F(0); ab = F(0)
        for run in itertools.product(cells, repeat=L_):
            p = F(1)
            for x in run: p *= pr[x]
            truth = max(f(x) for x in run)
            out = 0; aborted = False
            for x in run:
                if x == 0: out = max(out, ans0)
                elif ans0 == 1: out = max(out, 0)
                else: aborted = True; break
            if aborted: ab += p
            elif out != truth: sil += p
        worst_sil = max(worst_sil, sil); aborts[human] = ab
    return worst_sil, aborts
ok = True
for (L_, N1, pi) in [(1, 3, F(1, 5)), (2, 2, F(1, 10)), (3, 3, F(1, 4)), (4, 2, F(1, 3))]:
    ws, ab = item2(L_, N1, pi)
    a = 1 - (1 - N1 * pi) ** L_
    ok = ok and ws == 0 and ab[0] == 0 and all(ab[h] == a for h in ab if h != 0)
print("  item 2, exact (rational) enumeration, 4 settings: no silent failure, abort a (0 for the indicator of c0):", ok)

print("(3) Theorem 5.3(b) in a finite model of (P2) with c2 = 0 (tests = difference sets only)")
rng = random.Random(7)
cases = viol = fout = 0
for trial in range(60):
    nX = rng.randint(3, 6); nH = rng.randint(3, 9)
    H = set()
    while len(H) < nH: H.add(tuple(rng.randint(0, 2) for _ in range(nX)))
    H = sorted(H)
    raw = [rng.random() ** 4 + 1e-4 for _ in H]; tot = sum(raw) / rng.uniform(0.3, 1.0)
    w = [r / tot for r in raw]; lw = [-math.log2(v) for v in w]
    tests = {}
    for i in range(nH):
        for j in range(i + 1, nH):
            Qs = frozenset(x for x in range(nX) if H[i][x] != H[j][x])
            tests[Qs] = min(tests.get(Qs, math.inf), lw[i] + lw[j])
    for fi in range(nH):
        for r in range(nX + 1):
            for A in itertools.combinations(range(nX), r):
                As = frozenset(A)
                cons = [i for i in range(nH) if all(H[i][x] == H[fi][x] for x in A)]
                wmax = max(w[i] for i in cons); KD = -math.log2(wmax)
                for alpha in [1.0, 0.5, 0.1, 0.01]:
                    C = [i for i in cons if w[i] >= alpha * wmax]
                    if fi not in C: fout += 1
                    for x in range(nX):
                        if any(H[i][x] != H[fi][x] for i in C):
                            cases += 1
                            sep = min([c for Qs, c in tests.items() if x in Qs and not (Qs & As)], default=math.inf)
                            if sep > lw[fi] + KD + math.log2(1 / alpha) + 1e-9: viol += 1
print("  %d cases (f, A, alpha, x) with a member of the ratio set that differs from f at x; violations: %d; triples with f outside the set: %d" % (cases, viol, fout))

print("(4) Proposition 6.2(4): Protocol R[Nov_s], exact enumeration over (z, J) in every round")
def exact_nov(seed, nX=5, L_=2, n=4, s=2, nZ=2, nH=6):
    rng = random.Random(seed)
    tests = [(frozenset([x]), rng.randint(1, 3)) for x in range(nX)]
    for _ in range(5):
        Qs = frozenset(x for x in range(nX) if rng.random() < 0.5)
        if Qs: tests.append((Qs, rng.randint(0, 2)))
    Ts = sum(1 for _, k in tests if k < s)
    H = [tuple(rng.randint(0, 1) for _ in range(nX)) for _ in range(nH)]
    w = [2.0 ** (-(i + 1)) for i in range(nH)]
    fi = rng.randrange(nH); f = H[fi]
    heavier = sum(1 for i in range(nH) if w[i] >= w[fi])
    tab = {}
    def nxt(z, hist):
        if (z, hist) not in tab: tab[(z, hist)] = rng.randrange(nX)
        return tab[(z, hist)]
    def sep(x, A): return min([k for Qs, k in tests if x in Qs and not (Qs & A)], default=math.inf)
    def g_of(D):
        for i in range(nH):                       # decreasing weight
            if all(H[i][x] == y for x, y in D): return i
    res = dict(halt=F(0), wr=F(0), k1=F(0), k2=F(0), maxk1=0, maxk2=0)
    def rec(t, D, p, k1, k2):
        if t == n:
            res["maxk1"] = max(res["maxk1"], k1); res["maxk2"] = max(res["maxk2"], k2)
            res["k1"] += p * k1; res["k2"] += p * k2
            return
        A = frozenset(x for x, _ in D); gi = g_of(D)
        for z in range(nZ):
            hist = (); calls = []; halted = False; wr = 0
            for j in range(L_):
                x = nxt(z, hist); calls.append(x)
                if sep(x, A) < s: halted = True; break
                y = H[gi][x]; wr += (y != f[x]); hist += (y,)
            pz = p * F(1, nZ)
            res["halt"] += pz * halted; res["wr"] += pz * wr
            for J in range(L_):
                pj = pz * F(1, L_)
                if J < len(calls):
                    x = calls[J]
                    d1 = 1 if sep(x, A) < s else 0
                    d2 = 1 if (not d1 and H[gi][x] != f[x]) else 0
                    rec(t + 1, D + ((x, f[x]),), pj, k1 + d1, k2 + d2)
                else:
                    rec(t + 1, D, pj, k1, k2)
    rec(0, (), F(1), 0, 0)
    return Ts, heavier, res, L_
allok = True; lines = []
for seed in range(12):
    for s in (1, 2, 3):
        Ts, heavier, r, L_ = exact_nov(seed, s=s)
        ok = (r["halt"] == L_ * r["k1"] and r["wr"] == L_ * r["k2"] and r["maxk1"] <= Ts and r["maxk2"] <= heavier - 1
              and r["halt"] <= L_ * Ts and r["wr"] <= L_ * (heavier - 1))
        allok = allok and ok
        if seed < 2: lines.append("  seed %d, s = %d: sum Pr[Halt_t] = %s = L*E[rounds of the first kind] <= L*T_s = %d;  sum E[Wr_t] = %s <= L*(heavier - 1) = %d"
                                  % (seed, s, r["halt"], L_ * Ts, r["wr"], L_ * (heavier - 1)))
print("\n".join(lines))
print("  36 instances (12 seeds, s = 1, 2, 3; L = 2, n = 4), rational arithmetic: both identities exact, both path counts and both bounds hold:", allok)

print("(5) Example 5.7(b) with the cumulative (top) set")
def gf2_rank(vecs, d):
    rows_ = list(vecs); r = 0
    for bit in range(d):
        piv = next((i for i in range(r, len(rows_)) if (rows_[i] >> bit) & 1), None)
        if piv is None: continue
        rows_[r], rows_[piv] = rows_[piv], rows_[r]
        for i in range(len(rows_)):
            if i != r and (rows_[i] >> bit) & 1: rows_[i] ^= rows_[r]
        r += 1
    return r
def ex57(d, c0, seed):
    rng = random.Random(seed); n = d - c0
    while True:
        xs = [rng.randrange(1, 2 ** d) for _ in range(n)]
        if gf2_rank(xs, d) == n: break
    ys = [rng.randint(0, 1) for _ in range(n)]               # the coin's answers
    dot = lambda s_, x: bin(s_ & x).count("1") & 1
    post = {"P0": F(1, 2) * F(1, 2 ** n)}
    for s_ in range(2 ** d):
        if all(dot(s_, x) == y for x, y in zip(xs, ys)): post[s_] = F(1, 2 ** (d + 1))
    Z = sum(post.values()); post = {k: v / Z for k, v in post.items()}
    order = sorted(post, key=lambda k: (-post[k], str(k)))
    def cum(alpha):
        out = []; tot = F(0)
        for k in order:
            tot += post[k]
            if post[k] >= alpha * tot: out.append(k)
        return out
    def theta(C, x):
        S0 = min((F(1, 2) if k == "P0" else F(1 - dot(k, x))) for k in C)
        S1 = min((F(1, 2) if k == "P0" else F(dot(k, x))) for k in C)
        return 1 - S0 - S1
    Chalf = cum(F(1, 2 ** (c0 + 1))); Cfull = cum(F(1, 2 ** c0))
    ths = [theta(Chalf, x) for x in range(2 ** d)]
    return len(post) - 1, post["P0"], len(Chalf), len(Cfull), min(ths), sum(ths) / len(ths)
for d, c0 in [(6, 1), (7, 2), (9, 3)]:
    m, wP, nhalf, nfull, mn, mean = ex57(d, c0, 3)
    print("  d = %d, c0 = %d: %d consistent linear functions, posterior of P0 = %s; top set with alpha = 2^(-c0-1) has %d members, with alpha = 2^(-c0) %d;"
          " abstention probability with alpha = 2^(-c0-1): least %s, mean over inputs %s (1 - 2^(-c0-1) = %s)" % (d, c0, m, wP, nhalf, nfull, mn, mean, 1 - F(1, 2 ** (c0 + 1))))
c0 = 3; alpha = 2.0 ** (-c0 - 1); eta = 0.05
for d in [10 ** 3, 10 ** 5, 10 ** 7]:
    n = d - c0
    G0 = 0.5 * math.log(1 / (alpha * 0.5)) + math.log(1 / eta)          # Gamma without ln S
    lnS = math.log(2 ** -0.5 + 2.0 ** ((d - 1) / 2)) if d < 2000 else (d - 1) / 2 * math.log(2)
    without = alpha / 0.5 + eta + (1 / alpha) * math.sqrt(2 * G0 / n)
    with_ = alpha / 0.5 + eta + (1 / alpha) * math.sqrt(2 * (G0 + lnS) / n)
    true_lb = (1 - 2.0 ** -c0) * (1 - 2.0 ** (-c0 - 1))
    print("  c0 = 3, eta = 0.05, L = 1, d = %d: Theorem 5.6(b) for the top set WITHOUT ln S would give %.3f, with it %.2f; the abort probability is at least %.3f" % (d, without, with_, true_lb))

print("(6) arithmetic of the accepted corrections")
print("  Corollary 3.5: the condition Qbar + u <= u*N1/4 with Qbar >= 0 needs N1 >= 4 (N1 = 4: only Qbar = 0); with Qbar >= u it needs N1 >= 8 (N1 = 8: only Qbar = u; N1 = 16: u <= Qbar <= 3u)")
for N1 in (8, 16):
    print("    N1 = %d: N1/(30 (N1-1) log2 N1) = %s" % (N1, F(N1, 30 * (N1 - 1) * int(math.log2(N1)))))
print("  N4: sup over eta < 1/2 of 1 - [K/log2(1/(1-eta))]/[K ln2/eta] = 1 - 1/(2 ln 2) = %.4f" % (1 - 1 / (2 * math.log(2))))
worst = max((k + 1) * 2 ** (Kk / (k + 1)) / math.e - k - 1 for k in range(0, 60) for Kk in [x / 10 for x in range(0, 10 * (k + 1))])
print("  N10: largest value of (k+1) 2^(K/(k+1))/e - k - 1 over k < 60 and K < k + 1 (step 0.1): %.4f (negative: the bound is empty there)" % worst)
for d in (10, 100, 1000):
    k = d + 2 * math.log2(d)
    print("  (L1): d = %d, k = d + 2 log d (c = 0): 2^k / 2^d = d^2 = %d; k^2 = %.0f" % (d, d * d, k * k))

print("(7) the integrality hypothesis of Theorem 4.5")
def best_n(L_, sigma, a):
    """largest lower bound on n that the first claim of Theorem 4.5 gives, over integer N0 >= 1"""
    best = -math.inf
    centre = max(1, int((1 - a) * L_ / (2 * sigma)))
    for N0 in range(max(1, centre - 3), centre + 5):
        p = 1 - (1 - 1 / N0) ** L_
        best = max(best, N0 - (sigma * (N0 + L_) + L_ * a) / p)
    return best
rng = random.Random(5); bad = 0; cnt = 0; worstgap = math.inf; nonint = 0
for _ in range(200000):
    L_ = rng.randint(1, 50); a = rng.choice([0, 0, rng.random() * 0.9]); sigma = 10 ** rng.uniform(-4, -0.7)
    target = (1 - a) ** 2 * L_ / (4 * sigma) - L_
    if target < 1: continue
    N0real = (1 - a) * L_ / (2 * sigma)
    if abs(N0real - round(N0real)) > 1e-9: nonint += 1
    b = best_n(L_, sigma, a)
    cnt += 1; worstgap = min(worstgap, b - target)
    if b < target - 1e-9: bad += 1
print("  Theorem 4.5 with the best integer N0 near (1-a)L/(2 sigma): %d random (L, sigma, a) with (1-a)^2 L/(4 sigma) - L >= 1, of which %d with (1-a)L/(2 sigma) not an integer;" % (cnt, nonint))
print("    cases in which the first claim of the theorem gives less than (1-a)^2 L/(4 sigma) - L: %d (least surplus %.3f)" % (bad, worstgap))
print("    (so the integrality hypothesis looks like a convenience of the proof; this is a computation, not a proof, and the note states the hypothesis)")

print("(8) finding N14: a human without a preferred answer above 1 - eta at an input that is asked for ever")
def nonabstaining(p_h, biases, weights, eta, n):
    """Exact expected number of rounds t <= n at which Thr_eta answers, when one input is asked
    in every round and the human answers 1 with probability p_h; the class is a set of coins."""
    from math import comb
    total = 0.0
    for t in range(n):                      # t earlier answers
        for k in range(t + 1):              # k of them are 1
            pr = comb(t, k) * p_h ** k * (1 - p_h) ** (t - k)
            post = [w * b ** k * (1 - b) ** (t - k) for w, b in zip(weights, biases)]
            Z = sum(post); m1 = sum(q * b for q, b in zip(post, biases)) / Z
            if m1 >= 1 - eta or 1 - m1 >= 1 - eta: total += pr
    return total
biases = [0.6, 0.95, 0.05, 0.5, 0.8]; weights = [1 / 32, 15 / 32, 8 / 32, 4 / 32, 4 / 32]; eta = 0.2
K = math.log2(32); gamma = (1 - eta) - 0.6
for n in (50, 200, 600):
    e = nonabstaining(0.6, biases, weights, eta, n)
    print("  human: coin of bias 0.6 with weight 1/32 (K = 5), eta = 0.2, n = %d rounds: expected answered rounds %.3f (bound K ln2/(2 gamma^2) = %.1f), so abstentions %.1f"
          % (n, e, K * math.log(2) / (2 * gamma ** 2), n - e))
kl = lambda a, b: (a * math.log(a / b) if a > 0 else 0.0) + ((1 - a) * math.log((1 - a) / (1 - b)) if a < 1 else 0.0)
print("  kl(1 - eps0 || eta) and kl(eps0 || eta) at eps0 = 0, eta = 0.2: %.4f, %.4f;  ln(1/eta), ln(1/(1-eta)): %.4f, %.4f" % (kl(1.0, 0.2), kl(0.0, 0.2), math.log(5), math.log(1.25)))
