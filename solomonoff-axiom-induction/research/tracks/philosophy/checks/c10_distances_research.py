"""c10_distances_research.py -- revision check for notes-final.md section 4.4 Part C (thread `philosophy`).

Seed 20261016 (random starts only).  Writes c10_distances_research.out next to itself.

Referee B (issue 1) found that c8's table is not a table of least tolerances: at distance tolerance 1% the
vicarious hypothesis is compatible with the longitude data at 5.119' (c8: 6.31'), and three more cells
(vicarious 0.1%, 0.05%; eccentric 5%) are not minimal.  This script
  (1) re-checks the referee's witnessing elements (printed in referee_code/rb3b_distances.out, 6 decimals)
      with c8's own data() and residuals();
  (2) runs a wider search with c8's sequential-LP optimiser slp(): for each distance tolerance tau, starts at
      c8's starts, at the referee's witness for that tau and two perturbations of it (each with the scale
      re-optimised, since the printed elements are rounded to 6 decimals, which alone costs about 1' in
      longitude through n), at the previous tau's optimum (a decreasing and then an increasing sweep), and at
      6 seeded random starts;
  (3) prints, for each cell, the least longitude tolerance found by any of c8, rb3b (re-checked) and this
      search, with the witnessing elements and scale, re-checked with c8's residuals().
Every entry is an UPPER BOUND on the least longitude tolerance (witnessed by explicit elements); no entry is
proved minimal.
"""
import os
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import c8_mars_distances as c8  # noqa: E402

SEED = 20261016
ARC = c8.ARCMIN
OUT = []
T0 = time.time()


def out(*a):
    s = " ".join(str(x) for x in a)
    OUT.append(s)
    print(s, flush=True)


# referee B's witnesses (rb3b_distances.out; c8's frame; e's, w, L, n, scale), 6 decimals as printed
RB3B = {
    "vicarious": {
        0.05: [0.115724, 0.070791, -1.335839, -0.882341, 0.009146, 1.526950],
        0.02: [0.112726, 0.073827, -1.335813, -0.882321, 0.009146, 1.526521],
        0.015: [0.107785, 0.078817, -1.335784, -0.882331, 0.009146, 1.525812],
        0.01: [0.102836, 0.083797, -1.335871, -0.882335, 0.009146, 1.525097],
        0.0075: [0.100180, 0.086481, -1.335873, -0.882336, 0.009146, 1.524436],
        0.005: [0.097144, 0.089547, -1.335875, -0.882337, 0.009146, 1.523137],
        0.002: [0.092990, 0.088131, -1.335860, -0.882295, 0.009146, 1.520734],
        0.001: [0.092990, 0.066395, -1.335852, -0.882276, 0.009146, 1.522258],
        0.0005: [0.092988, 0.055420, -1.335864, -0.882275, 0.009146, 1.523022],
    },
    "eccentric": {
        0.05: [0.142275, 4.947130, -0.882270, 0.009146, 1.530769],
        0.03: [0.122594, 4.947092, -0.882266, 0.009146, 1.527937],
        0.02: [0.112726, 4.947064, -0.882265, 0.009146, 1.526521],
        0.015: [0.107785, 4.947299, -0.882265, 0.009146, 1.525813],
        0.01: [0.102840, 4.948094, -0.882261, 0.009146, 1.525105],
        0.0075: [0.100351, 4.947746, -0.882262, 0.009146, 1.524771],
        0.005: [0.097464, 4.947639, -0.882263, 0.009146, 1.524989],
    },
}
C8TABLE = {"vicarious": {0.05: 1.41, 0.02: 2.01, 0.01: 6.31, 0.005: 6.95, 0.002: 23.73, 0.001: 98.06, 0.0005: 146.73},
           "eccentric": {0.05: 189.92, 0.02: 252.45, 0.01: 286.70, 0.005: 305.33}}


def best_scale(form, q, tt, r):
    """the scale minimising max |s d_i / r_i - 1| (d_i the model distances at scale 1)."""
    d = c8.model(form, list(q[:-1]) + [1.0], tt)[1]
    ratio = d / r
    return 2.0 / (ratio.max() + ratio.min())


def score(form, q, tt, th, r):
    a, b = c8.residuals(form, np.asarray(q, float), tt, th, r)
    return np.max(np.abs(a)), np.max(np.abs(b))


def fmt(form, q):
    names = {"vicarious": ["e1", "e2", "w", "L", "n"], "eccentric": ["e", "w", "L", "n"]}[form] + ["scale"]
    return ", ".join("%s=%.9g" % (k, v) for k, v in zip(names, q))


def main():
    out("# c10_distances_research.py  seed=%d  numpy %s  python %s" % (SEED, np.__version__, sys.version.split()[0]))
    tt, th, r = c8.data()
    rng = np.random.default_rng(SEED)
    taus = [0.05, 0.03, 0.02, 0.015, 0.01, 0.0075, 0.005, 0.002, 0.001, 0.0005]

    out("## (1) referee B's witnesses re-checked with c8's residuals() (elements as printed, 6 decimals;")
    out("##     the scale is re-optimised for the distance constraint)")
    for form in ("vicarious", "eccentric"):
        for tau, q in RB3B[form].items():
            q = np.array(q, float)
            q2 = q.copy()
            q2[-1] = best_scale(form, q, tt, r)
            a, b = score(form, q, tt, th, r)
            a2, b2 = score(form, q2, tt, th, r)
            out("  %-9s tau=%6.2f%%: printed scale: max|dlon| %.3f', max|dr/r| %.5f%%;  optimal scale: %.3f', %.5f%%"
                % (form, 100 * tau, a / ARC, 100 * b, a2 / ARC, 100 * b2))

    out("## (2) wider search with c8's slp() (decreasing sweep, then increasing sweep)")
    L0 = np.deg2rad(309.446)
    base = {"eccentric": [0.184516, np.deg2rad(283.471), np.deg2rad(309.448), 0.0091461],
            "vicarious": [0.115724, 0.0707907, np.deg2rad(283.462), L0, 0.00914609]}
    extra = {"vicarious": [[0.0933767, 0.0933767, np.deg2rad(283.465), L0, 0.00914613],
                           [0.09317, 0.09332, np.deg2rad(283.465), L0, 0.00914612]], "eccentric": []}
    best = {}
    for form in ("vicarious", "eccentric"):
        q0 = np.array(base[form] + [1.5237])
        q0[-1] = best_scale(form, q0, tt, r)
        qd, _, rstar, _ = c8.slp(form, q0.copy(), tt, th, r, None)
        out("  %s: r* (least distance tolerance, no longitude constraint) = %.4f%%" % (form, 100 * rstar))
        fixed = [q0, qd] + [np.array(e + [q0[-1]]) for e in extra[form]]

        def rand_start():
            q = q0.copy()
            if form == "vicarious":
                q[0], q[1] = rng.uniform(0.06, 0.16), rng.uniform(0.03, 0.12)
                q[2] += rng.normal(0, 0.05)
            else:
                q[0] = rng.uniform(0.09, 0.2)
                q[1] += rng.normal(0, 0.05)
            q[-1] = best_scale(form, q, tt, r)
            return q

        rand = {tau: [rand_start() for _ in range(6)] for tau in taus}
        res = {tau: (None, None) for tau in taus}

        def try_start(tau, qs):
            q, a, b, ok = c8.slp(form, np.array(qs, float), tt, th, r, tau, iters=120)
            if ok and (res[tau][0] is None or a < res[tau][0]):
                res[tau] = (a, q)

        prev = None
        for tau in taus:                                   # decreasing sweep
            cand = [c.copy() for c in fixed] + [c.copy() for c in rand[tau]]
            if tau in RB3B[form]:
                w = np.array(RB3B[form][tau], float)
                w[-1] = best_scale(form, w, tt, r)          # printed 6-decimal elements: re-optimise the scale
                cand.append(w)
                for _ in range(2):
                    p = w.copy()
                    p[:2] += rng.normal(0, 0.003, 2)
                    p[-1] = best_scale(form, p, tt, r)
                    cand.append(p)
            if prev is not None:
                cand.append(prev.copy())
            for c in cand:
                try_start(tau, c)
            if res[tau][1] is not None:
                prev = res[tau][1]
            out("  %-9s tau=%6.2f%%: decreasing sweep: %s  (%.0f s)"
                % (form, 100 * tau, "none" if res[tau][0] is None else "%.3f'" % (res[tau][0] / ARC), time.time() - T0))
        prev = None
        for tau in reversed(taus):                         # increasing sweep from the smaller tau's optimum
            if prev is not None:
                try_start(tau, prev.copy())
            if res[tau][1] is not None:
                prev = res[tau][1]
        best[form] = res

    out("## (3) least longitude tolerance found (arcmin), each witnessed by the printed elements and re-checked")
    out("##     with c8's residuals(); 'none' = no elements found meeting tau.  min over c8, rb3b and this search.")
    for form in ("vicarious", "eccentric"):
        out("== %s" % form)
        env_prev = None
        rows = []
        for tau in taus:
            cands = []
            if best[form][tau][1] is not None:
                cands.append(("c10", best[form][tau][1]))
            if tau in RB3B[form]:
                w = np.array(RB3B[form][tau], float)
                w[-1] = best_scale(form, w, tt, r)
                cands.append(("rb3b", w))
            scored = []
            for src, q in cands:
                a, b = score(form, q, tt, th, r)
                if b <= tau * (1 + 1e-9):
                    scored.append((a, src, q, b))
            rows.append((tau, min(scored, key=lambda z: z[0]) if scored else None))
        # monotone envelope: elements feasible at a smaller tau are feasible at a larger one
        for i, (tau, row) in enumerate(rows):
            env = [z for _, z in rows[i:] if z is not None]
            envmin = min(env, key=lambda z: z[0]) if env else None
            c8v = C8TABLE[form].get(tau)
            if envmin is None:
                out("  tau=%6.2f%%: none  (c8: %s)" % (100 * tau, "infeas." if c8v is None else c8v))
                continue
            a, src, q, b = envmin
            out("  tau=%6.2f%%: %.3f'  [source %s; c8 table %s]  max|dr/r| %.5f%%  elements: %s"
                % (100 * tau, a / ARC, src, "n/a" if c8v is None else "%.2f'" % c8v, 100 * b, fmt(form, q)))
    out("# every entry is an upper bound on the least longitude tolerance; minimality is not proved")
    out("# done in %.0f s" % (time.time() - T0))


if __name__ == "__main__":
    main()
    with open(os.path.join(HERE, "c10_distances_research.out"), "w") as f:
        f.write("\n".join(OUT) + "\n")
