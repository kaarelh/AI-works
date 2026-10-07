import itertools
from math import log2
# Cor 5.2a without valid dominance: V={v}, E={F}, witness(F)={v}
def opt(c, comps, wit):
    best=None
    for r in range(len(comps)+1):
        for S in itertools.combinations(comps,r):
            S=set(S)
            if any(f in S and w<=S for f,w in wit.items()): continue
            val=sum(comps[x][0]-c*comps[x][1] for x in S)
            if best is None or val>best[0]+1e-15: best=(val,S)
    return best
comps={'v':(0.01,10),'F':(0.02,10)}
for c in [1e-4,5e-4,9e-4,1.1e-3,3e-3]:
    print('Cor5.2a cex c=%g'%c, opt(c,comps,{'F':{'v'}}))
# (d3) bundle: v k=10 r=0.01; e alone K=100, K(e|v)=1, r=0.01
def J(S,c):
    k={(): 0, ('v',):10, ('e',):100, ('e','v'):11}[tuple(sorted(S))]
    r={(): 0, ('v',):0.01, ('e',):0.01, ('e','v'):0.02}[tuple(sorted(S))]
    return c*k - r
c=1.5e-3
print('(d3) c=1.5e-3:', sorted([(J(S,c),S) for S in [(),('v',),('e',),('v','e')]]))
# Prop 4.4 three-option region: none / unguarded / guarded ; show 'for c above guard rate' can select NONE
M,eta=64,0.05
p_hit=1-eta+eta/M
H=-(p_hit*log2(p_hit)+(M-1)*(eta/M)*log2(eta/M)); g=log2(M)-H
def region(piG,piNG,ks,kG):
    A=(0, 0.0)                                   # uniform everywhere (risk reduction 0)
    B=(ks, piG*g - piNG*(log2(M/eta)-log2(M)))   # unguarded
    C=(ks+kG, piG*g + piNG*(log2(M)-log2(M-1)))  # guarded, uniform over the M-1 others
    return dict(none=A,unguarded=B,guarded=C)
for piG,piNG in [(0.05,5e-4),(0.002,0.002)]:
    R=region(piG,piNG,22,12)
    rG=(R['guarded'][1]-R['unguarded'][1])/12; rB=R['unguarded'][1]/22
    print(f"piG={piG} piNG={piNG}: guard rate {rG:.2e}, unguarded-sigma rate {rB:.2e}")
    for c in [rG*1.01, rG*3, rB*1.01 if rB>0 else 1e-3]:
        sel=min(R, key=lambda n: c*R[n][0]-R[n][1])
        print(f"   c={c:.2e}: selected {sel}")
