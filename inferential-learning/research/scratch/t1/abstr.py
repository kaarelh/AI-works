# abstraction: sequence of k-partitions pi_i of [0..i-1]; chain i0<..<ir with {i0..i_{b-1}} in one block of pi_{ib}
# L(i)= max chain ending at i. constraint L(i)<=d. maximize m.
import sys, itertools
sys.setrecursionlimit(100000)
k=int(sys.argv[1]); d=int(sys.argv[2])
best=[0]
def search(parts, Lend):
    # parts: list of labelings lab_i: tuple of block labels for j<i
    m=len(parts)
    if m>best[0]:
        best[0]=m; print('m=',m, flush=True)
    i=m
    # choose labeling for new element i over j<i, labels in range(k), canonical (first-occurrence order)
    def labelings(j, cur, used):
        if j==i:
            yield tuple(cur); return
        for b in range(min(used+1,k)):
            cur.append(b)
            yield from labelings(j+1,cur, max(used,b+1))
            cur.pop()
    for lab in labelings(0,[],0):
        # compute longest chain ending at i: chain contained in a block B of lab, then i
        # longest chain within a set S: dp over elements of S in order: C_S(j)= 1+ max over blocks of pi_j restricted to S∩[j]
        ok=True; Li=0
        for b in range(k):
            S=[j for j in range(i) if lab[j]==b]
            if not S: continue
            # chains inside S: need dp: longest chain within subset T ending at j, where T subset of S; chain prefix must be in one block of pi_j and in S
            # longest chain within S ending at j = 1 + max over blocks B' of pi_j of longest chain within S∩B'
            memo={}
            def LC(T):
                # longest chain with all elements in frozenset T
                if not T: return 0
                if T in memo: return memo[T]
                r=0
                for j in T:
                    labj=parts[j]
                    for bb in range(k):
                        T2=frozenset(x for x in T if x<j and labj[x]==bb)
                        r=max(r,1+LC(T2))
                memo[T]=r; return r
            Li=max(Li,LC(frozenset(S)))
            if Li+1>d: ok=False; break
        if ok:
            parts.append(lab)
            search(parts,Lend)
            parts.pop()
search([],None)
print('final',k,d,best[0])
