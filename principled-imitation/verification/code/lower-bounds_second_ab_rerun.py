"""Rerun of the one case of lower-bounds_second_ab.py with the largest z-score (3.28) for the identity
E[sum_t v_t] = L E[b] of Proposition 3.8(1) (seed 4, gamma 0.1, n_B 10, X0 = X), with R = 20000 and a fresh seed."""
import random
src = open(__file__.replace('_rerun', '')).read().split('R = 300')[0]
exec(src)
H, w, nxt, Z, L, nx, fi = make_instance(4)
rnd = random.Random(7); d = []
for r in range(20000):
    out = protocol_AB(H, w, nxt, Z, L, nx, fi, 0.1, 10, set(range(nx)), rnd); d.append(out[6] - L * out[7])
m = sum(d) / len(d); s = (sum((x - m) ** 2 for x in d) / len(d)) ** .5 / len(d) ** .5
print(f"R=20000: mean of sum v - L b = {m:.4f}, se {s:.4f}, z = {m/s:.2f}")
