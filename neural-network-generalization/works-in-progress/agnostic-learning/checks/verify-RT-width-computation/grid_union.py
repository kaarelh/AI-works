"""Grid count, covering radius, and the Hoeffding/union-bound constant in the proof of Prop. 6.1."""
import numpy as np
import sympy as sp

# (1) grid of spacing delta' on [-R, R]: count <= 2 + 2R/delta', covering radius delta'/2
rng = np.random.default_rng(1)
worst_cnt, worst_rad = 0, 0
for _ in range(20000):
    R = rng.uniform(0.01, 50); dl = rng.uniform(1e-3, 3)
    pts = -R + dl * np.arange(int(np.ceil(2 * R / dl)) + 1)
    worst_cnt = max(worst_cnt, len(pts) / (2 + 2 * R / dl))
    xs = rng.uniform(-R, R, 50)
    worst_rad = max(worst_rad, np.max(np.min(np.abs(xs[:, None] - pts[None, :]), axis=1)) / dl)
print(f"(1) max count/(2+2R/delta') = {worst_cnt:.4f} (<= 1); max covering radius/delta' = {worst_rad:.4f} (<= 0.5)")

# (2) Hoeffding (range 4) + union over |G| points at level delta/4:  |G| exp(-2 n t^2/16) = delta/4
n, t, G, dlt = sp.symbols('n t G delta', positive=True)
sol = sp.solve(sp.Eq(sp.log(G) - 2 * n * t ** 2 / 16, sp.log(dlt / 4)), t)
target = 4 * sp.sqrt((sp.log(G) + sp.log(4 / dlt)) / (2 * n))
print("(2) solved t:", [sp.simplify(s) for s in sol], " report's t:", target,
      " equal:", any(sp.simplify(sp.expand_log(s - target, force=True)) == 0 for s in sol))

# (3) competitor Hoeffding at level delta/4 with range (U+1)^2
U = sp.symbols('U', positive=True)
sol2 = sp.solve(sp.Eq(-2 * n * t ** 2 / (U + 1) ** 4, sp.log(dlt / 4)), t)
print("(3) competitor t:", [sp.simplify(s) for s in sol2], " report: (U+1)^2 sqrt(ln(4/delta)/(2n))")

# (4) Bernstein: n t^2/(2 s2 + 2 b t/3) = l  =>  t = b l/(3n) + sqrt((b l/(3n))^2 + 2 s2 l/n) <= 2 b l/(3n) + sqrt(2 s2 l/n)
b, s2, l = sp.symbols('b s2 l', positive=True)
tt = b * l / (3 * n) + sp.sqrt((b * l / (3 * n)) ** 2 + 2 * s2 * l / n)
print("(4) Bernstein root check:", sp.simplify(n * tt ** 2 - l * (2 * s2 + 2 * b * tt / 3)))
