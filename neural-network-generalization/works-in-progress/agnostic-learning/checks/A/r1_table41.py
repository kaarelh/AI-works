"""Table 4.1 and Remark 4.7 of research-notes/A-tight-conditioning-fails.md (written for revision 1, updated in the
second referee round): the certified excess of Theorem 4.4, eq. (4.3), optimised over the accuracy a.

Certified excess, with delta = 0.01, t = 1:
  e(a) = ( sqrt( (beta_n - sqrt(2 lam log(1/delta)/M))_+ ) - sqrt(eps(a)) )_+^2,
  eps(a) = c (K_mem(a) + t)/M + lam a^2,
  K_mem(a) = d(d+1) alpha_d^2 + (H+1) max{(8 d s)^{1/H}, 9/(2a)},  s = min(n, M),
  N_0(a) = floor(64 log 2 d (d+1) s / a^2) + 1.
e(a) depends on a only through eps(a) and is nonincreasing in eps, so the optimal a minimises eps(a). With
  a_kink = 9 / (2 (8 d s)^{1/H})        (where K_mem stops depending on a),
  a_int  = (9 (H+1) c / (4 lam M))^{1/3}  (the stationary point of eps on a < a_kink),
eps is decreasing on (0, min{a_int, a_kink}] and increasing beyond it, so a* = min{a_int, a_kink, 1}.
Revision 1 found a* with a bounded scalar optimiser in log10 a; at (H,d) = (2,60) the values of e near a* differ by
about 1e-17, below double precision, and the optimiser stopped at 2.0e-10 instead of a_kink = 1.91e-10 (second-round
computation report, issue 3). The closed form is used now; the optimiser is kept as a cross-check.

Because e(a) is flat beyond a*, the table also reports the largest a in [a*, 1] with e(a) >= e(a*) - 0.001, and its
N_0 (second-round computation report, issue 1(a)). The last part gives the certified excess at fixed a and finite d
(issue 5), next to its limit (sqrt(beta(lam)) - a sqrt(lam))_+^2.
"""
import math
import numpy as np
from scipy import stats, optimize

def beta_bin(n, M):
    k = np.arange(1, 600)
    return float(np.sum(stats.binom.pmf(k, float(n), 1.0 / M) / k))

def parts(d, H, lam, c, a, t=1.0, delta=0.01):
    M = 2.0 ** d; n = round(lam * M); s = min(n, M)
    alpha = 0.5 * math.log(4 * math.sqrt(2 * d))
    Kmem = d * (d + 1) * alpha ** 2 + (H + 1) * max((8 * d * s) ** (1.0 / H), 9 / (2 * a))
    eps = c * (Kmem + t) / M + (n / M) * a ** 2
    bn = beta_bin(n, M)
    conc = math.sqrt(2 * (n / M) * math.log(1 / delta) / M)
    val = max(0.0, math.sqrt(max(0.0, bn - conc)) - math.sqrt(eps)) ** 2
    N0 = math.floor(64 * math.log(2) * d * (d + 1) * s / a ** 2) + 1
    return val, Kmem, eps, bn, N0

def a_closed(d, H, lam, c):
    M = 2.0 ** d; n = round(lam * M); s = min(n, M)
    a_kink = 9 / (2 * (8 * d * s) ** (1.0 / H))
    a_int = (9 * (H + 1) * c / (4 * (n / M) * M)) ** (1.0 / 3)
    return min(a_int, a_kink, 1.0), a_kink, a_int

def a_optimiser(d, H, lam, c):
    """Revision 1's numerical optimiser (grid in log10 a, then bounded scalar search); kept as a cross-check."""
    grid = np.linspace(-16, 0, 1601)
    vals = [parts(d, H, lam, c, 10 ** g)[0] for g in grid]
    i = int(np.argmax(vals))
    lo, hi = grid[max(i - 1, 0)], grid[min(i + 1, len(grid) - 1)]
    res = optimize.minimize_scalar(lambda g: -parts(d, H, lam, c, 10 ** g)[0],
                                   bounds=(lo, hi), method="bounded", options={"xatol": 1e-10})
    g = res.x if -res.fun >= vals[i] else grid[i]
    return 10 ** g

def best_a(d, H, lam, c):
    a, _, _ = a_closed(d, H, lam, c)
    return a, parts(d, H, lam, c, a)

def largest_a_within(d, H, lam, c, tol=1e-3):
    """Largest a in [a*, 1] with e(a) >= e(a*) - tol (e is nonincreasing in a on [a*, 1]); bisection in log a."""
    a0, (v0, *_ ) = best_a(d, H, lam, c)
    if parts(d, H, lam, c, 1.0)[0] >= v0 - tol:
        return 1.0
    lo, hi = math.log(a0), 0.0
    for _ in range(200):
        mid = (lo + hi) / 2
        if parts(d, H, lam, c, math.exp(mid))[0] >= v0 - tol:
            lo = mid
        else:
            hi = mid
    return math.exp(lo)

rows = [(2, 20), (2, 30), (2, 40), (2, 60), (3, 20), (3, 30), (3, 40), (4, 30)]
print("Table 4.1 (c = 1, t = 1, delta = 0.01; a* = min{a_int, a_kink, 1} separately for each lambda)")
print(f"{'H':>2} {'d':>3} | {'e(lam=1)':>9} {'a*(1)':>9} {'at':>5} {'K_mem(a*(1))':>13} {'N0(a*(1))':>10} | "
      f"{'e(lam=1.5)':>10} {'a*(1.5)':>9} {'N0(a*(1.5))':>11} | {'beta_n(1)':>9} {'beta_n(1.5)':>11}")
for (H, d) in rows:
    a1, (v1, K1, e1, b1, N01) = best_a(d, H, 1.0, 1.0)
    a15, (v15, K15, e15, b15, N015) = best_a(d, H, 1.5, 1.0)
    _, ak, ai = a_closed(d, H, 1.0, 1.0)
    where = "kink" if ak <= ai else "int"
    print(f"{H:>2} {d:>3} | {v1:9.4f} {a1:9.2e} {where:>5} {K1:13.2e} {N01:10.2e} | {v15:10.4f} {a15:9.2e} {N015:11.2e} |"
          f" {b1:9.4f} {b15:11.4f}")

print("\nCross-check against revision 1's numerical optimiser (lambda = 1): e(closed form) - e(optimiser), and the a found")
for (H, d) in rows:
    a1, (v1, *_ ) = best_a(d, H, 1.0, 1.0)
    ao = a_optimiser(d, H, 1.0, 1.0)
    vo = parts(d, H, 1.0, 1.0, ao)[0]
    print(f"  H={H} d={d}: a*={a1:.4e}, optimiser a={ao:.4e}, e difference = {v1 - vo:+.1e}")

print("\nFlatness (lambda = 1): the largest a with e(a) >= e(a*) - 0.001, and its width threshold")
print(f"{'H':>2} {'d':>3} | {'e(a*)':>7} {'a_0.001':>9} {'e(a_0.001)':>10} {'N0(a_0.001)':>12} {'N0/n':>9} | {'N0(a*)/N0(a_0.001)':>18}")
for (H, d) in rows:
    a1, (v1, K1, e1, b1, N01) = best_a(d, H, 1.0, 1.0)
    am = largest_a_within(d, H, 1.0, 1.0)
    vm, Km, em, bm, N0m = parts(d, H, 1.0, 1.0, am)
    n = 2 ** d
    print(f"{H:>2} {d:>3} | {v1:7.4f} {am:9.3g} {vm:10.4f} {N0m:12.4g} {N0m / n:9.4g} | {N01 / N0m:18.4g}")

print("\nDistance to beta_n at d = 40, H = 2:")
for lam in (1.0, 1.5):
    a, (v, K, e, b, N0) = best_a(40, 2, lam, 1.0)
    print(f"  lambda={lam}: beta_n - e = {b - v:.4f}")

print("\nLargest c with certified e >= beta_n/2 at lambda = 1 (bisection in log c, a = a*(c)):")
for (H, d) in [(2, 30), (3, 30), (2, 40), (3, 40)]:
    n = 2 ** d
    def ok(logc):
        a, (v, K, e, b, N0) = best_a(d, H, 1.0, 10 ** logc)
        return v >= b / 2
    lo, hi = 0.0, math.log10(n)
    if not ok(lo):
        print(f"  H={H} d={d}: no c >= 1 works"); continue
    for _ in range(60):
        mid = (lo + hi) / 2
        if ok(mid): lo = mid
        else: hi = mid
    print(f"  H={H} d={d}: c_max = {10 ** lo:.4g};  n^(1-1/H) d^(-1/H) = {n ** (1 - 1 / H) * d ** (-1 / H):.3e}")

print("\nFixed accuracy a (Remark 4.7): limit (sqrt(beta(lam)) - a sqrt(lam))_+^2 as d -> infinity, N0/n at n = 2^d,")
print("and the certified excess (4.3) at finite d (lambda = 1, c = t = 1, delta = 0.01)")
beta1 = 0.48482910699
for a in (0.1, 0.3):
    print(f"  a={a}: limit (sqrt(beta(1)) - a)^2 = {(math.sqrt(beta1) - a) ** 2:.4f}")
    for d in (20, 30, 40):
        M = 2 ** d
        N0 = math.floor(64 * math.log(2) * d * (d + 1) * M / a ** 2) + 1
        print(f"     d={d}: N0/n = {N0 / M:.3g}")
    for H in (2, 3):
        vals = ", ".join(f"d={d}: {parts(d, H, 1.0, 1.0, a)[0]:.6f}" for d in (20, 30, 40, 60))
        print(f"     H={H}: certified e at finite d: {vals}")
