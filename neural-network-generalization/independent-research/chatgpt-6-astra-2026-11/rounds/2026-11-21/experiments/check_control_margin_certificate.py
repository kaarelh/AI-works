"""Integer and enclosing-interval checks of the observed-margin control dual.

The rail costs a(n)=2**(n-1)*sqrt(n)/binomial(n-2,(n-2)/2) are enclosed
using integer square roots, not floating tolerances. The full dual is also
checked exactly for dyadic costs within those enclosures. The analytic
rail atom inequality and the all-dimension theorem remain conventional
inputs; this finite check does not enumerate physical neural chambers.
"""
from fractions import Fraction as F
from pathlib import Path
import argparse,json,math,time
ROOT=Path(__file__).resolve().parents[1]
def fwht(a):
 a=list(a);h=1
 while h<len(a):
  for i in range(0,len(a),2*h):
   for j in range(i,i+h):x,y=a[j],a[j+h];a[j],a[j+h]=x+y,x-y
  h*=2
 return a

def character(s,z):return 1 if (s&z).bit_count()%2==0 else -1

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--k',type=int,default=2);ap.add_argument('--bits',type=int,default=512);args=ap.parse_args()
 k=args.k;assert k>=2;R=64;m=6*k+4;ell=8*k+4;P=4*k+3;M=2**m;K=2**(k-1);n0=(ell+1)*R;unit=2**args.bits;start=time.monotonic()
 assert M<=2**18,'Default finite checker intentionally caps full exact Walsh enumeration.'
 columns=[1<<i for i in range(m)];increments=[4]*m
 for j in range(2*k):columns.append((1<<(P+j))|(1<<(P+j+1)));increments.append(6 if j%2==0 else 2)
 v0=(1<<P)-1
 for j in range(k):v0|=1<<(P+2*j+1)
 basis=[(1<<(P+2*j))|(1<<(P+2*(k-1))) for j in range(k-1)]
 H=[0]
 for a in basis:H += [v^a for v in H]
 U=[v0^h for h in H];assert len(U)==K and 0 not in U
 assert all(not (set(U+[0]) & {u^a for u in U+[0]}) for a in columns)
 def hperp(s):return all(character(s,h)==1 for h in basis)
 E=[s for s in range(M) if hperp(s) and character(s,v0)==-1];Eset=set(E);assert len(E)==M//(2*K)
 degrees=[n0+sum(delta for a,delta in zip(columns,increments) if (a&s).bit_count()%2) for s in range(M)]
 unique=sorted(set(degrees+[n+2 for n in degrees]));cost={}
 for n in unique:
  c=math.comb(n-2,(n-2)//2);den=c*c;numerator=n<<(2*(n-1+args.bits));lo=math.isqrt(numerator//den)
  assert lo*lo*den<=numerator<(lo+1)**2*den;cost[n]=lo
 w=[cost[n] for n in degrees];wp=[cost[n+2] for n in degrees];transform=fwht(w)
 assert all(transform[s]+M//2<0 for s in range(1,M)), 'The actual nonconstant cost coefficients must be negative.'
 ordered=sorted(U,key=lambda u:transform[u]);assert all(transform[b]-transform[a]>M for a,b in zip(ordered,ordered[1:]))
 W=max(F(-transform[u]+M//2,M*unit) for u in U);delta=F(K+1,M)
 gamma_upper=F(cost[n0]+cost[n0+2]+2,unit)/(1-delta)
 epsilon=2*K*W+gamma_upper*delta
 assert 2*K*W<F(1,8) and gamma_upper*delta<F(3,4) and epsilon<1
 gap=min(F(cost[n+2]-cost[n]-1,unit) for n in set(degrees));assert gap>2
 rows=[];es=len(E);Hset=set(H);Uset=set(U)
 for index,v in enumerate(ordered):
  live=set(ordered[index:]);removed=Uset-live
  qhat=[x*es+(transform[v] if s in Eset else 0) for s,x in enumerate(w)]
  qval=[es*(transform[z]+transform[v]*((z in Hset)-(z in Uset))) for z in range(M)]
  assert fwht(qhat)==qval
  assert all(abs(qhat[s])<=w[s]*es for s in range(M))
  assert all(abs(qhat[s])<w[s]*es for s in E)
  wc=cost[n0+2]*es;gden=M-K-1;gnum=M*(wc+qhat[0])-2*sum(qval[u] for u in live);assert gnum>0
  D=M*gden;max_ratio=F(0)
  for s in range(M):
   hnum=-qhat[s]*D+2*gden*sum(qval[u]*character(s,u) for u in live)
   hnum+=gnum*((M if s==0 else 0)-1-(K*character(s,v0) if hperp(s) else 0))
   if s==0:assert hnum==wc*D
   else:
    assert abs(hnum)<wp[s]*es*D
    max_ratio=max(max_ratio,F(abs(hnum),wp[s]*es*D))
  for z in range(M):
   hv=-qval[z]*gden+(2*qval[z]*gden if z in live else 0)+(gnum if z!=0 and z not in Uset else 0)
   plus=qval[z]*gden+hv;minus=qval[z]*gden-hv
   assert plus>=0
   if z in live:assert minus==0
   elif z==0:assert minus>0
   else:assert minus<=0
   gv=int(z==0)+int(z==v)
   assert plus*gv==0 # plus score has margin 1/2+g; complementarity
   if z not in live:assert minus*((gv-F(1,2))-(F(1,2) if z==0 else -F(1,2)))==0
  assert sum(qhat[s]*(1+character(s,v)) for s in range(M))==sum(w[s]*es*(1+character(s,v)) for s in range(M))
  S={(0,1)}|{(u,-1) for u in live}|{(u,1) for u in removed}|{(v,1)}
  assert all(not(S & {(z^a,t) for z,t in S}) for a in columns)
  assert {z for z,t in S if (z,-t) in S}=={v}
  assert all(character(s,v)==-1 for s in E)
  rows.append(dict(stage=index,current=v,remaining=len(live),strict_mixed_dual_ratio_upper=str(max_ratio)))
 result=dict(status='PASS',k=k,logical_dimension=m,physical_dimension=ell*(2*R+4)+2*R+2,walsh_coefficients=M,
      live_count=K,interval_bits=args.bits,all_nonconstant_costs_negative=True,ordered_live_vertices=ordered,
      cost_gap_lower=str(gap),twice_KW_upper=str(2*K*W),gamma_delta_upper=str(gamma_upper*delta),
      mixed_perturbation_upper=str(epsilon),stages=rows,seconds=time.monotonic()-start,
      scope='Exact integer-square-root enclosures of the actual rail weights, and exact rational full dual/complementarity checks for enclosed dyadic costs. The full ReLU atom theorem and the general conditional-orthogonality argument are analytic inputs, not established by this checker.')
 (ROOT/'results/control_margin_certificate_checks.json').write_text(json.dumps(result,indent=2)+'\n')
 print(json.dumps({key:value for key,value in result.items() if key not in ['cost_gap_lower','twice_KW_upper','gamma_delta_upper','mixed_perturbation_upper','stages']},indent=2))
if __name__=='__main__':main()
