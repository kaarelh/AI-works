"""Exact control-dual checks using prefix-permutation symmetry.

A table indexed by prefix Hamming weight and path bit pattern represents
ALL logical Fourier coefficients. Integer Krawtchouk transforms implement
the prefix Walsh sum exactly; no sampled frequencies or floating tolerances
are used. Actual radical rail costs are enclosed by integer square roots.
"""
from fractions import Fraction as F
from pathlib import Path
import argparse,json,math,time
from check_control_margin_certificate import fwht,character
ROOT=Path(__file__).resolve().parents[1]

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--k',type=int,default=6);ap.add_argument('--bits',type=int,default=2048)
 ap.add_argument('--output',type=Path);args=ap.parse_args();k=args.k;assert k>=2
 R=64;P=4*k+3;V=2*k+1;Q=2**V;m=P+V;M=2**m;K=2**(k-1);ell=8*k+4;n0=(ell+1)*R
 unit=2**args.bits;start=time.monotonic();assert (P+1)*Q<=2**20,'Explicit memory cap for the finite checker.'
 columns=[1<<i for i in range(V)]+[(1<<j)|(1<<(j+1)) for j in range(2*k)]
 increments=[4]*V+[6 if j%2==0 else 2 for j in range(2*k)]
 path_increment=[sum(d for a,d in zip(columns,increments) if (a&s).bit_count()%2) for s in range(Q)]
 u0=sum(1<<(2*j+1) for j in range(k));basis=[(1<<(2*j))|(1<<(2*(k-1))) for j in range(k-1)]
 H=[0]
 for a in basis:H += [x^a for x in H]
 U=[u0^h for h in H];Uset=set(U);Hset=set(H)
 degrees=sorted({n0+4*j+inc for j in range(P+1) for inc in path_increment})
 cost={}
 for n in sorted(set(degrees+[n+2 for n in degrees])):
  c=math.comb(n-2,(n-2)//2);num=n<<(2*(n-1+args.bits));den=c*c;lo=math.isqrt(num//den)
  assert lo*lo*den<=num<(lo+1)**2*den;cost[n]=lo
 table=[[cost[n0+4*j+inc] for inc in path_increment] for j in range(P+1)]
 # Coefficients in (1-x)^j(1+x)^(P-j), including all multiplicities.
 kra=[[sum((-1)**l*math.comb(j,l)*math.comb(P-j,r-l)
            for l in range(max(0,r-(P-j)),min(j,r)+1)) for r in range(P+1)] for j in range(P+1)]
 def transform(t):
  result=[]
  for j in range(P+1):
   row=[sum(kra[j][r]*t[r][s] for r in range(P+1)) for s in range(Q)]
   result.append(fwht(row))
  return result
 Wtab=transform(table)
 assert all(Wtab[j][u]+M//2<0 for j in range(P+1) for u in range(Q) if j or u)
 ordered=sorted(U,key=lambda u:Wtab[P][u]);assert all(Wtab[P][b]-Wtab[P][a]>M for a,b in zip(ordered,ordered[1:]))
 hperp=[all(character(s,h)==1 for h in basis) for s in range(Q)]
 etab=[[int(hperp[s] and ((-1)**j)*character(s,u0)==-1) for s in range(Q)] for j in range(P+1)]
 es=M//(2*K)
 etrans=transform(etab)
 for j in range(P+1):
  for u in range(Q):
   assert etrans[j][u]==es*(int(j==0 and u in Hset)-int(j==P and u in Uset))
 del etrans
 W=max(F(-Wtab[P][u]+M//2,M*unit) for u in U);delta=F(K+1,M)
 gamma_upper=F(cost[n0]+cost[n0+2]+2,unit)/(1-delta);epsilon=2*K*W+gamma_upper*delta
 assert 2*K*W<F(1,8) and gamma_upper*delta<F(3,4) and epsilon<1
 assert min(cost[n+2]-cost[n]-1 for n in degrees)>2*unit
 # Compare with the uncompressed integer transform at k=2.
 full_agreement=None
 if k==2:
  full=[table[(s&((1<<P)-1)).bit_count()][s>>P] for s in range(M)]
  full_t=fwht(full)
  assert all(full_t[s]==Wtab[(s&((1<<P)-1)).bit_count()][s>>P] for s in range(M))
  full_agreement=True
 rows=[]
 for index,v in enumerate(ordered):
  live=set(ordered[index:]);removed=Uset-live;fv=Wtab[P][v]
  live_q={u:es*(Wtab[P][u]-fv) for u in live}
  q0=table[0][0]*es;wc=cost[n0+2]*es;gden=M-K-1;gnum=M*(wc+q0)-2*sum(live_q.values());assert gnum>0
  d=M*gden;live_transform=fwht([live_q.get(u,0) for u in range(Q)])
  for j in range(P+1):
   parity=(-1)**j
   for s in range(Q):
    w=table[j][s]*es;qp=w+fv*etab[j][s];assert abs(qp)<=w
    if etab[j][s]:assert abs(qp)<w
    hnum=-qp*d+2*gden*parity*live_transform[s]
    hnum+=gnum*((M if j==0 and s==0 else 0)-1-(K*parity*character(s,u0) if hperp[s] else 0))
    if j==0 and s==0:assert hnum==wc*d
    else:assert abs(hnum)<cost[n0+4*j+path_increment[s]+2]*es*d
    # Physical logical dual values in the same symmetry classes.
    inU=j==P and s in Uset;inH=j==0 and s in Hset;zero=j==0 and s==0;inL=j==P and s in live
    qv=es*(Wtab[j][s]+fv*(int(inH)-int(inU)))
    hv=-qv*gden+(2*qv*gden if inL else 0)+(gnum if not zero and not inU else 0)
    plus=qv*gden+hv;minus=qv*gden-hv;assert plus>=0
    if inL:assert minus==0
    elif zero:assert minus>0
    else:assert minus<=0
    gv=int(zero)+int(j==P and s==v)
    assert plus*gv==0
    if not inL:assert minus*(gv-1 if zero else gv)==0
  # Exact support combinatorics; prefixes are all one on U and zero at anchor.
  old_v=((1<<P)-1)|(v<<P);old_U={((1<<P)-1)|(u<<P) for u in U}
  old_L={((1<<P)-1)|(u<<P) for u in live}
  S={(0,1)}|{(u,-1) for u in old_L}|{(u,1) for u in old_U-old_L}|{(old_v,1)}
  old_columns=[1<<j for j in range(P)]+[a<<P for a in columns]
  assert all(not(S & {(z^a,t) for z,t in S}) for a in old_columns)
  assert {z for z,t in S if (z,-t) in S}=={old_v}
  rows.append(dict(stage=index,current=old_v,remaining=len(live)))
  print(json.dumps(dict(k=k,stage=index,remaining=len(live),seconds=time.monotonic()-start)),flush=True)
 out=dict(status='PASS',k=k,logical_dimension=m,physical_dimension=ell*(2*R+4)+2*R+2,
     total_logical_frequencies=M,exact_symmetry_classes=(P+1)*Q,live_count=K,stages=rows,interval_bits=args.bits,
     full_transform_agreement_at_k2=full_agreement,twice_KW_upper=str(2*K*W),
     gamma_delta_upper=str(gamma_upper*delta),mixed_perturbation_upper=str(epsilon),seconds=time.monotonic()-start,
     scope='Exact integer Krawtchouk/Walsh symmetry compression covers all logical frequencies. Radical costs have integer-square-root enclosures; full dual and complementarity are checked on exact enclosed dyadic costs. This is a finite check of the analytic construction, not a formalization of the neural atom theorem or Gaussian limit.')
 path=args.output or ROOT/'results'/f'control_margin_compressed_k{k}.json';path.write_text(json.dumps(out,indent=2)+'\n')
 print(json.dumps({key:value for key,value in out.items() if key not in ['stages','twice_KW_upper','gamma_delta_upper','mixed_perturbation_upper']},indent=2))
if __name__=='__main__':main()
