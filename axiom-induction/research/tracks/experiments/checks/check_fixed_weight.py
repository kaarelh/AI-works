"""Check for Prop X8 (referee M3): at a FIXED weight vector a constant verifier threshold can fail; averaged over
weights drawn from the Dirichlet prior (X8(a)) it does not; with the shrinking threshold of X8(c) it does not.

Setting (the referee's R9 and track model's Example 4.9, recomputed here with this track's code for the
likelihoods): L0; Q's term root law (0: .5, S: .5 - eps, +: eps/2, *: eps/2); T* = {0+0=0, S?z+0=S?z} with
Dirichlet(1/2, 1/2) weights; T' = {?z+0=?z}; prior 1/2 each.  The query q = (0*0)+0 = 0*0 is cited by T' and
not by T*.  The verifier accepts q at n iff pi_n(T*) <= delta = 0.01; the bound of X8(a) is delta/pi(T*) = 0.02.
Data i.i.d. from P_{T*, w*}:
  B1: w* = (.5, .5 - eps)/(1 - eps) fixed (the interior point at which T' is closest to the data law);
  B2: w* drawn from Dir(1/2, 1/2) for each run (the hypothesis of X8(a));
  B3: w* fixed as in B1, threshold delta_n = pi(T*) delta' R(n, 2) with delta' = 0.02 and the lower bound
      R(n, 2) >= 1/(e pi (n + 1)) (track model Lemma 4.6(b); checked exhaustively below for n <= 2000).
Only the count n0 of the datum 0+0=0 matters: ln BF(T' : T*) = n0 ln .5 + (n - n0) ln(.5 - eps) - ln DirMom(n0, n - n0).
Part 1 checks this closed form against bai.posterior.evaluate on random data sets; part 2 checks EVERY n <= 2e6,
300 runs per cell, numpy seed 11.
Command: python3 check_fixed_weight.py   (writes check_fixed_weight.out; about 5 minutes)"""
import math
import os
import random
import sys

import numpy as np
from scipy.special import gammaln

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', '..', '..', '..', 'code', 'experiments'))
import common  # noqa: E402,F401
from common import parse, Theory, Component  # noqa: E402
from bai.grammar import Grammar  # noqa: E402
from bai.posterior import evaluate  # noqa: E402
from bai.gens import cite_data  # noqa: E402

A = 0.5
DELTA = 0.01
OUT = []


def log(s):
    print(s, flush=True)
    OUT.append(s)


def ldir(n0, n1):
    n = n0 + n1
    return gammaln(2 * A) - gammaln(2 * A + n) + gammaln(A + n0) + gammaln(A + n1) - 2 * gammaln(A)


def lbf_closed(n0, n, eps):
    return n0 * math.log(0.5) + (n - n0) * math.log(0.5 - eps) - ldir(n0, n - n0)


# ---------------------------------------------------------------------------------------- part 1
worst = 0.0
for eps in (1e-2, 1e-5):
    Qe = Grammar(term_w={'0': 0.5, 'S': 0.5 - eps, '+': eps / 2, '*': eps / 2})
    Ts = Theory([parse('0+0=0'), parse('S?z+0=S?z')], 'T*', {'log_prior': math.log(0.5)})
    Tp = Theory([parse('?z+0=?z')], "T'", {'log_prior': math.log(0.5)})
    for seed in range(5):
        rng = random.Random(seed)
        w1 = rng.random()
        data = cite_data(Ts, [w1, 1 - w1], Qe, 200, seed)
        ns = [1, 5, 20, 80, 200]
        res = evaluate([Ts, Tp], data, ns, 'L0', Q=Qe, alpha=A, with_mem=False)
        for n, r in zip(ns, res):
            a = (r["T'"]['lp'] + r["T'"]['lm']) - (r['T*']['lp'] + r['T*']['lm'])
            n0 = sum(1 for d in data[:n] if d == parse('0+0=0'))
            worst = max(worst, abs(a - lbf_closed(n0, n, eps)))
log('Part 1: closed form against bai.posterior.evaluate, 2 eps x 5 seeds x 5 n: max |difference| of ln BF = %.2e' % worst)

# exhaustive check of the lower bound on R(n, 2) used for B3
worst_gap = math.inf
for n in range(1, 2001):
    c = np.arange(n + 1)
    lmax = np.where(c > 0, c * np.log(np.maximum(c, 1) / n), 0.0) + np.where(n - c > 0, (n - c) * np.log(np.maximum(n - c, 1) / n), 0.0)
    lR = float(np.min(ldir(c, n - c) - lmax))
    worst_gap = min(worst_gap, lR - (-math.log(math.e * math.pi * (n + 1))))
log('R(n, 2) >= 1/(e pi (n+1)) for every n <= 2000: smallest ln R - ln bound = %.3f (>= 0 means the bound holds)' % worst_gap)

# ---------------------------------------------------------------------------------------- part 2
rng = np.random.default_rng(11)
NMAX = 2 * 10 ** 6
n = np.arange(1, NMAX + 1, dtype=np.float64)


def accept_prob(eps, mode, runs=300):
    acc = 0
    first = []
    for _ in range(runs):
        w1 = rng.beta(A, A) if mode == 'B2' else 0.5 / (1 - eps)
        n0 = np.cumsum(rng.random(NMAX) < w1).astype(np.float64)
        lbf = n0 * math.log(0.5) + (n - n0) * math.log(0.5 - eps) - ldir(n0, n - n0)
        if mode == 'B3':
            dn = 0.5 * 0.02 / (math.e * math.pi * (n + 1))
            thr = np.log((1 - dn) / dn)
        else:
            thr = math.log((1 - DELTA) / DELTA)
        hit = np.nonzero(lbf >= thr)[0]
        if hit.size:
            acc += 1
            first.append(int(hit[0]) + 1)
    return acc / runs, (int(np.median(first)) if first else None)


log('Part 2: probability of ever accepting q (every n <= 2e6 checked; 300 runs per cell; bound delta/pi(T*) = 0.02)')
for eps in (1e-5, 1e-6):
    r = {m: accept_prob(eps, m) for m in ('B1', 'B2', 'B3')}
    log('eps = %g: B1 fixed w*, constant delta: %.3f (median first n %s) | B2 w* ~ Dir(1/2,1/2), constant delta: %.3f | '
        'B3 fixed w*, shrinking delta_n: %.3f' % (eps, r['B1'][0], r['B1'][1], r['B2'][0], r['B3'][0]))
with open(os.path.join(HERE, 'check_fixed_weight.out'), 'w') as f:
    f.write('\n'.join(OUT) + '\n')
