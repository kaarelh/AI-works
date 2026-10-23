import sys, numpy as np, pickle
sys.path.insert(0, '/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/hybrid')
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import common as C
from harness import agreement_score, H
from scipy.linalg import cho_factor, cho_solve
cache = pickle.load(open(H + '/cache.pkl', 'rb'))
def sgn(v): return np.where(v > 0, 1, -1)
def report(name, preds):
    h, _ = agreement_score(cache, preds, C.HELDOUT); c, _ = agreement_score(cache, preds, C.CALIB)
    errs_h = np.mean([abs(np.mean(p != c_['yte']) - c_['nn_err']) for c_, p in zip(cache, preds) if c_['fn'] in C.HELDOUT])
    print(f'{name:40s} HELDOUT {h:.3f}  CALIB {c:.3f}   |err-nn_err| per seed {errs_h:.3f}', flush=True)
# precompute
for c in cache:
    K = c['Ktr'].astype(np.float64); n = len(K); c['kap'] = np.trace(K) / n
    c['fr_tr'] = c['c0'] + c['Ftr'] @ c['a']; c['fr_te'] = c['c0'] + c['Fte'] @ c['a']
    lam = 1e-4 * c['kap']; c['cf'] = cho_factor(K + lam * np.eye(n))
    alpha = cho_solve(c['cf'], c['y']); c['fk_te'] = c['Kte'] @ alpha; c['fk_tr'] = K @ alpha
report('race', [sgn(c['fr_te']) for c in cache])
report('kernel', [sgn(c['fk_te']) for c in cache])
for g in [0.5, 1, 2, 4]:
    report(f'mix gamma={g}', [sgn(c['fr_te'] / c['fr_tr'].std() + g * c['fk_te'] / c['fk_tr'].std()) for c in cache])
# residual KRR: f = f_race + KRR_rho(y - f_race)
for rho in [1e-4, 1e-2, 1e-1, 1.0]:
    preds = []
    for c in cache:
        K = c['Ktr'].astype(np.float64); n = len(K)
        al = np.linalg.solve(K + rho * c['kap'] * np.eye(n), c['y'] - c['fr_tr']) if rho != 1e-4 else cho_solve(c['cf'], c['y'] - c['fr_tr'])
        preds.append(sgn(c['fr_te'] + c['Kte'] @ al))
    report(f'race + KRR(resid) rho={rho}', preds)
# joint KRR with K_total = K/kap + cg * F F^T / ngates
for cg in [0.03, 0.1, 0.3, 1, 3, 10, 100]:
    preds = []
    for c in cache:
        K = c['Ktr'].astype(np.float64) / c['kap']; n = len(K); F = c['Ftr']; m = max(F.shape[1], 1)
        A = K + (cg / m) * F @ F.T + 1e-4 * np.eye(n) + 1.0  # +1: free-ish constant
        al = cho_solve(cho_factor(A), c['y'])
        preds.append(sgn(c['Kte'] / c['kap'] @ al + (cg / m) * c['Fte'] @ (F.T @ al) + al.sum()))
    report(f'joint KRR cg={cg}', preds)
