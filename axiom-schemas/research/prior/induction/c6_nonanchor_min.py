# C6: what the cautious verifier over DT accepts BEFORE an anchor: the minimal determinate covering
# templates of non-anchor induction data (unique in all cases tried, i.e. an lgg exists here even
# though DT is not unitary in general), and they are all specializations of T_ind (so sound).
import sys, time
from so_core import *
from so_enum import enumerate_covering
from so_pool import *

def minimal(Ts):
    Ts = list(Ts)
    out = []
    for T in Ts:
        if not any(subsumes(T, U) and not subsumes(U, T) for U in Ts):
            out.append(T)
    # collapse equivalents
    reps = []
    for T in out:
        if not any(subsumes(T, U) and subsumes(U, T) for U in reps): reps.append(T)
    return reps

CASES = [(['x=x', 'x+0=x'], 23), (['x=x', '0=x'], 23), (['x=0', 'Sx=0'], 23), (['0=0', '~0=S0'], 16),
         (['Ay.y+x=x+y', 'Ay.(x=y->y=x)'], 22), (['x=x'], 19)]
# (a same-connective pair such as {x=0&x=x, 0=0&x=x} needs size bound >= 31 and was too slow to enumerate)
for names, s in CASES:
    t0 = time.time()
    D = [Ind(POOL[n]) for n in names]
    F = enumerate_covering(D, s, amax=2, maxar=2, arities_T=(0, 1), arities_F=(0, 1, 2))
    DT = [T for T in F if is_determinate(T)]
    mins = minimal(DT)
    print('D = %s, size bound %d: %d determinate covering templates; minimal up to equivalence: %d  (%.0f s)'
          % (names, s, len(DT), len(mins), time.time() - t0))
    for T in mins:
        print('    %2d %s   >= ... is an instance of T_ind (T_ind >= T): %s' % (size(T), pp(T), subsumes(T_IND, T)))
    sys.stdout.flush()
