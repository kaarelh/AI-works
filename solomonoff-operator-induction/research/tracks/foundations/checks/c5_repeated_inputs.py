"""c5: i.i.d. supervised data with noisy labels is eventually inconsistent (notes.md Prop 6.8).

Model: x_t i.i.d. from pi (uniform on m inputs), y_t ~ Bern(p) drawn freshly for every draw.
Plain SFI assigns probability 0 to any data set in which one input carries two labels, so its
cumulative log loss is infinite on that event.  We compute, exactly, the probability P_cons(n)
that the first n pairs are consistent, using the per-input factorisation of the exponential
generating function below, and confirm it by a seeded Monte Carlo estimate.

Exact formula used: P_cons(n) = n!/m^n * [z^n] ( 1 + sum_{j>=1} (p^j + q^j) z^j / j! )^m ,
q = 1-p (each input either unused or all its j labels equal).

Seed 20261011.  Output: c5_repeated_inputs.out.txt
"""
import math
import random
from fractions import Fraction as Fr


def p_consistent(n, m, p):
    q = 1 - p
    # per-input EGF coefficients a_j = (p^j+q^j)/j! for j>=1, a_0 = 1
    a = [Fr(1)] + [(p ** j + q ** j) / math.factorial(j) for j in range(1, n + 1)]
    poly = [Fr(1)] + [Fr(0)] * n
    for _ in range(m):
        new = [Fr(0)] * (n + 1)
        for i, ci in enumerate(poly):
            if ci == 0:
                continue
            for j in range(0, n + 1 - i):
                new[i + j] += ci * a[j]
        poly = new
    return poly[n] * math.factorial(n) / Fr(m) ** n


def mc(n, m, p, trials, rng):
    ok = 0
    for _ in range(trials):
        lab = {}
        good = True
        for _ in range(n):
            x = rng.randrange(m)
            y = 1 if rng.random() < p else 0
            if lab.setdefault(x, y) != y:
                good = False
                break
        ok += good
    return ok / trials


def main():
    rng = random.Random(20261011)
    lines = []
    for m, p in [(10, Fr(1, 2)), (10, Fr(1, 10)), (100, Fr(1, 2))]:
        for n in [2, 5, 10, 20, 50, 100]:
            ex = float(p_consistent(n, m, p))
            est = mc(n, m, float(p), 20000, rng)
            lines.append(f"m={m} p={p} n={n}: P(consistent) exact={ex:.6f}  MC(20000)={est:.4f}")
    lines.append("Under P(inconsistent)>0 the expected SFI log loss is +infinity (M_F(D)=0 there).")
    out = "\n".join(lines)
    print(out)
    with open(__file__.replace(".py", ".out.txt"), "w") as f:
        f.write(out + "\n")


if __name__ == "__main__":
    main()
