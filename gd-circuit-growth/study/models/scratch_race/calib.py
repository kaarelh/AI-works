"""Calibrate race hyperparameters on CALIB functions only (those with NN results on disk)."""
import os, sys, json, time, itertools
sys.path.insert(0, '.')
import numpy as np, common as C
from models.race import Race
LOG = 'models/scratch_race/calib_log.jsonl'
fns = [f for f in C.CALIB if os.path.exists(os.path.join(C.RESULTS, f'fixed_adam_{f}.npz'))]
seeds = [int(s) for s in os.environ.get('SEEDS', '0').split(',')]
configs = eval(sys.argv[1])          # list of dicts
for kw in configs:
    t0 = time.time()
    res = C.evaluate(Race(**kw), fns=fns, seeds=seeds, verbose=False)
    s = C.compare(res, 'adam', verbose=False)
    out = dict(kw=kw, seeds=seeds, fns=fns, secs=time.time() - t0,
               **{k: s[k] for k in ['curve_mae', 'sc_spearman', 'sc_mean_abs_log2_ratio', 'success_agreement',
                                    'example_agreement_score', 'time_spearman', 'n_time_pairs', 'n_partial_cells']},
               per_fn={r['fn']: (r['n_nn'], r['n_model']) for r in s['per_fn']},
               curves={fn: res['test_err'][fn].mean(1).round(3).tolist() for fn in fns})
    with open(LOG, 'a') as fh:
        fh.write(json.dumps(out) + '\n')
    print(f"{kw}  mae {out['curve_mae']:.3f} sc_rho {out['sc_spearman']:.2f} sc_log2 {out['sc_mean_abs_log2_ratio']:.2f} "
          f"succ {out['success_agreement']:.2f} ex {out['example_agreement_score']:.2f} t_rho {out['time_spearman']:.2f} "
          f"({out['secs']:.0f}s)  " + ' '.join(f"{f}:{a:.0f}/{b:.0f}" for f, (a, b) in out['per_fn'].items()), flush=True)
