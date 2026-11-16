# Attack on Propositions 4.2, 4.3 and Remark 4.5 of one-mind.md (trap scaffold).
import random, math
rng=random.Random(11)
def run(N,L,answer):
    # answer(x) -> 0/1 ; returns list of inputs and answers
    s=0; xs=[]; ys=[]
    for j in range(L):
        a=rng.randint(1,N); x=(a,s); y=answer(x); xs.append(x); ys.append(y)
        if s==0 and y==1: s=a
    return xs,ys
def g(a): return lambda x: 1 if ((x[1]==0 and x[0]==a) or (a!=0 and x[1]==a)) else 0
# --- Prop 4.2 (a),(b): class A, fixed surviving set U of size k, human g_0
N,L,k=10,6,4; U=list(range(1,k+1)); reps=200000
post=[(0,N/(N+k))]+[(a,1/(N+k)) for a in U]
def draw():
    r=rng.random(); c=0
    for a,p in post:
        c+=p
        if r<c: return a
    return post[-1][0]
cnt_pd=[0]*(L+2); cnt_mx=[0]*(L+2)
for _ in range(reps):
    h=g(draw()); xs,ys=run(N,L,h); C=sum(ys)        # human answers 0 everywhere
    cnt_pd[C]+=1
    xs,ys=run(N,L,lambda x: g(draw())(x)); C=sum(ys); cnt_mx[C]+=1
print("class A, N=%d L=%d k=%d, %d runs each"%(N,L,k,reps))
print(" c   Pr[C>=c] draw (MC)  formula      Pr[C>=c] mixture (MC)  bound C(L,c)/N^c")
for c in range(1,L+1):
    mc=sum(cnt_pd[c:])/reps; fo=(k/(N+k))*(1-(1-1/N)**(L-c+1))
    mm=sum(cnt_mx[c:])/reps; bd=math.comb(L,c)/N**c
    print("%2d   %.5f            %.5f      %.6f               %.6f"%(c,mc,fo,mm,bd))
# --- Remark 4.5: plurality vote in class B vs a deployed member, after a mixture-driven rehearsal
def rehearsal_B(N,L,n,astar):
    S=set(range(1,N+1)); known=None
    for t in range(n):
        if known: break
        Slist=list(S)
        def ans(x):
            return g(rng.choice(Slist))(x)
        xs,ys=run(N,L,ans); J=rng.randrange(L); x=xs[J]
        tested = x[0] if x[1]==0 else x[1]
        if tested==astar: known=astar
        else: S.discard(tested)
    return (set([known]) if known else S)
n=30; N=2*n; L=12; reps=4000; c0=math.ceil(L/4)
hit_vote=hit_member=hit_mix=0
for _ in range(reps):
    astar=rng.randint(1,N); S=rehearsal_B(N,L,n,astar); Sl=list(S); hum=g(astar)
    vote=lambda x: (1 if len(S)<3 and g(Sl[0])(x) else 0) if len(S)>1 else g(Sl[0])(x)
    m=g(min(Sl))
    for name,A in (("vote",vote),("member",m),("mix",lambda x: g(rng.choice(Sl))(x))):
        xs,ys=run(N,L,A); C=sum(1 for x,y in zip(xs,ys) if y!=hum(x))
        if C>=c0:
            if name=="vote": hit_vote+=1
            elif name=="member": hit_member+=1
            else: hit_mix+=1
print("class B, n=%d N=%d L=%d, %d rehearsals: Pr[>=%d unfaithful calls]: vote %.4f, first consistent member %.4f (lower bd L/(8n)=%.4f), mixture %.4f"%(n,N,L,reps,c0,hit_vote/reps,hit_member/reps,L/(8*n),hit_mix/reps))
