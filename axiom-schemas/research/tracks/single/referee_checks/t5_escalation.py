# Referee check of Prop F.8 (quadratic escalation chain) with an explicit witness template per step,
# and of the Thm F upper bound on random greedy chains.
from rc_core import *

def conj(fs):
    f = fs[0]
    for g in fs[1:]:
        f = AND(f, g)
    return f

def T0_of(D):
    info = DataInfo(D)
    T = D[0]
    for j, s in enumerate(info.slots):
        ys = sorted(info.Y[s])
        nm = ('f%d' if info.sort[s] == 'i' else 'P%d') % j
        T = replace_at(T, s, M(nm, *[V(y) for y in ys]))
    return T

for m in [2, 3, 4, 6]:
    b = m
    def sent(lhs):
        f = conj([EQ(l, Z) for l in lhs])
        for _ in range(b): f = ALL(f)
        return f
    d1 = sent([Z] * m); d2 = sent([('a',)] * m)
    chain = [d1, d2]
    for j in range(m):
        for k in range(b):
            lhs = [Z] * m; lhs[j] = V(k)
            chain.append(sent(lhs))
    ok = True
    for i in range(1, len(chain)):
        prev = chain[:i]
        T0 = T0_of(prev) if i >= 2 else prev[0]
        witness_ok = covers(T0, prev) and is_DT0(T0) and match(T0, chain[i]) is None
        feat_out = not DataInfo(prev).has_features(chain[i])
        ok = ok and witness_ok and feat_out
    N = max(size(s) for s in chain)
    print('m=b=%d: chain length %d (=2+m*b=%d), max size N=%d (=5m-1=%d), all escalations witnessed by explicit T_0: %s, lower bound 2+((N+1)/5)^2=%.1f, upper bound 2N^2+1=%d'
          % (m, len(chain), 2 + m * b, N, 5 * m - 1, ok, 2 + ((N + 1) / 5) ** 2, 2 * N * N + 1))
