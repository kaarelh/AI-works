#!/usr/bin/env python3
"""Two numerical checks for rehearsal-core.md.

(1) Proposition 5.5 (the 'ladder'): re-drawing the round at every CALL (the averaged
    kernel Mbar) is not covered by Theorem R1/R2; re-drawing it per RUN is.
    Monte Carlo over the rehearsal (fixed seed); given the rehearsal the two
    probabilities are computed exactly.
(2) Theorem 9.2 with K = 1, L = 1: the rate sqrt(K/n) per call for a stochastic human
    (two-point Bernoulli class), against the upper bound from R1 + Pinsker (Proposition 9.1).
"""
import math, random

def ladder(Lc, p, n, trials, rng):
    """Inputs x_1..x_L on the path of f = 0; prior: values independent, 0 with prob p.
    A wrong answer ends the run (STOP); in the file a junk input on which all agree
    would do the same."""
    s_run = s_call = 0.0
    for _ in range(trials):
        learned = [False] * Lc
        tau = [n] * Lc                  # tau[j] = min(round in which x_j is learned, n)
        unl = Lc
        sum_u = 0.0                     # sum over rounds of Pr[M^(t)-run unfaithful]
        t = 0
        while t < n and unl > 0:
            t += 1
            sum_u += 1 - p ** unl
            J = rng.randrange(Lc)
            ok = True
            for j in range(J):          # the run must be faithful on calls 1..J-1
                if not learned[j] and rng.random() >= p:
                    ok = False
                    break
            if ok and not learned[J]:
                learned[J] = True; tau[J] = t; unl -= 1
        s_run += sum_u / n              # deploy M^(t*) with t* drawn once per run
        prod = 1.0
        for j in range(Lc):
            prod *= 1 - (1 - p) * tau[j] / n
        s_call += 1 - prod              # deploy Mbar (round re-drawn at every call)
    return s_run / trials, s_call / trials

def two_point(n):
    """Class {Bern(1/2+eps), Bern(1/2-eps)}, uniform prior, one input.  Returns
    eps, E TV of the Bayes mixture after n answers, the Cesaro average over t < n."""
    eps = 1 / (4 * math.sqrt(2 * n))
    lp, lm = math.log(0.5 + eps), math.log(0.5 - eps)
    def etv(t):                         # E_+ TV(M_t, P_+) = 2 eps E_+[posterior of P_-]
        s = 0.0
        for k in range(t + 1):
            lb = math.lgamma(t + 1) - math.lgamma(k + 1) - math.lgamma(t - k + 1) + k * lp + (t - k) * lm
            d = (2 * k - t) * (lp - lm)               # log-likelihood ratio +/-
            s += math.exp(lb) * 2 * eps / (1 + math.exp(d))
        return s
    last = etv(n)
    ces = sum(etv(t) for t in range(n)) / n
    return eps, last, ces

if __name__ == "__main__":
    rng = random.Random(12345)
    print("== (1) ladder: per-run random round versus per-call averaged kernel ==")
    p = 0.5
    for Lc in (10, 20, 40):
        n = 20 * Lc ** 3
        r, c = ladder(Lc, p, n, 300, rng)
        bound = Lc * Lc * math.log(1 / p) / n
        lower = (1 - p) ** 2 * (Lc ** 3 / (2 * n) - Lc ** 6 / n ** 2)
        print(f"L={Lc} n={n}: Pr[unfaithful run], one round per run: {r:.5f} <= L K ln2/n = {bound:.5f}; "
              f"averaged kernel Mbar (a round per call): {c:.5f} (proved >= {lower:.5f}); ratio Mbar/bound = {c / bound:.2f}")
    print("== (2) stochastic human, two-point class, K = 1 bit ==")
    for n in (8, 32, 128, 512, 2048):
        eps, last, ces = two_point(n)
        print(f"n={n}: eps={eps:.4f}; minimax lower bound eps/2 = {eps / 2:.4f} = {eps / 2 * math.sqrt(n):.4f}/sqrt(n); "
              f"Bayes mixture: E TV after n answers = {last:.4f}, average over rounds = {ces:.4f} "
              f"<= sqrt(ln2/(2n)) = {math.sqrt(math.log(2) / (2 * n)):.4f}")
