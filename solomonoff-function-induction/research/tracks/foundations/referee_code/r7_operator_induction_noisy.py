"""r7 (referee): noisy i.i.d. supervised data.  Per-query product mixture (Solomonoff's operator
induction as described in secondary sources: sum_j w_j prod_i O_j(a_i | q_i) over ALL pairs, repeated
questions allowed) versus the per-input (random-function) mixture used by the foundations notes
(M_prod / M_F on data sets), and the time-stamped version of Thm 6.7(b).

Setting: X = {0,1,2}, pi uniform, true P(1|x) = (0.2, 0.5, 0.9), fresh label at every draw.
Class: the 27 product laws theta in {0.2,0.5,0.9}^3 (true law included), uniform weights, so
-log2 w = log2 27 = 4.755 bits.
Exact computations (sufficient statistics: counts n_{x,y}):
  (a) per-query mixture S: expected regret E[-log2 S(z_{1:n})] - E[-log2 P(z_{1:n})] for n = 1..20,
      and max over all count vectors of the pathwise regret; both must be <= log2 27;
  (b) per-input mixture R(D) = sum_theta w prod_{(x,y) in D} theta(y|x) on the SET D: probability
      that the n pairs are consistent (otherwise R = 0, loss = +infinity);
  (c) stamped inputs <x,t>: the random-function mixture over stamp-ignoring product laws equals S
      on every sequence (checked on 2000 seeded random sequences of length 12, exact rationals).
  (d) Cesaro form: (1/n) sum_t E E_pi KL(P || q_t) = (expected regret)/n <= log2(27)/n.

Seed 20261011.  Output: r7_operator_induction_noisy_output.txt
"""
import itertools
import math
import random
from fractions import Fraction as Fr

PX = [Fr(1, 3)] * 3
P1 = [Fr(1, 5), Fr(1, 2), Fr(9, 10)]
GRID = [Fr(1, 5), Fr(1, 2), Fr(9, 10)]
CLASS = list(itertools.product(GRID, repeat=3))
WT = Fr(1, len(CLASS))
CELLS = [(x, y) for x in range(3) for y in (0, 1)]


def theta_p(theta, x, y):
    return theta[x] if y == 1 else 1 - theta[x]


def compositions(n, k):
    if k == 1:
        yield (n,)
        return
    for i in range(n + 1):
        for rest in compositions(n - i, k - 1):
            yield (i,) + rest


def multinom(n, cs):
    r = math.factorial(n)
    for c in cs:
        r //= math.factorial(c)
    return r


def per_query_logs(counts):
    """log2 S and log2 P for a sequence with these cell counts (order-free for products)."""
    s = 0.0
    for th in CLASS:
        lp = sum(c * math.log2(float(theta_p(th, x, y))) for (x, y), c in zip(CELLS, counts) if c)
        s += float(WT) * 2.0 ** lp
    lP = sum(c * math.log2(float(theta_p(P1, x, y))) for (x, y), c in zip(CELLS, counts) if c)
    return math.log2(s), lP


def part_a_b(nmax=20):
    rows = []
    for n in range(1, nmax + 1):
        exp_regret = 0.0
        max_regret = -1e9
        p_cons = 0.0
        for counts in compositions(n, 6):
            # probability of one particular sequence with these counts
            lp_seq = sum(c * math.log2(float(PX[x] * theta_p(P1, x, y))) for (x, y), c in zip(CELLS, counts) if c)
            prob = multinom(n, counts) * 2.0 ** lp_seq
            lS, lP = per_query_logs(counts)
            reg = lP - lS
            exp_regret += prob * reg
            max_regret = max(max_regret, reg)
            consistent = all(not (counts[2 * x] > 0 and counts[2 * x + 1] > 0) for x in range(3))
            p_cons += prob * consistent
        rows.append((n, exp_regret, max_regret, p_cons))
    return rows


def part_c(rng, trials=2000, n=12):
    ok = True
    for _ in range(trials):
        seq = [(rng.randrange(3), rng.randrange(2)) for _ in range(n)]
        S = sum(WT * math.prod(theta_p(th, x, y) for x, y in seq) for th in CLASS)
        # stamped data set {(<x,t>, y)}: all stamped inputs distinct, product law ignores the stamp
        stamped = {((x, t), y) for t, (x, y) in enumerate(seq)}
        R = sum(WT * math.prod(theta_p(th, xt[0], y) for xt, y in stamped) for th in CLASS)
        ok &= (S == R)
    return ok


def main():
    rng = random.Random(20261011)
    bound = math.log2(len(CLASS))
    lines = [f"class size {len(CLASS)}, bound -log2 w = {bound:.4f} bits"]
    lines.append(" n   E regret(per-query)  max pathwise regret  (E regret)/n   P(per-input data consistent)")
    for n, er, mr, pc in part_a_b():
        lines.append(f"{n:2d}   {er:10.4f}          {mr:10.4f}          {er / n:8.4f}        {pc:.6f}")
    lines.append(f"(c) stamped random-function mixture == per-query mixture on 2000 random sequences (exact): {part_c(rng)}")
    lines.append("per-query regret stays <= log2 27 on every sequence; the per-input mixture has infinite loss "
                 "with the probability 1 - P(consistent) shown.")
    out = "\n".join(lines)
    print(out)
    with open(__file__.replace(".py", "_output.txt"), "w") as f:
        f.write(out + "\n")


if __name__ == "__main__":
    main()
