# Track "cases": pools of lambda-bodies (holes h0.. = the schema's arguments) for the ZF schemas.
from st_core import *
a = Par('a'); b = Par('b')
h0, h1, h2 = H(0), H(1), H(2)
w = V(0)          # inside one internal binder of a body

POOL1 = {   # unary bodies, hole h0 = x
    'x∈x': IN(h0, h0), 'x=x': EQ(h0, h0), 'x∈a': IN(h0, a), '¬x∈a': NOT(IN(h0, a)), '¬x=x': NOT(EQ(h0, h0)),
    'a∈x∧x∈b': AND(IN(a, h0), IN(h0, b)), 'x∈a→a∈x': IMP(IN(h0, a), IN(a, h0)), 'x=a∨x∈a': OR(EQ(h0, a), IN(h0, a)),
    'x∈a↔x∈b': IFF(IN(h0, a), IN(h0, b)),
    'Aw(w∈x→w∈a)': ALL(IMP(IN(w, h0), IN(w, a))), 'Ew(w∈x)': EX(IN(w, h0)), 'Aw¬w∈x': ALL(NOT(IN(w, h0))),
    # closed (x not free)
    'a∈b': IN(a, b), '¬a=a': NOT(EQ(a, a)), 'Aw(w=w)': ALL(EQ(w, w)), 'Ew(w∈a)': EX(IN(w, a)),
}
POOL2 = {   # binary bodies (h0, h1) = (x, z) for Sep, (x, y) for ReplJ
    'x∈z': IN(h0, h1), 'z∈x': IN(h1, h0), 'x=z': EQ(h0, h1), '¬x∈z': NOT(IN(h0, h1)), '¬x=a': NOT(EQ(h0, a)),
    'x∈a∧z∈a': AND(IN(h0, a), IN(h1, a)), 'x∈a': IN(h0, a), 'z∈a': IN(h1, a), 'x∈x∨z=z': OR(IN(h0, h0), EQ(h1, h1)),
    'x∈z→x=z': IMP(IN(h0, h1), EQ(h0, h1)), 'x∈a↔z∈a': IFF(IN(h0, a), IN(h1, a)),
    'Aw(w∈x→w∈z)': ALL(IMP(IN(w, h0), IN(w, h1))), 'Ew(x∈w∧w∈z)': EX(AND(IN(h0, w), IN(w, h1))),
    'Ew(w∈x)': EX(IN(w, h0)), 'a∈b': IN(a, b), 'Aw(w=w)': ALL(EQ(w, w)),
}
POOL3 = {   # ternary bodies (h0, h1, h2) = (x, y, A)
    'y=x': EQ(h1, h0), 'x∈y': IN(h0, h1), 'y∈A': IN(h1, h2), '¬y∈x': NOT(IN(h1, h0)), '¬x=A': NOT(EQ(h0, h2)),
    'y=x∧x∈A': AND(EQ(h1, h0), IN(h0, h2)), 'x∈A→y=A': IMP(IN(h0, h2), EQ(h1, h2)), 'y=x∨y=A': OR(EQ(h1, h0), EQ(h1, h2)),
    'y∈a↔x∈a': IFF(IN(h1, a), IN(h0, a)),
    'Aw(w∈y↔w∈x)': ALL(IFF(IN(w, h1), IN(w, h0))), 'Aw(w∈y↔w=x)': ALL(IFF(IN(w, h1), EQ(w, h0))),
    'Ew(w∈y∧w∈A)': EX(AND(IN(w, h1), IN(w, h2))),
    'x∈a': IN(h0, a), 'y∈a': IN(h1, a), 'a∈b': IN(a, b), 'Aw(w=w)': ALL(EQ(w, w)),
}
def pool_for(name):
    n = len(SCHEMAS[name]['args'])
    return {1: POOL1, 2: POOL2, 3: POOL3}[n]
