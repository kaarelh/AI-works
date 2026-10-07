# e13 (revision): structure of escalation chains (Prop F.9, Lemma F.10).
#  (1) Prop F.9: if the first datum d has no binder, every escalation chain after d has length <= 2|d| - 1;
#      at every (gamma)-step the equivalence "equal subterms in all data" on positions of d strictly refines.
#      Greedy adversarial chains (as in e6) over binder-free sentences.
#  (2) Lemma F.10 on random data with binders: (a) E(D) is closed under composition with
#      u_kj = u_ki[u_ij]; (b),(c) a datum that keeps C and Y and keeps (k,i),(k,j) [resp. (i,k),(k,j)] keeps (i,j).
# usage: python3 e13_escalation_structure.py SEED TRIALS
import sys, random, itertools
from dtcore import *
from dtfeat import Prefix
from dtrandom import rand_term

SEED = int(sys.argv[1]) if len(sys.argv) > 1 else 3
TR = int(sys.argv[2]) if len(sys.argv) > 2 else 40
rng = random.Random(SEED)


def rand_sentence(size, depth=0, binders=True):
    if size <= 3:
        return eq(rand_term(rng, depth, 1), rand_term(rng, depth, 1))
    r = rng.random()
    if r < 0.3:
        a = rng.randint(1, size - 2)
        return eq(rand_term(rng, depth, a), rand_term(rng, depth, size - 1 - a))
    if r < 0.45:
        return NOT(rand_sentence(size - 1, depth, binders))
    if r < 0.8 or not binders:
        a = rng.randint(3, max(3, size - 4))
        return AND(rand_sentence(a, depth, binders), rand_sentence(max(3, size - 1 - a), depth, binders))
    return ALL(rand_sentence(size - 1, depth + 1, binders))


def put(u, path, v):
    if not path:
        return v
    ks = list(kids(u))
    ks[path[0]] = put(ks[path[0]], path[1:], v)
    return rebuild(u, ks)


def mutate(s, binders=True):
    cand = list(positions(s))
    p, t, d, srt = rng.choice(cand)
    n = max(1, size(t) + rng.choice([-1, 0, 0, 1]))
    new = rand_term(rng, d, min(n, 3)) if srt == 'T' else rand_sentence(max(3, n), d, binders)
    return put(s, p, new)


def equiv_classes(d, D):
    """partition of positions of d: p ~ p' iff both exist in every datum with equal subterms"""
    ps = [p for (p, _, _, _) in positions(d)]
    def val(x, p):
        try:
            return sub(x, p)
        except (IndexError, TypeError):
            return None
    key = {}
    for p in ps:
        vs = tuple(val(x, p) for x in D)
        key[p] = vs if all(v is not None for v in vs) else ('missing', p)
    cls = {}
    for p in ps:
        cls.setdefault(key[p], []).append(p)
    return len(cls)


print('== (1) Prop F.9: binder-free first datum')
worst = 0.0
viol = refine_viol = 0
for trial in range(TR):
    d1 = rand_sentence(rng.randint(8, 18), binders=False)
    n = size(d1)
    D = [d1]
    P = Prefix(D)
    length = 0
    stall = 0
    while stall < 300:
        cands = []
        for _ in range(30):
            q = mutate(rng.choice(D), binders=False)
            if rng.random() < 0.3:
                q = mutate(q, binders=False)
            if size(q) <= 2 * n and not P.accepts(q):
                cands.append(q)
        if not cands:
            stall += 30
            continue
        best = max(cands, key=lambda q: Prefix(D + [q]).potential())
        P2 = Prefix(D + [best])
        same_CY = (set(P2.C) == set(P.C) and P2.Y == P.Y)
        if same_CY:   # a (gamma)-step: the equivalence must strictly refine
            if not equiv_classes(d1, D + [best]) > equiv_classes(d1, D):
                refine_viol += 1
        D.append(best)
        P = P2
        length += 1
        stall = 0
    viol += length > 2 * n - 1
    worst = max(worst, length / n)
print('  %d greedy chains: violations of length <= 2n-1: %d; (gamma)-steps without strict refinement: %d;'
      ' max chain/n = %.2f' % (TR, viol, refine_viol, worst))

print('== (2) Lemma F.10 on random data with binders')
X = H(0)
na = nb = nc = nb_kill = 0
bad_a = bad_b = bad_c = 0
for trial in range(TR * 10):
    base = rand_sentence(rng.randint(8, 16))
    D = [base] + [mutate(base) for _ in range(rng.randint(1, 3))]
    P = Prefix(D)
    E = {(s, r): dict(um) for (s, r, um) in P.eq_features()}
    # (a) composition
    for (k, i), uki in E.items():
        for (i2, j), uij in E.items():
            if i2 != i or j == k or comparable(j, k):
                continue
            if P.A[j][1] != P.A[k][1]:
                continue
            na += 1
            comp = {y: subst_free(t, uij) if fv(t) <= set(uij) else None for y, t in uki.items()}
            if (k, j) not in E or any(v is None or E[(k, j)].get(y) != v for y, v in comp.items()):
                bad_a += 1
    # (b), (c): new datum keeping C and Y
    for _ in range(15):
        q = mutate(rng.choice(D))
        P2 = Prefix(D + [q])
        if set(P2.C) != set(P.C) or P2.Y != P.Y:
            continue
        E2 = {(s, r) for (s, r, um) in P2.eq_features()}
        for (i, j) in E:
            for k in P.slots:
                if (k, i) in E and (k, j) in E:
                    nb += 1
                    if (k, i) in E2 and (k, j) in E2 and len(E2) < len(E):
                        nb_kill += 1
                    if (k, i) in E2 and (k, j) in E2 and (i, j) not in E2:
                        bad_b += 1
                if (i, k) in E and (k, j) in E:
                    nc += 1
                    if (i, k) in E2 and (k, j) in E2 and (i, j) not in E2:
                        bad_c += 1
print('  composition instances %d, failures %d; cancellation (b) instances %d, failures %d;'
      ' transitivity-in-step (c) instances %d, failures %d; (b)-premise kept while the step killed some pair: %d'
      % (na, bad_a, nb, bad_b, nc, bad_c, nb_kill))

print('== (2b) Lemma F.10 on structured low-diversity data  AxAy /\\_j (t_j = 0)')
POOL = [V(0), V(1), Z, S(V(0)), S(V(1)), S(Z), PA, add(V(0), V(1)), add(V(1), V(0)), S(S(V(0)))]
def fam(m):
    f = None
    for j in range(m):
        e = eq(rng.choice(POOL), Z)
        f = e if f is None else AND(f, e)
    return ALL(ALL(f))
na = nb = nc = nb_kill = 0
bad_a = bad_b = bad_c = 0
for trial in range(TR * 10):
    m = rng.randint(3, 6)
    # correlated data: start from one datum and copy columns to create equations
    D = [fam(m) for _ in range(rng.randint(2, 3))]
    P = Prefix(D)
    E = {(s, r): dict(um) for (s, r, um) in P.eq_features()}
    for (k, i), uki in E.items():
        for (i2, j), uij in E.items():
            if i2 != i or j == k or comparable(j, k) or P.A[j][1] != P.A[k][1]:
                continue
            na += 1
            comp = {y: subst_free(t, uij) if fv(t) <= set(uij) else None for y, t in uki.items()}
            if (k, j) not in E or any(v is None or E[(k, j)].get(y) != v for y, v in comp.items()):
                bad_a += 1
    for _ in range(20):
        q = fam(m)
        P2 = Prefix(D + [q])
        if set(P2.C) != set(P.C) or P2.Y != P.Y:
            continue
        E2 = {(s, r) for (s, r, um) in P2.eq_features()}
        for (i, j) in E:
            for k in P.slots:
                if (k, i) in E and (k, j) in E:
                    nb += 1
                    if (k, i) in E2 and (k, j) in E2 and len(E2) < len(E):
                        nb_kill += 1
                    if (k, i) in E2 and (k, j) in E2 and (i, j) not in E2:
                        bad_b += 1
                if (i, k) in E and (k, j) in E:
                    nc += 1
                    if (i, k) in E2 and (k, j) in E2 and (i, j) not in E2:
                        bad_c += 1
print('  composition instances %d, failures %d; cancellation (b) instances %d, failures %d;'
      ' transitivity-in-step (c) instances %d, failures %d; (b)-premise kept while the step killed some pair: %d'
      % (na, bad_a, nb, bad_b, nc, bad_c, nb_kill))
