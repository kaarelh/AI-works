"""c3: semimeasure loss is order-independent, normalised loss is not (notes.md Prop 5.3).

Random partial function law rho on inputs {a,b}, labels {0,1}:
  (a,b) = (0,0) w.p. 1/4, (0,bot) w.p. 1/4, (1,1) w.p. 1/4, (bot,bot) w.p. 1/4.
Data D = {(a,0),(b,0)}.  Computes, exactly, the probability assigned to D in both reveal
orders, under the semimeasure convention (product of rho(D_t)/rho(D_{t-1})) and under the
normalised convention (each conditional renormalised over labels).

Also checks the same phenomenon on a second law with full support, and checks that the
normalised probability is >= the semimeasure probability in every order.

Deterministic.  Output: c3_normalisation_order.out.txt
"""
import itertools
from fractions import Fraction as Fr

BOT = None


def containment(law, D):
    return sum(p for pt, p in law.items() if all(pt[x] == y for x, y in D))


def seq_prob(law, order, labels, normalised):
    D = []
    prob = Fr(1)
    for x in order:
        y = labels[x]
        num = containment(law, D + [(x, y)])
        den_semi = containment(law, D)
        den = sum(containment(law, D + [(x, yy)]) for yy in (0, 1)) if normalised else den_semi
        prob *= num / den
        D.append((x, y))
    return prob


def report(name, law, labels, lines):
    lines.append(f"law {name}: " + ", ".join(f"{k}:{v}" for k, v in law.items()))
    inputs = list(labels)
    for order in itertools.permutations(inputs):
        s = seq_prob(law, order, labels, False)
        nrm = seq_prob(law, order, labels, True)
        lines.append(f"  order {order}: semimeasure prob = {s}, normalised prob = {nrm}, "
                     f"normalised >= semimeasure: {nrm >= s}")


def main():
    lines = []
    # inputs: 0 = a, 1 = b ; points are tuples (F(a), F(b))
    law1 = {(0, 0): Fr(1, 4), (0, BOT): Fr(1, 4), (1, 1): Fr(1, 4), (BOT, BOT): Fr(1, 4)}
    report("rho1", law1, {0: 0, 1: 0}, lines)
    # a law on total functions over 3 inputs plus some undefinedness, to show the effect persists
    law2 = {(0, 0, 0): Fr(1, 5), (0, 1, BOT): Fr(1, 5), (1, 1, 1): Fr(1, 10),
            (BOT, 0, 1): Fr(1, 5), (1, BOT, 0): Fr(3, 10)}
    report("rho2", law2, {0: 0, 1: 0, 2: 0}, lines)
    out = "\n".join(lines)
    print(out)
    with open(__file__.replace(".py", ".out.txt"), "w") as f:
        f.write(out + "\n")


if __name__ == "__main__":
    main()
