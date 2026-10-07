# e11 (revision): complexity of the cautious verifier over unions H_k(DT°)  (Section 8b, Thm H).
#  (1) Lemma H.1 on random data: for every nonempty B subset of D,  q not in Acc(B)  iff  B fits a
#      q-relative failure type.
#  (2) Thm H.2: the polynomial k = 2 verifier (types + witnesses + 2-SAT) equals the brute-force
#      partition verifier of Prop F.6.
#  (3) Thm H.3: colouring reduction: q_G in Acc_k(D_G) iff chi(G) > k  (k = 1..4), and
#      q_G not in Acc(B) iff B is independent (all subsets).
#  (4) Thm H.4: set-cover reduction (binder-free data): q in Acc_k(D) iff no k sets cover; and every
#      Eq-type of binder-free data has no incompatible pairs (so fixed k is polynomial).
# usage: python3 e11_union_complexity.py SEED TRIALS
import sys, random, itertools, time
from dtcore import *
from dtfeat import Prefix
from dtrandom import rand_template, rand_theta, rand_term
from dtunion import *

SEED = int(sys.argv[1]) if len(sys.argv) > 1 else 1
TR = int(sys.argv[2]) if len(sys.argv) > 2 else 60
rng = random.Random(SEED)
X, Y = H(0), H(1)

# low-diversity body pools (many coincidences, so Eq-types with nonempty scopes occur)
TPOOL1 = [X, S(X), Z, PA, add(X, Z), S(Z)]
TPOOL2 = [X, Y, S(X), add(X, Y), Z, S(Y), PA]
FPOOL1 = [eq(X, X), eq(X, Z), eq(Z, Z), NOT(eq(X, Z)), eq(S(X), Z), ALL(eq(V(0), X))]
FPOOL2 = [eq(X, Y), eq(Y, X), eq(X, Z), NOT(eq(Y, Z)), eq(Z, Z), eq(add(X, Y), Z)]
FPOOL0 = [eq(Z, Z), eq(PA, Z), NOT(eq(Z, Z)), eq(S(Z), Z)]
TPOOL0 = [Z, PA, S(Z), S(PA)]


def low_theta(T):
    th = {}
    for nm, n in {o[1]: len(o[2]) for o in occurrences(T)}.items():
        if msort(nm) == 'T':
            pool = {0: TPOOL0, 1: TPOOL1, 2: TPOOL2}[n]
        else:
            pool = {0: FPOOL0, 1: FPOOL1, 2: FPOOL2}[n]
        th[nm] = rng.choice(pool)
    return th


def mutate(s):
    cand = [(p, t, d, srt) for (p, t, d, srt) in positions(s)]
    p, t, d, srt = rng.choice(cand)
    new = rand_term(rng, d, 2) if srt == 'T' else eq(rand_term(rng, d, 2), rand_term(rng, d, 1))
    def put(u, path, v):
        if not path:
            return v
        ks = list(kids(u))
        ks[path[0]] = put(ks[path[0]], path[1:], v)
        return rebuild(u, ks)
    return put(s, p, new)


def random_case():
    nT = rng.choice([1, 2, 2, 3])
    Ts = [rand_template(rng, nmeta=rng.choice([1, 1, 2]), max_derived=2, nclauses=rng.choice([1, 2]))
          for _ in range(nT)]
    D = []
    for _ in range(rng.randint(3, 6)):
        T = rng.choice(Ts)
        s = instantiate(T, low_theta(T))
        if s not in D:
            D.append(s)
    qs = []
    for _ in range(12):
        r = rng.random()
        if r < 0.4:
            T = rng.choice(Ts)
            qs.append(instantiate(T, low_theta(T)))
        elif r < 0.65:
            qs.append(mutate(rng.choice(D)))
        else:
            B = rng.sample(D, rng.randint(1, len(D)))
            P = Prefix(B)
            tems = P.feature_templates()
            Tq = rng.choice(tems)
            th = {nm: (rng.choice(TPOOL2 if n >= 2 else TPOOL1 if n == 1 else TPOOL0) if msort(nm) == 'T'
                       else rng.choice(FPOOL2 if n >= 2 else FPOOL1 if n == 1 else FPOOL0))
                  for nm, n in {o[1]: len(o[2]) for o in occurrences(Tq)}.items()}
            # pools may have too many holes for small arities: restrict
            ok = True
            for nm, n in {o[1]: len(o[2]) for o in occurrences(Tq)}.items():
                if max(holes(th[nm]) | {-1}) >= n:
                    ok = False
            if ok:
                qs.append(instantiate(Tq, th))
    return D, [q for q in qs if q not in D] + [q for q in qs if q in D][:1]


t0 = time.time()
print('== (1) Lemma H.1 and (2) Thm H.2 on random mixtures of 1-3 random DT° templates (seed %d)' % SEED)
n_sub = bad_sub = 0
n_q = bad_k2 = 0
acc2_true = 0
n_acc1 = n_split = n_split_eq = 0
fail_kinds = {'sym': 0, 'scope': 0, 'eq': 0, 'eq_nonempty_scope': 0}
cases = 0
while cases < TR:
    D, qs = random_case()
    if len(D) < 3:
        continue
    cases += 1
    BA = BlockAcc(D)
    idx = list(range(len(D)))
    for q in qs:
        types = failure_types(D, q)
        for ty in types:
            fail_kinds[ty[0]] += 1
            if ty[0] == 'eq' and ty[3]:
                fail_kinds['eq_nonempty_scope'] += 1
        for r in range(1, len(D) + 1):
            for B in itertools.combinations(idx, r):
                n_sub += 1
                if (not BA.accepts(list(B), q)) != fails_by_types(B, types):
                    bad_sub += 1
                    if bad_sub <= 3:
                        print('  H.1 MISMATCH', [pp(D[i]) for i in B], pp(q))
        n_q += 1
        if BA.accepts(idx, q):
            n_acc1 += 1
        bf = acc_union_bf(D, q, 2, BA)
        if BA.accepts(idx, q) and not bf:
            n_split += 1
            if any(ty[0] == 'eq' and ty[3] and fails_by_types(B, [ty]) for P in partitions(idx, 2) if len(P) == 2
                   and not any(BA.accepts(B_, q) for B_ in P) for B in P):
                n_split_eq += 1
        po = acc2_poly(D, q, types)
        acc2_true += bf
        if bf != po:
            bad_k2 += 1
            if bad_k2 <= 3:
                print('  H.2 MISMATCH bf=%s poly=%s' % (bf, po), [pp(d) for d in D], pp(q))
print('  cases %d, (D-subset, q) pairs %d: Lemma H.1 disagreements %d' % (cases, n_sub, bad_sub))
print('  types seen: %s  (eq types with incompatible pairs = Eq-types where compatibility matters)' % fail_kinds)
print('  queries %d (accepted by the H_2 verifier: %d): Thm H.2 poly vs brute force disagreements %d'
      % (n_q, acc2_true, bad_k2))
print('  of these: in Acc(D) (k=1) %d; in Acc(D) but rejected by the H_2 verifier %d (some failing split uses an'
      ' Eq-type with incompatible pairs: %d)' % (n_acc1, n_split, n_split_eq))
print('  time %.1fs' % (time.time() - t0))


def chi(n, edges):
    for k in range(1, n + 1):
        for col in itertools.product(range(k), repeat=n):
            if all(col[u - 1] != col[v - 1] for u, v in edges):
                return k
    return n


def independent(B, edges):
    S_ = set(B)
    return not any(u in S_ and v in S_ for u, v in edges)


print('== (3) Thm H.3: colouring reduction')
graphs = {
    'K3': (3, [(1, 2), (2, 3), (1, 3)]),
    'C4': (4, [(1, 2), (2, 3), (3, 4), (4, 1)]),
    'C5': (5, [(1, 2), (2, 3), (3, 4), (4, 5), (5, 1)]),
    'K4': (4, [(1, 2), (1, 3), (1, 4), (2, 3), (2, 4), (3, 4)]),
    'W5 (wheel, 6 vertices)': (6, [(1, 2), (2, 3), (3, 4), (4, 5), (5, 1), (6, 1), (6, 2), (6, 3), (6, 4), (6, 5)]),
    'Petersen': (10, [(1, 2), (2, 3), (3, 4), (4, 5), (5, 1), (1, 6), (2, 7), (3, 8), (4, 9), (5, 10),
                      (6, 8), (8, 10), (10, 7), (7, 9), (9, 6)]),
}
for g in range(6):
    n = rng.randint(5, 7)
    E = [(u, v) for u in range(1, n + 1) for v in range(u + 1, n + 1) if rng.random() < 0.5]
    rng.shuffle(E)
    E = [(v, u) if rng.random() < 0.5 else (u, v) for (u, v) in E]
    graphs['random G(%d,1/2) #%d' % (n, g)] = (n, E)
allok = True
for name, (n, E) in graphs.items():
    D, q = colouring_instance(n, E)
    BA = BlockAcc(D)
    c = chi(n, E)
    sub_ok = True
    if n <= 7:
        for r in range(1, n + 1):
            for B in itertools.combinations(range(n), r):
                indep = independent([i + 1 for i in B], E)
                if (not BA.accepts(list(B), q)) != indep:
                    sub_ok = False
    res = {}
    for k in range(1, 5):
        res[k] = acc_union_bf(D, q, k, BA)
    k2 = acc2_poly(D, q)
    ok = sub_ok and all(res[k] == (c > k) for k in res) and k2 == (c > 2)
    allok &= ok
    print('  %-24s n=%2d m=%2d size(d)<=%3d chi=%d  q in Acc_k for k=1..4: %s  poly k=2: %s  subsets ok: %s  %s'
          % (name, n, len(E), max(size(d) for d in D), c, [res[k] for k in range(1, 5)], k2,
             sub_ok if n <= 7 else 'n/a', 'OK' if ok else 'FAIL'))
print('  all colouring instances agree:', allok, ' time %.1fs' % (time.time() - t0))

print('== (4) Thm H.4: set-cover reduction (binder-free)')
allok = True
nonempty_inc = 0
for t in range(25):
    n = rng.randint(4, 7)
    m = rng.randint(2, 5)
    sets = [set(u for u in range(1, n + 1) if rng.random() < 0.4) for _ in range(m)]
    D, q = setcover_instance(n, sets)
    Dd = []
    for d in D:
        if d not in Dd:
            Dd.append(d)
    BA = BlockAcc(Dd)
    cover = None
    for k in range(1, m + 1):
        if any(set().union(*c) >= set(range(1, n + 1)) for c in itertools.combinations(sets, k)):
            cover = k
            break
    types = failure_types(Dd, q)
    nonempty_inc += sum(1 for ty in types if ty[0] == 'eq' and ty[3])
    for k in range(1, m + 1):
        bf = acc_union_bf(Dd, q, k, BA)
        want = (cover is None) or cover > k
        if bf != want:
            allok = False
            print('  MISMATCH', n, sets, k, bf, cover)
print('  25 random instances, k = 1..m: q in Acc_k(D) iff no cover by k sets: %s;'
      ' Eq-types with incompatible pairs: %d' % (allok, nonempty_inc))
print('total time %.1fs' % (time.time() - t0))
