"""c9: the sentence-only class without templates (referee issue M2; Prop U16 of notes-final).

Minimal calculus C_min = {cite (1-c), forall-elim (c)}, numeral data phi(S^j 0), j ~ Geom(q) (P(j) = (1-q) q^j),
phi = 0+x=x, c = 0.3, q = 1/2.  Hypotheses (finite sets of sentences):
  H_forall = {forall x phi};  Both0 = {phi(0), forall x phi};
  Split_k  = {phi(0), ..., phi(S^(k-1) 0), forall y phi(S^k y)}   (Split_1 is the 'Split' of notes.md);
  memorisers: finite sets of closed instances (product-Bernoulli prior r_j = 2^(-lam(|phi(S^j 0)|+1)), lower bracket).
All weights Dirichlet(alpha), alpha = 1/2 by default.  Prior 2^-(symbols + 1 per axiom); memoriser class mass 2^-6.
Provers of forall x phi: in pure logic H_forall and Both0; over Q also every Split_k (k uses of Q3); memorisers in
neither.

Part 1  the closed-form laws of Split_k and Both0 (L1-norm and L0-closure) against the generic exact engine of
        common.py (lp_L1, log_Z_L1, lp_L0closure), at fixed weights.
Part 2  inf_w KL(P* || Split_k) = q^k log((1+c)/c) and inf KL(P* || Both0) = q log((1+qc)/(qc)) (numerical).
Part 3  posteriors on paths up to n = 10^6 (20 seeds): classes S3 = {H_forall, Split_1, Both0} (the class of c7),
        S4m = {H_forall, Both0, Split_1..4, memorisers}, S40m = the same with Split_1..40.  L1-norm and L0-closure.
Part 4  class S40m at n = 10^7..10^12 (multinomial counts), L1-norm, with robustness variants.
Seeded.  Output: c9_sentences.out."""
import math
import random
import sys
import time
from collections import Counter

sys.dont_write_bytecode = True
import numpy as np

from common import P, num, NumLaw, lp_L1, log_Z_L1, lp_L0closure
from rev_common import (LN2, log_int, log_beta_int, log_beta_fn, log_dirmult, geom_logpmf, counts_from_path,
                        multinomial_geom_counts)

OUT = []


def say(s=''):
    print(s, flush=True)
    OUT.append(s)


C, Q = 0.3, 0.5
J = 200
LQ = np.array([geom_logpmf(Q, j) for j in range(J)])


def inst(j):
    t = num(j)
    return ('=', ('+', ('0',), t), t)


def univ(k):
    x = ('v', 0)
    for _ in range(k):
        x = ('S', x)
    return ('all', ('=', ('+', ('0',), x), x))


# ---------------------------------------------------------------------------------------------- Part 1
def split_law(k, v, u, j, variant):
    """normalised probability of phi(S^j 0) under Split_k with sentence weights v and universal weight u"""
    if variant == 'L1-norm':
        if j < k:
            return v[j] / (1 + C * u)
        return u * C * (1 - Q) * Q ** (j - k) / (1 + C * u)
    if j < k:
        return v[j]
    return u * (1 - Q) * Q ** (j - k)


def both0_law(th, j, variant):
    Qj = (1 - Q) * Q ** j
    if variant == 'L1-norm':
        return ((th if j == 0 else 0.0) + (1 - th) * C * Qj) / (1 + C * (1 - th))
    return (th if j == 0 else 0.0) + (1 - th) * Qj


def part1():
    say('Part 1: closed forms against the generic exact engine (common.py), fixed weights, data j = 0..8')
    law = NumLaw(Q)
    worst = 0.0
    for k, v, u in [(1, [0.6], 0.4), (2, [0.3, 0.3], 0.4), (3, [0.2, 0.2, 0.1], 0.5)]:
        th = [(inst(j), v[j]) for j in range(k)] + [(univ(k), u)]
        for j in range(9):
            e1 = math.exp(lp_L1(th, inst(j), C, law) - log_Z_L1(th, C))
            e0 = math.exp(lp_L0closure(th, inst(j), law))
            worst = max(worst, abs(e1 - split_law(k, v, u, j, 'L1-norm')), abs(e0 - split_law(k, v, u, j, 'L0')))
    for t in [0.2, 0.5, 0.8]:
        th = [(inst(0), t), (univ(0), 1 - t)]
        for j in range(9):
            e1 = math.exp(lp_L1(th, inst(j), C, law) - log_Z_L1(th, C))
            e0 = math.exp(lp_L0closure(th, inst(j), law))
            worst = max(worst, abs(e1 - both0_law(t, j, 'L1-norm')), abs(e0 - both0_law(t, j, 'L0')))
    say('  max |engine - closed form| = %.1e over Split_1..3 and Both0, 2 likelihoods' % worst)
    assert worst < 1e-12


# ---------------------------------------------------------------------------------------------- Part 2
def kl_split(k, u, q=Q, c=C, Jm=400):
    Qc = [(1 - q) * q ** j for j in range(Jm)]
    head = sum(Qc[:k])
    v = [(1 - u) * Qc[j] / head for j in range(k)]
    s = 0.0
    for j in range(Jm):
        p = v[j] / (1 + c * u) if j < k else u * c * Qc[j - k] / (1 + c * u)
        s += Qc[j] * math.log(Qc[j] / p)
    return s


def kl_both0(th, q=Q, c=C, Jm=400):
    s = 0.0
    for j in range(Jm):
        Qj = (1 - q) * q ** j
        p = ((th if j == 0 else 0.0) + (1 - th) * c * Qj) / (1 + c * (1 - th))
        s += Qj * math.log(Qj / p)
    return s


def gmin(f, lo=1e-9, hi=1 - 1e-9):
    gr = (math.sqrt(5) - 1) / 2
    a, b = lo, hi
    for _ in range(200):
        x1, x2 = b - gr * (b - a), a + gr * (b - a)
        if f(x1) < f(x2):
            b = x2
        else:
            a = x1
    return f((a + b) / 2)


def part2():
    say('\nPart 2: minimal KL (nats per datum) against the closed forms')
    worst = 0.0
    for q, c in [(0.5, 0.3), (0.8, 0.5), (0.3, 0.1)]:
        row = []
        for k in range(1, 7):
            x = gmin(lambda u: kl_split(k, u, q, c))
            pred = q ** k * math.log((1 + c) / c)
            worst = max(worst, abs(x - pred))
            row.append('%.5f/%.5f' % (x, pred))
        xb = gmin(lambda t: kl_both0(t, q, c))
        pb = q * math.log((1 + q * c) / (q * c))
        worst = max(worst, abs(xb - pb))
        say('  q=%.1f c=%.1f  H_forall %.5f | Split_1..6 numeric/pred %s | Both0 %.5f/%.5f'
            % (q, c, math.log((1 + c) / c), ' '.join(row), xb, pb))
    say('  max |numeric - closed form| = %.1e' % worst)


# ---------------------------------------------------------------------------------------------- Part 3
def lm_forall(n, variant):
    return n * math.log(C / (1 + C)) if variant == 'L1-norm' else 0.0


def lm_split(k, counts, n, alpha, variant):
    head = counts[:k]
    nh = int(head.sum())
    nt = n - nh
    s = log_dirmult(head, alpha) - float(np.dot(head, LQ[:k])) - nt * k * math.log(Q)
    if variant == 'L1-norm':
        s += nt * math.log(C) + log_beta_int(nt + alpha, nh + k * alpha, n, C)
    else:
        s += log_beta_int(nt + alpha, nh + k * alpha, 0, 0.0)
    return s - log_beta_fn(alpha, k * alpha)


def lm_both0(counts, n, alpha, variant):
    n0 = int(counts[0])
    n1 = n - n0
    q0 = 1 - Q

    def g(t):
        lt = -np.logaddexp(0.0, -t)
        l1t = -np.logaddexp(0.0, t)
        th = np.exp(lt)
        if variant == 'L1-norm':
            ll = n0 * np.log((th + (1 - th) * C * q0) / q0) + n1 * (l1t + math.log(C)) - n * np.log1p(C * (1 - th))
        else:
            ll = n0 * np.log((th + (1 - th) * q0) / q0) + n1 * l1t
        return ll + alpha * lt + alpha * l1t
    return log_int(g) - log_beta_fn(alpha, alpha)


def lm_mem(counts, alpha, lam, upper):
    js = np.nonzero(counts)[0]
    if len(js) == 0:
        return 0.0
    lr = -lam * LN2 * (6 + 2 * js)
    s = float(np.sum(lr))
    if not upper:
        logZ0 = float(np.sum(np.log1p(-2.0 ** (-lam * (6 + 2 * np.arange(400))))))
        s += logZ0 - float(np.sum(np.log1p(-np.exp(lr))))
    return s + log_dirmult(counts[js], alpha) - float(np.dot(counts, LQ))


def prior_bits(h, lam):
    if h == 'H_forall':
        return lam * 7
    if h == 'Both0':
        return lam * 13
    k = int(h.split('_')[1])
    return lam * (k * k + 7 * k + 7)


def posterior(counts, n, kmax, variant, alpha=0.5, lam=1.0, logmu=-6 * LN2, mem=True, upper=False, cache=None):
    names = ['H_forall', 'Both0'] + ['Split_%d' % k for k in range(1, kmax + 1)]
    lp = {}
    for h in names:
        key = (h, variant, alpha)
        if cache is not None and key in cache:
            l = cache[key]
        else:
            if h == 'H_forall':
                l = lm_forall(n, variant)
            elif h == 'Both0':
                l = lm_both0(counts, n, alpha, variant)
            else:
                l = lm_split(int(h.split('_')[1]), counts, n, alpha, variant)
            if cache is not None:
                cache[key] = l
        lp[h] = -prior_bits(h, lam) * LN2 + l
    if mem:
        lp['mem'] = lam * logmu + (lm_mem(counts, alpha, lam, upper) if n > 0 else 0.0)
    m = max(lp.values())
    Z = sum(math.exp(x - m) for x in lp.values())
    post = {h: math.exp(x - m) / Z for h, x in lp.items()}
    p_pure = post['H_forall'] + post['Both0']
    p_q = 1 - post.get('mem', 0.0)
    best = max(post, key=post.get)
    return p_pure, p_q, post.get('mem', 0.0), best, post


def part3():
    say('\nPart 3: posteriors on numeral data (Dirichlet(1/2) weights, prior 2^-(symbols+1 per axiom), '
        'memoriser class mass 2^-6, lower bracket)')
    NS = [0, 20, 100, 1000, 10 ** 4, 10 ** 5, 10 ** 6]
    seeds = 20
    paths = []
    for s in range(seeds):
        r = np.random.default_rng(9100 + s)
        paths.append(r.geometric(1 - Q, size=NS[-1]) - 1)
    for variant in ['L1-norm', 'L0-closure']:
        res = {cl: {n: [] for n in NS} for cl in ['S3', 'S4m', 'S40m']}
        for s in range(seeds):
            for n in NS:
                counts = counts_from_path(paths[s], n, J)
                cache = {}
                res['S3'][n].append(posterior(counts, n, 1, variant, mem=False, cache=cache))
                res['S4m'][n].append(posterior(counts, n, 4, variant, cache=cache))
                res['S40m'][n].append(posterior(counts, n, 40, variant, cache=cache))
        for cl, desc in [('S3', '{H_forall, Split_1, Both0}'), ('S4m', '{H_forall, Both0, Split_1..4, memorisers}'),
                         ('S40m', '{H_forall, Both0, Split_1..40, memorisers}')]:
            say('  %s | class %s %s | mean over %d seeds' % (variant, cl, desc, seeds))
            say('     n:                    ' + ' '.join('%9d' % n for n in NS))
            say('     P(T |- Ax phi), pure: ' + ' '.join('%9.3f' % np.mean([x[0] for x in res[cl][n]]) for n in NS))
            say('     P(T |- Ax phi), Q:    ' + ' '.join('%9.3f' % np.mean([x[1] for x in res[cl][n]]) for n in NS))
            say('     mass(memorisers):     ' + ' '.join('%9.3f' % np.mean([x[2] for x in res[cl][n]]) for n in NS))
            say('     MAP (mode over seeds):' + ' '.join('%9s' % Counter(x[3] for x in res[cl][n]).most_common(1)[0][0]
                                                        for n in NS))


def part4():
    say('\nPart 4: class S40m at larger n, L1-norm (multinomial counts, 10 seeds per n); robustness variants')
    NS = [10 ** 7, 10 ** 8, 10 ** 9, 10 ** 10, 10 ** 12]
    variants = [('default (alpha=1/2, lam=1, mu=2^-6, lower bracket)', dict()),
                ('memoriser upper bracket, mu=2^-1', dict(upper=True, logmu=-1 * LN2)),
                ('alpha=1', dict(alpha=1.0)),
                ('lam=2', dict(lam=2.0))]
    for vname, kw in variants:
        say('  %s' % vname)
        for n in NS:
            pq, pm, ks, gap = [], [], [], []
            for s in range(10):
                r = np.random.default_rng(9500 + s + 17 * int(math.log10(n)))
                counts = multinomial_geom_counts(r, n, Q, J)
                p_pure, p_q, p_mem, best, post = posterior(counts, n, 40, 'L1-norm', **kw)
                pq.append(p_q)
                pm.append(p_pure)
                ks.append(best)
            say('     n=1e%d: P_Q %.3f  P_pure %.1e  MAP %s' % (int(math.log10(n)), np.mean(pq), np.mean(pm),
                                                            Counter(ks).most_common(1)[0][0]))


def part5():
    """log posterior odds of the best Split_k against the memoriser class, along one path and at large n"""
    say('\nPart 5: log-odds (nats) of the Split family (sum over k <= 40) against the memoriser class, L1-norm, '
        'default prior; mean (min, max) over 10 seeds')
    for n in [10 ** 2, 10 ** 3, 10 ** 4, 10 ** 5, 10 ** 6, 10 ** 8, 10 ** 10, 10 ** 12]:
        vals = []
        for s in range(10):
            r = np.random.default_rng(9700 + s + 31 * int(math.log10(n)))
            counts = multinomial_geom_counts(r, n, Q, J)
            _, _, _, _, post = posterior(counts, n, 40, 'L1-norm')
            sp = sum(v for h, v in post.items() if h.startswith('Split'))
            # recompute in log space to avoid underflow
            lp = {}
            for h in ['Split_%d' % k for k in range(1, 41)]:
                lp[h] = -prior_bits(h, 1.0) * LN2 + lm_split(int(h.split('_')[1]), counts, n, 0.5, 'L1-norm')
            m = max(lp.values())
            lsplit = m + math.log(sum(math.exp(x - m) for x in lp.values()))
            lmem = -6 * LN2 + lm_mem(counts, 0.5, 1.0, False)
            vals.append(lsplit - lmem)
        L = math.log2(n)
        say('  n=1e%-2d  log-odds %9.1f (%9.1f, %9.1f)   L log2 L = %7.1f' % (int(math.log10(n)), np.mean(vals),
                                                                           min(vals), max(vals), L * math.log2(L)))


if __name__ == '__main__':
    t0 = time.time()
    say('c9_sentences: C_min, c=%.1f, numerals q=%.1f, phi = 0+x=x' % (C, Q))
    part1()
    part2()
    part3()
    part4()
    part5()
    print('runtime %.0f s' % (time.time() - t0))
    open('c9_sentences.out', 'w').write('\n'.join(OUT) + '\n')
