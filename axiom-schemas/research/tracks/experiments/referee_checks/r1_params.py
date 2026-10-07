"""Referee check R1: Min(D) with parameters whose canonical names do not align across data."""
import sys
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
from dtrc.syntax import parse, pp
from dtrc.templates import match, geq, covers_all, is_DT0, canon
from dtrc.mincover import MinCover

cases = [
    (['0=0 & w=w', 'a=0 & b=b'], '?f=0 & w=w'),
    # parameter in a motive-like slot of induction data
    (['(0<a & b=b & forall x.(x<a & b=b -> Sx<a & b=b)) -> forall x. (x<a & b=b)',
      '(0<b & b=b & forall x.(x<b & b=b -> Sx<b & b=b)) -> forall x. (x<b & b=b)'], None),
]
for D, cand in cases:
    D = [parse(s) for s in D]
    print('D =', [pp(d) for d in D])
    mins = MinCover(D).minimal()
    for M in mins:
        print('  computed min:', pp(M))
    if cand:
        C = parse(cand)
        print('  candidate', pp(C), 'DT0:', is_DT0(C), 'covers:', covers_all(C, D))
        print('  candidate strictly below some computed min:',
              [pp(M) for M in mins if geq(M, C) and not geq(C, M)])
        print('  candidate above some computed min:', [pp(M) for M in mins if geq(C, M)])
