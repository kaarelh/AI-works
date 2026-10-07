# Referee check of Cor D.1-D.3 specializations on Ind, Separation, Replacement, eps-Induction
# with independent code; brute force where feasible.
import sys, random, time, signal, itertools
from collections import Counter
from rc_core import *
from rc_enum import enumerate_covering
from rc_random import *
from rc_anchor import *
class TO(Exception): pass
def handler(s, f): raise TO()
signal.signal(signal.SIGALRM, handler)
P = 'P'
SEP = ALL(EX(ALL(IFF(IN(V(0), V(1)), AND(IN(V(0), V(2)), M(P, V(0), V(2)))))))
REP = ALL(IMP(ALL(IMP(IN(V(0), V(1)), EX(AND(M(P, V(1), V(0), V(2)), ALL(IMP(M(P, V(2), V(0), V(3)), EQ(V(0), V(1)))))))),
              EX(ALL(IMP(IN(V(0), V(2)), EX(AND(IN(V(0), V(2)), M(P, V(1), V(0), V(3)))))))))
EIND = IMP(ALL(IMP(ALL(IMP(IN(V(0), V(1)), M(P, V(0)))), M(P, V(0)))), ALL(M(P, V(0))))
IND = Ind_T()
TEMPL = {'Ind': (IND, 1), 'Sep': (SEP, 2), 'Rep': (REP, 3), 'EpsInd': (EIND, 1)}
seed = int(sys.argv[1]); ncases = int(sys.argv[2]); do_enum = len(sys.argv) > 3
rng = random.Random(seed)
def biased_body(ar):
    r = rng.random()
    if r < 0.5:
        return rbform(rng, ar, 0, rng.choice([0, 1, 2]))
    # low-diversity bodies: few roots, often missing holes
    zs = [('z', m) for m in range(ar)] + [Z]
    a, b = rng.choice(zs), rng.choice(zs)
    return rng.choice([EQ(a, b), EQ(a, b), IN(a, b), NOT(EQ(a, b))])
for name, (T, ar) in TEMPL.items():
    st = Counter(); t0 = time.time()
    for _ in range(ncases):
        N = rng.choice([1, 2, 2, 3])
        bodies = [biased_body(ar) for _ in range(N)]
        D = [inst(T, {P: b}) for b in bodies]
        if len(set(D)) < N:
            st['dup'] += 1; continue
        ev, _ = events(T, D)
        RN = ev['R'] and ev['N']
        full = ev['R*'] and ev['N'] and ev['U']
        ft, q = feat_truth(T, D, extra_rng=rng, n_random=20)
        st['RN=%s full=%s feat=%s' % (RN, full, ft)] += 1
        if do_enum and N >= 2:
            info = DataInfo(D)
            kmax = len(info.slots) + 1; amax = max([len(info.Y[s]) for s in info.slots] + [0])
            signal.alarm(40)
            try:
                Ts = enumerate_covering(D, kmax=kmax, amax=amax, extra_pool=False)
                signal.alarm(0)
            except (TO, RuntimeError):
                signal.alarm(0); st['enum_timeout'] += 1; continue
            insts = [inst(T, {P: b}) for b in candidate_bodies(P, ar)] + [inst(T, {P: rbform(rng, ar, 0, 2)}) for _ in range(20)]
            enum_anchor = all(match(U, s) is not None for U in Ts for s in insts)
            st['enum=%s RN=%s' % (enum_anchor, RN)] += 1
    print(name, 'N cases', ncases, '%.0fs' % (time.time() - t0))
    for k, v in sorted(st.items()): print('   %-34s %d' % (k, v))
    sys.stdout.flush()
