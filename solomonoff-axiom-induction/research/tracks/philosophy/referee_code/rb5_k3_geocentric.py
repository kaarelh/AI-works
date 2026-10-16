"""rb5_k3_geocentric.py -- referee B for thread `philosophy`: an independent estimate of what K3 saves in
geocentric longitude data (notes.md 4.4 Part B; c4 Part B), written without reading c4's Part B code.
Seed 20261016.  Writes rb5_k3_geocentric.out next to itself.

Data: geocentric ecliptic longitude of Mars = direction of (plan94 Mars - plan94 Earth-Moon barycentre),
J2000 equatorial rotated to the ecliptic with eps0 = 84381.448", daily 1580.0-1600.0 (7306 days), as
described in notes.md.  Model (as described in notes.md): Earth a Kepler ellipse in the ecliptic (a = 1;
e, w, L, n); Mars a Kepler ellipse in a fixed plane (the best plane through the Sun of its heliocentric
positions; e, w from the node, L, n) of size rho; 9 elements, or 8 with K3 (rho := (n_E/n_M)^(2/3)).

Steps: (i) heliocentric starting fits; (ii) minimax fits of the 9- and 8-element models (own exchange
algorithm with SLSQP); (iii) at each delta, the LINEARISED compatible polytope {x : |r0 + J x|_inf <= delta}
around the 9-element minimax point is sampled uniformly by hit-and-run (exact chords for linear
constraints; whitened by the sample covariance after a pilot run); (iv) y := rho - (n_E/n_M)^(2/3) is
computed exactly at the samples and its density at 0 is estimated by a Gaussian kernel (three bandwidths);
s(delta) = log2(4 * p_Y(0)) is what K3 saves (rho in [0, 4)); (v) the fraction of polytope samples that
are compatible under the EXACT model is reported (the linearisation's accuracy).
"""
import math
import os
import sys
import time

import numpy as np
from scipy.optimize import least_squares, minimize
import erfa

SEED = 20261016
HERE = os.path.dirname(os.path.abspath(__file__))
ARC = math.pi / (180 * 60)
TWO = 2 * math.pi
EPS0 = math.radians(84381.448 / 3600)
OUT = []


def out(*a):
    s = " ".join(str(x) for x in a)
    OUT.append(s)
    print(s, flush=True)


def wrap(x):
    return (x + np.pi) % TWO - np.pi


def to_ecl(p):
    c, s = math.cos(EPS0), math.sin(EPS0)
    return np.stack([p[:, 0], c * p[:, 1] + s * p[:, 2], -s * p[:, 1] + c * p[:, 2]], axis=1)


def kep(M, e):
    E = M + e * np.sin(M)
    for _ in range(30):
        E = E - (E - e * np.sin(E) - M) / (1 - e * np.cos(E))
    nu = 2 * np.arctan2(np.sqrt(1 + e) * np.sin(E / 2), np.sqrt(1 - e) * np.cos(E / 2))
    return nu, 1 - e * np.cos(E)


class Geo:
    def __init__(self):
        t = np.arange(-153405.0, -146100.0 + 0.5, 1.0)
        self.tt = t - 0.5 * (t[0] + t[-1])
        xM = to_ecl(erfa.plan94(2451545.0 + 0 * t, t, 4)["p"])
        xE = to_ecl(erfa.plan94(2451545.0 + 0 * t, t, 3)["p"])
        g = xM - xE
        self.lam = np.unwrap(np.arctan2(g[:, 1], g[:, 0]))
        _, _, vt = np.linalg.svd(xM, full_matrices=False)
        nrm = vt[2] if vt[2][2] > 0 else -vt[2]
        self.ex = np.cross([0.0, 0.0, 1.0], nrm)
        self.ex /= np.linalg.norm(self.ex)
        self.ey = np.cross(nrm, self.ex)
        self.incl = math.degrees(math.acos(nrm[2]))
        self.node = math.degrees(math.atan2(self.ex[1], self.ex[0]))
        self.thM = np.unwrap(np.arctan2(xM @ self.ey, xM @ self.ex))
        self.thE = np.unwrap(np.arctan2(xE[:, 1], xE[:, 0]))

    def lon(self, P, tt=None, k3=False):
        """P: (B,9) [eE,wE,LE,nE,eM,wM,LM,nM,rho] or (B,8) with K3."""
        tt = self.tt if tt is None else tt
        P = np.atleast_2d(P)
        c = lambda i: P[:, i:i + 1]  # noqa: E731
        eE, wE, LE, nE, eM, wM, LM, nM = (c(i) for i in range(8))
        rho = (nE / nM) ** (2.0 / 3.0) if k3 else c(8)
        nuE, rE = kep(LE + nE * tt - wE, eE)
        nuM, rM = kep(LM + nM * tt - wM, eM)
        aE = wE + nuE
        aM = wM + nuM
        XE, YE = rE * np.cos(aE), rE * np.sin(aE)
        u, v = rho * rM * np.cos(aM), rho * rM * np.sin(aM)
        X = u * self.ex[0] + v * self.ey[0] - XE
        Y = u * self.ex[1] + v * self.ey[1] - YE
        return np.arctan2(Y, X)

    def res(self, p, k3=False, idx=None):
        tt = self.tt if idx is None else self.tt[idx]
        lam = self.lam if idx is None else self.lam[idx]
        return wrap(self.lon(p, tt, k3)[0] - lam)


SC9 = np.array([1e-3, 1e-2, 1e-3, 1e-7, 1e-3, 1e-2, 1e-3, 1e-7, 1e-4])


def helio_fit(th, tt, e0):
    n0 = np.polyfit(tt, th, 1)[0]
    L0 = float(np.mean(th - n0 * tt))
    best = None
    for w0 in np.linspace(0, TWO, 8, endpoint=False):
        f = lambda q: wrap(q[1] + kep(q[2] + q[3] * tt - q[1], q[0])[0] - th) / ARC  # noqa: E731
        s = least_squares(f, [e0, w0, L0, n0], x_scale=[1e-2, 1e-1, 1e-2, 1e-6])
        if best is None or s.cost < best.cost:
            best = s
    return best.x


def exchange(geo, p0, k3, sc, iters=40):
    k = len(p0)
    N = len(geo.tt)
    r = geo.res(p0, k3)
    act = set(np.argsort(-np.abs(r))[:40].tolist()) | set(range(0, N, 200))
    p = np.array(p0, float)
    for _ in range(iters):
        A = np.array(sorted(act))

        def cons(y):
            q = p + y[:k] * sc
            rr = geo.res(q, k3, A)
            return np.concatenate([y[k] - rr, y[k] + rr])
        z0 = np.max(np.abs(geo.res(p, k3, A)))
        sol = minimize(lambda y: y[k], np.concatenate([np.zeros(k), [z0]]), method="SLSQP",
                       constraints=[{"type": "ineq", "fun": cons}], options={"maxiter": 500, "ftol": 1e-16})
        q = p + sol.x[:k] * sc
        full = np.abs(geo.res(q, k3))
        p = q
        new = set(np.argsort(-full)[:25].tolist()) - act
        if full.max() <= sol.x[k] * (1 + 1e-7) + 1e-13 or not new:
            break
        act |= new
    return p, float(np.max(np.abs(geo.res(p, k3))))


def jacobian(geo, p, sc):
    J = np.empty((len(geo.tt), len(p)))
    for i in range(len(p)):
        d = np.zeros(len(p))
        d[i] = 1e-3 * sc[i]
        J[:, i] = wrap(geo.lon(p + d)[0] - geo.lon(p - d)[0]) / (2e-3)    # per unit of scaled coordinate
    return J


def hit_and_run(J, r0, delta, rng, n_keep, thin, burn, Wm):
    """uniform samples from {x : |r0 + J x| <= delta}; x = Wm z (whitening); returns x samples."""
    k = J.shape[1]
    JW = J @ Wm
    z = np.zeros(k)
    Jz = np.zeros(J.shape[0])
    keep = []
    total = burn + n_keep * thin
    for it in range(total):
        d = rng.standard_normal(k)
        d /= np.linalg.norm(d)
        a = JW @ d
        lo_b = -delta - r0 - Jz
        hi_b = delta - r0 - Jz
        with np.errstate(divide="ignore", invalid="ignore"):
            t1 = lo_b / a
            t2 = hi_b / a
        lo = np.where(a > 0, t1, t2)
        hi = np.where(a > 0, t2, t1)
        m = a != 0
        tlo, thi = lo[m].max(), hi[m].min()
        t = rng.uniform(tlo, thi)
        z = z + t * d
        Jz = Jz + t * a
        if it >= burn and (it - burn) % thin == 0:
            keep.append(Wm @ z)
    return np.array(keep)


def main():
    t0 = time.time()
    rng = np.random.default_rng(SEED)
    out("# rb5_k3_geocentric.py  seed=%d  numpy %s  pyerfa %s  python %s"
        % (SEED, np.__version__, erfa.__version__, sys.version.split()[0]))
    geo = Geo()
    out("  Mars best plane (ecliptic J2000): inclination %.4f deg, node %.3f deg (c4: 1.8828, 50.757)" % (geo.incl, geo.node))
    pE = helio_fit(geo.thE, geo.tt, 0.0167)
    pM = helio_fit(geo.thM, geo.tt, 0.093)
    p9 = np.concatenate([pE, pM, [1.5237]])
    s9 = least_squares(lambda y: geo.res(p9 + y * SC9) / ARC, np.zeros(9))
    p9 = p9 + s9.x * SC9
    p9, m9 = exchange(geo, p9, False, SC9)
    p8, m8 = exchange(geo, p9[:8].copy(), True, SC9[:8])
    rho_k3 = (p9[3] / p9[7]) ** (2 / 3)
    out("  minimax geocentric error: rho free %.4f' (rho = %.6f, K3 value from these periods %.6f); with K3 %.4f'"
        % (m9 / ARC, p9[8], rho_k3, m8 / ARC))
    out("  (c4: 0.627' with rho free, fitted rho = 1.523676 against the K3 value 1.523687; 0.632' with K3)")
    J = jacobian(geo, p9, SC9)
    r0 = geo.res(p9)
    C0 = np.linalg.inv(J.T @ J)
    out("  delta   s(delta) [bw 0.05 / 0.1 / 0.2 sd]   sd(y)        Gaussian check   exact-compatible share   (c4 s)")
    c4s = {8: 11.28, 4: 12.31, 2: 13.39, 1: 14.73}
    for dl in [8, 4, 2, 1]:
        delta = dl * ARC
        W0 = np.linalg.cholesky(C0) * delta * math.sqrt(len(geo.tt)) * 0.05
        pilot = hit_and_run(J, r0, delta, rng, 3000, 3, 2000, W0)
        Cs = np.cov(pilot.T) + 1e-30 * np.eye(9)
        Wm = np.linalg.cholesky(Cs)
        xs = hit_and_run(J, r0, delta, rng, 60000, 3, 3000, Wm)
        P = p9[None, :] + xs * SC9[None, :]
        y = P[:, 8] - (P[:, 3] / P[:, 7]) ** (2 / 3)
        sd = y.std()
        dens = []
        for bw in [0.05, 0.1, 0.2]:
            h = bw * sd
            dens.append(np.mean(np.exp(-0.5 * (y / h) ** 2)) / (h * math.sqrt(2 * math.pi)))
        s_vals = [math.log2(4 * d) for d in dens]
        gauss = math.log2(4 / (math.sqrt(2 * math.pi) * sd))
        sub = P[rng.choice(len(P), 1000, replace=False)]
        ok = np.mean(np.max(np.abs(wrap(geo.lon(sub) - geo.lam[None, :])), axis=1) <= delta)
        out("  %2d'    %.2f / %.2f / %.2f                  %.2e     %.2f            %.3f                    %.2f"
            % (dl, s_vals[0], s_vals[1], s_vals[2], sd, gauss, ok, c4s[dl]))
    out("  (c4's linearised-only variant, notes.md Verification log 3: 11.2, 12.5, 13.5, 14.9; c4 sd(y): 6.47e-4, 3.10e-4, 1.47e-4, 5.54e-5)")
    out("# done in %.0f s" % (time.time() - t0))


if __name__ == "__main__":
    main()
    with open(os.path.join(HERE, "rb5_k3_geocentric.out"), "w") as f:
        f.write("\n".join(OUT) + "\n")
