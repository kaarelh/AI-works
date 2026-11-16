#!/usr/bin/env python3
"""Referee check (key: hellinger-runs), part 1: symbolic verification with sympy.

Every identity that the proofs of Lemma 2.2, Theorem 2.7, Examples 2.6, 2.8(i), 4.8 and
Lemma 1.1(6) of research/prove-b/hellinger-runs.md use as "a direct computation" is
checked here as an exact identity.  Each check prints the residual, which must be 0.

Needs sympy (not needed by any other script of this report).
"""
import sympy as sp

ok = True


def report(name, expr):
    global ok
    e = sp.simplify(expr)
    good = (e == 0)
    ok = ok and good
    print(f"  {name}: residual = {e}   {'OK' if good else 'FAIL'}")


print("Lemma 2.2 (potential U(x) = (2-x)_+^2 / 2, constant 4)")
x, Lam, m, m2 = sp.symbols("x Lambda m m2", nonnegative=True)   # m = E r, m2 = E r^2
U_in = sp.Rational(1, 2) * (2 - x) ** 2                       # U on [0,2]
report("(i)   U(x) - (3/2 - x) - (x-1)^2/2 on [0,2]", U_in - (sp.Rational(3, 2) - x) - (x - 1) ** 2 / 2)
# case Lam <= 2: E (2 - Lam r)^2 / 2 with E r^2 replaced by its bound 1
lhs = 2 - 2 * Lam * m + Lam ** 2 / 2
report("(ii)  case Lam<=2: [2 - 2 Lam m + Lam^2/2] - [(2-Lam)^2/2 + 2 Lam (1-m)]",
       lhs - (sp.Rational(1, 2) * (2 - Lam) ** 2 + 2 * Lam * (1 - m)))
report("(ii)  case Lam>2: 2 E(1-r)^2 at E r^2 = 1 equals 4(1 - m)", 2 * (1 - 2 * m + 1) - 4 * (1 - m))

print("Theorem 2.7, Step 0: the function g and the identities (iii)")
q = sp.symbols("q", positive=True)
g_explicit = 1 + q * sp.exp(q ** 2 / 4) * (1 / sp.sqrt(2) + sp.sqrt(sp.pi) / 2 * sp.erf(q / 2))
report("g' - [(g-1)(1/q + q/2) + q/2]  (explicit g with erf)",
       sp.diff(g_explicit, q) - ((g_explicit - 1) * (1 / q + q / 2) + q / 2))
report("g(q) - 1 - q/sqrt2 = O(q^2): coefficient of q in the series", sp.series(g_explicit, q, 0, 2).removeO() - 1 - q / sp.sqrt(2))
# now treat g as an unknown function satisfying the ODE
G = sp.Function("g")(q)
ode = {sp.Derivative(G, q): (G - 1) * (1 / q + q / 2) + q / 2}
s = 1 / G
p = 2 * (1 - s) / q
r = (p - q) / 2


def d(expr):
    return sp.diff(expr, q).subs(ode)


report("ds/dq + (s/(2q)) (2(1-s) + q^2)", d(s) + s / (2 * q) * (2 * (1 - s) + q ** 2))
report("dp/dq - (q^2 s - 2(1-s)^2)/q^2", d(p) - (q ** 2 * s - 2 * (1 - s) ** 2) / q ** 2)
report("d(p/s)/dq - 1/s", d(p / s) - 1 / s)
report("dr/dq + (1-s)(q^2 + 2(1-s))/(2 q^2)", d(r) + (1 - s) * (q ** 2 + 2 * (1 - s)) / (2 * q ** 2))
report("(dr/dq)/(ds/dq) - p/(2s)", d(r) / d(s) - p / (2 * s))
report("p q - 2(1-s)", p * q - 2 * (1 - s))

print("Theorem 2.7, Step 2: the three forms of tau_Lambda(a)")
a, c, Ls, ss, qq = sp.symbols("a c Lambda s q", positive=True)


def tau(ULam, mu, L_):
    return ULam + c * (1 - a / L_) + mu * (a ** 2 / L_ ** 2 - 1) + a


# range Lam <= 1
report("Lam<=1:  tau - (c-Lam)/(2 Lam^2) (a-Lam)^2", tau(-Ls, (c - Ls) / 2, Ls) - (c - Ls) / (2 * Ls ** 2) * (a - Ls) ** 2)
# range 1 <= Lam <= c: Lam = c s, p = 2(1-s)/q, r = (p-q)/2, U(Lam) = c r^2 - c s, mu = c p^2/4
pp = 2 * (1 - ss) / qq
rr = (pp - qq) / 2
report("1<=Lam<=c: tau - c/(4 s^2) (p a/c - s q)^2",
       tau(c * rr ** 2 - c * ss, c * pp ** 2 / 4, c * ss) - c / (4 * ss ** 2) * (pp * a / c - ss * qq) ** 2)
# range Lam >= c
t3 = tau(-c / 2, c / 2, Ls)
report("Lam>=c:  tau - [a(1 - c/Lam) + c a^2/(2 Lam^2)]", t3 - (a * (1 - c / Ls) + c * a ** 2 / (2 * Ls ** 2)))
report("Lam>=c:  tau - (a - c/2) - (c/2)(1 - a/Lam)^2", t3 - (a - c / 2) - c / 2 * (1 - a / Ls) ** 2)
report("Lam>=c:  d tau/d Lam - (c a/Lam^2)(1 - a/Lam)", sp.diff(t3, Ls) - c * a / Ls ** 2 * (1 - a / Ls))
# agreement at Lam = 1: s0 = 1/c, p = q = q0 with q0^2 = 2(c-1)/c
q0 = sp.sqrt(2 * (c - 1) / c)
mid_at_1 = (c / (4 * ss ** 2) * (qq * a / c - ss * qq) ** 2).subs({ss: 1 / c, qq: q0})
report("agreement at Lam = 1: middle form - (c-1)/2 (a-1)^2", mid_at_1 - (c - 1) / 2 * (a - 1) ** 2)
# agreement at Lam = c: s = 1, p = sqrt 2, q = 0
mid_at_c = c / 4 * (sp.sqrt(2) * a / c) ** 2
report("agreement at Lam = c: middle form - a^2/(2c)", mid_at_c - a ** 2 / (2 * c))

print("Theorem 2.7, Step 0 (iv), (v): the derivatives in s'")
s1, s2 = sp.symbols("s s_prime", positive=True)
P = sp.Function("p")
R = sp.Function("r")
Q = sp.Function("q")
phi = P(s1) * s2 - s1 * Q(s1) - 2 * s1 * R(s2)
dphi = sp.diff(phi, s2).subs(sp.Derivative(R(s2), s2), P(s2) / (2 * s2))
report("(iv)  d phi/d s' - s (p(s)/s - p(s')/s')", dphi - s1 * (P(s1) / s1 - P(s2) / s2))
psi = P(s1) * s2 - s1 * Q(s1) - 2 * s1 * sp.sqrt(s2 - sp.Rational(1, 2))
report("(v)   d psi/d s' - (p(s) - s/sqrt(s' - 1/2))", sp.diff(psi, s2) - (P(s1) - s1 / sp.sqrt(s2 - sp.Rational(1, 2))))

print("Example 2.6 (two calls)")
eps, sv = sp.symbols("epsilon s", positive=True)
aa, bb = eps, sv ** 2 * eps
H2 = 1 - sp.sqrt((1 - aa) * (1 - bb))
Esum = 1 - sp.sqrt((1 - aa) * (1 - bb)) - sp.sqrt(aa * bb) + aa
report("H2 = (1+s^2) eps/2 + O(eps^2)", sp.series(H2, eps, 0, 2).removeO() - (1 + sv ** 2) * eps / 2)
report("E sum h = (s^2-2s+3) eps/2 + O(eps^2)", sp.series(Esum, eps, 0, 2).removeO() - (sv ** 2 - 2 * sv + 3) * eps / 2)
ratio = (sv ** 2 + 1) / (sv ** 2 - 2 * sv + 3)
crit = sp.solve(sp.diff(ratio, sv), sv)
print("  critical points of (s^2+1)/(s^2-2s+3) on s>0:", crit)
report("value at s = 1+sqrt2 minus (2+sqrt2)/2", ratio.subs(sv, 1 + sp.sqrt(2)) - (2 + sp.sqrt(2)) / 2)

print("Example 2.8(i) (lattice walk): limit of the ratio as beta -> 1 with beta^m = b")
e, b = sp.symbols("e b", positive=True)          # beta = exp(e), m = ln b / e
beta = sp.exp(e)
mm = sp.log(b) / e
pi_ = (beta ** 2 - 1) / (b ** 2 * beta ** 2 - 1)
H2l = 1 - (1 - pi_) / beta
El = (beta - 1) / (beta + 1) * ((1 - pi_) - mm * pi_) + pi_
lim = sp.limit(H2l / El, e, 0)
report("limit - 2(b^2+1)/(b^2+3-2 ln b)", lim - 2 * (b ** 2 + 1) / (b ** 2 + 3 - 2 * sp.log(b)))
u_, bet = sp.symbols("u beta", positive=True)
report("Lambda^2 is a martingale under S: beta^2/(1+beta^2) + beta^-2 beta^2/(1+beta^2) - 1",
       bet ** 2 / (1 + bet ** 2) + bet ** (-2) * bet ** 2 / (1 + bet ** 2) - 1)
report("h of one lattice step: 1 - 2 beta/(1+beta^2) - (beta-1)^2/(1+beta^2)",
       1 - 2 * bet / (1 + bet ** 2) - (bet - 1) ** 2 / (1 + bet ** 2))

print("Example 2.8(ii) (drift and drop): S' is a probability law and E r^2 = 1")
dk = sp.symbols("d", nonnegative=True)
pik = (bet ** 2 - 1) / (bet ** 2 - dk ** 2)
report("pi d^2 + (1-pi) beta^2 - 1", pik * dk ** 2 + (1 - pik) * bet ** 2 - 1)

print("Example 4.8: the integral")
o = sp.symbols("o", positive=True)
val = sp.integrate(sp.log(u_ + o) - sp.log(u_), (u_, 0, 1))
report("int_0^1 ln(1+o/u) du - [(1+o) ln(1+o) + o ln(1/o)]", val - ((1 + o) * sp.log(1 + o) + o * sp.log(1 / o)))

print("Lemma 1.1(6): second derivative of sqrt(t(2-t))")
t = sp.symbols("t", positive=True)
report("d^2/dt^2 sqrt(2t-t^2) + (2t-t^2)^(-3/2)", sp.diff(sp.sqrt(2 * t - t ** 2), t, 2) + (2 * t - t ** 2) ** sp.Rational(-3, 2))

print("Proposition 3.4: kappa = KL(Bern(1/2+delta) || Bern(1/2-delta))")
dl, ell = sp.symbols("delta ell", positive=True)       # ell stands for ln((1/2+delta)/(1/2-delta))
half = sp.Rational(1, 2)
report("the two odds agree: (1/2+delta)/(1/2-delta) - (1+2 delta)/(1-2 delta)",
       (half + dl) / (half - dl) - (1 + 2 * dl) / (1 - 2 * dl))
report("kappa = (1/2+delta) ell + (1/2-delta)(-ell) = 2 delta ell", (half + dl) * ell + (half - dl) * (-ell) - 2 * dl * ell)
xx = sp.symbols("x", positive=True)
ser = sp.series(sp.log((1 + xx) / (1 - xx)) - 2 * xx / (1 - xx ** 2), xx, 0, 8).removeO()
print("  ln((1+x)/(1-x)) - 2x/(1-x^2) =", ser, "+ O(x^9): all coefficients <= 0, as the bound kappa <= 8 delta^2/(1-4 delta^2) needs")

print("ALL SYMBOLIC CHECKS PASSED" if ok else "SOME SYMBOLIC CHECK FAILED")
