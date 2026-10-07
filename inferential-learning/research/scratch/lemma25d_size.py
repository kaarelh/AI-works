# Lemma 2.5(d): is the extracted refutation of {sigma} of size <= size(pi)?
# Abstract judgments with given symbol sizes. Position [A:D] = [{Y,Z}:{w}], no world.
# Trusted: T1=(Y/X), t1=(c0,X/w). Untrusted: s=(X/c0) in inst(sigma) [fallacy], u=(Z/X) in inst(sigma') [genuine].
size={'Y':10,'Z':1,'X':1,'c0':1,'w':1}
A={'Y','Z'}; D={'w'}
trusted=[(('Y',),'X'),(('c0','X'),'w')]
# pi as a TREE: w <-t1( c0 <-s( X <-T1(Y) ),  X <-u(Z) )
def tree_size(t):  # t=(judgment, [subtrees])
    j,ch=t; return size[j]+sum(tree_size(c) for c in ch)
pi_tree=('w',[('c0',[('X',[('Y',[])])]),('X',[('Z',[])])])
pi_judg={'w','c0','X','Y','Z'}
# local e+ (forward/backward through trusted steps of pi)
val={j:1 for j in A}; val.update({j:0 for j in D})
ch=True
while ch:
    ch=False
    for (P,c) in trusted:
        if all(val.get(p)==1 for p in P) and c not in val: val[c]=1; ch=True
        if val.get(c)==0:
            unk=[p for p in P if val.get(p)!=1]
            if len(unk)==1 and unk[0] not in val: val[unk[0]]=0; ch=True
print('e+_pi =',val)
# descent: w (0) <- t1 premises c0(0),X(1) -> move to c0 <- s premise X(1) -> output s. Unblocked.
# extracted refutation of {sigma}: s, plus trusted justification of X (T1 from Y), and t1 for c0->w.
# As a TREE, X is needed twice (premise of s and side premise of t1), each time via T1 from Y:
ext_tree=('w',[('c0',[('X',[('Y',[])])]),('X',[('Y',[])])])
ext_judg={'w','c0','X','Y'}
ds=lambda S: sum(size[j] for j in S)
print('pi:        tree size %d, distinct-judgment size %d'%(tree_size(pi_tree),ds(pi_judg)))
print('extracted: tree size %d, distinct-judgment size %d'%(tree_size(ext_tree),ds(ext_judg)))
print('X derivable for a {sigma}-refutation only via T1 from Y (u is not a sigma-step), so the minimal')
print('tree-size refutation of {sigma} is', tree_size(ext_tree), '> d = tree size of pi =', tree_size(pi_tree))
