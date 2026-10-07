# Referee check of Prop G.3 (lgg existence criterion) and Cor G.4 against brute force minimal elements.
import sys, time, random, signal
from collections import Counter
from rc_core import *
from rc_enum import enumerate_covering, minimal_elements
from rc_random import *
from rc_anchor import events
class TO(Exception): pass
def handler(s, f): raise TO()
signal.signal(signal.SIGALRM, handler)
seed = int(sys.argv[1]); ncases = int(sys.argv[2])
rng = random.Random(seed)
TYPES = ['f1', 'f2', 'c0', 'P1', 'P2', 'Q0']
st = Counter(); ex = []
def g3(info):
    if any(r in info.C for (s, r, u) in info.feats):
        return False, None
    slots = info.slots
    edges = {(s, r): u for (s, r, u) in info.feats}
    # weak components
    parent = {s: s for s in slots}
    def find(a):
        while parent[a] != a: a = parent[a]
        return a
    for (s, r) in edges: parent[find(s)] = find(r)
    comps = {}
    for s in slots: comps.setdefault(find(s), []).append(s)
    T = info.D[0]
    for j, K in enumerate(comps.values()):
        src = [s for s in K if all((s, x) in edges for x in K if x != s)]
        if not src: return False, None
        s0 = src[0]
        nm = ('f%d' if info.sort[s0] == 'i' else 'P%d') % j
        ys = sorted(info.Y[s0])
        for x in K:
            if x == s0:
                T = replace_at(T, x, M(nm, *[V(y) for y in ys]))
            else:
                u = edges[(s0, x)]
                T = replace_at(T, x, M(nm, *[u[y] for y in ys]))
    return True, T
done = 0
t0 = time.time()
while done < ncases:
    chosen = rng.sample(TYPES, rng.choice([1, 1, 2]))
    metas_ = {t[0] + str(i): int(t[1]) for i, t in enumerate(chosen)}
    T = random_template(rng, metas_)
    if T is None: continue
    N = rng.choice([2, 2, 3])
    D = [inst(T, {nm: rbody(rng, nm, ar, d=rng.choice([0, 1, 2])) for nm, ar in metas_.items()}) for _ in range(N)]
    if len(set(D)) < N: continue
    info = DataInfo(D)
    kmax = len(info.slots) + 1; amax = max([len(info.Y[s]) for s in info.slots] + [0])
    if kmax > 7 or amax > 3: continue
    done += 1
    signal.alarm(90)
    try:
        Ts = enumerate_covering(D, kmax=kmax, amax=amax)
        mins = minimal_elements(Ts)
        signal.alarm(0)
    except (TO, RuntimeError):
        signal.alarm(0); st['timeout'] += 1; continue
    ok, Tall = g3(info)
    single = (len(mins) == 1)
    st['G3=%s brute_single=%s' % (ok, single)] += 1
    if ok and single:
        same = geq(Tall, mins[0]) and geq(mins[0], Tall) and covers(Tall, D) and is_DT0(Tall)
        st['T_all equals brute lgg: %s' % same] += 1
    ev, _ = events(T, D)
    if ev['R*'] and ev['N'] and ev['U']:
        st['anchor: lgg exists=%s, lgg==T*: %s' % (ok, ok and geq(Tall, T) and geq(T, Tall))] += 1
print('seed', seed, 'cases', ncases, '%.0fs' % (time.time() - t0))
for k, v in sorted(st.items()): print('  %-45s %d' % (k, v))
