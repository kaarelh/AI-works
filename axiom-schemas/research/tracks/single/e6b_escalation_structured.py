# e6b: structured search for long escalation chains of type (gamma) (Theorem F): the skeleton is fixed
#   Ax ( t_1 = 0 & t_2 = 0 & ... & t_m = 0 ),
# the first data make every t_j a slot with scope {x} and many equation features (a preorder
# j -> k iff a_j <= a_k from columns (S^{a_j} x, 0)); afterwards a greedy adversary picks, among
# random candidate queries that keep C and Y fixed, one that kills the FEWEST equation pairs (>= 1).
# Question: can the number of kills (escalations) grow faster than linearly in m?
import sys, random, time
from dtcore import *
from dtfeat import Prefix

SEED = int(sys.argv[1]) if len(sys.argv) > 1 else 1
rng = random.Random(SEED)


def conj(parts):
    f = parts[0]
    for g in parts[1:]:
        f = AND(f, g)
    return f


def sentence(ts):
    return ALL(conj([eq(t, Z) for t in ts]))


def Sk(t, k):
    for _ in range(k):
        t = S(t)
    return t


def pool_terms():
    x = V(0)
    base = [x, Z, PA, PB, S(x), S(Z), S(PA), add(x, Z), add(Z, x), add(x, x), add(x, PA), add(PA, x),
            S(S(x)), S(S(Z)), add(S(x), Z), S(add(x, Z)), add(x, S(Z)), add(PA, PB)]
    return base


POOL = pool_terms()
print('m  kills(gamma-steps)  #eq-pairs-initial  time')
for m in [3, 4, 5, 6, 8, 10, 12]:
    best = 0
    t0 = time.time()
    for trial in range(6):
        a = [rng.randint(0, 2) for _ in range(m)]
        D = [sentence([Sk(V(0), aj) for aj in a]), sentence([Z] * m)]
        P = Prefix(D)
        C0, Y0 = set(P.C), dict(P.Y)
        E = {(s, r) for (s, r, u) in P.eq_features()}
        n0 = len(E)
        kills = 0
        while True:
            bestq, bestE = None, None
            for _ in range(250):
                # candidate: slot contents of a random earlier datum, a few slots replaced by pool terms
                d = rng.choice(D)
                parts = []
                def flat(f):
                    if f[0] == 'and':
                        flat(f[1]); flat(f[2])
                    else:
                        parts.append(f[1])
                flat(d[1])
                cur = list(parts)
                for j in range(m):
                    if rng.random() < 0.3:
                        cur[j] = rng.choice(POOL)
                q = sentence(cur)
                if P.accepts(q):
                    continue
                Pq = Prefix(D + [q])
                if set(Pq.C) != C0 or dict(Pq.Y) != Y0:
                    continue
                Eq_ = {(s, r) for (s, r, u) in Pq.eq_features()}
                if bestE is None or len(Eq_) > len(bestE):
                    bestq, bestE = q, Eq_
            if bestq is None:
                break
            D.append(bestq)
            P = Prefix(D)
            assert {(s, r) for (s, r, u) in P.eq_features()} == bestE
            E = bestE
            kills += 1
        best = max(best, kills)
    print('%2d  %3d  %4d   %.1fs' % (m, best, n0, time.time() - t0))
