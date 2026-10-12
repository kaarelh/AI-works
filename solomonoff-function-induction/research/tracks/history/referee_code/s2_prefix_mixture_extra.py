"""s2 (referee, second report): the remark in notes.md §7 that, for SFI^hist built from
prefix-free deterministic programs, "labels that are random bits cost an extra ~ K(n)
[proof sketch: a prefix-free program that outputs n random labels must encode n]".

Counter-argument (proved in referee.md, issue M5): the program "<N> w" (a prefix-free code of
N, then N raw bits w; on the i-th query, i <= N, output w_i) is consistent with a label string
y in {0,1}^n whenever N >= n and w extends y.  Summing over all such programs,

    W_hist(y || x)  >=  2^{-n} * sum_{N >= n} 2^{-len(<N>)}            (*)

for EVERY y and every input list.  So the mixture never needs to encode n: it pays only the
tail of the length code.  With len = K this tail is >= 2^{-K(ceil(log2 n)) - c}, and it
dominates the tail of every computable code.

This script makes (*) concrete for a computable code, Elias delta (len_delta), which satisfies
K(N) <= len_delta(N) + c.  It
  (1) brute-forces (*) for n <= 6 in the toy program language (programs <N>w with N <= NMAX,
      exact rationals, plus the exact analytic tail for N > NMAX), for every y in {0,1}^n;
  (2) computes T(n) = sum_{N >= n} 2^{-len_delta(N)} exactly (closed form per dyadic block)
      and compares the mixture's extra cost -log2 T(n) with len_delta(n) ~ log n, for
      n up to 2^200;
  (3) checks the closed form T(2^k) = 1/(k+1) when k+1 is a power of 2.
Exact arithmetic (fractions); no randomness (seed recorded as 0).
Output: s2_prefix_mixture_extra.out
"""
from fractions import Fraction as Fr
from math import log2
import itertools

SEED = 0


def flog2(N):
    return N.bit_length() - 1


def len_delta(N):
    """Elias delta code length for N >= 1."""
    k = flog2(N)
    return k + 2 * flog2(k + 1) + 1


def tail_T(n):
    """T(n) = sum_{N >= n} 2^{-len_delta(N)}, exact.  Block k = [2^k, 2^{k+1}) has 2^k
    members of length k + 2 floor(log2(k+1)) + 1, so its total weight is
    2^{-2 floor(log2(k+1)) - 1}.  Sum of all blocks k >= K0 grouped by j = floor(log2(k+1)):
    blocks with given j are k in [2^j - 1, 2^{j+1} - 1), total 2^j * 2^{-2j-1} = 2^{-j-1}."""
    assert n >= 1
    k0 = flog2(n)
    # partial block k0: members N in [n, 2^{k0+1})
    cnt = (1 << (k0 + 1)) - n
    total = Fr(cnt, 1 << len_delta(n))
    # full blocks k > k0
    k = k0 + 1
    j = flog2(k + 1)
    # blocks k .. 2^{j+1} - 2 share j
    last_k_same_j = (1 << (j + 1)) - 2
    total += Fr(last_k_same_j - k + 1, 1 << (2 * j + 1))
    # all j' > j: sum 2^{-j'-1} = 2^{-j-1}
    total += Fr(1, 1 << (j + 1))
    return total


# sanity: Kraft sum equals 1
assert tail_T(1) == 1, tail_T(1)

# (3) closed form
for j in range(0, 8):
    k = (1 << j) - 1
    assert tail_T(1 << k) == Fr(1, k + 1), (k, tail_T(1 << k))
print("(3) T(2^k) = 1/(k+1) exactly when k+1 is a power of 2 (checked k+1 = 1,2,4,...,128)")

# (1) brute force in the toy program language
NMAX = 14
print("(1) brute force: W(y)*2^n versus T(n) (programs <N>w with N <= %d enumerated, rest analytic)" % NMAX)
for n in range(1, 7):
    worst = None
    for y in itertools.product((0, 1), repeat=n):
        W = Fr(0)
        for N in range(n, NMAX + 1):
            for w in itertools.product((0, 1), repeat=N - n):  # w extends y
                W += Fr(1, 1 << (len_delta(N) + N))
        W += Fr(1, 1 << n) * tail_T(NMAX + 1)  # programs with N > NMAX, all extensions
        ratio = W * (1 << n)
        assert ratio == tail_T(n), (n, y, ratio, tail_T(n))
        worst = ratio
    print(f"    n={n}: for all {2**n} label strings y, W(y)*2^n = T(n) = {float(worst):.6f} "
          f"(extra {-log2(worst):.3f} bits; len_delta(n) = {len_delta(n)})")

# (2) growth comparison
print("(2) extra cost of the program mixture (-log2 T(n)) versus the cost of encoding n (len_delta(n)):")
print("   n              -log2 T(n)   len_delta(n)   log2(log2 n + 1)")
for e in (4, 8, 16, 32, 64, 128, 200):
    forms = [("2^%d" % e, 1 << e),
             ("2^%d+%d" % (e, 12345 if e > 16 else 3), (1 << e) + (12345 if e > 16 else 3)),
             ("3*2^%d+1" % (e - 2), 3 * (1 << (e - 2)) + 1)]
    for label, n in forms:
        T = tail_T(n)
        # -log2 of a Fraction with huge denominator: use numerator/denominator bit lengths
        ex = log2(T.denominator) - log2(T.numerator) if T.numerator > 0 else float("inf")
        print(f"   {label:<14s} {ex:10.3f}   {len_delta(n):10d}   {log2(log2(n) + 1):10.3f}")
        assert ex <= log2(log2(n) + 1) + 2.0 + 1e-9  # extra <= log2(log2 n + 1) + 2 for this code
print("RESULT: in the toy language the mixture's extra cost over 2^-n is -log2 T(n) <= log2(log2 n + 1) + 2,")
print("        while encoding n costs len_delta(n) ~ log2 n + 2 log2 log2 n.  Since K(N) <= len_delta(N) + c,")
print("        the real W_hist pays at most -log2 T(n) + c extra on every label string: not ~K(n).")
