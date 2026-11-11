"""Section 9 example: D uniform on {(-delta0,-1), (delta0,+1)}, d = 1, clean labels.
(a) Chain competitor of width 1, depth L, weights omega = delta0^{-1/L}: exact fit, readout v <= 1.5 omega, energy.
(b) Lemma: kappa <= K  =>  |z(delta0) - z(-delta0)| <= 2 delta0 (K/L)^{L/2}  =>  L_D >= (1-eta)^2.
(c) L-BFGS minimization of F_c (c = n^{1-theta}) on a sample: test loss of the best network found,
    compared with the competitor (test loss 0) and with the theorem's guarantee regime."""
import numpy as np, math
from nn_utils import *
rng = np.random.default_rng(11)

def chain(delta0, L):
    H = L - 1; om = delta0 ** (-1 / L)
    t = delta0
    for _ in range(H): t = math.tanh(om * t)
    v = 1 / t
    return om, v, H * om ** 2 + v ** 2     # energy: first layer om^2 (d=1), (H-1) internal om^2, readout v^2

print("(a) chain competitor at delta0 = (1/2)(L/(n^theta+1))^{L/2}:")
print("  L  theta      n     n^theta   delta0      omega    v/omega   energy   energy/n^theta")
for L in [2, 3, 4]:
    for theta in [0.2, 0.3]:
        for n in [10 ** 3, 10 ** 5, 10 ** 7]:
            K = n ** theta + 1; delta0 = 0.5 * (L / K) ** (L / 2)
            om, v, E = chain(delta0, L)
            print(f"  {L}  {theta:.1f}  {n:9d}  {n**theta:8.2f}  {delta0:.3e}  {om:8.3f}  {v/om:7.4f}  {E:8.2f}   {E/n**theta:6.3f}")

print("\n(c) minimizing F_c over width-8 networks on the two-point law (L-BFGS, 6 restarts):")
print("  L  theta     n   delta0     n^theta  min F_c found  F_c(0-net)  F_c(chain)  test loss found  lower bound (1-eta)^2")
for (L, theta, n, delta0) in [(3, 0.3, 2000, None), (3, 0.3, 2000, 0.5), (2, 0.4, 2000, None), (2, 0.4, 2000, 0.5)]:
    H = L - 1; c = n ** (1 - theta); K = n ** theta + 1
    if delta0 is None: delta0 = 0.5 * (L / K) ** (L / 2)
    xs = rng.choice([-delta0, delta0], size=n); X = xs[:, None]; y = np.sign(xs)
    kp = np.sum(y > 0); km = n - kp
    F, th = minimize_Fc(X, y, c, 1, 8, H, rng, restarts=6, maxiter=4000)
    Ws, v = unflatten(th, 1, 8, H)
    zp, zm = forward(Ws, v, np.array([[delta0], [-delta0]]))
    test = 0.5 * ((zp - 1) ** 2 + (zm + 1) ** 2)
    om, vv, Ech = chain(delta0, L)
    F0 = n / c                                   # zero network: (1/c) sum y_i^2
    eta = delta0 * (K / L) ** (L / 2)
    lb = (1 - eta) ** 2 if eta <= 1 else 0.0
    print(f"  {L}  {theta:.1f}  {n:5d}  {delta0:.4f}  {n**theta:8.3f}   {F:10.3f}   {F0:9.3f}   {Ech:9.3f}     {test:9.4f}        {lb:.4f}")
