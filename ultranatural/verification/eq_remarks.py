"""Referee: machine checks of three small examples used in the report.

1. (report, w3)  With the values of squaring on 0..15 as data, the data together with
   f(f(f(S(S(x))))) = 0 have the standard model "x^2 below 16, 0 from 16 on", and prove f(16) = 0.
2. (report, 4.5) For every n >= 3 the set U_n
       f(x, S^j(0)) = S^j(x)  and  f(S^j(0), y) = S^j(y)   for j = 0..n-2,
       f(S(x), S(x)) = S(S(f(x, x)))
   has all sides of at most n + 1 symbols, is true of plus, proves x + y for all x, y < n, and is
   also true of the function that is 0 where both arguments are >= n - 1 and differ.  So a set
   that fits plus on [0, n)^2 with short sides need not determine the sums outside the square.
3. (report, m10) The set {f(x) = S^5(0), S^5(f(S(x))) = 0, S^5(f(0)) = S(0)} is inconsistent, but
   every proof of 0 = S(0) passes through a term of at least 10 letters.

Usage: python3 eq_remarks.py
"""
import itertools
import sys

sys.dont_write_bytecode = True

from eq_check_sets import Rewriter, closure_classes, parse_unary, true_on_range, tsize

# 1
g = lambda x: x * x if x < 16 else 0
ok = all(g(g(g(x + 2))) == 0 for x in range(100000))
print(f"1. g = x^2 below 16, 0 from 16 on, satisfies f(f(f(S(S(x))))) = 0 for x < 100000: {ok};"
      f" instance x = 0 uses f(2) = {g(2)}, f(4) = {g(4)} and gives f(16) = 0; the identity has {6 + 1} symbols")

# 2
V = lambda i: ("v", i)
Z = ("0",)


def S(t, k=1):
    for _ in range(k):
        t = ("S", t)
    return t


F = lambda a, b: ("f", a, b)
x, y = V(0), V(1)
for n in (3, 4, 5, 8):
    U = [(F(x, S(Z, j)), S(x, j)) for j in range(n - 1)] + [(F(S(Z, j), y), S(y, j)) for j in range(n - 1)]
    U.append((F(S(x), S(x)), S(S(F(x, x)))))
    maxside = max(max(tsize(s), tsize(t)) for s, t in U)
    plus = lambda a, b: a + b
    alt = lambda a, b, n=n: 0 if (a >= n - 1 and b >= n - 1 and a != b) else a + b
    t1 = true_on_range(U, {"f": plus}, n + 6)[0]
    t2 = true_on_range(U, {"f": alt}, n + 6)[0]
    rw = Rewriter(U)
    square = all(rw.apply("f", (a, b)) == a + b for a in range(n) for b in range(n))
    outside = rw.apply("f", (n - 1, n))
    print(f"2. n={n}: {len(U)} identities, {sum(tsize(s) + tsize(t) for s, t in U)} symbols, longest side {maxside} (n+1 = {n + 1}); "
          f"true of plus: {t1}; true of the alternative: {t2}; derives the square: {square}; "
          f"value derived at ({n - 1},{n}): {outside}; plus gives {2 * n - 1}, the alternative {alt(n - 1, n)}")

# 3
ids = [parse_unary(t) for t in "fx=SSSSS0 SSSSSfSx=0 SSSSSf0=S0".split()]
for L in (8, 9, 10):
    find = closure_classes(ids, L)
    print(f"3. bound {L}: 0 = S(0) derivable through terms of at most {L} letters: {find('') == find('S')}")
