"""Check of Lemma B1.4: the exact worst-case per-coordinate Adam step.

For Adam with bias correction, step_t = lr * mhat_t / (sqrt(vhat_t) + eps).  The lemma says
    sup_{g_1..g_t} |mhat_t| / sqrt(vhat_t) = C_t
      = (1-b1)/(1-b1^t) * sqrt((1-b2^t)/(1-b2)) * sqrt((1-r^t)/(1-r)),   r = b1^2/b2,
attained by g_s proportional to (b2/b1)^s (all of one sign), simultaneously for every t.
This script (i) compares the closed form with the ratio produced by that sequence, (ii) runs a
random search plus local ascent to confirm nothing beats it, (iii) prints sum_{t<=T} C_t,
and (iv) prints Kingma-Ba's "sparse case" value (1-b1)/sqrt(1-b2) for comparison.
Runs in a few seconds.
"""
import numpy as np
from scipy.optimize import minimize

b1, b2 = 0.9, 0.999
r = b1 ** 2 / b2

def C(t):
    return (1 - b1) / (1 - b1 ** t) * np.sqrt((1 - b2 ** t) / (1 - b2)) * np.sqrt((1 - r ** t) / (1 - r))

def ratio(g):
    t = len(g)
    m = v = 0.0
    for s in range(t):
        m = b1 * m + (1 - b1) * g[s]
        v = b2 * v + (1 - b2) * g[s] ** 2
    mh, vh = m / (1 - b1 ** t), v / (1 - b2 ** t)
    return abs(mh) / np.sqrt(vh)

print("t   closed-form C_t   ratio for g_s=(b2/b1)^s   best random/local search")
rng = np.random.default_rng(0)
for t in [1, 2, 3, 5, 10, 20, 50, 100]:
    g = (b2 / b1) ** np.arange(t)
    best = 0.0
    for trial in range(20):
        x0 = rng.standard_normal(t) * np.exp(rng.uniform(0, 3) * np.arange(t) / max(t, 1))
        res = minimize(lambda x: -ratio(x), x0, method="L-BFGS-B")
        best = max(best, -res.fun, ratio(x0))
    print(f"{t:4d}  {C(t):.6f}         {ratio(g):.6f}                 {best:.6f}")

Cinf = (1 - b1) / np.sqrt((1 - b2) * (1 - r))
print(f"\nC_inf = (1-b1)/sqrt((1-b2)(1-b1^2/b2)) = {Cinf:.4f}")
print(f"Kingma-Ba sparse-case value (1-b1)/sqrt(1-b2) = {(1 - b1) / np.sqrt(1 - b2):.4f}")
for T in [10, 100, 1000, 20000]:
    S = sum(C(t) for t in range(1, T + 1))
    print(f"sum_(t<=T) C_t for T={T:6d}: {S:10.2f}   (= {S / T:.3f} * T)")
# constant gradients give ratio exactly 1 at every t (no movement amplification)
print("constant gradient, t=50:", ratio(np.ones(50)))
# a plateau followed by a sudden rise: how close to C_inf does a realistic 'escape' get?
g = np.concatenate([1e-3 * np.ones(200), 1e-3 * 1.05 ** np.arange(100)])
print("plateau then 5%/step growth, ratio at end:", round(ratio(g), 3))
