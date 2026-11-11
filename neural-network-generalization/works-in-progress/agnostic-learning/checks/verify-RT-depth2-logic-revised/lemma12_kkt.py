"""Lemma 1.2 (a), (b) against the exact constrained minimum
     m(B) = min { sum_x f(x)^2 : R(f) = sum_{x in T} k_x (f(x) - ybar_x)^2 <= B }.
The minimiser vanishes off T; on T, KKT gives f_x = mu k_x ybar_x / (1 + mu k_x) with mu >= 0 chosen so the
constraint is tight (if B < G), and m(B) = 0 if B >= G.  Checks (a): m(B) >= (sqrt Q - sqrt B)_+^2 and
(b): m(B) >= (G - B)_+^2 / (4 V).  Also the identity (1.1) and R(clip f) <= R(f) on random f.
"""
import numpy as np

rng = np.random.default_rng(3)


def exact_min(k, yb, B):
    G = np.sum(k * yb ** 2)
    if B >= G:
        return 0.0
    def R(mu):
        f = mu * k * yb / (1 + mu * k)
        return np.sum(k * (f - yb) ** 2)
    lo, hi = 0.0, 1.0
    while R(hi) > B:
        hi *= 2
        if hi > 1e300:
            break
    for _ in range(300):
        mid = 0.5 * (lo + hi)
        if R(mid) > B:
            lo = mid
        else:
            hi = mid
    f = hi * k * yb / (1 + hi * k)
    return np.sum(f ** 2)


viol_a = viol_b = viol_id = viol_clip = 0
ratios_b = []
for trial in range(4000):
    M = int(rng.integers(4, 200)); n = int(rng.integers(1, 3 * M))
    idx = rng.integers(0, M, size=n)
    y = rng.choice([-1.0, 1.0], size=n) if trial % 2 == 0 else rng.uniform(-1, 1, size=n)
    k = np.bincount(idx, minlength=M).astype(float)
    S = np.bincount(idx, weights=y, minlength=M)
    T = k > 0
    yb = S[T] / k[T]; kT = k[T]
    Q = np.sum(yb ** 2); G = np.sum(kT * yb ** 2); V = np.sum(S ** 2)
    W = np.sum((y - (S / np.maximum(k, 1))[idx]) ** 2)
    B = G * rng.uniform(0, 1.2)
    m = exact_min(kT, yb, B)
    lb_a = max(np.sqrt(Q) - np.sqrt(B), 0) ** 2
    lb_b = (max(G - B, 0) ** 2 / (4 * V)) if V > 0 else 0.0
    if m < lb_a - 1e-9 * (1 + lb_a):
        viol_a += 1
    if m < lb_b - 1e-9 * (1 + lb_b):
        viol_b += 1
    if lb_b > 0:
        ratios_b.append(lb_b / m)
    f = rng.normal(scale=2.0, size=M)
    lhs = np.sum((f[idx] - y) ** 2)
    Rf = np.sum(kT * (f[T] - yb) ** 2)
    if not np.isclose(lhs, Rf + W):
        viol_id += 1
    fc = np.clip(f, -1, 1)
    if np.sum(kT * (fc[T] - yb) ** 2) > Rf + 1e-12:
        viol_clip += 1
print("violations: (a) %d, (b) %d, identity (1.1) %d, clipping %d" % (viol_a, viol_b, viol_id, viol_clip))
print("bound (b)/exact minimum: median %.3f, max %.3f" % (np.median(ratios_b), np.max(ratios_b)))
