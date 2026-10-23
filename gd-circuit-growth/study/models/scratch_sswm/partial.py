import sys, numpy as np
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import common as C
res = C.load_eval(sys.argv[1])
s = C.compare(res, 'adam', verbose=False, fns=sys.argv[2].split(',') if len(sys.argv) > 2 else None)
for c in s['partial_cells']:
    sc = (c['nn_model_agree'] - c['indep_agree']) / max(c['nn_nn_agree'] - c['indep_agree'], 1e-3)
    print(f"{c['fn']:10s} n={c['n']:6d} nn_err {c['nn_err']:.3f} m_err {c['model_err']:.3f} nn-nn {c['nn_nn_agree']:.3f} nn-m {c['nn_model_agree']:.3f} indep {c['indep_agree']:.3f}  score {sc:.2f}")
