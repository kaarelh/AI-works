# c3_tower.py -- a toy model of the posterior on data from a truth set that no hypothesis generates
# (track "pa", notes.md section 3).  Seeded; output in c3_tower.out.
#
# Abstraction.  Each datum has a "level" l >= 0: the least k such that T_k proves it, where T_0 = PA and
# T_{k+1} = T_k + Con(T_k) (any progression of sound theories will do).  Real data from Th(N) also contain sentences
# outside every T_k; the toy ignores them (they would only add exceptions).  Data: i.i.d. levels with
#   P*(l) = (1 - rho) rho^l                      (no T_k proves all levels: no hypothesis is well specified)
# Hypotheses T_k, k = 0..K, prior pi(T_k) proportional to 2^(-b (k+1))  (b bits per added Con-sentence: in DT^o a
# reflection schema is not a template, since quoting a formula is not a substitution, so each step up is a new
# ground sentence).  Likelihoods:
#   L1 (0/1 support with size principle):  P_k(l) = (1-s) s^l / (1 - s^(k+1)) for l <= k, else 0
#   L_eps (Haenni's "may also not contradict"): (1-eps) P_k(l) + eps * mu0(l), mu0(l) = (1/2)^(l+1)
# Reported: MAP level, the posterior probability that the next datum is provable by the theory (mass-weighted),
# and the cumulative log-loss regret of the Bayes mixture against P*.
import math, random

def run(rho, s, b, eps, n_max, K=400, seed=1):
    rng = random.Random(seed)
    logw = [-(b * (k + 1)) * math.log(2) for k in range(K + 1)]
    lz = max(logw); logw = [x - lz for x in logw]
    def lp_k(k, l):
        if l <= k:
            p = (1 - s) * s ** l / (1 - s ** (k + 1))
        else:
            p = 0.0
        if eps > 0:
            p = (1 - eps) * p + eps * 0.5 ** (l + 1)
        return math.log(p) if p > 0 else -math.inf
    regret = 0.0
    checkpoints = {10 ** j for j in range(1, 7) if 10 ** j <= n_max}
    rows = []
    maxl = 0
    for t in range(1, n_max + 1):
        u = rng.random()
        l = int(math.log(1 - u) / math.log(rho))          # geometric level
        maxl = max(maxl, l)
        m = max(logw)
        Z = sum(math.exp(x - m) for x in logw)
        pred = sum(math.exp(logw[k] - m) * math.exp(lp_k(k, l)) for k in range(K + 1) if lp_k(k, l) > -math.inf) / Z
        regret += -math.log2(pred) - (-math.log2((1 - rho) * rho ** l))
        logw = [logw[k] + lp_k(k, l) for k in range(K + 1)]
        if t in checkpoints:
            m = max(logw)
            w = [math.exp(x - m) for x in logw]
            Zw = sum(w)
            kmap = max(range(K + 1), key=lambda k: logw[k])
            # posterior probability that a fresh datum is provable by the theory (under P*)
            cover = sum(w[k] / Zw * (1 - rho ** (k + 1)) for k in range(K + 1))
            rows.append((t, maxl, kmap, 1 - cover, regret))
    return rows

if __name__ == '__main__':
    out = []
    def say(x=''):
        print(x); out.append(x)
    say('toy tower: levels ~ Geometric(rho); hypotheses T_k with prior 2^(-b(k+1)); seed 1')
    for rho, s, b, eps in ((0.5, 0.5, 50, 0.0), (0.5, 0.5, 50, 0.01), (0.8, 0.8, 50, 0.0), (0.5, 0.3, 50, 0.0)):
        say('rho=%.2f  s=%.2f  b=%d bits  eps=%.2f' % (rho, s, b, eps))
        say('  %8s %6s %6s %14s %12s %10s' % ('n', 'maxlvl', 'MAP k', 'P(next unprov)', 'regret bits', 'regret/n'))
        for t, ml, km, unp, reg in run(rho, s, b, eps, 10 ** 5):
            say('  %8d %6d %6d %14.2e %12.1f %10.4f' % (t, ml, km, unp, reg, reg / t))
    say('Reading: the MAP level tracks the largest level seen (logarithmic drift); the probability that the next')
    say('datum is unprovable by the posterior theory decays like 1/n; the regret grows like b*log n/log(1/rho)')
    say('when s = rho, and linearly when the theories\' own level law s differs from rho (misspecification).')
    open('c3_tower.out', 'w').write('\n'.join(out) + '\n')
