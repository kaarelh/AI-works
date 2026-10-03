# Added during verification (referee script): Remark after Thm 5.4 -- low root variety does not block identification when k'>=2.
import sys, itertools
sys.path.insert(0,'/home/user/AI-works/inferential-learning/research/theory/T1-code')
from terms import *
def splits(P,k):
    # all assignments of elements to k labelled classes (covers all minimal hypotheses)
    for lab in itertools.product(range(k),repeat=len(P)):
        yield [[P[j] for j in range(len(P)) if lab[j]==l] for l in range(k)]
def in_cap_vs(q,P,k):
    for cl in splits(P,k):
        if not any(c and is_instance(q,lgg_list(c)) for c in cl): return False
    return True
a,b,c=('a',),('b',),('c',)
p=lambda t:('p',t); qq=lambda t:('q',t)
# k=k'=2; R* = inst p(x) u inst q(y); x instantiated with only 2=k roots
P=[p(a),p(b),qq(a),qq(b)]
print('k=2,k\'=2: p(c) in capVS?', in_cap_vs(p(c),P,2), '; q(c)?', in_cap_vs(qq(c),P,2), '; p(p(a))?', in_cap_vs(p(p(a)),P,2))
# k'=1 version: remark is right
P1=[p(a),p(b)]
print('k=2,k\'=1: p(c) in capVS?', in_cap_vs(p(c),P1,2))
# VC bound check D=2k log2(4kM) : 2^d > (M(d+1))^k for all integer d>=D
import math
bad=[]
for k in range(1,9):
  for v in range(1,9):
    M=v+v*(v-1)//2
    D=2*k*math.log2(4*k*M)
    for d in range(math.ceil(D),math.ceil(D)+200):
        if not (2**d > (M*(d+1))**k): bad.append((k,v,d))
print('VC bound violations:',bad[:5])
