"""Symbolic instantiation checks for Remarks 5.5 and 5.7 of RT-depth2.fixed.md.
Remark 5.5 <- redteam.md Prop 6.1 at L=2 (H=1), zero competitor as width-1 net with B=1 (U=mB=1, E*=d(d+1)B^2+2(L-1)m^2B^2).
Remark 5.7 <- B.md Prop 6.1 + Lemma 5.3(a) at H=1, delta'=delta/2, K=n/c+1, D_n=sqrt(2(d+1)ln(n+1)) + (H-1)/2."""
import sympy as sp
d, n, c, N, delta = sp.symbols('d n c N delta', positive=True)
H = 1; L = 2; m = 1; B = 1
U = m * B; Es = d * (d + 1) * B**2 + 2 * (L - 1) * m**2 * B**2
PN = N * (d + 1) + (L - 2) * N**2 + N
K = Es + 1 + n * (U + 1)**2 / c
rt61 = c * (Es + 1) / n + 8 / n + 4 * sp.sqrt((PN * sp.log(2 + 2 * n * sp.sqrt(K * N) * H * (d + N + 1) * (K + 1)**sp.Rational(H, 2)) + sp.log(4 / delta)) / (2 * n)) + (U + 1)**2 * sp.sqrt(sp.log(4 / delta) / (2 * n))
Kdoc = d**2 + d + 3 + 4 * n / c
doc55 = (c * (d**2 + d + 3) + 8) / n + 4 * sp.sqrt((N * (d + 2) * sp.log(2 + 2 * n * sp.sqrt(Kdoc * N) * (d + N + 1) * sp.sqrt(Kdoc + 1)) + sp.log(4 / delta)) / (2 * n)) + 4 * sp.sqrt(sp.log(4 / delta) / (2 * n))
print("Remark 5.5: E* =", sp.expand(Es), "; K - Kdoc =", sp.simplify(K - Kdoc), "; P_N =", sp.factor(PN), "; display difference =", sp.simplify(rt61 - doc55))
# Remark 5.7
Kb = n / c + 1
Dn = sp.sqrt(2 * (d + 1) * sp.log(n + 1)) + sp.Rational(H - 1, 2)
Psi = 8 * (Kb / H)**sp.Rational(H, 2) * Dn / sp.sqrt(n) + 4 * sp.sqrt(sp.log(1 / (delta / 2)) / (2 * n))
Exc = c * (Es + 1) / n + Psi + (U + 1)**2 * sp.sqrt(sp.log(2 / delta) / (2 * n))
doc57 = c * (d**2 + d + 3) / n + 8 * sp.sqrt(2 * (d + 1) * sp.log(n + 1)) * sp.sqrt(1 / c + 1 / n) + 8 * sp.sqrt(sp.log(2 / delta) / (2 * n))
diff = sp.simplify(sp.expand(Exc - doc57))
print("Remark 5.7: Exc - doc display =", diff, "; numeric spot check:",
      float((Exc - doc57).subs({d: 30, n: 2**30, c: 7, delta: sp.Rational(1, 10)})))
# unclipped main term (Lemma 5.3(b)) order: 4 (sqrt K + 1) K^{1/2} D_n / sqrt n ~ 4 D_n sqrt(n)/c
main_b = 4 * (sp.sqrt(Kb) + 1) * sp.sqrt(Kb) * Dn / sp.sqrt(n)
print("Lemma 5.3(b) main term / (D_n sqrt(n)/c) at n=2^30, c=n^0.6:", float((main_b / (Dn * sp.sqrt(n) / c)).subs({d: 30, n: 2**30, c: (2**30)**0.6})))
