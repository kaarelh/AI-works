"""c3: how fast does posterior mass leave memorisation?  (Prop. U6 in notes.md)

Memoriser hypotheses: M_F = 'the data are drawn from the finite set F of sentences', with
  (u) uniform weights on F, or (l) Laplace weights (Dirichlet(1) prior on the weights over F).
Prior over F: independent inclusion of each sentence s with probability r_s = 2^{-(|s|+1)} (symbols + 1).
Data: phi(t) for phi = 0+x=x, t ~ Q i.i.d.  We compute, up to an additive constant in [log Z0, 0]
(Z0 = prod_s (1 - r_s) > 0; see notes), the log posterior odds of the whole memoriser class against H_sch:
  D_u(n) = sum_{s in S_n} log r_s - n log m_n          - [log pi_sch + sum_i log Q(t_i)]
  D_l(n) = sum_{s in S_n} log r_s + log Lap(counts)    - [log pi_sch + sum_i log Q(t_i)]
with S_n the set of distinct data and m_n = |S_n|; Lap = Gamma(m)/Gamma(n+m) prod_s Gamma(n_s+1).
Also the proved lower bound  D_l(n) >= sum log r_s - (m_n - 1) log(n + m_n - 1) - log pi_sch.
Prior mass of the memoriser class and of H_sch: both taken as 1/2 (constants do not affect rates).
Seeded; output c3_memo.out."""
import math
import random
from collections import Counter
from common import P, NumLaw, GWLaw, size
from dtrc.templates import instantiate

OUT = []


def say(*a):
    s = ' '.join(str(x) for x in a)
    print(s)
    OUT.append(s)


def main():
    sig = P('0+?z=?z')
    log_pi_sch = -(size(sig) + 1) * math.log(2)
    grid = [10, 30, 100, 300, 1000, 3000, 10000, 30000, 100000]
    say('c3_memo: phi = 0+x=x; natural logs; D = log posterior odds (memoriser class : H_sch), up to O(1)')
    for lawname, law in [('numerals q=1/2', NumLaw(0.5)), ('numerals q=0.9', NumLaw(0.9)),
                         ('GW(.4,.3,.2,.1)', GWLaw())]:
        say('\nlaw %s; 10 seeds; mean over seeds (min, max)' % lawname)
        say('  %7s %8s %12s %12s %12s %10s %10s' % ('n', 'm_n', 'D_uniform', 'D_laplace', 'lowerbnd_l',
                                                   'D_l/ln^2n', 'D_l/n'))
        rows = {n: [] for n in grid}
        for seed in range(10):
            rng = random.Random(500 + seed)
            cnt = Counter()
            sum_logr = 0.0
            sum_logQ = 0.0
            n = 0
            for target in grid:
                while n < target:
                    t = law.sample(rng)
                    d = instantiate(sig, {'z': t})
                    if cnt[d] == 0:
                        sum_logr += -(size(d) + 1) * math.log(2)
                    cnt[d] += 1
                    sum_logQ += law.logp(t)
                    n += 1
                m = len(cnt)
                lap = math.lgamma(m) - math.lgamma(n + m) + sum(math.lgamma(k + 1) for k in cnt.values())
                Du = sum_logr - n * math.log(m) - (log_pi_sch + sum_logQ)
                Dl = sum_logr + lap - (log_pi_sch + sum_logQ)
                lb = sum_logr - (m - 1) * math.log(n + m - 1) - log_pi_sch
                assert Dl >= lb - 1e-6
                rows[target].append((m, Du, Dl, lb))
        for n in grid:
            r = rows[n]
            mm = sum(x[0] for x in r) / len(r)
            Du = sum(x[1] for x in r) / len(r)
            Dl = sum(x[2] for x in r) / len(r)
            lb = sum(x[3] for x in r) / len(r)
            say('  %7d %8.1f %12.1f %12.1f %12.1f %10.3f %10.4f   (D_l range %.1f..%.1f)'
                % (n, mm, Du, Dl, lb, Dl / math.log(n) ** 2, Dl / n, min(x[2] for x in r), max(x[2] for x in r)))
    open('c3_memo.out', 'w').write('\n'.join(OUT) + '\n')


if __name__ == '__main__':
    main()
