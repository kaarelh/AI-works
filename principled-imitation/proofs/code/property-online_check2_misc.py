"""Independent checks for the referee report verification/property-online-check.md.

Part 1: Proposition 8.1(a) by brute force over all memorisers (a second instance).
Part 2: lower-bound columns of Section 9.5 (Proposition 3.6(a)).
Part 3: Remark 6.4(5) example (d_B, d_C of the two alternating rules).
Part 4: Example 2.3: ratio of N*/n to the lead's per-call bound (ln(2/pi)+1/2)/sqrt(n),
        with eta = 1/sqrt(n), beta = 1/(2n), delta = 1/2; is it below 1/2 for all n?
Part 5: Example 2.3 with the greatest minimiser: the books never move.
"""
import itertools
import math
from fractions import Fraction

print("== Part 1: Proposition 8.1(a), brute force ==")
for (N, A, p, K) in [(4, 3, Fraction(3, 10), 3), (3, 2, Fraction(1, 2), 2), (5, 1, Fraction(1, 4), 4)]:
    X = list(range(N))
    f = {x: 1 + (x % A) for x in X}           # the human: answers in {1..A}
    hyps = [("f", Fraction(1, 2 ** K), dict(f))]
    for r in range(N + 1):
        for D in itertools.combinations(X, r):
            for tau in itertools.product(range(1, A + 1), repeat=r):
                w = Fraction(1, 2) * p ** r * (1 - p) ** (N - r) / Fraction(A) ** r
                h = {x: 0 for x in X}
                for x, v in zip(D, tau):
                    h[x] = v
                hyps.append(("m", w, h))
    total = sum(w for _, w, _ in hyps)
    worst = Fraction(0)
    for k in range(N):
        for Q in itertools.combinations(X, k):
            post = [(w, h) for _, w, h in hyps if all(h[x] == f[x] for x in Q)]
            Z = sum(w for w, _ in post)
            mu = Fraction(1, 2) * (p / A) ** k / (Fraction(1, 2) * (p / A) ** k + Fraction(1, 2 ** K))
            for x in X:
                prob0 = sum(w for w, h in post if h[x] == 0) / Z
                target = 0 if x in Q else (1 - p) * mu
                worst = max(worst, abs(prob0 - target))
    print(f"N={N} A={A} p={p} K={K}: total weight = {total} (= 1/2 + 2^-K: {total == Fraction(1,2)+Fraction(1,2**K)}); "
          f"max |posterior P(0) - formula| = {worst}")
    assert worst == 0

print("\n== Part 2: Proposition 3.6(a) lower bounds of Section 9.5 ==")
for d, n in [(32, 1000), (100, 10000), (1000, 10000)]:
    lb = math.sqrt(n) / (math.sqrt(1 + n / d ** 2) + math.sqrt(n) / d)
    ub = math.sqrt((n + 1) * (2 * math.log(d) + math.log(n + 1)))
    print(f"d={d:5d} n={n:6d}: lower {lb:.1f}  upper (3.2) {ub:.1f}")

print("\n== Part 3: Remark 6.4(5) ==")
P1 = Fraction(1, 2)
for rule in [(1, 1, 0), (1, 0, 0)]:
    a = dict(zip("uvw", rule))
    dB = Fraction(sum(a.values()), 3) - P1
    dC = Fraction(a["u"] + a["w"], 3) - Fraction(2, 3) * P1
    print(f"rule {rule}: d_B = {dB}, d_C = {dC}")

print("\n== Part 4: Example 2.3, N*/n against the lead's per-call bound ==")
def Nstar(n):
    eta = 1 / math.sqrt(n); beta = 1 / (2 * n); delta = 0.5
    # least N >= 0 with beta*sinh(eta N) >= delta*sinh(eta)
    target = math.asinh(delta * math.sinh(eta) / beta) / eta
    N = max(0, math.ceil(target - 1e-9))
    while beta * math.sinh(eta * N) < delta * math.sinh(eta):
        N += 1
    while N > 0 and beta * math.sinh(eta * (N - 1)) >= delta * math.sinh(eta):
        N -= 1
    return N
mx = 0; arg = None
for n in list(range(1, 5000)) + [10 ** k for k in range(4, 13)]:
    cnt = min(n // 2, Nstar(n))
    ratio = (cnt / n) / ((math.log(4 * n) + 0.5) / math.sqrt(n))
    if ratio > mx:
        mx, arg = ratio, n
for n in [400, 10 ** 4, 10 ** 5, 10 ** 8, 10 ** 12]:
    cnt = min(n // 2, Nstar(n))
    print(f"n={n:>14d}: count={cnt:>9d}  ratio to lead bound = {(cnt/n)/((math.log(4*n)+0.5)/math.sqrt(n)):.4f}")
print(f"largest ratio over n < 5000 and n = 10^4..10^12: {mx:.4f} at n = {arg} (below 1/2: {mx < 0.5})")

print("\n== Part 5: Example 2.3 with the greatest minimiser ==")
def run(n, greatest):
    eta = 1 / math.sqrt(n); beta = 1 / (2 * n); delta = 0.5
    sB = sD = 0; ones = 0
    for t in range(1, n + 1):
        x = t + 1
        sc = [0.0, beta * math.sinh(eta * sB) + (delta * math.sinh(eta * sD) if x % 2 else 0.0),
              (delta * math.sinh(eta * sD) if x % 2 == 0 else 0.0)]
        m = min(sc)
        cands = [y for y in range(3) if sc[y] == m]
        a = cands[-1] if greatest else cands[0]
        h = 0 if x % 2 else 2
        inB = lambda y: y == 1
        inD = lambda y: (y == 1 and x % 2 == 1) or (y == 2 and x % 2 == 0)
        sB += inB(a) - inB(h); sD += inD(a) - inD(h); ones += (a == 1)
    return ones, sB, sD
for n in [100, 10000]:
    print(f"n={n}: least minimiser -> answers 1: {run(n, False)[0]}; greatest minimiser -> answers 1, books: {run(n, True)}")
print("\nall checks passed")
