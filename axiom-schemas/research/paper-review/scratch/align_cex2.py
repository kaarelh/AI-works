"""prop:setting:align for C = DT° (full, term metavariables of any arity): (b) and minimality in (c)."""
import sys
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
from dtrc.syntax import parse, pp
from dtrc.templates import geq, covers_all, is_DT0
from dtrc.mincover import MinCover

D = [parse('(Ax. 0=0) & (0=0)', canon=False), parse('(Ax. x=x) & (w0=w0)', canon=False), parse('(Ax. x=0) & (w0=0)', canon=False)]
# the paper's single alignment (G empty): rename every parameter apart
Da = [parse('(Ax. 0=0) & (0=0)', canon=False), parse('(Ax. x=x) & (u1=u1)', canon=False), parse('(Ax. x=0) & (u2=0)', canon=False)]
mins = MinCover(Da, term_arity0=False).minimal()
print('Min_DT0(alpha(D)) =', [pp(M) for M in mins])
T = parse('(Ax. ?g(x)=?h(x)) & (?g(c)=?h(c))')
print('T =', pp(T), 'DT0:', is_DT0(T), 'covers D:', covers_all(T, D))
print('T >=~ some member:', any(geq(T, M) for M in mins))
for M in mins:
    if geq(M, T) and not geq(T, M):
        print('member strictly above T (minimality fails):', pp(M))
