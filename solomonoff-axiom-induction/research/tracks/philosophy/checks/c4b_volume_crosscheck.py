"""c4b_volume_crosscheck.py -- an independent estimate of some of c4's compatible volumes.

Thread `philosophy`, T4 (notes.md section 4.4).  Seed 20261015.  Writes c4b_volume_crosscheck.out.

c4 estimates V_F(delta) by sampling in a parallelepiped built from the whitened linearisation at the
minimax point.  Where the compatible region is far from that linearisation (coarse delta: then the
vicarious hypothesis contains eccentric-like (e2 ~ 0), equant-like (e1 ~ e2) and, at 720', circle-like
(e1 ~ e2 ~ 0, any w) parts), the growth test of c4 may miss parts of the region.  This script
re-estimates the same volumes by hit-or-miss in an AXIS-ALIGNED box in element space whose
eccentricity coordinates span [0, e_max] and whose apsidal angle w spans the full circle when
delta >= 640.8' (the circle's minimax error, so that e = 0 is compatible) and w* +- 0.6 otherwise; the
mean longitude L and mean motion n get generous boxes.  A hit in the outer 2% of a face that is not
a prior-box cap makes the script enlarge that side and restart.  Same data, same model code (imported
from c4_mars_pool.py), same exact all-data hit test.
"""
import math
import sys
import time
import numpy as np
import c4_mars_pool as c

SEED = 20261015


def axis_volume(form, center, lo, hi, D, tt, th, rng, target=2000, max_samples=6_000_000, batch=20000):
    names = c.NAMES[form]
    caps = []
    for nm, x in zip(names, center):
        a, b = c.RANGE[nm]
        caps.append((x - np.pi, x + np.pi) if a is None else (a, b))
    lo, hi = np.array(lo, float), np.array(hi, float)
    hit_fn = c.make_hit_fn(lambda P, x: c.lon(form, P, x), tt, th, D)
    for rnd in range(8):
        lo = np.maximum(lo, [q[0] for q in caps])
        hi = np.minimum(hi, [q[1] for q in caps])
        width = hi - lo
        hits = n = 0
        near = np.zeros((len(lo), 2), bool)
        while hits < target and n < max_samples:
            U = rng.random((batch, len(lo)))
            P = lo + U * width
            h = hit_fn(P)
            hits += int(h.sum())
            n += batch
            if h.any():
                near[:, 0] |= (U[h] < 0.02).any(axis=0)
                near[:, 1] |= (U[h] > 0.98).any(axis=0)
        grow = False
        for i in range(len(lo)):
            if near[i, 0] and lo[i] > caps[i][0] + 1e-12:
                lo[i] -= 0.5 * width[i]
                grow = True
            if near[i, 1] and hi[i] < caps[i][1] - 1e-12:
                hi[i] += 0.5 * width[i]
                grow = True
        if not grow:
            vol = float(np.prod(width))
            f = hits / n
            return f * vol, vol * math.sqrt(max(f * (1 - f), 1e-300) / n), hits, n, rnd, lo, hi
    return None


def main():
    t0 = time.time()
    print("# c4b_volume_crosscheck.py  seed=%d  numpy %s  python %s" % (SEED, np.__version__, sys.version.split()[0]))
    t = np.arange((1580.0 - 2000.0) * c.YEAR, (1600.0 - 2000.0) * c.YEAR + 1e-9, 1.0)
    tt = t - 0.5 * (t[0] + t[-1])
    th, r, incl, node, oop = c.mars_helio_plane(t)
    N = len(t)
    n0 = c.TWO_PI / 686.98
    w0 = th[np.argmin(r)] % c.TWO_PI
    L0 = th[N // 2] % c.TWO_PI
    e0 = (r.max() - r.min()) / (r.max() + r.min())
    st = {"eccentric": [np.array([2 * e0, w0, L0, n0])], "equant": [np.array([e0, w0, L0, n0])],
          "vicarious": [np.array([1.2 * e0, 0.8 * e0, w0, L0, n0])], "ellipse": [np.array([e0, w0, L0, n0])]}
    rng = np.random.default_rng(SEED + 7)
    cases = [("vicarious", 720.0), ("vicarious", 120.0), ("vicarious", 60.0), ("vicarious", 30.0),
             ("ellipse", 720.0), ("eccentric", 720.0), ("equant", 120.0)]
    fits = {}
    print("%-10s %7s %10s %8s %8s %9s %5s  %s" % ("form", "delta'", "C_F bits", "+-se", "hits", "samples", "grow",
                                                 "axis box"))
    for form, d in cases:
        if form not in fits:
            fits[form] = c.fit_minimax(form, tt, th, st[form])
        p, mx = fits[form]
        D = d * c.ARCMIN
        names = c.NAMES[form]
        lo, hi = [], []
        for nm, x in zip(names, p):
            if nm in ("e", "e1", "e2"):
                lo.append(0.0)
                hi.append(1.0 if d >= 640.8 else min(1.0, 3 * x + 0.05))
            elif nm == "w":
                lo.append(x - (np.pi if d >= 640.8 else 0.6))
                hi.append(x + (np.pi if d >= 640.8 else 0.6))
            elif nm == "L":
                span = 0.5 if d >= 640.8 else 0.08 * max(d / 120.0, 0.3)
                lo.append(x - span)
                hi.append(x + span)
            else:  # n
                span = 1e-4 if d >= 640.8 else 2e-5 * max(d / 120.0, 0.3)
                lo.append(x - span)
                hi.append(x + span)
        out = axis_volume(form, p, lo, hi, D, tt, th, rng)
        if out is None:
            print("%-10s %7g  (did not converge)" % (form, d))
            continue
        V, se, hits, n, rnd, blo, bhi = out
        prior = 1.0
        for nm in names:
            a, b = c.RANGE[nm]
            prior *= (c.TWO_PI if a is None else b - a)
        C = -math.log2(V / prior)
        box = "; ".join("%s %.4g..%.4g" % (nm, a, b) for nm, a, b in zip(names, blo, bhi))
        print("%-10s %7g %10.2f %8.2f %8d %9d %5d  %s" % (form, d, C, se / V / math.log(2), hits, n, rnd, box))
        sys.stdout.flush()
    print("# compare with c4_mars_pool.out table A2 (same definition of C_F).")
    print("# done in %.0f s" % (time.time() - t0))


if __name__ == "__main__":
    main()
