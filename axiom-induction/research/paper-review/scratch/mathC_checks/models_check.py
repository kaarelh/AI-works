# Independent brute-force check of the counter-models of Prop pa:redundant (X11) and Prop exp:comm(b) (X12).
import itertools
N=12
def checkQ(dom, S, add, mul, zero=0):
    Q={}
    Q[1]=all(S(x)!=zero for x in dom)
    Q[2]=all((S(x)!=S(y)) or x==y for x in dom for y in dom)
    Q[3]=all(x==zero or any(x==S(y) for y in dom) for x in dom)
    Q[4]=all(add(x,zero)==x for x in dom)
    Q[5]=all(add(x,S(y))==S(add(x,y)) for x in dom for y in dom)
    Q[6]=all(mul(x,zero)==zero for x in dom)
    Q[7]=all(mul(x,S(y))==add(mul(x,y),x) for x in dom for y in dom)
    return Q
# finite truncations of N: restrict quantifiers to x,y < N/2 so that values stay below N
half=range(N//2)
models={
 1:(range(1),lambda x:0,lambda x,y:0,lambda x,y:0),
 2:(range(2),lambda x:1,lambda x,y:x if y==0 else 1,lambda x,y:0 if y==0 else x),
 4:(half,lambda x:x+1,lambda x,y:x+y+1,lambda x,y:y*(x+1)),
 5:(half,lambda x:x+1,lambda x,y:x,lambda x,y:0),
 6:(half,lambda x:x+1,lambda x,y:x+y,lambda x,y:x*y+1),
 7:(half,lambda x:x+1,lambda x,y:x+y,lambda x,y:0),
}
for i,(dom,S,a,m) in models.items():
    Q=checkQ(list(dom),S,a,m)
    # for the infinite models Q3 'exists y' needs y in dom: x-1 in dom whenever x>0
    print("X11 model falsifying Q%d:"%i, {k:v for k,v in Q.items()}, " as claimed:", (not Q[i]) and all(v for k,v in Q.items() if k not in (i,)))
# X12 model: N u {A,B}
A,B='A','B'
def S(x): return x if x in (A,B) else x+1
def add(x,y):
    if x in (A,B) and y in (A,B): return x  # A+A=A, B+B=B, A+B=A, B+A=B
    if x in (A,B): return x
    if y in (A,B): return y
    return x+y
def mul(x,y):
    if x in (A,B) and y in (A,B): return x
    if x in (A,B): return x if y!=0 else 0
    if y in (A,B): return y if x!=0 else 0
    return x*y
dom=list(range(8))+[A,B]
# closure of N u {a} under S,+,* and commutativity of + there
for a in (A,B):
    sub=list(range(8))+[a]
    print("N u {%s}: + commutative:"%a, all(add(x,y)==add(y,x) for x in sub for y in sub), "; closed:", all(v in sub or (isinstance(v,int)) for x in sub for y in sub for v in (add(x,y),mul(x,y),S(x))))
print("A+B =",add(A,B)," B+A =",add(B,A)," so forall x forall y x+y=y+x fails")
# one-parameter instances f(w)+g(w)=g(w)+f(w): enumerate terms in w of depth<=2
terms=['w','0']
def ev(t,w):
    if t=='w': return w
    if t=='0': return 0
    op,l,r=t
    if op=='S': return S(ev(l,w))
    if op=='+': return add(ev(l,w),ev(r,w))
    if op=='*': return mul(ev(l,w),ev(r,w))
T=['w','0']
for _ in range(2):
    T=T+[('S',t,None) for t in T]+[(o,l,r) for o in '+*' for l in T for r in T]
    T=list({repr(t):t for t in T}.values())[:400]
ok=all(add(ev(f,w),ev(g,w))==add(ev(g,w),ev(f,w)) for f in T[:120] for g in T[:120] for w in [0,1,2,A,B])
print("S_ab^open one-parameter instances hold on", min(len(T),120)**2, "pairs:", ok)
print("M_x closed instances forall x (x+n=n+x) hold at x in {A,B}:", all(add(x,n)==add(n,x) for x in (A,B) for n in range(6)))
