"""Independent recomputation (referee r1, computation lens) of the constants of RT-depth2.fixed.md section 1.3/4:
beta(lambda), gamma(lambda), their maxima, inequality (1.0) 4 gamma <= beta < 1 - e^{-lambda},
Gamma_lambda(nu) table, branch crossing, vanishing point, and Lemma 1.3's Poisson comparison
|beta_d - beta(lambda)|, |p_d - (1-e^-lambda)| <= (lambda'+1)/M against exact binomial values."""
import mpmath as mp
mp.mp.dps = 50

def beta_series(l):
    l = mp.mpf(l)
    return mp.e**(-l) * mp.nsum(lambda k: l**k / (k * mp.factorial(k)), [1, mp.inf])

def beta_ei(l):
    l = mp.mpf(l)
    return mp.e**(-l) * (mp.ei(l) - mp.euler - mp.log(l))

def gam(l):
    l = mp.mpf(l)
    return (1 - mp.e**(-l))**2 / (4 * l)

print("beta(1): series %s  Ei-form %s" % (mp.nstr(beta_series(1), 12), mp.nstr(beta_ei(1), 12)))
print("gamma(1) = %s" % mp.nstr(gam(1), 10))
# maxima by solving derivative = 0 (golden-section style independent of findroot on derivative)
def argmax(f, a, b):
    gr = (mp.sqrt(5) - 1) / 2
    for _ in range(200):
        c = b - gr * (b - a); d = a + gr * (b - a)
        if f(c) > f(d): b = d
        else: a = c
    return (a + b) / 2
lb = argmax(beta_ei, 0.5, 3); lg = argmax(gam, 0.5, 3)
print("argmax beta = %s, max beta = %s" % (mp.nstr(lb, 8), mp.nstr(beta_ei(lb), 8)))
print("argmax gamma = %s, max gamma = %s; e^l - 1 - 2l at argmax = %s" % (mp.nstr(lg, 8), mp.nstr(gam(lg), 8), mp.nstr(mp.e**lg - 1 - 2*lg, 5)))

# (1.0) on a log grid lambda in [1e-4, 60]
worst_left = mp.inf; worst_right = mp.inf
for i in range(0, 1201):
    l = mp.mpf(10) ** (-4 + i * (mp.log10(60) + 4) / 1200)
    b = beta_ei(l) if l > mp.mpf('1e-3') else beta_series(l)
    worst_left = min(worst_left, b / (4 * gam(l)))
    worst_right = min(worst_right, (1 - mp.e**(-l)) - b)
print("(1.0): min beta/(4 gamma) over grid = %s (>=1 needed); min (1-e^-l) - beta = %s (>0 needed)" % (mp.nstr(worst_left, 8), mp.nstr(worst_right, 6)))

# Gamma table
def Gamma(l, nu):
    l = mp.mpf(l); nu = mp.mpf(nu)
    b1 = gam(l) / (18 * nu + 1)**2
    inner = (1 - mp.e**(-l)) * 18 * nu / (18 * nu + 1)
    b2 = max(mp.sqrt(beta_ei(l)) - mp.sqrt(inner), 0)**2
    return b1, b2
print("\nGamma_1(nu):")
for nu in [0, mp.mpf('0.001'), mp.mpf('0.01'), mp.mpf('0.05'), mp.mpf(1)/18, mp.mpf('0.1'), 1]:
    b1, b2 = Gamma(1, nu)
    print("  nu=%-10s cor %.6f tri %.6f Gamma %.6f" % (mp.nstr(nu, 5), float(b1), float(b2), float(max(b1, b2))))
lo, hi = mp.mpf('0.01'), mp.mpf('0.1')
for _ in range(200):
    mid = (lo + hi) / 2
    if Gamma(1, mid)[0] - Gamma(1, mid)[1] < 0: lo = mid
    else: hi = mid
nux = (lo + hi) / 2
print("  crossing nu = %s" % mp.nstr(nux, 6))
r = beta_ei(1) / (1 - mp.e**-1)
print("  tri-branch zero at nu = %s" % mp.nstr(r / (18 * (1 - r)), 6))
# monotone check
vals = [max(Gamma(1, mp.mpf(i) / 2000)) for i in range(0, 4001)]
print("  Gamma_1 nonincreasing on [0,2] grid:", all(vals[i] >= vals[i + 1] - mp.mpf(10)**-30 for i in range(len(vals) - 1)))

# Lemma 1.3 Poisson comparison, exact binomial for d=2..24, lambda in {0.5,1,1.5,3}
print("\nLe Cam check: max over d of |beta_d - beta(l)| * M/(l'+1) and |p_d - (1-e^-l)| * M/(l'+1) (<=1 needed)")
def binom_stats(d, lam):
    M = mp.mpf(2)**d; n = mp.ceil(lam * M); p = 1 / M
    pmf = mp.e**(n * mp.log1p(-p)); p0 = pmf; s = mp.mpf(0); k = 0
    while True:
        k += 1
        pmf = pmf * (n - k + 1) / k * p / (1 - p)
        s += pmf / k
        if (pmf < mp.mpf(10)**-45 and k > 5) or k >= n: break
    return M, n, s, 1 - p0
for lam in [0.5, 1, 1.5, 3]:
    wb = 0; wp = 0
    for d in range(2, 25):
        M, n, bd, pd = binom_stats(d, mp.mpf(lam))
        lp = n / M
        wb = max(wb, abs(bd - beta_ei(lam)) * M / (lp + 1)); wp = max(wp, abs(pd - (1 - mp.e**(-mp.mpf(lam)))) * M / (lp + 1))
    print("  lambda=%.1f: %.4f  %.4f" % (lam, float(wb), float(wp)))
