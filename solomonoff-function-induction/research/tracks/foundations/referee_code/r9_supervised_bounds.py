"""r9 (referee): exact finite checks of Thm 6.7(a), Prop 6.8 and one inequality in Prop 4.5.

(a) Thm 6.7(a) (online-to-batch, deterministic labels).  Finite stand-in for M_F: the Bayes mixture
    of all 32 Boolean functions on X = {0..4} with prior w_f proportional to 2^-(1 + #ones(f)) * 3^0
    (normalised to 1), non-uniform input law pi.  For three targets phi and n = 1..6, exact
    enumeration of all 5^n input sequences:
       E L_n,  E R(Qbar_n),  E pi{argmax Qbar_n != phi},  bound -log2 w_phi / n.
(b) Prop 6.8: exact probability that the labels at x0 agree after n i.i.d. draws, versus the bound
    (1-a)^n + pmax^-1 (1-a+a pmax)^n, for 500 seeded random (a, label law with 2..4 labels), n <= 15.
(c) Prop 4.5, step "Count": sum over non-constant b in {0,1}^k of prod_j s_j(b_j) <= prod_j(1+delta 2^-j) - 1
    when s_j(y) <= 1 and s_j(1-y) <= delta 2^-j; 2000 seeded random instances, k <= 10.

Seed 20261011.  Output: r9_supervised_bounds_output.txt
"""
import itertools
import math
import random
from fractions import Fraction as Fr

X = range(5)
FUNCS = list(itertools.product((0, 1), repeat=5))
RAW = {f: Fr(1, 2 ** (1 + sum(f))) for f in FUNCS}
Z = sum(RAW.values())
W = {f: v / Z for f, v in RAW.items()}
PI = [Fr(4, 10), Fr(3, 10), Fr(15, 100), Fr(1, 10), Fr(5, 100)]


def mix(D):
    return sum(w for f, w in W.items() if all(f[x] == y for x, y in D))


def part_a():
    rows = []
    for phi in [(0, 0, 0, 0, 0), (1, 0, 1, 0, 1), (1, 1, 1, 1, 1)]:
        bound_bits = -math.log2(W[phi])
        for n in range(1, 7):
            EL = ER = E01 = 0.0
            for xs in itertools.product(X, repeat=n):
                p = 1.0
                for x in xs:
                    p *= float(PI[x])
                D = []
                L = 0.0
                Qs = []
                for x in xs:
                    # predictive at all inputs given D (before adding x)
                    mD = mix(D)
                    Q = {}
                    for z in X:
                        Q[z] = [float(mix(D + [(z, y)]) / mD) if z not in dict(D) else
                                (1.0 if dict(D)[z] == y else 0.0) for y in (0, 1)]
                    Qs.append(Q)
                    L -= math.log2(Q[x][phi[x]])
                    if x not in dict(D):
                        D.append((x, phi[x]))
                Qbar = {z: [sum(Q[z][y] for Q in Qs) / n for y in (0, 1)] for z in X}
                R = sum(float(PI[z]) * -math.log2(Qbar[z][phi[z]]) for z in X)
                err = sum(float(PI[z]) for z in X if (0 if Qbar[z][0] >= Qbar[z][1] else 1) != phi[z]
                          or Qbar[z][0] == Qbar[z][1])
                EL += p * L
                ER += p * R
                E01 += p * err
            rows.append((phi, n, EL, ER, E01, bound_bits))
    return rows


def part_b(rng, trials=500):
    worst = None
    viol = 0
    for _ in range(trials):
        a = rng.uniform(0.01, 0.9)
        k = rng.randrange(2, 5)
        ps = [rng.random() + 0.01 for _ in range(k)]
        s = sum(ps)
        ps = [p / s for p in ps]
        pmax = max(ps)
        for n in range(1, 16):
            exact = (1 - a) ** n + sum(math.comb(n, j) * a ** j * (1 - a) ** (n - j) * sum(p ** j for p in ps)
                                        for j in range(1, n + 1))
            bound = (1 - a) ** n + (1 - a + a * pmax) ** n / pmax
            if exact > bound + 1e-12:
                viol += 1
            gap = bound - exact
            worst = gap if worst is None else min(worst, gap)
    return viol, worst


def part_c(rng, trials=2000):
    viol = 0
    for _ in range(trials):
        k = rng.randrange(2, 11)
        delta = rng.uniform(0.001, 0.5)
        y0 = rng.randrange(2)
        s = []
        for j in range(1, k + 1):
            sj = {y0: rng.random(), 1 - y0: rng.random() * delta * 2 ** -j}
            s.append(sj)
        tot = 0.0
        for b in itertools.product((0, 1), repeat=k):
            if len(set(b)) == 1:
                continue
            tot += math.prod(s[j][b[j]] for j in range(k))
        rhs = math.prod(1 + delta * 2 ** -j for j in range(1, k + 1)) - 1
        viol += tot > rhs + 1e-15
    return viol


def main():
    rng = random.Random(20261011)
    lines = ["(a) phi, n, E L_n, E R(Qbar_n), E 0-1 risk(argmax Qbar_n), bound -log2 w_phi, bound/n ; checks"]
    for phi, n, EL, ER, E01, bb in part_a():
        lines.append(f"    {phi} n={n}: EL={EL:.4f} ER={ER:.4f} E01={E01:.4f} K={bb:.4f} K/n={bb / n:.4f} ; "
                     f"EL<=K {EL <= bb + 1e-9}, ER<=K/n {ER <= bb / n + 1e-9}, E01<=K/n {E01 <= bb / n + 1e-9}")
    viol, worst = part_b(rng)
    lines.append(f"(b) Prop 6.8 bound: violations = {viol} over 500 x 15 cases; smallest slack = {worst:.3e}")
    lines.append(f"(c) Prop 4.5 counting inequality: violations = {part_c(rng)} over 2000 instances")
    out = "\n".join(lines)
    print(out)
    with open(__file__.replace(".py", "_output.txt"), "w") as f:
        f.write(out + "\n")


if __name__ == "__main__":
    main()
