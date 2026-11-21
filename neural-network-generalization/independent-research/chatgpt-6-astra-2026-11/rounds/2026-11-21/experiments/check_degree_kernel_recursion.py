"""Exact finite checks of lexicographic degree-spectrum interpolation.

The recursion is compared with rational matrix solves. Margin KKT checks are
separately labeled exploration: equality interpolation alone does not prove
that positive-margin constraints are active. ReLU evaluations use 90 digits,
not interval arithmetic. The paper contains the all-dimensional proof.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
from fractions import Fraction as F
from pathlib import Path
import json,math,random,time
import mpmath as mp
import numpy as np
import sympy as sp
from sympy.polys.matrices import DM
ROOT=Path(__file__).resolve().parents[1]
mp.mp.dps=90

def next_value(mu,h):
    n=len(mu)-1
    if not h:return F(0)
    half=2**(n-1)
    if h<half:return next_value([(x+y)/2 for x,y in zip(mu,mu[1:])],h)
    r=(mu[0]-mu[1])/(mu[0]+mu[1])
    return r+(1-r)*next_value([2*x*y/(x+y) for x,y in zip(mu,mu[1:])],h-half)

def radial(d,mu):
    return [sum(F(sum((-1)**j*math.comb(h,j)*math.comb(d-h,p-j)
        for j in range(max(0,p-d+h),min(p,h)+1)))*mu[p] for p in range(d+1))/2**d for h in range(d+1)]

def exact_cases():
    rng=random.Random(2026112401);records=[]
    for d in range(1,7):
        for sample in range(8):
            mu=[F(1)]
            for _ in range(d):mu.append(mu[-1]+F(rng.randint(1,9),rng.randint(1,7)))
            values=[next_value(mu,h) for h in range(1,2**d)]
            assert max(values)<=-(mu[1]-mu[0])/(mu[1]+mu[0])/3**(d-1)
            rad=radial(d,mu);den=math.lcm(*(v.denominator for v in rad));ints=[int(v*den) for v in rad]
            histories=list(range(1,2**d)) if d<=4 else sorted({1,2,3,2**(d-1)-1,2**(d-1),2**(d-1)+1,2**d-1})
            margin_positive=[]
            for h in histories:
                A=DM([[sp.ZZ(ints[(i^j).bit_count()]) for j in range(h)] for i in range(h)],sp.ZZ)
                num,div=A.solve_den(DM([[sp.ZZ(1)] for _ in range(h)],sp.ZZ));div=int(div)
                coeff=[int(row[0]) for row in num.to_list()]
                prediction=F(sum(ints[(h^j).bit_count()]*v for j,v in enumerate(coeff)),div)
                assert prediction==values[h-1]
                margin_positive.append(all(F(c,div)>0 for c in coeff))
            records.append(dict(dimension=d,case=sample,spectrum=[str(x) for x in mu],
                exact_wrong_predictions=len(values),exact_matrix_comparisons=len(histories),
                positive_margin_multipliers_in_checked_cases=all(margin_positive),
                margin_scope='Finite exploration only; the general prefix KKT conjecture is not proved.'))
    return records

def relu_cases():
    records=[]
    for d in range(1,16):
        q=mp.mpf(d+1)
        kernel=[(mp.sqrt(q*q-(q-2*h)**2)+(q-2*h)*(mp.pi-mp.acos((q-2*h)/q)))/(2*mp.pi) for h in range(d+1)]
        lam=[sum((-1)**j*math.comb(p,j)*math.comb(d-p,h)*kernel[j+h]
            for j in range(p+1) for h in range(d-p+1))/2**d for p in range(d+1)]
        assert min(lam)>0 and all(lam[p]>=lam[p+1]-mp.mpf('1e-80') for p in range(d))
        if d%2:
            mu=list(reversed(lam));hvals=[next_value(mu,h) for h in range(1,2**d)]
            assert max(hvals)<=-(mu[1]-mu[0])/(mu[1]+mu[0])/3**(d-1)
            records.append(dict(dimension=d,wrong_lexicographic_predictions=len(hvals),largest_signed_prediction=str(max(hvals)),
                normalized_eigenvalues=[str(v) for v in lam],signed_predictions=[float(v) for v in hvals] if d<=7 else None,scope='90-digit evaluation of exact arc-cosine formulas and the proved recursion; not an interval enclosure.'))
    return records

def tangent_cases():
    records=[]
    for d in range(3,16,2):
        q=mp.mpf(d+1)
        for c0,c1 in [(0,1),(1,1)]:
            kernel=[(c0*mp.sqrt(q*q-(q-2*h)**2)+(c0+c1)*(q-2*h)*(mp.pi-mp.acos((q-2*h)/q)))/(2*mp.pi) for h in range(d+1)]
            lam=[sum((-1)**j*math.comb(p,j)*math.comb(d-p,h)*kernel[j+h]
                for j in range(p+1) for h in range(d-p+1))/2**d for p in range(d+1)]
            assert min(lam)>0 and lam[0]>lam[1] and lam[-2]>lam[-1]
            assert all(lam[p]>=lam[p+1]-mp.mpf('1e-80') for p in range(d))
            values=[next_value(list(reversed(lam)),h) for h in range(1,2**d)]
            assert max(values)<=-(lam[-2]-lam[-1])/(lam[-2]+lam[-1])/3**(d-1)
            records.append(dict(dimension=d,readout_weight=c0,incoming_weight=c1,
                wrong_lexicographic_predictions=len(values),largest_signed_prediction=str(max(values)),
                normalized_eigenvalues=[str(v) for v in lam],
                scope='90-digit ReLU initialization tangent kernel and proved interpolation recursion; frozen zero-output linearization, not nonlinear training.'))
    # Polynomial identity underlying strict adjacent tangent-level ordering.
    t,u,c0,c1,q,j=sp.symbols('t u c0 c1 q j')
    previous=c0+c1*u*((2*j-2)/t+(q-2*j+2)*t)
    current=t*t*(c0+c1*u*(2*j/t+(q-2*j)*t))
    claimed=(1-t*t)*(c0+c1*u*((2*j-2)/t+(q-2*j)*t))
    assert sp.factor(previous-current-claimed)==0
    return records

def positive_power_cases():
    rows=[];comparisons=0
    for q in range(3,19):
        v=[1]+[0]*q
        for m in range(65):
            assert sum(math.comb(q,r)*v[r] for r in range(q+1))==q**m
            for r in range(q-1):
                delta=v[r]-v[r+2];assert delta>=0
                assert (delta>0)==(m>=r and (m-r)%2==0)
            d=q-1;lam=[v[p]+v[p+1] for p in range(d+1)]
            assert all(lam[p]>=lam[p+1] for p in range(d))
            if m>=d:assert min(lam)>0
            if q<=8 and m<=12:
                for p in range(d+1):
                    numerator=sum((-1)**j*math.comb(p,j)*math.comb(d-p,h)*(q-2*(j+h))**m
                        for j in range(p+1) for h in range(d-p+1))
                    assert numerator==2**d*lam[p];comparisons+=1
            rows.append(dict(augmented_dimension=q,power=m,last_eigenvalue_numerator=lam[-1],last_gap_numerator=lam[-2]-lam[-1]))
            v=[(r*v[r-1] if r else 0)+((q-r)*v[r+1] if r<q else 0) for r in range(q+1)]
    return dict(exact_walk_cases=len(rows),exact_walsh_comparisons=comparisons,rows=rows,
        scope='Exact integer cube-walk recurrences and finite monomial Walsh identities; the manuscript gives the all-dimensional induction and infinite-series argument.')

def deep_relu_cases():
    records=[]
    def kappa(t):return (mp.sqrt(max(mp.mpf(0),1-t*t))+t*(mp.pi-mp.acos(t)))/mp.pi
    def prime(t):return (mp.pi-mp.acos(t))/mp.pi
    for d in range(2,11):
        q=mp.mpf(d+1);S=[(q-2*h)/q for h in range(d+1)];T=S.copy()
        for depth in range(1,5):
            Sn=[kappa(t) for t in S];T=[s+t*prime(c) for s,t,c in zip(Sn,T,S)];S=Sn
            for kind,kernel in [('NNGP',S),('NTK',T)]:
                lam=[sum((-1)**j*math.comb(p,j)*math.comb(d-p,h)*kernel[j+h]
                    for j in range(p+1) for h in range(d-p+1))/2**d for p in range(d+1)]
                assert min(lam)>0 and all(lam[p]>=lam[p+1]-mp.mpf('1e-80') for p in range(d))
                if depth>=2 or d%2:
                    assert lam[-2]>lam[-1]
                    values=[next_value(list(reversed(lam)),h) for h in range(1,2**d)]
                    gap=(lam[-2]-lam[-1])/(lam[-2]+lam[-1])/3**(d-1)
                    assert max(values)<=-gap
                    records.append(dict(dimension=d,depth=depth,kernel=kind,wrong_predictions=len(values),
                        largest_signed_prediction=str(max(values)),last_spectral_drop=str(lam[-2]-lam[-1])))
    return dict(cases=records,wrong_predictions=sum(r['wrong_predictions'] for r in records),
        scope='90-digit evaluation of the explicitly normalized fixed ReLU NNGP/NTK recursions; not a finite deep-network simulation or interval enclosure.')

def nonprefix_counterexample():
    mu=list(map(F,[1,2,16,17]));H=[0,1,3,6];rad=radial(3,mu)
    A=sp.Matrix([[sp.Rational(rad[(i^j).bit_count()].numerator,rad[(i^j).bit_count()].denominator) for j in H] for i in H])
    eq=sp.Matrix([1472,1908,1472,-12])/6093
    dual=sp.Matrix([34,44,34,0])/141
    observed=sp.Matrix([1,1,1,sp.Rational(143,141)])
    assert A*eq==sp.ones(4,1) and eq[-1]<0
    assert A*dual==observed and all(v>=0 for v in dual)
    assert all(v>=1 for v in observed) and sum(dual[i]*(observed[i]-1) for i in range(4))==0
    return dict(spectrum=[1,2,16,17],observed_set=H,equality_multipliers=[str(v) for v in eq],
        margin_dual=[str(v) for v in dual],margin_values=[str(v) for v in observed],
        scope='Exact rational counterexample to arbitrary-subset margin activity; not a counterexample to the prefix conjecture.')

def two_block_margin_cases():
    records=[]
    for d in range(2,7):
        for values in ([1+p*p for p in range(d+1)], [2**p for p in range(d+1)],
                       [1 if p<d else 1000 for p in range(d+1)]):
            mu=list(map(F,values));h=2**(d-1)+1;rad=radial(d,mu)
            A=sp.Matrix([[sp.Rational(rad[(i^j).bit_count()].numerator,rad[(i^j).bit_count()].denominator)
                          for j in range(h)] for i in range(h)])
            a=[(mu[p]+mu[p+1])/2 for p in range(d)]
            r=[(mu[p]-mu[p+1])/(mu[p]+mu[p+1]) for p in range(d)]
            s=[2*mu[p]*mu[p+1]/(mu[p]+mu[p+1]) for p in range(d)]
            R=radial(d-1,r);sdiag=sum(F(math.comb(d-1,p))*s[p] for p in range(d))/2**(d-1)
            z=(1-r[0])/sdiag
            lam=[1/a[0]-z*R[i.bit_count()] for i in range(h-1)]+[z]
            exact=sp.Matrix([sp.Rational(v.numerator,v.denominator) for v in lam])
            assert A*exact==sp.ones(h,1) and min(lam)>0
            assert R[0]<=0 and max(R[1:])<F(1,2) and sdiag>mu[1]/2
            records.append(dict(dimension=d,prefix=h,spectrum=values,minimum_multiplier=str(min(lam))))
    return dict(cases=records,scope='Exact rational verification of the half-cube-plus-one multiplier formula and bounds. The proof reduces dyadic and two-block prefixes to this case or a full/one-missing cube.')

def main():
    start=time.monotonic();exact=exact_cases();relu=relu_cases();tangent=tangent_cases();powers=positive_power_cases();deep=deep_relu_cases()
    report=dict(status='PASS',scope=__doc__.strip(),exact_cases=exact,relu_cases=relu,tangent_cases=tangent,positive_power_cases=powers,deep_relu_cases=deep,nonprefix_counterexample=nonprefix_counterexample(),two_block_margin_cases=two_block_margin_cases(),seconds=time.monotonic()-start)
    (ROOT/'results/degree_kernel_recursion_checks.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(status='PASS',exact_recursive_predictions=sum(r['exact_wrong_predictions'] for r in exact),
        exact_matrix_comparisons=sum(r['exact_matrix_comparisons'] for r in exact),
        high_precision_relu_predictions=sum(r['wrong_lexicographic_predictions'] for r in relu),high_precision_tangent_predictions=sum(r['wrong_lexicographic_predictions'] for r in tangent),exact_walk_cases=powers['exact_walk_cases'],exact_monomial_walsh_comparisons=powers['exact_walsh_comparisons'],deep_kernel_predictions=deep['wrong_predictions'],seconds=report['seconds'])),flush=True)
if __name__=='__main__':main()
