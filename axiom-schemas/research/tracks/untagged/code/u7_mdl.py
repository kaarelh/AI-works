# u7: MDL / size principle on untagged PA data (Q1..Q7 ground + raw induction).  Determinacy gives each datum a
# unique matcher under each template, so a two-part code  L(H) + sum_d [ index(d) + body-code(theta_d) ]  is
# well defined.  Compare H_true = {Q1..Q7, T_ind} with H_root = {Q1..Q7} + {T_ind[P := root-f pattern] : f}.
# Codes for the bodies: NAIVE (uniform per symbol), PC (sequential KT, context = parent symbol and child index,
# per template), DPC (KT, context = depth below the motive root, parent symbol, child index, per template; the
# split templates' bodies start at depth 1).  Index: sequential KT over the templates of H.  Template cost:
# 5 bits per symbol.  Prints L(H_root) - L(H_true) in bits (negative = MDL prefers splitting induction by root).
import sys, random, math
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code')
from dtlib import *
from practice import Q, pa_data, rand_motive, X

FSYM = ['=', 'not', 'and', 'or', 'imp', 'all', 'ex', 'top', 'bot']
TSYM = ['0', 'S', '+', '*', 'h0', 'h1', 'h2', 'v0', 'v1', 'v2', 'v3', 'a1', 'a2', 'a3']
def sym(t):
    h = t[0]
    if h == 'h': return 'h%d' % t[1]
    if h == 'v': return 'v%d' % t[1]
    if h == 'p': return t[1]
    return h

def split_template(f):
    hs = H(0)
    if f == '=': body = eq(M('tL', hs), M('tR', hs))
    elif f == 'not': body = NOT(M('F1', hs))
    elif f in ('and', 'or', 'imp'): body = (f, M('F1', hs), M('F2', hs))
    else: body = (f, M('F1', hs, V(0)))
    return instantiate(T_IND, {'FP': body}) if False else plug_template(body)

def plug_template(body):
    # T_ind with P := lambda x. body, where body may contain metavariable occurrences (DT deg template)
    def inst(T):
        if T[0] == 'M' and T[1] == 'FP':
            return plugM(body, list(T[2:]))
        ks = kids(T)
        return T if not ks else rebuild(T, [inst(k) for k in ks])
    return inst(T_IND)

def plugM(body, args, j=0):
    h = body[0]
    if h == 'h': return shift(args[body[1]], j)
    if h in BINDERS: return (h, plugM(body[1], args, j + 1))
    if h == 'M': return ('M', body[1]) + tuple(plugM(a, args, j) for a in body[2:])
    ks = kids(body)
    return body if not ks else rebuild(body, [plugM(k, args, j) for k in ks])

ROOTS = ['=', 'not', 'and', 'or', 'imp', 'all', 'ex']
SPLIT = {f: split_template(f) for f in ROOTS}

class KT:
    def __init__(self): self.c = {}
    def cost(self, ctx, s, alpha):
        d = self.c.setdefault(ctx, {})
        tot = sum(d.values())
        p = (d.get(s, 0) + 0.5) / (tot + 0.5 * len(alpha))
        d[s] = d.get(s, 0) + 1
        return -math.log2(p)

def body_cost(body, sort, model, mode, tname, depth0):
    """code length of a body (preorder symbols)"""
    total = 0.0
    def walk(t, ctx_parent, idx, depth, srt):
        nonlocal total
        s = sym(t)
        alpha = FSYM if srt == 'F' else TSYM
        if mode == 'NAIVE':
            total += math.log2(len(FSYM) + len(TSYM))
        else:
            ctx = (tname, ctx_parent, idx) if mode == 'PC' else (tname, depth, ctx_parent, idx)
            total += model.cost(ctx, s, alpha)
        cs = child_sorts(t)
        for i, k in enumerate(kids(t)):
            walk(k, s, i, depth + 1, cs[i])
    walk(body, 'ROOT', 0, depth0, sort)
    return total

def codelength(data, Hname, mode):
    tmpl_bits = 0.0
    if Hname == 'true':
        Ts = dict(Q); Ts['Ind'] = T_IND
    else:
        Ts = dict(Q); Ts.update({'Ind_' + f: SPLIT[f] for f in ROOTS})
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
        assert th is not None, (tn, pp(s))
        for nm in sorted(th):
            srt = 'F' if nm[0] == 'F' else 'T'
            depth0 = 0 if Hname == 'true' else 1
            bits += body_cost(th[nm], srt, model, mode, tn + nm if mode != 'NAIVE' else '', depth0)
    tmpl_bits = sum(5 * size(Ts[t]) for t in used)
    return bits + tmpl_bits

# ---- a "well-specified" usage law: every symbol depends only on (depth, parent symbol, child index); no quantifiers,
# so no scope effects.  Under it the DPC code is well specified for H_true.
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

import sys as _s
NS = [int(a) for a in _s.argv[1:]] or [200, 1000, 4000, 16000]
for gen_name, gen in (('G1 natural (rand_motive)', lambda n, r: pa_data(n, r, p_ind=0.5)),
                      ('G2 well-specified for DPC', g2_data)):
    print('usage law:', gen_name)
    for n in NS:
        rng = random.Random(n)
        data = gen(n, rng)
        row = []
        for mode in ('NAIVE', 'PC', 'DPC'):
            Lt = codelength(data, 'true', mode)
            Ls = codelength(data, 'root', mode)
            row.append('%s: %+8.0f (%+.3f/datum)' % (mode, Ls - Lt, (Ls - Lt) / n))
        print('  n=%6d  L(H_root)-L(H_true): ' % n + '   '.join(row), flush=True)
