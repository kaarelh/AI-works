# Independent check of Proposition 2.5 (sharpness of R4): series S(L,K), its two bounds,
# and a direct Monte Carlo of the posterior-draw rehearsal on the path example with fresh z
# (infinitely many top-level inputs: every round's z is fresh, product posterior tracked as ratio R).
import math, random
def S(L,K):
    R0=2**K-1; s=0; k=0
    while True:
        R=R0*(1-1/L)**k; u=R/(1+R); t=u/(1-u*(L-1)/(2*L)); s+=t; k+=1
        if t<1e-14 and k>10: return s
for L,K in [(2,100),(5,100),(20,100),(100,100),(2,2),(3,1),(10,10)]:
    up=2*L*L*K*math.log(2)/(L+1); lo=2*L*(L-1)*(K-1)*math.log(2)/(L+1)
    c=(L+1)/(2*L); lam=math.log(L/(L-1)); mid=math.log(1+c*(2**K-1))/(c*lam)
    print("L=%3d K=%3d S=%10.3f  S/(LKln2)=%.4f  lower=%10.3f mid=%10.3f upper=%10.3f ok=%s"%(L,K,S(L,K),S(L,K)/(L*K*math.log(2)),lo,mid,up, lo<=mid<=S(L,K)<=up))
# Monte Carlo of the actual protocol (not of the chain): hypotheses g_a with a(z) uniform; fresh z each round.
rng=random.Random(3)
def mc(L,K,reps=4000,rounds=4000):
    tot=0
    for _ in range(reps):
        R=2**K-1
        for t in range(rounds):
            u=R/(1+R); tot+=u
            J=rng.randint(1,L)
            if rng.random()<u:                 # driver is a trap g_a, a(z) uniform
                a=rng.randint(1,L)
                if J<=a: R*=1-1/L               # question (z,J) on path: removes 1/L of trap mass
            else: R*=1-1/L                     # driver f: always on path
            if R<1e-12: break
    return tot/reps
for L,K in [(3,1),(5,5),(10,4)]:
    print("MC L=%d K=%d: sum E[u_t] = %.3f   series S = %.3f"%(L,K,mc(L,K),S(L,K)))
