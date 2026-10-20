from mpmath import mp, mpf, log, sqrt, e, pi, exp
mp.dps=30
ct=sqrt(2*pi)*(exp(-1)-mpf(7)/20); c2=ct**2
eps=1/(64*(2+8/c2))
cs=mpf('1e-3')
def gam(s): return 1/(6*(1+pi/(2*s))**4)
for A in [1,10,100]:
  for s in [0.3,1,3]:
    g=gam(s); bA=32*((e-1)*A+1)+A
    lo=None
    for k in range(5,4000):
      L=mpf(10)**(mpf(k)/10); ld=log(L)
      Jd=ld+1+log(256*bA/c2)+log(1+4/g)*(1+(ld+log(A/eps))/(2*log(ld/(mpf('1.3')*cs))))
      rd=mpf('1.1')*(cs/ld+2/L)
      if Jd*rd<=pi/(256*e**2):
        lo=k/10;break
    print("A",A,"sigma",s,"L9 product first holds at log10 d ~",lo)
