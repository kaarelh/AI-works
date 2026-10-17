"""l9_correction.py -- explanation by approximate correction in a provable toy (thread `laws`, T7; notes
section 7).  Exact rational arithmetic (fractions.Fraction); deterministic (seed listed for uniformity).

Seed 20261016.  Writes l9_correction.out next to itself.

Toy.  Planar discrete-time motion.  T_0 (the old, exact law): x_t = R^t a, R the rotation with cos = 3/5,
sin = 4/5 (uniform circular motion).  T_N (the successor): x_{t+1} = A x_t with A = R + eta P, eta = 1/100.
Perturbations P: (i) P = J R (J = rotation by 90 deg): A = sqrt(1 + eta^2) R_{theta + arctan eta}, a slow
outward spiral plus a precession; (ii) P = S R, S = diag(1, -1): a distortion of the circle; (iii) P = I.
Initial condition a = (1, 0).  All entries rational, so for every t, x_t = A^t a is an exact rational vector.
Computed for windows W:
  * eps_min(W)^2 = max_{t <= W} |A^t a - R^t a|^2 (exact rational): the least tolerance eps such that
    T_N^W proves the honest law H_W^eps := { |x_t - R^t a| <= eps : t <= W } (Prop 7.1(b));
  * the general bound eps(W) = ((1 + eta ||P||)^W - 1) |a| (Prop 7.1(a)), ||P|| the operator 2-norm
    (computed in floating point, so the comparison eps_min <= eps(W) is checked with a 1e-12 margin);
  * the refutation of T_0: A a != R a (exact);
  * the bit sizes of the exact values x_t (numerators and denominators), which the natural derivation of
    H_W^eps from T_N^W writes out: their total over t <= W, and the largest;
  * (floating point, for comparison only) the best tolerance of a REFITTED uniform circular motion
    x_t = r R_phi^t a on the window (minimax over r, phi by a fine grid search plus a local refinement).
"""
import math
import sys
import time
from fractions import Fraction as Fr

SEED = 20261016
OUT = []


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def mat_mul(A, B):
    return [[A[0][0] * B[0][0] + A[0][1] * B[1][0], A[0][0] * B[0][1] + A[0][1] * B[1][1]],
            [A[1][0] * B[0][0] + A[1][1] * B[1][0], A[1][0] * B[0][1] + A[1][1] * B[1][1]]]


def mat_vec(A, v):
    return [A[0][0] * v[0] + A[0][1] * v[1], A[1][0] * v[0] + A[1][1] * v[1]]


def opnorm(M):
    a, b, c, d = (float(M[0][0]), float(M[0][1]), float(M[1][0]), float(M[1][1]))
    # largest singular value of a 2x2 matrix
    s1 = a * a + b * b + c * c + d * d
    s2 = math.sqrt(max((a * a + b * b - c * c - d * d) ** 2 + 4 * (a * c + b * d) ** 2, 0.0))
    return math.sqrt((s1 + s2) / 2)


def bits(q):
    return q.numerator.bit_length() + q.denominator.bit_length()


def refit(xs, W):
    """minimax over (r, phi) of max_{t <= W} |x_t - r R_phi^t a|, a = (1, 0); floating point."""
    pts = [(float(x[0]), float(x[1])) for x in xs[:W + 1]]

    def err(r, phi):
        return max(math.hypot(px - r * math.cos(t * phi), py - r * math.sin(t * phi)) for t, (px, py) in enumerate(pts))
    best = (math.inf, 1.0, math.atan2(4, 3))
    phi0 = math.atan2(4, 3)
    for i in range(-200, 201):
        phi = phi0 + i * 5e-5
        for j in range(-40, 41):
            r = 1 + j * 2.5e-4
            e = err(r, phi)
            if e < best[0]:
                best = (e, r, phi)
    e, r, phi = best
    step_r, step_p = 2.5e-4, 5e-5
    for _ in range(60):
        improved = False
        for dr, dp in ((step_r, 0), (-step_r, 0), (0, step_p), (0, -step_p)):
            e2 = err(r + dr, phi + dp)
            if e2 < e:
                e, r, phi, improved = e2, r + dr, phi + dp, True
        if not improved:
            step_r /= 2
            step_p /= 2
    return e, r, phi


def main():
    t0 = time.time()
    out("# l9_correction.py seed=%d python %s (exact rational arithmetic)" % (SEED, sys.version.split()[0]))
    c, s = Fr(3, 5), Fr(4, 5)
    R = [[c, -s], [s, c]]
    J = [[Fr(0), Fr(-1)], [Fr(1), Fr(0)]]
    S = [[Fr(1), Fr(0)], [Fr(0), Fr(-1)]]
    I = [[Fr(1), Fr(0)], [Fr(0), Fr(1)]]
    eta = Fr(1, 100)
    a = [Fr(1), Fr(0)]
    perts = {"(i) P = J R (spiral + precession)": mat_mul(J, R),
             "(ii) P = S R (distortion)": mat_mul(S, R),
             "(iii) P = I": I}
    Wmax = 200
    for name, P in perts.items():
        A = [[R[i][j] + eta * P[i][j] for j in range(2)] for i in range(2)]
        nP = opnorm(P)
        out("\n== %s: A = R + (1/100) P = [[%s, %s], [%s, %s]], ||P||_2 = %.6f" % (
            name, A[0][0], A[0][1], A[1][0], A[1][1], nP))
        xs, rs = [a], [a]
        for t in range(Wmax):
            xs.append(mat_vec(A, xs[-1]))
            rs.append(mat_vec(R, rs[-1]))
        refuted = xs[1] != rs[1]
        out("   T_N refutes T_0 at t = 1: A a = (%s, %s) != R a = (%s, %s): %s" % (
            xs[1][0], xs[1][1], rs[1][0], rs[1][1], refuted))
        out("   %5s | %14s | %12s | %8s | %12s %12s | %12s" % (
            "W", "eps_min(W)", "bound eps(W)", "ratio", "sum bits x_t", "max bits x_t", "refit circle"))
        d2max = Fr(0)
        tot_bits = 0
        max_bits = 0
        for t in range(Wmax + 1):
            d = [xs[t][0] - rs[t][0], xs[t][1] - rs[t][1]]
            d2 = d[0] * d[0] + d[1] * d[1]
            d2max = max(d2max, d2)
            b = bits(xs[t][0]) + bits(xs[t][1])
            tot_bits += b
            max_bits = max(max_bits, b)
            if t in (1, 2, 5, 10, 20, 50, 100, 200):
                emin = math.sqrt(float(d2max))
                bound = (1 + float(eta) * nP) ** t - 1
                ok = emin <= bound + 1e-12
                rf = refit(xs, t)[0] if t <= 100 else float("nan")
                out("   %5d | %14.8f | %12.8f | %8.4f | %12d %12d | %12.3e%s" % (
                    t, emin, bound, emin / bound if bound else float("nan"), tot_bits, max_bits, rf,
                    "" if ok else "   BOUND VIOLATED"))
        e10 = max(((xs[t][0] - rs[t][0]) ** 2 + (xs[t][1] - rs[t][1]) ** 2 for t in range(11)))
        out("   exact value: eps_min(10)^2 = p/q with p of %d digits and q of %d digits; p/q = %.15g" % (
            len(str(e10.numerator)), len(str(e10.denominator)), float(e10)))

    out("\n# runtime %.0f s" % (time.time() - t0))
    out("# done")
    with open(__file__.replace(".py", ".out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
