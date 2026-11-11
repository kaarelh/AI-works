"""Symbolic checks (sympy) of the algebra in RT-width.fixed.md."""
import sympy as sp
n, b, mu, l, H, c, z, m, a, N = sp.symbols('n b mu ell H c zeta m alpha N', positive=True)

# Lemma E(ii): t = A + C, A = sqrt(2 b mu l/n), C = 2 b l/(3n); claim t^2 - (2l/n)(b mu + b t/3) >= 0
A = sp.sqrt(2*b*mu*l/n); C = 2*b*l/(3*n); t = A + C
expr = sp.expand(t**2 - (2*l/n)*(b*mu + b*t/3))
print("E(ii): t^2 - (2l/n)(b mu + b t/3) =", sp.simplify(expr), "(>= 0 since every term is >= 0)")
# exact root of s^2 = 2 l (v + b s/3) with v = n b mu, in mean scale
texact = b*l/(3*n) + sp.sqrt((b*l/(3*n))**2 + 2*b*mu*l/n)
print("E(ii): exact root <= stated t:", sp.simplify(sp.expand((t - b*l/(3*n))**2 - ((b*l/(3*n))**2 + 2*b*mu*l/n))), "(= 2AC' + ... >= 0)")
# Hoeffding root: exp(-2 n t^2 / b^2) = delta'  ->  t = b sqrt(l/(2n))
th = sp.symbols('t_h', positive=True)
print("E(i): root of 2 n t^2/b^2 = l :", sp.solve(sp.Eq(2*n*th**2/b**2, l), th))

# Lemma F: a = zeta/(4(n/c+zeta)); (1-a)(m+zeta) - m - zeta/4 >= zeta/2 for 0 <= m <= n/c, equality at m = n/c
aa = z/(4*(n/c + z))
g = (1 - aa)*(m + z) - m - z/4 - z/2
print("Lemma F: margin at m = n/c:", sp.simplify(g.subs(m, n/c)), "; d(margin)/dm =", sp.simplify(sp.diff(g, m)), "(< 0, so worst case m = n/c)")

# Corollary 3 step 4: (H+5) ln(2n) - [(3+3H/2) ln2 + (2H+9)/4 ln n]
expr4 = (H+5)*sp.log(2*n) - ((3 + sp.Rational(3, 2)*H)*sp.log(2) + (2*H+9)/4*sp.log(n))
expr4 = sp.expand(sp.expand_log(expr4, force=True))
print("Cor 3 step 4: difference =", sp.collect(expr4, [sp.log(2), sp.log(n)]))
print("   at ln n = ln 2:", sp.simplify(expr4.subs(sp.log(n), sp.log(2))))
# product in step 4
nu = sp.symbols('nu', positive=True)
prod = 2*n*sp.sqrt(sp.Rational(3, 2)*n*2*sp.sqrt(n))*H*4*sp.sqrt(n)*(2*n)**(H/2)
print("Cor 3 step 4: product / (8 sqrt3 H 2^(H/2) n^((2H+9)/4)) =", sp.simplify(prod/(8*sp.sqrt(3)*H*2**(H/2)*n**((2*H+9)/4))))
# steps 1,2,3 constant arithmetic
L = H + 1
print("Cor 3 step 1: 2 + 8(L-1) + 1 =", sp.expand(2 + 8*(L-1) + 1), "; plus 4 ->", sp.expand(2 + 8*(L-1) + 1 + 4), "(= 8L-1)")
print("Cor 3 step 3: 2*3 + 4(H-1) =", sp.expand(6 + 4*(H-1)), "(= 4H+2)")
print("Cor 3 step 5: 4*sqrt((4H+2)(H+5)/2) =", sp.simplify(4*sp.sqrt((4*H+2)*(H+5)/2)), "; 4/sqrt2 =", sp.nsimplify(4/sp.sqrt(2)))
print("Cor 3 sum: 3 sqrt2 + 2 sqrt2 =", sp.simplify(3*sp.sqrt(2) + 2*sp.sqrt(2)))
# 2 + (16 - 8 sqrt3) * H 2^{H/2} n^{(2H+9)/4} margin at H=1, n=2
print("Cor 3 step 4: (16-8sqrt3)*1*sqrt2*2^(11/4) =", sp.N((16 - 8*sp.sqrt(3))*sp.sqrt(2)*2**sp.Rational(11, 4)), "(must be >= 2)")
# Remark 5 window: n^{2a} <= U+1 <= 3 n^{2a}  ->  term between n^{4a-1/2} sqrt(l/2) and 9/sqrt2 n^{4a-1/2} sqrt l
print("Remark 5: 9*sqrt(1/2) =", sp.nsimplify(9*sp.sqrt(sp.Rational(1, 2))))
# Remark 7 exponent: H + L = 2L - 1
print("Remark 7: H + L =", sp.expand(H + L), "(= 2L-1 with L=H+1)")
