# Referee check: prior C8.2 / author's correction: minimal DT° covering templates of {Ind(x=x), Ind(0=x)}
import time
from rc_core import *
from rc_enum import *
x = ('z', 0)
D = [Ind(EQ(x, x)), Ind(EQ(Z, x))]
for d in D: print('datum', pp(d))
for kmax, amax in [(5, 1), (6, 2)]:
    t0 = time.time()
    Ts = enumerate_covering(D, kmax=kmax, amax=amax)
    assert all(is_DT0(T) and covers(T, D) for T in Ts)
    mins = minimal_elements(Ts)
    print('kmax=%d amax=%d: %d covering templates, %d minimal (up to equiv), %.1fs' % (kmax, amax, len(Ts), len(mins), time.time()-t0))
    for T in mins:
        print('   size %d  %s   <= T_ind: %s' % (size(T), pp(T), geq(Ind_T(), T)))
    # every enumerated template above some minimal one
    print('   every covering template >= some minimal:', all(any(geq(T, m) for m in mins) for T in Ts))
