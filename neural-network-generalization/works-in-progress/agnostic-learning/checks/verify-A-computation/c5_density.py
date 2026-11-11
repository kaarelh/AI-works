"""Table 7.1, Proposition 7.4 and Remark 7.6, recomputed in log space with mpmath.
c = t = 1, n = 2^d, a = a_d = 2^{-d/3}, K_2 = max{n/c + t, K_mem(d, n, a_d, H)}, r = (1/n)(L/K_2)^{L/2}."""
import mpmath as mp
mp.mp.dps = 50
out = []
def P(*a):
    s = " ".join(str(x) for x in a); print(s); out.append(s)
def alpha(d): return mp.mpf(0.5)*mp.log(4*mp.sqrt(2*d))
def Kmem(d, s, a, H): return d*(d+1)*alpha(d)**2 + (H+1)*max((8*d*mp.mpf(s))**(mp.mpf(1)/H), mp.mpf(9)/(2*a))
L10 = lambda x: mp.log10(x)

P("Gamma bound check: Gamma(y+1) >= (y/e)^y for y = d/2, d = 1..400:",
  all(mp.gamma(mp.mpf(d)/2+1) >= (mp.mpf(d)/2/mp.e)**(mp.mpf(d)/2) for d in range(1, 401)))
P("(1/2) log2(8 pi e) =", mp.nstr(mp.log(8*mp.pi*mp.e, 2)/2, 6))
P("\n(H,d) | log10 r | log10 r^-d | log10 Prop7.4(a) exact-vol | same with Gamma bound | log10 K for mass 1/2 | all-c exponent log10 | floor/K2 (rho=1/2)")
for H in (2, 3):
    L = H+1
    for d in (20, 30, 40):
        n = mp.mpf(2)**d; c = 1; t = 1
        a = (mp.mpf(1)/2**d)**(mp.mpf(1)/3)
        K2 = max(n/c + t, Kmem(d, n, a, H))
        r = (1/n)*(L/K2)**(mp.mpf(L)/2)
        rho = 2*mp.sqrt(d)*(L/K2)**(mp.mpf(L)/2)       # rho_tr(K2)
        vol_exact = mp.pi**(mp.mpf(d)/2)*rho**d/mp.gamma(mp.mpf(d)/2+1)
        bound_a = n*2**(-d)*vol_exact                   # K = 1
        bound_b = (8*mp.pi*mp.e)**(mp.mpf(d)/2)*(L/K2)**(mp.mpf(L)*d/2)   # Prop 7.4(b) with the Gamma bound
        allc = (mp.log(8*mp.pi*mp.e, 2)/2*d - mp.mpf(L)/(2*H)*d*d)*mp.log10(2)
        floor_ratio = (2-2*mp.mpf(0.5))**(mp.mpf(2)/L)*n**(mp.mpf(2)/L)
        # direct check of the floor formula: L((2-2rho)/r)^{2/L} / K2
        floor_direct = L*((2-2*mp.mpf(0.5))/r)**(mp.mpf(2)/L)/K2
        P(f"({H},{d}) | {mp.nstr(L10(r),4)} | {mp.nstr(-d*L10(r),5)} | {mp.nstr(L10(bound_a),5)} | {mp.nstr(L10(bound_b),5)} |"
          f" {mp.nstr(-L10(bound_a)+L10(mp.mpf(1)/2),5)} | {mp.nstr(allc,5)} | {mp.nstr(floor_ratio,3)} (direct {mp.nstr(floor_direct,3)})")
        # Remark 7.5: log2 r^-d >= (1 + L/(2H)) d^2 and the c=1 asymptotics
        lhs = -d*mp.log(r, 2)
        assert lhs >= (1 + mp.mpf(L)/(2*H))*d*d
        # Prop 7.4(c) inequality: bound_b <= 2^{3.05 d - (L/2H) d^2} and (c<=1) <= 2^{3.05d - (L/2) d (d - log2 L)}
        assert mp.log(bound_b, 2) <= 3.05*d - mp.mpf(L)/(2*H)*d*d
        assert mp.log(bound_b, 2) <= 3.05*d - mp.mpf(L)/2*d*(d - mp.log(L, 2))
P("asserted: log2 r^-d >= (1+L/(2H)) d^2, and both bounds of Prop 7.4(c), at all six (H,d)")

# Prop 7.4(c) over a range of c (all-c claim) at n = 2^d
P("\nProp 7.4(c) all-c bound, sweep over c in [1e-3, 1e12] and a in {1, a_d}: max of [log2 bound(b) - (3.05 d - (L/2H) d^2)] (<= 0 required)")
worst = -mp.inf
for H in (2, 3, 4):
    L = H+1
    for d in (5, 10, 20, 40):
        n = mp.mpf(2)**d
        for c in [mp.mpf(10)**k for k in range(-3, 13)]:
            for a in (mp.mpf(1), (max(c, 1)/n)**(mp.mpf(1)/3) if max(c, 1) <= n else mp.mpf(1)):
                K2 = max(n/c + 1, Kmem(d, n, a, H))
                lb = d/mp.mpf(2)*mp.log(8*mp.pi*mp.e, 2) - mp.mpf(L)*d/2*mp.log(K2/L, 2)
                worst = max(worst, lb - (3.05*d - mp.mpf(L)/(2*H)*d*d))
P("  worst =", mp.nstr(worst, 6))

# the c=1 closed form of Remark 7.5
P("\nc=1 values of log2 r^-d against (1+L/2) d^2 (ratio -> 1 as d -> infinity):")
for H in (2, 3):
    L = H+1
    for d in (20, 40, 100, 400):
        n = mp.mpf(2)**d
        a = (1/n)**(mp.mpf(1)/3)
        K2 = max(n + 1, Kmem(d, n, a, H))
        r = (1/n)*(L/K2)**(mp.mpf(L)/2)
        P(f"  H={H} d={d}: log2 r^-d = {mp.nstr(-d*mp.log(r,2),6)}, (1+L/2)d^2 = {(1+L/2)*d*d}, ratio {mp.nstr(-d*mp.log(r,2)/((1+mp.mpf(L)/2)*d*d),5)}")
open(__file__.replace('.py', '.out'), 'w').write("\n".join(out) + "\n")
