# Restricted tail kernel on the subcube {z=z0}: eigenvalue on chi_U(x), |U|=j, is
# mu_j = sum_t C(k,t) lambda_{j+t} 1[j+t>r]  (ambient-degree cutoff).
# Compare max_j mu_j with ell_r = lambda_{r+1} and with (1+k) ell_r (the heuristic for removing the 2^k loss, ../../subcube-parity.md, Section 1).
import math, mpmath as mp
mp.mp.dps = 120
def Psi(t): return 2/mp.pi*mp.asin(t)
def eigs(dd, L):
    Kh = []
    for h in range(dd+1):
        t = mp.mpf(1+dd-2*h)/(dd+1)
        for _ in range(L-1): t = Psi(t)
        Kh.append(t)
    lam = []
    for j in range(dd+1):
        s = mp.mpf(0)
        for h in range(dd+1):
            kr = sum((-1)**i*math.comb(h,i)*math.comb(dd-h,j-i) for i in range(0, min(h,j)+1))
            s += Kh[h]*math.comb(dd,h)*kr
        lam.append(s/(mp.mpf(2)**dd*math.comb(dd,j)))
    return lam
for L in [2]:
    for d, k in [(40,2),(40,4),(40,6),(40,8)]:
        dd = d+k
        lam = eigs(dd, L)
        for r in [3,5]:
            ell = lam[r+1]
            mu = [sum(math.comb(k,t)*lam[j+t] for t in range(k+1) if j+t>r and j+t<=dd) for j in range(d+1)]
            jmax = max(range(d+1), key=lambda j: mu[j])
            mux = [mu[j] if j>r else 0 for j in range(d+1)]   # x-degree cutoff instead
            print(f"L={L} d={d} k={k} r={r}: max_j mu_j/ell_r = {float(mu[jmax]/ell):.2f} at j={jmax}; "
                  f"binom(k+1,ceil((k+1)/2))={math.comb(k+1,(k+2)//2)}; 1+k={1+k}; x-degree-cutoff max/ell_r = {float(max(mux)/ell):.2f}")
