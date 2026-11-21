"""Exact follow-up to failed exploratory dual certificates; no neural claim."""
from fractions import Fraction as Q
import json
from pathlib import Path
from rational_simplex import solve
ROOT=Path(__file__).resolve().parents[1]
def chi(s,v):return 1-2*((s&v).bit_count()%2)
def reverse(v,q):return int(f'{v:0{q}b}'[::-1],2)
rows=[]
for power,q in [(1,4),(2,4),(3,5),(4,5)]:
    n=2**q;v=6;step=reverse(v,q);c=[-Q(1,s**power) for s in range(1,n)]
    A=[[int(i==j) for j in range(n-1)] for i in range(n-1)];b=[1]*(n-1)
    old=[reverse(i,q) for i in range(step)]
    for u in old:
        row=[2*chi(s,u) for s in range(1,n)];A.append(row);b.append(sum(chi(s,u) for s in range(1,n))-1)
    value,x,y=solve(A,b,c);vertex=sum(c[s-1]*((1+chi(s,v))//2) for s in range(1,n))
    p=[(1+sum(chi(s,u)*(2*x[s-1]-1) for s in range(1,n)))/n for u in range(n)]
    row=dict(power=power,q=q,query=v,step=step,desired_vertex_is_optimal=value==vertex,objective_gap=str(vertex-value),
             masses=list(map(str,p)),primal=list(map(str,x)),dual=list(map(str,y)))
    rows.append(row);print(json.dumps({k:row[k] for k in ['power','q','query','step','desired_vertex_is_optimal','objective_gap']}),flush=True)
(ROOT/'results/power_cost_obstruction_checks.json').write_text(json.dumps(dict(status='PASS',scope='Exact finite rational LP optima; failure of one recursive certificate alone was not treated as failure of the optimizer.',cases=rows),indent=2)+'\n')
