"""Two by-products of re-deriving Theorem 5.1.

(A) Small c.  Theorem 5.1 is stated for every c>0.  For c = kappa/d its own bound tends to the CONSTANT
    gamma(lambda)/(18 kappa+1)^2, and for c = o(1/d) the t=1 memorizer plus Lemma 1.2(a) gives
    excess >= beta(lambda) - o(1).  So Corollary 5.2's remark "does not refute the +o(1) formulation,
    since eps_d ~ 1/log^2 n" holds only for c >> 1/d.
    Bound (b):  (th G - E0)_+^2/(4MV),  th = 1/(18dc+1), E0 = c(dF_d+1)+2.
    Bound (a'): (sqrt Q - sqrt Rmax)_+^2/M,  Rmax = c(dF_d + 18 d Q + 1) + 2   (t = 1, a = 1/n).
    Both evaluated at the worst case of the Lemma 1.3 event (Q, G low; V high).

(B) Width.  With a general accuracy a <= 4 the proof gives R(tg) <= (1-t)^2 G + n t a, hence
    R(z_w) <= (1-th)G + th n a + c(dF_d+1) on N_1, and the width needed is m0 <= 72 d n ln(2M)/a^2 + 2.
    With a = 1/d: width O(d^4 n) instead of 72 d n^3 ln(2M) + 2, excess >= (th(G - n/d) - c(dF_d+1))_+^2/(4MV).
"""
import math
import mpmath as mp
mp.mp.dps = 50

def FD(d): return 1 + (d + 1) * (d + 2) ** 2
def gam(l): return (1 - math.exp(-l)) ** 2 / (4 * l)

def event_vals(d, lam=1.0):
    M = mp.mpf(2) ** d; n = mp.ceil(lam * M)
    p_d = -mp.expm1(n * mp.log1p(-1 / M))
    # beta_d = E[1/K; K>=1], K ~ Bin(n, 1/M): sum the series
    q = 1 / M
    beta_d = mp.nsum(lambda kk: mp.binomial(n, kk) * q ** kk * (1 - q) ** (n - kk) / kk, [1, 60]) if d <= 40 else \
        mp.e ** (-lam) * (mp.ei(lam) - mp.euler - mp.log(lam))
    n23 = n ** (mp.mpf(2) / 3)
    Q = M * beta_d - 2 * n23; G = M * p_d - 2 * n23; V = n + n23
    return M, n, Q, G, V

print("(A) small c, lambda = 1, worst case on the event of Lemma 1.3")
print("  d    c          bound(b) Thm5.1     gamma/(18dc+1)^2    bound(a') t=1     beta(1)=0.4848")
for d in [30, 40, 60, 100, 200]:
    M, n, Q, G, V = event_vals(d)
    for label, c in [("1", 1.0), ("1/(18d)", 1 / (18 * d)), ("1/d^2", 1.0 / d ** 2), ("1/d^3", 1.0 / d ** 3)]:
        th = 1 / (18 * d * c + 1); E0 = c * (d * FD(d) + 1) + 2
        b = max(th * G - E0, 0) ** 2 / (4 * M * V)
        Rmax = c * (d * FD(d) + 18 * d * Q + 1) + 2
        a2 = max(mp.sqrt(Q) - mp.sqrt(Rmax), 0) ** 2 / M
        print("  %-4d %-9s  %.4e          %.4e          %.4e" % (d, label, float(b), gam(1.0) * th ** 2, float(a2)))

print("\n(B) width threshold: a = 1/n (as in the report) vs a = 1/d, c = 1, lambda = 1, event worst case")
print("  d    N0(a=1/n)=72dn^3ln2M+2   bound          N0(a=1/d)=72d^3 n ln2M+2   bound(a=1/d)   ratio")
for d in [33, 35, 40, 60, 100]:
    M, n, Q, G, V = event_vals(d)
    c = 1.0; th = 1 / (18 * d * c + 1)
    E0 = c * (d * FD(d) + 1) + 2
    b1 = max(th * G - E0, 0) ** 2 / (4 * M * V)
    a = mp.mpf(1) / d
    b2 = max(th * (G - n * a) - c * (d * FD(d) + 1), 0) ** 2 / (4 * M * V)
    N1 = 72 * d * n ** 3 * mp.log(2 * M) + 2
    N2 = 72 * d * n * mp.log(2 * M) / a ** 2 + 2
    print("  %-4d %.3e                 %.4e     %.3e                 %.4e     %.3f" % (d, float(N1), float(b1), float(N2), float(b2), float(b2 / b1) if b1 > 0 else float('nan')))

# sanity: the inequality n t [(1-t) a + t a^2/4] <= n t a for a <= 4, t in [0,1]
import itertools
worst = max(t * ((1 - t) * a + t * a * a / 4) - t * a for t in [i / 200 for i in range(201)] for a in [j / 50 for j in range(1, 201)])
print("\nmax over grid of t[(1-t)a + t a^2/4] - t a  (a<=4):", worst)
