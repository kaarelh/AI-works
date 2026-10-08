"""Referee check r3: Prop U11(e) of notes.md ("without a guard ... H_open wins on closed data, and every surviving
hypothesis proves forall x phi: the posterior takes the omega-step").

Calculus C_open = {cite (K = 1-c-g), forall-elim (c), Gen over the parameter w0 (g)}; term law for metavariables
and eliminations Q_open = rho*[w0] + (1-rho)*numerals(q).  phi = 0+x=x.  No guards anywhere ("no guard" class),
pure logic as background.  Data: closed instances phi(S^k 0), k ~ Geom(q) i.i.d. (= guarded schema's law
= H_forall's output filtered to closed instances).

Hypotheses (all DT°/first-order, unguarded):
  H_forall = {forall x phi};  H_open = {phi(z)};
  R_k = {phi(0), ..., phi(S^{k-1} 0), phi(S^k z)}  (k = 1, 2, 3; Dirichlet(1) weights)  -- R_k does NOT prove
        forall x phi in pure logic (model: N u {e, e'}, S e = e', S e' = e', 0+e = e', 0+e' = e');
  memoriser class (finite sets of closed instances, Laplace weights; prior product-Bernoulli with
        r_s = 2^-(|s|+1) on closed phi-instances, which is summable); lower bound used (F = distinct data).
Exact laws of R_k derived in referee.md and checked here against an independent Monte Carlo sampler of C_open.
Output: r3_noguard.out.  Seeded."""
import math
import random
from collections import Counter

OUT = []


def say(s=''):
    print(s)
    OUT.append(s)


c, g, rho, q = 0.3, 0.2, 0.1, 0.5
K = 1 - c - g
LN2 = math.log(2)


def Qc(k):
    return (1 - q) * q ** k


# ------------------------------------------------------------------ exact normalised laws at closed instances
def lp_forall(k):
    return math.log(Qc(k) * (1 - rho) * c / (1 + c))


def lp_open(k):
    return math.log(Qc(k) * (1 - rho) / (1 + g * rho))


def ZR(u):
    """normaliser of R_k when the template phi(S^k z) has weight u (sentences carry 1-u); in units of K"""
    return (1 - g * c * rho + g * rho * u * (1 + c)) / (1 - g * c * rho)


def p_R(kk, v, u, j):
    """R_kk, sentence weights v[0..kk-1], template weight u; normalised probability of phi(S^j 0)"""
    if j < kk:
        return v[j] / ZR(u)
    return (1 - rho) * Qc(j - kk) * u / ((1 - g * c * rho) * ZR(u))


# ------------------------------------------------------------------ Monte Carlo sampler of C_open (independent)
def qopen(rng):
    if rng.random() < rho:
        return ('w',)
    k = 0
    while rng.random() < q:
        k += 1
    return ('n', k)


def S(t):
    return ('n', t[1] + 1) if t[0] == 'n' else ('S', t)


def sample_R(kk, v, u, rng, depth=0):
    """formulas: ('inst', term) = phi(term); ('all', s) = forall x phi(S^s x).  Returns formula or None."""
    if depth > 400:
        return None
    r = rng.random()
    if r < K:  # cite
        x = rng.random()
        acc = 0.0
        for j in range(kk):
            acc += v[j]
            if x < acc:
                return ('inst', ('n', j))
        t = qopen(rng)
        for _ in range(kk):
            t = S(t)
        return ('inst', t)
    prem = sample_R(kk, v, u, rng, depth + 1)
    if prem is None:
        return None
    if r < K + c:  # forall-elim
        if prem[0] != 'all':
            return None
        t = qopen(rng)
        for _ in range(prem[1]):
            t = S(t)
        return ('inst', t)
    # Gen: abstract w0 if present
    if prem[0] != 'inst':
        return None
    t, s = prem[1], 0
    while t[0] == 'S':
        t, s = t[1], s + 1
    if t != ('w',):
        return None
    return ('all', s)


def check_R_law():
    rng = random.Random(4242)
    N = 400000
    worst = 0.0
    for kk, v, u in [(1, [0.5], 0.5), (2, [0.3, 0.2], 0.5)]:
        cnt = Counter(sample_R(kk, v, u, rng) for _ in range(N))
        fails = cnt.pop(None, 0)
        Zexact = K * ZR(u)
        zs = [((N - fails) / N - Zexact) / math.sqrt(Zexact * (1 - Zexact) / N)]
        for j in range(6):
            p = p_R(kk, v, u, j) * Zexact
            f = cnt[('inst', ('n', j))] / N
            zs.append((f - p) / math.sqrt(p * (1 - p) / N))
        worst = max(worst, max(abs(z) for z in zs))
        say('  R_%d weights %s/%.2f: MC vs exact z-scores (success, phi(0..5)): %s'
            % (kk, v, u, ' '.join('%+.2f' % z for z in zs)))
    return worst


# ------------------------------------------------------------------ marginal likelihoods with Dirichlet(1) weights
UGRID = [(i + 0.5) / 400 for i in range(400)]


def logml_R(kk, counts_lt, counts_ge_lpQ, n_ge):
    """log marginal likelihood of R_kk under Dirichlet(1,...,1) on (v_0..v_{kk-1}, u).
    counts_lt[j] = number of data phi(S^j 0), j < kk; counts_ge_lpQ = sum over data with j >= kk of log Qc(j-kk);
    n_ge = number of such data.  u ~ Beta(1, kk); given u, v = (1-u) * Dirichlet(1,...,1) on kk coordinates."""
    n_lt = sum(counts_lt)
    # Dirichlet-multinomial for the normalised sentence weights
    ldm = math.lgamma(kk) - math.lgamma(n_lt + kk) + sum(math.lgamma(x + 1) for x in counts_lt)
    vals = []
    for u in UGRID:
        lw = math.log(kk) + (kk - 1) * math.log(1 - u)  # Beta(1, kk) density
        l = (n_lt * math.log(1 - u) + n_ge * (math.log(u) + math.log(1 - rho) - math.log(1 - g * c * rho))
             + counts_ge_lpQ - (n_lt + n_ge) * math.log(ZR(u)))
        vals.append(lw + l)
    m = max(vals)
    return ldm + m + math.log(sum(math.exp(x - m) for x in vals) / len(UGRID))


def size_inst(j):
    return 5 + 2 * j  # |0+S^j0=S^j0| in symbols


def main():
    say('r3_noguard: C_open with c=%.1f g=%.1f rho=%.1f, numerals q=%.1f; closed-instance data' % (c, g, rho, q))
    say('(1) exact laws of the root splits R_k against Monte Carlo (400000 derivations each)')
    w = check_R_law()
    say('  max |z| = %.2f' % w)
    # (2) expected per-datum log-likelihood rates against the true (guarded) law
    say('(2) expected per-datum log-likelihood relative to the true law (nats; 0 is best):')
    Hc = -sum(Qc(k) * math.log(Qc(k)) for k in range(200))
    r_forall = sum(Qc(k) * (lp_forall(k) - math.log(Qc(k))) for k in range(200))
    r_open = sum(Qc(k) * (lp_open(k) - math.log(Qc(k))) for k in range(200))
    say('  H_forall %.4f   H_open %.4f' % (r_forall, r_open))
    for kk in [1, 2, 3, 4]:
        # optimal weights: grid over u, sentence weights proportional to their frequencies
        best = -1e9
        for u in [i / 1000 for i in range(1, 1000)]:
            pl = sum(Qc(j) for j in range(kk))
            v = [(1 - u) * Qc(j) / pl for j in range(kk)]
            r = sum(Qc(j) * (math.log(p_R(kk, v, u, j)) - math.log(Qc(j))) for j in range(200))
            best = max(best, r)
        say('  R_%d at best fixed weights %.4f   (R_%d - H_open = %+.4f per datum)' % (kk, best, kk, best - r_open))
    # (3) posteriors
    say('(3) mean posterior over 40 seeds; provers (pure logic): H_forall, H_open; non-provers: R_k, memorisers')
    NS = [0, 10, 30, 100, 300, 1000, 3000]
    prior_bits = {'H_forall': 6 + 1, 'H_open': 5 + 1}
    for kk in [1, 2, 3]:
        prior_bits['R_%d' % kk] = sum(size_inst(j) for j in range(kk)) + size_inst(kk) + 2 * (kk + 1)
    log_mu = -6 * LN2  # prior mass of the memoriser class
    rs = {j: 2.0 ** -(size_inst(j) + 1) for j in range(400)}
    logZ0 = sum(math.log(1 - r) for r in rs.values())
    classes = {'{H_forall, H_open, R_1}': ['H_forall', 'H_open', 'R_1'],
               'full (+R_2, R_3, memorisers)': ['H_forall', 'H_open', 'R_1', 'R_2', 'R_3', 'memo']}
    for cname, hs in classes.items():
        acc = {n: 0.0 for n in NS}
        accm = {n: {h: 0.0 for h in hs} for n in NS}
        seeds = 40
        for seed in range(seeds):
            rng = random.Random(900 + seed)
            data = []
            for _ in range(NS[-1]):
                k = 0
                while rng.random() < q:
                    k += 1
                data.append(k)
            for n in NS:
                D = data[:n]
                cnt = Counter(D)
                post = {}
                for h in hs:
                    if h == 'H_forall':
                        post[h] = -prior_bits[h] * LN2 + sum(lp_forall(k) for k in D)
                    elif h == 'H_open':
                        post[h] = -prior_bits[h] * LN2 + sum(lp_open(k) for k in D)
                    elif h.startswith('R_'):
                        kk = int(h[2:])
                        lt = [cnt.get(j, 0) for j in range(kk)]
                        ge = [k for k in D if k >= kk]
                        post[h] = -prior_bits[h] * LN2 + logml_R(kk, lt, sum(math.log(Qc(k - kk)) for k in ge), len(ge))
                    else:  # memoriser lower bound: F = distinct data, Laplace weights
                        m = len(cnt)
                        if n == 0:
                            post[h] = log_mu
                        else:
                            lap = math.lgamma(m) - math.lgamma(n + m) + sum(math.lgamma(x + 1) for x in cnt.values())
                            post[h] = log_mu + logZ0 + sum(math.log(rs[j] / (1 - rs[j])) for j in cnt) + lap
                mx = max(post.values())
                Zp = sum(math.exp(v - mx) for v in post.values())
                m_ = {h: math.exp(post[h] - mx) / Zp for h in hs}
                acc[n] += (m_['H_forall'] + m_['H_open']) / seeds
                for h in hs:
                    accm[n][h] += m_[h] / seeds
        say('  class %s' % cname)
        say('     n:              ' + ' '.join('%7d' % n for n in NS))
        say('     P(T |- Ax phi):  ' + ' '.join('%7.3f' % acc[n] for n in NS))
        for h in hs:
            say('     %-15s ' % h + ' '.join('%7.3f' % accm[n][h] for n in NS))

    # (4) the same classes under the selection-aware likelihood L1-sel (S = closed instances)
    say('(4) L1-sel (conditioned on "closed instance"): H_forall and H_open both reduce to the true law; R_k to a')
    say('    weighted family containing it.  Mean posterior over 40 seeds, full class:')
    hs = ['H_forall', 'H_open', 'R_1', 'R_2', 'R_3', 'memo']
    acc = {n: 0.0 for n in NS}
    accm = {n: {h: 0.0 for h in hs} for n in NS}
    for seed in range(40):
        rng = random.Random(900 + seed)
        data = []
        for _ in range(NS[-1]):
            k = 0
            while rng.random() < q:
                k += 1
            data.append(k)
        for n in NS:
            D = data[:n]
            cnt = Counter(D)
            post = {}
            for h in hs:
                if h in ('H_forall', 'H_open'):
                    post[h] = -prior_bits[h] * LN2 + sum(math.log(Qc(k)) for k in D)
                elif h.startswith('R_'):
                    kk = int(h[2:])
                    lt = [cnt.get(j, 0) for j in range(kk)]
                    n_lt = sum(lt)
                    ge = [k for k in D if k >= kk]
                    sQ = sum(math.log(Qc(k - kk)) for k in ge)
                    ldm = math.lgamma(kk) - math.lgamma(n_lt + kk) + sum(math.lgamma(x + 1) for x in lt)
                    vals = []
                    for u in UGRID:
                        a_ = (1 - rho) / (1 - g * c * rho)
                        tot = (1 - u) + a_ * u
                        vals.append(math.log(kk) + (kk - 1) * math.log(1 - u) + n_lt * math.log(1 - u)
                                    + len(ge) * (math.log(u) + math.log(a_)) + sQ - n * math.log(tot))
                    mv = max(vals)
                    post[h] = -prior_bits[h] * LN2 + ldm + mv + math.log(sum(math.exp(x - mv) for x in vals) / len(UGRID))
                else:
                    m = len(cnt)
                    if n == 0:
                        post[h] = log_mu
                    else:
                        lap = math.lgamma(m) - math.lgamma(n + m) + sum(math.lgamma(x + 1) for x in cnt.values())
                        post[h] = log_mu + logZ0 + sum(math.log(rs[j] / (1 - rs[j])) for j in cnt) + lap
            mx = max(post.values())
            Zp = sum(math.exp(v - mx) for v in post.values())
            m_ = {h: math.exp(post[h] - mx) / Zp for h in hs}
            acc[n] += (m_['H_forall'] + m_['H_open']) / 40
            for h in hs:
                accm[n][h] += m_[h] / 40
    say('     n:              ' + ' '.join('%7d' % n for n in NS))
    say('     P(T |- Ax phi):  ' + ' '.join('%7.3f' % acc[n] for n in NS))
    for h in hs:
        say('     %-15s ' % h + ' '.join('%7.3f' % accm[n][h] for n in NS))
    open('r3_noguard.out', 'w').write('\n'.join(OUT) + '\n')


if __name__ == '__main__':
    main()
