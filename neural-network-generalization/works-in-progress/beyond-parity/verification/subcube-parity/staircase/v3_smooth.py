import math
s1=sum(2**(-i/2) for i in range(200)); s2=sum(2**(-i/2)*math.sqrt(i+1) for i in range(400))
print("sum 2^{-i/2}=",s1," sum 2^{-i/2}sqrt(i+1)=",s2, " sqrt(log4)=",math.sqrt(math.log(4)))
def degbound(d,eps):
    J=max(0,math.ceil(math.log2(d))); tot=0
    for j in range(J+1):
        if 2**j>d: continue
        sj=math.ceil(math.sqrt(2**(j-1)*math.log(4**(J-j+1)/eps)))
        tot+=min(2**j,2*sj)
    return tot
def failprob(d,eps):
    J=max(0,math.ceil(math.log2(d))); tot=0
    for j in range(J+1):
        sj=math.ceil(math.sqrt(2**(j-1)*math.log(4**(J-j+1)/eps)))
        if 2*sj>=2**j: continue
        tot+=(d//2**j)*2*math.exp(-2*sj**2/2**j)
    return tot
worst=(0,None); worstf=(0,None)
ds=set()
for k in range(1,31):
    for off in [-1,0,1,2,3]:
        if 2**k+off>=1: ds.add(2**k+off)
for d in list(ds)+list(range(1,3000)):
    for eps in [0.999999,0.99,0.9,0.5,0.1,1e-3,1e-8,1e-20,1e-100]:
        r=degbound(d,eps)/math.sqrt(d*math.log(4/eps))
        if r>worst[0]: worst=(r,(d,eps))
        fp=failprob(d,eps)/eps
        if fp>worstf[0]: worstf=(fp,(d,eps))
print("max degree/sqrt(d log(4/eps)):",worst)
print("max failure-bound/eps:",worstf)
# analytic chain: 2*sqrt(d)*(3.414 sqrt(u)+1.177*s2) + 2(J+1) <= 18 sqrt(d (u+log4)) ?
bad=0
for d in range(1,10**5,7):
    J=max(0,math.ceil(math.log2(d)))
    for u in [0,1e-3,0.1,1,10,100,1e4]:
        lhs=math.sqrt(2)*math.sqrt(2**J)*(s1*math.sqrt(u)+math.sqrt(math.log(4))*s2)+2*(J+1)
        if lhs>18*math.sqrt(d*(u+math.log(4))): bad+=1
print("analytic chain violations:",bad)
