"""Evaluate SSWM on a subset and compare with NN-adam.  usage: calib.py --kw "theta=1,eps=0.05" [--fns ...]"""
import os, sys, time, json, numpy as np
os.environ.setdefault("OMP_NUM_THREADS", "1")
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import common as C
from models.sswm import SSWM
import argparse
ap = argparse.ArgumentParser()
ap.add_argument('--fns', default='calib')
ap.add_argument('--ns', default='32,64,128,256,512,1024,2048,4096')
ap.add_argument('--seeds', default='0')
ap.add_argument('--kw', default='')
ap.add_argument('--quiet', type=int, default=0)
ap.add_argument('--save', default='')
a = ap.parse_args()
kw = eval('dict(' + a.kw + ')')
fns = C.CALIB if a.fns == 'calib' else (C.HELDOUT if a.fns == 'heldout' else a.fns.split(','))
fns = [f for f in fns if os.path.exists(os.path.join(C.RESULTS, f"fixed_adam_{f}.npz"))]
if not os.environ.get("ALLOW_HELDOUT"):
    assert not set(fns) & set(C.HELDOUT), "calibration must not use HELDOUT functions"

ns = [int(x) for x in a.ns.split(',')]; seeds = [int(x) for x in a.seeds.split(',')]
M = SSWM(**kw)
t0 = time.time()
res = C.evaluate(M, fns=fns, ns=ns, seeds=seeds, verbose=False)
el = time.time() - t0
for fn in fns:
    nn = C.nn_fixed(fn); idx = [list(nn['ns']).index(n) for n in ns]
    print(f"{fn:10s} M " + " ".join(f"{v:.2f}" for v in res['test_err'][fn].mean(1)) +
          f" | t {np.nanmedian(res['time'][fn]):6.0f} sz {np.nanmedian(res['size'][fn]):4.0f} tr {res['train_err'][fn].mean():.2f}")
    print(f"{'':10s} N " + " ".join(f"{v:.2f}" for v in nn['test_err'][idx].mean(1)))
s = C.compare(res, 'adam', verbose=False)
print('fit seconds by n:', ' '.join(f"{n}:{sum(res['fit_seconds'][f][i].sum() for f in fns):.0f}" for i, n in enumerate(ns)))
print(f"[{a.kw}] {el:.0f}s  MAE {s['curve_mae']:.3f} scSp {s['sc_spearman']:.2f} sclog {s['sc_mean_abs_log2_ratio']:.2f} "
      f"succ {s['success_agreement']:.2f} ex {s['example_agreement_score']:.2f} ({s['n_partial_cells']}) tSp {s['time_spearman']:.2f} ({s['n_time_pairs']})")
print("  n*: " + ", ".join(f"{r['fn']} {r['n_nn']:.0f}/{r['n_model']:.0f}" for r in s['per_fn']))
if a.save:
    C.save_eval(res, a.save)
