# c6_theorem_data.py -- data that are THEOREMS given without proof (the user's "statements given without proof
# should be fairly easily derived from axioms"), under the track's two-part proof-text code L1-sch (referee issue
# M3; notes-final.md section 3).  Deterministic except the random motives of part (c) (seed 41).
#
# Code (as in c1_costs.py): a derivation costs, per line, log2(10) for the rule, log2(#axioms) for an axiom citation,
# log2(line index) per premise reference, and LAM = log2(23) bits per written symbol.  The prior charges LAM bits per
# axiom symbol.  "Memorise theta" = adopt the theorem theta as one more ground axiom: prior LAM*|theta| once, then a
# one-line citation per occurrence.  The memorisation threshold is beta*(theta) = (D(theta) - c)/|theta|: adopting
# theta at its first occurrence is cheaper than deriving it iff the per-symbol axiom prior is below beta*.
import math, random
from nd import Proof, size, show, NOT, ALL, IMP, AND, lt, V, subst, fv
import arith, thm
from arith import AX, SCH
from test_nd import rform

LAM = math.log2(23)
CITE = lambda n_ax: math.log2(len(Proof.RULES)) + math.log2(n_ax)
OUT = []
def say(s=''):
    print(s, flush=True); OUT.append(s)

def run(name, get_ind, get_lemma, axioms=AX, schemas=SCH):
    pf = Proof(axioms, schemas)
    thm.DERIV[name](pf, get_ind, get_lemma)
    pf.check_closed(thm.THM[name])
    return pf

# ------------------------------------------------------------------------------------------------------ (a)
say('(a) induction theorems as data: derive in a theory, or memorise (adopt as a ground axiom)?')
say('    D = bits of the checked derivation; c = one-line citation in the theory with theta added;')
say('    beta* = (D - c)/|theta| bits per symbol: memorising at the first occurrence is cheaper iff the axiom prior')
say('    per symbol is below beta* (the track uses LAM = %.2f).' % LAM)
THEORIES = {
    'T_Ind': (thm.ind_cite, 8),          # Q1..Q7 + Ind
    'T_CVI': (thm.ind_via_cvi, 9),       # Q1..Q7 + Dlt + CVI
    'T_LNP': (thm.ind_via_lnp, 9),       # Q1..Q7 + Dlt + LNP
}
say('%-6s %-6s %-34s %4s %6s %8s %8s %9s %9s %7s %s' % ('theory', 'thm', 'statement', '|th|', 'lines', 'D',
                                                        'D(dec)', 'memorise', 'D/memo', 'beta*', 'last line'))
RES = {}
for T, (gi, nax) in THEORIES.items():
    for name in thm.THM:
        gl = thm.lemmas_inline(gi)
        pf = run(name, gi, gl)
        st = pf.stats()
        D = pf.bits(LAM, nax)
        Dd = pf.bits_decodable(LAM, nax)
        th = thm.THM[name]
        c = CITE(nax + 1)
        memo = LAM * size(th) + c
        bstar = (D - c) / size(th)
        last = pf.lines[-1]
        lw = sum(size(w) for w in last.written)
        RES[T, name] = dict(D=D, Dd=Dd, size=size(th), lines=st['lines'], memo=memo, bstar=bstar)
        say('%-6s %-6s %-34s %4d %6d %8.1f %8.1f %9.1f %9.1f %7.1f %s writes %d' % (
            T, name, show(th), size(th), st['lines'], D, Dd, memo, D / memo, bstar, last.rule, lw))
say('Every derivation above ends with a tc line that writes the whole theorem (LAM*|theta| bits), or with allI')
say('lines over a tc line that writes its matrix; so D exceeds the memorisation cost by the cost of all the other lines.')
say()
say('    extra cost of each theorem in T_CVI and T_LNP over T_Ind (upper bounds: Ind is derived from CVI each time):')
for name in thm.THM:
    say('      %-6s  T_CVI %+8.1f   T_LNP %+8.1f' % (name, RES['T_CVI', name]['D'] - RES['T_Ind', name]['D'],
                                                    RES['T_LNP', name]['D'] - RES['T_Ind', name]['D']))
say()

# the referee's examples: Q4, Q5 in T_left (= Q4L, Q5L, Ind), and Q4L, Q5L in T_right (= T_Ind)
say('    the four theorems of the referee\'s r6 (recursion conventions; 8 axioms; c = citation with 9 axioms):')
gi = lambda pf, mm: pf.ax('Ind', mm)
for nm, d, goal in (('Q4 in T_left', arith.d_q4_from_left, AX['Q4']), ('Q5 in T_left', arith.d_q5_from_left, AX['Q5']),
                    ('Q4L in T_right', arith.d_q4l_from_right, AX['Q4L']),
                    ('Q5L in T_right', arith.d_q5l_from_right, AX['Q5L'])):
    pf = Proof(AX, SCH); d(pf, gi); pf.check_closed(goal)
    D = pf.bits(LAM, 8); c = CITE(9)
    say('      %-15s |th| %2d  D %6.1f   memorise %5.1f + %4.1f   beta* %5.1f' % (nm, size(goal), D, LAM * size(goal),
                                                                             c, (D - c) / size(goal)))
say()

# ------------------------------------------------------------------------------------------------------ (b)
say('(b) lemma reuse: commutativity with its two lemmas derived in-line, or cited after adopting them as axioms')
pf_in = run('comm', thm.ind_cite, thm.lemmas_inline(thm.ind_cite))
pf_ax = run('comm', thm.ind_cite, thm.lemmas_cited, axioms=thm.AXT)
D_in, D_ax = pf_in.bits(LAM, 8), pf_ax.bits(LAM, 10)
prior_lem = LAM * (size(thm.THM['add0l']) + size(thm.THM['addSl']))
say('    comm in T_Ind, lemmas in-line:  %3d lines, %7.1f bits' % (len(pf_in.lines), D_in))
say('    comm in T_Ind + {add0l, addSl}:  %3d lines, %7.1f bits   (saving %.1f bits per use; the two lemmas cost %.1f'
    ' bits of prior)' % (len(pf_ax.lines), D_ax, D_in - D_ax, prior_lem))
say('    so the lemmas are adopted as axioms once comm (or anything using them) occurs %d time(s).'
    % math.ceil(prior_lem / (D_in - D_ax)))
say()

# ------------------------------------------------------------------------------------------------------ (c)
say('(c) compressible theorems: instances of a schema form with large motives (seed 41)')
say('    datum f(phi), phi a random motive with x free; per-datum bits under three hypotheses:')
say('      derive  = bits of the schematic derivation of f(P) in T_Ind (c1_costs.py) + LAM*|phi| (L1-sch)')
say('      memo    = LAM*|f(phi)| + citation           (adopt the datum itself as a ground axiom)')
say('      templ   = citation + LAM*|phi|, plus LAM*|f(P)| of prior once (adopt the template f(P))')
# schematic costs of f(P) in T_Ind = Q1..Q7 + Dlt + Ind (9 axioms), exactly as in c1_costs.py section (a)
Pm, theta = arith.Pm, (lambda phi: ALL('y', IMP(lt(V('y'), V('x')), subst(phi, 'x', V('y')))))
ind_c = lambda phi: (lambda pf: pf.ax('Ind', (('x',), phi)))
cvi_i = lambda phi: (lambda pf: arith.d_cvi_from_ind(pf, phi, ind_c(theta(phi))))
SCHEM = {'Ind': ind_c(Pm), 'CVI': cvi_i(Pm), 'LNP': lambda pf: arith.d_lnp_from_cvi_neg(pf, Pm, cvi_i(NOT(Pm)))}
GOALF = {'Ind': arith.Ind, 'CVI': arith.CVI, 'LNP': arith.LNP}
SCH_BITS = {}
for f, prov in SCHEM.items():
    pf = Proof(AX, SCH); prov(pf); pf.check_closed(GOALF[f]((('x',), Pm)))
    SCH_BITS[f] = pf.bits(LAM, 9)
def motive_of_size(rng, target):
    while True:
        phi = rform(rng, 2)
        if 'x' in fv(phi): break
    while size(phi) < target:
        phi = AND(phi, rform(rng, 2))
    return phi
rng = random.Random(41)
for f in ('Ind', 'CVI', 'LNP'):
    sch = SCH_BITS[f]
    for target in (5, 20, 100, 400):
        phi = motive_of_size(rng, target)
        sz = size(phi)
        inst = {'Ind': arith.Ind, 'CVI': arith.CVI, 'LNP': arith.LNP}[f]((('x',), phi))
        derive = sch + LAM * (sz - size(arith.Pm))   # the schematic derivation already wrote P(x) (2 symbols)
        memo = LAM * size(inst) + CITE(9)
        templ = CITE(9) + LAM * sz
        say('      %-3s |phi| = %3d  |f(phi)| = %4d   derive %7.1f   memo %7.1f   templ %7.1f (+%.0f once)   cheapest per '
            'datum: %s' % (f, sz, size(inst), derive, memo, templ, LAM * size(GOALF[f]((('x',), Pm))),
                           min((derive, 'derive'), (memo, 'memo'))[1] if f != 'Ind' else 'derive (= cite Ind)'))
say('    Ind(phi) in T_Ind is a citation, so "derive" is the template row: the schema compresses its instances by a')
say('    factor of about |Ind(phi)|/|phi|.  For a non-primitive form (CVI, LNP in T_Ind) deriving beats memorising')
say('    only when the motive is long; adopting the template beats both after one or two uses.')
say()

# ------------------------------------------------------------------------------------------------------ (d)
say('(d) posterior on theorem streams (two-part code as above, uniform citation index log2 #axioms):')
LIB = list(thm.THM)
Qsize = sum(size(AX['Q%d' % i]) for i in range(1, 8))
ind_size = size(arith.Ind((('x',), Pm)))
lib_size = sum(size(thm.THM[k]) for k in LIB)
def stream(n, u, rng):
    """n data: with prob u a fresh induction use Ind(phi), phi random (|phi| ~ 8-12); else a library theorem."""
    out = []
    for _ in range(n):
        if rng.random() < u:
            while True:
                phi = rform(rng, 3)
                if 'x' in fv(phi): break
            out.append(('use', size(phi), size(arith.Ind((('x',), phi)))))
        else:
            out.append(('thm', rng.choice(LIB), None))
    return out
def codelengths(data):
    seen_thm = set(); n_use_syms = 0; use_inst_syms = 0; n_use = 0
    L = {'T_Ind': LAM * (Qsize + ind_size), 'T_Ind+lib': LAM * (Qsize + ind_size + lib_size),
         'Q+lib+memorised uses': LAM * (Qsize + lib_size)}
    for kind, a, b in data:
        if kind == 'thm':
            L['T_Ind'] += RES['T_Ind', a]['D']
            L['T_Ind+lib'] += CITE(8 + len(LIB))
            L['Q+lib+memorised uses'] += CITE(7 + len(LIB))
        else:
            n_use += 1
            L['T_Ind'] += CITE(8) + LAM * a
            L['T_Ind+lib'] += CITE(8 + len(LIB)) + LAM * a
            # a fresh use is not derivable from Q + library: it is memorised (prior) and cited
            L['Q+lib+memorised uses'] += LAM * b + CITE(7 + len(LIB) + n_use)
    return L
for u in (0.0, 0.1, 0.5):
    rng = random.Random(42)
    data = stream(1000, u, rng)
    for n in (1, 10, 100, 1000):
        L = codelengths(data[:n])
        best = min(L, key=L.get)
        say('    u=%.1f n=%4d  ' % (u, n) + '  '.join('%s %9.0f' % (k, v - L['T_Ind']) for k, v in L.items())
            + '   (relative to T_Ind; MAP: %s)' % best)
say('    T_Ind = Q1..Q7 + Ind (PA).  T_Ind+lib has the same theorems as T_Ind, since the library consists of')
say('    T_Ind-theorems.  Q+lib is Q plus six PA-theorems, a finite subtheory of PA, hence strictly weaker (PA is')
say('    not finitely axiomatisable).  The memorised-uses variant adds each fresh Ind(phi) as a ground axiom.')
open('c6_theorem_data.out', 'w').write('\n'.join(OUT) + '\n')
