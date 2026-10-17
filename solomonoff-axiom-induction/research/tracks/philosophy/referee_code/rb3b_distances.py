"""rb3b_distances.py -- referee B for thread `philosophy`: notes.md 4.4 Part C (c8), the least longitude
tolerance of the vicarious hypothesis and the eccentric circle when distances are data at relative
tolerance tau.  Seed 20261016 (only used for perturbed starts).  Writes rb3b_distances.out next to itself.

Method: rb3's own exchange algorithm (SLSQP on active sets of longitude and distance constraints; the
distance constraint is that the log-ratios log(|P_i|/r_i) have spread <= log((1+tau)/(1-tau)), which is
exactly the condition that some scale s gives max_i |s |P_i|/r_i - 1| <= tau), from several starts.
Every solution found is then RE-CHECKED WITH c8's OWN CODE: c8's data() and residuals() are imported
from ../checks/c8_mars_distances.py, my elements are moved into c8's frame (longitudes differ by a
constant offset, which is measured), the scale is set to its optimal value, and c8's residual function
reports the longitude and distance errors.
"""
import math
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, "..", "checks"))
import rb3_mars_pool as rb3  # noqa: E402
import c8_mars_distances as c8  # noqa: E402

SEED = 20261016
ARC = rb3.ARCMIN
OUT = []


def out(*a):
    s = " ".join(str(x) for x in a)
    OUT.append(s)
    print(s, flush=True)


def main():
    out("# rb3b_distances.py  seed=%d  numpy %s  python %s" % (SEED, np.__version__, sys.version.split()[0]))
    tt, th, r, _ = rb3.load()
    tt8, th8, r8 = c8.data()
    off = rb3.wrap(th8 - th)
    out("  frames: max |t - t_c8| = %.1e d; max |r - r_c8| = %.2e AU; longitude offset c8 - mine = %.9f rad (spread %.1e rad)"
        % (np.max(np.abs(tt - tt8)), np.max(np.abs(r - r8)), off.mean(), off.max() - off.min()))
    D = float(off.mean())
    fits = np.load(os.path.join(HERE, "rb3_fits.npy"), allow_pickle=True).item()
    rng = np.random.default_rng(SEED)

    def norm(form, p):
        p = np.array(p, float)
        if rb3.NAMES[form][0] == "e" and p[0] < 0:
            p[0], p[1] = -p[0], p[1] + math.pi
        return p

    def recheck(form, p, tau):
        q = np.array(p, float)
        names = rb3.NAMES[form]
        for j, k in enumerate(names):
            if k in ("w", "L"):
                q[j] += D
        dist = c8.model(form, list(q) + [1.0], tt8)[1]
        ratio = dist / r8
        s = 2.0 / (ratio.max() + ratio.min())          # optimal scale for max |s ratio - 1|
        a, b = c8.residuals(form, np.array(list(q) + [s]), tt8, th8, r8)
        return np.max(np.abs(a)) / ARC, np.max(np.abs(b)), q, s

    taus = [0.05, 0.03, 0.02, 0.015, 0.01, 0.0075, 0.005, 0.002, 0.001, 0.0005]
    c8ref = {"vicarious": {0.05: "1.41'", 0.02: "2.01'", 0.01: "6.31'", 0.005: "6.95'", 0.002: "23.73'",
                           0.001: "98.06'", 0.0005: "146.73'"},
             "eccentric": {0.05: "189.92'", 0.02: "252.45'", 0.01: "286.70'", 0.005: "305.33'", 0.002: "infeas."}}
    for form in ["vicarious", "eccentric"]:
        p0 = norm(form, fits[form][0])
        prev = None
        out("== %s: least longitude tolerance found at distance tolerance tau (re-checked with c8's code)" % form)
        for tau in taus:
            st = [p0.copy()] + ([prev.copy()] if prev is not None else [])
            for _ in range(4):
                q = p0.copy()
                q[0] += rng.uniform(-0.02, 0.02)
                q[1] += rng.uniform(-0.02, 0.02)
                st.append(q)
            if form == "vicarious":
                pe = norm("equant", fits["equant"][0])
                st.append(np.array([pe[0], pe[0], pe[1], pe[2], pe[3]]))
            best = None
            for s0 in st:
                s0 = np.array(s0, float)
                s0[0] = abs(s0[0])
                if form == "vicarious":
                    s0[1] = abs(s0[1])
                try:
                    res = rb3.exchange_minimax(form, s0, tt, th, extra=(r, tau), iters=80)
                except Exception:   # noqa: BLE001
                    res = None
                if res is not None and (best is None or res[1] < best[1]):
                    best = res
            if best is None:
                out("  tau=%.2f%%: no feasible solution found  (c8 %s)" % (100 * tau, c8ref[form].get(tau, "n/a")))
                continue
            prev = best[0]
            lon8, dr8, q8, s = recheck(form, best[0], tau)
            els = ", ".join("%s=%.6f" % (k, v) for k, v in zip(rb3.NAMES[form], q8))
            out("  tau=%.2f%%: mine %.3f'; c8's code on these elements: max|dlon| %.3f', max|dr/r| %.5f%% (<= tau: %s)"
                "  (c8 table %s)  elements in c8's frame: %s, scale %.6f"
                % (100 * tau, best[1] / ARC, lon8, 100 * dr8, dr8 <= tau * (1 + 1e-9), c8ref[form].get(tau, "n/a"), els, s))
    out("# done")


if __name__ == "__main__":
    main()
    with open(os.path.join(HERE, "rb3b_distances.out"), "w") as f:
        f.write("\n".join(OUT) + "\n")
