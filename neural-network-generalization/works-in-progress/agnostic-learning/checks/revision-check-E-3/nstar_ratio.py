from math import log, sqrt
def Nstar(d, s, a, H):
    Sb = 3**((H - 1) / 2) + 0.25; Amax = 2 * sqrt(2 * d * s) * 3**((H - 1) / 2)
    R = max(Amax**(1 / H), sqrt(128 * H * H * Sb**3 / a), 2.0)
    u0 = min(a / (16 * R**(H - 1)), a / (32 * H * H * Sb)); ld = (d + 1) * log(2) + log(8 * H)
    mf = int(128 * log(2) * Amax**2 * (d + 1) / a**2) + 1
    return max(mf, 256 * Amax**2 * ld / a**2, 512 * H * H * Sb**2 * ld / a**2, 2 * ld / u0**2)
for H in [2, 3, 4]:
    for d in [1, 10, 1e3, 1e6]:
        mx = 0
        for s in [1e-6, 1, 1e3, 1e9, 1e18, 1e30]:
            for a in [1, 1e-3, 1e-9, 1e-20]:
                r = Nstar(d, s, a, H) / (d*d*s/a**2 + d*(d*s)**((H-1)/H)/a**2 + d*a**(-(H+1)))
                mx = max(mx, r)
        print(f"H={H} d={d:g}: max ratio over s,a = {mx:.3g}")
