# u5b: part B of u5 with a smaller logic budget (15 instances per template), so that the run with a designated sentence is
# fast.  Data: ZF with the weak forms of Union and Power (seed 4, as in u5).  (1) logic + HF only; (2) bootstrapped coherence:
# designate the closure of Russell's instance of Separation, an instance accepted by the learned Separation cluster.
import sys, random, time
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code')
from dtlib import *
from dtrc import World, DTRC
from practice import *
exec(open('/home/user/AI-works/axiom-schemas/research/tracks/untagged/code/u5_dtrc_zf.py').read().split("print('== Part A")[0].split('from practice import *')[1])
single = dict(ZF); del single['Union']; del single['Power']; single.update(ZFW)
rng = random.Random(4)
data = zf_data(45, rng, single=single)
rng.shuffle(data)
univ = canon_params(EX(ALL(IMP(eq(P('a1'), P('a1')), mem(V(0), V(1))))))
russell_sep = canon_params(instantiate(SEP, {'Fphi': NOT(mem(H(0), H(0)))}))
def closure(s):
    ps = params(s)
    t = s
    for p in reversed(ps):
        def R(u, j):
            if u == ('p', p): return ('v', j)
            if u[0] == 'v': return u if u[1] < j else ('v', u[1] + 1)
            if u[0] in BINDERS: return (u[0], R(u[1], j + 1))
            ks = kids(u)
            return u if not ks else rebuild(u, [R(k, j) for k in ks])
        t = ALL(R(t, 0))
    return t
for label, des in (('logic + HF only', []), ('+ designated closure of the learned Russell instance of Separation', [closure(russell_sep)])):
    W = World('set', hf=3, budget=500, seed=4, designated=des)
    W.logic_budget = 15
    A = DTRC(W)
    t0 = time.time()
    A.run([s for _, s in data])
    print('== %s: clusters=%d  coherence tests=%d  time=%.0fs  [v2: passes=%d, |N_final|=%d]' % (label, len(A.clusters), A.tests, time.time() - t0, A.rounds, len(W.neg)), flush=True)
    report(A, data, ZF_SCHEMAS)
    print('   accepts the universal-set sentence:', A.accepts(univ), '; accepts Russell instance of Separation:', A.accepts(russell_sep), flush=True)
