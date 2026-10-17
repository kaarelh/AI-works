"""rb3_mars_pool.py -- referee B for thread `philosophy`: independent re-computation of parts of
notes.md section 4.4 (c4 Part A, c4b, c8) with code written from the record's description, not from
c4/c4b/c8.  Seed 20261016.  Appends to rb3_mars_pool.out next to itself (each part writes when done).

Data pipeline (own): ERFA plan94 heliocentric J2000 equatorial positions of Mars at the 7306 days
t = -153405 .. -146100 (days from J2000; 1580.0 .. 1600.0 as Julian epochs); best plane through the
Sun by SVD (sign: angular momentum along the normal); in-plane longitude measured from an in-plane
axis of my own choice (a constant offset relative to c4, absorbed by L and w); in-plane distance.

Forms (geometric definitions, as in rb2): circle; eccentric (centre -e u(w)); bisected equant (centre
-e u(w), equant -2e u(w)); vicarious (centre -e1 u(w), equant -(e1+e2) u(w)); ellipse (Kepler).  Mean
longitude L(t) = L + n (t - t_mid).  Prior box: e, e1, e2 in [0,1); w, L in [0, 2pi); n in [0, 0.1).
Also "equant32": the family that c4's S1/S3 equant TEXT describes (centre 2e, equant 3e; see rb2).

Parts (python rb3_mars_pool.py PART):
  fit     minimax fits of the five forms (+ equant32) by an exchange algorithm with SLSQP on active sets
          (own method), from several least-squares starts; the circle exactly (1-D convex problem)
  circle  the circle's Occam factor at 720' exactly (1-D integral of the L-interval length)
  occam   hit-or-miss Occam factors with adaptively grown boxes (own explorer by a uniform random walk
          inside the region): the three cases c4b did not finish (ellipse 720', eccentric 720',
          equant 120') and two cases with c4 values for calibration (ellipse 120', ellipse 60')
  dist    distances as data (c8): ellipse at its longitude minimax; vicarious constrained minimax at
          tau = 2%, 1%, 0.5% from several starts (own SLSQP exchange); equant at its minimax
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
OUTFILE = os.path.join(HERE, "rb3_mars_pool.out")
ARCMIN = math.pi / (180 * 60)
TWO_PI = 2 * math.pi
LINES = []


def out(*a):
    s = " ".join(str(x) for x in a)
    LINES.append(s)
    print(s, flush=True)


def flush_out():
    with open(OUTFILE, "a") as f:
        f.write("\n".join(LINES) + "\n")
    LINES.clear()


# ------------------------------------------------------------------------------------------- data
def load():
    t = np.arange(-153405.0, -146100.0 + 0.5, 1.0)
    pv = erfa.plan94(2451545.0 + 0.0 * t, t, 4)
    p = pv["p"]
    v = pv["v"]
    _, _, vt = np.linalg.svd(p, full_matrices=False)
    nrm = vt[2]
    if np.mean(np.cross(p, v) @ nrm) < 0:
        nrm = -nrm
    ex = np.array([1.0, 0.0, 0.0]) - nrm[0] * nrm
    ex /= np.linalg.norm(ex)
    ey = np.cross(nrm, ex)
    x, y, z = p @ ex, p @ ey, p @ nrm
    th = np.unwrap(np.arctan2(y, x))
    r = np.hypot(x, y)
    tmid = 0.5 * (t[0] + t[-1])
    return t - tmid, th, r, float(np.max(np.abs(z) / np.linalg.norm(p, axis=1)))


NAMES = {"circle": ["L", "n"], "eccentric": ["e", "w", "L", "n"], "equant": ["e", "w", "L", "n"],
         "equant32": ["e", "w", "L", "n"], "vicarious": ["e1", "e2", "w", "L", "n"],
         "ellipse": ["e", "w", "L", "n"]}
PRIOR = {"e": (0.0, 1.0), "e1": (0.0, 1.0), "e2": (0.0, 1.0), "w": (0.0, TWO_PI), "L": (0.0, TWO_PI),
         "n": (0.0, 0.1)}


def kepler_E(M, e):
    E = M + e * np.sin(M)
    for _ in range(25):
        dE = (E - e * np.sin(E) - M) / (1 - e * np.cos(E))
        E = E - np.clip(dE, -0.5, 0.5)
    return E


def model(form, P, tt):
    """P: (B,k); returns (theta (B,N), distance (B,N))."""
    P = np.atleast_2d(P)
    col = lambda i: P[:, i:i + 1]  # noqa: E731
    if form == "circle":
        L, n = col(0), col(1)
        th = L + n * tt
        return th, np.ones_like(th)
    if form == "ellipse":
        e, w, L, n = col(0), col(1), col(2), col(3)
        M = L + n * tt - w
        E = kepler_E(M, e)
        nu = 2 * np.arctan2(np.sqrt(1 + e) * np.sin(E / 2), np.sqrt(1 - e) * np.cos(E / 2))
        return w + nu, 1 - e * np.cos(E)
    if form == "vicarious":
        c, d, w, L, n = col(0), col(1), col(2), col(3), col(4)
    else:
        e, w, L, n = col(0), col(1), col(2), col(3)
        c, d = {"eccentric": (e, 0 * e), "equant": (e, e), "equant32": (2 * e, e)}[form]
    Lt = L + n * tt
    M = Lt - w
    s = d * np.cos(M) + np.sqrt(np.maximum(1 - (d * np.sin(M)) ** 2, 0.0))
    q = c + d
    X = -q * np.cos(w) + s * np.cos(Lt)
    Y = -q * np.sin(w) + s * np.sin(Lt)
    return np.arctan2(Y, X), np.hypot(X, Y)


def wrap(x):
    return (x + np.pi) % TWO_PI - np.pi


def lonres(form, p, tt, th):
    return wrap(model(form, p, tt)[0][0] - th)


# ------------------------------------------------------------------------------------- fitting
SCALE = {"e": 1e-2, "e1": 1e-2, "e2": 1e-2, "w": 1e-2, "L": 1e-3, "n": 1e-6}


def exchange_minimax(form, p0, tt, th, extra=None, iters=40):
    """min max_i |lon res_i| (and, if extra = (r, tau), subject to the distance spread constraint)."""
    names = NAMES[form]
    sc = np.array([SCALE[k] for k in names])
    k = len(p0)
    N = len(tt)
    act = set(np.argsort(-np.abs(lonres(form, p0, tt, th)))[:40].tolist()) | set(range(0, N, 365))
    dact = set()
    if extra is not None:
        r, tau = extra
        lim = math.log((1 + tau) / (1 - tau))
        u0 = np.log(model(form, p0, tt)[1][0] / r)
        dact = set(np.argsort(u0)[:20].tolist()) | set(np.argsort(-u0)[:20].tolist())
    p = np.array(p0, float)
    best = None
    for it in range(iters):
        A = np.array(sorted(act))
        D = np.array(sorted(dact)) if dact else None

        def unpack(y):
            return p + y[:k] * sc, y[k]

        def obj(y):
            return y[k]

        def cons(y):
            q, z = unpack(y)
            rr = lonres(form, q, tt[A], th[A])
            cs = [z - rr, z + rr]
            if D is not None:
                uu = np.log(model(form, q, tt[D])[1][0] / r[D])
                a_, b_ = y[k + 1], y[k + 2]
                cs += [b_ - uu, uu - a_, np.array([lim - (b_ - a_)])]
            return np.concatenate(cs)
        z0 = np.max(np.abs(lonres(form, p, tt[A], th[A])))
        y0 = np.concatenate([np.zeros(k), [z0]])
        if D is not None:
            uu = np.log(model(form, p, tt[D])[1][0] / r[D])
            y0 = np.concatenate([y0, [uu.min(), uu.max()]])
        sol = minimize(obj, y0, method="SLSQP", constraints=[{"type": "ineq", "fun": cons}],
                       options={"maxiter": 500, "ftol": 1e-15})
        q, z = unpack(sol.x)
        full = np.abs(lonres(form, q, tt, th))
        feas_d = True
        if extra is not None:
            uu = np.log(model(form, q, tt)[1][0] / r)
            spread = uu.max() - uu.min()
            feas_d = spread <= lim * (1 + 1e-9)
        if feas_d and (best is None or full.max() < best[1]):
            best = (q.copy(), full.max())
        p = q
        newl = set(np.argsort(-full)[:25].tolist()) - act
        grew = False
        if full.max() > z * (1 + 1e-7) + 1e-12 and newl:
            act |= newl
            grew = True
        if extra is not None:
            newd = (set(np.argsort(uu)[:10].tolist()) | set(np.argsort(-uu)[:10].tolist())) - dact
            if spread > lim * (1 + 1e-9) and newd:
                dact |= newd
                grew = True
        if not grew:
            break
    return best


def lsq_fit(form, p0, tt, th):
    names = NAMES[form]
    sc = np.array([SCALE[k] for k in names])
    f = lambda y: lonres(form, p0 + y * sc, tt, th) / ARCMIN  # noqa: E731
    sol = least_squares(f, np.zeros(len(p0)), method="lm", x_scale=1.0)
    return p0 + sol.x * sc


def circle_exact(tt, th):
    """the circle: spread(n) = max(th - n t) - min(th - n t) is convex; minimax = min spread / 2."""
    def spread(n):
        d = th - n * tt
        return d.max() - d.min()
    lo, hi = 0.0, 0.1
    n0 = np.polyfit(tt, th, 1)[0]
    lo, hi = n0 - 1e-4, n0 + 1e-4
    for _ in range(200):
        a = lo + (hi - lo) / 3
        b = hi - (hi - lo) / 3
        if spread(a) < spread(b):
            hi = b
        else:
            lo = a
    nb = 0.5 * (lo + hi)
    return nb, spread(nb) / 2, spread


def starts(form, tt, th):
    n0, _, _ = circle_exact(tt, th)
    L0 = float(np.mean(th - n0 * tt)) % TWO_PI
    S = []
    for w in np.linspace(0, TWO_PI, 8, endpoint=False):
        if form == "circle":
            return [np.array([L0, n0])]
        if form == "vicarious":
            for (a, b) in [(0.1, 0.07), (0.09, 0.09), (0.18, 0.0)]:
                S.append(np.array([a, b, w, L0, n0]))
        else:
            e = 0.18 if form == "eccentric" else (0.06 if form == "equant32" else 0.09)
            S.append(np.array([e, w, L0, n0]))
    return S


def part_fit(tt, th, r):
    out("== fit: minimax errors (arcmin) by own exchange algorithm; c4 table A1 for comparison")
    c4v = {"circle": 640.7908, "eccentric": 23.0508, "equant": 8.1653, "vicarious": 1.4127, "ellipse": 1.0733}
    fits = {}
    nb, half, _ = circle_exact(tt, th)
    L0 = float(0.5 * ((th - nb * tt).max() + (th - nb * tt).min())) % TWO_PI
    fits["circle"] = (np.array([L0, nb]), half)
    out("  circle     exact 1-D: %.4f'   (c4 %.4f')   n=%.8f" % (half / ARCMIN, c4v["circle"], nb))
    for form in ["eccentric", "equant", "vicarious", "ellipse", "equant32"]:
        best = None
        for s0 in starts(form, tt, th):
            try:
                p1 = lsq_fit(form, s0, tt, th)
            except Exception:
                continue
            ls = np.max(np.abs(lonres(form, p1, tt, th)))
            if best is not None and ls > 3 * best[1]:
                continue
            res = exchange_minimax(form, p1, tt, th)
            if res is not None and (best is None or res[1] < best[1]):
                best = res
        fits[form] = best
        els = ", ".join("%s=%.6g" % (k, v) for k, v in zip(NAMES[form], best[0]))
        out("  %-10s %.4f'   (c4 %s)   %s" % (form, best[1] / ARCMIN,
                                              ("%.4f'" % c4v[form]) if form in c4v else "n/a: S1 text's family", els))
    np.save(os.path.join(HERE, "rb3_fits.npy"), {k: (v[0], v[1]) for k, v in fits.items()}, allow_pickle=True)
    return fits


# ------------------------------------------------------------------------------ Occam factors
def part_circle(tt, th):
    out("== circle: exact Occam factor at 720' (integral over n of the length of the compatible L-interval)")
    nb, half, spread = circle_exact(tt, th)
    delta = 720 * ARCMIN
    # the compatible n-interval: spread(n) <= 2 delta; spread is convex
    def edge(sign):
        lo, hi = nb, nb + sign * 1e-3
        for _ in range(200):
            mid = 0.5 * (lo + hi)
            if spread(mid) <= 2 * delta:
                lo = mid
            else:
                hi = mid
        return lo
    a, b = edge(-1), edge(+1)
    ns = np.linspace(a, b, 200001)
    vals = np.array([max(0.0, 2 * delta - spread(n)) for n in ns])
    V = float(np.sum(0.5 * (vals[1:] + vals[:-1]) * np.diff(ns)))
    C = -math.log2(V / (TWO_PI * 0.1))
    out("  n-interval [%.8f, %.8f]; V = %.6e rad^2/day; C_circle(720') = %.3f bits (c4: 20.93 +- 0.02)" % (a, b, V, C))


def hit_fn(form, tt, th, delta, coarse_step=25):
    idx = np.arange(0, len(tt), coarse_step)

    def hit(P):
        P = np.atleast_2d(P)
        ok = np.ones(len(P), bool)
        names = NAMES[form]
        for j, kname in enumerate(names):
            lo, hi = PRIOR[kname]
            ok &= (P[:, j] >= lo) & (P[:, j] < hi)
        if not ok.any():
            return ok
        sel = np.where(ok)[0]
        m1 = np.max(np.abs(wrap(model(form, P[sel], tt[idx])[0] - th[idx])), axis=1) <= delta
        ok[sel[~m1]] = False
        sel = sel[m1]
        if len(sel):
            m2 = np.max(np.abs(wrap(model(form, P[sel], tt)[0] - th)), axis=1) <= delta
            ok[sel[~m2]] = False
        return ok
    return hit


def explore(form, p0, hit, rng, nsteps=6000):
    """uniform random walk inside the region from p0 (indicator Metropolis); returns visited points."""
    names = NAMES[form]
    step = np.array([SCALE[k] for k in names]) * 2.0
    x = np.array(p0, float)
    pts = [x.copy()]
    acc = 0
    for i in range(nsteps):
        y = x + step * rng.standard_normal(len(x))
        if hit(y[None, :])[0]:
            x = y
            acc += 1
        pts.append(x.copy())
        if (i + 1) % 200 == 0:
            rate = acc / 200
            step *= 1.6 if rate > 0.4 else (0.6 if rate < 0.15 else 1.0)
            acc = 0
    return np.array(pts)


def occam(form, delta_arcmin, p0, tt, th, rng, target=2000, chunk=20000, max_samples=40_000_000, full_w=False):
    delta = delta_arcmin * ARCMIN
    hit = hit_fn(form, tt, th, delta)
    names = NAMES[form]
    pts = explore(form, p0, hit, rng)
    lo = pts.min(axis=0)
    hi = pts.max(axis=0)
    span = hi - lo
    lo = lo - 0.5 * span
    hi = hi + 0.5 * span
    for j, kname in enumerate(names):
        plo, phi = PRIOR[kname]
        if kname in ("w",) and (full_w or hi[j] - lo[j] > 0.8 * TWO_PI):
            lo[j], hi[j] = 0.0, TWO_PI
        if kname in ("e", "e1", "e2"):
            lo[j] = max(lo[j], plo) if not full_w else plo
            hi[j] = min(hi[j], phi)
    grows = 0
    while True:
        boxvol = float(np.prod(hi - lo))
        hits = 0
        n = 0
        H = []
        while hits < target and n < max_samples:
            P = lo + (hi - lo) * rng.random((chunk, len(names)))
            # w is periodic: sample in the box and fold into [0, 2pi)
            for j, kname in enumerate(names):
                if kname in ("w", "L"):
                    P[:, j] = P[:, j] % TWO_PI
            ok = hit(P)
            hits += int(ok.sum())
            n += chunk
            if ok.any():
                H.append(P[ok])
        H = np.concatenate(H) if H else np.zeros((0, len(names)))
        # faces: a non-cap face with hits in its outer 2% is grown by 50% of the span on that side
        grew = False
        if len(H):
            span = hi - lo
            for j, kname in enumerate(names):
                if kname == "w" and hi[j] - lo[j] >= TWO_PI - 1e-12:
                    continue
                Hj = H[:, j].copy()
                if kname in ("w", "L"):
                    Hj = lo[j] + (Hj - lo[j]) % TWO_PI
                cap_lo = kname in ("e", "e1", "e2") and lo[j] <= PRIOR[kname][0] + 1e-15
                cap_hi = kname in ("e", "e1", "e2") and hi[j] >= PRIOR[kname][1] - 1e-15
                if not cap_lo and np.any(Hj < lo[j] + 0.02 * span[j]):
                    lo[j] -= 0.5 * span[j]
                    grew = True
                if not cap_hi and np.any(Hj > hi[j] - 0.02 * span[j]):
                    hi[j] += 0.5 * span[j]
                    grew = True
                if kname in ("e", "e1", "e2"):
                    lo[j] = max(lo[j], PRIOR[kname][0])
                    hi[j] = min(hi[j], PRIOR[kname][1])
                if kname == "w" and hi[j] - lo[j] > 0.8 * TWO_PI:
                    lo[j], hi[j] = 0.0, TWO_PI
        if not grew or grows >= 6:
            break
        grows += 1
    frac = hits / n
    prior = float(np.prod([PRIOR[k][1] - PRIOR[k][0] for k in names]))
    V = frac * boxvol
    C = -math.log2(V / prior)
    se = 1 / math.sqrt(max(hits, 1)) / math.log(2)
    return C, se, hits, n, grows, list(zip(names, lo, hi))


def part_occam(tt, th, fits):
    rng = np.random.default_rng(SEED + 3)
    out("== occam: hit-or-miss Occam factors (bits), own adaptive boxes; c4 / c4b values for comparison")
    cases = [("ellipse", 720, "c4 21.18 (c4b not obtained)"), ("eccentric", 720, "c4 20.24 (c4b not obtained)"),
             ("equant", 120, "c4 31.70 (c4b not obtained)"), ("ellipse", 120, "c4 31.63"),
             ("ellipse", 60, "c4 35.68")]
    for form, d, ref in cases:
        t0 = time.time()
        C, se, hits, n, grows, box = occam(form, d, fits[form][0], tt, th, rng)
        bx = "; ".join("%s %.4g..%.4g" % (k, a, b) for k, a, b in box)
        out("  %-9s %4d'  C = %.2f +- %.2f  (%d hits / %d samples, %d grows, %.0f s)  [%s]  box: %s"
            % (form, d, C, se, hits, n, grows, time.time() - t0, ref, bx))
        flush_out()


# ---------------------------------------------------------------------------------- distances
def part_occam720(tt, th, fits):
    """the 720' cases again with the apsidal angle w forced to its full range and e from 0: at 720' the
    compatible region contains every w for small e (the circle fits to 640.8'), which an explored box can miss."""
    rng = np.random.default_rng(SEED + 7)
    out("== occam720: 720' cases with w over its full range and e from 0 (target 4000 hits)")
    for form, ref in [("ellipse", "c4 21.18"), ("eccentric", "c4 20.24"), ("equant", "c4 21.20")]:
        t0 = time.time()
        C, se, hits, n, grows, box = occam(form, 720, fits[form][0], tt, th, rng, target=4000, full_w=True)
        bx = "; ".join("%s %.4g..%.4g" % (k, a, b) for k, a, b in box)
        out("  %-9s  720'  C = %.2f +- %.2f  (%d hits / %d samples, %d grows, %.0f s)  [%s]  box: %s"
            % (form, C, se, hits, n, grows, time.time() - t0, ref, bx))
        flush_out()


def part_dist(tt, th, r, fits):
    out("== dist: distances as data (c8)")
    for form in ["ellipse", "equant", "vicarious", "eccentric"]:
        p, m = fits[form]
        d = model(form, p, tt)[1][0]
        u = np.log(d / r)
        R = math.exp(u.max() - u.min())
        out("  %-9s at its longitude minimax (%.3f'): least relative distance tolerance with the best scale"
            " = %.4f%%" % (form, m / ARCMIN, 100 * (R - 1) / (R + 1)))
    out("  c8: ellipse fits both at 1.07' for every tau >= 0.05%; equant at 8.17' for tau >= 0.5%")
    # vicarious constrained minimax
    rng = np.random.default_rng(SEED + 5)
    pv = fits["vicarious"][0]
    pe = fits["equant"][0]
    for tau, ref in [(0.02, "2.01'"), (0.01, "6.31'"), (0.005, "6.95'")]:
        results = []
        st = [pv, np.array([pe[0], pe[0], pe[1], pe[2], pe[3]])]
        for _ in range(6):
            q = pv.copy()
            q[0] += rng.uniform(-0.03, 0.03)
            q[1] += rng.uniform(-0.03, 0.03)
            q[2] += rng.uniform(-0.05, 0.05)
            st.append(q)
        for s0 in st:
            s0 = s0.copy()
            s0[0] = abs(s0[0])
            s0[1] = abs(s0[1])
            try:
                res = exchange_minimax("vicarious", s0, tt, th, extra=(r, tau), iters=60)
            except Exception as ex:   # noqa: BLE001
                res = None
            if res is not None:
                results.append(res[1] / ARCMIN)
        best = min(results) if results else float("nan")
        out("  vicarious tau=%.1f%%: best longitude tolerance found %.3f' over %d of %d starts (c8 %s); all: %s"
            % (100 * tau, best, len(results), len(st), ref, " ".join("%.2f" % x for x in sorted(results))))
        flush_out()


def main():
    part = sys.argv[1] if len(sys.argv) > 1 else "fit"
    tt, th, r, zmax = load()
    out("# rb3_mars_pool.py part=%s  seed=%d  numpy %s  pyerfa %s  python %s"
        % (part, SEED, np.__version__, erfa.__version__, sys.version.split()[0]))
    out("# data: N=%d days; largest out-of-plane angle %.3f arcmin" % (len(tt), math.degrees(zmax) * 60))
    if part == "fit":
        part_fit(tt, th, r)
    else:
        fits = np.load(os.path.join(HERE, "rb3_fits.npy"), allow_pickle=True).item()
        # normalise the mirror solutions (e < 0, w) -> (-e, w + pi) and angles into [0, 2pi)
        for form, (p, m) in list(fits.items()):
            p = np.array(p, float)
            names = NAMES[form]
            if names[0] == "e" and p[0] < 0:
                p[0] = -p[0]
                p[1] += math.pi
            for j, kname in enumerate(names):
                if kname in ("w", "L"):
                    p[j] %= TWO_PI
            assert abs(np.max(np.abs(lonres(form, p, tt, th))) - m) < 1e-9, form
            fits[form] = (p, m)
        if part == "circle":
            part_circle(tt, th)
        elif part == "occam":
            part_occam(tt, th, fits)
        elif part == "occam720":
            part_occam720(tt, th, fits)
        elif part == "dist":
            part_dist(tt, th, r, fits)
    out("# part %s done" % part)
    flush_out()


if __name__ == "__main__":
    main()
