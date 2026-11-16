#!/usr/bin/env python3
"""Referee check (key: hellinger-runs), part 5: the second half of Example 4.8.

The text of Example 4.8 gives numbers for "B alternatives of weight 1/(2B), each refuted in
its own branch" without stating the construction; it is in the prover's script
hellinger-runs_thmA.py (function example_48_many):
  call 1 at x0 with answers in {0, 1..B}; the answer i >= 1 leads to call 2 at x_i; the
  answer 0 stops.  Human: P(i|x0) = p/B, P(0|x0) = 1-p, P(.|x_i) = point mass at 1.
  nu_i: nu_i(i|x0) = 0, nu_i(0|x0) = 1-p+p/B, nu_i(.|x_i) = point mass at 0, otherwise as P.
  Weights 1/2 for P and 1/(2B) for each nu_i, so K = 1.
Before round t let n0 be the number of recorded runs with answer 0 and v the number of
visited branches.  Each surviving nu_i has posterior weight omega = r^n0/(B + (B-v) r^n0)
with r = (1-p+p/B)/(1-p), and the excess of the frozen per-call mixture over the mixture of
run laws in round t is (B-v)(p/B) ln(1/(1-omega)).

The prover sums the expected excess over t by the trapezoid rule on a logarithmic grid of t.
Here it is computed for EVERY t and summed, in two independent ways:
  (1) a dynamic programme over the joint law of (n0, v), run by run (B <= 64);
  (2) the binomial law of the number of branch runs times the occupancy law of v, with the
      binomial law cut where it is below 1e-25 (all B).
Needs numpy and scipy.
"""
import math

import numpy as np
from scipy.stats import binom


def lost(B, alive, lr):
    """ln(1/(1-omega)) for omega = lr/(B + alive lr), written without cancellation."""
    return np.log(B + alive * lr) - np.log(B + np.maximum(alive - 1, 0.0) * lr)


def excess_dp(B, p, tmax):
    r = (1 - p + p / B) / (1 - p)
    v = np.arange(B + 1)
    alive = (B - v).astype(float)[None, :]
    law = np.zeros((tmax + 1, B + 1))                # law[n0, v] before round t
    law[0, 0] = 1.0
    n0 = np.arange(tmax + 1, dtype=float)[:, None]
    lr = np.exp(np.minimum(n0 * math.log(r), 600.0))
    loss = np.where(alive > 0, alive * (p / B) * lost(B, alive, lr), 0.0)
    per_t = []
    for t in range(1, tmax + 1):
        per_t.append(float(np.sum(law * loss)))
        new = np.zeros_like(law)
        new[1:, :] += law[:-1, :] * (1 - p)                          # answer 0
        new[:, :] += law * p * (v / B)[None, :]                      # a branch visited before
        new[:, 1:] += law[:, :-1] * p * (1 - v[:-1] / B)[None, :]      # a new branch
        law = new
    return per_t


def excess_window(B, p, tmax):
    r = (1 - p + p / B) / (1 - p)
    logr = math.log(r)
    v = np.arange(B + 1)
    alive = (B - v).astype(float)[None, :]
    # occupancy law occ[b, v] of the number v of distinct branches among b branch runs
    occ = np.zeros((tmax + 1, B + 1))
    occ[0, 0] = 1.0
    for b in range(1, tmax + 1):
        occ[b] = occ[b - 1] * (v / B)
        occ[b, 1:] += occ[b - 1, :-1] * (1 - v[:-1] / B)
    per_t = []
    for t in range(1, tmax + 1):
        nprev = t - 1
        mean, sd = nprev * p, math.sqrt(nprev * p * (1 - p))
        lo = max(0, int(mean - 12 * sd - 8))
        hi = min(nprev, int(mean + 12 * sd + 8))
        nb = np.arange(lo, hi + 1)                                   # number of branch runs
        pb = binom.pmf(nb, nprev, p)
        keep = pb > 1e-25
        nb, pb = nb[keep], pb[keep]
        lr = np.exp(np.minimum((nprev - nb) * logr, 600.0))[:, None]
        loss = np.where(alive > 0, alive * (p / B) * lost(B, alive, lr), 0.0)
        per_t.append(float(np.sum(pb[:, None] * occ[nb] * loss)))
    return per_t


if __name__ == "__main__":
    p = 0.5
    print("Example 4.8, many alternatives (K = 1, L = 2, p = 1/2): excess of the frozen per-call mixture, summed over EVERY t")
    print("  columns: B | cut-off t of the prover | sum up to the cut-off, method (2) | method (1) | sum up to twice the cut-off | the file quotes | (ln B)/2")
    prev = None
    for B, quoted in [(4, 1.8189), (16, 2.5025), (64, 3.2131), (256, 3.9188)]:
        t_prover = int(6 * B * math.log(B) / p) + 10
        tmax = 2 * t_prover if B <= 64 else t_prover
        w = excess_window(B, p, tmax)
        s_cut = sum(w[:t_prover])
        dp = f"{sum(excess_dp(B, p, t_prover)):.4f}" if B <= 64 else "not run"
        s_all = f"{sum(w):.4f}" if B <= 64 else "not run"
        step = "" if prev is None else f"; increase over the previous B: {s_cut - prev:.3f} (ln 4 / 2 = {math.log(4) / 2:.3f})"
        print(f"  B = {B:3d} | {t_prover:5d} | {s_cut:.4f} | {dp} | {s_all} | {quoted} | {math.log(B) / 2:.4f}{step}")
        prev = s_cut
    print(f"  L K ln2 = {2 * math.log(2):.4f}")
