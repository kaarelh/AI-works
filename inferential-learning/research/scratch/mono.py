import mpmath as mp
mp.mp.dps = 40
def e_exact(th): k2 = mp.sin(th/2)**2; return 2/mp.pi*mp.ellipk(k2) - 1
def e_up(th): k2 = mp.sin(th/2)**2; return k2/4 + mp.mpf(9)/64*k2**2/(1-k2)
def e_lo(th): k2 = mp.sin(th/2)**2; return k2/4
# check enclosure on a range
for d in [1,5,10,30,50,90,120,150,170,179]:
    th = mp.radians(d); assert e_lo(th) <= e_exact(th) <= e_up(th), d
print("enclosure ok")
# exact thresholds and certified thresholds (where e_up = tau)
for tau in ['1e-3','5e-3','1e-2','5e-2']:
    tau = mp.mpf(tau)
    tex = mp.findroot(lambda t: e_exact(t)-tau, mp.radians(30))
    tcert = mp.findroot(lambda t: e_up(t)-tau, mp.radians(30))
    print(float(tau), "exact thr deg", mp.nstr(mp.degrees(tex),8), " cert thr (e_up=tau) deg", mp.nstr(mp.degrees(tcert),8))
# check claimed certified values satisfy e_up <= tau (rounded down values)
for tau, d in [('1e-3',7.24),('5e-3',16.17),('1e-2',22.81),('5e-2',49.95)]:
    print(tau, d, e_up(mp.radians(d)) <= mp.mpf(tau), mp.nstr(e_up(mp.radians(d)),10))
# monotonicity of coefficients c_n
c = mp.mpf(1)
for n in range(1,50):
    cn = c*((2*n-1)/mp.mpf(2*n))**2
    assert cn <= c; c = cn
print("c_n decreasing ok")
# 60 deg error and conformal quantile check
print("e(60)", e_exact(mp.radians(60)), "e(30)", e_exact(mp.radians(30)))
