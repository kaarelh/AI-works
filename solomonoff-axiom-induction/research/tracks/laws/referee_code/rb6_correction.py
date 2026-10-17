"""rb6_correction.py -- Referee B, thread `laws`: notes section 7 (Prop 7.1, the correction toy), exact rational
arithmetic, independently of l9.

Toy: R = rotation with cos 3/5, sin 4/5; eta = 1/100; A = R + eta P; a = (1, 0); P in {JR, SR, I} with
J = rotation by 90 degrees, S = diag(1, -1) (operator norm 1 each).
A. eps_min(W)^2 = max_{t <= W} |A^t a - R^t a|^2 (exact) and the bound eps(W) = (1.01^W - 1)|a| (exact), at
   W = 1, 10, 100, 200 (record: JR 0.0100, 0.0999, 0.961, 1.69; SR 0.0100, 0.0127, 0.0186, 0.0243;
   I 0.0100, 0.103, 1.33, 3.49; bound 0.0100, 0.105, 1.70, 6.32); the bound checked at EVERY W <= 200.
B. (c): A a != R a (the successor refutes the old exact law at t = 1).
C. Is the uniform honest form H^{eps_min(W)} "exactly what the two theories have in common" (notes §0, §7
   Reading, §9.1)?  (i) The time-dependent tolerance law {|x_t - R^t a| <= eps_t : t <= W},
   eps_t := |A^t a - R^t a|, is also a common consequence (T_0 proves it with all eps_t >= 0, T_N proves it
   exactly), and it is strictly stronger: exhibit a rational point satisfying H^{eps_min(W)} that violates it.
   (ii) The strongest common consequence of the finite theories T_0^W and T_N^W is the disjunction
   (/\ T_0^W) \/ (/\ T_N^W); exhibit a rational model of H^{eps_min(W)} violating it.
D. (e): total bit size of the numerals of A^t a, t <= W (numerators and denominators), W = 10, 100
   (record 1894 / 1.8e5 for JR; conventions may differ).
Writes rb6_correction.out next to itself (deterministic).
"""
import math
import os
import sys
import time
from fractions import Fraction as Fr

OUT = []
HERE = os.path.dirname(os.path.abspath(__file__))


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def mm(A, B):
    return [[A[0][0] * B[0][0] + A[0][1] * B[1][0], A[0][0] * B[0][1] + A[0][1] * B[1][1]],
            [A[1][0] * B[0][0] + A[1][1] * B[1][0], A[1][0] * B[0][1] + A[1][1] * B[1][1]]]


def mv(A, v):
    return [A[0][0] * v[0] + A[0][1] * v[1], A[1][0] * v[0] + A[1][1] * v[1]]


def n2(v):
    return v[0] * v[0] + v[1] * v[1]


def bits(x):
    return x.numerator.bit_length() + x.denominator.bit_length()


def main():
    t0 = time.time()
    out("# rb6_correction.py (deterministic, exact rationals) python %s" % sys.version.split()[0])
    R = [[Fr(3, 5), Fr(-4, 5)], [Fr(4, 5), Fr(3, 5)]]
    J = [[Fr(0), Fr(-1)], [Fr(1), Fr(0)]]
    S = [[Fr(1), Fr(0)], [Fr(0), Fr(-1)]]
    I = [[Fr(1), Fr(0)], [Fr(0), Fr(1)]]
    eta = Fr(1, 100)
    a = [Fr(1), Fr(0)]
    Ps = {"JR": mm(J, R), "SR": mm(S, R), "I": I}
    Wmax = 200
    for name, P in Ps.items():
        A = [[R[i][j] + eta * P[i][j] for j in range(2)] for i in range(2)]
        xs_N, xs_0 = [a], [a]
        for t in range(Wmax):
            xs_N.append(mv(A, xs_N[-1]))
            xs_0.append(mv(R, xs_0[-1]))
        d2 = [n2([xs_N[t][0] - xs_0[t][0], xs_N[t][1] - xs_0[t][1]]) for t in range(Wmax + 1)]
        run_max = []
        m = Fr(0)
        for t in range(Wmax + 1):
            m = max(m, d2[t])
            run_max.append(m)
        bound_ok = all(run_max[W] <= ((Fr(101, 100) ** W - 1) ** 2) for W in range(Wmax + 1))
        out("\n== %s: A = R + P/100" % name)
        out("   A. eps_min(W) = %s for W = 1, 10, 100, 200; bound eps(W) = %s; bound holds at every W <= 200: %s" % (
            ", ".join("%.4g" % math.sqrt(run_max[W]) for W in (1, 10, 100, 200)),
            ", ".join("%.4g" % float(Fr(101, 100) ** W - 1) for W in (1, 10, 100, 200)), bound_ok))
        out("   B. A a - R a = (%s, %s) != 0: %s" % (xs_N[1][0] - xs_0[1][0], xs_N[1][1] - xs_0[1][1],
                                                     xs_N[1] != xs_0[1]))
        for W in (10, 100):
            em2 = run_max[W]
            # (i) time-dependent tolerance law: a point within eps_min(W) of R^t a everywhere but outside eps_1 at t=1
            # choose x_1 = R a + delta * (1, 0) with rational delta, eps_1 < delta <= eps_min(W)
            e1 = math.sqrt(d2[1])
            emin = math.sqrt(em2)
            delta = Fr(e1 + emin) / 2
            delta = Fr(delta).limit_denominator(10 ** 6)
            ok_H = delta * delta <= em2
            viol = delta * delta > d2[1]
            # (ii) disjunction: the point x_t = R^t a + (delta', 0) for all t, delta' small rational, is a model
            # of H^{eps_min} and of neither T_0 (x_0 != a) nor T_N (x_0 != a)
            dp = Fr(1, 10 ** 4)
            ok_H2 = dp * dp <= em2
            out("   C. W=%d: eps_1 = %.4g, eps_min(W) = %.4g (ratio %.3g).  (i) x_1 = R a + (%s, 0): satisfies"
                " H^{eps_min} %s, violates the time-dependent common consequence %s.  (ii) x_t = R^t a + (1/10^4, 0)"
                " for all t: model of H^{eps_min} %s, of T_0^W False (x_0 != a), of T_N^W False (x_0 != a)" % (
                    W, e1, emin, e1 / emin, delta, ok_H, viol, ok_H2))
            avg = sum(math.sqrt(d2[t]) for t in range(W + 1)) / (W + 1)
            out("      mean of eps_t over t <= W: %.4g (the uniform tolerance is %.2f times larger on average)" % (
                avg, emin / avg if avg > 0 else float('nan')))
        tb = {W: sum(bits(x) for t in range(W + 1) for x in xs_N[t]) for W in (10, 100)}
        out("   D. numeral bits of A^t a, t <= W (numerators + denominators): W=10: %d, W=100: %d" % (tb[10], tb[100]))
    out("\n# runtime %.0f s" % (time.time() - t0))
    out("# done")
    with open(os.path.join(HERE, "rb6_correction.out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
