"""c3_kepler_constant.py -- what Newton says about the constant in Kepler's third law.

Scout P (philosophy), running example of notes.md section 2 ("what Newton adds").

c1_kepler_fit.py fitted one fixed Kepler ellipse (free mean motion n) to each planet
and reported q = n^2 a^3 / k^2, with k the Gaussian constant, so that Kepler's third law
with one constant for all planets says q = 1.  This script computes two Newtonian
predictions of q and sets them beside the fitted values copied from c1_kepler_fit.out:

  two-body : q = 1 + m/M (the planet's own mass; Newton's correction of K3);
  ring     : q = 1 + m/M + sum_j (m_j/M) r^2 f_j(r), where f_j(r) is the inward radial
             force per unit G m_j at radius r in the plane of a uniform circular ring of
             radius R_j (the orbit-averaged pull of planet j), evaluated at r = a.  This
             is the circular-orbit balance n^2 r = GM(1 + m/M)/r^2 + sum_j G m_j f_j(r).
             A heuristic (secular, circular, coplanar), not a perturbation theory.

Masses: plan94's own inverse masses.  Radii: osculating semi-major axes at J2000 from
plan94 (the ring radius of planet j, and r for the planet itself).
Requirements: numpy, scipy, pyerfa.  Deterministic.
Run:  python c3_kepler_constant.py > c3_kepler_constant.out
"""
import numpy as np
import erfa
from scipy.integrate import quad

GK = 0.017202098950
AMAS = {1: 6023600.0, 2: 408523.5, 3: 328900.5, 4: 3098710.0,
        5: 1047.355, 6: 3498.5, 7: 22869.0, 8: 19314.0}
NAMES = {1: "Mercury", 2: "Venus", 3: "EMB", 4: "Mars", 5: "Jupiter",
         6: "Saturn", 7: "Uranus", 8: "Neptune"}
JD2000 = 2451545.0
# fitted q = n^2 a^3 / k^2 from c1_kepler_fit.out (free_n fits), by window in years
Q_FIT = {
    1: {12: 0.99999692, 30: 0.99999682, 100: 0.99999617, 300: 0.99999007, 1000: 1.00000730, 2000: 0.99999679},
    4: {12: 0.99996620, 30: 0.99997329, 100: 0.99996865, 300: 0.99998394, 1000: 0.99998112, 2000: 1.00002372},
    5: {12: 1.00062014, 30: 1.00098782, 100: 1.00083032, 300: 1.00083624, 1000: 1.00075114, 2000: 1.00080620},
    6: {12: 1.00487386, 30: 1.00134341, 100: 1.00152333, 300: 1.00162087, 1000: 1.00189548, 2000: 1.00130640},
}


def osc_a(np_):
    pv = erfa.plan94(JD2000, 0.0, np_)
    r, v = pv["p"], pv["v"]
    mu = GK ** 2 * (1 + 1 / AMAS[np_])
    return 1.0 / (2.0 / np.linalg.norm(r) - np.dot(v, v) / mu)


def ring_inward(r, R):
    """(1/2pi) * integral of (r - R cos phi) / (r^2 + R^2 - 2 r R cos phi)^{3/2}"""
    f = lambda ph: (r - R * np.cos(ph)) / (r * r + R * R - 2 * r * R * np.cos(ph)) ** 1.5
    val, _ = quad(f, 0.0, 2 * np.pi, limit=400, epsabs=1e-14, epsrel=1e-12)
    return val / (2 * np.pi)


def main():
    print("# c3_kepler_constant.py  pyerfa %s  (deterministic)" % erfa.__version__)
    a = {p: osc_a(p) for p in range(1, 9)}
    print("# osculating a at J2000 (AU): " + ", ".join("%s %.4f" % (NAMES[p], a[p]) for p in a))
    print()
    print("%-8s %12s %12s   %s" % ("planet", "two-body q", "ring q", "fitted q (c1, windows 12/30/100/300/1000/2000 yr)"))
    for p in (1, 4, 5, 6):
        r = a[p]
        q2 = 1 + 1 / AMAS[p]
        qr = q2
        for j in range(1, 9):
            if j == p:
                continue
            qr += (1 / AMAS[j]) * r * r * ring_inward(r, a[j])
        fits = Q_FIT[p]
        print("%-8s %12.8f %12.8f   %s" % (NAMES[p], q2, qr, " ".join("%.6f" % fits[w] for w in sorted(fits))))
    print()
    print("# contributions to ring q - 1 for Saturn and Jupiter, by perturber:")
    for p in (5, 6):
        r = a[p]
        parts = []
        for j in range(1, 9):
            if j == p:
                continue
            parts.append("%s %+.2e" % (NAMES[j], (1 / AMAS[j]) * r * r * ring_inward(r, a[j])))
        print("  %-8s own %+.2e; " % (NAMES[p], 1 / AMAS[p]) + ", ".join(parts))
    print("# done")


if __name__ == "__main__":
    main()
