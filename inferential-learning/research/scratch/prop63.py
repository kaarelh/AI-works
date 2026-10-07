import numpy as np
from scipy.optimize import brentq
def G(r, phi, a=1.0):
    """E/I0 (alpha-free) at floor point (r, phi) relative to anti-sun azimuth; returns (G, s); None if not in image"""
    phi = np.mod(phi, 2*np.pi)
    def F(psi):
        u = np.sqrt(r**2 - a**2*np.cos(psi/2)**2); return psi + np.arctan2(a*np.cos(psi/2), u) - phi
    if F(1e-13) > 0 or F(2*np.pi-1e-13) < 0: return 0.0, np.inf
    psi = brentq(F, 1e-13, 2*np.pi-1e-13, xtol=1e-14)
    c = np.sin(psi/2); u = np.sqrt(r**2 - a**2*np.cos(psi/2)**2); s = u - a*c
    return a*c/(2*s + a*c), s
def lohi(eps, sig):
    m = np.arcsin(eps)/2; return 1 - m/sig, (1 + m/sig)/(np.sqrt(1-eps**2) - eps/2)
rng = np.random.default_rng(1)
viol = tested = 0; worst = 0
for trial in range(1500):
    ds = rng.choice([4.65e-3, 0.05, 0.15, 0.3])
    amin = np.radians(rng.uniform(ds*180/np.pi + 1, 70)); amax = np.radians(rng.uniform(np.degrees(amin), 89.9 - np.degrees(ds)))
    Delta = np.arcsin(np.sin(ds)/np.sin(amin))
    Lr = rng.uniform(5, 200)                        # L/a
    rmax = Lr*np.tan(amin - ds)
    if rmax < 1.2: continue
    r = rng.uniform(1.12, rmax); eps = 1/r
    if eps >= 2/np.sqrt(5): continue
    m = np.arcsin(eps)/2
    if m + Delta/2 >= 1: continue
    sig = rng.uniform(m + Delta/2, 1)
    if not sig - Delta/2 > m: continue
    alpha = rng.uniform(amin, amax)
    phi = 2*np.arcsin(sig) if rng.random() < .5 else 2*np.pi - 2*np.arcsin(sig)
    # sample sun disc: n points, limb darkening optional
    n = 400; rho = ds*np.sqrt(rng.uniform(0, 1, n)); chi = rng.uniform(0, 2*np.pi, n)
    ld = rng.random() < 0.5
    rad = (1 - 0.6*(1 - np.sqrt(np.clip(1 - (rho/ds)**2, 0, 1)))) if ld else np.ones(n)
    # direction toward sun: center at zenith alpha, azimuth 0; offset by rho in direction chi
    c0 = np.array([np.sin(alpha), 0, np.cos(alpha)])
    e1 = np.array([np.cos(alpha), 0, -np.sin(alpha)]); e2 = np.array([0, 1, 0])
    dirs = np.cos(rho)[:, None]*c0 + np.sin(rho)[:, None]*(np.cos(chi)[:, None]*e1 + np.sin(chi)[:, None]*e2)
    ad = np.arccos(dirs[:, 2]); bd = np.arctan2(dirs[:, 1], dirs[:, 0])
    assert np.all(np.abs(bd) <= Delta + 1e-12)
    w = rad*np.cos(ad)
    num = 0.0
    for wi, adi, bdi in zip(w, ad, bd):
        g, s = G(r, phi - bdi)
        lit = s <= Lr*np.tan(adi)
        num += wi*g*lit
    Esun_over_I0 = num/np.sum(w)
    E0_over_I0 = 0.5*sig/r
    ratio = Esun_over_I0/E0_over_I0
    lo, hi = lohi(eps, sig - Delta/2)
    LB = (1 - Delta/(2*sig))*lo; UB = (1 + Delta/(2*sig))*hi
    tested += 1
    if not (LB - 1e-10 <= ratio <= UB + 1e-10): viol += 1; print('VIOL', ds, np.degrees(amin), r, sig, ratio, LB, UB)
    worst = max(worst, (ratio - LB)/(UB - LB) if ratio > (LB+UB)/2 else 0)
print('tested', tested, 'violations', viol)
