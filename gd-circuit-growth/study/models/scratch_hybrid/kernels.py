import sys, numpy as np, pickle
sys.path.insert(0, '/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/hybrid')
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import common as C
from harness import agreement_score, H
from scipy.linalg import cho_factor, cho_solve
cache = pickle.load(open(H + '/cache.pkl', 'rb'))
d = 30
def rc(rho, var):  # E relu relu
    rho = np.clip(rho, -1, 1); return var / (2 * np.pi) * (np.sqrt(1 - rho ** 2) + (np.pi - np.arccos(rho)) * rho)
def dc(rho):  # E relu' relu'
    rho = np.clip(rho, -1, 1); return (np.pi - np.arccos(rho)) / (2 * np.pi)
rho0 = np.linspace(-1, 1, d + 1)
S1 = rho0; S2 = rc(S1, 1.0); v2 = S2[-1]; S3 = rc(S2 / v2, v2); D2 = dc(S1); D3 = dc(S2 / v2)
tables = {
  'nngp': S3,
  'ntk': S3 + S2 * D3 + S1 * D2 * D3,
  'ntk-l1': S1 * D2 * D3,
  'ntk-l2': S2 * D3,
  'nngp1': S2,              # one hidden layer NNGP
  'ntk-l1+l2': S2 * D3 + S1 * D2 * D3,
}
def sgn(v): return np.where(v > 0, 1, -1)
XTE = {fn: C.test_data(fn)[0] for fn in C.FNS}
for name, tab in tables.items():
    tab = tab / tab[-1]
    for ridge in [1e-4, 1e-2]:
        preds = []
        for c in cache:
            X = c['X']; Xte = XTE[c['fn']]
            idx_tr = ((X @ X.T).astype(np.int64) + d) // 2; K = tab[idx_tr]
            al = cho_solve(cho_factor(K + ridge * np.eye(len(X))), c['y'])
            preds.append(sgn(tab[((Xte @ X.T).astype(np.int64) + d) // 2] @ al))
        h, _ = agreement_score(cache, preds, C.HELDOUT); cc, _ = agreement_score(cache, preds, C.CALIB)
        de = np.mean([np.mean(p != c['yte']) - c['nn_err'] for c, p in zip(cache, preds)])
        de_small = np.mean([np.mean(p != c['yte']) - c['nn_err'] for c, p in zip(cache, preds) if c['n'] <= 64])
        print(f'{name:10s} ridge {ridge:g}: HELDOUT {h:.3f} CALIB {cc:.3f} | mean (err - nn_err) all {de:+.3f}, n<=64 {de_small:+.3f}', flush=True)
