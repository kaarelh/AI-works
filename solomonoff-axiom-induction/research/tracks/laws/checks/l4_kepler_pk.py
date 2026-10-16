"""l4_kepler_pk.py -- residuals of one fixed Kepler ellipse against ERFA's planetary and lunar
theories, and their peakedness pk(e) = eps*/E|e|, per body and window.

Thread `laws` (T3, last item).  Seed 20261016.  Writes l4_kepler_pk.out next to itself and saves
the residual series it uses to l4_residuals.npz (read by l5_kepler_select.py, which does the
selection between honest law, patched exact law and no law).

Data.  ERFA's eraPlan94 (heliocentric planets; Simon et al. analytical theory) and eraMoon98
(geocentric Moon; Meeus), through pyerfa 2.0.1.5, exactly as in scout P's c1_kepler_fit.py, whose
machinery (ecliptic rotation, osculating elements, Kepler solver, 3-D least-squares fit) is copied
below.  pyerfa is imported from a scratch library folder outside the repository (PYTHONPATH).

For each body and window W centred on J2000.0: N_T = 8000 i.i.d. uniform sample times.  The 1-D
quantity is the ecliptic longitude (heliocentric; geocentric for the Moon).  The error of the fixed
Kepler ellipse with elements theta is
    e_theta(t) = wrap(lon_Kepler(t; theta) - lon_true(t))   (arcmin; model minus truth).
Fits (all with 7 free elements a, e, i, Om, om, M0, n):
    F3   scout P's 3-D least squares on normalised positions;
    L2   least squares on (longitude, latitude) residuals;
    L1   soft-L1 (robust) on longitude residuals (+ latitude): aims at a small mean |e|;
    Linf L_p continuation p = 4, 8, 16 on longitude residuals: aims at a small max |e|.
eps* := min over fits of max|e| over the sample (an upper bound on the minimax error of a fixed
ellipse on the window, up to sampling: the sample max is below the true sup on the window);
E|e| := min over fits of mean|e|; pk := eps*/E|e|.  The two minima may come from different fits
on purpose: the honest law states its tolerance for its own (minimax) elements, and the patched
exact law uses its own (mean-optimal) elements.
"""
import sys
import time
import numpy as np
import scipy
from scipy.optimize import least_squares
import erfa

SEED = 20261016
RNG = np.random.default_rng(SEED)
OUT = []


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


# ---------------- scout P's machinery (copied from scouts/philosophy/checks/c1_kepler_fit.py) ------------
GK = 0.017202098950
AMAS = {1: 6023600.0, 2: 408523.5, 3: 328900.5, 4: 3098710.0,
        5: 1047.355, 6: 3498.5, 7: 22869.0, 8: 19314.0}
NAMES = {1: "Mercury", 2: "Venus", 3: "EMB", 4: "Mars", 5: "Jupiter", 6: "Saturn"}
EPS0 = np.deg2rad(84381.448 / 3600.0)
JD2000 = 2451545.0
YEAR = 365.25
ARCMIN = np.pi / (180 * 60)


def eq_to_ecl(p):
    c, s = np.cos(EPS0), np.sin(EPS0)
    x, y, z = p[..., 0], p[..., 1], p[..., 2]
    return np.stack([x, c * y + s * z, -s * y + c * z], axis=-1)


def planet_pv(np_, t):
    pv = erfa.plan94(JD2000 + np.zeros_like(t), t, np_)
    return eq_to_ecl(pv["p"]), eq_to_ecl(pv["v"])


def moon_pv(t):
    pv = erfa.moon98(JD2000 + np.zeros_like(t), t)
    return eq_to_ecl(pv["p"]), eq_to_ecl(pv["v"])


def osculating(r, v, mu):
    h = np.cross(r, v)
    rn, vn = np.linalg.norm(r), np.linalg.norm(v)
    a = 1.0 / (2.0 / rn - vn ** 2 / mu)
    evec = np.cross(v, h) / mu - r / rn
    e = np.linalg.norm(evec)
    i = np.arccos(h[2] / np.linalg.norm(h))
    nvec = np.cross([0.0, 0.0, 1.0], h)
    Om = np.arctan2(nvec[1], nvec[0])
    om = np.arctan2(np.dot(np.cross(nvec, evec), h) / np.linalg.norm(h), np.dot(nvec, evec))
    nu = np.arctan2(np.dot(np.cross(evec, r), h) / np.linalg.norm(h), np.dot(evec, r))
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


def model(p, t):
    a, e, i, Om, om, M0, n = p
    return kepler_xyz(a, e, i, Om, om, M0 + n * t)
# ------------------------------------------------------------------------------------------------------------


LO = np.array([0.0, 0.0, -np.inf, -np.inf, -np.inf, -np.inf, -np.inf])
HI = np.array([np.inf, 0.99, np.inf, np.inf, np.inf, np.inf, np.inf])


def lonlat(p):
    lon = np.arctan2(p[:, 1], p[:, 0])
    lat = np.arctan2(p[:, 2], np.hypot(p[:, 0], p[:, 1]))
    return lon, lat


def wrap(x):
    return np.angle(np.exp(1j * x))


def lon_err(p, t, lon_d):
    lm, _ = lonlat(model(p, t))
    return wrap(lm - lon_d) / ARCMIN  # arcmin, model minus truth


def ls(fun, x0, **kw):
    x0 = np.clip(np.asarray(x0, float), LO + 1e-12, HI - 1e-12)
    return least_squares(fun, x0, bounds=(LO, HI), method="trf", x_scale="jac",
                         xtol=1e-13, ftol=1e-13, gtol=1e-13, max_nfev=3000, **kw).x


def fits(t, rdata, x0):
    rn = np.linalg.norm(rdata, axis=-1)[:, None]
    lon_d, lat_d = lonlat(rdata)

    def r3(p):
        return ((model(p, t) - rdata) / rn).ravel()

    def r2(p):
        lm, bm = lonlat(model(p, t))
        return np.concatenate([wrap(lm - lon_d), bm - lat_d])

    res = {}
    x3 = ls(r3, x0)
    res["F3"] = x3
    x2 = ls(r2, x3)
    res["L2"] = x2
    s = np.sqrt(np.mean(lon_err(x2, t, lon_d) ** 2)) * ARCMIN

    def r1(p):
        lm, bm = lonlat(model(p, t))
        return np.concatenate([wrap(lm - lon_d), 0.3 * (bm - lat_d)])

    x1 = ls(r1, x2, loss="soft_l1", f_scale=0.02 * s)
    res["L1"] = x1
    xp = x2
    for pw in (4, 8, 16):
        def rp(p, pw=pw):
            lm, bm = lonlat(model(p, t))
            d = wrap(lm - lon_d) / s
            return np.concatenate([np.abs(d) ** (pw / 2.0), 0.1 * (bm - lat_d) / s])
        xp = ls(rp, xp)
    res["Linf"] = xp
    return res, lon_d


def main():
    t0 = time.time()
    out("# l4_kepler_pk.py  seed=%d  python %s  numpy %s  scipy %s  pyerfa %s" %
        (SEED, sys.version.split()[0], np.__version__, scipy.__version__, erfa.__version__))
    out("# longitude residuals of one fixed Kepler ellipse (7 elements) against plan94 / moon98; arcmin")
    N_T = 8000
    windows = [12, 30, 100, 300, 1000, 2000]
    series = {}
    rows = []
    out("")
    out("== A. residual statistics per body and window (eps*: min over fits of max|e|; E|e|: min over fits of mean|e|)")
    out("%-8s %6s | %8s %8s %8s %8s | %8s %8s | %7s %7s" % ("body", "W(yr)", "max F3", "max L2", "max L1",
                                                         "max Linf", "eps*", "E|e|", "pk", "pk(L2)"))
    for np_ in (1, 2, 3, 4, 5, 6):
        name = NAMES[np_]
        mu = GK ** 2 * (1 + 1 / AMAS[np_])
        r0, v0 = planet_pv(np_, np.array([0.0]))
        a, e, i, Om, om, M = osculating(r0[0], v0[0], mu)
        x0 = [a, e, i, Om, om, M, np.sqrt(mu / a ** 3)]
        for W in windows:
            Wd = W * YEAR
            t = np.sort(RNG.uniform(-Wd / 2, Wd / 2, N_T))
            rdata, _ = planet_pv(np_, t)
            res, lon_d = fits(t, rdata, x0)
            x0 = res["L2"]
            errs = {k: lon_err(v, t, lon_d) for k, v in res.items()}
            mx = {k: np.max(np.abs(v)) for k, v in errs.items()}
            mn = {k: np.mean(np.abs(v)) for k, v in errs.items()}
            kmax = min(mx, key=mx.get)
            kmean = min(mn, key=mn.get)
            eps_star, Eabs = mx[kmax], mn[kmean]
            pk = eps_star / Eabs
            pkL2 = mx["L2"] / mn["L2"]
            out("%-8s %6d | %8.3f %8.3f %8.3f %8.3f | %8.3f %8.3f | %7.3f %7.3f   (eps* from %s, E|e| from %s)"
                % (name, W, mx["F3"], mx["L2"], mx["L1"], mx["Linf"], eps_star, Eabs, pk, pkL2, kmax, kmean))
            key = "%s_%d" % (name, W)
            series[key + "_t"] = t.astype(np.float32)
            series[key + "_e_mean"] = errs[kmean].astype(np.float32)
            series[key + "_e_max"] = errs[kmax].astype(np.float32)
            rows.append((name, W, Wd, eps_star, Eabs, pk, errs[kmean]))
    # the Moon
    r0, v0 = moon_pv(np.array([0.0]))
    mu_em = GK ** 2 / 328900.5
    a, e, i, Om, om, M = osculating(r0[0], v0[0], mu_em)
    x0 = [a, e, i, Om, om, M, np.sqrt(mu_em / a ** 3)]
    for label, Wd in (("1 month", 27.32), ("1 year", YEAR), ("18.6 yr", 18.6 * YEAR)):
        t = np.sort(RNG.uniform(-Wd / 2, Wd / 2, N_T))
        rdata, _ = moon_pv(t)
        res, lon_d = fits(t, rdata, x0)
        x0 = res["L2"]
        errs = {k: lon_err(v, t, lon_d) for k, v in res.items()}
        mx = {k: np.max(np.abs(v)) for k, v in errs.items()}
        mn = {k: np.mean(np.abs(v)) for k, v in errs.items()}
        kmax = min(mx, key=mx.get)
        kmean = min(mn, key=mn.get)
        eps_star, Eabs = mx[kmax], mn[kmean]
        out("%-8s %6s | %8.2f %8.2f %8.2f %8.2f | %8.2f %8.2f | %7.3f %7.3f   (eps* from %s, E|e| from %s)"
            % ("Moon", label.split()[0] + label.split()[1][0], mx["F3"], mx["L2"], mx["L1"], mx["Linf"],
               eps_star, Eabs, eps_star / Eabs, mx["L2"] / mn["L2"], kmax, kmean))
        key = "Moon_%s" % label.replace(" ", "")
        series[key + "_t"] = t.astype(np.float32)
        series[key + "_e_mean"] = errs[kmean].astype(np.float32)
        series[key + "_e_max"] = errs[kmax].astype(np.float32)
        rows.append(("Moon", label, Wd, eps_star, Eabs, eps_star / Eabs, errs[kmean]))
    np.savez_compressed(__file__.replace("l4_kepler_pk.py", "l4_residuals.npz"), **series)
    out("")
    out("   (saved: l4_residuals.npz, keys <body>_<W>_{t,e_mean,e_max}: sample times in days from J2000,")
    out("    signed longitude errors in arcmin of the fit with the smallest mean |e| and of the fit with the smallest max |e|)")

    out("")
    out("# runtime %.0f s" % (time.time() - t0))
    out("# done")
    with open(__file__.replace(".py", ".out"), "w") as f:
        f.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
