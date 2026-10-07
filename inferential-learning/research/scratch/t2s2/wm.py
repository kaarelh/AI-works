import random, math
def subsets(mask):
    s=mask; out=[]
    while True:
        out.append(s)
        if s==0: break
        s=(s-1)&mask
    return out
random.seed(3); viol=0; maxratio=0
for trial in range(20000):
    u=random.randint(2,5); n=random.randint(2,8)
    H=[random.randrange(1<<u) for _ in range(n)]
    w0=[random.random() for _ in H]; s=sum(w0); w0=[x/s for x in w0]
    w=list(w0); t=random.randrange(n); beta=random.choice([0.0,0.1,0.3,0.5,0.9])
    D=0; m=0
    for rnd in range(40):
        W=sum(w)
        if W<=0: break
        order=sorted(range(n),key=lambda i:-w[i]*random.random())
        S=[];acc=0
        for i in order:
            S.append(i); acc+=w[i]
            if acc>=W/2: break
        Rhat=(1<<u)-1
        for i in S: Rhat&=H[i]
        Ps=subsets(Rhat)
        false_alarm = random.random()<0.15
        legal=[P for P in Ps if false_alarm or (H[t]&P)!=P]
        if not legal: continue
        P=random.choice(legal)
        D+=1; m+=false_alarm
        for i in range(n):
            if (H[i]&P)==P: w[i]*=beta
    if beta==0 and m>0: continue
    num=math.log(1/w0[t])+(m*math.log(1/beta) if m>0 else 0)
    bound=num/math.log(2/(1+beta))
    if D>bound+1e-9: viol+=1; print("VIOL",D,bound)
print("violations",viol)
