#!/usr/bin/env python3
"""Exact small checks for rehearsal-core.md (no sampling).

(1) Proposition 6.1(a): last round, non-adaptive scaffold, deterministic human:
    E beta(M^(n+1)) <= L (ln(W/w(f)) + 1)/n.
(2) Proposition 12.2 (R3a, bounded damage): the condition k(1+D) + sqrt(2 L ln(1/delta)) <= eta mu L,
    against the rule that replaces the human's good answers.
(3) Theorem 13.1(a) (V1): the upper confidence bound for the rate of disagreement.
(4) Proposition 9.3(i): the tolerance of the majority scaffold.
"""
import math
from math import lgamma, log, exp, sqrt


def binom_pmf(n, k, p):
    if p <= 0:
        return 1.0 if k == 0 else 0.0
    if p >= 1:
        return 1.0 if k == n else 0.0
    return exp(lgamma(n + 1) - lgamma(k + 1) - lgamma(n - k + 1) + k * log(p) + (n - k) * log(1 - p))


def binom_cdf(n, k, p):
    """Pr[Bin(n,p) <= k]."""
    if k < 0:
        return 0.0
    return min(1.0, sum(binom_pmf(n, i, p) for i in range(0, min(k, n) + 1)))


# ---------------------------------------------------------------- (1)
def last_round_disjoint(N, eps, w, n):
    """One call (L = 1); with probability N*eps the input falls in one of N regions (each eps),
    otherwise in a region where all hypotheses agree with f.  Class: f (weight w) and h_1..h_N
    (weight (1-w)/N each), h_i wrong exactly on region i.  Returns E[error of M^(n+1)] exactly,
    by the Markov chain of the number j of regions already asked."""
    dist = [0.0] * (N + 1)
    dist[0] = 1.0
    for _ in range(n):
        new = [0.0] * (N + 1)
        for j, pr in enumerate(dist):
            if pr == 0.0:
                continue
            up = eps * (N - j)
            new[j] += pr * (1 - up)
            if j < N:
                new[j + 1] += pr * up
        dist = new
    err = 0.0
    for j, pr in enumerate(dist):
        surv = (1 - w) * (N - j) / N
        err += pr * eps * (N - j) * ((1 - w) / N) / (w + surv)
    return err


def check_last_round():
    print("== (1) last round, non-adaptive scaffold, deterministic human (L = 1) ==")
    for w in (0.5, 1e-2, 1e-4, 1e-8):
        for N in (10, 100):
            worst = 0.0
            arg = None
            for n in (10, 30, 100, 300, 1000):
                for i in range(1, 60):
                    eps = min(1.0 / N, (i / 8.0) / n)
                    e = last_round_disjoint(N, eps, w, n)
                    if n * e > worst:
                        worst, arg = n * e, (n, eps)
            print(f"w(f)={w:g} N={N}: max over n, eps of n*E[error of M^(n+1)] = {worst:.4f} at n={arg[0]}, eps={arg[1]:.4g};"
                  f"  ln(1/w) = {log(1 / w):.4f};  bound ln(1/w) + 1 = {log(1 / w) + 1:.4f}")


# ---------------------------------------------------------------- (2)
def check_bounded_damage():
    print("== (2) bounded damage: human step +1 w.p. (1+mu)/2, -1 otherwise; the rule replaces the first k answers +1 by a step -D ==")
    mu, D, eta = 0.2, 3.0, 0.5
    for Lc in (400, 1600, 6400):
        for delta in (0.1, 0.01):
            for label, c in (("sqrt(2 L ln(1/delta))", 2.0), ("sqrt(8 L ln(1/delta)) [note.md]", 8.0)):
                slack = eta * mu * Lc - sqrt(c * Lc * log(1 / delta))
                k = int(math.floor(slack / (1 + D))) if slack > 0 else -1
                if k < 0:
                    print(f"L={Lc} delta={delta} with {label}: the condition allows no k")
                    continue
                # total rise = (2B - L) - k(1+D) with B ~ Bin(L,(1+mu)/2), provided B >= k; good iff >= (1-eta) mu L
                need = ((1 - eta) * mu * Lc + k * (1 + D) + Lc) / 2.0      # B >= need
                bmin = math.ceil(need - 1e-12)
                fail = binom_cdf(Lc, max(bmin, k) - 1, (1 + mu) / 2)
                print(f"L={Lc} delta={delta} with {label}: largest k = {k} (fraction {k / Lc:.4f}); exact failure = {fail:.3e} <= delta")
        # without the square-root term the statement fails
        k = int(math.floor(eta * mu * Lc / (1 + D)))
        need = ((1 - eta) * mu * Lc + k * (1 + D) + Lc) / 2.0
        fail = binom_cdf(Lc, math.ceil(need - 1e-12) - 1, (1 + mu) / 2)
        print(f"L={Lc}: k = floor(eta mu L/(1+D)) = {k} (no square-root term): exact failure = {fail:.3f}")
        k2 = int(math.floor((eta * mu * Lc + 2 * sqrt(Lc)) / (1 + D)))
        need = ((1 - eta) * mu * Lc + k2 * (1 + D) + Lc) / 2.0
        fail = binom_cdf(Lc, math.ceil(need - 1e-12) - 1, (1 + mu) / 2)
        print(f"L={Lc}: k = floor((eta mu L + 2 sqrt(L))/(1+D)) = {k2}: exact failure = {fail:.3f}")


# ---------------------------------------------------------------- (3)
def check_certificate():
    print("== (3) validation certificate, part (a): Pr[rho > rho_hat + sqrt(2 rho_hat ln(1/delta)/m) + 2 ln(1/delta)/m] ==")
    for delta in (0.1, 0.01):
        for m in (20, 100, 500):
            worst = 0.0
            for i in range(1, 400):
                rho = i / 400.0
                # the event: the bound computed from k disagreements is below rho
                pr = 0.0
                for k in range(0, m + 1):
                    rh = k / m
                    ub = rh + sqrt(2 * rh * log(1 / delta) / m) + 2 * log(1 / delta) / m
                    if ub < rho:
                        pr += binom_pmf(m, k, rho)
                    else:
                        break
                worst = max(worst, pr)
            zero = max((1 - r / 1000.0) ** m for r in range(1, 1000) if r / 1000.0 > log(1 / delta) / m) if log(1 / delta) / m < 0.999 else 0.0
            print(f"delta={delta} m={m}: worst coverage failure over rho = {worst:.4f} <= delta;  "
                  f"rule 'no disagreement => rho <= ln(1/delta)/m': worst failure = {zero:.4f} <= delta")


# ---------------------------------------------------------------- (4)
def check_majority_tolerance():
    print("== (4) majority scaffold: Pr[Bin(L, 1/2 + th) <= L/2 + k] against exp(-2 (th L - k)^2 / L) ==")
    for Lc, th in ((101, 0.2), (401, 0.1), (1601, 0.05)):
        for frac in (0.0, 0.25, 0.5):
            k = int(frac * th * Lc)
            ex = binom_cdf(Lc, int(math.floor(Lc / 2 + k)), 0.5 + th)
            print(f"L={Lc} theta'={th} k={k}: exact = {ex:.3e} <= bound = {exp(-2 * (th * Lc - k) ** 2 / Lc):.3e}")


if __name__ == "__main__":
    check_last_round()
    check_bounded_damage()
    check_certificate()
    check_majority_tolerance()
