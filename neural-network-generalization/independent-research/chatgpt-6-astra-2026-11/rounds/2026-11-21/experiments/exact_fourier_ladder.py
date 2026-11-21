"""Exact rational primal/dual checks for a reduced Fourier-cube ladder.

This is NOT a certificate for the neural atomic norm. The physical
realization of the dense Fourier objective remains open.
"""
import argparse,json,time
from pathlib import Path
from fractions import Fraction
from rational_simplex import solve,InfeasibleLPError

ROOT=Path(__file__).resolve().parents[1]
def character(s,v):return (-1)**((s&v).bit_count())
def reverse(v,q):return int(f'{v:0{q}b}'[::-1],2)

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--max-q',type=int,default=6)
    ap.add_argument('--base',type=int,default=4);ap.add_argument('--hours',type=float,default=4.)
    ap.add_argument('--output',type=Path,required=True);args=ap.parse_args()
    start=time.monotonic();args.output.parent.mkdir(parents=True,exist_ok=True)
    with args.output.open('w',buffering=1) as stream:
        for q in range(1,args.max_q+1):
            n=2**q;variables=n-1;c=[-args.base**(n-1-s) for s in range(1,n)]
            A=[[int(i==j) for j in range(variables)] for i in range(variables)];b=[1]*variables
            for step in range(n-1):
                if time.monotonic()-start>args.hours*3600:return
                query=reverse(step,q);u=[(1+character(s,query))//2 for s in range(1,n)]
                expected=sum(a*z for a,z in zip(c,u));begin=time.monotonic()
                value,x,y=solve(A,b,c)
                assert value<=expected
                row=dict(q=q,base=args.base,step=step,query=query,seconds=time.monotonic()-begin,
                         desired_vertex_is_optimal=value==expected,objective=str(value),vertex_objective=str(expected),
                         primal=list(map(str,x)),dual=list(map(str,y)))
                if value!=expected:
                    stream.write(json.dumps(row)+'\n');print(json.dumps({k:row[k] for k in ['q','step','query','desired_vertex_is_optimal','seconds']}),flush=True);break
                queryrow=[2*character(s,query) for s in range(1,n)]
                rhs=sum(character(s,query) for s in range(1,n))-1
                try:
                    correct,xc,yc=solve(A+[queryrow],b+[rhs+Fraction(n,2)],c)
                    row.update(correct_sign_gap=str(correct-value),correct_primal=list(map(str,xc)),correct_dual=list(map(str,yc)))
                    assert correct>value
                except InfeasibleLPError:
                    # Before the last vertex, mixing the query and one unseen
                    # point is a feasible correct-sign completion. Reject any
                    # solver claim inconsistent with this explicit witness.
                    raise AssertionError('Unexpected infeasibility before the last vertex')
                stream.write(json.dumps(row)+'\n')
                print(json.dumps({k:row.get(k) for k in ['q','step','query','correct_sign_gap','seconds']}),flush=True)
                A.append(queryrow);b.append(rhs)
if __name__=='__main__':main()
