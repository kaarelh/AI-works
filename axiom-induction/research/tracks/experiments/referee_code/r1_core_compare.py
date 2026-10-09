"""Referee check R1: the track's core probabilities against independent reimplementations (ref_core.py).

(a) Q log-probabilities on samples from an independent sampler, in several contexts.
(b) Q is proper: P(tree has at most N nodes) -> 1 (exact size distribution by dynamic programming).
(c) DT° matching: own matcher against dtrc's on sentences instantiated from templates of the pools.
(d) prior code lengths of the main theories.
(e) L0 coefficients.
(f) Dirichlet marginal on random coefficient sets (m <= 6, up to 5 overlapping components).
(g) L1 chain coefficients (K = 1, 2) by independent brute-force backward enumeration, on data drawn from an
    independent forward sampler; and the forward sampler's frequencies against the exact values.
Seeded.  Command: python3 r1_core_compare.py  (writes r1_core_compare.out)
"""
import math
import os
import random
import sys
from collections import Counter

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '..', '..', '..', '..', 'code')))
import bai  # noqa: E402,F401
from bai.grammar import Grammar, TemplateCode, theory_bits as bai_theory_bits  # noqa: E402
from bai.theory import Component, Theory  # noqa: E402
from bai.lik import Chain, dirichlet_marginal  # noqa: E402
from dtrc.templates import match as dmatch, canon  # noqa: E402
from dtrc.schemas import Q_AXIOMS, T_IND  # noqa: E402
import ref_core as R  # noqa: E402

OUT = []


def log(*a):
    s = ' '.join(str(x) for x in a)
    print(s, flush=True)
    OUT.append(s)


rng = random.Random(20261008)
G = Grammar()
q = R.Q()

# (a) -----------------------------------------------------------------------------------------------
worst = 0.0
n = 0
for (nh, nb, ap) in [(0, 0, False), (0, 0, True), (1, 0, False), (2, 0, True), (1, 1, False), (0, 2, True)]:
    for _ in range(1500):
        t = q.sample_term(rng, nh, nb, ap)
        a, b = q.q_term(t, nh, nb, ap), G.logq_term(t, nh, nb, ap)
        worst = max(worst, abs(a - b))
        f = q.sample_form(rng, nh, nb, ap)
        a, b = q.q_form(f, nh, nb, ap), G.logq_form(f, nh, nb, ap)
        worst = max(worst, abs(a - b))
        n += 2
log('(a) Q log-probabilities: %d samples, max |own - bai| = %.2e' % (n, worst))
# out-of-support cases
cases = [(('h', 0), 0, 0, False), (('p', 'w0'), 0, 0, False), (('v', 1), 0, 1, False), (('p', 'w1'), 0, 0, True)]
log('    out-of-support agree:', all((q.q_term(t, a, b, c) == R.NEG) == (G.logq_term(t, a, b, c) == float('-inf'))
                                    for t, a, b, c in cases))

# (b) -----------------------------------------------------------------------------------------------
def size_mass_terms(N, nv, ap):
    o = q.term_opts(nv, ap)
    leaf = o['0'] + o.get('var', 0) + o.get('par', 0)
    P = [0.0] * (N + 1)        # P[k] = probability that a term tree has exactly k nodes
    for k in range(1, N + 1):
        v = leaf if k == 1 else 0.0
        v += o['S'] * P[k - 1]
        bi = o['+'] + o['*']
        v += bi * sum(P[i] * P[k - 1 - i] for i in range(1, k - 1))
        P[k] = v
    return P


def size_mass_forms(N, nv_max=3, ap=False):
    # formulas with up to N nodes, term nodes counted too; context-free in the number of variables only
    # through the term options; approximate nv by a fixed nv (we check properness for nv = 0 and nv = 2)
    Pt = size_mass_terms(N, nv_max, ap)
    z = sum(R.FW.values())
    fw = {k: v / z for k, v in R.FW.items()}
    F = [0.0] * (N + 1)
    for k in range(1, N + 1):
        v = 0.0
        for at in ('=', '<'):
            v += fw[at] * sum(Pt[i] * Pt[k - 1 - i] for i in range(1, k - 1))
        for un in ('not', 'all', 'ex'):
            v += fw[un] * F[k - 1]
        for bi in ('and', 'or', 'imp', 'iff'):
            v += fw[bi] * sum(F[i] * F[k - 1 - i] for i in range(1, k - 1))
        F[k] = v
    return F


for (nv, ap) in [(0, False), (0, True), (2, True)]:
    P = size_mass_terms(400, nv, ap)
    log('(b) terms nv=%d ap=%s: P(size <= 50) = %.6f, P(size <= 400) = %.9f' % (nv, ap, sum(P[:51]), sum(P)))
F = size_mass_forms(400, 0, False)
log('(b) formulas (closed atoms): P(size <= 50) = %.6f, P(size <= 400) = %.9f' % (sum(F[:51]), sum(F)))
F = size_mass_forms(400, 2, True)
log('(b) formulas (nv = 2, ap): P(size <= 400) = %.9f' % sum(F))

# (c), (e) --------------------------------------------------------------------------------------------
temps = [R.parse(s) for s in ['?t+0=?t', '0+?t=?t', '~S?t=0', 'forall x. x+?b=?b+x', '?a+?b=?b+?a',
                              'forall x. forall y. ?P(x, y)', 'forall x. ?P(x)', '?P']] + [T_IND]
temps += [R.parse('(?A & forall x. (?P(x) -> ?P(Sx))) -> forall x. ?P(x)'), R.parse('?A -> forall x. ?P(x)')]
qsent = [R.parse(s) for s in Q_AXIOMS.values()]
mism = 0
l0w = 0.0
ntests = 0
for T in temps:
    ms = R.metas(T)
    for _ in range(150):
        th = {}
        for m, ar in ms.items():
            th[m] = q.sample_form(rng, ar, 0, False) if R.meta_is_formula(m) else q.sample_term(rng, ar, 0, False)
        s = R.inst(T, th)
        for T2 in temps + qsent:
            a = R.match(T2, s)
            b = dmatch(T2, s)
            ntests += 1
            if (a is None) != (b is None) or (a is not None and a != b):
                mism += 1
            la = R.l0(T2, {}, s, q)
            lb = Component(T2).logcoef0(s, G)
            if (la == R.NEG) != (lb == float('-inf')):
                mism += 1
            elif la != R.NEG:
                l0w = max(l0w, abs(la - lb))
log('(c,e) matcher and L0 on %d (template, sentence) pairs: disagreements %d, max |L0 own - bai| = %.2e'
    % (ntests, mism, l0w))

# (d) -----------------------------------------------------------------------------------------------
code = TemplateCode()
named = {'H_sch {?t+0=?t}': [R.parse('?t+0=?t')], 'H_all {Ax x+0=x}': [R.parse('forall x. x+0=x')],
         '{?P}': [R.parse('?P')], 'T* = Q1..Q7 + T_Ind': qsent + [T_IND], 'T_Ind': [T_IND],
         'Q-lumped': [R.parse('forall x. forall y. ?P(x, y)'), R.parse('forall x. ?P(x)'), T_IND],
         '{~S?t=0}': [R.parse('~S?t=0')], '{Ax ~Sx=0}': [R.parse('forall x. ~Sx=0')]}
for k, ts in named.items():
    a = R.theory_bits(ts)
    b = bai_theory_bits([canon(T) for T in ts], code)
    log('(d) bits %-26s own %.4f  bai %.4f' % (k, a, b))

# (f) -----------------------------------------------------------------------------------------------
worst = 0.0
for _ in range(400):
    m = rng.randint(1, 6)
    nn = rng.randint(1, 10)
    alpha = rng.choice([0.5, 1.0])
    coefs = []
    for j in range(nn):
        S = rng.sample(range(m), rng.randint(1, min(m, 5)))
        coefs.append({i: rng.uniform(-9, 0) for i in S})
    a = R.dir_marg(coefs, m, alpha)
    b = dirichlet_marginal(coefs, m, alpha)
    c = R.dir_marg_brute(coefs, m, alpha) if nn <= 7 else a
    worst = max(worst, abs(a - b), abs(a - c))
log('(f) Dirichlet marginal, 400 random cases (m <= 6, n <= 10, up to 5 overlapping): max |own - bai| = %.2e' % worst)

# (g) -----------------------------------------------------------------------------------------------
def T1(*comps):
    return R.Theory1([(R.parse(s), g) for s, g in comps])


def bth(t1, name):
    return Theory([Component(T, g) for T, g in t1.comps], name)


L1T = {
    'H_all': T1(('forall x. x+0=x', {})),
    'H_open': T1(('?t+0=?t', {'t': 'open'})),
    'comm': T1(('forall x. forall y. x+y=y+x', {})),
    'M_x': T1(('forall x. x+?b=?b+x', {})),
    'bare?P': T1(('?P', {})),
    'allP': T1(('forall x. ?P(x)', {})),
    'mp': T1(('?t=0', {}), ('?t=0 -> ?t+0=0', {}), ('forall x. (x=0 -> x+0=0)', {})),
    'mix': T1(('forall x. x+0=x', {}), ('?t*0=0', {'t': 'open'}), ('w0*0=0', {})),
}
for K, qe_open in [(1, False), (1, True), (2, False), (2, True)]:
    ch = Chain(G, G, K=K, c_stop=0.5, qe_open=qe_open)
    worst, cnt, skipped = 0.0, 0, 0
    for name, t1 in L1T.items():
        if K == 2 and name in ('bare?P', 'allP'):
            continue
        th = bth(t1, name)
        m = len(t1.comps)
        data = set()
        for _ in range(60):
            d = R.chain_sample(t1, [1.0] * m, q, q, qe_open, K, 0.5, rng)
            if len(str(d)) < 200:
                data.add(d)
        for d in sorted(data, key=str):
            try:
                own = {i: R.l1_coef(t1, i, d, q, q, qe_open, K, 0.5) for i in range(m)}
            except OverflowError:
                skipped += 1
                continue
            theirs = ch.logcoefs(th, d)
            for i in range(m):
                a = own[i]
                b = theirs.get(i, float('-inf'))
                if (a == R.NEG) != (b == float('-inf')):
                    worst = float('inf')
                    log('   MISMATCH support', name, R.pp(d), i, a, b)
                elif a != R.NEG:
                    worst = max(worst, abs(a - b))
                cnt += 1
    log('(g) L1 K=%d qe_open=%s: %d (theory, datum, component) triples, max |own - bai| = %.2e (skipped %d)'
        % (K, qe_open, cnt, worst, skipped))

# forward sampler frequencies against exact (own sampler, own exact), chi-square
for name, K, qe_open in [('H_all', 1, True), ('M_x', 2, False), ('mp', 1, False), ('mix', 2, True)]:
    t1 = L1T[name]
    m = len(t1.comps)
    w = [1.0 / m] * m
    N = 10000
    cnt = Counter(R.chain_sample(t1, w, q, q, qe_open, K, 0.5, rng) for _ in range(N))
    stat, df, rest_c, tot, big, unk = 0.0, 0, 0, 0.0, 0.0, 0

    def pex(d):
        return sum(w[i] * math.exp(R.l1_coef(t1, i, d, q, q, qe_open, K, 0.5)) for i in range(m))
    for d, c in cnt.items():
        if c < 5:                  # cells with N p >= 20 have count >= 5 except with negligible probability
            rest_c += c
            continue
        try:
            p = pex(d)
        except OverflowError:      # too many occurrences for the brute force: pooled
            rest_c += c
            unk += 1
            continue
        tot += p
        if N * p >= 20:
            stat += (c - N * p) ** 2 / (N * p)
            df += 1
            big += p
        else:
            rest_c += c
    rp = 1 - big
    stat += (rest_c - N * rp) ** 2 / (N * rp)
    log('(g) own sampler vs own exact, %s K=%d qe_open=%s: chi2 = %.1f on %d cells (+1 pooled); sum of exact '
        'probabilities of data seen >= 5 times %.4f <= 1' % (name, K, qe_open, stat, df, tot))

with open(os.path.join(HERE, 'r1_core_compare.out'), 'w') as f:
    f.write('\n'.join(OUT) + '\n')
