import sys, os, pickle, cProfile, pstats, time
os.environ['OMP_NUM_THREADS']='1'
sys.path.insert(0,'.')
from cil.provers import *
from cil.baselines import *
SP='/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/'
D, T = pickle.load(open(SP+'data.pkl','rb'))
model = sys.argv[1]
t=time.time()
v = StatisticalVerifier(model, seed=0, n_hash=512).fit(D)
print(model, 'fit', time.time()-t)
vt = v.with_threshold(0.9993 if model=='gboost' else 0.99)
P = ProposalGenerator()
def run():
    for g in FALSE_GOALS[:4]:
        r = prove(g, EdgeChecker(vt), P, 3000, seed=0)
        print(g.name, r.proved, r.queries, r.expansions, r.accepted)
t=time.time()
cProfile.run('run()', SP+'prof')
print(model, 'search time', time.time()-t)
st = pstats.Stats(SP+'prof'); st.sort_stats('tottime').print_stats(14)
