import os
import sys
import random
import pytest

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))

from dtrc.syntax import parse, pp, H, EQ, NOT, ZERO, S, rebuild, kids, canon_params, close_params  # noqa
from dtrc.templates import match, instantiate, geq, equiv, is_DT0, canon, covers_all, metas      # noqa
from dtrc.schemas import (T_IND, T_SEP, T_REP, T_EIND, Ind, Sep, Rep, EInd, U_AXIOMS, pa_targets,   # noqa
                          zf_targets)
from dtrc.mincover import MinCover, min_covering                                                   # noqa
from dtrc.datasets import pa_motive, zf_body, pa_mix, zf_mix, universal_instance                  # noqa


def hole_body(s):
    f = parse(s, canon=False)

    def go(t):
        if t == ('p', 'X'):
            return ('h', 0)
        if t[0] in ('v', 'p', 'h', '0'):
            return t
        return rebuild(t, [go(k) for k in kids(t)])
    return go(f)


# ----------------------------------------------------------------------------------- syntax
SENTENCES = ['forall x. x+0=x', 'forall x. forall y. (Sx=Sy -> x=y)', 'forall x. (~x=0 -> exists y. x=Sy)',
             'forall a. exists b. forall x. (x in b <-> (x in a & ~x in w))', '(0=0 & forall x. (x=x -> Sx=Sx)) -> forall x. x=x',
             'forall x. ((forall y. (y in x -> y=y)) -> x=x)', 'exists x. forall y<SSx. ~y=x']


@pytest.mark.parametrize('s', SENTENCES)
def test_roundtrip(s):
    f = parse(s)
    assert parse(pp(f)) == f


def test_random_roundtrip():
    rng = random.Random(1)
    for _ in range(200):
        s = Ind(pa_motive(rng))
        assert parse(pp(s)) == s
        z = Sep(zf_body(rng, 2, [0]))
        assert parse(pp(z)) == z


def test_close_params():
    f = parse('w0+0=w1')
    assert close_params(f) == ('all', ('all', ('=', ('+', ('v', 1), ('0',)), ('v', 0))))


# ----------------------------------------------------------------------------------- matching
def test_targets_are_DT0():
    for T in list(pa_targets().values()) + list(zf_targets().values()):
        assert is_DT0(T)


def test_match_recovers_motive():
    rng = random.Random(2)
    for _ in range(300):
        m = pa_motive(rng)
        s = Ind(m)
        th = match(T_IND, s)
        assert th is not None
        assert canon_params(instantiate(T_IND, th)) == s
    for _ in range(100):
        for T, mk, nh, need in [(T_SEP, Sep, 2, [0]), (T_REP, Rep, 3, [0, 1]), (T_EIND, EInd, 1, [0])]:
            b = zf_body(rng, nh, need)
            s = mk(b)
            th = match(T, s)
            assert th is not None and canon_params(instantiate(T, th)) == s


def test_match_rejects_noninstances():
    bad = ['(0=0 & forall x. (x=x -> Sx=Sx)) -> forall x. x=0',
           '(0=0 & forall x. (x=0 -> x=0)) -> forall x. x=0',
           '(S0=0 & forall x. (x=0 -> Sx=0)) -> forall x. x=0']
    for s in bad:
        assert match(T_IND, parse(s)) is None
    # Separation with b free in phi is not an instance (freshness is built in)
    assert match(T_SEP, parse('forall a. exists b. forall x. (x in b <-> (x in a & ~x in b))')) is None


def test_geq():
    T12 = parse('(?A & forall x. (?P(x) -> ?Q(x))) -> forall x. ?P(x)')
    assert geq(T12, T_IND) and not geq(T_IND, T12)
    assert equiv(T_IND, canon(T_IND))
    assert geq(parse('?P'), T_SEP)
    assert not geq(T_SEP, T_REP) and not geq(T_REP, T_SEP)


def test_param_renaming():
    T = parse('?P & w0=w0')
    assert match(T, parse('(a=0) & b=b')) is not None
    assert match(T, parse('b=b & b=b')) is not None


# ----------------------------------------------------------------------------------- minimal covers
def test_anchor_gives_T_ind():
    D = [Ind(hole_body('X=X')), Ind(hole_body('~X=0'))]
    for ta0 in (True, False):
        mins, _ = min_covering(D, term_arity0=ta0)
        assert len(mins) == 1 and equiv(mins[0], T_IND)


def test_singleton():
    s = Ind(hole_body('X=X'))
    mins, _ = min_covering([s])
    assert mins == [s]


def test_nonunitary_C81():
    s1 = parse('(forall x. x=0) & ((forall x. x=x) & 0=0)')
    s2 = parse('(forall x. ~x=0) & ((forall x. ~x=x) & ~0=0)')
    G1 = parse('(forall x. ?P(x)) & ((forall x. ?Q(x)) & ?P(0))')
    G2 = parse('(forall x. ?P(x)) & ((forall x. ?Q(x)) & ?Q(0))')
    mins, _ = min_covering([s1, s2])
    assert len(mins) == 2
    assert any(equiv(M, G1) for M in mins) and any(equiv(M, G2) for M in mins)


def test_coincidence_counts():
    D = [Ind(hole_body('X=X')), Ind(hole_body('0=X'))]
    assert len(min_covering(D, term_arity0=True)[0]) == 2
    assert len(min_covering(D, term_arity0=False)[0]) == 4


def test_universal_from_numerals():
    D = [parse('S0+0=S0'), parse('0+0=0')]
    mins, _ = min_covering(D)
    assert len(mins) == 1 and equiv(mins[0], U_AXIOMS['U_add0'])
    assert match(mins[0], parse('w+0=w')) is not None       # closure-normal form: Ax(x+0=x)
    D2 = [parse('S0+0=S0'), parse('SS0+0=SS0')]          # same head symbol S: not an anchor
    mins2, _ = min_covering(D2)
    assert len(mins2) == 1 and not geq(mins2[0], U_AXIOMS['U_add0'])


def test_mins_properties_random():
    rng = random.Random(3)
    for trial in range(60):
        k = rng.choice(['Ind', 'Sep', 'EInd'])
        n = rng.randint(1, 3)
        if k == 'Ind':
            D, T = [Ind(pa_motive(rng)) for _ in range(n)], T_IND
        elif k == 'Sep':
            D, T = [Sep(zf_body(rng, 2, [0])) for _ in range(n)], T_SEP
        else:
            D, T = [EInd(zf_body(rng, 1, [0])) for _ in range(n)], T_EIND
        mins, mc = min_covering(D)
        assert mins
        for M in mins:
            assert is_DT0(M) and covers_all(M, D)
        for a in mins:
            for b in mins:
                if a is not b:
                    assert not geq(a, b)
        # the target is above some minimal template (well-foundedness, needed for within-schema merges)
        assert any(geq(T, M) for M in mins)
