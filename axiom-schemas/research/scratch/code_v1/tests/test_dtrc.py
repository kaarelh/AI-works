import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))

from dtrc.datasets import pa_mix, zf_mix                       # noqa
from dtrc.refute import TemplateRefuter                        # noqa
from dtrc.dtrc import DTRC                                     # noqa
from dtrc.metrics import adjusted_rand, purity, exact_for       # noqa
from dtrc.schemas import pa_targets, zf_targets, T_IND          # noqa
from dtrc.syntax import canon_params, parse                    # noqa
from dtrc.baselines import pattern_lgg, FOLgg, KUnion           # noqa
from dtrc.templates import equiv                                # noqa


def _run(data, lang):
    """ARI over data that are instances of exactly one target (e.g. 0+0=0 is an instance of both
    t+0=t and 0+t=t and is excluded)"""
    from dtrc.metrics import targets_of
    targets = pa_targets() if lang == 'PA' else zf_targets()
    m = DTRC(TemplateRefuter(lang)).fit([s for s, _ in data])
    lab = {canon_params(s): l for s, l in data}
    sents = [s for s in lab if len(targets_of(s, targets)) == 1]
    pred = m.labels_for(sents)
    return m, adjusted_rand([lab[s] for s in sents], pred)


def test_dtrc_pa_small():
    m, ari = _run(pa_mix(1, n_ind=12, n_univ=(4, 4, 3)), 'PA')
    assert ari == 1.0
    assert any(c.acc and exact_for(c.acc, T_IND) for c in m.clusters)


def test_dtrc_zf_small():
    m, ari = _run(zf_mix(1, n_sep=5, n_rep=4, n_eind=4), 'ZF')
    assert ari == 1.0


def test_ari():
    assert adjusted_rand([1, 1, 2, 2], [5, 5, 6, 6]) == 1.0
    assert adjusted_rand([1, 1, 2, 2], [5, 6, 5, 6]) < 0.1
    assert purity([1, 1, 2], [0, 0, 0]) == 2 / 3


def test_pattern_lgg_induction_is_T12():
    from dtrc.schemas import Ind
    from dtrc.syntax import EQ, NOT, H, ZERO
    D = [Ind(EQ(H(0), H(0))), Ind(NOT(EQ(H(0), ZERO)))]
    T12 = parse('(?A & forall x. (?P(x) -> ?Q(x))) -> forall x. ?P(x)')
    assert equiv(pattern_lgg(D), T12)


def test_fo_lgg_unsound_on_induction():
    from dtrc.schemas import Ind
    from dtrc.syntax import EQ, ADD, H, ZERO
    D = [Ind(EQ(ADD(H(0), ZERO), H(0))), Ind(EQ(ADD(ZERO, H(0)), H(0)))]
    for enc in ('named', 'debruijn'):
        L = FOLgg(D, enc)
        # the false sentence (0+0=0) & Ax(0+0=x -> 0+S0=Sx) -> Ax(0+0=x) is accepted (prior work)
        q = parse('(0+0=0 & forall x. (0+0=x -> 0+S0=Sx)) -> forall x. 0+0=x')
        assert L.accepts(q)
