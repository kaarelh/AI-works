"""Referee check R2: is E2's "early unsound lumping" (Q-lumped or skel4 with posterior >= 0.997 in 3 of 5 seeds at
some n <= 32) an artefact of the candidate pool?

The E2 pool contains T* minus ONE Q axiom (7 theories) and data-derived DTRC/skeleton theories built from the
first 16 or 40 data, but not the obvious sound sub-theory SeenQ(D_n) = {Q axioms occurring in D_n} + T_Ind, which,
like Mem(D_n), depends only on the data seen so far.  This script
  1. regenerates the E2 data streams with the track's generator (same seeds),
  2. recomputes the track's pool posterior with the track's pipeline (bai.posterior.evaluate),
  3. scores SeenQ(D_n) and Q-lumped INDEPENDENTLY (ref_core: own matcher, own Q, own prior code, own Dirichlet sum),
     cross-checks the Q-lumped score against the track's value,
  4. reports, per seed and n, the posterior of Q-lumped, of all unsound theories, and the false-probe acceptance
     at delta = 0.05, without and with SeenQ(D_n) added to the pool.
Seeds 0-4 (the track's) and 5-24 (new).  Command: python3 r2_e2_seenq.py  (writes r2_e2_seenq.out)
"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
EXP = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..', 'code', 'experiments'))
sys.path.insert(0, EXP)
import common  # noqa: E402,F401
from pa_common import build_pa_pool, t_star, W_TRUE, QSENT, pa_heldout  # noqa: E402
from bai.grammar import Grammar  # noqa: E402
from bai.gens import cite_data  # noqa: E402
from bai.posterior import evaluate, Deriver  # noqa: E402
from dtrc.schemas import T_IND  # noqa: E402
from dtrc.templates import canon  # noqa: E402
import ref_core as R  # noqa: E402

LN2 = math.log(2)
NS = [8, 16, 32, 64]
OUT = []


def log(*a):
    s = ' '.join(str(x) for x in a)
    print(s, flush=True)
    OUT.append(s)


q = R.Q()
LUMP = [R.parse('forall x. forall y. ?P(x, y)'), R.parse('forall x. ?P(x)'), T_IND]


def own_score(temps, data):
    """ln prior (2^-bits) + ln Dirichlet(1/2) marginal under L0, all components closed-guard"""
    coefs = []
    for d in data:
        c = {}
        for i, T in enumerate(temps):
            v = R.l0(T, {}, d, q)
            if v != R.NEG:
                c[i] = v
        coefs.append(c)
    return -R.theory_bits(temps) * LN2 + R.dir_marg(coefs, len(temps), 0.5)


def seenq(data):
    seen = []
    for d in data:
        if d in QSENT and d not in seen:
            seen.append(d)
    return seen + [T_IND], len(seen)


def run(seed):
    Q = Grammar()
    data = cite_data(t_star(), W_TRUE, Q, max(NS), seed)
    pool = build_pa_pool(data, seed)
    res_all = evaluate(pool, data, NS, 'L0', Q=Q, alpha=0.5)
    der = Deriver(K=0, Q=Q)
    _, false = pa_heldout(Q, seed)
    unsound = {th.name for th in pool if th.tags.get('sound') is False}
    rows = []
    for n, res in zip(NS, res_all):
        D = data[:n]
        sq, k = seenq(D)
        s_sq = own_score(sq, D)
        # SeenQ may coincide with a pool theory (e.g. DTRC(n=16) or T*-Qi); then it is already in the pool and
        # must not be added twice
        key_sq = frozenset(canon(T) for T in sq)
        dup = [th.name for th in pool if frozenset(c.T for c in th.comps) == key_sq]
        s_lump = own_score(LUMP, D)
        s_lump_track = res['Q-lumped']['lp'] + res['Q-lumped']['lm']
        scores = {name: v['lp'] + v['lm'] for name, v in res.items() if not name.startswith('_')}
        z0 = R.lse(list(scores.values()))
        if dup:
            s_sq = R.NEG          # already in the pool under the name dup[0]
        z1 = R.lse(list(scores.values()) + [s_sq])
        post0 = {kk: math.exp(v - z0) for kk, v in scores.items()}
        post1 = {kk: math.exp(v - z1) for kk, v in scores.items()}
        p_sq = math.exp(s_sq - z1) if s_sq != R.NEG else post1[dup[0]]
        uns0 = sum(post0[x] for x in unsound)
        uns1 = sum(post1[x] for x in unsound)
        map0 = max(post0, key=post0.get)
        map1 = max(list(post1) + ([] if dup else ['SeenQ']), key=lambda x: p_sq if x == 'SeenQ' else post1[x])
        if dup and map1 == dup[0]:
            map1 = dup[0] + '=SeenQ'
        # false-probe mass (citation depth): theories in the pool deriving the probe; SeenQ is sound and
        # derives none of the probes (they are not Q axioms and not induction instances)
        thmap = {th.name: th for th in pool}
        if 'Mem' in res and 'theory' in res['Mem']:
            thmap['Mem'] = res['Mem']['theory']
        pf0 = max(sum(post0[x] for x in post0 if x in thmap and der.derives(thmap[x], s)) for s in false)
        pf1 = max(sum(post1[x] for x in post1 if x in thmap and der.derives(thmap[x], s)) for s in false)
        best_sound_pool = max((v for kk, v in scores.items() if kk not in unsound), default=R.NEG)
        # posterior of Q-lumped (and of skel4) with SeenQ added
        p_lump1 = post1.get('Q-lumped', 0.0)
        s_sq_val = own_score(sq, D)
        rows.append(dict(n=n, k=k, sq_minus_lump_bits=(s_sq_val - s_lump) / LN2,
                         lump_check=abs(s_lump - s_lump_track), uns0=uns0, uns1=uns1, p_sq=p_sq, map0=map0,
                         map1=map1, pf0=pf0, pf1=pf1, sq_minus_best_sound_pool_bits=(s_sq_val - best_sound_pool) / LN2, dup=bool(dup)))
    return seed, rows


def main():
    from multiprocessing import Pool
    seeds = list(range(25))
    with Pool(4) as p:
        out = p.map(run, seeds, chunksize=1)
    log('R2: E2 data (track generator), pool posterior from the track pipeline, SeenQ(D_n) and Q-lumped scored '
        'independently (ref_core).')
    log('columns: seed n | #Q axioms seen | log2 score SeenQ - Q-lumped | unsound mass: track pool -> pool+SeenQ | '
        'max false-probe mass: track pool -> pool+SeenQ | posterior of SeenQ | MAP: track pool -> pool+SeenQ | '
        'SeenQ - best sound pool theory (bits; 0 = SeenQ is already in the pool) | |own - track| Q-lumped score')
    worst_check = 0.0
    acc0 = {n: 0 for n in NS}
    acc1 = {n: 0 for n in NS}
    any0 = set()
    any1 = set()
    for seed, rows in out:
        for r in rows:
            worst_check = max(worst_check, r['lump_check'])
            log('seed %2d n %3d | %d | %+8.1f | %.3f -> %.3g | %.3f -> %.3g | %.3f | %s -> %s | %+.1f | %.1e' % (
                seed, r['n'], r['k'], r['sq_minus_lump_bits'], r['uns0'], r['uns1'], r['pf0'], r['pf1'], r['p_sq'],
                r['map0'][:14], r['map1'][:14], r['sq_minus_best_sound_pool_bits'], r['lump_check']))
            if r['pf0'] >= 0.95:
                acc0[r['n']] += 1
                any0.add(seed)
            if r['pf1'] >= 0.95:
                acc1[r['n']] += 1
                any1.add(seed)
    log('')
    log('max |own - track| on the Q-lumped log score: %.2e' % worst_check)
    for n in NS:
        log('n = %d: seeds where a delta = 0.05 verifier accepts a false probe: track pool %d/25, pool + SeenQ %d/25'
            % (n, acc0[n], acc1[n]))
    log('seeds 0-4: accepting at some n <= 32: track pool %s, pool + SeenQ %s' % (
        sorted(s for s in any0 if s < 5), sorted(s for s in any1 if s < 5)))
    log('all 25 seeds: accepting at some n in %s: track pool %d/25, pool + SeenQ %d/25' % (NS, len(any0), len(any1)))
    with open(os.path.join(HERE, 'r2_e2_seenq.out'), 'w') as f:
        f.write('\n'.join(OUT) + '\n')


if __name__ == '__main__':
    main()
