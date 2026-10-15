import sys, math, importlib.util
spec = importlib.util.spec_from_file_location("t6", sys.argv[1])
t6 = importlib.util.module_from_spec(spec); spec.loader.exec_module(t6)
for (kappa, dS) in ((0, 0), (0, 20), (30, 0), (30, 20)):
    X = t6.Inst(100, 20, 1, 10, kappa, dS, Imax=8)
    c = 1e-4
    r = X.ident(c)
    print(f"kappa={kappa} dS={dS}: ua={r['ua']:.7f} u1={r['u1']:.7f} u2={r['u2']:.7f} ea={r['ea']:.7f} e1={r['e1']:.7f} e2={r['e2']:.7f} Dl={r['Dl']:.5f} I={r['I']:.5f} LS-K={dS + r['I']:.5f}")
# c_hi at kappa 0 and 30: bisection on Jg <= Phi2 (Phi2 of thm:teacher:main), recompute directly
def chi(kappa):
    d,m,p=100,20,2**-10
    kg=2*math.log2(d)+2*math.log2(10)+kappa
    L1=2*math.log2(d)+2*math.log2(m)+kappa
    H=-(p*math.log2(p)+(1-p)*math.log2(1-p))
    G=lambda j: 1-math.log2(1+2**-j+2*p)
    ts=(d-L1)/4
    if ts>=2:
        return min((G(1)-H)/(8+L1+kg),(G(ts-1)-H)/(d+kg))
    return (G(1)-H)/(d+kg)
print("c_hi k0=%.7e k30=%.7e"%(chi(0),chi(30)))
