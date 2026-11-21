"""Exact low-dimensional coefficient exploration for the open prefix KKT conjecture.

Cramer's numerator is expanded in nonnegative consecutive spectral gaps.
Nonnegative coefficients certify only the explicitly enumerated finite cases.
A negative coefficient is not a counterexample to positivity of the polynomial.
Full and one-missing-vertex sets use exact reciprocal-spectrum identities instead
of redundant determinant expansions.
"""
import argparse,json,time
from pathlib import Path
import sympy as s
from sympy.polys.matrices import DomainMatrix
ROOT=Path(__file__).resolve().parents[1]

def main():
 parser=argparse.ArgumentParser();parser.add_argument("--max-dimension",type=int,default=3);parser.add_argument("--resume",action="store_true");args=parser.parse_args()
 assert 1<=args.max_dimension<=4
 start=time.monotonic();records=[];previous_seconds=0.
 checkpoint=ROOT/"results/prefix_kkt_polynomial_exploration.json"
 if args.resume and checkpoint.exists():
  prior=json.loads(checkpoint.read_text());records=prior["records"];previous_seconds=prior["seconds"]
 completed={(r["dimension"],r["prefix"]) for r in records}
 for d in range(1,args.max_dimension+1):
  M=2**d;g=s.symbols('g0:'+str(d+1));mu=[sum(g[:p+1]) for p in range(d+1)]
  W=s.Matrix([[(-1)**((i&j).bit_count()) for j in range(M)] for i in range(M)])
  C=W*s.diag(*[mu[j.bit_count()] for j in range(M)])*W.T/M
  for h in range(1,M+1):
   if (d,h) in completed:continue
   if h in [M-1,M]:
    if h==M:
     values=[1/mu[0]]*M;method='Full cube: exact constant-vector eigenvalue identity.'
     positive_terms=None
    else:
     Q=W*s.diag(*[1/mu[j.bit_count()] for j in range(M)])*W.T/M
     values=[s.cancel((Q[M-1,M-1]-Q[i,M-1])/(mu[0]*Q[M-1,M-1])) for i in range(h)]
     positive_terms=[[sum(1 for mask in range(M) if mask.bit_count()==p and ((mask&(i^(M-1))).bit_count()%2)==1) for p in range(d+1)] for i in range(h)]
     assert all(sum(row)>0 for row in positive_terms)
     method='One missing vertex: (Q_ii-Q_ij)/(mu0 Q_ii), whose numerator is a strictly positive reciprocal-spectrum sum.'
    residual=C[:h,:h]*s.Matrix(values)-s.ones(h,1)
    assert all(s.cancel(v)==0 for v in residual)
    records.append(dict(dimension=d,prefix=h,method=method,strict_positive_for_all_ordered_positive_spectra=True,
        multipliers=[str(v) for v in values],reciprocal_positive_term_counts=positive_terms))
    print(json.dumps({k:records[-1][k] for k in ['dimension','prefix','method']}),flush=True)
    out=dict(status='in_progress',scope=__doc__.strip(),records=records,seconds=previous_seconds+time.monotonic()-start)
    checkpoint.write_text(json.dumps(out,indent=2)+'\n')
    continue
   A=C[:h,:h];dm=DomainMatrix.from_Matrix(A).convert_to(s.QQ.poly_ring(*g));den=dm.det().as_expr()
   # Cramer's rule avoids expanding all adjugate entries.
   numerators=[]
   for i in range(h):
    B=A.copy();B[:,i]=s.ones(h,1)
    numerator=DomainMatrix.from_Matrix(B).convert_to(s.QQ.poly_ring(*g)).det().as_expr()
    pol=s.Poly(numerator,*g);negative=sum(bool(c<0) for c in pol.coeffs())
    assert pol.eval({g[0]:1,**{x:0 for x in g[1:]}})==1
    numerators.append(dict(index=i,monomials=len(pol.terms()),negative_coefficients=negative,polynomial=str(pol.as_expr())))
   records.append(dict(dimension=d,prefix=h,all_coefficients_nonnegative=all(r['negative_coefficients']==0 for r in numerators),numerators=numerators))
   print(json.dumps({k:records[-1][k] for k in ['dimension','prefix','all_coefficients_nonnegative']}),flush=True)
   out=dict(status='in_progress',scope=__doc__.strip(),records=records,seconds=previous_seconds+time.monotonic()-start)
   (ROOT/'results/prefix_kkt_polynomial_exploration.json').write_text(json.dumps(out,indent=2)+'\n')
 out=dict(status='complete',scope=__doc__.strip(),records=records);out['seconds']=previous_seconds+time.monotonic()-start;out['timing_scope']='Saved completed-case wall time plus this resumed segment; discarded interrupted determinant computation is not included.'
 (ROOT/'results/prefix_kkt_polynomial_exploration.json').write_text(json.dumps(out,indent=2)+'\n')
if __name__=='__main__':main()
