# c5_euler.py -- a false generalisation that positive data favour (track "pa", notes.md section 5).
# Data: true sentences Prime(k*k + k + 41) with unary numerals, k ~ Geometric(rho) conditioned on k^2+k+41 being
# prime (so k = 40, 41, 44, 49, ... never occur).  Hypotheses (L0 citation likelihood, template prior 5 bits/symbol):
#   H_sch  the template Prime(z*z + z + 41) with a term metavariable z: FALSE (instance z := 40 is false);
#   H_mem  one ground axiom per distinct observed datum: TRUE.
# (No finite union of unguarded templates covering these data is true without memorising: k = 41j makes
# k^2+k+41 divisible by 41, so false instances recur.)  The numeral z is coded by a sequential KT grammar with
#   'flat'   one context for every symbol of the numeral (a geometric family), or
#   'depth'  context = depth below the occurrence (the positional grammar of c4; a nonparametric hazard model).
# Output: L(H_mem) - L(H_sch) (positive: the posterior prefers the false schema), and the predictive probability that
# H_sch's grammar gives to the false instance k = 40.  Seeded; output in c5_euler.out.
import math, random

def isprime(m):
    if m < 2: return False
    i = 2
    while i * i <= m:
        if m % i == 0: return False
        i += 1
    return True

TRUE_K = [k for k in range(2000) if isprime(k * k + k + 41)]
FALSE_K = [k for k in range(200) if not isprime(k * k + k + 41)]

# Sizes are measured on syntax trees with nd.size (a quantifier and its variable count 2), not by hand.  The first
# version counted m twice; it occurs three times in Prime(m) (referee issue m9), and the frame was miscounted.
from functools import lru_cache
import nd
def num(k):
    t = nd.Z
    for _ in range(k): t = nd.S(t)
    return t
def prime_of(m):
    a, b = nd.V('a'), nd.V('b')
    return nd.AND(nd.NOT(nd.eq(m, nd.Z)),
                  nd.AND(nd.NOT(nd.eq(m, nd.S(nd.Z))),
                         nd.ALL('a', nd.ALL('b', nd.IMP(nd.eq(nd.mul(a, b), m),
                                                        nd.OR(nd.eq(a, nd.S(nd.Z)), nd.eq(b, nd.S(nd.Z))))))))
def euler_term(t):
    return nd.add(nd.add(nd.mul(t, t), t), num(41))
@lru_cache(maxsize=None)
def datum_size(k):
    return nd.size(prime_of(euler_term(num(k))))
TEMPLATE_SIZE = nd.size(prime_of(euler_term(nd.V('z'))))     # z: one symbol per occurrence (9 occurrences)
FRAME = nd.size(prime_of(nd.Z)) - 3                          # logical frame without the three copies of m
assert datum_size(0) == FRAME + 3 * nd.size(euler_term(num(0)))

class KT:
    def __init__(self, a=2): self.c = {}; self.a = a
    def cost(self, ctx, s):
        d = self.c.setdefault(ctx, [0, 0])
        p = (d[s] + 0.5) / (d[0] + d[1] + 0.5 * self.a)
        d[s] += 1
        return -math.log2(p)
    def prob(self, ctx, s):
        d = self.c.get(ctx, [0, 0])
        return (d[s] + 0.5) / (d[0] + d[1] + 0.5 * self.a)

def numeral_bits(k, model, mode):
    # unary numeral S^k 0: symbol 1 = 'S', 0 = '0'; (a two-letter alphabet suffices: z ranges over numerals here)
    b = 0.0
    for d in range(k + 1):
        ctx = 'all' if mode == 'flat' else d
        b += model.cost(ctx, 1 if d < k else 0)
    return b

def p_numeral(k, model, mode):
    p = 1.0
    for d in range(k + 1):
        ctx = 'all' if mode == 'flat' else d
        p *= model.prob(ctx, 1 if d < k else 0)
    return p

def run(rho, n_max, seed):
    rng = random.Random(seed)
    def draw():
        while True:
            k = int(math.log(1 - rng.random()) / math.log(rho))
            if isprime(k * k + k + 41): return k
    models = {'flat': KT(), 'depth': KT()}
    Lsch = {'flat': 5 * TEMPLATE_SIZE, 'depth': 5 * TEMPLATE_SIZE}
    idx_counts = {}
    Lmem_data = 0.0
    Lmem_prior = 0.0
    rows = []
    cps = {10 ** j for j in range(2, 7)} | {3 * 10 ** j for j in range(2, 6)}
    seen = []
    for t in range(1, n_max + 1):
        k = draw()
        for mode in models:
            Lsch[mode] += numeral_bits(k, models[mode], mode)
        if k not in idx_counts:
            idx_counts[k] = 0; seen.append(k)
            Lmem_prior += 5 * datum_size(k)
        idx_counts[k] += 1
        if t in cps:
            # KT over the m distinct memorised axioms, in hindsight (the hypothesis lists them)
            m = len(idx_counts)
            lg = math.lgamma
            Lmem_data = -(lg(m * 0.5) - lg(t + m * 0.5) + sum(lg(c + 0.5) - lg(0.5) for c in idx_counts.values())) / math.log(2)
            Lmem = Lmem_prior + Lmem_data
            rows.append((t, m, Lmem - Lsch['flat'], Lmem - Lsch['depth'],
                         p_numeral(40, models['flat'], 'flat'), p_numeral(40, models['depth'], 'depth')))
    return rows

if __name__ == '__main__':
    out = []
    def say(x=''):
        print(x, flush=True); out.append(x)
    say('false k in [0,200): %s ...' % FALSE_K[:12])
    say('sizes (nd.size): frame %d symbols, m occurs 3 times; |datum(k)| = %d + 3*(3(k+1)+45); |template| = %d'
        % (FRAME, FRAME, TEMPLATE_SIZE))
    for rho, seed in ((0.9, 5), (0.97, 6)):
        mass_false = sum((1 - rho) * rho ** k for k in FALSE_K)
        say('rho=%.2f: mass of the false instances under the unconditioned geometric law: %.4f' % (rho, mass_false))
        say('  %8s %5s %16s %16s %14s %14s' % ('n', 'm', 'Lmem-Lsch flat', 'Lmem-Lsch depth', 'P_flat(k=40)',
                                               'P_depth(k=40)'))
        for t, m, df, dd, pf, pd in run(rho, 10 ** 6, seed):
            say('  %8d %5d %16.0f %16.0f %14.2e %14.2e' % (t, m, df, dd, pf, pd))
    say('Positive differences: the posterior prefers the FALSE schema (by that many bits of log-odds).')
    open('c5_euler.out', 'w').write('\n'.join(out) + '\n')
