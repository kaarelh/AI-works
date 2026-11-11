# Remark 6(c) of RT-width.fixed.md says it is not shown that a BEST-IN-CLASS competitor g* can have
# loss fluctuations of order (Ubar+1)/sqrt(n).  Probe (depth L=2, d=1): a steep step that the class can
# only fit at maximal slope, plus a rare point at x=1 where such a fit overshoots to ~Ubar.
#   D: x=-eps (y=-1) and x=+eps (y=+1), each w.p. (1-p)/2;  x=1 (y=+1) w.p. p = cc/Ubar^2,
#   eps = 1/(m B^2) (the largest slope a width-m, weight-B depth-2 net can have at 0 is m B^2).
# We minimise L_D over the box-constrained class (many restarts) and report sd((g*(x)-y)^2)/Ubar.
import numpy as np
from scipy.optimize import minimize
rng = np.random.default_rng(11)

def make(m, B, cc):
    U = m * B; eps = 1.0 / (m * B * B); p = cc / U**2
    xs = np.array([-eps, eps, 1.0]); ys = np.array([-1.0, 1.0, 1.0]); ps = np.array([(1 - p) / 2, (1 - p) / 2, p])
    return U, eps, p, xs, ys, ps

def net(theta, m, x):
    W = theta[:2 * m].reshape(m, 2); u = theta[2 * m:]
    return np.tanh(np.outer(x, W[:, 1]) + W[:, 0][None, :]) @ u

def LD(theta, m, xs, ys, ps):
    r = net(theta, m, xs) - ys
    return float(ps @ r**2)

for (m, B, cc) in [(2, 6.0, 0.5), (3, 8.0, 0.5), (4, 10.0, 0.5), (4, 10.0, 2.0), (6, 12.0, 0.5)]:
    U, eps, p, xs, ys, ps = make(m, B, cc)
    best = None
    for r in range(400):
        th0 = rng.uniform(-B, B, size=3 * m)
        if r % 4 == 0:  # seed near the max-slope solution
            th0 = np.concatenate([np.column_stack([rng.normal(0, 0.1, m), B * np.ones(m)]).ravel(), B * rng.uniform(0.3, 1, m)])
        res = minimize(LD, th0, args=(m, xs, ys, ps), method='L-BFGS-B', bounds=[(-B, B)] * (3 * m))
        if best is None or res.fun < best.fun:
            best = res
    g = net(best.x, m, xs)
    loss = (g - ys) ** 2
    mean = ps @ loss; sd = np.sqrt(ps @ (loss - mean) ** 2)
    print("m=%d B=%.0f Ubar=%.0f p=%.2e: L_D(g*)=%.4f  g*(-eps,eps,1)=(%.3f, %.3f, %.2f)  sd(loss)/Ubar=%.3f  L_D(0)=1"
          % (m, B, U, p, mean, g[0], g[1], g[2], sd / U))
print("If sd(loss)/Ubar stays bounded below, the best-in-class competitor fluctuates at order Ubar/sqrt(n),")
print("so the chain of Theorem 1(b)/Corollary 2 applied to g* cannot give a rate below Ubar/sqrt(n) for this law.")
