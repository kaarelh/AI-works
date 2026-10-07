# Common PA encodings on top of the paper's T1-code term library.
import sys, itertools
sys.path.insert(0,'/home/user/AI-works/inferential-learning/research/theory/T1-code')
from terms import *   # terms: ('f',args...), metavariables ('?',name); lgg_list, match, is_instance, size, mu, canon

def C(n): return (n,)
Z=C('0')
def S(t): return ('S',t)
def add(a,b): return ('add',a,b)
def mul(a,b): return ('mul',a,b)
def eq(a,b): return ('eq',a,b)
def lt(a,b): return ('lt',a,b)
def NOT(a): return ('not',a)
def AND(a,b): return ('and',a,b)
def OR(a,b): return ('or',a,b)
def IMP(a,b): return ('imp',a,b)
def ALL(v,a): return ('all',v,a)
def EX(v,a): return ('ex',v,a)
def MV(n): return ('?',n)
x,y,n,m,w=C('x'),C('y'),C('n'),C('m'),C('w')
VARNAMES=[C(s) for s in ['x','y','n','m','k','i','j','u','w','z']]

def subst(f,v,t):
    """phi[t/v] for an object variable v (a constant), respecting binders all/ex."""
    if f==v: return t
    if len(f)==1: return f
    if f[0] in ('all','ex') and f[1]==v: return f
    return (f[0],)+tuple(subst(a,v,t) for a in f[1:])

# ---- step encodings ----
# (V) variable-arity encoding, as in the paper's s(and(p0,p1),p0) and T7's ('st',prem1,prem2,concl)
def ax_V(A): return ('st',A)
def ind_V(phi,v):
    a=subst(phi,v,Z); b=subst(phi,v,S(v))
    return ('st',('Sub',phi,v,Z,a),('Sub',phi,v,S(v),b),IMP(AND(a,ALL(v,IMP(phi,b))),ALL(v,phi)))
def sigma_V(xmeta=True):
    P,A,B=MV('P'),MV('A'),MV('B'); X=MV('X') if xmeta else x
    return ('st',('Sub',P,X,Z,A),('Sub',P,X,S(X),B),IMP(AND(A,ALL(X,IMP(P,B))),ALL(X,P)))
# (L) list encoding s(premise-list, conclusion)
NIL=C('nil')
def cons(h,t): return ('cons',h,t)
def ax_L(A): return ('s',NIL,A)
def ind_L(phi,v):
    a=subst(phi,v,Z); b=subst(phi,v,S(v))
    return ('s',cons(('Sub',phi,v,Z,a),cons(('Sub',phi,v,S(v),b),NIL)),IMP(AND(a,ALL(v,IMP(phi,b))),ALL(v,phi)))
def sigma_L(xmeta=True):
    P,A,B=MV('P'),MV('A'),MV('B'); X=MV('X') if xmeta else x
    return ('s',cons(('Sub',P,X,Z,A),cons(('Sub',P,X,S(X),B),NIL)),IMP(AND(A,ALL(X,IMP(P,B))),ALL(X,P)))

def equiv(a,b): return canon(a)==canon(b)
def gen(p,t):  # p at least as general as t (t may contain metavariables)
    return match(p,t) is not None

# Robinson Q, closed forms
Q=[ALL(x,NOT(eq(S(x),Z))),
   ALL(x,ALL(y,IMP(eq(S(x),S(y)),eq(x,y)))),
   ALL(x,IMP(NOT(eq(x,Z)),EX(y,eq(x,S(y))))),
   ALL(x,eq(add(x,Z),x)),
   ALL(x,ALL(y,eq(add(x,S(y)),S(add(x,y))))),
   ALL(x,eq(mul(x,Z),Z)),
   ALL(x,ALL(y,eq(mul(x,S(y)),add(mul(x,y),x))))]
# open forms (free variables) of the same axioms
Qopen=[NOT(eq(S(x),Z)), IMP(eq(S(x),S(y)),eq(x,y)), IMP(NOT(eq(x,Z)),EX(y,eq(x,S(y)))),
       eq(add(x,Z),x), eq(add(x,S(y)),S(add(x,y))), eq(mul(x,Z),Z), eq(mul(x,S(y)),add(mul(x,y),x))]

# ---- cautious verifier for untagged unions H_k, by brute force over set partitions ----
def set_partitions_le_k(items,k):
    """all partitions of list items into at most k nonempty blocks"""
    def rec(i,blocks):
        if i==len(items):
            yield [list(b) for b in blocks]; return
        for b in blocks:
            b.append(items[i]); yield from rec(i+1,blocks); b.pop()
        if len(blocks)<k:
            blocks.append([items[i]]); yield from rec(i+1,blocks); blocks.pop()
    yield from rec(0,[])
def in_cap_vs(q,D,k,return_witness=False):
    """q in intersection of VS_{H_k}(D)?  Minimal members of VS are unions of lggs of the blocks of a
    partition of D into <=k blocks; q is outside the intersection iff some such union misses q."""
    D=list(dict.fromkeys(D))
    for part in set_partitions_le_k(D,k):
        L=[lgg_list(b) for b in part]
        if not any(is_instance(q,l) for l in L):
            return (False,L) if return_witness else False
    return (True,None) if return_witness else True
