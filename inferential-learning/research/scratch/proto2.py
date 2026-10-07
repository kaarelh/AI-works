import time, random, sys, pickle, os
sys.path.insert(0, '.')
from collections import Counter
from cil.domains.algebra import *
from cil.learners import prepare_training
from cil.baselines import *
SP='/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/data.pkl'
if os.path.exists(SP):
    D, T = pickle.load(open(SP,'rb'))
else:
    cfg = HumanConfig(noise_rate=0.05, fallacy_rate=0.3)
    tr = prepare_training(generate_corpus(500, cfg, seed=0), ALGEBRA)
    te = prepare_training(generate_corpus(300, cfg, seed=1000), ALGEBRA)
    lab = WorldOracle(seed=99, n_points=30)
    D = build_step_dataset(tr, lab, seed=0, n_fallacy=300)
    T = build_step_dataset(te, lab, seed=1, n_fallacy=200)
    pickle.dump((D,T), open(SP,'wb'))
y = [e.label for e in T]
for m, nh in [(a, b) for a in sys.argv[1].split(',') for b in map(int, sys.argv[2].split(','))]:
    t=time.time()
    v = StatisticalVerifier(m, seed=0, n_hash=nh).fit(D)
    ft = time.time()-t
    t=time.time()
    s = v.score_batch([(e.before, e.after, e.facts) for e in T])
    st = time.time()-t
    bm = binary_metrics(s, y, 0.5)
    print(m, nh, 'fit %.1fs score %.2fs'%(ft, st), 'auc %.4f'%roc_auc(s, y), 'acc %.3f bacc %.3f'%(bm['accuracy'], bm['balanced_accuracy']))
    for p in [0.9, 0.95, 0.99, 1.0]:
        tau = calibrate_threshold(s, y, p)
        b = binary_metrics(s, y, tau)
        print('  ', p, round(tau,4), 'tpr %.3f fpr %.4f bprec %.4f'%(b['tpr'], b['fpr'], b['balanced_precision']))
