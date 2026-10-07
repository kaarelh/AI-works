"""E1 (Q1): learning a universal axiom  Ax phi(x)  from instances phi(t).

Targets are instance schemas with term metavariables (?t, ?u).  Instances: t a numeral (p=0.6, uniform
0..7), a random closed term (p=0.25) or a parameter (p=0.15; in closure-normal form phi(w) means Ax phi(x)).
Learners: DT°_F cautious verifier (Min of the data) and first-order lgg (Plotkin).  For each run we record
the number of instances N until the learner is exact (acceptance set = inst(target)); 400 runs per target.
Also: numeral-only data (no parameter, no closed terms).
"""
import random
import time
from collections import Counter
from common import save, md_table, pp
from dtrc.syntax import parse, num, P, canon_params
from dtrc.templates import instantiate, equiv, match, geq
from dtrc.mincover import MinCover
from dtrc.baselines import fo_lgg
from dtrc.datasets import rand_closed_term

TARGETS = {
    'x+0=x': parse('?t+0=?t'),
    'x*0=0': parse('?t*0=0'),
    '0+x=x': parse('0+?t=?t'),
    '~Sx=0': parse('~S?t=0'),
    'x<Sx': parse('?t<S?t'),
    'x+y=y+x': parse('?t+?u=?u+?t'),
}


def draw_term(rng, mode):
    if mode == 'numerals':
        return num(rng.randrange(8))
    r = rng.random()
    if r < 0.6:
        return num(rng.randrange(8))
    if r < 0.85:
        return rand_closed_term(rng, 2)
    return P('a%d' % rng.randrange(2))


def fo_to_template(t):
    if t[0] == 'X':
        return ('M', ('P%d' if t[2] == 'F' else 'f%d') % t[1], ())
    if t[0] in ('v', 'p', '0', 'h'):
        return t
    return (t[0],) + tuple(fo_to_template(k) for k in t[1:])


def head(t):
    return t[0]


def run(name, T, mode, runs, Nmax, seed0):
    from dtrc.templates import metas as _metas
    names = sorted(_metas(T))
    n_dt, n_fo, agree = [], [], 0
    for r in range(runs):
        rng = random.Random(seed0 * 1000003 + 7919 * r)
        D = []
        ndt = nfo = None
        for N in range(1, Nmax + 1):
            th = {m: draw_term(rng, mode) for m in names}
            D.append(canon_params(instantiate(T, th)))
            if ndt is None:
                mins = MinCover(D).minimal()
                if len(mins) == 1 and equiv(mins[0], T):
                    ndt = N
            if nfo is None:
                L = fo_to_template(fo_lgg(list(dict.fromkeys(D))))
                if equiv(L, T):
                    nfo = N
            if ndt is not None and nfo is not None:
                break
        n_dt.append(ndt if ndt is not None else Nmax + 1)
        n_fo.append(nfo if nfo is not None else Nmax + 1)
        agree += int(ndt == nfo)
    return n_dt, n_fo, agree


def _occ(T, acc=None):
    if acc is None:
        acc = set()
    if T[0] == 'M':
        acc.add(T)
        return acc
    if T[0] in ('v', 'p', '0', 'h'):
        return acc
    for k in T[1:]:
        _occ(k, acc)
    return acc


def mean(xs):
    return sum(xs) / len(xs)


def pct(xs, q):
    s = sorted(xs)
    return s[min(len(s) - 1, int(q * len(s)))]


HEADS = {'mixed': {'S': 0.6 * 7 / 8 + 0.25 * (0.4 * 0.75 + 0.6 / 3), '0': 0.6 / 8 + 0.25 * 0.4 * 0.25,
                   '+': 0.25 * 0.6 / 3, '*': 0.25 * 0.6 / 3, 'param': 0.15},
         'numerals': {'S': 7 / 8, '0': 1 / 8}}


def predicted_mean(mode, cap):
    """E[min(N_exact, cap+1)] for a one-variable target, from P(not exact after N) = sum_h p_h^N, where
    p_h is the (exact) probability that the substituted term has head symbol h (leaves 0 and the parameter
    count as heads)"""
    ps = list(HEADS[mode].values())
    e = 1.0
    for N in range(1, cap + 1):
        e += sum(p ** N for p in ps)
    return e, {k: round(v, 4) for k, v in HEADS[mode].items()}


def main():
    t0 = time.time()
    RUNS, NMAX = 2000, 40
    rows, data = [], {}
    for mode in ('mixed', 'numerals'):
        for name, T in TARGETS.items():
            n_dt, n_fo, agree = run(name, T, mode, RUNS, NMAX, 1000)
            pred = '%.2f' % predicted_mean(mode, NMAX)[0] if name != 'x+y=y+x' else '-'
            rows.append([mode, name, '%.2f' % mean(n_dt), pct(n_dt, 0.5), pct(n_dt, 0.95), '%.2f' % mean(n_fo),
                         '%d/%d' % (agree, RUNS), pred])
            data[mode + ':' + name] = {'dt': Counter(n_dt), 'fo': Counter(n_fo)}
    # closure-normal acceptance of the Gen form
    gen_rows = []
    for name, T in TARGETS.items():
        D = [canon_params(instantiate(T, {'t': num(0), 'u': num(1)})),
             canon_params(instantiate(T, {'t': num(1), 'u': ('+', num(0), num(0))}))]
        mins = MinCover(D).minimal()
        q = canon_params(instantiate(T, {'t': P('a'), 'u': P('b')}))
        gen_rows.append([name, '; '.join(pp(d) for d in D), ' / '.join(pp(M) for M in mins), pp(q),
                         all(match(M, q) is not None for M in mins)])
    # non-anchor example: same head symbol
    D2 = [parse('S0+0=S0'), parse('SS0+0=SS0'), parse('SSS0+0=SSS0')]
    m2 = MinCover(D2).minimal()
    text = '# E1: universal axioms from instances (Q1)\n\n'
    text += ('Command: `python3 experiments/e1_universal.py`; %d runs per target, run r uses random.Random(1000*1000003 + 7919*r), '
             'N capped at %d (a run that never becomes exact is counted as %d).\n\n' % (RUNS, NMAX, NMAX + 1))
    text += ('Instance distribution *mixed*: numeral (p=0.6, uniform 0..7), random closed term over 0,S,+,* of '
             'depth <= 2 (p=0.25), parameter (p=0.15). *numerals*: numerals only.\n\n')
    text += md_table(['data', 'target', 'DT°_F mean N', 'median', '95%', 'fo-lgg mean N', 'same N (runs)',
                      'predicted mean N'], rows)
    text += ('\nPredicted: E[min(N,41)] from P(not exact after N) = sum_h p_h^N (anchor iff the substituted terms '
             'do not all share a head symbol); head distributions: mixed %s, numerals %s.\n' %
             (predicted_mean('mixed', NMAX)[1], predicted_mean('numerals', NMAX)[1]))
    text += '\n## Closure-normal form: the learned schema accepts the Gen form\n\n'
    text += md_table(['target', 'data', 'Min(D)', 'query (closure = Ax...)', 'accepted'], gen_rows)
    text += '\n## A non-anchor: all substituted terms have head S\n\n'
    text += 'D = %s ; Min(D) = %s ; accepts 0+0=0: %s\n' % (
        ', '.join(pp(d) for d in D2), ' / '.join(pp(M) for M in m2),
        all(match(M, parse('0+0=0')) is not None for M in m2))
    text += '\nWall time: %.1fs\n' % (time.time() - t0)
    save('e1_universal', text, data)
    print(text)


if __name__ == '__main__':
    main()
