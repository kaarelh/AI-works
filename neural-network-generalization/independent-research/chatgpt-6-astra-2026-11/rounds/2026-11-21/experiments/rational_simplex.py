"""Small exact two-phase simplex; every returned solution is independently checked.

min c.x subject to A.x<=b and x>=0. Bland's entering/leaving rules.
For research certificates only; not a general production LP library.
"""
from fractions import Fraction as F

class InfeasibleLPError(Exception):pass
class UnboundedLPError(Exception):pass

def solve(A,b,c):
    m=len(b);n=len(c);negative=[i for i,v in enumerate(b) if v<0]
    total=n+m+len(negative);art={i:n+m+k for k,i in enumerate(negative)}
    rows=[];rhs=[];basis=[]
    for i in range(m):
        sign=1 if b[i]>=0 else -1
        row=[F(sign*v) for v in A[i]]+[F(0)]*(total-n)
        row[n+i]=F(sign)
        if sign<0:row[art[i]]=F(1);basis.append(art[i])
        else:basis.append(n+i)
        rows.append(row);rhs.append(F(sign*b[i]))

    def pivot(leaving,entering):
        p=rows[leaving][entering];rows[leaving]=[v/p for v in rows[leaving]];rhs[leaving]/=p
        pr=rows[leaving];pb=rhs[leaving]
        for i in range(len(rows)):
            if i==leaving:continue
            a=rows[i][entering]
            if a:
                rows[i]=[v-a*u for v,u in zip(rows[i],pr)];rhs[i]-=a*pb
        basis[leaving]=entering

    def optimize(cost):
        rc=list(map(F,cost));value=F(0)
        for i,j in enumerate(basis):
            cb=cost[j]
            if cb:rc=[v-cb*u for v,u in zip(rc,rows[i])];value+=cb*rhs[i]
        iterations=0
        while True:
            entering=next((j for j,v in enumerate(rc) if v<0),None)
            if entering is None:return value,rc,iterations
            candidates=[(rhs[i]/row[entering],basis[i],i) for i,row in enumerate(rows) if row[entering]>0]
            if not candidates:raise UnboundedLPError()
            leaving=min(candidates)[2];old=rc[entering]
            pivot(leaving,entering)
            rc=[v-old*u for v,u in zip(rc,rows[leaving])];value+=old*rhs[leaving]
            iterations+=1
            assert all(v>=0 for v in rhs)

    phaseone=[F(int(j>=n+m)) for j in range(total)]
    value,_,_=optimize(phaseone)
    if value>0:raise InfeasibleLPError()
    assert value==0
    for i in reversed(range(len(rows))):
        if basis[i]>=n+m:
            entering=next((j for j in range(n+m) if rows[i][j]),None)
            if entering is None:del rows[i];del rhs[i];del basis[i]
            else:pivot(i,entering)
    rows[:]=[row[:n+m] for row in rows]
    value,rc,_=optimize(list(map(F,c))+[F(0)]*m)
    x=[F(0)]*n
    for i,j in enumerate(basis):
        if j<n:x[j]=rhs[i]
    y=rc[n:n+m]
    assert all(v>=0 for v in x) and all(v>=0 for v in y)
    assert all(sum(a*z for a,z in zip(row,x))<=v for row,v in zip(A,b))
    assert all(c[j]+sum(A[i][j]*y[i] for i in range(m))>=0 for j in range(n))
    assert value==sum(a*z for a,z in zip(c,x))==-sum(a*z for a,z in zip(b,y))
    return value,x,y
