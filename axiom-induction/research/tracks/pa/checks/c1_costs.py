# c1_costs.py -- code lengths of checked schematic derivations between equivalent axiomatisations, and the
# resulting posterior comparisons (track "pa", notes.md section 1).  Deterministic; output in c1_costs.out.
#
# Code ("proof-text code", the schematic two-part code L1-sch of notes.md section 0):
#   per line: log2(#rules) for the rule, log2(#axioms of the theory) for a citation, log2(line index) per premise
#   reference, LAM bits per written symbol; the metavariable P is written as one symbol plus its arguments.
#   A datum that is an instance of form f at motive phi costs  bits(schematic derivation of f(P)) + L_Q(phi);
#   the term L_Q(phi) is the same under every theory and cancels in every comparison.
# Naive code L1-naive: every written formula is written out at the instance, so each written occurrence of P adds
#   LAM*(|phi|-1) bits: the overhead grows linearly in |phi| with slope LAM*(K - K_cite), K = written occurrences.
import math, itertools
import arith, zf
from nd import Proof, size, show, subst, NOT, ALL, IMP, lt, V, pred, AND, eq, mem

LAM = math.log2(23)
out = []
def say(s=''):
    print(s); out.append(s)

# ------------------------------------------------------------------------------------------ arithmetic
x, y = V('x'), V('y')
Pm = arith.Pm
m = (('x',), Pm)
negm = (('x',), NOT(Pm))
theta = lambda phi: ALL('y', IMP(lt(y, x), subst(phi, 'x', y)))
BASE = ['Q1', 'Q2', 'Q3', 'Q4', 'Q5', 'Q6', 'Q7', 'Dlt']

def ind_cite(phi): return lambda pf: pf.ax('Ind', (('x',), phi))
def cvi_cite(phi): return lambda pf: pf.ax('CVI', (('x',), phi))
def lnp_cite(phi): return lambda pf: pf.ax('LNP', (('x',), phi))
def cvi_via_ind(phi): return lambda pf: arith.d_cvi_from_ind(pf, phi, ind_cite(theta(phi)))
def cvi_via_lnp(phi): return lambda pf: arith.d_cvi_from_lnp_neg(pf, phi, lnp_cite(NOT(phi)))

# how each theory obtains each form f(P): a provider (pf -> closed line)
ARITH = {
    'T_Ind': {'Ind': ind_cite(Pm),
              'CVI': cvi_via_ind(Pm),
              'LNP': lambda pf: arith.d_lnp_from_cvi_neg(pf, Pm, cvi_via_ind(NOT(Pm)))},
    'T_CVI': {'Ind': lambda pf: arith.d_ind_from_cvi(pf, Pm, cvi_cite(Pm)),
              'CVI': cvi_cite(Pm),
              'LNP': lambda pf: arith.d_lnp_from_cvi_neg(pf, Pm, cvi_cite(NOT(Pm)))},
    'T_LNP': {'Ind': lambda pf: arith.d_ind_from_cvi(pf, Pm, cvi_via_lnp(Pm)),
              'CVI': cvi_via_lnp(Pm),
              'LNP': lnp_cite(Pm)},
    'T_all': {'Ind': ind_cite(Pm), 'CVI': cvi_cite(Pm), 'LNP': lnp_cite(Pm)},
}
NSCH = {'T_Ind': 1, 'T_CVI': 1, 'T_LNP': 1, 'T_all': 3}
GOAL = {'Ind': arith.Ind(m), 'CVI': arith.CVI(m), 'LNP': arith.LNP(m)}

def measure(axioms, schemas, provider, goal, n_axioms):
    pf = Proof(axioms, schemas)
    provider(pf)
    pf.check_closed(goal)
    st = pf.stats()
    st['bits'] = pf.bits(LAM, n_axioms)
    st['bits_dec'] = pf.bits_decodable(LAM, n_axioms)
    return st

say('LAM = log2(23) = %.3f bits per written symbol; rules = %d' % (LAM, len(Proof.RULES)))
say()
say('== (a) Q + Dlt + {Ind | CVI | LNP}: cost of obtaining each form f(P) in each theory (all derivations checked)')
say('%-6s %-4s %6s %8s %4s %9s %10s %10s %12s' % ('theory', 'form', 'lines', 'written', 'K', 'bits', 'overhead',
                                                  'bits(dec)', 'overhead(dec)'))
COST = {}
for T, prov in ARITH.items():
    nax = len(BASE) + NSCH[T]
    for f in ('Ind', 'CVI', 'LNP'):
        st = measure(arith.AX, arith.SCH, prov[f], GOAL[f], nax)
        COST[T, f] = st
for T in ARITH:
    for f in ('Ind', 'CVI', 'LNP'):
        st = COST[T, f]
        cite_bits = COST['T_all', f]['bits'] - math.log2(len(BASE) + 3) + math.log2(len(BASE) + NSCH[T])
        cite_dec = COST['T_all', f]['bits_dec'] - math.log2(len(BASE) + 3) + math.log2(len(BASE) + NSCH[T])
        st['overhead'] = st['bits'] - cite_bits
        st['overhead_dec'] = st['bits_dec'] - cite_dec
        say('%-6s %-4s %6d %8d %4d %9.1f %10.1f %10.1f %12.1f' % (T, f, st['lines'], st['written'], st['meta_occ'],
                                                                st['bits'], st['overhead'], st['bits_dec'],
                                                                st['overhead_dec']))
say('overhead = bits minus the bits of a one-line citation of f(P) in a theory with the same number of axioms.')
say('K = written occurrences of P; under the naive code the overhead grows by LAM*(K-1) = %.2f*(K-1) bits per'
    % LAM)
say('    extra symbol of the motive (a citation writes the motive once, K = 1).')
say('bits(dec) = the decodable variant (nd.Proof.bits_decodable: + number of lines, number of tc premises, the')
say('    variable of each subst and exI line); increase over bits: %.1f%% to %.1f%% on the non-citation rows.'
    % (min(100 * (COST[k]['bits_dec'] / COST[k]['bits'] - 1) for k in COST if COST[k]['lines'] > 1),
       max(100 * (COST[k]['bits_dec'] / COST[k]['bits'] - 1) for k in COST if COST[k]['lines'] > 1)))
say()

# template sizes (prior):  |f(P)| symbols, LAM bits each
TSZ = {f: size(GOAL[f]) for f in GOAL}
say('template sizes |f(P)| (symbols): ' + ', '.join('%s %d' % kv for kv in TSZ.items()) +
    '  -> prior cost LAM*|f| = ' + ', '.join('%s %.0f' % (f, LAM * s) for f, s in TSZ.items()) + ' bits')
say()

# break-even usage ratios between pairs of minimal theories
say('pairwise break-even: per use of a form, the extra bits it costs in each theory')
def per_use(T, p):
    return sum(p[f] * COST[T, f]['bits'] for f in p)
say('  T_Ind vs T_CVI on Ind/CVI data:  T_Ind wins iff p_CVI/p_Ind < %.3f'
    % ((COST['T_CVI', 'Ind']['bits'] - COST['T_Ind', 'Ind']['bits']) /
       (COST['T_Ind', 'CVI']['bits'] - COST['T_CVI', 'CVI']['bits'])))
say('  T_Ind vs T_LNP on Ind/LNP data:  T_Ind wins iff p_LNP/p_Ind < %.3f'
    % ((COST['T_LNP', 'Ind']['bits'] - COST['T_Ind', 'Ind']['bits']) /
       (COST['T_Ind', 'LNP']['bits'] - COST['T_LNP', 'LNP']['bits'])))
say('  T_CVI vs T_LNP on CVI/LNP data:  T_CVI wins iff p_LNP/p_CVI < %.3f'
    % ((COST['T_LNP', 'CVI']['bits'] - COST['T_CVI', 'CVI']['bits']) /
       (COST['T_CVI', 'LNP']['bits'] - COST['T_LNP', 'LNP']['bits'])))
def ratio(a, b, key):
    (Ta, fa), (Tb, fb) = a, b
    return ((COST[Ta, fa][key] - COST[Tb, fa][key]) / (COST[Tb, fb][key] - COST[Ta, fb][key]))
say('  same three ratios under the decodable code: %.3f, %.3f, %.3f'
    % (ratio(('T_CVI', 'Ind'), ('T_Ind', 'CVI'), 'bits_dec'), ratio(('T_LNP', 'Ind'), ('T_Ind', 'LNP'), 'bits_dec'),
       ratio(('T_LNP', 'CVI'), ('T_CVI', 'LNP'), 'bits_dec')))
say('  (each ratio is for L1-sch with THIS derivation library: the costs are upper bounds, so the ratios are not')
say('  the ratios of shortest derivations; see the naive-code ratios at the end of this file for code dependence)')
say()
# sizes used in the lower-bound argument of notes-final section 1.2 (referee m5)
from nd import size as _sz
_cvi, _ind = GOAL['CVI'], GOAL['Ind']
say('lower-bound sizes: |CVI(P)| = %d, its antecedent %d symbols; |Ind(P)| = %d, its antecedent %d symbols;'
    % (_sz(_cvi), _sz(_cvi[1]), _sz(_ind), _sz(_ind[1])))
say('  |LNP(P)| = %d, its antecedent %d symbols' % (_sz(GOAL['LNP']), _sz(GOAL['LNP'][1])))
say()

# phase diagram over usage frequencies (p_Ind, p_CVI, p_LNP), asymptotic winner (prior negligible)
say('asymptotic winner (least expected bits per schema use; prior terms are O(1) and ignored), grid step 0.1')
say('rows p_Ind, columns p_CVI (p_LNP = 1 - p_Ind - p_CVI).  I=T_Ind C=T_CVI L=T_LNP; second letter: winner when')
say('the redundant union T_all is also allowed (A = T_all)')
hdr = '        ' + ' '.join('%5.1f' % (c / 10) for c in range(11))
say(hdr)
for i in range(10, -1, -1):
    row = []
    for c in range(11):
        if i + c > 10: row.append('     '); continue
        p = {'Ind': i / 10, 'CVI': c / 10, 'LNP': (10 - i - c) / 10}
        best = min(('T_Ind', 'T_CVI', 'T_LNP'), key=lambda T: per_use(T, p))
        best2 = min(ARITH, key=lambda T: per_use(T, p))
        row.append('   %s%s' % (best[2], 'A' if best2 == 'T_all' else best2[2]))
    say('p_I=%.1f ' % (i / 10) + ' '.join(row))
say()

# crossover sample size for keeping a redundant form, e.g. T_all vs T_Ind when CVI is used at rate p
say('redundant union versus a minimal theory: T_all - T_Ind (prior: + LAM*(|CVI|+|LNP|) bits; per use: index')
say('cost log2(11/9) more for every citation, minus the derivation overhead saved on CVI and LNP uses)')
for pC, pL in ((0.01, 0.0), (0.05, 0.0), (0.1, 0.05), (0.0, 0.01)):
    pI = 1 - pC - pL
    p = {'Ind': pI, 'CVI': pC, 'LNP': pL}
    d = per_use('T_Ind', p) - per_use('T_all', p)
    prior = LAM * (TSZ['CVI'] + TSZ['LNP'])
    say('  p_CVI=%.2f p_LNP=%.2f: per-use saving %.2f bits; T_all ahead after n > %s schema uses'
        % (pC, pL, d, ('%.0f' % (prior / d)) if d > 0 else 'never'))
say()

# ------------------------------------------------------------------------------------------ recursion conventions
say('== (c) recursion convention for +: textbook Q4,Q5 (right) versus Q4L,Q5L (left), both with Ind')
AXR = dict(arith.AX)
gi = lambda pf, mm: pf.ax('Ind', mm)
conv = {}
for nm, d, goal in (('Q4 in T_left', arith.d_q4_from_left, arith.AX['Q4']),
                    ('Q5 in T_left', arith.d_q5_from_left, arith.AX['Q5']),
                    ('Q4L in T_right', arith.d_q4l_from_right, arith.AX['Q4L']),
                    ('Q5L in T_right', arith.d_q5l_from_right, arith.AX['Q5L'])):
    pf = Proof(AXR, arith.SCH)
    d(pf, gi)
    pf.check_closed(goal)
    st = pf.stats()
    cite_bits = math.log2(len(Proof.RULES)) + math.log2(8)
    conv[nm] = pf.bits(LAM, 8) - cite_bits
    say('  %-15s lines %3d  written %3d  overhead %.1f bits per use' % (nm, st['lines'], st['written'], conv[nm]))
say('  (Q + Ind has 8 axioms; a citation costs log2(%d)+log2(8) bits.)' % len(Proof.RULES))
say('  T_right beats T_left iff  r4*%.1f + r5*%.1f > l4*%.1f + l5*%.1f, with r_i, l_i the usage rates of'
    % (conv['Q4 in T_left'], conv['Q5 in T_left'], conv['Q4L in T_right'], conv['Q5L in T_right']))
say('  Q_i and of the left variants: the posterior adopts the convention the data use.')
say()

# ------------------------------------------------------------------------------------------ ZF
say('== (b) ZF: checked derivations between schema forms (schematic in P(u) / R(x,y))')
x_, y_, u_ = V('x'), V('y'), V('u')
Pu, Rxy, Sv = zf.Pu, zf.Rxy, zf.Sv
psi_sep = AND(subst(Pu, 'u', x_), eq(y_, x_))
ZROWS = [
    ('SepJ from ReplJ', lambda pf: zf.d_sep_from_replj(pf, Pu, zf.cite('ReplJ', (('x', 'y'), psi_sep))),
     zf.SepJ((('u',), Pu)), 'SepJ'),
    ('Found from EInd', lambda pf: zf.d_found_from_eind(pf, zf.cite('EInd', (('x',), NOT(mem(x_, Sv))))),
     zf.FOUND, 'Found'),
    ('ReplK from Coll', lambda pf: zf.d_replk_from_coll(pf, Rxy, zf.cite('Coll', (('x', 'y'), Rxy))),
     zf.ReplK((('x', 'y'), Rxy)), 'ReplK'),
    ('ReplJ from Coll+SepJ', lambda pf: zf.d_replj_from_coll_sep(pf, Rxy, zf.cite('Coll', (('x', 'y'), Rxy)),
                                                                 lambda pf, mm: pf.ax('SepJ', mm)),
     zf.ReplJ((('x', 'y'), Rxy)), 'ReplJ'),
]
NZ = 9   # Ext, Pair, Union, Power, Inf, Found/EInd, Sep, Repl/Coll, (one more slot): a ZF-sized axiom list
for nm, prov, goal, form in ZROWS:
    pf = Proof(zf.ZAX, zf.ZSCH)
    prov(pf)
    pf.check_closed(goal)
    st = pf.stats()
    ov = pf.bits(LAM, NZ) - (math.log2(len(Proof.RULES)) + math.log2(NZ))
    say('  %-22s lines %3d  written %3d  K %2d  overhead %6.1f bits;  template |%s| = %d symbols (%.0f bits)'
        % (nm, st['lines'], st['written'], st['meta_occ'], ov, form, size(goal), LAM * size(goal)))
say('  not computed (long; see notes): Coll from Repl (needs ranks and Power Set), EInd from Found (needs')
say('  transitive closures, hence Infinity and Replacement).')
say('  Overheads are upper bounds on the true minimum (shortest derivations were not searched).')

open('c1_costs.out', 'w').write('\n'.join(out) + '\n')

# ------------------------------------------------------------------------------------------ naive code on concrete motives
say()
say('== naive code (every written formula written out at the instance): overhead on concrete motives')
import random
from test_nd import rform
from nd import fv
rng = random.Random(7)
say('%-22s %s' % ('derivation', '  '.join('|phi|=%-3d' % s for s in (5, 10, 20, 40))))
def concrete_overhead(T, f, phi):
    prov = {('T_Ind', 'CVI'): lambda pf: arith.d_cvi_from_ind(pf, phi, ind_cite(theta(phi))),
            ('T_CVI', 'Ind'): lambda pf: arith.d_ind_from_cvi(pf, phi, cvi_cite(phi)),
            ('T_CVI', 'LNP'): lambda pf: arith.d_lnp_from_cvi_neg(pf, phi, cvi_cite(NOT(phi))),
            ('T_LNP', 'CVI'): lambda pf: arith.d_cvi_from_lnp_neg(pf, phi, lnp_cite(NOT(phi)))}[T, f]
    mm = (('x',), phi)
    goal = {'Ind': arith.Ind, 'CVI': arith.CVI, 'LNP': arith.LNP}[f](mm)
    pf = Proof(arith.AX, arith.SCH); prov(pf); pf.check_closed(goal)
    pc = Proof(arith.AX, arith.SCH); pc.ax(f, mm)
    return pf.bits(LAM, 9) - pc.bits(LAM, 9)
pools = {}
while any(len(pools.get(s, [])) < 5 for s in (5, 10, 20, 40)):
    phi = rform(rng, 5)
    if 'x' not in fv(phi): continue
    s = size(phi)
    for t in (5, 10, 20, 40):
        if abs(s - t) <= max(1, t // 10) and len(pools.setdefault(t, [])) < 5:
            pools[t].append(phi)
for T, f in (('T_Ind', 'CVI'), ('T_CVI', 'Ind'), ('T_CVI', 'LNP'), ('T_LNP', 'CVI')):
    vals = []
    for t in (5, 10, 20, 40):
        vals.append(sum(concrete_overhead(T, f, p) for p in pools[t]) / len(pools[t]))
    say('%-22s %s   (schematic: %.0f; K = %d)' % ('%s from %s' % (f, T), '  '.join('%9.0f' % v for v in vals),
                                                 COST[T, f]['overhead'], COST[T, f]['meta_occ']))
say('mean over 5 random motives per size (seed 7); the growth per motive symbol is about LAM*(K-1).')
NAIVE = {}
for T, f in (('T_Ind', 'CVI'), ('T_CVI', 'Ind')):
    NAIVE[T, f] = [sum(concrete_overhead(T, f, p) for p in pools[t]) / len(pools[t]) for t in (5, 10, 20, 40)]
say('break-even under the naive code (T_Ind beats T_CVI iff p_CVI/p_Ind < overhead(Ind|T_CVI)/overhead(CVI|T_Ind)):')
say('  ' + '  '.join('|phi|=%d: %.3f' % (t, a / b) for t, a, b in zip((5, 10, 20, 40), NAIVE['T_CVI', 'Ind'],
                                                                      NAIVE['T_Ind', 'CVI'])))
open('c1_costs.out', 'w').write('\n'.join(out) + '\n')

# ------------------------------------------------------------------------------------------ base axioms used
say()
say('== base axioms cited by each derivation (the base theory over which the equivalences are proved)')
for nm, build in (('Ind <- CVI (A)', lambda pf: arith.d_ind_from_cvi(pf, Pm, cvi_cite(Pm))),
                  ('CVI <- Ind (B)', lambda pf: arith.d_cvi_from_ind(pf, Pm, ind_cite(theta(Pm)))),
                  ('LNP <- CVI(~) (C1)', lambda pf: arith.d_lnp_from_cvi_neg(pf, Pm, cvi_cite(NOT(Pm)))),
                  ('CVI <- LNP(~) (C2)', lambda pf: arith.d_cvi_from_lnp_neg(pf, Pm, lnp_cite(NOT(Pm)))),
                  ('Q4 <- left+Ind', lambda pf: arith.d_q4_from_left(pf, lambda p, mm: p.ax('Ind', mm))),
                  ('Q5 <- left+Ind', lambda pf: arith.d_q5_from_left(pf, lambda p, mm: p.ax('Ind', mm))),
                  ('Q4L <- right+Ind', lambda pf: arith.d_q4l_from_right(pf, lambda p, mm: p.ax('Ind', mm))),
                  ('Q5L <- right+Ind', lambda pf: arith.d_q5l_from_right(pf, lambda p, mm: p.ax('Ind', mm)))):
    pf = Proof(arith.AX, arith.SCH); build(pf)
    say('  %-20s cites %s' % (nm, sorted(set(pf.cited))))
open('c1_costs.out', 'w').write('\n'.join(out) + '\n')
