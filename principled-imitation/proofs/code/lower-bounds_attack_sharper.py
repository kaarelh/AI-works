#!/usr/bin/env python3
"""Attack on the verdict "R3 'sharper form', first half: PROVED / correct"
(research/prove/lower-bounds.md, Section 0 row of Proposition 5.2 and Section 10,
item 5).

The candidate theory's sentence is stated for samplers: the robustness curve is
defined with  E sum_j TV(C, P)(x_j) <= beta, and the claim is
    failure <= (concave majorant of delta_Pi)(L K ln2 / n).
Proposition 5.2 proves it for a DETERMINISTIC human.  For a human who is not
deterministic the sentence is false as stated.  Exact counterexample:

  one input x0, answers {0, 1}; the class has two members, P+ and P-, with
  P+-(1|x0) = 1/2 +- theta, weights 1/2 each, so K = 1 bit; the human is P-;
  the scaffold makes one call at x0 (L = 1); a run is good iff the answer is 0.
  Then delta_Pi(beta) = min(1, 1/2 - theta + beta) (already concave), and the
  sentence claims   Pr[deployed answer = 1] <= 1/2 - theta + ln2/n.
  Protocol R asks x0 in every round; the mixture of round t answers 1 with
  probability 1/2 - theta + 2 theta w_t, where w_t is the posterior weight of P+
  after t-1 answers; the deployed failure is 1/2 - theta + 2 theta mean_t E[w_t].

The script computes mean_t E[w_t] exactly (binomial sums in rational arithmetic
for the small cases, floating point for the larger ones) and compares the
excess failure  2 theta mean_t E[w_t]  with  ln2/n  (the sentence as stated)
and with  sqrt(ln2/(2n))  (what Pinsker's inequality gives: the correct form of
the first half for a stochastic human, beta <= L sqrt(K ln2/(2n))).
"""
import math
from fractions import Fraction as F


def mean_wrong_weight(theta, n, exact=False):
    """(1/n) sum_{t=1}^n E[w_t], w_t = posterior weight of P+ after t-1 draws from P- ."""
    if exact:
        th = F(theta)
        p1 = F(1, 2) - th                       # human: Pr[answer 1]
        rho = (F(1, 2) + th) / (F(1, 2) - th)
        tot = F(0)
        for k in range(n):                      # k = t-1 answers seen
            e = F(0)
            for j in range(k + 1):              # j ones
                pr = math.comb(k, j) * p1 ** j * (1 - p1) ** (k - j)
                lr = rho ** (2 * j - k)         # likelihood ratio P+ / P-
                e += pr * lr / (1 + lr)
            tot += e
        return tot / n
    p1 = 0.5 - theta
    lrho = math.log((0.5 + theta) / (0.5 - theta))
    tot = 0.0
    for k in range(n):
        e = 0.0
        for j in range(k + 1):
            logpr = (math.lgamma(k + 1) - math.lgamma(j + 1) - math.lgamma(k - j + 1)
                     + j * math.log(p1) + (k - j) * math.log(1 - p1))
            x = (2 * j - k) * lrho
            wplus = 1.0 / (1.0 + math.exp(-x)) if x > -700 else 0.0
            e += math.exp(logpr) * wplus
        tot += e
    return tot / n


def main():
    print("Excess failure of the deployed mixture M^(T) over the human system (exact), two-member class, K = 1, L = 1")
    print("  theta      n    2 theta mean E[w_t]    ln2/n (sentence as stated)   ratio    sqrt(ln2/(2n)) (Pinsker form)")
    viol = 0
    for theta, n, exact in [(F(1, 20), 8, True), (F(1, 20), 20, True), (F(1, 20), 60, True),
                            (F(1, 10), 20, True), (F(1, 10), 60, True),
                            (0.05, 200, False), (0.05, 1000, False), (0.02, 1000, False),
                            (0.02, 5000, False), (0.01, 5000, False), (0.25, 20, False), (0.25, 200, False)]:
        mw = mean_wrong_weight(theta, n, exact)
        excess = 2 * float(theta) * float(mw)
        claim = math.log(2) / n
        pinsk = math.sqrt(math.log(2) / (2 * n))
        flag = "VIOLATED" if excess > claim else "holds"
        if excess > claim:
            viol += 1
        print("  %-7s %5d    %.6f               %.6f                    %6.2f   %.6f    %s%s"
              % (theta, n, excess, claim, excess / claim, pinsk, flag, "  (exact rational)" if exact else ""))
        assert excess <= pinsk + 1e-12, "even the Pinsker form fails?"
    print("the sentence as stated (argument L K ln2/n) is violated in %d of the cases; the Pinsker form holds in all" % viol)
    assert viol > 0
    print("all checks passed")


if __name__ == "__main__":
    main()
