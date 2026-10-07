# Referee C, r2: anchor theorems C3 (DT: anchor iff R&N) and C7 (SO°: anchor iff R&B) on NEW motives
# (v, E, *, rebinding, shielding under binders, random motives), independent enumerator.
# For each data set D (pairs, plus some triples), enumerate every covering template with
# metavariable-free arguments (arity <= 2, argument size <= 3, size <= SMAX), classify each as
#   good (>= T_ind) / bad (misses a held-out genuine instance) / undetermined.
import sys, random, itertools, time
from rc_core import *
from rc_enum import enum_covering
from rc_pool import *

SMAX = int(sys.argv[1]) if len(sys.argv) > 1 else 14
NPAIRS = int(sys.argv[2]) if len(sys.argv) > 2 else 120
P = pool(seed=11, n=30)
names = list(P)
HELD = [Ind(m) for m in P.values()] + [Ind(EQ(X, X)), Ind(NOT(EQ(X, Z())))]
rng = random.Random(5)
pairs = list(itertools.combinations(names, 2))
rng.shuffle(pairs)
# make sure the interesting categories are present
must = [('Sx=S0', '~Sx=0'), ('Sx*Sx=0', 'x=0|~x=0'), ('Ay.Sx=y', '~Sx=0'), ('Ey.(x+0)*y=0', 'SSx=x+S0'),
        ('Ay.x*y=y*x', 'Ey.x=y*y'), ('x=0&Ay.y=y', 'Ey.Az.y=z'), ('0=0', 'Ey.Az.y=z'), ('Ay.S(x+y)=0', '~(x=x)'),
        ('x=x', '~x=0'), ('Ey.y=x', 'x*x=x'), ('0=0>0=S0', 'Ax.x=x-ish')]
sets = must + [p for p in pairs if p not in must][:NPAIRS]
sets += [tuple(rng.sample(names, 3)) for _ in range(15)]

def shielding_terms(m):
    # parent terms (as terms at depth 1: hole -> v0) of free x occurrences; internal vars excluded
    out = []
    def walk(t, parent):
        if t[0] == 'h':
            if parent is not None: out.append(parent)
            return
        if t[0] in FORMH:
            for c in children(t): walk(c, None)
            return
        for c in children(t): walk(c, t)
    walk(m, None)
    return out

def T_Theta(ms):
    th = []
    for m in ms:
        for t in shielding_terms(m):
            u = plug(t, [V(0)], 1)
            if u not in th: th.append(u)
    return IMP(MV('B'), ALL(MV('Q', *th)))

def classify(T):
    if geq(T, T_IND): return 'good'
    for h in HELD:
        if not covers(T, h): return 'bad'
    return 'undet'

stats = {}
thetaOK = []
beyond = []
disagree_DT = disagree_SO = undet = 0
t0 = time.time()
for ds in sets:
    ms = [P[n] for n in ds]
    D = [Ind(m) for m in ms]
    R, N, B = pR(ms), pN(ms), pB(ms)
    smax = SMAX if R else 7          # without (R) a size-7 witness suffices (C3 'only if')
    Ts = enum_covering(D, smax, amax=3, ar_F=(0, 1, 2), ar_T=(0, 1))
    cls = {T: classify(T) for T in Ts}
    undet += sum(1 for v in cls.values() if v == 'undet')
    dt_anchor = all(cls[T] == 'good' for T in Ts if is_DT(T))
    so_anchor = all(cls[T] == 'good' for T in Ts)
    if not R:   # bounded search cannot certify an anchor; only a bad template certifies non-anchor
        dt_anchor = dt_anchor and None
        so_anchor = so_anchor and None
    if R and dt_anchor != (R and N): disagree_DT += 1; print('DT DISAGREE', ds, R, N, B)
    if not B:
        TT = T_Theta(ms)
        tt_cov = all(so_covers(TT, d) for d in D); tt_miss = not so_covers(TT, Ind(EQ(X, X)))
        thetaOK.append(tt_cov and tt_miss)
        if so_anchor and tt_cov and tt_miss:
            so_anchor = False; beyond.append(ds)   # T_Theta (arity 3) is a bad SO template beyond the enumeration bound
    stats.setdefault((R, N, B), []).append((dt_anchor, so_anchor))
    if R and so_anchor != (R and B): disagree_SO += 1; print('SO DISAGREE', ds, R, N, B)
    if not R and (dt_anchor is not None and dt_anchor) : print('non-R but no bad DT template <=7 found', ds)
    if ds in must:
        worst = sorted([T for T in Ts if cls[T] == 'bad'], key=size)[:2]
        print('%-34s R=%d N=%d B=%d  #cover=%5d  DT-anchor=%s SO-anchor=%s  smallest bad: %s' %
              (' , '.join(ds), R, N, B, len(Ts), dt_anchor, so_anchor,
               '; '.join('%s[%d%s]' % (pp(T), size(T), ',DT' if is_DT(T) else '') for T in worst)))
    sys.stdout.flush()
print()
print('data sets: %d   (%.0f s)   undetermined templates: %d' % (len(sets), time.time() - t0, undet))
for key in sorted(stats):
    v = stats[key]
    print('R=%d N=%d B=%d : %3d sets; DT-anchor %s ; SO-anchor %s' % (key + (len(v),
          {str(a) for a, b in v}, {str(b) for a, b in v})))
print('T_Theta (proof of C7 only-if) covers D and misses Ind(x=x) on all %d non-(B) sets: %s' % (len(thetaOK), all(thetaOK)))
print('non-(B) sets whose only bad SO template found has arity > 2 (T_Theta):', beyond)
print('disagreements with prediction  DT: %d   SO: %d' % (disagree_DT, disagree_SO))
