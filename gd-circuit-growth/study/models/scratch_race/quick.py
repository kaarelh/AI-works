import sys, os, time, argparse; sys.path.insert(0, '.')
import numpy as np, common as C
from models.race import Race
ap = argparse.ArgumentParser()
ap.add_argument('--fns', default='dict,and3,maj3,par2,par3')
ap.add_argument('--ns', default='16,32,64,128,256,512,1024,2048,4096')
ap.add_argument('--seeds', default='0')
ap.add_argument('--kw', default='')
ap.add_argument('-v', action='store_true')
a = ap.parse_args()
kw = eval('dict(' + a.kw + ')')
M = Race(**kw, verbose=a.v)
ns = [int(x) for x in a.ns.split(',')]; seeds = [int(s) for s in a.seeds.split(',')]
for fn in a.fns.split(','):
    Xte, yte = C.test_data(fn)
    errs, times, sizes, secs = [], [], [], []
    for n in ns:
        e_, t_, s_, sec_ = [], [], [], []
        for s in seeds:
            X, y = C.train_data(fn, s, n)
            t0 = time.time()
            r = M.fit(X, y, np.random.default_rng([s, n, C._fn_seed(fn)]))
            sec_.append(time.time() - t0)
            e_.append(np.mean(r['predict'](Xte) != yte)); t_.append(r['time']); s_.append(r['size'])
        errs.append(np.mean(e_)); times.append(np.mean(t_)); sizes.append(np.mean(s_)); secs.append(np.sum(sec_))
    line = f"{fn:10s} race err " + ' '.join(f"{e:.2f}" for e in errs)
    if os.path.exists(os.path.join(C.RESULTS, f'fixed_adam_{fn}.npz')):
        nn = C.nn_fixed(fn); idx = [list(nn['ns']).index(n) for n in ns]
        line += "\n           NN   err " + ' '.join(f"{e:.2f}" for e in nn['test_err'][idx].mean(1))
        line += "\n           NN  s2g  " + ' '.join(f"{e:4.0f}" for e in np.nanmin(np.where(np.isfinite(nn['steps_to_gen'][idx]), nn['steps_to_gen'][idx], np.nan), 1))
    line += "\n           time     " + ' '.join(f"{e:5.1f}" for e in times)
    line += "\n           size     " + ' '.join(f"{e:4.0f}" for e in sizes)
    line += f"\n           secs     " + ' '.join(f"{e:4.1f}" for e in secs)
    print(line, flush=True)
