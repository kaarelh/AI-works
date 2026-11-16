# Attack on Theorem 2.1 (R4) of one-mind.md.
# The theorem rests on the one-round inequality  E[m_t | D] >= E_z[psi_L(u(z))]/L  (Steps 1-3)
# plus the potential Lemma 1.5. We test the one-round inequality exactly on random and
# hill-climbed instances: variable-length runs, stochastic hypotheses and semimeasures, deterministic human.
import random, itertools, math
def psi(u,L): return u - u*u*(L-1)/(2*L)

def make_instance(rng, nX=5, nY=3, nZ=3, L=4, nH=6, stoch=True):
    nxt = {}
    def next_input(z, hist):
        key=(z,hist)
        if key not in nxt:
            j=len(hist)
            if j>=L: nxt[key]=None
            elif j>0 and rng.random()<0.25: nxt[key]=None   # STOP: variable length
            else: nxt[key]=rng.randrange(nX)
        return nxt[key]
    f=[rng.randrange(nY) for _ in range(nX)]
    H=[]
    for h in range(nH):
        if stoch and rng.random()<0.6:
            ker=[]
            for x in range(nX):
                v=[rng.random()**3 for _ in range(nY+1)]   # last = missing mass (bottom)
                if rng.random()<0.5: v[-1]=0
                s=sum(v); ker.append([a/s for a in v])
        else:
            g=[f[x] if rng.random()<0.7 else rng.randrange(nY+1) for x in range(nX)]
            ker=[[1.0 if y==g[x] else 0.0 for y in range(nY+1)] for x in range(nX)]
        H.append(ker)
    fker=[[1.0 if y==f[x] else 0.0 for y in range(nY+1)] for x in range(nX)]
    H.append(fker)
    w=[rng.random()**2 for _ in H]; s=sum(w); w=[a/s for a in w]
    D0=[rng.random() for _ in range(nZ)]; s=sum(D0); D0=[a/s for a in D0]
    return dict(next=next_input,f=f,H=H,w=w,D0=D0,L=L,nY=nY)

def runs(inst, ker, z):
    # enumerate runs of answerer ker on z: list of (prob, inputs, answers)
    out=[]
    def rec(hist, inputs, p):
        x=inst['next'](z, hist)
        if x is None: out.append((p,inputs,hist)); return
        for y,q in enumerate(ker[x]):
            if q>0: rec(hist+(y,), inputs+(x,), p*q)
    rec((),(),1.0); return out

def one_round(inst):
    L=inst['L']; f=inst['f']; H=inst['H']; w=inst['w']
    ebar=lambda x: sum(wv*(1-k[x][f[x]]) for wv,k in zip(w,H))
    Em=0.0; Epsi=0.0; Eu=0.0
    for z,pz in enumerate(inst['D0']):
        fr=runs(inst,H[-1],z)[0]
        u=0.0
        for wv,k in zip(w,H):
            for p,inp,ans in runs(inst,k,z):
                if (inp,ans)!=(fr[1],fr[2]): u+=wv*p
                Em+=pz*wv*p*sum(ebar(x) for x in inp)/L
        Epsi+=pz*psi(u,L); Eu+=pz*u
    return Em, Epsi/L, Eu

rng=random.Random(7)
worst=0; n=0
for trial in range(3000):
    L=rng.choice([1,2,3,4,5])
    inst=make_instance(rng,L=L,nH=rng.choice([2,4,8]),stoch=rng.random()<0.7)
    Em,rhs,Eu=one_round(inst)
    if rhs>1e-12:
        r=rhs/Em; n+=1
        if r>worst: worst=r; wl=(L,Em,rhs,Eu)
print("random instances: %d, max of [E psi_L(u)/L] / E[m] = %.6f  (theorem needs <= 1)"%(n,worst), "at L,Em,rhs,Eu =",wl)

# Hill-climb: path scaffold (the extremal structure) with general deterministic hypotheses on a
# single z; maximize ratio over weights. Lower bound target: ratio -> 1 when ...
def path_ratio(L, wf, dev_pos_weights):
    # hypotheses g_a deviating first at position a in [L] then leaving the path (no more removals)
    # weights q_a for g_a, wf for f. u = sum q_a. m: f-run asks pos J (mass removed = q_J);
    # g_a-run asks pos J if J<=a, removes q_J; else off path, removes 0.
    q=dev_pos_weights; u=sum(q)
    Em = wf*sum(q)/L + sum(q[a]*sum(q[j] for j in range(a+1))/L for a in range(L))
    return psi(u,L)/L/Em
best=0
for L in [2,3,5,10]:
    b=0
    for it in range(20000):
        wf=rng.random()*0.2
        q=[rng.random() for _ in range(L)]; s=sum(q); tot=1-wf; q=[a*tot/s for a in q]
        r=path_ratio(L,wf,q); b=max(b,r)
    # uniform q, wf->0:
    print("L=%d: best random ratio on path family %.5f; uniform q, wf=1e-9: %.5f"%(L,b,path_ratio(L,1e-9,[(1-1e-9)/L]*L)))
