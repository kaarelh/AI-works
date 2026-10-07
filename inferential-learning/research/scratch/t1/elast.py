import sys, itertools, functools
from terms import *
sys.setrecursionlimit(10000)
def universe(sig, N):
    by=ground_terms(sig,N)
    U=[t for n in range(1,N+1) for t in by[n]]
    return U
def make_checker(U):
    idx={t:i for i,t in enumerate(U)}
    lggcache={}
    def lgg_mask(mask):
        # returns bitmask of instance set of lgg of elements in mask (within U)
        if mask in lggcache: return lggcache[mask]
        ts=[U[i] for i in range(len(U)) if mask>>i&1]
        L=lgg_list(ts)
        inst=0
        for i,t in enumerate(U):
            if is_instance(t,L): inst|=1<<i
        lggcache[mask]=inst
        return inst
    return lgg_mask
def escapes(P_list, s, k, lgg_mask):
    # exists partition of P into <=k blocks, each block's lgg-instance-set excludes s
    n=len(P_list)
    bit_s=1<<s
    # assign elements greedily via DFS
    blocks=[0]*k
    def rec(j):
        if j==n: return True
        e=1<<P_list[j]
        tried_empty=False
        for b in range(k):
            if blocks[b]==0:
                if tried_empty: continue
                tried_empty=True
            nb=blocks[b]|e
            if not (lgg_mask(nb)&bit_s):
                old=blocks[b]; blocks[b]=nb
                if rec(j+1): return True
                blocks[b]=old
        return False
    return rec(0)
def max_elasticity(U,k,target_mask=None):
    lgg_mask=make_checker(U)
    n=len(U)
    if target_mask is None: target_mask=(1<<n)-1
    memo={}
    best_seq={}
    def R(P):
        if P in memo: return memo[P]
        Pl=[i for i in range(n) if P>>i&1]
        best=0; arg=None
        for s in range(n):
            if P>>s&1 or not (target_mask>>s&1): continue
            if escapes(Pl,s,k,lgg_mask):
                v=1+R(P|1<<s)
                if v>best: best=v; arg=s
        memo[P]=best; best_seq[P]=arg
        return best
    v=R(0)
    # reconstruct
    seq=[];P=0
    while best_seq.get(P) is not None:
        s=best_seq[P]; seq.append(U[s]); P|=1<<s
    return v,seq,len(memo)
if __name__=='__main__':
    sig=eval(sys.argv[1]); N=int(sys.argv[2]); k=int(sys.argv[3])
    U=universe(sig,N)
    print('|U|=',len(U))
    v,seq,ms=max_elasticity(U,k)
    print('k=',k,'max elasticity',v,'states',ms)
    print([show(t) for t in seq])
