import mpmath as mp
mp.mp.dps = 40
def e(deg):
    th = mp.mpf(deg)*mp.pi/180
    return 2/mp.pi*mp.ellipk(mp.sin(th/2)**2) - 1
def eup(deg):
    th = mp.mpf(deg)*mp.pi/180; k2 = mp.sin(th/2)**2
    return k2/4 + mp.mpf(9)/64*k2**2/(1-k2)
# check enclosure on series: c_n decreasing
c = lambda n: (mp.fac2(2*n-1)/mp.fac2(2*n))**2 if n>0 else mp.mpf(1)
print([float(c(n)) for n in range(6)])
for tau in ['1e-3','5e-3','1e-2','5e-2']:
    tau = mp.mpf(tau)
    texact = mp.findroot(lambda d: e(d)-tau, 20)
    tcert = mp.findroot(lambda d: eup(d)-tau, 20)
    print(float(tau), 'exact', mp.nstr(texact, 10), 'cert(eup=tau)', mp.nstr(tcert, 10))
for d in ['7.243','16.168','22.810','49.946','16.17','49.95']:
    print(d, 'e=', mp.nstr(e(d), 10), 'eup=', mp.nstr(eup(d), 10))
# lazy bisection emulation in mp
for tau in ['1e-3','5e-3','1e-2','5e-2']:
    tau = mp.mpf(tau); lo, hi = mp.mpf(0), 0.9*mp.pi; best=None
    for _ in range(20):
        m = (lo+hi)/2; k2 = mp.sin(m/2)**2
        if k2/4 + mp.mpf(9)/64*k2**2/(1-k2) <= tau: lo = m; best = m
        else: hi = m
    print(float(tau), 'lazy-bisection best deg', mp.nstr(best*180/mp.pi, 10), 'floor to 0.001:', mp.floor(best*180/mp.pi*1000)/1000)
