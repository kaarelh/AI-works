import time, sys, pickle, os
os.environ['OMP_NUM_THREADS']='1'
sys.path.insert(0, '.')
from cil.domains.algebra import *
from cil.provers import *
from cil.baselines import *
SP='/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/'
D, T = pickle.load(open(SP+'data.pkl','rb'))
model = sys.argv[1]
mp = SP + f'model_{model}.pkl'
if os.path.exists(mp):
    v = pickle.load(open(mp,'rb'))
else:
    v = StatisticalVerifier(model, seed=0, n_hash=512).fit(D); v._cache.clear(); pickle.dump(v, open(mp,'wb'))
y = [e.label for e in T]
s = v.score_batch([(e.before, e.after, e.facts) for e in T])
B = int(sys.argv[2])
P = ProposalGenerator()
for prec in [0.5, 0.95, 0.99, 1.0]:
    tau = 0.5 if prec == 0.5 else calibrate_threshold(s, y, prec)
    bm = binary_metrics(s, y, tau)
    vt = v.with_threshold(tau)
    t = time.time()
    nf = 0; nt = 0; qs=[]; dfs = 0
    for g in FALSE_GOALS + TRUE_GOALS:
        ch = EdgeChecker(vt)
        r = prove(g, ch, P, B, seed=0)
        dfs += len(r.derived_false)
        if r.proved and not g.true: nf += 1; qs.append((g.name, r.queries)); 
        if r.proved and g.true: nt += 1
        if r.proved and not g.true and prec >= 0.99:
            print('   ', g.name, r.queries, ' | '.join(map(str, r.proof)), r.proof_labels)
    print(model, prec, 'tau %.4f tpr %.3f fpr %.4f'%(tau, bm['tpr'], bm['fpr']), 'false proved', nf, '/', len(FALSE_GOALS), 'true proved', nt, '/', len(TRUE_GOALS), 'derived false', dfs, '%.1fs'%(time.time()-t), qs)
