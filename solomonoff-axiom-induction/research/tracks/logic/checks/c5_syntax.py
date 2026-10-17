"""c5_syntax.py -- constants for the Th(N) lower bound of notes.md section 6 (Theorem 6.1).

No randomness.  Output: c5_syntax.out (stdout).

Syntax.  Polish notation over the 14-symbol alphabet
    0 S + * x ' = < ~ & | > A E
(terms: 0, S t, + t t, * t t, variables x, x', x'', ...; formulas: = t t, < t t, ~ f, & f f, | f f,
 > f f (implication), A v f, E v f).  No parentheses are needed.
Binary numerals: num(0) = 0, num(1) = S0, num(2m) = * num(m) SS0, num(2m+1) = S * num(m) SS0.

Checks and outputs:
  N1  num(k) evaluates to k and |num(k)| <= 5 floor(log2 k) + 2, for 1 <= k <= 20000.
  N2  the number F(L) of formulas of length L (an upper bound for the number of sentences), by
      dynamic programming for L <= 400, and the ratio F(L+1)/F(L), whose limit is the growth rate
      gamma of the syntax.
  N3  the exponent delta in Theorem 6.1: the index of beta_k = beta(num(k)) in a length-
      lexicographic enumeration is at most sum_{L <= |beta| + |num(k)|} (#sentences of length L);
      with the trivial count 14^L this gives delta_str = 1/(5 log2 14); with the formula count it
      gives delta_wff = 1/(5 log2 gamma) (gamma estimated numerically; not a proof).

Revision note (notes-final.md; referee B, issue 5).  The numerical gamma here is an extrapolation.
A proof that #formulas of length <= L is at most 0.7482 * 5.385^L for every L, hence
delta >= 0.0823, is the exact super-solution certificate of c6_revision.py R4 (and of referee B's
rb6 S3).  The code is unchanged; its output is byte-identical to the development round's.
"""
from math import log2


def num(k):
    if k == 0:
        return "0"
    if k == 1:
        return "S0"
    m, b = divmod(k, 2)
    return ("S*" if b else "*") + num(m) + "SS0"


def eval_term(s, i=0):
    c = s[i]
    if c == "0":
        return 0, i + 1
    if c == "S":
        v, j = eval_term(s, i + 1)
        return v + 1, j
    if c in "+*":
        a, j = eval_term(s, i + 1)
        b, j2 = eval_term(s, j)
        return (a + b if c == "+" else a * b), j2
    raise ValueError(c)


def main():
    bad = 0
    worst = 0
    for k in range(1, 20001):
        t = num(k)
        v, j = eval_term(t)
        if v != k or j != len(t):
            bad += 1
        bound = 5 * (k.bit_length() - 1) + 2
        if len(t) > bound:
            bad += 1
        worst = max(worst, len(t) - 5 * (k.bit_length() - 1))
    print(f"N1 numerals 1..20000: errors {bad}; max of |num(k)| - 5 floor(log2 k) = {worst}")
    assert bad == 0

    Lmax = 400
    V = [0] + [1] * Lmax                    # variables x'^(L-1)
    T = [0] * (Lmax + 1)
    F = [0] * (Lmax + 1)
    for L in range(1, Lmax + 1):
        t = (1 if L == 1 else 0) + V[L] + (T[L - 1] if L >= 2 else 0)
        t += 2 * sum(T[a] * T[L - 1 - a] for a in range(1, L - 1))
        T[L] = t
        f = 2 * sum(T[a] * T[L - 1 - a] for a in range(1, L - 1))
        f += F[L - 1] if L >= 2 else 0
        f += 3 * sum(F[a] * F[L - 1 - a] for a in range(1, L - 1))
        f += 2 * sum(V[lv] * F[L - 1 - lv] for lv in range(1, L - 1))
        F[L] = f
    print("N2 formula counts F(L):", {L: F[L] for L in (3, 5, 10, 20)})
    for L in (50, 100, 200, 300, 399):
        print(f"   F({L+1})/F({L}) = {F[L+1] / F[L]:.6f}" if L + 1 <= Lmax else "")
    gamma = F[Lmax] / F[Lmax - 1]
    # Richardson-type refinement: ratios behave like gamma (1 - 3/(2L)) for algebraic singularities
    g2 = (F[Lmax] / F[Lmax - 1]) / (1 - 1.5 / Lmax)
    print(f"   gamma estimate: ratio at L={Lmax}: {gamma:.6f}; corrected for L^(-3/2): {g2:.6f}")
    d_str = 1 / (5 * log2(14))
    d_wff = 1 / (5 * log2(g2))
    print(f"N3 delta_str = 1/(5 log2 14) = {d_str:.5f}  (rigorous, all strings)")
    print(f"   delta_wff = 1/(5 log2 gamma) ~ {d_wff:.5f}  (formula count; gamma numerical)")
    print(f"   e.g. n = 10^6 first sentences contain beta_1..beta_m with m ~ (n/C)^delta, "
          f"n^delta_str = {(10**6) ** d_str:.2f}, n^delta_wff = {(10**6) ** d_wff:.2f} (times C^-delta)")
    print("done")


if __name__ == "__main__":
    main()
