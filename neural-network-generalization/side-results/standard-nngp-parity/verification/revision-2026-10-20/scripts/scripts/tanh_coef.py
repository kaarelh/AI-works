# Check: tanh first-layer dual coefficients c_m(sigma^2) = sigma^{2m} I_m^2/(m! v),
# normalization sum c_m = 1, two-step regularity c_{m+2} >= gamma c_m with
# gamma = 1/(6(1+pi/(2 sigma))^4), and the sharper bound X_m^4/((m+1)(m+2)).
import mpmath as mp
mp.mp.dps = 40
def I(m, s):
    def f(w):
        if w == 0: return mp.mpf(0) if m > 1 else 2/mp.pi
        return mp.e**(m*mp.log(w) - s**2*w**2/2 - mp.log(mp.sinh(mp.pi*w/2)))
    # peak of integrand: roughly where m/w = s^2 w + pi/2
    a = mp.pi/2
    pk = (-a + mp.sqrt(a*a + 4*s*s*m))/(2*s*s)
    pk = max(pk, mp.mpf('0.5'))
    wid = 1/s
    pts = [mp.mpf(0)] + [max(mp.mpf(0), pk + k*wid) for k in range(-12, 13, 2) if pk + k*wid > 0] + [pk + 40*wid]
    pts = sorted(set(pts))
    tot = mp.mpf(0)
    for lo, hi in zip(pts[:-1], pts[1:]):
        tot += mp.quad(f, [lo, hi], method='gauss-legendre')
    return tot
def v(s):
    g = lambda t: mp.tanh(s*t)**2*mp.e**(-t**2/2)/mp.sqrt(2*mp.pi)
    return mp.quad(g, [-12, -5, 0, 5, 12])
for s in [0.3, 0.5, 1.0, 2.0, 3.0]:
    s = mp.mpf(s)
    vv = v(s)
    M = 201
    c = {}
    for m in range(1, M+3, 2):
        c[m] = s**(2*m)*I(m, s)**2/(mp.factorial(m)*vv)
    tot = sum(c.values())
    a = mp.pi/(2*s)
    gam = 1/(6*(1+a)**4)
    minratio = min(c[m+2]/c[m] for m in range(1, M+1, 2))
    argmin = min(range(1, M+1, 2), key=lambda m: c[m+2]/c[m])
    viol = 0; viol2 = 0
    for m in range(1, M+1, 2):
        X = (mp.sqrt(a**2+4*m)-a)/2
        g = X**4/((m+1)*(m+2))
        if c[m+2]/c[m] < g*(1-mp.mpf(10)**-20): viol += 1
        if c[m+2]/c[m] < gam: viol2 += 1
    e1 = mp.quad(lambda t: mp.sech(s*t)**2*mp.e**(-t**2/2)/mp.sqrt(2*mp.pi), [-12,0,12])
    c1alt = s**2*e1**2/vv
    print(f"sigma={float(s):.2f} v={float(vv):.6f} sum_(m<={M+2}) c_m={float(tot):.12f} c1={float(c[1]):.6f} c1(alt)={float(c1alt):.6f} "
          f"min c(m+2)/c(m)={float(minratio):.5f} at m={argmin}; gamma_bound={float(gam):.3e}; viol(sharp)={viol} viol(gamma)={viol2}; "
          f"c_{M+2}/c_{M}={float(c[M+2]/c[M]):.4f}")
