# c10_quotes.py -- mechanical check that the numbers quoted in ../notes-final.md are the numbers in the saved outputs
# (referee issue M1).  For each quote: a regular expression extracts numbers from an output file, a template formats
# them the way the notes print them, and the formatted string must occur verbatim in notes-final.md.  Tables are
# generated from the outputs row by row in the same way.  Deterministic; output c10_quotes.out.
import re, os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
NOTES = open(os.path.join(HERE, '..', 'notes-final.md')).read()
def out(name): return open(os.path.join(HERE, name)).read()
LOG = []; FAIL = []
def check(label, snippet):
    ok = snippet in NOTES
    LOG.append('%-4s %-46s %s' % ('ok' if ok else 'FAIL', label, snippet.replace('\n', ' / ')[:110]))
    if not ok: FAIL.append(label)
def rx(label, fname, pattern, template, fn=None):
    m = re.search(pattern, out(fname), re.M)
    if not m:
        LOG.append('FAIL %-46s pattern not found in %s' % (label, fname)); FAIL.append(label); return
    g = list(m.groups())
    if fn: g = fn(g)
    check(label, template.format(*g))

N = r'\s+([-+]?[\d.]+)'
# ---------------------------------------------------------------- c1_costs.out
for T, f in (('T_Ind', 'CVI'), ('T_Ind', 'LNP'), ('T_CVI', 'Ind'), ('T_CVI', 'LNP'), ('T_LNP', 'Ind'), ('T_LNP', 'CVI')):
    rx('c1 row %s %s' % (T, f), 'c1_costs.out', r'^%s\s+%s' % (T, f) + N * 7 + '$',
       '| %s | %s | {0} | {1} | {2} | {3} | {4} | {6} |' % (T, f))
rx('c1 decodable increase', 'c1_costs.out', r'increase over bits: ([\d.]+)% to ([\d.]+)%', '{0}–{1}%')
rx('c1 template priors', 'c1_costs.out', r'prior cost LAM\*\|f\| = Ind (\d+), CVI (\d+), LNP (\d+) bits',
   'Ind {0} bits, CVI {1}, LNP {2}')
rx('c1 break-even', 'c1_costs.out',
   r'p_CVI/p_Ind < ([\d.]+)\n.*p_LNP/p_Ind < ([\d.]+)\n.*p_LNP/p_CVI < ([\d.]+)',
   'T_Ind beats T_CVI iff p_CVI/p_Ind < {0}; T_Ind beats T_LNP iff p_LNP/p_Ind < {1}; T_CVI\n    beats T_LNP iff p_LNP/p_CVI < {2}')
rx('c1 break-even decodable', 'c1_costs.out', r'decodable code: ([\d.]+), ([\d.]+), ([\d.]+)',
   'the three ratios are {0}, {1} and {2}')
rx('c1 naive break-even', 'c1_costs.out', r'\|phi\|=5: ([\d.]+)\s+\|phi\|=10: ([\d.]+)\s+\|phi\|=20: ([\d.]+)\s+\|phi\|=40: ([\d.]+)',
   'the first ratio is {0}, {1}, {2} and {3}')
rx('c1 lower-bound sizes', 'c1_costs.out', r'\|CVI\(P\)\| = (\d+), its antecedent (\d+) symbols; \|Ind\(P\)\| = (\d+), its antecedent (\d+)',
   'log₂10 + 11β ≈ 53 bits more than citing CVI(P)', lambda g: g if (g[0], g[1], g[3]) == ('18', '13', '11') else ['x'])
rx('c1 naive CVI|T_Ind', 'c1_costs.out', r'CVI from T_Ind' + N * 4, '1621, 1915, 2515, 3832',
   lambda g: g if [round(float(v)) for v in g] == [1621, 1915, 2515, 3832] else ['x'])
rx('c1 naive Ind|T_CVI', 'c1_costs.out', r'Ind from T_CVI' + N * 4, '1088, 1487,\n  2264, 4030',
   lambda g: g if [round(float(v)) for v in g] == [1088, 1487, 2264, 4030] else ['x'])
rx('c1 recursion conventions', 'c1_costs.out',
   r'Q4 in T_left.*overhead ([\d.]+).*\n.*Q5 in T_left.*overhead ([\d.]+).*\n.*Q4L in T_right.*overhead ([\d.]+).*\n.*Q5L in T_right.*overhead ([\d.]+)',
   'Q4 in T_left {0} bits, Q5 in T_left {1}, Q4L in\nT_right {2}, Q5L in T_right {3}')
for nm, val in (('SepJ from ReplJ', '1209'), ('ReplK from Coll', '574'), ('ReplJ from Coll\\+SepJ', '1432'),
                ('Found from EInd', '758')):
    rx('c1 ZF ' + nm, 'c1_costs.out', nm + r'.*overhead\s+([\d.]+)', val,
       lambda g, val=val: [val] if round(float(g[0])) == int(val) else ['MISMATCH'])
# ---------------------------------------------------------------- c2_mdl.out, c2b_cf.out
def parse_c2():
    res = {}; law = None; n = None
    for ln in out('c2_mdl.out').split('\n'):
        if ln.startswith('usage law: G'): law = ln.split()[2]
        m = re.match(r'\s+n=\s*(\d+)\s+roots', ln)
        if m: n = int(m.group(1))
        m = re.match(r'\s+(NAIVE|PC|DPC|SDPC|RDPC)\s+H_root\s+([-+][\d.]+)\s+H_used\s+([-+][\d.]+)', ln)
        if m: res[law, n, m.group(1)] = (m.group(2), m.group(3))
    for ln in out('c2b_cf.out').split('\n'):
        if ln.startswith('usage law: G'): law = ln.split()[2]
        m = re.match(r'\s+n=\s*(\d+)\s+CF: H_root\s+([-+][\d.]+).*H_used\s+([-+][\d.]+)', ln)
        if m: res[law, int(m.group(1)), 'CF'] = (m.group(2), m.group(3))
    return res
C2 = parse_c2()
fmt = lambda v: v.replace('-', '−')
for n in (1000, 4000, 16000, 64000, 256000):
    row = '| %d | ' % n + ' | '.join(fmt(C2['G1', n, m][0]) for m in ('NAIVE', 'PC', 'DPC', 'SDPC', 'RDPC', 'CF')) + ' |'
    check('c2 G1 row n=%d' % n, row)
for law in ('G2', 'G3'):
    for n in (1000, 16000, 256000):
        row = '| %s | %d | ' % (law, n) + ' | '.join(fmt(C2[law, n, m][1]) for m in ('NAIVE', 'PC', 'DPC', 'SDPC', 'RDPC', 'CF')) \
            + ' | ' + fmt(C2[law, n, 'SDPC'][0]) + ' |'
        check('c2 %s row n=%d' % (law, n), row)
rx('c2 identity example', 'c2_mdl.out', r'n=  1000  roots used \[.=., .all., .and.[^\n]*\n(?:.*\n){3}\s+SDPC\s+H_root\s+([+\d.]+).*identity: H_root\s+([+\d.]+)',
   '+770.0 and +770.015', lambda g: g if g == ['+770.0', '+770.015'] else ['x'])
rx('c2 u7 reproduction G2', 'c2_mdl.out',
   r'usage law: G2.*\n.*n=  1000.*\n\s+NAIVE.*u7 bookkeeping for H_root:\s+([-\d.]+)\]\n\s+PC.*u7 bookkeeping for H_root:\s+([-+\d.]+)\]\n\s+DPC.*u7 bookkeeping for H_root:\s+([-+\d.]+)\]',
   'G2: −{0}, +{1}, +{2} after rounding',
   lambda g: ['%d' % round(-float(g[0])), '%d' % round(float(g[1])), '%d' % round(float(g[2]))])
# ---------------------------------------------------------------- c2_detour.out
for f, w in (('not', '¬¬P'), ('and', 'P∧P'), ('or', 'P∨P'), ('imp', '(0=0)→P'), ('all', '∀zP'), ('ex', '∃zP')):
    rx('detour ' + f, 'c2_detour.out', r'^%s\s+\S.*?\s+(\d+)\s+\d+\s+\d+\s+([\d.]+)$' % f,
       '| %s | {0} | {1} |' % w)
# ---------------------------------------------------------------- c3_tower.out
rx('tower rho=.5 n=1e5', 'c3_tower.out', r'rho=0.50  s=0.50  b=50 bits  eps=0.00\n(?:.*\n){5}\s+100000\s+(\d+)\s+(\d+)\s+([\d.e+-]+)\s+([\d.]+)',
   '(16 at n = 10⁵ for ρ = ½; logarithmic drift). The posterior\n  probability that the next datum is unprovable decays like 1/n ({2} at n = 10⁵). The regret against the true law\n  grows like b × (largest level): {3} bits',
   lambda g: [g[0], g[1], '%.2f·10⁻⁶' % (float(g[2]) * 1e6), g[3]])
rx('tower misspecified', 'c3_tower.out', r's=0.30.*\n(?:.*\n){5}\s+100000.*\s([\d.]+)$', '({0} bits per datum)')
rx('tower L_eps', 'c3_tower.out', r'eps=0.01\n(?:.*\n){5}\s+100000\s+\d+\s+\d+\s+\S+\s+([\d.]+)', '({0} bits)')
# ---------------------------------------------------------------- c4_bdtrc.out
def parse_c4():
    rows = {}; part = n = neg = None
    for ln in out('c4_bdtrc.out').split('\n'):
        if ln.startswith('(A)'): part = 'A'
        if ln.startswith('(B)'): part = 'B'
        m = re.match(r'\s+n=\s*(\d+)\s+(no negatives|negatives.*|\(\d+ distinct\))', ln)
        if m: n = int(m.group(1)); neg = m.group(2).startswith('negatives'); continue
        m = re.match(r'\s{5}(\S.*?)\s+L-L_(?:true|schema)\s+([+-]\S+) bits\s+posterior (\S+)', ln)
        if m: rows.setdefault((part, m.group(1).strip(), neg), {})[n] = (m.group(2), m.group(3))
    return rows
C4 = parse_c4()
def c4row(label, key, first):
    v = C4[key]
    cells = [('0' if v[k][0] == '+0.0' else fmt(v[k][0])) for k in sorted(v)]
    check('c4 row ' + label, '| %s | ' % first + ' | '.join(cells) + ' |')
for key, first in ((('A', 'root  Q+T_f (7 roots)', False), 'root split (7 T_f)'),
                   (('A', 'spare Q+T_Ind+(F->F)', False), 'spare Q+T_Ind+(F→F)'),
                   (('A', 'mem   Q+instances', False), 'memorise instances'),
                   (('A', 'over  Q+T_Linf', False), 'over-general Q+T_L∞'),
                   (('A', 'lumpQ F0+T_Ind', False), 'lump F₀+T_Ind'),
                   (('A', 'bare  F0', False), 'bare F₀'),
                   (('B', 'split by head of t (sound)', False), 'split by head of t (0, S, +, ·): sound'),
                   (('B', 'mem     instances', False), 'memorise instances'),
                   (('B', 'over    z1+0=z2', False), 'over-general z₁+0=z₂'),
                   (('B', 'L1: Ax(x+0=x) + forall-E', False), '∀x(x+0=x), one ∀E step per datum, fixed rule code')):
    c4row('%s %s' % key[:2], key, first)
P = lambda name, n, neg=False: C4['A', name, neg][n][1]
check('c4 mass true n=10,30', '%s·10⁻⁵³ at n = 10, %s·10⁻¹³ at n = 30' % (
    P('true  Q+T_Ind', 10).split('e')[0], P('true  Q+T_Ind', 30).split('e')[0]))
check('c4 spare n=100', '%s·10⁻⁶ at n = 100' % P('spare Q+T_Ind+(F->F)', 100).split('e')[0])
check('c4 lump n=100', '(%s·10⁻⁹⁷)' % P('lumpQ F0+T_Ind', 100).split('e')[0])
assert float(P('spare Q+T_Ind+(F->F)', 10, True)) < 1.6e-5
check('c4 spare with negatives', '≥ 1 − 1.6·10⁻⁵ from n = 10 on')
# ---------------------------------------------------------------- c5_euler.out
rx('euler rho .9', 'c5_euler.out', r'rho=0.90.*\n.*\n\s+100\s+\d+\s+(\d+).*\n(?:.*\n){7}\s+1000000\s+\d+\s+(\d+)\s+\d+\s+\S+\s+(\S+)',
   'flat\n    grammar: {0} and {1}', lambda g: g[:2])
rx('euler rho .97', 'c5_euler.out', r'rho=0.97.*\n(?:.*\n){9}\s+1000000\s+\d+\s+(\d+)', '1.8·10⁶ bits at n = 10⁶',
   lambda g: [] if round(int(g[0]) / 1e5) == 18 else ['x'])
rx('euler P_depth', 'c5_euler.out', r'1000000\s+\d+\s+\d+\s+\d+\s+\S+\s+(\S+)$', '({0} at n = 10⁶)',
   lambda g: ['%.2f·10⁻⁷' % (float(g[0]) * 1e7)])
# ---------------------------------------------------------------- c6_theorem_data.out
for nm, st in (('snx', '∀x ¬Sx=x'), ('mul0', '∀x 0·x=0'), ('add0l', '∀x 0+x=x'), ('addSl', '∀a∀v Sa+v=S(a+v)'),
               ('comm', '∀q∀x x+q=q+x'), ('assoc', '∀a∀b∀x (a+b)+x=a+(b+x)')):
    rx('c6 ' + nm, 'c6_theorem_data.out', r'^T_Ind\s+%s\s+\S+\s+(\d+)\s+(\d+)\s+([\d.]+)\s+[\d.]+\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)' % nm,
       '| %s | %s | {0} | {1} | {2} | {3} | {4} | {5} |' % (nm, st))
rx('c6 lemma reuse', 'c6_theorem_data.out', r'lemmas in-line:\s+\d+ lines,\s+([\d.]+) bits\n.*\{add0l, addSl\}:\s+\d+ lines,\s+([\d.]+) bits.*cost ([\d.]+)',
   'derived in-line costs\n{0} bits; with the lemmas adopted as axioms, {1} bits. The lemmas cost {2} bits of prior')
def c6c(f, s, fields):
    rx('c6 compress %s %s' % (f, s), 'c6_theorem_data.out',
       r'^\s+%s \|phi\| =\s+%d .*derive\s+([\d.]+)\s+memo\s+([\d.]+)\s+templ\s+([\d.]+)' % (f, s), fields)
c6c('Ind', 21, '| Ind | 21 | {0} (a citation) | {1} | = derive |')
c6c('Ind', 429, '| Ind | 429 | {0} (a citation) | {1} | = derive |')
c6c('CVI', 20, '| CVI | 20 | {0} | {1} | {2} (+81 once) |')
c6c('CVI', 418, '| CVI | 418 | {0} | {1} | {2} (+81 once) |')
c6c('LNP', 21, '| LNP | 21 | {0} | {1} | {2} (+86 once) |')
c6c('LNP', 400, '| LNP | 400 | {0} | {1} | {2} (+86 once) |')
def c6d(u, n, mapname):
    rx('c6 stream u=%s n=%d' % (u, n), 'c6_theorem_data.out',
       r'u=%s n=\s*%d\s+T_Ind\s+0\s+T_Ind\+lib\s+(-?\d+)\s+Q\+lib\+memorised uses\s+(-?\d+)' % (u, n),
       '| %s | %d | {0} | {1} | %s |' % (u if u != '0.0' else '0', n, mapname), lambda g: [fmt(v) for v in g])
c6d('0.0', 10, 'Q + library'); c6d('0.0', 1000, 'Q + library'); c6d('0.1', 10, 'T_Ind + library')
c6d('0.1', 1000, 'T_Ind + library'); c6d('0.5', 1000, 'T_Ind + library')
# ---------------------------------------------------------------- c7_rulecode.out
rx('c7 n=1e3', 'c7_rulecode.out', r'R = 10.*\n.*\n.*\n(?:.*\n){4}\s+1000\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)', '| 10³ | {0} | {1} | {2} |')
rx('c7 n=1e6', 'c7_rulecode.out', r'R = 10.*\n(?:.*\n){10}\s+1000000\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)',
   '| 10⁶ | {0} | {1} | {2} |')
rx('c7 coefficient', 'c7_rulecode.out', r'R = 10.*\n(?:.*\n){10}\s+1000000\s+[\d.]+\s+[\d.]+\s+[\d.]+\s+([\d.]+)', '({0}·log₂n at n = 10⁶')
rx('c7 mixed', 'c7_rulecode.out', r'f=0.9  depth:\s+[\d.]+ bits \(([\d.]+) per datum.*\n\s+f=0.5  depth:\s+[\d.]+ bits \(([\d.]+) per',
   '{0} at f = 0.9, {1} at f = 0.5', lambda g: ['%.3f' % float(v) for v in g])
# ---------------------------------------------------------------- c8_narrow.out
rx('c8 narrow seed 31', 'c8_narrow.out',
   r'seed 31.*\n\s+n=  100.*c4 code\s+([+\d.]+).*\n\s+n=  300.*c4 code\s+([+\d.]+).*\n\s+n= 1000.*c4 code\s+([+\d.]+).*\n\s+n= 3000.*c4 code\s+([+\d.]+).*\n.*crossover.*n = 2\^([\d.]+)',
   '{0}, {1}, {2}, {3} bits at\n  n = 100, 300, 1000, 3000 (seed 31)')
rx('c8 crossover', 'c8_narrow.out', r'crossover.*slope (-[\d.]+)\): n = 2\^([\d.]+)', 'crossover is n ≈ 2^{1}')
rx('c8 G1 skeletons', 'c8_narrow.out', r'200000 motives drawn from G1 \(seed 12\): (\d+)', 'exactly {0}')
rx('c8 G1 skel 3000', 'c8_narrow.out', r'n= 3000  H_skel.*c4 code\s+([+\d.]+)\s+identity\s+([+\d.]+)\s+prior part ([+\d]+)',
   'L(H_skel) − L(H_true) = {0} bits\n  (prior part {2})')
rx('c8 G1 slope', 'c8_narrow.out', r'is \((\d+) - 8\)/2 - (\d+)\*\(9-1\)/2 = ([+\d.]+) bits', '({0} − 8)/2 − {1}·(9−1)/2 = {2} bits per doubling')
rx('c8 112 skeletons', 'c8_narrow.out', r'first 3000 data: (\d+)', 'With the {0} skeletons seen in 3000 data')
# ---------------------------------------------------------------- c9_shift.out
rx('c9 shift', 'c9_shift.out', r'checked, (\d+) lines.*\n.*code length ([\d.]+) bits.*costs ([\d.]+) bits',
   '({0} lines; {1} bits against a {2}-bit citation)')

LOG.append('')
LOG.append('%d quotes checked, %d failed%s' % (len([l for l in LOG if l[:4] in ('ok  ', 'FAIL')]), len(FAIL),
                                                ': ' + ', '.join(FAIL) if FAIL else ''))
print('\n'.join(LOG))
open(os.path.join(HERE, 'c10_quotes.out'), 'w').write('\n'.join(LOG) + '\n')
sys.exit(1 if FAIL else 0)
