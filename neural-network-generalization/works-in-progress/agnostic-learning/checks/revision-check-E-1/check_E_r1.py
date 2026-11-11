"""Independent checks for the revision check of E-finite-prior-scale.md (round 1).
1. Table 7.1: unrounded e (grid a as in bounds_table_fs.py, and continuous a with exact beta_n) -> 'within 1e-4'.
2. gamma_H = (D_H-1)/(D_H-H) and the claim that theta_{L,gamma} < 1/D_H exactly for 1<gamma<gamma_H.
3. Prop 4.4 Step 6: five Xi terms sum to 37/96 a with H>=2; with H=1 bound would be 0.4167a.
4. N_* explicit form: ratio N_*/(d^2 s/a^2 + d (ds)^{(H-1)/H}/a^2 + d a^{-(H+1)}) bounded over a grid.
5. A_L(rho) - E_*/2 versus (d+m)(ln(1/rho)+ln(dmB)) over a grid (incl. corner d=m=B=1, rho=1).
6. Remark 5.4a: (1-2e^{-N})(1+e) >= 1+e-4e^{-N} for e in [0,1]; and N_* >= s0 on the Cor 5.3 schedule.
7. E1: general-c extra terms of Lemma 2.2 vs the c=n^{1-theta} form (symbolic).
"""
import numpy as np, math
from math import log, sqrt, exp
from scipy import special, optimize
import sympy as sp

print("== 1. Table 7.1 unrounded ==")
def beta_pois(lam): return float(np.exp(-lam)*(special.expi(lam)-np.euler_gamma-np.log(lam)))
def beta_binom_exact(n, M):
    n=int(round(n)); p=1.0/M; tot=0.0; logc=0.0
    for k in range(1,400):
        logc += math.log(n-(k-1)) - math.log(k)
        tot += math.exp(logc + k*math.log(p) + (n-k)*math.log1p(-p))/k
    return tot
def params(d,s,a,H):
    Sb=3**((H-1)/2)+0.25; Amax=2*sqrt(2*d*s)*3**((H-1)/2); ad=0.5*log(4*sqrt(2*d))
    alpha=2+max(ad,0.5*log(256*H*Sb/a)); R=max(Amax**(1/H),sqrt(128*H**2*Sb**3/a),2.0)
    K=d*(d+1)*alpha**2+(H+1)*R**2; u0=min(a/(16*R**(H-1)),a/(32*H**2*Sb)); ld=(d+1)*log(2)+log(8*H)
    mf=math.floor(128*log(2)*Amax**2*(d+1)/a**2)+1
    Nst=max(mf,256*Amax**2*ld/a**2,512*H**2*Sb**2*ld/a**2,2*ld/u0**2)
    return K,Nst
maxdiff=0
for H in [2,3]:
    for d in [30,40,60]:
        for lam in [1.0,1.5]:
            M=2.0**d; n=lam*M; s0=min(n,M); delta=0.01; t=1.0; c=1.0
            dev=sqrt(2*lam*log(1/delta)/M)
            def e_of(a,bn):
                K,_=params(d,s0,a,H); eta=a**2+c*(K+2*t)/n
                return max(0.0,sqrt(max(0.0,bn-dev))-sqrt(lam*eta))**2
            bn_lb=beta_pois(lam)-n/M**2
            grid=np.logspace(-12,0,600)
            eg=max(e_of(a,bn_lb) for a in grid)
            bn_ex=beta_binom_exact(n,M)
            res=optimize.minimize_scalar(lambda la:-e_of(10**la,bn_ex),bounds=(-13,0),method='bounded',options={'xatol':1e-10})
            # refine with a dense grid near the optimum to be safe
            g2=np.logspace(-13,0,20000); ec=max(max(e_of(a,bn_ex) for a in g2), e_of(10**res.x,bn_ex))
            maxdiff=max(maxdiff,abs(ec-eg))
            print(f"H={H} d={d} lam={lam}: e(grid, beta lower bound)={eg:.7f}  e(continuous, exact beta_n)={ec:.7f}  diff={ec-eg:.2e}")
print(f"max |diff| = {maxdiff:.2e} (text: 'within 1e-4')")

print("\n== 2. gamma_H ==")
def theta_gt1(H,g): return max((g-1)/(g*H-1),(g-1)/(H*(H-1)*(2-g)))
for H in [2,3,4,5]:
    L=H+1; DH=4+16*(L-2)*3**(L-2); gH=(DH-1)/(DH-H)
    gs=np.linspace(1+1e-9,2-1/H-1e-9,200001)
    below=np.array([theta_gt1(H,g)<1/DH for g in gs])
    # check 'exactly when gamma<gamma_H'
    ok=np.all(below==(gs<gH))
    cross=2-2/H+1/H**2
    print(f"H={H}: D_H={DH}, gamma_H={gH:.5f}, crossover={cross:.4f}, below<=>gamma<gamma_H on grid: {ok}")

print("\n== 3. Xi terms ==")
for H in [1,2,3]:
    tot=sp.Rational(1,8)+sp.Rational(1,8)+sp.Rational(1,16)+sp.Rational(1,16)+sp.Rational(1,24*H**2)
    print(f"H={H}: sum = {tot} = {float(tot):.4f}")

print("\n== 4. N_* explicit form ==")
worst=0
for H in [2,3,4]:
    for d in [1,2,5,10,30]:
        for s in [1e-3,1,10,1e3,1e6]:
            for a in [1,0.3,1e-2,1e-4,1e-8]:
                Sb=3**((H-1)/2)+0.25; Amax=2*sqrt(2*d*s)*3**((H-1)/2)
                R=max(Amax**(1/H),sqrt(128*H**2*Sb**3/a),2.0); u0=min(a/(16*R**(H-1)),a/(32*H**2*Sb)); ld=(d+1)*log(2)+log(8*H)
                mf=math.floor(128*log(2)*Amax**2*(d+1)/a**2)+1
                Nst=max(mf,256*Amax**2*ld/a**2,512*H**2*Sb**2*ld/a**2,2*ld/u0**2)
                form=d**2*s/a**2+d*(d*s)**((H-1)/H)/a**2+d*a**(-(H+1))
                worst=max(worst,Nst/form)
        print(f"H={H}: max N_*/form so far = {worst:.3g}")

print("\n== 5. A_L - E_*/2 vs (d+m)(ln(1/rho)+ln(dmB)) ==")
def A_L(d,m,B,rho,L):
    Es=d*(d+1)*B**2+2*(L-1)*m**2*B**2
    b0=2*sqrt(2*(2*log(9)+log(4*L))); A0=2+3*m*B+b0; P0=1+2*m*B*(d+L+1)*A0**(L-2)
    eta=min(0.5,rho/(2*P0))
    return 1+0.5*Es+(d+2+(L-2)*m)*log(8/(3*eta))+log(2), Es
for (d,m,B,rho,L) in [(1,1,1,1.0,3),(1,1,1,0.5,3),(10,5,2,0.01,3),(10,5,2,1e-6,4)]:
    A,Es=A_L(d,m,B,rho,L); rhs=(d+m)*(log(1/rho)+log(d*m*B))
    print(f"d={d} m={m} B={B} rho={rho} L={L}: A_L-E_*/2={A-0.5*Es:.2f}, (d+m)(ln(1/rho)+ln(dmB))={rhs:.2f}")

print("\n== 6. Remark 5.4a inequality ==")
ok=True
for e in np.linspace(0,1,101):
    for N in [1,2,5,10,100]:
        for g in [1.0,1.5,3.0]:
            lhs=(1-2*exp(-N**g))*(1+e); rhs=1+e-4*exp(-N)
            ok &= lhs>=rhs-1e-15
print("(1-2e^{-N^g})(1+e) >= 1+e-4e^{-N} for e in [0,1], N>=1, g>=1:", ok)

print("\n== 7. E1 general-c terms ==")
Ng,n,c,A,dl,th=sp.symbols('Ng n c A dl theta',positive=True)
Lam=Ng*n/(2*c)
extra=(Ng*A+dl)/Lam+2*Lam/n
print("extra terms (general c):", sp.simplify(sp.expand(extra)))
print("residual vs 2cA/n+2c*dl/(Ng*n)+Ng/c:", sp.simplify(extra-(2*c*A/n+2*c*dl/(Ng*n)+Ng/c)))
print("at c=n^{1-theta}, residual vs displayed:", sp.simplify((extra-(2*n**(-th)*(A+dl/Ng)+Ng*n**(th-1))).subs(c,n**(1-th))))
