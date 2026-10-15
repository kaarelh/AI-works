"""r6 (referee): the hypothesis "the input rule sees only the past" in Theorem 6.5 of the foundations
notes is necessary for the expected-KL bound, while the pathwise bound survives (the notes' remark).

Finite stand-in for M_F: M = w * U + (1-w) * Z on X = {0..N-1}, Y = {0,1}, where U is the uniform
random total function (fair coin per input) and Z is the all-zeros function; w = 1/2, so the
"complexity" of U is -log2 w = 1 bit.  True law: U.
  Rule A (past-only): query inputs 0,1,2,... in order.
  Rule B (sees F): query an unqueried input whose label is 0 if one exists, else any unqueried input.
For each rule, exactly over all 2^N functions:
  S = sum_t E d_t,  d_t = KL( U(.|D_{t-1},x_t) || M(.|D_{t-1},x_t) ) in bits,
  E log2 U(D_N)/M(D_N), and max over paths of log2 U(D_t)/M(D_t).
Theorem 6.5 says S = E log2 U/M <= 1 bit under rule A.  Under rule B the identity breaks and S grows.

Deterministic.  Output: r6_merging_rule_sees_F_output.txt
"""
import itertools
import math
from fractions import Fraction as Fr

W = Fr(1, 2)


def M_of(D):
    """mixture probability of data set D (list of (x,y))."""
    u = Fr(1, 2 ** len(D))
    z = Fr(1) if all(y == 0 for _, y in D) else Fr(0)
    return W * u + (1 - W) * z


def kl_bits(p, q):
    return sum(float(pi) * math.log2(float(pi) / float(qi)) for pi, qi in zip(p, q) if pi > 0)


def run(N, rule):
    S = 0.0
    E_ratio = 0.0
    max_path = -1e9
    for F in itertools.product((0, 1), repeat=N):
        D = []
        queried = set()
        tot = 0.0
        for t in range(N):
            if rule == "A":
                x = t
            else:
                zeros = [x for x in range(N) if x not in queried and F[x] == 0]
                x = zeros[0] if zeros else min(set(range(N)) - queried)
            p = [Fr(1, 2), Fr(1, 2)]
            mD = M_of(D)
            q = [M_of(D + [(x, 0)]) / mD, M_of(D + [(x, 1)]) / mD]
            tot += kl_bits(p, q)
            D.append((x, F[x]))
            queried.add(x)
            max_path = max(max_path, math.log2(float(Fr(1, 2 ** len(D)) / M_of(D))))
        S += tot / 2 ** N
        E_ratio += math.log2(float(Fr(1, 2 ** N) / M_of(D))) / 2 ** N
    return S, E_ratio, max_path


def main():
    lines = [f"bound -log2 w = {-math.log2(W):.4f} bits"]
    for N in (2, 4, 6, 8, 10, 12, 14):
        for rule in ("A", "B"):
            S, Er, mp = run(N, rule)
            lines.append(f"N={N:2d} rule {rule}: sum_t E d_t = {S:8.4f}   E log2 U/M = {Er:.4f}   "
                         f"max_path log2 U/M = {mp:.4f}   sumKL<=1: {S <= 1 + 1e-12}")
    out = "\n".join(lines)
    print(out)
    with open(__file__.replace(".py", "_output.txt"), "w") as f:
        f.write(out + "\n")


if __name__ == "__main__":
    main()
