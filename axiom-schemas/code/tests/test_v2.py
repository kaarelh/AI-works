"""v2 tests (after the referee's report): alignment-complete Min, the PA case split, the refuter's top/bot
pass, the genuine pattern lgg, the sharing pass, held-out de-duplication."""
import os
import random
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))

from dtrc.syntax import parse, pp, IN, H, EQ, ADD, ZERO, num, canon_params, P            # noqa
from dtrc.templates import equiv, geq, covers_all, is_DT0, instantiate, match             # noqa
from dtrc.mincover import MinCover, aligned_min, n_alignments                            # noqa
from dtrc.oracle_pa import PAEval                                                        # noqa
from dtrc.oracle_zf import ZFEval                                                        # noqa
from dtrc.refute import TemplateRefuter                                                  # noqa
from dtrc.baselines import pattern_lgg, pattern_lgg_formula                              # noqa
from dtrc.schemas import Sep, T_SEP, U_AXIOMS, Ind                                        # noqa
from dtrc.dtrc import DTRC                                                               # noqa
from dtrc.metrics import exact_for                                                       # noqa


def test_aligned_min_counterexample_R1():
    D = [parse('0=0 & w0=w0'), parse('w0=0 & w1=w1')]
    lit = MinCover(D).minimal()
    al, mc = aligned_min(D)
    assert [pp(T) for T in lit] == ['?f0=0 & ?f1=?f1']
    assert len(al) == 1 and equiv(al[0], parse('?f=0 & w0=w0'))
    assert covers_all(al[0], D) and geq(lit[0], al[0]) and not geq(al[0], lit[0])
    assert mc.differs


def test_aligned_min_single_alignment_when_a_datum_is_parameter_free():
    D = [parse('w0+0=w0'), parse('1+0=1'), parse('0+0=0')]
    assert n_alignments(D) == 1
    al, _ = aligned_min(D)
    lit = MinCover(D).minimal()
    assert len(al) == len(lit) and all(any(equiv(a, b) for b in lit) for a in al)


def test_aligned_min_rigid_parameter_target():
    # target with a rigid parameter c: (?P(x) -> x in c); data name c differently
    T = parse('forall x. (?P(x) -> x in c)')
    rng = random.Random(3)
    bodies = [IN(H(0), P('d')), EQ(H(0), H(0)), IN(H(0), H(0))]
    D = [canon_params(instantiate(T, {'P': b})) for b in bodies]
    al, _ = aligned_min(D)
    assert any(geq(T, M) for M in al)
    assert all(covers_all(M, D) and is_DT0(M) for M in al)


def test_pa_case_split_refutes_seed0_exhibit():
    q = parse('((Ex.0=0 & ~0=2) & (Ax.(Ey.x=0 & ~x=2) -> (Ey.y<Sx & ~Sx=2))) -> (Ax.Ey.y<Sx & ~Sx=2)')
    assert PAEval(split=0).truth(q) is None
    assert PAEval().truth(q) is False


def test_pa_case_split_certifies_pi1_truths():
    for s in ['forall x. (x=0 | 0<x)', 'forall x. (~x=1 | 0<x)', 'forall x. (x=0 | ~x*x=0)']:
        assert PAEval(split=0).truth(parse(s)) is None
        assert PAEval().truth(parse(s)) is True
    # witnesses are not constructed from terms: this true Pi2 sentence stays undecided
    assert PAEval().truth(parse('forall x. (x=0 | exists y. x=Sy)')) is None


def test_pa_case_split_sound_on_true_sentences():
    rng = random.Random(11)
    from dtrc.datasets import pa_motive
    from dtrc.schemas import T_IND
    ev = PAEval()
    for _ in range(150):
        assert ev.truth(Ind(pa_motive(rng))) is not False


def test_refuter_topbot_pass_refutes_zf_residual_merges():
    for s in ['Ax.Ey.Az.z in y <-> (z in x & (Au.?P0(u,z,x) -> ?P1(u,z,y)))',
              'Ax.Ey.Az.z in y <-> (z in x & (Au.?P0(u,y) -> ?P1(u,z,y)))']:
        assert TemplateRefuter('ZF', budget=400).refuted(parse(s))


def test_refuter_never_refutes_true_schema_templates():
    from dtrc.schemas import T_REP, T_EIND
    for T in (T_SEP, T_REP, T_EIND):
        assert not TemplateRefuter('ZF', budget=120).refuted(T)
    assert not TemplateRefuter('PA', budget=400).refuted(parse('(?P(0) & forall x. (?P(x) -> ?P(Sx))) -> forall x. ?P(x)'))


def test_universal_set_schema_refuted_by_generic_foundation():
    # UnionW/PowerW merge (untagged track Prop 7.1): refutable here because generics satisfy G notin G
    assert ZFEval().truth(parse('forall a. exists b. forall x. (x=x -> x in b)')) is False
    assert TemplateRefuter('ZF').refuted(parse('forall a. exists b. forall x. (?P(x, a) -> x in b)'))


def test_genuine_pattern_lgg_sep_example():
    D = [Sep(IN(H(0), H(1))), Sep(IN(H(1), H(0)))]
    assert equiv(pattern_lgg_formula(D), T_SEP)
    G = pattern_lgg(D)
    assert is_DT0(G) and covers_all(G, D)
    assert geq(T_SEP, G) and not geq(G, T_SEP)


def test_sharing_pass_gives_both_anchors():
    data = [parse(s) for s in ['0+0=0', '1+0=1', '2+0=2', '0+1=1', '0+3=3', '0*0=0', '1*0=0']]
    m0 = DTRC(TemplateRefuter('PA')).fit(data)
    m1 = DTRC(TemplateRefuter('PA'), share=True).fit(data)
    ex0 = [k for k, T in U_AXIOMS.items() if any(c.acc and exact_for(c.acc, T) for c in m0.clusters)]
    ex1 = [k for k, T in U_AXIOMS.items() if any(c.acc and exact_for(c.acc, T) for c in m1.clusters)]
    assert len(ex0) == 2 and sorted(ex1) == ['U_0add', 'U_add0', 'U_mul0']


def test_heldout_disjoint_from_training():
    from dtrc.datasets import pa_mix, heldout_pa, zf_mix, heldout_zf
    data = pa_mix(0)
    tr = set(canon_params(s) for s, _ in data)
    held = heldout_pa(0, exclude=tr)
    for k in ('Ind', 'U_add0', 'U_mul0', 'U_0add'):
        assert held[k] and not (set(held[k]) & tr)
    data = zf_mix(0)
    tr = set(canon_params(s) for s, _ in data)
    held = heldout_zf(0, exclude=tr)
    for k in ('Sep', 'Rep', 'EInd'):
        assert held[k] and not (set(held[k]) & tr)
