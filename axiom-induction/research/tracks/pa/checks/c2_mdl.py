# c2_mdl.py -- the MDL comparison of ../axiom-schemas (sec:many:mdl, app:many:mdl, table tab:many:mdl; script
# research/tracks/untagged/code/u7_mdl.py) re-run as a Bayes-factor computation, with two new instantiation
# grammars (track "pa", notes.md section 2).  The code-length machinery below is copied from u7_mdl.py (which runs
# its experiment at import time); the data generators are imported from the untagged prototype unchanged.
#
# Every code here is a Bayesian marginal likelihood: sequential KT with counts (n_s + 1/2)/(N + |alphabet|/2) is the
# Dirichlet(1/2) mixture, so  L(H) = template bits + (-log2 marginal likelihood of the data under H),  and
# L(H_root) - L(H_true) is  log2 of the posterior odds  P(H_true | D) / P(H_root | D)  for a prior of 5 bits per
# template symbol.  Positive: the posterior prefers keeping T_Ind whole.
#
# Grammars (contexts for the KT model of each body symbol):
#   NAIVE  uniform per symbol (u7)
#   PC     (template, parent, child index), per template (u7)
#   DPC    (template, depth, parent, child index), per template (u7)
#   SDPC   (depth, parent, child index), ONE grammar shared by all templates; the split templates' bodies are
#          coded in the context their position in T_Ind would have (depth 1, parent = the template's root symbol).
#          So the split changes only how the root symbol is coded (index instead of grammar).            [new]
#   RDPC   H_true: (template, root symbol of the motive, depth, parent, child index): the grammar may condition on
#          the motive's root; H_root: DPC as in u7 (its template already fixes the root).                 [new]
#   CF     (sort): one shared context-free grammar (symbol frequencies per sort, as in a PCFG with one formula and
#          one term nonterminal: the brief's H1 grammar Q); run separately by c2b_cf.py.                  [new]
import sys, random, math
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code')
from dtlib import *
from practice import Q, pa_data, rand_motive, X, rand_term
import practice

FSYM = ['=', 'not', 'and', 'or', 'imp', 'all', 'ex', 'top', 'bot']
TSYM = ['0', 'S', '+', '*', 'h0', 'h1', 'h2', 'v0', 'v1', 'v2', 'v3', 'a1', 'a2', 'a3']
def sym(t):
    h = t[0]
    if h == 'h': return 'h%d' % t[1]
    if h == 'v': return 'v%d' % t[1]
    if h == 'p': return t[1]
    return h

def plugM(body, args, j=0):
    h = body[0]
    if h == 'h': return shift(args[body[1]], j)
    if h in BINDERS: return (h, plugM(body[1], args, j + 1))
    if h == 'M': return ('M', body[1]) + tuple(plugM(a, args, j) for a in body[2:])
    ks = kids(body)
    return body if not ks else rebuild(body, [plugM(k, args, j) for k in ks])

def plug_template(body):
    def inst(T):
        if T[0] == 'M' and T[1] == 'FP':
            return plugM(body, list(T[2:]))
        ks = kids(T)
        return T if not ks else rebuild(T, [inst(k) for k in ks])
    return inst(T_IND)

def split_template(f):
    hs = H(0)
    if f == '=': body = eq(M('tL', hs), M('tR', hs))
    elif f == 'not': body = NOT(M('F1', hs))
    elif f in ('and', 'or', 'imp'): body = (f, M('F1', hs), M('F2', hs))
    else: body = (f, M('F1', hs, V(0)))
    return plug_template(body)

ROOTS = ['=', 'not', 'and', 'or', 'imp', 'all', 'ex']
SPLIT = {f: split_template(f) for f in ROOTS}
# position of each split metavariable inside the root node (child index), for SDPC
MV_IDX = {'tL': 0, 'tR': 1, 'F1': 0, 'F2': 1}

class KT:
    def __init__(self): self.c = {}
    def cost(self, ctx, s, alpha):
        d = self.c.setdefault(ctx, {})
        tot = sum(d.values())
        p = (d.get(s, 0) + 0.5) / (tot + 0.5 * len(alpha))
        d[s] = d.get(s, 0) + 1
        return -math.log2(p)

def body_cost(body, sort, model, mode, tname, depth0, root_parent='ROOT', root_idx=0, motive_root=None):
    total = 0.0
    def walk(t, ctx_parent, idx, depth, srt):
        nonlocal total
        s = sym(t)
        alpha = FSYM if srt == 'F' else TSYM
        if mode == 'NAIVE':
            total += math.log2(len(FSYM) + len(TSYM))
        else:
            if mode == 'PC': ctx = (tname, ctx_parent, idx)
            elif mode == 'DPC': ctx = (tname, depth, ctx_parent, idx)
            elif mode == 'SDPC': ctx = (depth, ctx_parent, idx)
            elif mode == 'CF': ctx = (srt,)                   # shared context-free grammar (one PCFG nonterminal per sort)
            elif mode == 'RDPC':
                ctx = (tname, depth, ctx_parent, idx) if depth == 0 else (tname, motive_root, depth, ctx_parent, idx)
            total += model.cost(ctx, s, alpha)
        cs = child_sorts(t)
        for i, k in enumerate(kids(t)):
            walk(k, s, i, depth + 1, cs[i])
    walk(body, root_parent, root_idx, depth0, sort)
    return total

TBITS = 5   # template prior: 5 bits per template symbol (as in u7)

def codelength(data, Hname, mode, charge='all'):
    """L(H) in bits and its template part.  charge='all' (default, corrected after the referee, issue m1): the prior
    charges every template the hypothesis lists.  charge='u7': only templates some datum uses (u7_mdl.py's
    bookkeeping, kept only to reproduce tab:many:mdl).  The KT index code always ranges over all listed templates."""
    if Hname == 'true':
        Ts = dict(Q); Ts['Ind'] = T_IND
    elif Hname == 'root':
        Ts = dict(Q); Ts.update({'Ind_' + f: SPLIT[f] for f in ROOTS})
    else:   # 'used': split only into the roots that occur in the data (no spare split templates)
        present = sorted({s[2][1][0] for k, s in data if not k.startswith('Q')})
        Ts = dict(Q); Ts.update({'Ind_' + f: SPLIT[f] for f in present})
    used = set()
    idx = KT(); model = KT()
    bits = 0.0
    for k, s in data:
        if k.startswith('Q'):
            tn = k
        else:
            tn = 'Ind' if Hname == 'true' else 'Ind_' + s[2][1][0]
        used.add(tn)
        bits += idx.cost('idx', tn, list(Ts))
        th = match(Ts[tn], s)
        assert th is not None
        mroot = s[2][1][0] if not k.startswith('Q') else None
        bmode = mode
        if mode == 'RDPC' and Hname != 'true': bmode = 'DPC'
        for nm in sorted(th):
            srt = 'F' if nm[0] == 'F' else 'T'
            if Hname == 'true':
                bits += body_cost(th[nm], srt, model, bmode, tn + nm if bmode != 'NAIVE' else '', 0,
                                  motive_root=mroot)
            elif bmode in ('SDPC', 'CF'):
                b = th[nm]
                if mroot in ('all', 'ex'):
                    b = plug(b, [H(0), V(0)])   # code the body in H_true's convention (hole 1 -> bound var 0)
                bits += body_cost(b, srt, model, bmode, '', 1, root_parent=mroot, root_idx=MV_IDX[nm])
            else:
                bits += body_cost(th[nm], srt, model, bmode, tn + nm if bmode != 'NAIVE' else '', 1)
    tmpl_bits = sum(TBITS * size(Ts[t]) for t in (Ts if charge == 'all' else used))
    return bits + tmpl_bits, tmpl_bits

# ---- usage laws.  G1: u7's natural law (pa_data).  G2: u7's law for which DPC is well specified.
FLAW = {0: [('=', .5), ('not', .2), ('and', .15), ('imp', .15)], 1: [('=', .7), ('not', .3)]}
def g2_formula(rng, d):
    law = FLAW.get(d, [('=', 1.0)])
    r, acc = rng.random(), 0
    for f, p in law:
        acc += p
        if r < acc: break
    if f == '=': return eq(g2_term(rng, d + 1, '=', 0), g2_term(rng, d + 1, '=', 1))
    if f == 'not': return NOT(g2_formula(rng, d + 1))
    return (f, g2_formula(rng, d + 1), g2_formula(rng, d + 1))
def g2_term(rng, d, parent, idx):
    if d >= 4: return rng.choice([Z, X])
    r = rng.random()
    p_s, p_add = (0.25, 0.25) if parent == '=' else (0.2, 0.1)
    if r < p_s: return S(g2_term(rng, d + 1, 'S', 0))
    if r < p_s + p_add: return add(g2_term(rng, d + 1, '+', 0), g2_term(rng, d + 1, '+', 1))
    return Z if rng.random() < (0.3 if idx == 0 else 0.6) else X
def g2_data(n, rng, p_ind=0.5):
    out = []
    for _ in range(n):
        if rng.random() < p_ind:
            out.append(('Ind', canon_params(Ind(g2_formula(rng, 0)))))
        else:
            k = rng.choice(sorted(Q)); out.append((k, Q[k]))
    return out

# G3: u7's natural law restricted to three roots (=, imp, all): roots the community never uses
def g3_data(n, rng, p_ind=0.5):
    old = practice.ROOT_LAW
    practice.ROOT_LAW = [('=', .6), ('imp', .25), ('all', .15)]
    try:
        return pa_data(n, rng, p_ind=p_ind)
    finally:
        practice.ROOT_LAW = old

# ---- exact SDPC identity and its asymptotic (Occam) form.  Under SDPC the two hypotheses code every body symbol
# below the motive root in the same context and in the same order, so those costs are identical; they differ only in
# (i) the prior, (ii) the KT index code, (iii) H_true's root context (depth 0, ROOT, 0), alphabet FSYM.  Sequential
# KT equals the Dirichlet(1/2) marginal, hence the identity below (exact), and Stirling gives its expansion.
LG = math.lgamma
def kt_bits(counts, A):
    """-log2 of the Dirichlet(1/2) marginal of a count vector over an alphabet of A symbols (zeros may be omitted)."""
    n = sum(counts)
    return -(LG(A / 2) - LG(n + A / 2) + sum(LG(c + 0.5) - LG(0.5) for c in counts)) / math.log(2)
def kt_asym(counts, A):
    """n*H(empirical) + (A-1)/2 log2 n + C(A,k): the expansion of kt_bits when every nonzero count grows linearly.
    C(A,k) = [(1-k)/2 ln(2 pi) + k ln Gamma(1/2) - ln Gamma(A/2)] / ln 2, k = number of nonzero counts."""
    cs = [c for c in counts if c > 0]
    n, k = sum(cs), len(cs)
    H = -sum(c * math.log2(c / n) for c in cs)
    C = ((1 - k) / 2 * math.log(2 * math.pi) + k * LG(0.5) - LG(A / 2)) / math.log(2)
    return H + (A - 1) / 2 * math.log2(n) + C
def sdpc_identity(data, roots_listed):
    """returns (exact prediction, asymptotic prediction) of L(H_F) - L(H_true) under SDPC without the prior."""
    from collections import Counter
    q = Counter(k for k, s in data if k.startswith('Q'))
    r = Counter(s[2][1][0] for k, s in data if not k.startswith('Q'))
    n_ind = sum(r.values())
    idx_true = list(q.values()) + [n_ind]
    idx_F = list(q.values()) + [r.get(f, 0) for f in roots_listed]
    A_T, A_F = len(Q) + 1, len(Q) + len(roots_listed)
    exact = kt_bits(idx_F, A_F) - kt_bits(idx_true, A_T) - kt_bits(list(r.values()), len(FSYM))
    asym = kt_asym(idx_F, A_F) - kt_asym(idx_true, A_T) - kt_asym(list(r.values()), len(FSYM))
    return exact, asym

if __name__ == '__main__':
    NS = [int(a) for a in sys.argv[1:]] or [1000, 4000, 16000, 64000, 256000]
    MODES = ('NAIVE', 'PC', 'DPC', 'SDPC', 'RDPC')
    lines = []
    def say(s):
        print(s, flush=True); lines.append(s)
    say('L(H) - L(H_true) in bits = log2 posterior odds (H_true : H); positive keeps T_Ind whole.')
    say('Template prior: %d bits per symbol, charged for EVERY listed template (corrected; referee m1).' % TBITS)
    say('H_root = Q + all 7 root templates; H_used = Q + the root templates of the roots that occur (the split H_F of')
    say('app:many:mdl, F = main connectives of the induction data; index alphabet restricted to them).')
    say('Seeds: random.Random(n) for each n (as in u7).')
    for gen_name, gen in (('G1 natural (u7)', lambda n, r: pa_data(n, r, p_ind=0.5)),
                          ('G2 well specified for DPC (u7)', g2_data),
                          ('G3 natural, roots {=,imp,all} only', g3_data)):
        say('usage law: ' + gen_name)
        for n in NS:
            rng = random.Random(n)
            data = gen(n, rng)
            present = sorted({s[2][1][0] for k, s in data if not k.startswith('Q')})
            unused_prior = TBITS * sum(size(SPLIT[f]) for f in ROOTS if f not in present)
            say('  n=%6d  roots used %s; prior of the unused root templates %d bits' % (n, present, unused_prior))
            for mode in MODES:
                Lt, tt = codelength(data, 'true', mode)
                Lr, tr = codelength(data, 'root', mode)
                if len(present) < len(ROOTS):
                    Lu, tu = codelength(data, 'used', mode)
                else:
                    Lu, tu = Lr, tr
                row = '    %-5s H_root %+9.1f   H_used %+9.1f   [u7 bookkeeping for H_root: %+9.1f]' % (
                    mode, Lr - Lt, Lu - Lt, Lr - Lt - unused_prior)
                if mode == 'SDPC':
                    ex_r, as_r = sdpc_identity(data, ROOTS)
                    ex_u, as_u = sdpc_identity(data, present)
                    row += ('   identity: H_root %+9.3f (asym %+8.1f), H_used %+9.3f (asym %+8.1f); template parts '
                            '%+d, %+d' % (ex_r + tr - tt, as_r + tr - tt, ex_u + tu - tt, as_u + tu - tt,
                                          tr - tt, tu - tt))
                say(row)
    say('identity = prior difference + KT(index of H) - KT(index of H_true) - KT(H_true root context), exact under')
    say('SDPC; asym = its Stirling expansion; the log2 n coefficient is (|F| - |FSYM|)/2 = (|F| - 9)/2.')
    open('c2_mdl.out', 'w').write('\n'.join(lines) + '\n')
