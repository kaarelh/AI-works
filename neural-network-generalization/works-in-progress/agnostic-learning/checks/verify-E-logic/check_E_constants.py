"""Independent sanity checks for E.md (logic referee). Not proofs."""
import numpy as np, itertools, math
import mpmath as mp
mp.mp.dps = 50
from numpy.polynomial.hermite_e import hermegauss
xg, wg = hermegauss(160); wg = wg/np.sqrt(2*np.pi)

print("== Theorem 2.7 arithmetic ==")
E = 1/8 + (1/4+1/256) + 1/4 + 1/16 + 1/8
S = 1/8 + 1/8 + 1/256 + 1/4 + 1/4
MF = 1/8 + (1/4+1/256) + 1/8 + 1/8 + 1/8
print(f"regime E/T excess {E:.4f} (<0.82), regime S {S:.4f} (<0.76), regime MF {MF:.4f} (<0.76)")
print(f"sum delta/(4N^2) = {math.pi**2/24:.4f} delta (<0.42)")
# Remark 2.9(b): good-parameter bound below 0.7 eps
print(f"good-param bounds: E {1/8+1/4+1/256+1/4:.4f}, T {1/8+1/4+1/256+1/4+1/16:.4f}, MF {1/8+1/4+1/256+1/8+1/8:.4f} (<0.7)")

print("== theta thresholds ==")
for H in [2,3,4,5]:
    g0 = 2-1/H
    # route (ii) at gamma>=2-1/H gives >=1/H
    for g in np.linspace(g0, 1.999, 7):
        assert (g-1)/(H*(H-1)*(2-g)) >= 1/H - 1e-12
    for g in np.linspace(1.0001, g0-1e-4, 50):
        assert (g-1)/(H*(H-1)*(2-g)) < 1/H and (g-1)/(g*H-1) < 1/H
    # e_i algebra
    for g in [1.1,1.3,1.7]:
        for th in [0.01,0.05,0.2]:
            lhs = (1-th)/g - th*(H-1)/(g-1); rhs = (g-1-th*(g*H-1))/(g*(g-1))
            assert abs(lhs-rhs) < 1e-12
    # gamma -> 1+ : theta_{L,gamma} vs theta_{L,1}
    DH = 4+16*(H-1)*3**(H-1)   # L=H+1, L-2=H-1
    th1 = 1/DH
    gstar = None
    for g in np.linspace(1.00001, 1.5, 200001):
        th = max((g-1)/(g*H-1), (g-1)/(H*(H-1)*(2-g)))
        if th >= th1: gstar = g; break
    print(f"H={H}: theta_(L,1)=1/{DH}={th1:.5f}; proven theta_(L,gamma) < theta_(L,1) for 1<gamma<{gstar:.5f}")

print("== (I3) degrees from meanfield.tex formulas (L>=3) ==")
def mf(L, K, a, d=5):
    r = L-1; Kb = K+1
    K = mp.mpf(K); a = mp.mpf(a); Kb = K+1
    G = [mp.mpf(0)]*(r+1); G[r] = 8*r*K*Kb/a**2
    for l in range(r-1, 0, -1): G[l] = 8*G[l+1]*(1+G[l+1])**2
    G1 = G[1]
    l0 = mp.log(3) + 2*d*mp.log(1+8*mp.sqrt(d)*K**(mp.mpf(L)/2)/a)
    P3 = 24*G1+36*G1**2+8*G1**3
    T = max(1, 2*mp.ceil(G1**2/2)*l0/(K-1), 4*G1**2, P3**2)  # c_nu omitted (constant)
    b = 8*(1+G1)**2; eta = a**2/(8*K*r*b**(r-1))
    s = (1+8*mp.sqrt(d)*K**(mp.mpf(L)/2)/a)**d
    J = 2*eta**-2*mp.log(8*r*s**2)
    P = J*(d+1)+(L-2)*J**2+J
    return T, P
for L in [3,4]:
    K1, K2 = 1e6, 1e12
    T1, P1 = mf(L, K1, 0.1); T2, P2 = mf(L, K2, 0.1)
    dT = (mp.log(T2)-mp.log(T1))/(mp.log(K2)-mp.log(K1))
    dH = (mp.log(P2)-mp.log(P1))/(mp.log(K2)-mp.log(K1))
    print(f"L={L}: empirical deg_K T ~ {float(dT):.3f} (claim {4*3**(L-1)}), deg_K P ~ {float(dH):.3f} (claim {4+16*(L-2)*3**(L-2)}, P is H^mf up to a log)")

print("== Lemma 4.2 at tau=1 (worst case), alpha = 2+alpha_d ==")
for d in [1,2,5,10,20,30]:
    alpha_d = 0.5*math.log(4*math.sqrt(2*d)); alpha = 2+alpha_d
    taud = math.sqrt((d+1)/d)
    phi = lambda u: np.tanh(np.asarray(u,float)[...,None] + 1.0*taud*xg) @ wg
    worst = 1e9
    for k in range(1, d+1):
        bk = 1 if k%2==0 else 0
        # c_k^phi via counting j minus-ones
        ck = sum(math.comb(k,j)*(-1)**j*float(phi(alpha*(k-2*j-bk))) for j in range(k+1))/2**k
        worst = min(worst, abs(ck)*2*math.sqrt(2*k))
    one_minus_phi = 1-float(phi(alpha))
    inv_phi = 1/float(phi(alpha))
    print(f"d={d}: min_k |c_k^phi| 2sqrt(2k) = {worst:.4f} (claim >=1); 1-phi(alpha)={one_minus_phi:.3e} <= {1/(2*math.sqrt(2*d)):.3e}; 1/phi(alpha)={inv_phi:.3f} < 2sqrt(2d)={2*math.sqrt(2*d):.3f}")

print("== Proposition 4.4: Xi bound ==")
for H in range(2,9):
    Sb = 3**((H-1)/2)+0.25
    for a in [1.0, 0.1, 1e-4]:
        for Amax in [1.0, 1e3, 1e9]:
            R = max(Amax**(1/H), math.sqrt(128*H**2*Sb**3/a), 2)
            u0 = min(a/(16*R**(H-1)), a/(32*H**2*Sb))
            phi_ = a/(16*H*Sb)
            fbar = phi_ + H*(u0 + 4*Sb**2/R**2)
            Xi = 2*R**(H-1)*u0 + 2*H*Sb*fbar + 16*Sb**3/(3*R**2)
            assert Xi < 0.39*a, (H,a,Amax,Xi/a)
print("Xi < 0.39a on grid: OK")
print("== misc ==")
print("3.5sqrtN >= 2sqrtN+sqrt(2ln2) at N=1:", 3.5 >= 2+math.sqrt(2*math.log(2)))
print("2sqrt2+3(H-1)+2 <= 3H+2:", all(2*math.sqrt(2)+3*(H-1)+2 <= 3*H+2 for H in range(1,50)))
print("(G1) ln2/6 < 1/8:", math.log(2)/6 < 1/8)
