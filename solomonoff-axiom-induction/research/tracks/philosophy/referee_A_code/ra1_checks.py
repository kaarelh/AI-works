"""Referee A (philosophy) checks for tracks/philosophy/notes.md.  Seeded (20261016); writes ra1_checks.out.

Parts:
 (1) Conservation world (notes Prop 2.2(d)): the "factor of about 2" between the law's value per raw step and per
     question depends on the no-law question baseline.  Compare the record's uniform baseline log2(m+1) with the
     fair baseline H(Binomial(m,1/2)) (the true distribution of |x_t| when x_t is uniform on {0,1}^m).
 (2) Law texts of c4 (notes §4.4): token counts with brackets (c4's serialisation) and without brackets (Polish
     notation with fixed arities, also prefix-free).  K3 cost and the number of bodies at which K3 pays.
 (3) Noise regime for the Mars pool: least-squares residuals of each form against the c4 data (plan94 Mars,
     heliocentric longitude in the best plane, 1580.0-1600.0 daily); expected Gaussian log-likelihood penalty per
     independent observation relative to the ellipse at sigma = 1', 2'; number of observations N* at which the
     cumulative penalty exceeds the S1 / S2 law-text differences.  Also the per-datum cost log2(eps_F/eps_ellipse)
     of honest uniform-tolerance theories with eps = minimax error.
 (4) Intrinsic form errors: minimax fit of each form to an EXACT unperturbed Kepler ellipse (e = 0.0934,
     P = 686.98 d) over the same 20 years, to separate form error from perturbation error.
 (5) Exact K3 for Jupiter and Saturn: geocentric angular error (1580-1600, plan94 positions) caused by the
     third-law constant q = n^2 a^3/k^2 differing from the Earth's, with q-1 = 9.5e-4 (Jupiter, two-body) and
     1.5e-3 (Saturn, the record's fitted range 1.0013-1.0019).
Run:  PYTHONPATH=<pyerfa lib> python3 ra1_checks.py   (imports c4_mars_pool from ../checks for data and models)
"""
import sys, os, math, time
import numpy as np
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "checks"))
import c4_mars_pool as c4  # noqa: E402  (module-level code only defines functions and constants)
from scipy.optimize import least_squares  # noqa: E402
from scipy.stats import binom  # noqa: E402

SEED = 20261016
rng = np.random.default_rng(SEED)
out = []


def P(*a):
    s = " ".join(str(x) for x in a)
    print(s)
    out.append(s)


T0 = time.time()
P("# ra1_checks.py seed=%d numpy %s" % (SEED, np.__version__))

# ---------------------------------------------------------------- (1)
P("\n## (1) conservation world: law's value per raw step vs per question, two no-law QA baselines")
P("%8s %14s %16s %18s %12s %12s" % ("m", "raw gain", "uniform QA", "binomial QA H", "ratio unif", "ratio binom"))
for m in [8, 12, 16, 32, 64, 128, 1024]:
    lgC = (math.lgamma(m + 1) - 2 * math.lgamma(m / 2 + 1)) / math.log(2)
    raw = m - lgC                          # log2(S/C), the gain at t = 0
    unif = math.log2(m + 1)
    k = np.arange(m + 1)
    p = binom.pmf(k, m, 0.5)
    p = p[p > 0]
    H = float(-(p * np.log2(p)).sum())
    P("%8d %14.4f %16.4f %18.4f %12.3f %12.3f" % (m, raw, unif, H, unif / raw, H / raw))
P("# asymptotics: raw gain ~ 0.5 log2(pi m/2); H(Bin) ~ 0.5 log2(pi e m/2); difference -> 0.5 log2 e = %.4f bits"
  % (0.5 * math.log2(math.e)))

# ---------------------------------------------------------------- (2)
P("\n## (2) law-text lengths: c4 serialisation (brackets counted) vs Polish notation (no brackets)")


def tok_nobr(x):
    if isinstance(x, str):
        return 1
    return sum(tok_nobr(y) for y in x)


bits_per = {S: math.ceil(math.log2(len(c4.ALPHABET[S]))) for S in ("S1", "S2", "S3")}
bitsP = {S: math.ceil(math.log2(len([a for a in c4.ALPHABET[S] if a not in ("(", ")")]))) for S in ("S1", "S2", "S3")}
P("# bits/token with brackets: %s ; Polish (alphabet without brackets): %s" % (bits_per, bitsP))
P("%-10s %s" % ("law", "  ".join("%s:br/Pol" % S for S in ("S1", "S2", "S3"))))
L = {}
for f in c4.FORMS + ["K3"]:
    row = []
    for S in ("S1", "S2", "S3"):
        x = c4.K3 if f == "K3" else c4.TEXTS[S][f]
        a = c4.tokens(x) * bits_per[S]
        b = tok_nobr(x) * bitsP[S]
        L[(S, f)] = (a, b)
        row.append("%5d/%5d" % (a, b))
    P("%-10s %s" % (f, "   ".join(row)))
for S in ("S1", "S2"):
    P("# %s differences (brackets / Polish): equant-ellipse %d / %d; vicarious-ellipse %d / %d; ellipse-vicarious %d / %d"
      % (S, L[(S, "equant")][0] - L[(S, "ellipse")][0], L[(S, "equant")][1] - L[(S, "ellipse")][1],
         L[(S, "vicarious")][0] - L[(S, "ellipse")][0], L[(S, "vicarious")][1] - L[(S, "ellipse")][1],
         L[(S, "ellipse")][0] - L[(S, "vicarious")][0], L[(S, "ellipse")][1] - L[(S, "vicarious")][1]))
# a compact K3 with a power symbol: forall b forall c (= (* (^ n b 2)... ) written in Polish with '^' and '3'
K3c = ["forall", "b", ["forall", "c", ["=", ["*", ["^", ["n", "b"], "2"], ["^", ["a", "b"], "3"]],
                                           ["*", ["^", ["n", "c"], "2"], ["^", ["a", "c"], "3"]]]]]
nK3c = tok_nobr(K3c)
P("# compact K3 (Polish, with '^' and numeral '3' added to S1, 32 symbols -> 5 bits/token): %d tokens = %d bits"
  % (nK3c, nK3c * 5))
for name, kb in [("c4 S1", L[("S1", "K3")][0]), ("Polish S1", L[("S1", "K3")][1]), ("compact", nK3c * 5)]:
    P("#   |K3| = %4d bits: bodies needed at s = 11.3 / 14.7 bits per body: %.1f / %.1f" % (kb, kb / 11.3, kb / 14.7))

# ---------------------------------------------------------------- data for (3), (4)
t = np.arange((1580.0 - 2000.0) * c4.YEAR, (1600.0 - 2000.0) * c4.YEAR + 1e-9, 1.0)
N = len(t)
tt = t - 0.5 * (t[0] + t[-1])
theta, r, incl, node, oop = c4.mars_helio_plane(t)
n0 = c4.TWO_PI / 686.98
w0 = theta[np.argmin(r)] % c4.TWO_PI
L0 = theta[N // 2] % c4.TWO_PI
e0 = (r.max() - r.min()) / (r.max() + r.min())


def starts(form, m=6):
    outs = []
    for j in range(m):
        jit = rng.normal(size=5)
        e = abs(e0 * (1 + 0.3 * jit[0])); w = w0 + 0.2 * jit[1]; Lm = L0 + 0.05 * jit[2]; n = n0 * (1 + 1e-4 * jit[3])
        if form == "circle":
            outs.append(np.array([Lm, n]))
        elif form == "eccentric":
            outs.append(np.array([2 * e, w, Lm, n]))
        elif form == "vicarious":
            outs.append(np.array([1.2 * e, 0.8 * e * (1 + 0.3 * jit[4]), w, Lm, n]))
        else:
            outs.append(np.array([e, w, Lm, n]))
    return outs


def lsq(form, th, st):
    best = None
    for p0 in st:
        try:
            s = least_squares(lambda p: c4.res(form, p, tt, th), p0, method="lm", xtol=1e-15, ftol=1e-15,
                              gtol=1e-15, max_nfev=20000)
        except Exception:
            continue
        rr = c4.res(form, s.x, tt, th)
        v = float(np.mean(rr ** 2))
        if best is None or v < best[1]:
            best = (s.x, v, float(np.max(np.abs(rr))))
    return best


AM = c4.ARCMIN
P("\n## (3) noise regime: least-squares fits to the c4 data (N = %d daily heliocentric longitudes)" % N)
fitsLS = {}
for f in ["eccentric", "equant", "vicarious", "ellipse"]:
    x, v, mx = lsq(f, theta, starts(f))
    fitsLS[f] = (x, v, mx)
    P("%-10s RMS %8.3f'   max %8.3f'" % (f, math.sqrt(v) / AM, mx / AM))
minimax = {"eccentric": 23.05, "equant": 8.17, "vicarious": 1.41, "ellipse": 1.07}   # notes §4.3 (c4 A1)
textdiff = {S: {f: L[(S, f)][0] - L[(S, "ellipse")][0] for f in minimax} for S in ("S1", "S2")}
P("# expected penalty per independent Gaussian observation (bits) relative to the ellipse:"
  " (RMS_F^2 - RMS_ell^2)/(2 sigma^2 ln 2).  text = |LAW_F| - |LAW_ellipse| (c4 bits); where text < 0 the form"
  " is the shorter text and N* = -text/penalty observations overcome it; n/a: the ellipse is already shorter")
for sig in (1.0, 2.0):
    for f in ["eccentric", "equant", "vicarious"]:
        pen = (fitsLS[f][1] - fitsLS["ellipse"][1]) / (2 * (sig * AM) ** 2 * math.log(2))
        cells = []
        for S in ("S1", "S2"):
            td = textdiff[S][f]
            cells.append("N*(%s, text %+5d) = %s" % (S, td, ("%8.1f" % (-td / pen)) if td < 0 else "     n/a"))
        P("  sigma %.0f'  %-10s penalty %8.4f bits/obs   %s" % (sig, f, pen, "   ".join(cells)))
P("# honest uniform-tolerance theories with eps_F = minimax error: per-datum cost difference log2(eps_F/eps_ell)")
for f in ["eccentric", "equant", "vicarious"]:
    d = math.log2(minimax[f] / minimax["ellipse"])
    cells = ["N*(%s) = %s" % (S, ("%.0f" % (-textdiff[S][f] / d)) if textdiff[S][f] < 0 else "n/a") for S in ("S1", "S2")]
    P("  %-10s %.3f bits/datum; %s" % (f, d, ", ".join(cells)))

# ---------------------------------------------------------------- (4)
P("\n## (4) intrinsic form errors against an exact unperturbed Kepler ellipse (e = 0.0934, P = 686.98 d)")
pK = np.array([0.0934, w0, L0, n0])
thK = np.unwrap(c4.lon("ellipse", pK, tt)[0])
for f in ["eccentric", "equant", "vicarious"]:
    x, mx = c4.fit_minimax(f, tt, thK, starts(f))
    P("%-10s minimax vs exact ellipse %8.3f'   (vs plan94, notes §4.3: %.2f')" % (f, mx / AM, minimax[f]))

# ---------------------------------------------------------------- (5)
P("\n## (5) exact K3 for Jupiter and Saturn: geocentric angular error from q != q_Earth (1580-1600)")
emb = c4.helio(3, t)
for body, name, q in [(5, "Jupiter", 1 + 1 / 1047.35), (6, "Saturn", 1.0015)]:
    xb = c4.helio(body, t)
    qE = 1 + 1 / 332946.0 + 1 / 27068510.0
    scale = (qE / q) ** (1 / 3)                       # a from K3 normalised on the Earth, relative to true a
    g1 = xb - emb
    g2 = xb * scale - emb
    ang = np.arccos(np.clip(np.sum(g1 * g2, 1) / np.linalg.norm(g1, axis=1) / np.linalg.norm(g2, axis=1), -1, 1))
    P("%-8s q-1 = %.2e   relative a error %.2e   geocentric error max %.3f'  median %.3f'"
      % (name, q - 1, 1 - scale, np.max(ang) / AM, np.median(ang) / AM))

P("\n# done in %.0f s" % (time.time() - T0))
with open(os.path.join(HERE, "ra1_checks.out"), "w") as fh:
    fh.write("\n".join(out) + "\n")
