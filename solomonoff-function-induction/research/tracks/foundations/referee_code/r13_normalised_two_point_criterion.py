"""r13 (referee, second pass): when is the normalised loss order-independent on two-point data?

Referee Proposition B (referee.md, question Q1).  Let P be the law of a random partial function on
two inputs a, b.  Write A = {F(a) defined}, B = {F(b) defined}, and consider the condition
    P(B | F(a)=alpha) = P(B | A)  for every alpha,   and   P(A | F(b)=beta) = P(A | B)  for every beta,
i.e. definedness at one input carries no information about the label at the other input.
(i) If it holds, the normalised probability of {(a,alpha),(b,beta)} is the same in both reveal
orders for every pair of labels.  (ii) If every two-point probability P(F(a)=alpha, F(b)=beta) is
positive and the two orders agree for every pair of labels, the condition holds.  (Without that
positivity (ii) can fail.)  The random laws in (1) below have full support, so both directions apply.

Checks with exact rationals, labels Y = {0,1,2}:
 (1) 300 seeded random laws on (Y+bot)^2: criterion and order-independence agree in every case;
 (2) 300 seeded laws built to satisfy the criterion (definedness pattern drawn first; label of a
     drawn from one law r whenever a is defined, label of b from one law s whenever b is defined,
     with an arbitrary coupling when both are defined): all are order-independent;
 (3) the notes' rho_1 (c3): criterion fails and the two orders give 2/3 and 1/2;
 (4) random *total* laws: criterion holds trivially and the orders agree.

Seed 20261012.  Output: r13_normalised_two_point_criterion_output.txt
"""
import itertools
import random
from fractions import Fraction as Fr

BOT = None
Y = (0, 1, 2)
VALS = (BOT,) + Y


def p_of(law, pred):
    return sum(p for pt, p in law.items() if pred(pt))


def normalised(law, first, labels):
    """first = 0 (a first) or 1 (b first); labels = (alpha, beta)."""
    order = (0, 1) if first == 0 else (1, 0)
    prob = Fr(1)
    fixed = {}
    for i in order:
        num = p_of(law, lambda pt: all(pt[j] == v for j, v in fixed.items()) and pt[i] == labels[i])
        den = p_of(law, lambda pt: all(pt[j] == v for j, v in fixed.items()) and pt[i] is not BOT)
        if den == 0:
            return Fr(0)
        prob *= num / den
        fixed[i] = labels[i]
    return prob


def criterion(law):
    PA = p_of(law, lambda pt: pt[0] is not BOT)
    PB = p_of(law, lambda pt: pt[1] is not BOT)
    PAB = p_of(law, lambda pt: pt[0] is not BOT and pt[1] is not BOT)
    for al in Y:
        pa = p_of(law, lambda pt: pt[0] == al)
        paB = p_of(law, lambda pt: pt[0] == al and pt[1] is not BOT)
        if paB * PA != PAB * pa:
            return False
    for be in Y:
        pb = p_of(law, lambda pt: pt[1] == be)
        pbA = p_of(law, lambda pt: pt[1] == be and pt[0] is not BOT)
        if pbA * PB != PAB * pb:
            return False
    return True


def order_free(law):
    return all(normalised(law, 0, lab) == normalised(law, 1, lab)
               for lab in itertools.product(Y, Y))


def positive_marginals(law):
    return all(p_of(law, lambda pt: pt[0] == y) > 0 and p_of(law, lambda pt: pt[1] == y) > 0 for y in Y)


def random_law(rng, total=False):
    pts = [pt for pt in itertools.product(VALS, VALS) if not total or (BOT not in pt)]
    w = [Fr(rng.randrange(1, 12)) for _ in pts]
    Z = sum(w)
    return {pt: x / Z for pt, x in zip(pts, w)}


def criterion_law(rng):
    pat = [Fr(rng.randrange(1, 9)) for _ in range(4)]  # both, only a, only b, neither
    Zp = sum(pat)
    pat = [x / Zp for x in pat]
    r = [Fr(rng.randrange(1, 9)) for _ in Y]
    s = [Fr(rng.randrange(1, 9)) for _ in Y]
    r = [x / sum(r) for x in r]
    s = [x / sum(s) for x in s]
    # random coupling with marginals r, s on the 'both' event: mix product with a shifted coupling
    t = Fr(rng.randrange(0, 5), 4)
    law = {}
    for i, al in enumerate(Y):
        for j, be in enumerate(Y):
            prod = r[i] * s[j]
            law[(al, be)] = pat[0] * prod
    # perturb within the 'both' block keeping marginals: add t*eps*(+1,-1;-1,+1) on a 2x2 minor
    eps = min(law[(0, 0)], law[(1, 1)], law[(0, 1)], law[(1, 0)]) * t
    law[(0, 0)] += eps
    law[(1, 1)] += eps
    law[(0, 1)] -= eps
    law[(1, 0)] -= eps
    for i, al in enumerate(Y):
        law[(al, BOT)] = pat[1] * r[i]
    for j, be in enumerate(Y):
        law[(BOT, be)] = pat[2] * s[j]
    law[(BOT, BOT)] = pat[3]
    assert sum(law.values()) == 1
    return law


def main():
    rng = random.Random(20261012)
    out = []
    agree = 0
    n_crit = 0
    n_free = 0
    for _ in range(300):
        law = random_law(rng)
        c, f = criterion(law), order_free(law)
        agree += (c == f)
        n_crit += c
        n_free += f
    out.append(f"(1) random laws: 300; criterion==order-independence in {agree}; criterion true in {n_crit}; order-free in {n_free}")
    ok = 0
    for _ in range(300):
        law = criterion_law(rng)
        if criterion(law) and order_free(law) and positive_marginals(law):
            ok += 1
    out.append(f"(2) laws built to satisfy the criterion: 300; criterion and order-independence both hold in {ok}")
    rho1 = {(0, 0): Fr(1, 4), (0, BOT): Fr(1, 4), (1, 1): Fr(1, 4), (BOT, BOT): Fr(1, 4)}
    PA = Fr(3, 4)
    PAB = Fr(1, 2)
    pa0 = Fr(1, 2)
    pa0B = Fr(1, 4)
    out.append(f"(3) rho_1: P(B|F(a)=0)={pa0B / pa0}, P(B|A)={PAB / PA}; normalised prob of {{(a,0),(b,0)}}: "
               f"a first {normalised(rho1, 0, (0, 0))}, b first {normalised(rho1, 1, (0, 0))}")
    tot_ok = 0
    for _ in range(100):
        law = random_law(rng, total=True)
        tot_ok += criterion(law) and order_free(law)
    out.append(f"(4) random total laws: 100; criterion and order-independence both hold in {tot_ok}")
    text = "\n".join(out) + "\n"
    print(text, end="")
    with open(__file__.replace(".py", "_output.txt"), "w") as f:
        f.write(text)


if __name__ == "__main__":
    main()
