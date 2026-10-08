"""c8: the class without a closedness guard in C_open (referee issue M1; Prop U11(e) and Props N1-N3 of notes-final).

Calculus C_open(c, g): each node cites (K = 1-c-g), applies forall-elimination (c; term from Q_open) or Gen over the
parameter w0 (g).  Q_open = rho [w0] + (1-rho) Q_c, Q_c(S^j 0) = (1-q) q^j.  phi = 0+x=x.  No guards anywhere.
Data: closed instances phi(S^j 0), j ~ Q_c i.i.d. (= H_forall's output filtered to closed instances).

Hypotheses:
  H_forall = {forall x phi};  H_open = {phi(z)};
  R_k = {phi(0), ..., phi(S^(k-1) 0), phi(S^k z)}  (root splits; weights (v_0..v_{k-1}, u), Dirichlet(alpha));
  memorisers: finite sets F of closed instances, product-Bernoulli prior r_j = 2^(-lam(|phi(S^j 0)|+1)) on numeral
  instances (summable), Dirichlet(alpha) weights; the exact class marginal is bracketed by U6(i):
  lower = the term F = S_n, upper = prod_{s in S_n} r_s * DirMult.
Provers of forall x phi: in pure logic H_forall, H_open; over Q also every R_k (k uses of Q3).  Memorisers prove it
in neither.

Part 1  exact output law of R_k (Prop N1) against the procedural sampler of common.py (independent of the formulas).
Part 2  inf_w KL(P* || P_{R_k,w}) = q^k log((1+g rho)/(1-rho)) (Prop N2), by numerical minimisation over the
        weights, for several parameter settings; random perturbations of the head weights never improve it.
Part 3  posteriors under L1-norm and L1-sel, paths up to n = 10^6, 20 seeds; classes A = {H_forall, H_open, R_1},
        B4 = A + R_2..R_4 + memorisers, B40 = A + R_2..R_40 + memorisers.
Part 4  larger n (multinomial counts) for class B40 under L1-norm, with robustness variants.
Seeded.  Output: c8_noguard.out."""
import math
import random
import sys
import time
from collections import Counter

sys.dont_write_bytecode = True
import numpy as np
import mpmath as mp

from common import P, NumLaw, OpenLaw, sample_derivation
from rev_common import (LN2, log_beta_int, log_beta_fn, log_dirmult, geom_logpmf, counts_from_path,
                        multinomial_geom_counts)

OUT = []


def say(s=''):
    print(s, flush=True)
    OUT.append(s)


C, G, RHO, Q = 0.3, 0.2, 0.1, 0.5


def consts(c=C, g=G, rho=RHO):
    K = 1 - c - g
    A = (1 - rho) / (1 - g * c * rho)
    B = (1 + g * rho) / (1 - g * c * rho)
    return K, A, B


# ---------------------------------------------------------------------------------------------- Part 1
def phi_of(term):
    return ('=', ('+', ('0',), term), term)


def S_pow(k, t):
    for _ in range(k):
        t = ('S', t)
    return t


def classify(d):
    if d is None:
        return None
    if d[0] == 'all':
        return 'univ'
    t, s = d[2], 0
    while t[0] == 'S':
        t, s = t[1], s + 1
    if t == ('0',):
        return ('j', s)
    return ('par', s)


def part1():
    say('Part 1: exact law of R_k (Prop N1) against the procedural sampler (common.sample_derivation)')
    K, A, B = consts()
    tl = OpenLaw(NumLaw(Q), RHO)
    worst = 0.0
    for k, v, u, N, seed in [(1, [0.5], 0.5, 200000, 11), (2, [0.3, 0.2], 0.5, 200000, 12), (3, [0.2, 0.1, 0.1], 0.6, 200000, 13)]:
        theory = [(phi_of(S_pow(j, ('0',))), v[j]) for j in range(k)] + [(phi_of(S_pow(k, ('M', 'z', ()))), u)]
        rng = random.Random(seed)
        cnt = Counter(classify(sample_derivation(theory, C, G, tl, None, rng)) for _ in range(N))
        succ = N - cnt.get(None, 0)
        exact = {'succ': K * (1 - u + u * B)}
        for j in range(k):
            exact[('j', j)] = K * v[j]
        for m in range(4):
            exact[('j', k + m)] = K * u * A * (1 - Q) * Q ** m
        exact[('par', k)] = K * u * RHO / (1 - G * C * RHO)
        exact['univ'] = K * u * G * RHO / (1 - G * C * RHO)
        zs = []
        for key, p in exact.items():
            f = (succ if key == 'succ' else cnt.get(key, 0)) / N
            zs.append((f - p) / math.sqrt(p * (1 - p) / N))
        # nothing else may occur
        other = sum(x for key, x in cnt.items() if key is not None and key not in exact and not (key[0] == 'j' and key[1] >= k))
        worst = max(worst, max(abs(z) for z in zs))
        say('  R_%d v=%s u=%.1f, N=%d: z-scores (success, heads, tail j=k..k+3, phi(S^k w0), universal): %s; '
            'unexpected outputs: %d' % (k, v, u, N, ' '.join('%+.2f' % z for z in zs), other))
    say('  max |z| = %.2f' % worst)


# ---------------------------------------------------------------------------------------------- Part 2
def kl_R(k, u, c, g, rho, q, v=None, J=400):
    """KL(P* || P_{R_k}) by direct summation; head weights v (default proportional to Q_c on the head)."""
    K, A, B = consts(c, g, rho)
    Qc = [(1 - q) * q ** j for j in range(J)]
    head = sum(Qc[:k])
    if v is None:
        v = [(1 - u) * Qc[j] / head for j in range(k)]
    Z = sum(v) + u * B
    kl = 0.0
    for j in range(J):
        p = v[j] / Z if j < k else A * u * Qc[j - k] / Z
        kl += Qc[j] * math.log(Qc[j] / p)
    return kl


def argmin_golden(f, lo, hi, it=200):
    gr = (math.sqrt(5) - 1) / 2
    a, b = lo, hi
    x1, x2 = b - gr * (b - a), a + gr * (b - a)
    f1, f2 = f(x1), f(x2)
    for _ in range(it):
        if f1 < f2:
            b, x2, f2 = x2, x1, f1
            x1 = b - gr * (b - a)
            f1 = f(x1)
        else:
            a, x1, f1 = x1, x2, f2
            x2 = a + gr * (b - a)
            f2 = f(x2)
    return (a + b) / 2


def part2():
    say('\nPart 2: inf_w KL(P* || R_k) against q^k log((1+g rho)/(1-rho)) (Prop N2)')
    rng = random.Random(21)
    worst = 0.0
    worst_pert = -1.0
    for (c, g, rho, q) in [(0.3, 0.2, 0.1, 0.5), (0.5, 0.3, 0.3, 0.8), (0.1, 0.6, 0.05, 0.3), (0.2, 0.2, 0.5, 0.9)]:
        K, A, B = consts(c, g, rho)
        row = []
        for k in range(0, 7):
            if k == 0:
                kl = math.log(B / A)
                ustar = 1.0
            else:
                ustar = argmin_golden(lambda u: kl_R(k, u, c, g, rho, q), 1e-9, 1 - 1e-9)
                kl = kl_R(k, ustar, c, g, rho, q)
                upred = q ** k / (B * (1 - q ** k) + q ** k)
                assert abs(ustar - upred) < 1e-6, (ustar, upred)
                # random perturbations of the head weights (same total) never do better
                Qc = [(1 - q) * q ** j for j in range(k)]
                for _ in range(20):
                    w = [x * math.exp(0.3 * rng.gauss(0, 1)) for x in Qc]
                    s = sum(w)
                    v = [(1 - ustar) * x / s for x in w]
                    worst_pert = max(worst_pert, kl - kl_R(k, ustar, c, g, rho, q, v=v))
            pred = q ** k * math.log((1 + g * rho) / (1 - rho))
            worst = max(worst, abs(kl - pred))
            row.append('%d: %.6f/%.6f' % (k, kl, pred))
        say('  c=%.1f g=%.1f rho=%.2f q=%.1f  k: numeric/predicted  %s' % (c, g, rho, q, '  '.join(row)))
    say('  max |numeric - predicted| = %.1e; minimiser u* = q^k/(B(1-q^k)+q^k) to 1e-6; '
        'max gain from perturbing head weights = %.1e (<= 0 means none)' % (worst, worst_pert))


# ---------------------------------------------------------------------------------------------- Part 3
J = 200
LQ = np.array([geom_logpmf(Q, j) for j in range(J)])


def lm_forall(n, variant):
    return n * math.log(C * (1 - RHO) / (1 + C)) if variant == 'L1-norm' else 0.0


def lm_open(n, variant):
    K, A, B = consts()
    return n * math.log(A / B) if variant == 'L1-norm' else 0.0


def lm_R(k, counts, n, alpha, variant):
    """log marginal likelihood ratio of R_k (Dirichlet(alpha) on k+1 weights) against the true law."""
    K, A, B = consts()
    beta = (B - 1) if variant == 'L1-norm' else (A - 1)
    head = counts[:k]
    nh = int(head.sum())
    nt = n - nh
    s = log_dirmult(head, alpha) - float(np.dot(head, LQ[:k]))
    s += nt * (math.log(A) - k * math.log(Q))
    s += log_beta_int(nt + alpha, nh + k * alpha, n, beta) - log_beta_fn(alpha, k * alpha)
    return s


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


def prior_bits(name, lam):
    if name == 'H_forall':
        return lam * 7
    if name == 'H_open':
        return lam * 6
    k = int(name[2:])
    return lam * (k * k + 7 * k + 6)


def posterior(counts, n, kmax, variant, alpha=0.5, lam=1.0, logmu=-6 * LN2, mem=True, upper=False, cache=None):
    names = ['H_forall', 'H_open'] + ['R_%d' % k for k in range(1, kmax + 1)]
    lp = {}
    for h in names:
        if h == 'H_forall':
            l = lm_forall(n, variant)
        elif h == 'H_open':
            l = lm_open(n, variant)
        else:
            key = (h, variant, alpha)
            if cache is not None and key in cache:
                l = cache[key]
            else:
                l = lm_R(int(h[2:]), counts, n, alpha, variant)
                if cache is not None:
                    cache[key] = l
        lp[h] = -prior_bits(h, lam) * LN2 + l
    if mem:
        lp['mem'] = (lam / 1.0) * logmu + lm_mem(counts, alpha, lam, upper) if n > 0 else lam * logmu
    m = max(lp.values())
    Z = sum(math.exp(x - m) for x in lp.values())
    post = {h: math.exp(x - m) / Z for h, x in lp.items()}
    p_pure = post['H_forall'] + post['H_open']
    p_q = 1 - post.get('mem', 0.0)
    best = max(post, key=post.get)
    return p_pure, p_q, post.get('mem', 0.0), best, post


def part3():
    say('\nPart 3: posteriors, closed-instance data, Dirichlet(1/2) weights, prior 2^-(symbols + 1 per axiom), '
        'memoriser class mass 2^-6 (lower bracket)')
    NS = [0, 10, 100, 1000, 10 ** 4, 10 ** 5, 10 ** 6]
    seeds = 20
    paths = []
    for s in range(seeds):
        r = np.random.default_rng(8000 + s)
        paths.append(r.geometric(1 - Q, size=NS[-1]) - 1)
    for variant in ['L1-norm', 'L1-sel']:
        res = {cl: {n: [] for n in NS} for cl in ['A', 'B4', 'B40']}
        for s in range(seeds):
            for n in NS:
                counts = counts_from_path(paths[s], n, J)
                cache = {}
                res['A'][n].append(posterior(counts, n, 1, variant, mem=False, cache=cache))
                res['B4'][n].append(posterior(counts, n, 4, variant, cache=cache))
                res['B40'][n].append(posterior(counts, n, 40, variant, cache=cache))
        for cl, desc in [('A', '{H_forall, H_open, R_1}'), ('B4', '+ R_2..R_4 + memorisers'),
                         ('B40', '+ R_2..R_40 + memorisers')]:
            say('  %s | class %s %s | mean over %d seeds' % (variant, cl, desc, seeds))
            say('     n:                    ' + ' '.join('%9d' % n for n in NS))
            say('     P(T |- Ax phi), pure: ' + ' '.join('%9.3f' % np.mean([x[0] for x in res[cl][n]]) for n in NS))
            say('     P(T |- Ax phi), Q:    ' + ' '.join('%9.3f' % np.mean([x[1] for x in res[cl][n]]) for n in NS))
            say('     mass(memorisers):     ' + ' '.join('%9.3f' % np.mean([x[2] for x in res[cl][n]]) for n in NS))
            say('     MAP (mode over seeds):' + ' '.join('%9s' % Counter(x[3] for x in res[cl][n]).most_common(1)[0][0]
                                                        for n in NS))


def part4():
    say('\nPart 4: class B40 at larger n, L1-norm (multinomial counts, 10 seeds per n); robustness variants')
    NS = [10 ** 7, 10 ** 8, 10 ** 9, 10 ** 10, 10 ** 12]
    variants = [('default (alpha=1/2, lam=1, mu=2^-6, lower bracket)', dict()),
                ('memoriser upper bracket, mu=2^-1', dict(upper=True, logmu=-1 * LN2)),
                ('alpha=1', dict(alpha=1.0)),
                ('lam=2', dict(lam=2.0))]
    for vname, kw in variants:
        rows = []
        for n in NS:
            pq, pm, ks = [], [], []
            for s in range(10):
                r = np.random.default_rng(9000 + s + 17 * int(math.log10(n)))
                counts = multinomial_geom_counts(r, n, Q, J)
                p_pure, p_q, p_mem, best, post = posterior(counts, n, 40, 'L1-norm', **kw)
                pq.append(p_q)
                pm.append(p_pure)
                ks.append(best)
            rows.append('n=1e%d: P_Q %.3f P_pure %.1e MAP %s' % (int(math.log10(n)), np.mean(pq), np.mean(pm),
                                                              Counter(ks).most_common(1)[0][0]))
        say('  %s' % vname)
        for r_ in rows:
            say('     ' + r_)


def selftest():
    say('Self-test of the integrator: log int_0^1 u^(a-1)(1-u)^(b-1)(1+beta u)^(-n) du against mpmath hyp2f1')
    worst = 0.0
    for a, b, n, beta in [(2.5, 3.5, 0, 0.3), (10.5, 40.5, 51, 0.3), (0.5, 0.5, 10, 0.2), (300.5, 2.5, 303, -0.3),
                          (50.5, 0.5, 51, 0.026), (0.5, 2.0, 3000, 0.026)]:
        x = log_beta_int(a, b, n, beta)
        ex = float(mp.log(mp.beta(a, b) * mp.hyp2f1(n, a, a + b, -beta)))
        worst = max(worst, abs(x - ex))
    say('  max abs error %.1e over 6 cases' % worst)
    assert worst < 1e-8


if __name__ == '__main__':
    t0 = time.time()
    say('c8_noguard: C_open, c=%.1f g=%.1f rho=%.1f, numerals q=%.1f, phi = 0+x=x' % (C, G, RHO, Q))
    selftest()
    part1()
    part2()
    part3()
    part4()
    print('runtime %.0f s' % (time.time() - t0))
    open('c8_noguard.out', 'w').write('\n'.join(OUT) + '\n')
