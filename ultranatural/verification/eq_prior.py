"""Referee's independent check of the prior weights (equational.md, Section 1, Corollary 4 and its
table, Section 6.2).  Shares no code with code/prior_tail.py.  Exact arithmetic (fractions) or
decimals with 4000 digits throughout.

Usage: python3 eq_prior.py
"""
from decimal import Decimal, getcontext
from fractions import Fraction
from math import comb, log2

getcontext().prec = 4000


def log2dec(d):
    """log2 of a positive Decimal, as a float"""
    t = d.as_tuple()
    digits = len(t.digits)
    mant = float(Decimal(t.digits[0]) + sum(Decimal(dg) / (10 ** (i + 1)) for i, dg in enumerate(t.digits[1:40])))
    return log2(mant) + (t.exponent + digits - 1) * log2(10)


def term_counts_binary(maxsize, leaves=4):
    T = [0, leaves]
    for s in range(2, maxsize + 1):
        T.append(T[s - 1] + sum(T[i] * T[s - 1 - i] for i in range(1, s - 1)))
    return T


def main():
    print("== Section 1: the weights sum to less than 1 ==")
    # unary: 3 leaves, a term of size s is one of 3 * 2^(s-1); alphabet 6
    q1 = sum(Fraction(3 * 2 ** (s - 1), 6 ** s) for s in range(1, 400))
    print(f"unary:  q = sum of 6^-size over terms = {float(q1):.9f} (closed form 3/4); "
          f"all identity sets (even number of terms, then the end marker): (1/6)/(1-q^2) = {float(Fraction(1, 6) / (1 - Fraction(9, 16))):.9f} = 8/21")
    # binary: T(z) = 4z + z T + z T^2; at z = 1/7: T^2 - 6T + 4 = 0, T = 3 - sqrt 5
    q2 = Decimal(3) - Decimal(5).sqrt()
    tot2 = (Decimal(1) / 7) / (1 - q2 * q2)
    print(f"binary: q = 3 - sqrt(5) = {float(q2):.9f};  all identity sets: (1/7)/(1-q^2) = {float(tot2):.9f}")
    MAXS = 3200
    T = term_counts_binary(MAXS)
    print(f"        check of the closed form: partial sum of T_s/7^s up to s = 400 is {float(sum(Fraction(T[s], 7 ** s) for s in range(1, 401))):.9f}")
    print(f"        number of terms of size 1..8: {T[1:9]};  T_s/T_(s-1) at s = 100, 1000, 3000: "
          f"{T[100] / T[99]:.4f}, {float(Fraction(T[1000], T[999])):.4f}, {float(Fraction(T[3000], T[2999])):.4f}  (limit 5)")
    part5 = sum(Fraction(T[s], 5 ** s) for s in range(1, 3001))
    print(f"        sum of T_s/5^s up to s = 3000: {float(part5):.6f}  (the generating function at its singularity 1/5 is exactly 2,")
    print("        since T = 4z + zT + zT^2 at z = 1/5 reads (T - 2)^2 = 0; hence the weight of the terms of size > m is at most 2 (5/7)^(m+1))")

    print("\n== Corollary 4: eps(m) = (1/a) (1/(1-q^2) - 1/(1-q_m^2)) ==")
    # binary, exact partial sums as Decimals
    qm = [Decimal(0)]
    acc = Fraction(0)
    p7 = 1
    for s in range(1, MAXS + 1):
        p7 *= 7
        acc += Fraction(T[s], p7)
        qm.append(Decimal(acc.numerator) / Decimal(acc.denominator))

    def eps2(m):
        return (1 / (1 - q2 * q2) - 1 / (1 - qm[m] * qm[m])) / 7

    def eps1(m):                              # unary, exact
        qmm = Fraction(3, 4) - Fraction(3, 4) / 3 ** m
        return (1 / (1 - Fraction(9, 16)) - 1 / (1 - qmm * qmm)) / 6

    w_plus = Decimal(7) ** 13
    print("  n   log2[7^13 eps(n+1)] (addition)   36.5-0.485n   log2[6^5 eps(n)] (successor)   13-1.58n   log2 n")
    for n in (10, 20, 50, 100, 200, 500, 1000):
        a = log2dec(w_plus * eps2(n + 1))
        e1 = eps1(n)
        b = log2(e1.numerator) - log2(e1.denominator) + 5 * log2(6)
        print(f"{n:5d} {a:14.2f} {36.5 - 0.485 * n:25.2f} {b:18.2f} {13 - 1.58 * n:22.2f} {log2(n):9.1f}")
    first = next(n for n in range(0, 3000) if w_plus * eps2(n + 1) < 1)
    print(f"  the addition bound 7^13 eps(n+1) is below 1 first at n = {first} (so it says nothing for n < {first});")
    first2 = next(n for n in range(0, 3000) if 36.5 - 0.485 * n < 0)
    print(f"  the closed form 2^(36.5-0.485n) is below 1 first at n = {first2}")
    first3 = next(n for n in range(0, 3000) if eps1(n) * 6 ** 5 < 1)
    print(f"  the successor bound 6^5 eps(n) is below 1 first at n = {first3}")
    # the two inequalities, for all n <= 3000
    worst2 = max(log2dec(w_plus * eps2(n + 1)) - (36.5 - 0.485 * n) for n in range(0, 3001))
    bad2 = [n for n in range(0, 3001) if log2dec(w_plus * eps2(n + 1)) > 36.5 - 0.485 * n]
    print(f"  7^13 eps(n+1) <= 2^(36.5-0.485n) for all n <= 3000: {not bad2}  (largest log2 of the ratio: {worst2:.4f}, at n = "
          f"{max(range(0, 3001), key=lambda n: log2dec(w_plus * eps2(n + 1)) - (36.5 - 0.485 * n))})")
    bad1 = []
    worst1 = -1e9
    for n in range(0, 3001):
        e1 = eps1(n)
        d = (log2(e1.numerator) - log2(e1.denominator) + 5 * log2(6)) - (13 - 1.58 * n) if e1 > 0 else -1e9
        worst1 = max(worst1, d)
        if d > 0:
            bad1.append(n)
    print(f"  6^5 eps(n) <= 2^(13-1.58n) for all n <= 3000: {not bad1}  (largest log2 of the ratio: {worst1:.4f})")
    # beyond 3000: eps(m) <= (1/7) 2q tail / (1-q^2)^2 and tail <= 2 (5/7)^(m+1)
    c = float((2 * q2 / (1 - q2 * q2) ** 2) / 7 * 2) * (5 / 7) ** 2
    print(f"  for every n: eps(n+1) <= {c:.4f} (5/7)^n, and (5/7)^n / 2^(-0.485 n) = {2 ** (log2(5 / 7) + 0.485):.6f}^n;")
    import math
    n0 = math.log(c / 2 ** (36.5 - 13 * log2(7))) / -math.log(2 ** (log2(5 / 7) + 0.485))
    print(f"  so the stated inequality holds for all n >= {math.ceil(n0)} by this estimate, and for n <= 3000 by the exact computation: for all n.")
    print(f"  asymptotic slope: log2(7/5) = {log2(7 / 5):.5f} (stated 0.485); unary: log2 3 = {log2(3):.5f} (stated 1.58)")

    print("\n== Section 6.2: what the enumeration covers (unary f, sets of at most 12 symbols) ==")
    CAP = 12
    ident = [0] * (CAP + 1)                   # concrete identities (strings) of each size
    canon = [0] * (CAP + 1)                   # identities up to renaming of variables and swapping of sides
    for s in range(2, CAP + 1):
        O = (s - 1) * 2 ** (s - 2)            # ordered pairs of words with s - 2 letters in all
        E = 2 ** ((s - 2) // 2) if s % 2 == 0 else 0      # pairs with equal words
        ident[s] = 9 * O
        canon[s] = O + 3 * (O + E) // 2       # u(x)=v(0): ordered; u(x)=v(x), u(x)=v(y), u(0)=v(0): unordered
    lists = [1] + [0] * CAP                   # ordered lists of concrete identities by total size
    for n in range(1, CAP + 1):
        lists[n] = sum(ident[s] * lists[n - s] for s in range(2, n + 1))
    w = sum(Fraction(lists[n], 6 ** (n + 1)) for n in range(CAP + 1))
    print(f"identities up to renaming and swapping, sizes 2..12: {sum(canon)}  (eq_unary reports 51297)")
    print(f"ordered lists of concrete identities with at most 12 symbols: {sum(lists)}; their total weight: {float(w):.12f}  (eq_unary count mode: 0.352913217272)")
    print(f"weight of all identity sets of any size: {8 / 21:.12f}; so sets of more than 12 symbols weigh {8 / 21 - float(w):.6f} = {100 * (8 / 21 - float(w)) / (8 / 21):.1f}% of the prior")
    # multisets of canonical identities by total size: product over sizes of (1 - z^s)^(-canon[s])
    multi = [1] + [0] * CAP
    for s in range(2, CAP + 1):
        new = [0] * (CAP + 1)
        for n in range(CAP + 1):
            if multi[n]:
                for k in range(0, (CAP - n) // s + 1):
                    new[n + k * s] += multi[n] * comb(canon[s] + k - 1, k)
        multi = new
    print(f"identity sets of at most 12 symbols up to renaming, swapping and reordering (multisets): {sum(multi)}")
    print("   (eq_unary count mode reports 476610; the 200,093 of the note is the number of search nodes it visits, namely the")
    print("    sets found consistent plus the inconsistent sets whose predecessor in its search order is consistent)")


if __name__ == "__main__":
    main()
