# c4_bdtrc.py -- posterior over finite unions of DT^o templates on unlabelled data ("Bayesian DTRC"), track "pa",
# notes.md section 4.  Seeded; output in c4_bdtrc.out.
#
# Likelihood L0 (citation), marginalised:  each datum picks a template (Dirichlet(1/2) mixture weights: sequential
# KT over the templates of H) and its metavariable bodies are coded by ONE shared, positional instantiation grammar
# (sequential KT, context = (sort, depth, parent symbol, child index)): each body is coded as the subtree of the
# datum at the metavariable's read-off occurrence, continuing the sentence's parse tree there.  So two templates
# that fix different amounts of the same sentence code the remaining symbols in the same contexts.  A datum covered by several
# templates is coded by the cheapest (two-part approximation of the sum).  Prior: 5 bits per template symbol.
# So  L(H) = -log2 [prior(H) * marginal likelihood(D | H)]  up to the two-part approximation, and the posterior over
# a candidate set is proportional to 2^(-L(H)).
# Negative data N (sentences certified false): H gets likelihood 0 if some template of H has an instance in N
# (the "refuted => likelihood 0" rule; under L0, "derives" means "has as an instance").
import sys, math, random
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code')
from dtlib import *
from practice import Q, pa_data, rand_closed
from c2_mdl import KT, sym, FSYM, TSYM, SPLIT, ROOTS, TBITS

def occ_positions(T):
    """for each metavariable of T: (depth, parent symbol, child index, args) of its LAST pattern occurrence in
    preorder (the last occurrence if none is a pattern occurrence).  The body is coded as the subtree of the datum
    at that position, continuing the sentence's parse tree there (positional shared grammar)."""
    pos = {}
    def is_pattern(args):
        return all(a[0] == 'v' for a in args) and len(set(args)) == len(args)
    def walk(t, depth, parent, idx):
        if t[0] == 'M':
            args = t[2:]
            prev = pos.get(t[1])
            if prev is None or is_pattern(args) or not prev[4]:
                pos[t[1]] = (depth, parent, idx, args, is_pattern(args))
            return
        for i, k in enumerate(kids(t)):
            walk(k, depth + 1, sym(t), i)
    walk(T, 0, 'ROOT', 0)
    return {m: p[:4] for m, p in pos.items()}

def body_bits(body, sort, model, depth0=0, parent0='ROOT', idx0=0):
    total = 0.0
    def walk(t, parent, idx, depth, srt):
        nonlocal total
        alpha = FSYM if srt == 'F' else TSYM
        total += model.cost((srt, depth, parent, idx), sym(t), alpha)
        cs = child_sorts(t)
        for i, k in enumerate(kids(t)):
            walk(k, sym(t), i, depth + 1, cs[i])
    walk(body, parent0, idx0, depth0, sort)
    return total

def code_bodies(T, th, model, update=True):
    if not update:
        m2 = KT(); m2.c = {k: dict(v) for k, v in model.c.items()}
        model = m2
    pos = occ_positions(T)
    tot = 0.0
    for m in sorted(th):
        depth, parent, idx, args = pos[m]
        sub = plug(th[m], list(args))          # the datum's subtree at the occurrence
        tot += body_bits(sub, 'F' if m[0] == 'F' else 'T', model, depth, parent, idx)
    return tot

def codelength(H, data, N=()):
    """H: dict name -> template.  Returns (bits, prior bits) or (inf, prior) if refuted or a datum is uncovered."""
    prior = TBITS * sum(size(T) for T in H.values())
    for nsent in N:
        for T in H.values():
            if match(T, nsent) is not None:
                return math.inf, prior
    idx, model = KT(), KT()
    names = sorted(H)
    bits = 0.0
    for d in data:
        best = None
        for nm in names:
            th = match(H[nm], d)
            if th is None: continue
            c = -math.log2((idx.c.get('i', {}).get(nm, 0) + 0.5) / (sum(idx.c.get('i', {}).values()) + 0.5 * len(names)))
            c += code_bodies(H[nm], th, model, update=False)
            if best is None or c < best[0]: best = (c, nm, th)
        if best is None:
            return math.inf, prior
        c, nm, th = best
        bits += idx.cost('i', nm, names)
        bits += code_bodies(H[nm], th, model)
    return bits + prior, prior

def posterior(Ls):
    finite = {k: v for k, v in Ls.items() if v < math.inf}
    m = min(finite.values())
    w = {k: 2 ** (-(v - m)) for k, v in finite.items()}
    Z = sum(w.values())
    return {k: (w.get(k, 0.0) / Z) for k in Ls}

# ------------------------------------------------------------------------------------------------ candidates
F0 = M('F0')
T_LINF = IMP(AND(M('F1'), ALL(IMP(M('F2', V(0)), M('F3', V(0))))), ALL(M('F2', V(0))))
T_SPARE = IMP(M('F1'), M('F1'))
def candidates(data):
    inds = sorted({s for k, s in data if not k.startswith('Q')}, key=repr)
    C = {}
    C['true  Q+T_Ind'] = dict(Q, Ind=T_IND)
    C['root  Q+T_f (7 roots)'] = dict(Q, **{'Ind_' + f: SPLIT[f] for f in ROOTS})
    C['spare Q+T_Ind+(F->F)'] = dict(Q, Ind=T_IND, Spare=T_SPARE)
    C['mem   Q+instances'] = dict(Q, **{'m%d' % i: s for i, s in enumerate(inds)})
    C['over  Q+T_Linf'] = dict(Q, Linf=T_LINF)
    C['lumpQ F0+T_Ind'] = {'F0': F0, 'Ind': T_IND}
    C['bare  F0'] = {'F0': F0}
    return C

# negative data: closure-normal false sentences (certified by evaluation in N)
NEG = [eq(Z, S(Z)),
       IMP(AND(eq(Z, Z), ALL(IMP(eq(Z, S(Z)), eq(Z, S(Z))))), ALL(eq(Z, S(Z))))]   # false instance of T_Linf

if __name__ == '__main__':
    out = []
    def say(x=''):
        print(x, flush=True); out.append(x)
    say('(A) PA practice (u7 law G1: Q1..Q7 ground, induction with prob 0.5), unlabelled; seed 11')
    rng = random.Random(11)
    full = pa_data(3000, rng, p_ind=0.5)
    data_strip = [s for k, s in full]
    for n in (10, 30, 100, 300, 1000, 3000):
        D = full[:n]
        C = candidates(D)
        for label, NN in (('no negatives', ()), ('negatives {0=S0, false T_Linf instance}', NEG)):
            Ls = {k: codelength(H, [s for _, s in D], NN)[0] for k, H in C.items()}
            post = posterior(Ls)
            ref = Ls['true  Q+T_Ind']
            say('  n=%5d  %s' % (n, label))
            for k in C:
                say('     %-24s  L-L_true %+10.1f bits   posterior %.3e' % (k, Ls[k] - ref, post[k]))
    say()
    say('(B) the universal x+0=x from closed instances t+0=t (t random closed terms, u7 rand_closed); seed 12')
    rng = random.Random(12)
    inst = [eq(add(t, Z), t) for t in (rand_closed(rng, 3) for _ in range(3000))]
    TS = eq(add(M('tz'), Z), M('tz'))
    TOVER = eq(add(M('tz1'), Z), M('tz2'))
    SPL = {'s0': eq(add(Z, Z), Z), 'sS': eq(add(S(M('tz')), Z), S(M('tz'))),
           'sA': eq(add(add(M('tz1'), M('tz2')), Z), add(M('tz1'), M('tz2'))),
           'sM': eq(add(mul(M('tz1'), M('tz2')), Z), mul(M('tz1'), M('tz2')))}
    for n in (10, 30, 100, 300, 1000, 3000):
        D = inst[:n]
        distinct = sorted(set(D), key=repr)
        C = {'schema  z+0=z': {'s': TS}, 'split by head of t (sound)': SPL,
             'mem     instances': {'m%d' % i: s for i, s in enumerate(distinct)},
             'over    z1+0=z2': {'o': TOVER}}
        Ls = {k: codelength(H, D)[0] for k, H in C.items()}
        # L1: the sentence Ax(x+0=x) cited and instantiated by one forall-elimination step per datum: same term code
        # as the schema plus the extra step (rule choice among 10 rules + a premise pointer, >= log2(10) bits)
        Ls['L1: Ax(x+0=x) + forall-E'] = Ls['schema  z+0=z'] - TBITS * size(TS) + TBITS * (size(TS) + 1) \
            + n * math.log2(10)
        post = posterior(Ls)
        ref = Ls['schema  z+0=z']
        say('  n=%5d (%d distinct)' % (n, len(distinct)))
        for k in Ls:
            say('     %-28s  L-L_schema %+10.1f bits   posterior %.3e' % (k, Ls[k] - ref, post[k]))
        Ln = codelength(C['over    z1+0=z2'], D, [eq(add(Z, Z), S(Z))])[0]
        say('     with the negative 0+0=S0, the over-general template is refuted: L = %s' % Ln)
    open('c4_bdtrc.out', 'w').write('\n'.join(out) + '\n')
