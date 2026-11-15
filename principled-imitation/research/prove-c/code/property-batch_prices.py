# Checks for Section 5 of research/prove-c/property-batch.md (the two prices; what test matching does not see).
# Pure Python.  Run:  python3 property-batch_prices.py > property-batch_prices.out
import random, math, itertools
from math import log, sqrt
random.seed(5)

d = 12; u = 2**d                      # inputs: the d-bit strings, uniform law; answers in {0,1}
def bit(x, i): return (x >> i) & 1

# ---- a family of tests R of pairs (x, y), each given as a function (x, y) -> bool; uniform weights
tests = []
for c in (0, 1): tests.append(lambda x, y, c=c: y == c)
for i in range(d):
    for a in (0, 1):
        for c in (0, 1): tests.append(lambda x, y, i=i, a=a, c=c: bit(x, i) == a and y == c)
for i, j in itertools.combinations(range(d), 2):
    for a, b, c in itertools.product((0, 1), repeat=3):
        tests.append(lambda x, y, i=i, j=j, a=a, b=b, c=c: bit(x, i) == a and bit(x, j) == b and y == c)
for t in range(256, u+1, 256):
    for c in (0, 1): tests.append(lambda x, y, t=t, c=c: x < t and y == c)
for i, j, k in itertools.combinations(range(d), 3):
    for a, c in itertools.product((0, 1), repeat=2):
        tests.append(lambda x, y, i=i, j=j, k=k, a=a, c=c: (bit(x, i) ^ bit(x, j) ^ bit(x, k)) == a and y == c)
M = len(tests); pi_ = 1.0/M
# precompute, for each test, the two indicator vectors over x (y = 0 and y = 1)
ind = [([R(x, 0) for x in range(u)], [R(x, 1) for x in range(u)]) for R in tests]
coin_freq = [(sum(i0) + sum(i1))/(2*u) for i0, i1 in ind]          # Q_coin(R)

print(f"(1) Proposition 5.2: u = 2^{d} inputs, {M} tests with weight 1/{M} each; human = a random function f, imitator = a fair coin")
eta = 0.1
bound = sqrt(log(2/(pi_*eta))/(2*u))
T = 40; fails = 0; worst = 0.0; in_matching = 0; N = u // 4
tolN = sqrt(log(2/(pi_*eta))/(2*N))
for _ in range(T):
    f = [random.getrandbits(1) for _ in range(u)]
    f_freq = [sum((i1[x] if f[x] else i0[x]) for x in range(u))/u for i0, i1 in ind]        # Q_f(R)
    dev = max(abs(a - b) for a, b in zip(f_freq, coin_freq)); worst = max(worst, dev)
    if dev > bound: fails += 1
    # N recorded runs of the human system f; does the coin lie within tol_N(R) of the empirical frequency of every test?
    xs = [random.randrange(u) for _ in range(N)]
    emp = [sum((i1[x] if f[x] else i0[x]) for x in xs)/N for i0, i1 in ind]
    if all(abs(c - e) <= tolN for c, e in zip(coin_freq, emp)): in_matching += 1
print(f"    max over tests and over {T} draws of f of |Q_f(R) - Q_coin(R)| = {worst:.4f};  bound sqrt(ln(2/(pi eta))/(2u)) = {bound:.4f} (eta = {eta}); draws exceeding the bound: {fails}/{T}")
print(f"    total variation between the two run laws: 0.5 exactly (the coin differs from f(x) with probability 1/2 at every x)")
print(f"    with N = u/4 = {N} recorded runs of f: tol_N = {tolN:.4f}; the coin is within tol_N of the empirical frequency of every test in {in_matching}/{T} draws")
print(f"    the test 'y = f(x)' would separate them (frequency 1 against 1/2); a family that contains it with weight pi must have")
print(f"    sqrt(ln(2/(pi eta))/(2u)) >= 1/2, i.e. pi <= (2/eta) exp(-u/2) = {2/eta:.0f} x exp(-{u//2})")

# ---- Example 5.3: per-call tests do not see dependence between the calls of a run
print("(2) Example 5.3: scaffold with two calls that put the same input z to the answerer; human = fair coin at each call; imitator = one random function g")
worst = 0.0
for _ in range(10):
    g = [random.getrandbits(1) for _ in range(u)]
    g_freq = [sum((i1[x] if g[x] else i0[x]) for x in range(u))/u for i0, i1 in ind]        # per-call frequency of B for the imitator
    worst = max(worst, max(abs(a - b) for a, b in zip(g_freq, coin_freq)))
print(f"    per-call tests: max |a(B) - h(B)| over the {M} tests and 10 draws of g = {worst:.4f} (bound {bound:.4f})")
print(f"    run test 'the two answers agree': probability 1 for the imitator, 1/2 for the human system")
