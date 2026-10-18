"""rb4_toy.py -- referee B, track `purpose`, target T4(a) (independent code).

Seed 20261018.  Writes rb4_toy.out next to itself.

  A. The developer's toy (law A: errors U[-1,1]; law B: errors -M, 0, M w.p. rho/2, 1-rho, rho/2, M = 1000,
     rho = 0.2) and the pointwise-dominance pair (A': s U, B': s), by SIMULATION: deterministic error sequences
     e(t_j) drawn once, i.i.d. dithers, and the band-confined machine with the calibrated error law scored by its
     exact cell probabilities; against the closed forms of notes T4(a).  The crossovers Delta_c by root finding.
  B. The regime-R consistency point.  If the truth is q(t) and two computable laws f_A, f_B have errors
     e_A = f_A - q, e_B = f_B - q, then e_A - e_B = f_A - f_B is a computable function of t.  (i) In the toy this
     determines q: a machine that knows f_A and f_B decodes e_B exactly from d(t) = f_A(t) - f_B(t) and has rate 0.
     (ii) If instead A's errors are genuinely i.i.d. random (regime R's hypothesis for A), then B's errors are
     e_A - d(t) and the calibrated B-machine's rate is never below A's: computed for d(t) in {-M, 0, M}
     (the toy's B-pattern imposed on random A-errors).  So the toy's ranking "B beats A" can only occur for
     deterministic error sequences, where Prop. 9.2(c)'s lower bound and the limit of L_A/n do not apply.
"""
import math
import os

import numpy as np
from scipy import optimize

SEED = 20261018
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []
LN2 = math.log(2)


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def H(ps):
    ps = np.asarray(ps, float)
    ps = ps[ps > 0]
    return float(-(ps * np.log2(ps)).sum())


# ----------------------------------------------------------------------- calibrated cell probabilities (exact)
def cell_prob_uniform(lo, hi, a=-1.0, b=1.0):
    return np.clip(np.minimum(hi, b) - np.maximum(lo, a), 0, None) / (b - a)


def cell_prob_atoms(lo, hi, xs, ps):
    tot = np.zeros_like(lo)
    for x, p in zip(xs, ps):
        tot += p * ((lo <= x) & (x < hi))
    return tot


def sim_rate(e, Delta, prob_fn, rng):
    """cells of a dithered grid containing the error e (equivalently the value, by translation): [e - r, e - r + D)"""
    r = rng.uniform(0, Delta, e.size)
    lo, hi = e - r, e - r + Delta
    p = prob_fn(lo, hi)
    v = -np.log2(np.maximum(p, 1e-300))
    return float(v.mean()), float(v.std() / math.sqrt(e.size))


def rate_A(D):
    return 1 + D / (4 * LN2) - math.log2(D) if D <= 2 else (1 / LN2) / D


def part_A(rng):
    M, rho, n = 1000.0, 0.2, 400000
    xsB, psB = [-M, 0.0, M], [rho / 2, 1 - rho, rho / 2]
    eA = rng.uniform(-1, 1, n)
    eB = rng.choice(xsB, size=n, p=psB)
    HB = H(psB)
    out("\n== A. toy 1: law A errors U[-1,1]; law B errors {-M,0,M} w.p. {.1,.8,.1}, M=1000; n = %d data per Delta" % n)
    out("   %8s | %18s %8s | %18s %8s" % ("Delta", "A simulated", "closed", "B simulated", "closed"))
    for D in (0.1, 0.5, 1.0, 1.5, 1.55, 1.6, 2.0, 10.0, 1500.0, 4000.0):
        a, sa = sim_rate(eA, D, lambda lo, hi: cell_prob_uniform(lo, hi), rng)
        b, sb = sim_rate(eB, D, lambda lo, hi: cell_prob_atoms(lo, hi, xsB, psB), rng)
        cb = HB if D <= M else ((2 * M * H([rho / 2, 1 - rho / 2])) / D if D >= 2 * M else float("nan"))
        out("   %8.2f | %9.5f +- %.5f %8.5f | %9.5f +- %.5f %8.5f" % (D, a, sa, rate_A(D), b, sb, cb))
    Dc = optimize.brentq(lambda D: rate_A(D) - HB, 1.0, 2.0, xtol=1e-14)
    out("   H(B) = %.6f; crossover Delta_c = %.6f (developer 1.558542)" % (HB, Dc))
    # is there a second crossover in (2, 2M)?  rate_A <= 1/(2 ln2) < H(B) there, and for Delta in (M, 2M) check B
    Ds = np.linspace(M, 2 * M, 21)
    bvals = [sim_rate(eB[:100000], D, lambda lo, hi: cell_prob_atoms(lo, hi, xsB, psB), rng)[0] for D in Ds]
    out("   B's rate on (M, 2M): min %.4f > rate_A there (<= %.5f): no second crossover" % (min(bvals), rate_A(M)))
    # pointwise dominance pair
    s = rng.choice([-1.0, 1.0], size=n)
    U = rng.uniform(0, 1, n)
    eAp, eBp = s * U, s
    assert np.all(np.abs(eAp) <= np.abs(eBp))
    out("\n   toy 2: A' = s U, B' = s (|e_A'| <= |e_B'| at every datum, asserted)")
    for D in (0.5, 1.0, 1.4, 1.45, 2.0):
        a, sa = sim_rate(eAp, D, lambda lo, hi: cell_prob_uniform(lo, hi), rng)
        b, sb = sim_rate(eBp, D, lambda lo, hi: cell_prob_atoms(lo, hi, [-1.0, 1.0], [0.5, 0.5]), rng)
        out("   Delta %.2f: A' %.5f +- %.5f (closed %.5f) | B' %.5f +- %.5f (closed 1 for Delta <= 2)" % (
            D, a, sa, rate_A(D), b, sb))
    Dc2 = optimize.brentq(lambda D: rate_A(D) - 1.0, 1.0, 2.0, xtol=1e-14)
    out("   crossover Delta_c' = %.6f (developer 1.429612); the other root of Delta/4 = ln Delta, %.4f, lies where the"
        " closed form no longer applies (Delta > 2)" % (Dc2, optimize.brentq(lambda D: D / 4 - math.log(D), 3, 20)))


def part_B(rng):
    out("\n== B. two laws for one quantity: what regime R allows")
    M, n = 1000.0, 400000
    # (i) deterministic toy: q(t) arbitrary; f_B = q + e_B; f_A = q + e_A; the pair decodes q
    q = rng.uniform(-5000, 5000, n)
    eA = rng.uniform(-1, 1, n)
    eB = rng.choice([-M, 0.0, M], size=n, p=[0.1, 0.8, 0.1])
    fA, fB = q + eA, q + eB
    d = fA - fB
    eB_dec = M * np.round(-d / M)           # e_B = e_A - d with |e_A| <= 1 < M/2: the element of {-M,0,M} nearest -d
    eB_dec = np.where(np.abs(eB_dec + d) <= 1, eB_dec, np.nan)   # consistency: e_A = e_B + d must lie in [-1, 1]
    q_dec = fB - eB_dec
    out("   (i) knowing f_A and f_B: e_B decoded from d(t) = f_A - f_B on %d of %d data; max |q_dec - q| = %.2e"
        % (int(np.sum(np.isfinite(eB_dec) & (eB_dec == eB))), n, float(np.nanmax(np.abs(q_dec - q)))))
    out("       so a theory machine stating both laws (and the decoding) proves every cell: rate 0 < both laws' rates;"
        " SAI's own rate here is 0, not min(r_A, r_B)")
    # (ii) A's errors random i.i.d. U[-1,1]; B = A shifted by a deterministic pattern d(t) in {-M, 0, M}
    dpat = rng.choice([-M, 0.0, M], size=n, p=[0.1, 0.8, 0.1])
    eB2 = eA - dpat
    # calibrated (time-invariant) law of e_B2: mixture of U[-1-m, 1-m]
    def probB(lo, hi):
        return sum(w * cell_prob_uniform(lo, hi, -1 - m, 1 - m) for m, w in ((-M, .1), (0.0, .8), (M, .1)))
    out("   (ii) A's errors i.i.d. U[-1,1] (random); B's errors e_A - d(t), d(t) in {-M,0,M} w.p. {.1,.8,.1}:")
    for D in (0.1, 1.0, 1.5, 2.0, 10.0):
        a, sa = sim_rate(eA, D, lambda lo, hi: cell_prob_uniform(lo, hi), rng)
        b, sb = sim_rate(eB2, D, probB, rng)
        out("       Delta %5.1f: calibrated A %.4f +- %.4f | calibrated B %.4f +- %.4f | B - A = %+.4f (H(d) = 0.9219)"
            % (D, a, sa, b, sb, b - a))
    out("       B never beats A: with A's errors random, r_A is Prop. 9.2(c)'s lower bound for EVERY machine; a ranking")
    out("       of two laws' calibrated machines that differs from 'A first' needs errors that are not random for either.")


def main():
    rng = np.random.default_rng(SEED)
    out("# rb4_toy.py seed=%d numpy %s (referee B, independent of checks/p4_toy.py)" % (SEED, np.__version__))
    part_A(rng)
    part_B(rng)
    out("\n# done")
    with open(os.path.join(HERE, "rb4_toy.out"), "w") as f:
        f.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
