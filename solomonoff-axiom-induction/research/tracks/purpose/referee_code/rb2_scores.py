"""rb2_scores.py -- referee B, track `purpose`, target T2 (independent code).

Seed 20261018 (Monte Carlo in part C only).  Writes rb2_scores.out next to itself.

  A. The author's example and the developer's variants: log score (bits), CRPS by its threshold integral (exact,
     piecewise) and by the kernel form E|X-x| - E|X-X'|/2 (exact rationals), CRIGN (threshold-integrated log score,
     bits), energy score ES_b for b = 0.5, 1.
  B. A search for the developer's claim "a variant reverses the two rankings": the smallest change of the scattered
     forecast's mass on the truth that makes it log-better than the near forecast while CRPS-worse.
  C. Misspecified Gaussian family for a bimodal truth: log-optimal and CRPS-optimal scales by independent methods
     (closed-form expected log score; expected CRPS by numerical integration of the Gaussian CRPS formula against the
     truth density, and by Monte Carlo); expected scores at both optima.
  D. Theorem T2.1 sanity checks: (i) on 3 outcomes the 'local Brier' rule s(x) = (1-x)^2 and the 'local spherical-like'
     rule s(x) = -x are improper (explicit q != p beating p); (ii) on 2 outcomes the Brier score is local and proper;
     (iii) a non-differentiable local rule on 3 outcomes, s(x) = -ln x + 0.3*[x > 1/2], is improper (consistent
     with McCutcheon's removal of differentiability); (iv) the log rule passes a random propriety test.
"""
import math
import os
import random
from fractions import Fraction as Fr

import numpy as np
from scipy import integrate, optimize, stats

SEED = 20261018
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def crps_kernel(atoms, x):
    e1 = sum(p * abs(y - x) for y, p in atoms)
    e2 = sum(p * q * abs(y - z) for y, p in atoms for z, q in atoms)
    return e1 - e2 / 2


def crps_integral(atoms, x):
    pts = sorted(set([y for y, _ in atoms] + [x]))
    tot = Fr(0)
    for a, b in zip(pts[:-1], pts[1:]):
        F = sum(p for y, p in atoms if y <= a)
        H = 1 if a >= x else 0
        tot += (b - a) * (F - H) ** 2
    return tot


def crign(atoms, x):
    pts = sorted(set([y for y, _ in atoms] + [x]))
    tot = 0.0
    for a, b in zip(pts[:-1], pts[1:]):
        F = float(sum(p for y, p in atoms if y <= a))
        v = F if a >= x else 1 - F
        tot += float(b - a) * (-math.log2(v))
    return tot


def energy(atoms, x, b):
    e1 = sum(float(p) * abs(float(y - x)) ** b for y, p in atoms)
    e2 = sum(float(p * q) * abs(float(y - z)) ** b for y, p in atoms for z, q in atoms)
    return e1 - e2 / 2


def logscore(atoms, x):
    return -math.log2(float(sum(p for y, p in atoms if y == x)))


def part_A():
    out("\n== A. truth x = 0; scores as losses (lower is better)")
    fc = {
        "near {-2..2}": [(Fr(v), Fr(1, 5)) for v in range(-2, 3)],
        "scattered {-20,-10,0,10,20}": [(Fr(v), Fr(1, 5)) for v in (-20, -10, 0, 10, 20)],
        "scattered {-37,0,12,55,81}": [(Fr(v), Fr(1, 5)) for v in (-37, 0, 12, 55, 81)],
        "scattered, 0.21 on truth": [(Fr(0), Fr(21, 100))] + [(Fr(v), Fr(79, 400)) for v in (-20, -10, 10, 20)],
        "refs-report {-40,-17,0,23,51}": [(Fr(v), Fr(1, 5)) for v in (-40, -17, 0, 23, 51)],
    }
    out("   %-31s %8s %9s %9s %9s %8s %8s" % ("forecast", "LS bits", "CRPS ker", "CRPS int", "CRIGN", "ES_0.5", "ES_1"))
    for k, a in fc.items():
        ck, ci = crps_kernel(a, Fr(0)), crps_integral(a, Fr(0))
        assert ck == ci, (k, ck, ci)
        out("   %-31s %8.4f %9.4f %9.4f %9.4f %8.4f %8.4f" % (k, logscore(a, 0), float(ck), float(ci), crign(a, Fr(0)),
                                                         energy(a, Fr(0), 0.5), energy(a, Fr(0), 1.0)))
    out("   (CRPS kernel and integral forms agree EXACTLY in rationals; ES_1 = CRPS as it must)")
    return fc


def part_B(fc):
    out("\n== B. reversal: scattered forecast with mass m on the truth and (1-m)/4 on each of -20,-10,10,20")
    near = fc["near {-2..2}"]
    lsn, crn = logscore(near, 0), float(crps_kernel(near, Fr(0)))
    for m in (Fr(1, 5), Fr(201, 1000), Fr(21, 100), Fr(1, 2), Fr(9, 10), Fr(99, 100)):
        a = [(Fr(0), m)] + [(Fr(v), (1 - m) / 4) for v in (-20, -10, 10, 20)]
        ls, cr = logscore(a, 0), float(crps_kernel(a, Fr(0)))
        out("   m=%-6s LS %.4f (near %.4f) CRPS %.4f (near %.4f): LS prefers %s, CRPS prefers %s" % (
            str(m), ls, lsn, cr, crn, "scattered" if ls < lsn else ("tie" if ls == lsn else "near"),
            "scattered" if cr < crn else "near"))
    # where does CRPS switch? solve CRPS(m) = CRPS(near)
    f = lambda m: float(crps_kernel([(Fr(0), Fr(m))] + [(Fr(v), (1 - Fr(m)) / 4) for v in (-20, -10, 10, 20)], Fr(0))) - crn
    mstar = optimize.brentq(lambda m: f(Fr(m).limit_denominator(10 ** 12)), 0.2, 0.999999)
    out("   CRPS of the scattered family equals the near forecast's at m* = %.6f: for 1/5 < m < m* the two scores rank"
        " the pair oppositely" % mstar)


def part_C():
    out("\n== C. truth P = 0.5 N(-1, 0.1^2) + 0.5 N(1, 0.1^2); family N(0, s^2)")
    mu, sd = 1.0, 0.1
    EX2 = mu ** 2 + sd ** 2
    s_log = math.sqrt(EX2)
    def exp_ls_bits(s):    # E[-log2 phi_s(X)] = 0.5 log2(2 pi s^2) + E X^2 / (2 s^2 ln 2)
        return 0.5 * math.log2(2 * math.pi * s * s) + EX2 / (2 * s * s * math.log(2))
    def crps_gauss(s, x):
        z = x / s
        return s * (z * (2 * stats.norm.cdf(z) - 1) + 2 * stats.norm.pdf(z) - 1 / math.sqrt(math.pi))
    def dens(x):
        return 0.5 * stats.norm.pdf(x, -mu, sd) + 0.5 * stats.norm.pdf(x, mu, sd)
    def exp_crps(s):
        # symmetric truth: integrate over x > 0 and double
        v, _ = integrate.quad(lambda x: crps_gauss(s, x) * dens(x), 0.0, 3.0, limit=200, points=[1.0])
        return 2 * v
    res = optimize.minimize_scalar(exp_crps, bounds=(0.5, 2.0), method="bounded", options={"xatol": 1e-10})
    s_crps = res.x
    # Monte Carlo check of the expected CRPS at both scales, kernel form E|Y-X| - E|Y-Y'|/2
    rng = np.random.default_rng(SEED)
    n = 400000
    X = np.where(rng.random(n) < 0.5, -mu, mu) + sd * rng.standard_normal(n)
    def mc_crps(s):
        Y = s * rng.standard_normal(n)
        Yp = s * rng.standard_normal(n)
        return float(np.mean(np.abs(Y - X)) - 0.5 * np.mean(np.abs(Y - Yp)))
    out("   log-optimal s = sqrt(E X^2) = %.6f; CRPS-optimal s (bounded scalar minimisation of quad integral) = %.6f" % (
        s_log, s_crps))
    for name, s in (("s_log", s_log), ("s_crps", s_crps)):
        out("   N(0,%s^2): E log score %.5f bits | E CRPS %.5f (quad) %.5f (Monte Carlo, n=%d)" % (
            name, exp_ls_bits(s), exp_crps(s), mc_crps(s), n))
    out("   -> each proper score prefers its own projection: E LS(s_log) < E LS(s_crps), E CRPS(s_crps) < E CRPS(s_log)")


def part_D():
    out("\n== D. local rules: propriety checks (expected loss sum_w p(w) s(q(w)) minimised over q in the simplex)")
    rng = random.Random(SEED)
    def worst_gap(s, m, trials=2000):
        """max over random interior p of [E_p S(p) - min_q E_p S(q)] (>0: improper); q minimised by SLSQP + random"""
        best = (0.0, None, None)
        for _ in range(trials // 20):
            p = np.array([rng.random() + 0.05 for _ in range(m)])
            p /= p.sum()
            Ep = lambda q: float(np.sum(p * s(np.clip(q, 1e-12, 1))))
            base = Ep(p)
            cands = [np.array([rng.random() + 1e-3 for _ in range(m)]) for _ in range(20)]
            cands = [c / c.sum() for c in cands] + [np.eye(m)[i] * 0.999 + 0.001 / m for i in range(m)]
            for c in cands:
                r = optimize.minimize(Ep, c, method="SLSQP", bounds=[(1e-9, 1)] * m,
                                      constraints=[{"type": "eq", "fun": lambda q: q.sum() - 1}])
                if r.success and base - r.fun > best[0]:
                    best = (base - r.fun, p.copy(), r.x.copy())
        return best
    rules = {
        "local Brier s(x)=(1-x)^2, m=3": (lambda x: (1 - x) ** 2, 3),
        "linear s(x)=-x, m=3": (lambda x: -x, 3),
        "log s(x)=-ln x, m=3": (lambda x: -np.log(x), 3),
        "log s(x)=-ln x, m=5": (lambda x: -np.log(x), 5),
        "kinked s(x)=-ln x + 0.3[x>1/2], m=3": (lambda x: -np.log(x) + 0.3 * (x > 0.5), 3),
    }
    for name, (s, m) in rules.items():
        gap, p, q = worst_gap(s, m)
        out("   %-38s max improvement found %.3e%s" % (name, gap, "" if p is None else
                                                       "  (p=%s, q=%s)" % (np.round(p, 3), np.round(q, 3))))
    # binary Brier, written as a local rule s(p(w), w) = (1 - p(w))^2 + (1 - p(w))^2 ... on two outcomes p(w') = 1-p(w)
    def bin_brier(qw, w_is_1):
        return 2 * (1 - qw) ** 2      # (1-q(w))^2 + q(w')^2 = 2(1-q(w))^2 on two outcomes
    worst = 0.0
    for _ in range(200):
        p = rng.random()
        qs = np.linspace(0.0005, 0.9995, 2000)
        E = p * bin_brier(qs, 1) + (1 - p) * bin_brier(1 - qs, 0)
        worst = max(worst, abs(qs[np.argmin(E)] - p))
    out("   binary Brier written as a function of q(realised) only: minimiser within %.1e of p on 200 random p (proper)" % worst)


def main():
    out("# rb2_scores.py seed=%d (referee B, independent of checks/p2_scores.py)" % SEED)
    fc = part_A()
    part_B(fc)
    part_C()
    part_D()
    out("\n# done")
    with open(os.path.join(HERE, "rb2_scores.out"), "w") as f:
        f.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
