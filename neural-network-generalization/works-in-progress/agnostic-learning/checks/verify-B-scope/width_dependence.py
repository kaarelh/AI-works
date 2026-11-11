"""Does the obstruction "no choice of c(n) works" (B.md Cor 9.3, Section 0 table) depend on learner width?

Depth L = 3 (H = 2), repository architecture (xbar = (1,x), no internal biases, tanh, linear readout),
energy kappa_N = (d/N)|W1|_F^2 + |W2|_F^2 + N|v|^2, objective F_c = kappa_N + (1/c) sum_i (z(x_i)-y_i)^2.

Certificates used (valid for EVERY near-minimiser w, F_c(w) <= min F_c + 1, at the stated width):
  Lemma 2.3(b) of B.md with any explicit comparison network w' at the same width:
      R(z_w) <= R(z_w') + c (kappa(w') + 1)                  (R = atom-wise residual, Lemma 7.1(a))
  Noisy cube: excess >= (sqrt(Q/M) - sqrt(R(z_w)/M))_+^2       (Lemma 7.1(b,c), n = M)
  Two-point law: L_D(z_w) <= hat L(z_w) * n / (2 min(k+,k-))   and Prop 9.1(a) lower bound (1-eta)^2.

Part A  (noisy cube, d = 10, n = M = 1024, LARGE width N = 1024): explicit random-feature memoriser w'
         => certified failure for small c at this width.
Part B  (same sample, width N = 1): multi-start L-BFGS on F_c. ILLUSTRATION ONLY (optimisation is one-sided).
Part C  (steep two-point law with competitor weights n^alpha, alpha = 0.4 > 1/(2H)): certified success of
         small c at EVERY width (clone of the Lemma 9.2 network), certified failure of c = n^{1-theta},
         theta = 0.4 < 1/H, at every width (Prop 9.1(a)).
"""
import math
import numpy as np
from scipy.optimize import minimize

rng = np.random.default_rng(20261111)
d, H = 10, 2
M = 2 ** d
n = M
cube = np.array([[1 if (i >> j) & 1 else -1 for j in range(d)] for i in range(M)], dtype=float)
cubebar = np.hstack([np.ones((M, 1)), cube])

# ---- noisy-cube sample (with replacement) ----
idx = rng.integers(0, M, size=n)
ys = rng.choice([-1.0, 1.0], size=n)
k = np.bincount(idx, minlength=M).astype(float)
sumy = np.bincount(idx, weights=ys, minlength=M)
T = np.nonzero(k)[0]
kT = k[T]
ybarT = sumy[T] / kT
XbT = cubebar[T]
Q = float(np.sum(ybarT ** 2))
S1 = int(np.sum(kT == 1))
R0 = float(np.sum(kT * ybarT ** 2))  # residual of the zero network
print(f"noisy cube: d={d}, M=n={n}, seen atoms |T|={len(T)}, singletons S1={S1}, Q={Q:.1f}, Q/M={Q/M:.4f}, R(0)={R0:.1f}")


def forward(W1, W2, v, Xb):
    h1 = np.tanh(Xb @ W1.T)
    h2 = np.tanh(h1 @ W2.T)
    return h2 @ v, h1, h2


def kappa(W1, W2, v):
    N = v.shape[0]
    return (d / N) * np.sum(W1 ** 2) + np.sum(W2 ** 2) + N * np.sum(v ** 2)


def residual(W1, W2, v):
    z, _, _ = forward(W1, W2, v, XbT)
    return float(np.sum(kT * (z - ybarT) ** 2))


def cert_excess(Rbound):
    return max(0.0, math.sqrt(Q / M) - math.sqrt(max(Rbound, 0.0) / M)) ** 2


# ---------------- Part A ----------------
N = 1024
best = None
for s in [0.5, 1.0, 2.0, 3.0]:
    A = rng.normal(0.0, s, size=(N, d + 1))
    Phi = np.tanh(XbT @ A.T)                       # |T| x N
    for Rg in [2.0, 4.0, 8.0, 16.0, 32.0]:
        tau = Rg * np.arctanh(ybarT / Rg)          # so that Rg*tanh(g/Rg) = ybar exactly
        u, *_ = np.linalg.lstsq(Phi, tau, rcond=None)
        W1 = A
        W2 = np.tile(u / Rg, (N, 1))               # every layer-2 unit computes tanh(g/Rg)
        v = np.full(N, Rg / N)
        kap = kappa(W1, W2, v)
        res = residual(W1, W2, v)
        if best is None or kap + res * 1e3 < best[0] + best[1] * 1e3:
            best = (kap, res, s, Rg)
kapA, resA, sA, RA = best
print(f"\nPart A (width N={N}): explicit memoriser w' with feature scale {sA}, chain gain {RA}:"
      f" kappa(w')={kapA:.1f}, R(z_w')={resA:.2e}")
print("  c          certified test excess of EVERY near-minimiser at this width (OPT = 1)")
for c in [1e-4, 1e-3, 1e-2, 3e-2, 0.1, 1.0]:
    print(f"  {c:8.0e}   >= {cert_excess(resA + c * (kapA + 1)):.4f}")

# ---------------- Part B ----------------
def F_and_grad(theta, c, Nw):
    p = 0
    W1 = theta[p:p + Nw * (d + 1)].reshape(Nw, d + 1); p += Nw * (d + 1)
    W2 = theta[p:p + Nw * Nw].reshape(Nw, Nw); p += Nw * Nw
    v = theta[p:p + Nw]
    z, h1, h2 = forward(W1, W2, v, XbT)
    e = 2 * kT * (z - ybarT)
    gv = h2.T @ e
    g2 = np.outer(e, v) * (1 - h2 ** 2)
    gW2 = g2.T @ h1
    g1 = (g2 @ W2) * (1 - h1 ** 2)
    gW1 = g1.T @ XbT
    Rv = float(np.sum(kT * (z - ybarT) ** 2))
    F = kappa(W1, W2, v) + Rv / c
    grad = np.concatenate([(gW1 / c + 2 * (d / Nw) * W1).ravel(), (gW2 / c + 2 * W2).ravel(), gv / c + 2 * Nw * v])
    return F, grad


def test_excess(theta, Nw):
    p = 0
    W1 = theta[p:p + Nw * (d + 1)].reshape(Nw, d + 1); p += Nw * (d + 1)
    W2 = theta[p:p + Nw * Nw].reshape(Nw, Nw); p += Nw * Nw
    v = theta[p:p + Nw]
    z, _, _ = forward(W1, W2, v, cubebar)
    return float(np.mean(z ** 2)), kappa(W1, W2, v)


print("\nPart B (width 1; ILLUSTRATION, multi-start L-BFGS, 400 starts):")
print("  c        best F_c found    R(z)/R(0)    kappa     test excess E_x z(x)^2")
for c in [1e-3, 1e-2]:
    Nw = 1
    P = Nw * (d + 1) + Nw * Nw + Nw
    bestB = None
    for r in range(400):
        sc = 10 ** rng.uniform(-1, 1.5)
        th0 = rng.normal(0, sc, size=P)
        out = minimize(F_and_grad, th0, args=(c, Nw), jac=True, method='L-BFGS-B', options={'maxiter': 3000})
        if bestB is None or out.fun < bestB.fun:
            bestB = out
    te, kp = test_excess(bestB.x, Nw)
    Rb = bestB.fun - kp
    print(f"  {c:7.0e}   {bestB.fun:14.2f}    {Rb * c / R0:9.4f}   {kp:8.2f}    {te:.4f}")
print("  (compare Part A at width 1024: every near-minimiser has excess >= the certified values above)")

# ---------------- Part C ----------------
alpha, L = 0.4, 3
Bw = n ** alpha
delta0 = math.tanh(1) ** (-H) / (1 * Bw ** L)       # Lemma 9.2 with m = 1
t1 = math.tanh(Bw * delta0); t2 = math.tanh(Bw * t1); vC = 1 / t2
assert vC <= Bw
kapC = 1 * Bw ** 2 + Bw ** 2 + vC ** 2               # width-1 energy, d = 1: (1/1)B^2 + B^2 + 1*v^2 (clone energy equal)
xs = rng.choice([-1, 1], size=n)
kp_, km_ = int(np.sum(xs == 1)), int(np.sum(xs == -1))
print(f"\nPart C (two-point law, delta0={delta0:.3e}; competitor: width 1, weights <= n^alpha={Bw:.1f}, exact fit,"
      f" energy {kapC:.1f}); sample counts k+={kp_}, k-={km_}")
for c in [1e-3, 1e-2]:
    hatL = c * (kapC + 1) / n
    LD = hatL * n / (2 * min(kp_, km_))
    print(f"  c={c:7.0e}: every near-minimiser at EVERY width has L_D <= {LD:.2e}  (competitor: 0)")
theta = 0.4
K = n ** theta + 1
eta = delta0 * (K / L) ** (L / 2)
print(f"  c=n^(1-theta), theta={theta} (<1/H): eta={eta:.3e}; every near-minimiser at EVERY width has L_D >= {(1 - eta) ** 2:.4f}")
