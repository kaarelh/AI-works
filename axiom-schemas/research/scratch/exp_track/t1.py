from dtrc.syntax import *
from dtrc.templates import *
from dtrc.schemas import *
from dtrc.mincover import *
import time, sys
ta0 = sys.argv[1] != 'full' if len(sys.argv) > 1 else True
def body(s):
    f = parse(s, canon=False)
    def go(t):
        if t==('p','X'): return ('h',0)
        if t[0] in ('v','p','h','0'): return t
        return rebuild(t,[go(k) for k in kids(t)])
    return go(f)
tests = [['X=X','~X=0'], ['X=X'], ['X=X','0=X'], ['X=X','X+0=X'], ['X=0','S X=0'], ['0=0','~0=S0'], ['forall y. y+X=X+y', 'forall y. (X=y -> y=X)']]
for ms in tests:
    D = [Ind(body(m)) for m in ms]
    t=time.time(); mins, mc = min_covering(D, term_arity0=ta0); dt=time.time()-t
    print(ms, 'slots', len(mc.slots), 'min', len(mins), 'trunc', mc.truncated, '%.3fs'%dt)
    for T in mins: print('    ', pp(T), '  >=T_ind' if geq(T, T_IND) else '', ' ==T_ind' if equiv(T,T_IND) else '')
s1 = parse('(forall x. x=0) & ((forall x. x=x) & 0=0)'); s2 = parse('(forall x. ~x=0) & ((forall x. ~x=x) & ~0=0)')
mins, mc = min_covering([s1,s2], term_arity0=ta0); print('C8.1:', [pp(T) for T in mins])
