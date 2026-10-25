"""Width dilation of the model itself (no network data): onset step of every target character at width N, relative
to width 128, online.  The mean log ratio gives BETA_W in flow.py (onsets ~ (128 / N)^BETA_W).

    python width.py <fns> '<json list of widths>' <seeds>
"""
import os, sys, json
import numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); TR = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE); sys.path.insert(0, TR)
import flow
from analyze_traj import subsets, chi_matrix, first_cross

fns = sys.argv[1].split(","); Ns = json.loads(sys.argv[2]); seeds = int(sys.argv[3])
res = {}
for fn in fns:
    R, pats, y = flow.target(fn); subs = subsets(len(R)); C = chi_matrix(pats, subs); yhat = C.T @ y / len(y)
    supp = [j for j in range(len(subs)) if abs(yhat[j]) > 1e-9 and subs[j] != ()]
    on = {}
    for N in Ns:
        steps, out = flow.run(fn, conds=("online",), N=N, seeds=seeds)
        coef = out["online"].mean(0) @ C / len(y)
        on[N] = np.array([first_cross(steps.astype(float), coef[:, j] / yhat[j]) or np.nan for j in supp])
    for N in Ns:
        lr = np.log(on[N] / on[128])
        print(f"{fn:10s} N={N:4d} mean log-ratio {np.nanmean(lr):+.3f}  per character {np.round(np.exp(lr), 2)}", flush=True)
        res.setdefault(N, []).extend(list(lr[np.isfinite(lr)]))
for N in Ns:
    m = np.mean(res[N])
    print(f"N={N}: onset factor {np.exp(m):.3f}" + (f", beta = {m / np.log(128 / N):.3f}" if N != 128 else ""))
