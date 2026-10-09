"""c7: a sentence-only hypothesis class (no templates), numeral data phi(S^k 0), phi = 0+x=x (Prop. U16).

Hypotheses (all finite sets of sentences):
  H_forall      = {forall x phi}
  Split         = {phi(0), forall y phi(Sy)}       (root split; in pure logic it does not prove forall x phi)
  Both0         = {phi(0), forall x phi}            (forall x phi plus its most frequent instance)
Two-axiom theories get a Laplace (uniform) prior on the citation weight.  Likelihoods: L0-closure (a universal
sentence cites its closed instances) and L1-norm (minimal calculus {cite, forall-elim}, normalised), exact via
the engine in common.py.  Reported: mean posterior masses, and P(T |- forall x phi) in pure logic (H_forall,
Both0) and over the background Q, where Q3 (every x != 0 is a successor) makes Split prove it as well.
Seeded; output c7_sentences.out."""
import math
import random
from common import P, num, NumLaw, lp_L1, log_Z_L1, lp_L0closure, prior_logw, logsumexp

OUT = []
C = 0.3
GRID = [i / 200 for i in range(1, 200)]


def say(*a):
    s = ' '.join(str(x) for x in a)
    print(s)
    OUT.append(s)


def main():
    law = NumLaw(0.5)
    sig = P('0+?z=?z')
    al, p0, aS = P('forall x. 0+x=x'), P('0+0=0'), P('forall y. 0+S y=S y')
    hyps = {'H_forall': [al], 'Split': [p0, aS], 'Both0': [p0, al]}
    prior = {h: prior_logw(ax) - (math.log(2) if len(ax) > 1 else 0) for h, ax in hyps.items()}
    NS = [0, 1, 5, 20, 100, 500]
    from dtrc.templates import instantiate
    for variant in ['L0-closure', 'L1-norm']:
        acc = {n: {h: 0.0 for h in hyps} for n in NS}
        accp = {n: [0.0, 0.0] for n in NS}
        cache = {}

        def comp(A, d):
            key = (A, d)
            if key not in cache:
                if variant == 'L0-closure':
                    cache[key] = lp_L0closure([(A, 1.0)], d, law)
                else:
                    cache[key] = lp_L1([(A, 1.0)], d, C, law)
            return cache[key]
        Zs = {A: (1.0 if variant == 'L0-closure' else math.exp(log_Z_L1([(A, 1.0)], C))) for A in [al, p0, aS]}
        seeds = 40
        for seed in range(seeds):
            rng = random.Random(9100 + seed)
            data = [instantiate(sig, {'z': law.sample(rng)}) for _ in range(NS[-1])]
            for n in NS:
                D = data[:n]
                post = {}
                for h, ax in hyps.items():
                    if len(ax) == 1:
                        post[h] = prior[h] + sum(comp(ax[0], d) for d in D) - n * math.log(Zs[ax[0]])
                    else:
                        A1, A2 = ax
                        la = [comp(A1, d) for d in D]
                        lb = [comp(A2, d) for d in D]
                        vals = []
                        for th in GRID:
                            s = 0.0
                            for x, y in zip(la, lb):
                                s += logsumexp([math.log(th) + x, math.log(1 - th) + y])
                            s -= n * math.log(th * Zs[A1] + (1 - th) * Zs[A2])
                            vals.append(s)
                        post[h] = prior[h] + logsumexp(vals) - math.log(len(GRID))
                Zp = logsumexp(list(post.values()))
                m = {h: math.exp(post[h] - Zp) for h in post}
                for h in m:
                    acc[n][h] += m[h] / seeds
                accp[n][0] += (m['H_forall'] + m['Both0']) / seeds
                accp[n][1] += 1.0 / seeds
        say('%s: mean posterior over %d seeds (numerals q=1/2, c=%.1f)' % (variant, seeds, C))
        say('   n:            ' + ' '.join('%7d' % n for n in NS))
        for h in hyps:
            say('   %-13s ' % h + ' '.join('%7.3f' % acc[n][h] for n in NS))
        say('   P(T |- forall x phi), pure logic: ' + ' '.join('%7.3f' % accp[n][0] for n in NS))
        say('   P(T |- forall x phi), over Q:     ' + ' '.join('%7.3f' % accp[n][1] for n in NS))
    open('c7_sentences.out', 'w').write('\n'.join(OUT) + '\n')


if __name__ == '__main__':
    main()
