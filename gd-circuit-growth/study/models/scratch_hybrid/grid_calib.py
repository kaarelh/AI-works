"""Full-grid evaluation on a function subset for a list of hybrid settings; prints compare() metrics."""
import sys, time, os, numpy as np, json
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import common as C
sys.path.insert(0, "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/hybrid"); from hybrid_static import Hybrid
EV = '/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/hybrid/evals'
os.makedirs(EV, exist_ok=True)
fns = C.CALIB if sys.argv[1] == 'calib' else (C.HELDOUT if sys.argv[1] == 'heldout' else C.FNS)
for spec in sys.argv[2:]:
    kw = {}
    for a in spec.split(';'):
        k, v = a.split('='); kw[k] = None if v == 'None' else float(v)
    M = Hybrid(**kw); M.name = 'hybrid-' + spec
    t0 = time.time(); res = C.evaluate(M, fns=fns, ns=[n for n in C.NS if n <= int(os.environ.get("NMAX", 16384))], verbose=False)
    C.save_eval(res, os.path.join(EV, f"{sys.argv[1]}_{spec.replace(';','_')}.npz"))
    b = C.compare(res, 'adam', fns=fns, verbose=False)
    print(f"{spec:24s} {sys.argv[1]}: n* |log2| {b['sc_mean_abs_log2_ratio']:.2f} Spearman {b['sc_spearman']:.2f} success {b['success_agreement']:.2f} "
          f"MAE {b['curve_mae']:.3f} per-example {b['example_agreement_score']:.3f} time {b['time_spearman']:.2f}  ({time.time()-t0:.0f}s)", flush=True)
    print('    ' + ' '.join(f"{p['fn']}:{p['n_nn']:.0f}/{p['n_model']:.0f}" for p in b['per_fn']), flush=True)
