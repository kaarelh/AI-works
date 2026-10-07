# Sanity check of the standard model showing Q + "exists x (Sx = x)" is consistent:
# domain N ∪ {w}; S(w)=w; n+w=w+n=w+w=w; 0*w=0, n*w=w (n>0), w*0=0, w*n=w (n>0), w*w=w.
# Check Q1..Q7 on all x,y in {0..N} ∪ {w} (for standard x,y they are true arithmetic facts).
W='w'; N=40
def S(x): return W if x==W else x+1
def add(x,y):
    if x==W or y==W: return W
    return x+y
def mul(x,y):
    if y==0 or x==0: return 0
    if x==W or y==W: return W
    return x*y
D=list(range(N))+[W]
ok=True
for x in D:
    ok&= S(x)!=0                                   # Q1
    ok&= (x==0) or any(S(y)==x for y in D)          # Q3 (predecessor exists in D; for standard x<N fine)
    ok&= add(x,0)==x                                # Q4
    ok&= mul(x,0)==0                                # Q6
    for y in D:
        ok&= (S(x)!=S(y)) or x==y                   # Q2
        ok&= add(x,S(y))==S(add(x,y))               # Q5
        ok&= mul(x,S(y))==add(mul(x,y),x)           # Q7
print('Q1-Q7 hold on sample:',ok, '; witness S(w)==w:',S(W)==W)
# Euler: n^2+n+41
def prime(k): return k>1 and all(k%d for d in range(2,int(k**0.5)+1))
print('least n with n^2+n+41 composite:', next(n for n in range(100) if not prime(n*n+n+41)), 40*40+40+41, 41*41)
