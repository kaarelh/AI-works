"""research-notes/A-tight-conditioning-fails.md (script added in revision 1), Proposition 6.6(b): non-centred +-1 labels at fixed d; probability that NO atom carries both labels.

x uniform on {-1,1}^d (M = 2^d atoms), P(y = 1 | x) = p = (1 + eta0)/2.  Given the counts k_x, the probability of
no conflict is prod_x f(k_x) with f(0) = 1, f(k) = p^k + (1-p)^k (k >= 1).  Exact value (multinomial counts):
   P = M^{-n} sum_{a+b+e=M} M!/(a! b! e!) (-1)^e (a p + b (1-p))^n,
from the exponential generating function (e^{pz} + e^{(1-p)z} - 1)^M.  Computed in exact rationals.
Bound used in the text (one fixed atom):
   P <= (1 - (1-p)/M)^n + (1 - p/M)^n - (1 - 1/M)^n <= 2 exp(-n (1 - eta0) / (2M)).
"""
import math
from fractions import Fraction
import numpy as np

def exact_no_conflict(M, n, p):
    tot = Fraction(0)
    for a in range(M + 1):
        for b in range(M + 1 - a):
            e = M - a - b
            coef = math.factorial(M) // (math.factorial(a) * math.factorial(b) * math.factorial(e))
            tot += coef * (-1) ** e * (a * p + b * (1 - p)) ** n
    return tot / Fraction(M) ** n

def single_atom(M, n, p):
    q = 1 - p
    return (1 - q / M) ** n + (1 - p / M) ** n - (1 - 1 / M) ** n

rng = np.random.default_rng(7)
print(f"{'d':>2} {'eta0':>5} {'n':>5} {'exact P':>12} {'MC P':>8} {'one-atom':>10} {'2exp(..)':>10}  ok")
for d in (1, 2, 3):
    M = 2 ** d
    for eta0 in (Fraction(1, 4), Fraction(1, 2), Fraction(9, 10)):
        p = (1 + eta0) / 2
        for n in (4, 16, 64, 256):
            P = float(exact_no_conflict(M, n, p))
            one = single_atom(M, n, float(p))
            bnd = 2 * math.exp(-n * (1 - float(eta0)) / (2 * M))
            # Monte Carlo
            reps = 4000; cnt = 0
            for _ in range(reps):
                idx = rng.integers(0, M, size=n); ys = rng.random(n) < float(p)
                pos = np.bincount(idx[ys], minlength=M); neg = np.bincount(idx[~ys], minlength=M)
                cnt += not np.any((pos > 0) & (neg > 0))
            ok = (P <= one + 1e-15) and (one <= bnd + 1e-15)
            print(f"{d:>2} {float(eta0):>5.2f} {n:>5} {P:>12.4e} {cnt / reps:>8.4f} {one:>10.4e} {bnd:>10.4e}  {ok}")
