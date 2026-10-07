# Remark to B2: occurrence/freshness guards learned from F' data do not rescue L_n.
# On F' data, z (B-slot) and z' (C-slot) are always instantiated by terms containing x, z'' (A-slot) by closed
# terms; so the strongest such guards are  x in FV(z), x in FV(z'), z'' closed.  Pad with 0*x.
from raw_common import *
from raw_search import pretty
from b2_family import Ln
for n in range(6):
    th = {'a': Z, 'b': mul(Z, X), 'c': add(S(Z), mul(Z, X))}
    s = subst_meta(Ln(n), th)
    assert is_sentence(s) and X in free_vars(th['b']) and X in free_vars(th['c']) and not free_vars(th['a'])
    assert truth(s) is False
    if n <= 1: print('n=%d guarded false instance:' % n, pretty(s))
print('guarded false instances exist for n=0..5: True')
