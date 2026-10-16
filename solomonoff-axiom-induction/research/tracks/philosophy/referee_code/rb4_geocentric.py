"""rb4_geocentric.py -- referee B for thread `philosophy`: independent numerical checks of Props 4.3, 4.4
and of c7's figures (notes.md 4.2), written without reading c7's code.  Deterministic (no randomness
except a seeded choice of test days, seed 20261016).  Writes rb4_geocentric.out next to itself.

(1) Prop 4.4(b) / c7 (1): with F_M(t) := x_Mars(t) / 1.523679 (plan94) and x_E the plan94 Earth-Moon
    barycentre, the geocentric direction of rho F_M - x_E over rho in (0, inf) sweeps the open great-circle
    arc from -u_E (the Sun's direction) to F_M/|F_M|, of length alpha(t); percentiles of alpha over
    1580-1600; monotone sweep and great-circle check on 60 seeded days; sensitivity |d dir / d rho| at
    rho = 1.523679 (arcmin per unit rho); the crude bits-of-rho estimate.
(2) Prop 4.3 / c7 (2): the counter-model M_0 (co-moving circular orbits, equal periods) and the K3 model
    with the same Earth, rho = 1.5237 and the same initial phase: angle from opposition.
(3) Prop 4.3(a) numerically: random K12+K3 element sets (Earth i = 0; Mars any plane) never keep Mars at
    opposition on a 20-year daily grid (the largest minimum over t of the angle from opposition is
    reported), while random K12 sets WITHOUT K3 but with equal periods and coplanar circular co-phased
    orbits do (the M_0 family).
"""
import math
import os
import sys

import numpy as np
import erfa

SEED = 20261016
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []


def out(*a):
    s = " ".join(str(x) for x in a)
    OUT.append(s)
    print(s, flush=True)


def unit(v):
    return v / np.linalg.norm(v, axis=-1, keepdims=True)


def ang(a, b):
    a, b = unit(a), unit(b)
    c = np.clip(np.sum(a * b, axis=-1), -1, 1)
    # robust angle
    d = np.linalg.norm(a - b, axis=-1)
    return np.where(c < 0.9, np.arccos(c), 2 * np.arcsin(np.minimum(d / 2, 1)))


def part1():
    out("== (1) Prop 4.4(b) and c7 (1)")
    t = np.arange(-153405.0, -146100.0 + 0.5, 1.0)
    xM = erfa.plan94(2451545.0 + 0 * t, t, 4)["p"]
    xE = erfa.plan94(2451545.0 + 0 * t, t, 3)["p"]
    rho0 = 1.523679
    F = xM / rho0
    sun_dir = -xE                      # direction from Earth to Sun
    alpha = ang(sun_dir, F)
    pc = np.percentile(np.degrees(alpha), [0, 5, 25, 50, 75, 95, 100])
    out("  alpha percentiles 0/5/25/50/75/95/100 (deg): " + " ".join("%.2f" % x for x in pc))
    out("  (c7: 0.11 9.52 46.68 90.22 133.91 170.34 179.96)")
    out("  day 0: alpha = %.4f deg (c7 47.618)" % np.degrees(alpha[0]))
    rng = np.random.default_rng(SEED)
    days = rng.choice(len(t), 60, replace=False)
    rhos = np.logspace(-4, 4, 2001)
    viol = 0
    worst_plane = 0.0
    worst_end = 0.0
    for d in days:
        g = rhos[:, None] * F[d][None, :] - xE[d][None, :]
        a_from_sun = ang(np.broadcast_to(sun_dir[d], g.shape), g)
        a_to_F = ang(np.broadcast_to(F[d], g.shape), g)
        if np.any(np.diff(a_from_sun) < -1e-12):
            viol += 1
        # on the great circle between the ends: the two angles sum to alpha
        worst_plane = max(worst_plane, float(np.max(np.abs(a_from_sun + a_to_F - alpha[d]))))
        worst_end = max(worst_end, float(a_from_sun[0]), float(a_to_F[-1]))
    out("  60 seeded days, rho on a log grid 1e-4..1e4: monotone-sweep violations %d; max |angle(Sun,g)+angle(g,F)-alpha| = %.1e rad;"
        " ends approached within %.2e rad" % (viol, worst_plane, worst_end))
    g = rho0 * F - xE
    gn = np.linalg.norm(g, axis=1)
    perp = F - (np.sum(g * F, axis=1) / gn ** 2)[:, None] * g
    sens = np.linalg.norm(perp, axis=1) / gn * (180 * 60 / math.pi)
    out("  sensitivity at rho = %.6f (arcmin per unit rho): median %.0f, 95th pct %.0f, max %.0f (c7: 969, 2676, 3555)"
        % (rho0, np.median(sens), np.percentile(sens, 95), sens.max()))
    for dl in [8, 4, 2]:
        w = dl / sens.max()
        out("  delta=%d': rho to +-%.2e from the most sensitive day; log2(4/(2w)) = %.2f bits" % (dl, w, math.log2(4 / (2 * w))))


def part2():
    out("== (2) M_0 against a K3 model (circular, coplanar; Earth a=1, P=365.25 d, rho=1.5237, same phase)")
    rho = 1.5237
    PE = 365.25
    PM = PE * rho ** 1.5
    for N in [1, 10, 100]:
        tt = np.linspace(0, N, 20 * N + 1)
        uE = np.stack([np.cos(2 * np.pi * tt / PE), np.sin(2 * np.pi * tt / PE), 0 * tt], axis=1)
        xm0 = rho * uE
        xmk = rho * np.stack([np.cos(2 * np.pi * tt / PM), np.sin(2 * np.pi * tt / PM), 0 * tt], axis=1)
        a0 = np.degrees(np.max(ang(xm0 - uE, uE)))
        ak = np.degrees(np.max(ang(xmk - uE, uE)))
        out("  first %3d days: max angle from opposition  M_0 %.2e deg   K3 model %.3f deg" % (N, a0, ak))
    out("  (c7: M_0 1.21e-06 (rounding); K3 model 1.343, 13.299, 87.114 deg)")


def kepler_pos(el, t):
    """el: a, e, i, Om, w (argument of perihelion), M0, P; returns (N,3) positions."""
    a, e, i, Om, w, M0, P = el
    M = M0 + 2 * np.pi * t / P
    E = M.copy()
    for _ in range(50):
        E = E - (E - e * np.sin(E) - M) / (1 - e * np.cos(E))
    xp = a * (np.cos(E) - e)
    yp = a * np.sqrt(1 - e * e) * np.sin(E)
    cO, sO, ci, si, cw, sw = np.cos(Om), np.sin(Om), np.cos(i), np.sin(i), np.cos(w), np.sin(w)
    R = np.array([[cO * cw - sO * sw * ci, -cO * sw - sO * cw * ci, sO * si],
                  [sO * cw + cO * sw * ci, -sO * sw + cO * cw * ci, -cO * si],
                  [sw * si, cw * si, ci]])
    return (R @ np.stack([xp, yp, 0 * xp])).T


def part3():
    out("== (3) Prop 4.3(a) numerically: K12+K3 models never keep Mars (outer) permanently at opposition")
    rng = np.random.default_rng(SEED + 1)
    t = np.arange(0.0, 7306.0, 1.0)
    worst = None
    for k in range(300):
        aE = 1.0
        PE = rng.uniform(300, 400)
        eE, eM = rng.uniform(0, 0.3), rng.uniform(0, 0.3)
        aM = rng.uniform(1.05, 3.0)
        PM = PE * (aM / aE) ** 1.5                            # K3
        elE = (aE, eE, 0.0, 0.0, rng.uniform(0, 2 * np.pi), rng.uniform(0, 2 * np.pi), PE)
        elM = (aM, eM, rng.uniform(0, 0.2), rng.uniform(0, 2 * np.pi), rng.uniform(0, 2 * np.pi),
               rng.uniform(0, 2 * np.pi), PM)
        xE = kepler_pos(elE, t)
        xM = kepler_pos(elM, t)
        dev = ang(xM - xE, xE)                                  # angle of geocentric Mars from opposition
        mx = float(np.degrees(dev.max()))
        worst = mx if worst is None else min(worst, mx)
    out("  300 random K12+K3 models (outer planet, a_M in [1.05,3]): the smallest, over models, of the largest"
        " angle from opposition over 20 years = %.2f deg (> 0: never permanently at opposition)" % worst)
    # M_0 family: K12 without K3, equal periods, circular coplanar, co-phased
    worst0 = 0.0
    for k in range(50):
        PE = rng.uniform(300, 400)
        aM = rng.uniform(1.05, 3.0)
        ph = rng.uniform(0, 2 * np.pi)
        xE = kepler_pos((1.0, 0.0, 0.0, 0.0, 0.0, ph, PE), t)
        xM = kepler_pos((aM, 0.0, 0.0, 0.0, 0.0, ph, PE), t)
        worst0 = max(worst0, float(np.degrees(ang(xM - xE, xE).max())))
    out("  50 random M_0 models (equal periods, co-moving): largest angle from opposition = %.1e deg" % worst0)


if __name__ == "__main__":
    out("# rb4_geocentric.py  seed=%d  numpy %s  pyerfa %s  python %s"
        % (SEED, np.__version__, erfa.__version__, sys.version.split()[0]))
    part1()
    part2()
    part3()
    out("# done")
    with open(os.path.join(HERE, "rb4_geocentric.out"), "w") as f:
        f.write("\n".join(OUT) + "\n")
