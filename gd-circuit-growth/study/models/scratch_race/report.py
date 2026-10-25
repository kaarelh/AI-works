"""Compare saved race eval (and baselines) with NN results on HELDOUT and CALIB."""
import os, sys, json
sys.path.insert(0, '.')
import numpy as np, common as C
OUT = '/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/model_evals'
names = sys.argv[1].split(',') if len(sys.argv) > 1 else ['race', 'nngp-kernel', 'occam-junta', 'sswm']
opts = sys.argv[2].split(',') if len(sys.argv) > 2 else ['adam']
keys = ['curve_mae', 'sc_spearman', 'sc_mean_abs_log2_ratio', 'success_agreement', 'example_agreement_score',
        'n_partial_cells', 'time_spearman', 'n_time_pairs']
summ = {}
for opt in opts:
    for split, fns in [('HELDOUT', C.HELDOUT), ('CALIB', C.CALIB), ('ALL', C.FNS)]:
        for nm in names:
            p = f'{OUT}/{nm}.npz'
            if not os.path.exists(p):
                continue
            res = C.load_eval(p)
            print(f'--- {nm} vs NN-{opt} on {split}')
            s = C.compare(res, opt, fns=fns, verbose=True)
            summ[f'{nm}|{opt}|{split}'] = {k: s[k] for k in keys}
        if opt == 'adam':
            pass
    if opt == 'adam' and any(os.path.exists(os.path.join(C.RESULTS, f'fixed_sgd_{f}.npz')) for f in C.FNS):
        for split, fns in [('HELDOUT', C.HELDOUT), ('CALIB', C.CALIB)]:
            r = C.nn_as_model_res('sgd')
            print(f'--- nn-sgd vs NN-adam on {split}')
            s = C.compare(r, 'adam', fns=fns, verbose=True)
            summ[f'nn-sgd|adam|{split}'] = {k: s[k] for k in keys}
json.dump(summ, open('models/scratch_race/report_summary.json', 'w'), indent=1)
