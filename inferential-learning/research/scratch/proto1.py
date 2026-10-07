import time, random, sys
sys.path.insert(0, '.')
from collections import Counter
from cil.domains.algebra import *
from cil.learners import prepare_training
from cil.baselines import *
t=time.time()
cfg = HumanConfig(noise_rate=0.05, fallacy_rate=0.3)
tr = prepare_training(generate_corpus(500, cfg, seed=0), ALGEBRA)
te = prepare_training(generate_corpus(300, cfg, seed=1000), ALGEBRA)
lab = WorldOracle(seed=99, n_points=30)
D = build_step_dataset(tr, lab, seed=0, n_fallacy=300)
T = build_step_dataset(te, lab, seed=1, n_fallacy=200)
print('data', len(D), Counter((e.source, e.label) for e in D), time.time()-t)
print('test', len(T), Counter((e.source, e.label) for e in T))
for m in ['logreg', 'gboost', 'forest']:
    t=time.time()
    v = StatisticalVerifier(m, seed=0).fit(D)
    ft = time.time()-t
    t=time.time()
    s = v.score_batch([(e.before, e.after, e.facts) for e in T])
    st = time.time()-t
    y = [e.label for e in T]
    print(m, 'fit %.1fs score %.2fs'%(ft, st), 'auc %.4f'%roc_auc(s, y), binary_metrics(s, y, 0.5))
    for p in [0.9, 0.95, 0.99, 1.0]:
        tau = calibrate_threshold(s, y, p)
        print('  ', p, round(tau,4), {k: round(x,3) for k,x in binary_metrics(s, y, tau).items()})
