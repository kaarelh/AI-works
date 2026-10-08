"""Unit tests for the bai package (run: cd code && python3 -m pytest -q tests)."""
import itertools
import math
import os
import random
import sys
from collections import Counter

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
import bai  # noqa: E402,F401
from dtrc.syntax import parse, pp, num, ZERO, S  # noqa: E402
from dtrc.templates import instantiate  # noqa: E402
from bai.grammar import Grammar, TemplateCode, theory_bits, logsumexp  # noqa: E402
from bai.theory import Component, Theory  # noqa: E402
from bai.lik import (Chain, SelChain, dirichlet_marginal, forall_elim, gen, ungen, elim_predecessors,  # noqa: E402
                     class_prob_qf, logcoefs0, TooManyOccurrences)
from bai.pool import forall_of, term_patterns, specialise, generalisations  # noqa: E402
from bai.posterior import evaluate, Deriver, support_mass  # noqa: E402
from bai.gens import cite_data, chain_data  # noqa: E402

Q = Grammar()


# ------------------------------------------------------------------------------------ grammar
def test_term_logq_hand():
    assert abs(math.exp(Q.logq_term(ZERO)) - 0.45) < 1e-12
    assert abs(math.exp(Q.logq_term(S(ZERO))) - 0.35 * 0.45) < 1e-12
    # with the parameter allowed the options renormalise over 1 + 0.15
    assert abs(math.exp(Q.logq_term(ZERO, ap=True)) - 0.45 / 1.15) < 1e-12
    # a variable in a context with 2 variables
    assert abs(math.exp(Q.logq_term(('h', 0), 1, 1)) - 0.3 / 1.3 / 2) < 1e-12
    assert abs(math.exp(Q.logq_term(('v', 0), 1, 1)) - 0.3 / 1.3 / 2) < 1e-12
    assert Q.logq_term(('h', 1), 1, 0) == float('-inf')
    assert Q.logq_term(('p', 'w1'), ap=True) == float('-inf')


def test_sampler_matches_logq():
    rng = random.Random(0)
    N = 40000
    cnt = Counter(Q.sample_form(rng, 1, 0, False) for _ in range(N))
    for f, c in cnt.most_common(10):
        p = math.exp(Q.logq_form(f, 1, 0, False))
        z = (c / N - p) / math.sqrt(p * (1 - p) / N)
        assert abs(z) < 4.5, (pp(f), c / N, p)


def test_param_fixed_point():
    rng = random.Random(1)
    N = 40000
    k = sum(1 for _ in range(N) if 'w0' in str(Q.sample_term(rng, 0, 0, True)))
    h = Q.p_term_has_param()
    assert abs(k / N - h) < 4.5 * math.sqrt(h * (1 - h) / N)


def test_template_code_hand():
    code = TemplateCode()
    # 0=0: formula '=' then two term nodes '0' (no variable in scope: options 0,S,+,*,param,M)
    z = 0.3 + 0.2 + 0.1 + 0.1 + 0.05 + 0.1
    expect = -math.log2(0.2) - 2 * math.log2(0.3 / z)
    assert abs(code.bits(parse('0=0')) - expect) < 1e-9
    # ?t+0=?t: '=', '+', M(new: log2 1 = 0, arity 0: 1 bit, guard: 1 bit), '0', M(existing: log2 2 = 1)
    expect = (-math.log2(0.2) - math.log2(0.1 / z) - math.log2(0.1 / z) + 0 + 1 + 1 - math.log2(0.3 / z)
              - math.log2(0.1 / z) + 1)
    assert abs(code.bits(parse('?t+0=?t')) - expect) < 1e-9
    # a set of m distinct templates saves log2 m!
    a, b = parse('0=0'), parse('1=1')
    assert abs(theory_bits([a, b]) - (3 + code.bits(a) + code.bits(b) - 1)) < 1e-9


# ------------------------------------------------------------------------------------ components
def test_component_canonical_and_l0():
    c1 = Component(parse('?t+0=?t'), {'t': 'open'})
    c2 = Component(parse('?u+0=?u'), {'u': 'open'})
    c3 = Component(parse('?u+0=?u'))
    assert c1.key == c2.key and c1.key != c3.key
    d = parse('S0+0=S0')
    assert abs(c3.logcoef0(d, Q) - math.log(0.35 * 0.45)) < 1e-12
    # closed guard rejects a parameter body
    assert c3.logcoef0(parse('w0+0=w0'), Q) == float('-inf')
    assert c1.logcoef0(parse('w0+0=w0'), Q) > float('-inf')
    th = Theory([c1, c2, c3], 'x')
    assert len(th.comps) == 2


# ------------------------------------------------------------------------------------ Dirichlet DP
def _brute_dir(coefs, m, alpha):
    lg = math.lgamma
    tot = []
    for z in itertools.product(*[sorted(c) for c in coefs]):
        cnt = [0] * m
        lp = 0.0
        for j, i in enumerate(z):
            cnt[i] += 1
            lp += coefs[j][i]
        n = len(coefs)
        lp += lg(m * alpha) - lg(m * alpha + n) + sum(lg(alpha + c) - lg(alpha) for c in cnt)
        tot.append(lp)
    return logsumexp(tot)


def test_dirichlet_dp_exact():
    rng = random.Random(3)
    for _ in range(200):
        m = rng.randint(1, 5)
        n = rng.randint(1, 8)
        alpha = rng.choice([0.5, 1.0, 0.3])
        coefs = []
        for j in range(n):
            Sset = rng.sample(range(m), rng.randint(1, m))
            coefs.append({i: rng.uniform(-8, 0) for i in Sset})
        assert abs(dirichlet_marginal(coefs, m, alpha) - _brute_dir(coefs, m, alpha)) < 1e-9


def test_dirichlet_unused_component():
    # one used component and one unused: ratio = Gamma(2a)Gamma(a+n)/(Gamma(a)Gamma(2a+n))
    n, a = 50, 0.5
    coefs = [{0: 0.0}] * n
    lg = math.lgamma
    expect = lg(2 * a) + lg(a + n) - lg(a) - lg(2 * a + n)
    assert abs(dirichlet_marginal(coefs, 2, a) - expect) < 1e-12


# ------------------------------------------------------------------------------------ syntax helpers
def test_elim_gen_inverse():
    s = parse('forall x. forall y. x+Sy=S(x+y)')
    t = num(2)
    r = forall_elim(s, t)
    assert pp(r) == pp(parse('forall y. 2+Sy=S(2+y)'))
    g = gen(parse('w0+0=w0'))
    assert g == parse('forall x. x+0=x')
    assert ungen(g) == parse('w0+0=w0')
    assert ungen(parse('forall x. 0=0')) is None


def test_elim_predecessors_are_predecessors():
    s = parse('S0+0=S0')
    for pred, lt in elim_predecessors(s, Q, True):
        assert pred[0] == 'all'
        # every non-vacuous predecessor eliminates to s with its term; the vacuous one with any term
        ok = forall_elim(pred, num(5)) == s or any(
            forall_elim(pred, t) == s for t in [ZERO, S(ZERO), ('+', S(ZERO), ZERO)])
        assert ok, pp(pred)


# ------------------------------------------------------------------------------------ L1 chain
THEORIES = [
    Theory([parse('forall x. x+0=x')], 'H_all'),
    Theory([Component(parse('?t+0=?t'), {'t': 'open'})], 'H_open'),
    Theory([parse('?t+0=?t')], 'H_sch'),
    Theory([parse('forall x. forall y. x+y=y+x')], 'comm'),
    Theory([parse('?t=0'), parse('?t=0 -> ?t+0=0'), parse('forall x. (x=0 -> x+0=0)')], 'mp'),
    Theory([parse('?P')], 'bare'),
    Theory([parse('forall x. x+0=x'), Component(parse('?t*0=0'), {'t': 'open'}), parse('w0*0=0')], 'mix'),
    Theory([parse('forall x. ?P(x)')], 'allP'),
    Theory([Component(parse('?P'), {'P': 'open'})], 'bareOpen'),
]


def _data(chain, n, seed):
    rng = random.Random(seed)
    out = set()
    for th in THEORIES:
        for _ in range(n):
            d = chain.sample(th.comps, [1.0 / len(th.comps)] * len(th.comps), rng)
            if len(str(d)) < 260:
                out.add(d)
    return sorted(out, key=str)


def test_l1_guided_equals_bruteforce_K1():
    chg = Chain(Q, K=1, c_stop=0.4, qe_open=True)
    chb = Chain(Q, K=1, c_stop=0.4, qe_open=True, guided=False, max_occ=14)
    data = _data(chg, 12, 5)
    for th in THEORIES:
        for d in data:
            a = chg.logcoefs(th, d)
            try:
                b = chb.logcoefs(th, d)
            except TooManyOccurrences:
                continue
            if chb.inexact:
                chb.inexact = 0
                continue
            assert set(a) == set(b), (th.name, pp(d))
            for k in a:
                assert abs(a[k] - b[k]) < 1e-9, (th.name, pp(d), a[k], b[k])
    assert chg.inexact == 0


def test_l1_guided_equals_bruteforce_K2():
    chg = Chain(Q, K=2, c_stop=0.4, qe_open=True)
    chb = Chain(Q, K=2, c_stop=0.4, qe_open=True, guided=False, max_occ=10)
    data = _data(chg, 6, 6)
    for th in THEORIES:
        if th.name in ('bare', 'allP', 'bareOpen'):
            continue      # K = 2 with a bare metavariable is brute force in both modes
        for d in data:
            a = chg.logcoefs(th, d)
            try:
                b = chb.logcoefs(th, d)
            except TooManyOccurrences:
                continue
            if chb.inexact:
                chb.inexact = 0
                continue
            assert set(a) == set(b), (th.name, pp(d))
            for k in a:
                assert abs(a[k] - b[k]) < 1e-9, (th.name, pp(d))


def _chi2_check(th, w, chain, N, seed):
    rng = random.Random(seed)
    cnt = Counter(chain.sample(th.comps, w, rng) for _ in range(N))
    stat, df, rest_c, rest_p = 0.0, 0, 0, 0.0
    tot_p = 0.0
    for d, c in cnt.items():
        p = sum(w[i] * math.exp(v) for i, v in chain.logcoefs(th, d).items())
        assert p > 0, pp(d)
        tot_p += p
        if N * p >= 20:
            stat += (c - N * p) ** 2 / (N * p)
            df += 1
        else:
            rest_c += c
            rest_p += p
    rest_p = 1.0 - (tot_p - rest_p)       # everything not in a big cell, including unseen sentences
    stat += (rest_c - N * rest_p) ** 2 / (N * rest_p)
    assert tot_p <= 1 + 1e-9
    # chi-square with df degrees of freedom: mean df, sd sqrt(2 df); allow 5 sd
    assert stat < df + 5 * math.sqrt(2 * df) + 10, (th.name, stat, df)


def test_l1_sampler_matches_exact():
    ch = Chain(Q, K=1, c_stop=0.5, qe_open=True)
    _chi2_check(THEORIES[0], [1.0], ch, 30000, 1)
    _chi2_check(THEORIES[1], [1.0], ch, 30000, 2)
    _chi2_check(THEORIES[4], [0.5, 0.3, 0.2], ch, 30000, 3)
    ch2 = Chain(Q, K=2, c_stop=0.5, qe_open=True)
    _chi2_check(THEORIES[3], [1.0], ch2, 30000, 4)
    _chi2_check(THEORIES[6], [0.4, 0.3, 0.3], ch2, 30000, 5)


def test_class_prob_monte_carlo():
    for qe_open in (False, True):
        ch = Chain(Q, K=2, c_stop=0.4, qe_open=qe_open)
        for th in [THEORIES[0], THEORIES[1], THEORIES[3]]:
            c = th.comps[0]
            p = class_prob_qf(c, ch)
            rng = random.Random(7)
            N = 20000
            k = 0
            for _ in range(N):
                d = ch.sample([c], [1.0], rng)
                if d[0] != 'all' and 'w0' not in str(d) and 'ex' not in str(d):
                    k += 1
            assert abs(k / N - p) < 4.5 * math.sqrt(p * (1 - p) / N) + 1e-9, (th.name, qe_open, k / N, p)


# ------------------------------------------------------------------------------------ pool helpers
def test_term_patterns_partition():
    rng = random.Random(2)
    for depth in (1, 2):
        pats = term_patterns(depth)
        P = parse('?t+0=?t')
        temps = [specialise(P, 't', p) for p in pats]
        for _ in range(300):
            t = Q.sample_term(rng)
            d = instantiate(P, {'t': t})
            hits = sum(1 for T in temps if Component(T).matcher(d) is not None)
            assert hits == 1, pp(d)


def test_generalisations_are_more_general():
    from dtrc.templates import geq
    P = parse('?t+0=?t')
    gs = generalisations(P)
    assert gs and all(geq(G, P) and not geq(P, G) for G in gs)


# ------------------------------------------------------------------------------------ posterior / verifier
def test_posterior_and_verifier():
    P = parse('?t+0=?t')
    pool = [Theory([forall_of(P)], 'H_all'), Theory([Component(P)], 'H_sch'),
            Theory([Component(P, {'t': 'open'})], 'H_open'), Theory([parse('?P')], 'bare')]
    data = cite_data(pool[1], [1.0], Q, 64, 0)
    res = evaluate(pool, data, [64], 'L0', Q=Q)[0]
    assert abs(sum(v['post'] for v in res.values()) - 1) < 1e-9
    assert res['H_sch']['post'] > 0.99
    der = Deriver(K=2, Q=Q)
    A = forall_of(P)
    assert der.derives(pool[0], parse('S0+0=S0'))
    assert not der.derives(pool[1], A)
    assert der.derives(pool[2], A)
    assert der.derives(pool[3], A)
    assert support_mass(res, pool, der, A) < 0.01


def test_dirichlet_bounds_bracket_exact():
    from bai.lik import dirichlet_bounds
    rng = random.Random(11)
    for _ in range(100):
        m = rng.randint(2, 6)
        n = rng.randint(5, 30)
        coefs = []
        for j in range(n):
            Sset = rng.sample(range(m), rng.randint(1, min(3, m)))
            coefs.append({i: rng.uniform(-6, 0) for i in Sset})
        ex = dirichlet_marginal(coefs, m, 0.5)
        lo, hi = dirichlet_bounds(coefs, m, 0.5)
        assert lo <= ex + 1e-9 <= hi + 2e-9


def test_star_closed_form_large_numeral():
    # large terms: the closed form must not overflow and must agree with brute force
    d = instantiate(parse('?t+0=?t'), {'t': num(40)})
    th = Theory([parse('?P')], 'bare')
    a = Chain(Q, K=1, c_stop=0.5, qe_open=False).logcoefs(th, d)
    b = Chain(Q, K=1, c_stop=0.5, qe_open=False, guided=False, max_occ=14).logcoefs(th, d)
    assert abs(a[0] - b[0]) < 1e-9
