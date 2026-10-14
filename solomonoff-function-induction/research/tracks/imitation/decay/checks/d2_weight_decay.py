"""d2: weight decay as a per-sample penalty; a toy where the regularised limit classifies worse
(sub-track "decay", target I2). Deterministic or seeded. Python 3.11, NumPy, SciPy.
Output: d2_weight_decay.out (same folder).

Toy (notes Example 4.3). Labels y uniform in {-1,+1}; xi = +1 with probability 1-q, -1 with q,
independent; input x = (eps*y, xi*y). Logistic model p_theta(y|x) = sigmoid(y theta.x), no bias.
With z := y x in {(eps, 1) w.p. 1-q, (eps, -1) w.p. q}, the population log loss (nats) is
    L(theta) = (1-q) s(eps th1 + th2) + q s(eps th1 - th2),   s(u) = ln(1 + e^{-u}),
inf L = 0 (not attained), and the 0-1 error of theta (th1, th2 > 0) is q * [eps th1 <= th2].

Parts
 (A) The population-regularised minimiser theta*(wd) of F = L + (wd/2)|theta|^2: closed-form threshold
     wd*, a scan of wd, the sign change of b = eps th1 - th2 at wd*, the excess-loss bound.
 (B) Empirical minimisers on n i.i.d. samples: fixed wd (per-sample penalty, prior precision n wd)
     against wd_n = tau/n (a fixed Gaussian prior N(0, I/tau) on the summed loss).
 (C) Minibatch SGD with coupled weight decay reaches the regime of (B).
 (D) AdamW (decoupled) against Adam on F (L2 in the loss), full batch on L: different limits.
 (E) Per-step decay: fixed points of theta <- theta - eta_t (alpha grad L + lam theta) minimise
     L + (lam/(2 alpha))|theta|^2, so the effective L2 coefficient depends on the learning rate alpha;
     before convergence the iterate depends on eta*T.
"""
import math

import numpy as np
from scipy.optimize import brentq, minimize

EPS = 0.1
Q = 0.2


def s(u):
    return np.logaddexp(0.0, -u)


def sig(u):
    return 0.5 * (1.0 + np.tanh(0.5 * u))


def loss_grad_hess(th, w_plus, w_minus):
    """Weighted logistic loss over the two atoms z+ = (EPS, 1), z- = (EPS, -1); weights sum to 1."""
    a = EPS * th[0] + th[1]
    b = EPS * th[0] - th[1]
    val = w_plus * s(a) + w_minus * s(b)
    ga, gb = -sig(-a), -sig(-b)  # d s(u)/du
    g = np.array([w_plus * ga * EPS + w_minus * gb * EPS, w_plus * ga - w_minus * gb])
    ha, hb = sig(a) * sig(-a), sig(b) * sig(-b)
    Hm = np.array([[EPS * EPS * (w_plus * ha + w_minus * hb), EPS * (w_plus * ha - w_minus * hb)],
                   [EPS * (w_plus * ha - w_minus * hb), w_plus * ha + w_minus * hb]])
    return val, g, Hm


def reg_min(wd, w_plus=1 - Q, w_minus=Q, th0=None):
    """Newton's method on L_w + (wd/2)|th|^2 (strictly convex for wd > 0)."""
    th = np.zeros(2) if th0 is None else th0.copy()
    for _ in range(500):
        _, g, Hm = loss_grad_hess(th, w_plus, w_minus)
        g = g + wd * th
        Hm = Hm + wd * np.eye(2)
        step = np.linalg.solve(Hm, g)
        # damped Newton with backtracking on F
        F0 = loss_grad_hess(th, w_plus, w_minus)[0] + 0.5 * wd * th @ th
        t = 1.0
        while True:
            thn = th - t * step
            Fn = loss_grad_hess(thn, w_plus, w_minus)[0] + 0.5 * wd * thn @ thn
            if Fn <= F0 - 1e-4 * t * g @ step or t < 1e-12:
                break
            t *= 0.5
        th = thn
        if np.linalg.norm(step) < 1e-13:
            break
    return th


def err01(th):
    a = EPS * th[0] + th[1]
    b = EPS * th[0] - th[1]
    return (1 - Q) * (a <= 0) + Q * (b <= 0)


def pop_loss(th):
    return loss_grad_hess(th, 1 - Q, Q)[0]


print("=" * 100)
print(f"(A) Population-regularised minimiser, eps = {EPS}, q = {Q}")
print("=" * 100)
sb = Q * (1 + EPS**2) / (2 * (1 - Q) * (1 - EPS**2))  # sigma(-a*) at the threshold
a_star = math.log(1.0 / sb - 1.0)
wd_star = 2 * Q * EPS**2 / ((1 - EPS**2) * a_star)
print(f"closed form: sigma(-a*) = q(1+eps^2)/(2(1-q)(1-eps^2)) = {sb:.6f}, a* = {a_star:.6f}, "
      f"wd* = 2 q eps^2/((1-eps^2) a*) = {wd_star:.6e}")
print(f"  condition for a* > 0: q(1+eps^2) < (1-q)(1-eps^2): {Q * (1 + EPS**2):.4f} < {(1 - Q) * (1 - EPS**2):.4f}")
b_of = lambda wd: (lambda th: EPS * th[0] - th[1])(reg_min(wd))
wd_root = brentq(b_of, 1e-4, 1e-1, xtol=1e-15, rtol=1e-14)
print(f"numerical root of b(wd) = eps th1 - th2: {wd_root:.6e} (relative difference {abs(wd_root - wd_star) / wd_star:.1e})")
th_s = reg_min(wd_star)
print(f"theta*(wd*) = ({th_s[0]:.6f}, {th_s[1]:.6f}); predicted (a*/(2 eps), a*/2) = ({a_star / (2 * EPS):.6f}, {a_star / 2:.6f})")
print(f"{'wd':>10} {'theta1':>10} {'theta2':>10} {'b=eps*th1-th2':>14} {'0-1 error':>10} {'pop. log loss':>14} {'|theta|^2':>10}")
for wd in [1e-5, 1e-4, 5e-4, 1e-3, 2e-3, 2.2e-3, 3e-3, 5e-3, 1e-2, 3e-2, 1e-1, 1.0]:
    th = reg_min(wd)
    print(f"{wd:>10.1e} {th[0]:>10.4f} {th[1]:>10.4f} {EPS * th[0] - th[1]:>14.5f} {err01(th):>10.3f} {pop_loss(th):>14.6f} {th @ th:>10.3f}")
print("inf over theta of the population log loss = 0 (along theta = (t, 0), t -> inf; error 0 there).")
# excess-loss bound: L(th*) - L(th) <= (wd/2)(|th|^2 - |th*|^2) for every th
worst = -np.inf
rg = np.random.default_rng(3)
for wd in [1e-3, 1e-2, 1e-1]:
    th_w = reg_min(wd)
    for _ in range(20000):
        th = rg.normal(0, 30, size=2)
        lhs = pop_loss(th_w) - pop_loss(th)
        rhs = 0.5 * wd * (th @ th - th_w @ th_w)
        worst = max(worst, lhs - rhs)
print(f"max over 60000 random theta of [L(th*) - L(th)] - (wd/2)(|th|^2 - |th*|^2): {worst:.2e} (<= 0 expected)")

print()
print("=" * 100)
print("(B) Empirical minimisers: fixed wd (prior precision n*wd) against wd_n = tau/n (fixed prior)")
print("=" * 100)
ns = [100, 1000, 10000, 100000, 1000000]
seeds = range(20)
rows = []
for scheme, wd_fn in [("wd = 0.01", lambda n: 0.01), ("wd = 0.003", lambda n: 0.003),
                      ("wd = 1/n (tau=1)", lambda n: 1.0 / n), ("wd = 10/n (tau=10)", lambda n: 10.0 / n)]:
    line = []
    for n in ns:
        errs = []
        for sd in seeds:
            rg = np.random.default_rng(10_000 + sd)
            n_minus = rg.binomial(n, Q)
            if n_minus == 0 or n_minus == n:
                pass
            th = reg_min(wd_fn(n), w_plus=(n - n_minus) / n, w_minus=n_minus / n)
            errs.append(err01(th))
        errs = np.array(errs)
        line.append(f"{errs.mean():.3f} ({(errs > 0).sum():>2}/20)")
    print(f"{scheme:>20}: " + "  ".join(f"n={n}: {v}" for n, v in zip(ns, line)))
print("entries: mean population 0-1 error of the empirical minimiser over 20 seeds (number of seeds with error q).")
print(f"wd* = {wd_star:.3e}: fixed wd above it keeps error q = {Q} at every n; tau/n falls below it once n > tau/wd*.")

print()
print("=" * 100)
print("(C) Minibatch SGD with coupled weight decay, n = 10000 samples, batch 32")
print("=" * 100)
n = 10000
rg = np.random.default_rng(424242)
xi = np.where(rg.random(n) < Q, -1.0, 1.0)
Z = np.stack([np.full(n, EPS), xi], axis=1)  # z_i = y_i x_i
for wd, epochs, lr in [(0.01, 60, 0.5), (1.0 / n, 400, 2.0)]:
    th = np.zeros(2)
    steps = 0
    for ep in range(epochs):
        perm = rg.permutation(n)
        eta = lr / math.sqrt(1 + ep)
        for i0 in range(0, n, 32):
            zb = Z[perm[i0:i0 + 32]]
            u = zb @ th
            g = -(sig(-u)[:, None] * zb).mean(axis=0)
            th = th - eta * (g + wd * th)  # PyTorch-style SGD weight decay: gradient of L_B + (wd/2)|th|^2
            steps += 1
    nm = (xi < 0).sum()
    th_emp = reg_min(wd, w_plus=(n - nm) / n, w_minus=nm / n)
    print(f"wd = {wd:.1e}: SGD after {steps} steps: theta = ({th[0]:.3f}, {th[1]:.3f}), error {err01(th):.3f}; "
          f"empirical minimiser ({th_emp[0]:.3f}, {th_emp[1]:.3f}), error {err01(th_emp):.3f}")

print()
print("=" * 100)
print("(D) Full batch on L: Adam on L + (wd/2)|theta|^2 against AdamW with decoupled decay lam")
print("=" * 100)


def adam_run(lam, decoupled, T=200000, lr0=0.05, b1=0.9, b2=0.999, ea=1e-8):
    th = np.zeros(2)
    m = np.zeros(2)
    v = np.zeros(2)
    for t in range(1, T + 1):
        _, g, _ = loss_grad_hess(th, 1 - Q, Q)
        if not decoupled:
            g = g + lam * th
        m = b1 * m + (1 - b1) * g
        v = b2 * v + (1 - b2) * g * g
        mh = m / (1 - b1**t)
        vh = v / (1 - b2**t)
        eta = lr0 / math.sqrt(1 + t / 1000.0)  # non-increasing, divergent partial sums
        step = mh / (np.sqrt(vh) + ea)
        if decoupled:
            th = th - eta * (step + lam * th)
        else:
            th = th - eta * step
    return th


def box_min(lam):
    r = minimize(lambda t: loss_grad_hess(t, 1 - Q, Q)[0], x0=np.zeros(2),
                 jac=lambda t: loss_grad_hess(t, 1 - Q, Q)[1], method="L-BFGS-B",
                 bounds=[(-1 / lam, 1 / lam)] * 2, options={"ftol": 1e-15, "gtol": 1e-12, "maxiter": 10000})
    return r.x


print(f"{'coef':>8} | {'Adam on F: theta':>22} {'err':>6} {'argmin F':>22} | {'AdamW: theta':>22} {'err':>6} {'box argmin, |th|_inf<=1/lam':>30}")
for lam in [0.001, 0.003, 0.01, 0.05, 0.1, 0.2, 0.5]:
    tA = adam_run(lam, decoupled=False)
    tF = reg_min(lam)
    tW = adam_run(lam, decoupled=True)
    tB = box_min(lam)
    print(f"{lam:>8.3f} | ({tA[0]:>9.4f},{tA[1]:>9.4f}) {err01(tA):>6.3f} ({tF[0]:>9.4f},{tF[1]:>9.4f}) | "
          f"({tW[0]:>9.4f},{tW[1]:>9.4f}) {err01(tW):>6.3f} ({tB[0]:>9.4f},{tB[1]:>9.4f}) err {err01(tB):.3f}")
# threshold for the box problem: th1 = 1/lam, th2 solves (1-q) sig(-(eps/lam + th2)) = q sig(-(eps/lam - th2)) if interior
def box_b(lam):
    tB = box_min(lam)
    return EPS * tB[0] - tB[1]
lam_box = brentq(box_b, 0.01, 1.0, xtol=1e-12)
print(f"error switches from 0 to q at wd* = {wd_star:.4e} for L2 (Adam on F, SGD) and at lam = {lam_box:.4f} for the box problem")

print()
print("=" * 100)
print("(E) Per-step decay: fixed points and finite T")
print("=" * 100)
lam = 0.01
for alpha in [0.1, 0.5, 2.0]:
    th = np.zeros(2)
    for t in range(1, 200001):
        eta_t = 1.0 / math.sqrt(1 + t / 1000.0)  # schedule multiplier
        _, g, _ = loss_grad_hess(th, 1 - Q, Q)
        th = th - eta_t * (alpha * g + lam * th)  # SGDW-style: decay not multiplied by alpha
    tF = reg_min(lam / alpha)
    print(f"alpha = {alpha}: limit ({th[0]:.4f}, {th[1]:.4f}), error {err01(th):.3f}; argmin L + (lam/(2 alpha))|th|^2 = "
          f"({tF[0]:.4f}, {tF[1]:.4f}), error {err01(tF):.3f}")
wd = 0.01
print(f"coupled GD on F, wd = {wd}, from theta = 0, stopped after T steps (no convergence):")
for eta, T in [(0.1, 1000), (0.01, 10000), (1.0, 100), (0.1, 100), (0.1, 100000)]:
    th = np.zeros(2)
    for _ in range(T):
        _, g, _ = loss_grad_hess(th, 1 - Q, Q)
        th = th - eta * (g + wd * th)
    print(f"  eta = {eta:<5} T = {T:<7} eta*T = {eta * T:<8g}: theta = ({th[0]:.4f}, {th[1]:.4f}), error {err01(th):.3f}")
tF = reg_min(wd)
print(f"  argmin F = ({tF[0]:.4f}, {tF[1]:.4f}), error {err01(tF):.3f}")
print(f"  a coordinate with zero loss gradient shrinks by (1 - eta wd)^T, e.g. eta = 0.1, T = 1000: {(1 - 0.1 * wd) ** 1000:.4f}"
      f" (exp(-wd eta T) = {math.exp(-wd * 0.1 * 1000):.4f})")
wd = 0.001
print(f"coupled GD on F, wd = {wd} < wd* (converged minimiser classifies perfectly), eta = 0.1, stopped after T steps:")
th = np.zeros(2)
done = 0
for T in [10, 100, 1000, 3000, 10000, 100000, 1000000]:
    while done < T:
        _, g, _ = loss_grad_hess(th, 1 - Q, Q)
        th = th - 0.1 * (g + wd * th)
        done += 1
    print(f"  T = {T:<8}: theta = ({th[0]:.4f}, {th[1]:.4f}), b = {EPS * th[0] - th[1]:+.4f}, error {err01(th):.3f}")
tF = reg_min(wd)
print(f"  argmin F = ({tF[0]:.4f}, {tF[1]:.4f}), error {err01(tF):.3f}")
