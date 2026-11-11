"""Lemma-level checks for depth-two.md (Lemmas 1.2 and 2.1, Theorem 5.1).

(A) Lemma 1.2 with a general budget B: for every f with R(f) <= B,
      sum_x f(x)^2 >= (sqrt Q - sqrt B)_+^2      (tri)
      sum_x f(x)^2 >= (G - B)_+^2 / (4 V)         (cor)
    compared with the exact minimum of sum f^2 subject to R(f) <= B (KKT: f_x = mu k_x ybar_x/(1+mu k_x)).
(B) R(t g) <= (1-t)^2 G + n t a whenever |g - ybar| <= a/2 on T, a <= 4, t in [0,1] (random + adversarial).
(C) bracket: min_t [alpha t^2 + (1-t)^2] = alpha/(1+alpha) at t = 1/(1+alpha)  (sympy).
(D) parity coefficients: c_k = E[prod v sign(sum v - b_k)] equals binom(2m,m)/4^m in magnitude, |c_k| >= 1/sqrt(2k),
    and |c_{k,alpha_d}| * 2 sqrt(2k) >= 1 for 1 <= k <= d <= 80, alpha_d = max{1, log(4 sqrt(2d))/2}.
(E) If R(f) <= B < G then V > 0 (from the correlation identity).
"""
import numpy as np
import sympy as sp
import mpmath as mp
from math import comb

rng = np.random.default_rng(7)

# ---------------- (A)
def sample_stats(d, n):
    M = 2 ** d
    idx = rng.integers(0, M, size=n)
    y = rng.choice([-1.0, 1.0], size=n)
    k = np.bincount(idx, minlength=M).astype(float)
    S = np.bincount(idx, weights=y, minlength=M)
    T = k > 0
    ybar = np.zeros(M); ybar[T] = S[T] / k[T]
    return M, k, S, T, ybar


def min_sumsq(k, ybar, T, B):
    """exact min of sum_T f^2 subject to sum_T k (f - ybar)^2 <= B."""
    G = np.sum(k[T] * ybar[T] ** 2)
    if B >= G:
        return 0.0
    kk, yy = k[T], ybar[T]
    res = lambda mu: np.sum(kk * yy ** 2 / (1 + mu * kk) ** 2)
    lo, hi = 0.0, 1.0
    while res(hi) > B:
        hi *= 2
        if hi > 1e300:
            break
    for _ in range(300):
        mid = (lo + hi) / 2
        if res(mid) > B:
            lo = mid
        else:
            hi = mid
    mu = hi
    f = mu * kk * yy / (1 + mu * kk)
    return np.sum(f ** 2)


viol = 0; ratios_tri = []; ratios_cor = []; trials = 0
for trial in range(3000):
    d = int(rng.integers(3, 11))
    n = int(rng.integers(1, 3 * 2 ** d))
    M, k, S, T, ybar = sample_stats(d, n)
    Q = np.sum(ybar[T] ** 2); G = np.sum(k[T] * ybar[T] ** 2); V = np.sum(S ** 2)
    B = rng.uniform(0, 1.2) * G
    m = min_sumsq(k, ybar, T, B)
    tri = max(np.sqrt(Q) - np.sqrt(B), 0) ** 2
    cor = max(G - B, 0) ** 2 / (4 * V) if V > 0 else 0.0
    if G > B and V == 0:
        viol += 1
    if tri > m * (1 + 1e-9) + 1e-12 or cor > m * (1 + 1e-9) + 1e-12:
        viol += 1
    if m > 0:
        ratios_tri.append(tri / m); ratios_cor.append(cor / m)
    trials += 1
print("(A) Lemma 1.2 with general budget: %d trials, %d violations; max bound/min ratio: tri %.4f, cor %.4f; median cor/min %.3f" % (
    trials, viol, max(ratios_tri), max(ratios_cor), np.median(ratios_cor)))

# ---------------- (B)
worst = -np.inf
for trial in range(20000):
    d = int(rng.integers(2, 9)); n = int(rng.integers(1, 3 * 2 ** d))
    M, k, S, T, ybar = sample_stats(d, n)
    G = np.sum(k[T] * ybar[T] ** 2)
    a = rng.uniform(0, 4) if trial % 2 else rng.uniform(0, 1)
    t = rng.uniform(0, 1) if trial % 3 else rng.choice([0.0, 1.0, rng.uniform(0, 1)])
    # adversarial error: e = -(a/2) sign(ybar) (pushes away from target when t<1) or random
    if trial % 4 == 0:
        e = (a / 2) * np.sign(ybar) * (-1)
    elif trial % 4 == 1:
        e = (a / 2) * np.sign(ybar)
    else:
        e = rng.uniform(-a / 2, a / 2, size=M)
    g = ybar + e
    R = np.sum(k[T] * (t * g[T] - ybar[T]) ** 2)
    worst = max(worst, R - ((1 - t) ** 2 * G + n * t * a))
print("(B) R(tg) - [(1-t)^2 G + n t a] over 20000 trials: max = %.3e (<= 0 expected)" % worst)

# ---------------- (C)
al, t = sp.symbols('alpha t', positive=True)
expr = al * t ** 2 + (1 - t) ** 2
tstar = sp.solve(sp.diff(expr, t), t)[0]
print("(C) argmin t =", sp.simplify(tstar), "; min value =", sp.simplify(expr.subs(t, tstar)),
      "; 1 - 1/(1+alpha) =", sp.simplify(1 - 1 / (1 + al)))

# ---------------- (D)
mp.mp.dps = 50
def c_sign(k):
    b = 0 if k % 2 else 1
    return mp.mpf(sum(comb(k, j) * (-1) ** j * mp.sign(k - 2 * j - b) for j in range(k + 1))) / 2 ** k

def c_tanh(k, al):
    b = 0 if k % 2 else 1
    return sum(comb(k, j) * (-1) ** j * mp.tanh(al * (k - 2 * j - b)) for j in range(k + 1)) / mp.mpf(2) ** k

ok = True
for k in range(1, 41):
    m = (k - 1) // 2 if k % 2 else k // 2
    target = mp.mpf(comb(2 * m, m)) / 4 ** m if k > 1 else mp.mpf(1)
    if abs(abs(c_sign(k)) - target) > mp.mpf(10) ** -40 or abs(c_sign(k)) < 1 / mp.sqrt(2 * k):
        ok = False
print("(D1) |c_k| = binom(2m,m)/4^m and |c_k| >= 1/sqrt(2k) for k <= 40:", ok)
mn = mp.inf; arg = None
for d in range(1, 81):
    ald = max(1, mp.log(4 * mp.sqrt(2 * d)) / 2)
    assert ald <= d + 2
    for k in range(1, d + 1):
        val = abs(c_tanh(k, ald)) * 2 * mp.sqrt(2 * k)
        if val < mn:
            mn, arg = val, (d, k)
print("(D2) min over 1<=k<=d<=80 of |c_{k,alpha_d}| 2 sqrt(2k) = %s at (d,k) = %s (>= 1 expected)" % (mp.nstr(mn, 6), arg))
print("     2 sqrt(2) = %.4f <= 3 ; 1/tanh(1) = %.4f <= 3" % (2 * np.sqrt(2), 1 / np.tanh(1)))
