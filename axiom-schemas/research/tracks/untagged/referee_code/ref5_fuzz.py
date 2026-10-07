# Referee check 5: one-sided soundness fuzz of the refuters on sentences TRUE by construction.
import sys, random
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code'); sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/referee_code')
from dtlib import *
from practice import *
import refuters as R
rng = random.Random(2024)
def taut(f, g):
    return rng.choice([IMP(f, f), OR(f, NOT(f)), NOT(AND(f, NOT(f))), IMP(AND(IMP(f, g), f), g),
                       IFF(f, NOT(NOT(f))), IMP(ALL(plug(f, [V(0)]) if False else f), f)])
def close_hole(m, t):
    return plug(m, [t])
bad = []
n = 0
# arithmetic: induction instances with parameters, Q axioms, tautologies over random motives
for i in range(1500):
    m = rand_motive(rng, 2, 0, ('p1', 'p2'))
    s = canon_params(Ind(m))
    cands = [s, canon_params(taut(close_hole(m, P('p1')), close_hole(rand_motive(rng, 2, 0, ('p1',)), Z)))]
    for c in cands:
        n += 1
        if R.refute_arith(c, B=3) is not None: bad.append(('arith', pp(c)))
        if size(c) <= 45 and R.logic_unsat([c]): bad.append(('logic', pp(c)))
for k, q in Q.items():
    if R.refute_arith(q) is not None or R.logic_unsat([q]): bad.append(('Q', k))
print('arith/logic: tested %d true sentences, refuted: %d' % (n, len(bad)))
for b in bad[:5]: print('  ', b)
bad = []; n = 0
for i in range(600):
    k = rng.choice(['Sep', 'Rep', 'EInd'])
    s = schema_instance(k, rng)
    f = rand_set_formula(rng, 0, 2, 0, ('a1', 'a2'))
    for c in (s, canon_params(taut(f, rand_set_formula(rng, 0, 2, 0, ('a1',))))):
        n += 1
        if R.refute_hf(c, n=3) is not None: bad.append(('hf', pp(c)))
        if size(c) <= 45 and R.logic_unsat([c]): bad.append(('logic', pp(c)))
for k, s in ZF.items():
    n += 1
    if R.refute_hf(s, n=3) is not None or R.logic_unsat([s]): bad.append(('ZF', k))
print('set theory: tested %d true sentences, refuted: %d' % (n, len(bad)))
for b in bad[:5]: print('  ', b)
