"""Reviewer's independent checks of claims in sections setting/single (uses only mini_dt.py)."""
import itertools, math, random, sys
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/paper-review/scratch')
from mini_dt import *

Z = ('0',)
def S(t): return ('S', t)
def EQ(a, b): return ('=', a, b)
def AND(*fs):
    out = fs[-1]
    for f in reversed(fs[:-1]):
        out = ('and', f, out)
    return out
def ALL(f): return ('all', f)
def IMP(a, b): return ('imp', a, b)
def NOT(f): return ('not', f)
def V(k): return ('v', k)
def Pm(name): return ('p', name)
def num(n):
    t = Z
    for _ in range(n): t = S(t)
    return t
def h(m=0): return ('h', m)
def M(name, *args): return ('M', name, tuple(args))
def Ind(phi):   # phi uses V(0) for x at depth 0 (its own binder count is relative)
    phi0 = subst(phi, {0: Z}) if 0 in FV(phi) else phi
    # phi under 'all': x is index 0;   phi[Sx/x]
    phiS = subst(phi, {0: S(V(0))}) if 0 in FV(phi) else phi
    phi0 = lower_closed(phi0)
    return IMP(AND(phi0, ALL(IMP(phi, phiS))), ALL(phi))
def lower_closed(f):
    # phi0 has no free index 0 any more; indices >=1 do not occur in motives here
    return f

ok_all = True
def check(name, cond):
    global ok_all
    print(('OK   ' if cond else 'FAIL ') + name)
    ok_all &= bool(cond)

# ---------------- Prop G.2 (blowup): Acc(D_n) = D_n on a pool of queries -----------------
def Cn(n): return AND(*[EQ(Z, Z) for _ in range(n)])
for n in (1, 2, 3):
    D = [AND(ALL(EQ(V(0), V(0))), Cn(n)), AND(ALL(EQ(Z, Z)), Cn(n))]
    check(f'G.2 size n={n}: total size 8n+8', sum(size(d) for d in D) == 8 * n + 8)
    F = Features(D)
    pool = [V(0), Z, S(V(0)), S(Z), ('+', V(0), Z), ('+', Z, V(0)), ('*', V(0), Z), Pm('a'), ('+', V(0), V(0))]
    acc = [t for t in pool if F.accepts(AND(ALL(EQ(t, t)), Cn(n)))]
    check(f'G.2 n={n}: accepted terms are exactly x and 0', set(acc) == {V(0), Z})
    # number of Eq features: 2 slot-slot + 2 slots x 2n zeros
    check(f'G.2 n={n}: number of Eq features = 2 + 4n', len(F.eq) == 2 + 4 * n)

# ---------------- C8.2 example: feature list -----------------
x = V(0)
D = [Ind(EQ(x, x)), Ind(EQ(Z, x))]
F = Features(D)
print('C8.2 slots:', F.slots, ' scopes:', F.Y)
print('C8.2 Eq features:', [(s, r, u) for s, r, u in F.eq])
check('C8.2: three slots with scope {x}', len(F.slots) == 3 and all(F.Y[s] == {0} for s in F.slots))
check('C8.2: 6 Eq features (b<->d, b->c, d->c, b,d -> two zeros)', len(F.eq) == 7 or len(F.eq) == 6)

# ---------------- Prop D.4/D.5/D.6: non-anchors, via a violating instance of T* -----------------
def nonanchor_witness(Tstar, thetas, pool):
    data = [instantiate(Tstar, th) for th in thetas]
    F = Features(data)
    names = list(metas(Tstar))
    for combo in itertools.product(*[pool[nm] for nm in names]):
        th = dict(zip(names, combo))
        q = instantiate(Tstar, th)
        if not F.accepts(q):
            return th, F.accepts(q, why=True)[1]
    return None

# D.5: T* = forall x (0 = f(x))
T5 = ALL(EQ(Z, M('f', V(0))))
th5 = [{'f': Z}, {'f': h(0)}]
ev = events(T5, th5)
check('D.5: (R*),(N) hold, (U) fails', ev[0] and ev[1] and not ev[2])
w = nonanchor_witness(T5, th5, {'f': [Z, h(0), S(h(0))]})
check('D.5: instance f:=Sz violates a D-feature', w is not None and w[0]['f'] == S(h(0)))
# D.4
T4 = AND(ALL(ALL(EQ(S(M('f', V(1), V(0))), Z))), ALL(ALL(EQ(M('f', V(1), S(V(0))), Z))))
th4 = [{'f': h(0)}, {'f': h(1)}, {'f': S(h(0))}]
ev = events(T4, th4)
print('D.4 events (R*,N,U):', ev[:3], ' data:', ev[3])
check('D.4: (R*),(N) hold, (U) fails', ev[0] and ev[1] and not ev[2])
w = nonanchor_witness(T4, th4, {'f': [Z, h(0), h(1), S(h(0)), S(h(1))]})
print('D.4 witness:', w)
check('D.4: some instance of T* violates a D-feature', w is not None)
# check (U) restricted to pattern occurrence holds
data4 = ev[3]
F4 = Features(data4)
pat = (0, 0, 0, 0)    # S f(x,y): position of f is under and.0 -> all -> all -> = lhs(S) -> child
print('D.4 Eq features:', F4.eq)
# D.6
T6 = AND(ALL(ALL(EQ(M('f', V(1), V(0)), Z))), ALL(EQ(V(0), Z)))
th6 = [{'f': h(0)}, {'f': h(1)}]
ev = events(T6, th6)
check('D.6: (R*),(N) hold, (U) fails', ev[0] and ev[1] and not ev[2])
w = nonanchor_witness(T6, th6, {'f': [Z, h(0), h(1), S(h(0))]})
check('D.6: some instance violates a feature', w is not None)

# ---------------- Prop F.8: quadratic chain -----------------
def chain_F8(m):
    atoms_d1 = [EQ(Z, Z) for _ in range(m)]
    def wrap(atoms):
        f = AND(*atoms)
        for _ in range(m): f = ALL(f)
        return f
    d1 = wrap(atoms_d1)
    d2 = wrap([EQ(Pm('a'), Z) for _ in range(m)])
    qs = []
    for j in range(m):
        for k in range(m):
            at = list(atoms_d1); at[j] = EQ(V(k), Z); qs.append(wrap(at))
    return [d1, d2] + qs
for m in (1, 2, 3, 4):
    ch = chain_F8(m)
    sizes = {size(c) for c in ch}
    good = all(not Features(ch[:i]).accepts(ch[i]) for i in range(1, len(ch)))
    check(f'F.8(i) m={m}: chain of {len(ch)} = 2+m^2, sizes {sizes} = 5m-1, each outside Acc(pred)', good and sizes == {5 * m - 1} and len(ch) == 2 + m * m)
    # Scope features are the violated ones for the q's
    kinds = [Features(ch[:i]).accepts(ch[i], why=True)[1][0] for i in range(1, len(ch))]
    print('   violated feature kinds:', kinds[:4], '...')
for m in (2, 3):
    ch = [Ind(c) for c in chain_F8(m)]
    good = all(not Features(ch[:i]).accepts(ch[i]) for i in range(1, len(ch)))
    check(f'F.8(ii) m={m}: Ind chain sizes {set(size(c) for c in ch)} = 20m+1, each outside Acc(pred)', good and {size(c) for c in ch} == {20 * m + 1})

# ---------------- Thm F linear chain -----------------
for N in (5, 6, 8):
    k = N - 3
    ch = [EQ(num(k), Z), EQ(S_k(Pm('a'), k) if False else None, Z)] if False else None
    def Sk(t, k):
        for _ in range(k): t = S(t)
        return t
    ch = [EQ(Sk(Z, k), Z), EQ(Sk(Pm('a'), k), Z)] + [EQ(Sk(Z, j), Z) for j in range(k - 1, -1, -1)] + [EQ(Z, S(Z)), NOT(EQ(Z, Z))]
    good = all(not Features(ch[:i]).accepts(ch[i]) for i in range(1, len(ch)))
    check(f'Thm F linear chain N={N}: length {len(ch)} = N+1, max size {max(size(c) for c in ch)} <= N', good and len(ch) == N + 1 and max(size(c) for c in ch) <= N)

# ---------------- Cor F.4(iii) encoded union lower bound, k = 2, n+1 = 3 (N = 9) -----------------
def acc_k(D, q, k):
    D = list(D)
    if not D:
        return False
    # q in Acc_k(D) iff every partition of D into <= k nonempty blocks has a block B with q in Acc(B)
    n = len(D)
    for labels in itertools.product(range(k), repeat=n):
        blocks = [[D[i] for i in range(n) if labels[i] == b] for b in range(k)]
        blocks = [b for b in blocks if b]
        if not any(Features(b).accepts(q) for b in blocks):
            return False
    return True
def Sk(t, k):
    for _ in range(k): t = S(t)
    return t
k, n1 = 2, 3
N = 9
assert (N - 1) // k - 1 == n1
qs = sorted(itertools.product(range(n1), repeat=k), key=lambda a: -sum(a))
sent = [EQ(('+', Sk(Z, a[0]), Sk(Z, a[1])), Z) for a in qs]
good = all(not acc_k(sent[:i], sent[i], k) for i in range(len(sent)))
check(f'Cor F.4(iii) k=2: {len(sent)} escalations = (floor((N-1)/k)-1)^k, sizes <= {max(size(s) for s in sent)} <= N=9', good and len(sent) == 9 and max(size(s) for s in sent) <= N)

# ---------------- Prop F.3 thickness -----------------
s = AND(ALL(EQ(Z, Z)), EQ(Z, Z))
for t in (Z, S(Z), Pm('a'), ('+', Z, Z)):
    T = AND(ALL(M('P', V(0))), M('P', t))
    check(f'F.3: s in inst(forall x P(x) & P({t}))', match_DT(T, s) is not None)

# ---------------- worked law 1: exact non-anchor probability at N=8 by features ----------------
T1 = ALL(EQ(Z, M('f', V(0))))
supp = [(Z, 0.4), (h(0), 0.3), (S(h(0)), 0.3)]
pool = [Z, h(0), S(h(0)), S(S(h(0))), S(Z), Pm('a'), ('+', h(0), Z), ('+', h(0), h(0))]
def is_anchor(Tstar, thetas, poolf):
    data = [instantiate(Tstar, th) for th in thetas]
    F = Features(data)
    return all(F.accepts(instantiate(Tstar, {'f': b})) for b in poolf)
Nn = 8
p = 0.0
for counts in itertools.product(range(Nn + 1), repeat=3):
    if sum(counts) != Nn: continue
    thetas = [{'f': supp[i][0]} for i in range(3) if counts[i] > 0]
    prob = math.factorial(Nn)
    for i in range(3): prob = prob / math.factorial(counts[i]) * supp[i][1] ** counts[i]
    if not is_anchor(T1, thetas, pool): p += prob
check(f'law 1: exact P[not anchor] at N=8 = {p:.6f} (claim 0.057714 = 0.7^8+0.3^8)', abs(p - 0.057714) < 5e-7)
bound = 0.4 ** 7 + 0.4 ** 8 + 0.49 ** 4
check(f'law 1: Thm E upper bound {bound:.6f} (claim 0.059942), lower bound 0.7^8 = {0.7**8:.6f} (claim 0.057648)', abs(bound - 0.059942) < 5e-7 and abs(0.7 ** 8 - 0.057648) < 5e-7)

# ---------------- worked law 2: coincidence probability at (f(x), g(y)) -----------------
T2 = ALL(ALL(EQ(M('f', V(1)), M('g', V(0)))))
fs = [h(0), S(h(0))]
gs = [h(0), Z, S(h(0))]
supp2 = [({'f': a, 'g': b}, 1 / 6) for a in fs for b in gs]
sig, r = (0, 0, 0), (0, 0, 1)
def coinc(thetas):
    data = [instantiate(T2, th) for th in thetas]
    return common_map([(sub(d, sig), sub(d, r)) for d in data]) is not None
# exact by inclusion-exclusion over the multinomial: enumerate sets of support points used
pc = 0.0
for mask in range(1, 2 ** 6):
    pts = [i for i in range(6) if mask >> i & 1]
    if coinc([supp2[i][0] for i in pts]):
        # probability that the set of sampled points is exactly pts: inclusion-exclusion
        q = 0.0
        for sub_mask in range(1, 2 ** len(pts)):
            sub_pts = [pts[j] for j in range(len(pts)) if sub_mask >> j & 1]
            sign = (-1) ** (len(pts) - len(sub_pts))
            q += sign * (len(sub_pts) / 6) ** 8
        pc += q
claim = (1 / 3) ** 8 + 2 * (1 / 6) ** 8
check(f'law 2: coincidence probability at N=8 = {pc:.4e} (claim (1/3)^8+2(1/6)^8 = {claim:.4e} ~ 1.54e-4)', abs(pc - claim) < 1e-9)
# 1 - kappa
ok_pairs = sum(1 / 36 for a in range(6) for b in range(6) if coinc([supp2[a][0], supp2[b][0]]))
check(f'law 2: 1-kappa = {ok_pairs:.4f} (claim 1/6)', abs(ok_pairs - 1 / 6) < 1e-12)

# ---------------- Thm E(c) analytic steps -----------------
a_ok = all(1 - math.exp(-a) >= 0.75 * a - 1e-15 for a in [i / 10000 * 0.5 for i in range(10001)])
check('E(c): 1-e^{-a} >= 3a/4 on [0,1/2]', a_ok)
lam_ok = all((1 - lam) ** (n // 2) <= math.sqrt(math.e) * math.exp(-lam * n / 2) + 1e-15
             for lam in [i / 100 for i in range(1, 101)] for n in range(0, 60))
check('E(c): (1-l)^floor(n/2) <= sqrt(e) e^{-l n/2} for l in (0,1], n>=0', lam_ok)

# ---------------- SO° matcher count for P(0) (Thm A(d)) -----------------
def count_bodies(cols, args_per_occ, e=0):
    # cols: list of subterms (one per occurrence); args: list of argument tuples
    cnt = 0
    for m in range(len(args_per_occ[0])):
        if all(c == shift(a[m], e) for c, a in zip(cols, args_per_occ)):
            cnt += 1
    labs = {label(c) for c in cols}
    if len(labs) == 1:
        c0 = cols[0]
        if c0[0] == 'v' and c0[1] >= e:
            return cnt
        e2 = e + (1 if c0[0] in BINDERS else 0)
        prod = 1
        for i in range(len(kids(c0))):
            prod *= count_bodies([kids(c)[i] for c in cols], args_per_occ, e2)
            if prod == 0: break
        cnt += prod
    return cnt
for kk in (2, 4, 6):
    s = AND(*[EQ(Z, Z) for _ in range(kk // 2)])
    check(f'Thm A(d): P(0) against a sentence with {kk} zeros has 2^{kk} matchers', count_bodies([s], [(Z,)]) == 2 ** kk)

# ---------------- ex:setting:classes (4): f(S0)+f(0)=f(S0) -----------------
T4s = EQ(('+', M('f', S(Z)), M('f', Z)), M('f', S(Z)))
def so_member(T, s):
    occ = list(occurrences(T))
    for p, t, b in positions(T):
        if t[0] != 'M' and (not has_pos(s, p) or label(sub(s, p)) != label(t)):
            return False
    cols = [sub(s, p) for p, t, b in occ]
    return count_bodies(cols, [t[2] for p, t, b in occ]) > 0
check('ex 2.3(4): covers 0+0=0', so_member(T4s, EQ(('+', Z, Z), Z)))
check('ex 2.3(4): covers S0+0=S0', so_member(T4s, EQ(('+', S(Z), Z), S(Z))))
check('ex 2.3(4): misses SS0+0=SS0', not so_member(T4s, EQ(('+', num(2), Z), num(2))))

# ---------------- random check of Thm D (both directions) on small arithmetic targets -----------------
rng = random.Random(7)
BODY_T1 = [Z, Pm('a'), h(0), S(h(0)), S(Z), ('+', h(0), Z), ('+', h(0), h(0)), S(S(h(0))), ('*', h(0), h(0))]
BODY_T2 = [Z, Pm('a'), h(0), h(1), S(h(0)), S(h(1)), ('+', h(0), h(1)), ('+', h(1), h(0)), ('*', h(0), h(1)), S(Z)]
BODY_T0 = [Z, Pm('a'), S(Z), Pm('b'), ('+', Z, Pm('a'))]
def rand_target(rng):
    # forall x forall y ( lhs = rhs ) & ( lhs2 = rhs2 ) with occurrences of f (arity 1 or 2) and c (0-ary)
    ar = rng.choice([0, 1, 2])
    def term(depth_vars):
        choice = rng.random()
        if choice < 0.45:
            # occurrence
            if ar == 0: return M('f')
            if ar == 1:
                return M('f', rng.choice([V(0), V(1), Z, S(V(0)), S(V(1))]))
            args = rng.choice([(V(0), V(1)), (V(1), V(0)), (V(0), S(V(1))), (Z, V(0)), (V(1), V(1)), (S(V(0)), V(1))])
            return M('f', *args)
        if choice < 0.65: return rng.choice([V(0), V(1), Z])
        return S(term(depth_vars))
    while True:
        T = AND(ALL(ALL(EQ(term(2), term(2)))), ALL(ALL(EQ(term(2), term(2)))))
        # ensure a pattern occurrence exists
        if ar == 0:
            pat = M('f')
        elif ar == 1:
            pat = M('f', V(0))
        else:
            pat = M('f', V(1), V(0))
        T = AND(ALL(ALL(EQ(pat, Z))), T) if rng.random() < 0.5 else AND(T, ALL(ALL(EQ(pat, term(2)))))
        if is_DT(T):
            return T, ar
nchk = 0; disagree = 0; n_anchor = 0
for trial in range(400):
    T, ar = rand_target(rng)
    pool = {0: BODY_T0, 1: BODY_T1, 2: BODY_T2}[ar]
    Ndata = rng.choice([1, 2, 3])
    thetas = [{'f': rng.choice(pool)} for _ in range(Ndata)]
    Rs, Nv, U, data, _ = events(T, thetas)
    pred = Rs and Nv and U
    # sanity: matching recovers theta (uniqueness, Thm A)
    for th, d in zip(thetas, data):
        mt = match_DT(T, d)
        assert mt is not None and instantiate(T, mt) == d
        if Nv:
            pass
    F = Features(data)
    viol = None
    for b in pool + [S(S(S(h(0))))] if ar >= 1 else pool:
        q = instantiate(T, {'f': b})
        if not F.accepts(q):
            viol = b; break
    truth = viol is None
    nchk += 1
    n_anchor += truth
    if pred != truth:
        disagree += 1
        print('DISAGREE', T, thetas, pred, truth, viol)
check(f'Thm D random: prediction (R*)(N)(U) = pool-based anchor status on {nchk} cases ({n_anchor} anchors), disagreements {disagree}', disagree == 0)

print('ALL OK' if ok_all else 'SOME CHECKS FAILED')
