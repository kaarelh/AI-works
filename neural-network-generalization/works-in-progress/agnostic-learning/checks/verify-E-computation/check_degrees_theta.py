"""(1) Degrees in K of T_L and H^mf_L from meanfield.tex (Proposition mf-cover, eq. T, finite realization,
counting), evaluated exactly in log space with mpmath.  (2) Exponent bookkeeping of Theorem 2.7:
for each regime/route, the exponent of n in each sufficient condition, and the resulting theta threshold."""
import mpmath as mp
mp.mp.dps = 60

def mf_logs(L, K, a, d):
    K = mp.mpf(K); a = mp.mpf(a); r = L-1; Kb = K+1
    G = [None]*(r+1)
    G[r] = 8*r*K*Kb/a**2
    for l in range(r-1, 0, -1):
        G[l] = 8*G[l+1]*(1+G[l+1])**2
    G1 = G[1]
    net = 1 + 8*mp.sqrt(d)*K**(mp.mpf(L)/2)/a       # cube version (Remark cube)
    ell0 = mp.log(3) + 2*d*mp.log(net)
    P3 = 24*G1 + 36*G1**2 + 8*G1**3
    cnu = 1.0   # any fixed positive constant; does not affect the degree
    T = max(1, 2*mp.ceil(G1**2/2)*ell0/(K-1), 4*G1**2, cnu**2*P3**2)
    b = 8*(1+G1)**2
    eta = a**2/(8*K*r*b**(r-1))
    logs = d*mp.log(net)
    J = mp.ceil(2*eta**-2*(mp.log(8*r) + 2*logs))
    P = J*(d+1) + (L-2)*J**2 + J
    a0 = mp.mpf(1)/4
    DJ = J*(d+1) + (L-2)*J**2
    B0 = max(1, K/(a*J), mp.sqrt((2*G1 + mp.log(4*mp.sqrt(2)*max(DJ, 1)))/a0))
    Lam = (d + L*J)*(1 + J*(B0+1))**(L-1)
    Hmf = P*mp.log(3 + 16*B0*Lam/a)
    return mp.log(T), mp.log(Hmf), mp.log(P)

for L in [3, 4, 5]:
    DT_claim = 4*3**(L-1); DH_claim = 4 + 16*(L-2)*3**(L-2)
    K1, K2 = mp.mpf(10)**8, mp.mpf(10)**12
    t1, h1, p1 = mf_logs(L, K1, 0.01, 10); t2, h2, p2 = mf_logs(L, K2, 0.01, 10)
    dK = mp.log(K2) - mp.log(K1)
    print(f"L={L}: slope deg_K T = {float((t2-t1)/dK):.3f} (claim D_T={DT_claim}); slope deg_K P = {float((p2-p1)/dK):.3f}, "
          f"slope deg_K H^mf = {float((h2-h1)/dK):.3f} (claim D_H={DH_claim}, up to logs); "
          f"D_H >= D_T+1: {DH_claim >= DT_claim+1}; theta_(L,1) = 1/{DH_claim} = {1/DH_claim:.6f}")

print()
print("== Gaussian-coordinate remark: without the Lindeberg terms (4G1^2, c_nu^2 P3^2), deg_K T would be ==")
for L in [3, 4, 5]:
    print(f"L={L}: deg(G1^2/K) = {4*3**(L-2)-1} (+log), vs D_T = {4*3**(L-1)}; D_H = {4+16*(L-2)*3**(L-2)} unchanged")

print()
print("== Theorem 2.7 exponent bookkeeping (each entry: exponent of n that must be > 0) ==")
def conds(H, g, th):
    out = {}
    if H == 1 or g >= 2:
        out['I:(C3)'] = (1 - th*H)/2
        return out
    if g > 1:
        degT = th*(H-1)/(g-1)                  # T ~ n^{degT}
        out['II(i):T^g<=eps n^(1-th)/4'] = (1-th) - g*degT
        out['II(i):(C3) Kbar=L K_T'] = (1 - th*H)/2
        thp = max(th, (2-g)*degT)              # K' ~ n^{max(th,(2-g) degT)}
        out['II(ii):(C3) Kbar=max(LK_T,K\')'] = (1 - thp*H)/2
        return out
    L = H+1; DT = 4*3**(L-1); DH = 4+16*(L-2)*3**(L-2)
    out['III:T_mf<=eps n^(1-th)/4'] = 1 - th - th*DT
    out['III:(C5)'] = 1 - th*DH
    return out

def theta_claim(H, g):
    if H == 1: return 1.0
    if g == 1: return 1/(4+16*(H-1)*3**(H-1))
    if g >= 2-1/H: return 1/H
    return max((g-1)/(g*H-1), (g-1)/(H*(H-1)*(2-g)))

def theta_numeric(H, g):
    # largest theta such that the conditions of SOME admissible route have all exponents > 0
    def ok(th):
        c = conds(H, g, th)
        if H == 1 or g >= 2: return all(v > 0 for v in c.values())
        if g > 1:
            r1 = c['II(i):T^g<=eps n^(1-th)/4'] > 0 and c['II(i):(C3) Kbar=L K_T'] > 0
            r2 = c["II(ii):(C3) Kbar=max(LK_T,K')"] > 0
            return r1 or r2
        return all(v > 0 for v in c.values())
    lo, hi = 0.0, 1.0
    for _ in range(80):
        mid = (lo+hi)/2
        if ok(mid): lo = mid
        else: hi = mid
    return lo

worst = 0
for H in [1, 2, 3, 4, 5]:
    for g in [1.0, 1.001, 1.01, 1.05, 1.1, 1.2, 1.25, 1.3, 1.4, 1.444, 1.5, 1.5625, 1.6, 1.6667, 1.7, 1.75, 1.8, 1.9, 1.99, 2.0, 2.5, 3.0]:
        tn, tc = theta_numeric(H, g), theta_claim(H, g)
        worst = max(worst, abs(tn - tc))
print("max |numeric threshold - claimed theta_{L,gamma}| over grid:", worst)
for H in [2, 3, 4]:
    print(f"H={H}: theta at gamma -> 1+ : {theta_claim(H,1.0001):.5f}, at gamma = 1: {theta_claim(H,1.0):.5f}  (discontinuous at 1)")
