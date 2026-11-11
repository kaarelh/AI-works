"""Independent re-check of depth-two.md section 0.2 'Input dimension' (fixed d, c of order n) and Remark 5.2b numbers.
(1) d in {1,3}: largest constant output a with min_b [d b^2 + a^2/tanh^2 b] + R(a)/c <= 1 (a near-minimizer, since
    min F >= W/c), certified test excess a^2; minimum over 200 samples. Independent RNG and implementation.
(2) C_1 = 2(1+sqrt(1/2))^2 and the inclusion {kappa <= 1/2} in N_1 for c >= C_1 n (worst case over labels/outputs).
(3) Remark 5.2b: worst case of underline Psi_cor on E_d (lambda=1, a=1/d) / (gamma(1) theta_c^2), and log2(1/eps_d)/d,
    in mpmath at high precision for c = 2^sqrt(d), d^ln d.
(4) Bullet 3 of 'Input dimension': excess of every w in N_zeta <= kappa_N(w) <= G/c + zeta; check F(0) = (G+W)/c = n/c.
"""
import math, numpy as np
from scipy.optimize import minimize_scalar, brentq
import mpmath as mp

rng = np.random.default_rng(7)

def cost(a, d):
    # min over b>0 of d b^2 + a^2/tanh(b)^2 (constant network, all neurons equal)
    if a == 0: return 0.0
    f = lambda lb: d*math.exp(2*lb) + a*a/math.tanh(math.exp(lb))**2
    r = minimize_scalar(f, bounds=(-12, 3), method='bounded', options={'xatol':1e-12})
    return r.fun

def largest_a(n, c, d, ys, xs):
    M = 2**d
    k = np.bincount(xs, minlength=M); S = np.bincount(xs, weights=ys, minlength=M)
    seen = k > 0
    G = float(np.sum(S[seen]**2 / k[seen])); tot = float(S.sum())
    best = 0.0
    for sgn in (1.0, -1.0):
        R = lambda a: n*a*a - 2*sgn*a*tot + G     # R(sgn*a) = sum_T k_x (sgn a - ybar_x)^2
        g = lambda a: cost(a, d) + R(a)/c - 1.0
        if g(1e-9) > 0: continue
        hi = 1.0
        while g(hi) < 0 and hi < 10: hi *= 1.5
        if g(hi) < 0: a = hi
        else: a = brentq(g, 1e-9, hi, xtol=1e-12)
        best = max(best, a)
    return best

print("(1) min over 200 samples of certified excess a^2 (constant near-minimizer)")
for d in (1, 3):
    for n in (10**3, 10**4, 10**5):
        for frac in (0.1, 0.25):
            c = frac*n; vals = []
            for _ in range(200):
                xs = rng.integers(0, 2**d, size=n); ys = rng.choice([-1.0, 1.0], size=n)
                vals.append(largest_a(n, c, d, ys, xs)**2)
            print("   d=%d n=%6d c/n=%.2f : min %.4f  median %.4f" % (d, n, frac, min(vals), float(np.median(vals))))

print("\n(2) C_1 = 2(1+sqrt(1/2))^2 = %.5f" % (2*(1+math.sqrt(0.5))**2))
# worst case: kappa <= 1/2 gives |z| <= sqrt(1/2); (z - y)^2 <= (1+sqrt(1/2))^2; F <= 1/2 + n(1+sqrt(1/2))^2/c <= 1 iff c >= C_1 n
n = 1000; c = 2*(1+math.sqrt(0.5))**2*n
print("   F upper bound at c = C_1 n: %.12f (<= 1 = min F + 1 since min F >= 0)" % (0.5 + n*(1+math.sqrt(0.5))**2/c))

print("\n(3) Remark 5.2b ratios (lambda = 1, a = 1/d), worst case of Psi_cor on E_d")
mp.mp.dps = 60
gam = (1-mp.e**-1)**2/4
def psi_cor_ratio(d, c):
    M = mp.mpf(2)**d; n = mp.ceil(M); lam = n/M; h = 2*n**(mp.mpf(2)/3)/M
    p = 1-(1-1/M)**n; a = mp.mpf(1)/d
    th = 1/(18*d*c+1); Fd = 1+(d+1)*(d+2)**2
    num = th*(p-h-lam*a) - c*(d*Fd+1)/M
    val = (num if num > 0 else 0)**2/(4*(lam+h/2))
    return val/(gam*th**2), mp.log(3*(18*d*c+1)**2/gam, 2)/d
for name, cf in (("2^sqrt d", lambda d: mp.mpf(2)**mp.sqrt(d)), ("d^ln d", lambda d: mp.mpf(d)**mp.log(d))):
    for d in (256, 4096):
        r, l = psi_cor_ratio(d, cf(d))
        print("   c=%-9s d=%5d ratio %.6f  log2(1/eps_d)/d %.4f" % (name, d, float(r), float(l)))

print("\n(4) F(0) = n/c = (G+W)/c on random samples")
for _ in range(3):
    d=2; n=50; xs = rng.integers(0, 4, size=n); ys = rng.choice([-1.0,1.0], size=n)
    k = np.bincount(xs, minlength=4); S = np.bincount(xs, weights=ys, minlength=4); seen = k>0
    G = float(np.sum(S[seen]**2/k[seen])); ybar = np.zeros(4); ybar[seen] = S[seen]/k[seen]
    W = float(np.sum((ys - ybar[xs])**2))
    print("   G+W = %.12f, n = %d" % (G+W, n))
