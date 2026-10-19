"""Per-junta-cell confidence for stair4 (d=12, L=2, seed 0): mean q over unobserved x in each of the 16 cells."""
import sys, os, json
import numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
from common import cube, gram, stair_sum
from signgp import sample_signs, Predictor
import targets as T
from run_sweep import train_inputs
d, L = 12, 2
Xc = cube(d)
res = {}
for n in (800, 2400):
    idx = train_inputs(d, n, 0)
    KXX = gram(Xc[idx], Xc[idx], d, L); Kcx = gram(Xc, Xc[idx], d, L)
    P = Predictor(Kcx, KXX, idx)
    f = T.target_values("stair4", d)
    G, _ = sample_signs(KXX, f[idx], 1500, 300, 2, np.random.default_rng(1))
    q, _ = P.q_from_samples(G.reshape(-1, len(idx)), f)
    cell = np.arange(2 ** d) % 16
    X4 = cube(4)
    S4 = stair_sum(X4.astype(float), 4)
    rows = []
    for c in range(16):
        m = (cell == c) & P.unseen
        rows.append(dict(x=X4[c].tolist(), f=int(T.junta("stair4", d)[1][c]), S4=int(S4[c]),
                         mean_q=round(float(q[m].mean()), 3), frac_fail=round(float(np.mean(q[m] <= 2 / 3)), 3)))
    res[n] = rows
    print("n =", n)
    for r in rows: print("  ", r)
json.dump(res, open(os.path.join(HERE, "stair4_cells.json"), "w"), indent=1)
