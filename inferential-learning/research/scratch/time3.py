import sys, os, pickle, time
os.environ['OMP_NUM_THREADS']='1'
sys.path.insert(0,'.')
from cil.provers import *
from cil.baselines import *
SP='/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/'
D, T = pickle.load(open(SP+'data.pkl','rb'))
y = [e.label for e in T]
for model in sys.argv[1].split(','):
    v = StatisticalVerifier(model, seed=0, n_hash=512).fit(D)
    s = v.score_batch([(e.before, e.after, e.facts) for e in T])
    vt = v.with_threshold(calibrate_threshold(s, y, 1.0))
    P = ProposalGenerator()
    t=time.time(); q=0
    for g in FALSE_GOALS[:4] + TRUE_GOALS[-4:]:
        ch = EdgeChecker(vt)
        r = prove(g, ch, P, 3000 if not g.true else 1500, seed=0)
        q += ch.queries
    dt = time.time()-t
    print(model, 'search time %.1f s, %d queries, %.3f ms/query' % (dt, q, 1000*dt/q))
