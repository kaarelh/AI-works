"""Constants and derivative bounds used in E-finite-prior-scale.md Lemmas 4.1-4.3 (smoothed activations,
parity features, noisy chain) and Pi_*.  Gauss-Hermite quadrature for Gaussian expectations.
kappa(q) = E sech^2(sqrt(q) G) below is varpi(q) in the text."""
import numpy as np
from numpy.polynomial.hermite_e import hermegauss

xg, wg = hermegauss(200); wg = wg/np.sqrt(2*np.pi)
E = lambda f: np.sum(wg*f(xg))
sech2 = lambda y: 1/np.cosh(y)**2

# derivative sup bounds
y = np.linspace(-20, 20, 2000001)
t = np.tanh(y); s2 = sech2(y)
d3tanh = -2*s2*(1-3*t**2)          # tanh'''
d2sech2 = 2*s2*(3*t**2-1)          # (sech^2)''
d2tanh2 = 2*s2*(1-3*t**2)          # (tanh^2)''
print("sup|tanh'''| =", np.abs(d3tanh).max(), "(claim 2)")
print("sup|(sech^2)''| =", np.abs(d2sech2).max(), "(claim <=2)")
print("sup|(tanh^2)''| =", np.abs(d2tanh2).max(), "(claim <=2)")
# numerical-derivative cross-check
h = y[1]-y[0]
num3 = np.gradient(np.gradient(np.gradient(np.tanh(y), h), h), h)
print("max |tanh''' formula - numeric| (interior) =", np.abs(num3-d3tanh)[100:-100].max())

kappa = lambda q: E(lambda g: sech2(np.sqrt(q)*g))
F = lambda q: E(lambda g: np.tanh(np.sqrt(q)*g)**2)
print("kappa(1)=E sech^2(G) =", kappa(1.0))
print("F(1)=E tanh^2(G) =", F(1.0))
qs = np.linspace(0, 1, 1001)
kv = np.array([kappa(q) for q in qs]); Fv = np.array([F(q) for q in qs])
print("min_q<=1 kappa(q) - (1+2q)^(-1/2) =", (kv - (1+2*qs)**-0.5).min(), "(claim >=0)")
print("max |kappa'| on [0,1] =", np.abs(np.diff(kv)/np.diff(qs)).max(), "(claim <=1)")
print("max |F'| on [0,1] =", np.abs(np.diff(Fv)/np.diff(qs)).max(), "(claim <=1)")
print("kappa decreasing on [0,1]:", np.all(np.diff(kv) < 0))

# Pi*_H(tau): q1=1, q_{l}=F_tau(q_{l-1}), kappa*_l = kappa(tau^2 q_l), Pi* = prod_{l=1}^{H-1}
def pistar(H, tau):
    q = 1.0; P = 1.0
    for l in range(1, H):
        P *= kappa(tau**2*q)
        q = E(lambda g: np.tanh(tau*np.sqrt(q)*g)**2)
    return P
for H in range(2, 7):
    print(f"H={H}: Pi*(tau=1)={pistar(H,1.0):.4f}, Pi*(tau=0.5)={pistar(H,0.5):.4f}, lower bound 3^-(H-1)/2={3**(-(H-1)/2):.4f}")

# chain-remainder check: |psi_q(u) - kappa(q) u| <= |u|^3/3, and |Q(u,q)-Q(0,q)| <= u^2
worst1 = 0; worst2 = 0
for q in [0.0, 0.1, 0.5, 1.0]:
    for u in np.linspace(-1.5, 1.5, 301):
        psi = E(lambda g: np.tanh(u+np.sqrt(q)*g)); k = kappa(q)
        if u != 0: worst1 = max(worst1, abs(psi-k*u)/(abs(u)**3/3))
        Qu = E(lambda g: np.tanh(u+np.sqrt(q)*g)**2); Q0 = E(lambda g: np.tanh(np.sqrt(q)*g)**2)
        if u != 0: worst2 = max(worst2, abs(Qu-Q0)/u**2)
print("max |psi_q(u)-kappa(q)u| / (|u|^3/3) =", worst1, "(claim <=1)")
print("max |Q(u,q)-Q(0,q)| / u^2 =", worst2, "(claim <=1)")

# first-layer saturation constants: 1-psi_1(alpha) <= 2 e^{4-2alpha}; E sech^2(alpha t + tau tau_d G) <= 8 e^{4-2alpha}
for d in [2, 10, 40]:
    taud = np.sqrt((d+1)/d)
    for alpha in [2.5, 3.5, 5.0]:
        one_minus_psi = E(lambda g: 1-np.tanh(alpha+taud*g))
        es2 = max(E(lambda g: sech2(alpha*tt+taud*g)) for tt in [1, 3, 5])
        print(f"d={d}, alpha={alpha}: 1-psi1(alpha)={one_minus_psi:.3e} <= {2*np.exp(4-2*alpha):.3e}; max E sech^2={es2:.3e} <= {8*np.exp(4-2*alpha):.3e}")

# sech^2(y) >= exp(-y^2)
print("min sech^2(y)-exp(-y^2) =", (s2-np.exp(-y**2)).min(), "(claim >=0)")
