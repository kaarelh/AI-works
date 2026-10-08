# r6_theorem_data.py -- referee for track "pa": what the track's own L1 code says when the data are THEOREMS given
# without proof (the user's "statements given without proof should be easily derived") rather than axiom
# instances ("uses").  Two questions:
#  (1) Does the per-use cost of a non-primitive form transfer to theorem data?  Example: the theorem Ax(0+x=x),
#      derived in T_Ind (the track's derivation d_q4l_from_right) and in T_CVI (a direct derivation written here).
#  (2) Derivation versus memorisation: under the same code, is it cheaper to derive an induction theorem from Q+Ind
#      or to add the theorem itself as one more axiom?
# Derivations are built with the track's nd.Proof and re-checked by the independent checker of r1_recheck.py.
# Code: the track's proof-text code (log2 10 per line, log2 #axioms per citation, log2(line index) per premise
# reference, LAM = log2 23 bits per written symbol); prior LAM bits per axiom symbol (as in c1_costs.py).
# Deterministic.  Output: r6_theorem_data.out next to this script.
import sys, os, math
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import importlib.util
spec = importlib.util.spec_from_file_location('r1', os.path.join(HERE, 'r1_recheck.py'))
# r1 runs its own report at import; we only need its functions, so import quietly
_stdout = sys.stdout; sys.stdout = open(os.devnull, 'w')
r1 = importlib.util.module_from_spec(spec); spec.loader.exec_module(r1)
sys.stdout.close(); sys.stdout = _stdout
import nd, arith
from nd import V, Z, S, add, eq, lt, ALL, EX, IMP, OR
LAM = math.log2(23)
OUT = []
def say(s=''):
    print(s); OUT.append(s)

x, w, y = V('x'), V('w'), V('y')
m = eq(add(Z, x), x)                                   # motive 0+x=x
ph = lambda t: nd.subst(m, 'x', t)
GOAL = ALL('x', m)

def tcvi_0px(pf):
    """Ax(0+x=x) in Q + Dlt + CVI, directly (progressiveness of 0+x=x, then CVI)."""
    G = ALL('y', IMP(lt(y, x), ph(y)))
    l1 = pf.hyp(G)
    l2 = pf.ax('Q3'); l3 = pf.allE(l2, x)                        # x=0 v Ev x=Sv
    l4 = pf.hyp(eq(x, Z))
    l5 = pf.ax('Q4'); l6 = pf.allE(l5, Z)                        # 0+0=0
    l7 = pf.refl(x)
    l8 = pf.subst(l4, l7, 'z', eq(V('z'), x))                    # 0=x
    l9 = pf.subst(l8, l6, 'z', ph(V('z')))                       # 0+x=x
    l10 = pf.impI(l9, eq(x, Z))
    l11 = pf.hyp(eq(x, S(w)))
    l12 = pf.ax('Dlt'); l13 = pf.allE(l12, w); l14 = pf.allE(l13, x)   # w<x <-> Ez w+Sz=x
    l15 = pf.ax('Q5'); l16 = pf.allE(l15, w); l17 = pf.allE(l16, Z)    # w+S0 = S(w+0)
    l18 = pf.allE(l5, w)                                         # w+0=w
    l19 = pf.subst(l18, l17, 'z', eq(add(w, S(Z)), S(V('z'))))   # w+S0 = Sw
    l20 = pf.subst(l11, l7, 'z', eq(V('z'), x))                  # Sw = x
    l21 = pf.subst(l20, l19, 'z', eq(add(w, S(Z)), V('z')))      # w+S0 = x
    l22 = pf.exI(l21, 'z', eq(add(w, S(V('z'))), x), Z)
    l23 = pf.tc([l14, l22], lt(w, x))
    l24 = pf.allE(l1, w)
    l25 = pf.tc([l23, l24], ph(w))                               # 0+w=w
    l26 = pf.allE(l15, Z); l27 = pf.allE(l26, w)                 # 0+Sw = S(0+w)
    l28 = pf.subst(l25, l27, 'z', eq(add(Z, S(w)), S(V('z'))))   # 0+Sw = Sw
    l29 = pf.subst(l20, l28, 'z', ph(V('z')))                    # 0+x=x
    Ev = EX('v', eq(x, S(V('v'))))
    l30 = pf.hyp(Ev)
    l31 = pf.exE(l30, l29, 'w')
    l32 = pf.impI(l31, Ev)
    l33 = pf.tc([l3, l10, l32], m)
    l34 = pf.impI(l33, G)
    l35 = pf.allI(l34, 'x')
    l36 = pf.ax('CVI', (('x',), m))
    return pf.tc([l35, l36], GOAL)

def build(fn):
    pf = nd.Proof(arith.AX, dict(arith.SCH)); fn(pf); return pf

say('(1) the theorem Ax(0+x=x) as a datum, under the track\'s L1 code (theories with 9 axioms: Q1-Q7, Dlt, one form)')
p_ind = build(lambda pf: arith.d_q4l_from_right(pf, lambda p, mm: p.ax('Ind', mm)))
p_cvi = build(tcvi_0px)
for nm, pf in (('T_Ind (track derivation)', p_ind), ('T_CVI (direct derivation)', p_cvi)):
    ok, msg = r1.recheck(pf, r1.MYAX['Q4L'])
    say('  %-28s lines %3d  bits %7.1f  independent check: %s' % (nm, len(pf.lines), r1.bits(pf, 9), msg))
say('  extra cost of the theorem in T_CVI: %.1f bits (the track\'s per-use overhead of Ind in T_CVI: 880.4)'
    % (r1.bits(p_cvi, 9) - r1.bits(p_ind, 9)))

say()
say('(2) derive or memorise?  cost of an induction theorem theta as a datum:')
say('    derive in Q+Ind      = bits of the derivation (8 axioms, as in c1_costs.py section (c))')
say('    memorise theta       = prior LAM*|theta| once + a one-line citation log2(10)+log2(9) per occurrence')
rows = [('Ax 0+x=x', r1.MYAX['Q4L'], lambda pf: arith.d_q4l_from_right(pf, lambda p, mm: p.ax('Ind', mm))),
        ('Ax Ay Sx+y=S(x+y)', r1.MYAX['Q5L'], lambda pf: arith.d_q5l_from_right(pf, lambda p, mm: p.ax('Ind', mm))),
        ('Ax x+0=x  (in T_left)', r1.MYAX['Q4'], lambda pf: arith.d_q4_from_left(pf, lambda p, mm: p.ax('Ind', mm))),
        ('Ax Ay x+Sy=S(x+y) (T_left)', r1.MYAX['Q5'], lambda pf: arith.d_q5_from_left(pf, lambda p, mm: p.ax('Ind', mm)))]
for nm, goal, fn in rows:
    pf = nd.Proof(arith.AX, dict(arith.SCH)); fn(pf)
    ok, msg = r1.recheck(pf, goal)
    d = r1.bits(pf, 8)
    prior = LAM * r1.size(goal)
    cite = math.log2(10) + math.log2(9)
    k_star = prior / (d - cite)
    beta_star = (d - cite) / r1.size(goal)
    say('  %-28s derive %6.1f   memorise: prior %5.1f + cite %4.1f   memorising cheaper at first occurrence: %s;'
        ' derivation wins only if the axiom prior exceeds %.1f bits/symbol  [%s]'
        % (nm, d, prior, cite, 'yes' if prior + cite < d else 'no', beta_star, msg))
say('Reading: under the track\'s own code a theorem that needs one induction costs 6-9 times more to derive than to')
say('state.  So on data consisting of distinct induction theorems given without proof, "Q + the theorems as axioms"')
say('beats Q+Ind on every datum, and Q+Ind is preferred only if the derivations are much shorter than in this')
say('library or the axiom prior is much steeper (30-46 bits per symbol here, against 4.5) -- or if the data are drawn from')
say('Q+Ind\'s own derivation process (well-specified case).')
open(os.path.join(HERE, 'r6_theorem_data.out'), 'w').write('\n'.join(OUT) + '\n')
