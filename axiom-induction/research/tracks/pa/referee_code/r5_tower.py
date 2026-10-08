# r5_tower.py -- referee for track "pa", section 3 toy tower (c3_tower.py).  Independent re-implementation in log
# space (log-sum-exp throughout), same model, same draws.  Also reports the posterior mass on levels above the largest
# level seen, which the track does not report.  Output: r5_tower.out next to this script.
import math, random, os
HERE = os.path.dirname(os.path.abspath(__file__))

def lse(xs):
    m = max(xs)
    return m + math.log(sum(math.exp(x - m) for x in xs))

def run(rho, s, b, eps, nmax, K=400, seed=1):
    rng = random.Random(seed)
    logpost = [-(b * (k + 1)) * math.log(2) for k in range(K + 1)]
    def ll(k, l):
        p = (1 - s) * s ** l / (1 - s ** (k + 1)) if l <= k else 0.0
        if eps: p = (1 - eps) * p + eps * 0.5 ** (l + 1)
        return math.log(p) if p > 0 else -math.inf
    reg, maxl, rows = 0.0, 0, {}
    for t in range(1, nmax + 1):
        l = int(math.log(1 - rng.random()) / math.log(rho))
        maxl = max(maxl, l)
        terms = [lp + ll(k, l) for k, lp in enumerate(logpost)]
        finite = [x for x in terms if x > -math.inf]
        lpred = lse(finite) - lse(logpost)
        reg += (-lpred - (-math.log((1 - rho) * rho ** l))) / math.log(2)
        logpost = terms
        if t in (10, 100, 1000, 10000, 100000):
            fin = [(k, x) for k, x in enumerate(logpost) if x > -math.inf]
            Z = lse([x for _, x in fin])
            kmap = max(fin, key=lambda kx: kx[1])[0]
            unprov = sum(math.exp(x - Z) * rho ** (k + 1) for k, x in fin)
            above = sum(math.exp(x - Z) for k, x in fin if k > maxl)
            rows[t] = (maxl, kmap, unprov, reg, above)
    return rows

out = []
for rho, s, b, eps in ((0.5, 0.5, 50, 0.0), (0.5, 0.5, 50, 0.01), (0.8, 0.8, 50, 0.0), (0.5, 0.3, 50, 0.0)):
    out.append('rho=%.2f s=%.2f b=%d eps=%.2f:   n  maxlvl  MAP  P(next unprov)  regret  P(level > max seen)'
               % (rho, s, b, eps))
    for t, (ml, km, up, rg, ab) in run(rho, s, b, eps, 10 ** 5).items():
        out.append('   %7d %6d %5d %12.2e %9.1f %12.2e' % (t, ml, km, up, rg, ab))
open(os.path.join(HERE, 'r5_tower.out'), 'w').write('\n'.join(out) + '\n')
print('\n'.join(out))
