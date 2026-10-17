"""c2_mars_models.py -- which planetary theory is compatible with Mars data at which precision?

Scout P (philosophy), running example of notes.md section 2 (precision-dependent selection).

What it computes
----------------
Data: heliocentric positions of Mars over 1580.0-1600.0 (the span of Tycho Brahe's
observations), sampled once a day, from ERFA's eraPlan94 (Simon et al. 1994; see
c1_kepler_fit.py for its accuracy, about 26" in longitude for Mars over 1800-2100
against DE200).  The positions are rotated into the best-fitting plane through the
Sun (smallest singular vector of the uncentred position matrix), and reduced to an
in-plane heliocentric longitude theta(t) and a distance r(t).

Five classical theories of a planet's heliocentric motion, each a law with free
parameters (the "elements"):
  circle    : uniform circular motion centred on the Sun.          params: th0, n
  eccentric : uniform circular motion about a centre C displaced from the Sun by e
              (in units of the radius) toward aphelion (Hipparchus).  params: e, w, M0, n
  equant    : circle centred at C (offset e), uniform angular motion as seen from
              the equant point Q at offset 2e ("bisected eccentricity", Ptolemy).
                                                                    params: e, w, M0, n
  vicarious : as equant, but the Sun-centre offset e1 and the centre-equant offset
              e2 are independent (Kepler's "vicarious hypothesis", Astronomia Nova
              ch. 16).                                              params: e1, e2, w, M0, n
  ellipse   : Kepler's first two laws: an ellipse with the Sun at a focus, traversed
              according to Kepler's equation E - e sin E = M.       params: e, w, M0, n
(One more parameter, the radius or semi-major axis, only scales distances.)

For each theory:
  (A) fit to longitudes only: least squares, then an L_p (p = 4, 16, 64) refinement
      towards the minimax fit; report the largest and RMS longitude error.  The
      largest error of the refined fit is an upper bound on the smallest tolerance
      delta at which the theory (with suitable elements) is compatible with every
      datum "theta(t_i) lies within delta of v_i".
  (B) the distance error of the fit in (A), after fitting the scale alone;
  (C) fit to longitudes and distances jointly (1 arcmin of longitude weighted like a
      relative distance error of 2.9e-4): the largest longitude error.  For the
      equant this is the analogue of the 8' discrepancy of Astronomia Nova ch. 19.
  (D) a compatibility table: for tolerances delta, which theories have max error
      <= delta.
  (E) a crude two-part code at each delta: bits to state the elements (greedy
      per-parameter quantisation of the refined fit to the coarsest binary grid
      that keeps every longitude within delta), against the cost log2(pi/delta) of
      stating one datum to precision delta outright; and the number of data at which
      the theory's elements are paid for.  The text of each law is not counted (see
      the note printed with table E).

Requirements: numpy, scipy, pyerfa (tested: numpy 2.4.6, scipy 1.17.1, pyerfa 2.0.1.5).
Deterministic (no random numbers); SEED is recorded for uniformity with c1.
Run:  python c2_mars_models.py > c2_mars_models.out
"""
import numpy as np
import erfa
import scipy
from scipy.optimize import least_squares

SEED = 20261015  # unused: the script is deterministic
JD2000 = 2451545.0
YEAR = 365.25
EPS0 = np.deg2rad(84381.448 / 3600.0)
ARCMIN = np.pi / (180 * 60)
TWO_PI = 2 * np.pi


def wrap(x):
    return (x + np.pi) % TWO_PI - np.pi


def eq_to_ecl(p):
    c, s = np.cos(EPS0), np.sin(EPS0)
    x, y, z = p[..., 0], p[..., 1], p[..., 2]
    return np.stack([x, c * y + s * z, -s * y + c * z], axis=-1)


def mars_data(y0, y1, step_days=1.0):
    t = np.arange((y0 - 2000.0) * YEAR, (y1 - 2000.0) * YEAR + 1e-9, step_days)
    pv = erfa.plan94(JD2000 + np.zeros_like(t), t, 4)
    p = eq_to_ecl(pv["p"])
    # best plane through the Sun
    _, s, vt = np.linalg.svd(p, full_matrices=False)
    nrm = vt[2]
    if nrm[2] < 0:
        nrm = -nrm
    ex = np.cross([0.0, 0.0, 1.0], nrm)
    ex /= np.linalg.norm(ex)          # ascending node direction
    ey = np.cross(nrm, ex)
    x, y, z = p @ ex, p @ ey, p @ nrm
    theta = np.unwrap(np.arctan2(y, x))
    r = np.hypot(x, y)
    incl = np.degrees(np.arccos(nrm[2]))
    out_of_plane = np.max(np.abs(z) / np.linalg.norm(p, axis=1))
    return t, theta, r, incl, out_of_plane


# ------------------------------------------------------------------ models
def kepler_E(M, e):
    E = M + e * np.sin(M)
    for _ in range(60):
        dE = (E - e * np.sin(E) - M) / (1 - e * np.cos(E))
        E -= dE
        if np.max(np.abs(dE)) < 1e-15:
            break
    return E


def circle_on_line(t, e_c, e_q, w, M0, n):
    """circle of radius 1 centred at C = -e_c u(w) (Sun at origin), uniform angular
    motion about Q = -(e_c + e_q) u(w); returns heliocentric longitude and distance."""
    M = M0 + n * t
    u = np.stack([np.cos(w + M), np.sin(w + M)], axis=-1)
    uw = np.array([np.cos(w), np.sin(w)])
    C = -e_c * uw
    Q = -(e_c + e_q) * uw
    d = Q - C                       # = -e_q u(w)
    du = u @ d
    s = -du + np.sqrt(du ** 2 - d @ d + 1.0)
    P = Q + s[:, None] * u
    return np.arctan2(P[:, 1], P[:, 0]), np.hypot(P[:, 0], P[:, 1])


def model(name, p, t):
    if name == "circle":
        th0, n = p
        th = th0 + n * t
        return th, np.ones_like(t)
    if name == "eccentric":
        e, w, M0, n = p
        return circle_on_line(t, e, 0.0, w, M0, n)
    if name == "equant":
        e, w, M0, n = p
        return circle_on_line(t, e, e, w, M0, n)
    if name == "vicarious":
        e1, e2, w, M0, n = p
        return circle_on_line(t, e1, e2, w, M0, n)
    if name == "ellipse":
        e, w, M0, n = p
        E = kepler_E(M0 + n * t, e)
        nu = 2 * np.arctan2(np.sqrt(1 + e) * np.sin(E / 2), np.sqrt(1 - e) * np.cos(E / 2))
        return w + nu, 1 - e * np.cos(E)
    raise ValueError(name)


PARAM_NAMES = {"circle": ["th0", "n"], "eccentric": ["e", "w", "M0", "n"],
               "equant": ["e", "w", "M0", "n"], "vicarious": ["e1", "e2", "w", "M0", "n"],
               "ellipse": ["e", "w", "M0", "n"]}
# natural ranges used to count bits of each element (a constant offset per element)
RANGE = {"th0": TWO_PI, "w": TWO_PI, "M0": TWO_PI, "e": 1.0, "e1": 1.0, "e2": 1.0, "n": 0.1}


def lon_res(name, p, t, theta):
    th, _ = model(name, p, t)
    return wrap(th - theta)


def fit_lon(name, p0, t, theta):
    best = least_squares(lambda p: lon_res(name, p, t, theta), p0, method="lm",
                         xtol=1e-15, ftol=1e-15, gtol=1e-15, max_nfev=20000)
    x = best.x
    mx = np.max(np.abs(lon_res(name, x, t, theta)))
    for pexp in (4, 16, 64):
        def f(p, s=mx, q=pexp):
            r = lon_res(name, p, t, theta) / s
            return np.abs(r) ** (q / 2.0)
        sol = least_squares(f, x, method="lm", xtol=1e-15, ftol=1e-15, gtol=1e-15,
                            max_nfev=20000)
        m2 = np.max(np.abs(lon_res(name, sol.x, t, theta)))
        if m2 < mx:
            x, mx = sol.x, m2
    res = lon_res(name, x, t, theta)
    return x, np.max(np.abs(res)), np.sqrt(np.mean(res ** 2))


def dist_err(name, p, t, r):
    _, rm = model(name, p, t)
    scale = np.sum(rm * r) / np.sum(rm * rm)      # best scale (least squares)
    return np.max(np.abs(scale * rm - r) / r), scale


def fit_joint(name, p0, t, theta, r, w_dist=1.0 / (2.9e-4)):
    """longitudes in arcmin and relative distance errors weighted so that a relative
    error of 2.9e-4 counts like 1 arcmin; the scale is an extra parameter."""
    def f(q):
        p, sc = q[:-1], q[-1]
        th, rm = model(name, p, t)
        return np.concatenate([wrap(th - theta) / ARCMIN, w_dist * (sc * rm - r) / r])
    sc0 = np.mean(r)
    sol = least_squares(f, np.concatenate([p0, [sc0]]), method="lm",
                        xtol=1e-15, ftol=1e-15, gtol=1e-15, max_nfev=20000)
    p, sc = sol.x[:-1], sol.x[-1]
    th, rm = model(name, p, t)
    return p, np.max(np.abs(wrap(th - theta))), np.max(np.abs(sc * rm - r) / r)


def element_bits(name, p, t, theta, delta):
    """greedy per-parameter quantisation; returns total bits or None."""
    names = PARAM_NAMES[name]
    if np.max(np.abs(lon_res(name, p, t, theta))) > delta:
        return None, None
    bits = [48] * len(p)

    def quant(bvec):
        q = []
        for k, (v, b) in enumerate(zip(p, bvec)):
            step = RANGE[names[k]] * 2.0 ** (-b)
            q.append(np.round(v / step) * step)
        return np.array(q)

    if np.max(np.abs(lon_res(name, quant(bits), t, theta))) > delta:
        return None, None
    changed = True
    while changed:
        changed = False
        for k in range(len(p)):
            while bits[k] > 1:
                trial = list(bits)
                trial[k] -= 1
                if np.max(np.abs(lon_res(name, quant(trial), t, theta))) <= delta:
                    bits = trial
                    changed = True
                else:
                    break
    return sum(bits), bits


def main():
    print("# c2_mars_models.py  numpy %s  scipy %s  pyerfa %s  (deterministic)"
          % (np.__version__, scipy.__version__, erfa.__version__))
    t, theta, r, incl, oop = mars_data(1580.0, 1600.0, 1.0)
    N = len(t)
    print("# data: ERFA plan94 Mars, heliocentric, 1580.0-1600.0, daily: N = %d" % N)
    print("# best plane through the Sun: inclination to the J2000 ecliptic %.4f deg; "
          "largest out-of-plane angle %.3f arcmin" % (incl, np.degrees(oop) * 60))
    print()

    # initial guesses from a quick ellipse fit seeded by osculating-like values
    n0 = TWO_PI / 686.98
    tmid = t[N // 2]
    # perihelion longitude guess: longitude at minimum distance
    i_min = np.argmin(r)
    w0 = theta[i_min] % TWO_PI
    M0g = wrap(-n0 * t[i_min])
    e0 = (r.max() - r.min()) / (r.max() + r.min())
    guesses = {
        "ellipse": [e0, w0, M0g, n0],
        "equant": [e0, w0, M0g, n0],
        "vicarious": [1.1 * e0, 0.9 * e0, w0, M0g, n0],
        "eccentric": [2 * e0, w0, M0g, n0],
        "circle": [w0 + M0g, n0],
    }
    fits = {}
    print("## (A) fit to longitudes only; (B) distance error of that fit (scale fitted)")
    print("%-10s %3s %14s %14s %16s   %s" % ("theory", "k", "max |dlon| '", "rms |dlon| '",
                                           "max |dr|/r (B)", "elements"))
    for name in ["circle", "eccentric", "equant", "vicarious", "ellipse"]:
        x, mx, rms = fit_lon(name, np.array(guesses[name], float), t, theta)
        fits[name] = (x, mx)
        de, sc = dist_err(name, x, t, r)
        el = ", ".join("%s=%.6g" % (nm, v if nm not in ("w", "M0", "th0") else np.degrees(v) % 360)
                       for nm, v in zip(PARAM_NAMES[name], x))
        print("%-10s %3d %14.3f %14.3f %16.2e   %s (angles deg; n rad/day)"
              % (name, len(x), mx / ARCMIN, rms / ARCMIN, de, el))
    xe = fits["ellipse"][0]
    print("   ellipse: e = %.5f, period 2pi/n = %.3f d" % (xe[0], TWO_PI / xe[3]))
    xv = fits["vicarious"][0]
    print("   vicarious: e1 = %.5f, e2 = %.5f, e1/(e1+e2) = %.4f  (bisection would be 0.5)"
          % (xv[0], xv[1], xv[0] / (xv[0] + xv[1])))
    print()

    print("## (C) fit to longitudes and distances jointly (1 arcmin ~ 2.9e-4 relative distance)")
    print("%-10s %14s %16s" % ("theory", "max |dlon| '", "max |dr|/r"))
    for name in ["eccentric", "equant", "vicarious", "ellipse"]:
        p, mlon, mdr = fit_joint(name, fits[name][0], t, theta, r)
        extra = ""
        if name in ("equant", "ellipse"):
            extra = "   e = %.5f" % p[0]
        if name == "vicarious":
            extra = "   e1 = %.5f, e2 = %.5f" % (p[0], p[1])
        print("%-10s %14.3f %16.2e%s" % (name, mlon / ARCMIN, mdr, extra))
    e_k = fits["ellipse"][0][0]
    print("   second-order estimate of the equant's longitude error, e^2/4 = %.2f arcmin"
          % (e_k ** 2 / 4 / ARCMIN))
    print()

    print("## (D) compatibility with longitude data at tolerance delta (max |dlon| <= delta)")
    deltas = [720.0, 60.0, 30.0, 10.0, 8.0, 5.0, 2.0, 1.0, 0.5]
    names = ["circle", "eccentric", "equant", "vicarious", "ellipse"]
    print("%-10s " % "delta(')" + " ".join("%10s" % n for n in names))
    for d in deltas:
        print("%-10g " % d + " ".join("%10s" % ("yes" if fits[n][1] <= d * ARCMIN else "-")
                                       for n in names))
    print()

    print("## (E) crude two-part code at tolerance delta (element bits only)")
    print("# datum cost log2(pi/delta) bits (a longitude to within delta on the circle);")
    print("# N_even = element bits / datum cost: the number of data at which stating the")
    print("# elements is cheaper than stating the data outright.  Law texts are NOT counted:")
    print("# each is a short formula, and in any fixed syntax they differ by a few hundred bits")
    print("# at most; this offset is formalisation-dependent and is left out.")
    print("%-8s %-10s %10s %24s %10s" % ("delta'", "theory", "elem bits", "bits per element",
                                         "N_even"))
    for d in [60.0, 10.0, 8.0, 5.0, 2.0, 1.0]:
        dc = np.log2(np.pi / (d * ARCMIN))
        for name in names:
            x, mx = fits[name]
            tot, bv = element_bits(name, x, t, theta, d * ARCMIN)
            if tot is None:
                continue
            print("%-8g %-10s %10d %24s %10.1f" % (d, name, tot, str(bv), tot / dc))
        print("%-8g %-10s datum cost %.2f bits" % (d, "", dc))
    print()
    print("# done")


if __name__ == "__main__":
    main()
