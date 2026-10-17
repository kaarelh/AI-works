"""c9_revision.py -- revision checks for notes-final.md (thread `philosophy`), written independently of the
referees' ra1-ra3 (whose outputs it is compared with in notes-final.md, not here).

Seed 20261016.  Writes c9_revision.out next to itself.  Imports the data and model code of c4_mars_pool.py
(same folder) and, for part (5), reads c4_mars_pool.out (table A2, the Occam factors).

Parts
  (1) Conservation world (notes-final 2.2): the law's value per question under three no-law baselines for
      the question task -- uniform on {0..m} (the development record's QA-NOLAW), i.i.d. Binomial(m,1/2), and
      the baseline induced by the raw no-law model (chain rule) -- against its value per raw step.
  (2) Mars, least squares: RMS and maximal residual of each form's least-squares fit to the c4 data
      (7306 daily heliocentric longitudes 1580-1600).
  (3) Mars, Gaussian noise, expected penalty: per-observation expected log-likelihood penalty of form F
      relative to the ellipse, (RMS_F^2 - RMS_ell^2) / (2 sigma^2 ln 2) bits, and the number of
      observations at which it overcomes F's law-text advantage in each syntax (corrected c4 texts).
  (4) Mars, Gaussian noise, full simulation: n days drawn at random from 1580-1600, plan94 longitude plus
      N(0, sigma^2) noise (sigma = 2'), each form fitted by least squares; posterior log-weight
      -|LAW_F|_S + log2 p(D | F) with the Laplace approximation of the evidence under the uniform element
      prior of c4 (fixed-length numerals); MAP counts over 20 seeds per n and syntax.
  (5) Mars, guaranteed-tolerance regime without a text prior: uniform prior over the five forms and c4's
      uniform element prior; posterior from c4's Occam factors alone.  Also: the effect of halving the
      eccentricity ranges (a change of parametrisation of the prior box).
  (6) Honest uniform-tolerance theories: per-datum cost difference log2(eps_F / eps_ell), eps_F the c4
      minimax error, and the crossover numbers of data.
  (7) Intrinsic errors: the minimax error of each form against an exact, unperturbed Kepler ellipse (the
      ellipse's own least-squares elements on the c4 data), on the same 7306 days.
  (8) Law-text lengths in a second serialisation (Polish notation with fixed arities, no brackets; a separate
      symbol for unary minus) and a compact K3 (with a power symbol and the numeral 3).
  (9) Exact K3 for Jupiter and Saturn: the geocentric direction error, 1580-1600 daily, of moving each
      planet radially by the factor (q_Ea/q_b)^(1/3) (scout P c3's q values), against plan94.
"""
import math
import os
import re
import sys
import time

import numpy as np
from scipy.optimize import least_squares

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import c4_mars_pool as c4  # noqa: E402

SEED = 20261016
ARC = c4.ARCMIN
OUT = []
T0 = time.time()


def out(*a):
    s = " ".join(str(x) for x in a)
    OUT.append(s)
    print(s, flush=True)


FORMS = c4.FORMS
# c4 table A1 (minimax elements; w, L in degrees) -- used as starting points only
A1 = {"circle": [309.45, 0.00914611], "eccentric": [0.184516, 283.471, 309.448, 0.0091461],
      "equant": [0.0933767, 283.465, 309.446, 0.00914613],
      "vicarious": [0.115724, 0.0707907, 283.462, 309.446, 0.00914609],
      "ellipse": [0.0930389, 283.445, 309.442, 0.00914609]}
MINIMAX = {"circle": 640.7908, "eccentric": 23.0508, "equant": 8.1653, "vicarious": 1.4127, "ellipse": 1.0733}


def a1_elements(f):
    v = list(A1[f])
    for i, nm in enumerate(c4.NAMES[f]):
        if nm in ("w", "L"):
            v[i] = math.radians(v[i])
    return np.array(v, float)


def ls_fit(f, tt, th, p0):
    sol = least_squares(lambda p: c4.res(f, p, tt, th), p0, method="lm", xtol=1e-15, ftol=1e-15, gtol=1e-15,
                        max_nfev=20000)
    return sol.x


def texts_bits():
    return {(S, f): c4.text_bits(S, c4.K3 if f == "K3" else c4.TEXTS[S][f])
            for S in ("S1", "S2", "S3") for f in FORMS + ["K3"]}


def part1():
    out("## (1) conservation world: the law's value per raw step and per question (bits)")
    out("#  m     g_0=log2(S/C)  g_{C/2}   per question: uniform{0..m}   iid Binomial (realised, |x|=m/2)"
        "   induced by raw no-law model at step t")
    for m in (8, 12, 16, 32, 64, 128, 1024):
        C = math.comb(m, m // 2)
        S = 2 ** m
        g0 = math.log2(S / C)
        gh = math.log2((S - C // 2) / (C - C // 2))
        unif = math.log2(m + 1)
        binom = -math.log2(C / S)            # -log2 P_Bin(m/2)
        out("%6d %12.4f %10.4f %16.4f %22.4f %26s" % (m, g0, gh, unif, binom, "= g_t exactly"))
    out("# chain rule: under RAW-NOLAW the step-t loss log2(S-t) = log2((S-t)/(C-t)) [the induced probability")
    out("# of the observed weight class] + log2(C-t) [the state within the class], and RAW-LAW's loss is the")
    out("# second term; so the law's raw gain g_t IS the no-law raw model's loss on the question 'what is |x_t+1|?'.")
    # numerical check of the identity at m = 12 for all t < C
    m = 12
    C, S = math.comb(m, 6), 2 ** m
    worst = max(abs(math.log2(S - t) - (math.log2((S - t) / (C - t)) + math.log2(C - t))) for t in range(C))
    out("# identity checked at m = 12 for t = 0..C-1: largest |difference| %.1e bits" % worst)
    out()


def part2_3(tt, th, bits):
    out("## (2) least-squares fits to the c4 data (N = %d)" % len(tt))
    fitsLS = {}
    for f in FORMS:
        p = ls_fit(f, tt, th, a1_elements(f))
        r = c4.res(f, p, tt, th)
        fitsLS[f] = p
        out("%-10s RMS %10.4f'   max %10.4f'   (c4 minimax %.4f')" % (f, np.sqrt(np.mean(r ** 2)) / ARC,
                                                                     np.max(np.abs(r)) / ARC, MINIMAX[f]))
    out()
    rms = {f: np.sqrt(np.mean(c4.res(f, fitsLS[f], tt, th) ** 2)) for f in FORMS}
    out("## (3) Gaussian noise: expected penalty per observation relative to the ellipse, and crossovers")
    out("#  where F's text is shorter than the ellipse's in syntax S: N* = (|LAW_ell| - |LAW_F|) / penalty observations")
    for sig in (1.0, 2.0, 4.0):
        s = sig * ARC
        for f in ("eccentric", "equant", "vicarious"):
            pen = (rms[f] ** 2 - rms["ellipse"] ** 2) / (2 * s * s * math.log(2))
            cells = []
            for S in ("S1", "S2", "S3"):
                adv = bits[(S, "ellipse")] - bits[(S, f)]
                cells.append("%s: text adv %5d -> %s" % (S, adv, ("N* %.1f" % (adv / pen)) if adv > 0 else "none"))
            out("  sigma %.0f'  %-10s %10.4f bits/obs   %s" % (sig, f, pen, ";  ".join(cells)))
    out()
    return fitsLS


def part4(tt, th, bits, fitsLS):
    out("## (4) Gaussian noise, full simulation (Laplace evidence; uniform element prior; 20 seeds per cell)")
    rng = np.random.default_rng(SEED)
    prior_logvol = {}
    for f in FORMS:
        lv = 0.0
        for nm in c4.NAMES[f]:
            a, b = c4.RANGE[nm]
            lv += math.log(c4.TWO_PI if a is None else b - a)
        prior_logvol[f] = lv
    ns = [5, 10, 20, 40, 80, 160, 320, 640, 1280, 2560, 5120, 7306]
    for sig_arc in (2.0, 1.0):
        sig = sig_arc * ARC
        out("# sigma = %.0f'" % sig_arc)
        out("%-6s %-4s %s" % ("n", "S", "MAP counts over 20 seeds (circle/eccentric/equant/vicarious/ellipse);"
                              "  median log2 odds ellipse : vicarious (evidence only, no text)"))
        for n in ns:
            counts = {S: {f: 0 for f in FORMS} for S in ("S1", "S2", "S3")}
            odds = []
            for seed in range(20):
                idx = np.sort(rng.choice(len(tt), size=n, replace=False))
                t_s = tt[idx]
                y = th[idx] + rng.normal(0, sig, size=n)
                logev = {}
                for f in FORMS:
                    p = ls_fit(f, t_s, y, fitsLS[f])
                    r = c4.res(f, p, t_s, y)
                    J = c4.jac(f, p, t_s, y)
                    k = len(p)
                    sign, ld = np.linalg.slogdet(J.T @ J / sig ** 2)
                    if sign <= 0 or n < k:
                        logev[f] = -np.inf
                        continue
                    ln = (-np.sum(r ** 2) / (2 * sig ** 2) - prior_logvol[f] + 0.5 * k * math.log(2 * math.pi)
                          - 0.5 * ld)
                    logev[f] = ln / math.log(2)
                odds.append(logev["ellipse"] - logev["vicarious"])
                for S in ("S1", "S2", "S3"):
                    lp = {f: logev[f] - bits[(S, f)] for f in FORMS}
                    counts[S][max(lp, key=lp.get)] += 1
            for S in ("S1", "S2", "S3"):
                out("%-6d %-4s %s%s" % (n, S, " / ".join("%2d" % counts[S][f] for f in FORMS),
                                        ("      %.1f" % float(np.median(odds))) if S == "S1" else ""))
    out("# (the Laplace evidence includes the parameter-fitting (Occam) terms that the expected-penalty estimate")
    out("#  of part (3) omits; the noise model's own text is common to all forms and cancels.  n = 7306 uses every")
    out("#  day of 1580-1600, with fresh noise per seed.)")
    out()


def read_A2():
    path = os.path.join(HERE, "c4_mars_pool.out")
    occ = {}
    sec = False
    for line in open(path):
        if line.startswith("## A2."):
            sec = True
            continue
        if sec and line.startswith("## A3."):
            break
        if sec:
            m = re.match(r"^(\d+(?:\.\d+)?)\s+(\w+)\s+(-|[\d.]+)\s", line)
            if m and m.group(2) in FORMS:
                occ[(float(m.group(1)), m.group(2))] = None if m.group(3) == "-" else float(m.group(3))
    return occ


def part5_6(bits):
    occ = read_A2()
    deltas = sorted({d for d, _ in occ}, reverse=True)
    out("## (5) guaranteed tolerance, no text prior: uniform over the five forms, c4's uniform element prior")
    out("%-7s %s   MAP   margin over runner-up (bits)" % ("delta'", " ".join("%10s" % f for f in FORMS)))
    for d in deltas:
        lw = {f: -occ[(d, f)] for f in FORMS if occ[(d, f)] is not None}
        mx = max(lw.values())
        Z = sum(2 ** (v - mx) for v in lw.values())
        srt = sorted(lw.values(), reverse=True)
        marg = srt[0] - srt[1] if len(srt) > 1 else float("inf")
        out("%-7g %s   %-10s %.2f" % (d, " ".join("%10.3g" % (2 ** (lw[f] - mx) / Z if f in lw else 0) for f in FORMS),
                                       max(lw, key=lw.get), marg))
    out("# parametrisation of the prior box: halving the eccentricity ranges ([0,1) -> [0,0.5)) adds 1 bit of prior")
    out("# density per eccentricity element (the compatible regions lie inside [0,0.5) at every delta <= 120'),")
    out("# so it moves the vicarious hypothesis (two eccentricities) by 1 bit against the 4-element forms and the")
    out("# circle (no eccentricity) by -1 bit against them.")
    out()
    out("## (6) honest uniform-tolerance theories (tolerance = c4 minimax error): per-datum cost against the ellipse")
    for f in ("eccentric", "equant", "vicarious"):
        c = math.log2(MINIMAX[f] / MINIMAX["ellipse"])
        cells = []
        for S in ("S1", "S2", "S3"):
            adv = bits[(S, "ellipse")] - bits[(S, f)]
            cells.append("%s: %s" % (S, ("N* %.0f" % (adv / c)) if adv > 0 else "none"))
        out("  %-10s %.3f bits/datum   %s" % (f, c, ";  ".join(cells)))
    out()


def part7(tt, th, fitsLS):
    out("## (7) intrinsic errors: minimax of each form against an exact Kepler ellipse (the ellipse's LS elements)")
    pe = fitsLS["ellipse"]
    exact = c4.lon("ellipse", pe, tt)[0]
    out("#  exact ellipse: e = %.6f; its own deviation from plan94: max %.4f'" % (pe[0], np.max(np.abs(c4.wrap(exact - th))) / ARC))
    rng = np.random.default_rng(SEED + 1)
    for f in ("eccentric", "equant", "vicarious"):
        p0 = a1_elements(f)
        starts = [p0] + [p0 * (1 + 0.02 * rng.normal(size=len(p0)) * (np.array([1 if nm in ("e", "e1", "e2") else 0 for nm in c4.NAMES[f]])))
                         for _ in range(2)]
        p, mx = c4.fit_minimax(f, tt, exact, starts)
        out("  %-10s minimax against the exact ellipse %8.4f'   (against plan94, c4: %.4f')" % (f, mx / ARC, MINIMAX[f]))
    out()


def polish_tokens(x):
    """Polish notation with fixed arities: one token per atom (heads included); unary minus is a separate
    symbol 'neg' (counted as one atom)."""
    if isinstance(x, str):
        return 1
    return sum(polish_tokens(y) for y in x)


def part8(bits):
    out("## (8) law texts in a second serialisation: Polish notation (no brackets; 'neg' for unary minus)")
    out("%-10s %s" % ("law", "   ".join("%s: brackets/Polish (bits)" % S for S in ("S1", "S2", "S3"))))
    for f in FORMS + ["K3"]:
        cells = []
        for S in ("S1", "S2", "S3"):
            x = c4.K3 if f == "K3" else c4.TEXTS[S][f]
            A = len(c4.ALPHABET[S]) - 2 + 1          # no brackets, plus 'neg'
            pb = polish_tokens(x) * math.ceil(math.log2(A))
            cells.append("%5d / %5d" % (bits[(S, f)], pb))
        out("%-10s %s" % (f, "      ".join(cells)))
    # compact K3: forall b forall c (= (* (^ (n b) 2) (^ (a b) 3)) (* (^ (n c) 2) (^ (a c) 3)))
    K3c = ["forall", "b", ["forall", "c", ["=", ["*", ["^", ["n", "b"], "2"], ["^", ["a", "b"], "3"]],
                                           ["*", ["^", ["n", "c"], "2"], ["^", ["a", "c"], "3"]]]]]
    A = len(c4.ALPHABET["S1"]) - 2 + 1 + 2          # + '^' and '3'
    kb = polish_tokens(K3c) * math.ceil(math.log2(A))
    out("# compact K3 (Polish, '^' and '3' added): %d tokens, %d bits" % (polish_tokens(K3c), kb))
    for k3 in (bits[("S1", "K3")], polish_tokens(c4.K3) * 5, kb):
        out("#   |K3| = %4d bits: bodies whose size it must fix to pay, at s = 11.3 / 14.7 bits per body: %.1f / %.1f"
            % (k3, k3 / 11.3, k3 / 14.7))
    out()


def part9():
    out("## (9) exact K3 for Jupiter and Saturn: geocentric direction error from q_b != q_Ea, 1580-1600 daily")
    t = np.arange((1580.0 - 2000.0) * c4.YEAR, (1600.0 - 2000.0) * c4.YEAR + 1e-9, 1.0)
    pE = c4.helio(3, t)
    qE = 1.0 + 3.04e-6                       # Earth-Moon mass / Sun mass
    for body, name, q in ((5, "Jupiter", 1.00095479), (6, "Saturn", 1.0015)):
        pB = c4.helio(body, t)
        f = (qE / q) ** (1.0 / 3.0)
        g1 = pB - pE
        g2 = f * pB - pE
        cosang = np.sum(g1 * g2, axis=1) / (np.linalg.norm(g1, axis=1) * np.linalg.norm(g2, axis=1))
        ang = np.arccos(np.clip(cosang, -1, 1)) / ARC
        out("  %-8s q = %.6f  relative a change %.3e   geocentric error max %.3f'  median %.3f'"
            % (name, q, 1 - f, ang.max(), np.median(ang)))
    out("#  (q: scout P c3 -- Jupiter two-body; Saturn the middle of its fitted range 1.0013-1.0019)")
    out()


def main():
    out("# c9_revision.py  seed=%d  numpy %s  python %s" % (SEED, np.__version__, sys.version.split()[0]))
    t = np.arange((1580.0 - 2000.0) * c4.YEAR, (1600.0 - 2000.0) * c4.YEAR + 1e-9, 1.0)
    tt = t - 0.5 * (t[0] + t[-1])
    th = c4.mars_helio_plane(t)[0]
    bits = texts_bits()
    part1()
    fitsLS = part2_3(tt, th, bits)
    part5_6(bits)
    part8(bits)
    part9()
    part7(tt, th, fitsLS)
    part4(tt, th, bits, fitsLS)
    out("# done in %.0f s" % (time.time() - T0))


if __name__ == "__main__":
    main()
    with open(os.path.join(HERE, "c9_revision.out"), "w") as f:
        f.write("\n".join(OUT) + "\n")
