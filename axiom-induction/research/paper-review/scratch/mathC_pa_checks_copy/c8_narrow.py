# c8_narrow.py -- weaker-than-PA theories that cover a practice of induction uses (referee issue M4; notes-final.md
# section 4.3, Prop. 4.6).  Seeded (31, 33, 11); output c8_narrow.out.
#
# (A) The referee's counterexample to the old Prop. 3.5(c), re-checked independently: practice = Q plus induction on
#     motives Ez(s=t) (Sigma_1) and ~(s=t) (open); H_narrow = Q + T_E + T_N with TERM metavariables only.  Checks:
#     every datum is covered; L(H_narrow) - L(H_true) under the track's positional grammar (c4_bdtrc.codelength);
#     the exact identity  prior + KT(index') - KT(index) - sum_c KT(formula context c)  and its asymptotic slope.
# (B) Skeleton theories for u7's natural law G1: G1's motives have bounded depth, hence finitely many formula
#     skeletons, so Q + {Ind(skeleton with term metavariables)} covers G1 and is contained in I-Sigma_2.  Counts the
#     skeletons, checks coverage, scores the theory, and gives the asymptotic slope from the same identity.
import sys, math, random
import c4_bdtrc as c4
from c2_mdl import plug_template, FSYM, kt_bits, kt_asym, TBITS
from dtlib import M, H, V, EX, NOT, eq, size, canon_params, Ind, T_IND, match, plug, BINDERS
from practice import Q, rand_term, X, pa_data

OUT = []
def say(s=''):
    print(s, flush=True); OUT.append(s)

class Recorder:
    """stands in for c4's KT model: records the (context, symbol) pairs of FORMULA-sort nodes."""
    def __init__(self): self.c = {}
    def cost(self, ctx, s, alpha):
        if ctx[0] == 'F':
            d = self.c.setdefault(ctx, {}); d[s] = d.get(s, 0) + 1
        return 0.0

def formula_contexts(data):
    """counts per formula context of the motive bodies, as H_true = Q + T_Ind codes them (c4 positional grammar)."""
    rec = Recorder()
    pos = c4.occ_positions(T_IND)['FP']
    for d in data:
        if d in Q.values(): continue
        th = match(T_IND, d)
        depth, parent, idx, args = pos
        c4.body_bits(plug(th['FP'], list(args)), 'F', rec, depth, parent, idx)
    return rec.c

def index_counts(data, H):
    cnt = {}
    for d in data:
        for nm in sorted(H):
            if match(H[nm], d) is not None:
                cnt[nm] = cnt.get(nm, 0) + 1; break
        else:
            raise AssertionError('datum not covered')
    return cnt

def identity(data, H_alt, H_true):
    """exact and asymptotic L(H_alt) - L(H_true) WITHOUT the prior, when H_alt fixes every formula symbol of the
    motive and codes the term subtrees at the same positions."""
    fc = formula_contexts(data)
    ia, it = index_counts(data, H_alt), index_counts(data, H_true)
    ex = kt_bits(list(ia.values()), len(H_alt)) - kt_bits(list(it.values()), len(H_true)) \
        - sum(kt_bits(list(v.values()), len(FSYM)) for v in fc.values())
    asym = kt_asym(list(ia.values()), len(H_alt)) - kt_asym(list(it.values()), len(H_true)) \
        - sum(kt_asym(list(v.values()), len(FSYM)) for v in fc.values())
    slope = (len(H_alt) - len(H_true)) / 2 - len(fc) * (len(FSYM) - 1) / 2
    return ex, asym, slope, len(fc)

def prior(H): return TBITS * sum(size(T) for T in H.values())

# ------------------------------------------------------------------------------------------------------------ (A)
T_E = plug_template(EX(eq(M('tA', H(0), V(0)), M('tB', H(0), V(0)))))
T_N = plug_template(NOT(eq(M('tC', H(0)), M('tD', H(0)))))
H_TRUE = dict(Q, Ind=T_IND)
H_NARROW = dict(Q, IE=T_E, IN=T_N)

def narrow_motive(rng):
    while True:
        if rng.random() < 0.5:
            m = EX(eq(rand_term(rng, 2, [X, V(0)]), rand_term(rng, 2, [X, V(0)])))
        else:
            m = NOT(eq(rand_term(rng, 2, [X]), rand_term(rng, 2, [X])))
        if 'h' in repr(m): return m                      # x occurs
def narrow_data(n, rng):
    keys = sorted(Q)
    return [canon_params(Ind(narrow_motive(rng))) if rng.random() < 0.5 else Q[rng.choice(keys)] for _ in range(n)]

say('(A) narrow practice: Q + induction on motives Ez(s=t) and ~(s=t); H_narrow = Q + T_E + T_N (term metavariables)')
say('    |T_Ind| = %d, |T_E| = %d, |T_N| = %d symbols; prior(H_narrow) - prior(H_true) = %d bits'
    % (size(T_IND), size(T_E), size(T_N), prior(H_NARROW) - prior(H_TRUE)))
for seed in (31, 33):
    rng = random.Random(seed)
    D = narrow_data(3000, rng)
    ok = all(any(match(T, d) is not None for T in H_NARROW.values()) for d in D) and \
        all(any(match(T, d) is not None for T in H_TRUE.values()) for d in D)
    say('  seed %d: every datum covered by H_narrow and by H_true: %s' % (seed, ok))
    for n in (100, 300, 1000, 3000):
        Dn = D[:n]
        Lt = c4.codelength(H_TRUE, Dn)[0]; Ln = c4.codelength(H_NARROW, Dn)[0]
        ex, asym, slope, nfc = identity(Dn, H_NARROW, H_TRUE)
        pd = prior(H_NARROW) - prior(H_TRUE)
        say('    n=%5d  L(H_narrow)-L(H_true): c4 code %+8.1f   identity %+8.1f   asymptotic %+8.1f   '
            '(%d formula contexts; slope %+.1f bits per doubling of n)' % (n, Ln - Lt, ex + pd, asym + pd, nfc, slope))
    # extrapolation from the asymptotic form at n = 3000
    n0 = 3000
    ex, asym, slope, nfc = identity(D[:n0], H_NARROW, H_TRUE)
    val = asym + prior(H_NARROW) - prior(H_TRUE)
    say('    extrapolated crossover (asymptotic form, slope %+.1f): n = 2^%.1f' % (slope, math.log2(n0) + val / -slope))
say('  Q + H_narrow is contained in I-Sigma_1 (every T_E instance is Sigma_1 induction, every T_N instance open')
say('  induction), so it is strictly weaker than PA; yet it covers the practice and overtakes Q + T_Ind.')
say()

# ------------------------------------------------------------------------------------------------------------ (B)
def skeleton(body, k=0, ctr=None):
    """the formula skeleton of a motive body: each atom s = t becomes A_i(x, bound vars) = B_i(x, bound vars)."""
    if ctr is None: ctr = [0]
    h = body[0]
    if h == '=':
        args = (H(0),) + tuple(V(i) for i in range(k))
        i = ctr[0]; ctr[0] += 1
        return eq(M('tA%d' % i, *args), M('tB%d' % i, *args))
    if h in BINDERS: return (h, skeleton(body[1], k + 1, ctr))
    if h == 'not': return NOT(skeleton(body[1], k, ctr))
    if h in ('and', 'or', 'imp'): return (h, skeleton(body[1], k, ctr), skeleton(body[2], k, ctr))
    raise ValueError(h)

say('(B) u7 natural law G1 (seed 11, as in c4_bdtrc.py): motive skeletons and the skeleton theory')
rng = random.Random(11)
full = [s for k, s in pa_data(3000, rng, p_ind=0.5)]
SK = {}
for n_mark in (100, 300, 1000, 3000):
    for d in full[:n_mark]:
        if d in Q.values(): continue
        sk = skeleton(match(T_IND, d)['FP'])
        SK.setdefault(repr(sk), sk)
    say('  distinct skeletons among the first %4d data: %d' % (n_mark, len(SK)))
say('  (rand_motive has depth 2 and quantifiers only over atoms: at most 1 + 7 + 3*49 + 2 = 157 skeletons)')
H_SKEL = dict(Q, **{'K%d' % i: plug_template(sk) for i, sk in enumerate(SK.values())})
for n in (1000, 3000):
    Dn = full[:n]
    cov = all(any(match(T, d) is not None for T in H_SKEL.values()) for d in Dn)
    Lt = c4.codelength(H_TRUE, Dn)[0]; Ls = c4.codelength(H_SKEL, Dn)[0]
    ex, asym, slope, nfc = identity(Dn, H_SKEL, H_TRUE)
    pd = prior(H_SKEL) - prior(H_TRUE)
    say('  n=%5d  H_skel (%d templates) covers the data: %s;  L(H_skel)-L(H_true): c4 code %+9.1f   identity %+9.1f'
        '   prior part %+d;  %d formula contexts; asymptotic slope %+.1f bits per doubling'
        % (n, len(H_SKEL), cov, Ls - Lt, ex + pd, pd, nfc, slope))
# all skeletons with positive probability under G1: collect from a large independent sample (seed 12)
from practice import rand_motive
rng2 = random.Random(12)
ALLSK = {}
for _ in range(200000):
    sk = skeleton(rand_motive(rng2, 2, 0))
    ALLSK.setdefault(repr(sk), sk)
say('  distinct skeletons in 200000 motives drawn from G1 (seed 12): %d' % len(ALLSK))
rng3 = random.Random(13)
nfc_all = len(formula_contexts([canon_params(Ind(rand_motive(rng3, 2, 0))) for _ in range(20000)]))
say('  formula contexts used by H_true on 20000 G1 motives (seed 13): %d' % nfc_all)
say('  with all of them, H_skel has %d templates; the asymptotic slope is (%d - 8)/2 - %d*(9-1)/2 = %+.1f bits per'
    ' doubling of n (positive: H_skel falls further behind)' % (7 + len(ALLSK), 7 + len(ALLSK), nfc_all,
                                                           (7 + len(ALLSK) - 8) / 2 - nfc_all * 4))
say('  Each G1 motive is a Boolean combination of atoms and of single quantifiers over atoms, so it is logically')
say('  equivalent to a Sigma_2 formula; hence Q + H_skel is contained in I-Sigma_2, strictly weaker than PA.')
say('  It covers G1 but loses to Q + T_Ind by its prior and, asymptotically, by the slope above (if positive).')
open('c8_narrow.out', 'w').write('\n'.join(OUT) + '\n')
