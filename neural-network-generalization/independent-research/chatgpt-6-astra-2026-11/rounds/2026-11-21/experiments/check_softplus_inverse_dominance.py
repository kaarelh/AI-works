"""Positive Fourier quadrature for the softplus inverse-parity mechanism.

Generalized Gauss-Laguerre quadrature removes the small scale and high-degree
powers before integration. Two meshes and the existing independent positive
quadrature cross-check the values. These are non-interval numerical checks.
The rational teacher's ReLU interpolation identity is checked exactly.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import json,math,time
from pathlib import Path
import mpmath as mp
import numpy as np
from scipy.special import roots_genlaguerre,roots_legendre,roots_hermitenorm,gammaln,logsumexp
from check_smoothing_degree_order import eigenvalues
from check_smoothing_moment_order import log_multiplier
ROOT=Path(__file__).resolve().parents[1]
mp.mp.dps=80

def log_L(d,beta,n):
    q=d+1;answer=[]
    for j in range(1,q//2+1):
        x,w=roots_genlaguerre(n,2*j-2);w=w/float(mp.gamma(2*j-1))
        u=beta*beta*x[:,None]*x[None,:]/math.pi**2
        logcosh=u+np.log1p(np.exp(-2*u))-math.log(2)
        logsinhc=u+np.log(-np.expm1(-2*u))-math.log(2)-np.log(u)
        kernel=-q*beta*beta*(x[:,None]**2+x[None,:]**2)/(2*math.pi**2)
        kernel+=2*j*logsinhc+(q-2*j)*logcosh
        denominator=np.log(x)-np.log(-np.expm1(-2*x))
        kernel+=denominator[:,None]+denominator[None,:]
        value=float(np.sum(w[:,None]*w[None,:]*np.exp(kernel)))
        answer.append(math.log(4)+(4*j-2)*math.log(beta)-4*j*math.log(math.pi)+2*gammaln(2*j-1)+math.log(value))
    return np.array(answer)

def inspect(d,beta):
    low=log_L(d,beta,128);high=log_L(d,beta,256)
    mesh=float(np.max(np.abs(np.expm1(high-low))));assert mesh<2e-7,(d,beta,mesh)
    loglam=[2*math.log(math.log(2)/beta),float(np.logaddexp(math.log(.25),high[0]))]
    loglam += [float(high[(p+1)//2-1]) for p in range(2,d+1)]
    delta=float(math.exp(logsumexp([math.log(math.comb(d,p))+loglam[d]-loglam[p] for p in range(d)])))
    eps=math.exp(1/math.pi**2)*d**4*beta**4/math.pi**4
    ratios=np.exp(np.diff(high))
    assert np.all(ratios<=eps*(1+1e-6)) and delta<.25
    cross=None
    if d<=15 and beta>1e-3:
        other=eigenvalues(d,768,[beta])[0]['eigenvalues']
        cross=max(abs(math.expm1(math.log(other[p-1])-loglam[p])) for p in range(1,d+1))
        assert cross<2e-6,(d,beta,cross)
    return dict(dimension=d,beta=beta,log_L=high.tolist(),adjacent_ratio_upper=eps,
        largest_adjacent_ratio=float(ratios.max()),inverse_other_to_parity_upper=delta,
        precision_min_to_max_lower=(1-delta)/(1+delta),mesh_relative_difference=mesh,
        independent_quadrature_relative_difference=cross,
        scope='Non-interval quadrature. Degree-zero uses its analytic lower bound, so the computed inverse remainder is an upper bound conditional on these quadrature values.')

def teacher(d):
    A=32*d;mins=mp.inf
    for j in range(d+1):
        s=-d+2*j;target=(-1)**(d-j)
        value=-1+max(s+d,0)+2*sum((-1)**k*max(s+d-2*k,0) for k in range(1,d))
        assert value==target
        soft=lambda x:max(x,0)+mp.log1p(mp.exp(-abs(x)))
        value=-mp.mpf(3)/2*mp.log(2)+soft(A*(s+d))/A
        value+=2*sum((-1)**k*soft(A*(s+d-2*k))/A for k in range(1,d))
        mins=min(mins,target*value)
    assert mins>mp.mpf('.9')
    return dict(dimension=d,exact_hinge_interpolation=True,softplus_minimum_signed_score=str(mins),width=d+1)

def relu_precision(d):
    q=mp.mpf(d+1)
    k=[(mp.sqrt(q*q-(q-2*h)**2)+(q-2*h)*(mp.pi-mp.acos((q-2*h)/q)))/(2*mp.pi) for h in range(d+1)]
    lam=[sum((-1)**j*math.comb(p,j)*math.comb(d-p,h)*k[j+h]
        for j in range(p+1) for h in range(d-p+1))/2**d for p in range(d+1)]
    # Common positive scale omitted: only precision signs matter here.
    Q=[(-1)**h*sum(sum((-1)**j*math.comb(h,j)*math.comb(d-h,p-j)
        for j in range(max(0,p-(d-h)),min(p,h)+1))/lam[p] for p in range(d+1))/2**d
        for h in range(d+1)]
    if d==5:assert Q[3]<-1
    return dict(dimension=d,scaled_radial_precision=[str(x) for x in Q],
        scope='80-digit evaluation of exact arc-cosine eigenvalue formulas, not an interval certificate.')


def log_tanh_J(d,b,n):
    q=d+1;answer=[]
    for j in range(d//2+1):
        x,w=roots_genlaguerre(n,2*j);w=w/float(mp.gamma(2*j+1))
        u=b*b*x[:,None]*x[None,:]/math.pi**2
        logcosh=u+np.log1p(np.exp(-2*u))-math.log(2)
        logsinhc=u+np.log(-np.expm1(-2*u))-math.log(2)-np.log(u)
        kernel=-q*b*b*(x[:,None]**2+x[None,:]**2)/(2*math.pi**2)
        kernel+=(2*j+1)*logsinhc+(q-2*j-1)*logcosh
        denominator=np.log(x)-np.log(-np.expm1(-2*x));kernel+=denominator[:,None]+denominator[None,:]
        value=float(np.sum(w[:,None]*w[None,:]*np.exp(kernel)))
        answer.append(math.log(16)+(4*j+2)*math.log(b)-(4*j+4)*math.log(math.pi)+2*gammaln(2*j+1)+math.log(value))
    return np.array(answer)

def direct_tanh_J(d,b,n):
    z,w=roots_legendre(n);z=(z+1)/2;w=w/2
    y=z/(1-z);wy=w/(1-z)**2;v=z*9/math.sqrt(d+1);wv=w*9/math.sqrt(d+1)
    u=v[:,None]+y[None,:];delta=u*u-v[:,None]**2
    em=np.exp(-delta);sm=-np.expm1(-delta)
    t=(u+v[:,None])/math.sqrt(2);ss=(u-v[:,None])/math.sqrt(2)
    base=np.exp(-(d+1)*v[:,None]**2)*(sm/delta)*wv[:,None]*wy[None,:]
    base*=np.exp(log_multiplier(t,b)+log_multiplier(ss,b))
    return np.array([float(np.sum(base*sm**(2*j)*(1+em)**(d-2*j)))*2.**(3-d)/math.pi**2 for j in range(d//2+1)])

def tanh_inspect(d,b):
    low=log_tanh_J(d,b,128);high=log_tanh_J(d,b,256)
    mesh=float(np.max(np.abs(np.expm1(high-low))));assert mesh<2e-7,(d,b,mesh)
    loglam=[high[p//2] for p in range(d+1)]
    delta=float(math.exp(logsumexp([math.log(math.comb(d,p))+loglam[d]-loglam[p] for p in range(d)])))
    eps=math.exp(1/math.pi**2)*(d+1)**4*b**4/math.pi**4
    ratios=np.exp(np.diff(high));assert np.all(ratios<=eps*(1+1e-6)) and delta<.25
    cross=None
    if d<=14:
        direct=direct_tanh_J(d,b,768);cross=float(np.max(np.abs(np.expm1(np.log(direct)-high))))
        assert cross<2e-6,(d,b,'tanh direct quadrature',cross)
    z,w=roots_hermitenorm(256);trace=float(np.dot(w,np.tanh((b/2)*math.sqrt(d+1)*z)**2)/math.sqrt(2*math.pi))
    spectral_trace=sum(math.comb(d,p)*math.exp(loglam[p]) for p in range(d+1))
    trace_error=abs(spectral_trace/trace-1);assert trace_error<2e-7,(d,b,'trace',trace_error)
    return dict(dimension=d,raw_sigma=b/2,logistic_multiplier_scale=b,log_J=high.tolist(),
        inverse_other_to_parity_upper=delta,adjacent_ratio_upper=eps,
        largest_adjacent_ratio=float(ratios.max()),mesh_relative_difference=mesh,
        independent_quadrature_relative_difference=cross,one_dimensional_trace_relative_difference=trace_error,
        scope='Two non-interval positive generalized Gauss-Laguerre meshes; the analytic proof supplies the all-dimensional bound.')

def tanh_teacher(d):
    mins=mp.inf
    for k in range(d+1):
        s=-d+2*k;target=(-1)**(d-k)
        sign=lambda z:1 if z>0 else -1
        exact=1+sum((-1)**j*sign(s-(-d+2*j-1)) for j in range(1,d+1))
        assert exact==target
        value=mp.tanh(2*d)+sum((-1)**j*mp.tanh(2*d*(s-(-d+2*j-1))) for j in range(1,d+1))
        mins=min(mins,target*value)
    assert mins>mp.mpf('.9')
    return dict(dimension=d,exact_sign_interpolation=True,tanh_minimum_signed_score=str(mins),width=d+1)

def main():
    start=time.monotonic();rows=[]
    for d in [3,5,7,11,15,23,31,51,101]:
        for multiplier in [1.,.125]:
            row=inspect(d,multiplier/(d+1)**1.5);rows.append(row)
            print(json.dumps({k:row[k] for k in ['dimension','beta','inverse_other_to_parity_upper','mesh_relative_difference']}),flush=True)
    teachers=[teacher(d) for d in [3,5,7,11,21,51,101]]
    tanh_rows=[tanh_inspect(d,multiplier/(d+1)**1.5) for d in [2,4,6,10,14,22,30,50,100] for multiplier in [1.,.25]]
    tanh_teachers=[tanh_teacher(d) for d in [2,4,6,10,20,50,100]]
    report=dict(status='PASS',scope=__doc__.strip(),spectral_cases=rows,teacher_cases=teachers,tanh_spectral_cases=tanh_rows,tanh_teacher_cases=tanh_teachers,
        relu_precision=[relu_precision(d) for d in [3,5,7]],seconds=time.monotonic()-start)
    (ROOT/'results/softplus_inverse_dominance_checks.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(status='PASS',spectral_cases=len(rows),teacher_cases=len(teachers),tanh_spectral_cases=len(tanh_rows),tanh_teacher_cases=len(tanh_teachers),seconds=report['seconds'])))
if __name__=='__main__':main()
