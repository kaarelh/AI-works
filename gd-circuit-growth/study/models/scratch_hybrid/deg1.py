import sys, os, numpy as np
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import common as C
from hybrid_diagnose import nn_score, kernel_score, race_score, net_index, PROBE
from models.race import Race
M = Race(theta=1.5, Q=3, gate='relu')
def cs(a, b): return float(a @ b / np.sqrt((a @ a) * (b @ b) + 1e-30))
tot = {}
for fn in ['dict', 'maj3', 'maj9', 'thr10', 'rand1', 'mux', 'dlist5', 'sparsepoly']:
    nn = C.nn_fixed(fn); rel = C.SUITE[fn]['relevant']; irr = [j for j in range(C.D) if j not in rel]
    P = np.load(os.path.join(C.RESULTS, f'params_fixed_adam_{fn}.npz')); I = net_index(os.path.join(C.RESULTS, f'fixed_adam_{fn}.npz'))
    for a, n in enumerate(nn['ns']):
        if not 0.05 <= nn['test_err'][a].mean() <= 0.45: continue
        res = []
        for s in range(3):
            X, y = C.train_data(fn, s, int(n))
            h = X.T @ (y - y.mean()) / n
            # least squares / ridge-linear direction
            w_ls = np.linalg.solve(X.T @ X + 1.0 * np.eye(C.D), X.T @ (y - y.mean()))
            fs = {'nn': nn_score(P, I[(int(n), s)]), 'kernel': kernel_score(X, y), 'race': race_score(M.fit(X, y, np.random.default_rng([s, int(n), C._fn_seed(fn)])))}
            c1 = {k: PROBE.T @ ((v := f(PROBE)) - v.mean()) / len(PROBE) for k, f in fs.items()}
            res.append([cs(c1['nn'][irr], h[irr]), cs(c1['nn'][irr], w_ls[irr]), cs(c1['nn'][irr], c1['kernel'][irr]), cs(c1['nn'][irr], c1['race'][irr]),
                        np.linalg.norm(c1['nn'][irr]) / np.linalg.norm(c1['nn']), np.linalg.norm(c1['kernel'][irr]) / np.linalg.norm(c1['kernel']), np.linalg.norm(c1['race'][irr]) / np.linalg.norm(c1['race'])])
        r = np.mean(res, 0)
        print(f"{fn:10s} n={int(n):5d}  cos(NN deg1 noise, .): Hebb {r[0]:.2f}  ridge-LS {r[1]:.2f}  kernel {r[2]:.2f}  race {r[3]:.2f} | noise/total deg1 norm: NN {r[4]:.2f} kernel {r[5]:.2f} race {r[6]:.2f}", flush=True)
