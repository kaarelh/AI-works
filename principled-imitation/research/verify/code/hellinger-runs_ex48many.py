#!/usr/bin/env python3
"""Referee check (key: hellinger-runs), part 5: the second half of Example 4.8.

The text of Example 4.8 gives numbers for "B alternatives of weight 1/(2B), each refuted in
its own branch" without stating the construction; it is in the prover's script
hellinger-runs_thmA.py (function example_48_many):
  call 1 at x0 with answers in {0, 1..B}; the answer i >= 1 leads to call 2 at x_i; the
  answer 0 stops.  Human: P(i|x0) = p/B, P(0|x0) = 1-p, P(.|x_i) = point mass at 1.
  nu_i: nu_i(i|x0) = 0, nu_i(0|x0) = 1-p+p/B, nu_i(.|x_i) = point mass at 0, otherwise as P.
  Weights 1/2 for P and 1/(2B) for each nu_i, so K = 1.
The prover sums the excess over t by the trapezoid rule on a logarithmic grid of t.  Here the
excess  E[(B-v)(p/B) ln(1/(1-omega_t))]  is computed for EVERY t and summed, with the tail
after the prover's cut-off shown separately.  Needs numpy.
"""
import math
import numpy as np


def excess_sum(B, p, tmax):
    r = (1 - p + p / B) / (1 - p)
    v = np.arange(B + 1)
    alive = (B - v).astype(float)
    # joint law of (n0, v) after the recorded runs, updated run by run:
    # a run answers 0 (prob 1-p): n0 += 1; or enters a uniformly chosen branch (prob p): v may grow
    # state: dict over n0 would be large; use arrays law[n0, v] with n0 <= tmax
    law = np.zeros((tmax + 1, B + 1))
    law[0, 0] = 1.0
    total = 0.0
    per_t = []
    logr = math.log(r)
    n0 = np.arange(tmax + 1, dtype=float)
    for t in range(1, tmax + 1):
        # excess at round t given the state before it
        lr = np.exp(np.minimum(n0 * logr, 600.0))[:, None]
        # ln(1/(1-omega)) with omega = lr/(B + alive lr), written without cancellation
        a = alive[None, :]
        lost = np.log(B + a * lr) - np.log(B + np.maximum(a - 1, 0.0) * lr)
        loss = np.where(a > 0, a * (p / B) * lost, 0.0)
        e = float(np.sum(law * loss))
        per_t.append(e)
        total += e
        new = np.zeros_like(law)
        new[1:, :] += law[:-1, :] * (1 - p)                       # answer 0
        new[:, :] += law * p * (v / B)[None, :]                   # a branch visited before
        new[:, 1:] += law[:, :-1] * p * (1 - v[:-1] / B)[None, :]   # a new branch
        law = new
    return total, per_t


if __name__ == "__main__":
    print("Example 4.8, many alternatives (K = 1, L = 2, p = 1/2): excess of the frozen per-call mixture, summed over ALL t <= tmax")
    for B, quoted in [(4, 1.8189), (16, 2.5025), (64, 3.2131)]:
        t_prover = int(6 * B * math.log(B) / 0.5) + 10
        tmax = 2 * t_prover
        total, per_t = excess_sum(B, 0.5, tmax)
        upto = sum(per_t[:t_prover])
        print(f"  B = {B:3d}: sum over t <= {t_prover} = {upto:.4f} (the file quotes {quoted}); sum over t <= {tmax} = {total:.4f};"
              f" last term = {per_t[-1]:.2e}; (ln B)/2 = {math.log(B) / 2:.4f}; L K ln2 = {2 * math.log(2):.4f}")
