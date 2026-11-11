"""Symbolic checks (sympy) of exponent and constant algebra in B.md."""
import sympy as sp
H, al, th, n, L = sp.symbols('H alpha theta n L', positive=True)

print("== Thm 6.3: balancing theta = (1 - theta H)/2 ==")
sol = sp.solve(sp.Eq(th, (1 - th * H) / 2), th); print("  theta* =", sol, " -> rate exponent", [sp.simplify((1 - s * H) / 2) for s in sol])

print("== Cor 8.1 (H>=2): theta=(1+8a)/(H+2), beta=(1-4aH)/(H+2) ==")
T = (1 + 8 * al) / (H + 2); beta = (1 - 4 * al * H) / (H + 2)
print("  4a - theta + beta          =", sp.simplify(4 * al - T + beta))
print("  (1 - theta H)/2 - beta     =", sp.simplify((1 - T * H) / 2 - beta))
print("  theta < 1/H  <=>  a < 1/(4H): 1/H - theta =", sp.factor(sp.simplify(1 / H - T)))
print("  -beta - (4a - 1/2) =", sp.factor(sp.simplify(-beta - (4 * al - sp.Rational(1, 2)))), " (>=0 iff a <= H/16)")
print("  H=1: theta=", T.subs(H, 1), " 4a-theta =", sp.simplify(4 * al - T.subs(H, 1)), " (1-theta)/2 =", sp.simplify((1 - T.subs(H, 1)) / 2))
for a_ in [sp.Rational(1, 16), sp.Rational(1, 10), sp.Rational(1, 8), sp.Rational(3, 16), sp.Rational(6, 25)]:
    b1 = min((1 - 4 * a_) / 3, sp.Rational(1, 2) - 4 * a_)
    print(f"    H=1, alpha={a_}: beta = min((1-4a)/3, 1/2-4a) = {b1}  ({'vacuous: no decay' if b1 <= 0 else 'ok'})")
print("  example depth 3 (H=2), alpha=1/16: beta =", beta.subs({H: 2, al: sp.Rational(1, 16)}))

print("== E*+1 <= (d(d+1)+2L) n^{4a} with m = floor(n^a), B = n^a; (U+1)^2+4 <= 8 n^{4a} ==")
d, x = sp.symbols('d x', positive=True)   # x = n^alpha >= 1
Es1 = d * (d + 1) * x ** 2 + 2 * H * x ** 4 + 1
print("  (d(d+1)+2H+2) x^4 - (E*+1) =", sp.expand((d * (d + 1) + 2 * H + 2) * x ** 4 - Es1), " (>=0 for x>=1)")
print("  8x^4 - (4+(x^2+1)^2) =", sp.factor(sp.expand(8 * x ** 4 - 4 - (x ** 2 + 1) ** 2)), " (>=0 for x>=1)")

print("== Cor 9.3 thresholds ==")
Ls = sp.symbols('L', positive=True)
Hs = Ls - 1
print("  (a) width 1: eta exponent  L/(2H) - a L  > 0 => a* = 1/(2H):", sp.solve(sp.Eq(Ls / (2 * Hs) - al * Ls, 0), al))
print("  (b) width&weights: L/(2H) - a(2L-1) => a* =", sp.solve(sp.Eq(Ls / (2 * Hs) - al * (2 * Ls - 1), 0), al))
for Lv in [2, 3, 4, 5]:
    print(f"    L={Lv}: [1/(4H), L/(2H(2L-1))] = [{sp.Rational(1, 4 * (Lv - 1))}, {sp.Rational(Lv, 2 * (Lv - 1) * (2 * Lv - 1))}]"
          f" = [{float(sp.Rational(1, 4 * (Lv - 1))):.4f}, {float(sp.Rational(Lv, 2 * (Lv - 1) * (2 * Lv - 1))):.4f}]")
print("  m^H B^L with m = n^a, B = n^a: exponent a(H+L) = a(2L-1):", sp.simplify(al * (Hs + Ls) - al * (2 * Ls - 1)))

print("== Prop 9.1(c) arithmetic ==")
for Lv in range(2, 12):
    c1 = (1 + sp.Rational(5, 4 * Lv)) * sp.Integer(4) ** sp.Rational(1, Lv)
    c2 = sp.Integer(2) ** sp.Rational(1, Lv) / sp.sqrt(Lv)
    print(f"  L={Lv}: (1+5/(4L)) 4^(1/L) = {float(c1):.4f} (<=3.25?)  2^(1/L)/sqrt(L) = {float(c2):.4f} (<=1?)")

print("== Remark 6.2': unclipped cover route exponents ==")
Lv = sp.symbols('Lv', positive=True)
# entropy ~ K^{4(L-1)} a^{-8}, a ~ K^{-1/2} -> K^{4L}; deviation ~ K * sqrt(K^{4L}/n) = K^{2L+1}/sqrt(n)
print("  L>=3: theta < 1/(2(2L+1)) =", sp.simplify(sp.Rational(1, 2) / (2 * Lv + 1)), "= 1/(4L+2)")
print("  L=2: entropy ~ K^2 a^-4 = K^4, deviation K * K^2/sqrt(n) -> theta < 1/6")

print("== Lemma 7.2 constants ==")
t = sp.symbols('t', positive=True)
print("  2*(3/2)^3/3 =", sp.Rational(2, 3) * sp.Rational(3, 2) ** 3, " = 9/4")
print("  ln(2M) with M=2^d:", sp.simplify(sp.log(2 * 2 ** d)), "= (d+1) ln 2")
print("== Lemma 7.1(d): (1-1/M)^(M-1) >= 1/e numerically for M=2..1e6 ==")
import math
print("  min over M in {2,..}: ", min((1 - 1 / M) ** (M - 1) * math.e for M in [2, 3, 4, 8, 16, 1024, 10 ** 6]))
