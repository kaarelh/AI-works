"""p4_allfits.py -- re-run the four Kepler fits of laws/checks/l4_kepler_pk.py and keep ALL FOUR longitude
error series per body and window (l4 kept only the minimax and the mean fit).

Track `purpose`, target T4(b).  Seed 20261016 (the same as l4, and the same order of random draws, so the sample
times and the fits are those of l4).  The fitting machinery is copied verbatim from l4_kepler_pk.py (which copied
it from scout P's c1_kepler_fit.py).  pyerfa 2.0.1.5 is imported from a scratch library folder (PYTHONPATH).

Output: p4_allfits.npz with keys <body>_<W>_t (days from J2000) and <body>_<W>_<fit>, fit in {F3, L2, L1, Linf}
(signed longitude errors in arcmin, model minus truth), plus <body>_<W>_params_<fit>; and p4_allfits.out, which
checks that the minimax and mean series agree with l4_residuals.npz.

Restart safety: after each body-window the partial results are saved to p4_allfits.partial.npz; on restart the
random draws are replayed (cheap) and finished windows are skipped, with the next initial guess taken from the
saved L2 parameters, exactly as in an uninterrupted run.
"""
import os
import sys
import time
import numpy as np
import scipy
from scipy.optimize import least_squares
import erfa

SEED = 20261016
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


# ---------------- copied verbatim from laws/checks/l4_kepler_pk.py ------------------------------------------
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
# ------------------------------------------------------------------------------------------------------------


def main():
    t0 = time.time()
    rng = np.random.default_rng(SEED)
    partial_path = os.path.join(HERE, "p4_allfits.partial.npz")
    done = {}
    if os.path.exists(partial_path):
        Zp = np.load(partial_path)
        done = {k: Zp[k] for k in Zp.files}
    out("# p4_allfits.py  seed=%d  python %s  numpy %s  scipy %s  pyerfa %s" %
        (SEED, sys.version.split()[0], np.__version__, scipy.__version__, erfa.__version__))
    out("# all four fits of l4_kepler_pk.py kept; %d arrays restored from a partial run" % len(done))
    FITS = ("F3", "L2", "L1", "Linf")
    series = dict(done)

    def handle(key, t, rdata, x0):
        if key + "_t" in series:
            assert np.array_equal(series[key + "_t"], t.astype(np.float32)), key
            out("   %s: restored" % key)
            return series[key + "_params_L2"]
        res, lon_d = fits(t, rdata, x0)
        series[key + "_t"] = t.astype(np.float32)
        for k in FITS:
            series[key + "_" + k] = lon_err(res[k], t, lon_d).astype(np.float32)
            series[key + "_params_" + k] = np.asarray(res[k], float)
        np.savez_compressed(partial_path, **series)
        out("   %s: fitted (%.0f s)" % (key, time.time() - t0))
        return res["L2"]

    windows = [12, 30, 100, 300, 1000, 2000]
    for np_ in (1, 2, 3, 4, 5, 6):
        name = NAMES[np_]
        mu = GK ** 2 * (1 + 1 / AMAS[np_])
        r0, v0 = planet_pv(np_, np.array([0.0]))
        a, e, i, Om, om, M = osculating(r0[0], v0[0], mu)
        x0 = [a, e, i, Om, om, M, np.sqrt(mu / a ** 3)]
        for W in windows:
            Wd = W * YEAR
            t = np.sort(rng.uniform(-Wd / 2, Wd / 2, 8000))
            key = "%s_%d" % (name, W)
            rdata = None if key + "_t" in series else planet_pv(np_, t)[0]
            x0 = handle(key, t, rdata, x0)
    r0, v0 = moon_pv(np.array([0.0]))
    mu_em = GK ** 2 / 328900.5
    a, e, i, Om, om, M = osculating(r0[0], v0[0], mu_em)
    x0 = [a, e, i, Om, om, M, np.sqrt(mu_em / a ** 3)]
    for label, Wd in (("1 month", 27.32), ("1 year", YEAR), ("18.6 yr", 18.6 * YEAR)):
        t = np.sort(rng.uniform(-Wd / 2, Wd / 2, 8000))
        key = "Moon_%s" % label.replace(" ", "")
        rdata = None if key + "_t" in series else moon_pv(t)[0]
        x0 = handle(key, t, rdata, x0)

    np.savez_compressed(os.path.join(HERE, "p4_allfits.npz"), **series)

    # comparison with l4_residuals.npz
    L4 = np.load(os.path.join(HERE, "..", "..", "laws", "checks", "l4_residuals.npz"))
    out("")
    out("== comparison with laws/checks/l4_residuals.npz (max |difference| in arcmin)")
    worst = 0.0
    for k in sorted({k[:-2] for k in L4.files if k.endswith("_t")}):
        dt = float(np.max(np.abs(L4[k + "_t"] - series[k + "_t"])))
        mx = {f: float(np.max(np.abs(series[k + "_" + f]))) for f in FITS}
        mn = {f: float(np.mean(np.abs(series[k + "_" + f]))) for f in FITS}
        kmax, kmean = min(mx, key=mx.get), min(mn, key=mn.get)
        d1 = float(np.max(np.abs(L4[k + "_e_max"] - series[k + "_" + kmax])))
        d2 = float(np.max(np.abs(L4[k + "_e_mean"] - series[k + "_" + kmean])))
        worst = max(worst, dt, d1, d2)
        out("   %-14s times %.1e | minimax=%-4s %.1e | mean=%-4s %.1e" % (k, dt, kmax, d1, kmean, d2))
    out("   largest difference: %.2e" % worst)
    out("")
    out("# runtime %.0f s" % (time.time() - t0))
    out("# done")
    with open(os.path.join(HERE, "p4_allfits.out"), "w") as f:
        f.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
