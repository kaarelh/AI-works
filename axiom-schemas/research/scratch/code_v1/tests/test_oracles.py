"""Soundness of the refutation oracles: never refute a true axiom instance (on samples); refute known
false sentences; the template refuter refutes over-general templates and never the targets."""
import os
import sys
import random

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))

from dtrc.syntax import parse                                                    # noqa
from dtrc.schemas import (Ind, Sep, Rep, EInd, Q_AXIOMS, ZF_AXIOMS, T_IND, T_SEP, T_REP, T_EIND,  # noqa
                          U_AXIOMS)
from dtrc.datasets import pa_motive, zf_body, universal_instance                 # noqa
from dtrc.oracle_pa import PAEval                                                 # noqa
from dtrc.oracle_zf import ZFEval                                                 # noqa
from dtrc.refute import TemplateRefuter                                           # noqa
from dtrc.templates import instantiate                                            # noqa


def test_pa_never_refutes_true_instances():
    ev = PAEval()
    rng = random.Random(7)
    for s in Q_AXIOMS.values():
        assert ev.truth(parse(s)) is not False
    for _ in range(400):
        assert ev.truth(Ind(pa_motive(rng))) is not False
    for T in U_AXIOMS.values():
        for _ in range(50):
            assert ev.truth(universal_instance(rng, T)) is not False


def test_pa_refutes_false():
    ev = PAEval()
    for s in ['forall x. x=0', '(0=0 & forall x. (x=x -> Sx=Sx)) -> forall x. x=0', 'w*0=S0', '0+0=S0',
              'forall x. forall y. x+y=x', '(0=0 & forall x. (x=0 -> x=0)) -> forall x. x=0']:
        assert ev.truth(parse(s)) is False, s


def test_pa_certifies_some_truths():
    ev = PAEval()
    for s in ['forall x. x+0=x', 'forall x. forall y. x+y=y+x', 'forall x. (x=0 | ~x=0)', 'forall x. x<Sx']:
        assert ev.truth(parse(s)) is True, s


def test_zf_never_refutes_true_instances():
    ev = ZFEval()
    rng = random.Random(8)
    for s in ZF_AXIOMS.values():
        assert ev.truth(parse(s)) is not False
    for _ in range(120):
        assert ev.truth(Sep(zf_body(rng, 2, [0]))) is not False
        assert ev.truth(EInd(zf_body(rng, 1, [0]))) is not False
    for _ in range(40):
        assert ev.truth(Rep(zf_body(rng, 3, [0, 1]))) is not False


def test_zf_refutes_false():
    ev = ZFEval()
    for s in ['forall a. exists b. forall x. (x in b <-> x=x)',            # universal set
              'forall a. exists b. forall x. (x in b <-> ~x in x)',        # Russell
              'forall a. exists b. forall x. (x in b <-> (x in a & ~x in b))',   # captured Separation
              'forall x. forall y. ((forall z. (z in x -> z in y)) -> x=y)',
              'forall x. x in x', 'exists x. x in x | forall x. x in x']:
        r = ev.truth(parse(s))
        assert r is False, s
    # Infinity is true: must not be refuted although no HF set witnesses it
    assert ev.truth(parse(ZF_AXIOMS['Inf'])) is not False


def test_template_refuter():
    R = TemplateRefuter('PA')
    assert R.refuted(parse('(?A & forall x. (?P(x) -> ?Q(x))) -> forall x. ?P(x)'))
    assert R.refuted(parse('?t+?u=?v'))
    assert not R.refuted(T_IND)
    for T in U_AXIOMS.values():
        assert not R.refuted(T)
    Z = TemplateRefuter('ZF')
    assert Z.refuted(parse('forall a. exists b. forall x. (x in b <-> ?P(x, a))'))
    assert Z.refuted(parse('forall a. ?P(a)'))
    assert Z.refuted(parse('forall a. exists b. forall x. (x in b <-> (x in a & ?P(x, a, b)))'))
    for T in (T_SEP, T_EIND, T_REP):
        assert not Z.refuted(T)
