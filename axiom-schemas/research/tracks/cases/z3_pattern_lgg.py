# Track "cases", Part 2(f): higher-order pattern anti-unification (Pfenning 1991; Baumgartner-Kutsia-Levy-
# Villaret 2017 style, n-ary, own implementation st_core.pattern_lgg) on ZF-schema instances.
# Claims checked: the pattern lgg (i) is a pattern template covering the data, (ii) is always <= T* (sound),
# (iii) equals T* iff (R) and all (N_i) hold (Corollary F); on all pairs and on 400 random triples per schema.
# Contrast: on PA induction the pattern lgg is the unsound T12 (prior C9) -- reproduced with the prior code.
import sys, itertools, random
from st_core import *
from st_pool import pool_for

rng = random.Random(7)
for nm in SCHEMAS:
    T = SCHEMAS[nm]['T']; P = pool_for(nm); n = len(SCHEMAS[nm]['args']); ks = list(P)
    for r in (2, 3):
        combos = list(itertools.combinations(ks, r))
        if r == 3: combos = rng.sample(combos, 400)
        agree = ok_pat = ok_cov = ok_sound = rec = 0
        for c in combos:
            bs = [P[k] for k in c]
            D = [instance(nm, b) for b in bs]
            L = pattern_lgg(D)
            ok_pat += is_pattern_template(L)
            ok_cov += all(covers(L, s) for s in D)
            ok_sound += subsumes(T, L)
            got = equiv(L, T)
            rec += got
            agree += got == (pred_R(bs) and all(pred_N(bs, n)))
        print('%-6s %d-sets %4d: pattern %4d  covers %4d  <=T* %4d  ==T* %4d  (==T*) <=> (R)&(N): %4d'
              % (nm, r, len(combos), ok_pat, ok_cov, ok_sound, rec, agree))
    # one example each
    k1, k2 = ks[0], ks[4]
    L = pattern_lgg([instance(nm, P[k1]), instance(nm, P[k2])])
    print('       e.g. bodies %s, %s ->  %s' % (k1, k2, pp(L)))
    for c in itertools.combinations(ks, 2):
        bs = [P[k] for k in c]
        if pred_R(bs) and not all(pred_N(bs, n)):
            L = pattern_lgg([instance(nm, b) for b in bs])
            print('       non-anchor (R holds, some N_i fails) e.g. %s, %s -> %s' % (c[0], c[1], pp(L))); break
    for c in itertools.combinations(ks, 2):
        bs = [P[k] for k in c]
        if not pred_R(bs) and all(pred_N(bs, n)):
            L = pattern_lgg([instance(nm, b) for b in bs])
            print('       non-anchor (R fails) e.g. %s, %s -> %s' % (c[0], c[1], pp(L))); break

# PA induction, prior code: the pattern lgg is T12 (unsound) -- for contrast
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/prior/induction')
import so_core as so
def occurs(t, k):
    if t == ('v', k): return True
    return any(occurs(c, k) for c in so.kids(t))
def plgg_pa(ss):
    store = {}
    def go(cols, D):
        c0 = cols[0]
        if all(c == c0 for c in cols): return c0
        if all(c[0] == c0[0] and len(so.kids(c)) == len(so.kids(c0)) for c in cols) and c0[0] != 'v':
            nD = D + 1 if c0[0] in so.BINDERS else D
            ch = [so.kids(c) for c in cols]
            return so.rebuild(c0, [go([x[i] for x in ch], nD) for i in range(len(ch[0]))])
        ys = tuple(so.V(k) for k in range(D) if any(occurs(c, k) for c in cols))
        key = (tuple(cols), ys)
        if key not in store: store[key] = 'X%d' % len(store)
        return ('M', store[key]) + ys
    return go(list(ss), 0)
L = plgg_pa([so.Ind(so.eq(so.X, so.X)), so.Ind(so.NOT(so.eq(so.X, so.Z)))])
print('\nPA induction (prior so_core): pattern lgg of {Ind(x=x), Ind(~x=0)} =', so.pp(L), '; equals T_ind:',
      so.subsumes(L, so.T_IND) and so.subsumes(so.T_IND, L))
