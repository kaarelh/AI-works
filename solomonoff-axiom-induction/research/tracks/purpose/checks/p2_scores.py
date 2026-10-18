"""p2_scores.py -- track `purpose`, target T2: local and distance-sensitive scores on the author's example, and
proper scores ranking wrong forecasts in opposite orders.

Deterministic (no randomness).  Writes p2_scores.out next to itself.  All scores are LOSSES (lower is better), in
bits for the logarithmic ones and in the units of the outcome for CRPS / energy score.

  log score       LS(P, x)    = -log2 P({x})                     (discrete)  or -log2 p(x) (densities)
  CRPS            CRPS(F, x)  = int (F(t) - 1{t >= x})^2 dt  = E|X - x| - (1/2) E|X - X'|
  energy score    ES_b(P, x)  = E|X - x|^b - (1/2) E|X - X'|^b,  0 < b < 2  (b = 1: CRPS)
  CRIGN           CRIGN(F, x) = int -log2( F(t) if t >= x else 1 - F(t) ) dt   (threshold-integrated log score)

Parts
  A. The author's example: uniform on 5 nearby values vs 5 scattered values, truth among them.
  B. Opposite rankings by LS and CRPS: the scattered forecast with slightly more mass on the truth.
  C. A non-degenerate truth: P = (1/2) N(-1, 0.1^2) + (1/2) N(1, 0.1^2), family N(0, s^2): the log-optimal and the
     CRPS-optimal scale differ, and the two scores rank the two fitted members in opposite orders.
"""
import math
import os

import numpy as np
from scipy import integrate, optimize, stats

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def discrete_scores(pts, probs, x, b=0.5):
    pts = np.asarray(pts, float)
    probs = np.asarray(probs, float)
    ls = -math.log2(probs[pts == x].sum())
    e1 = float(np.sum(probs * np.abs(pts - x)))
    e2 = float(np.sum(probs[:, None] * probs[None, :] * np.abs(pts[:, None] - pts[None, :])))
    crps = e1 - 0.5 * e2
    # direct integral of (F(t) - 1{t>=x})^2 over the breakpoints
    brk = np.unique(np.concatenate([pts, [x]]))
    crps_int, crign = 0.0, 0.0
    for a, c in zip(brk[:-1], brk[1:]):
        t = (a + c) / 2
        F = probs[pts <= t].sum()
        crps_int += (c - a) * (F - (1.0 if t >= x else 0.0)) ** 2
        pr = F if t >= x else 1 - F
        crign += (c - a) * (-math.log2(pr)) if pr > 0 else float("inf")
    esb = float(np.sum(probs * np.abs(pts - x) ** b)) - 0.5 * float(
        np.sum(probs[:, None] * probs[None, :] * np.abs(pts[:, None] - pts[None, :]) ** b))
    return ls, crps, crps_int, crign, esb


def gauss_crps(mu, s, x):
    z = (x - mu) / s
    return s * (z * (2 * stats.norm.cdf(z) - 1) + 2 * stats.norm.pdf(z) - 1 / math.sqrt(math.pi))


def main():
    out("# p2_scores.py (deterministic)")
    out("\n== A. truth x = 0; forecasts uniform on 5 points")
    out("   %-36s %8s %8s %8s %8s %8s" % ("forecast", "LS", "CRPS", "CRPS(int)", "CRIGN", "ES_0.5"))
    near = ([-2, -1, 0, 1, 2], [0.2] * 5)
    far = ([-20, -10, 0, 10, 20], [0.2] * 5)
    rnd = ([-37, 0, 12, 55, 81], [0.2] * 5)
    farp = ([-20, -10, 0, 10, 20], [0.1975, 0.1975, 0.21, 0.1975, 0.1975])
    for name, (pts, pr) in (("near {-2,...,2}", near), ("scattered {-20,-10,0,10,20}", far),
                            ("scattered {-37,0,12,55,81}", rnd), ("scattered, 0.21 on the truth", farp)):
        ls, c, ci, cr, es = discrete_scores(pts, pr, 0.0)
        out("   %-36s %8.4f %8.4f %8.4f %8.4f %8.4f" % (name, ls, c, ci, cr, es))
    out("   -> LS equal (log2 5) for the three uniform forecasts; CRPS, CRIGN, ES grow with the spread.")
    out("   -> B. 'scattered, 0.21 on the truth' has the lower LS (%.4f < %.4f) and the higher CRPS: opposite rankings."
        % (-math.log2(0.21), math.log2(5)))

    out("\n== C. truth P = 0.5 N(-1, 0.1^2) + 0.5 N(1, 0.1^2); family N(0, s^2) (misspecified)")
    w, m, sd = 0.5, 1.0, 0.1

    def pdf(x):
        return w * stats.norm.pdf(x, -m, sd) + (1 - w) * stats.norm.pdf(x, m, sd)

    def exp_score(f):
        return integrate.quad(lambda x: pdf(x) * f(x), -3, 3, points=[-1, 1], limit=400)[0]

    def E_LS(s):
        return exp_score(lambda x: -stats.norm.logpdf(x, 0, s) / math.log(2))

    def E_CRPS(s):
        return exp_score(lambda x: gauss_crps(0.0, s, x))
    s_log = math.sqrt(m * m + sd * sd)          # moment matching = KL projection onto N(0, s^2)
    r_log = optimize.minimize_scalar(E_LS, bounds=(0.2, 3), method="bounded", options={"xatol": 1e-10})
    r_crps = optimize.minimize_scalar(E_CRPS, bounds=(0.05, 3), method="bounded", options={"xatol": 1e-10})
    out("   log-optimal scale: closed form sqrt(E X^2) = %.6f, numerical %.6f" % (s_log, r_log.x))
    out("   CRPS-optimal scale: %.6f" % r_crps.x)
    for name, s in (("N(0, s_log^2)", s_log), ("N(0, s_crps^2)", r_crps.x)):
        out("   %-16s expected LS = %.5f bits (density), expected CRPS = %.5f" % (name, E_LS(s), E_CRPS(s)))
    out("   -> LS prefers N(0, s_log^2), CRPS prefers N(0, s_crps^2): both proper, opposite rankings of two wrong forecasts.")
    # sanity: CRPS closed form against the integral definition at one point
    x0, s0 = 0.7, 0.9
    ci = integrate.quad(lambda t: (stats.norm.cdf(t, 0, s0) - (t >= x0)) ** 2, -12, 12, points=[x0], limit=400)[0]
    out("   check: Gaussian CRPS closed form %.8f vs integral %.8f" % (gauss_crps(0, s0, x0), ci))
    out("\n# done")
    with open(os.path.join(HERE, "p2_scores.out"), "w") as f:
        f.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
