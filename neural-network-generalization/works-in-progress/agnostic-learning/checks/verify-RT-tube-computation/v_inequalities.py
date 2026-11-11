"""Random and exact checks of every scalar inequality in the proof of
red-team Proposition 4.1 (TUBE with a sup-norm residual budget).

Notation: g = teacher value, y = label (|y|<=1, |y-g|<=rho0), z = learner output,
h = cover centre with |h - z| <= a.  All checks are pointwise in x, which is
all the proof needs (the sup over X is taken afterwards).
"""
import numpy as np
import sympy as sp

rng = np.random.default_rng(20261111)
T = 4_000_000
clip = lambda u: np.clip(u, -1.0, 1.0)


def draw_g_y(T):
    rho0 = rng.uniform(0.0, 1.5, T)
    g = rng.uniform(-2.5, 2.5, T)
    lo = np.maximum(-1.0, g - rho0)
    hi = np.minimum(1.0, g + rho0)
    ok = lo <= hi                      # law exists only if [g-rho0,g+rho0] meets [-1,1]
    y = lo + (hi - lo) * rng.uniform(0, 1, T)
    # put a quarter of the mass on the extreme residuals |y-g| = rho0
    ext = rng.uniform(0, 1, T) < 0.25
    s = np.where(rng.uniform(0, 1, T) < 0.5, -1.0, 1.0)
    y_ext = g + s * rho0
    use = ext & (np.abs(y_ext) <= 1)
    y = np.where(use, y_ext, y)
    return rho0[ok], g[ok], y[ok]


print("=== (1) denominator: U_{rho-rho0}(g) lies in the conditioning event ===")
rho0, g, y = draw_g_y(T)
m = len(g)
rho = rho0 + rng.uniform(1e-9, 1.5, m)
z = g + (rho - rho0) * rng.uniform(-1, 1, m) * (1 - 1e-12)   # |z-g| < rho-rho0
viol = np.abs(z - y) >= rho
print(f"samples {m}, violations of |z-y|<rho: {viol.sum()}, max |z-y|-rho = {np.max(np.abs(z-y)-rho):.3e}")

print("=== (2) cover step, training side: |h(x_i)-g(x_i)| < rho+rho0+a ===")
a = rng.uniform(0, 1, m)
z = y + rho * rng.uniform(-1, 1, m) * (1 - 1e-12)           # feasible: |z-y|<rho
h = z + a * rng.uniform(-1, 1, m)                           # |h-z|<=a
viol = np.abs(h - g) >= rho + rho0 + a
print(f"violations: {viol.sum()}, max |h-g|-(rho+rho0+a) = {np.max(np.abs(h-g)-(rho+rho0+a)):.3e}")
# tightness: the bound rho+rho0+a is approached
print(f"  sup of |h-g|/(rho+rho0+a) over samples = {np.max(np.abs(h-g)/(rho+rho0+a)):.6f} (tight -> 1)")

print("=== (3) cover step, test side: |z-g|>tau and 2a<=tau-rho-rho0 imply |h-g|>rho+rho0+a ===")
tau = rho + rho0 + rng.uniform(1e-9, 2, m)
gap = tau - rho - rho0
a = gap / 2 * rng.uniform(0, 1, m)            # 2a <= gap (boundary allowed)
a[: m // 10] = gap[: m // 10] / 2             # 10% exactly on the boundary 2a = gap
zz = g + np.where(rng.uniform(0, 1, m) < .5, -1, 1) * (tau + rng.exponential(0.3, m) + 1e-12)
hh = zz + a * rng.uniform(-1, 1, m)
hh[: m // 20] = zz[: m // 20] - np.sign(zz[: m // 20] - g[: m // 20]) * a[: m // 20]  # worst case
viol = np.abs(hh - g) <= rho + rho0 + a
print(f"violations: {viol.sum()} (boundary 2a = tau-rho-rho0 included: strictness of 2a<... is not needed)")

print("=== (4) a = min{1/2,(tau-rho-rho0)/4}: 2a < gap and 1/a <= 4u' ===")
gaps = np.concatenate([rng.uniform(1e-8, 5, 10**6), [1e-8, 0.5, 1.0, 1.999, 2.0, 2.001, 10.0]])
aa = np.minimum(0.5, gaps / 4)
up = 1 / np.minimum(1.0, gaps)
print(f"2a<gap fails: {(2*aa >= gaps).sum()};  1/a <= 4u' fails: {(1/aa > 4*up*(1+1e-15)).sum()};"
      f"  max (1/a)/(4u') = {np.max((1/aa)/(4*up)):.6f}")

print("=== (5) risk: (clip z - y)^2 <= min{4, (|z-g|+rho0)^2} ===")
rho0, g, y = draw_g_y(T)
z = rng.uniform(-6, 6, len(g))
lhs = (clip(z) - y) ** 2
rhs = np.minimum(4.0, (np.abs(z - g) + rho0) ** 2)
print(f"samples {len(g)}, violations: {(lhs > rhs + 1e-12).sum()}, max lhs-rhs = {np.max(lhs-rhs):.3e}")
# without |y|<=1 the clip step fails: example
print("  counterexample if |y|>1 were allowed: y=1.5,g=1.5,rho0=0,z=1.5:",
      (np.clip(1.5, -1, 1) - 1.5) ** 2, "> (|z-g|+rho0)^2 =", 0.0)

print("=== (6) clipped loss is 4-Lipschitz in the prediction (for the sharper bound) ===")
y = rng.uniform(-1, 1, T); z = rng.uniform(-5, 5, T); h = z + rng.uniform(-1, 1, T)
lhs = np.abs((clip(z) - y) ** 2 - (clip(h) - y) ** 2)
print(f"max |diff|/|z-h| = {np.max(lhs/np.abs(z-h)):.6f} (<= 4)")

print("=== (7) refined risk constant: E(tau+|g-y|)^2 <= (tau+sqrt(L_D(g)))^2 <= (tau+rho0)^2 ===")
worst = -np.inf
for _ in range(20000):
    k = rng.integers(1, 8)
    rho0_ = rng.uniform(0, 1)
    r = rho0_ * rng.uniform(0, 1, k)             # |g-y| values
    p = rng.dirichlet(np.ones(k))
    tau_ = rng.uniform(0, 3)
    lhs = np.sum(p * (tau_ + r) ** 2)
    mid = (tau_ + np.sqrt(np.sum(p * r ** 2))) ** 2
    rhs = (tau_ + rho0_) ** 2
    worst = max(worst, lhs - mid, mid - rhs)
print(f"max violation (should be <= 0): {worst:.3e}")

print("=== (8) arithmetic of the example and of the admissible constants (sympy) ===")
r0, r, t = sp.symbols('rho0 rho tau', positive=True)
expr = (t + r0) ** 2
print("rho=2rho0, tau=4rho0: tau-(rho+rho0) =", sp.simplify(4*r0 - 3*r0), "; (tau+rho0)^2 =", sp.expand(expr.subs({t: 4*r0})))
print("u' at rho=2rho0,tau=4rho0: 1/min{1, tau-rho-rho0} = 1/min{1,", sp.simplify(4*r0-2*r0-r0), "}")
print("inf over rho>rho0, tau>rho+rho0 of (tau+rho0)^2 = (3 rho0)^2 =", sp.expand((3*r0)**2), "(not attained; u'->inf)")
for c, name in [(25, 'stated constants 25'), (9, 'best constants 9')]:
    print(f"  {name}: bound < 4 (non-trivial vs clipped range) iff rho0 < {sp.nsimplify(sp.sqrt(sp.Rational(4, c)))};"
          f" bound < 1 (can beat L_D(0)<=1 at all) iff rho0 < {sp.nsimplify(sp.sqrt(sp.Rational(1, c)))}")
print("fair signs: ess sup |y-g| = 1+|g| >= 1 => rho0>=1, tau>2, (tau+rho0)^2 > 9 > 4: vacuous. OK")
