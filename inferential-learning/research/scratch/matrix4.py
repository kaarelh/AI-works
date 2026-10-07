# Backtracking search for an n-valued matrix validating S and DN, with AC designation-preserving,
# bottom undesignated, and A1={q, p>q, p>F} satisfiable. (Witnesses {S,DN,AC} clean at every depth on {empty,A1}.)
import itertools, sys, time
def search(n,k,tlimit=600):
    D=set(range(k)); Fv=n-1; ND=[v for v in range(n) if v not in D]
    cells=[(a,b) for a in range(n) for b in range(n)]
    dom={}
    for a,b in cells:
        dom[(a,b)]= ND if (a not in D and b in D) else list(range(n))   # AC preservation
    T={}
    def f(a,b):
        if a is None or b is None: return None
        return T.get((a,b))
    cons=[]
    for a in range(n):
        cons.append(lambda a=a: (lambda x: None if x is None else x in D)(f(f(f(a,Fv),Fv),a)))
    for a in range(n):
        for b in range(n):
            for c in range(n):
                cons.append(lambda a=a,b=b,c=c: (lambda x: None if x is None else x in D)(f(f(a,f(b,c)),f(f(a,b),f(a,c)))))
    def a1_possible():
        for p in range(n):
            for q in D:
                x=f(p,q); y=f(p,Fv)
                if (x is None or x in D) and (y is None or y in D): return True
        return False
    t0=time.time(); cnt=[0]
    order=sorted(cells,key=lambda c:len(dom[c]))
    def bt(i):
        cnt[0]+=1
        if time.time()-t0>tlimit: raise TimeoutError
        for c in cons:
            r=c()
            if r is False: return None
        if not a1_possible(): return None
        if i==len(order): return dict(T)
        cell=order[i]
        for v in dom[cell]:
            T[cell]=v
            r=bt(i+1)
            if r: return r
            del T[cell]
        return None
    return bt(0),cnt[0],time.time()-t0
for n in [2,3,4]:
    for k in range(1,n):
        try:
            r,c,t=search(n,k)
            print('n=%d |D|=%d'%(n,k),'FOUND' if r else 'none','nodes',c,'%.1fs'%t)
            if r:
                print('  table:',[[r[(a,b)] for b in range(n)] for a in range(n)],'D=',list(range(k)),'bottom=',n-1); sys.exit()
        except TimeoutError: print('n=%d |D|=%d timeout'%(n,k))
