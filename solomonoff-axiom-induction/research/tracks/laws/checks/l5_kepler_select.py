"""l5_kepler_select.py -- which form of Kepler's law (honest law, exact law with exceptions, tolerance law
with exceptions, or no law) the two-part objective selects on the REAL residuals of a fixed Kepler ellipse,
per body, window, data precision Delta, steepness lambda and pricing (thread `laws`, T3, notes section 3.6).

Seed 20261016.  Reads l4_residuals.npz (written by l4_kepler_pk.py: longitude errors e(t) of a fixed
Kepler ellipse against ERFA's plan94 / moon98, for the fit with the smallest mean |e| ("mean" fit) and the
fit with the smallest max |e| ("minimax" fit), 8000 uniform times per body and window).  Writes
l5_kepler_select.out next to itself.

Revision note (notes-final.md, Setting S3; referee A M1): the draw t ~ U[0,1) stands for a FRESH time at each
datum (distinct numerals t_j) with the error e(t_j) and the dither u_j i.i.d.; a law on numerals cannot be atomless.
The deterministic-patch pricings (Q/det, R/det) with a constant pi_c are a finite-horizon cost model
(notes-final Prop 3.3a); the randomised pricings are exact theory-machine costs for all n.
Revision note (referee A M6, referee B 8): the 'pk' printed in part A is the CROSS ratio eps*(minimax fit) /
E|e|(mean fit), not pk(e) of one law; per-fit values are in l10_revision.out part A.  The R/rand pool here
(0, P, H, tolerance family with whole-circle exceptions) is incomplete (referee B 1; l10 parts B, C).

Data model (notes section 3.1): dithered cells of width Delta on the longitude circle (21600'); a datum's
literal cost gamma = log2(21600/Delta); naming a time costs pi_c = log2(days in window) + 2 bits.
For each tolerance eps (grid 0, 0.05 eps*, ..., eps*) and each of the two fits, the per-datum rates are
averaged over the 8000 sample times.  The average over the dither is EXACT in the coarse regime
Delta >= eps + max|e| (Lemma 3.2 for prove / silent / refute; Lemma 3.6 and its proof for the distribution
of the band's share Lband of the true cell given silence: uniform on (w,1) plus uniform on (1-w,1) if |e| <= eps,
uniform on (0,1) if |e| > eps), and by Monte Carlo over 20 dithers per sample (160000 data) otherwise.
Per-datum rates (notes Def 3.1, Prop 3.3; law-part lengths are O(1) per form and do not enter rates):
    0       : gamma
    Q/det   : gamma Pr[not proved] + lam pi_c Pr[refuted]
    Q/rand  : gamma Pr[not proved] + H2(Pr[refuted])          (random exceptions, flag code)
    R/det   : E[cost], cost = 0 proved, -log2(overlap/2eps) silent, lam pi_c + gamma refuted
    R/rand  : min over rho of E[-log2((1-rho) Lband + rho 2^-gamma)], Lband = 1 proved, overlap/2eps silent,
              0 refuted (SAI's own pricing: honest law with random completion and random exceptions)
Pure forms: P = (eps = 0, mean fit), H = (eps = eps* of the minimax fit, minimax fit; never refuted).
The tolerance family: the minimum over the eps grid and the two fits ("T" in the tables, with eps_opt/eps*
and the share of exceptions at the optimum).
"""
import math
import os
import sys
import time
import numpy as np

SEED = 20261016
OUT = []
RANGE = 21600.0
YEAR = 365.25


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def H2(x):
    x = np.clip(np.asarray(x, float), 1e-300, 1 - 1e-16)
    return -x * np.log2(x) - (1 - x) * np.log2(1 - x)


def events(e, eps, Delta, u):
    lo, hi = -u * Delta, (1 - u) * Delta
    if eps == 0:
        pr = (e >= lo) & (e < hi)
        return pr, ~pr, np.where(pr, 1.0, 0.0)
    blo, bhi = e - eps, e + eps
    pr = (blo >= lo) & (bhi < hi)
    ov = np.clip(np.minimum(hi, bhi) - np.maximum(lo, blo), 0, None)
    rf = ov <= 0
    return pr, rf, np.where(pr, 1.0, ov / (2 * eps))


def rand_rate(Lband, g):
    """min over rho of E[-log2((1-rho) Lband + rho 2^-g)] by golden section on log10(rho) in [-7, 0]."""
    s = 2.0 ** (-g)

    def f(lr):
        rho = 10.0 ** lr
        return float(np.mean(-np.log2((1 - rho) * Lband + rho * s)))
    a, b = -7.0, 0.0
    gr = (math.sqrt(5) - 1) / 2
    c, d = b - gr * (b - a), a + gr * (b - a)
    fc, fd = f(c), f(d)
    for _ in range(40):
        if fc < fd:
            b, d, fd = d, c, fc
            c = b - gr * (b - a)
            fc = f(c)
        else:
            a, c, fc = c, d, fd
            d = a + gr * (b - a)
            fd = f(d)
    lr = (a + b) / 2
    # rho -> 0 limit: infinite if some Lband = 0, else E[-log2 Lband]
    best = min(f(lr), f(-7.0))
    if np.all(Lband > 0):
        best = min(best, float(np.mean(-np.log2(Lband))))
    return best, 10.0 ** lr


def main():
    t0 = time.time()
    rng = np.random.default_rng(SEED)
    here = os.path.dirname(os.path.abspath(__file__))
    Z = np.load(os.path.join(here, "l4_residuals.npz"))
    # keep l4's order: planets by number then windows, then the Moon
    order_b = ["Mercury", "Venus", "EMB", "Mars", "Jupiter", "Saturn", "Moon"]

    def sortkey(k):
        b, w = k.split("_")
        wv = {"1month": 1 / 12, "1year": 1.0, "18.6yr": 18.6}.get(w, None)
        return (order_b.index(b), float(w) if wv is None else wv)
    rows = sorted({k[:-2] for k in Z.files if k.endswith("_t")}, key=sortkey)
    out("# l5_kepler_select.py seed=%d python %s numpy %s; input l4_residuals.npz (%d series)" % (
        SEED, sys.version.split()[0], np.__version__, len(Z.files)))
    DELTAS = [0.1, 0.3, 1.0, 3.0, 10.0, 30.0, 60.0, 120.0, 300.0, 600.0, 1800.0]
    LAMS = [1.0, 2.0, 4.0]
    EPSG = np.linspace(0, 1, 21)
    M = 20

    out("\n== A. residual statistics (arcmin): eps* = max|e| of the minimax fit; E|e| of the mean fit; pk = eps*/E|e|;")
    out("   beta_e = log2 e - E H2((eps* - e)/(2 eps*)) for the minimax fit (Lemma 3.6); share of times with |e| > eps*/2")
    out("   %-8s %7s | %8s %8s %6s | %6s %7s | %s" % ("body", "window", "eps*", "E|e|", "pk", "beta_e", ">eps*/2", "days"))
    info = {}
    for k in rows:
        b, w = k.split("_")
        em = Z[k + "_e_mean"].astype(float)
        ex = Z[k + "_e_max"].astype(float)
        t = Z[k + "_t"].astype(float)
        eps_star = float(np.max(np.abs(ex)))
        Ee = float(np.mean(np.abs(em)))
        beta = math.log2(math.e) - float(np.mean(H2((eps_star - ex) / (2 * eps_star))))
        days = float(t.max() - t.min())
        info[k] = (em, ex, eps_star, Ee, beta, days)
        out("   %-8s %7s | %8.3f %8.3f %6.2f | %6.3f %7.3f | %.0f" % (
            b, w, eps_star, Ee, eps_star / Ee, beta, float(np.mean(np.abs(ex) > eps_star / 2)), days))

    # ---------------- rates
    def I(a, b, al, be):
        """integral_a^b -log2(al x + be) dx (elementwise), al > 0, be >= 0; 0 where b <= a."""
        a = np.asarray(a, float)
        b = np.asarray(b, float)

        def F(x):
            y = al * x + be
            return (y * np.log(np.maximum(y, 1e-300)) - y) / al
        return np.where(b > a, -(F(b) - F(a)) / math.log(2), 0.0)

    def rates_exact(e, eps, D, g, pic, lam_list):
        """coarse regime: exact dither averages; returns dict pricing -> rate, and refute share."""
        a = np.abs(e)
        if eps == 0:
            pref = np.minimum(a / D, 1.0)
            psil = np.zeros_like(a)
        else:
            pref = np.maximum(a - eps, 0) / D
            psil = np.full_like(a, 2 * eps / D)
        ppr = 1 - psil - pref
        Pref, Psil = float(pref.mean()), float(psil.mean())
        r = {}
        for lam in lam_list:
            r[("Q/det", lam)] = g * (Psil + Pref) + lam * pic * Pref
        r[("Q/rand", 0.0)] = g * (Psil + Pref) + (float(H2(Pref)) if Pref > 0 else 0.0)
        s = 2.0 ** (-g)
        if eps > 0:
            inside = a <= eps
            w = np.where(inside, (eps - e) / (2 * eps), 0.0)

            def silent_cost(al, be):
                # E[-log2(al L + be)] given silence
                c_in = I(w, 1.0, al, be) + I(1 - w, 1.0, al, be)
                c_out = I(np.zeros_like(a), np.ones_like(a), al, be)
                return np.where(inside, c_in, c_out)
            sil_R = float(np.mean(psil * silent_cost(1.0, 0.0)))
        else:
            sil_R = 0.0
        for lam in lam_list:
            r[("R/det", lam)] = sil_R + Pref * (lam * pic + g)

        def f(lr):
            rho = 10.0 ** lr
            al, be = 1 - rho, rho * s
            c = float(ppr.mean()) * (-math.log2(al + be)) + Pref * (-math.log2(be))
            if eps > 0:
                c += float(np.mean(psil * silent_cost(al, be)))
            return c
        best = sil_R if Pref == 0 else float("inf")
        lo_, hi_ = -9.0, 0.0
        gr = (math.sqrt(5) - 1) / 2
        c_, d_ = hi_ - gr * (hi_ - lo_), lo_ + gr * (hi_ - lo_)
        fc, fd = f(c_), f(d_)
        for _ in range(50):
            if fc < fd:
                hi_, d_, fd = d_, c_, fc
                c_ = hi_ - gr * (hi_ - lo_)
                fc = f(c_)
            else:
                lo_, c_, fc = c_, d_, fd
                d_ = lo_ + gr * (hi_ - lo_)
                fd = f(d_)
        best = min(best, fc, fd)
        r[("R/rand", 0.0)] = best
        return r, Pref

    def rates_mc(e, eps, D, g, pic, lam_list, u):
        ee = np.repeat(e, u.size // e.size)
        pr, rf, Lb = events(ee, eps, D, u)
        npr, nrf = float(np.mean(~pr)), float(np.mean(rf))
        sil = ~pr & ~rf
        silR = float(np.mean(np.where(sil, -np.log2(np.where(sil, Lb, 1.0)), 0.0)))
        r = {}
        for lam in lam_list:
            r[("Q/det", lam)] = g * npr + lam * pic * nrf
            r[("R/det", lam)] = silR + nrf * (lam * pic + g)
        r[("Q/rand", 0.0)] = g * npr + (float(H2(nrf)) if nrf > 0 else 0.0)
        r[("R/rand", 0.0)] = rand_rate(Lb, g)[0]
        return r, nrf

    results = {}
    nexact = nmc = 0
    for k in rows:
        em, ex, eps_star, Ee, beta, days = info[k]
        pic = math.log2(days) + 2.0
        u = rng.random(em.size * M)
        fits = {"mean": em, "minimax": ex}
        for D in DELTAS:
            g = math.log2(RANGE / D)
            res = {"0": g}
            fam = {}
            for fname, e in fits.items():
                for x in EPSG:
                    eps = x * eps_star
                    if D >= eps + float(np.max(np.abs(e))):
                        r, nrf = rates_exact(e, eps, D, g, pic, LAMS)
                        nexact += 1
                    else:
                        r, nrf = rates_mc(e, eps, D, g, pic, LAMS, u)
                        nmc += 1
                    for key, val in r.items():
                        if key not in fam or val < fam[key][0]:
                            fam[key] = (val, x, fname, nrf)
                        if fname == "mean" and x == 0:
                            res[("P",) + key] = val
                        if fname == "minimax" and x == 1:
                            res[("H",) + key] = val
            results[(k, D)] = (res, fam, g, pic)
    out("\n   (rates: %d (fit, eps, Delta) cells averaged exactly over the dither, %d by Monte Carlo)" % (nexact, nmc))

    PRICINGS = [("Q/det", 1.0), ("Q/det", 2.0), ("Q/det", 4.0), ("Q/rand", 0.0), ("R/det", 1.0), ("R/det", 4.0),
                ("R/rand", 0.0)]

    def pname(pr):
        return pr[0] + ("" if pr[1] == 0 else " lam=%g" % pr[1])

    out("\n== B. pure forms: which of 0 (no law), P (exact law with exceptions), H (honest law) has the least rate")
    out("   (asymptotic lambda-MAP among the three, Thm 3.8(i)); lower-case = within 2% of the runner-up")
    hdr = "   %-8s %7s |" % ("body", "window") + "".join("%6g" % d for d in DELTAS)
    for pr in PRICINGS:
        out("\n   pricing %s" % pname(pr))
        out(hdr)
        for k in rows:
            b, w = k.split("_")
            cells = []
            for D in DELTAS:
                res, fam, g, pic = results[(k, D)]
                cand = {"0": res["0"], "P": res[("P",) + pr], "H": res[("H",) + pr]}
                srt = sorted(cand.items(), key=lambda kv: kv[1])
                lab = srt[0][0]
                if srt[1][1] - srt[0][1] <= 0.02 * max(srt[1][1], 1e-12):
                    lab = lab.lower()
                cells.append("%6s" % lab)
            out("   %-8s %7s |" % (b, w) + "".join(cells))

    out("\n== C. the tolerance family (Prop 3.5): optimal eps/eps* and share of exceptions at the optimum;")
    out("   entries 'x/s' = eps_opt/eps*, exception share in %; '0' if the empty law is cheaper")
    for pr in (("Q/det", 1.0), ("Q/det", 4.0), ("R/rand", 0.0)):
        out("\n   pricing %s" % pname(pr))
        out("   %-8s %7s |" % ("body", "window") + "".join("%10g" % d for d in DELTAS))
        for k in rows:
            b, w = k.split("_")
            cells = []
            for D in DELTAS:
                res, fam, g, pic = results[(k, D)]
                r, x, fname, nrf = fam[pr]
                cells.append("%10s" % ("0" if res["0"] <= r else "%.2f/%.1f" % (x, 100 * nrf)))
            out("   %-8s %7s |" % (b, w) + "".join(cells))

    out("\n== D. Prop 3.4 against the simulated rates, coarse regime (Delta >= 2 eps*), pure forms P and H:")
    out("   predicted H iff pk < gamma_ex/(2 gamma_si) with p = E|e|/Delta (mean fit) and q = 2 eps*/Delta;")
    out("   'agree' counts (body, window, Delta, pricing) cells where the predicted and the simulated winner agree")
    agree = tot = 0
    disagree = []
    for k in rows:
        em, ex, eps_star, Ee, beta, days = info[k]
        pk = eps_star / Ee
        for D in DELTAS:
            if D < 2 * eps_star:
                continue
            res, fam, g, pic = results[(k, D)]
            p = Ee / D
            for pr in PRICINGS:
                name, lam = pr
                gex = (lam * pic + g) if name.endswith("det") else (g + float(H2(p)) / p)
                gsi = g if name.startswith("Q") else beta
                pred = "H" if pk < gex / (2 * gsi) else "P"
                sim = "H" if res[("H",) + pr] < res[("P",) + pr] else "P"
                tot += 1
                if pred == sim:
                    agree += 1
                else:
                    disagree.append("%s %s Delta=%g %s: pk=%.2f thr=%.2f rates P=%.4f H=%.4f" % (
                        *k.split("_"), D, pname(pr), pk, gex / (2 * gsi), res[("P",) + pr], res[("H",) + pr]))
    out("   agree in %d of %d cells" % (agree, tot))
    for s in disagree:
        out("   disagreement: " + s)

    out("\n# runtime %.0f s" % (time.time() - t0))
    out("# done")
    with open(__file__.replace(".py", ".out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
