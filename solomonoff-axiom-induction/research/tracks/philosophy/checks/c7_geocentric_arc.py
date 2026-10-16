"""c7_geocentric_arc.py -- Props 4.3 and 4.4 of notes.md, numerically (thread `philosophy`, T4).

Deterministic.  Writes c7_geocentric_arc.out next to itself.

(1) Prop 4.4(b): without K3 (and without a(Ma)), the geocentric direction of Mars at time t ranges over
    the open arc from the Sun's direction to Mars's heliocentric direction, of length alpha(t).  We
    compute alpha(t) along 1580.0-1600.0 from plan94 (EMB for the Earth), its distribution, and, as a
    check of the arc claim, the directions for rho on a grid (monotone along the arc, endpoints approached).
(2) Prop 4.3: the counter-model M_0 (Earth circular, Mars co-moving at rho = 1.5237 with the Earth's
    period) has Mars permanently at opposition; a K3-model with the same Earth and the same Mars phase
    and orbit shape (rho = 1.5237, period from K3) leaves opposition: we print the largest angle between
    Mars's geocentric direction and the anti-Sun direction over one, ten and a hundred days.
"""
import sys
import numpy as np
import erfa

JD2000 = 2451545.0
YEAR = 365.25
EPS0 = np.deg2rad(84381.448 / 3600.0)
OUT = []


def p(*a):
    s = " ".join(str(x) for x in a)
    OUT.append(s)
    print(s)


def ecl(pv):
    c, s = np.cos(EPS0), np.sin(EPS0)
    x, y, z = pv[..., 0], pv[..., 1], pv[..., 2]
    return np.stack([x, c * y + s * z, -s * y + c * z], axis=-1)


def unit(v):
    return v / np.linalg.norm(v, axis=-1, keepdims=True)


def ang(a, b):
    return np.degrees(np.arccos(np.clip(np.sum(unit(a) * unit(b), axis=-1), -1, 1)))


def main():
    p("# c7_geocentric_arc.py  numpy %s  pyerfa %s  python %s (deterministic)"
      % (np.__version__, erfa.__version__, sys.version.split()[0]))
    t = np.arange((1580.0 - 2000.0) * YEAR, (1600.0 - 2000.0) * YEAR + 1e-9, 1.0)
    xE = ecl(erfa.plan94(JD2000 + 0 * t, t, 3)["p"])
    xM = ecl(erfa.plan94(JD2000 + 0 * t, t, 4)["p"])
    rho_true = np.linalg.norm(xM, axis=1)
    FM = xM / 1.523679                                  # Mars's orbit at unit size (a = 1)
    alpha = ang(-xE, FM)                                # arc length (deg): Sun direction to Mars's helio direction
    p("(1) arc length alpha(t) between the Sun's direction and Mars's heliocentric direction, 1580-1600 daily")
    q = np.percentile(alpha, [0, 5, 25, 50, 75, 95, 100])
    p("    percentiles 0/5/25/50/75/95/100: " + " ".join("%.2f" % v for v in q) + " deg")
    p("    fraction of days with alpha < 2' (near conjunction or opposition): %.5f" % np.mean(alpha < 2 / 60))
    # arc claim: directions for rho on a grid at a few sample days
    rhos = np.concatenate([np.geomspace(1e-3, 1, 30), np.geomspace(1.0001, 1e3, 60)])
    worst_mono = 0
    for i in range(0, len(t), 365):
        g = rhos[:, None] * FM[i][None, :] - xE[i][None, :]
        d_from_sun = ang(g, np.repeat(-xE[i][None, :], len(rhos), 0))
        d_to_F = ang(g, np.repeat(FM[i][None, :], len(rhos), 0))
        mono = np.all(np.diff(d_from_sun) >= -1e-9)
        worst_mono += int(not mono)
        if i == 0:
            p("    day 0 (1580.0): alpha = %.3f deg; rho=0.001 -> %.4f deg from the Sun's direction; rho=1000 -> %.4f deg"
              " from Mars's heliocentric direction; sum of the two angles at rho=1.5237: %.4f (= alpha on the arc)"
              % (alpha[i], d_from_sun[0], d_to_F[-1],
                 ang(1.5237 * FM[i] - xE[i], -xE[i]) + ang(1.5237 * FM[i] - xE[i], FM[i])))
    p("    monotone sweep along the arc as rho grows: violated on %d of %d sampled days" % (worst_mono, len(range(0, len(t), 365))))
    # how precisely rho must be known: d(direction)/d(rho) at the true rho, per day
    eps = 1e-6
    g0 = 1.523679 * FM - xE
    g1 = (1.523679 + eps) * FM - xE
    sens = ang(g0, g1) / eps * 60                        # arcmin per unit rho
    p("    sensitivity of the geocentric direction to rho at the true rho (arcmin per unit rho):"
      " median %.0f, 95th percentile %.0f, max %.0f" % (np.median(sens), np.percentile(sens, 95), sens.max()))
    for d in (8, 4, 2):
        w = 2 * d / sens.max()
        p("    at precision %g': rho must be known to about +-%.2e (from the most sensitive day); log2(4/(2 w)) = %.1f bits"
          % (d, d / sens.max(), np.log2(4 / (2 * d / sens.max()))))

    # (2) the counter-model and a K3 model
    p("(2) counter-model M_0 and a K3 model (circular, coplanar; Earth a = 1, P = 365.25 d)")
    PE = 365.25
    rho = 1.5237
    tt = np.linspace(0, 100, 10001)
    uE = np.stack([np.cos(2 * np.pi * tt / PE), np.sin(2 * np.pi * tt / PE), 0 * tt], axis=1)
    xM0 = rho * uE                                      # same period: M_0
    PM = PE * rho ** 1.5                                # K3 period
    uM = np.stack([np.cos(2 * np.pi * tt / PM), np.sin(2 * np.pi * tt / PM), 0 * tt], axis=1)
    xMK = rho * uM
    dev0 = ang(xM0 - uE, uE)
    devK = ang(xMK - uE, uE)
    for T in (1, 10, 100):
        m = tt <= T
        p("    first %3d days: max angle from opposition  M_0 %.2e deg   K3 model %.3f deg" % (T, dev0[m].max(), devK[m].max()))
    p("# done")
    with open(__file__.replace(".py", ".out"), "w") as f:
        f.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
