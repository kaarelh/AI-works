"""E6: the cautious k-union verifier over DT°_F templates (no clustering), small cases, without and with
refutation negatives (a block whose minimal templates are all refuted cannot be a slot of the union).

Data: Q's 7 axioms + m induction instances.  Bound k = 8 (= number of targets) and k = 9.
Queries: 8 held-out induction instances (motives disjoint from the data), 2 false non-instances.
Reported: number of held-out instances accepted, false sentences accepted, and a witness union for a
rejection (a member of the version space missing the query).
"""
import random
import time
from common import save, md_table, pp, TemplateRefuter
from dtrc.syntax import parse, EQ, NOT, ADD, MUL, LT, H, ZERO, S, P, ALL, EX, AND, OR, IMP
from dtrc.schemas import Q_AXIOMS, Ind
from dtrc.baselines import KUnion

X = H(0)
MOTIVES = {
    'x=x': EQ(X, X), '~x=0': NOT(EQ(X, ZERO)), 'x+0=x': EQ(ADD(X, ZERO), X),
    'Ey.x<y': EX(LT(('v', 1 - 1), ('v', 0))),     # placeholder replaced below
}
# Ey. x < y  (x = hole, y = bound): body ex(<(h0, v0))
MOTIVES['Ey.x<y'] = EX(LT(X, ('v', 0)))
HELD = [EQ(MUL(X, ZERO), ZERO), OR(EQ(X, ZERO), NOT(EQ(X, ZERO))), IMP(EQ(X, ZERO), EQ(ADD(X, X), X)),
        ALL(EQ(ADD(X, ('v', 0)), ADD(('v', 0), X))), LT(X, S(X)), AND(EQ(X, X), EQ(ZERO, ZERO)),
        NOT(LT(S(X), X)), EX(EQ(S(X), ('v', 0)))]
FALSE = [parse('(0=0 & forall x. (x=x -> Sx=Sx)) -> forall x. x=0'),
         parse('(0=0 & forall x. (x=0 -> x=0)) -> forall x. x=0')]


def main():
    t0 = time.time()
    Q = [parse(s) for s in Q_AXIOMS.values()]
    configs = [(['x=x', '~x=0'], 8), (['x=x', '~x=0'], 9), (['x=x', '~x=0', 'x+0=x'], 8),
               (['x=x', '~x=0', 'x+0=x'], 9), (['x=x', '~x=0', 'Ey.x<y'], 9)]
    rows = []
    witnesses = []
    R = TemplateRefuter('PA')
    for motives, k in configs:
        D = Q + [Ind(MOTIVES[m]) for m in motives]
        for neg in (False, True):
            t = time.time()
            ku = KUnion(D, k, refuter=R if neg else None)
            acc_held = 0
            for b in HELD:
                ok, wit = ku.accepts(Ind(b), return_witness=True)
                acc_held += int(ok)
                if not ok and len([w for w in witnesses if w[0] == (tuple(motives), k, neg)]) == 0:
                    witnesses.append(((tuple(motives), k, neg), pp(Ind(b)), [pp(T) for T in wit]))
            acc_false = sum(int(ku.accepts(f)) for f in FALSE)
            rows.append([' , '.join(motives), k, 'yes' if neg else 'no', '%d/%d' % (acc_held, len(HELD)),
                         '%d/%d' % (acc_false, len(FALSE)), '%.1f' % (time.time() - t)])
    text = '# E6: cautious k-union verifier over DT°_F (no clustering), Q + induction\n\n'
    text += 'Command: `python3 experiments/e6_kunion.py`.\n\n'
    text += md_table(['induction motives in data', 'k', 'refutation negatives', 'held-out Ind accepted',
                      'false non-instances accepted', 'time (s)'], rows)
    text += '\nWitness unions (a member of the version space that misses the query):\n\n'
    for (cfg, q, wit) in witnesses:
        text += '* motives %s, k=%d, negatives=%s; query `%s`:\n' % (list(cfg[0]), cfg[1], cfg[2], q)
        for w in wit:
            text += '    * `%s`\n' % w
    text += '\nWall time: %.1fs\n' % (time.time() - t0)
    save('e6_kunion', text, {'rows': rows})
    print(text)


if __name__ == '__main__':
    main()
