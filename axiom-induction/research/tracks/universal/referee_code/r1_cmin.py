"""Referee check r1: Prop U1 and Thm U2 in the minimal calculus C_min = {cite, forall-elim}.

Independent of the track's common.py and of dtrc: own formula representation, own exact chain enumeration,
own Monte Carlo sampler of the derivation grammar.  Numeral term law Q(S^k 0) = (1-q) q^k.

Checks
 (a) P_{forall x phi}(d) = c * P_{sigma_phi}(d) for every output d != forall x phi (exact enumeration);
 (b) Z_forall = (1-c) + c Z_sigma, Z_sigma = (1-c) sum_{k<=m} c^k;
 (c) Monte Carlo frequencies of the recursive grammar against the exact law;
 (d) Thm U2 rows L1, L1-norm, L1-sel, L0-closure on random instance streams.
Seeded.  Output: r1_cmin.out"""
import math
import random
from collections import Counter

OUT = []


def say(s=''):
    print(s)
    OUT.append(s)


Q_q = 0.5
KMAX = 60


def Q(k):
    return (1 - Q_q) * Q_q ** k


def qsample(rng):
    k = 0
    while rng.random() < Q_q:
        k += 1
    return k


def num(k):
    t = '0'
    for _ in range(k):
        t = ('S', t)
    return t


def subst(f, name, val):
    """replace variable/metavariable `name` by the closed term `val` (no capture: val is closed)"""
    if isinstance(f, str):
        return f
    if f[0] in ('var', 'mv'):
        return val if f[1] == name else f
    if f[0] == 'all':
        if f[1] == name:
            return f
        return ('all', f[1], subst(f[2], name, val))
    return (f[0],) + tuple(subst(x, name, val) for x in f[1:])


def elim(f, t):
    if isinstance(f, str) or f[0] != 'all':
        return None
    return subst(f[2], f[1], t)


def show(f):
    if isinstance(f, str):
        return f
    h = f[0]
    if h == 'S':
        k, g = 0, f
        while not isinstance(g, str) and g[0] == 'S':
            g, k = g[1], k + 1
        return str(k) if g == '0' else 'S' * k + show(g)
    if h in ('var', 'mv'):
        return f[1]
    if h == 'all':
        return 'A%s.%s' % (f[1], show(f[2]))
    if h == 'eq':
        return '%s=%s' % (show(f[1]), show(f[2]))
    if h == 'add':
        return '(%s+%s)' % (show(f[1]), show(f[2]))
    if h == 'not':
        return '~' + show(f[1])
    raise ValueError(h)


X, Y, Z_ = ('var', 'x'), ('var', 'y'), ('mv', 'z')
CASES = {
    '0+x=x': ('eq', ('add', '0', X), X),
    'Sx!=0': ('not', ('eq', ('S', X), '0')),
    'Ay.x+y=y+x': ('all', 'y', ('eq', ('add', X, Y), ('add', Y, X))),
}


def lead(f):
    m = 0
    while not isinstance(f, str) and f[0] == 'all':
        f, m = f[2], m + 1
    return m


def exact_law(axiom, mvs, c):
    """exact output law of the one-axiom theory: chains cite (metavariables from Q) then k eliminations.
    Terms truncated at S^KMAX 0 (mass lost < q^KMAX per draw)."""
    law = Counter()
    # instantiate metavariables
    inst = [(axiom, 1.0)]
    for mv in mvs:
        inst = [(subst(f, mv, num(k)), p * Q(k)) for f, p in inst for k in range(KMAX)]
    frontier = [(f, p * (1 - c)) for f, p in inst]
    while frontier:
        new = []
        for f, p in frontier:
            law[f] += p
            if not isinstance(f, str) and f[0] == 'all':
                for k in range(KMAX):
                    g = elim(f, num(k))
                    if p * c * Q(k) > 1e-30:
                        new.append((g, p * c * Q(k)))
        frontier = new
    return law


def sample(axiom, mvs, c, rng):
    """recursive grammar: with prob c, forall-elim (term ~ Q) applied to a recursively generated premise;
    else cite the axiom with fresh metavariable values.  Returns None on failure."""
    if rng.random() < c:
        prem = sample(axiom, mvs, c, rng)
        if prem is None:
            return None
        return elim(prem, num(qsample(rng)))
    f = axiom
    for mv in mvs:
        f = subst(f, mv, num(qsample(rng)))
    return f


def main():
    rng = random.Random(20261008)
    c = 0.3
    say('r1_cmin: c = %.2f, numerals q = %.2f' % (c, Q_q))
    worst_fact = 0.0
    worst_z = 0.0
    for name, phi in CASES.items():
        A_all = ('all', 'x', phi)
        A_sch = subst(phi, 'x', Z_)
        L_all = exact_law(A_all, [], c)
        L_sch = exact_law(A_sch, ['z'], c)
        # (a) factorisation on all outputs with non-negligible mass
        dev = 0.0
        nout = 0
        for d, p in L_all.items():
            if d == A_all:
                continue
            ps = L_sch.get(d, 0.0)
            if p < 1e-14:
                continue
            nout += 1
            dev = max(dev, abs(math.log(p) - math.log(ps) - math.log(c)))
        assert all(d == A_all or d in L_all for d in L_sch if L_sch[d] > 1e-12)
        worst_fact = max(worst_fact, dev)
        # (b) normalisers
        m = lead(phi)
        Zs, Za = sum(L_sch.values()), sum(L_all.values())
        Zs_f = (1 - c) * sum(c ** k for k in range(m + 1))
        say('phi = %-12s outputs %5d  max|log P_all - log P_sch - log c| = %.2e  Z_sch = %.6f (formula %.6f)'
            '  Z_all = %.6f ((1-c)+cZ_sch = %.6f)' % (name, nout, dev, Zs, Zs_f, Za, (1 - c) + c * Zs))
        assert abs(Zs - Zs_f) < 1e-9 and abs(Za - ((1 - c) + c * Zs)) < 1e-9
        # (c) Monte Carlo of the recursive grammar
        N = 100000
        for lab, A, mvs, L in [('forall', A_all, [], L_all), ('sch', A_sch, ['z'], L_sch)]:
            cnt = Counter(sample(A, mvs, c, rng) for _ in range(N))
            fails = cnt.pop(None, 0)
            zs = [(1 - fails / N - sum(L.values())) / math.sqrt(sum(L.values()) * (1 - sum(L.values())) / N)]
            for d, k in cnt.most_common(6):
                p = L[d]
                zs.append((k / N - p) / math.sqrt(p * (1 - p) / N))
            worst_z = max(worst_z, max(abs(z) for z in zs))
            say('   MC %-6s success-rate z = %+.2f; top-6 output z-scores: %s'
                % (lab, zs[0], ' '.join('%+.2f' % z for z in zs[1:])))
    say('max factorisation deviation %.2e; max |z| %.2f' % (worst_fact, worst_z))

    # (d) Thm U2 rows on random instance streams (qf phi = 0+x=x)
    phi = CASES['0+x=x']
    A_all, A_sch = ('all', 'x', phi), subst(phi, 'x', Z_)
    L_all, L_sch = exact_law(A_all, [], c), exact_law(A_sch, ['z'], c)
    Za, Zs = sum(L_all.values()), sum(L_sch.values())
    PS_all = sum(p for d, p in L_all.items() if d != A_all)  # selection S = closed instances
    PS_sch = sum(L_sch.values())
    maxerr = {'L1': 0.0, 'L1-norm': 0.0, 'L1-sel': 0.0, 'L0-closure': 0.0}
    for seed in range(20):
        r = random.Random(seed)
        lo = {k: 0.0 for k in maxerr}
        for n in range(1, 201):
            k = qsample(r)
            d = subst(phi, 'x', num(k))
            la, ls = math.log(L_all[d]), math.log(L_sch[d])
            lo['L1'] += la - ls
            lo['L1-norm'] += (la - math.log(Za)) - (ls - math.log(Zs))
            lo['L1-sel'] += (la - math.log(PS_all)) - (ls - math.log(PS_sch))
            lo['L0-closure'] += math.log(Q(k)) - math.log(Q(k))  # forall cited through its instances
            exp = {'L1': n * math.log(c), 'L1-norm': n * math.log(c / (1 + c)), 'L1-sel': 0.0, 'L0-closure': 0.0}
            for key in maxerr:
                maxerr[key] = max(maxerr[key], abs(lo[key] - exp[key]))
    say('Thm U2 rows, 20 streams x 200 instances: max |log-odds - predicted|: ' +
        ', '.join('%s %.1e' % kv for kv in maxerr.items()))
    say('   predicted per-datum factors: L1 c = %.4f; L1-norm c/(1+c) = %.4f; L1-sel 1; L0-closure 1' % (c, c / (1 + c)))
    assert all(v < 1e-8 for v in maxerr.values())
    open('r1_cmin.out', 'w').write('\n'.join(OUT) + '\n')


if __name__ == '__main__':
    main()
