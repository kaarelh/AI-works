"""Counterexample check for prop:setting:align (b)/(c) and the claim
'If some datum has no parameter ... Min^al(D) is Min(D) up to equiv~' (app-setting.tex)."""
import os, sys
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
from dtrc.syntax import parse, pp, canon_params
from dtrc.templates import geq, covers_all, is_DT0, equiv
from dtrc.mincover import MinCover, aligned_min, n_alignments

def run(name, T, D):
    print('==', name)
    print('T =', pp(T), ' in DT0:', is_DT0(T))
    D = [canon_params(d) for d in D]
    for d in D: print('  datum', pp(d))
    print('T covers D (up to renaming):', covers_all(T, D))
    print('n_alignments:', n_alignments(D))
    lit = MinCover(D).minimal()
    print('Min_lit(D):', [pp(M) for M in lit])
    al, mc = aligned_min(D)
    print('Min^al(D):', [pp(M) for M in al])
    print('some member below T (T >=~ M):', any(geq(T, M) for M in al))
    print('some literal member below T:', any(geq(T, M) for M in lit))

# Example 1: a parameter-free datum exists, T has a parameter only in a derived argument,
# and it appears under different canonical names in two data.
T = parse('?Q & ((Ax. ?P(x)) & ?P(c))')
D = [parse('(0=0) & ((Ax. 0=0) & (0=0))'),
     parse('(0=0) & ((Ax. x=x) & (c=c))'),
     parse('(e=e) & ((Ax. x=0) & (c=0))')]
run('Ex1 (DT0_F, parameter-free datum present)', T, D)

# Example 2: theory reading -- one alignment renames ALL parameters apart, so even a shared name is split.
T2 = parse('(Ax. ?P(x)) & ?P(c)')
D2 = [parse('(Ax. 0=0) & (0=0)'), parse('(Ax. x=x) & (c=c)'), parse('(Ax. x=0) & (c=0)')]
run('Ex2 (literal covering; shared name w0)', T2, D2)

# Example 2b: the paper's definition of the single alignment (G empty): every parameter renamed apart.
D2a = [parse('(Ax. 0=0) & (0=0)', canon=False), parse('(Ax. x=x) & (u1=u1)', canon=False), parse('(Ax. x=0) & (u2=0)', canon=False)]
lit2a = MinCover(D2a).minimal()
print('== Ex2b: Min(alpha(D2)) with parameters renamed apart (paper definition):', [pp(M) for M in lit2a])
print('T2 >= some member:', any(geq(T2, M) for M in lit2a))

# Example 3: a target all of whose instances are logically valid (relevant to prop:exp:oracle(b)).
T3 = parse('(?Q | ~?Q) & ((Ax. ?P(x)) -> ?P(c))')
D3 = [parse('((0=0) | ~(0=0)) & ((Ax. 0=0) -> 0=0)'),
      parse('((0=0) | ~(0=0)) & ((Ax. x=x) -> c=c)'),
      parse('((e=e) | ~(e=e)) & ((Ax. x=0) -> c=0)')]
run('Ex3 (valid target, DT0_F)', T3, D3)
