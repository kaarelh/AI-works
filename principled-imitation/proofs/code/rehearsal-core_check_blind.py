#!/usr/bin/env python3
"""Referee's check of Remark (ii) after Theorem 8.4 of research/prove-c/rehearsal-core.md:
"A tolerance assumption for rules that do not see the human's answer would not suffice for Theorem 8.4."
The file asserts this without an example.  It is true; here is one, in the family of Remark 12.3(ii)
with D > 1.

All L calls are at one input.  The human answers u (step +1) with probability (1+mu)/2 and d (step -1)
otherwise; a third answer b has the step -D.  A run is good if the total rise is at least (1 - eta) mu L.

Blind rules.  A blind rule chooses at call j, before the human's answer y'_j exists (it may use everything
earlier, and coins), either to pass the human's answer or an override o_j in {u, d, b, bottom}; a replacement
is counted when the passed answer differs from the human's (Definition 3.3).  With xi_j := step(y'_j) - mu,
the loss of call j against the human's step is
    override b or bottom:  step(y'_j) + D = (mu + D) + xi_j      (always a replacement),
    override d:            2 * 1[y'_j = u]                        (2 per replacement),
    override u:            -2 * 1[y'_j = d] <= 0.
Hence, with c* := max(2, mu + D) and k the number of replacements,
    rise >= mu L - c* k + sum over the calls not overridden by b or bottom of xi_j,
and the last sum is a martingale with increments of conditional range 2 (the override is chosen before the
answer).  By Lemma 12.1 every blind rule with at most k replacements fails with probability at most delta if
        c* k + sqrt(2 L ln(1/delta)) <= eta mu L.                                   (*)
Note that a blind rule can lose 2 per replacement by passing d until its budget is used (passing d when the
human says d is no replacement); so for D <= 1 blind rules are as harmful as rules that see the answer,
and the example needs D > 1.

The kernel C_eps gives b in place of u with probability eps and is the human otherwise:
beta(C_eps) = eps L (1+mu)/2 unfaithful calls in expectation, each of which loses exactly 1 + D > c*.

If Theorem 8.4 held with tolerance against blind rules, the failure of C_eps would be at most
delta + beta/(k+1) for every k satisfying (*).  The exact failure (binomial computation) is larger.
"""
import numpy as np
from math import sqrt, log, floor
from scipy.stats import binom


def kernel_fail(L, mu, D, eta, eps):
    """Exact failure probability of the run of C_eps."""
    thr = (1 - eta) * mu * L
    p = (1 + mu) / 2
    sd = sqrt(L * p * (1 - p))
    us = np.arange(max(0, int(L * p - 9 * sd)), min(L, int(L * p + 9 * sd)) + 1)   # number of answers u
    pu = binom.pmf(us, L, p)
    # rise = 2U - L - (1 + D) R,  R ~ Bin(U, eps);  fail iff R > (2U - L - thr)/(1 + D)
    rmax = np.floor((2 * us - L - thr) / (1 + D) + 1e-9)
    fail = np.where(rmax < 0, 1.0, binom.sf(rmax, us, eps))
    return float((pu * fail).sum())


def blind_b_fail(L, mu, D, eta, k):
    """One blind rule: override k calls fixed in advance by b."""
    thr = (1 - eta) * mu * L
    n = L - k
    need = (thr + n + D * k) / 2            # the number of u among the other calls must be at least this
    return float(binom.cdf(int(np.ceil(need - 1e-9)) - 1, n, (1 + mu) / 2))


def blind_d_fail(L, mu, D, eta, k):
    """Another blind rule: pass d at every call until k replacements have been counted.
    This replaces the first k answers u by d: rise = 2U - L - 2 min(k, U)."""
    thr = (1 - eta) * mu * L
    p = (1 + mu) / 2
    us = np.arange(0, L + 1)
    rise = 2 * us - L - 2 * np.minimum(k, us)
    return float(binom.pmf(us, L, p)[rise < thr - 1e-9].sum())


def main():
    eta, delta = 0.5, 1e-3
    ok = True
    for mu, D in ((0.2, 3.0), (0.2, 1.0)):
        cstar = max(2.0, mu + D)
        print(f"mu = {mu}, D = {D}, eta = {eta}, delta = {delta}: loss per replacement at most c* = {cstar} for blind rules, 1 + D = {1 + D} for the kernel")
        for L in (200000, 2000000):
            k = int(floor((eta * mu * L - sqrt(2 * L * log(1 / delta))) / cstar))     # allowed by (*)
            fb, fd = blind_b_fail(L, mu, D, eta, k), blind_d_fail(L, mu, D, eta, k)
            ok &= fb <= delta and fd <= delta
            for x in (0.9, 0.95):
                beta = x * k
                eps = beta / (L * (1 + mu) / 2)
                f = kernel_fail(L, mu, D, eta, eps)
                would = delta + beta / (k + 1)
                verdict = "the bound would be VIOLATED" if f > would else "no violation"
                print(f"  L = {L}: (*) allows k = {k} (two particular blind rules fail w.p. {fb:.1e} and {fd:.1e} <= delta); "
                      f"kernel with beta = {beta:.0f} = {x} k: exact failure = {f:.4f}; delta + beta/(k+1) = {would:.4f} -> {verdict}")
    print("For D = 3 the kernel fails with probability near 1 although every blind rule with k replacements fails with")
    print("probability at most delta and beta < k: tolerance against rules that do not see the current human answer does")
    print("not give the conclusion of Theorem 8.4.  For D = 1 there is no violation, as it must be: there c* = 1 + D.")
    print("ALL CHECKS PASSED" if ok else "SOME CHECK FAILED")


if __name__ == "__main__":
    main()
