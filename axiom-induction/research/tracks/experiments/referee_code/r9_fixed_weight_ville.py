"""Referee check R9: the summary of the notes promises "The threshold verifier is time-uniformly sound with probability
1 - delta' for delta <= 2^(-bits(T*)) delta'" for data "i.i.d. from a theory in the pool".  Prop X8(a) proves this only
for data drawn from the Dirichlet-averaged law M_{T*}; at a FIXED weight vector X8(c) needs a shrinking threshold.
This script shows (independently of the track's code; construction of track model, notes-final Example 4.9) that with
fixed weights and a constant threshold the verifier accepts an underivable sentence with probability near 1.

Setting (L0, Dirichlet(1/2) weights in the model): Q's term root law (0: 0.5, S: 0.5 - eps, +: eps/2, *: eps/2).
T* = {0+0=0, S?z+0=S?z}; T' = {?z+0=?z}.  Prior 1/2 each, so delta' = delta / pi(T*) = 2 delta.  The query
q = (0*0)+0 = 0*0 is cited by T' and not by T*.  The verifier accepts q at n iff pi_n(T*) <= delta = 0.01.
Data i.i.d. from P_{T*, w*} with w* = (0.5, 0.5 - eps)/(1 - eps), the interior point at which T*'s law equals the
law of T' restricted... (T' then differs from the data law only through the eps mass).  Only the count n0 of
datum 0+0=0 matters:
  ln P_{T'}(D) - ln P^Dir_{T*}(D) = n ln(1 - eps) + n0 ln w1* + (n - n0) ln w2* - ln DirMom(n0, n - n0)
(the Q(z) factors cancel).  Accept iff this log Bayes factor >= ln 99.  Checked on a grid of n up to 2e6 (a lower
bound on the acceptance probability).  Also: w* drawn from Dir(1/2, 1/2) (X8(a)'s hypothesis), and the shrinking
threshold of X8(c).  300 runs each, numpy seed 7.  Command: python3 r9_fixed_weight_ville.py"""
import math
import os

import numpy as np
from scipy.special import gammaln

HERE = os.path.dirname(os.path.abspath(__file__))
rng = np.random.default_rng(7)
grid = np.unique(np.round(np.logspace(0, math.log10(2e6), 400)).astype(np.int64))
A = 0.5


def ldir(n0, n1):
    n = n0 + n1
    return gammaln(2 * A) - gammaln(2 * A + n) + gammaln(A + n0) + gammaln(A + n1) - 2 * gammaln(A)


def run(eps, mode, runs=300):
    acc = 0
    for _ in range(runs):
        if mode == 'dirichlet':
            w1 = rng.beta(A, A)
        else:
            w1 = 0.5 / (1 - eps)
        w2 = 1 - w1
        # data law: 0+0=0 w.p. w1; else S z with z ~ Q.  Under T': P(0)=0.5, P(Sz) = (0.5-eps) Q(z).
        inc = np.diff(np.concatenate([[0], grid]))
        n0 = np.cumsum(rng.binomial(inc, w1))
        n = grid
        lbf = n * math.log(1 - eps) + n0 * math.log(0.5) + (n - n0) * math.log(0.5 - eps) - ldir(n0, n - n0) \
            - (n * 0)  # T' versus T* (Dirichlet); the common Q(z) factors cancel
        # note: P_{T'}(0+0=0) = 0.5, P_{T'}(Sz+0=Sz) = (0.5-eps) Q(z); P^Dir_{T*} = DirMom * prod Q(z)
        if mode == 'shrinking':
            # X8(c)/model Thm 4.8: delta_n = pi(T*) delta' R(n, 2), R(n,2) >= 1/(e pi (n+1)) for alpha = 1/2 (Lemma 4.6(b)
            # of track model: Gamma(1)/(e (1)! Gamma(1/2)^2) (n+1)^-1)
            delta_n = 0.5 * 0.02 / (math.e * math.pi) / (n + 1)
            thr = np.log((1 - delta_n) / delta_n)
        else:
            thr = math.log(99)
        if np.any(lbf >= thr):
            acc += 1
    return acc / runs


lines = ['R9: acceptance probability of the underivable query (bound delta/pi(T*) = 0.02), 300 runs each, n <= 2e6 on a grid']
for eps in (1e-5, 1e-6):
    lines.append('eps = %g: fixed w*, constant delta: %.3f | w* ~ Dir(1/2,1/2), constant delta: %.3f | fixed w*, '
                 'shrinking delta_n: %.3f' % (eps, run(eps, 'fixed'), run(eps, 'dirichlet'), run(eps, 'shrinking')))
print('\n'.join(lines))
with open(os.path.join(HERE, 'r9_fixed_weight_ville.out'), 'w') as f:
    f.write('\n'.join(lines) + '\n')
