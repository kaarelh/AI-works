# Referee exploration of Conjecture F.7 (equation-kill steps): skeleton Ax.Ay.(c_1=0 & ... & c_m=0).
# Greedy: from random initial data, repeatedly add a datum that keeps C(D) and all scopes Y and kills as
# few Eq pairs as possible (>=1).  Candidate data are built by propagation along surviving equations.
import sys, random, itertools
from rc_core import *
seed = int(sys.argv[1]); trials = int(sys.argv[2]); ms = [int(a) for a in sys.argv[3].split(',')]
rng = random.Random(seed)
def terms(sz):
    out = {1: [V(0), V(1), Z]}
    for s in range(2, sz + 1):
        out[s] = [S(t) for t in out[s - 1]]
        for a in range(1, s - 1):
            out[s] += [ADD(t, u) for t in out[a] for u in out[s - 1 - a]]
    return [t for s in out for t in out[s]]
U = terms(3)
def sent(cs):
    f = EQ(cs[0], Z)
    for c in cs[1:]:
        f = AND(f, EQ(c, Z))
    return ALL(ALL(f))
def state(D):
    info = DataInfo(D)
    return info, frozenset(info.C), tuple(sorted((s, tuple(sorted(info.Y[s]))) for s in info.slots)), {(s, r): u for (s, r, u) in info.feats}
for m in ms:
    best = 0
    for tr in range(trials):
        D = [sent([rng.choice(U) for _ in range(m)]) for _ in range(2)]
        info, C0, Y0, E = state(D)
        if len(info.slots) != m:
            continue
        slotpos = info.slots
        kills = 0
        while True:
            pairs = [p for p in E if p[0] in slotpos and p[1] in slotpos]
            best_q, best_k = None, None
            cands = []
            for target in pairs:
                Ep = {p: u for p, u in E.items() if p != target and p[1] in slotpos}
                indeg = {s: [p for p in Ep if p[1] == s] for s in slotpos}
                free = [s for s in slotpos if not indeg[s]]
                for _ in range(60):
                    q = {s: rng.choice(U) for s in free}
                    # propagate
                    changed = True; ok = True
                    while changed and ok:
                        changed = False
                        for (a, b), u in Ep.items():
                            if a in q and b not in q:
                                try:
                                    q[b] = subst_free(q[a], u)
                                except Fail:
                                    ok = False; break
                                changed = True
                    if not ok or len(q) < m:
                        continue
                    cands.append(sent([q[s] for s in sorted(slotpos)]))
            for cq in cands:
                info2, C2, Y2, E2 = state(D + [cq])
                if C2 != C0 or Y2 != Y0:
                    continue
                k = len(E) - len(E2)
                if k >= 1 and (best_k is None or k < best_k):
                    best_q, best_k = cq, k
            if best_q is None:
                break
            D.append(best_q); kills += 1
            info, C0, Y0, E = state(D)
        best = max(best, kills)
    print('m=%d slots: max kill-steps found %d (m(m-1)=%d)' % (m, best, m * (m - 1)))
    sys.stdout.flush()
