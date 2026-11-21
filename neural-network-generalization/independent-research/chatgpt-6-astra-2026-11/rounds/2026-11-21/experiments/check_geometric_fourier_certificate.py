"""Exact integer dual certificates for the signed Fourier completion theorem.

All lambda coefficients are represented with common denominator 2**q.
This checks the inductive construction, not the neural atomic norm.
"""
import argparse,json,random,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def fwht(a):
    a=list(a);h=1
    while h<len(a):
        for i in range(0,len(a),2*h):
            for j in range(i,i+h):
                x,y=a[j],a[j+h];a[j],a[j+h]=x+y,x-y
        h*=2
    return a

def reverse(v,q):return int(f'{v:0{q}b}'[::-1],2) if q else 0

def dual(c,v):
    n=len(c)+1
    if n==1:return [0]
    assert all(x>0 for x in c) and all(2*y<=x for x,y in zip(c,c[1:]))
    half=n//2;vp=v>>1
    if v&1:
        d=[c[2*s-1]-c[2*s] for s in range(1,half)]
        lower=dual(d,vp);kernel=fwht(c[::2])
        assert min(kernel)>=0
        return [x for i in range(half) for x in (2*kernel[i]+lower[i],lower[i])]
    d=[c[2*s] if (s&vp).bit_count()%2==0 else c[2*s-1] for s in range(1,half)]
    lower=dual(d,vp)
    assert sum(lower)<=half*sum(d)
    assert sum(lower)<half*c[0]
    return [x for a in lower for x in (2*a,0)]

def verify(c,v):
    n=len(c)+1;q=n.bit_length()-1;lam=dual(c,v)
    assert min(lam)>=0
    step=reverse(v,q)
    assert all(a==0 or reverse(u,q)<step for u,a in enumerate(lam))
    assert sum(lam)<=n*sum(c)
    h=fwht(lam);residual=[n*c[s-1]-h[s] for s in range(1,n)]
    assert all(a*((-1)**((s&v).bit_count()))>=0 for s,a in enumerate(residual,1))
    primal=sum(c[s-1]*((-1)**((s&v).bit_count())) for s in range(1,n))
    dual_value=sum(abs(a) for a in residual)-h[0]
    assert dual_value==n*primal
    return dict(q=q,step=step,nonzero_dual=sum(a>0 for a in lam),minimum_outward_residual=min((a*((-1)**((s&v).bit_count())) for s,a in enumerate(residual,1)),default=0))

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--all-through',type=int,default=9);ap.add_argument('--large-q',type=int,default=14)
    ap.add_argument('--large-cases',type=int,default=20);args=ap.parse_args()
    rng=random.Random(2026112242);start=time.monotonic();rows=[]
    for q in range(1,args.all_through+1):
        n=2**q
        for base in [2,4]:
            c=[base**(n-1-s) for s in range(1,n)]
            for v in range(n):rows.append(verify(c,v))
        print(json.dumps(dict(q=q,cases=len(rows),seconds=time.monotonic()-start)),flush=True)
    for q in sorted(set([args.all_through+2,args.large_q])):
        n=2**q
        # Random unequal successive ratios also satisfy the theorem's hypothesis.
        for case in range(args.large_cases):
            c=[1]
            for s in range(n-2):c.append(c[-1]*rng.choice([2,2,3,4]))
            c.reverse();v=rng.randrange(n);rows.append(verify(c,v))
        print(json.dumps(dict(q=q,cases=len(rows),seconds=time.monotonic()-start)),flush=True)
    out=dict(status='PASS',cases=len(rows),all_vertices_through_dimension=args.all_through,largest_dimension=max(r['q'] for r in rows),
             geometric_bases=[2,4],additional_coefficients='independent adjacent integer ratios in {2,3,4}',seconds=time.monotonic()-start,
             scope='Exact integer primal/dual identities for the explicit recursive certificate; no neural realization or asymptotic sampling claim.')
    (ROOT/'results/geometric_fourier_certificate_checks.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out,indent=2))
if __name__=='__main__':main()
