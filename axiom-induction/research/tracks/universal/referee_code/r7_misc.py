"""Referee check r7: miscellaneous independent checks.

 (1) U4(4): P_tau(I) <= pbar = max_f Q(root = f) for random first-order generalisations tau of sigma_phi
     (term metavariables only), by Monte Carlo with own matcher; numeral and Galton-Watson laws.
 (2) U6(i): the bracket for uniform-weight memorisers, by exhaustive enumeration over subsets of a small universe.
 (3) U11(c): closed forms in C_open for H_forall, H_open, guarded H_sch and a mixture, against an own sampler.
 (4) U8 / c4: the summed-miss value 4.22 for Laplace with a point mass (closed form), bound ln(1/pi0) = 4.61.
Seeded.  Output: r7_misc.out"""
import itertools
import math
import random
from collections import Counter

OUT = []


def say(s=''):
    print(s)
    OUT.append(s)


# ------------------------------------------------------------------ (1) U4(4)
class Num:
    def __init__(self, q):
        self.q = q

    def sample(self, rng):
        t = ('0',)
        while rng.random() < self.q:
            t = ('S', t)
        return t

    def pbar(self):
        return max(self.q, 1 - self.q)


class GW:
    p = {'0': 0.4, 'S': 0.3, '+': 0.2, '*': 0.1}

    def sample(self, rng, budget=None):
        if budget is None:
            budget = [300]
        budget[0] -= 1
        if budget[0] < 0:
            raise OverflowError
        u, acc = rng.random(), 0.0
        for h, ph in self.p.items():
            acc += ph
            if u < acc:
                break
        if h == '0':
            return ('0',)
        if h == 'S':
            return ('S', self.sample(rng, budget))
        return (h, self.sample(rng, budget), self.sample(rng, budget))

    def safe(self, rng):
        while True:
            try:
                return self.sample(rng)
            except OverflowError:
                pass

    def pbar(self):
        return max(self.p.values())


def inst(t, th):
    if t[0] == 'mv':
        return th[t[1]]
    return (t[0],) + tuple(inst(k, th) if isinstance(k, tuple) else k for k in t[1:])


def mvs(t, acc=None):
    acc = set() if acc is None else acc
    if t[0] == 'mv':
        acc.add(t[1])
    for k in t[1:]:
        if isinstance(k, tuple):
            mvs(k, acc)
    return acc


def subterm_positions(t, path=()):
    if path:
        yield path, t
    for i, k in enumerate(t[1:], 1):
        if isinstance(k, tuple):
            yield from subterm_positions(k, path + (i,))


def at(t, path):
    for i in path:
        t = t[i]
    return t


def replace(t, path, new):
    if not path:
        return new
    i = path[0]
    return t[:i] + (replace(t[i], path[1:], new),) + t[i + 1:]


def z_path(sig):
    for p, s in subterm_positions(sig):
        if s == ('mv', 'z'):
            return p


def is_instance(sig, f):
    """f is sigma[z := t] for some closed t (own matcher via the first z position)"""
    p = z_path(sig)
    try:
        t = at(f, p)
    except (IndexError, TypeError):
        return False
    return inst(sig, {'z': t}) == f


def rand_generalisation(sig, rng):
    """replace 1-3 random positions (disjoint) by fresh metavariables, sometimes sharing one fresh metavariable
    between positions with equal subterms; keep only strictly more general tau (not a renaming)"""
    tau = sig
    pos = [p for p, _ in subterm_positions(sig)]
    rng.shuffle(pos)
    chosen = []
    for p in pos:
        if any(p[:len(c)] == c or c[:len(p)] == p for c in chosen):
            continue
        chosen.append(p)
        if len(chosen) >= rng.randint(1, 3):
            break
    fresh = {}
    for i, p in enumerate(chosen):
        sub = at(sig, p)
        key = sub if rng.random() < 0.5 else ('uniq', i)
        if key not in fresh:
            fresh[key] = ('mv', 'u%d' % len(fresh))
        tau = replace(tau, p, fresh[key])
    return tau


def renaming_equiv(a, b):
    # crude: compare after renaming metavariables in order of first occurrence
    def canon(t, m):
        if t[0] == 'mv':
            if t[1] not in m:
                m[t[1]] = 'm%d' % len(m)
            return ('mv', m[t[1]])
        return (t[0],) + tuple(canon(k, m) if isinstance(k, tuple) else k for k in t[1:])
    return canon(a, {}) == canon(b, {})


def check_u4():
    z = ('mv', 'z')
    sigs = {
        '0+x=x': ('=', ('+', ('0',), z), z),
        'x<Sx': ('<', z, ('S', z)),
        'x+x=x*SS0': ('=', ('+', z, z), ('*', z, ('S', ('S', ('0',))))),
        'S(x+0)=S0+x': ('=', ('S', ('+', z, ('0',))), ('+', ('S', ('0',)), z)),
    }
    rng = random.Random(404)
    worst = -1.0
    ntested = 0
    for lawname, law in [('numerals q=1/2', Num(0.5)), ('numerals q=0.8', Num(0.8)), ('GW', GW())]:
        samp = law.safe if isinstance(law, GW) else law.sample
        for name, sig in sigs.items():
            seen = []
            for _ in range(40):
                tau = rand_generalisation(sig, rng)
                if renaming_equiv(tau, sig) or any(renaming_equiv(tau, s) for s in seen):
                    continue
                # tau must generalise sig: sig = tau rho  -- true by construction (replaced subterms)
                seen.append(tau)
                M = 20000
                hits = 0
                for _ in range(M):
                    th = {m: samp(rng) for m in mvs(tau)}
                    if is_instance(sig, inst(tau, th)):
                        hits += 1
                p = hits / M
                se = math.sqrt(max(p * (1 - p), 1e-9) / M)
                ntested += 1
                worst = max(worst, (p - law.pbar()) / se)
    return ntested, worst


# ------------------------------------------------------------------ (2) U6(i) bracket
def check_u6_bracket():
    rng = random.Random(66)
    U = 7
    worst_ratio_lo, worst_ratio_hi = float('inf'), 0.0
    for trial in range(200):
        r = [rng.uniform(0.01, 0.6) for _ in range(U)]
        Z0 = math.prod(1 - x for x in r)
        m = rng.randint(1, 4)
        S = rng.sample(range(U), m)
        n = rng.randint(1, 12)
        data = [rng.choice(S) for _ in range(n)]
        data[:m] = S  # every element of S occurs
        tot = 0.0
        others = [i for i in range(U) if i not in S]
        for k in range(len(others) + 1):
            for G in itertools.combinations(others, k):
                F = set(S) | set(G)
                piF = math.prod(r[i] if i in F else 1 - r[i] for i in range(U))
                tot += piF * len(F) ** (-len(data))
        lo = Z0 * math.prod(r[i] for i in S) * m ** (-len(data))
        hi = math.prod(r[i] for i in S) * m ** (-len(data))
        worst_ratio_lo = min(worst_ratio_lo, tot / lo)
        worst_ratio_hi = max(worst_ratio_hi, tot / hi)
    return worst_ratio_lo, worst_ratio_hi


# ------------------------------------------------------------------ (3) U11(c) closed forms
c, g, rho, q = 0.3, 0.2, 0.1, 0.5
K = 1 - c - g


def forms(wa, wo, ws, k):
    a = K * (wa + g * rho * wo) / (1 - g * c * rho)
    bp = rho * (K * wo + c * a)
    bcl = (1 - q) * q ** k * ((1 - rho) * (K * wo + c * a) + K * ws)
    Z = a * (1 + c) + K * (wo + ws)
    return a, bp, bcl, Z


def qc(rng):
    k = 0
    while rng.random() < q:
        k += 1
    return ('n', k)


def qo(rng):
    return ('w',) if rng.random() < rho else qc(rng)


def sample_open(theory, rng, depth=0):
    """theory: list of (kind, weight), kind in {'all', 'open', 'sch'}.  Formulas: ('ALL',), ('I', term)."""
    if depth > 500:
        return None
    u = rng.random()
    if u < K:
        x, acc = rng.random(), 0.0
        for kind, wgt in theory:
            acc += wgt
            if x < acc:
                break
        if kind == 'all':
            return ('ALL',)
        return ('I', qo(rng) if kind == 'open' else qc(rng))
    p = sample_open(theory, rng, depth + 1)
    if p is None:
        return None
    if u < K + c:
        return ('I', qo(rng)) if p == ('ALL',) else None
    return ('ALL',) if p[0] == 'I' and p[1] == ('w',) else None


def check_u11c():
    rng = random.Random(1111)
    N = 300000
    worst = 0.0
    rows = []
    for lab, th, wts in [('H_forall', [('all', 1.0)], (1, 0, 0)), ('H_open', [('open', 1.0)], (0, 1, 0)),
                         ('H_sch', [('sch', 1.0)], (0, 0, 1)),
                         ('mix .3/.3/.4', [('all', .3), ('open', .3), ('sch', .4)], (.3, .3, .4))]:
        cnt = Counter(sample_open(th, rng) for _ in range(N))
        fails = cnt.pop(None, 0)
        a, bp, _, Z = forms(*wts, 0)
        zs = []
        for obs, p in [((N - fails) / N, Z), (cnt[('ALL',)] / N, a), (cnt[('I', ('w',))] / N, bp)] + \
                [(cnt[('I', ('n', k))] / N, forms(*wts, k)[2]) for k in range(4)]:
            if p > 0:
                zs.append((obs - p) / math.sqrt(p * (1 - p) / N))
            else:
                zs.append(0.0 if obs == 0 else float('inf'))
        worst = max(worst, max(abs(x) for x in zs))
        rows.append('  %-13s z-scores (success, Ax phi, phi(w0), phi(0..3)): %s' % (lab, ' '.join('%+.2f' % x for x in zs)))
    # normalised ratios per closed datum
    f = {nm: forms(*w, 2) for nm, w in [('all', (1, 0, 0)), ('open', (0, 1, 0)), ('sch', (0, 0, 1))]}
    r = {k: f[k][2] / f[k][3] for k in f}
    rows.append('  normalised per-closed-datum ratios: forall/sch %.4f (c(1-rho)/(1+c) = %.4f); open/sch %.4f '
                '((1-rho)/(1+g rho) = %.4f); forall/open %.4f (c(1+g rho)/(1+c) = %.4f)'
                % (r['all'] / r['sch'], c * (1 - rho) / (1 + c), r['open'] / r['sch'], (1 - rho) / (1 + g * rho),
                   r['all'] / r['open'], c * (1 + g * rho) / (1 + c)))
    return rows, worst


def main():
    n, worst = check_u4()
    say('(1) U4(4): %d random strict generalisations x 3 laws; max (P_tau(I) - pbar)/se = %.1f (negative: bound holds)'
        % (n, worst))
    lo, hi = check_u6_bracket()
    say('(2) U6(i) bracket, 200 random small universes: min (sum / lower bracket) = %.4f (>= 1), '
        'max (sum / upper bracket) = %.4f (<= 1)' % (lo, hi))
    assert lo >= 1 - 1e-12 and hi <= 1 + 1e-12
    rows, w = check_u11c()
    say('(3) U11(c) closed forms against an own sampler of C_open (300000 derivations per theory):')
    for r in rows:
        say(r)
    say('  max |z| = %.2f' % w)
    pi0 = 0.01
    tot = sum((1 - pi0) / ((n + 1) * (n + 2)) / (pi0 + (1 - pi0) / (n + 1)) for n in range(10 ** 6))
    say('(4) U8 summed misses, Laplace with point mass pi0 = 0.01: %.4f (notes: 4.22); ln(1/pi0) = %.4f'
        % (tot, math.log(1 / pi0)))
    open('r7_misc.out', 'w').write('\n'.join(OUT) + '\n')


if __name__ == '__main__':
    main()
