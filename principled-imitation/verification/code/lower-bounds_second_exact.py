"""Second check of proofs/lower-bounds.md: exact computations written independently.

A. Proposition 3.10: exact failure of Protocol R on the block class (equal weights, block
   scaffold), deploying M^(T) with T uniform on [n]; value at n = 4mN and least n with
   failure <= delta.
B. Proposition 3.7: exact Bayes failure of the best deployed system after n i.i.d. mu-questions
   on the rare-points class vs. the bound 2 eps (1-2eps)(1-q/d)^n; the final inequality
   ln(2(1-2eps))(Ld/(4eps)-1) >= 0.1 K L/eps - 0.4 on a grid.
C. Theorem 3.3(3) / Proposition 3.8(3): the constant 2.7 on a grid of u = log2(L/eps) >= 4.
D. Proposition 3.9: the arithmetic max{1/ln(1/(1-g)), L/ln(1/g)} = L/ln(L/ln L), g = ln L/L.
E. Proposition 5.6: the table of Section 5.4 (N0 - delta(N0+B)/p(B,N0) with N0 = B/(2 delta)).
F. Proposition 5.7: the counterexample (excess failure of Protocol R, two Bernoulli samplers),
   exact rational arithmetic for small n, floats for large n; growth with theta = 1/(2 sqrt n).
G. Example for Theorem 3.3(5): replayed by hand-coded logic.
H. Proposition 7.2 / Corollary N2d: arithmetic of the bounds and of the numbers for a person.
"""
import math
from fractions import Fraction as Fr

def p_of(L, N):
    return 1 - (1 - 1 / N) ** L

print("A. Proposition 3.10: Protocol R on the block class, exact")
def fail_given_k(N, L, k):
    # a_j not yet asked; k non-needle cells of block j asked (all answered 0)
    c0 = k / N + (N - k - 1) / N * (N - k - 1) / (N - k)
    return 2 * ((1 - 1 / N) ** L - c0 ** L)

def protocolR_block(m, N, L, nmax):
    # state distribution over k (0..N-1) with needle not found; found -> failure 0
    dist = [0.0] * N
    dist[0] = 1.0
    cum = 0.0
    out = []
    mN = m * N
    fk = [fail_given_k(N, L, k) for k in range(N)]
    for t in range(1, nmax + 1):
        cum += sum(d * f for d, f in zip(dist, fk))
        out.append(cum / t)
        new = [0.0] * N
        for k, d in enumerate(dist):
            if d == 0.0:
                continue
            # needle asked: prob 1/mN -> found (dropped)
            new[k] += d * (1 - (1 + (N - 1 - k)) / mN)
            if k + 1 < N:
                new[k + 1] += d * (N - 1 - k) / mN
        dist = new
    return out

ok = True
for (m, N, L) in [(1, 8, 1), (2, 10, 2), (4, 16, 2), (3, 40, 4), (8, 64, 4), (16, 128, 4), (2, 100, 10)]:
    delta = L / (2 * N)
    nmax = 5 * m * N
    fails = protocolR_block(m, N, L, nmax)
    f4 = fails[4 * m * N - 1]
    nmin = next(i + 1 for i, f in enumerate(fails) if f <= delta and all(g <= delta for g in fails[i:]))
    ok &= f4 <= delta
    # also check the intermediate bound: failure of M^(t) given a_j unasked <= 2L/N
    worst = max(fail_given_k(N, L, k) for k in range(N))
    ok &= worst <= 2 * L / N + 1e-15
    print(f"  m={m:2d} N={N:4d} L={L:2d} delta={delta:.4f}: fail(n=4mN)={f4:.6f} <= delta: {f4 <= delta};"
          f" least n (failure stays <= delta) = {nmin} = {nmin/(m*N):.3f} mN; max_k fail|unasked = {worst:.5f} <= 2L/N = {2*L/N:.5f}")
assert ok
print("  (Theorem 3.1 lower bound (1-10 delta) m L/(8 delta) vs 4mN = 2mL/delta: ratio 16/(1-10 delta))")

print("\nB. Proposition 3.7: rare-points class")
def bayes_fail_rare(d, L, eps, n):
    q = 4 * eps / L
    # exact: average over uniform f of failure of the Bayes system (copy known values, guess unknown)
    # = E[1 - 2^{-#distinct unasked points hit by the run}]. Use |U| distribution Binomial(d, (1-q/d)^n)
    # (points independent? No: multinomial; compute exactly by inclusion over the number of unasked points)
    # Exact via the joint law: each question is x0 w.p. 1-q, else uniform point. Unasked set U.
    # E over U of g(|U|) where P(|U| = u): occupancy.  Compute by DP over the n questions on count of asked points.
    from math import comb
    dist = [0.0] * (d + 1)  # number of asked distinct points
    dist[0] = 1.0
    for _ in range(n):
        new = [0.0] * (d + 1)
        for a, pr in enumerate(dist):
            if pr == 0: continue
            stay = (1 - q) + q * a / d
            new[a] += pr * stay
            if a < d:
                new[a + 1] += pr * q * (d - a) / d
        dist = new
    tot = 0.0
    for a, pr in enumerate(dist):
        u = d - a
        # run: L calls; each hits a given unasked point w.p. q/d. Failure = 1 - E[2^{-H}], H distinct unasked hit.
        # E[2^{-H}] via DP over calls on number of distinct unasked points hit
        hd = [0.0] * (u + 1); hd[0] = 1.0
        for _ in range(L):
            nh = [0.0] * (u + 1)
            for h, ph in enumerate(hd):
                if ph == 0: continue
                newp = q * (u - h) / d
                nh[h] += ph * (1 - newp)
                if h < u: nh[h + 1] += ph * newp
            hd = nh
        tot += pr * (1 - sum(ph * 2.0 ** (-h) for h, ph in enumerate(hd)))
    return tot

for (d, L, eps) in [(3, 2, 0.125), (5, 4, 0.1), (8, 3, 0.05), (4, 10, 0.125)]:
    q = 4 * eps / L
    rows = []
    nreq = None
    for n in range(0, 4000):
        ex = bayes_fail_rare(d, L, eps, n)
        bd = 2 * eps * (1 - 2 * eps) * (1 - q / d) ** n
        assert ex >= bd - 1e-12, (d, L, eps, n, ex, bd)
        if ex <= eps and nreq is None:
            nreq = n
            break
    lb = math.log(2 * (1 - 2 * eps)) * (L * d / (4 * eps) - 1)
    print(f"  d={d} L={L} eps={eps}: least n with exact Bayes failure <= eps: {nreq}; bound of (a): {lb:.2f};"
          f" 0.1KL/eps-0.4 = {0.1*d*L/eps-0.4:.2f}; R1 rounds ceil(LK ln2/eps) = {math.ceil(L*d*math.log(2)/eps)}")
    assert nreq >= lb - 1e-9
# final chain on a grid
worst = 1e9
for eps in [1/8, 0.1, 0.05, 0.01, 1e-4]:
    for L in [1, 2, 5, 100, 10**4]:
        for d in [1, 2, 10, 1000]:
            lhs = math.log(2 * (1 - 2 * eps)) * (L * d / (4 * eps) - 1)
            rhs = 0.1 * d * L / eps - 0.4
            worst = min(worst, lhs - rhs)
print(f"  min over grid of [ln(2(1-2eps))(Ld/(4eps)-1) - (0.1KL/eps - 0.4)] = {worst:.4f} (must be >= 0)")
assert worst >= 0
print(f"  ln 2/0.1 = {math.log(2)/0.1:.4f} (< 7); 0.1/ln 2 = {0.1/math.log(2):.4f} vs 1/7 = {1/7:.4f}")

print("\nC. Theorem 3.3(3): (u/(u-log u) + ln 2) <= 2.7 for u >= 4; gamma = u 2^-u <= 1/4")
mx = 0
u = 4.0
while u < 200:
    val = u / (u - math.log2(u)) + math.log(2)
    mx = max(mx, val)
    assert u * 2 ** (-u) <= 0.25 + 1e-15
    u += 0.001
print(f"  max of u/(u - log2 u) + ln 2 over u in [4, 200): {mx:.5f} (attained at u = 4: {4/(4-2)+math.log(2):.5f})")
assert mx < 2.7

print("\nD. Proposition 3.9 arithmetic")
for L in [3, 4, 5, 10, 100, 1000, 10**6]:
    g = math.log(L) / L
    a = 1 / math.log(1 / (1 - g))
    b = L / math.log(1 / g)
    c = L / math.log(L / math.log(L))
    assert abs(max(a, b) - c) < 1e-9 * c and g < 0.5
    print(f"  L={L}: 1/ln(1/(1-g))={a:.4f}, L/ln(1/g)={b:.4f}, L/ln(L/ln L)={c:.4f}; ln(L/ln L)={math.log(L/math.log(L)):.4f}")

print("\nE. Proposition 5.6: table of Section 5.4")
def need(B, delta):
    N0 = B / (2 * delta)
    assert abs(N0 - round(N0)) < 1e-9
    N0 = round(N0)
    return N0 - delta * (N0 + B) / p_of(B, N0), N0
for (m, delta, L) in [(1, 1/20, 61), (2, 1/20, 62), (5, 1/40, 137), (10, 1/100, 472), (50, 1/100, 5252)]:
    Bseq = (L - m) // (m + 1)
    assert Bseq * (m + 1) + m == L
    Bmaj = L // (2 * m + 1)
    qs, N0s = need(Bseq, delta)
    qm, N0m = need(Bmaj, delta)
    K = math.log2(N0s + 1)
    R3 = L * K * math.log(2) / ((m + 1) * delta)
    print(f"  m={m} delta={delta} L={L}: block-majority B={Bmaj} n>={qm:.1f}; sequential B={Bseq} n>={qs:.1f};"
          f" ratio {qs/qm:.2f}; R3 {R3:,.0f}; closed form (1-4d)(L-m)/(4(m+1)d) = {(1-4*delta)*(L-m)/(4*(m+1)*delta):.1f}")
    assert qs >= (1 - 4 * delta) * (L - m) / (4 * (m + 1) * delta) - 1e-9

print("\nF. Proposition 5.7: counterexample")
def excess(theta, n, exact=False):
    if exact:
        th = Fr(theta)
        pm = Fr(1, 2) - th; pp = Fr(1, 2) + th
        r = pp / pm
    else:
        th = theta; pm = 0.5 - th; pp = 0.5 + th; r = pp / pm
    tot = 0
    if not exact:
        import numpy as np
        from scipy.stats import binom
        for t in range(1, n + 1):
            s = t - 1
            k = np.arange(s + 1)
            pr = binom.pmf(k, s, pm)
            llr = (2 * k - s) * math.log(r)
            tot += float(np.sum(pr / (1 + np.exp(-llr))))
        return 2 * th * tot / n
    for t in range(1, n + 1):
        s = t - 1
        Ew = 0
        for k in range(s + 1):  # k ones among s answers of the human P-
            pr = math.comb(s, k) * pm ** k * (1 - pm) ** (s - k)
            lr = r ** (2 * k - s)
            Ew += pr * lr / (1 + lr)   # prior weights 1/2, 1/2
        tot += Ew
    return 2 * th * tot / n
for (th, n, ex) in [(Fr(1, 20), 20, True), (Fr(1, 20), 60, True), (Fr(1, 10), 60, True), (0.02, 5000, False), (0.01, 5000, False)]:
    e = excess(th, n, ex)
    e = float(e)
    cand = math.log(2) / n
    prop = math.sqrt(math.log(2) / (2 * n))
    print(f"  theta={float(th)} n={n}: excess={e:.5f}; ln2/n={cand:.6f}; ratio={e/cand:.1f}; sqrt(ln2/(2n))={prop:.4f}; bound holds: {e <= prop}")
    assert e <= prop
for n in [100, 400, 1600, 6400]:
    th = 1 / (2 * math.sqrt(n))
    e = excess(th, n)
    print(f"  theta=1/(2 sqrt n), n={n}: excess={e:.5f}, ratio to ln2/n = {e*n/math.log(2):.2f}, ratio/sqrt(n) = {e*n/math.log(2)/math.sqrt(n):.3f}")

print("\nG. Example for Theorem 3.3(5)")
w = Fr(1, 9); gamma = Fr(1, 8)
members = {i: (lambda i: (lambda x: 1 if x == i or (x == 9 and i < 4) else 0))(i) for i in range(9)}
V = set(range(9))
def M(V, x, y):
    return Fr(sum(1 for g in V if members[g](x) == y), len(V))
first_is_B = all(max(M(V, x, 0), M(V, x, 1)) > 1 - gamma for x in range(9))
h9 = 0 if M(V, 9, 0) > M(V, 9, 1) else 1
V2 = {g for g in V if members[g](9) == members[0](9)}
split0 = max(M(V2, 0, 0), M(V2, 0, 1))
V3 = {g for g in V2 if members[g](0) == members[0](0)}
print(f"  first step type (B): {first_is_B}; h_1(9) = {h9} (weight {M(V,9,h9)}); after audit at 9: {sorted(V2)}, factor {Fr(len(V2),9)};"
      f" input 0 then max weight {split0} <= 7/8: {split0 <= 1-gamma}; after asking 0: {sorted(V3)}")
print(f"  (1-gamma)^1 gamma^1 = {(1-gamma)*gamma} < w(f) = {w}: {(1-gamma)*gamma < w}")
assert first_is_B and h9 == 0 and V3 == {0} and (1 - gamma) * gamma < w

print("\nH. Proposition 7.2 / N2d arithmetic")
for (L, delta) in [(1000, 0.01), (10, 0.05)]:
    for K in [1e9]:
        n_R = L * K * math.log(2) / delta
        n_AB = 1 + 2.7 * K * L / (delta * math.log2(L / delta))
        n_blk = (1 - 10 * delta) * K * L / (8 * delta * math.log2(L / (2 * delta)))
        n_nd = L / (4 * delta) - L
        print(f"  L={L} delta={delta} K={K:.0e}: R {n_R:.3g} (break-even {delta*n_R/L:.3g}); AB {n_AB:.3g} ({delta*n_AB/L:.3g});"
              f" block {n_blk:.3g} ({delta*n_blk/L:.3g}); needle {n_nd:.6g} ({delta*n_nd/L:.4g})")
# F < 1/4 - delta  <=>  4F/(1-4 delta) < 1
for delta in [0.01, 0.1, 0.2]:
    for F in [0.1, 0.2, 0.24, 0.3]:
        assert (4 * F / (1 - 4 * delta) < 1) == (F < 0.25 - delta)
# r L/(L K ln2/delta + 1) = F/(K ln 2 + delta/L)
r, L, delta, K = 7, 13, 0.03, 5.0
F = r * delta
assert abs(r * L / (L * K * math.log(2) / delta + 1) - F / (K * math.log(2) + delta / L)) < 1e-12
print("  identities of Proposition 7.2(a), (c) and the threshold F < 1/4 - delta checked")
print("\nAll assertions passed.")
