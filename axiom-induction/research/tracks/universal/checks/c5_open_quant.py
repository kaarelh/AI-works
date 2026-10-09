"""c5: open instances, Gen, the closedness guard, filtered data, and quantified data (Props. U10-U12).

Part A (calculus {cite, forall-elim (c), Gen (g)}, Q_open = rho*[w0] + (1-rho)*numerals(1/2); exact output laws
from common.open_calculus_forms, validated by Monte Carlo in c1):
  hypotheses H_forall, H_open (unguarded template phi(z), z ~ Q_open), H_sch (guarded: z closed),
  H_both (forall x phi and the guarded template, Laplace weight on the split).
  Streams: S1 = closed instances t ~ Q_c (this is also the law of H_forall's output filtered to closed
  instances); S2 = output of H_open; S3 = output of H_forall (unfiltered).
  Likelihoods: L1-norm (normalised grammar), L1-sel (conditioned on 'the datum is a closed instance'),
  L0-closure (forall x phi read as its instance template, z ~ Q_open).
  Reported: mean posterior P(T |- forall x phi | D_n) (H_forall, H_open, H_both prove it; H_sch does not),
  in the full class and in a class without the guarded template.
Part B (minimal calculus {cite, forall-elim}; quantified data): data are forall x phi with probability f_q and
  phi(t) otherwise.  Hypotheses T_sch = {phi(z)}, T_forall = {forall x phi}, and with Laplace weights
  T_sch+B = {B, phi(z)} where B = forall^L forall x phi (L vacuous quantifiers: forall x phi costs L extra
  eliminations) and T_both = {forall x phi, phi(z)}.  Exact likelihoods via common.lp_L1, normalised.
Seeded; output c5_open_quant.out."""
import math
import random
from common import P, num, NumLaw, open_calculus_forms, lp_L1, log_Z_L1, prior_logw, logsumexp, NEG_INF

OUT = []


def say(*a):
    s = ' '.join(str(x) for x in a)
    print(s)
    OUT.append(s)


C, G, RHO = 0.3, 0.2, 0.1
BASE = NumLaw(0.5)
GRID = [i / 400 for i in range(1, 400)]  # theta grid for the Laplace weight of H_both


def laws():
    """for each hypothesis (and each theta of H_both): functions giving normalised log-probabilities of
    the three datum kinds: ('all',), ('par',), ('cl', k) for phi(S^k 0)."""
    out = {}
    for name, (wa, wo, ws) in {'forall': (1, 0, 0), 'open': (0, 1, 0), 'sch': (0, 0, 1)}.items():
        a, bp, bcl, Z = open_calculus_forms(C, G, RHO, wa, wo, ws, BASE.logp)
        out[name] = (a / Z, bp / Z, (lambda bcl=bcl, Z=Z: (lambda k: bcl(num(k)) / Z))())
    both = []
    for th in GRID:
        a, bp, bcl, Z = open_calculus_forms(C, G, RHO, th, 0, 1 - th, BASE.logp)
        both.append((a / Z, bp / Z, (lambda bcl=bcl, Z=Z: (lambda k: bcl(num(k)) / Z))()))
    return out, both


def logp(law, d, variant):
    a, bp, bcl = law
    if variant == 'L1-norm':
        p = a if d[0] == 'all' else bp if d[0] == 'par' else bcl(d[1])
    elif variant == 'L1-sel':  # condition on 'closed instance'; only closed data are allowed here
        if d[0] != 'cl':
            raise ValueError
        tot = 1 - a - bp
        p = bcl(d[1]) / tot
    else:
        raise ValueError(variant)
    return math.log(p) if p > 0 else NEG_INF


def sample(law_name, out, rng):
    a, bp, bcl = out[law_name]
    u = rng.random()
    if u < a:
        return ('all',)
    if u < a + bp:
        return ('par',)
    # closed instance: conditional law of k is geometric(1/2) for every hypothesis (checked in c1)
    return ('cl', numval(BASE.sample(rng)))


def numval(t):
    k = 0
    while t[0] == 'S':
        t, k = t[1], k + 1
    return k


def part_a():
    out, both = laws()
    sizes = {'forall': 6, 'open': 5, 'sch': 6, 'both': 6 + 6}  # dtrc symbols; the guard costs 1 symbol
    lp0 = {h: -(sizes[h] + (2 if h == 'both' else 1)) * math.log(2) for h in sizes}
    say('Part A: c=%.1f g=%.1f rho=%.1f, numerals q=1/2; prior 2^-(symbols+1 per axiom), guard = 1 symbol' % (C, G, RHO))
    say('  per-datum ratios at a closed instance (L1-norm): forall/sch = %.4f, open/sch = %.4f, forall/open = %.4f'
        % tuple(math.exp(logp(out[x], ('cl', 2), 'L1-norm') - logp(out[y], ('cl', 2), 'L1-norm'))
                for x, y in [('forall', 'sch'), ('open', 'sch'), ('forall', 'open')]))
    NS = [0, 1, 2, 5, 10, 20, 50, 100]
    for stream, gen in [('S1 closed instances (= H_forall filtered)', 'sch'), ('S2 output of H_open', 'open'),
                        ('S3 output of H_forall', 'forall')]:
        for variant in ['L1-norm', 'L1-sel']:
            if variant == 'L1-sel' and gen != 'sch':
                continue
            for cls in ['full', 'no guard']:
                hs = ['forall', 'open', 'sch', 'both'] if cls == 'full' else ['forall', 'open']
                accp = {n: 0.0 for n in NS}
                accw = {n: {h: 0.0 for h in hs} for n in NS}
                seeds = 200
                for seed in range(seeds):
                    rng = random.Random(3000 + seed)
                    ll = {h: 0.0 for h in hs if h != 'both'}
                    llb = [0.0] * len(GRID)
                    for n in range(NS[-1] + 1):
                        if n in accp:
                            post = {h: lp0[h] + ll[h] for h in ll}
                            if 'both' in hs:
                                post['both'] = lp0['both'] + logsumexp(llb) - math.log(len(GRID))
                            Zp = logsumexp(list(post.values()))
                            m = {h: math.exp(post[h] - Zp) for h in post}
                            accp[n] += sum(m[h] for h in m if h != 'sch') / seeds
                            for h in m:
                                accw[n][h] += m[h] / seeds
                        if n == NS[-1]:
                            break
                        d = sample(gen, out, rng)
                        for h in ll:
                            ll[h] += logp(out[h], d, variant)
                        if 'both' in hs:
                            llb = [x + logp(bl, d, variant) for x, bl in zip(llb, both)]
                say('  %s | %s | class %s' % (stream, variant, cls))
                say('     n:            ' + ' '.join('%6d' % n for n in NS))
                say('     P(|- forall): ' + ' '.join('%6.3f' % accp[n] for n in NS))
                for h in hs:
                    say('     %-13s ' % h + ' '.join('%6.3f' % accw[n][h] for n in NS))


def part_c():
    """spare slot: H_both = {forall x phi, phi(z)} with a uniform prior on the weight theta of forall x phi, closed
    minimal calculus, L1-norm, instance-only data.  Its likelihood relative to H_sch is
    I_n = int_0^1 ((1 - theta (1-c)) / (1 + theta c))^n d theta, with 1/(n+1) <= I_n <= 1/(n (1-c))."""
    import mpmath as mp
    say('\nPart C: spare slot H_both (uniform weight) vs H_sch on n closed instances, L1-norm, c = %.1f' % C)
    for n in [1, 10, 100, 1000, 10 ** 4, 10 ** 5]:
        In = mp.quad(lambda th: ((1 - th * (1 - C)) / (1 + th * C)) ** n, [0, mp.mpf(1) / n, mp.mpf(10) / n, 1])
        assert 1 / (n + 1) <= In <= 1 / (n * (1 - C))
        say('  n = %6d   I_n = %.6e   n I_n = %.5f   bounds [n/(n+1), 1/(1-c)] = [%.5f, %.5f]'
            % (n, float(In), float(n * In), n / (n + 1), 1 / (1 - C)))


def part_b():
    say('\nPart B: minimal calculus, c = %.1f; data: forall x phi with prob f_q, else phi(t), t ~ numerals(1/2)' % C)
    sig, al = P('0+?z=?z'), P('forall x. 0+x=x')
    law = BASE
    for L in [3, 10]:
        B = al
        for _ in range(L):
            B = ('all', B)  # vacuous quantifiers: B |- forall x phi after L eliminations
        hyps = {'T_sch': [(sig, 1.0)], 'T_forall': [(al, 1.0)]}
        prior = {h: prior_logw([A for A, w in th]) for h, th in hyps.items()}
        prior['T_both'] = prior_logw([al, sig]) - math.log(2)
        prior['T_sch+B'] = prior_logw([B, sig]) - math.log(2)
        # closed forms for the Laplace-weighted two-axiom theories (Prop. U1 and the chain structure of B)
        def ZB(th):
            return (1 - C) * (th * sum(C ** k for k in range(L + 2)) + (1 - th))

        def lpB(th, quantified):
            if quantified:
                return math.log((1 - C) * th * C ** L) - math.log(ZB(th))
            return math.log((1 - C) * ((1 - th) + th * C ** (L + 1))) - math.log(ZB(th))
        for th in [0.1, 0.5, 0.9]:
            thy = [(B, th), (sig, 1 - th)]
            assert abs(lp_L1(thy, al, C, law) - log_Z_L1(thy, C) - lpB(th, True)) < 1e-12
            assert abs(lp_L1(thy, P('0+2=2'), C, law) - log_Z_L1(thy, C) - lpB(th, False) - law.logp(num(2))) < 1e-12
        logZ = {h: log_Z_L1(th, C) for h, th in hyps.items()}
        dq, di = al, P('0+2=2')
        for th in [0.05, 0.2]:
            Zt = (1 - C) * (1 + th * C)
            say('  L = %d, theta = %.2f: per quantified datum log P_T_both - log P_T_sch+B = %.3f (L log(1/c) = %.3f); '
                'per instance %.3f' % (L, th, math.log((1 - C) * th / Zt) - lpB(th, True), L * math.log(1 / C),
                                        math.log((1 - C) * (1 - th + th * C) / Zt) - lpB(th, False)))
        # T_both(theta) in closed form (Prop. U1): P(forall x phi) = (1-c) theta / Z, P(phi(t)) = (1-c)(1-theta+theta c) Q(t) / Z,
        # Z = (1-c)(1 + theta c); checked against the generic engine at three thetas
        for th in [0.1, 0.5, 0.9]:
            Zt = (1 - C) * (1 + th * C)
            assert abs(lp_L1([(al, th), (sig, 1 - th)], dq, C, law) - log_Z_L1([(al, th), (sig, 1 - th)], C)
                       - math.log((1 - C) * th / Zt)) < 1e-12
            assert abs(lp_L1([(al, th), (sig, 1 - th)], di, C, law) - log_Z_L1([(al, th), (sig, 1 - th)], C)
                       - math.log((1 - C) * (1 - th + th * C) * math.exp(law.logp(num(2))) / Zt)) < 1e-12
        cache = {}
        for fq in [0.0, 0.01, 0.05, 0.2]:
            NS = [0, 10, 50, 200, 1000]
            acc = {n: {h: 0.0 for h in list(hyps) + ['T_sch+B', 'T_both']} for n in NS}
            seeds = 40
            for seed in range(seeds):
                rng = random.Random(7000 + seed)
                ll = {h: 0.0 for h in hyps}
                nq = ni = 0
                slq = 0.0
                for n in range(NS[-1] + 1):
                    if n in acc:
                        post = {h: prior[h] + ll[h] for h in ll}
                        lb = [nq * math.log((1 - C) * th) + ni * math.log((1 - C) * (1 - th + th * C)) + slq
                              - n * math.log((1 - C) * (1 + th * C)) for th in GRID]
                        post['T_both'] = prior['T_both'] + logsumexp(lb) - math.log(len(GRID))
                        lbB = [nq * lpB(th, True) + ni * lpB(th, False) + slq for th in GRID]
                        post['T_sch+B'] = prior['T_sch+B'] + logsumexp(lbB) - math.log(len(GRID))
                        Zp = logsumexp(list(post.values()))
                        for h in post:
                            acc[n][h] += math.exp(post[h] - Zp) / seeds
                    if n == NS[-1]:
                        break
                    if rng.random() < fq:
                        d = dq
                        nq += 1
                    else:
                        t = law.sample(rng)
                        d = instance(sig, t)
                        ni += 1
                        slq += law.logp(t)
                    for h, th in hyps.items():
                        if ll[h] > NEG_INF:
                            if (h, d) not in cache:
                                cache[(h, d)] = lp_L1(th, d, C, law) - logZ[h]
                            ll[h] += cache[(h, d)]
            say('   f_q = %.2f   n: ' % fq + ' '.join('%7d' % n for n in NS))
            for h in list(hyps) + ['T_sch+B', 'T_both']:
                say('     %-9s ' % h + ' '.join('%7.3f' % acc[n][h] for n in NS))
            say('     P(T |- forall x phi) = 1 - mass(T_sch): ' + ' '.join('%7.3f' % (1 - acc[n]['T_sch']) for n in NS))


def instance(sig, t):
    from dtrc.templates import instantiate
    return instantiate(sig, {'z': t})


if __name__ == '__main__':
    part_a()
    part_c()
    part_b()
    open('c5_open_quant.out', 'w').write('\n'.join(OUT) + '\n')
