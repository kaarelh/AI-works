"""Referee, second pass: the closed forms in the proof of Corollary 4 of the revised equational.md,
the bound for successor, where Proposition 4a(2) starts to say something, and the bounds quoted
after Proposition 10.  Exact rational arithmetic or 3000-digit decimals; shares nothing with code/.

Usage: python3 eq2_prior.py
"""
from decimal import Decimal, getcontext
from fractions import Fraction
from math import ceil, log2

getcontext().prec = 3000


def lg(x):
    """log2 of a positive Fraction or Decimal, as a float"""
    if isinstance(x, Fraction):
        return log2(x.numerator) - log2(x.denominator)
    t = x.as_tuple()
    mant = float(Decimal(int("".join(map(str, t.digits[:30])))))
    return log2(mant) + (t.exponent + len(t.digits) - min(30, len(t.digits))) * log2(10)


# ------------------------------------------------------------------ unary (successor): everything exact
def eps1(m):
    q, qm = Fraction(3, 4), Fraction(3, 4) - Fraction(3, 4) / 3 ** m
    return (1 / (1 - q * q) - 1 / (1 - qm * qm)) / 6


print("== successor (k = 1) ==")
print(f"2q/(a(1-q^2)^2) * (q - q_n) with q = 3/4, a = 6, q - q_n = (3/4) 3^-n:  coefficient of 3^-n = "
      f"{2 * Fraction(3, 4) * Fraction(3, 4) / (6 * (1 - Fraction(9, 16)) ** 2)}  (the note: 48/49)")
ok_closed = all(eps1(n) <= Fraction(48, 49) / 3 ** n for n in range(0, 400))
print(f"eps(n) <= (48/49) 3^-n for n < 400: {ok_closed}")
# the note's bound 2^(13 - 1.58 n): compare exactly, 2^(13 - 1.58 n) = 2^13 * 2^(-158 n / 100)
# 6^5 eps(n) <= 2^(13 - 1.58 n)  <=>  (6^5 eps(n))^100 <= 2^(1300 - 158 n)
bad_note = [n for n in range(0, 2001) if (6 ** 5 * eps1(n)) ** 100 > Fraction(2) ** (1300 - 158 * n)]
print(f"6^5 eps(n) <= 2^(13 - 1.58 n) for all n <= 2000 (exact): {not bad_note}")
print(f"   and for all n by the closed form: log2(6^5 * 48/49) = {5 * log2(6) + log2(48 / 49):.6f} <= 13 and log2 3 = {log2(3):.7f} >= 1.58")
# the first report's 2^(12.9 - 1.585 n):  (6^5 eps(n))^1000 <= 2^(12900 - 1585 n)
bad_ref = [n for n in range(0, 401) if (6 ** 5 * eps1(n)) ** 1000 > Fraction(2) ** (12900 - 1585 * n)]
print(f"the first report's 6^5 eps(n) <= 2^(12.9 - 1.585 n): fails first at n = {bad_ref[0]}, and at every n from there to 400: "
      f"{bad_ref == list(range(bad_ref[0], 401))}")
print(f"   (reason: 1.585 > log2 3 = {log2(3):.7f}; the margin 12.9 - {5 * log2(6) + log2(48 / 49):.6f} = "
      f"{12.9 - 5 * log2(6) - log2(48 / 49):.6f} is used up at n = {(12.9 - 5 * log2(6) - log2(48 / 49)) / (1.585 - log2(3)):.1f})")
print(f"   a correct pair of rounded constants: 6^5 eps(n) <= 2^(12.9 - 1.5849 n) for all n: "
      f"{all((6 ** 5 * eps1(n)) ** 10000 <= Fraction(2) ** (129000 - 15849 * n) for n in range(0, 401))} (checked to 400; 1.5849 < log2 3)")

# ------------------------------------------------------------------ binary (addition)
print("\n== addition (k = 2) ==")
q = Decimal(3) - Decimal(5).sqrt()
coef = 2 * q / (7 * (1 - q * q) ** 2)
print(f"q = 3 - sqrt 5 = {float(q):.9f};  2q/(a(1-q^2)^2) = {float(coef):.6f};  times 2 (5/7)^2 = {float(coef * 2 * Decimal(25) / 49):.6f}  (the note: 1.2845)")
MAXS = 3100
T = [0, 4]
for s in range(2, MAXS + 1):
    T.append(T[s - 1] + sum(T[i] * T[s - 1 - i] for i in range(1, s - 1)))
# sum of T_s / 5^s <= 2: by induction on the partial sums P_N <= 4/5 + P_(N-1)/5 + P_(N-1)^2/5 <= 2
P = Fraction(0)
ok = True
p5 = 1
for s in range(1, 400):
    p5 *= 5
    Pn = P + Fraction(T[s], p5)
    ok &= Pn <= Fraction(4, 5) + P / 5 + P * P / 5 and Pn < 2
    P = Pn
print(f"partial sums P_N of T_s/5^s: P_N <= 4/5 + P_(N-1)/5 + P_(N-1)^2/5 and P_N < 2 for N < 400: {ok}   (P_399 = {float(P):.5f})")
qm = [Decimal(0)]
acc = Fraction(0)
p7 = 1
for s in range(1, MAXS + 1):
    p7 *= 7
    acc += Fraction(T[s], p7)
    qm.append(Decimal(acc.numerator) / Decimal(acc.denominator))
eps2 = lambda m: (1 / (1 - q * q) - 1 / (1 - qm[m] * qm[m])) / 7
tail_ok = all(q - qm[m] <= 2 * (Decimal(5) / 7) ** (m + 1) for m in range(0, 3001))
print(f"q - q_m <= 2 (5/7)^(m+1) for m <= 3000: {tail_ok}")
c1 = Decimal("1.2845")
print(f"eps(n+1) <= 1.2845 (5/7)^n for n <= 3000: {all(eps2(n + 1) <= c1 * (Decimal(5) / 7) ** n for n in range(0, 3001))}")
# 7^13 * 1.2845 * (5/7)^n <= 2^(36.5 - 0.485 n)  <=>  (7^13 * 1.2845)^1000 * (5/7)^(1000 n) <= 2^(36500 - 485 n)
lhs = lambda n: (Fraction(7) ** 13 * Fraction(12845, 10000)) ** 1000 * Fraction(5, 7) ** (1000 * n)
first = next(n for n in range(700, 1000) if lhs(n) <= Fraction(2) ** (36500 - 485 * n))
print(f"7^13 * 1.2845 * (5/7)^n <= 2^(36.5 - 0.485 n) holds from n = {first} on (exact; the note: 836); at n = {first - 1} it fails: "
      f"{lhs(first - 1) > Fraction(2) ** (36500 - 485 * (first - 1))}")
W = Decimal(7) ** 13
print(f"7^13 eps(n+1) <= 2^(36.5 - 0.485 n) for all n <= 3000 (high precision): "
      f"{all(lg(W * eps2(n + 1)) <= 36.5 - 0.485 * n for n in range(0, 3001))}")

print("\n== where the bounds say something ==")
m0 = next(m for m in range(1, 3000) if W * eps2(m) < 1)
print(f"7^13 eps(m) < 1 first at m = {m0}  (Corollary 4: m = n + 1, so n = {m0 - 1})")
print(f"Proposition 4a(2) gives 7^13 eps(m) with n >= m^2 (h + 1): below 1 only for m >= {m0}, that is n >= {m0 * m0} (h + 1):")
for h in (1, 2, 5):
    print(f"   h = {h}: n >= {m0 * m0 * (h + 1)};   at n = 200 it allows m <= {int((200 / (h + 1)) ** 0.5)} and the bound is 2^{lg(W * eps2(int((200 / (h + 1)) ** 0.5))):.1f}"
          f"  (Corollary 4 without missing pairs: 2^{lg(W * eps2(201)):.1f})")
for n in (10000, 40000):
    for h in (1, 3):
        m = int((n / (h + 1)) ** 0.5)
        print(f"   n = {n}, h = {h}: m = {m}, bound 2^{lg(W * eps2(m)):.1f}   (Corollary 4 without missing pairs: about 2^{36.5 - 0.485 * n:.0f})")

print("\n== after Proposition 10: doubling ==")
print("lower bound on a wrong belief at n = 2^j: 6^-(1.5 j^2 + 8.5 j + 8); upper bound from Theorem 2: 6^11 eps(m), largest m with 2^(m-2) + 1 <= n, i.e. m = j + 1")
for j in (5, 10, 20, 30, 40):
    up = lg(6 ** 11 * eps1(j + 1))
    lo = -(1.5 * j * j + 8.5 * j + 8) * log2(6)
    print(f"   j = {j:2d}: pinning between {-up:8.1f} and {-lo:8.1f} bits;   the note's 1.58 j - 28 = {1.58 * j - 28:7.1f},  3.9 j^2 + 22 j + 21 = {3.9 * j * j + 22 * j + 21:8.1f}")
print(f"   exact constants: lower end = {log2(3):.4f} (j + 1) - {11 * log2(6) + log2(48 / 49):.2f} (from (48/49) 3^-m);  upper end = {1.5 * log2(6):.3f} j^2 + {8.5 * log2(6):.2f} j + {8 * log2(6):.2f}")
