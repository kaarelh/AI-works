"""Exact matrix identities and certified finite QP paths for cosine Bayes.

Floating point proposes active sets. Integer fraction-free solves then
certify every feasibility and KKT inequality, and the selected wrong sign.
These checks do not establish the Gaussian conditioning or neural limit.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):
    os.environ[key]='1'
import argparse,json,math,time
from pathlib import Path
import numpy as np
import sympy as sp
from scipy.linalg import cholesky,solve_triangular
from scipy.optimize import nnls
from sympy.polys.matrices import DM
ROOT=Path(__file__).resolve().parents[1]

def radial(d,p,q):
    return [p**h*q**(d+1-h)+p**(d-h+1)*q**h for h in range(d+1)]

def identities(max_dimension):
    rows=[]
    for d in range(1,max_dimension+1,2):
        for p,q in ((1,3),(1,2),(3,4),(9,10)):
            B=radial(d,p,q)
            for h in range(d+1):
                product=sum((-1)**(i+j)*math.comb(h,i)*math.comb(d-h,j)*
                    B[i+j]*B[h-i+j] for i in range(h+1) for j in range(d-h+1))
                assert product==((q*q-p*p)**(d+1) if h==0 else 0)
            assert min(B)*q**(d+1)>=max(B)*p**(d+1)
            assert max(B)==q**(d+1)+p**(d+1)
            assert sum(math.comb(d,h)*B[h] for h in range(d+1))==(p+q)**(d+1)
            eigenvalues=[(q+p)**(d-l)*(q-p)**l*(q+(-1)**l*p) for l in range(d+1)]
            assert min(eigenvalues)>0
            rows.append(dict(dimension=d,rho=f'{p}/{q}',entries_positive=True,
                signed_inverse_product=True,ratio_bound=True,positive_spectrum=True,exact_row_sum=True,diagonal_maximum=True))
    return rows

def exact_mode(B,history):
    M=len(B);scale=max(abs(x) for row in B for x in row)
    K=np.array([[B[i][j]/scale for j in history] for i in history])
    L=cholesky(K,lower=True);rhs=solve_triangular(L,np.ones(len(history)),lower=True)
    proposal,_=nnls(L.T,rhs,maxiter=100*len(history))
    active=[history[j] for j in range(len(history)) if proposal[j]>1e-12*max(proposal)]
    visited=set()
    for _ in range(4*M):
        key=tuple(active)
        assert key not in visited,('active-set repair cycled',history,active)
        visited.add(key)
        A=DM([[sp.ZZ(B[i][j]) for j in active] for i in active],sp.ZZ)
        one=DM([[sp.ZZ(1)] for _ in active],sp.ZZ)
        num,den=A.solve_den(one)
        den=int(den);coeff=[int(row[0]) for row in num.to_list()]
        if den<0:den=-den;coeff=[-x for x in coeff]
        if min(coeff)<0:
            del active[min(range(len(coeff)),key=coeff.__getitem__)]
            continue
        values=[sum(B[i][j]*c for j,c in zip(active,coeff)) for i in range(M)]
        assert all(values[i]==den for i in active)
        violated=[i for i in history if values[i]<den]
        if violated:
            active=sorted(active+[min(violated,key=lambda i:values[i])])
            continue
        return active,values,den
    raise AssertionError('active-set repair did not finish')

def path(d,p,q):
    start=time.monotonic();M=2**d;b=radial(d,p,q)
    B=[[(-1)**((i^j).bit_count())*b[(i^j).bit_count()] for j in range(M)] for i in range(M)]
    history=[0];stages=[]
    while len(history)<M:
        active,values,den=exact_mode(B,history)
        unseen=[i for i in range(M) if i not in history]
        query=min(unseen,key=lambda i:(values[i],i))
        assert values[query]<0
        # Exact version of the all-positive precision bound, at margin one.
        assert values[query]*len(unseen)*max(b)<=-den*len(history)*min(b)
        rowsum=sum(math.comb(d,h)*b[h] for h in range(d+1))
        assert values[query]*len(unseen)*max(b)<=-den*(rowsum-len(unseen)*max(b))
        stages.append(dict(observed=len(history),active=len(active),query=query,
            signed_score_numerator=str(values[query]),signed_score_denominator=str(den),
            exact_kkt=True,quantitative_wrong_mode_bound=True,exact_row_sum_mean_bound=True))
        history.append(query)
    return dict(dimension=d,rho=f'{p}/{q}',permutation=history,stages=stages,seconds=time.monotonic()-start)

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--max-identity-dimension',type=int,default=31)
    ap.add_argument('--path-dimensions',type=int,nargs='+',default=[1,3,5,7])
    args=ap.parse_args();rows=identities(args.max_identity_dimension);paths=[]
    for d in args.path_dimensions:
        for p,q in ((1,2),(3,4)):
            item=path(d,p,q);paths.append(item)
            print(json.dumps(dict(dimension=d,rho=item['rho'],stages=len(item['stages']),seconds=item['seconds'])),flush=True)
    out=dict(status='PASS',matrix_identities=rows,paths=paths,
        scope='Exact integer radial identities and exact rational KKT-certified finite paths. Floating point only proposes active sets; no analytic limit is certified by these checks.')
    (ROOT/'results/gaussian_cosine_precision_checks.json').write_text(json.dumps(out,indent=2)+'\n')
    print(json.dumps(dict(status='PASS',matrix_cases=len(rows),path_stages=sum(len(p['stages']) for p in paths))))

if __name__=='__main__':main()
