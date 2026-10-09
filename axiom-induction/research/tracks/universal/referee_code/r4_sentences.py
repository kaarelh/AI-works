"""Referee check r4: Prop U16(b) of notes.md ("sentence-only class, L1-norm: Split = {phi(0), forall y phi(Sy)} wins").

Minimal calculus C_min = {cite (1-c), forall-elim (c)}, L1-norm, phi = 0+x=x, numeral data phi(S^k 0), k ~ Geom(q).
Sentence-only hypotheses (finite sets of sentences, Dirichlet(1) citation weights):
  H_forall = {forall x phi};
  Split_k = {phi(0), ..., phi(S^{k-1} 0), forall y phi(S^k y)}, k = 1, 2, 3, 4  (Split_1 is the track's Split);
  memorisers: finite sets of closed instances (Laplace weights; product-Bernoulli prior r_s = 2^-(|s|+1); lower
  bound F = distinct data).
Exact laws (derived in referee.md): with sentence weights v_j and weight u on the universal,
  P(phi(S^j 0)) = v_j / (1 + c u)  (j < k),   P(phi(S^{k+m} 0)) = u c Q(m) / (1 + c u),   P(universal) = u/(1+cu).
These are checked against an independent sampler.  Reports: per-datum rates at the best weights, posteriors.
Over Q, Split_k proves forall x phi (k uses of Q3); in pure logic it does not.  Memorisers prove it in neither.
Output: r4_sentences.out.  Seeded."""
import math
import random
from collections import Counter

OUT = []


def say(s=''):
    print(s)
    OUT.append(s)


c, q = 0.3, 0.5
LN2 = math.log(2)


def Q(k):
    return (1 - q) * q ** k


def p_split(k, v, u, j):
    if j < k:
        return v[j] / (1 + c * u)
    return u * c * Q(j - k) / (1 + c * u)


def sample_split(k, v, u, rng):
    """C_min chain: elim with prob c on a recursively generated premise, else cite by weight.
    Returns ('inst', j) for phi(S^j 0), ('univ',) for the universal sentence, or None."""
    if rng.random() < c:
        p = sample_split(k, v, u, rng)
        if p is None or p[0] != 'univ':
            return None
        m = 0
        while rng.random() < q:
            m += 1
        return ('inst', k + m)
    x, acc = rng.random(), 0.0
    for j in range(k):
        acc += v[j]
        if x < acc:
            return ('inst', j)
    return ('univ',)


UGRID = [(i + 0.5) / 400 for i in range(400)]


def logml_split(k, cnt, n):
    lt = [cnt.get(j, 0) for j in range(k)]
    n_lt = sum(lt)
    ge = [(j, x) for j, x in cnt.items() if j >= k]
    n_ge = sum(x for _, x in ge)
    sQ = sum(x * math.log(Q(j - k)) for j, x in ge)
    ldm = math.lgamma(k) - math.lgamma(n_lt + k) + sum(math.lgamma(x + 1) for x in lt)
    vals = []
    for u in UGRID:
        lw = math.log(k) + (k - 1) * math.log(1 - u)
        vals.append(lw + n_lt * math.log(1 - u) + n_ge * math.log(u * c) + sQ - n * math.log(1 + c * u))
    m = max(vals)
    return ldm + m + math.log(sum(math.exp(x - m) for x in vals) / len(UGRID))


def size_inst(j):
    return 5 + 2 * j


def main():
    say('r4_sentences: C_min, c = %.1f, L1-norm, numerals q = %.1f, phi = 0+x=x' % (c, q))
    rng = random.Random(77)
    N = 300000
    worst = 0.0
    for k, v, u in [(1, [0.5], 0.5), (3, [0.3, 0.2, 0.1], 0.4)]:
        cnt = Counter(sample_split(k, v, u, rng) for _ in range(N))
        fails = cnt.pop(None, 0)
        Zx = (1 - c) * (1 + c * u)
        zs = [((N - fails) / N - Zx) / math.sqrt(Zx * (1 - Zx) / N)]
        for j in range(6):
            p = p_split(k, v, u, j) * Zx
            zs.append((cnt[('inst', j)] / N - p) / math.sqrt(p * (1 - p) / N))
        worst = max(worst, max(abs(z) for z in zs))
        say('  sampler check Split_%d: z-scores (success, phi(0..5)): %s' % (k, ' '.join('%+.2f' % z for z in zs)))
    say('  max |z| = %.2f' % worst)
    say('per-datum expected log-likelihood relative to the true law (best fixed weights):')
    r_all = sum(Q(j) * (math.log(c * Q(j) / (1 + c)) - math.log(Q(j))) for j in range(200))
    say('  H_forall %.4f' % r_all)
    # check of the notes' per-datum ratios for Split_1 at theta = 1/2
    th = 0.5
    r0 = th * (1 + c) / ((th + (1 - th) * (1 + c)) * c * (1 - q))
    r1 = (1 - th) * (1 + c) / ((th + (1 - th) * (1 + c)) * q)
    say('  notes U16(b) ratios Split:H_forall at theta = 1/2: %.3f at phi(0), %.3f at phi(St); mean log %.3f nats'
        % (r0, r1, (1 - q) * math.log(r0) + q * math.log(r1)))
    for k in [1, 2, 3, 4, 6]:
        best = -1e9
        for u in [i / 2000 for i in range(1, 2000)]:
            pl = sum(Q(j) for j in range(k))
            v = [(1 - u) * Q(j) / pl for j in range(k)]
            r = sum(Q(j) * (math.log(p_split(k, v, u, j)) - math.log(Q(j))) for j in range(300))
            best = max(best, r)
        say('  Split_%d %.4f' % (k, best))
    say('mean posterior over 40 seeds (prior 2^-(symbols + 1 per axiom + 1 per Laplace weight))')
    NS = [0, 20, 100, 500, 2000, 10000]
    prior_bits = {'H_forall': 7}
    for k in [1, 2, 3, 4]:
        # sentences phi(S^j 0) (5+2j symbols), universal forall y phi(S^k y) (6+2k symbols)
        prior_bits['Split_%d' % k] = sum(size_inst(j) for j in range(k)) + (6 + 2 * k) + 2 * (k + 1)
    rs = {j: 2.0 ** -(size_inst(j) + 1) for j in range(400)}
    logZ0 = sum(math.log(1 - r) for r in rs.values())
    log_mu = -7 * LN2
    for cname, hs in [('{H_forall, Split_1} (Both0 omitted)', ['H_forall', 'Split_1']),
                      ('+ Split_2..4', ['H_forall', 'Split_1', 'Split_2', 'Split_3', 'Split_4']),
                      ('+ Split_2..4 + memorisers', ['H_forall', 'Split_1', 'Split_2', 'Split_3', 'Split_4', 'memo'])]:
        acc = {n: {h: 0.0 for h in hs} for n in NS}
        seeds = 40
        for seed in range(seeds):
            r = random.Random(5000 + seed)
            data = []
            for _ in range(NS[-1]):
                k = 0
                while r.random() < q:
                    k += 1
                data.append(k)
            for n in NS:
                cnt = Counter(data[:n])
                post = {}
                for h in hs:
                    if h == 'H_forall':
                        post[h] = -prior_bits[h] * LN2 + sum(x * math.log(c * Q(j) / (1 + c)) for j, x in cnt.items())
                    elif h.startswith('Split_'):
                        post[h] = -prior_bits[h] * LN2 + logml_split(int(h[6:]), cnt, n)
                    else:
                        m = len(cnt)
                        if n == 0:
                            post[h] = log_mu
                        else:
                            lap = math.lgamma(m) - math.lgamma(n + m) + sum(math.lgamma(x + 1) for x in cnt.values())
                            post[h] = log_mu + logZ0 + sum(math.log(rs[j] / (1 - rs[j])) for j in cnt) + lap
                mx = max(post.values())
                Zp = sum(math.exp(v - mx) for v in post.values())
                for h in hs:
                    acc[n][h] += math.exp(post[h] - mx) / Zp / seeds
        say('  class %s' % cname)
        say('     n:          ' + ' '.join('%7d' % n for n in NS))
        for h in hs:
            say('     %-10s  ' % h + ' '.join('%7.3f' % acc[n][h] for n in NS))
    open('r4_sentences.out', 'w').write('\n'.join(OUT) + '\n')


if __name__ == '__main__':
    main()
