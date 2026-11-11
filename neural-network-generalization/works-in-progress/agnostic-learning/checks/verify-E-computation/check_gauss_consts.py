"""Independent numerical checks of (G1), (G4), Lemma 4.1, Lemma 4.2 constants and Pi_* values,
using scipy.integrate.quad (adaptive) instead of Gauss-Hermite."""
import numpy as np
from scipy import integrate, stats, optimize

phi = lambda x: np.exp(-x*x/2)/np.sqrt(2*np.pi)
def EG(f, lim=12):
    return integrate.quad(lambda x: f(x)*phi(x), -lim, lim, epsabs=1e-14, epsrel=1e-13, limit=400)[0]
sech2 = lambda y: 1/np.cosh(y)**2

print("== (G1): Pr(chi2_P > u) <= exp(-u/8) for u >= 3P; worst ratio over P, u in [3P, 30P] ==")
worst = 0
for P in [1, 2, 3, 5, 10, 30, 100, 1000, 10000]:
    for k in np.linspace(3, 30, 200):
        u = k*P
        lhs = stats.chi2.logsf(u, P); rhs = -u/8
        worst = max(worst, lhs - rhs)
print("max log(LHS/RHS) =", worst, "(must be <= 0)")
print("exact rate at u=3P: (3-1-ln3)/2 =", (3-1-np.log(3))/2, " vs bound rate 3/8 =", 3/8)

print("== (G4): 1-Phi(t) <= exp(-t^2/2)/2 for t>=0 ==")
t = np.linspace(0, 40, 400001)
print("max log ratio:", np.max(stats.norm.logsf(t) - (-t**2/2 - np.log(2))), "(must be <= 0)")

print("== varpi, F, Pi_* (adaptive quadrature) ==")
varpi = lambda q: EG(lambda x: sech2(np.sqrt(q)*x))
F = lambda q: EG(lambda x: np.tanh(np.sqrt(q)*x)**2)
print("varpi(1) =", varpi(1.0), " F(1) =", F(1.0), " sum =", varpi(1.0)+F(1.0))
def pistar(H, tau):
    q, P = 1.0, 1.0
    for l in range(1, H):
        P *= varpi(tau**2*q); q = F(tau**2*q)
    return P
for H in range(2, 7):
    print(f"Pi*(tau=1,H={H}) = {pistar(H,1.0):.5f}   lower bound 3^-(H-1)/2 = {3**(-(H-1)/2):.5f}")
print("Pi*(tau) monotone in tau? H=3:", [round(pistar(3, t), 4) for t in [0.05, 0.25, 0.5, 0.75, 1.0]])

print("== Lemma 4.1(b): varpi(q) >= (1+2q)^{-1/2}; |varpi'| <= 1; |F'| <= 1 ==")
qs = np.linspace(0, 1, 201)
vv = np.array([varpi(q) for q in qs]); FF = np.array([F(q) for q in qs])
print("min varpi - (1+2q)^-1/2 =", (vv - (1+2*qs)**-0.5).min())
# derivative via Stein identity: varpi'(q) = (1/2) E (sech^2)''(sqrt q G)
d2s = lambda y: 2*sech2(y)*(3*np.tanh(y)**2-1)
der = np.array([0.5*EG(lambda x: d2s(np.sqrt(q)*x)) for q in qs])
print("max |varpi'| =", np.abs(der).max(), " at q =", qs[np.abs(der).argmax()])
print("F' = -varpi' (since F = 1 - varpi): max |F'| same.")

print("== Lemma 4.1(a),(c): sup over u in [-6,6], q in [0,1] ==")
r1 = 0; r2 = 0
for q in [0.0, 0.05, 0.2, 0.5, 0.8, 1.0]:
    for u in np.r_[np.linspace(-6, -0.01, 120), np.linspace(0.01, 6, 120)]:
        psi = EG(lambda x: np.tanh(u + np.sqrt(q)*x))
        r1 = max(r1, abs(psi - varpi(q)*u)/(abs(u)**3/3))
        Ups = EG(lambda x: np.tanh(u + np.sqrt(q)*x)**2)
        r2 = max(r2, abs(Ups - F(q))/u**2)
print("max |psi_q(u)-varpi(q)u|/(|u|^3/3) =", r1, " ; max |Upsilon(u,q)-F(q)|/u^2 =", r2)

print("== Lemma 4.2 at the worst noise level tau^2 tau_d^2 = 2 (d=1, tau=1) and alpha = 2 + alpha_d ==")
for d in [1, 2, 3, 5, 10, 30, 100]:
    alpha_d = 0.5*np.log(4*np.sqrt(2*d)); alpha = 2 + alpha_d
    s = np.sqrt((d+1)/d)
    ph = lambda u: EG(lambda x: np.tanh(u + s*x))
    worst = np.inf
    for k in range(1, min(d, 14)+1):
        bk = 1 if k % 2 == 0 else 0
        # c_k^phi via counts of -1's: v has j minus ones -> prod = (-1)^j, sum = k-2j
        from math import comb
        ck = sum(comb(k, j)*(-1)**j*ph(alpha*(k-2*j-bk)) for j in range(k+1))/2**k
        worst = min(worst, abs(ck)*2*np.sqrt(2*k))
    sat = 1 - ph(alpha)
    es2 = max(EG(lambda x: sech2(alpha*tt + s*x)) for tt in [1, 3, 5])
    print(f"d={d}: min_k |c_k^phi| 2sqrt(2k) = {worst:.4f} (>=1); 1-phi(alpha) = {sat:.3e} <= {(2*np.sqrt(2*d))**-1:.3e}; "
          f"E sech^2 = {es2:.3e} <= 8e^(4-2alpha) = {8*np.exp(4-2*alpha):.3e}")

print("== cosh y <= exp(y^2/2) => sech^2 y >= exp(-y^2): min over grid ==")
y = np.linspace(-30, 30, 600001)
print(np.min(np.log(sech2(y)+1e-300) + y**2) >= -1e-9)
