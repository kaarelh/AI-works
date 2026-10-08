# r1_recheck.py -- referee for track "pa": an INDEPENDENT line-by-line re-check of every checked derivation of the
# track (Prop. 1.1, 1.4, the ZF derivations, the wrapper derivations of Prop. 2.2, and the composite derivations
# used for the cost table), plus an independent recomputation of their code lengths and a sensitivity analysis of
# the break-even ratios.
#
# What is independent here: the syntax helpers (free variables, capture-checking substitution, alpha-normal form,
# symbol count), the propositional tautology test, the rule semantics, the hypothesis bookkeeping, the axioms and
# the schema statements (Q1-Q7, Dlt, Q4L, Q5L, Ind, CVI, LNP, SepJ, ReplJ, ReplK, Coll, EInd, Found), and the bit
# accounting.  What is reused: the track's derivation *builders* (they produce the proof objects), and the proof
# lines they record (rule name, premise indices, written objects, conclusion).  Every conclusion and every
# hypothesis set is recomputed here and compared; the track's stored hypothesis sets are not trusted.
#
# Deterministic.  Output: r1_recheck.out next to this script.
import sys, os, math, itertools
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
TRACK = os.path.join(HERE, '..', 'checks')
sys.path.insert(0, TRACK)
OUT = []
def say(s=''):
    print(s); OUT.append(s)

# ----------------------------------------------------------------------------------------- independent syntax
CONN = ('not', 'and', 'or', 'imp', 'iff', 'bot')
def V(x): return ('var', x)

def free(e):
    k = e[0]
    if k == 'var': return {e[1]}
    if k in ('0', 'bot'): return set()
    if k in ('all', 'ex'): return free(e[2]) - {e[1]}
    if k == 'pred':
        s = set()
        for a in e[2]: s |= free(a)
        return s
    s = set()
    for c in e[1:]: s |= free(c)
    return s

def allv(e):
    k = e[0]
    if k == 'var': return {e[1]}
    if k in ('0', 'bot'): return set()
    if k in ('all', 'ex'): return allv(e[2]) | {e[1]}
    if k == 'pred':
        s = set()
        for a in e[2]: s |= allv(a)
        return s
    s = set()
    for c in e[1:]: s |= allv(c)
    return s

class Bad(Exception): pass

def sub(e, x, t, bound=frozenset()):
    """e[t/x]; raises Bad if a free variable of t would be captured at a replaced occurrence."""
    k = e[0]
    if k == 'var':
        if e[1] == x:
            if free(t) & bound: raise Bad('capture')
            return t
        return e
    if k in ('0', 'bot'): return e
    if k in ('all', 'ex'):
        if e[1] == x: return e
        return (k, e[1], sub(e[2], x, t, bound | {e[1]}))
    if k == 'pred': return ('pred', e[1], tuple(sub(a, x, t, bound) for a in e[2]))
    return (k,) + tuple(sub(c, x, t, bound) for c in e[1:])

def canon(e, env=None, d=0):
    """alpha-normal form: the bound variable of the binder at nesting depth d is renamed '#d'."""
    env = env or {}
    k = e[0]
    if k == 'var': return ('var', env.get(e[1], e[1]))
    if k in ('0', 'bot'): return e
    if k in ('all', 'ex'):
        nm = '#%d' % d
        e2 = dict(env); e2[e[1]] = nm
        return (k, nm, canon(e[2], e2, d + 1))
    if k == 'pred': return ('pred', e[1], tuple(canon(a, env, d) for a in e[2]))
    return (k,) + tuple(canon(c, env, d) for c in e[1:])

def size(e):
    k = e[0]
    if k in ('var', '0', 'bot'): return 1
    if k in ('all', 'ex'): return 2 + size(e[2])
    if k == 'pred': return 1 + sum(size(a) for a in e[2])
    return 1 + sum(size(c) for c in e[1:])

def taut(prems, concl):
    atoms = []
    def coll(e):
        if e[0] == 'bot': return
        if e[0] in CONN:
            for c in e[1:]: coll(c)
            return
        c = canon(e)
        if c not in atoms: atoms.append(c)
    for p in prems: coll(p)
    coll(concl)
    def ev(e, val):
        k = e[0]
        if k == 'bot': return False
        if k == 'not': return not ev(e[1], val)
        if k == 'and': return ev(e[1], val) and ev(e[2], val)
        if k == 'or': return ev(e[1], val) or ev(e[2], val)
        if k == 'imp': return (not ev(e[1], val)) or ev(e[2], val)
        if k == 'iff': return ev(e[1], val) == ev(e[2], val)
        return val[canon(e)]
    for bits in itertools.product((False, True), repeat=len(atoms)):
        val = dict(zip(atoms, bits))
        if all(ev(p, val) for p in prems) and not ev(concl, val):
            return False
    return True

def fresh(avoid, base):
    for c in [base] + [base + str(i) for i in range(1, 200)]:
        if c not in avoid: return c

# ----------------------------------------------------------------------------------------- independent statements
Z0 = ('0',)
def S(t): return ('S', t)
def EQ(a, b): return ('=', a, b)
def LT(a, b): return ('<', a, b)
def IN(a, b): return ('in', a, b)
def ADD(a, b): return ('+', a, b)
def MUL(a, b): return ('*', a, b)
def ALL(x, a): return ('all', x, a)
def EX(x, a): return ('ex', x, a)
def IMP(a, b): return ('imp', a, b)
def AND(a, b): return ('and', a, b)
def OR(a, b): return ('or', a, b)
def IFF(a, b): return ('iff', a, b)
def NOT(a): return ('not', a)
a_, b_ = V('a'), V('b')
MYAX = {   # Robinson's Q (Q3 in the form x=0 v Ey x=Sy), the definition of <, left-recursive variants, Foundation
    'Q1': ALL('a', NOT(EQ(S(a_), Z0))),
    'Q2': ALL('a', ALL('b', IMP(EQ(S(a_), S(b_)), EQ(a_, b_)))),
    'Q3': ALL('a', OR(EQ(a_, Z0), EX('b', EQ(a_, S(b_))))),
    'Q4': ALL('a', EQ(ADD(a_, Z0), a_)),
    'Q5': ALL('a', ALL('b', EQ(ADD(a_, S(b_)), S(ADD(a_, b_))))),
    'Q6': ALL('a', EQ(MUL(a_, Z0), Z0)),
    'Q7': ALL('a', ALL('b', EQ(MUL(a_, S(b_)), ADD(MUL(a_, b_), a_)))),
    'Dlt': ALL('a', ALL('b', IFF(LT(a_, b_), EX('c', EQ(ADD(a_, S(V('c'))), b_))))),
    'Q4L': ALL('a', EQ(ADD(Z0, a_), a_)),
    'Q5L': ALL('a', ALL('b', EQ(ADD(S(a_), b_), S(ADD(a_, b_))))),
    'Found': ALL('s', IMP(EX('a', IN(a_, V('s'))),
                          EX('a', AND(IN(a_, V('s')), ALL('b', IMP(IN(b_, a_), NOT(IN(b_, V('s'))))))))),
}
def my_Ind(xs, phi):
    (x,) = xs
    return IMP(AND(sub(phi, x, Z0), ALL(x, IMP(phi, sub(phi, x, S(V(x)))))), ALL(x, phi))
def my_CVI(xs, phi):
    (x,) = xs; y = fresh(allv(phi) | {x}, 'q')
    return IMP(ALL(x, IMP(ALL(y, IMP(LT(V(y), V(x)), sub(phi, x, V(y)))), phi)), ALL(x, phi))
def my_LNP(xs, phi):
    (x,) = xs; y = fresh(allv(phi) | {x}, 'q')
    return IMP(EX(x, phi), EX(x, AND(phi, ALL(y, IMP(LT(V(y), V(x)), NOT(sub(phi, x, V(y))))))))
def my_SepJ(xs, phi):           # AX EY Au (u in Y <-> u in X & phi)
    (u,) = xs; av = free(phi) | {u}
    X, Y = fresh(av, 'XX'), fresh(av, 'YY')
    return ALL(X, EX(Y, ALL(u, IFF(IN(V(u), V(Y)), AND(IN(V(u), V(X)), phi)))))
def my_ReplJ(xs, psi):          # functional psi -> the image of every set is a set
    x, y = xs; av = allv(psi) | {x, y}
    z, X, Y = fresh(av, 'zz'), fresh(av, 'XX'), fresh(av, 'YY')
    return IMP(ALL(x, ALL(y, ALL(z, IMP(AND(psi, sub(psi, y, V(z))), EQ(V(y), V(z)))))),
               ALL(X, EX(Y, ALL(y, IFF(IN(V(y), V(Y)), EX(x, AND(IN(V(x), V(X)), psi)))))))
def my_ReplK(xs, psi):          # bounding form with E!y spelled out
    x, y = xs; av = allv(psi) | {x, y}
    A, B, u = fresh(av, 'AA'), fresh(av, 'BB'), fresh(av, 'uu')
    return ALL(A, IMP(ALL(x, IMP(IN(V(x), V(A)), EX(y, AND(psi, ALL(u, IMP(sub(psi, y, V(u)), EQ(V(u), V(y)))))))),
                      EX(B, ALL(x, IMP(IN(V(x), V(A)), EX(y, AND(IN(V(y), V(B)), psi)))))))
def my_Coll(xs, psi):
    x, y = xs; av = allv(psi) | {x, y}
    A, B = fresh(av, 'AA'), fresh(av, 'BB')
    return ALL(A, IMP(ALL(x, IMP(IN(V(x), V(A)), EX(y, psi))),
                      EX(B, ALL(x, IMP(IN(V(x), V(A)), EX(y, AND(IN(V(y), V(B)), psi)))))))
def my_EInd(xs, chi):
    (x,) = xs; y = fresh(allv(chi) | {x}, 'q')
    return IMP(ALL(x, IMP(ALL(y, IMP(IN(V(y), V(x)), sub(chi, x, V(y)))), chi)), ALL(x, chi))
MYSCH = {'Ind': (my_Ind, [('x',)]), 'CVI': (my_CVI, [('x',)]), 'LNP': (my_LNP, [('x',)]),
         'SepJ': (my_SepJ, [('u',)]), 'ReplJ': (my_ReplJ, [('x', 'y')]), 'ReplK': (my_ReplK, [('x', 'y')]),
         'Coll': (my_Coll, [('x', 'y')]), 'EInd': (my_EInd, [('x',)])}

# ----------------------------------------------------------------------------------------- the re-checker
def recheck(pf, goal):
    """re-verify every line of a track Proof object; return (ok, message)."""
    H, C = [], []
    cited = list(pf.cited)
    for i, ln in enumerate(pf.lines):
        r, refs, W, c = ln.rule, ln.refs, ln.written, ln.concl
        try:
            if r == 'hyp':
                (A,) = W
                if canon(A) != canon(c): raise Bad('hyp')
                h = {canon(A)}
            elif r == 'ax':
                name = cited.pop(0)
                if name in MYAX:
                    if W or canon(c) != canon(MYAX[name]): raise Bad('axiom %s misstated' % name)
                elif name in MYSCH:
                    fn, choices = MYSCH[name]
                    (phi,) = W
                    if not any(canon(fn(xs, phi)) == canon(c) for xs in choices):
                        raise Bad('schema %s: line is not an instance at the written motive' % name)
                else:
                    raise Bad('unknown axiom %s' % name)
                h = set()
            elif r == 'tc':
                (B,) = W
                if canon(B) != canon(c) or not taut([C[j] for j in refs], c): raise Bad('tc')
                h = set().union(*[H[j] for j in refs])
            elif r == 'impI':
                (A,) = W; (j,) = refs
                if canon(c) != canon(IMP(A, C[j])): raise Bad('impI')
                h = H[j] - {canon(A)}
            elif r == 'allE':
                (t,) = W; (j,) = refs
                if C[j][0] != 'all': raise Bad('allE premise')
                if canon(c) != canon(sub(C[j][2], C[j][1], t)): raise Bad('allE')
                h = set(H[j])
            elif r == 'allI':
                (xv,) = W; (j,) = refs; x = xv[1]
                if any(x in free(q) for q in H[j]): raise Bad('allI eigenvariable')
                if canon(c) != canon(ALL(x, C[j])): raise Bad('allI')
                h = set(H[j])
            elif r == 'exI':
                A, t = W; (j,) = refs
                if c[0] != 'ex' or canon(c[2]) != canon(A): raise Bad('exI form')
                if canon(sub(A, c[1], t)) != canon(C[j]): raise Bad('exI witness')
                h = set(H[j])
            elif r == 'exE':
                (wv,) = W; i1, j = refs; w = wv[1]
                if C[i1][0] != 'ex': raise Bad('exE premise')
                Aw = canon(sub(C[i1][2], C[i1][1], V(w)))
                if Aw not in H[j]: raise Bad('exE: instance not a hypothesis')
                rest = H[j] - {Aw}
                if w in free(C[i1]) or w in free(C[j]) or any(w in free(q) for q in rest):
                    raise Bad('exE eigenvariable')
                if canon(c) != canon(C[j]): raise Bad('exE concl')
                h = H[i1] | rest
            elif r == 'refl':
                (t,) = W
                if canon(c) != canon(EQ(t, t)): raise Bad('refl')
                h = set()
            elif r == 'subst':
                (A,) = W; i1, j = refs
                if C[i1][0] != '=': raise Bad('subst premise')
                s, t = C[i1][1], C[i1][2]
                ok = False
                for z in sorted(allv(A)):
                    try:
                        if canon(sub(A, z, s)) == canon(C[j]) and canon(sub(A, z, t)) == canon(c):
                            ok = True; break
                    except Bad:
                        pass
                if not ok: raise Bad('subst')
                h = H[i1] | H[j]
            else:
                raise Bad('unknown rule ' + r)
        except Bad as e:
            return False, 'line %d (%s): %s' % (i, r, e)
        if h != {canon(q) for q in ln.hyps.values()}:
            return False, 'line %d: hypothesis set differs from the track record' % i
        H.append(h); C.append(c)
    if H[-1]: return False, 'open hypotheses at the end'
    if canon(C[-1]) != canon(goal): return False, 'final conclusion is not the stated goal'
    return True, 'ok'

LAM = math.log2(23)
def bits(pf, n_ax, lam=LAM, extra=False):
    """the track's proof-text code, re-implemented; extra=True adds what a decodable code also needs: the variable z
    of each subst line and the bound variable x of each exI line (one symbol each), the number of premises of
    each tc line (Elias gamma), and the number of lines (Elias gamma)."""
    eg = lambda k: 2 * math.floor(math.log2(k)) + 1
    b = 0.0
    for i, ln in enumerate(pf.lines):
        b += math.log2(10)
        if ln.rule == 'ax': b += math.log2(n_ax)
        for j in ln.refs: b += math.log2(max(i, 1))
        b += lam * sum(size(w) for w in ln.written)
        if extra:
            if ln.rule in ('subst', 'exI'): b += lam
            if ln.rule == 'tc': b += eg(len(ln.refs))
    if extra: b += eg(len(pf.lines))
    return b

# ----------------------------------------------------------------------------------------- the derivations
import nd, arith, zf
import c2_detour
P = ('pred', 'P', (V('x'),))
NP = NOT(P)
theta = lambda phi: ALL('y', IMP(LT(V('y'), V('x')), sub(phi, 'x', V('y'))))
def cite(name, phi): return lambda pf: pf.ax(name, (('x',), phi))
cvi_via_ind = lambda phi: (lambda pf: arith.d_cvi_from_ind(pf, phi, cite('Ind', theta(phi))))
cvi_via_lnp = lambda phi: (lambda pf: arith.d_cvi_from_lnp_neg(pf, phi, cite('LNP', NOT(phi))))
BASE = 8
JOBS = [  # name, builder, my goal, number of axioms of the theory (for the code)
    ('(A)  Ind <- CVI', lambda pf: arith.d_ind_from_cvi(pf, P, cite('CVI', P)), my_Ind(('x',), P), 9),
    ('(B)  CVI <- Ind(theta)', lambda pf: arith.d_cvi_from_ind(pf, P, cite('Ind', theta(P))), my_CVI(('x',), P), 9),
    ('(C1) LNP <- CVI(~P)', lambda pf: arith.d_lnp_from_cvi_neg(pf, P, cite('CVI', NP)), my_LNP(('x',), P), 9),
    ('(C2) CVI <- LNP(~P)', lambda pf: arith.d_cvi_from_lnp_neg(pf, P, cite('LNP', NP)), my_CVI(('x',), P), 9),
    ('T_Ind: LNP', lambda pf: arith.d_lnp_from_cvi_neg(pf, P, cvi_via_ind(NP)), my_LNP(('x',), P), 9),
    ('T_LNP: Ind', lambda pf: arith.d_ind_from_cvi(pf, P, cvi_via_lnp(P)), my_Ind(('x',), P), 9),
    ('Q4 <- Q4L,Q5L,Ind', lambda pf: arith.d_q4_from_left(pf, lambda p, m: p.ax('Ind', m)), MYAX['Q4'], 8),
    ('Q5 <- Q4L,Q5L,Ind', lambda pf: arith.d_q5_from_left(pf, lambda p, m: p.ax('Ind', m)), MYAX['Q5'], 8),
    ('Q4L <- Q4,Q5,Ind', lambda pf: arith.d_q4l_from_right(pf, lambda p, m: p.ax('Ind', m)), MYAX['Q4L'], 8),
    ('Q5L <- Q4,Q5,Ind', lambda pf: arith.d_q5l_from_right(pf, lambda p, m: p.ax('Ind', m)), MYAX['Q5L'], 8),
]
Pu, Rxy = ('pred', 'P', (V('u'),)), ('pred', 'R', (V('x'), V('y')))
psi_sep = AND(sub(Pu, 'u', V('x')), EQ(V('y'), V('x')))
JOBS += [
    ('ZF SepJ <- ReplJ', lambda pf: zf.d_sep_from_replj(pf, Pu, lambda p: p.ax('ReplJ', (('x', 'y'), psi_sep))),
     my_SepJ(('u',), Pu), 9),
    ('ZF Found <- EInd', lambda pf: zf.d_found_from_eind(pf, lambda p: p.ax('EInd', (('x',), NOT(IN(V('x'), V('S')))))),
     MYAX['Found'], 9),
    ('ZF ReplK <- Coll', lambda pf: zf.d_replk_from_coll(pf, Rxy, lambda p: p.ax('Coll', (('x', 'y'), Rxy))),
     my_ReplK(('x', 'y'), Rxy), 9),
    ('ZF ReplJ <- Coll+SepJ', lambda pf: zf.d_replj_from_coll_sep(pf, Rxy, lambda p: p.ax('Coll', (('x', 'y'), Rxy)),
                                                                 lambda p, m: p.ax('SepJ', m)),
     my_ReplJ(('x', 'y'), Rxy), 9),
]
for f in c2_detour.WRAP:
    JOBS.append(('wrapper %s: Ind(P) <- Ind(w(P))' % f, (lambda ff: lambda pf: c2_detour.d_ind_from_wrapped(pf, ff))(f),
                 my_Ind(('x',), P), 14))

say('r1: independent re-check of the track\'s checked derivations (rules, hypotheses, axioms, schema statements)')
say('%-34s %6s %8s %10s %10s  %s' % ('derivation', 'lines', 'written', 'bits', 'bits+dec', 'independent check'))
RES = {}
allok = True
for name, build, goal, nax in JOBS:
    pf = nd.Proof(arith.AX if not name.startswith('ZF') else zf.ZAX,
                  dict(arith.SCH) if not name.startswith('ZF') else zf.ZSCH)
    build(pf)
    ok, msg = recheck(pf, goal)
    allok &= ok
    b0, b1 = bits(pf, nax), bits(pf, nax, extra=True)
    RES[name] = (b0, b1, len(pf.lines))
    say('%-34s %6d %8d %10.1f %10.1f  %s' % (name, len(pf.lines), sum(size(w) for l in pf.lines for w in l.written),
                                             b0, b1, msg))
say('ALL DERIVATIONS RE-CHECKED' if allok else 'SOME DERIVATION FAILED THE INDEPENDENT CHECK')

# --------------------------------------------------------------------------- the track's overhead table, recomputed
say()
say('overheads (bits minus a one-line citation in a theory with the same number of axioms), two codes:')
say('  "track" = the track\'s proof-text code; "decodable" = plus the omitted symbols and length fields')
def cite_bits(nax, extra):
    pf = nd.Proof(arith.AX, dict(arith.SCH)); pf.ax('Ind', (('x',), P))
    return bits(pf, nax, extra=extra)
ov = {}
for key, nm in (('CVI|T_Ind', '(B)  CVI <- Ind(theta)'), ('Ind|T_CVI', '(A)  Ind <- CVI'),
                ('LNP|T_CVI', '(C1) LNP <- CVI(~P)'), ('CVI|T_LNP', '(C2) CVI <- LNP(~P)'),
                ('LNP|T_Ind', 'T_Ind: LNP'), ('Ind|T_LNP', 'T_LNP: Ind')):
    b0, b1, _ = RES[nm]
    ov[key] = (b0 - cite_bits(9, False), b1 - cite_bits(9, True))
    say('  %-10s track %7.1f   decodable %7.1f' % (key, ov[key][0], ov[key][1]))
say()
say('break-even usage ratios (asymptotic, L1-sch):')
for lab, num, den in (('T_Ind beats T_CVI iff p_CVI/p_Ind <', 'Ind|T_CVI', 'CVI|T_Ind'),
                      ('T_Ind beats T_LNP iff p_LNP/p_Ind <', 'Ind|T_LNP', 'LNP|T_Ind'),
                      ('T_CVI beats T_LNP iff p_LNP/p_CVI <', 'CVI|T_LNP', 'LNP|T_CVI')):
    say('  %-38s track %.3f   decodable %.3f' % (lab, ov[num][0] / ov[den][0], ov[num][1] / ov[den][1]))
say('  same ratio from the track\'s own L1-naive numbers (c1_costs.out, mean of 5 motives):')
NAIVE = {5: (1088, 1621), 10: (1487, 1915), 20: (2264, 2515), 40: (4030, 3832)}
for s, (ind_cvi, cvi_ind) in NAIVE.items():
    say('    |phi|=%-3d  T_Ind beats T_CVI iff p_CVI/p_Ind < %.3f' % (s, ind_cvi / cvi_ind))

# --------------------------------------------------------------------------- mutation test of the re-checker itself
say()
say('mutation test (the re-checker must reject corrupted proofs): for every line of (A), (B), (C2) and the ZF')
say('derivation SepJ <- ReplJ, replace that line\'s conclusion by its negation, or (for allI/exE lines) its')
say('eigenvariable by a variable free in a hypothesis, and re-check')
import copy
def mutants(pf):
    for i, ln in enumerate(pf.lines):
        q = copy.copy(pf); q.lines = list(pf.lines); q.cited = list(pf.cited)
        l2 = copy.copy(ln); l2.concl = NOT(ln.concl); q.lines[i] = l2
        yield 'neg concl line %d' % i, q
        if ln.rule in ('allI', 'exE'):
            hv = set().union(*[free(h) for h in ln.hyps.values()]) if ln.hyps else set()
            for var in sorted(hv):
                q = copy.copy(pf); q.lines = list(pf.lines); q.cited = list(pf.cited)
                l3 = copy.copy(ln); l3.written = [V(var)]
                if ln.rule == 'allI': l3.concl = ALL(var, pf.lines[ln.refs[0]].concl)
                q.lines[i] = l3
                yield 'eigenvariable %s line %d' % (var, i), q
                break
tot = rej = 0
for name, build, goal, nax in JOBS:
    if not (name.startswith('(A)') or name.startswith('(B)') or name.startswith('(C2)') or name.startswith('ZF SepJ')):
        continue
    pf = nd.Proof(arith.AX if not name.startswith('ZF') else zf.ZAX,
                  dict(arith.SCH) if not name.startswith('ZF') else zf.ZSCH)
    build(pf)
    for lab, q in mutants(pf):
        tot += 1
        ok, msg = recheck(q, goal)
        rej += (not ok)
        if ok: say('  NOT REJECTED: %s %s' % (name, lab))
say('  %d of %d mutants rejected' % (rej, tot))
open(os.path.join(HERE, 'r1_recheck.out'), 'w').write('\n'.join(OUT) + '\n')
