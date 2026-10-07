# Track "cases", revision (referee missing item 3): anchors for pattern targets with SEVERAL metavariables
# (Thm E' in notes-final.md).  Language {in, =}, parameters a, b, de Bruijn binders.
# Predictions:
#   PAT:  anchor <=> (R_P) & (N_P,i) for every P,i & (D^PAT_PQ): no bijection pi of the arguments with
#         phi_Q,j = phi_P,j o pi for all j (only for P, Q of equal arity);
#   DT:   anchor <=> (R) & (N) & (D^DT_PQ) for every ORDERED pair: no map pi: args(P) -> args(Q) u Par with
#         phi_Q,j = phi_P,j o pi for all j;
#   SO:   (R)&(N)&(D+) [roots of P and Q differ in some datum] => anchor => (R)&(N)&(D^DT); both gaps real.
# Checks:
#  (1) PAT, via Cor F': pattern_lgg(D) == T*  <=>  PAT-prediction, on random data (pairs, triples) for three
#      two-metavariable templates, with data biased towards coincidences;
#  (2) DT, via dt_search (bounded single-group search, probes = genuine instances): anchor <=> DT-prediction
#      on random pairs (with coincidence bias) for TB = AxAy(P(x,y) -> Q(x)) and TA = AxAy(P(x,y) -> Q(x,y));
#  (3) explicit separations: (a) a pair that is a PAT anchor but not a DT anchor (Q's body = P's body
#      diagonalised); (b) a pair that is a DT anchor (search) but not an SO anchor: the SO template
#      AxAy(G(x,y,x) -> G(x,x,y)) covers it and misses a genuine instance.
import random, itertools, time
from st_core import *
from dt_search import search

a, b = Par('a'), Par('b')
h0, h1 = H(0), H(1)
T_A = ALL(ALL(IMP(M('P', v1, v0), M('Q', v1, v0))))                  # AxAy(P(x,y) -> Q(x,y))
T_B = ALL(ALL(IMP(M('P', v1, v0), M('Q', v1))))                      # AxAy(P(x,y) -> Q(x))
T_C = IMP(ALL(IMP(M('P', v0), M('Q', v0))), IMP(ALL(M('P', v0)), ALL(M('Q', v0))))   # Ax(P->Q) -> (AxP -> AxQ)
ARITY = {'A': (2, 2), 'B': (2, 1), 'C': (1, 1)}
TEMPL = {'A': T_A, 'B': T_B, 'C': T_C}

def atoms(n):
    ts = [H(i) for i in range(n)] + [a]
    return [IN(s, t) for s in ts for t in ts] + [EQ(s, t) for s in ts for t in ts if s != t]
def rand_body(rng, n):
    r = rng.random(); A = atoms(n)
    if r < 0.4: return rng.choice(A)
    if r < 0.55: return NOT(rng.choice(A))
    if r < 0.7: return AND(rng.choice(A), rng.choice(A))
    if r < 0.8: return IMP(rng.choice(A), rng.choice(A))
    if r < 0.9: return ALL(IN(V(0), rng.choice([H(i) for i in range(n)] + [a])))
    return EX(AND(IN(V(0), rng.choice([H(i) for i in range(n)])), IN(rng.choice([H(i) for i in range(n)]), V(0))))

def ren(body, m):
    """replace hole i by m[i] (a hole or a parameter)"""
    if body[0] == 'h': return m[body[1]]
    if body[0] in ('v', 'p'): return body
    return rebuild(body, [ren(k, m) for k in kids(body)])

def maps(nP, nQ, params, bijective):
    targets = [H(i) for i in range(nQ)] + ([] if bijective else list(params))
    for m in itertools.product(targets, repeat=nP):
        if bijective and (nP != nQ or len(set(m)) != nP): continue
        yield m

def coincide(PB, QB, nP, nQ, bijective):
    """exists pi with QB_j == PB_j o pi for all j"""
    params = {a, b}
    return any(all(ren(p, m) == q for p, q in zip(PB, QB)) for m in maps(nP, nQ, params, bijective))

def predicates(PB, QB, nP, nQ):
    R = pred_R(PB) and pred_R(QB)
    N = all(pred_N(PB, nP)) and all(pred_N(QB, nQ))
    dpat = not coincide(PB, QB, nP, nQ, True) and not coincide(QB, PB, nQ, nP, True)
    ddt = not coincide(PB, QB, nP, nQ, False) and not coincide(QB, PB, nQ, nP, False)
    dplus = any(p[0] != q[0] for p, q in zip(PB, QB))
    return R, N, dpat, ddt, dplus

def draw(rng, key, r):
    nP, nQ = ARITY[key]
    PB, QB = [], []
    mode = rng.random()
    for _ in range(r):
        p = rand_body(rng, nP)
        if mode < 0.35:            # coincidence by a fixed map (bijective or not)
            if not hasattr(draw, 'm') or rng.random() < 0.0: pass
            q = None
        else:
            q = rand_body(rng, nQ)
        PB.append(p); QB.append(q)
    if mode < 0.35:
        m = tuple(rng.choice([H(i) for i in range(nQ)] + ([a] if rng.random() < 0.3 else [])) for _ in range(nP))
        QB = [ren(p, m) for p in PB]
    return PB, QB

def inst(key, PB, QB): return [instantiate(TEMPL[key], {'P': p, 'Q': q}) for p, q in zip(PB, QB)]

rng = random.Random(11)
t0 = time.time()
print('(1) PAT (pattern lgg == T*) vs prediction (R)&(N)&(D^PAT)')
for key in 'ABC':
    nP, nQ = ARITY[key]
    agree = tot = rec = sep = 0
    for trial in range(1500):
        r = 2 if trial < 1000 else 3
        PB, QB = draw(rng, key, r)
        D = inst(key, PB, QB)
        L = pattern_lgg(D)
        got = equiv(L, TEMPL[key])
        R, N, dpat, ddt, dplus = predicates(PB, QB, nP, nQ)
        pred = R and N and dpat
        agree += got == pred; tot += 1; rec += got
        sep += (pred and not ddt)
    print('   T_%s: data sets %d, lgg == T* in %d, agreement with prediction %d/%d; PAT anchors violating D^DT: %d'
          % (key, tot, rec, agree, tot, sep))

print('\n(2) DT (bounded single-group search) vs prediction (R)&(N)&(D^DT)')
def probes_for(key, rng, k=14):
    nP, nQ = ARITY[key]
    out = []
    for _ in range(k):
        out.append(instantiate(TEMPL[key], {'P': rand_body(rng, nP), 'Q': rand_body(rng, nQ)}))
    # two systematic probes: unrelated roots
    out.append(instantiate(TEMPL[key], {'P': IN(H(0), H(nP - 1)), 'Q': NOT(EQ(H(0), H(nQ - 1)))}))
    out.append(instantiate(TEMPL[key], {'P': NOT(EQ(H(0), H(nP - 1))), 'Q': IN(H(nQ - 1), H(0))}))
    return out
for key in 'BA':
    nP, nQ = ARITY[key]
    probes = probes_for(key, random.Random(5))
    agree = tot = nanch = ncov_tot = 0
    pairs_seen = 0
    while tot < 150:
        PB, QB = draw(rng, key, 2)
        R, N, dpat, ddt, dplus = predicates(PB, QB, nP, nQ)
        if not (R and N): continue            # (R),(N) are covered by Thm E's witnesses; focus on (D)
        D = inst(key, PB, QB)
        ncov, wit = search(D, probes, [a], gmax=2, amax=2, degree='DT')
        ncov_tot += ncov
        got = not wit
        agree += got == ddt; tot += 1; nanch += got
    print('   T_%s: pairs with (R)&(N): %d; DT anchors found %d; agreement with D^DT %d/%d (covering templates seen %d)'
          % (key, tot, nanch, agree, tot, ncov_tot))

print('\n(3a) PAT anchor that is not a DT anchor (T_B, Q-body = P-body diagonalised)')
PB = [IN(h0, h1), NOT(EQ(h0, h1))]
QB = [IN(h0, h0), NOT(EQ(h0, h0))]
D = inst('B', PB, QB)
print('   predicates (R,N,D^PAT,D^DT,D+):', predicates(PB, QB, 2, 1))
print('   pattern lgg == T_B:', equiv(pattern_lgg(D), T_B))
Tw = ALL(ALL(IMP(M('P', v1, v0), M('P', v1, v1))))
miss = instantiate(T_B, {'P': IN(h0, h1), 'Q': NOT(EQ(h0, h0))})
print('   DT witness %s: determinate %s, covers data %s, covers %s: %s'
      % (pp(Tw), is_determinate(Tw), all(covers(Tw, d) for d in D), pp(miss), covers(Tw, miss)))
PBp = [IN(h0, h1), NOT(EQ(h1, h0))]
QBp = [IN(h0, a), NOT(EQ(a, h0))]
Dp = inst('B', PBp, QBp)
Twp = ALL(ALL(IMP(M('P', v1, v0), M('P', v1, a))))
print('   parameter version: predicates', predicates(PBp, QBp, 2, 1), '; pattern lgg == T_B:', equiv(pattern_lgg(Dp), T_B),
      '; witness %s covers data %s, misses the probe: %s' % (pp(Twp), all(covers(Twp, d) for d in Dp), not covers(Twp, miss)))

print('\n(3b) DT anchor that is not an SO anchor (T_A)')
PB = [IN(h0, h1), NOT(EQ(h0, h1))]
QB = [IN(h1, h0), NOT(EQ(h0, h0))]
D = inst('A', PB, QB)
print('   predicates (R,N,D^PAT,D^DT,D+):', predicates(PB, QB, 2, 2))
Tso = ALL(ALL(IMP(M('G', v1, v0, v1), M('G', v1, v1, v0))))
missA = instantiate(T_A, {'P': IN(h0, h1), 'Q': NOT(EQ(h0, h0))})
print('   SO template %s: determinate %s, covers data %s, covers %s: %s'
      % (pp(Tso), is_determinate(Tso), all(covers(Tso, d) for d in D), pp(missA), covers(Tso, missA)))
probesA = probes_for('A', random.Random(5))
ncov, wit = search(D, probesA, [a], gmax=2, amax=2, degree='DT')
print('   DT search (group size <= 2, arity <= 2): covering templates %d, witnesses missing a probe: %d' % (ncov, len(wit)))
ncov3, wit3 = search(D, probesA, [a], gmax=2, amax=3, degree='DT')
print('   DT search (group size <= 2, arity <= 3): covering templates %d, witnesses missing a probe: %d' % (ncov3, len(wit3)))
ncovs, wits = search(D, probesA, [a], gmax=2, amax=3, degree='SO')
print('   SO search (group size <= 2, arity <= 3): first witness %s' % (pp(wits[0][0]) if wits else None))

print('\n(4) SO (bounded search, group size <= 2, arity <= 3) on random pairs with (R)&(N): D+ => anchor?')
for key in 'AB':
    nP, nQ = ARITY[key]
    probes = probes_for(key, random.Random(5))
    stats = {}
    tot = 0
    while tot < 120:
        PB, QB = draw(rng, key, 2)
        R, N, dpat, ddt, dplus = predicates(PB, QB, nP, nQ)
        if not (R and N): continue
        if rng.random() < 0.5 and dplus: continue      # oversample the interesting D^DT-without-D+ pairs
        D = inst(key, PB, QB)
        ncov, wit = search(D, probes, [a], gmax=2, amax=3, degree='SO')
        k = ('D+' if dplus else ('D^DT not D+' if ddt else 'not D^DT'))
        st = stats.setdefault(k, [0, 0]); st[0] += 1; st[1] += (not wit)
        tot += 1
    print('   T_%s: ' % key + '; '.join('%s: %d pairs, SO anchors %d' % (k, v[0], v[1]) for k, v in sorted(stats.items())))
print('time %.1fs' % (time.time() - t0))
