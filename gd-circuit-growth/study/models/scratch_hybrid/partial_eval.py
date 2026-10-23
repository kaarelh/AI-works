"""Evaluate a model only on the NN's partial cells (fast proxy for per-example agreement)."""
import sys, time, numpy as np, json
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
sys.path.insert(0, '/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/hybrid')
import common as C
from harness import partial_cells

def run_partial(model, fns):
    cells = partial_cells(fns); out = []
    for fn, n, a_ in cells:
        nn = C.nn_fixed(fn, 'adam'); Xte, yte = C.test_data(fn)
        for s in range(3):
            X, y = C.train_data(fn, s, n)
            r = model.fit(X, y, np.random.default_rng([s, n, C._fn_seed(fn)]))
            p = np.where(np.asarray(r['predict'](Xte)) > 0, 1, -1)
            out.append(dict(fn=fn, n=n, seed=s, nn_pred=nn['pred'][a_, s], nn_err=float(nn['test_err'][a_, s]), yte=yte, pred=p, size=r.get('size', np.nan)))
    return out

def score(rows, fns):
    cells = {}
    for c in rows:
        if c['fn'] in fns: cells.setdefault((c['fn'], c['n']), []).append(c)
    num = den = 0.0
    for key, lst in cells.items():
        en = np.mean([c['nn_err'] for c in lst]); em = np.mean([np.mean(c['pred'] != c['yte']) for c in lst])
        agree = np.mean([np.mean(c['pred'] == c['nn_pred']) for c in lst])
        indep = (1 - en) * (1 - em) + en * em
        num += agree - indep; den += 1 - indep
    return num / den

def summary(name, rows):
    h = score(rows, C.HELDOUT); c = score(rows, C.CALIB)
    mm = np.mean([abs(np.mean(r['pred'] != r['yte']) - r['nn_err']) for r in rows if r['fn'] in C.HELDOUT])
    sz = np.mean([r['size'] for r in rows])
    print(f'{name:36s} agreement HELDOUT {h:.3f} CALIB {c:.3f} | per-seed |err diff| HELDOUT {mm:.3f} | mean gates {sz:.1f}', flush=True)
    return h, c
