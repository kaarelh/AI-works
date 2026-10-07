"""R17: fidelity of the 'pattern lgg' baseline.  dtrc.baselines.pattern_lgg builds on the DT°_F common-prefix
tree, where an atom whose term disagreement has a bound variable becomes a formula slot (?P(x,..) for the whole
atom).  A genuine higher-order pattern anti-unifier keeps the agreed atom head and generalises the term with
f(x,..).  Count E2 data sets (same seeds) where pattern_lgg is 'exact' although its tree contains such an atom
(the genuine pattern lgg is then strictly more specific than the target there, hence not exact)."""
import sys, random
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
from dtrc.mincover import _build_tree, build_tree
from dtrc.baselines import pattern_lgg
from dtrc.templates import equiv
from dtrc.schemas import T_SEP, T_REP, T_EIND, T_IND, Sep, Rep, EInd, Ind
from dtrc.datasets import zf_body, pa_motive
from dtrc.syntax import ATOM_HEADS
SCHEMAS = {'Sep': (T_SEP, lambda r: Sep(zf_body(r, 2, [0]))), 'Rep': (T_REP, lambda r: Rep(zf_body(r, 3, [0, 1]))),
           'EInd': (T_EIND, lambda r: EInd(zf_body(r, 1, [0]))), 'Ind': (T_IND, lambda r: Ind(pa_motive(r)))}
for name, (T, gen) in SCHEMAS.items():
    for N in (2, 3, 4):
        exact = affected = 0
        for seed in range(30):
            rng = random.Random(seed * 7919 + N)
            D = list(dict.fromkeys(gen(rng) for _ in range(N)))
            r0, n0 = _build_tree(D)
            conv = sum(1 for nd in n0 if not nd.slot and nd.proto is not None and nd.proto[0] in ATOM_HEADS
                       and any(c.slot for c in nd.children))
            r1, n1 = build_tree(D)
            fsl = sum(1 for nd in n1 if nd.slot and nd.proto is None and nd.children == [] and
                      any(m.path == nd.path and not m.slot for m in n0))
            ex = equiv(pattern_lgg(D), T)
            exact += ex
            affected += int(ex and fsl > 0)
        print(name, 'N=%d' % N, 'pattern_lgg exact %d/30, of which with an atom generalised to ?P (genuine pattern lgg not exact): %d' % (exact, affected))
