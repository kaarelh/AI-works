"""Exact prefix-interpolation maximum principles and lexicographic cosine modes.

Matrices are cleared to integers. Fraction-free solves independently check
the proposed block recursions, all KKT multipliers, and the uniform wrong
margin. No floating-point optimizer participates in these conclusions.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import argparse,json,math,time
from fractions import Fraction as F
from pathlib import Path
import sympy as sp
from sympy.polys.matrices import DM
from check_gaussian_cosine_precision import radial
ROOT=Path(__file__).resolve().parents[1]

def solve_prefix(B,count):
    A=DM([[sp.ZZ(B[i][j]) for j in range(count)] for i in range(count)],sp.ZZ)
    one=DM([[sp.ZZ(1)] for _ in range(count)],sp.ZZ)
    num,den=A.solve_den(one);den=int(den);c=[int(row[0]) for row in num.to_list()]
    if den<0:den=-den;c=[-x for x in c]
    val=[sum(row[j]*c[j] for j in range(count)) for row in B]
    assert all(val[j]==den for j in range(count))
    return c,val,den

def prediction(n,r,t,count):
    if count==0:return F(0)
    assert 0<count<2**n
    half=2**(n-1)
    if count<half:return prediction(n-1,r,-r*t,count)
    c=(t-r)/(1-r*t)
    return c+(1-c)*prediction(n-1,r,r*t,count-half)

def positive_prefixes(max_n):
    cases=0
    for n in range(max_n+1):
        M=2**n
        for r in (F(1,3),F(1,2),F(3,4)):
            for t in (-r,-r*r,F(0),r*r,r):
                rad=[r**h+t*r**(n-h) for h in range(n+1)]
                den=math.lcm(*(x.denominator for x in rad))
                ints=[int(x*den) for x in rad]
                B=[[ints[(i^j).bit_count()] for j in range(M)] for i in range(M)]
                for count in range(1,M+1):
                    _,v,D=solve_prefix(B,count)
                    assert all(abs(x)<D for x in v[count:]),(n,r,t,count)
                    cases+=1
    return cases

def cosine_paths(dims):
    records=[]
    for d in dims:
        for p,q in ((1,2),(3,4)):
            start=time.monotonic();M=2**d;r=F(p,q);b=radial(d,p,q)
            B=[[(-1)**((i^j).bit_count())*b[(i^j).bit_count()] for j in range(M)] for i in range(M)]
            stages=[]
            for count in range(1,M):
                coeff,v,den=solve_prefix(B,count)
                assert min(coeff)>0,(d,r,count,'inactive observed constraint')
                score=F(v[count],den)
                assert score==prediction(d,r,-r,count)
                assert score<=-r/(1+r+r*r)
                stages.append(dict(observed=count,query=count,all_multipliers_strictly_positive=True,
                    mode_score=str(score),uniform_margin_bound=True,recursive_formula=True))
            row=dict(dimension=d,rho=str(r),stages=stages,seconds=time.monotonic()-start)
            records.append(row)
            print(json.dumps({k:row[k] for k in ['dimension','rho','seconds']}),flush=True)
    return records

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--max-prefix-dimension',type=int,default=4)
    ap.add_argument('--path-dimensions',type=int,nargs='+',default=[1,3,5,7]);args=ap.parse_args()
    r,t=sp.symbols('r t');u=r*(1-t*t)/(1-r*r*t*t);v=t*(1-r*r)/(1-r*r*t*t)
    assert sp.factor(u+v-(r+t)/(1+r*t))==0
    assert sp.factor((1+r*t)*(1-r*t)-r*r*(1-t*t)-t*t*(1-r*r)-(1-r*r)*(1-t*t))==0
    count=positive_prefixes(args.max_prefix_dimension)
    paths=cosine_paths(args.path_dimensions)
    result=dict(status='PASS',positive_prefix_cases=count,cosine_paths=paths,
        cosine_lexicographic_stages=sum(len(r['stages']) for r in paths),
        scope='Exact finite rational checks of the prefix maximum principle, strict KKT activity, lexicographic recursion, and dimension-uniform wrong mode margin. The Gaussian concentration and neural width limits are not formalized by these checks.')
    (ROOT/'results/cosine_lexicographic_checks.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ['status','positive_prefix_cases','cosine_lexicographic_stages']}),flush=True)
if __name__=='__main__':main()
