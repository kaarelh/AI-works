import random, math
# R* = {a,b} with p*(a)=p*(b)=1/2 ; R'={a,c} with p'(a)=1-eta, p'(c)=eta ; c invalid under R*.
# Bayesian verifier accepts c iff posterior(R*) < delta.  delta = w* delta'.
def run(wstar, dprime, eta, rng, Tmax=200):
    delta=wstar*dprime
    lr=1.0  # L(R')/L(R*)
    for t in range(Tmax):
        post_star=wstar/(wstar+(1-wstar)*lr)
        if post_star<delta: return True
        x='a' if rng.random()<0.5 else 'b'
        if x=='b': return False
        lr*= (1-eta)/0.5
    return False
rng=random.Random(0)
for wstar in [0.5,0.1,0.01]:
    for dprime in [0.1,0.01]:
        for eta in [0.0,0.1]:
            T=200000
            f=sum(run(wstar,dprime,eta,rng) for _ in range(T))/T
            print(f"w*={wstar:5} delta'={dprime:5} eta={eta}: P(ever accept invalid)={f:.4f}  (Ville bound {dprime})")
