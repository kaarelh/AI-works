"""c1_kepler_fit.py -- how true are Kepler's laws, and where do they fail?

Scout P (philosophy), running example of notes.md section 2.

What it computes
----------------
"Real" positions come from ERFA's eraPlan94 (Simon et al. 1994 analytical
planetary theory: heliocentric positions of the major planets, valid 1000-3000
AD, quoted max error vs JPL DE102 over 1800-2050: Jupiter 71", Saturn 81" in
longitude) and eraMoon98 (Meeus' lunar theory; quoted worst-case error vs
ELP/MPP02 over 1950-2100: 18.3"), via pyerfa.  Neither contains any fitting to
Kepler's laws, so they are honest stand-ins for observational data.

For each body and time window W centred at J2000.0 we fit one fixed Kepler
orbit (laws K1+K2: a fixed ellipse with the central body at a focus, traversed
by Kepler's equation) by least squares, and report the largest and the RMS
angular separation between the fitted and the "real" heliocentric (for the
Moon: geocentric) direction, and the largest relative radius error.  The
largest separation of the least-squares fit is an upper bound on the smallest
tolerance eps at which "Kepler + this body's elements" is compatible with every
datum "the direction of the body at time t lies within eps of v_t"; the RMS is
(up to the mismatch between 3-D and angular residuals) a lower bound on it.

Variants of the fit (planets only):
  free_n   : 7 parameters (a, e, i, Omega, omega, M0, n): laws K1 + K2 only.
  K3_gauss : n = k * a^(-3/2), k the Gaussian constant: K1 + K2 + K3 with one
             constant for all planets (Kepler's third law as Kepler stated it).
  K3_newton: n = k * sqrt(1 + m/M) * a^(-3/2): the two-body Newtonian
             correction of K3, with plan94's own planetary masses.
  prec     : free_n plus a uniform rotation of the line of apsides
             (d omega/dt): the first correction a Newtonian treatment adds for
             Mercury.
  accel    : free_n plus a quadratic term c*t^2 in the mean anomaly (an
             empirical "secular acceleration", the form of the pre-Laplace
             correction for Jupiter and Saturn); Jupiter and Saturn only.
  sinus    : free_n plus a sinusoid A sin(w t) + B cos(w t) in the mean
             anomaly with free period (the form of Laplace's great-inequality
             term); Jupiter and Saturn, windows >= 300 yr.

It also reports q = n^2 a^3 / k^2 from the free_n fits ("Kepler's constant",
in units where K3 with the Gaussian constant gives q = 1), to compare with the
Newtonian two-body value 1 + m/M, and the period of the oscillation left in
Saturn's longitude over 1000-3000 AD (the great inequality).

Requirements: numpy, scipy, pyerfa (tested: numpy 2.4.6, scipy 1.17.1,
pyerfa 2.0.1.5).  Seed 20261015 (random sample times).
Run:  python c1_kepler_fit.py > c1_kepler_fit.out
"""
import sys
import numpy as np
import erfa
import scipy
from scipy.optimize import least_squares

SEED = 20261015
RNG = np.random.default_rng(SEED)

GK = 0.017202098950          # Gaussian gravitational constant (plan94.c, GK)
# plan94.c "Planetary inverse masses" (Sun mass / planet mass), used by the
# theory itself; read from liberfa/erfa/src/plan94.c in the pyerfa 2.0.1.5 sdist.
AMAS = {1: 6023600.0, 2: 408523.5, 3: 328900.5, 4: 3098710.0,
        5: 1047.355, 6: 3498.5, 7: 22869.0, 8: 19314.0}
NAMES = {1: "Mercury", 2: "Venus", 3: "EMB", 4: "Mars", 5: "Jupiter",
         6: "Saturn", 7: "Uranus", 8: "Neptune"}
EPS0 = np.deg2rad(84381.448 / 3600.0)   # obliquity of J2000 (IAU 1976)
JD2000 = 2451545.0
YEAR = 365.25
ARCMIN = np.pi / (180 * 60)


def eq_to_ecl(p):
    c, s = np.cos(EPS0), np.sin(EPS0)
    x, y, z = p[..., 0], p[..., 1], p[..., 2]
    return np.stack([x, c * y + s * z, -s * y + c * z], axis=-1)


def planet_pv(np_, t):
    """heliocentric ecliptic-J2000 position/velocity, t = days from J2000."""
    pv = erfa.plan94(JD2000 + np.zeros_like(t), t, np_)
    return eq_to_ecl(pv["p"]), eq_to_ecl(pv["v"])


def moon_pv(t):
    pv = erfa.moon98(JD2000 + np.zeros_like(t), t)
    return eq_to_ecl(pv["p"]), eq_to_ecl(pv["v"])


def osculating(r, v, mu):
    """classical elements (a, e, i, Om, om, M) from one state vector."""
    h = np.cross(r, v)
    rn, vn = np.linalg.norm(r), np.linalg.norm(v)
    a = 1.0 / (2.0 / rn - vn ** 2 / mu)
    evec = np.cross(v, h) / mu - r / rn
    e = np.linalg.norm(evec)
    i = np.arccos(h[2] / np.linalg.norm(h))
    nvec = np.cross([0.0, 0.0, 1.0], h)
    Om = np.arctan2(nvec[1], nvec[0])
    om = np.arctan2(np.dot(np.cross(nvec, evec), h) / np.linalg.norm(h),
                    np.dot(nvec, evec))
    nu = np.arctan2(np.dot(np.cross(evec, r), h) / np.linalg.norm(h),
                    np.dot(evec, r))
    E = 2 * np.arctan2(np.sqrt(1 - e) * np.sin(nu / 2), np.sqrt(1 + e) * np.cos(nu / 2))
    M = E - e * np.sin(E)
    return a, e, i, Om, om, M


def kepler_xyz(a, e, i, Om, om, M):
    E = M.copy()
    for _ in range(50):
        dE = (E - e * np.sin(E) - M) / (1 - e * np.cos(E))
        E -= dE
        if np.max(np.abs(dE)) < 1e-14:
            break
    xp = a * (np.cos(E) - e)
    yp = a * np.sqrt(1 - e * e) * np.sin(E)
    co, so = np.cos(om), np.sin(om)
    cO, sO = np.cos(Om), np.sin(Om)
    ci, si = np.cos(i), np.sin(i)
    x1, y1 = co * xp - so * yp, so * xp + co * yp
    return np.stack([cO * x1 - sO * ci * y1, sO * x1 + cO * ci * y1, si * y1], axis=-1)


def model(params, t, variant, nfix):
    if variant == "free_n":
        a, e, i, Om, om, M0, n = params
        domdt = 0.0
    elif variant == "prec":
        a, e, i, Om, om, M0, n, domdt = params
    elif variant == "accel":
        a, e, i, Om, om, M0, n, c2 = params
        return kepler_xyz(a, e, i, Om, om, M0 + n * t + c2 * t * t)
    elif variant == "sinus":
        a, e, i, Om, om, M0, n, A, B, w = params
        return kepler_xyz(a, e, i, Om, om, M0 + n * t + A * np.sin(w * t) + B * np.cos(w * t))
    else:
        a, e, i, Om, om, M0 = params
        n = nfix(a)
        domdt = 0.0
    return kepler_xyz(a, e, i, Om, om + domdt * t, M0 + n * t)


def angsep(p, q):
    c = np.linalg.norm(np.cross(p, q), axis=-1)
    d = np.sum(p * q, axis=-1)
    return np.arctan2(c, d)


def fit(t, rdata, x0, variant, nfix=None):
    rn = np.linalg.norm(rdata, axis=-1)[:, None]

    def res(p):
        return ((model(p, t, variant, nfix) - rdata) / rn).ravel()

    lo = [0.0, 0.0, -np.inf, -np.inf, -np.inf, -np.inf]
    hi = [np.inf, 0.99, np.inf, np.inf, np.inf, np.inf]
    nextra = {"free_n": 1, "prec": 2, "accel": 2, "sinus": 4}.get(variant, 0)
    lo += [-np.inf] * nextra
    hi += [np.inf] * nextra
    x0 = np.clip(np.asarray(x0, float), np.array(lo) + 1e-12, np.array(hi) - 1e-12)
    sol = least_squares(res, x0, bounds=(lo, hi), method="trf",
                        x_scale="jac", xtol=1e-15, ftol=1e-15, gtol=1e-15, max_nfev=4000)
    rm = model(sol.x, t, variant, nfix)
    sep = angsep(rm, rdata)
    drr = np.abs(np.linalg.norm(rm, axis=-1) - rn[:, 0]) / rn[:, 0]
    return sol.x, sep.max() / ARCMIN, np.sqrt(np.mean(sep ** 2)) / ARCMIN, drr.max()


def sample_times(W_days, period_days, nmax=20000, nmin=3000):
    n = int(min(nmax, max(nmin, 60 * W_days / period_days)))
    return np.sort(RNG.uniform(-W_days / 2, W_days / 2, n))


def main():
    print("# c1_kepler_fit.py  seed=%d  numpy %s  scipy %s  pyerfa %s" %
          (SEED, np.__version__, scipy.__version__, erfa.__version__))
    print("# data: ERFA plan94 (heliocentric planets) and moon98 (geocentric Moon), ecliptic J2000")
    print("# windows centred on J2000.0; sep = angular separation fit vs data (arcmin)")
    print()
    windows_yr = [12, 30, 100, 300, 1000, 2000]
    results = {}
    for np_ in (1, 4, 5, 6):
        name = NAMES[np_]
        mu = GK ** 2 * (1 + 1 / AMAS[np_])
        r0, v0 = planet_pv(np_, np.array([0.0]))
        a, e, i, Om, om, M = osculating(r0[0], v0[0], mu)
        n0 = np.sqrt(mu / a ** 3)
        P_days = 2 * np.pi / n0
        print("## %s  (1/mass = %.1f; osculating a=%.6f AU, e=%.5f, P=%.3f d at J2000)"
              % (name, AMAS[np_], a, e, P_days))
        print("%-6s %-9s %12s %12s %12s %14s" % ("W(yr)", "variant", "max sep'", "rms sep'",
                                                  "max dr/r", "q=n^2a^3/k^2"))
        x_free = [a, e, i, Om, om, M, n0]
        x_k3 = [a, e, i, Om, om, M]
        for W in windows_yr:
            Wd = W * YEAR
            t = sample_times(Wd, P_days)
            rdata, _ = planet_pv(np_, t)
            xf, mx, rms, drr = fit(t, rdata, x_free, "free_n")
            x_free = xf
            q = xf[6] ** 2 * xf[0] ** 3 / GK ** 2
            results[(name, W, "free_n")] = (mx, rms, drr, q)
            print("%-6d %-9s %12.3f %12.3f %12.2e %14.8f" % (W, "free_n", mx, rms, drr, q))
            for var, nfix in (("K3_gauss", lambda A: GK * A ** -1.5),
                              ("K3_newton", lambda A, m=AMAS[np_]: GK * np.sqrt(1 + 1 / m) * A ** -1.5)):
                xk, mx2, rms2, drr2 = fit(t, rdata, xf[:6], var, nfix)
                results[(name, W, var)] = (mx2, rms2, drr2, None)
                print("%-6d %-9s %12.3f %12.3f %12.2e %14s" % (W, var, mx2, rms2, drr2, "-"))
            if np_ in (5, 6):
                xa, mxa, rmsa, drra = fit(t, rdata, list(xf) + [0.0], "accel")
                results[(name, W, "accel")] = (mxa, rmsa, drra, xa[7])
                print("%-6d %-9s %12.3f %12.3f %12.2e" % (W, "accel", mxa, rmsa, drra))
                if W >= 300:
                    w0 = 2 * np.pi / (900 * YEAR)
                    xs, mxs, rmss, drrs = fit(t, rdata, list(xf) + [1e-3, 1e-3, w0], "sinus")
                    results[(name, W, "sinus")] = (mxs, rmss, drrs, 2 * np.pi / xs[9] / YEAR)
                    print("%-6d %-9s %12.3f %12.3f %12.2e   period=%.0f yr, amplitude=%.1f arcmin"
                          % (W, "sinus", mxs, rmss, drrs, 2 * np.pi / abs(xs[9]) / YEAR,
                             np.hypot(xs[7], xs[8]) / ARCMIN))
            if np_ == 1:
                xp, mx3, rms3, drr3 = fit(t, rdata, list(xf) + [0.0], "prec")
                results[(name, W, "prec")] = (mx3, rms3, drr3, xp[7])
                print("%-6d %-9s %12.3f %12.3f %12.2e   d(om)/dt=%.1f\"/century"
                      % (W, "prec", mx3, rms3, drr3, np.rad2deg(xp[7]) * 3600 * 36525))
        print("   Newtonian two-body K3 value 1 + m/M = %.8f" % (1 + 1 / AMAS[np_]))
        print()

    # ---- the great inequality: Saturn's and Jupiter's longitude residual, 1000-3000 AD
    print("## Great inequality: longitude residual of the free_n fit over 2000 yr, sinusoid fit")
    for np_ in (5, 6):
        name = NAMES[np_]
        mu = GK ** 2 * (1 + 1 / AMAS[np_])
        Wd = 2000 * YEAR
        t = np.linspace(-Wd / 2, Wd / 2, 20001)
        rdata, _ = planet_pv(np_, t)
        r0, v0 = planet_pv(np_, np.array([0.0]))
        el = osculating(r0[0], v0[0], mu)
        x0 = list(el) + [np.sqrt(mu / el[0] ** 3)]
        xf, mx, rms, drr = fit(t, rdata, x0, "free_n")
        rm = model(xf, t, "free_n", None)
        lon_d = np.arctan2(rdata[:, 1], rdata[:, 0])
        lon_m = np.arctan2(rm[:, 1], rm[:, 0])
        dl = np.angle(np.exp(1j * (lon_d - lon_m))) / ARCMIN
        best = None
        for Pyr in np.arange(600.0, 1300.0, 1.0):
            w = 2 * np.pi / (Pyr * YEAR)
            A = np.stack([np.ones_like(t), np.cos(w * t), np.sin(w * t)], axis=1)
            c, *_ = np.linalg.lstsq(A, dl, rcond=None)
            r = np.sum((A @ c - dl) ** 2)
            if best is None or r < best[0]:
                best = (r, Pyr, np.hypot(c[1], c[2]))
        resid_rms = np.sqrt(best[0] / len(t))
        print("  %-8s best period %.0f yr, amplitude %.1f arcmin, rms left after sinusoid %.2f arcmin, "
              "max |dlon| %.1f arcmin" % (name, best[1], best[2], resid_rms, np.max(np.abs(dl))))
    print()

    # ---- the Moon: Kepler's laws for the Earth-Moon system
    print("## Moon (geocentric, moon98): one fixed Kepler orbit, free n")
    print("%-10s %12s %12s %12s" % ("window", "max sep(deg)", "rms sep(deg)", "max dr/r"))
    r0, v0 = moon_pv(np.array([0.0]))
    mu_em = GK ** 2 / 328900.5 * 1.0  # rough G(M_E + M_moon) in AU^3/d^2 for the initial guess only
    a, e, i, Om, om, M = osculating(r0[0], v0[0], mu_em)
    x = [a, e, i, Om, om, M, np.sqrt(mu_em / a ** 3)]
    for label, Wd in (("1 month", 27.32), ("1 year", YEAR), ("10 years", 10 * YEAR), ("18.6 yr", 18.6 * YEAR)):
        t = np.sort(RNG.uniform(-Wd / 2, Wd / 2, int(min(20000, max(3000, 60 * Wd / 27.32)))))
        rdata, _ = moon_pv(t)
        xf, mx, rms, drr = fit(t, rdata, x, "free_n")
        x = xf
        print("%-10s %12.3f %12.3f %12.2e" % (label, mx / 60, rms / 60, drr))
    print()
    print("# done")


if __name__ == "__main__":
    main()
