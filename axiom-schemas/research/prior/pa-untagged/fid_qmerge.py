import sys, itertools
sys.path.insert(0,'/home/user/AI-works/inferential-learning/research/theory/T1-code')
sys.path.insert(0,'/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/pa-untagged')
from terms import lgg_list, show, is_var, vars_of
import importlib.util
spec=importlib.util.spec_from_file_location('m','/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/pa-untagged/fid_merge.py')
import io,contextlib
with contextlib.redirect_stdout(io.StringIO()):
    m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
Q=m.Q
# evaluator on N for closed formulas whose quantifiers we bound-check up to B (only used to find counterexamples of a top-level forall-prefix with qf matrix)
B=6
def ev_t(t,env):
    h=t[0]
    if h=='0': return 0
    if h=='S': return ev_t(t[1],env)+1
    if h=='plus': return ev_t(t[1],env)+ev_t(t[2],env)
    if h=='times': return ev_t(t[1],env)*ev_t(t[2],env)
    if h in env: return env[h]
    raise ValueError(h)
def ev_f(f,env):
    h=f[0]
    if h=='eq': return ev_t(f[1],env)==ev_t(f[2],env)
    if h=='lt': return ev_t(f[1],env)<ev_t(f[2],env)
    if h=='not': return not ev_f(f[1],env)
    if h=='and': return ev_f(f[1],env) and ev_f(f[2],env)
    if h=='or': return ev_f(f[1],env) or ev_f(f[2],env)
    if h=='imp': return (not ev_f(f[1],env)) or ev_f(f[2],env)
    if h=='all': return all(ev_f(f[2],{**env,f[1][0]:n}) for n in range(B))
    if h=='ex': return any(ev_f(f[2],{**env,f[1][0]:n}) for n in range(3*B))
    raise ValueError(h)
FALSEF=m.eq(m.z0,m.S(m.z0)); TERM=m.S(m.z0)
def fill(t,ctx):
    # ctx: 'f' formula position or 't' term position
    if is_var(t): return FALSEF if ctx=='f' else TERM
    h=t[0]
    if h in('all','ex'): return (h,t[1],fill(t[2],'f'))
    if h in('not',): return (h,fill(t[1],'f'))
    if h in('and','or','imp'): return (h,fill(t[1],'f'),fill(t[2],'f'))
    if h in('eq','lt','plus','times'): return (h,fill(t[1],'t'),fill(t[2],'t'))
    if h=='S': return (h,fill(t[1],'t'))
    return t
bad=0
for r in range(2,8):
    for sub in itertools.combinations(range(7),r):
        L=lgg_list([Q[i] for i in sub])
        inst=fill(L,'f')
        val=ev_f(inst,{})
        if val: bad+=1; print('no false instance found for',sub,show(L))
print('subsets of >=2 Q axioms checked:',sum(1 for r in range(2,8) for _ in itertools.combinations(range(7),r)),' without a found false instance:',bad)
print('example pair lggs:')
for sub in [(3,5),(4,6),(0,1),(1,4)]:
    L=lgg_list([Q[i] for i in sub]); print(' ',sub,show(L),'-> false instance',show(fill(L,'f')))
