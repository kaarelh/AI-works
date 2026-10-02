import sys
sys.setrecursionlimit(100000)
k=int(sys.argv[1]); d=int(sys.argv[2]); target=int(sys.argv[3])
# chainlen(T): longest chain inside set T (frozenset of indices). chain: i0<..<ir, {i0..i_{b-1}} in one block of pi_{ib}
def make():
    parts=[]
    memo={}
    def LC(T):
        if not T: return 0
        key=T
        if key in memo: return memo[key]
        r=0
        for j in T:
            lab=parts[j]
            for bb in range(k):
                T2=frozenset(x for x in T if x<j and lab[x]==bb)
                v=1+LC(T2)
                if v>r: r=v
        memo[key]=r; return r
    return parts,LC,memo
parts,LC,memo=make()
found=[None]
def labelings(i):
    def rec(j,cur,used):
        if j==i: yield tuple(cur); return
        for b in range(min(used+1,k)):
            cur.append(b); yield from rec(j+1,cur,max(used,b+1)); cur.pop()
    yield from rec(0,[],0)
best=[0]
def search():
    i=len(parts)
    if i>best[0]:
        best[0]=i; print('reached',i,flush=True)
    if i==target:
        found[0]=list(parts); return True
    for lab in labelings(i):
        ok=True
        for b in range(k):
            S=frozenset(j for j in range(i) if lab[j]==b)
            if LC(S)+1>d: ok=False;break
        if ok:
            parts.append(lab)
            if search(): return True
            parts.pop()
    return False
search()
print('target',target,'found' if found[0] else 'not found', 'best',best[0])
if found[0]:
    for i,l in enumerate(found[0]): print(i,l)
