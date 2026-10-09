"""c15: spare templates whose law lies in the span of T*'s components (referee issue m7; notes-final Prop 5.5(d)).

T* = {tau1, tau2} with disjoint instance sets: Q1 = point mass at a, Q2 = uniform on {b1, b2}; Dir(alpha1, alpha2) weights,
alpha = (1/2, 1/2).  R_n := P^Dir_{T* + sigma}(D) / P^Dir_{T*}(D).
(d1) Q_sigma = Q1 (e.g. a renamed or argument-permuted copy of tau1).  Claimed exact formula (Dirichlet aggregation):
     R_n = [G(A+as) G(A+n) / (G(A) G(A+as+n))] * [G(a1+as+n1) G(a1) / (G(a1+as) G(a1+n1))]
         -> [G(A+as) G(a1) / (G(A) G(a1+as))] * (w1*)^as   a.s.
     Checked against direct numerical integration over the 2-simplex, and the limit at n = 1e6.
(d2) Q_sigma = (Q1 + Q2)/2 (in the convex hull, not equal to a component): R_n by numerical integration, at
     w1* = 0.3 (the notes claim, as a proof sketch, a positive finite limit when the induced prior density of the law
     is finite and positive at P*) and at w1* = 0.5, where P* = Q_sigma and that density is infinite.
"""
import math
import numpy as np
from scipy.special import gammaln, logsumexp

out = []
rng = np.random.default_rng(1515)
a1 = a2 = 0.5
A = a1 + a2


def exact_d1(n1, n, as_):
    return (gammaln(A + as_) + gammaln(A + n) - gammaln(A) - gammaln(A + as_ + n)
            + gammaln(a1 + as_ + n1) + gammaln(a1) - gammaln(a1 + as_) - gammaln(a1 + n1))


def log_marg_tstar(n1, n2):
    # int w1^n1 w2^n2 Dir(a1, a2) * Q factors (the Q factors cancel in R_n and are omitted)
    return gammaln(a1 + n1) + gammaln(a2 + n2) - gammaln(A + n1 + n2) - (gammaln(a1) + gammaln(a2) - gammaln(A))


def log_marg_spare_numeric(n1, nb1, nb2, as_, case, G=1500):
    """Numerical integral over the simplex of prod_x P_w(x)^{n_x} Dir(a1, a2, as)(dw), via stick-breaking:
    w_s = u ~ Beta(as, A), (w1, w2) = (1-u)(v, 1-v), v ~ Beta(a1, a2); Gauss-Jacobi-free midpoint rule on
    transformed variables u = y^(1/as), v = sin^2(pi z / 2) (uniform z <=> v ~ Beta(1/2, 1/2))."""
    y = (np.arange(G) + 0.5) / G
    u = y ** (1 / as_)
    # density of Beta(as, A) in y: u^(as-1) du = dy/as  => weight (1-u)^(A-1) / (B(as, A) * as) per unit y
    lu = (A - 1) * np.log1p(-u) - (gammaln(as_) + gammaln(A) - gammaln(as_ + A)) - math.log(as_) - math.log(G)
    z = (np.arange(G) + 0.5) / G
    v = np.sin(np.pi * z / 2) ** 2
    lv = np.full(G, -math.log(G))
    U, V = u[:, None], v[None, :]
    w1, w2, ws = (1 - U) * V, (1 - U) * (1 - V), U
    if case == 'd1':
        pa, pb1, pb2 = w1 + ws, w2 / 2, w2 / 2
    else:
        pa, pb1, pb2 = w1 + ws / 2, w2 / 2 + ws / 4, w2 / 2 + ws / 4
    ll = n1 * np.log(pa) + nb1 * np.log(pb1) + nb2 * np.log(pb2)
    return float(logsumexp(ll + lu[:, None] + lv[None, :]))


w1s = 0.5
for as_ in (0.5, 1.0, 2.0):
    lim = gammaln(A + as_) + gammaln(a1) - gammaln(A) - gammaln(a1 + as_) + as_ * math.log(w1s)
    for n in (20, 200, 2000):
        n1 = int(rng.binomial(n, w1s))
        nb1 = int(rng.binomial(n - n1, 0.5))
        nb2 = n - n1 - nb1
        base = log_marg_tstar(n1, n - n1) - (n - n1) * math.log(2)          # Q2 factor (1/2 per b-datum)
        num = log_marg_spare_numeric(n1, nb1, nb2, as_, 'd1') - base
        ex = exact_d1(n1, n, as_)
        out.append(f"(d1) alpha_s = {as_}: n = {n:5d}, n1 = {n1:5d}: ln R_n exact {ex:.5f}, numerical {num:.5f}")
    big = [exact_d1(int(rng.binomial(10**6, w1s)), 10**6, as_) for _ in range(5)]
    out.append(f"(d1) alpha_s = {as_}: ln R_n at n = 1e6 (5 draws): " + ", ".join(f"{b:.4f}" for b in big)
               + f";  claimed limit {lim:.4f}")

for w1d in (0.3, 0.5):
    for as_ in (0.5, 1.0):
        rows = []
        for n in (10**2, 10**3, 10**4, 10**5):
            vals = []
            for _ in range(10):
                n1 = int(rng.binomial(n, w1d))
                nb1 = int(rng.binomial(n - n1, 0.5))
                nb2 = n - n1 - nb1
                base = log_marg_tstar(n1, n - n1) - (n - n1) * math.log(2)
                vals.append(log_marg_spare_numeric(n1, nb1, nb2, as_, 'd2', G=2500) - base)
            rows.append(np.mean(vals))
        incr = np.diff(rows)
        out.append(f"(d2) w1* = {w1d}, alpha_s = {as_}: mean ln R_n at n = 1e2..1e5: " + ", ".join(f"{r:.4f}" for r in rows)
                   + "; increments per decade: " + ", ".join(f"{d:.4f}" for d in incr))
out.append("(d2) at w1* = 0.5 the truth equals Q_sigma itself (P* = (Q1 + Q2)/2), the induced prior density of P(a) is "
           "infinite there (the line w1 + ws/2 = 1/2 runs into the vertex ws = 1, where w1 = w2 -> 0 and the Dir(1/2) "
           "density is ~ 1/(w1 w2)^(1/2), not integrable along that line); R_n then grows without bound but slowly (the heuristic is R_n ~ c ln n, i.e. ln R_n ~ ln ln n; the increments of ln R_n per decade shrink)")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
