# Brute-force the cautious verifier over H_k for a small PA corpus.
# Fact used: for h in VS(D,Pneg), the 'first-cover' partition of D gives h' = union of lgg(block) with D <= h' <= h,
# so q in /\VS(D,Pneg) iff no partition of D into <=k blocks has a block-lgg union containing no Pneg step and missing q.
import sys, io, contextlib, importlib.util
sys.path.insert(0,'/home/user/AI-works/inferential-learning/research/theory/T1-code')
from terms import lgg_list, is_instance, show
P='/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/pa-untagged/fid_merge.py'
spec=importlib.util.spec_from_file_location('m',P)
with contextlib.redirect_stdout(io.StringIO()):
    m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
C=m.C; x=m.x; z0=m.z0; S=m.S; eq=m.eq
def partitions(n,kmax):
    # restricted growth strings
    a=[0]*n
    def rec(i,mx):
        if i==n: yield list(a); return
        for b in range(min(mx+1,kmax)):
            a[i]=b; yield from rec(i+1,max(mx,b+1) if b==mx else mx)
    yield from rec(0,0)
def in_cautious(D,k,Pneg,q):
    n=len(D); cache={}
    for rg in partitions(n,k):
        blocks={}
        for i,b in enumerate(rg): blocks.setdefault(b,[]).append(i)
        slots=[]
        for bl in blocks.values():
            key=tuple(bl)
            if key not in cache: cache[key]=lgg_list([D[i] for i in bl])
            slots.append(cache[key])
        if any(is_instance(s_,sl) for s_ in Pneg for sl in slots): continue
        if not any(is_instance(q,sl) for sl in slots):
            return False, [show(s) for s in slots]
    return True, None
ind=m.ind; Qsteps=m.Qsteps
D=Qsteps+[ind(eq(C('plus',z0,x),x)), ind(C('lt',x,S(x)))]
print('|D| =',len(D),' (7 Q axioms + 2 generic induction instances, P-roots eq, lt)')
q_wf=ind(C('ex',C('y'),eq(S(x),C('y'))))
q_ill=ind(z0)  # P := 0, an ill-formed member of inst(sigma)
assert is_instance(q_wf,m.sigma) and is_instance(q_ill,m.sigma)
Pneg=[C('st0',C('all',x,eq(z0,S(z0)))), C('st0',C('all',x,C('all',C('y'),eq(z0,S(z0)))))]
for k in (8,):
    for label,neg in (('no negatives',[]),('2 world-refuted negatives',Pneg)):
        for qn,q in (('well-formed ex-instance',q_wf),('ill-formed P:=0 instance',q_ill)):
            ok,wit=in_cautious(D,k,neg,q)
            print(f'k={k}, {label}: {qn} accepted = {ok}', '' if ok else f'(witness has {len(wit)} slots: {wit[0]} + ...)')
