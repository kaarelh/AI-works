"""c8_mars_distances.py -- the historical Mars pool when distances are data too (thread `philosophy`, T4).

Deterministic.  Writes c8_mars_distances.out next to itself.

c4 uses longitude data only.  Kepler's rejection of his vicarious hypothesis came from distances
(scout P Table 2.2, c2 part (C)).  Here the data are longitudes "theta(t_i) within delta of v_i" AND
distances "r(t_i) within a factor 1 +- tau of r_i" (plan94, 1580.0-1600.0 daily, best plane, as in c2/c4).
For each form and distance tolerance tau we compute, by sequential linear programming,
    lon*(tau) := min over elements and scale of max_i |dlon_i|  subject to  max_i |s r_model,i / r_i - 1| <= tau,
the least longitude tolerance at which the form is compatible with both kinds of data ("infeasible" if no
elements meet the distance tolerance).  Also r*(form) := min max_i |s r_model,i / r_i - 1| (no longitude
constraint).  Minima are upper bounds witnessed by explicit elements (local optimisation from the c4
longitude-minimax elements and from the distance-minimax elements; not proved global).
"""
import sys
import numpy as np
import erfa
import scipy
from scipy.optimize import linprog

JD2000 = 2451545.0
YEAR = 365.25
EPS0 = np.deg2rad(84381.448 / 3600.0)
ARCMIN = np.pi / (180 * 60)
TWO_PI = 2 * np.pi
OUT = []


def p(*a):
    s = " ".join(str(x) for x in a)
    OUT.append(s)
    print(s)


def wrap(x):
    return (x + np.pi) % TWO_PI - np.pi


def data():
    t = np.arange((1580.0 - 2000.0) * YEAR, (1600.0 - 2000.0) * YEAR + 1e-9, 1.0)
    pv = erfa.plan94(JD2000 + 0 * t, t, 4)["p"]
    c, s = np.cos(EPS0), np.sin(EPS0)
    q = np.stack([pv[:, 0], c * pv[:, 1] + s * pv[:, 2], -s * pv[:, 1] + c * pv[:, 2]], axis=1)
    _, _, vt = np.linalg.svd(q, full_matrices=False)
    nrm = vt[2] if vt[2][2] > 0 else -vt[2]
    ex = np.cross([0, 0, 1.0], nrm)
    ex /= np.linalg.norm(ex)
    ey = np.cross(nrm, ex)
    x, y = q @ ex, q @ ey
    return t - 0.5 * (t[0] + t[-1]), np.unwrap(np.arctan2(y, x)), np.hypot(x, y)


def kepler_E(M, e):
    E = M + e * np.sin(M)
    for _ in range(60):
        dE = (E - e * np.sin(E) - M) / (1 - e * np.cos(E))
        E -= dE
        if np.max(np.abs(dE)) < 1e-15:
            break
    return E


def model(form, q, tt):
    """q = elements + [scale]; returns (longitude, distance)."""
    *el, sc = q
    if form == "ellipse":
        e, w, L, n = el
        M = L + n * tt - w
        E = kepler_E(M, e)
        nu = 2 * np.arctan2(np.sqrt(1 + e) * np.sin(E / 2), np.sqrt(1 - e) * np.cos(E / 2))
        return w + nu, sc * (1 - e * np.cos(E))
    if form == "vicarious":
        e1, e2, w, L, n = el
    else:
        e, w, L, n = el
        e1, e2 = (e, 0.0) if form == "eccentric" else (e, e)
    Lt = L + n * tt
    M = Lt - w
    s = e2 * np.cos(M) + np.sqrt(1 - (e2 * np.sin(M)) ** 2)
    X = -(e1 + e2) * np.cos(w) + s * np.cos(Lt)
    Y = -(e1 + e2) * np.sin(w) + s * np.sin(Lt)
    return np.arctan2(Y, X), sc * np.hypot(X, Y)


def residuals(form, q, tt, th, r):
    lo, di = model(form, q, tt)
    return wrap(lo - th), di / r - 1


def jac(form, q, tt, th, r):
    k = len(q)
    JL, JR = np.empty((len(tt), k)), np.empty((len(tt), k))
    for i in range(k):
        h = 1e-7 * (1e-3 if i == k - 2 else 1.0)       # n is the last element before the scale
        dq = np.zeros(k)
        dq[i] = h
        a1, b1 = residuals(form, q + dq, tt, th, r)
        a0, b0 = residuals(form, q - dq, tt, th, r)
        JL[:, i], JR[:, i] = wrap(a1 - a0) / (2 * h), (b1 - b0) / (2 * h)
    return JL, JR


def slp(form, q, tt, th, r, tau=None, iters=80):
    """tau None: minimise max |dr/r|.  Otherwise minimise max |dlon| s.t. max |dr/r| <= tau
    (phase 1 first if infeasible).  Returns (q, max|dlon|, max|dr/r|, feasible)."""
    k = len(q)
    tr = np.array([1e-3] * k)
    tr[k - 2] = 1e-7

    def score(qq):
        a, b = residuals(form, qq, tt, th, r)
        return np.max(np.abs(a)), np.max(np.abs(b))

    def objective(qq, phase):
        a, b = score(qq)
        if phase == 1:
            return b
        return a if b <= tau + 1e-12 else np.inf

    phase = 1 if tau is None or score(q)[1] > tau else 2
    cur = objective(q, phase)
    for _ in range(iters):
        JL, JR = jac(form, q, tt, th, r)
        a0, b0 = residuals(form, q, tt, th, r)
        N = len(tt)
        c = np.zeros(k + 1)
        c[-1] = 1
        if phase == 1:
            A = np.vstack([np.hstack([JR, -np.ones((N, 1))]), np.hstack([-JR, -np.ones((N, 1))])])
            b = np.concatenate([-b0, b0])
        else:
            A = np.vstack([np.hstack([JL, -np.ones((N, 1))]), np.hstack([-JL, -np.ones((N, 1))]),
                           np.hstack([JR, np.zeros((N, 1))]), np.hstack([-JR, np.zeros((N, 1))])])
            b = np.concatenate([-a0, a0, tau - b0, tau + b0])
        sol = linprog(c, A_ub=A, b_ub=b, bounds=[(-tr[i], tr[i]) for i in range(k)] + [(0, None)], method="highs")
        if sol.status == 0:
            qn = q + sol.x[:k]
            new = objective(qn, phase)
            if new < cur - 1e-15:
                q, cur = qn, new
                tr *= 1.5
                if phase == 1 and tau is not None and score(q)[1] <= tau:
                    phase = 2
                    cur = objective(q, 2)
                continue
        tr /= 2
        if np.all(tr < 1e-14):
            break
    a, b = score(q)
    return q, a, b, (tau is None) or (b <= tau + 1e-12)


def main():
    p("# c8_mars_distances.py  numpy %s  scipy %s  pyerfa %s  python %s (deterministic)"
      % (np.__version__, scipy.__version__, erfa.__version__, sys.version.split()[0]))
    tt, th, r = data()
    # starting elements: the c4 longitude-minimax elements (printed in c4_mars_pool.out, table A1), scale 1.5237
    L0 = np.deg2rad(309.446)
    starts = {"eccentric": [0.184516, np.deg2rad(283.471), np.deg2rad(309.448), 0.0091461],
              "equant": [0.0933767, np.deg2rad(283.465), L0, 0.00914613],
              "vicarious": [0.115724, 0.0707907, np.deg2rad(283.462), L0, 0.00914609],
              "ellipse": [0.0930389, np.deg2rad(283.445), np.deg2rad(309.442), 0.00914609]}
    taus = [0.10, 0.05, 0.02, 0.01, 0.005, 0.002, 0.001, 0.0005]
    p("data: plan94 Mars 1580.0-1600.0 daily (N = %d), longitudes and distances in the best plane" % len(tt))
    p("%-10s %12s   " % ("form", "r* (no lon)") + " ".join("%10s" % ("tau=%g" % t) for t in taus))
    extra = {"vicarious": [[0.0933767, 0.0933767, np.deg2rad(283.465), L0, 0.00914613],      # bisected (equant-like)
                           [0.09317, 0.09332, np.deg2rad(283.465), L0, 0.00914612]]}         # c2 (C) joint fit (approx.)
    for form, st in starts.items():
        q0 = np.array(st + [1.5237])
        _, di = model(form, q0, tt)
        q0[-1] = np.sum(di / q0[-1] * r) / np.sum((di / q0[-1]) ** 2)
        qd, _, rstar, _ = slp(form, q0.copy(), tt, th, r, None)
        others = []
        for ex in extra.get(form, []):
            qe = np.array(ex + [q0[-1]])
            others.append(qe)
        raw, prev = [], None
        for tau in taus:                                   # decreasing tau: continuation from the previous optimum
            best, bq = None, None
            cand = [q0.copy(), qd.copy()] + [o.copy() for o in others] + ([prev.copy()] if prev is not None else [])
            for qs in cand:
                q, a, b, ok = slp(form, qs, tt, th, r, tau)
                if ok and (best is None or a < best):
                    best, bq = a, q
            raw.append(best)
            if bq is not None:
                prev = bq
        # monotone envelope: a solution feasible at tau' <= tau is feasible at tau
        env = []
        for i in range(len(taus)):
            vals = [v for v in raw[i:] if v is not None]
            env.append(min(vals) if vals else None)
        cells = ["%10s" % ("infeas." if v is None else "%.2f'" % (v / ARCMIN)) for v in env]
        rawc = ["%10s" % ("-" if v is None else "%.2f'" % (v / ARCMIN)) for v in raw]
        p("%-10s %12.2e   " % (form, rstar) + " ".join(cells))
        p("%-10s %12s   " % ("  (raw)", "") + " ".join(rawc))
        sys.stdout.flush()
    p("# entry: least longitude tolerance (arcmin) found at which the form, with suitable elements and scale, proves")
    p("# all longitude data and all distance data at relative tolerance tau ('infeas.': no elements found meeting tau).")
    p("# Rows are the monotone envelope (a solution feasible at a smaller tau is feasible at a larger one) of the raw")
    p("# local optima, which are printed below each row; starts: c4 longitude minimax, distance minimax, the")
    p("# previous tau's optimum, and for the vicarious hypothesis also the bisected and c2 (C) elements.")
    p("# done")
    with open(__file__.replace(".py", ".out"), "w") as f:
        f.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
