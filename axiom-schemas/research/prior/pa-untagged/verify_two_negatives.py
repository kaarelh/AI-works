import sys, itertools, importlib.util, io, contextlib
sys.path.insert(0,'/home/user/AI-works/inferential-learning/research/theory/T1-code')
from terms import lgg_list, show, is_var
spec=importlib.util.spec_from_file_location('m','fid_merge.py')
with contextlib.redirect_stdout(io.StringIO()):
    m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
Q=m.Q
print('Q axioms:'); [print('  ',show(q)) for q in Q]
def match(pat, t, s):
    if is_var(pat):
        if pat in s: return s[pat]==t
        s[pat]=t; return True
    if is_var(t) or not isinstance(t,tuple) or not isinstance(pat,tuple): return pat==t
    if pat[0]!=t[0] or len(pat)!=len(t): return False
    return all(match(a,b,s) for a,b in zip(pat[1:],t[1:]))
# build the two negative steps in the same encoding as a Q step
q0=Q[0]; print('example encoding:',q0)
N1=('all',('x',),('eq',('0',),('S',('0',))))
N2=('all',('x',),('all',('y',),('eq',('0',),('S',('0',)))))
ok=0; fail=[]
for r in range(2,8):
    for sub in itertools.combinations(range(7),r):
        L=lgg_list([Q[i] for i in sub])
        if match(L,N1,{}) or match(L,N2,{}): ok+=1
        else: fail.append((sub,show(L)))
print('merges covered by the two negatives:',ok,'of',ok+len(fail))
for f in fail: print('NOT covered:',f)
# sanity: no single Q axiom (and hence the true target) contains either negative
print('any Q axiom matches a negative:',any(match(q,N1,{}) or match(q,N2,{}) for q in Q))
