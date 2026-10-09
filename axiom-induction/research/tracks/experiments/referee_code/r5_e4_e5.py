"""Referee check R5: independent recomputation of E4(A) (tight construction), E5(a) (unused spare factor),
E5(a2) (nested spare: exact Beta-moment sum against the track's quadrature), E5(b) (L_5 versus L_inf) and
E5(c) (Gold's text stage lengths).  Uses ref_core only (own prior code, own Dirichlet moments).
Command: python3 r5_e4_e5.py  (writes r5_e4_e5.out)"""
import math
import os
import random
import sys

import numpy as np
from scipy.special import gammaln, betaln

HERE = os.path.dirname(os.path.abspath(__file__))
import ref_core as R  # noqa: E402

L = []


def out(s):
    print(s, flush=True)
    L.append(s)


lg = math.lgamma
A = 0.5

# ---------------------------------------------------------------- E4(A)
out('E4(A): t* = first n with pi(T*|phi(0)^n) <= w* delta\'; P(win) = (1-u)^t*; ratio = delta\'/P(win)')
for (u, w, dp) in [(0.05, 0.01, 0.01), (0.01, 0.001, 0.05), (0.5, 0.01, 0.01), (0.1, 0.1, 0.1), (0.2, 0.05, 0.2)]:
    n = 0
    while True:
        n += 1
        lmT = n * math.log(1 - u)
        lmD = lg(1) - lg(0.5) + lg(0.5 + n) - lg(1 + n)          # E[w1^n], w ~ Beta(1/2, 1/2)
        post = 1 / (1 + math.exp(math.log(1 - w) + lmD - math.log(w) - lmT))
        if post <= w * dp:
            break
    p = (1 - u) ** n
    out('  u=%.2f w*=%.3f delta\'=%.2f: t* = %d, P(win) = %.5f, bound/P(win) = %.1f' % (u, w, dp, n, p, dp / p))

# ---------------------------------------------------------------- E5(a) unused spare
out('E5(a): unused spare, exact log2 factor Gamma(2a)Gamma(a+n)/(Gamma(a)Gamma(2a+n)):')
out('  ' + ', '.join('n=%d: %.2f' % (n, (lg(2 * A) + lg(A + n) - lg(A) - lg(2 * A + n)) / math.log(2))
                     for n in (1, 16, 256, 4096)))

# ---------------------------------------------------------------- E5(a2) nested spare, exact sum
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '..', '..', '..', '..', 'code', 'experiments')))
import common  # noqa: E402,F401
from e5_gold import nested_bf_quadrature  # noqa: E402


def nested_exact(n, nS, q):
    """log2 E_{w ~ Beta(a,a)} [(1-w+w/q)^nS (1-w)^(n-nS)] = log2 sum_k C(nS,k) q^-k B(a+k, a+n-k)/B(a,a)"""
    k = np.arange(nS + 1, dtype=np.float64)
    t = (gammaln(nS + 1) - gammaln(k + 1) - gammaln(nS - k + 1) - k * math.log(q)
         + betaln(A + k, A + n - k) - betaln(A, A))
    m = t.max()
    return float((m + np.log(np.exp(t - m).sum())) / math.log(2))


q = 0.35
rng = np.random.default_rng(1)
worst = 0.0
for n in (100, 10 ** 4, 10 ** 6):
    for _ in range(3):
        nS = int(rng.binomial(n, q))
        a, b = nested_exact(n, nS, q), nested_bf_quadrature(n, nS, q)
        worst = max(worst, abs(a - b))
out('E5(a2): exact Beta-moment sum against the track quadrature, n in {1e2, 1e4, 1e6}, 3 draws each: '
    'max |diff| = %.2e bits' % worst)
means = []
ns = [10 ** k for k in range(2, 8)]
for n in ns:
    v = [nested_exact(n, int(rng.binomial(n, q)), q) for _ in range(40)]
    means.append(sum(v) / len(v))
xs = [math.log2(n) for n in ns]
mx, my = sum(xs) / len(xs), sum(means) / len(means)
fit = sum((x - mx) * (y - my) for x, y in zip(xs, means)) / sum((x - mx) ** 2 for x in xs)
out('E5(a2) own exact means (40 draws, numpy seed 1): ' + ', '.join('n=1e%d: %.2f' % (k + 2, m) for k, m in enumerate(means))
    + '; least-squares slope vs log2 n: %.3f (alpha/2 = 0.25)' % fit)

# ---------------------------------------------------------------- E5(b)
phi = '?t+0=?t'
P = R.parse(phi)


def numeral(j):
    t = ('0',)
    for _ in range(j):
        t = ('S', t)
    return t


Ls = {k: [R.inst(P, {'t': numeral(j)}) for j in range(k)] for k in range(1, 61)}
bitsL = {k: R.theory_bits(v) for k, v in Ls.items()}
bitsInf = R.theory_bits([P])
out('E5(b) prior bits (own): L_1 %.1f, L_5 %.1f, L_8 %.1f, L_inf %.1f' % (bitsL[1], bitsL[5], bitsL[8], bitsInf))


def post_chain(data_j, n, kmax=40):
    """posterior over {L_1..L_kmax, L_inf} given numeral indices data_j[:n] (Q_num(S^j 0) = 2^-(j+1))"""
    sc = {'inf': -bitsInf * math.log(2) + sum(-(j + 1) * math.log(2) for j in data_j[:n])}
    mxj = max(data_j[:n])
    for k in range(mxj + 1, kmax + 1):
        cnt = [0] * k
        for j in data_j[:n]:
            cnt[j] += 1
        sc[k] = -bitsL[k] * math.log(2) + R.dir_moment(cnt, A)
    z = R.lse(list(sc.values()))
    return {kk: math.exp(v - z) for kk, v in sc.items()}


for src in ('L5', 'Linf'):
    acc = {n: [0.0, 0.0, {}] for n in (4, 8, 16, 64, 128, 256)}
    for seed in range(10):
        r = random.Random(seed)
        if src == 'L5':
            dj = [r.randrange(5) for _ in range(256)]
        else:
            dj = []
            for _ in range(256):
                j = 0
                while r.random() < 0.5:
                    j += 1
                dj.append(j)
        for n in acc:
            p = post_chain(dj, n)
            acc[n][0] += p.get(5, 0.0) / 10
            acc[n][1] += p['inf'] / 10
            mp = max(p, key=p.get)
            acc[n][2][mp] = acc[n][2].get(mp, 0) + 1
    out('E5(b) data from %s (own streams, seeds 0-9): ' % src + '; '.join(
        'n=%d: L5 %.2g, Linf %.3f, MAP %s' % (n, a[0], a[1], a[2]) for n, a in acc.items()))

# ---------------------------------------------------------------- E5(c)
counts = {}
n = 0
linf = -bitsInf * math.log(2)
lens = []
for i in range(1, 15):
    start = n
    j = 0
    while True:
        jj = j % i
        j += 1
        n += 1
        counts[jj] = counts.get(jj, 0) + 1
        linf += -(jj + 1) * math.log(2)
        best, bv = 'inf', linf
        mxj = max(counts)
        for k in range(mxj + 1, 61):
            c = [counts.get(x, 0) for x in range(k)]
            v = -bitsL[k] * math.log(2) + R.dir_moment(c, A)
            if v > bv:
                best, bv = k, v
        if best == i:
            break
    lens.append(n - start)
out('E5(c) own stage lengths i=1..14: %s (total %d)' % (lens, n))
with open(os.path.join(HERE, 'r5_e4_e5.out'), 'w') as f:
    f.write('\n'.join(L) + '\n')
